# This Python file uses the following encoding: utf-8
# Developed by Jeremías Castillo

# Modulo que permite la incorporación de timers.
import time

# Modulo que incorpora utilidades para comunicación serie.
import serial

# Modulo "os" brinda utilidades vinculadas con el sistema operativo de la computadora
# Modulo "datetime" contiene funciones vinculadas fechas.
# Modulo "getpass" brinda funciones para acceder a datos del usuario del sistema que corre el código (nombre)
# Modulo "sys" contiene funciones que se encarga del estado de la aplicación, entre otras cosas...

import os
import sys
import datetime
import getpass
import serial.tools.list_ports

from pathlib import Path

from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtCore import QObject, Signal, Slot, QTimer, QUrl
from datetime import datetime

# ---------- Nombre de usuario de la computadora para poder crear archivo de LOG --------------
Name_User = getpass.getuser()

# ---------- Ruta por defecto para almacenar el archivo de LOG auto guardado --------------
DEFAULT_URL_LOG = "file:///C:/Users/"+Name_User+"/Desktop/Ground_Station_Log.txt"

# ---------- Auto guardado cada 10 seg --------------
Tiempo_AutoSave = 10000

# ---------- Timer de chequeo de puerto serie cada 15 seg --------------
Tiempo_Check_Ports = 15000

# ---------- Timer de chequeo de tracking cada 30 seg --------------
Tiempo_Tracking = 30000

# ---------- Conexión con el puerto serie --------------

Flag_recep = False
flag1 = True
acimut = 0
elevacion = 0
data_acimut = -99       # Valor no valido
data_elevacion = -99    # Valor no valido

class VentanaPrincipal(QObject):

    # ======================================== Señales a emitir ======================================== #

    # Creación de la señal que se encarga de actualizar datos en la interface cada 1 segundo, no envia datos. (podría hacerlo)
    actualizarDataToSave = Signal()

    # Señal enviada a la UI para notificar que los datos fueron guardados y puede borrar lo que tenga el LOG
    cleanLogAvalible = Signal()

    # Señal donde se envia el puerto serie a la UI
    setPortCOM = Signal(str)

    #Señal de error
    commSerieFailed = Signal(str)
    # ==================================== Fin de señales a emitir ==================================== #

    # String que almacena datos enviados desde la ventana de LOG
    DataToSave = ""

    # String que almacena datos enviados desde la ventana de LOG
    DataSaved = ""

    def __init__(self):
        QObject.__init__(self)

        self.timerautosave = QTimer()
        self.timercheckports = QTimer()
        self.timertracking = QTimer()

        # Ejecución de Actualizar_Interface cada vez que desborde el timer
        self.timerautosave.timeout.connect(lambda: self.autoGuardadoLog())

        # Chequeo de status de puerto de comunicaciones
        self.timercheckports.timeout.connect(lambda: self.statusPortCOM())

        # Ejecución de tracking
        self.timertracking.timeout.connect(lambda: self.Control_autonomo())

        # Recarga de timer asociados
        self.timerautosave.start(Tiempo_AutoSave)
        self.timercheckports.start(Tiempo_Check_Ports)
        self.timertracking.start(Tiempo_Tracking)

    # No es necesario un slot por que no recibimos datos desde UI, ni tampoco una signal dado que no mandamos nada
    # La lógica de esta combinación es necesaria ya que si no puede generarse discrepancia de los datos guardados.

    # Orden de ejecución:
    #  - Timer desborda -> Ejecuta autoGuardadoLog()
    #  - autoGuardadoLog -> Envia signal a la UI
    #  - UI responde y ejecuta saveDataLog() Y si hay datos distintos en el LOG
    #  de los que ya se tenian en un princpio en DataToSave se guardan

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

    # Guardado de LOG en una dirección determinada por el usuario a gusto.
    @Slot(str)
    def saveFile(self,filePath):
        file = open(QUrl(filePath).toLocalFile(), "a")
        file.write(self.DataToSave)
        file.close()

    @Slot(str)
    def openFile(self,filePath):
      file = open(QUrl(filePath).toLocalFile(), "r")
      Data = file.readlines()
      print(Data)
      print(type(Data))
      file.close()
    #############################################################################################################
    # Hay diferencia entre el autoGuardadoLog() y cleanLog() ya que aca la ejecución de esta última esta función
    # es por la UI y en el caso anterior se necesita saber desde la UI cuando desborda el Timer,
    # por ello se utiliza la signal en la primera.
    #############################################################################################################

    @Slot(str)
    def cleanLog(self, dataReadLog):
        if(dataReadLog != self.DataToSave):
            file = open(QUrl(DEFAULT_URL_LOG).toLocalFile(), "a")
            file.write(dataReadLog + "\n")
            file.close()
            print("Limpiando ventana de LOG")

        self.cleanLogAvalible.emit()
    #############################################################################################################
    #                                    Funciones de puerto serie                                              #
    #############################################################################################################

    def getPortCOM(self):
       # Deben de ser ingresado en formato hexadecimal (sin 0x), sino no podran ser encontrados
       # ID: 0x6860 (o ID: 27620) -> 6860
       list_PID = ['6860','6001']
       list_VID = ['04E8','0403']
       # Recorremos la lista de PID ingresados
       for Index in range(len(list_PID)):
           # Procedemos a buscar el dispositivo que contenga PID en su descriptor de HW
           # Si la lista es de longitud distinta de cero es por que hay un dispositivo que matcheo con el PID ingresado
           Device_To_Found = list(serial.tools.list_ports.grep(list_VID[Index] + ':' + list_PID[Index]))

           if (len(Device_To_Found) != 0):
               for Port in list(serial.tools.list_ports.grep(list_VID[Index] + ':' + list_PID[Index])):
                   print('\n* =================================== Puerto encontrado =================================== *')
                   print('\t\t\tCOM utilizado: ' + Port.device)
                   VID = '0x' + Port.hwid[12:16]
                   PID = '0x' + Port.hwid[17:22]
                   print('\t\t\tVID: ' + VID)
                   print('\t\t\tPID: ' + PID)
                   print('\t\t\t' + Port.description)
                   print('* ========================================================================================= *')
                   self.setPortCOM.emit(Port.device)
                   if (VID == '0x0403' and PID == '0x6001'):  # Parche para que no genere bardo con mi telefono xd
                       try:
                           print("Intentando conectar con " + Port.device + "...")
                           Serial_PORT = serial.Serial(Port.device, 9600, )
                       except(serial.SerialException):
                           print("* ==== Error ==== * - Se detecto un problema al intentar inicializar el puerto " + Port.device + "cuto PID es " + list_PID[Index])
                   else:
                      print('\n* =================================== Notificación =================================== *')
                      print("\t No se encontro ningún dispositivo cuyo par VID:PID sea 0x" + list_VID[Index] +':0x'+list_PID[Index])
                      print('* =================================================================================== *')

    def statusPortCOM(self):
        # Deben de ser ingresado en formato hexadecimal (sin 0x), sino no podran ser encontrados
        # ID: 0x6860 (o ID: 27620) -> 6860
        list_PID = ['6860','6001']
        list_VID = ['04E8','0403']
        # Recorremos la lista de PID ingresados
        for Index in range(len(list_PID)):
            # Procedemos a buscar el dispositivo que contenga PID en su descriptor de HW
            # Si la lista es de longitud distinta de cero es por que hay un dispositivo que matcheo con el PID ingresado
            Device_To_Found = list(serial.tools.list_ports.grep(list_VID[Index] + ':' + list_PID[Index]))

            if (len(Device_To_Found) != 0):
                for USB_Port in list(serial.tools.list_ports.grep(list_VID[Index] + ':' + list_PID[Index])):
                    print('\n* =================================== Puerto encontrado =================================== *')
                    print('\t\t\tCOM utilizado: ' + USB_Port.device)
                    VID = '0x' + USB_Port.hwid[12:16]
                    PID = '0x' + USB_Port.hwid[17:22]
                    print('\t\t\tVID: ' + VID)
                    print('\t\t\tPID: ' + PID)
                    print('\t\t\t' + USB_Port.description)
                    print('* ========================================================================================= *')
                    if (VID == '0x0403' and PID == '0x6001'):  # Parche para que no genere bardo con mi telefono xd
                        try:
                            print("Intentando conectar con " + USB_Port.device + "...")
                            Serial_PORT = serial.Serial(USB_Port.device, 9600, )
                        except(serial.SerialException):
                            print("* ==== Error ==== * - Se detecto un problema al intentar inicializar el puerto " + USB_Port.device + "cuto PID es " + list_PID[Index])
            else:
                print('\n* =================================== Notificación =================================== *')
                print("\t No se encontro ningún dispositivo cuyo par VID:PID sea 0x" + list_VID[Index] + ':0x' + list_PID[Index])
                print('* =================================================================================== *')

    #############################################################################################################
    #                                   Fin funciones de puerto serie                                           #
    #############################################################################################################

    #############################################################################################################
    #                                      Comando manuales                                                     #
    #############################################################################################################

    # U // UP Direction Rotation
    @Slot()
    def moveUp(self):
        #comando a enviar: "U\r"
      texto = b'U\r'
      try:
         ser.write(texto)
      except(serial.SerialException):
         self.commSerieFailed.emit("Falla de envió por puerto serie")
      print("Arriba")

    # D // DOWN Direction Rotation
    @Slot()
    def moveDown(self):
        #comando a enviar: "D\r"
        texto = b'D\r'
        try:
           ser.write(texto)
        except(serial.SerialException):
           self.commSerieFailed.emit("Falla de envió por puerto serie")
        print("Abajo")

    #R // Clockwise Rotation
    @Slot()
    def moveToRight(self):
        #comando a enviar: "R\r"
        texto = b'R\r'
        try:
           ser.write(texto)
        except(serial.SerialException):
           self.commSerieFailed.emit("Falla de envió por puerto serie")
        print("Derecha")

    #L// Counter Clockwise Rotation
    @Slot()
    def moveToLeft(self):
        #comando a enviar: "L\r"
        texto = b'L\r'
        try:
           ser.write(texto)
        except(serial.SerialException):
           self.commSerieFailed.emit("Falla de envió por puerto serie")
        print("Izquierda")      

    # A // CW/CCW Rotation Stop
    @Slot()
    def stopAcimut(self):
        #comando a enviar: "A\r"
        texto = b'A\r'
        try:
           ser.write(texto)
        except(serial.SerialException):
           self.commSerieFailed.emit("Falla de envió por puerto serie")
        print("Parando Acimut")

    # E // UP/DOWN Direction Rotation Stop
    @Slot()
    def stopElevacion(self):
        #comando a enviar: "E\r"
        texto = b'E\r'
        try:
           ser.write(texto)
        except(serial.SerialException):
           self.commSerieFailed.emit("Falla de envió por puerto serie")
        print("Parando Elevación")

    # E // UP/DOWN Direction Rotation Stop
    @Slot()
    def stopEverthing(self):
        #comando a enviar: "S\r"
        command = b'S\r'
        try:
           ser.write(texto)
        except(serial.SerialException):
           self.commSerieFailed.emit("Falla de envió por puerto serie")
        print("Parando todo")

    #############################################################################################################
    #                                         Fin comando manuales                                              #
    #############################################################################################################


    #############################################################################################################
    #                                   Funciones vinculadas con el tracking                                    #
    #############################################################################################################


#HAY QUE VER LA LÓGICA QUE USO SEBA PARA DEFINIR LA FLAG Y ESO PERO ESTARIA EL ENVIO REALIZADO CADA 30 SEG
# PENSAR ALGUNA FORMA DE QUE SE HAGA 1 ENVIO SIN USO DE BANDERAS
    def Control_autonomo(self):
        global data_acimut
        global data_elevacion
        global flag1

        lineasleidas = 0
        hora_actual = time.strftime('%H:%M')
        """ -------- Solicito fecha y la genero al formato para comparar con el archivo ----------"""
        fecha_sin_analizar= time.strftime('%m/%d/%y')
        objDate = datetime.strptime(fecha_sin_analizar,'%m/%d/%y')
        fecha=datetime.strftime(objDate, '%Y-%b-%d')

        file = open("comandos4.txt",'r')

        total_lines = sum(1 for line in file)

        file.seek(0)

        linea = file.readline()
        while len(linea) > 0:
            dato1 = linea.split(',')
            if dato1[0] != '\n':
                if dato1[1] == hora_actual and fecha == dato1[0]:
                    if flag1:
                        data_acimut=dato1[2]
                        data_elevacion=dato1[3]

                        parametros="P"+str(float(dato1[2]))+" "+str(float(dato1[3]))

                        #ser.write(parametros.encode('ascii')+ b'\r')
                        print(parametros.encode('ascii')+ b'\r')
                        print("envie comando")

                        flag1=False
                        lineasleidas=lineasleidas+1

                    if (float(data_acimut)!=float(dato1[2])) | (float(data_elevacion)!=float(dato1[3])):
                        #Tracking(float(dato1[2]), float(dato1[3]))
                        data_acimut = dato1[2]
                        data_elevacion = dato1[3]
                        lineasleidas += 1

            linea = file.readline()
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
