import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Button{
    id: btnToggle

    property url iconSource: "../../images/svg_images/menu_icon.svg"
    property color btnDefault: "#1c1d20"
    property color btnMouseOver: "#23272E"
    property color btnColorClicked: "#00a1f1"
    text: ""

    implicitWidth: 200
    implicitHeight: 60

    QtObject{
        id:internal

        property var dynamicColor:
            if(btnToggle.down){
                btnToggle.down ? btnColorClicked : btnDefault
             }else{
                btnToggle.hovered ? btnMouseOver: btnDefault
             }
    }


    background: Rectangle{
            id:backgroundBtn
            color:internal.dynamicColor
            radius: 10

            Image {
                id: iconBtn
                source: iconSource
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                height: 25
                width: 25
                fillMode: Image.PreserveAspectFit
            }

            ColorOverlay{
                anchors.fill: iconBtn
                source: iconBtn
                color: "#ffffff"
                antialiasing: false
            }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:1.33;height:50;width:50}
}
##^##*/
