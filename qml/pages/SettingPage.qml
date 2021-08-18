import QtQuick 2.0
import QtQuick.Controls 2.15

Page{
    id: id_setting_page

    Rectangle {
        id: backGroundPage
        color: "#3b0b07"
        anchors.fill: parent
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0

        Rectangle {
            id: backGroundSettingTracking
            radius: 15
            implicitWidth: 541
            implicitHeight:  588
            color: "#ffffff"
            anchors.left: parent.left
            anchors.right: backGroundNumber1.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.rightMargin: 44
            anchors.leftMargin: 20
            anchors.topMargin: 10
            anchors.bottomMargin: 10
        }

        Rectangle {
            id: backGroundNumber1
            color: "#ffffff"
            implicitHeight: 280
            implicitWidth: 588
            radius:15

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: backGroundNumber2.top
            anchors.bottomMargin: 28
            anchors.leftMargin: 605
            anchors.topMargin: 10
            anchors.rightMargin: 25
        }

        Rectangle {
            id: backGroundNumber2
            color: "#ffffff"

            implicitHeight: 280
            implicitWidth: 588
            radius:15

            anchors.left: backGroundSettingTracking.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 318
            anchors.leftMargin: 44
            anchors.bottomMargin: 10
            anchors.rightMargin: 25
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.5;height:608;width:1218}D{i:2}D{i:3}D{i:4}
}
##^##*/
