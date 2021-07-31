import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

// Simulamos un label con un boton para poder ponerle background

Button{
    property color backgroundButton: "#1c1d20"
    property string dataTxt: "Data Text"
    property int altotxt: 8
    property bool enableEditData: false

    id:id_label_TextEdit
    text: qsTr("Change this text")

    width: 400
    height: 30
    visible: true

    background: Rectangle{
        id:backgroundlabel_TextEdit
        width: parent.width
        height: parent.height
        color: backgroundButton
        border.width: 2
        radius: 10
    }

    contentItem: Item{
        id: item1
        width: 300
        anchors.fill: parent

        Text {
            id: label_TextEdit_txt

            font.pointSize: altotxt
            anchors.left: parent.left
            anchors.leftMargin: 10

            text: id_label_TextEdit.text
            color: "#ffffff"
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        TextEdit{
            id:textEdit
            font.pointSize: altotxt
            color: "#ffffff"
            text: dataTxt
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            anchors.rightMargin: 15
            anchors.leftMargin: 50

            readOnly: true
            cursorVisible: false

            anchors.left: label_TextEdit_txt.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
    }
}





/*##^##
Designer {
    D{i:0;formeditorZoom:1.25}
}
##^##*/
