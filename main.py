# This Python file uses the following encoding: utf-8
import os
from pathlib import Path
import sys
import progressManager
import paletteManager
import recolorManager

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

# BASE_DIR = os.path.dirname(os.path.abspath(__file__))


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    progressManager = progressManager.ProgressManager()
    paletteManager = paletteManager.PaletteManager()
    recolorManager = recolorManager.RecolorManager()
    context = engine.rootContext()
    context.setContextProperty("progressManager", progressManager)
    context.setContextProperty("paletteManager", paletteManager)
    context.setContextProperty("recolorManager", recolorManager)

    recolorManager.updatePalette.connect(paletteManager.readPalette)
    recolorManager.succeedRecolor.connect(progressManager.readPath)
    paletteManager.setPalette.connect(recolorManager.setPalette)

    engine.load(os.fspath(Path(__file__).resolve().parent / "main.qml"))
    if not engine.rootObjects():
        sys.exit(-1)

    # root = engine.rootObjects()[0]
    # root.doOstu.connect(ostuManager.func)
    sys.exit(app.exec())
