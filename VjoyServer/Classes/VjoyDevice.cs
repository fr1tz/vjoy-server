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
using System.Text;
using System.Threading;
using System.Threading.Tasks;

using vJoyInterfaceWrap;

namespace VjoyServer
{
    public class VjoyDevice
    {
        private vJoy vjoy;
        private uint vjoyDeviceId;
        private VjoyDeviceConfig config;
        private Status status;
        private Object statusLock;
        private bool exported;
        private Object exportedLock;
        private List<VjoyController> controllers;

        public VjoyDevice(VjoyInterface vjoyInterface, uint vjoyDeviceId)
        {
            if (vjoyDeviceId < 1 || vjoyDeviceId > 16)
                throw new ArgumentException("Invalid device ID");
            this.vjoy = new vJoy();
            this.vjoyDeviceId = vjoyDeviceId;
            this.config = new VjoyDeviceConfig(vjoyDeviceId);
            this.status = Status.Disabled;
            this.statusLock = new object();
            this.exported = true;
            this.exportedLock = new object();
            this.controllers = new List<VjoyController>();
        }

        public event EventHandler StatusChanged;
        public event EventHandler ExportedChanged;

        public enum Status
        {
            Disabled,
            Busy,
            Free,
            Acquired
        }

        public uint GetVjoyDeviceId()
        {
            return this.vjoyDeviceId;
        }

        public void UpdateJoystickState()
        {
            JoystickState joystickState = new JoystickState();
            foreach(VjoyController controller in this.controllers)
                joystickState.Add(controller.GetJoystickState());
            joystickState.Clamp();

            uint buttons1 = 0;
            for (int i = 0; i < 32; i++)
                if (joystickState.buttons[i])
                    buttons1 |= (uint)1 << i;
            uint buttons2 = 0;
            for (int i = 0; i < 32; i++)
                if (joystickState.buttons[32+i])
                    buttons2 |= (uint)1 << i;
            uint buttons3 = 0;
            for (int i = 0; i < 32; i++)
                if (joystickState.buttons[64+i])
                    buttons3 |= (uint)1 << i;
            uint buttons4 = 0;
            for (int i = 0; i < 32; i++)
                if (joystickState.buttons[96+i])
                    buttons4 |= (uint)1 << i;

            vJoy.JoystickState iReport = new vJoy.JoystickState
            {
                bDevice = (byte)this.vjoyDeviceId,
                bHats = 0xFFFFFFFF,
                bHatsEx1 = 0xFFFFFFFF,
                bHatsEx2 = 0xFFFFFFFF,
                bHatsEx3 = 0xFFFFFFFF,
                AxisX = (int)((joystickState.axis_x + 1) / 2 * 0x8000),
                AxisY = (int)((joystickState.axis_y + 1) / 2 * 0x8000),
                AxisZ = (int)((joystickState.axis_z + 1) / 2 * 0x8000),
                AxisXRot = (int)((joystickState.axis_x_rot + 1) / 2 * 0x8000),
                AxisYRot = (int)((joystickState.axis_y_rot + 1) / 2 * 0x8000),
                AxisZRot = (int)((joystickState.axis_z_rot + 1) / 2 * 0x8000),
                Slider = (int)((joystickState.slider1 + 1) / 2 * 0x8000),
                Dial = (int)((joystickState.slider2 + 1) / 2 * 0x8000),
                Buttons = buttons1,
                ButtonsEx1 = buttons2,
                ButtonsEx2 = buttons3,
                ButtonsEx3 = buttons4
            };

            lock (this.vjoy)
            {
                this.vjoy.UpdateVJD(this.vjoyDeviceId, ref iReport);
            }
        }

        public VjoyDeviceConfig GetConfig()
        {
            return this.config;
        }

        public Status GetStatus()
        {
            lock (this.statusLock)
            {
                return this.status;
            }           
        }

        public void SetExported(bool exported)
        {
            lock (this.exportedLock)
            {
                if (this.exported == exported)
                    return;
                this.exported = exported;
            }
            OnExportedChanged();
        }

        public bool IsExported()
        {
            lock (this.exportedLock)
            {
                return this.exported;
            }            
        }

        public bool AddRemoteController(VjoyController rc)
        {
            if (!IsExported())
                return false;

            lock (this.controllers)
            {
                if (GetStatus() != Status.Acquired)
                    if (!Acquire())
                        return false;
                this.controllers.Add(rc);
            }            
            return true;
        }

        public void RemoveRemoteController(VjoyController rc)
        {
            lock (this.controllers)
            {
                this.controllers.Remove(rc);
                if (this.controllers.Count == 0)
                    Release();
            }
        }

        public void UpdateStatus()
        {
            lock (this.statusLock)
            {
                Status oldStatus, newStatus;
                oldStatus = this.status;
                switch (this.vjoy.GetVJDStatus(this.vjoyDeviceId))
                {
                    case VjdStat.VJD_STAT_MISS:
                        newStatus = Status.Disabled;
                        break;
                    case VjdStat.VJD_STAT_BUSY:
                        newStatus = Status.Busy;
                        break;
                    case VjdStat.VJD_STAT_FREE:
                        newStatus = Status.Free;
                        break;
                    case VjdStat.VJD_STAT_OWN:
                        newStatus = Status.Acquired;
                        break;
                    default:
                        newStatus = Status.Disabled;
                        break;
                };
                if (newStatus != oldStatus)
                {
                    if (oldStatus == Status.Disabled && newStatus != Status.Disabled)
                        this.config.Update();
                    this.status = newStatus;
                    OnStatusChanged();
                }
            }
        }

        protected virtual void OnStatusChanged()
        {
            StatusChanged?.Invoke(this, null);
        }

        protected virtual void OnExportedChanged()
        {
            ExportedChanged?.Invoke(this, null);
        }

        private void Log(string msg)
        {
            Program.Log.AddEntry(string.Format("vJoy #{0}: {1}\n", this.vjoyDeviceId, msg));
        }

        private bool Acquire()
        {
            lock (this.vjoy)
            {
                if (this.vjoy.GetVJDStatus(this.vjoyDeviceId) != VjdStat.VJD_STAT_FREE)
                    return false;
                if (!this.vjoy.AcquireVJD(this.vjoyDeviceId))
                    return false;
                this.vjoy.ResetVJD(this.vjoyDeviceId);
                return true;
            }
        }

        private void Release()
        {
            lock (this.vjoy)
            {
                this.vjoy.ResetVJD(this.vjoyDeviceId);
                this.vjoy.RelinquishVJD(this.vjoyDeviceId);
            }
        }
    }
}
