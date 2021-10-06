import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.3

import "controls"
import "pages"

Window {
    id: mainwindow
    visible: true
    color: "#00000000"
    title: "GroundStationController"

    height: 700
    width: 1300

    //Mínima resolución de escritorio tolerada
    minimumHeight: 700
    minimumWidth:  1300

    //Máxima resolución de escritorio tolerada
    maximumHeight: 1920
    maximumWidth:  1080

    // Removemos bordes de de aplicación de Windows
    flags: Qt.Window | Qt.FramelessWindowHint

    // Propiedades
    property int windowStatus: 0
    property int windowMargin: 10

    // Funciones internas

    QtObject{
        id:internal

        function resetResize(){
            // Visibilidad de los ajustes de ventana
            resizeLeft.visible = true
            resizeRight.visible = true
            resizeBottom.visible = true
            resizeDiagDrchaInf.visible = true
        }

        function maximazeRestore(){
            if(windowStatus == 0){
                mainwindow.showMaximized()
                windowStatus = 1
                windowMargin = 0

                // Visibilidad de los ajustes de ventana
                resizeLeft.visible = false
                resizeRight.visible = false
                resizeBottom.visible = false
                resizeDiagDrchaInf.visible = false

                // Cambio de icono de maximizado
                maximizeButton.iconSource = "../images/svg_images/restore_icon.svg"
            }else{
                mainwindow.showNormal()
                windowStatus = 0
                windowMargin = 10

                // Visibilidad de los ajustes de ventana
                internal.resetResize()

                // Cambio de icono de maximizado
                maximizeButton.iconSource = "../images/svg_images/maximize_icon.svg"
            }
        }

        function ifMaximizedWindowRestore(){
            if(windowStatus == 1){
                mainwindow.showNormal()
                windowStatus = 0
                windowMargin = 10
                // Cambio de icono de maximizado
                maximizeButton.iconSource = "../images/svg_images/maximize_icon.svg"
            }
        }

        function restoreMargins(){
            windowStatus = 0
            windowMargin = 10
            maximizeButton.iconSource = "../images/svg_images/maximize_icon.svg"
        }

        function disableButtonsMenu(){
            btnHome.isActiveMenu = false
            btnSettings.isActiveMenu = false
            btnTracking.isActiveMenu = false
        }

        function disableViews(){
            viewHomePage.visible = false
            viewSettingPage.visible = false
            viewTrackingPage.visible = false
            viewManualPage.visible = false
        }

        function setVisibility(btnClicked){

            switch(btnClicked){

                case btnHome:
                    disableViews()
                    viewHomePage.visible = true
                    break;

                case btnTracking:
                    disableViews()
                    viewTrackingPage.visible = true
                    break;

                case btnSettings:
                    disableViews()
                    viewSettingPage.visible = true
                    break;
            }
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
        clip: true

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
                color: "#222222"
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
                    clip: true
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
                        clip: true
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
                        clip: true
                        anchors.leftMargin: 75
                        btnColorClicked: "#ff007f"
                        btnMouseOver: "#797979"
                        anchors.bottomMargin: 5
                        anchors.topMargin: 5
                        anchors.rightMargin: 5
                        btnDefault: "#3f3f3f"
                        iconSource: "../images/svg_images/close_icon.svg"

                        onClicked: {
                            mainwindow.close()
                        }
                    }

                    TopBarButton {
                        id: minimizeButton
                        anchors.left: parent.left
                        anchors.right: maximizeButton.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        clip: true
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
                    anchors.rightMargin: 5
                    anchors.leftMargin: 5
                    anchors.topMargin: 5
                    anchors.bottomMargin: 5

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
                    z: 1
                    clip: true
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
                        duration: 1200
                        easing.type:  Easing.InOutQuint
                    }

                    Column {
                        id: column
                        anchors.fill: parent
                        spacing: 2
                        anchors.topMargin: 0
                        anchors.bottomMargin: 60
                        clip: true

                        LeftMenuButton {
                            id: btnMenu
                            width: leftBar.width
                            text: qsTr(" ")
                            font.italic: true
                            iconSource: "../images/svg_images/menu_icon.svg"
                            iconHeigh: 30
                            layer.textureMirroring: ShaderEffectSource.MirrorVertically
                            iconWidth: 30

                            onClicked:{
                                animationLeftMenu.running = true
                            }
                            Text {
                                id: textMenuButton
                                text: "Menu Principal"
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                font.italic: true
                                anchors.leftMargin: 60
                            }
                        }

                        LeftMenuButton {
                            id: btnHome
                            width: leftBar.width
                            text: qsTr("Home")
                            font.italic: true
                            isActiveMenu: true
                            iconWidth: 30
                            iconHeigh: 30
                            layer.textureMirroring: ShaderEffectSource.MirrorVertically
                            onClicked: {
                                internal.disableButtonsMenu()
                                btnHome.isActiveMenu = true
                                internal.setVisibility(btnHome)
                            }
                        }

                        LeftMenuButton {
                            id: btnTracking
                            x: 0
                            y: 60
                            width: leftBar.width
                            text: qsTr("Antena")
                            font.italic: true
                            iconWidth: 25
                            iconHeigh: 30
                            layer.textureMirroring: ShaderEffectSource.MirrorVertically
                            iconSource: "../images/svg_images/Antena.png"

                            onClicked: {
                                internal.disableButtonsMenu()
                                btnTracking.isActiveMenu = true
                                //stackView.push(Qt.resolvedUrl("pages/TrackingPage.qml"))
                                internal.setVisibility(btnTracking)
                            }
                        }
                    }

                    LeftMenuButton {
                        id: btnSettings
                        y: 485
                        width: leftBar.width
                        text: qsTr("Setting")
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 0
                        font.italic: true
                        iconWidth: 30
                        iconHeigh: 25
                        clip: false
                        anchors.leftMargin: 0
                        iconSource: "../images/svg_images/settings_icon.svg"
                        onClicked: {
                            internal.disableButtonsMenu()
                            btnSettings.isActiveMenu = true
                            //stackView.push(Qt.resolvedUrl("pages/SettingPage.qml"))
                            internal.setVisibility(btnSettings)
                        }
                    }
                }

                Rectangle {
                    id: contentPage
                    color: "#2c313b"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    clip: true
                    anchors.bottomMargin: 20
                    anchors.leftMargin: 60

                    Loader{
                        id:viewHomePage
                        anchors.fill: parent
                        source: Qt.resolvedUrl("pages/HomePage.qml")
                        visible: true
                    }

                    Loader{
                        id:viewSettingPage
                        anchors.fill: parent
                        source: Qt.resolvedUrl("pages/SettingPage.qml")
                        visible: false
                    }

                    Loader{
                        id:viewManualPage
                        anchors.fill: parent
                        source: Qt.resolvedUrl("pages/ManualPage.qml")
                        visible: false
                    }

                    Loader{
                        id:viewTrackingPage
                        anchors.fill: parent
                        source: Qt.resolvedUrl("pages/TrackingPage.qml")
                        visible: false
                    }
                }

                Rectangle {
                    id: bottomContentBar
                    color: "#282c34"
                    anchors.left: leftBar.right
                    anchors.right: parent.right
                    anchors.top: contentPage.bottom
                    anchors.bottom: parent.bottom
                    clip: true
                    anchors.rightMargin: 0
                    anchors.leftMargin: 0
                    anchors.bottomMargin: 0
                    anchors.topMargin: 0

                    Label {
                        id: label
                        x: 1080
                        y: 4
                        width: 400
                        height: 30
                        color: "#ffffff"
                        text: qsTr("Desarrollado por: Biagiola, Sebastían C. ; Campero, Gustavo; Castillo, Jeremías")
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        clip: false
                        anchors.rightMargin: 20
                    }
                }
            }

            MouseArea {
                id: resizeDiagDrchaInf
                x: 1264
                y: 664
                width: 25
                height: 25
                opacity: 0.5
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.rightMargin: 0
                cursorShape: Qt.SizeFDiagCursor

                Image {
                    id: imageResize
                    width: 30
                    height: 30
                    anchors.fill: parent
                    source: "../images/svg_images/resize_icon.svg"
                    anchors.leftMargin: 8
                    sourceSize.height: 16
                    sourceSize.width: 16
                    anchors.topMargin: 8
                    fillMode: Image.PreserveAspectFit
                    antialiasing: false
                }

                DragHandler{
                    target: null
                    onActiveChanged:{
                        if(active){
                            mainwindow.startSystemResize(Qt.RightEdge | Qt.BottomEdge)
                        }
                    }
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

    MouseArea {
        id: resizeLeft
        width: 10
        height: 741
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.topMargin: 10
        anchors.leftMargin: 0
        cursorShape: Qt.SizeHorCursor
        DragHandler{
            target: null
            onActiveChanged:{
                if(active){
                    mainwindow.startSystemResize(Qt.LeftEdge)
                }
            }
        }
    }

    MouseArea {
        id: resizeRight
        x: 1289
        width: 10
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.topMargin: 10
        anchors.rightMargin: 0
        cursorShape: Qt.SizeHorCursor

        DragHandler{
            target: null
            onActiveChanged:{
                if(active){
                    mainwindow.startSystemResize(Qt.RightEdge)
                }
            }
        }
    }

    MouseArea {
        id: resizeBottom
        y: 690
        height: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 10
        anchors.leftMargin: 10
        anchors.bottomMargin: 0
        cursorShape: Qt.SizeVerCursor

        DragHandler{
            target: null
            onActiveChanged:{
                if(active){
                    mainwindow.startSystemResize(Qt.BottomEdge)
                }
            }
        }
    }

}













/*##^##
Designer {
    D{i:0;formeditorZoom:0.5}
}
##^##*/
