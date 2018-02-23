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
    public class NewLogEntryEventArgs : EventArgs
    {
        public string Msg { get; private set; }

        public NewLogEntryEventArgs(string msg)
        {
            Msg = msg;
        }
    }

    public class Log
    {
        private string log;

        public Log()
        {
            AddEntry("Logging started");
        }

        public event EventHandler<NewLogEntryEventArgs> NewLogEntry;

        public void AddEntry(string msg)
        {
            msg = string.Format("{0}   {1}\n", DateTime.Now, msg.Trim());
            this.log += msg;
            NewLogEntryEventArgs e = new NewLogEntryEventArgs(msg);
            OnNewLogEntry(e);
        }

        public string Get()
        {
            return this.log;
        }

        public void Clear()
        {
            this.log = "";
        }

        protected virtual void OnNewLogEntry(NewLogEntryEventArgs e)
        {
            NewLogEntry?.Invoke(this, e);
        }
    }
}
