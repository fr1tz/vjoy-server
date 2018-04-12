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
    public class RemoteController
    {
        const string vrcFileName = "vJoyServerVRC.tar";

        TcpClient tcpClient;
        IPAddress address;
        int tcpPort;
        int controllerId;
        VjoyDevice vjoyDevice;
        Gui activeGui;
        JoystickState joystickState;
        Thread setupThread;
        Thread receiverThread;
        Object sendLock;

        public RemoteController(IPAddress address, int tcpPort)
        {
            this.tcpClient = new TcpClient();
            this.address = address;
            this.tcpPort = tcpPort;
            this.controllerId = -1;
            this.vjoyDevice = null;
            this.activeGui = Gui.None;
            this.joystickState = new JoystickState();
            this.setupThread = new Thread(SetupThread);
            this.setupThread.Start();
            this.sendLock = new Object();
        }

        enum Gui
        {
            None,
            OptionsScreen,
            JoystickScreen
        };

        public int GetControllerId()
        {
            return this.controllerId;
        }

        public IPAddress GetAddress()
        {
            return this.address;
        }

        public JoystickState GetJoystickState()
        {
            lock (this.joystickState)
            {
                return this.joystickState;
            }
        }

        public void ProcessJoystickStatePacket(byte[] data)
        {
            lock (this.joystickState)
            {
                bool old_button_state = this.joystickState.buttons[0];

                this.joystickState.axis_x = DecodeInt7(data[3]) / 127f;
                this.joystickState.axis_y = DecodeInt7(data[4]) / 127f;
                this.joystickState.axis_z = DecodeInt7(data[5]) / 127f;
                this.joystickState.axis_x_rot = DecodeInt7(data[6]) / 127f;
                this.joystickState.axis_y_rot = DecodeInt7(data[7]) / 127f;
                this.joystickState.axis_z_rot = DecodeInt7(data[8]) / 127f;
                this.joystickState.slider1 = DecodeInt7(data[9]) / 127f;
                this.joystickState.slider2 = DecodeInt7(data[10]) / 127f;
                for (int i = 0; i < 8; i++)
                    this.joystickState.buttons[i] = (data[11] & (1 << i)) > 0;
                for (int i = 0; i < 8; i++)
                    this.joystickState.buttons[8 + i] = (data[12] & (1 << i)) > 0;

                if (old_button_state != this.joystickState.buttons[0])
                    Program.Log.AddEntry(string.Format("Button 1 state: {0}", this.joystickState.buttons[0]));
            }

            if (this.vjoyDevice != null)
                this.vjoyDevice.UpdateJoystickState();
        }

        private void Remove()
        {
            if (this.vjoyDevice != null)
                this.vjoyDevice.RemoveRemoteController(this);
            this.vjoyDevice = null;
        }

        private int DecodeInt7(byte b)
        {
            return (b & 127) * ((b & 128) == 0 ? 1 : -1);
        }

        private void Log(string msg)
        {
            Program.Log.AddEntry(string.Format(" [{0}:{1}]: {2}\n", this.address.ToString(), this.tcpPort, msg));
        }

        private bool Connect(IPAddress address, int port)
        {
            try
            {
                this.tcpClient.Connect(this.address, this.tcpPort);
            }
            catch (Exception e)
            {
                Log(string.Format("Failed to connect: {0}", e.Message));
                return false;
            }
            return true;
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
                    Remove();
                    return;
                }
                
            }
        }

        private void SendCmd(string format, params System.Object[] args)
        {
            lock (this.sendLock)
            {
                string cmdline = string.Format(format.Replace("\n", "") + "\n", args);
                byte[] bytes = Encoding.UTF8.GetBytes(cmdline);
                this.tcpClient.GetStream().Write(bytes, 0, bytes.Length);
            }
        }

        private void SetupThread()
        {
            if (!Connect(this.address, this.tcpPort))
                return;

            this.controllerId = ((IPEndPoint)this.tcpClient.Client.LocalEndPoint).Port;

            byte[] vrcData;
            try
            {
                vrcData = File.ReadAllBytes(vrcFileName);
            }
            catch(Exception e)
            {
                Log(string.Format("Error reading {0}: {1}", vrcFileName, e.Message));
                return;
            }

            string cmds = "";
            VjoyDevice[] vjoyDevices = Program.VjoyInterface.GetDevices();
            cmds += string.Format("/set_var SERVER_NAME '{0}'\n", Environment.MachineName);
            cmds += string.Format("/set_var CONTROLLER_ID '{0}'\n", GetControllerId());
            cmds += string.Format("/set_var SEND_UPDATE_ADDR 'udp!$0!{0}'\n", Program.RemoteInterface.GetUdpPort());
            cmds += string.Format("/set_var ACTIVE_JOYSTICK_ID '{0}'\n", 0);
            foreach (VjoyDevice vjoyDevice in vjoyDevices)
            {
                vjoyDevice.StatusChanged += VjoyDevice_StatusChanged;
                vjoyDevice.ExportedChanged += VjoyDevice_StatusChanged;
                uint id = vjoyDevice.GetVjoyDeviceId();
                string status = GetJoystickStatus(vjoyDevice);
                cmds += string.Format("/set_var JOYSTICK_STATUS/{0} '{1}'\n", id, status);
            }             
            cmds += string.Format("/load_vrc '{0}'\n", vrcData.Length);
            byte[] cmdsData = Encoding.UTF8.GetBytes(cmds);

            byte[] data = new byte[cmdsData.Length + vrcData.Length];
            Array.Copy(cmdsData, data, cmdsData.Length);
            Array.Copy(vrcData, 0, data, cmdsData.Length, vrcData.Length);
            this.tcpClient.GetStream().Write(data, 0, data.Length);

            this.activeGui = Gui.OptionsScreen;

            this.receiverThread = new Thread(ReceiverThread);
            this.receiverThread.Start();
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
                    Remove();
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
                    ProcessLogMsg(level, source, content);
                }
            }
        }

        private void ProcessLogMsg(string level, string source, string content)
        {
            string[] source_nodes = source.Split(new char[] { '/' });
            if (source == "vrchost/vrc")
            {
                string[] words = content.Split(new char[] { ' ' });
                if(words.Length == 2 && words[0] == "joystick_request")
                {
                    uint id = uint.Parse(words[1]);
                    if(id == 0)
                    {
                        if (this.vjoyDevice != null)
                            this.vjoyDevice.RemoveRemoteController(this);
                        this.vjoyDevice = null;
                    }
                    else
                    {
                        VjoyDevice oldVjoyDevice = this.vjoyDevice;
                        this.vjoyDevice = Program.VjoyInterface.GetDevice(id);
                        if (this.vjoyDevice == null)
                            return;
                        if (this.vjoyDevice.AddRemoteController(this) == false)
                            return;
                        if (oldVjoyDevice != null)
                            oldVjoyDevice.RemoveRemoteController(this);
                    }
                    string cmd = string.Format("/set_var ACTIVE_JOYSTICK_ID '{0}'\n", id);
                    Send(cmd);
                }
            }
            /*
            else if (this.activeGui == Gui.JoystickScreen
            && source.EndsWith("vrc")
            && content == "joystick disabled")
            {
                if (this.vjoyDevice == null)
                    return;
                this.vjoyDevice.RemoveRemoteController(this);
                string cmd = string.Format("/set_var ACTIVE_JOYSTICK_ID '{0}'\n", 0);
                Send(cmd);
                this.activeGui = Gui.OptionsScreen;
            }
            */
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

        private void VjoyDevice_StatusChanged(object sender, EventArgs e)
        {
            VjoyDevice vjoyDevice = (VjoyDevice)sender;
            uint id = vjoyDevice.GetVjoyDeviceId();
            string status = GetJoystickStatus(vjoyDevice);
            string msg = string.Format("/set_var JOYSTICK_STATUS/{0} '{1}'\n", id, status);
            Send(msg);
        }
    }
}
