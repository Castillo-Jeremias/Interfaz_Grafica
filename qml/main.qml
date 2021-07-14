import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: mainwindow
    visible: true
    title: "mainWindow"
    color: "#00000000"  //Color transparente

    Rectangle {
        id: backGround
        color: "#2c313c"
        border.color: "#3d4453"
        border.width: 1
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        Rectangle {
            id: appCotainer
            color: "#00000000"
            anchors.fill: parent
            anchors.rightMargin: 1
            anchors.leftMargin: 1
            anchors.bottomMargin: 1
            anchors.topMargin: 1

            Rectangle {
                id: topBar
                width: 780
                height: 60
                color: "#232323"
                border.width: 0
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: 0
                anchors.leftMargin: 0
                anchors.topMargin: 0

                Rectangle {
                    id: bottomBar
                    color: "#282c34"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 30
                    anchors.rightMargin: 0
                    anchors.leftMargin: 60
                    anchors.bottomMargin: 0
                }

                Image {
                    id: imagen
                    anchors.left: parent.left
                    anchors.right: titleBar.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    source: "qrc:/qtquickplugin/images/template_image.png"
                    anchors.rightMargin: 10
                    anchors.leftMargin: 10
                    anchors.bottomMargin: 10
                    anchors.topMargin: 10
                    fillMode: Image.PreserveAspectFit

                    Rectangle {
                        id: rectangle1
                        color: "#00000000"
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: 0
                        anchors.leftMargin: 0
                        anchors.bottomMargin: 0
                        anchors.topMargin: 0
                    }
                }

                Rectangle {
                    id: titleBar
                    width: 640
                    color: "#222222"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 30
                    anchors.topMargin: 0
                    anchors.leftMargin: 60
                    anchors.rightMargin: 105

                    Label {
                        id: label
                        color: "#dadada"
                        text: qsTr("Ground Station Controller")
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        anchors.rightMargin: 0
                        font.pointSize: 10
                        anchors.topMargin: 5
                        anchors.bottomMargin: 5
                        anchors.leftMargin: 5
                    }
                }

                Rectangle {
                    id: rectangle
                    color: "#222222"
                    anchors.left: titleBar.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: bottomBar.top
                    anchors.leftMargin: 0
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 0
                    anchors.topMargin: 0

                    RoundButton {
                        id: roundButton2
                        width: 20
                        text: "+"
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 5
                        anchors.bottomMargin: 5
                        anchors.rightMargin: 10
                    }

                    RoundButton {
                        id: roundButton
                        width: 20
                        text: "+"
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5
                        anchors.topMargin: 5
                        anchors.rightMargin: 40
                    }

                    RoundButton {
                        id: roundButton1
                        width: 20
                        text: "+"
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: 70
                        anchors.bottomMargin: 5
                        anchors.topMargin: 5
                    }
                }
            }

            Rectangle {
                id: leftBar
                width: 60
                color: "#222222"
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 0
                anchors.bottomMargin: 0
                anchors.topMargin: 60
            }

        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:1.5;height:600;width:800}D{i:10}D{i:11}D{i:12}
D{i:9}D{i:13}
}
##^##*/
