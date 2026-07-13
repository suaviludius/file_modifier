import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic


CheckBox {
    id: control
    checked: false
    text: ""

    indicator: Rectangle {
        color: Theme.backgroundDark
        y: control.height / 2 - height / 2
        implicitWidth: 25
        implicitHeight: 25
        radius: 8

        Rectangle {
            color: control.checked ? Theme.primary : Theme.backgroundLight
            width: parent.width / 1.5
            height: parent.height / 1.5
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height / 2
            radius: 4
        }
    }

}