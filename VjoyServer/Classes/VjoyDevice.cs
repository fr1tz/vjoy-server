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
        private Status status;
        private Object statusLock;
        private bool exported;
        private Object exportedLock;
        private List<RemoteController> remoteControllers;

        public VjoyDevice(VjoyInterface vjoyInterface, uint vjoyDeviceId)
        {
            if (vjoyDeviceId <= 0 || vjoyDeviceId > 16)
                throw new ArgumentException("Invalid device ID");
            this.vjoy = new vJoy();
            this.vjoyDeviceId = vjoyDeviceId;
            this.status = Status.Unknown;
            this.statusLock = new object();
            this.exported = true;
            this.exportedLock = new object();
            this.remoteControllers = new List<RemoteController>();
        }

        public event EventHandler StatusChanged;
        public event EventHandler ExportedChanged;

        public enum Status
        {
            Unknown,
            Missing,
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
            foreach(RemoteController rc in this.remoteControllers)
                joystickState.Add(rc.GetJoystickState());
            joystickState.Clamp();

            uint buttons = 0;
            for (int i = 0; i < 16; i++)
                if (joystickState.buttons[i])
                    buttons |= (uint)1 << i;

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
                Buttons = buttons
            };

            lock (this.vjoy)
            {
                this.vjoy.UpdateVJD(this.vjoyDeviceId, ref iReport);
            }
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

        public bool AddRemoteController(RemoteController rc)
        {
            lock (this.remoteControllers)
            {
                if (GetStatus() != Status.Acquired)
                    if (!Acquire())
                        return false;
                this.remoteControllers.Add(rc);
            }            
            return true;
        }

        public void RemoveRemoteController(RemoteController rc)
        {
            lock (this.remoteControllers)
            {
                this.remoteControllers.Remove(rc);
                if (this.remoteControllers.Count == 0)
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
                        newStatus = Status.Missing;
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
                        newStatus = Status.Unknown;
                        break;
                };
                if (newStatus != oldStatus)
                {
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
