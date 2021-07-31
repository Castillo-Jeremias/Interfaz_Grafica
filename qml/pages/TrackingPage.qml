import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.calendar 1.0
import QtGraphicalEffects 1.15

import "../controls"

Page{
    property color colorBgComando : "#c00"
    property alias scrollViewContentWidth: scrollView.contentWidth
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
            width: 518
            height: 226
            color: "#00c5dd"
            radius: 15
            border.width: 3
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 20
            anchors.topMargin: 10
            clip: true

            Rectangle{
                id: containerTracking
                color: "#00000000"
                anchors.fill: parent
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
                    anchors.bottomMargin: 61
                    anchors.topMargin: 49
                    anchors.rightMargin: 45
                    anchors.leftMargin: 30
                    spacing: 15

                    Label_TextEdit{
                        id: labelObjetivo
                        width: coloumnTracking.width
                        height: (coloumnTracking.height-2*coloumnTracking.spacing)/3
                        text: "Objetivo"
                        dataTxt: "Sol"
                        altotxt: 12
                    }

                    Label_TextEdit{
                        id: labelInicio
                        width: coloumnTracking.width
                        height: (coloumnTracking.height-2*coloumnTracking.spacing)/3
                        text: "Inicio"
                        dataTxt: "31/07 08:00"
                        altotxt: 12
                    }

                    Label_TextEdit{
                        id: labelFin
                        width: coloumnTracking.width
                        height:(coloumnTracking.height-2*coloumnTracking.spacing)/3
                        text: "Fin"
                        dataTxt: "31/07 15:00"
                        altotxt: 12
                    }
                }
                Row{
                    id: rowBtnTracking
                    y: 179
                        //3*btnIniciar.width+2*rowBtnTracking.spacing

                    height: 32
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 15
                    anchors.leftMargin: 52
                    anchors.rightMargin: 67
                    spacing: 20

                    CustomButton{
                        id:btnIniciar
                        width: (rowBtnTracking.width-2*rowBtnTracking.spacing)/3
                        height: rowBtnTracking.height
                        onClicked: {
                            internal.disableBusyIndicators()
                            labelEstActObjetivo.dataTxt = labelObjetivo.dataTxt
                            labelEstActInicio.dataTxt = labelInicio.dataTxt
                            labelEstActFin.dataTxt = labelFin.dataTxt
                        }
                    }

                    CustomButton{
                        id: btnFinalizar
                        width: (rowBtnTracking.width-2*rowBtnTracking.spacing)/3
                        height: rowBtnTracking.height
                        onClicked: {
                            internal.disableBusyIndicators()
                            labelEstActObjetivo.dataTxt = ". . ."
                            labelEstActInicio.dataTxt = ". . ."
                            labelEstActFin.dataTxt = ". . ."
                        }
                    }
                    CustomButton{
                        id: btnCalibrar
                        width: (rowBtnTracking.width-2*rowBtnTracking.spacing)/3
                        height: rowBtnTracking.height
                        onClicked: {
                            internal.enableBusyIndicators()
                            labelEstActObjetivo.dataTxt = "Calibrando...       "
                            labelEstActInicio.dataTxt = "Calibrando...       "
                            labelEstActFin.dataTxt = "Calibrando...       "
                        }
                    }
                }
            }
        }
        Rectangle {
            id: backGroundComandos
            width: 518
            color: colorBgComando
            radius: 15
            border.width: 3
            anchors.left: parent.left
            anchors.top: backGroundTracking.bottom
            anchors.bottom: backgroundLog.top
            anchors.topMargin: 28
            clip: true
            anchors.leftMargin: 20
            anchors.bottomMargin: 30

            Grid {
                id: gridComandos
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: 61
                anchors.bottomMargin: 21
                anchors.leftMargin: 31
                anchors.rightMargin: 157
                clip: true
                flow: Grid.LeftToRight
                spacing: 15
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
                    height:(gridComandos.height-gridComandos.spacing)/2
                    iconSource: "../../images/svg_images/Arriba.png"
                    onClicked: {
                        internal.disableBusyIndicators()
                        labelEstActObjetivo.dataTxt = "Movimiento hacia arriba"
                        labelEstActInicio.dataTxt = ". . ."
                        labelEstActFin.dataTxt = ". . ."
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
                        labelEstActObjetivo.dataTxt = "Movimiento hacia la izquierda"
                        labelEstActInicio.dataTxt = ". . ."
                        labelEstActFin.dataTxt = ". . ."
                    }
                }
                CustomButton{
                    id:btnAbajo
                    width: (gridComandos.width-2*gridComandos.spacing)/3
                    height: (gridComandos.height-gridComandos.spacing)/2
                    iconSource: "../../images/svg_images/Abajo.png"
                    onClicked: {
                        internal.disableBusyIndicators()
                        labelEstActObjetivo.dataTxt = "Movimiento hacia abajo"
                        labelEstActInicio.dataTxt = ". . ."
                        labelEstActFin.dataTxt = ". . ."
                    }
                }
                CustomButton{
                    id:btnDerecha
                    width: (gridComandos.width-2*gridComandos.spacing)/3
                    height: (gridComandos.height-gridComandos.spacing)/2
                    iconSource: "../../images/svg_images/Derecha.png"
                    onClicked: {
                        internal.disableBusyIndicators()
                        labelEstActObjetivo.dataTxt = "Movimiento hacia la derecha"
                        labelEstActInicio.dataTxt = ". . ."
                        labelEstActFin.dataTxt = ". . ."
                    }
                }
            }

            Column{
                id: columnStop
                x: 382
                width: 90
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.rightMargin: 20
                anchors.bottomMargin: 10
                anchors.topMargin: 10
                spacing: 20
                CustomButton{
                    width: columnStop.width
                    height:(columnStop.height-2*columnStop.spacing)/3
                    clip: false
                }

                CustomButton{
                    width: columnStop.width
                    height:(columnStop.height-2*columnStop.spacing)/3
                    clip: false
                }

                CustomButton{
                    width: columnStop.width
                    height:(columnStop.height-2*columnStop.spacing)/3
                    clip: false
                }
            }

            CheckBox {
                id: checkBox
                width: 182
                height: 37

                font.italic: true
                font.bold: true
                text: qsTr("Bloquear Mov. Manual")

                anchors.left: parent.left
                anchors.top: parent.top
                clip: true
                anchors.leftMargin: 6
                anchors.topMargin: 8

            }
        }
        Rectangle {
            id: backgroundEstadoActual
            height: 226
            radius: 15
            border.width: 3
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
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
            width: 518
            radius:15
            border.width: 3

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 475
            anchors.leftMargin: 20
            anchors.bottomMargin: 10

            color: "#ffffff"
            clip: true

            ScrollView {
                id: scrollView
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: 35
                anchors.rightMargin: 0
                anchors.leftMargin: 6
                anchors.bottomMargin: 8
                clip: true
                hoverEnabled: false
                wheelEnabled: true

                //Prueba de scroll
                Label {
                    text: "ABCDEFG"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    font.pixelSize: 500
                    anchors.topMargin: 0
                    clip: true
                }
            }
            Label{
                width: 99
                text: qsTr("Log...")
                anchors.left: parent.left
                anchors.top: parent.top
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
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
            color: "#ffffff"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: backgroundEstadoActual.bottom
            anchors.bottom: parent.bottom
            anchors.leftMargin: 605
            anchors.topMargin: 28
            anchors.bottomMargin: 8
            anchors.rightMargin: 25
            radius: 15
            border.width: 3

            Rectangle{
                id:containerAngulos
                color: "#00000000"
                border.width: 0
                anchors.fill: parent

            }
        }
    }

}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.66;height:608;width:1218}D{i:3}D{i:14}D{i:27}D{i:38}D{i:42}
}
##^##*/
