import QtQuick 2.0
import QtQuick.Controls 2.15

Item {
    Rectangle {
        id: backGroundPage
        color: "#2c313b"
        anchors.fill: parent

        Label {
            id: label
            x: 315
            y: 198
            color: "#ffffff"
            text: qsTr("Home Page")
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 20
        }
    }

}
