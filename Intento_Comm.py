import serial 
# timeout = None,   #Tiempo de espera para una posible respuesta ('x' segundos, los flotantes estan permitidos)

"""
Solo se permite configurar los siguientes campos del puerto una vez creado el mismo:
    write_timeout, inter_byte_timeout, dsrdtr, baudrate, timeout, parity, bytesize, rtscts, stopbits, xonxoff
        
        Ejemplo:
            New_Config= {
            #write_timeout : , #Tiempo limite para envio de un mensaje ('x' segundos, los flotantes estan permitidos)
            'dsrdtr'    : False,
            'baudrate'  : 9600,
            'timeout'   : None,   #Tiempo de espera para una posible respuesta ('x' segundos, los flotantes estan permitidos)
            'parity'    : PARITY_NONE,
            'bytesize'  : EIGHTBITS,
            'rtscts'    : False,
            'stopits'   : STOPBITS_ONE,
            'xonxoff'   : False,
            }
"""

class Puerto_Serie(serial.Serial):
    
    def __init__(self,port,baudrate,bytesize,parity,stopbits,timeout,xonxoff,rtscts,write_timeout,dsrdtr,inter_byte_timeout,exclusive):
        '''
        - Contructor del padre.
            serial.Serial.__init__(self,)
        '''
        self.port = port
        self.baudrate = baudrate
        self.bytesize = bytesize
        self.parity = parity
        self.stopbits = stopbits
        self.timeout = timeout
        self.xonxoff = xonxoff
        self.rtscts = rtscts
        self.write_timeout = write_timeout
        self.inter_byte_timeout = inter_byte_timeout
        self.exclusive = exclusive
        
        self.SerialException():
            pass


    def Change_Port_Config(self,Config_To_Apply):
    if type(Config_To_Apply) is dict:
        if(Serial_Port.is_open()):
            Serial_Port.apply_settings(Config_To_Apply)
        else:
            print("ERROR: Puerto a configurar no abierto o no válido.")
    else:
        print("ERROR: Configuración no aplicada.")
        print("Por favor ingrese la misma en formato de diccionario con los valores permitidos")

    


Puerto_a_utilizar= 'COMX'
ser = serial.Serial(Puerto_a_utiliza,9600)  # open serial port

Mensaje = b'Hello there'    #Mensaje a enviar por Puerto_a_utilizar

ser.write(Mensaje = b'Hello there')     # write a string
ser.close()             # close port