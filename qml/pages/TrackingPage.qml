import QtQuick 2.0
import QtQuick.Controls 2.15
import "../controls"
import Qt.labs.calendar 1.0

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
            x: 481
            y: 288
            color: "#ffffff"
            text: qsTr("Tracking Page")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            rotation: 90
            font.pointSize: 20
        }

        Rectangle {
            id: backGroundComandos
            color: "#b5b5b5"
            radius: 15
            border.width: 5
            anchors.left: parent.left
            anchors.right: backgroundLog.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.rightMargin: 106
            anchors.leftMargin: 50
            anchors.bottomMargin: 30
            anchors.topMargin: 54
            rotation: 0

            CustomComboBox{
                x: 261
                y: 112
            }
            CustomLabel{
                x: 48
                y: 112
                anchors.verticalCenterOffset: 12
                anchors.leftMargin: 74
            }
        }

        Rectangle {
            id: backgroundEstadoActual
            color: "#ffffff"
            radius: 15
            border.width: 5
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: backgroundLog.top
            anchors.leftMargin: 660
            anchors.topMargin: 39
            anchors.bottomMargin: 50
            anchors.rightMargin: 80

            Label {
                id: label1
                text: qsTr("Estado Actual")
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.NoWrap
                font.italic: true
                font.bold: true
                anchors.rightMargin: 0
                anchors.leftMargin: 20
                anchors.topMargin: 10
                font.pointSize: 20
            }
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
    D{i:0;height:608;width:1218}D{i:7}
}
##^##*/
