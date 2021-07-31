import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
Item {
    property bool isActive: false
    width: 50
    height: 50
    BusyIndicator{
        anchors.fill: parent
        id:myBusyIndicator
    }

    ColorOverlay{
        id:custombusycolor
        width: parent.width
        height: parent.height
        anchors.fill: myBusyIndicator
        source: myBusyIndicator
        color: "#ffffff"
        antialiasing: false
    }
    visible: isActive   // No van a ver nada si aca hay un false
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:1.66;height:50;width:50}
}
##^##*/
