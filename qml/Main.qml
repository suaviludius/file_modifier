import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic


ApplicationWindow {
    id: window
    width: 860
    height: 420
    visible: true
    title: qsTr("FIle XOR processor")

    property color mainColor: "#3c90a4"
    property color mainDarkColor: "#255a66"
    property color successColor: "#3fee85"
    property color errorColor: "#e95349"
    property color backgroundColor: "#3e4556"
    property color backgroundDarkColor: "#24272d"
    property color versionColor: "#757575"
    property color textColor: "white"

    color: backgroundDarkColor

    ColumnLayout {
        anchors.fill: parent
        spacing: 5
        Layout.alignment: Qt.AlignTop

        // Заголовок
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignTop
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
            //Layout.preferredHeight: 400
            Layout.alignment: Qt.AlignTop
            color: backgroundColor

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // -------- Путь для поиска файлов -------------
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 15
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
                        Layout.fillHeight: true
                        placeholderText: "Путь к файлу"

                        background: Rectangle {
                            radius: 10 // Sets corner radius
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
                        Layout.fillHeight: true
                        Layout.preferredWidth: 100
                        background: Rectangle {
                                        //implicitWidth: 100
                                        //implicitHeight: 40
                                        color: mainColor
                                        radius: 10 // Sets corner radius
                                    }

                        onClicked: backend.selectFolder()
                    }
                }
                Text { // Строка ошибки для пути
                    id: pathError
                    text: "Выберите папку для поиска файлов"
                    color: errorColor
                    font.pixelSize: 11
                    visible: false
                    //Layout.leftMargin: 30
                }

                // ---------- Маска файлов ----------
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 15
                    spacing: 10

                    Label {
                        text:  "Маска файлов:\t"
                        font.bold: true
                        font.pixelSize: 14
                        //Layout.preferredWidth: 120
                        //color: maskField.text === "" ? errorColor : textColor
                    }

                    TextField {
                        id: maskField
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        placeholderText: "*.txt или *.bin"

                        background: Rectangle {
                            radius: 10 // Sets corner radius
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
                    font.pixelSize: 11
                    visible: false
                }

                // ---------- Путь для сохранения ------------
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 15
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
                        Layout.fillHeight: true
                        placeholderText: "Папка для сохранения"

                        background: Rectangle {
                            radius: 10 // Sets corner radius
                            color: backgroundDarkColor
                        }

                        onTextChanged: {
                            outputError.visible = text === ""
                        }
                    }

                    Button {
                        text: "Обзор"
                        onClicked: backend.selectOutputFolder()
                        Layout.fillHeight: true
                        Layout.preferredWidth: 100
                        background: Rectangle {
                                        color: mainColor
                                        radius: 10 // Sets corner radius
                                    }
                    }
                }
                Text {
                    id: outputError
                    text: "Введите папку для сохранения файлов"
                    color: errorColor
                    font.pixelSize: 11
                    visible: false
                }

                // ----------- XOR значение -------------
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 15
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
                        Layout.fillHeight: true
                        placeholderText: "16 символов HEX, например, 1234567890ABCDEF"
                        //validator: RegExpValidator { свалидировать как-то }

                        background: Rectangle {
                            radius: 10 // Sets corner radius
                            color: backgroundDarkColor
                        }

                        onTextChanged: {
                            if (text.length === 16) {
                                xorError.visible = false
                            } else if (text.length > 0) {
                                xorError.text = "Нужно ровно 16 HEX символов"
                                xorError.visible = true
                            } else {
                                xorError.text = "Введите XOR значение"
                                xorError.visible = true
                            }
                        }
                    }
                }
                Text {
                    id: xorError
                    text: "Введите 16-символьное HEX значение"
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
                                       visible: testCheckBox.checked
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
                                       visible: testCheckBox.checked
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
                    spacing: 15

                    // TODO: Вынести дизайн кнопки в отдельный ui
                    Button {
                        id: startButton
                        text: "Начать"
                        Layout.fillWidth: true
                        //Layout.fillHeight: true
                        Layout.preferredWidth: 100
                        highlighted: true

                        enabled: validateInputs()

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

                        enabled: backend.isRunning()

                        background: Rectangle {
                                        color: mainColor
                                        radius: 8
                                    }

                        onClicked: {
                            if (backend.isPaused()) {
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
                        enabled: backend.isRunning() || backend.isPaused()

                        background: Rectangle {
                                        color: mainColor
                                        radius: 8
                                    }

                        onClicked: {
                            backend.stopProcessing()
                            pauseButton.text = "Пауза"
                        }
                    }
                }

                // ----------- Секция прогресса -----------
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    color: cardColor
                    radius: 8
                    border.color: mainDarkColor
                    border.width: 3

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                id: fileLabel
                                text: "Ожидание начала..."
                                font.pixelSize: 12
                                //color: textColor
                                Layout.fillWidth: true
                                //elide: Text.ElideMiddle
                            }

                            Text {
                                id: speedLabel
                                text: "0 MB/s"
                                font.pixelSize: 12
                                //color: textColor
                            }
                        }

                        ProgressBar {
                            id: progressBar
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: 0

                            background: Rectangle {
                                        color: backgroundColor
                                        radius: 4
                                        height: 15
                                        border.color: textColor
                                    }
                        }


                        RowLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft

                            Text {
                                id: progressLabel
                                text: "0%"
                                font.pixelSize: 14
                                font.bold: true
                                color: mainDarkColor
                                //Layout.fillWidth: true
                            }

                            // Text {
                            //     id: statusLabel
                            //     text: "Готов к работе"
                            //     //color: textColor
                            //     //Layout.alignment: Qt.AlignRight
                            // }
                        }

                        // Сообщение об ошибке валидации (всплывающее)
                        Text {
                            id: validationMessage
                            text: ""
                            color: errorColor
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            visible: false
                            Layout.fillWidth: true
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
}