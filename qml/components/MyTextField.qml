import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic


TextField {
    id: control

    Layout.fillWidth: true
    Layout.preferredHeight: Theme.controlHeight

    background: Rectangle {
        radius: Theme.radiusStandard
        color: Theme.backgroundDark
    }
}