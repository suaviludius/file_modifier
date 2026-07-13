import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Dialogs

//import "views"
import "components"
import "theme"

ApplicationWindow {
    id: window
    width: 920
    height: 740
    visible: true
    title: qsTr("FIle XOR processor")

    color: Theme.backgroundDark

    ColumnLayout {
        anchors.fill: parent

        // ----- Заголовок -----
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.controlHeight
            color: Theme.primaryDark

            Text {
                text: "File XOR Processor"
                font: Theme.fontHeader
                color: Theme.textMain
                anchors.centerIn: parent
            }
        }

        // ----- Настройки -----
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.backgroundLight

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.marginMain
                spacing: Theme.spacingNormal

                // ----- Путь для поиска файлов -----
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSmall

                    Label {
                        text: "Входной файл:\t"
                        font: Theme.fontHeader
                    }

                    MyTextField {
                        id: pathField
                        placeholderText: "Путь к файлу"

                        // Валидация на лету
                        onTextChanged: {
                            if (text === "") {
                                pathError.visible = true
                            } else {
                                pathError.visible = false
                            }
                        }
                    }

                    MyButton  {
                        text: "Обзор"
                        onClicked: {
                            folderDialog.targetField = pathField;
                            folderDialog.open();
                        }
                    }
                }
                // Строка ошибки для пути
                Text {
                    id: pathError
                    text: "Выберите папку для поиска файлов"
                    color: Theme.statusError
                    font: Theme.fontCaption
                    visible: false
                }

                // ----- Маска файлов -----
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSmall

                    Label {
                        text:  "Маска файлов:\t"
                        font: Theme.fontHeader
                    }

                    MyTextField {
                        id: maskField
                        placeholderText: "Например: *.txt, *.bin, *.hex, ..."

                        onTextChanged: {
                            maskError.visible = text === ""
                        }
                    }
                }
                // Строка ошибки для пути
                Text {
                    id: maskError
                    text: "Введите маску файлов"
                    color: Theme.statusError
                    font: Theme.fontCaption
                    visible: false
                }

                // ----- Путь для сохранения -----
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSmall

                    Label {
                        text: "Результат:\t\t"
                        font: Theme.fontHeader
                    }

                    MyTextField {
                        id: outputField
                        placeholderText: "Папка для сохранения"

                        onTextChanged: {
                            outputError.visible = text === ""
                        }
                    }

                    MyButton {
                        text: "Обзор"
                        onClicked: {
                            folderDialog.targetField = outputField;
                            folderDialog.open();
                        }
                    }
                }
                // Строка ошибки для пути
                Text {
                    id: outputError
                    text: "Введите папку для сохранения файлов"
                    color: Theme.statusError
                    font: Theme.fontCaption
                    visible: false
                }

                // ----- XOR значение -----
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSmall

                    Label {
                        text: "XOR значение:\t"
                        font: Theme.fontHeader
                    }

                    MyTextField {
                        id: xorField
                        placeholderText: "16 символов HEX, например, 1234567890ABCDEF"

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
                // Строка ошибки для пути
                Text {
                    id: xorError
                    text: "Введите XOR значение (16 HEX символов)"
                    color: Theme.statusError
                    font: Theme.fontCaption
                    visible: false
                }

                // ----- Дополнительные настройки -----
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.controlHeight
                    spacing: Theme.spacingNormal

                    Label {
                        text: "Настройки:\t\t"
                        font: Theme.fontHeader
                    }

                    MyCheckBox {
                        id: deleteCheckBox
                        text: "Удалять исходные файлы"
                        checked: false
                    }

                    MyCheckBox {
                        id: timerCheckBox
                        text: "Работа по таймеру"
                        checked: false
                    }

                    MyCheckBox {
                        id: overwriteCheckBox
                        text: "Перезапись выходных файлов"
                        checked: true
                    }
                }

                // ----- Интервал для периода -----
                RowLayout {
                    visible: timerCheckBox.checked
                    spacing: Theme.spacingSmall

                    Label {
                        text: "Интервал (сек):\t"
                        font: Theme.fontHeader
                    }

                    SpinBox {
                        id: intervalSpinBox
                        from: 5
                        to: 300
                        value: 60
                        editable: true

                        background: Rectangle {
                            implicitWidth: Theme.buttonWidth
                            color: Theme.backgroundDark
                        }
                    }
                }

                // ----- Секция прогресса -----
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.controlHeight * 2 + Theme.spacingNormal
                    color: "transparent"
                    radius: Theme.radiusStandard

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Theme.spacingSmall

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                id: fileLabel
                                text: backend.currentFile || "Ожидание начала ..."
                                font: Theme.fontCaption
                                color: Theme.textMuted
                                Layout.fillWidth: true
                            }

                            // ----- Кнопки управления -----
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Theme.controlHeight
                                spacing: Theme.spacingNormal

                                MyButton {
                                    id: startButton
                                    text: "Начать"
                                    enabled: !backend.isRunning

                                    // По нажатию передаем конфигурацию в бекенд
                                    onClicked: {
                                        if (validateInputs() && !backend.isRunning) {
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

                                MyButton {
                                    id: pauseButton
                                    text: "Пауза"
                                    enabled: backend.isRunning

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

                                MyButton {
                                    id: stopButton
                                    text: "Стоп"
                                    enabled: backend.isRunning || backend.isPaused

                                    onClicked: {
                                        backend.stopProcessing()
                                        pauseButton.text = "Пауза"
                                    }
                                }
                            }

                            // Text {
                            //     id: speedLabel
                            //     text: backend.speed.toFixed(1) + " MB/s"
                            //     font.pixelSize: 12
                            //     color: Theme.textMain
                            // }
                        }

                        MyProgressBar {
                            id: progressBar
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: backend.progress
                        }
                    }
                }

                // ----- Лог консоль -----
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Theme.backgroundDark
                    radius: Theme.radiusStandard

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: Theme.marginMain
                        clip: true

                        ColumnLayout {
                            Repeater {
                                model: backend.logMessages

                                Text {
                                    text: modelData
                                    font.pixelSize: 14
                                    color: Theme.textMain
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }
        // ---- Конец настроек ----
    }
    // ---- Конец объектов окна ----


    // Функция валидации всех полей
    function validateInputs() {
        var valid = true

        // Проверка пути
        if (pathField.text === "") {
            pathError.visible = true
            pathError.text = "Путь поиска не указан"
            valid = false
        } else if(!backend.checkPathExists(pathField.text)){
            pathError.text = "Путь поиска не существует"
            pathError.visible = true
            valid = false
        } else {
            pathError.visible = false
        }

        // Проверка маски
        if (maskField.text === "") {
            maskError.visible = true
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
        } else if(outputField.text == pathField.text){
            outputError.text = "Путь сохранения должен отличаться от пути поиска"
            outputError.visible = true
            valid = false
        } else {
            outputError.visible = false
        }

        // Проверка XOR значения
        if (xorField.text.length !== 16) {
            xorError.visible = true
            valid = false
        }
        return valid
    }

    // Диалог выбора папки при нажатии на кнопку "Обзор"
    FolderDialog {
        id: folderDialog
        title: qsTr("Выберите папку")

        property var targetField: null

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
            targetField.text = decodeURIComponent(cleanPath);

            checkPathExists(targetField.text, targetField, pathError)
        }

        onRejected: {
            console.log("Пользователь отменил выбор папки")
        }
    }
}


