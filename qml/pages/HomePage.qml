import QtQuick 2.0
import QtQuick.Controls 2.15

Item{
    id: homepage

    Rectangle{
        id: backGroundPage
        color: "#2c313b"
        anchors.fill: parent

        Label {
            id: label
            x: 541
            y: 288
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("Home Page")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: "#ffffff"
            font.pointSize: 20
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.5;height:608;width:1218}
}
##^##*/
