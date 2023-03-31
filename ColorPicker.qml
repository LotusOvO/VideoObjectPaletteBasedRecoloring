import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: colorPicker
    width: 720
    height: 350
    property color pickedColor: Qt.hsva(1, 1, 1, 1)
    property color savedColor: pickedColor
    property int r: 255
    property int g: 0
    property int b: 0
    property int h: 360
    property int s: 255
    property int v: 255
    property int a: 255

    signal pickColor(string c)
    signal resetColor()

    onPickedColorChanged: {
        hsPicker.updateCanvasByColor()
        control.updateCanvasByColor()
    }
    function updateByRGB(){
        pickedColor = Qt.rgba(r/255, g/255, b/255, pickedColor.a)
    }
    function updateByHSV(){
        pickedColor = Qt.hsva(h/360, s/255, v/255, pickedColor.a)
    }
    function getR(){
        r = Math.floor(pickedColor.r * 255)
    }
    function getG(){
        g = Math.floor(pickedColor.g * 255)
    }
    function getB(){
        b = Math.floor(pickedColor.b * 255)
    }
    function getH(){
        h = Math.floor(pickedColor.hsvHue * 360)
    }
    function getS(){
        s = Math.floor(pickedColor.hsvSaturation * 255)
    }
    function getV(){
        v = Math.floor(pickedColor.hsvValue * 255)
    }
    function getRGB(){
        getR()
        getG()
        getB()
    }
    function getHSV(){
        getH()
        getS()
        getV()
    }

    Row {
        //        padding: 30
        spacing: 20
//        Button {
//            width: 30
//            height: 30

//            onClicked: {
//                r = 125
//                g = 125
//                b = 6
//                updateByRGB()
//                getHSV()
//                console.log(pickedColor.hsvHue, pickedColor.hsvSaturation,
//                            pickedColor.hsvValue)
//                console.log(pickedColor.r, pickedColor.g, pickedColor.b,
//                            pickedColor.a)
//            }
//        }

//        Rectangle {
//            width: 30
//            height: 30
//            color: pickedColor
//        }

        Item {
            id: circleItem
            width: 350
            height: width
            signal colorChanged(color newColor)
            property int circleWidth: 40 //圆环宽度
            property real curAngle: 0

            Rectangle {
                id: control
                width: circleItem.width
                height: width
                color: "transparent"
                border.width: 2
                border.color: "black"
                radius: 15
                anchors.margins: 10

                // 根据角度获取颜色值
                function getAngleColor(angle) {
                    var color, d
                    if (angle < Math.PI * 2 / 5) {
                        // angle: 0-72
                        d = 255 / (Math.PI * 2 / 5) * angle
                        color = '255,' + Math.round(
                                    d) + ',0' // color: 255,0,0 - 255,255,0
                    } else if (angle < Math.PI * 4 / 5) {
                        // angle: 72-144
                        d = 255 / (Math.PI * 2 / 5) * (angle - Math.PI * 2 / 5)
                        color = (255 - Math.round(
                                     d)) + ',255,0' // color: 255,255,0 - 0,255,0
                    } else if (angle < Math.PI * 6 / 5) {
                        // angle: 144-216
                        d = 255 / (Math.PI * 2 / 5) * (angle - Math.PI * 4 / 5)
                        color = '0,255,' + Math.round(
                                    d) // color: 0,255,0 - 0,255,255
                    } else if (angle < Math.PI * 8 / 5) {
                        // angle: 216-288
                        d = 255 / (Math.PI * 2 / 5) * (angle - Math.PI * 6 / 5)
                        color = '0,' + (255 - Math.round(
                                            d)) + ',255' // color: 0,255,255 - 0,0,255
                    } else {
                        // angle: 288-360
                        d = 255 / (Math.PI * 2 / 5) * (angle - Math.PI * 8 / 5)
                        color = Math.round(
                                    d) + ',0,' + (255 - Math.round(
                                                      d)) // color: 0,0,255 - 255,0,0
                    }
                    return color
                }

                // 获取旋转角度
                function getRotateAngle(mouseX, mouseY) {
                    var yPosOffset = mouseY - control.width / 2
                    // 计算角度 : tan(x) = (y2-y1)/(x2-x1);
                    var xPosOffset = mouseX - control.height / 2
                    // 旋转的弧度 hudu, 角度angle
                    var hudu = 0, angle = 0
                    if (xPosOffset != 0 && yPosOffset != 0) {
                        hudu = Math.atan(Math.abs(yPosOffset / xPosOffset))
                    }

                    if (xPosOffset === 0 && yPosOffset === 0) {
                        return angle
                    } else if (xPosOffset < 0 && yPosOffset < 0) {
                        angle = hudu * 180 / Math.PI // 左上
                    } else if (xPosOffset === 0 && yPosOffset < 0) {
                        angle = 90 // 上 中间
                    } else if (xPosOffset > 0 && yPosOffset < 0) {
                        angle = 180 - hudu * 180 / Math.PI // 右上
                    } else if (xPosOffset > 0 && yPosOffset === 0) {
                        angle = 180 // 上 下 中间
                    } else if (xPosOffset > 0 && yPosOffset > 0) {
                        angle = 180 + hudu * 180 / Math.PI // 右下
                    } else if (xPosOffset === 0 && yPosOffset > 0) {
                        angle = 270 // 下 中间
                    } else if (xPosOffset < 0 && yPosOffset > 0) {
                        angle = 360 - hudu * 180 / Math.PI // 左下
                    }
                    return (angle + 180) % 360
                }

                // 通过鼠标所在点更新Canvas画图信息
                function updateCanvasByMousePos(x, y) {
                    var currentAngle = control.getRotateAngle(x, y)
                    updateCanvasByAngle(currentAngle)
                }

                //通过角度更新Canvas画图信息位置
                function updateCanvasByAngle(angle) {
                    var newX = control.width / 2 + -Math.cos(
                                (angle + 180) % 360 * Math.PI
                                / 180) * (control.width / 2 - circleItem.circleWidth
                                          / 2 - 2 * control.anchors.margins)
                    var newY = control.height / 2 - Math.sin(
                                (angle + 180) % 360 * Math.PI
                                / 180) * (control.height / 2 - circleItem.circleWidth
                                          / 2 - 2 * control.anchors.margins)
                    handle.xDrawPos = newX
                    handle.yDrawPos = newY
                    handle.requestPaint()
                    hshandle.requestPaint()
                    circleItem.curAngle = angle
//                    pickedColor = Qt.hsva(angle / 360,
//                                          pickedColor.hsvSaturation,
//                                          pickedColor.hsvValue, pickedColor.a)
                    h = angle
                    updateByHSV()
                    getRGB()
                }

                function updateCanvasByColor() {
                    var angle = pickedColor.hsvHue * 360
                    //                    console.log(angle, circleItem.curAngle)
                    if (angle !== circleItem.curAngle) {
                        var newX = control.width / 2 + -Math.cos(
                                    (angle + 180) % 360 * Math.PI
                                    / 180) * (control.width / 2 - circleItem.circleWidth
                                              / 2 - 2 * control.anchors.margins)
                        var newY = control.height / 2 - Math.sin(
                                    (angle + 180) % 360 * Math.PI
                                    / 180) * (control.height / 2 - circleItem.circleWidth
                                              / 2 - 2 * control.anchors.margins)
                        handle.xDrawPos = newX
                        handle.yDrawPos = newY

                        handle.requestPaint()
                        circleItem.curAngle = angle
                    }
                }

                // 鼠标选择圆环按钮
                Canvas {
                    id: handle
                    width: parent.width
                    height: width

                    property int xDrawPos: 0
                    property int yDrawPos: 0

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.beginPath()
                        ctx.arc(xDrawPos, yDrawPos, circleItem.circleWidth / 2,
                                0, 2 * Math.PI, false)
                        ctx.fillStyle = 'lightblue'
                        ctx.fill()
                        ctx.strokeStyle = 'transparent'
                        ctx.stroke()
                        ctx.closePath()

                        ctx.beginPath()
                        ctx.arc(xDrawPos, yDrawPos,
                                circleItem.circleWidth / 2 - 2, 0,
                                2 * Math.PI, false)
                        ctx.fillStyle = Qt.hsva(circleItem.curAngle / 360, 1,
                                                1, 1)
                        ctx.fill()
                        ctx.strokeStyle = 'transparent'
                        ctx.stroke()
                        ctx.closePath()
                    }

                    z: 10
                }

                // 圆环画布
                Canvas {
                    id: canvas
                    width: parent.width - 4 * control.anchors.margins
                    height: parent.height
                    anchors.centerIn: parent

                    onPaint: {
                        var ctx = getContext("2d")
                        var iSectors = 360
                        var iSectorAngle = (360 / iSectors) / 180 * Math.PI
                        // in radians
                        ctx.translate(width / 2, height / 2)
                        for (var i = 0; i < iSectors; i++) {
                            var startAngle = 0
                            var endAngle = startAngle + iSectorAngle
                            var radius = (width / 2 - 1)
                            var color = control.getAngleColor(iSectorAngle * i)
                            ctx.beginPath()
                            ctx.moveTo(0, 0)
                            ctx.arc(0, 0, radius, startAngle, endAngle, false)
                            ctx.closePath()
                            ctx.strokeStyle = Qt.hsva(i / 360, 1, 1, 1)
                            ctx.stroke()
                            ctx.fillStyle = Qt.hsva(i / 360, 1, 1, 1)
                            ctx.fill()
                            ctx.rotate(iSectorAngle)
                        }
                        ctx.restore()

                        ctx.save()
                        ctx.translate(0, 0)
                        ctx.beginPath()
                        ctx.arc(0, 0, width / 2 - circleItem.circleWidth, 0,
                                2 * Math.PI, false)
                        ctx.fillStyle = 'white'
                        ctx.fill()
                        ctx.strokeStyle = 'transparent'
                        ctx.stroke()
                        ctx.restore()
                    }

                    MouseArea {
                        id: colorSelectorMouseArea
                        anchors.fill: parent
                        onMouseXChanged: {
                            control.updateCanvasByMousePos(mouseX, mouseY)
                        }
                    }

                    Component.onCompleted: {
                        control.updateCanvasByAngle(0)
                    }
                }
                Rectangle {
                    id: hsPicker
                    width: Math.floor(
                               (parent.width - 4 * control.anchors.margins - 2
                                * circleItem.circleWidth) / 1.415)
                    height: width
                    anchors.centerIn: parent

                    function updateCanvasByPos(x, y) {

                        hshandle.xDrawPos = x
                        hshandle.yDrawPos = y
                        if (hshandle.xDrawPos < hshandle.x)
                            hshandle.xDrawPos = hshandle.x
                        if (hshandle.xDrawPos > hshandle.x + hshandle.width)
                            hshandle.xDrawPos = hshandle.x + hshandle.width
                        if (hshandle.yDrawPos < hshandle.y)
                            hshandle.yDrawPos = hshandle.y
                        if (hshandle.yDrawPos > hshandle.y + hshandle.height)
                            hshandle.yDrawPos = hshandle.y + hshandle.height
//                        var s = hshandle.xDrawPos / width
//                        var v = 1 - hshandle.yDrawPos / width
//                        pickedColor = Qt.hsva(pickedColor.hsvHue, s, v)
                        hshandle.requestPaint()

                        s = Math.floor(hshandle.xDrawPos / width * 255)
                        v = Math.floor((1 - hshandle.yDrawPos / width) * 255)
                        updateByHSV()
                        getRGB()
                    }

                    function updateCanvasByColor() {
                        var x = pickedColor.hsvSaturation * width
                        var y = (1 - pickedColor.hsvValue) * width
                        hshandle.xDrawPos = x
                        hshandle.yDrawPos = y

                        hshandle.requestPaint()
                    }

                    Component.onCompleted: {
                        updateCanvasByColor()
                    }

                    Canvas {
                        id: hshandle
                        width: parent.width
                        height: width

                        property int xDrawPos: x + width
                        property int yDrawPos: y

                        onPaint: {

                            //                            console.log(xDrawPos, yDrawPos)
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            ctx.beginPath()
                            ctx.arc(xDrawPos, yDrawPos,
                                    circleItem.circleWidth / 4, 0,
                                    2 * Math.PI, false)
                            ctx.fillStyle = 'lightblue'
                            ctx.fill()
                            ctx.strokeStyle = 'transparent'
                            ctx.stroke()
                            ctx.closePath()

                            ctx.beginPath()
                            ctx.arc(xDrawPos, yDrawPos,
                                    circleItem.circleWidth / 4 - 2, 0,
                                    2 * Math.PI, false)
                            ctx.fillStyle = colorPicker.pickedColor
                            ctx.fill()
                            ctx.strokeStyle = 'transparent'
                            ctx.stroke()
                            ctx.closePath()
                        }

                        z: 20
                    }

                    Rectangle {
                        rotation: -90
                        anchors.fill: parent
                        transformOrigin: Item.Center

                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: "white"
                            }
                            GradientStop {
                                position: 1.0
                                color: Qt.hsva(pickedColor.hsvHue, 1, 1, 1)
                            }
                        }
                    }
                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            GradientStop {
                                position: 1.0
                                color: "#ff000000"
                            }
                            GradientStop {
                                position: 0.0
                                color: "#00000000"
                            }
                        }
                    }

                    z: 15
                    MouseArea {
                        id: hsSelectorMouseArea
                        anchors.fill: parent
                        onMouseYChanged: {
                            hsPicker.updateCanvasByPos(mouseX, mouseY)
                        }

                        onMouseXChanged: {
                            hsPicker.updateCanvasByPos(mouseX, mouseY)
                        }
                    }
                }
            }
        }

        Item {
            id: stripItem
            y: 10
            width: 350
            height: width
            Rectangle {
                anchors.fill: parent
                //                color: "red"
            }
            Column {
                width: parent.width
                spacing: 20
                Row {
                    spacing: 10
                    id: hPicker
                    width: parent.width
                    property bool ac: true
                    Text {
                        height: 20
                        width: parent.width * 0.05
                        text: qsTr("H")
                    }
                    Rectangle {
                        id: hRec
                        border.width: 1
                        radius: 2
                        height: 20
                        width: parent.width * 0.7
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop {
                                position: 0.0
                                color: Qt.hsva(0, pickedColor.hsvSaturation,
                                               pickedColor.hsvValue, 1)
                            }
                            GradientStop {
                                position: 0.16
                                color: Qt.hsva(0.16, pickedColor.hsvSaturation,
                                               pickedColor.hsvValue, 1)
                            }
                            GradientStop {
                                position: 0.33
                                color: Qt.hsva(0.33, pickedColor.hsvSaturation,
                                               pickedColor.hsvValue, 1)
                            }
                            GradientStop {
                                position: 0.5
                                color: Qt.hsva(0.5, pickedColor.hsvSaturation,
                                               pickedColor.hsvValue, 1)
                            }
                            GradientStop {
                                position: 0.76
                                color: Qt.hsva(0.76, pickedColor.hsvSaturation,
                                               pickedColor.hsvValue, 1)
                            }
                            GradientStop {
                                position: 0.85
                                color: Qt.hsva(0.85, pickedColor.hsvSaturation,
                                               pickedColor.hsvValue, 1)
                            }
                            GradientStop {
                                position: 1.0
                                color: Qt.hsva(1, pickedColor.hsvSaturation,
                                               pickedColor.hsvValue, 1)
                            }
                        }
                        Rectangle {
                            id: hSlider
                            width: 4
                            height: 24
                            x: parent.width - 2
                            y: parent.y - 2
                            z:5
                            color: "black"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onMouseXChanged: {
                                if (mouseX < 0)
                                    hSlider.x = -2
                                else if (mouseX > hRec.width)
                                    hSlider.x = hRec.width - 2
                                else
                                    hSlider.x = mouseX - 2
                                hSpinBox.value = Math.floor(
                                            mouseX / hRec.width * 360)
                            }
                        }
                    }
                    SpinBox {
                        id: hSpinBox
                        height: 20
                        width: parent.width * 0.15
                        value: 360
                        to: 360
                        editable: true
                        onValueChanged: {
                            hSlider.x = Math.floor(value / 360 * hRec.width) - 2
//                            pickedColor = Qt.hsva(value / 360,
//                                                  pickedColor.hsvSaturation,
//                                                  pickedColor.hsvValue, 1)
                            if(hPicker.ac === true){
                                h = value
                                updateByHSV()
                                getRGB()
                            }
                        }
                    }
                    Connections {
                        target: colorPicker
                        function onHChanged() {
                            hPicker.ac = false
                            hSpinBox.value = h
                            hPicker.ac = true
                        }
                    }
                }
                Row {
                    spacing: 10
                    id: sPicker
                    width: parent.width
                    property bool ac: true
                    Text {
                        height: 20
                        width: parent.width * 0.05
                        text: qsTr("S")
                    }
                    Rectangle {
                        id: sRec
                        border.width: 1
                        radius: 2
                        height: 20
                        width: parent.width * 0.7
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop {
                                position: 0.0
                                color: Qt.hsva(pickedColor.hsvHue, 0,
                                               pickedColor.hsvValue, 1)
                            }
                            GradientStop {
                                position: 1.0
                                color: Qt.hsva(pickedColor.hsvHue, 1,
                                               pickedColor.hsvValue, 1)
                            }
                        }
                        Rectangle {
                            id: sSlider
                            width: 4
                            height: 24
                            x: parent.width - 2
                            y: parent.y - 2
                            z: 5
                            color: "black"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onMouseXChanged: {
                                if (mouseX < 0)
                                    sSlider.x = -2
                                else if (mouseX > sRec.width)
                                    sSlider.x = sRec.width - 2
                                else
                                    sSlider.x = mouseX - 2
                                sSpinBox.value = Math.floor(
                                            mouseX / sRec.width * 255)
                            }
                        }
                    }
                    SpinBox {
                        id: sSpinBox
                        height: 20
                        width: parent.width * 0.15
                        value: 255
                        to: 255
                        editable: true
                        onValueChanged: {
                            sSlider.x = Math.floor(value / 255 * sRec.width) - 2
//                            pickedColor = Qt.hsva(pickedColor.hsvHue,
//                                                  value / 255,
//                                                  pickedColor.hsvValue, 1)
                            if(sPicker.ac === true){
                                s = value
                                updateByHSV()
                                getRGB()
                            }
                        }
                    }
                    Connections {
                        target: colorPicker
                        function onSChanged() {
                            sPicker.ac = false
                            sSpinBox.value = s
                            sPicker.ac = true
                        }
                    }
                }
                Row {
                    spacing: 10
                    id: vPicker
                    width: parent.width
                    property bool ac: true
                    Text {
                        height: 20
                        width: parent.width * 0.05
                        text: qsTr("V")
                    }
                    Rectangle {
                        id: vRec
                        border.width: 1
                        radius: 2
                        height: 20
                        width: parent.width * 0.7
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop {
                                position: 0.0
                                color: Qt.hsva(pickedColor.hsvHue,
                                               pickedColor.hsvSaturation, 0, 1)
                            }
                            GradientStop {
                                position: 1.0
                                color: Qt.hsva(pickedColor.hsvHue,
                                               pickedColor.hsvSaturation, 1, 1)
                            }
                        }
                        Rectangle {
                            id: vSlider
                            width: 4
                            height: 24
                            x: parent.width - 2
                            y: parent.y - 2
                            z: 5
                            color: "black"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onMouseXChanged: {
                                if (mouseX < 0)
                                    vSlider.x = -2
                                else if (mouseX > vRec.width)
                                    vSlider.x = vRec.width - 2
                                else
                                    vSlider.x = mouseX - 2
                                vSpinBox.value = Math.floor(
                                            mouseX / vRec.width * 255)
                            }
                        }
                    }
                    SpinBox {
                        id: vSpinBox
                        height: 20
                        width: parent.width * 0.15
                        value: 255
                        to: 255
                        editable: true
                        onValueChanged: {
                            vSlider.x = Math.floor(value / 255 * vRec.width) - 2
//                            pickedColor = Qt.hsva(pickedColor.hsvHue,
//                                                  pickedColor.hsvSaturation,
//                                                  value / 255, 1)
                            if(vPicker.ac === true){
                                v = value
                                updateByHSV()
                                getRGB()
                            }
                        }
                    }
                    Connections {
                        target: colorPicker
                        function onVChanged() {
                            vPicker.ac = false
                            vSpinBox.value = v
                            vPicker.ac = true
                        }
                    }
                }
                Row {
                    spacing: 10
                    id: rPicker
                    width: parent.width
                    property bool ac: true
                    Text {
                        height: 20
                        width: parent.width * 0.05
                        text: qsTr("R")
                    }
                    Rectangle {
                        id: rRec
                        border.width: 1
                        radius: 2
                        height: 20
                        width: parent.width * 0.7
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop {
                                position: 0.0
                                color: Qt.rgba(0, pickedColor.g, pickedColor.b, 1)
                            }
                            GradientStop {
                                position: 1.0
                                color: Qt.rgba(1, pickedColor.g, pickedColor.b, 1)
                            }
                        }
                        Rectangle {
                            id: rSlider
                            width: 4
                            height: 24
                            x: parent.width - 2
                            y: parent.y - 2
                            z: 5
                            color: "black"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onMouseXChanged: {
                                if (mouseX < 0)
                                    rSlider.x = -2
                                else if (mouseX > rRec.width)
                                    rSlider.x = rRec.width - 2
                                else
                                    rSlider.x = mouseX - 2
                                rSpinBox.value = Math.floor(
                                            mouseX / rRec.width * 255)
                            }
                        }
                    }
                    SpinBox {
                        id: rSpinBox
                        height: 20
                        width: parent.width * 0.15
                        value: 255
                        to: 255
                        editable: true
                        onValueChanged: {
                            rSlider.x = Math.floor(value / 255 * rRec.width) - 2
//                            pickedColor = Qt.rgba(value / 255, pickedColor.g, pickedColor.b, 1)
                            if(rPicker.ac === true){
                                r = value
                                updateByRGB()
                                getHSV()
                            }
                        }
                    }
                    Connections {
                        target: colorPicker
                        function onRChanged() {
                            rPicker.ac = false
                            rSpinBox.value = r
                            rPicker.ac = true
                        }
                    }
                }
                Row {
                    spacing: 10
                    id: gPicker
                    width: parent.width
                    property bool ac: true
                    Text {
                        height: 20
                        width: parent.width * 0.05
                        text: qsTr("G")
                    }
                    Rectangle {
                        id: gRec
                        border.width: 1
                        radius: 2
                        height: 20
                        width: parent.width * 0.7
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop {
                                position: 0.0
                                color: Qt.rgba(pickedColor.r, 0, pickedColor.b, 1)
                            }
                            GradientStop {
                                position: 1.0
                                color: Qt.rgba(pickedColor.r, 1, pickedColor.b, 1)
                            }
                        }
                        Rectangle {
                            id: gSlider
                            width: 4
                            height: 24
                            x: -2
                            y: parent.y - 2
                            z: 5
                            color: "black"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onMouseXChanged: {
                                if (mouseX < 0)
                                    gSlider.x = -2
                                else if (mouseX > gRec.width)
                                    gSlider.x = gRec.width - 2
                                else
                                    gSlider.x = mouseX - 2
                                gSpinBox.value = Math.floor(
                                            mouseX / gRec.width * 255)
                            }
                        }
                    }
                    SpinBox {
                        id: gSpinBox
                        height: 20
                        width: parent.width * 0.15
                        value: 255
                        to: 255
                        editable: true
                        onValueChanged: {
                            gSlider.x = Math.floor(value / 255 * gRec.width) - 2
                            if(gPicker.ac === true){
                                g = value
                                updateByRGB()
                                getHSV()
                            }
                        }
                    }
                    Connections {
                        target: colorPicker
                        function onGChanged() {
                            gPicker.ac = false
                            gSpinBox.value = g
                            gPicker.ac = true
                        }
                    }
                }
                Row {
                    spacing: 10
                    id: bPicker
                    width: parent.width
                    property bool ac: true
                    Text {
                        height: 20
                        width: parent.width * 0.05
                        text: qsTr("B")
                    }
                    Rectangle {
                        id: bRec
                        border.width: 1
                        radius: 2
                        height: 20
                        width: parent.width * 0.7
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop {
                                position: 0.0
                                color: Qt.rgba(pickedColor.r, pickedColor.g, 0, 1)
                            }
                            GradientStop {
                                position: 1.0
                                color: Qt.rgba(pickedColor.r, pickedColor.g, 1 , 1)
                            }
                        }
                        Rectangle {
                            id: bSlider
                            width: 4
                            height: 24
                            x: -2
                            y: parent.y - 2
                            z: 5
                            color: "black"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onMouseXChanged: {
                                if (mouseX < 0)
                                    bSlider.x = -2
                                else if (mouseX > bRec.width)
                                    bSlider.x = bRec.width - 2
                                else
                                    bSlider.x = mouseX - 2
                                bSpinBox.value = Math.floor(
                                            mouseX / bRec.width * 255)
                            }
                        }
                    }
                    SpinBox {
                        id: bSpinBox
                        height: 20
                        width: parent.width * 0.15
                        value: 255
                        to: 255
                        editable: true
                        onValueChanged: {
                            bSlider.x = Math.floor(value / 255 * bRec.width) - 2
                            if(bPicker.ac === true){
                                b = value
                                updateByRGB()
                                getHSV()
                            }
                        }
                    }
                    Connections {
                        target: colorPicker
                        function onBChanged() {
                            bPicker.ac = false
                            bSpinBox.value = b
                            bPicker.ac = true
                        }
                    }
                }
                Item {
                    id: chosenItem
                    width: parent.width
                    height: 110
                    Rectangle{
                        border.width: 2
                        radius: 5
                        y: parent.height / 8
                        x: parent.width / 16
                        height: parent.height * 3 / 4
                        width : parent.width * 5 / 8
                        color: pickedColor
                        TextInput {
                            anchors.centerIn: parent
                            text: pickedColor
                            selectByMouse: true
//                            cursorVisible: false
                            cursorDelegate: Rectangle{
                                visible: false
                            }

                            color: Qt.rgba(1 - pickedColor.r, 1 - pickedColor.g, 1 - pickedColor.b, 1)
                        }
                    }
                    Button{
                        y: parent.height / 4
                        x: parent.width * 3 / 4
                        text: qsTr("确认颜色")
                        background: Rectangle{

                            color: "transparent"
                            border.width: 2
                            radius: 3
                        }
                        onClicked: {
//                            savedColor = pickedColor
                            pickColor(pickedColor)
                        }
                    }
                    Button{
                        y: parent.height / 2
                        x: parent.width * 3 / 4
                        text: qsTr("还原颜色")
                        background: Rectangle{

                            color: "transparent"
                            border.width: 2
                            radius: 3
                        }
                        onClicked: {
                            resetColor()
//                            pickedColor = savedColor
//                            getHSV()
//                            getRGB()
                        }
                    }
                }
            }
        }
        Connections{
            target: paletteView
            function onSetColor(c){
                pickedColor = c
                getHSV()
                getRGB()
            }
        }
    }
}
