import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Button{
    id: topBarBtn

    property url iconSource: "../../images/svg_images/minimize_icon.svg"
    property color btnDefault: "#505050"
    property color btnMouseOver: "#797979"
    property color btnColorClicked: "#00a1f1"

    QtObject{
        id:internal
        property var dynamicColor: if(topBarBtn.down){
                                        topBarBtn.down ? btnColorClicked : btnDefault
                                     }else{
                                        topBarBtn.hovered ? btnMouseOver: btnDefault
                                     }
    }

    implicitWidth: 16
    implicitHeight: 16


    background: Rectangle{
            id:backgroundBtn
            color:internal.dynamicColor
            radius: 100

            Image {
                id: iconBtn
                source: iconSource
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                height: 16
                width: 16
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
    D{i:0;formeditorZoom:3;height:20;width:20}
}
##^##*/
