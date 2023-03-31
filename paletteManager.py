# This Python file uses the following encoding: utf-8
from PySide6.QtCore import QObject, Slot, Signal
import numpy as np
import json


def str2RGB(color_str):
    strR = color_str[1:3]
    strG = color_str[3:5]
    strB = color_str[5:7]
    r = int('0x' + strR, 16)
    g = int('0x' + strG, 16)
    b = int('0x' + strB, 16)
    return [r, g, b]


class PaletteManager(QObject):
    setColor = Signal(int, str, str)  # index, originalColor, replaceColor
    clearColor = Signal()
    setPalette = Signal(list)
    flushPalette = Signal()

    def __init__(self):
        super(PaletteManager, self).__init__()
        self.colors = []  # shape(n, 2)->(str, str) index 0 origin, index 1 replace

    @Slot(int, str)
    def setNewColor(self, index, color):
        self.colors[index][1] = color
        self.setPalette.emit(self.getPalette())

    @Slot()
    def updateColors(self):
        for i in range(len(self.colors)):
            self.setColor.emit(i, self.colors[i][0], self.colors[i][1])
        self.flushPalette.emit()

    @Slot(str)
    def readPalette(self, path):
        self.colors = []
        tetra_prime = np.asfarray(json.load(open(path))['vs'])
        for rgb in tetra_prime:
            r = '{:02X}'.format(int(float(rgb[0])))
            g = '{:02X}'.format(int(float(rgb[1])))
            b = '{:02X}'.format(int(float(rgb[2])))
            color = "#" + r + g + b
            self.colors.append([color, color])
        self.clearColor.emit()
        self.updateColors()

    def getPalette(self):
        palette = []
        for two_colors in self.colors:
            palette.append(str2RGB(two_colors[1]))
        return palette

    @Slot(str)
    def saveRecolorPalette(self, path):
        palette = np.asarray(self.colors)
        palette = palette[:, 1]
        np.save(path, palette)

    @Slot(str)
    def readRecolorPalette(self, path):
        palette = np.load(path)
        for i in range(len(self.colors)):
            self.colors[i][1] = palette[i]
        self.setPalette.emit(self.getPalette())
        self.clearColor.emit()
        self.updateColors()


if __name__ == "__main__":
    p = PaletteManager()
    p.readPalette("C:/Users/Administrator/Documents/Code/fastLayerDecomposition/0000043-rawconvexhull.obj")
    print(p.colors)
