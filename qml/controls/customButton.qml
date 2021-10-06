import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Button{
    id: btnToggle

    property url iconSource: "../../images/svg_images/menu_icon.svg"
    property color btnDefault: "#1c1d20"
    property color btnMouseOver: "#33353a"
    property color btnColorClicked: "#00a1f1"
    property color colorBtnDisable:"#636671"
    property int shadowHorizontal: 5
    property int shadowVertical: 5

    implicitWidth: 200
    implicitHeight: 60

    DropShadow{
        anchors.fill: backgroundBtn
        horizontalOffset: shadowHorizontal
        verticalOffset:shadowVertical
        radius: backgroundBtn.radius
        samples: 20
        color:"#80000000"
        source: backgroundBtn
    }

    QtObject{
        id:internal

        property var dynamicColor:
            if(btnToggle.enabled){
                if(btnToggle.down){
                    btnToggle.down ? btnColorClicked : btnDefault
                }else{
                    btnToggle.hovered ? btnMouseOver: btnDefault
                }
             }else{
                colorBtnDisable
             }
    }

    background: Rectangle{
            id:backgroundBtn
            color:internal.dynamicColor
            radius: 10
            border.width: 2

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
                width: 50
                height: 50
                anchors.fill: iconBtn
                source: iconBtn
                color: "#ffffff"
                antialiasing: false
            }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.9;height:60;width:60}
}
##^##*/
