#!/usr/bin/env python3
import subprocess
import dbus

lock = subprocess.Popen(["swaylock", "-c", "003030"])

session = dbus.SessionBus()
mumble_ = session.get_object('net.sourceforge.mumble.mumble', '/')
mumble = dbus.Interface(mumble_, 'net.sourceforge.mumble.Mumble')
prev = mumble.getCurrentUrl()
if 'flurfunk' in prev:
    mumble.openUrl('mumble://flurfunk.mayflower.de:64738/AFK Channel')
    lock.wait()
    mumble.openUrl(prev)
