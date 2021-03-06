import QtQuick 1.0

Item {
    id: root
    property int loadProgress: 0
    property alias text: inputLine.text
    signal accepted()
    signal textChanged()
    signal activeFocusChanged()
    height: inputArea.height + textInputOverlay.height + 2
    property alias cursorPosition: inputLine.cursorPosition
    property alias inputFocus: inputLine.focus
    property alias inputMethodHints: inputLine.inputMethodHints
    property bool setUrlCall: false
    property bool setBackspace: false
    property bool selectAllOnFocus: false
    property bool disableUnfocusOnAccept: false

    function setUrl(value) {
        if (!setBackspace) {
            root.setUrlCall = true
            var oldLength = inputLine.text.length
            inputLine.text = value
            inputLine.cursorPosition = 0
            inputLine.select(inputLine.text.length, oldLength)
        }
        else {
            setBackspace = false
        }
    }

    function setFocus(op) {
        if (op)
            inputLine.forceActiveFocus()
        else {
            inputLine.closeSoftwareInputPanel()
            inputLine.focus = false
            webViewport.forceActiveFocus()
        }
    }

    Item {
        id: inputArea
        anchors.top: root.top
        anchors.left: root.left
        anchors.right: root.right
        height: 40

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: parent.width / 100 * root.loadProgress
            radius: 10
            color: "cyan"
            opacity: 0.6
            visible: (root.loadProgress > 0) ? (root.loadProgress < 100 ? true : false) : false
            smooth: true
        }

        Rectangle {
            anchors.fill: parent

            color: "white"
            border.width: 1
            radius: 10
            smooth: true
            opacity: 0.6
        }

        TextInput {
            id: inputLine

            Timer {
                id: selectTimer
                interval: 500
                repeat: false
                onTriggered: {
                    inputLine.selectAll()
                }
            }

            autoScroll: true
            selectByMouse: true
            font {
                pixelSize: 26
                family: "Nokia Pure Text"
            }
            anchors.verticalCenter: inputArea.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 5

            onTextChanged: {
                if (!root.setUrlCall) {
                    root.textChanged()
                }
                if (setUrlCall) {
                    setUrlCall = false
                }
            }

            onActiveFocusChanged: {
                root.activeFocusChanged()
                if (activeFocus && selectAllOnFocus) {
                    selectTimer.start()
                }
            }

            Keys.onReturnPressed:{
                root.accepted()
                if (!disableUnfocusOnAccept) {
                    root.setFocus(false)
                }
            }

            Keys.onPressed: {
                if (event.key == Qt.Key_Backspace) {
                    setBackspace = true
                }
                else if (((event.modifiers & Qt.ControlModifier) && event.key == Qt.Key_L) || event.key == Qt.key_F6) {
                    root.setFocus(true)
                    event.accepted = true
                }
            }
        }
    }

    Row {
        id: textInputOverlay
        spacing: 3
        anchors.left: root.left
        anchors.right: root.right
        anchors.top: inputArea.bottom
        anchors.topMargin: 5
        visible: inputLine.focus
        height: visible ? 40 : 0

        OverlayButton {
            height: parent.height-3
            width: parent.width/3-2
            text: "Copy"
            onClicked: inputLine.copy()
        }

        OverlayButton {
            height: parent.height-3
            width: parent.width/3-2
            text: "Paste"
            enabled: inputLine.canPaste
            onClicked: inputLine.paste()
        }

        OverlayButton {
            height: parent.height-3
            width: parent.width/3-2
            text: "Select all"
            onClicked: inputLine.selectAll()
        }
    }
}
