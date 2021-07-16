import QtQuick 2.0
import QtQuick.Controls 2.15
import "../controls"

Item {
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
            color: colorBgComando
            radius: 15
            border.width: 5
            anchors.left: parent.left
            anchors.right: backgroundLog.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.rightMargin: 191
            anchors.leftMargin: 50
            anchors.bottomMargin: 30
            anchors.topMargin: 311
            rotation: 0

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
    }



}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.5;height:608;width:1218}D{i:3}D{i:4}D{i:5}
}
##^##*/
