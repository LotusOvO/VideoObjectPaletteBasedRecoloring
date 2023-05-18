import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls

Window {
    //    property string path: ""
    //    property string filename: ""
    width: 1300
    height: 700
    visible: true
    title: qsTr("VideoObjectPaletteBasedRecoloring")
    id: rootwindow
    Item {
        width: 1300
        height: 700
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        ColorPicker {
            id: colorPicker
            x: rootwindow.x + 300
            y: rootwindow.y + 100
//            width: 480
        }
        ButtonArea{
            id: buttonArea
            x: 40
            y: 20
        }

        PaletteView{
            id: paletteView
            x: buttonArea.width + buttonArea.x + 20
            y: 20
        }

        VideoPlayer{
            id: videoPlayer
            y: buttonArea.height + buttonArea.y + 20
            x: 40
        }
        MaskSelector{
            id: maskSelector
            x: rootwindow.x + 10
            y: rootwindow.y + 10
        }
        OptionWindow{
            id: optionWindow
            x: rootwindow.x + 10
            y: rootwindow.y + 10
        }
    }
}
