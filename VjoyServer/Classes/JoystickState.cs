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

namespace VjoyServer
{
    public class JoystickState
    {
        public float axis_x;
        public float axis_y;
        public float axis_z;
        public float axis_x_rot;
        public float axis_y_rot;
        public float axis_z_rot;
        public float slider1;
        public float slider2;
        public bool[] buttons;

        public JoystickState()
        {
            axis_x = 0;
            axis_y = 0;
            axis_z = 0;
            axis_x_rot = 0;
            axis_y_rot = 0;
            axis_z_rot = 0;
            slider1 = 0;
            slider2 = 0;
            buttons = new bool[16];
            for (int i = 0; i < 16; i++)
                buttons[i] = false;
        }

        public void Add(JoystickState joystickState)
        {
            axis_x += joystickState.axis_x;
            axis_y += joystickState.axis_y;
            axis_z += joystickState.axis_z;
            axis_x_rot += joystickState.axis_x_rot;
            axis_y_rot += joystickState.axis_y_rot;
            axis_z_rot += joystickState.axis_z_rot;
            slider1 += joystickState.slider1;
            slider2 += joystickState.slider2;
            for (int i = 0; i < 16; i++)
                if(joystickState.buttons[i])
                    buttons[i] = true;
        }

        public void Clamp()
        {
            axis_x = ClampAxis(axis_x);
            axis_y = ClampAxis(axis_y);
            axis_z = ClampAxis(axis_z);
            axis_x_rot = ClampAxis(axis_x_rot);
            axis_y_rot = ClampAxis(axis_y_rot);
            axis_z_rot = ClampAxis(axis_z_rot);
            slider1 = ClampAxis(slider1);
            slider2 = ClampAxis(slider2);
        }

        private float ClampAxis(float val)
        {
            if (val > 1.0)
                return 1.0f;
            else if (val < -1.0)
                return -1.0f;
            else
                return val;
        }
    }
}
