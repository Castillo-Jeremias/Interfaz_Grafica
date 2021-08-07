import QtQuick 2.0
import QtQuick.Controls 2.15
import "../controls"

Page{
    property color colorBgComando : "#c00"
    id: item1
    implicitHeight: 1218
    implicitWidth: 608

    Rectangle {
        id: backGroundPage
        color: "#2c313b"
        anchors.fill: parent
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0

        Label {
            id: label
            x: 415
            y: 106
            color: "#ffffff"
            text: qsTr("Manual Page")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 20
        }

        Rectangle {
            id: backGroundComandos
            x: 72
            y: 359
            width: 347
            height: 164
            color: colorBgComando
            radius: 15
            border.width: 3

            Grid {
                id: gridComandos
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.rightMargin: 15
                anchors.leftMargin: 15
                anchors.topMargin: 15
                anchors.bottomMargin: 15
                flow: Grid.LeftToRight
                spacing: 10
                rows: 2
                columns: 3
                Rectangle{
                    width: 100
                    height: 30
                    color: "#00000000"
                }

                CustomButton{
                    id:btnArriba
                    width: 100
                    iconSource: "../../images/svg_images/Arriba.png"
                }

                Rectangle{
                    width: 100
                    height: 30
                    color: "#00000000"
                }
                CustomButton{
                    id:btnIzquierda
                    width: 100
                    iconSource: "../../images/svg_images/Izquierda.png"
                }
                CustomButton{
                    id:btnAbajo
                    width: 100
                    iconSource: "../../images/svg_images/Abajo.png"
                }
                CustomButton{
                    id:btnDerecha
                    width: 100
                    iconSource: "../../images/svg_images/Derecha.png"
                }

            }

        }

        Rectangle {
            id: backgroundEstadoActual
            color: "#ffffff"
            radius: 15
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: backgroundLog.top
            anchors.leftMargin: 690
            anchors.topMargin: 50
            anchors.bottomMargin: 58
            anchors.rightMargin: 110
        }

        Rectangle {
            id: backgroundLog
            radius:15
            anchors.left: parent.left
            anchors.right: parent.right
            color: "#ffffff"
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 43
            anchors.rightMargin: 40
            anchors.leftMargin: 620
            anchors.topMargin: 324
        }

        ButtonTracking{}
    }



}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.9;height:608;width:1218}
}
##^##*/
