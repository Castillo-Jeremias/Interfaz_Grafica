# This Python file uses the following encoding: utf-8

# Developed by Jeremías Castillo

#############################################################################################################
#                                                Imports                                                    #
#############################################################################################################
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

#############################################################################################################
#                                               End Imports                                                 #
#############################################################################################################

#############################################################################################################
#                                                Constantes                                                 #
#############################################################################################################

# Nombre de usuario de la computadora para poder crear archivo de LOG
Name_User = getpass.getuser()

# Ruta por defecto para almacenar el archivo de LOG auto guardado
DEFAULT_URL_LOG = "file:///C:/Users/"+Name_User+"/Desktop/Ground_Station_Log.txt"

# Número máximo de caracteres a recibir ante un pedido de posición
MAX_SIZE_COMMAND_ANGLE = 18

# Número máximo de caracteres a recibir en respuesta afirmativa o negativa
MAX_SIZE_COMMAND_RESP = 4

# Terminador de comando
END_COMMAND = '\r\n'

# Segundos en milisegundos (Difiere en algunos casos)
SECOND = 1000

# Minuto en milisegundos.
MINUTE = 60 * SECOND

# Hora en milisegundos.
HOUR   = 60 * MINUTE

# Auto guardado cada 60 seg (Si hay cambios)
Tiempo_AutoSave = 1 * MINUTE

# Timer de chequeo de puerto serie
Tiempo_Check_Ports = 0 * SECOND

# Timer de chequeo de tracking cada 60 seg
Tiempo_Tracking = 1 * MINUTE

# Timer de actualizacion de graficos cada 30 seg
Tiempo_Actualizacion_Graf = 30 * SECOND

Dict_Text_Commands = {
    'U' : '[Mov. Arriba]',
    'D' : '[Mov. Abajo]',
    'L' : '[Mov. Izq]',
    'R' : '[Mov. Drcha]',
    'A' : '[Stop Acimut]',
    'E' : '[Stop Elevación]',
    'S' : '[Stop Global]'
}

# Conexión con el puerto serie
Serial_PORT = serial.Serial()
#############################################################################################################
#                                                Fin Constantes                                             #
#############################################################################################################

# ======================================== TO DO ======================================== #
'''
   Nota: Mientra más asteriscos tengo más importante es la cosa

    ** Continuación con la parte gráfica, borrar la pestaña de settings y colocar una pestaña de ayuda para generar el 
        el archivo de texto y color medianamente hacer las cosas para no manquearla.
    
    ** Definir como hacer la parte del stop del tracking enviado por la parte gráfica.

    *** Testar la recepción de datos del MCU y el envió a la PC ante una solicitud de ángulos con la nueva implementación
'''
# ======================================================================================= #

class VentanaPrincipal(QObject):

    # String que almacena datos enviados desde la ventana de LOG
    DataToSave = ""

    # String que almacena datos enviados desde la ventana de LOG
    DataSaved = ""

    #############################################################################################################
    #                                           Señales a emitir                                                #
    #############################################################################################################

    # Creación de la señal que se encarga de actualizar datos en la interface cada 1 segundo, no envia datos. (podría hacerlo)
    actualizarDataToSave = Signal()

    # Señal enviada a la UI para notificar que los datos fueron guardados y puede borrar lo que tenga el LOG
    cleanLogAvalible = Signal()

    # Señal donde se envia el puerto serie a la UI
    setPortCOM = Signal(str)

    #Señal de error de envio por puerto serie
    commSerieFailed = Signal(str)

    # Señal de actualizacion de los grados graficos
    actual_graf_grados_signal = Signal(float,float)

    # Señal simple (envió de string) hacia la parte gráfica de la aplicación
    signal_To_FrontEnd = Signal(str, str)

    #############################################################################################################
    #                                        Fin Señales a emitir                                               #
    #############################################################################################################

    def __init__(self):
        QObject.__init__(self)

        self.timerautosave = QTimer()
        self.timercheckports = QTimer()
        self.timertracking = QTimer()
        self.timer_actual_graf = QTimer()

        # Ejecución de Actualizar_Interface cada vez que desborde el timer
        self.timerautosave.timeout.connect(lambda: self.autoGuardadoLog())

        # Chequeo de status de puerto de comunicaciones
        self.timercheckports.timeout.connect(lambda: self.statusPortCOM())

        # Ejecución de tracking
        self.timertracking.timeout.connect(lambda: self.Control_autonomo())

        # Ejecucion de actualizacion grafica grados
        self.timer_actual_graf.timeout.connect(lambda: self.Actualizar_Posicion())

        # Recarga de timer asociados
        self.timerautosave.start(Tiempo_AutoSave)
        self.timercheckports.start(Tiempo_Check_Ports)

        self.timertracking.start(Tiempo_Tracking)
        self.timer_actual_graf.start(Tiempo_Actualizacion_Graf)

    # No es necesario un slot por que no recibimos datos desde UI, ni tampoco una signal dado que no mandamos nada
    # La lógica de esta combinación es necesaria ya que si no puede generarse discrepancia de los datos guardados.

    # Orden de ejecución:
    #  - Timer desborda -> Ejecuta autoGuardadoLog()
    #  - autoGuardadoLog -> Envia signal a la UI
    #  - UI responde y ejecuta saveDataLog() Y si hay datos distintos en el LOG
    #  de los que ya se tenian en un princpio en DataToSave se guardan

    def autoGuardadoLog(self):
        self.actualizarDataToSave.emit()
        if self.DataSaved != self.DataToSave:
            file = open(QUrl(DEFAULT_URL_LOG).toLocalFile(), "a")
            file.write(self.DataToSave + "\n")
            self.DataSaved = self.DataToSave
            file.close()
            print("saved")

    @Slot(str)
    def saveDataLog(self,dataLog):
        if self.DataToSave != dataLog:
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
        if dataReadLog != self.DataToSave:
            file = open(QUrl(DEFAULT_URL_LOG).toLocalFile(), "a")
            file.write(dataReadLog + "\n")
            file.close()
            print("Limpiando ventana de LOG")

        self.cleanLogAvalible.emit()

    #############################################################################################################
    #                                    Actualizacion grafica de los grados                                   #
    #############################################################################################################
    # ======= WORKINK ON THIS
    # Caso crítico
    # Buffer: \r\nA,135.01,E,150.5\r\n?>\r\n
    # Máx Command single: A,135.01,E,150.5\r\n
    # Msg:     1  |         2          | 3
    # Salida del split \r\n: ['', '', 'A, 135.01, E, 0.5', '']
    #
    # =======

        #@Slot()
        # def Actualizar_Grafica(self):
        #     if Serial_PORT.in_waiting > 0:
        #         Data_From_MCU = Serial_PORT.read(Serial_PORT.inWaiting()).decode('ascii')  # read the bytes and convert from binary array to ASCII
        #         Data_Command = Data_From_MCU.split(',')
        #         if Data_Command[0] == "A" and Data_Command[2] == "E":
        #             Raw_acimut = Data_Command[1]
        #             Raw_elevacion = Data_Command[3]
        #             self.actual_graf_grados_signal.emit(float(Raw_acimut),float(Raw_elevacion))
        #             return 1
        #         else:
        #             return 0

        # def Recepcion_Datos(self):
        #     if Serial_PORT.in_waiting > 0:
        #         Data_From_MCU = Serial_PORT.read(Serial_PORT.inWaiting()).decode('ascii')  # read the bytes and convert from binary array to ASCII
        #         if Data_From_MCU == '\r\n':
        #             return 1
        #         elif Data_From_MCU == "?>\r\n":
        #             return 0
        #         else:
        #             return -1   # Levantamos verdura (Podríamos usarlo para debugear nosotros y ver que hacer si pasa en un futuro)

    def Recepcion_Datos(self):
        try:
            Data_From_MCU = Serial_PORT.read_until(END_COMMAND).decode('ascii')
            Serial_PORT.reset_input_buffer()
        except serial.SerialException:
            self.commSerieFailed.emit("[Recepcion_Datos]: No Existe Conexión con el Dispositivo")
            self.signal_To_FrontEnd.emit("USB", "Problem")
            return -1 # Error
        else:
            if(len(Data_From_MCU) >= 2 and len(Data_From_MCU) <= 4):
                print("Número de caracteres en puerto serie Man: " + str(len(Data_From_MCU)))
                print("Lectura de puerto serie Manual: " + Data_From_MCU)
                # Leemos hasta encontrar un END_COMMAND(\r\n) o un máximo de 4 caracteres o hasta que salte el timeout de lectura
                if Data_From_MCU == '\r\n':
                    return 1
                elif Data_From_MCU == '?>\r\n':
                    return 0
                else:
                    return -1 # Error
            else:
                # Leemos hasta encontrar un END_COMMAND(\r\n) o un máximo de 18 caracteres o hasta que salte el timeout de lectura
                # Si leemos hasta un END_COMMAND trabajamos siempre con un comando a la vez y nos sacamos el bardo del encolamiento
                print("Número de caracteres en puerto serie Ángulos: " + str(len(Data_From_MCU)))
                print("Lectura de puerto serie Ángulos: " + Data_From_MCU)
                Data_Split = Data_From_MCU.split('\r\n')
                # Una vez realizado el split tenemos la información de la siguiente manera:
                    #   Data_Split = ['A,135.01,E,150.05', '']
                    #   Index list   |        0         | 1 |
                    #                |  Data Command    |End|
                Data_Command = Data_Split[0].split(',')
                # Data_Command = ['A', '135.01', 'E', '150.05', '']
                # Index list     | 0 |    1    |  2 |    3    | 4 |
                if Data_Command[0] == "A" and Data_Command[2] == "E":
                    Raw_acimut = Data_Command[1]
                    Raw_elevacion = Data_Command[3]
                    self.actual_graf_grados_signal.emit(float(Raw_acimut), float(Raw_elevacion))
                    return 1
                else:
                    return 0

    #############################################################################################################
    #                                       Fin funciones de puerto serie                                       #
    #############################################################################################################

    #############################################################################################################
    #                                           Funciones de puerto serie                                       #
    #############################################################################################################

    # Descripción:
    #
    #   Función encargada de chequear el estado del puerto de comunicación usado entre la APP y el dispositivo de control
    #   Por defecto, busco el par VID:PID, que son ingresados por separdos en las listas list_PID y list VID
    #   Una vez detectado el dispositivo con sus identificadores, se conecta automáticamente con este según al puerto donde
    #   esta conectado. Por otro lado, la misma realiza un chequeo del estado de la conexión, dando información a
    #   la APP si ha ocurrido un problema con la misma.
    #   Esta función esta vinculada a un timer de período nulo, es decir, es un proceso que CORRERA EN PARALELO con la APP
    #
    # Variables Importantes:
    #
    #   list_PID:   Lista que contiene los PID del dispositivo a buscar
    #   list_VID:   Lista que contiene los VID de los dispositivos a buscar
    #   serial.tools.list_ports.grep(): API para buscar coincidencias entre los PID y VID ingresados.
    #   Device_To_Found: Lista que contendra los puertos serie que tengan una concidencia de PID y VID con los buscados
    def statusPortCOM(self):
        # Deben de ser ingresado en formato hexadecimal (sin 0x), sino no podran ser encontrados
        # ID: 0x6860 (o ID: 27620) -> 6860 (HEXADECIMAL)
        list_PID = ['6001']
        list_VID = ['0403']
        # Recorremos la lista de PID ingresados
        for Index in range(len(list_PID)):
            # Procedemos a buscar el dispositivo que contenga PID en su descriptor de HW
            # Si la lista es de longitud distinta de cero es por que hay un dispositivo que matcheo con el PID ingresado
            Device_To_Found = list(serial.tools.list_ports.grep(list_VID[Index] + ':' + list_PID[Index]))
            if len(Device_To_Found) != 0:
                for USB_Port in Device_To_Found:
                    try:
                        if Serial_PORT.is_open == False:
                            Serial_PORT.port = USB_Port.device
                            #Serial_PORT.port = "COM2"  # Debug con termite y VSPE para virtualizar puertos
                            Serial_PORT.baudrate = 9600
                            Serial_PORT.timeout = 0.05   # Timeout de lectura en segundos (50 mS) | Tiempo máx = (18 (Bytes) * 1 / 9600) ≈ 0.00187 S, estamos holgados
                    except serial.SerialException:
                        if Serial_PORT.is_open == True:
                            self.commSerieFailed.emit("[statusPortCOM]: Ha Ocurrido un Problema con el Puerto: " + USB_Port.device)
                            self.signal_To_FrontEnd.emit("USB", "Problem")
                            Serial_PORT.close()
                        if Serial_PORT.is_open == False:
                            self.commSerieFailed.emit("[statusPortCOM]: No se ha Podido Conectar con el Puerto: " + USB_Port.device)
                            self.signal_To_FrontEnd.emit("USB", "Bad")
                    else:
                        if(Serial_PORT.is_open == False):
                            try:
                                self.commSerieFailed.emit("[statusPortCOM]: Intentando Conectar con " + USB_Port.device + "...")
                                Serial_PORT.open()
                            except:
                                self.commSerieFailed.emit("[statusPortCOM]: ¡Falla al abrir el puerto " + USB_Port.device + "!")
                                self.signal_To_FrontEnd.emit("USB", "Bad")
                            else:
                                self.commSerieFailed.emit("[statusPortCOM]: ¡Conectado al " + USB_Port.device + "!")
                                self.signal_To_FrontEnd.emit("USB", "Good")
            else:
                self.commSerieFailed.emit("[statusPortCOM]: Dispositivo No Encontrado")
                self.signal_To_FrontEnd.emit("USB", "Problem")
        time.sleep(0.05)  # Sleep de Seguridad de 50 mS

    #############################################################################################################
    #                                   Fin funciones de puerto serie                                           #
    #############################################################################################################

    #############################################################################################################
    #                                           Comando manuales                                                #
    #############################################################################################################

    # U // UP Direction Rotation
    @Slot()
    def moveUp(self):
        #comando a enviar: "U\r"
        cmd = 'U\r'
        self.Enviar_Comando(cmd)

    # D // DOWN Direction Rotation
    @Slot()
    def moveDown(self):
        #comando a enviar: "D\r"
        cmd = 'D\r'
        self.Enviar_Comando(cmd)

    #R // Clockwise Rotation
    @Slot()
    def moveToRight(self):
        #comando a enviar: "R\r"
        cmd = 'R\r'
        self.Enviar_Comando(cmd)

    #L// Counter Clockwise Rotation
    @Slot()
    def moveToLeft(self):
        #comando a enviar: "L\r"
        cmd = 'L\r'
        self.Enviar_Comando(cmd)

    # A // CW/CCW Rotation Stop
    @Slot()
    def stopAcimut(self):
        #comando a enviar: "A\r"
        cmd = 'A\r'
        self.Enviar_Comando(cmd)

    # E // UP/DOWN Direction Rotation Stop
    @Slot()
    def stopElevacion(self):
        #comando a enviar: "E\r"
        cmd = 'E\r'
        self.Enviar_Comando(cmd)

    # E // UP/DOWN Direction Rotation Stop
    @Slot()
    def stopEverthing(self):
        #comando a enviar: "S\r"
        cmd = 'S\r'
        self.Enviar_Comando(cmd)

    #############################################################################################################
    #                                         Fin comando manuales                                              #
    #############################################################################################################

    #############################################################################################################
    #                                   Funciones vinculadas con el tracking                                    #
    #############################################################################################################

    def Control_autonomo(self):
       global data_acimut
       global data_elevacion
       global Flag_Enable_Send

       hora_actual = time.strftime('%H:%M')
       """ -------- Solicito fecha y la genero al formato para comparar con el archivo ----------"""
       fecha_sin_analizar = time.strftime('%m/%d/%y')
       objDate = datetime.strptime(fecha_sin_analizar, '%m/%d/%y')
       fecha = datetime.strftime(objDate, '%Y-%b-%d')

       try:
           file = open("comandos4.txt", 'r')
       except:
           print("No Se Encontro el Archivo de Comandos")
           return
       else:
           total_lines = sum(1 for line in file)
           file.seek(0)

       linea = file.readline()
       while len(linea) > 0:
           dato1 = linea.split(',')
           if dato1[0] != '\n':
               if fecha == dato1[0] and dato1[1] == hora_actual:
                  data_acimut = dato1[2]
                  data_elevacion = dato1[3]
                  parametros = "P" + str(float(dato1[2])) + " " + str(float(dato1[3]))
                  Serial_PORT.write(parametros.encode('ascii') + b'\r')
                  if self.Recepcion_Datos() == 1:
                      self.signal_To_FrontEnd.emit("Tracking", "Good")
                      file.close()
                      break
                  elif self.Recepcion_Datos() == 0:
                      self.signal_To_FrontEnd.emit("Tracking", "Problem")
                      file.close()
                      break
           elif dato1[0] == '':     # Fin de archivo detectado
                   self.signal_To_FrontEnd.emit("Tracking", "Off")
                   file.close()
           linea = file.readline()

    #############################################################################################################
    #                                   Fin funciones vinculadas con el tracking                                #
    #############################################################################################################

    #############################################################################################################
    #                                 Funciones vinculadas con solicitud de ángulos                             #
    #############################################################################################################

    # Descripción:
    #   Ejecución períodica de la misma cada 60 segundos ante el desborde o overflow del timer de actualización gráfica.
    #   Esta es la que posee mayor prioridad de envió por puerto serie, si el timer esta en 0 (overflow), hasta no terminar
    #   la ejecución de esta función no se procedera con cualquier otro envió de puerto serie.

    def Actualizar_Posicion(self):
        #comando a enviar: "B\r"
        cmd = 'B\r'
        try:
            if(Serial_PORT.is_open):
                Serial_PORT.write(cmd.encode('utf-8'))
            else:
                self.commSerieFailed.emit("[Act. Posición]: Falla de Envió por Puerto Serie")
                self.signal_To_FrontEnd.emit("USB", "Problem")
        except serial.SerialException :
           self.commSerieFailed.emit("[Act. Posición]: Falla de Envió por Puerto Serie")
           self.signal_To_FrontEnd.emit("USB", "Problem")
        else:
            if self.Recepcion_Datos() == 1:
                self.signal_To_FrontEnd.emit("USB", "Good")
            elif self.Recepcion_Datos() == 0:
                self.commSerieFailed.emit("[Act. Posición]: Comando No Renocido")
                self.signal_To_FrontEnd.emit("USB", "Problem")

    # Descripción:
    #
    #   Enviar_Comando se encarga de escribir a través del puerto serie los comandos y transmitirlos al dispositivo. La misma
    #   cuenta con un bucle while para evitar el encolamiento y mal funcionamiento de datos por parte de la APP. Realiza un chequeo
    #   del estado del timer (timer_actual_graf) antes de proceder con el envió del comando al dispositivo.
    #   Se ejecutara la misma ante eventos manuales de la parte gráfica.
    #
    # Variables Importantes:
    #   Letra_Cmd: ID o Comando a enviar al dispositivo
    #   timer_actual_graf.remainingTime():  Tiempo restante antes del overflow del timer de actualización gráfica
    #   Dict_Text_Commands[Letra_Cmd]: Texto Asociado al Comando a Ser enviado a la APP.

    def Enviar_Comando(self,Command):
        Letra_Cmd = Command[0:1]
        #print(Letra_Cmd)
        try:
            while (self.timer_actual_graf.remainingTime() == 0):    # Cuidado si se modifica o elimina timer_actual_graf (QTimer)
                time.sleep(0.01)  # Sleep de 10 mS
            else:
                try:
                    if(Serial_PORT.is_open):
                        Serial_PORT.write(Command.encode('utf-8'))
                    else:
                        self.commSerieFailed.emit(Dict_Text_Commands[Letra_Cmd] + " :El puerto Serie no se Encuentra Abierto")
                        self.signal_To_FrontEnd.emit("USB", "Problem")
                except serial.PortNotOpenError:
                    self.commSerieFailed.emit(Dict_Text_Commands[Letra_Cmd]  + " :El puerto Serie no se Encuentra Abierto")
                    self.signal_To_FrontEnd.emit("USB", "Problem")
        except serial.SerialException:
           self.commSerieFailed.emit("[Enviar_Comando]:" + ": Falla de Envió por Puerto Serie")
           self.signal_To_FrontEnd.emit("USB", "Problem")
        else:
            if self.Recepcion_Datos() == 1:
                self.signal_To_FrontEnd.emit("USB", "Good")
            elif self.Recepcion_Datos() == 0:
                self.commSerieFailed.emit(Dict_Text_Commands[Letra_Cmd]   + " :Comando No Reconocido")
                self.signal_To_FrontEnd.emit("USB", "Problem")

    #############################################################################################################
    #                                 Fin funciones vinculadas con solicitud de ángulos                         #
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