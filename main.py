# This Python file uses the following encoding: utf-8
import os, sys
from pathlib import Path
import datetime,getpass

from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtCore import QObject, Signal, Slot, QTimer, QUrl

#Nombre de usuario de la computadora para poder crear archivo de LOG
Name_User = getpass.getuser()

#Ruta por defecto para almacenar el archivo de LOG auto guardado
DEFAULT_URL_LOG = "file:///C:/Users/"+Name_User+"/Desktop/Ground_Station_Log.txt"

#Auto guardado cada 10 seg
Tiempo_AutoSave = 10000

#Tiempo de timerXSeg
Tiempo_Timer = 1000

class VentanaPrincipal(QObject):

    #String que almacena datos enviados desde la ventana de LOG
    DataToSave = ""

    #String que almacena datos enviados desde la ventana de LOG
    DataSaved = ""

    def __init__(self):
        QObject.__init__(self)

        self.timerautosave = QTimer()

        #Ejecución de Actualizar_Interface cada vez que desborde el timer
        self.timerautosave.timeout.connect(lambda:self.autoGuardadoLog())

        #Carga de nueva cuenta
        self.timerautosave.start(Tiempo_AutoSave)

    #Creación de la señal que se encarga de actualizar datos en la interface cada 1 segundo, no envia datos. (podría hacerlo)
    actualizar = Signal()

    #No es necesario un slot por que no recibimos datos desde UI, ni tampoco una signal dado que no mandamos nada
    def autoGuardadoLog(self):
        self.actualizar.emit()
        if(self.DataSaved != self.DataToSave):
            file = open(QUrl(DEFAULT_URL_LOG).toLocalFile(), "a")
            file.write(self.DataToSave + "\n")
            self.DataSaved = self.DataToSave
            file.close()
            print("saved")

    @Slot(str)
    def sendDataToSave(self,dataLog):
        if(self.DataToSave != dataLog):
            self.DataToSave = dataLog

    @Slot(str)
    def saveFile(self,filePath):
        file = open(QUrl(filePath).toLocalFile(), "a")
        file.write(self.DataToSave)
        file.close()

    cleanLogAvalible = Signal()

    @Slot(str)
    def cleanLog(self,dataReadLog):
        if( dataReadLog != self.DataToSave):
            file = open(QUrl(DEFAULT_URL_LOG).toLocalFile(), "a")
            file.write(dataReadLog + "\n")
            file.close()
            print("Limpiando ventana de LOG")

        self.cleanLogAvalible.emit()

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    #Obtención del contexto del objeto desde la interface gráfica
    ventana = VentanaPrincipal()
    engine.rootContext().setContextProperty("backendPython",ventana)

    #Carga del archivo QML
    engine.load(os.fspath(Path(__file__).resolve().parent / "qml\main.qml"))

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec_())
