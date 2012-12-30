#from QtMobility.SystemInfo import QSystemDeviceInfo,QSystemNetworkInfo
#from QtMobility.Messaging import QMessageManager, QMessage, QMessageFilter
from PySide.QtCore import QObject
from PySide import QtCore
from wadebug import WADebug
import dbus
import dbus.mainloop
import dbus.glib
import re

class SMSHandler(QObject):
    
    gotCode = QtCore.Signal(str)
    
    def __init__(self):
        WADebug.attach(self)

        super(SMSHandler, self).__init__()
        
    def initManager(self):
        self._d("INIT MANAGER!")        
        dbus_main_loop = dbus.glib.DBusGMainLoop(set_as_default=True)
        bus = dbus.SessionBus(dbus_main_loop)
        mybus = bus.get_object('org.freedesktop.Telepathy.ConnectionManager.ring', '/org/freedesktop/Telepathy/Connection/ring/tel/ring/text13')
        self.nface = dbus.Interface(mybus, 'org.freedesktop.Telepathy.Channel.Interface.Messages')
        self.nface.connect_to_signal("MessageReceived", self.messageReceived)
        
    def messageReceived(self, arrayData):
        self._d("MESSAGE RECEIVED!")
        message=(arrayData[1]['content'].title())
        self._d(message)
        try:
            message.lower().index("whatsapp code")
            result=re.search('\d{3}-\d{3}', message)
            if result!=None:
                code=result.group(0).replace("-","")
                self._d("GOT CODE!")
                self._d(code)
                self.gotCode.emit(code)
        except ValueError:
            return

    def stopListener(self):
        pass
    
    def run(self):
        pass