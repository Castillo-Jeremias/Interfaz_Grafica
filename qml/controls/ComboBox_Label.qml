import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Button{

    width: 300
    height: 50
    visible: true

    id: customLabel

    background: Rectangle{
        id:backgroundComboBox
        color: "#1c1d20"
        border.width: 2
        radius: 15
    }
    contentItem: Item {
        id: item1

        Text {
            id: textBtn
            text: qsTr("Objetivo")
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            font.pointSize: 12
            color: "#ffffff"

        }
    }
    CustomComboBox{
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        anchors.topMargin: 2
        anchors.rightMargin: 2

    }

}
