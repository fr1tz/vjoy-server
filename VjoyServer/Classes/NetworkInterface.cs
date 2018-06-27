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
    public class NetworkInterface
    {
        const int VJIPP = 1; // vJoy IP Protocol version

        List<VRC> VRCs;
        List<VjoyClient> vjoyClients;
        TcpListener tcpListener;
        UdpClient udpClient;
        Thread tcpListenerThread;
        Thread datagramReaderThread;
        Thread announcerThread;
        Object sendLock;

        public NetworkInterface()
        {
            this.VRCs = new List<VRC>();
            this.vjoyClients = new List<VjoyClient>();
            this.sendLock = new object();
        }

        public void Init()
        {
            this.tcpListener = new TcpListener(IPAddress.Any, 0);
            tcpListener.Start();
            Log(string.Format("Listening on TCP port {0}", GetTcpPort()));
            this.udpClient = new UdpClient(AddressFamily.InterNetwork);
            this.udpClient.EnableBroadcast = true;
            this.tcpListenerThread = new Thread(TcpListenerThread);
            this.tcpListenerThread.Start();
            this.datagramReaderThread = new Thread(DatagramReaderThread);
            this.datagramReaderThread.Start();
            this.announcerThread = new Thread(AnnouncerThread);
            this.announcerThread.Start();
        }

        public int GetTcpPort()
        {
            IPEndPoint endPoint = (IPEndPoint)this.tcpListener.LocalEndpoint;
            return endPoint.Port;
        }

        public int GetUdpPort()
        {
            IPEndPoint endPoint = (IPEndPoint)this.udpClient.Client.LocalEndPoint;
            return endPoint.Port;
        }

        private void Log(string msg)
        {
            Program.Log.AddEntry(string.Format("NetworkInterface: {0}\n", msg));
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

        private void TcpListenerThread()
        {
            while (true)
            {
                TcpClient tcpClient = tcpListener.AcceptTcpClient();
                VjoyClient rc = new VjoyClient(tcpClient);
                this.vjoyClients.Add(rc);
            }
        }

        private void AnnouncerThread()
        {
            while (true)
            {
                //PrivateNetworkBroadcast("#VrcHost-AP.HB", 44000);
                string msg = string.Format("#Vjoy-Server {0} {1} {2}",
                    VJIPP, GetTcpPort(), Environment.MachineName);
                PrivateNetworkBroadcast(msg, 44001);
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
                Stream stream = assembly.GetManifestResourceStream("VjoyServer.Graphics.icon.icon.png");
                byte[] icon_data = new byte[stream.Length];
                stream.Read(icon_data, 0, icon_data.Length);

                string host = Environment.MachineName;
                string desc = "vJoy Server";
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
                VRC rc = new VRC(source.Address, tcpPort);
                this.VRCs.Add(rc);
            }
            else if (data[0] == 10)
            {
                int clientId = ((UInt16)data[1] << 8) | (UInt16)data[2];
                foreach (VjoyClient vjoyClient in this.vjoyClients)
                {
                    if (vjoyClient.GetClientId() == clientId && vjoyClient.GetClientAddress().Equals(source.Address))
                    {
                        vjoyClient.ProcessPacket(data);
                        foreach (VjoyDevice device in Program.VjoyInterface.GetDevices())
                            if(device.IsExported())
                                device.UpdateJoystickState();
                        return;
                    }
                }
                foreach (VRC rc in this.VRCs)
                {
                    if (rc.GetControllerId() == clientId)
                    {
                        rc.ProcessJoystickStatePacket(data);
                        return;
                    }
                }
            }
        }

        private void PrivateNetworkBroadcast(string msg, int port)
        {
            byte[] bytes = Encoding.ASCII.GetBytes(msg);
            System.Net.NetworkInformation.NetworkInterface[] adapters = System.Net.NetworkInformation.NetworkInterface.GetAllNetworkInterfaces();
            foreach (System.Net.NetworkInformation.NetworkInterface adapter in adapters)
            {
                IPInterfaceProperties properties = adapter.GetIPProperties();
                foreach (UnicastIPAddressInformation ip in properties.UnicastAddresses)
                {
                    if (ip.Address.AddressFamily == AddressFamily.InterNetwork
                    && IsPrivateAddress(ip.Address))
                    {
                        IPAddress broadcastAddress = GetBroadcastAddress(ip.Address, ip.IPv4Mask);
                        lock (this.sendLock) this.udpClient.Send(bytes, bytes.Length, new IPEndPoint(broadcastAddress, port));
                    }
                }
            }
        }
    }
}
