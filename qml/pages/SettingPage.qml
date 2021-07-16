import QtQuick 2.0
import QtQuick.Controls 2.15

Item {
    Rectangle {
        id: backGroundPage
        color: "#2c313b"
        anchors.fill: parent

        Label {
            id: label
            color: "#ffffff"
            text: qsTr("Setting Page")
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 20
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.5;height:480;width:800}
}
##^##*/
