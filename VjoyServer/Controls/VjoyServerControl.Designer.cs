namespace VjoyServer
{
    partial class VjoyServerControl
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

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.feederStatus = new System.Windows.Forms.Label();
            this.vjoyDeviceLabel = new System.Windows.Forms.Label();
            this.VjoyDeviceStatusPictureBox = new System.Windows.Forms.PictureBox();
            this.ExportCheckBox = new System.Windows.Forms.CheckBox();
            this.ExportLabel = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.VjoyDeviceStatusPictureBox)).BeginInit();
            this.SuspendLayout();
            // 
            // feederStatus
            // 
            this.feederStatus.AutoSize = true;
            this.feederStatus.Location = new System.Drawing.Point(90, 8);
            this.feederStatus.Name = "feederStatus";
            this.feederStatus.Size = new System.Drawing.Size(73, 13);
            this.feederStatus.TabIndex = 0;
            this.feederStatus.Text = "Feeder Status";
            // 
            // vjoyDeviceLabel
            // 
            this.vjoyDeviceLabel.AutoSize = true;
            this.vjoyDeviceLabel.Location = new System.Drawing.Point(3, 8);
            this.vjoyDeviceLabel.Name = "vjoyDeviceLabel";
            this.vjoyDeviceLabel.Size = new System.Drawing.Size(53, 13);
            this.vjoyDeviceLabel.TabIndex = 0;
            this.vjoyDeviceLabel.Text = "vJoy #XX";
            // 
            // VjoyDeviceStatusPictureBox
            // 
            this.VjoyDeviceStatusPictureBox.BackColor = System.Drawing.Color.White;
            this.VjoyDeviceStatusPictureBox.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.VjoyDeviceStatusPictureBox.Location = new System.Drawing.Point(62, 3);
            this.VjoyDeviceStatusPictureBox.Name = "VjoyDeviceStatusPictureBox";
            this.VjoyDeviceStatusPictureBox.Size = new System.Drawing.Size(22, 22);
            this.VjoyDeviceStatusPictureBox.TabIndex = 1;
            this.VjoyDeviceStatusPictureBox.TabStop = false;
            // 
            // ExportCheckBox
            // 
            this.ExportCheckBox.AutoSize = true;
            this.ExportCheckBox.Location = new System.Drawing.Point(169, 8);
            this.ExportCheckBox.Name = "ExportCheckBox";
            this.ExportCheckBox.Size = new System.Drawing.Size(15, 14);
            this.ExportCheckBox.TabIndex = 2;
            this.ExportCheckBox.UseVisualStyleBackColor = true;
            this.ExportCheckBox.Click += new System.EventHandler(this.ExportCheckBox_Click);
            // 
            // ExportLabel
            // 
            this.ExportLabel.AutoSize = true;
            this.ExportLabel.Location = new System.Drawing.Point(190, 8);
            this.ExportLabel.Name = "ExportLabel";
            this.ExportLabel.Size = new System.Drawing.Size(37, 13);
            this.ExportLabel.TabIndex = 3;
            this.ExportLabel.Text = "Export";
            // 
            // VjoyServerControl
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.ExportLabel);
            this.Controls.Add(this.ExportCheckBox);
            this.Controls.Add(this.VjoyDeviceStatusPictureBox);
            this.Controls.Add(this.vjoyDeviceLabel);
            this.Controls.Add(this.feederStatus);
            this.Margin = new System.Windows.Forms.Padding(0);
            this.Name = "VjoyServerControl";
            this.RightToLeft = System.Windows.Forms.RightToLeft.No;
            this.Size = new System.Drawing.Size(236, 28);
            this.Load += new System.EventHandler(this.VjoyServerControl_Load);
            ((System.ComponentModel.ISupportInitialize)(this.VjoyDeviceStatusPictureBox)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label feederStatus;
        private System.Windows.Forms.Label vjoyDeviceLabel;
        private System.Windows.Forms.PictureBox VjoyDeviceStatusPictureBox;
        private System.Windows.Forms.CheckBox ExportCheckBox;
        private System.Windows.Forms.Label ExportLabel;
    }
}
