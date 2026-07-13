import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic


Button {
    id: control

    Layout.preferredWidth: Theme.buttonWidth
    Layout.preferredHeight: Theme.controlHeight

    contentItem: Text {
        text: control.text
        font: Theme.fontHeader
        color: control.enabled ? Theme.textMain : Qt.darker(Theme.textMain, 1.5)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        color: control.enabled ? (control.down ? Theme.primary : (control.hovered ? Qt.lighter(Theme.primaryDark, 1.1) : Theme.primaryDark)) : Qt.darker(Theme.primaryDark, 1.5)
        radius: Theme.radiusStandard
        border.color: Theme.itemBorder

        Behavior on color { ColorAnimation { duration: 120 } }
    }
}
