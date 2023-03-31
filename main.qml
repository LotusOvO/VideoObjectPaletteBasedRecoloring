import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls

Window {
    //    property string path: ""
    //    property string filename: ""
    width: 1600
    height: 900
    visible: true
    title: qsTr("VideoObjectPaletteBasedRecoloring")
    Item {
        width: 1400
        height: 900
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        ColorPicker {
            id: colorPicker
            x: 10
            y: 450
            width: 480
        }
        ButtonArea{
            id: buttonArea
            x: 60
            y: 20
        }

        PaletteView{
            id: paletteView
            y: 200
            x: 60
        }

        VideoPlayer{
            id: videoPlayer
            y : 10
            x : 720
        }
    }
}
