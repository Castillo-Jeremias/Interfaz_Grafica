# This Python file uses the following encoding: utf-8
import os, sys, datetime, getpass
from pathlib import Path

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


    #No es necesario un slot por que no recibimos datos desde UI, ni tampoco una signal dado que no mandamos nada
    # La lógica de esta combinación es necesaria ya que si no puede generarse discrepancia de los datos guardados.

    # Orden de ejecución:
    #   - Timer desborda -> Ejecuta autoGuardadoLog()
    #   - autoGuardadoLog -> Envia signal a la UI
    #   - UI responde y ejecuta saveDataLog() Y si hay datos distintos en el LOG
    #   de los que ya se tenian en un princpio en DataToSave se guardan

    #Creación de la señal que se encarga de actualizar datos en la interface cada 1 segundo, no envia datos. (podría hacerlo)
    actualizarDataToSave = Signal()

    def autoGuardadoLog(self):
        self.actualizarDataToSave.emit()
        if(self.DataSaved != self.DataToSave):
            file = open(QUrl(DEFAULT_URL_LOG).toLocalFile(), "a")
            file.write(self.DataToSave + "\n")
            self.DataSaved = self.DataToSave
            file.close()
            print("saved")

    @Slot(str)
    def saveDataLog(self,dataLog):
        if(self.DataToSave != dataLog):
            self.DataToSave = dataLog

    #Guardado de LOG en una dirección determinada por el usuario a gusto.
    @Slot(str)
    def saveFile(self,filePath):
        file = open(QUrl(filePath).toLocalFile(), "a")
        file.write(self.DataToSave)
        file.close()

    #############################################################################################################
    # Hay diferencia entre el autoGuardadoLog() y cleanLog() ya que aca la ejecución de esta última esta función
    # es por la UI y en el caso anterior se necesita saber desde la UI cuando desborda el Timer,
    # por ello se utiliza la signal en la primera.
    #############################################################################################################

    #Señal enviada a la UI para notificar que los datos fueron guardados y puede borrar lo que tenga el LOG
    cleanLogAvalible = Signal()

    @Slot(str)
    def cleanLog(self,dataReadLog):
        if( dataReadLog != self.DataToSave):
            file = open(QUrl(DEFAULT_URL_LOG).toLocalFile(), "a")
            file.write(dataReadLog + "\n")
            file.close()
            print("Limpiando ventana de LOG")

        self.cleanLogAvalible.emit()

    #############################################################################################################
    #                                      Comando manuales                                                     #
    #############################################################################################################
    @Slot()
    def moveUp(self):
        #comando a enviar: "U\r"
        print("Arriba")

    @Slot()
    def moveDown(self):
        #comando a enviar: "D\r"
        print("Abajo")

    @Slot()
    def moveToRight(self):
        #comando a enviar: "R\r"
        print("Derecha")

    @Slot()
    def moveToLeft(self):
        #comando a enviar: "L\r"
        print("Izquierda")

    @Slot()
    def stopAcimut(self):
        #comando a enviar: "A\r"
        print("Parando Acimut")

    @Slot()
    def stopElevacion(self):
        #comando a enviar: "E\r"
        print("Parando Elevación")

    @Slot()
    def stopEverthing(self):
        #comando a enviar: "S\r"
        print("Parando todo")
    #############################################################################################################
    #                                         Fin comando manuales                                              #
    #############################################################################################################
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
