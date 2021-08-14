import QtQml 2.15

import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.calendar 1.0
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.3
import QtQuick.Controls.Styles 1.4
import "../controls"
import QtQuick.Extras 1.4

Page{

    id: trackingpage
    implicitHeight: 1218
    implicitWidth: 608

    QtObject{
        id:internal

        function enableBusyIndicators(){
            busyFin.visible=true
            busyInicio.visible=true
            busyObj.visible=true
        }

        function disableBusyIndicators(){
            busyFin.visible=false
            busyInicio.visible=false
            busyObj.visible=false
        }

        function disableManualButtons(){
            btnAbajo.enabled = false
            btnArriba.enabled = false
            btnIzquierda.enabled = false
            btnDerecha.enabled = false
        }

        function enableManualButtons(){
            btnAbajo.enabled = true
            btnArriba.enabled = true
            btnIzquierda.enabled = true
            btnDerecha.enabled = true
        }

        function showNothingdataTxt(){
            labelEstActObjetivo.dataTxt = " - - - "
            labelEstActInicio.dataTxt = " - - - "
            labelEstActFin.dataTxt = " - - - "
        }

        function getTime(){
            return Qt.formatDateTime(new Date(),"dd/MM/yy  hh:mm:ss")
        }

        function changeCalibrationText(btn){
            if(btn.text === "Calibrar Home"){
              btnIniciar.enabled = false
              btnFinalizar.enabled = false
              ventanaLog.append(internal.getTime()+" --- Calibrando Home")
              return "Term. Calibracion"
            }else{
              ventanaLog.append(internal.getTime()+" --- Calibración terminada")
              disableBusyIndicators()
              showNothingdataTxt()
              btnIniciar.enabled = true
              //btnFinalizar.enabled = true
              return "Calibrar Home"
            }
        }

        function sendCommandToBackend(btnClicked){
            switch(btnClicked){
                case btnArriba:
                   backendPython.moveUp()
                break

                case btnAbajo:
                   backendPython.moveDown()
                break

                case btnIzquierda:
                   backendPython.moveToLeft()
                break

                case btnDerecha:
                   backendPython.moveToRight()
                break

                case btnStop:
                   backendPython.stopEverthing()
                break

                case btnStopAcimut:
                    backendPython.stopAcimut()
                break

                case btnStopElevacion:
                    backendPython.stopElevacion()
                break
            }
        }

}

    Rectangle {
        id: backGroundPage
        color: "#2c313b"
        anchors.fill: parent
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0

        Rectangle {
            id: backGroundTracking
            color: "#9f9f9f"
            radius: 15
            border.width: 3
            anchors.left: parent.left
            anchors.right: backgroundEstadoActual.left
            anchors.top: parent.top
            anchors.bottom: backGroundComandos.top
            anchors.bottomMargin: 22
            rotation: 0
            anchors.rightMargin: 44
            anchors.leftMargin: 20
            anchors.topMargin: 10
            clip: true

            Rectangle{
                id: containerTracking
                color: "#00000000"
                anchors.fill: parent
                anchors.rightMargin: 0
                anchors.bottomMargin: 0
                anchors.leftMargin: 0
                anchors.topMargin: 0
                clip: true

                Label{
                    id: labelIngresarDatos
                    height: 33
                    text: "Ingresar Datos"

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top

                    anchors.rightMargin: 290
                    anchors.leftMargin: 15
                    anchors.topMargin: 10

                    font.italic: true
                    font.bold: true
                    font.pointSize: 18

                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter

                }

                Column{

                    id: coloumnTracking
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 65
                    anchors.topMargin: 49
                    anchors.rightMargin: 45
                    anchors.leftMargin: 30
                    spacing: 15

                    Label_TextEdit{
                        id: labelObjetivo
                        width: coloumnTracking.width
                        height: (coloumnTracking.height-2*coloumnTracking.spacing)/3
                        text: "Objetivo"
                        shadowVertical: 5
                        shadowHorizontal: 5
                        dataTxt: " - - - "
                        altotxt: 12
                    }

                    Label_TextEdit{
                        id: labelInicio
                        width: coloumnTracking.width
                        height: (coloumnTracking.height-2*coloumnTracking.spacing)/3
                        text: "Inicio"
                        shadowVertical: 5
                        shadowHorizontal: 5
                        dataTxt: " - - - "
                        altotxt: 12
                    }

                    Label_TextEdit{
                        id: labelFin
                        width: coloumnTracking.width
                        height:(coloumnTracking.height-2*coloumnTracking.spacing)/3
                        text: "Fin"
                        shadowVertical: 5
                        shadowHorizontal: 5
                        dataTxt: " - - - "
                        altotxt: 12
                    }
                }
                Row{
                    id: rowBtnTracking
                        //3*btnIniciar.width+2*rowBtnTracking.spacing

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: coloumnTracking.bottom
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 15
                    anchors.bottomMargin: 15
                    anchors.leftMargin: 30
                    anchors.rightMargin: 45
                    spacing: 10

                    ButtonTracking{
                        id:btnIniciar
                        width: (rowBtnTracking.width-3*rowBtnTracking.spacing)/4
                        height: rowBtnTracking.height
                        text: "Iniciar Tracking"
                        font.italic: true
                        font.bold: true
                        shadowVertical: 5
                        shadowHorizontal: 5
                        font.pointSize: 8
                        enabled: false
                        onClicked: {
                            internal.disableBusyIndicators()

                            labelEstActObjetivo.dataTxt = labelObjetivo.dataTxt
                            labelEstActInicio.dataTxt = labelInicio.dataTxt
                            labelEstActFin.dataTxt = labelFin.dataTxt

                            btnIniciar.enabled = false
                            btnCalibrar.enabled = false
                            btnFinalizar.enabled = true
                            btnDetenerContinuar.enabled = true
                            checkBoxManual.checked = true
                            checkBoxManual.checkable = false
                            ventanaLog.append( internal.getTime() +" --- Tracking Iniciado")
                        }
                    }
                    ButtonTracking{
                        id:btnDetenerContinuar
                        width: (rowBtnTracking.width-3*rowBtnTracking.spacing)/4
                        height: rowBtnTracking.height
                        text: "Detener Tracking"
                        hoverEnabled: true
                        font.italic: true
                        font.bold: true
                        shadowVertical: 5
                        shadowHorizontal: 5
                        font.pointSize: 8
                        enabled: false
                        onClicked: {
                            if(btnDetenerContinuar.text === "Detener Tracking"){
                                ventanaLog.append( internal.getTime() +" --- Tracking Detenido")
                                checkBoxManual.checkable = true
                                checkBoxManual.checked = false

                                btnDetenerContinuar.text = "Cont. Tracking"
                            }else{
                                ventanaLog.append( internal.getTime() +" --- Tracking Continuado")
                                checkBoxManual.checked = true
                                checkBoxManual.checkable = false
                                btnDetenerContinuar.text = "Detener Tracking"
                                }
                        }
                    }
                    ButtonTracking{
                        id: btnFinalizar
                        width: (rowBtnTracking.width-3*rowBtnTracking.spacing)/4
                        height: rowBtnTracking.height
                        text: "Finalizar Tracking"
                        hoverEnabled: true
                        font.italic: true
                        font.bold: true
                        shadowVertical: 5
                        shadowHorizontal: 5
                        font.pointSize: 8
                        enabled: false
                        checkable: false
                        checked: false
                        onClicked: {
                            internal.disableBusyIndicators()

                            labelEstActObjetivo.dataTxt = " - - - "
                            labelEstActInicio.dataTxt = " - - - "
                            labelEstActFin.dataTxt = " - - - "

                            ventanaLog.append( internal.getTime() +" --- Tracking Finalizado")

                            btnIniciar.enabled = true
                            btnCalibrar.enabled = true
                            btnFinalizar.enabled = false
                            btnDetenerContinuar.enabled = false
                            checkBoxManual.checked = false
                            checkBoxManual.checkable = true
                        }
                    }

                    ButtonTracking{
                        id: btnCalibrar
                        width: (rowBtnTracking.width-3*rowBtnTracking.spacing)/4
                        height: rowBtnTracking.height
                        text: "Calibrar Home"
                        font.italic: true
                        font.bold: true
                        shadowVertical: 5
                        shadowHorizontal: 5
                        font.pointSize: 8
                        onClicked: {
                            internal.enableBusyIndicators()
                            labelEstActObjetivo.dataTxt = "Calibrando...       "
                            labelEstActInicio.dataTxt = "Calibrando...       "
                            labelEstActFin.dataTxt = "Calibrando...       "
                            btnCalibrar.text = internal.changeCalibrationText(btnCalibrar)
                        }
                    }
                }
            }
        }

        Rectangle {
            id: backGroundComandos
            width: 300
            color: "#9f9f9f"
            radius: 15
            border.width: 3
            anchors.left: parent.left
            anchors.right: backGroundAngulos.left
            anchors.top: parent.top
            anchors.bottom: backgroundLog.top
            anchors.topMargin: 258
            anchors.bottomMargin: 20
            anchors.rightMargin: 44
            clip: true
            anchors.leftMargin: 20

            Grid {
                id: gridComandos
                width: 330
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: 59
                anchors.bottomMargin: 16
                anchors.leftMargin: 31
                anchors.rightMargin: 157
                clip: false
                flow: Grid.LeftToRight
                spacing: 10
                rows: 2
                columns: 3

                Rectangle{
                    width: (gridComandos.width-2*gridComandos.spacing)/3
                    height: (gridComandos.height-2*gridComandos.spacing)/3
                    color: "#00000000"  
                }

                CustomButton{
                    id:btnArriba
                    width: (gridComandos.width-2*gridComandos.spacing)/3
                    height: (gridComandos.height-gridComandos.spacing)/2
                    autoExclusive: true
                    colorBtnDisable: "#636671"
                    btnDefault: "#1c1d20"
                    iconSource: "../../images/svg_images/Arriba.png"
                    onClicked: {
                        internal.disableBusyIndicators()
                        internal.showNothingdataTxt()
                        ventanaLog.append( internal.getTime() +" --- Movimiento hacia arriba")

                        internal.sendCommandToBackend(btnArriba)
                    }
                }

                Rectangle{
                    width: (gridComandos.width-2*gridComandos.spacing)/3
                    height: (gridComandos.height-gridComandos.spacing)/2
                    color: "#00000000"
                }
                CustomButton{
                    id:btnIzquierda
                    width: (gridComandos.width-2*gridComandos.spacing)/3
                    height: (gridComandos.height-gridComandos.spacing)/2
                    iconSource: "../../images/svg_images/Izquierda.png"
                    onClicked: {
                        internal.disableBusyIndicators()
                        internal.showNothingdataTxt()
                        ventanaLog.append( internal.getTime() + " --- Movimiento hacia la izquierda")
                        internal.sendCommandToBackend(btnIzquierda)
                    }
                }
                CustomButton{
                    id:btnAbajo
                    width: (gridComandos.width-2*gridComandos.spacing)/3
                    height: (gridComandos.height-gridComandos.spacing)/2
                    iconSource: "../../images/svg_images/Abajo.png"
                    onClicked:{
                        internal.disableBusyIndicators()
                        internal.showNothingdataTxt()
                        ventanaLog.append( internal.getTime() + " --- Movimiento hacia abajo")
                        internal.sendCommandToBackend(btnAbajo)
                    }
                }
                CustomButton{
                    id:btnDerecha
                    width: (gridComandos.width-2*gridComandos.spacing)/3
                    height: (gridComandos.height-gridComandos.spacing)/2
                    iconSource: "../../images/svg_images/Derecha.png"
                    onClicked: {
                        internal.disableBusyIndicators()
                        internal.showNothingdataTxt()
                        ventanaLog.append( internal.getTime() + " --- Movimiento hacia la derecha")
                        internal.sendCommandToBackend(btnDerecha)
                    }
                }
            }

            Column{
                id: columnStop
                x: 416
                width: 110
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.rightMargin: 15
                anchors.bottomMargin: 15
                anchors.topMargin: 15
                spacing: 20

                ButtonTracking{
                    id: btnStopAcimut
                    width: columnStop.width
                    height:(columnStop.height-2*columnStop.spacing)/3
                    text: "Parar Acimut"
                    font.pointSize: 10
                    font.italic: true
                    shadowHorizontal: 5
                    shadowVertical: 5
                    onClicked: {
                        internal.disableBusyIndicators()
                        internal.showNothingdataTxt()
                        ventanaLog.append( internal.getTime() + " --- Detener Acimut")
                        internal.sendCommandToBackend(btnStopAcimut)
                    }
                }

                ButtonTracking{
                    id:btnStopElevacion
                    width: columnStop.width
                    height:(columnStop.height-2*columnStop.spacing)/3
                    text: "Parar Eleve."
                    font.pointSize: 10
                    font.bold: true
                    font.italic: true
                    shadowHorizontal: 5
                    shadowVertical: 5
                    onClicked: {
                        internal.disableBusyIndicators()
                        internal.showNothingdataTxt()
                        ventanaLog.append( internal.getTime() + " --- Detener Elevación")
                        internal.sendCommandToBackend(btnStopElevacion)
                    }
                }

                ButtonTracking{
                    id:btnStop
                    width: columnStop.width
                    height:(columnStop.height-2*columnStop.spacing)/3
                    text: "Parar Todo"
                    font.pointSize: 10
                    font.bold: true
                    font.italic: true
                    shadowHorizontal: 5
                    shadowVertical: 5
                    onClicked: {
                        internal.disableBusyIndicators()
                        internal.showNothingdataTxt()
                        ventanaLog.append( internal.getTime() + " --- Detener Ambos Motores")
                        internal.sendCommandToBackend(btnStop)
                    }
                }
            }

            RadioButton {
                id: checkBoxManual
                width: 182
                height: 37

                font.italic: true
                font.bold: true
                text: qsTr("Bloquear Mov. Manual")

                anchors.left: parent.left
                anchors.top: parent.top
                autoRepeat: false
                autoExclusive: false
                clip: true
                anchors.leftMargin: 6
                anchors.topMargin: 8
                onCheckedChanged: {
                    if(checkBoxManual.checked == true){
                        internal.disableManualButtons()
                    }
                    else{
                        internal.enableManualButtons()
                    }
                }
            }
        }
        Rectangle {
            id: backgroundEstadoActual
            color: "#9f9f9f"
            radius: 15
            border.width: 3
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: backGroundAngulos.top
            anchors.bottomMargin: 28
            anchors.leftMargin: 605
            anchors.topMargin: 10
            anchors.rightMargin: 25

            Rectangle{
                id: containerEstadoAcual
                color: "#00000000"
                anchors.fill: parent
                clip: true

                Label {
                    id: labelEstadoActual
                    height: 33
                    text: qsTr("Estado Actual")

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top

                    anchors.rightMargin: 290
                    anchors.leftMargin: 15
                    anchors.topMargin: 10

                    font.italic: true
                    font.bold: true
                    font.pointSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
                Column{
                    id: columnDataEstadoActual
                    width: 440
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: labelEstadoActual.bottom
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20
                    anchors.rightMargin: 20
                    anchors.leftMargin: 20
                    anchors.topMargin: 10
                    spacing: 20

                    Label_TextEdit{
                        id: labelEstActObjetivo
                        width: parent.width
                        height: (columnDataEstadoActual.height-2*columnDataEstadoActual.spacing)/3
                        text: "Objetivo"
                        altotxt: 12
                        dataTxt: " - - - "
                        CustomBusyIndicator{
                            id:busyObj
                            width: 50
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.topMargin: 0
                            anchors.bottomMargin: 0
                            anchors.rightMargin: 0
                        }
                    }

                    Label_TextEdit{
                        id: labelEstActInicio
                        width: parent.width
                        height: (columnDataEstadoActual.height-2*columnDataEstadoActual.spacing)/3
                        text: "Inicio"
                        altotxt: 12
                        dataTxt: " - - - "
                        CustomBusyIndicator{
                            id:busyInicio
                            width: 50
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.topMargin: 0
                            anchors.bottomMargin: 0
                            anchors.rightMargin: 0
                        }
                    }

                    Label_TextEdit{
                        id: labelEstActFin
                        width: parent.width
                        height: (columnDataEstadoActual.height-2*columnDataEstadoActual.spacing)/3
                        text: "Fin..."
                        altotxt: 12
                        dataTxt: " - - - "
                        CustomBusyIndicator{
                            id:busyFin
                            width: 50
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.topMargin: 0
                            anchors.bottomMargin: 0
                            anchors.rightMargin: 0
                        }
                    }
                }

                Row{
                    id: rowAcimutElevacion
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: columnDataEstadoActual.bottom
                    anchors.leftMargin: 40
                    anchors.rightMargin: 40
                    anchors.topMargin: 30
                    layoutDirection: Qt.LeftToRight
                    clip: true
                    spacing: 20
                }

            }

        }

        Rectangle {
            id: backgroundLog
            radius:15
            border.width: 3

            anchors.left: parent.left
            anchors.right: backGroundAngulos.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 478
            anchors.rightMargin: 44
            anchors.leftMargin: 20
            anchors.bottomMargin: 10

            color: "#9f9f9f"
            clip: true

            Rectangle{
                id:containerLog
                color: "#00000000"
                anchors.fill:parent
                anchors.rightMargin: parent.border.width
                anchors.leftMargin: parent.border.width
                anchors.bottomMargin: parent.border.width
                anchors.topMargin: 40
                radius: parent.radius

                ScrollView {
                    background: Rectangle{
                        color: backgroundLog.color
                        anchors.fill:parent
                        radius: backgroundLog.radius
                    }
                    id: scrollViewLog
                    anchors.fill: parent
                    anchors.topMargin: 4
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 3
                    anchors.leftMargin: 15
                    clip: true
                    wheelEnabled: true

                    TextEdit{
                        id: ventanaLog
                        anchors.fill: parent
                        cursorVisible: true
                        selectByKeyboard: true

                        selectionColor: "#8c8c8c"
                        selectByMouse: true
                        clip: true

                        font.italic: true
                        font.pointSize: 10

                        readOnly: true
                    }
                }
            }

            ButtonTracking {
                id: buttonSave
                width: 110
                height: 30
                text: qsTr("Save Log")
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 8
                anchors.rightMargin: 15
                onClicked: {
                    // Abre la ventana de Windows para seleccionar una dirección
                    fileSave.open()
                }

                ButtonTracking{
                    id: buttonClear
                    width: 110
                    height: 30
                    text: qsTr("Clear log")
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.rightMargin: 130
                    onClicked: {
                        // Abre la ventana de Windows para seleccionar una dirección
                        backendPython.cleanLog(ventanaLog.getFormattedText(0,ventanaLog.length))
                    }
                }

                FileDialog{
                    id:fileSave
                    title: "Guardar Archivo"
                    folder: shortcuts.home
                    nameFilters: ["Text File (*.txt)"]
                    selectExisting: false
                    selectMultiple: false
                    onAccepted:{
                        // Si todo correcto una vez determinara la ruta, enviamos los datos del backgroundLo
                        // junto con la dirección URL seleccionada por el usuario (Si decide hacerlo)
                        backendPython.saveDataLog(ventanaLog.getFormattedText(0,ventanaLog.length))
                        backendPython.saveFile(fileSave.fileUrl)
                    }
                }
            }

            Label{
                id: labelLog
                width: 99
                visible: true
                color: "#26282a"
                text: qsTr("Log...")
                anchors.left: parent.left
                anchors.top: parent.top

                font.underline: false

                anchors.leftMargin: 15
                anchors.topMargin: 5
                font.italic: true
                font.bold: true
                font.pointSize: 20

            }
        }

        Rectangle {
            id: backGroundAngulos
            color: "#9e9e9e"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 264
            anchors.leftMargin: 605
            anchors.bottomMargin: 8
            anchors.rightMargin: 25
            radius: 15
            border.width: 3

            Rectangle{
                id:containerAngulos
                color: "#00000000"
                border.width: 0
                anchors.fill: parent

                CircularGauge {
                    id: circularGauge
                    x: 38
                    width: 250
                    height: 250

                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 20
                    anchors.bottomMargin: 43
                    anchors.topMargin: 43


                    style: CircularGaugeStyle{
                        minimumValueAngle: -180
                        maximumValueAngle : 180
                    }
                }

                CircularGauge {
                    id: circularGauge2
                    width: 250
                    height: 250

                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 41
                    anchors.bottomMargin: 43
                    anchors.topMargin: 43


                    style: CircularGaugeStyle{
                        minimumValueAngle: -180
                        maximumValueAngle : 180
                    }

                }

            }
        }
    }

    Connections{
        target: backendPython

        function onActualizarDataToSave(){
            backendPython.saveDataLog(ventanaLog.getFormattedText(0,ventanaLog.length))
            //Guardado de la información de LOG cada "X" de tiempo. Este "X" se define en el backend de Python
        }


    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.5;height:608;width:1218}
}
##^##*/
