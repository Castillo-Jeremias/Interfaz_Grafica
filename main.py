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

byteEND_COMMAND = END_COMMAND.encode('utf-8')

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
    'S' : '[stopEverthing()]'
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

class classBackendTrackingPage(QObject):

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

    signalTracking = Signal(str)

    signalCalibration = Signal(str)
    #############################################################################################################
    #                                        Fin Señales a emitir                                               #
    #############################################################################################################

    def __init__(self):
        QObject.__init__(self)

        self.timerAutoSave = QTimer()
        self.timerCheckPorts = QTimer()
        self.timerActualGraf = QTimer()
        self.timerTracking_v2_1 = QTimer()
        self.timerAnimTXRX = QTimer()
        self.timerCheckRX = QTimer()

        self.timerAutoSave.timeout.connect(lambda: self.autoGuardadoLog())
        self.timerAnimTXRX.timeout.connect(lambda: self.Turn_Off_RX_TX())
        self.timerCheckPorts.timeout.connect(lambda: self.statusPortCOM())
        self.timerActualGraf.timeout.connect(lambda: self.Actualizar_Posicion())
        self.timerTracking_v2_1.timeout.connect(lambda: self.Control_autonomov_2_1())
        self.timerCheckRX.timeout.connect(lambda: self.Recepcion_Datos(Serial_PORT))

        # Recarga de timer asociados
        self.timerAutoSave.start(1 * QTIMER_MINUTE)
        self.timerCheckPorts.start(0 * QTIMER_SECOND)
        self.timerCheckRX.start(0 * QTIMER_SECOND)

        # Configuraciónes Especiales
        self.timerAnimTXRX.setSingleShot(True)
        self.timerAnimTXRX.setInterval(200)

    #===================================== TO TEST AND DEBUGGING ==========================================


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
            #print("saved")

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
                if boolDEBUG:
                    try:
                        if Serial_PORT.is_open == False:
                            Serial_PORT = serial.Serial("COM2",9600)
                            Serial_PORT.timeout = 0.05  # Timeout de lectura en segundos (50 mS) | Tiempo máx = (18 (Bytes) * 1 / 9600) ≈ 0.00187 seg
                            self.signalChangeStateFrontEnd.emit("USB", "Good")
                            self.timerActualGraf.start(1 * QTIMER_SECOND)  # Arranque al timer de actualización gráfica
                    except:
                        self.signalChangeStateFrontEnd.emit("USB", "Bad")
                else:
                    for USB_Port in Device_To_Found:
                        try:
                            #Nota: Chequeo inicial del estado de la instancia para proceder a realizar una configuración de la misma en caliente (ya creada).
                            if Serial_PORT.is_open == False:
                                Serial_PORT.port = USB_Port.device
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
                                    self.timerActualGraf.start(0.25 * QTIMER_SECOND)        # Arranque al timer de actualización gráfica
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
        if boolTracking_Enable == True:
            #self.signalTrackingStopped.emit()
            self.signalTracking.emit("Stop")
        self.Enviar_Comando(cmd)
        self.signalCommSerieFailed.emit("[Parada Global]: Deteniendo Movimientos")

    #############################################################################################################
    #                                         Fin comando manuales                                              #
    #############################################################################################################

    #############################################################################################################
    #                                   Funciones vinculadas con tracking                                       #
    #############################################################################################################

    @Slot()
    def enableTracking(self):
        global boolTracking_Enable
        boolTracking_Enable = True
        self.signalChangeStateFrontEnd.emit("Tracking", "Good")
        self.signalCommBackFront.emit("[enableTracking()]: Tracking Iniciado")
        self.timerTracking_v2_1.start(1 * QTIMER_SECOND)

    @Slot()
    def stopTracking(self):
        global boolTracking_Enable

        if boolTracking_Enable == True:
            self.signalChangeStateFrontEnd.emit("Tracking", "Stoped")
            self.signalCommBackFront.emit("[stopTracking()]: Tracking Interrumpido")
            boolTracking_Enable = False

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
        self.signalCommBackFront.emit("[endTracking()]: Tracking Finalizado")
        self.timerTracking_v2_1.stop()

    # Ejecución periíodica cada 1 segundo en busca de coincidencia de valores de tracking.
    # Dicha función trabaja directamente con la lista "listDataCommands" que contiene los valores cargados por el usuario.
    def Control_autonomov_2_1(self):
        global boolTracking_Enable
        strSecondExecution = "00"
        if boolTracking_Enable == True:
            objTimeNow = datetime.datetime.now()
            strSecondsNow = objTimeNow.strftime('%S')
            if strSecondsNow == strSecondExecution:
                iIndexList = 0
                iLongListMax = len(self.listDataCommands)
                for iIndexList in range(iLongListMax):
                    strCmdAct = self.listDataCommands[0]    # Buscamos coincidencia con el primer elemento en la lista, siempre.
                    strCmdAct = strCmdAct.strip()   # Elimino espacios y \n
                    listCmdAct = strCmdAct.split(',')
                    sYearMonthDay = objTimeNow.strftime('%Y-%b-%d')
                    sHourMinute = objTimeNow.strftime('%H:%M')
                    if listCmdAct[0] == sYearMonthDay and listCmdAct[1] == sHourMinute:

                        # ======================= FOR DEBUGGING =======================#
                        #print("Comando Retirado (próximo a enviar) de la lista 'listDataCommands': " + strCmdAct)
                        # ======================= FOR DEBUGGING =======================#

                        fDataAcimut = float(listCmdAct[2])
                        fDataElevacion = float(listCmdAct[3])
                        sCmd = "P" + str(fDataAcimut) + " " + str(fDataElevacion) + "\r"
                        self.Enviar_Comando(sCmd)

                        sCmd = sCmd.strip() #Se retira el "\r" para bug visual en gráfica
                        self.signalCommBackFront.emit("[Tracking()]: Comando Generado: " + sCmd)

                        # Removemos el elemento que ha sido enviado de la lista "listDataCommands"
                        self.listDataCommands.remove(strCmdAct + "\n")
                        break
                    elif listCmdAct[0] < sYearMonthDay or listCmdAct[1] < sHourMinute:
                        # ======================= FOR DEBUGGING =======================#
                        #print("Comando Descartado de la listDataCommands: " + strCmdAct)
                        # ======================= FOR DEBUGGING =======================#

                        # Retiramos el elemento que ya no sirve
                        self.listDataCommands.remove(strCmdAct + "\n")
                else:
                    if len(self.listDataCommands) == 0 and boolTracking_Enable == True:
                        self.signalChangeStateFrontEnd.emit("Tracking", "Off")
                        self.signalCommBackFront.emit("[Tracking()]: No se han Encontrado Datos a Enviar")
                        self.signalTracking.emit("End")

                if len(self.listDataCommands) == 0 and boolTracking_Enable == True:
                    self.signalChangeStateFrontEnd.emit("Tracking", "Off")
                    self.signalCommBackFront.emit("[Tracking()]: Se han Enviado Todos los Datos")
                    self.signalTracking.emit("End")
    #############################################################################################################
    #                                   Fin funciones vinculadas con tracking                                   #
    #############################################################################################################

    #############################################################################################################
    #                                 Funciones vinculadas con solicitud de ángulos                             #
    #############################################################################################################

    # Descripción:
    #   Ejecución períodica de la misma cada 250 mSeg ante el desborde o overflow del timer de actualización gráfica.
    #   Esta es la que posee mayor prioridad de envió por puerto serie, si el timer esta en 0 (overflow), hasta no terminar
    #   la ejecución de esta función no se procedera con cualquier otro envió de puerto serie.
    def Actualizar_Posicion(self):
        #comando a enviar: "B\r"
        cmd = 'B\r'
        if Serial_PORT.is_open == True:
            try:
                Serial_PORT.write(cmd.encode('utf-8'))
                #self.signalChangeStateFrontEnd.emit("USB - TX", "Good")
            except serial.SerialException:
               self.signalCommBackFront.emit("[Actualizar_Posicion()]: Falla de Envió por Puerto Serie")
               #self.signalChangeStateFrontEnd.emit("USB - TX", "Problem")
        else:
            self.signalCommBackFront.emit("[Actualizar_Posicion()]: Puerto Cerrado. Envió Omitido")
            #self.signalChangeStateFrontEnd.emit("USB - TX", "Bad")

    #############################################################################################################
    #                              Fin funciones vinculadas con solicitud de ángulos                            #
    #############################################################################################################

    #############################################################################################################
    #                         Funciones vinculadas con envió y recepción por puerto serie                       #
    #############################################################################################################

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
        if self.timerActualGraf.remainingTime() == 0:    # Cuidado si se modifica o elimina timerActualGraf (QTimer)
            time.sleep(0.0001)  # Sleep de 0.1 mS
        else:
            if Serial_PORT.is_open == True:
                try:
                    Serial_PORT.write(Command.encode('utf-8'))
                    self.signalChangeStateFrontEnd.emit("USB - TX", "Good")
                except serial.PortNotOpenError:
                    self.signalCommBackFront.emit(Dict_Text_Commands[Letra_Cmd]  + ": Falla de Envió por Puerto Serie")
                    self.signalChangeStateFrontEnd.emit("USB - TX", "Bad")
            else:
                self.signalCommBackFront.emit(Dict_Text_Commands[Letra_Cmd] + ": Puerto Cerrado. Envió Omitido")
                self.signalChangeStateFrontEnd.emit("USB - TX", "Bad")
        self.timerAnimTXRX.start()

    def Turn_Off_RX_TX(self):
        self.signalChangeStateFrontEnd.emit("USB - TX", "")
        self.signalChangeStateFrontEnd.emit("USB - RX", "")

    # Descripción:
    #
    #   Recepcion_Datos se encarga de chequear de forma "paralela" el buffer de recepción del puerto al cual estamos conectados.
    #   Si existiran datos a leer, esta función los extrae, notifica a la UI (animaciones) y reacciona al evento encontrado.
    #
    #   Comentario: Si estamos en modo debug y alguien envia algo "hardcodeado" o un comando escrito a mano se va a colgar
    #               o saltara un error dado que busca el "END_COMMAND" y no existe.
    def Recepcion_Datos(self,objSerial):
        # Estado de puerto: Abierto y hay datos en el buffer de recepción
        if objSerial.is_open == True and objSerial.inWaiting() > 0:
            try:
                listData_From_MCU = []
                # Leemos hasta encontrar un END_COMMAND = "\r\n". Si leemos hasta un END_COMMAND trabajamos siempre con un comando a la vez y nos sacamos el bardo del encolamiento
                listData_From_MCU.append(objSerial.read_until(byteEND_COMMAND).decode('ascii'))

                while objSerial.inWaiting()> 0:
                    listData_From_MCU.append(objSerial.read_until(byteEND_COMMAND).decode('ascii'))
                    if objSerial.inWaiting() == 0:
                        break
                    else:
                        continue

            except serial.SerialException:
                self.signalCommBackFront.emit("[Recepcion_Datos()]: No Existe Conexión con el Dispositivo")
                self.signalChangeStateFrontEnd.emit("USB - RX", "Bad")
            else:
                for Data_From_MCU in listData_From_MCU:
                    if Data_From_MCU == END_COMMAND or Data_From_MCU == '?>' + END_COMMAND:
                        # ======================= FOR DEBUGGING =======================#
                        #print("Número de caracteres en puerto serie Man: " + str(len(Data_From_MCU)))
                        #print("Lectura de puerto serie Manual: " + Data_From_MCU)
                        # ======================= FOR DEBUGGING =======================#
                        if Data_From_MCU == END_COMMAND:
                            self.signalChangeStateFrontEnd.emit("USB - RX", "Good")     #Recepción de comando OK
                        elif Data_From_MCU == '?>' + END_COMMAND:
                            self.signalChangeStateFrontEnd.emit("USB - RX", "Problem")  #Recepción de comando NOT OK
                        else:
                            self.signalChangeStateFrontEnd.emit("USB - RX", "Bad")      #Error (?)

                    elif Data_From_MCU[0] == 'C':

                        Data_Split = Data_From_MCU.split(END_COMMAND)
                        # Una vez realizado el split tenemos la información de la siguiente manera:
                        #   Data_Split = ['Cx', '']   ---  x : Valor entero posible -1, 0, 1.
                        #   Index list   | 0  | 1 |

                        Data_Command = Data_Split[0]

                        if Data_Command == 'C0':
                            self.signalCommBackFront.emit("[Recepcion_Datos()]: Secuencia de Calibración Iniciada")
                            self.signalCalibration.emit('C0')
                        elif Data_Command == 'C1':
                            self.signalCommBackFront.emit("[Recepcion_Datos()]: Secuencia de Calibración Finalizada")
                            self.signalCalibration.emit('C1')
                        elif Data_Command == 'C-1':
                            self.signalCommBackFront.emit("[Recepcion_Datos()]: Error de Calibración")
                            self.signalCalibration.emit('C-1')
                        else:
                            self.signalCommBackFront.emit("[Recepcion_Datos()]: Secuencia de Calibración no Identificada")
                            # TO DO (Definir que hacer aca)

                    elif Data_From_MCU[0] == 'B':
                        # ======================= FOR DEBUGGING =======================#
                        #print("Número de caracteres en puerto serie Ángulos: " + str(len(Data_From_MCU)))
                        #print("Lectura de puerto serie Ángulos: " + Data_From_MCU)
                        # ======================= FOR DEBUGGING =======================#

                        Data_Split = Data_From_MCU.split(END_COMMAND)
                        # Una vez realizado el split tenemos la información de la siguiente manera:
                            #   Data_Split = ['B,A,135.01,E,150.05', '']
                            #   Index list   |        0          | 1 |
                            #                |  Data Command     |End|

                        Data_Command = Data_Split[0].split(',')
                        # Data_Command = ['A', '135.01', 'E', '150.05', '']
                        # Index list     | 0 |    1    |  2 |    3    | 4 |

                        if Data_Command[1] == "A" and Data_Command[3] == "E":
                            Raw_acimut = Data_Command[2]
                            Raw_elevacion = Data_Command[4]
                            self.signalActualGraf.emit(float(Raw_acimut), float(Raw_elevacion))
                            #self.signalChangeStateFrontEnd.emit("USB - RX", "Good")     #Recepción de comando OK
                        else:
                            #self.signalChangeStateFrontEnd.emit("USB - RX", "Problem")  #Recepción de comando NOT OK
                            pass
                    else:
                        self.signalCommBackFront.emit("[Recepcion_Datos()]: Mensaje o Comando No Identificado")
                    self.timerAnimTXRX.start()
    #############################################################################################################
    #                      Fin funciones vinculadas con envio y recepción por puerto serie                      #
    #############################################################################################################

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Instancia de objetos backend
    objBackend = classBackendTrackingPage()

    engine.rootContext().setContextProperty("backendTrackingPage",objBackend)

    #Carga del archivo QML
    engine.load(os.fspath(Path(__file__).resolve().parent / "qml\main.qml"))

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec_())