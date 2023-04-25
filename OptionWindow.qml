import QtQuick
import QtQuick.Controls

Window {
    id: optionWindow
    width: 220
    height: 300
//    visible: true
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    signal changeSpinBoxNum(int num)
    Rectangle {
        anchors.fill: parent
        border.width: 3
        radius: 15
        Column {
            y: 10
            x: parent.x + 10
            spacing: 10
            Rectangle {
                x: parent.width / 2 - width / 2
                height: 20
                width: 200
                color: "transparent"
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr("选项")
                    font.pixelSize: 18
                }
            }

            CheckBox {
                id: enableWeightsDict
                text: qsTr("使用WeightsDict计算权重")
                checked: true
                hoverEnabled: false
                onClicked: {
                    recolorManager.setUsingWeightsDict(enableWeightsDict.checked)
                }

                indicator: Rectangle {
                    implicitWidth: 20
                    implicitHeight: 20
                    x: enableWeightsDict.leftPadding
                    y: parent.height / 2 - height / 2
                    radius: 3
                    border.color: "black"

                    Rectangle {
                        width: 12
                        height: 12
                        x: 4
                        y: 4
                        radius: 2
                        color: "black"
                        visible: enableWeightsDict.checked
                    }
                }

                contentItem: Text {
                    text: enableWeightsDict.text
                    font: enableWeightsDict.font
                    opacity: enabled ? 1.0 : 0.3
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: enableWeightsDict.indicator.width + enableWeightsDict.spacing
                }
            }

            CheckBox {
                id: enableRecolorAgain
                text: qsTr("使用已重着色视频作为输入视频")
                checked: false
                hoverEnabled: false
                onClicked: {
                    recolorManager.setRecolorAgain(enableRecolorAgain.checked)
                }

                indicator: Rectangle {
                    implicitWidth: 20
                    implicitHeight: 20
                    x: enableRecolorAgain.leftPadding
                    y: parent.height / 2 - height / 2
                    radius: 3
                    border.color: "black"

                    Rectangle {
                        width: 12
                        height: 12
                        x: 4
                        y: 4
                        radius: 2
                        color: "black"
                        visible: enableRecolorAgain.checked
                    }
                }

                contentItem: Text {
                    text: enableRecolorAgain.text
                    font: enableRecolorAgain.font
                    opacity: enabled ? 1.0 : 0.3
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: enableRecolorAgain.indicator.width + enableRecolorAgain.spacing
                }
            }

            CheckBox {
                id: enableAutoConvertVideo
                text: qsTr("自动生成重着色视频")
                checked: true
                hoverEnabled: false
                onClicked: {
                    recolorManager.setConvertVideo(enableAutoConvertVideo.checked)
                }

                indicator: Rectangle {
                    implicitWidth: 20
                    implicitHeight: 20
                    x: enableAutoConvertVideo.leftPadding
                    y: parent.height / 2 - height / 2
                    radius: 3
                    border.color: "black"

                    Rectangle {
                        width: 12
                        height: 12
                        x: 4
                        y: 4
                        radius: 2
                        color: "black"
                        visible: enableAutoConvertVideo.checked
                    }
                }

                contentItem: Text {
                    text: enableAutoConvertVideo.text
                    font: enableAutoConvertVideo.font
                    opacity: enabled ? 1.0 : 0.3
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: enableAutoConvertVideo.indicator.width
                                 + enableAutoConvertVideo.spacing
                }
            }

            Row {
                Rectangle{
                    color: "transparent"
                    height: 20
                    width: 10
                }

                SpinBox {
                    id: vNum
                    height: 20
                    width: 60
                    from: 4
                    to: 10
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
                        implicitWidth: 20
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
                        implicitWidth: 20
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
                        implicitWidth: 60
                        border.width: 1
                        radius: 5
                    }
                    onValueChanged: {
                        changeSpinBoxNum(vNum.value)
                    }

                    Component.onCompleted: {
                        vNum.value = 6
                    }
                }

                Rectangle {
                    height: 20
                    width: 80
                    color: "transparent"
                    Text {
//                        x: parent.x
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr("凸包顶点数")
                    }
                }
            }
        }
        Rectangle {
            id: acButton
            width: 100
            height: 30
            x: parent.width - width - 10
            y: parent.height - height - 10
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
                    optionWindow.visible = false
                }
            }
        }
    }
}
