# This Python file uses the following encoding: utf-8

# Developed by Jeremías Castillo

#############################################################################################################
#                                                Imports                                                    #
#############################################################################################################
# Modulo que permite funciones relacionados con tiempo
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
import datetime
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
MAX_SIZE_COMMAND_ANGLE = 19

# Número máximo de caracteres a recibir en respuesta afirmativa o negativa
MAX_SIZE_COMMAND_RESP = 4

# Terminador de comando
END_COMMAND = '\r\n'

# Segundos en milisegundos (USAR SOLO EN QTIMER)
QTIMER_SECOND = 1000

# Minuto en milisegundos. (USAR SOLO EN QTIMER)
QTIMER_MINUTE = 60 * QTIMER_SECOND

# Hora en milisegundos. (USAR SOLO EN QTIMER)
QTIMER_HOUR   = 60 * QTIMER_MINUTE

Dict_Text_Commands = {
    'U' : '[moveUp()]',
    'D' : '[moveDown()]',
    'L' : '[moveToLeft()]',
    'R' : '[moveToRight()]',
    'A' : '[stopAcimut()]',
    'E' : '[stopElevacion()]',
    'S' : '[stopEverthing()]',
    'P' : '[Act_Posicion()]'
}

# Instanciación de Puerto Serie, a la espera de una conexión.
Serial_PORT = serial.Serial()

boolTracking_Enable = False

boolDEBUG = True
#############################################################################################################
#                                                Fin Constantes                                             #
#############################################################################################################

# ======================================== TO DO ======================================== #
'''
   Nota: Mientra más asteriscos tengo más importante es la cosa

    ** Continuación con la parte gráfica, borrar la pestaña de settings y colocar una pestaña de ayuda para generar el 
        el archivo de texto y color medianamente hacer las cosas para no manquearla.
    
    ** Definir como hacer la parte del stop del tracking enviado por la parte gráfica.

    *** Testar la recepción de datos del MCU y el envió a la PC ante una solicitud de ángulos con la nueva implementación (** DONE **)
'''
# ======================================================================================= #

class VentanaPrincipal(QObject):

    # String que almacena datos enviados desde la ventana de LOG
    DataToSave = ""

    # String que almacena datos enviados desde la ventana de LOG
    DataSaved = ""

    listDataCommands = []

    #############################################################################################################
    #                                           Señales a emitir                                                #
    #############################################################################################################

    # Señal que se encarga de actualizar datos en la interface cada 1 segundo, no envia datos. (podría hacerlo)
    actualizarDataToSave = Signal()

    # Señal enviada al frontend para notificar que los datos fueron guardados y puede borrar lo que tenga el LOG
    cleanLogAvalible = Signal()

    # Señal de emisión de error en puerto serie
    signalCommSerieFailed = Signal(str)

    # Señal de actualizacion de gráficas.
    signalActualGraf = Signal(float,float)

    # Señal para cambiar el estado de componentes en el front end.
    signalChangeStateFrontEnd = Signal(str, str)

    # Señal de emisión de eventos ÚNICOS (NO USAR EN STATUSPORTCOMM)
    signalCommBackFront = Signal(str)

    signalTrackingEnded = Signal()

    signalTrackingStopped = Signal()
    #############################################################################################################
    #                                        Fin Señales a emitir                                               #
    #############################################################################################################

    def __init__(self):
        QObject.__init__(self)

        self.timerAutoSave = QTimer()
        self.timerCheckPorts = QTimer()
        self.timerTracking = QTimer()
        self.timerActualGraf = QTimer()

        # Ejecución de Actualizar_Interface cada vez que desborde el timer
        self.timerAutoSave.timeout.connect(lambda: self.autoGuardadoLog())

        # Chequeo de status de puerto de comunicaciones
        self.timerCheckPorts.timeout.connect(lambda: self.statusPortCOM())

        # Ejecución de tracking
        self.timerTracking.timeout.connect(lambda: self.Control_autonomo())

        # Ejecucion de actualizacion grafica grados
        self.timerActualGraf.timeout.connect(lambda: self.Actualizar_Posicion())

        # Recarga de timer asociados
        self.timerAutoSave.start(1 * QTIMER_MINUTE)
        self.timerCheckPorts.start(0 * QTIMER_SECOND)

    #===================================== TO TEST AND DEBUGGING ==========================================
        self.timerTracking_v2_1 = QTimer()
        self.timerTracking_v2_1.timeout.connect(lambda: self.Control_autonomov_2_1(self.listDataCommands))
        self.timerTracking_v2_1.start(1 * QTIMER_MINUTE)

        self.timerCheckRX = QTimer()
        self.timerCheckRX.timeout.connect(lambda: self.getDataRXPort())
        self.timerCheckRX.start(0 * QTIMER_SECOND)
    #=======================================================================================================

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

    def checkforMaskData(self,objFileLocal):
        strMaskToFoundUT = ' Date__(UT)__HR:MN, , ,Azi_(a-app), Elev_(a-app),'
        strMaskToFoundZONE = ' Date_(ZONE)_HR:MN, , ,Azi_(a-app), Elev_(a-app),'
        strLineInFile = objFileLocal.readline()
        while len(strLineInFile) > 0 and strLineInFile != '':
            if (strMaskToFoundUT or strMaskToFoundZONE) in strLineInFile:
                objFileLocal.seek(0)    # Rewind of file
                return True    #1 Mask Founded (UT or ZONE)
                break
            strLineInFile = objFileLocal.readline()
        else:
            objFileLocal.seek(0)  # Rewind of file
            return False        #Mask not Founded

    def appendListCommands(self,strCmd):
        self.listDataCommands.append(strCmd)

    def clearListCommands(self):
        self.listDataCommands.clear

    def setDataFormatCSV(self,objFileLocal):
        strMarcaInicio = '$$SOE\n'
        strMarcaFin = '$$EOE\n'
        flaginit = 0
        listDataCmd = []

        TEST_TXT = open("C:/Users/"+Name_User+"/Desktop/TEST_TXT.txt","w")   # Solo para testeo

        listDataCmd = objFileLocal.readline()
        while listDataCmd != strMarcaInicio:
            listDataCmd = objFileLocal.readline()
            if listDataCmd == '':
                break
        else:
            listDataCmd = objFileLocal.readline()
            while(listDataCmd != strMarcaFin):
                listLineRawCmd = listDataCmd.split(",")
                listDataCmd = listLineRawCmd[0] + "," + str(float("{0:.1f}".format(float(listLineRawCmd[3])))) + "," + str(float("{0:.1f}".format(float(listLineRawCmd[4]))))
                listDataCmd = listDataCmd.split(' ')
                strDataToWrite = listDataCmd[1] + "," + listDataCmd[2] + "\n"
                TEST_TXT.write(strDataToWrite)   # Solo para testeo
                self.appendListCommands(strDataToWrite)
                listDataCmd = objFileLocal.readline()
                if listDataCmd == '':
                    break
            else:
                objFileLocal.seek(0)
                TEST_TXT.close()
                return True
        objFileLocal.seek(0)
        return False

    @Slot(str)
    def chargeThisFile(self,filePath):
        self.clearListCommands()
        try:
            objFileOpen = open(QUrl(filePath).toLocalFile(), "r")
        except:
            self.signalCommBackFront.emit("Problema con la Carga de Datos. Reintentar Nuevamente.")
        else:
            if self.checkforMaskData(objFileOpen) == True:
                self.getDataofTracking(objFileOpen)
                self.setDataFormatCSV(objFileOpen)
                self.signalChangeStateFrontEnd.emit("File Success", "El Archivo de Tracking ha Sido Cargado Correctamente")
                objFileOpen.close()
            else:
                self.signalCommBackFront.emit("No se ha Detectado el Formato Adecuado. Abortado")
                objFileOpen.close()

    def getDataofTracking(self,objFileLocal):

        strMaskTarget   = "Target body name:"
        strMaskStart    = "Start time      :"
        strMaskStop     = "Stop  time      :"

        strLineInFile = objFileLocal.readline()
        while len(strLineInFile) > 0 and strLineInFile != '':
            if strMaskTarget in strLineInFile:
                listData = strLineInFile.split(" ")
                strData = listData[3]
                self.signalChangeStateFrontEnd.emit("Target",strData)
            elif strMaskStart in strLineInFile:
                listData = strLineInFile.split(" ")
                strData = listData[9] + " " + listData[10][:8]
                self.signalChangeStateFrontEnd.emit("Start Time",strData)
            elif strMaskStop in strLineInFile:
                listData = strLineInFile.split(" ")
                strData = listData[10] + " " + listData[11][:8]
                self.signalChangeStateFrontEnd.emit("Stop Time",strData)
                break
            strLineInFile = objFileLocal.readline()
        objFileLocal.seek(0)

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
        self.cleanLogAvalible.emit()

    #############################################################################################################
    #                                    Actualizacion grafica de los grados                                    #
    #############################################################################################################

    # ========================= WORKINK ON THIS =========================
    # Caso crítico
    # Buffer: \r\nA,135.01,E,150.5\r\n?>\r\n
    # Máx Command single: A,135.01,E,150.5\r\n
    # Msg:     1  |         2          | 3
    # Salida del split \r\n: ['', '', 'A, 135.01, E, 0.5', '']
    #
    # ====================================================================

    def Recepcion_Datos(self,objSerial):
        if (objSerial.is_open == True):
            try:
                if(objSerial.inWaiting() > 0):
                    # Leemos hasta encontrar un END_COMMAND = "\r\n". Si leemos hasta un END_COMMAND trabajamos siempre con un comando a la vez y nos sacamos el bardo del encolamiento
                    Data_From_MCU = objSerial.read_until(END_COMMAND).decode('ascii')
                else:
                    #No hay caracteres en el buffer de recepción.
                    return
            except serial.SerialException:
                self.signalCommBackFront.emit("[Recepcion_Datos()]: No Existe Conexión con el Dispositivo")
                self.signalChangeStateFrontEnd.emit("USB - RX", "Bad")
            else:
                if Data_From_MCU == '\r\n' or Data_From_MCU == '?>\r\n':
                    # ======================= FOR DEBUGGING =======================#
                    #print("Número de caracteres en puerto serie Man: " + str(len(Data_From_MCU)))
                    #print("Lectura de puerto serie Manual: " + Data_From_MCU)
                    # ======================= FOR DEBUGGING =======================#
                    if Data_From_MCU == '\r\n':
                        self.signalChangeStateFrontEnd.emit("USB - RX", "Good")     #Recepción de comando OK
                    elif Data_From_MCU == '?>\r\n':
                        self.signalChangeStateFrontEnd.emit("USB - RX", "Problem")  #Recepción de comando NOT OK
                    else:
                        self.signalChangeStateFrontEnd.emit("USB - RX", "Bad")      #Error

                elif Data_From_MCU[0] == 'C':

                    Data_Split = Data_From_MCU.split('\r\n')
                    # Una vez realizado el split tenemos la información de la siguiente manera:
                    #   Data_Split = ['Cx', '']   ---  x : Valor entero posible -1, 0, 1.
                    #   Index list   | 0  | 1 |

                    Data_Command = Data_Split[0]

                    if Data_Command == 'C0':
                        self.signalCommBackFront.emit("[Recepcion_Datos()]: Secuencia de Calibración Detectada")
                    elif Data_Command == 'C1':
                        self.signalCommBackFront.emit("[Recepcion_Datos()]: Secuencia de Calibración Finalizada")
                    else:
                        self.signalCommBackFront.emit("[Recepcion_Datos()]: Error de Calibración")

                else:
                    # ======================= FOR DEBUGGING =======================#
                    #print("Número de caracteres en puerto serie Ángulos: " + str(len(Data_From_MCU)))
                    #print("Lectura de puerto serie Ángulos: " + Data_From_MCU)
                    # ======================= FOR DEBUGGING =======================#

                    Data_Split = Data_From_MCU.split('\r\n')
                    # Una vez realizado el split tenemos la información de la siguiente manera:
                        #   Data_Split = ['A,135.01,E,150.05', '']
                        #   Index list   |        0          | 1 |
                        #                |  Data Command     |End|

                    Data_Command = Data_Split[0].split(',')
                    # Data_Command = ['A', '135.01', 'E', '150.05', '']
                    # Index list     | 0 |    1    |  2 |    3    | 4 |

                    if Data_Command[0] == "A" and Data_Command[2] == "E":
                        Raw_acimut = Data_Command[1]
                        Raw_elevacion = Data_Command[3]
                        self.signalActualGraf.emit(float(Raw_acimut), float(Raw_elevacion))
                        self.signalChangeStateFrontEnd.emit("USB - RX", "Good")     #Recepción de comando OK
                    else:
                        self.signalChangeStateFrontEnd.emit("USB - RX", "Problem")  #Recepción de comando NOT OK

    #############################################################################################################
    #                                       Fin funciones de puerto serie                                       #
    #############################################################################################################

    #############################################################################################################
    #                                         Funciones de puerto serie                                         #
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
        global Serial_PORT
        # Deben de ser ingresado en formato hexadecimal (sin 0x), sino no podran ser encontrados
        # ID: 0x6860 (o ID: 27620) -> 6860 (HEXADECIMAL)
        list_PID = ['6001']
        list_VID = ['0403']
        # Recorremos la lista de PID ingresados
        for Index in range(len(list_PID)):
            # Procedemos a buscar el dispositivo que contenga PID en su descriptor de HW
            # Si la lista es de longitud distinta de cero es por que hay un dispositivo que matcheo con el PID ingresado

            Device_To_Found = list(serial.tools.list_ports.grep(list_VID[Index] + ':' + list_PID[Index]))

            if len(Device_To_Found) != 0 or boolDEBUG == True:
                if(boolDEBUG):
                    if Serial_PORT.is_open == False:
                        Serial_PORT = serial.Serial("COM2",9600)
                else:
                    for USB_Port in Device_To_Found:
                        try:
                            #Nota: Chequeo inicial del estado de la instancia para proceder a realizar una configuración de la misma en caliente (ya creada).
                            if Serial_PORT.is_open == False:
                                #Serial_PORT.port = USB_Port.device
                                Serial_PORT.port = "COM2"  # Debug con termite y VSPE para virtualizar puertos
                                Serial_PORT.baudrate = 9600
                                Serial_PORT.timeout = 0.05   # Timeout de lectura en segundos (50 mS) | Tiempo máx = (18 (Bytes) * 1 / 9600) ≈ 0.00187 seg
                        except serial.SerialException:
                            if Serial_PORT.is_open == True:
                                self.signalCommSerieFailed.emit("[statusPortCOM()]: Problema con la Instancia del Puerto " + USB_Port.device)
                                self.signalCommSerieFailed.emit("[statusPortCOM()]: Cerrando Conexión con el Puerto  " + USB_Port.device)
                                Serial_PORT.close()
                            elif Serial_PORT.is_open == False:
                                self.signalCommSerieFailed.emit("[statusPortCOM()]: Desconexión Forzada del Puerto " + USB_Port.device)
                                self.signalCommSerieFailed.emit("[statusPortCOM()]: Cerrando Conexión con el Puerto  " + USB_Port.device)
                                Serial_PORT.close()
                        else:
                            if Serial_PORT.is_open == False:
                                try:
                                    Serial_PORT.port = USB_Port.device
                                    # Serial_PORT.port = "COM2"  # Debug con termite y VSPE para virtualizar puertos
                                    Serial_PORT.baudrate = 9600
                                    Serial_PORT.timeout = 0.05  # Timeout de lectura en segundos (50 mS) | Tiempo máx = (18 (Bytes) * 1 / 9600) ≈ 0.00187 seg
                                    Serial_PORT.open()
                                    self.signalCommSerieFailed.emit("[statusPortCOM()]: Intentando Conectar Dispositivo a través del Puerto " + USB_Port.device + "...")
                                    self.signalChangeStateFrontEnd.emit("USB - TX", "")     # Reset necesario por si tocan botones manuales sin conexión con dispositivo
                                    self.signalChangeStateFrontEnd.emit("USB - RX", "")     # Reset necesario por si tocan botones manuales sin conexión con dispositivo
                                    self.timerActualGraf.start(1 * QTIMER_SECOND)           # Arranque al timer de actualización gráfica
                                except:
                                    self.signalCommSerieFailed.emit("[statusPortCOM()]: ¡El puerto " + USB_Port.device + " esta siendo usado por otro dispositivo!")
                                    Serial_PORT.close()  # Just in case . . .
                                else:
                                    self.signalCommSerieFailed.emit("[statusPortCOM()]: ¡¡ Dispositivo Conectado en el Puerto " + USB_Port.device + " !!")
                        finally:
                            if Serial_PORT.is_open == True:
                                self.signalChangeStateFrontEnd.emit("USB", "Good")
                            else:
                                self.signalCommSerieFailed.emit("[statusPortCOM()]: Cerrando Conexión con el Puerto  " + USB_Port.device)
                                self.signalChangeStateFrontEnd.emit("USB", "Bad")
            else:
                self.signalCommSerieFailed.emit("[statusPortCOM()]: En Busqueda del Dispositivo...")
                self.signalChangeStateFrontEnd.emit("USB", "Problem")

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
        self.signalTrackingStopped.emit()
        self.Enviar_Comando(cmd)

    #############################################################################################################
    #                                         Fin comando manuales                                              #
    #############################################################################################################

    #############################################################################################################
    #                                   Funciones vinculadas con el tracking                                    #
    #############################################################################################################

    @Slot()
    def enableTracking(self):
        global boolTracking_Enable
        # try:
        #     objFile = open("tracking_test.txt", 'r')
        # except:
        #     self.signalChangeStateFrontEnd.emit("Tracking", "Bad")
        #     self.signalCommBackFront.emit("[Control_Autonomo_v2_0()]: Archivo de Tracking no Encontrado. Tracking Abortado")
        #     self.signalTrackingEnded.emit()
        # else:
        boolTracking_Enable = True
        self.signalChangeStateFrontEnd.emit("Tracking", "Good")
        self.signalCommBackFront.emit("[enableTracking()]: Tracking Habilitado")
        #self.timerTracking_v2.start(1 * QTIMER_MINUTE)
        self.timerTracking_v2_1.start(1 * QTIMER_MINUTE)

    @Slot()
    def stopTracking(self):
        global boolTracking_Enable
        boolTracking_Enable = False
        self.signalChangeStateFrontEnd.emit("Tracking", "Stoped")
        self.signalCommBackFront.emit("[stopTracking()]: Tracking Detenido")

    @Slot()
    def continueTracking(self):
        global boolTracking_Enable
        boolTracking_Enable = True
        self.signalChangeStateFrontEnd.emit("Tracking", "Good")
        self.signalCommBackFront.emit("[continueTracking()]: Tracking Reanudado")

    @Slot()
    def endTracking(self):
        global boolTracking_Enable
        boolTracking_Enable = False
        self.signalChangeStateFrontEnd.emit("Tracking", "Off")
        self.signalCommBackFront.emit("[endTracking()]: Tracking Interrumpido")
        self.signalTrackingEnded.emit()
        #self.timerTracking_v2_0.stop()
        self.timerTracking_v2_1.stop()

    def Control_autonomov_2_1(self,listCmd):
        global boolTracking_Enable
        objTimeNow = datetime.datetime.now()
        sMinuteNow = objTimeNow.strftime('%M')
        sLastMinute = 0
        iTotalLines = len(listCmd)

        if (boolTracking_Enable == True):
            iCantLineasLeidas = 0
            for strCmdAct in listCmd:
                listCmdAct = strCmdAct.split(',')
                sYearMonthDay = objTimeNow.strftime('%Y-%b-%d')
                sHourMinute = objTimeNow.strftime('%H:%M')
                if listCmdAct[0] == sYearMonthDay and listCmdAct[1] == sHourMinute:
                    fDataAcimut = float(listCmdAct[2])
                    fDataElevacion = float(listCmdAct[3])
                    sCmd = "P" + str(fDataAcimut) + " " + str(fDataElevacion) + "\r"
                    self.signalCommBackFront.emit("[Tracking]: Comando Generado: " + sCmd)
                    self.Enviar_Comando(sCmd)
                    if self.Recepcion_Datos(Serial_PORT) == 1:
                        self.signalChangeStateFrontEnd.emit("Tracking", "Good")
                        self.signalCommBackFront.emit("[Control_autonomo_v2_0()]: Comando Reconocido")
                        break
                    elif self.Recepcion_Datos(Serial_PORT) == 0:
                        self.signalChangeStateFrontEnd.emit("Tracking", "Problem")
                        self.signalCommBackFront.emit("[Control_autonomo_v2_0()]: Comando No Reconocido")
                        break
                    else:
                        self.signalChangeStateFrontEnd.emit("Tracking", "Bad")
                        self.signalCommBackFront.emit("[Control_autonomo_v2_0()]: Recepción Erronea")
                else:
                    iCantLineasLeidas = iCantLineasLeidas + 1
                    continue

            if (iCantLineasLeidas == iTotalLines and boolTracking_Enable == True):
                self.signalChangeStateFrontEnd.emit("Tracking", "Off")
                self.signalCommBackFront.emit("[Tracking]: No Hay más Datos a enviar. Tracking Finalizado")
                boolTracking_Enable = False
                self.timerTracking_v2_1.stop()
                self.signalTrackingEnded.emit()
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
        if (Serial_PORT.is_open):
            try:
                Serial_PORT.write(cmd.encode('utf-8'))
                self.signalChangeStateFrontEnd.emit("USB - TX", "Good")
            except serial.SerialException:
               self.signalCommBackFront.emit("[Actualizar_Posicion()]: Falla de Envió por Puerto Serie")
               self.signalChangeStateFrontEnd.emit("USB - TX", "Bad")
            else:
                if self.Recepcion_Datos(Serial_PORT) == 1:
                    #self.signalCommBackFront.emit("[Actualizar_Posicion()]: Comando Reconocido")
                    self.signalChangeStateFrontEnd.emit("USB - RX", "Good")
                elif self.Recepcion_Datos(Serial_PORT) == 0:
                    #self.signalCommBackFront.emit("[Actualizar_Posicion()]: Comando No Reconocido")
                    self.signalChangeStateFrontEnd.emit("USB - RX", "Problem")
                else:
                    self.signalCommBackFront.emit("[Actualizar_Posicion()]: Recepción Erronea")
                    self.signalChangeStateFrontEnd.emit("USB - RX", "Bad")
        else:
            self.signalCommBackFront.emit("[Actualizar_Posicion()]: Puerto Cerrado. Envió Omitido")
            self.signalChangeStateFrontEnd.emit("USB - TX", "Bad")
            self.signalChangeStateFrontEnd.emit("USB - RX", "Bad")

    # Descripción:
    #
    #   Enviar_Comando se encarga de escribir a través del puerto serie los comandos y transmitirlos al dispositivo. La misma
    #   cuenta con un bucle while para evitar el encolamiento y mal funcionamiento de datos por parte de la APP. Realiza un chequeo
    #   del estado del timer (timerActualGraf) antes de proceder con el envió del comando al dispositivo.
    #   Se ejecutara la misma ante eventos manuales de la parte gráfica.
    #
    # Variables Importantes:
    #   Letra_Cmd: ID o Comando a enviar al dispositivo
    #   timerActualGraf.remainingTime():  Tiempo restante antes del overflow del timer de actualización gráfica
    #   Dict_Text_Commands[Letra_Cmd]: Texto Asociado al Comando a Ser enviado a la APP.
    def Enviar_Comando(self,Command):
        Letra_Cmd = Command[:1]
        while(self.timerActualGraf.remainingTime() == 0):    # Cuidado si se modifica o elimina timerActualGraf (QTimer)
            time.sleep(0.001)  # Sleep de 1 mS
        else:
            if (Serial_PORT.is_open == True):
                try:
                    Serial_PORT.write(Command.encode('utf-8'))
                    self.signalChangeStateFrontEnd.emit("USB - TX", "Good")
                except serial.PortNotOpenError:
                    self.signalCommBackFront.emit(Dict_Text_Commands[Letra_Cmd]  + ": Falla de Envió por Puerto Serie")
                    self.signalChangeStateFrontEnd.emit("USB - TX", "Bad")
                else:
                    if self.Recepcion_Datos(Serial_PORT) == 1:
                        self.signalCommBackFront.emit(Dict_Text_Commands[Letra_Cmd] + ": Comando Reconocido")
                        self.signalChangeStateFrontEnd.emit("USB - RX", "Good")
                    elif self.Recepcion_Datos(Serial_PORT) == 0:
                        self.signalCommBackFront.emit(Dict_Text_Commands[Letra_Cmd] + ": Comando No Reconocido")
                        self.signalChangeStateFrontEnd.emit("USB - RX", "Problem")
                    else:
                        self.signalCommBackFront.emit(Dict_Text_Commands[Letra_Cmd] + ": Recepción Erronea")
                        self.signalChangeStateFrontEnd.emit("USB - RX", "Bad")
            else:
                self.signalCommBackFront.emit(Dict_Text_Commands[Letra_Cmd] + ": Puerto Cerrado. Envió Omitido")
                self.signalChangeStateFrontEnd.emit("USB - TX", "Bad")
                self.signalChangeStateFrontEnd.emit("USB - RX", "Bad")

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