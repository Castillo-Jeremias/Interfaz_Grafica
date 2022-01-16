import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3
import "../controls"

Page{
    id: id_setting_page

    Rectangle {
        id: backGroundPage
        color: "#3b0b07"
        anchors.fill: parent
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0

        Rectangle {
            id: backGroundSettingTracking
            radius: 15
            implicitWidth: 541
            implicitHeight:  588
            color: "#ffffff"
            anchors.left: parent.left
            anchors.right: backGroundNumber1.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.rightMargin: 44
            anchors.leftMargin: 20
            anchors.topMargin: 10
            anchors.bottomMargin: 10

            Rectangle {
                id: containerComandosToShow
                color: "#ffffff"
                anchors.fill: parent
                anchors.rightMargin: 3
                anchors.leftMargin: 3
                anchors.bottomMargin: 3
                anchors.topMargin: 3

                ScrollView {
                    id: scrollViewVentanaComandosToShow
                    anchors.fill: parent
                    font.pointSize: 15
                    font.italic: true
                    TextEdit{
                        id: ventanaComandosToShow
                        anchors.fill: parent
                        cursorVisible: true

                        selectionColor: "#8c8c8c"
                        selectByMouse: true
                        clip: true

                        font.italic: true
                        font.pointSize: 10

                        readOnly: true
                    }
                }

            }
        }

        Rectangle {
            id: backGroundNumber1
            color: "#ffffff"
            implicitHeight: 280
            implicitWidth: 588
            radius:15

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 605
            anchors.topMargin: 10
            anchors.rightMargin: 25


            CustomComboBox{ x: 37;y: 47;width: 200 ;height: 30}

            Label {
                id: label
                x: 8
                y: 8
                text: qsTr("Configuración - Puerto Serie")
                font.italic: true
                font.bold: true
                font.pointSize: 20
            }

            Button {
                id: button
                x: 78
                y: 92
                text: qsTr("Cargar configuración")
            }

            ComboBox {
                id: mycomboBoxTest
                x: 278
                y: 47

                contentItem: Item{
                    id: item1
                    Text{
                        id: textmycomboBoxTest
                        y: 0
                        visible: true
                        text: mycomboBoxTest.currentText
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        color: "#ffffff"
                        font.pointSize: 12
                        anchors.leftMargin: 10
                    }
                }
                model: ListModel{
                    id: listModeltmycomboBoxTest
                    ListElement{
                        text: "jere"
                    }
                    }
                }
            }
        }

        Rectangle {
            id: backGroundNumber2
            color: "#ffffff"

            implicitHeight: 280
            implicitWidth: 588
            radius:15

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 318
            anchors.leftMargin: 605
            anchors.bottomMargin: 10
            anchors.rightMargin: 25
        }

    Connections{
        target: backendPython
        //recordar la preposicion on delante de la funcion

        /*function onCleanLogAvalible(){
            ventanaLog.clear()
        }
        */
        function onSetPortCOM(COM_Data){

        }
    }
}





/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.5;height:608;width:1218}D{i:4;invisible:true}
}
##^##*/
