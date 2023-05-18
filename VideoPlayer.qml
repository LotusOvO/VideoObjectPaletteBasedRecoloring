import QtQuick

Item {
    id: videoPlayer
//    width: 1320
    height: 500
    Rectangle{
//        anchors.leftMargin: 20
//        anchors.rightMargin: 20
        anchors.fill: parent
        color: "transparent"
    }
        Rectangle{
//            anchors.horizontalCenter: parent.horizontalCenter
            y: 10
            width: 600
            height: width / 16 * 9
            border.width: 2
            radius: 5
            Image {
                visible: buttonArea.pathReady
                cache: false
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.topMargin: 4.5
                anchors.bottomMargin: 4.5
                id: origin
                fillMode: Image.PreserveAspectFit
//                source: "file:///C:/Users/Administrator/Pictures/yuki1.jpg"
            }
        }
        Rectangle{
//            anchors.horizontalCenter: parent.horizontalCenter
            y: 10
            x: width + 20
            width: 600
            height: width / 16 * 9
            border.width: 2
            radius: 5
            Image {
                visible: buttonArea.weightReady
                cache: false
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.topMargin: 4.5
                anchors.bottomMargin: 4.5
                id: recolor
                fillMode: Image.PreserveAspectFit
//                source: "file:///C:/Users/Administrator/Pictures/yuki1.jpg"
            }
        }

        Connections {
            target: progressManager
            function onSwitchFrame(list){
                origin.source = list[0]
                recolor.source = list[1]
//                console.log(list)
            }
            function onSetPause(){
                pause.paused = true
                progressMouseArea.enabled = true
            }
            function onSetPos(x){
                pos.x = x * bar.width  - pos.width / 2
            }
        }
//        Rectangle{
//            height: 30
//            width: height
//            color: "red"
//            MouseArea{
//                anchors.fill: parent
//                onClicked: {
//                    progressManager.readPath("C:/Users/Administrator/Documents/Code/XMem/workspace/harmoe/")
//                }
//            }
//        }

    Rectangle{
        id: progress
        y: width / 16 * 9 + 10
        x: width / 2 + 10
//        anchors.horizontalCenter: parent.horizontalCenter
        width: 640
        height: 40
        color: "transparent"
        border.width: 2
        radius: 5
        Row{
            anchors.fill: parent
            anchors.leftMargin: 10
            spacing: 15

            Rectangle{
                anchors.verticalCenter: parent.verticalCenter
                property bool paused: true
                id : pause
                height: 30
                width: height
                color: "transparent"
                Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: pause.paused ? "./Icons/play.svg" : "./Icons/pause.svg"
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        if(pause.paused === true){
                            pause.paused = false
                            progressMouseArea.enabled = false
                            progressManager.play()
                        }
                        else{
                            pause.paused = true
                            progressMouseArea.enabled = true
                            progressManager.pause()
                        }
                    }
                }
            }
            Rectangle{
                anchors.verticalCenter: parent.verticalCenter
                id : progressBar
                height: 30
                width: 560
                color: "transparent"
                MouseArea{
                    id: progressMouseArea
                    anchors.fill: parent
                    enabled: false
                    onMouseXChanged: {
                        if(mouseX < 0) pos.x = -pos.width / 2
                        else if(mouseX > progressBar.width) pos.x = progressBar.width - pos.width / 2
                        else pos.x = mouseX - pos.width / 2
                        progressManager.switchPos(pos.x, progressBar.width)
                    }
                }
                Rectangle{
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 5
                    id : bar
                    height: 5
                    width: 560
                    color: "gray"
                }
                Rectangle{
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 2
                    id : pos
                    x: -2
                    height: 26
                    width: 4
                    color: "black"
                }
            }
        }
    }
}
