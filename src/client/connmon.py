'''
Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>

This file is part of Wazapp, an IM application for Meego Harmattan platform that
allows communication with Whatsapp users

Wazapp is free software: you can redistribute it and/or modify it under the 
terms of the GNU General Public License as published by the Free Software 
Foundation, either version 2 of the License, or (at your option) any later 
version.

Wazapp is distributed in the hope that it will be useful, but WITHOUT ANY 
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with 
Wazapp. If not, see http://www.gnu.org/licenses/.
'''
from PySide.QtCore import *
from PySide.QtGui import *
from PySide import QtCore
from PySide.QtNetwork import QNetworkSession, QNetworkConfigurationManager,QNetworkConfiguration, QNetworkAccessManager 
import sys
import PySide

import dbus

from wadebug import ConnMonDebug;

class ConnMonitor(QObject):

	connectionSwitched = QtCore.Signal();
	connected = QtCore.Signal()
	disconnected = QtCore.Signal()
	
	def __init__(self):
		super(ConnMonitor,self).__init__();
		
		_d = ConnMonDebug();
		self._d = _d.d;
		
		self.session = None
		self.online = False
		self.manager = QNetworkConfigurationManager()
		self.config = self.manager.defaultConfiguration() if self.manager.isOnline() else None
		
		self.mobiledata = True
		self.cellular = True
		
		self.wasError = False
		
		self.manager.onlineStateChanged.connect(self.onOnlineStateChanged)
		self.manager.configurationChanged.connect(self.onConfigurationChanged)
		
		#self.connected.connect(self.onOnline)
		#self.disconnected.connect(self.onOffline)
		self.session =  QNetworkSession(self.manager.defaultConfiguration());
		self.session.stateChanged.connect(self.sessionStateChanged)
		self.session.error.connect(self.sessionError);
		#self.session.closed.connect(self.disconnected);
		#self.session.opened.connect(self.connected);
		
		self.bus = dbus.SystemBus()
		mcebus = self.bus.get_object('com.nokia.mce', '/com/nokia/mce/signal')
		self.mcenface = dbus.Interface(mcebus, 'com.nokia.mce.signal')
		self.mcenface.connect_to_signal("radio_states_ind", self.mceStateChanged)
		
		self.mceStateChanged(open("/var/lib/mce/radio_states.online", "r").read())

	def sessionError(self,error):
		self._d("Session error: " + str(error))
		self._d("Session error: " + self.session.errorString())
		self.wasError = True
	
	def mceStateChanged(self,state):
		if int(state)&4:
			self.mobiledata = True
			self.wasError = False
			self._d("mce mobile data enabled. can connect to network now")
		else:
			self.mobiledata = False
			
		if int(state)&2:
			self.cellular = True
		else:
			self.cellular = False
		
	def sessionStateChanged(self,state):
		self._d("ConnMonitor.sessionStateChanged "+str(state));
		if state==5: #QNetworkSession::Disconnected
			self.disconnected.emit()
			if not self.mobiledata and not self.wasError:
				self.createSession()
			elif self.wasError:
				self._d("connection request was aborted by user. cant auto connect to network now")
			if self.mobiledata:
				self.createSession()
		if state==3:
			self.connected.emit();
	
	def sessionState(self):
		return self.session.state()
	
	def createSession(self):
		self._d("ConnMonitor.createSession")
		if not self.session.isOpen():
			self.session.open();
			self.sessionError(self.session.error())
			if self.session.waitForOpened(-1):
				self._d("Network session opened!")
				self.connected.emit()
	
	def isOnline(self):
		myonline = self.manager.isOnline()
		self._d("ConnMonitor.isOnline: " + str(myonline))
		return myonline
	
	def onConfigurationChanged(self,config):
		self._d("ConnMonitor.onConfigurationChanged")
		'''if self.manager.isOnline() and config.state() == PySide.QtNetwork.QNetworkConfiguration.StateFlag.Active:
			if self.config is None:
				self.config = config
			else:
				self.createSession();'''
		
	def onOnlineStateChanged(self,state):
		self._d("ConnMonitor.onOnlineStateChanged: " + ("online" if state else "offline"))
		self.online = state
		'''if state:
			self.connected.emit()
		elif not self.isOnline():
			self.config = None
			self.disconnected.emit()'''
	
	def onOnline(self):
		self._d("ONLINE")
	
	def onOffline(self):
		self._d("OFFLINE");

if __name__=="__main__":
	app = QApplication(sys.argv)
	cm = ConnMon()
	
	
	sys.exit(app.exec_())
