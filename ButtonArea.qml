import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls

Item {
    width: 600
    height: 200
    id: buttonArea
    property bool pathReady: false
    property bool hullReady: false
    property bool weightReady: false
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 2
        radius: 5
    }
    Column {
        y: 10
        spacing: 10
        width: 500
        anchors.horizontalCenter: parent.horizontalCenter
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            Rectangle {
                y: 3
                width: 440
                height: 24
                border.width: 1
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    id: chosenPath
                    text: qsTr("-")
                }
                radius: 5
            }

            FolderDialog {
                id: folderChosen
                onAccepted: {
                    pathReady = false
                    chosenPath.text = currentFolder.toString(
                                ).substring(8) + '/'
                    recolorManager.setWorkPath(chosenPath.text)
                    pathReady = true
                    hullReady = false
                    weightReady = false
                    progressManager.readPath(chosenPath.text)
                }
            }
            Rectangle {
                id: choosePathButton
                width: 100
                height: 30
                color: "transparent"
                radius: 5
                border.width: 3
                border.color: choosePathButtonArea.pressed ? "#ececec" : "transparent"
                Rectangle {
                    width: 94
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    border.width: 1
                    radius: 5
                    color: pathReady ? "lawngreen" : "transparent"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("选择文件夹")
                }
                MouseArea {
                    id: choosePathButtonArea
                    anchors.fill: parent
                    onClicked: {
                        folderChosen.open()
                    }
                }
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            Column {
                spacing: 10
                Rectangle {
                    id: chooseMaskButton
                    width: 100
                    height: 30
                    color: "transparent"
                    radius: 5
                    border.width: 3
                    border.color: chooseMaskButtonArea.pressed ? "#ececec" : "transparent"
                    Rectangle {
                        width: 94
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        border.width: 1
                        radius: 5
                        color: "transparent"
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("选项")
                    }
                    MouseArea {
                        id: chooseMaskButtonArea
                        anchors.fill: parent
                        onClicked: {
                            optionWindow.visible = true
                        }
                    }
                }
                Rectangle {
                    id: optionButton
                    width: 100
                    height: 30
                    color: "transparent"
                    radius: 5
                    border.width: 3
                    border.color: optionButtonArea.pressed ? "#ececec" : "transparent"
                    Rectangle {
                        width: 94
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        border.width: 1
                        radius: 5
                        color: "transparent"
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("选择目标")
                    }
                    MouseArea {
                        id: optionButtonArea
                        anchors.fill: parent
                        onClicked: {
                            maskSelector.visible = true
                        }
                    }
                }
            }

            Column {
                spacing: 10
                Rectangle {
                    id: getHullButton
                    width: 100
                    height: 30
                    color: "transparent"
                    radius: 5
                    border.width: 3
                    border.color: getHullButtonArea.pressed ? "#ececec" : "transparent"
                    Rectangle {
                        width: 94
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        border.width: 1
                        radius: 5
                        color: hullReady ? "lawngreen" : "transparent"
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("计算凸包")
                    }
                    MouseArea {
                        id: getHullButtonArea
                        anchors.fill: parent
                        onClicked: {
                            if (pathReady) {
                                console.log("计算凸包")
                                recolorManager.useMaskAndGetConvexhull(
                                            vNum.value)
                            }
                        }
                    }
                }
                SpinBox {
                    id: vNum
                    height: 20
                    width: 40
                    from: 4
                    to: 10
                    visible: false
                    //                        value: 6
                    //                        editable: true
                    contentItem: TextInput {
                        z: 2
                        text: vNum.textFromValue(vNum.value, vNum.locale)
                        font: vNum.font
                        selectionColor: "#21be2b"
                        selectedTextColor: "#ffffff"
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        //                                width: 20
                        readOnly: !vNum.editable
                        validator: vNum.validator
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                    }

                    up.indicator: Rectangle {
                        z: 5
                        x: parent.width - width
                        height: parent.height
                        implicitWidth: 10
                        implicitHeight: 10
                        color: vNum.up.pressed ? "#e4e4e4" : "#f6f6f6"
                        border.width: 1
                        radius: 5
                        Text {
                            text: "+"
                            font.pixelSize: vNum.font.pixelSize * 2
                            anchors.fill: parent
                            fontSizeMode: Text.Fit
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                vNum.increase()
                            }
                        }
                    }

                    down.indicator: Rectangle {
                        z: 5
                        x: 0
                        height: parent.height
                        implicitWidth: 10
                        implicitHeight: 10
                        color: vNum.down.pressed ? "#e4e4e4" : "#f6f6f6"
                        border.width: 1
                        radius: 5
                        Text {
                            text: "-"
                            font.pixelSize: vNum.font.pixelSize * 2
                            anchors.fill: parent
                            fontSizeMode: Text.Fit
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                vNum.decrease()
                            }
                        }
                    }

                    background: Rectangle {
                        width: 40
                        border.width: 1
                        radius: 5
                    }
                    Component.onCompleted: {
                        vNum.value = 6
                    }
                    Connections {
                        target: optionWindow
                        function onChangeSpinBoxNum(num) {
                            vNum.value = num
                        }
                    }
                }
                Rectangle {
                    id: choseHullButton
                    width: 100
                    height: 30
                    color: "transparent"
                    radius: 5
                    border.width: 3
                    border.color: choseHullButtonArea.pressed ? "#ececec" : "transparent"
                    Rectangle {
                        width: 94
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        border.width: 1
                        radius: 5
                        color: hullReady ? "lawngreen" : "transparent"
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("选择凸包文件")
                    }
                    MouseArea {
                        id: choseHullButtonArea
                        anchors.fill: parent
                        onClicked: {
                            if (pathReady) {
                                console.log("选择凸包文件")
                                hullFile.open()
                            }
                        }
                    }
                    FileDialog {
                        id: hullFile
                        nameFilters: ["Js files (*.js)"]
                        onAccepted: {
                            recolorManager.readTetraPrime(currentFile.toString(
                                                              ).substring(8))
                        }
                    }
                }
            }

            Column {
                spacing: 10
                Rectangle {
                    id: getWeightsButton
                    width: 100
                    height: 30
                    color: "transparent"
                    radius: 5
                    border.width: 3
                    border.color: getWeightsButtonArea.pressed ? "#ececec" : "transparent"
                    Rectangle {
                        width: 94
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        border.width: 1
                        radius: 5
                        color: weightReady ? "lawngreen" : "transparent"
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("计算权重")
                    }
                    MouseArea {
                        id: getWeightsButtonArea
                        anchors.fill: parent
                        onClicked: {
                            if (hullReady) {
                                console.log("计算权重")
                                recolorManager.getWeights()
                            }
                        }
                    }
                }
                Rectangle {
                    id: chooseWeightsButton
                    width: 100
                    height: 30
                    color: "transparent"
                    radius: 5
                    border.width: 3
                    border.color: chooseWeightsButtonArea.pressed ? "#ececec" : "transparent"
                    Rectangle {
                        width: 94
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        border.width: 1
                        radius: 5
                        color: weightReady ? "lawngreen" : "transparent"
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("选择权重文件")
                    }
                    MouseArea {
                        id: chooseWeightsButtonArea
                        anchors.fill: parent
                        onClicked: {
                            if (hullReady) {
                                console.log("选择权重文件")
                                weightsFile.open()
                            }
                        }
                    }
                    FileDialog {
                        id: weightsFile
                        nameFilters: ["Numpy files (*.npy)"]
                        onAccepted: {
                            recolorManager.readWeightsDict(currentFile.toString(
                                                               ).substring(8))
                        }
                    }
                }
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            Rectangle {
                id: savePaletteButton
                width: 100
                height: 30
                color: "transparent"
                radius: 5
                border.width: 3
                border.color: savePaletteButtonArea.pressed ? "#ececec" : "transparent"
                Rectangle {
                    width: 94
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    border.width: 1
                    radius: 5
                    color: "transparent"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("保存调色板")
                }
                MouseArea {
                    id: savePaletteButtonArea
                    anchors.fill: parent
                    onClicked: {
                        if (hullReady) {
                            console.log("保存调色板")
                            savePalettePath.open()
                        }
                    }
                }
                FileDialog {
                    id: savePalettePath
                    fileMode: FileDialog.SaveFile
                    defaultSuffix: "npy"
                    onAccepted: {
                        paletteManager.saveRecolorPalette(currentFile.toString(
                                                              ).substring(8))
                    }
                }
            }
            Rectangle {
                id: readPaletteButton
                width: 100
                height: 30
                color: "transparent"
                radius: 5
                border.width: 3
                border.color: readPaletteButtonArea.pressed ? "#ececec" : "transparent"
                Rectangle {
                    width: 94
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    border.width: 1
                    radius: 5
                    color: "transparent"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("读取调色板")
                }
                MouseArea {
                    id: readPaletteButtonArea
                    anchors.fill: parent
                    onClicked: {
                        if (hullReady) {
                            console.log("读取调色板")
                            readPalettePath.open()
                        }
                    }
                }
                FileDialog {
                    id: readPalettePath
                    nameFilters: ["Numpy files (*.npy)"]
                    //                    defaultSuffix: "npy"
                    onAccepted: {
                        paletteManager.readRecolorPalette(currentFile.toString(
                                                              ).substring(8))
                    }
                }
            }
            Rectangle {
                id: recolorButton
                width: 100
                height: 30
                color: "transparent"
                radius: 5
                border.width: 3
                border.color: recolorButtonArea.pressed ? "#ececec" : "transparent"
                Rectangle {
                    width: 94
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    border.width: 1
                    radius: 5
                    color: "transparent"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("重着色")
                }
                MouseArea {
                    id: recolorButtonArea
                    anchors.fill: parent
                    onClicked: {
                        if (weightReady) {
                            console.log("重着色")
                            recolorManager.doRecolor()
                        }
                    }
                }
            }
        }
        Connections {
            target: recolorManager
            function onSucceedGetWeight() {
                weightReady = true
            }
            function onSucceedGetConvexhull() {
                hullReady = true
                weightReady = false
            }
            function onSucceedRecolor() {}
        }
    }
}
