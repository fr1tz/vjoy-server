// Copyright © 2017, 2018 Michael Goldener <mg@wasted.ch>
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Net.NetworkInformation;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Reflection;

namespace VjoyServer
{
    public class RemoteInterface
    {
        List<RemoteController> remoteControllers;
        UdpClient udpClient;
        Thread datagramReaderThread;
        Thread announcerThread;
        Object sendLock;

        public RemoteInterface()
        {
            this.remoteControllers = new List<RemoteController>();
            this.sendLock = new object();
        }

        public void Init()
        {
            this.udpClient = new UdpClient(AddressFamily.InterNetwork);
            this.udpClient.EnableBroadcast = true;
            this.datagramReaderThread = new Thread(DatagramReaderThread);
            this.datagramReaderThread.Start();
            this.announcerThread = new Thread(AnnouncerThread);
            this.announcerThread.Start();
        }

        public int GetUdpPort()
        {
            IPEndPoint endPoint = (IPEndPoint)this.udpClient.Client.LocalEndPoint;
            return endPoint.Port;
        }

        private IPAddress GetBroadcastAddress(IPAddress address, IPAddress netmask)
        {
            byte[] b1 = address.GetAddressBytes();
            byte[] b2 = netmask.GetAddressBytes();
            int len = b1.Length;
            byte[] b3 = new byte[len];
            for (int i = 0; i < len; i++)
                b3[i] = (byte)(b1[i] | (b2[i] ^ 255));
            return new IPAddress(b3);
        }

        private bool IsPrivateAddress(IPAddress address)
        {
            byte[] b = address.GetAddressBytes();
            switch (b[0])
            {
                case 10: return true;
                case 172: return (b[1] <= 31 && b[1] >= 15);
                case 192: return (b[1] == 168);
            }
            return false;
        }

        private void DatagramReaderThread()
        {
            while (true)
            {
                if (this.udpClient.Available > 0)
                    ReadDatagram();
                else
                    Thread.Sleep(50);
            }
        }

        private void AnnouncerThread()
        {
            while (true)
            {
                SendAnnounce();
                Thread.Sleep(2500);
            }
        }

        private void ReadDatagram()
        {
            IPEndPoint source = new IPEndPoint(IPAddress.Any, 0);
            byte[] data = this.udpClient.Receive(ref source);
            string msg = Encoding.ASCII.GetString(data);
            if (data.Length == 2 && data[0] == 0 && data[1] == 1)
            {
                //Program.Log.Add("Got info request");
                Assembly assembly = Assembly.GetExecutingAssembly();
                Stream stream = assembly.GetManifestResourceStream("VjoyServer.VRC.icon.icon.png");
                byte[] icon_data = new byte[stream.Length];
                stream.Read(icon_data, 0, icon_data.Length);

                string host = Environment.MachineName;
                string desc = "Vjoy Server";
                string icon = Convert.ToBase64String(icon_data);
                msg = string.Format(
                    "#service\nhost: {0}\ndesc: {1}\nicon: {2}\n",
                    host,
                    desc,
                    icon
                    );
                data = Encoding.ASCII.GetBytes(msg);
                lock (this.sendLock) this.udpClient.Send(data, data.Length, source);
            }
            else if (data.Length == 32 && data[0] == 0 && data[1] == 2)
            {
                //Program.Log.Add("Got service request");
                int tcpPort = ((UInt16)data[2] << 8) | (UInt16)data[3];
                RemoteController vrcHost = new RemoteController(source.Address, tcpPort);
                this.remoteControllers.Add(vrcHost);
            }
            else if (data.Length == 16 && data[0] == 10)
            {
                int controllerId = ((UInt16)data[1] << 8) | (UInt16)data[2];
                foreach(RemoteController rc in this.remoteControllers)
                {
                    if (rc.GetControllerId() == controllerId)
                        rc.ProcessJoystickStatePacket(data);
                }
            }
        }

        private void SendAnnounce()
        {
            byte[] bytes = Encoding.ASCII.GetBytes("#VrcHost-AP.HB");
            NetworkInterface[] adapters = NetworkInterface.GetAllNetworkInterfaces();
            foreach (NetworkInterface adapter in adapters)
            {
                IPInterfaceProperties properties = adapter.GetIPProperties();
                foreach (UnicastIPAddressInformation ip in properties.UnicastAddresses)
                {
                    if (ip.Address.AddressFamily == AddressFamily.InterNetwork
                    && IsPrivateAddress(ip.Address))
                    {
                        IPAddress broadcastAddress = GetBroadcastAddress(ip.Address, ip.IPv4Mask);
                        lock (this.sendLock) this.udpClient.Send(bytes, bytes.Length, new IPEndPoint(broadcastAddress, 44000));
                    }
                }
            }
        }
    }
}
