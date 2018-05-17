# Copyright © 2017, 2018 Michael Goldener <mg@wasted.ch>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http:#www.gnu.org/licenses/>.

extends Node

var mVrcHost = null

func _ready():
	mVrcHost = get_node("/root/pseudo_vrc_host")
	mVrcHost.set_var("SERVER_NAME", "[No Server]")
	mVrcHost.set_var("CONTROLLER_ID", "123")
	mVrcHost.set_var("SEND_UPDATE_ADDR", "udp!127.0.0.1!1234")
	mVrcHost.set_var("ACTIVE_JOYSTICK_ID", "1")
	for i in range(1, 17):
		var status = [ "free", "taken", "" ]
		mVrcHost.set_var(("JOYSTICK_STATUS/"+str(i)), status[randi() % 3])
	

