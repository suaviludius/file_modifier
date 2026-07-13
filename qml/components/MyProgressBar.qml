import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

ProgressBar {
    id: control
    Layout.fillWidth: true
    height: Theme.controlHeight * 0.8

    // Фон
    background: Rectangle {
        color: Theme.backgroundDark
        //border.color: Theme.itemBorder
        radius: Theme.radiusStandard
    }

    // Элемент загрузки
    contentItem: Item {
        // Полоса прогресса
        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: Theme.primary
            radius: Theme.radiusStandard
        }

        // Дополнительный текст (обновляется с прогрессом)
        Text {
            width: parent.width
            height: parent.height
            text: Math.round(control.value) + "%"
            color: Theme.textMain
            font: Theme.fontHeader
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}