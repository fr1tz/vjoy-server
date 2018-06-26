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
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Windows.Forms;

using vJoyInterfaceWrap;

namespace VjoyServer
{
    public partial class MainForm : Form
    {
        private VjoyServerControl[] serverControls;

        public MainForm()
        {
            InitializeComponent();
            VjoyServerControls.Visible = false;
            InitErrorPanel.Visible = false;
            Init();
            AppendLog(Program.Log.Get());
            Program.Log.NewLogEntry += NewLogEntry;
        }

        private void Init()
        {
            Program.Log.AddEntry("Initialization started");
            int error = Program.VjoyInterface.Init();
            if (error == 0)
            {
                VjoyServerControls.Visible = true;
                InitErrorPanel.Visible = false;
                this.serverControls = new VjoyServerControl[16];
                for (uint i = 0; i < 16; i++)
                {
                    VjoyServerControl control = new VjoyServerControl();
                    control.VjoyDeviceId = i + 1;
                    VjoyServerControls.Controls.Add(control);
                    this.serverControls[i] = control;
                }
                Program.NetworkInterface.Init();
                Program.VjoyInterface.StartMonitoring();
                Program.Log.AddEntry("Initialization successful");
            }
            else if(error == 1)
            {
                Program.Log.AddEntry("Initialization failed");
                VjoyServerControls.Visible = false;
                InitErrorPanel.Visible = true;
                InitErrorRichTextBox.Text = "vJoy driver not installed.\n" +
                    "Visit http://vjoystick.sourceforge.net to download the driver.\n" +
                    "After downloading and installing the driver, click the retry button below.";
            }
            else if(error == 2)
            {
                Program.Log.AddEntry("Initialization failed");
                UInt32 DllVer = Program.VjoyInterface.GetDllVersion();
                UInt32 DrvVer = Program.VjoyInterface.GetDriverVersion();
                VjoyServerControls.Visible = false;
                InitErrorPanel.Visible = true;
                InitErrorRichTextBox.Text = string.Format(
                    "The version of the operating system's vJoy driver is not compatible " +
                    "with this version of vJoy Server.\n\n" +
                    "Operating system vJoy driver version: {0:X}\n" +
                    "vJoy Server vJoyInterface.dll version: {1:X}",
                    DrvVer,
                    DllVer
                );
            }
        }

        private void AppendLog(string msg)
        {
            LogRichTextBox.Text += msg;
            LogRichTextBox.SelectionStart = LogRichTextBox.Text.Length;
            LogRichTextBox.ScrollToCaret();
        }

        private void NewLogEntry(object sender, NewLogEntryEventArgs e)
        {
            if (this.InvokeRequired)
            {
                this.BeginInvoke((MethodInvoker)delegate
                {
                    NewLogEntry(sender, e);
                });
                return;
            }
            AppendLog(e.Msg);
            Program.Log.Clear();
        }

        private void ShowAboutBox(object sender, EventArgs e)
        {
            /*
            AboutBox aboutBox = new AboutBox();
            aboutBox.ShowDialog();
            */
        }

        private void MakeVisible()
        {
            if (this.WindowState == FormWindowState.Minimized)
            {
                this.Show();
                this.WindowState = FormWindowState.Normal;
            }
            else
                this.Activate();
        }

        private void MainForm_Resize(object sender, EventArgs e)
        {
            if(this.WindowState == FormWindowState.Minimized)
            {
                this.Hide();
            }
        }

        private void NotifyIcon_MouseClick(object sender, MouseEventArgs e)
        {
            if(e.Button == MouseButtons.Left)
            {
                MakeVisible();
            }
        }

        private void NotifyContextMenuStripShowItem_Click(object sender, EventArgs e)
        {
            MakeVisible();
        }

        private void NotifyContextMenuStripExitItem_Click(object sender, EventArgs e)
        {
            Environment.Exit(0);
        }

        private void InitErrorPanelButton_Click(object sender, EventArgs e)
        {
            Init();
        }

        private void InitErrorRichTextBox_LinkClicked(object sender, LinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start(e.LinkText);
        }

        private void LogRichTextBox_LinkClicked(object sender, LinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start(e.LinkText);
        }

        private void MainForm_FormClosed(object sender, FormClosedEventArgs e)
        {
            Environment.Exit(0);
        }
    }
}
