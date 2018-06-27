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
    public class VjoyInterface
    {
        private vJoy vjoy;
        private VjoyDevice[] vjoyDevices;
        private Thread monitorStatusThread;
        private Thread monitorConfigThread;

        public VjoyInterface()
        {
            this.vjoy = new vJoy();
            this.vjoyDevices = new VjoyDevice[16];
            for (uint i = 0; i < 16; i++)
                this.vjoyDevices[i] = new VjoyDevice(this, i + 1);
            this.monitorStatusThread = new Thread(MonitorStatusThread);
            this.monitorConfigThread = new Thread(MonitorConfigThread);
        }

        public int Init()
        {
            if (!this.vjoy.vJoyEnabled())
            {
                Program.Log.AddEntry("vJoy driver not installed");
                return 1;
            }
            // Test if our vJoyInterface DLL matches the driver.
            UInt32 DllVer = 0, DrvVer = 0;
            bool match = this.vjoy.DriverMatch(ref DllVer, ref DrvVer);
            if (!match)
            {
                Program.Log.AddEntry(string.Format(
                    "Version of vJoy driver ({0:X}) does not match DLL version ({1:X})",
                    DrvVer,
                    DllVer
                ));
                return 2;
            }
            Program.Log.AddEntry(string.Format(
                "Version of vJoy driver matches DLL version ({0:X})",
                DllVer
            ));
            return 0;
        }

        public UInt32 GetDllVersion()
        {
            UInt32 DllVer = 0, DrvVer = 0;
            this.vjoy.DriverMatch(ref DllVer, ref DrvVer);
            return DllVer;
        }

        public UInt32 GetDriverVersion()
        {
            UInt32 DllVer = 0, DrvVer = 0;
            this.vjoy.DriverMatch(ref DllVer, ref DrvVer);
            return DrvVer;
        }

        public string GetDriverInformation()
        {
            return string.Format(
                "vJoy Driver Information:\n" +
                "   Vendor:  {0}\n" +
                "   Product: {1}\n" +
                "   Version: {2}",
                this.vjoy.GetvJoyManufacturerString(),
                this.vjoy.GetvJoyProductString(),
                this.vjoy.GetvJoySerialNumberString()
            );
        }

        public void StartMonitoring()
        {
            lock (this.monitorStatusThread) this.monitorStatusThread.Start();
            //lock (this.monitorConfigThread) this.monitorConfigThread.Start();
        }

        public void StopMonitoring()
        {
            lock (this.monitorStatusThread) this.monitorStatusThread.Abort();
            //lock (this.monitorConfigThread) this.monitorConfigThread.Abort();
        }

        public VjoyDevice GetDevice(uint vjoyDeviceId)
        {
            if (vjoyDeviceId < 1 || vjoyDeviceId > 16)
                return null;
            return this.vjoyDevices[vjoyDeviceId - 1];
        }

        public VjoyDevice[] GetDevices()
        {
            return this.vjoyDevices.Clone() as VjoyDevice[];
        }

        private void MonitorStatusThread()
        {
            while (true)
            {
                for (uint i = 0; i < 16; i++)
                    this.vjoyDevices[i].UpdateStatus();
                Thread.Sleep(250);
            }
        }

        private void MonitorConfigThread()
        {
            while (true)
            {
                Thread.Sleep(5000);
                for (uint i = 0; i < 16; i++)
                    this.vjoyDevices[i].GetConfig().Update();
            }
        }
    }
}
