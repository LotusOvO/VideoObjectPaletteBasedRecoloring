import QtQuick
import QtQuick.Controls

Item {
    width: 600
    height: 240
    id: paletteView
    property int currentIndex: 0

    signal setColor(string c)
    Rectangle {
        //        anchors.leftMargin: 20
        //        anchors.rightMargin: 20
        anchors.fill: parent
        color: "transparent"
        border.width: 2
        radius: 15
    }
    ListView {
        y: 25
        x: 40
        width: 520
        height: 200
        orientation: Qt.Horizontal
        model: paletteColors
        delegate: paletteDelegate
    }
    Component {
        id: paletteDelegate
        Rectangle {
            width: 80
            height: 200
            color: "transparent"
            Column {
                width: 80
                height: 200
                spacing: -4
                Rectangle {
                    width: 60
                    height: 60
                    radius: 30
                    border.width: 2
                    z: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: originalColor
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 8
                    height: 80
                    border.width: 2
//                    color: "black"
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: originalColor
                        }
                        GradientStop {
                            position: 1.0
                            color: replaceColor
                        }
                    }
//                    border.width: currentIndex === index ? 2 : 0
//                    border.color: "lightblue"
                    z: 4
                }
                Rectangle {
                    width: 66
                    height: 66
                    radius: 33
                    z: 3
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: currentIndex === index ? "lightblue" : "transparent"

                    Rectangle{
                        width: 60
                        height: 60
                        radius: 30
                        z: 5
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        border.width: 2
                        color: replaceColor

                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            currentIndex = index
                        }
                    }
                }
            }
        }
    }
    ListModel {
        id: paletteColors
//        ListElement {
//            index: 0
//            originalColor: "#123456"
//            replaceColor: "#654321"
//        }
//        ListElement {
//            index: 1
//            originalColor: "#123456"
//            replaceColor: "black"
//        }
//        ListElement {
//            index: 2
//            originalColor: "#123456"
//            replaceColor: "lightblue"
//        }
    }

    function addColor(index, oc, rc){
        paletteColors.append({"index":index, "originalColor": oc, "replaceColor" : rc})
    }

    function changeColor(index, c){
        for (let i = 0;i < paletteColors.count; ++i){
            if(paletteColors.get(i).index === index){
                paletteColors.setProperty(i, "replaceColor", c)
                paletteManager.setNewColor(i, c)
                break
            }
        }
    }

    function resetColor(index){
        for (let i = 0;i < paletteColors.count; ++i){
            if(paletteColors.get(i).index === index){
                paletteColors.setProperty(i, "replaceColor", paletteColors.get(i).originalColor)
                setColor(paletteColors.get(i).originalColor)
                paletteManager.setNewColor(i, paletteColors.get(i).originalColor)
                break
            }
        }
    }

    onCurrentIndexChanged: {
        setColor(paletteColors.get(currentIndex).replaceColor)
    }

    Connections{
        target: colorPicker
        function onPickColor(color){
            changeColor(currentIndex, color)
        }
        function onResetColor(){
            resetColor(currentIndex)
        }
    }
    Connections{
        target: paletteManager
        function onSetColor(index, oc, rc){
            addColor(index, oc, rc)
        }
        function onClearColor(){
            paletteColors.clear()
        }
        function onFlushPalette(){
            setColor(paletteColors.get(currentIndex).replaceColor)
        }
    }
}
