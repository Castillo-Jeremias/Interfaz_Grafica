import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import "controls"

Window {
    id: mainwindow
    visible: true
    color: "#00000000"
    title: "mainWindow"

    height: 600
    width: 1300

    // Removemos bordes de de aplicación deWindows
    flags: Qt.Window | Qt.FramelessWindowHint

    // Propiedades
    property int windowStatus: 0
    property int windowMargin: 10

    // Funciones internas
    QtObject{
        id:internal

        function maximazeRestore(){
            if(windowStatus == 0){
                mainwindow.showMaximized()
                windowStatus = 1
                windowMargin = 0
                maximizeButton.iconSource = "../images/svg_images/restore_icon.svg"
            }else{
                mainwindow.showNormal()
                windowStatus = 0
                windowMargin = 10
                maximizeButton.iconSource = "../images/svg_images/maximize_icon.svg"
            }
        }

        function ifMaximizedWindowRestore(){
            if(windowStatus == 1){
                mainwindow.showNormal()
                windowStatus = 0
                windowMargin = 10
                maximizeButton.iconSource = "../images/svg_images/maximize_icon.svg"
            }
        }

        function restoreMargins(){
            windowStatus = 0
            windowMargin = 10
            maximizeButton.iconSource = "../images/svg_images/maximize_icon.svg"
        }
    }

    Rectangle {
        z:1     // Se generaba un bug que no podiamos ver la interfaz en editor
        id: backGround
        color: "#2c313b"
        border.color: "#3d4453"
        border.width: 1

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        anchors.topMargin: windowMargin
        anchors.bottomMargin: windowMargin
        anchors.leftMargin: windowMargin
        anchors.rightMargin: windowMargin

        Rectangle {
            id: appContainer
            color: "#00000000"
            anchors.fill: parent
            anchors.rightMargin: 1
            anchors.leftMargin: 1
            anchors.bottomMargin: 1
            anchors.topMargin: 1


            Rectangle {
                id: topBar
                width: 780
                height: 50
                color: "#232323"
                border.width: 0
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: 0
                anchors.leftMargin: 60
                anchors.topMargin: 0

                Rectangle {
                    id: bottomBar
                    color: "#282c34"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: titleBar.bottom
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.topMargin: 0
                    anchors.rightMargin: 0
                    anchors.leftMargin: 0
                }


                Rectangle {
                    id: titleBar
                    width: 640
                    color: "#00000000"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20
                    anchors.topMargin: 0
                    anchors.leftMargin: 0
                    anchors.rightMargin: 105

                    DragHandler{
                        onActiveChanged:
                            if(active){
                                mainwindow.startSystemMove()
                                internal.ifMaximizedWindowRestore()   // Actualización de sombra
                            }
                    }

                    Label {
                        id: tituloLabel
                        color: "#dadada"
                        text: qsTr("Ground Station Controller")
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        anchors.leftMargin: 10
                        font.pointSize: 10
                    }
                }

                Rectangle {
                    id: rectCloseMinimMax
                    color: "#222222"
                    anchors.left: titleBar.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: bottomBar.top
                    anchors.bottomMargin: 0
                    anchors.leftMargin: 0
                    anchors.rightMargin: 0
                    anchors.topMargin: 0

                    TopBarButton {
                        id: maximizeButton
                        width: 30
                        anchors.left: parent.left
                        anchors.right: closeButton.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 5
                        anchors.bottomMargin: 5
                        anchors.leftMargin: 40
                        anchors.rightMargin: 10
                        btnMouseOver: "#555555"
                        btnDefault: "#3f3f3f"
                        iconSource: "../images/svg_images/maximize_icon.svg"

                        onClicked: internal.maximazeRestore()
                    }

                    TopBarButton {
                        id: closeButton
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 75
                        btnColorClicked: "#ff007f"
                        btnMouseOver: "#797979"
                        anchors.bottomMargin: 5
                        anchors.topMargin: 5
                        anchors.rightMargin: 5
                        btnDefault: "#3f3f3f"
                        iconSource: "../images/svg_images/close_icon.svg"

                        onClicked: mainwindow.close()
                    }

                    TopBarButton {
                        id: minimizeButton
                        anchors.left: parent.left
                        anchors.right: maximizeButton.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: 10
                        anchors.leftMargin: 5
                        btnMouseOver: "#555555"
                        anchors.bottomMargin: 5
                        anchors.topMargin: 5
                        btnDefault: "#3f3f3f"

                        onClicked:{
                            mainwindow.showMinimized()
                            internal.restoreMargins()
                        }
                    }
                }
            }

            Rectangle {
                id: imageContainer
                color: "#222222"
                anchors.left: parent.left
                anchors.right: topBar.left
                anchors.top: parent.top
                anchors.bottom: content.top
                anchors.leftMargin: 0
                anchors.topMargin: 0
                anchors.bottomMargin: 0
                anchors.rightMargin: 0

                LogoFceia {
                    height: 60
                    anchors.right: parent.right
                    anchors.rightMargin: 3
                    anchors.leftMargin: 3
                    anchors.topMargin: 3
                    anchors.bottomMargin: 3

                }


            }

            Rectangle {
                id: content
                color: "#00000000"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: topBar.bottom
                anchors.bottom: parent.bottom
                anchors.rightMargin: 0
                anchors.leftMargin: 0
                anchors.bottomMargin: 0
                anchors.topMargin: 0

                Rectangle {
                    id: leftBar
                    x: 0
                    y: 0
                    width: 60
                    color: "#222222"
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 0
                    anchors.bottomMargin: 0
                    anchors.topMargin: 0

                    PropertyAnimation{
                        id: animationLeftMenu
                        target:leftBar
                        property: "width"
                        to: if(leftBar.width == 60){
                                return 180;
                            }else{
                                return 60
                            }
                        duration: 1000
                        easing.type:  Easing.InOutQuint
                    }

                    LeftMenuButton {
                        id: btnSetting
                        x: 0
                        y: 180
                        text: qsTr("Setting")
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 0
                        iconSource: "../images/svg_images/settings_icon.svg"
                    }

                    Column {
                        id: columnaMenu
                        width: 60
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: 0
                        anchors.leftMargin: 0
                        anchors.bottomMargin: 0
                        anchors.topMargin: 0

                        CustomButton {
                            id: toggleButton
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 468
                            anchors.rightMargin: 0
                            anchors.leftMargin: 0
                            anchors.topMargin: 0
                            btnMouseOver: "#282d35"
                            btnDefault: "#212121"
                            onClicked: animationLeftMenu.running = true

                        }

                        LeftMenuButton {
                            id:btnSave
                            text: qsTr("Save")
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: 0
                            iconSource: "../images/svg_images/save_icon.svg"
                            anchors.topMargin: 180
                        }

                        LeftMenuButton {
                            id: btnOpenFile
                            text: qsTr("Open File")
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: 0
                            iconSource: "../images/svg_images/open_icon.svg"
                            anchors.topMargin: 120
                        }

                        LeftMenuButton {
                            id: btnHome
                            text: qsTr("Home")
                            anchors.top: parent.top
                            anchors.topMargin: 60
                        }
                    }


                }

                Rectangle {
                    id: contentPage
                    color: "#2c313b"
                    anchors.left: leftBar.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20
                    anchors.leftMargin: 0
                }

                Rectangle {
                    id: bottomContentBar
                    color: "#282c34"
                    anchors.left: leftBar.right
                    anchors.right: parent.right
                    anchors.top: contentPage.bottom
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 0
                    anchors.leftMargin: 0
                    anchors.bottomMargin: 0
                    anchors.topMargin: 0
                }
            }

        }
    }
    // Agregado de sombra en bordes de la aplicación
    DropShadow{
        anchors.fill: backGround
        horizontalOffset: 0
        verticalOffset: 0
        radius: 10
        samples: 20
        color:"#80000000"
        source: backGround
        z:0
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.9}
}
##^##*/
