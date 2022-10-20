import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3
import "../controls"

Page{
    id: id_setting_page

    QtObject{
        id:internal

        function getTime(){
            return Qt.formatDateTime(new Date(),"dd/MM/yy  hh:mm:ss")
        }

    }

    property string colorBackgroundPage: "#2c313b"
    property string colorBackgroundContainer: "#9f9f9f"
    property string colorForegroundTitle: "#26282a"
    property string colorForegroundText: "#ffffff"

    Rectangle {
        id: backGroundPage
        color: colorBackgroundPage
        anchors.fill: parent
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0

        Rectangle {
            id: backGroundSettingTracking
            radius: 15
            border.width: 3
            implicitWidth: 541
            implicitHeight:  588
            color: colorBackgroundContainer
            anchors.left: parent.left
            anchors.right: backGroundNumber1.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.rightMargin: 44
            anchors.leftMargin: 20
            anchors.topMargin: 10
            anchors.bottomMargin: 10

            Rectangle {
                id: containerComandosToShow
                color: "#00000000"
                anchors.fill: parent
                anchors.rightMargin: 5
                anchors.leftMargin: 5
                anchors.bottomMargin: 5
                anchors.topMargin: 5

                ScrollView {
                    id: scrollViewVentanaComandosToShow
                    anchors.fill: parent
                    anchors.topMargin: 4
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 3
                    anchors.leftMargin: 15

                    font.pointSize: 15
                    font.italic: true

                    clip: true
                    wheelEnabled: true
                    TextEdit{
                        id: ventanaLogComandos
                        anchors.fill: parent
                        cursorVisible: true

                        selectionColor: "#8c8c8c"
                        selectByMouse: true
                        clip: true

                        font.italic: true
                        font.pointSize: 10

                        readOnly: true
                    }
                }

            }
        }

        Rectangle {
            id: backGroundNumber1
            color: colorBackgroundContainer
            implicitHeight: 280
            implicitWidth: 588
            radius:15
            border.width: 3

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 605
            anchors.topMargin: 10
            anchors.rightMargin: 25
        }
    }

    Rectangle {
        id: backGroundNumber2
        color: colorBackgroundContainer

        implicitHeight: 280
        implicitWidth: 588
        radius:15
        border.width: 3

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 318
        anchors.leftMargin: 605
        anchors.bottomMargin: 10
        anchors.rightMargin: 25
    }
}





/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.9;height:608;width:1218}
}
##^##*/
