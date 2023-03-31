import os

import numpy as np
from PySide6.QtCore import QObject, Slot, Signal
from PySide6 import QtTest
from Convexhull_simplification import *
from additiveMixingLayersExtraction import *
from multiprocessing import Pool


class RecolorManager(QObject):
    succeedGetWeight = Signal()
    succeedGetConvexhull = Signal()
    succeedRecolor = Signal(str)
    updatePalette = Signal(str)

    def __init__(self):
        super(RecolorManager, self).__init__()
        self.work_path = ""
        self.tetra_prime = None
        self.palette = None
        self.weights = None
        self.weights_dict = None

    @Slot(str)
    def setWorkPath(self, path):
        self.work_path = path
        #  do some check

    @Slot(int)
    def useMaskAndGetConvexhull(self, vertices_num=6):
        pool = Pool(processes=1)
        tetra_prime_path = pool.starmap_async(get_convexhull, [(self.work_path, vertices_num)])
        while not tetra_prime_path.ready():
            QtTest.QTest.qWait(100)
        tetra_prime_path = tetra_prime_path.get()[0]
        # tetra_prime_path = get_convexhull(self.work_path, vertices_num)
        self.tetra_prime = np.asfarray(json.load(open(tetra_prime_path))['vs'])
        print(tetra_prime_path)
        self.succeedGetConvexhull.emit()
        self.updatePalette.emit(tetra_prime_path)

    @Slot()
    def getWeights(self):
        # pool = Pool(processes=1)
        # work = pool.starmap_async(get_images_weight, [(self.work_path, self.tetra_prime)])
        # while not work.ready():
        #     QtTest.QTest.qWait(100)
        # self.weights = work.get()[0]
        self.weights = get_images_weight(self.work_path, self.tetra_prime)
        self.saveWeightDict()
        self.succeedGetWeight.emit()

    @Slot(list)
    def setPalette(self, colors):
        self.palette = np.asarray(colors)

    @Slot()
    def doRecolor(self):
        # pool = Pool(processes=1)
        # work = pool.starmap_async(images_recolor, [(self.work_path, self.weights, self.palette)])
        # while not work.ready():
        #     QtTest.QTest.qWait(100)
        if self.weights_dict is not None:
            images_recolor_use_dict(self.work_path, self.weights_dict, self.palette)
        else:
            images_recolor(self.work_path, self.weights, self.palette)
        self.succeedRecolor.emit(self.work_path)

    @Slot(str)
    def readTetraPrime(self, tetra_prime_file_path):
        self.tetra_prime = np.asfarray(json.load(open(tetra_prime_file_path))['vs'])
        self.palette = self.tetra_prime.copy()
        self.succeedGetConvexhull.emit()
        self.updatePalette.emit(tetra_prime_file_path)

    # @Slot(str)
    # def saveTetraPrime(self, tetra_prime_path):
    #     video_name = self.work_path.rsplit("/", 2)[1]
    #     name = tetra_prime_path + video_name + ('-%02d.js' % len(self.tetra_prime))
    #     with open(name, 'w') as myfile:
    #         json.dump({'vs': self.tetra_prime.clip(0.0, 255.0).tolist()}, myfile, indent=4)

    @Slot()
    def saveWeightDict(self):
        if not self.weights_dict:
            masked_path = self.work_path + "masked/"
            images = os.listdir(masked_path)
            self.weights_dict = np.zeros((256, 256, 256, len(self.tetra_prime)))
            for index in range(len(images)):
                image = Image.open(masked_path + images[index]).convert('RGB')
                img_label = np.asfarray(image).reshape((-1, 3))
                w = self.weights[index].reshape((-1, len(self.tetra_prime)))
                ud, ii = np.unique(img_label, return_index=True, axis=0)
                ud = ud.astype(np.uint8)
                self.weights_dict[ud[:, 0], ud[:, 1], ud[:, 2], :] = w[ii]
            video_name = self.work_path.rsplit("/", 2)[1]
            name = self.work_path + video_name + "-weightsDict"
            np.save(name, self.weights_dict)
            self.weights = None
        else:
            video_name = self.work_path.rsplit("/", 2)[1]
            name = self.work_path + video_name + "-weightsDict"
            np.save(name, self.weights_dict)

    @Slot(str)
    def readWeightsDict(self, weights_dict_path):
        self.weights_dict = np.load(weights_dict_path)
        self.succeedGetWeight.emit()


if __name__ == "__main__":
    pass
