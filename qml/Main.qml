import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Dialogs


ApplicationWindow {
    id: window
    width: 920
    height: 740
    visible: true
    title: qsTr("FIle XOR processor")

    property color mainColor: "#3c90a4"
    property color mainDarkColor: "#255a66"
    property color successColor: "#3fee85"
    property color errorColor: "#e95349"
    property color pauseColor: "#FF9800"
    property color backgroundColor: "#3e4556"
    property color backgroundDarkColor: "#24272d"
    property color versionColor: "#757575"
    property color textColor: "white"

    color: backgroundDarkColor

    // Создаем слоты на изменения свойств
    // Connections {
    //     target: backend

    //     // function onStatusChanged(status) {
    //     //     statusLabel.text = status
    //     //     statusLabel.color = status === "Running" ? successColor :
    //     //                        status === "Paused" ? pauseColor :
    //     //                        status === "Error" ? errorColor : textColor
    //     // }
    // }

    ColumnLayout {
        anchors.fill: parent
        //anchors.margins: 10
        //spacing: 10
        //Layout.alignment: Qt.AlignTop

        // Заголовок
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            //Layout.alignment: Qt.AlignTop
            color: mainDarkColor

            Text {
                text: "File XOR Processor"
                font.pixelSize: 14
                font.bold: true
                color: textColor
                anchors.centerIn: parent
            }
        }

        // Настройки
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            //Layout.preferredHeight: 300
            //Layout.alignment: Qt.AlignTop
            color: backgroundColor

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // -------- Путь для поиска файлов -------------
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Label {
                        text: "Входной файл:\t"
                        font.bold: true
                        font.pixelSize: 14
                        //Layout.preferredWidth: 120
                        //Layout.alignment: Qt.AlignTop
                        //color: pathField.text === "" ? errorColor : textColor
                    }

                    TextField {
                        id: pathField
                        Layout.fillWidth: true
                        //Layout.fillHeight: true
                        Layout.preferredHeight: 40
                        placeholderText: "Путь к файлу"

                        background: Rectangle {
                            radius: 8 // Sets corner radius
                            color: backgroundDarkColor
                        }

                        // Валидация на лету
                        onTextChanged: {
                            if (text === "") {
                                pathError.visible = true
                            } else {
                                pathError.visible = false
                            }
                        }
                    }

                    Button {
                        text: "Обзор"
                        //Layout.fillHeight: true
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40

                        background: Rectangle {
                                        //implicitWidth: 100
                                        //implicitHeight: 40
                                        color: mainColor
                                        radius: 8 // Sets corner radius
                                    }

                        onClicked: folderDialog.open()
                    }

                    FolderDialog {
                        id: folderDialog
                        title: qsTr("Выберите входную папку")

                        onAccepted: {
                            var cleanPath = folderDialog.selectedFolder.toString();
                            // Убираем префикс схемы, если он есть (а у меня он всегда есть)
                            if (cleanPath.startsWith("file:///")) {
                                // Для Windows (оставляем "C:/Folder") или Linux/macOS (оставляем "/home/user")
                                cleanPath = cleanPath.substring(8);
                            } else if (cleanPath.startsWith("file://")) {
                                cleanPath = cleanPath.substring(7);
                            }
                            // Декодируем пробелы и спецсимволы (например, %20 обратно в пробел)
                            pathField.text = decodeURIComponent(cleanPath);

                            checkPathExists(pathField.text, pathField, pathError)
                        }

                        onRejected: {
                            console.log("Пользователь отменил выбор папки")
                        }
                    }
                }
                Text { // Строка ошибки для пути
                    id: pathError
                    text: "Выберите папку для поиска файлов"
                    color: errorColor
                    font.pixelSize: 12
                    visible: false
                    //Layout.leftMargin: 30
                }

                // ---------- Маска файлов ----------
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Label {
                        text:  "Маска файлов:\t"
                        font.bold: true
                        font.pixelSize: 14
                        //Layout.preferredHeight: 40
                        //color: maskField.text === "" ? errorColor : textColor
                    }

                    TextField {
                        id: maskField
                        Layout.fillWidth: true
                        //Layout.fillHeight: true
                        Layout.preferredHeight: 40
                        placeholderText: "Например: txt, bin, hex, ..."

                        background: Rectangle {
                            radius: 8 // Sets corner radius
                            color: backgroundDarkColor
                        }

                        onTextChanged: {
                            maskError.visible = text === ""
                        }
                    }
                }
                Text {
                    id: maskError
                    text: "Введите маску файлов"
                    color: errorColor
                    font.pixelSize: 12
                    visible: false
                }

                // ---------- Путь для сохранения ------------
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Label {
                        text: "Результат:\t\t"
                        font.bold: true
                        font.pixelSize: 14
                        //Layout.preferredWidth: 120
                        //color: outputField.text === "" ? errorColor : textColor
                    }

                    TextField {
                        id: outputField
                        Layout.fillWidth: true
                        //Layout.fillHeight: true
                        Layout.preferredHeight: 40
                        placeholderText: "Папка для сохранения"

                        background: Rectangle {
                            radius: 8 // Sets corner radius
                            color: backgroundDarkColor
                        }

                        onTextChanged: {
                            outputError.visible = text === ""
                        }
                    }

                    Button {
                        text: "Обзор"
                        onClicked: outFolderDialog.open()
                        //Layout.fillHeight: true
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40
                        background: Rectangle {
                                        color: mainColor
                                        radius: 8 // Sets corner radius
                                    }
                    }

                    FolderDialog {
                        id: outFolderDialog
                        title: qsTr("Выберите выходную папку")

                        onAccepted: {
                            var cleanPath = folderDialog.selectedFolder.toString();
                            // Убираем префикс схемы, если он есть (а у меня он всегда есть)
                            if (cleanPath.startsWith("file:///")) {
                                // Для Windows (оставляем "C:/Folder") или Linux/macOS (оставляем "/home/user")
                                cleanPath = cleanPath.substring(8);
                            } else if (cleanPath.startsWith("file://")) {
                                cleanPath = cleanPath.substring(7);
                            }
                            // Декодируем пробелы и спецсимволы (например, %20 обратно в пробел)
                            outputField.text = decodeURIComponent(cleanPath);
                        }

                        onRejected: {
                            console.log("Пользователь отменил выбор папки")
                        }
                    }
                }
                Text {
                    id: outputError
                    text: "Введите папку для сохранения файлов"
                    color: errorColor
                    font.pixelSize: 12
                    visible: false
                }

                // ----------- XOR значение -------------
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Label {
                        text: "XOR значение:\t"
                        font.bold: true
                        font.pixelSize: 14
                        //Layout.preferredWidth: 120
                        //color: xorField.text === "" ? errorColor : textColor
                    }

                    TextField {
                        id: xorField
                        Layout.fillWidth: true
                        //Layout.fillHeight: true
                        Layout.preferredHeight: 40
                        placeholderText: "16 символов HEX, например, 1234567890ABCDEF"
                        //validator: RegExpValidator { свалидировать как-то }

                        background: Rectangle {
                            radius: 8 // Sets corner radius
                            color: backgroundDarkColor
                        }

                        onTextChanged: {
                            // Регулярное выражение для HEX символов (0-9, A-F, a-f)
                            var hexPattern = /^[0-9A-Fa-f]+$/

                            if (text.length === 16 && hexPattern.test(text)) {
                                xorError.visible = false
                                xorError.text = ""
                            } else if (text.length > 0) {
                                if (text.length !== 16) {
                                    xorError.text = "Нужно ровно 16 HEX символов (сейчас " + text.length + ")"
                                } else if (!hexPattern.test(text)) {
                                    // Находим первый недопустимый символ
                                    xorError.text = "Обнаружены недопустимые символы (разрешены 0-9, A-F)"
                                }
                                xorError.visible = true
                            } else {
                                xorError.text = "Введите XOR значение (16 HEX символов)"
                                xorError.visible = true
                            }
                        }
                    }
                }
                Text {
                    id: xorError
                    text: "Введите XOR значение (16 HEX символов)"
                    color: errorColor
                    font.pixelSize: 11
                    visible: false
                }

                // ---------- Дополнительные настройки ----------------
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    spacing: 20

                    Label {
                        text: "Настройки:\t\t"
                        font.bold: true
                        font.pixelSize: 14
                        //Layout.preferredWidth: 120
                        //color: xorField.text === "" ? errorColor : textColor
                    }
                    CheckBox {
                        id: deleteCheckBox
                        text: "Удалять исходные файлы"
                        checked: false

                        // Дизайн
                        indicator: Rectangle {
                                    color: backgroundDarkColor
                                    y: deleteCheckBox.height / 2 - height / 2
                                    implicitWidth: 25
                                    implicitHeight: 25
                                    radius: 8

                                    Rectangle {
                                       color: deleteCheckBox.checked ? mainColor : backgroundColor
                                       //visible: deleteCheckBox.checked
                                       width: parent.width / 1.5
                                       height: parent.height / 1.5
                                       x: parent.width / 2 - width / 2
                                       y: parent.height / 2 - height / 2
                                       radius: 4
                                    }
                                }

                    }
                    CheckBox {
                        id: timerCheckBox
                        text: "Работа по таймеру"
                        checked: false

                        // Дизайн
                        indicator: Rectangle {
                                    color: backgroundDarkColor
                                    y: timerCheckBox.height / 2 - height / 2
                                    implicitWidth: 25
                                    implicitHeight: 25
                                    radius: 8

                                    Rectangle {
                                       color: timerCheckBox.checked ?  mainColor : backgroundColor
                                       //visible: timerCheckBox.checked
                                       width: parent.width / 1.5
                                       height: parent.height / 1.5
                                       x: parent.width / 2 - width / 2
                                       y: parent.height / 2 - height / 2
                                       radius: 4
                                    }
                                }
                    }
                    Item{ Layout.fillWidth: true }
                    // Интервал для периода
                    RowLayout {
                        // TODO: что лучше оставить enable ~ visible: ?
                        visible: timerCheckBox.checked
                        spacing: 20

                        Label {
                            text: "Интервал (сек):"
                            font.bold: true
                            font.pixelSize: 14
                        }

                        SpinBox {
                            id: intervalSpinBox
                            from: 5
                            to: 3600
                            value: 60
                            editable: true

                            background: Rectangle {
                                implicitWidth: 140
                                color: backgroundDarkColor
                                border.color: backgroundDarkColor
                                border.width: 4
                            }
                        }
                    }
                }

                // --------- Кнопки управления -----------------
                RowLayout {
                    Layout.fillWidth: true
                    //Layout.fillHeight: true
                    Layout.preferredHeight: 20
                    spacing: 10

                    // TODO: Вынести дизайн кнопки в отдельный ui
                    Button {
                        id: startButton
                        text: "Начать"
                        Layout.fillWidth: true
                        //Layout.fillHeight: true
                        Layout.preferredWidth: 100
                        highlighted: true

                        enabled: true // validateInputs()

                        // Дизайн текста
                        contentItem: Text {
                                text: parent.text
                                font.bold: true
                                font.pixelSize: 14
                                color: textColor // Установка цвета текста
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                        // Дизайн кнопки
                        background: Rectangle {
                                        color: mainDarkColor
                                        radius: 8 // Sets corner radius
                                        border.color: textColor
                                    }

                        // По нажатию передаем конфигурацию в бекенд
                        onClicked: {
                            if (validateInputs()) {
                                backend.startProcessing(
                                    pathField.text,
                                    maskField.text,
                                    outputField.text,
                                    xorField.text,
                                    deleteCheckBox.checked,
                                    timerCheckBox.checked,
                                    intervalSpinBox.value
                                )
                            }
                        }
                    }

                    Button {
                        id: pauseButton
                        text: "Пауза"
                        font.pixelSize: 14
                        Layout.fillWidth: true
                        Layout.preferredWidth: 100

                        enabled: backend.isRunning

                        background: Rectangle {
                                        color: mainColor
                                        radius: 8
                                    }

                        onClicked: {
                            if (backend.isPaused) {
                                backend.resume()
                                pauseButton.text = "Пауза"
                            } else {
                                backend.pause()
                                pauseButton.text = "Продолжить"
                            }
                        }
                    }

                    Button {
                        id: stopButton
                        text: "Стоп"
                        font.pixelSize: 14
                        Layout.preferredWidth: 100
                        Layout.fillWidth: true

                        // Добавляем условия для активности кнопки
                        enabled: backend.isRunning || backend.isPaused

                        background: Rectangle {
                                        color: mainColor
                                        radius: 8
                                    }

                        onClicked: {
                            //backend.stopProcessing()
                            pauseButton.text = "Пауза"
                        }
                    }
                }

                // ----------- Секция прогресса -----------
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: "transparent"
                    radius: 8
                    //border.color: mainDarkColor
                    //border.width: 3

                    ColumnLayout {
                        anchors.fill: parent
                        //anchors.margins: 20
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                id: fileLabel
                                text: backend.currentFile || "Ожидание начала ..."
                                font.pixelSize: 12
                                color: textColor
                                Layout.fillWidth: true
                                //elide: Text.ElideMiddle
                            }

                            Text {
                                id: speedLabel
                                text: backend.speed.toFixed(1) + " MB/s"
                                font.pixelSize: 12
                                color: textColor
                            }
                        }

                        ProgressBar {
                            id: progressBar
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: backend.progress

                            // Кастомизация фона
                            background: Rectangle {
                                implicitWidth: 200
                                implicitHeight: 20
                                color: backgroundColor
                                border.color: textColor
                                radius: 8
                            }

                            contentItem: Item {
                                    implicitWidth: 200
                                    implicitHeight: 20

                                    Rectangle {
                                        width: progressBar.visualPosition * parent.width
                                        height: parent.height
                                        color: mainColor // Цвет полосы прогресса (зеленый)
                                        radius: 8
                                    }
                                    Text {
                                        width: parent.width
                                        text: Math.round(progressBar.value) + "%"
                                        color: textColor
                                        font.pixelSize: 14
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                            // background: Rectangle {
                            //             color: backgroundColor
                            //             radius: 4
                            //             height: 25
                            //             border.color: textColor
                            //         }

                            // contentItem: Text {
                            //     text: Math.round(progressBar.value) + "%"
                            //     color: mainColor
                            //     font.pixelSize: 14
                            //     font.bold: true
                            //     horizontalAlignment: Text.AlignHCenter
                            //     verticalAlignment: Text.AlignVCenter
                            // }
                        }


                        // RowLayout {
                        //     Layout.fillWidth: true
                        //     Layout.alignment: Qt.AlignLeft

                        //     Text {
                        //         id: progressLabel
                        //         text: "0%"
                        //         font.pixelSize: 14
                        //         font.bold: true
                        //         color: mainDarkColor
                        //         //Layout.fillWidth: true
                        //     }

                        //     Text {
                        //         id: statusLabel
                        //         text: "Готов к работе"
                        //         //color: textColor
                        //         //Layout.alignment: Qt.AlignRight
                        //     }
                        // }

                        // Сообщение об ошибке валидации (всплывающее)
                        // Text {
                        //     id: validationMessage
                        //     text: ""
                        //     color: errorColor
                        //     font.pixelSize: 12
                        //     wrapMode: Text.WordWrap
                        //     visible: false
                        //     Layout.fillWidth: true
                        // }
                    }
                }

                // -------- Лог консоль ----------
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    //Layout.preferredHeight: 80
                    color: backgroundDarkColor
                    radius: 8
                    //border.color: mainColor
                    //border.width: 1

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true

                        ColumnLayout {
                            spacing: 2

                            Repeater {
                                model: backend.logMessages

                                Text {
                                    text: modelData
                                    font.pixelSize: 14
                                    color: textColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }

            }

            // RowLayout {
            //     anchors.fill: parent
            //     anchors.leftMargin: 10
            //     spacing: 10
            //     Layout.alignment: Qt.AlignHCenter

            //     Image {
            //         source: "qrc:/icons/white/folder.svg"
            //         //width: 50
            //         //height: 60
            //         //Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            //         //Layout.bottomMargin: 20
            //         fillMode: Image.PreserveAspectFit
            //     }
            // }

        }
    }

    // Функция валидации всех полей
    function validateInputs() {
        var valid = true
        //var errors = []

        // Проверка пути
        if (pathField.text === "") {
            pathError.visible = true
            pathError.text = "Путь поиска не указан"
            valid = false
        } else if(!backend.checkPathExists(pathField.text)){
            pathError.text = "Путь поиска не существует"
            pathError.visible = true
            valid = false
        }

        // Проверка маски
        if (maskField.text === "") {
            maskError.visible = true
            //errors.push("Маска файлов не указана")
            valid = false
        }

        // Проверка пути сохранения
        if (outputField.text === "") {
            outputError.visible = true
            outputError.text = "Путь сохранения не указан"
            valid = false
        } else if(!backend.checkPathExists(outputField.text)){
            outputError.text = "Путь сохранения не существует"
            outputError.visible = true
            valid = false
        }

        // Проверка XOR значения
        if (xorField.text.length !== 16) {
            xorError.visible = true
            //errors.push("XOR значение должно быть 16 HEX символов")
            valid = false
        }

        // Показываем общую ошибку
        // if (!valid) {
        //     validationMessage.text = errors.join("; ")
        //     validationMessage.visible = true
        //     // Скрываем через 3 секунд
        //     hideValidationTimer.restart()
        // } else {
        //     validationMessage.visible = false
        // }
        return valid
    }

    // Таймер для скрытия сообщения
    // Timer {
    //     id: hideValidationTimer
    //     interval: 3000
    //     running: false
    //     repeat: false
    //     onTriggered: {
    //         validationMessage.visible = false
    //     }
    // }
}


