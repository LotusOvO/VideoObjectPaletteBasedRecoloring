# This Python file uses the following encoding: utf-8
import os

from PySide6.QtCore import QObject, Slot, Signal, QThread
from PySide6 import QtTest


class Player(QThread):
    s = Signal()

    def __init__(self):
        super(Player, self).__init__(None)
        self.working = True

    def run(self):
        while self.working:
            self.s.emit()
            QtTest.QTest.qWait(40)  # sleep 40ms


class ProgressManager(QObject):
    switchFrame = Signal(list)
    setPause = Signal()
    setPos = Signal(float)

    def __init__(self):
        super(ProgressManager, self).__init__()
        self.path = None
        self.player = Player()
        self.currentFrame = 0
        self.countFrame = 0
        self.player.s.connect(self.next)
        self.frame = []

    @Slot(str)
    def readPath(self, path):
        self.path = path
        self.countFrame = len(os.listdir(path + "images/"))
        self.frame.clear()
        for img_item in os.listdir(path + "images/"):
            self.frame.append(img_item[:-4])
        self.currentFrame = 0
        # 将图像设置为第一帧
        self.switchFrame.emit(["file:///" + self.path + "images/" + self.frame[self.currentFrame] + ".jpg",
                               "file:///" + self.path + "recolored/" + self.frame[self.currentFrame] + ".png"])
        self.setPos.emit(self.currentFrame / self.countFrame)

    @Slot()
    def next(self):
        if self.currentFrame < self.countFrame:
            self.switchFrame.emit(["file:///" + self.path + "images/" + self.frame[self.currentFrame] + ".jpg",
                                   "file:///" + self.path + "recolored/" + self.frame[self.currentFrame] + ".png"])
            self.setPos.emit(self.currentFrame / self.countFrame)
            self.currentFrame += 1
        else:
            self.setPause.emit()
            self.player.working = False

    @Slot()
    def pause(self):
        self.player.working = False

    @Slot()
    def play(self):
        if self.currentFrame >= self.countFrame:
            self.currentFrame = 0
        self.player.working = True
        self.player.run()

    @Slot(int, int)
    def switchPos(self, pos, width):
        self.currentFrame = pos * self.countFrame // width
        if self.currentFrame > self.countFrame:
            self.currentFrame = self.countFrame
        elif self.currentFrame < 0:
            self.currentFrame = 0
        self.switchFrame.emit(["file:///" + self.path + "images/" + self.frame[self.currentFrame] + ".jpg",
                               "file:///" + self.path + "recolored/" + self.frame[self.currentFrame] + ".png"])


if __name__ == "__main__":
    pass
