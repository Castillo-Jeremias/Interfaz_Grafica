import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15


Image {
    id: logoImage
    property url iconSource: "../../images/svg_images/logo.svg"

    width: 60
    height: 60
    anchors.left: parent.left
    anchors.right: titleBar.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    source: iconSource
    fillMode: Image.PreserveAspectFit

    ColorOverlay{
        anchors.fill: logoImage
        source: logoImage
        color: "#ffffff"
        antialiasing: false
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:2;height:50;width:50}
}
##^##*/
