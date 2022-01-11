# This Python file uses the following encoding: utf-8

# Modulo que permite la incorporación de timers.
import time

#Modulo que incorpora utilidades para comunicación serie.
import serial

# Modulo "os" brinda utilidades vinculadas con el sistema operativo de la computadora
# Modulo "datetime" contiene funciones vinculadas fechas.
# Modulo "getpass" brinda funciones para acceder a datos del usuario del sistema que corre el código (nombre)
# Modulo "sys" contiene funciones que se encarga del estado de la aplicación, entre otras cosas...
import os, sys, datetime, getpass

from pathlib import Path

from serial import Serial

from datetime import datetime

from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtCore import QObject, Signal, Slot, QTimer, QUrl

# ---------- Nombre de usuario de la computadora para poder crear archivo de LOG --------------
Name_User = getpass.getuser()

# ---------- Ruta por defecto para almacenar el archivo de LOG auto guardado --------------
DEFAULT_URL_LOG = "file:///C:/Users/"+Name_User+"/Desktop/Ground_Station_Log.txt"

# ---------- Auto guardado cada 10 seg --------------
Tiempo_AutoSave = 10000

# ---------- Tiempo de timerXSeg --------------
Tiempo_Timer = 1000

# ---------- Conexión con el puerto serie --------------
ser = serial.Serial('COM2', 9600, )
Flag_recep = False
flag1 = True
acimut = 0
elevacion = 0
data_acimut = -99       #valor no valido
data_elevacion = -99    #valor no valido

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

    # U // UP Direction Rotation
    @Slot()
    def moveUp(self):
        #comando a enviar: "U\r"
        texto = b'U\r'
        ser.write(texto)
        print("Arriba")
        return
    # D // DOWN Direction Rotation
    @Slot()
    def moveDown(self):
        #comando a enviar: "D\r"
        texto = b'D\r'
        ser.write(texto)
        print("Abajo")
        return

    #R // Clockwise Rotation
    @Slot()
    def moveToRight(self):
        #comando a enviar: "R\r"
        texto = b'R\r'
        ser.write(texto)
        print("Derecha")
        return

    #L// Counter Clockwise Rotation
    @Slot()
    def moveToLeft(self):
        #comando a enviar: "L\r"
        texto = b'L\r'
        ser.write(texto)
        print("Izquierda")
        return

    # A // CW/CCW Rotation Stop
    @Slot()
    def stopAcimut(self):
        #comando a enviar: "A\r"
        texto = b'A\r'
        ser.write(texto)
        print("Parando Acimut")
        return

    # E // UP/DOWN Direction Rotation Stop
    @Slot()
    def stopElevacion(self):
        #comando a enviar: "E\r"
        texto = b'E\r'
        ser.write(texto)
        print("Parando Elevación")
        return

    # E // UP/DOWN Direction Rotation Stop
    @Slot()
    def stopEverthing(self):
        #comando a enviar: "S\r"
        command = b'S\r'
        ser.write(command)
        print("Parando todo")
        return
    #############################################################################################################
    #                                         Fin comando manuales                                              #
    #############################################################################################################


    #############################################################################################################
    #                                   Funciones vinculadas con el tracking                                    #
    #############################################################################################################
    def Tracking(acimut,elevacion):
        #parametros="P"+str(float("{0:.1f}".format(float(acimut))))+" "+str(float("{0:0.1f}".format(float(elevacion))))
        parametros="P"+str(acimut)+" "+str(elevacion)

        ser.write(parametros.encode('ascii')+ b'\r')
        print(parametros.encode('ascii')+ b'\r')
        print("envie comando")
        return

    def Control_autonomo():
        global data_acimut
        global data_elevacion
        global flag1

        lineasleidas = 0
        hora_actual = time.strftime('%H:%M')
        """ -------- Solicito fecha y la genero al formato para comparar con el archivo ----------"""
        fecha_sin_analizar= time.strftime('%m/%d/%y')
        objDate = datetime.strptime(fecha_sin_analizar,'%m/%d/%y')
        fecha=datetime.strftime(objDate, '%Y-%b-%d')

        total_lines = sum(1 for line in file)
        file.seek(0)
        #print(total_lines)
        linea = file.readline()
        while len(linea) > 0:
            dato1 = linea.split(',')

            if dato1[1] == hora_actual and fecha == dato1[0]:
               # print("envie comando")
                if flag1:
                    data_acimut=dato1[2]
                    data_elevacion=dato1[3]
                    Tracking(float(dato1[2]),float(dato1[3]))
                    flag1=False
                    lineasleidas=lineasleidas+1

                if (float(data_acimut)!=float(dato1[2])) | (float(data_elevacion)!=float(dato1[3])):
                    Tracking(float(dato1[2]), float(dato1[3]))
                    data_acimut = dato1[2]
                    data_elevacion = dato1[3]
                    lineasleidas += 1


            linea = file.readline()
            #data = file.readlines()[total_lines]

        return 0

        if total_lines==lineasleidas:
            return 1
    #############################################################################################################
    #                                   Fin funciones vinculadas con el tracking                                #
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
