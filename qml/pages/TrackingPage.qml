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

    /*Ingreso de comandos manuales por teclado*/
    Keys.onPressed:{
        if(event.key === Qt.Key_Up && !checkBoxManual.checked && !btnAbajo.down){
            //console.log("[Tracking Page] Tecla Arriba Presionada")
            //btnArriba.clicked()
        }

        if(event.key === Qt.Key_Down && !checkBoxManual.checked && !btnArriba.down){
            //console.log("[Tracking Page] Tecla Abajo Presionada")
            //btnAbajo.clicked()
        }

        if(event.key === Qt.Key_Left && !checkBoxManual.checked && !btnIzquierda.down){
            //console.log("[Tracking Page] Tecla Izquierda Presionada")
            //btnIzquierda.clicked()
        }

        if(event.key === Qt.Key_Right && !checkBoxManual.checked && !btnDerecha.down){
            //console.log("[Tracking Page] Tecla Derecha Presionada")
            btnDerecha.clicked()
        }

    }

    id: trackingpage
    focus: true
    implicitHeight: 1218
    implicitWidth: 608

    QtObject{
        id:internal

        function enableBusyIndicators(){
            //busyFin.visible=true
            //busyInicio.visible=true
            //busyObj.visible=true
        }

        function disableBusyIndicators(){
            //busyFin.visible=false
            //busyInicio.visible=false
            //busyObj.visible=false
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
            labelEstActElevacion.dataTxt = " - - - "
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

            }
        }

    }

    Rectangle {
        id: backGroundPage
        color: "#303641"
        anchors.fill: parent
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0

        Column {
            id: column
            width: parent.width*(1/2+1/3)/2
            height: 592
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            anchors.leftMargin: 20
            spacing: 10

            Rectangle {
                id: backGroundTracking
                color: "#9f9f9f"
                radius: 15
                border.width: 3
                rotation: 0
                clip: true
                width: parent.width
                height: parent.height/3

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
                        text: "Datos de Tracking"

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
                        y: 50
                        height: 80
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: rowBtnTracking.top
                        anchors.bottomMargin: 13
                        anchors.topMargin: 50
                        anchors.rightMargin: 20
                        anchors.leftMargin: 20
                        spacing: coloumnTracking.height/10

                        Label_TextEdit{
                            id: labelObjetivo
                            width: coloumnTracking.width
                            height: (coloumnTracking.height-2*coloumnTracking.spacing)/3
                            text: "Objetivo"
                            shadowVertical: 5
                            shadowHorizontal: 5
                            dataTxt: " - - - "
                            altotxt: 12
                            radius_label: (coloumnTracking.height-2*coloumnTracking.spacing)/12
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
                            radius_label: (coloumnTracking.height-2*coloumnTracking.spacing)/12
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
                            radius_label: (coloumnTracking.height-2*coloumnTracking.spacing)/12
                        }
                    }
                    Row{
                        id: rowBtnTracking
                        height: 36.75

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        focus: false
                        anchors.bottomMargin: 15
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20

                        spacing: backGroundTracking.height/20
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
                                labelEstActElevacion.dataTxt = labelInicio.dataTxt

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
                                labelEstActElevacion.dataTxt = " - - - "

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
                                labelEstActElevacion.dataTxt = "Calibrando...       "
                                btnCalibrar.text = internal.changeCalibrationText(btnCalibrar)
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: backGroundComandos
                color: "#9f9f9f"
                radius: 15
                border.width: 3
                clip: true
                width: parent.width
                height: parent.height/3

                Grid {
                    id: gridComandos
                    width: 330
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 51
                    anchors.bottomMargin: 24
                    anchors.leftMargin: 75
                    anchors.rightMargin: 75
                    clip: false

                    spacing: ((gridComandos.height+gridComandos.width)/2)/16
                    rows: 2
                    columns: 3

                    Rectangle{
                        width: (gridComandos.width-2*gridComandos.spacing)/3
                        height: (gridComandos.height-2*gridComandos.spacing)/3
                        color: "#00000000"
                    }

                    CustomButton{
                        id:btnArriba
                        focus: true
                        width: (gridComandos.width-2*gridComandos.spacing)/3
                        height: (gridComandos.height-gridComandos.spacing)/2
                        autoExclusive: true
                        colorBtnDisable: "#636671"
                        btnDefault: "#1c1d20"
                        iconSource: "../../images/svg_images/Arriba.png"

                        onReleased: {
                            backendPython.stopElevacion()
                            internal.disableBusyIndicators()
                            internal.showNothingdataTxt()
                            ventanaLog.append( internal.getTime() +" --- Deteniendo elevación")
                        }

                        onPressAndHold: {
                            //Do nothing
                        }

                        onPressed:{
                           if(!btnArriba.pressAndHold()){
                                ventanaLog.append( internal.getTime() +" --- Movimiento hacia arriba")
                            }
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

                        onReleased: {
                            backendPython.stopAcimut()
                            internal.disableBusyIndicators()
                            internal.showNothingdataTxt()
                            ventanaLog.append( internal.getTime() + " --- Deteniendo acimut")
                        }

                        onPressed:{
                            if(!btnIzquierda.pressAndHold()){
                                ventanaLog.append( internal.getTime() + " --- Movimiento hacia la izquierda")
                            }
                            internal.sendCommandToBackend(btnIzquierda)
                        }
                    }
                    CustomButton{
                        id:btnAbajo
                        width: (gridComandos.width-2*gridComandos.spacing)/3
                        height: (gridComandos.height-gridComandos.spacing)/2
                        iconSource: "../../images/svg_images/Abajo.png"

                        onReleased: {
                            backendPython.stopElevacion()
                            internal.disableBusyIndicators()
                            internal.showNothingdataTxt()
                            ventanaLog.append( internal.getTime() + " --- Deteniendo elevación")
                        }

                        onPressed:{
                            if(!btnAbajo.pressAndHold()){
                                ventanaLog.append( internal.getTime() + " --- Movimiento hacia abajo")
                            }
                            internal.sendCommandToBackend(btnAbajo)
                        }
                    }
                    CustomButton{
                        id:btnDerecha
                        width: (gridComandos.width-2*gridComandos.spacing)/3
                        height: (gridComandos.height-gridComandos.spacing)/2
                        iconSource: "../../images/svg_images/Derecha.png"

                        onReleased: {
                            btnDerecha.down = false
                            backendPython.stopAcimut()
                            internal.disableBusyIndicators()
                            internal.showNothingdataTxt()
                            ventanaLog.append( internal.getTime() + " --- Deteniendo acimut")
                        }
                        onPressed:{
                            if(!btnDerecha.pressAndHold()){
                                ventanaLog.append( internal.getTime() + " --- Movimiento hacia la derecha")
                            }
                            internal.sendCommandToBackend(btnDerecha)
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

                ButtonTracking{
                    id:btnStop
                    x: 416
                    width: 118
                    height:34

                    text: "Parar Todo"
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.rightMargin: 20
                    font.pointSize: 10
                    font.bold: true
                    font.italic: true
                    shadowHorizontal: 5
                    shadowVertical: 5

                    onPressed: {
                        if(!btnStop.pressAndHold()){
                            ventanaLog.append( internal.getTime() + " --- Deteniendo movimientos")
                        }
                        console.log(internal.getTime() + " --- Deteniendo movimientos")
                        internal.sendCommandToBackend(btnStop)
                    }

                    onReleased: {
                        internal.disableBusyIndicators()
                        internal.showNothingdataTxt()
                        checkBoxManual.checkable = true
                        checkBoxManual.checked = false
                    }
                }
            }

            Rectangle {
                id: backgroundLog
                radius:15
                border.width: 3
                color: "#9f9f9f"
                clip: true
                width: parent.width
                height: parent.height/3 - 2*column.spacing

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
                    width: 118
                    height: 30
                    text: qsTr("Save Log")
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.rightMargin: 20
                    onClicked: {
                        // Abre la ventana de Windows para seleccionar una dirección
                        fileSave.open()
                    }

                    ButtonTracking{
                        id: buttonClear
                        width: 118
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
        }

        Column {
            id: column1

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: 10
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.bottomMargin: 10
            anchors.topMargin: 10
            anchors.right: parent.right
            anchors.left: column.right

            Rectangle {
                id: backgroundEstadoActual
                color: "#9f9f9f"
                radius: 15
                border.width: 3
                width: parent.width
                height: backGroundTracking.height
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
                        y: 50
                        width: 440
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: conteinerLucesEstAct.top
                        anchors.bottomMargin: 5
                        anchors.rightMargin: 20
                        anchors.leftMargin: 20
                        anchors.topMargin: 50
                        spacing: columnDataEstadoActual.height/5

                        Label_TextEdit{
                            id: labelEstActObjetivo
                            width: parent.width
                            height: (columnDataEstadoActual.height-columnDataEstadoActual.spacing)/2
                            text: "Azimut"
                            altotxt: 12
                            dataTxt: " - - - "
                        }

                        Label_TextEdit{
                            id: labelEstActElevacion
                            width: parent.width
                            height: (columnDataEstadoActual.height-columnDataEstadoActual.spacing)/2
                            text: "Elevación"
                            altotxt: 12
                            dataTxt: " - - - "
                        }
                    }

                    Rectangle {
                        id: conteinerLucesEstAct
                        y: 158
                        width: 523
                        height: 50
                        color: "#00000000"
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 10
                        anchors.leftMargin: 40
                        anchors.rightMargin: 40

                        Rectangle {
                            id: statusTracking
                            width: 50
                            height: 20
                            color: "#2f2f2f"
                            radius: 10
                            border.width: 2
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.topMargin: 3
                            anchors.leftMargin: 20
                        }

                        Rectangle {
                            id: statusCommUSB
                            y: 28
                            width: 50
                            height: 20
                            color: "#282828"
                            radius: 30
                            border.width: 2
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 3
                            anchors.leftMargin: 20
                        }

                        Text {
                            id: text1
                            x: 85
                            height: 20
                            text: qsTr("Tracking")
                            anchors.top: parent.top
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            anchors.topMargin: 3
                        }

                        Text {
                            id: text2
                            x: 84
                            y: 30
                            height: 20
                            text: "Comunicacion USB"
                            anchors.bottom: parent.bottom
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            anchors.bottomMargin: 3
                            minimumPixelSize: 12
                        }
                    }

                }

            }

            Rectangle {
                id: backGroundAngulos
                color: "#9e9e9e"
                radius: 15
                border.width: 3
                width: parent.width
                height: parent.height - backgroundEstadoActual.height - column1.spacing
                Rectangle{
                    id:containerAngulos
                    x: 0
                    y: 0
                    color: "#00000000"
                    border.width: 0
                    anchors.fill: parent
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 0
                    anchors.leftMargin: 0
                    anchors.topMargin: 0

                    CircularGauge {
                        id: gaugeElevacion
                        x: 316
                        width: containerAngulos.width/2 - 30
                        height: 250
                        anchors.right: parent.right

                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: 20
                        anchors.bottomMargin: 40
                        anchors.topMargin: 40

                        //Máximo valor y minímo de la escala a representar
                        maximumValue: 180
                        minimumValue: 0

                        //Minímo offset de valor para mover la aguja del gauge
                        stepSize: 0.1

                        value: 90
                        style: CircularGaugeStyle{
                            //tickmarkLabel: null     // Label que viene por defecto OFF
                            minimumValueAngle: -90
                            maximumValueAngle : 90
                            minorTickmarkCount: 4
                            labelStepSize: 20

                            tickmarkLabel: Text{
                                text: styleData.value
                                color: "#ffffff"
                                font.pixelSize: 13
                            }
                        }
                    }

                    CircularGauge {
                        id: gaugeAcimut
                        width: containerAngulos.width/2 - 30
                        height: containerAngulos.width - 20
                        anchors.left: parent.left

                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 20

                        anchors.bottomMargin: 40
                        anchors.topMargin: 40

                        //Máximo valor y minímo de la escala a representar
                        maximumValue: 360
                        minimumValue: 0

                        //Minímo offset de valor para mover la aguja del gauge
                        stepSize: 0.1

                        style: CircularGaugeStyle{
                            //tickmarkLabel: null     // Label que viene por defecto OFF
                            minimumValueAngle: -180
                            maximumValueAngle : 180
                            minorTickmarkCount: 4
                            labelStepSize: 20

                            tickmarkLabel: Text{
                                text: styleData.value
                                color: "#ffffff"
                                font.pixelSize:  14
                            }
                        }
                    }

                    Rectangle {
                        id: conteinerLucesAngulos
                        x: 361
                        y: 257
                        width: 197
                        height: 57
                        color: "#00000000"
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 20
                        anchors.rightMargin: 30

                        Rectangle {
                            id: rectangle2
                            x: 181
                            width: 50
                            height: 20
                            color: "#00ff00"
                            radius: 24
                            border.width: 2
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.topMargin: 6
                            anchors.rightMargin: 10
                        }

                        Rectangle {
                            id: rectangle3
                            x: 181
                            y: 34
                            width: 50
                            height: 20
                            color: "#00ff00"
                            radius: 30
                            border.width: 2
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 6
                            anchors.rightMargin: 10
                        }

                        Text {
                            id: text3
                            x: 13
                            width: 111
                            height: 30
                            text: "Indicador Azimut"
                            anchors.right: parent.right
                            anchors.top: parent.top
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            anchors.topMargin: 0
                            anchors.rightMargin: 80
                            minimumPixelSize: 12
                        }

                        Text {
                            id: text4
                            x: 18
                            y: 43
                            height: 30
                            text: "Indicador Elevación"
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            anchors.rightMargin: 80
                            minimumPixelSize: 12
                            anchors.bottomMargin: 0
                        }
                    }

                }
            }

        }
    }

    Connections{
        target: backendPython
        //recordar la preposicion on delante de la funcion

        function onActualizarDataToSave(){
            backendPython.saveDataLog(ventanaLog.getFormattedText(0,ventanaLog.length))
            //Guardado de la información de LOG cada "X" de tiempo. Este "X" se define en el backend de Python
        }

        function onCleanLogAvalible(){
            ventanaLog.clear()
        }

        function onCommSerieFailed(msgError){
            // Caso en el cual estamos trabajando y se detecta un problema con el USB
            if(statusCommUSB.color == "#00ff00"){
                ventanaLog.append(internal.getTime()+ " --- " + msgError)
            }
        }

        function onActual_graf_grados_signal(acimut,elevacion){
            // Actualización del gauge de acimut
            gaugeAcimut.value = acimut
            // Actualización del gauge de elevación
            gaugeElevacion.value = elevacion
        }

        function onSignal_To_FrontEnd(Signal_ID,Signal_Msg){
            if(Signal_ID === "USB"){
                switch(Signal_Msg){
                    case "Good":
                        statusCommUSB.color = "#00ff00"    // Verde
                        break;
                    case "Bad":
                        statusCommUSB.color = "#ff0000"    // Rojo
                        break;
                    case "Problem":
                        statusCommUSB.color = "#fff700"    // Amarillo
                        break;
                    default:
                        statusCommUSB.color = "#2f2f2f"     // Gris
                        break;
                }
            }
            else if(Signal_ID === "Tracking"){
                switch(Signal_Msg){
                    case "Good":
                        statusTracking.color = "#00ff00"    // Verde
                        break;
                    case "Stoped":
                        statusTracking.color = "#fff700"    // Amarillo
                        break;
                    case "Off":
                        statusTracking.color = "#2f2f2f"     // Gris
                        break;
                    case "Problem":
                        statusTracking.color = "#ff0000"    // Rojo
                        break;
                    default:
                        statusTracking.color = "#2f2f2f"     // Gris
                        break;
                }
            }
        }

    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.9;height:608;width:1218}
}
##^##*/
