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
using System.Threading.Tasks;

using vJoyInterfaceWrap;

namespace VjoyServer
{
    public class PropertyChangedEventArgs : EventArgs
    {
        public string Name { get; private set; }
        public string Value { get; private set; }

        public PropertyChangedEventArgs(string name, string value)
        {
            Name = name;
            Value = value;
        }
    }

    public class VjoyDeviceConfig
    {
        private uint vjoyDeviceId;
        bool[] axis;
        int numButtons;

        public VjoyDeviceConfig(uint vjoyDeviceId)
        {
            this.vjoyDeviceId = vjoyDeviceId;
            this.axis = new bool[8];
            for (int i = 0; i < 8; i++)
                this.axis[i] = false;
            this.numButtons = 0;
        }

        public event EventHandler<PropertyChangedEventArgs> PropertyChanged;

        public uint GetVjoyDeviceId()
        {
            return this.vjoyDeviceId;
        }

        public void Update()
        {
            //if(this.vjoyDeviceId == 1) Program.Log.AddEntry(string.Format("Updating config for vjoy #{0}", this.vjoyDeviceId));

            bool[] oldAxis = new bool[8];
            for (int i = 0; i < 8; i++)
                oldAxis[i] = this.axis[i];
            int oldNumButtons = this.numButtons;

            vJoy vjoy = new vJoy();
            if (vjoy.GetVJDStatus(this.vjoyDeviceId) == VjdStat.VJD_STAT_MISS)
            {
                for (int i = 0; i < 8; i++)
                    this.axis[i] = false;
                this.numButtons = 0;
            }
            else
            {
                for (int i = 0; i < 8; i++)
                    this.axis[i] = vjoy.GetVJDAxisExist(this.vjoyDeviceId, HID_USAGES.HID_USAGE_X + i);
                this.numButtons = vjoy.GetVJDButtonNumber(this.vjoyDeviceId);
            }

            //for (int i = 0; i < 8; i++)
            //    if (this.vjoyDeviceId == 1) Program.Log.AddEntry(string.Format(" axis {0}: {1} -> {2}",i, oldAxis[i], this.axis[i]));
            //if (this.vjoyDeviceId == 1) Program.Log.AddEntry(string.Format(" num_buttons: {0} -> {1}", oldNumButtons, this.numButtons));

            if (this.axis[0] != oldAxis[0])
                OnPropertyChanged("axis_x", this.axis[0] ? "enabled" : "disabled");
            if (this.axis[1] != oldAxis[1])
                OnPropertyChanged("axis_y", this.axis[1] ? "enabled" : "disabled");
            if (this.axis[2] != oldAxis[2])
                OnPropertyChanged("axis_z", this.axis[2] ? "enabled" : "disabled");
            if (this.axis[3] != oldAxis[3])
                OnPropertyChanged("axis_x_rot", this.axis[3] ? "enabled" : "disabled");
            if (this.axis[4] != oldAxis[4])
                OnPropertyChanged("axis_y_rot", this.axis[4] ? "enabled" : "disabled");
            if (this.axis[5] != oldAxis[5])
                OnPropertyChanged("axis_z_rot", this.axis[5] ? "enabled" : "disabled");
            if (this.axis[6] != oldAxis[6])
                OnPropertyChanged("slider1", this.axis[6] ? "enabled" : "disabled");
            if (this.axis[7] != oldAxis[7])
                OnPropertyChanged("slider2", this.axis[7] ? "enabled" : "disabled");
            if (this.numButtons != oldNumButtons)
                OnPropertyChanged("num_buttons", this.numButtons.ToString());
        }

        public string[] GetProperties()
        {
            string[] props = new string[9];
            props[0] = string.Format("{0} {1}", "axis_x", this.axis[0] ? "enabled" : "disabled");
            props[1] = string.Format("{0} {1}", "axis_y", this.axis[1] ? "enabled" : "disabled");
            props[2] = string.Format("{0} {1}", "axis_z", this.axis[2] ? "enabled" : "disabled");
            props[3] = string.Format("{0} {1}", "axis_x_rot", this.axis[3] ? "enabled" : "disabled");
            props[4] = string.Format("{0} {1}", "axis_y_rot", this.axis[4] ? "enabled" : "disabled");
            props[5] = string.Format("{0} {1}", "axis_z_rot", this.axis[5] ? "enabled" : "disabled");
            props[6] = string.Format("{0} {1}", "slider1", this.axis[6] ? "enabled" : "disabled");
            props[7] = string.Format("{0} {1}", "slider2", this.axis[7] ? "enabled" : "disabled");
            props[8] = string.Format("{0} {1}", "num_buttons", this.numButtons.ToString());
            return props;
        }

        protected virtual void OnPropertyChanged(PropertyChangedEventArgs e)
        {
            PropertyChanged?.Invoke(this, e);
        }

        protected virtual void OnPropertyChanged(string name, string value)
        {
            //if (this.vjoyDeviceId == 1) Program.Log.AddEntry(string.Format(" property changed: {0} = {1}", name, value));
            PropertyChangedEventArgs e = new PropertyChangedEventArgs(name, value);
            PropertyChanged?.Invoke(this, e);
        }
       
    }
}
