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

namespace VjoyServer
{
    partial class MainForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
            this.notifyIcon = new System.Windows.Forms.NotifyIcon(this.components);
            this.notifyContextMenuStrip = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.notifyContextMenuStripShowItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.notifyContextMenuStripExitItem = new System.Windows.Forms.ToolStripMenuItem();
            this.SplitContainer1 = new System.Windows.Forms.SplitContainer();
            this.InitErrorPanel = new System.Windows.Forms.Panel();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.InitErrorPanelButton = new System.Windows.Forms.Button();
            this.InitErrorRichTextBox = new System.Windows.Forms.RichTextBox();
            this.VjoyServerControls = new System.Windows.Forms.FlowLayoutPanel();
            this.LogRichTextBox = new System.Windows.Forms.RichTextBox();
            this.notifyContextMenuStrip.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.SplitContainer1)).BeginInit();
            this.SplitContainer1.Panel1.SuspendLayout();
            this.SplitContainer1.Panel2.SuspendLayout();
            this.SplitContainer1.SuspendLayout();
            this.InitErrorPanel.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.SuspendLayout();
            // 
            // notifyIcon
            // 
            this.notifyIcon.ContextMenuStrip = this.notifyContextMenuStrip;
            this.notifyIcon.Icon = ((System.Drawing.Icon)(resources.GetObject("notifyIcon.Icon")));
            this.notifyIcon.Text = "vJoy Server";
            this.notifyIcon.Visible = true;
            this.notifyIcon.MouseClick += new System.Windows.Forms.MouseEventHandler(this.NotifyIcon_MouseClick);
            // 
            // notifyContextMenuStrip
            // 
            this.notifyContextMenuStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.notifyContextMenuStripShowItem,
            this.toolStripSeparator1,
            this.notifyContextMenuStripExitItem});
            this.notifyContextMenuStrip.Name = "notifyContextMenuStrip";
            this.notifyContextMenuStrip.RenderMode = System.Windows.Forms.ToolStripRenderMode.System;
            this.notifyContextMenuStrip.ShowImageMargin = false;
            this.notifyContextMenuStrip.Size = new System.Drawing.Size(76, 54);
            // 
            // notifyContextMenuStripShowItem
            // 
            this.notifyContextMenuStripShowItem.Name = "notifyContextMenuStripShowItem";
            this.notifyContextMenuStripShowItem.Size = new System.Drawing.Size(75, 22);
            this.notifyContextMenuStripShowItem.Text = "Show";
            this.notifyContextMenuStripShowItem.Click += new System.EventHandler(this.NotifyContextMenuStripShowItem_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(72, 6);
            // 
            // notifyContextMenuStripExitItem
            // 
            this.notifyContextMenuStripExitItem.Name = "notifyContextMenuStripExitItem";
            this.notifyContextMenuStripExitItem.Size = new System.Drawing.Size(75, 22);
            this.notifyContextMenuStripExitItem.Text = "Exit";
            this.notifyContextMenuStripExitItem.Click += new System.EventHandler(this.NotifyContextMenuStripExitItem_Click);
            // 
            // SplitContainer1
            // 
            this.SplitContainer1.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.SplitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.SplitContainer1.Location = new System.Drawing.Point(0, 0);
            this.SplitContainer1.Name = "SplitContainer1";
            this.SplitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // SplitContainer1.Panel1
            // 
            this.SplitContainer1.Panel1.AutoScroll = true;
            this.SplitContainer1.Panel1.Controls.Add(this.InitErrorPanel);
            this.SplitContainer1.Panel1.Controls.Add(this.VjoyServerControls);
            // 
            // SplitContainer1.Panel2
            // 
            this.SplitContainer1.Panel2.Controls.Add(this.LogRichTextBox);
            this.SplitContainer1.Size = new System.Drawing.Size(425, 613);
            this.SplitContainer1.SplitterDistance = 461;
            this.SplitContainer1.TabIndex = 1;
            // 
            // InitErrorPanel
            // 
            this.InitErrorPanel.Anchor = System.Windows.Forms.AnchorStyles.None;
            this.InitErrorPanel.BackColor = System.Drawing.SystemColors.Control;
            this.InitErrorPanel.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.InitErrorPanel.Controls.Add(this.pictureBox1);
            this.InitErrorPanel.Controls.Add(this.InitErrorPanelButton);
            this.InitErrorPanel.Controls.Add(this.InitErrorRichTextBox);
            this.InitErrorPanel.Location = new System.Drawing.Point(68, 169);
            this.InitErrorPanel.Name = "InitErrorPanel";
            this.InitErrorPanel.Size = new System.Drawing.Size(284, 119);
            this.InitErrorPanel.TabIndex = 2;
            // 
            // pictureBox1
            // 
            this.pictureBox1.Image = global::VjoyServer.Properties.Resources.dialog_error;
            this.pictureBox1.Location = new System.Drawing.Point(3, 3);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(32, 32);
            this.pictureBox1.TabIndex = 2;
            this.pictureBox1.TabStop = false;
            // 
            // InitErrorPanelButton
            // 
            this.InitErrorPanelButton.Location = new System.Drawing.Point(96, 87);
            this.InitErrorPanelButton.Name = "InitErrorPanelButton";
            this.InitErrorPanelButton.Size = new System.Drawing.Size(90, 23);
            this.InitErrorPanelButton.TabIndex = 0;
            this.InitErrorPanelButton.Text = "Retry";
            this.InitErrorPanelButton.UseVisualStyleBackColor = true;
            this.InitErrorPanelButton.Click += new System.EventHandler(this.InitErrorPanelButton_Click);
            // 
            // InitErrorRichTextBox
            // 
            this.InitErrorRichTextBox.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.InitErrorRichTextBox.Location = new System.Drawing.Point(41, 3);
            this.InitErrorRichTextBox.Name = "InitErrorRichTextBox";
            this.InitErrorRichTextBox.ReadOnly = true;
            this.InitErrorRichTextBox.Size = new System.Drawing.Size(240, 78);
            this.InitErrorRichTextBox.TabIndex = 1;
            this.InitErrorRichTextBox.Text = "";
            this.InitErrorRichTextBox.LinkClicked += new System.Windows.Forms.LinkClickedEventHandler(this.InitErrorRichTextBox_LinkClicked);
            // 
            // VjoyServerControls
            // 
            this.VjoyServerControls.AutoSize = true;
            this.VjoyServerControls.FlowDirection = System.Windows.Forms.FlowDirection.TopDown;
            this.VjoyServerControls.Location = new System.Drawing.Point(0, 0);
            this.VjoyServerControls.Name = "VjoyServerControls";
            this.VjoyServerControls.Size = new System.Drawing.Size(192, 143);
            this.VjoyServerControls.TabIndex = 0;
            // 
            // LogRichTextBox
            // 
            this.LogRichTextBox.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.LogRichTextBox.Dock = System.Windows.Forms.DockStyle.Fill;
            this.LogRichTextBox.Location = new System.Drawing.Point(0, 0);
            this.LogRichTextBox.Name = "LogRichTextBox";
            this.LogRichTextBox.ReadOnly = true;
            this.LogRichTextBox.Size = new System.Drawing.Size(421, 144);
            this.LogRichTextBox.TabIndex = 0;
            this.LogRichTextBox.Text = "";
            this.LogRichTextBox.LinkClicked += new System.Windows.Forms.LinkClickedEventHandler(this.LogRichTextBox_LinkClicked);
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(425, 613);
            this.Controls.Add(this.SplitContainer1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "MainForm";
            this.Text = "vJoy Server";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.MainForm_FormClosed);
            this.Resize += new System.EventHandler(this.MainForm_Resize);
            this.notifyContextMenuStrip.ResumeLayout(false);
            this.SplitContainer1.Panel1.ResumeLayout(false);
            this.SplitContainer1.Panel1.PerformLayout();
            this.SplitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.SplitContainer1)).EndInit();
            this.SplitContainer1.ResumeLayout(false);
            this.InitErrorPanel.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.NotifyIcon notifyIcon;
        private System.Windows.Forms.ContextMenuStrip notifyContextMenuStrip;
        private System.Windows.Forms.ToolStripMenuItem notifyContextMenuStripShowItem;
        private System.Windows.Forms.ToolStripMenuItem notifyContextMenuStripExitItem;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.SplitContainer SplitContainer1;
        private System.Windows.Forms.FlowLayoutPanel VjoyServerControls;
        private System.Windows.Forms.RichTextBox LogRichTextBox;
        private System.Windows.Forms.Panel InitErrorPanel;
        private System.Windows.Forms.Button InitErrorPanelButton;
        private System.Windows.Forms.RichTextBox InitErrorRichTextBox;
        private System.Windows.Forms.PictureBox pictureBox1;
    }
}