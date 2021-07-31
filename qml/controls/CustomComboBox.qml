import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

ComboBox{
    property color btnDefault: "#1c1d20"
    property color btnMouseOver: "#23272E"
    property color btnColorClicked: "#00a1f1"
    visible: true

    id: btnComboBoxCustom
    implicitWidth:  120
    implicitHeight: 50

    QtObject{
        id:internal
        property var dynamicColor:
            if(btnComboBoxCustom.down){
                btnComboBoxCustom.down ? btnColorClicked : btnDefault
             }else{
                btnComboBoxCustom.hovered ? btnMouseOver: btnDefault
             }
    }

    background: Rectangle{
        id:backgroundComboBox
        color: internal.dynamicColor
        radius: 15
    }
    contentItem: Item{
        id: item1

        Text{
            id: textComboBox
            y: 0
            visible: true
            text: btnComboBoxCustom.currentText
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            color: "#ffffff"
            font.pointSize: 12
            anchors.leftMargin: 10
        }

    }
    model: ListModel{
        ListElement{
            text: "Sol"
        }
        ListElement{
            text: "Luna"
        }
        ListElement{
            text: "Jupiter"
        }
        ListElement{
            text: "Otros..."
        }
    }


}

/*##^##
Designer {
    D{i:0;formeditorZoom:1.66;height:50;width:150}
}
##^##*/
