import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Button{
    id: btnLeftMenu
    implicitWidth: 250
    implicitHeight: 60
    text: qsTr("Left Text")

    property url iconSource: "../../images/svg_images/home_icon.svg"
    property color btnDefault: "#222222"
    property color btnMouseOver: "#23272E"
    property color btnColorClicked: "#00a1f1"

    property int iconWidth: 20
    property int iconHeigh: 20

    property color activeMenuColorLeft: "#55aaff"
    property color activeMenuColorRight: "#2c313c"
    property color buttonPush: "#2a2a2a"
    property int  ancho_altoRectPush: 5
    property bool isActiveMenu: false

    QtObject{
        id:internal
        property var dynamicColor:
            if(btnLeftMenu.down){
                btnLeftMenu.down ? btnColorClicked : btnDefault
            }else{
                btnLeftMenu.hovered ? btnMouseOver: btnDefault
            }
    }


    background: Rectangle{
            id: backgroundBtn
            color: internal.dynamicColor

            Rectangle{
                anchors{
                    top: parent.top
                    left: parent.left
                    bottom: parent.bottom
                }
                color: activeMenuColorLeft
                width: 3
                visible: isActiveMenu
            }

            Rectangle{
                anchors{
                    top: parent.top
                    right: parent.right
                    bottom: parent.bottom
                }
                color: buttonPush
                width: ancho_altoRectPush
                visible: isActiveMenu
            }

            Rectangle{
                height: ancho_altoRectPush
                visible: isActiveMenu
                color: buttonPush

                anchors{
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                anchors.rightMargin: 0
                anchors.leftMargin: 3
                anchors.bottomMargin: 0
            }
            Rectangle{
                height: ancho_altoRectPush
                visible: isActiveMenu
                color: buttonPush

                anchors{
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                anchors.topMargin: 0
                anchors.rightMargin: 0
                anchors.leftMargin: 3
            }

    }

    contentItem: Item{
        id: content
        anchors.fill: parent
            Image {
                id: btnIcon
                source: iconSource

                anchors.leftMargin: 15
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                sourceSize.width: iconWidth
                sourceSize.height: iconHeigh
                width: iconWidth
                height: iconHeigh

                fillMode: Image.PreserveAspectFit
                visible: false
                antialiasing: true
            }

            ColorOverlay{
                anchors.fill: btnIcon
                source: btnIcon
                color: "#ffffff"
                width: iconWidth
                height: iconHeigh

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                antialiasing: true
            }

            Text {
                text: btnLeftMenu.text
                font: btnLeftMenu.font
                color: "#ffffff"

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 60

            }
    }
}


/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:2;height:60;width:200}D{i:5}
}
##^##*/
