pragma Singleton
import QtQuick

QtObject {

    // ----- Цветовая палитра -----

    // Фоновые цвета (Backgrounds)
    readonly property color backgroundDark:  "#24272d" // Самый глубокий фон (окно, поля ввода)
    readonly property color backgroundLight: "#3e4556" // Контейнеры, карточки настроек

    // Основные цвета
    readonly property color primary:          "#3c90a4" // Главный цвет (кнопки, активные элементы)
    readonly property color primaryDark:      "#255a66" // Для состояния Pressed (нажато)

    // Статусные цвета
    readonly property color statusSuccess:    "#3fee85" // Процесс завершен успешно
    readonly property color statusError:      "#e95349" // Ошибка (неверный путь, сбой XOR)
    readonly property color statusWarning:    "#FF9800" // Процесс на паузе

    // Текст (Typography Colors)
    readonly property color textMain:         "white"   // Основной читаемый текст
    readonly property color textMuted:        "#757575" // Подписи, версии, плейсхолдеры

    // Границы фигур
    readonly property color itemBorder:        "white"  // Граница объектов (кнопки, поля, ректанглы, ...)

    // ----- Размеры и отступы по умолчанию -----

    // Скругления углов (Border Radius)
    readonly property real  radiusStandard:   8.0
    readonly property real  radiusSmall:      4.0

    // Размеры элементов управления по умолчанию
    readonly property real  controlHeight:    35.0
    readonly property real  buttonWidth:      140.0

    // Стандартные отступы (Spacing & Margins)
    readonly property real  spacingSmall:     10.0
    readonly property real  spacingNormal:    15.0
    readonly property real  paddingMain:      20.0
    readonly property real  marginMain:       20.0

    // ----- Шрифты (Typography) -----

    // Настройки для заголовков
    readonly property font  fontHeader: Qt.font({
        family: "Segoe UI", // Или стандартный системный
        pixelSize: 14,
        bold: true
    })

    // Настройки для обычного текста / лейблов
    readonly property font  fontBody: Qt.font({
        family: "Segoe UI",
        pixelSize: 14,
        bold: false
    })

    // Настройки для мелких ошибок или подсказок
    readonly property font  fontCaption: Qt.font({
        family: "Segoe UI",
        pixelSize: 12,
        bold: false
    })
}
