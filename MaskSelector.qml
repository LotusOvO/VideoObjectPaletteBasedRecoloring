import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls

Window {
    width: 500
    height: 300
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    id: maskSelector
    Rectangle{
        anchors.fill: parent
        border.width: 3
        radius: 15
    }
    Rectangle{
        x: 20
        y: 20
        width: 360
        height: 200
        border.width: 1
        radius: 10
        Image{
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: 350
            height: 190
            id: mask
            source: ""
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    selectedPos.x = mouseX
                    selectedPos.y = mouseY
                    selectedPos.visible = true
                    maskManager.setPos(selectedPos.x/mask.width, selectedPos.y/mask.height)
                }
            }
            Rectangle{
                id: selectedPos
                visible: false
                width: 10
                height: width
                radius: 5
                color: "transparent"
                border.width: 2
            }
        }
    }

    Rectangle{
        y: 40
        x: 360
        width: 140
        Column{
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 15
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
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("选择Mask文件")
                }
                MouseArea {
                    id: chooseMaskButtonArea
                    anchors.fill: parent
                    onClicked: {
                        maskFile.open()
                    }
                }
            }
            Rectangle{
                width: 100
                height: 30
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle{
                    x: 10
                    width: 25
                    height: 25
                    radius: 15
                    id: maskColor
//                    color: "transparent"
                    color: "black"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text{
                    x: maskColor.x + maskColor.width + 10
                    text: maskColor.color
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: qsTr("选中颜色")
                    x: maskColor.x - 5
                    y: maskColor.height
                    font.pixelSize : 10

                }
            }
            Rectangle {
                id: resetMaskButton
                width: 100
                height: 30
                color: "transparent"
                radius: 5
                border.width: 3
                border.color: resetMaskButtonArea.pressed ? "#ececec" : "transparent"
                Rectangle {
                    width: 94
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    border.width: 1
                    radius: 5
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("重置")
                }
                MouseArea {
                    id: resetMaskButtonArea
                    anchors.fill: parent
                    onClicked: {
                        selectedPos.visible = false
                        maskManager.resetMask()
                    }
                }
            }
            Rectangle {
                id: acButton
                width: 100
                height: 30
                color: "transparent"
                radius: 5
                border.width: 3
                border.color: acButtonArea.pressed ? "#ececec" : "transparent"
                Rectangle {
                    width: 94
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    border.width: 1
                    radius: 5
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("确认")
                }
                MouseArea {
                    id: acButtonArea
                    anchors.fill: parent
                    onClicked: {
                        maskSelector.visible = false
                    }
                }
            }
        }
    }


    FileDialog{
        id: maskFile
        onAccepted: {
            mask.source = currentFile
            maskManager.readImage(currentFile.toString().substring(8))
        }
    }

    Connections{
        target: maskManager
        function onSetObjectColor(color){
            maskColor.color = color
        }
        function onUnsetObjectColor(){
            maskColor.color = "black"
        }
    }
}
