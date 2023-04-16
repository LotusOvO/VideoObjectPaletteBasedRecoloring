# This Python file uses the following encoding: utf-8
from PySide6.QtCore import QObject, Slot, Signal
import PIL.Image as Image
import numpy as np


class MaskManager(QObject):
    setObjectColor = Signal(str)
    unsetObjectColor = Signal()

    def __init__(self):
        super(MaskManager, self).__init__()
        self.mask_image = None

    @Slot(str)
    def readImage(self, path):
        self.mask_image = np.asfarray(Image.open(path).convert('RGB'))

    @Slot(float, float)
    def setPos(self, x, y):
        x = int(x * self.mask_image.shape[1])
        y = int(y * self.mask_image.shape[0])
        r = '{:02X}'.format(int(self.mask_image[y][x][0]))
        g = '{:02X}'.format(int(self.mask_image[y][x][1]))
        b = '{:02X}'.format(int(self.mask_image[y][x][2]))
        color = "#" + r + g + b
        if color != "#000000":
            self.setObjectColor.emit(color)

    @Slot()
    def resetMask(self):
        self.unsetObjectColor.emit()


# if __name__ == "__main__":
#     pass
