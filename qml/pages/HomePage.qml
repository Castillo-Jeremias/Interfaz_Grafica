import QtQuick 2.0
import QtQuick.Controls 2.15

Page{
    id: homepage

    Rectangle{
        id: backGroundPage
        color: "#2c313b"
        anchors.fill: parent
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0



        Rectangle {
            id: rectangle2
            x: 726
            width: 472
            color: "#ffffff"
            radius: 15
            border.width: 3
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            anchors.rightMargin: 20
        }

        Column {
            id: columnPresentacion
            width: backGroundPage.width/2
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 20
            anchors.bottomMargin: 10
            anchors.topMargin: 10
            spacing: backGroundPage.height/12

            Rectangle {
                id: backgroundPresentacion
                width: columnPresentacion.width
                height: 5*columnPresentacion.width/12 - columnPresentacion.spacing/2 - columnPresentacion.anchors.bottomMargin
                color: "#9f9f9f"
                radius:15
                border.width: 3

                Label{
                    id: tituloPresentacion

                    width:backgroundPresentacion.width
                    height:30

                    text: "Descripción del proyecto"
                    anchors.top: parent.top
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignTop
                    anchors.topMargin: 10
                    font.italic: true
                    font.bold: true
                    font.pointSize: 18
                }

                Label{
                    id: mensajePresentacion

                    text: qsTr("Controlador para posicionamiento y tracking de un radiotelescopio. Está basado en un DSPIC33FJ128GP804 con 2 tipos diferentes de salidas digitales, una entrada y salida analógica, modulo GPS y una conexión USB. Este dispositivo interactuará con 2 motores encargados del movimiento del radiotelescopio y será capaz de comunicarse con una PC vía USB para obtener la ruta que deberá seguir.")
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: tituloPresentacion.bottom
                    anchors.bottom: parent.bottom
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    anchors.topMargin: 5
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    anchors.bottomMargin: 20
                    font.bold: true
                    font.pointSize: (mensajePresentacion.height + mensajePresentacion.width)/60
                    color: "#ffffff"
                }
            }

            Rectangle {
                id: rectangle1
                width: parent.width
                height: 7*columnPresentacion.width/12 - columnPresentacion.spacing/2 - columnPresentacion.anchors.bottomMargin
                color: "#ffffff"
                radius: 15
                border.width: 3
            }
        }


    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.66;height:608;width:1218}D{i:2}
}
##^##*/
