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
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace VjoyServer
{
    public class VjoyClient
    {
        IPAddress clientAddress;
        int clientId;
        TcpClient tcpClient;
        Object sendLock;
        VjoyController[] controllers;

        public VjoyClient(TcpClient tcpClient)
        {
            this.clientAddress = ((IPEndPoint)tcpClient.Client.RemoteEndPoint).Address;
            this.clientId = ((IPEndPoint)tcpClient.Client.RemoteEndPoint).Port;
            this.tcpClient = tcpClient;
            this.sendLock = new Object();
            this.controllers = new VjoyController[16];
            for (uint i = 0; i < 16; i++)
            {
                VjoyController controller = new VjoyController();
                VjoyDevice device = Program.VjoyInterface.GetDevice(i + 1);
                device.GetConfig().PropertyChanged += VjoyDeviceConfig_PropertyChanged;
                device.AddRemoteController(controller);
                this.controllers[i] = controller;
            }

            //this.setupThread = new Thread(SetupThread);
            //this.setupThread.Start();
            string lines = "";
            lines += string.Format("init {0} {1} {2}\n", Environment.MachineName,
                Program.NetworkInterface.GetUdpPort(), this.clientId);
            VjoyDevice[] vjoyDevices = Program.VjoyInterface.GetDevices();
            foreach (VjoyDevice vjoyDevice in vjoyDevices)
            {
                vjoyDevice.StatusChanged += VjoyDevice_StatusChanged;
                vjoyDevice.ExportedChanged += VjoyDevice_StatusChanged;
                uint id = vjoyDevice.GetVjoyDeviceId();
                string status = GetJoystickStatus(vjoyDevice);
                lines += string.Format("vjoy_status {0} {1}\n", id, status);
                foreach(string prop in vjoyDevice.GetConfig().GetProperties())
                    lines += string.Format("vjoy_config {0} {1}\n", id, prop);
            }
            Send(lines);
        }

        public IPAddress GetClientAddress()
        {
            return this.clientAddress;
        }

        public int GetClientId()
        {
            return this.clientId;
        }

        public int GetPort()
        {
            IPEndPoint endPoint = (IPEndPoint)this.tcpClient.Client.RemoteEndPoint;
            return endPoint.Port;
        }

        public void ProcessPacket(byte[] data)
        {
            if (data.Length < 3)
                return;
            if (data.Length == 3)
            {
                for (int controllerId = 0; controllerId < 16; controllerId++)
                    this.controllers[controllerId].GetJoystickState().Reset();
                return;
            }
            int pos = 3;
            int segments_header = DecodeUInt16(data[pos], data[pos+1]); pos += 2;
            for (int controllerId = 0; controllerId < 16; controllerId++)
            {
                if ((segments_header & 1<<controllerId) == 0)
                    continue;
                JoystickState joystickState = this.controllers[controllerId].GetJoystickState();
                joystickState.Reset();
                int axis_header = data[pos++];
                if ((axis_header & 1 << 0) > 0)
                    joystickState.axis_x = DecodeInt7(data[pos++]) / 127f;
                if ((axis_header & 1 << 1) > 0)
                    joystickState.axis_y = DecodeInt7(data[pos++]) / 127f;
                if ((axis_header & 1 << 2) > 0)
                    joystickState.axis_z = DecodeInt7(data[pos++]) / 127f;
                if ((axis_header & 1 << 3) > 0)
                    joystickState.axis_x_rot = DecodeInt7(data[pos++]) / 127f;
                if ((axis_header & 1 << 4) > 0)
                    joystickState.axis_y_rot = DecodeInt7(data[pos++]) / 127f;
                if ((axis_header & 1 << 5) > 0)
                    joystickState.axis_z_rot = DecodeInt7(data[pos++]) / 127f;
                if ((axis_header & 1 << 6) > 0)
                    joystickState.slider1 = DecodeInt7(data[pos++]) / 127f;
                if ((axis_header & 1 << 7) > 0)
                    joystickState.slider2 = DecodeInt7(data[pos++]) / 127f;
                //Log(string.Format("x: {0} y: {1}", axis_x, axis_y));
                int buttons_header = DecodeUInt16(data[pos], data[pos + 1]); pos += 2;
                if(buttons_header == 0)
                {
                    int button_idx;
                    while ((button_idx = data[pos++]) != 255)
                        joystickState.buttons[button_idx] = true;
                }
                else
                {
                    for(int button_group_idx = 0; button_group_idx < 16; button_group_idx++)
                    {
                        if ((buttons_header & 1 << button_group_idx) == 0)
                            continue;
                        int button_group = data[pos++];
                        for (int button_idx = 0; button_idx < 8; button_idx++)
                            if ((button_group & 1 << button_idx) > 0)
                                joystickState.buttons[8 * button_group_idx + button_idx] = true;
                    }
                }
            }

        }

        private int DecodeInt7(byte b)
        {
            return (b & 127) * ((b & 128) == 0 ? 1 : -1);
        }

        private int DecodeUInt16(byte b1, byte b2)
        {
            return ((UInt16)b1 << 8) | (UInt16)b2;
        }

        private void Log(string msg)
        {
            Program.Log.AddEntry(string.Format(" [{0}:{1}]: {2}\n", GetClientAddress().ToString(), GetPort(), msg));
        }

        private void Send(string data)
        {
            lock (this.sendLock)
            {
                byte[] bytes = Encoding.UTF8.GetBytes(data);
                try
                {
                    this.tcpClient.GetStream().Write(bytes, 0, bytes.Length);
                }
                catch (Exception e)
                {
                    Log(e.Message);
                    //Remove();
                    return;
                }
                
            }
        }

        private void SendLine(string format, params System.Object[] args)
        {
            lock (this.sendLock)
            {
                string cmdline = string.Format(format.Replace("\n", "") + "\n", args);
                byte[] bytes = Encoding.UTF8.GetBytes(cmdline);
                this.tcpClient.GetStream().Write(bytes, 0, bytes.Length);
            }
        }

        private void ReceiverThread()
        {
            string receiveBuffer = "";
            while (true)
            {
                byte[] buf = new byte[512];
                Int32 bytes;
                try
                {
                    bytes = this.tcpClient.GetStream().Read(buf, 0, buf.Length);
                }
                catch(Exception e)
                {
                    Log(e.Message);
                    //Remove();
                    return;
                }              
                string str = Encoding.UTF8.GetString(buf, 0, bytes);
                receiveBuffer += str;
                int msg_terminator_index;
                while ((msg_terminator_index = receiveBuffer.IndexOf('\0')) >= 0)
                {
                    string msg = receiveBuffer.Substring(0, msg_terminator_index);
                    receiveBuffer = receiveBuffer.Remove(0, msg_terminator_index + 1);
                    if (msg == "")
                        continue;
                    Log(msg);
                    string[] entry_fields = msg.Split(new string[] { "\n" }, 3, StringSplitOptions.None);
                    string level = entry_fields[0].Trim();
                    string source = entry_fields[1].Trim();
                    string content = entry_fields[2].Trim();
                    //ProcessLogMsg(level, source, content);
                }
            }
        }

        private string GetJoystickStatus(VjoyDevice vjoyDevice)
        {
            string status = "";
            if (vjoyDevice.IsExported())
            {
                switch (vjoyDevice.GetStatus())
                {
                    case VjoyDevice.Status.Acquired:
                    case VjoyDevice.Status.Busy:
                        status = "taken"; break;
                    case VjoyDevice.Status.Free:
                        status = "free"; break;
                }
            }
            return status;
        }

        private void VjoyDeviceConfig_PropertyChanged(object sender, PropertyChangedEventArgs e)
        {
            VjoyDeviceConfig config = (VjoyDeviceConfig)sender;
            uint vjoyDeviceId = config.GetVjoyDeviceId();
            string msg = string.Format("vjoy_config {0} {1} {2}\n", vjoyDeviceId, e.Name, e.Value);
            Send(msg);
        }
        

        private void VjoyDevice_StatusChanged(object sender, EventArgs e)
        {
            VjoyDevice vjoyDevice = (VjoyDevice)sender;
            uint vjoyDeviceId = vjoyDevice.GetVjoyDeviceId();
            string status = GetJoystickStatus(vjoyDevice);
            string msg = string.Format("vjoy_status {0} {1}\n", vjoyDeviceId, status);
            Send(msg);
        }
    }
}
