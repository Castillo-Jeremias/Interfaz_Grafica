import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Button{
    z:1
    id: btnTracking
    text: "Buttorn TXT"
    font.bold: true
    font.pointSize: 10
    font.italic: true

    property color btnDefault: "#1c1d20"
    property color btnMouseOver: "#33353a"
    property color btnColorClicked: "#00a1f1"
    property color colorBtnDisable:"#767a87"
    property int shadowHorizontal: 3
    property int shadowVertical: 3

    implicitWidth: 120
    implicitHeight: 30

    QtObject{
        id:internal

        property var dynamicColor:
            if(btnTracking.enabled){
                if(btnTracking.down){
                    btnTracking.down ? btnColorClicked : btnDefault
                }else{
                    btnTracking.hovered ? btnMouseOver: btnDefault
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
    }

    Text {
        z:1
        anchors.fill: parent
        font.italic: btnTracking.font.italic
        font.pointSize: btnTracking.font.pointSize
        font.bold: btnTracking.font.bold
        color: "#ffffff"
        text: btnTracking.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

    }

    DropShadow{
        anchors.fill: backgroundBtn
        horizontalOffset: shadowHorizontal
        verticalOffset:shadowVertical
        radius: 10
        samples: 20
        color:"#80000000"
        source: backgroundBtn
        z:0
    }


}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.75;height:30;width:100}
}
##^##*/

