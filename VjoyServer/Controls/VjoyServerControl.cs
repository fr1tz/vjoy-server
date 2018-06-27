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
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace VjoyServer
{
    public partial class VjoyServerControl : UserControl
    {
        private VjoyDevice vjoyDevice;

        public VjoyServerControl()
        {
            InitializeComponent();
        }

        [Description("The vJoy Device Number (1-16)"), Category("Behavior")]
        public uint VjoyDeviceId
        {
            get;
            set;
        }

        private void UpdateVjoyDeviceStatus()
        {
            if (this.InvokeRequired)
            {
                this.BeginInvoke((MethodInvoker)delegate
                {
                    UpdateVjoyDeviceStatus();
                });
                return;
            }
            PictureBox pic = VjoyDeviceStatusPictureBox;
            Label label = feederStatus;
            VjoyDevice.Status status = this.vjoyDevice.GetStatus();
            bool disabled = false;
            switch (status)
            {
                case VjoyDevice.Status.Disabled:
                    pic.BackColor = Color.Transparent;
                    label.Text = "Disabled";
                    disabled = true;
                    break;
                case VjoyDevice.Status.Busy:
                    pic.BackColor = Color.DarkRed;
                    label.Text = "Busy";
                    break;
                case VjoyDevice.Status.Free:
                    pic.BackColor = Color.DarkGreen;
                    label.Text = "Free";
                    break;
                case VjoyDevice.Status.Acquired:
                    pic.BackColor = Color.LightGreen;
                    label.Text = "Acquired";
                    break;
                default:
                    pic.BackColor = Color.Transparent;
                    label.Text = "Unknown";
                    break;
            }
            ExportCheckBox.Checked = this.vjoyDevice.IsExported();
            ExportCheckBox.Visible = !disabled;
            ExportLabel.Visible = !disabled;
        }

        private void VjoyDevice_StatusChanged(object sender, EventArgs e)
        {
            UpdateVjoyDeviceStatus();
        }

        private void VjoyServerControl_Load(object sender, EventArgs e)
        {
            this.vjoyDevice = Program.VjoyInterface.GetDevice(VjoyDeviceId);
            this.vjoyDevice.StatusChanged += VjoyDevice_StatusChanged;
            this.vjoyDevice.ExportedChanged += VjoyDevice_StatusChanged;
            this.vjoyDeviceLabel.Text = string.Format("vJoy #{0}", VjoyDeviceId);
            UpdateVjoyDeviceStatus();
        }

        private void ExportCheckBox_Click(object sender, EventArgs e)
        {
            if (this.vjoyDevice != null)
                vjoyDevice.SetExported(ExportCheckBox.Checked);
        }
    }
}
