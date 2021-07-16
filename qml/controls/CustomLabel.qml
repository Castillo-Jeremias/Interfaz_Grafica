import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Button{

    width: 120
    height: 50
    visible: true

    id: customLabel
    implicitWidth:  120
    implicitHeight: 50

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

}


/*##^##
Designer {
    D{i:0;formeditorZoom:1.75}
}
##^##*/
