# This Python file uses the following encoding: utf-8

from __future__ import print_function, division
from PySide6 import QtTest
import time
import warnings
import json
import time
import PIL.Image as Image
import scipy.sparse
import scipy
from scipy.spatial import ConvexHull
from scipy.spatial import Delaunay
from scipy.optimize import *
import numpy as np
from multiprocessing import Pool
from multiprocessing.dummy import Pool as ThreadPool
import pyximport
# pyximport.install(reload_support=True)
pyximport.install()
from GteDistPointTriangle import *


def recover_ASAP_weights_using_scipy_delaunay(Hull_vertices, data, option=1):
    ###modified from https://codereview.stackexchange.com/questions/41024/faster-computation-of-barycentric-coordinates-for-many-points (Gareth Rees)
    # Load points
    points = Hull_vertices
    # Load targets
    targets = data
    ntargets = len(targets)

    start = time.time()
    # Compute Delaunay triangulation of points.
    tri = Delaunay(points)

    end1 = time.time()

    # Find the tetrahedron containing each target (or -1 if not found)
    tetrahedra = tri.find_simplex(targets, tol=1e-6)
    #     print tetrahedra[tetrahedra==-1]

    # Affine transformation for tetrahedron containing each target
    X = tri.transform[tetrahedra, :data.shape[1]]

    # Offset of each target from the origin of its containing tetrahedron
    Y = targets - tri.transform[tetrahedra, data.shape[1]]

    # First three barycentric coordinates of each target in its tetrahedron.
    # The fourth coordinate would be 1 - b.sum(axis=1), but we don't need it.
    b = np.einsum('...jk,...k->...j', X, Y)
    barycoords = np.c_[b, 1 - b.sum(axis=1)]

    end2 = time.time()

    ############# this is slow for large size weights like N*1000
    if option == 1:
        weights_list = np.zeros((targets.shape[0], points.shape[0]))
        num_tetra = len(tri.simplices)
        all_index = np.arange(len(targets))
        for i in range(num_tetra):
            weights_list[all_index[tetrahedra == i][:, None], np.array(tri.simplices[i])] = barycoords[
                                                                                            all_index[tetrahedra == i],
                                                                                            :]

    elif option == 2:
        rows = np.repeat(np.arange(len(data)).reshape((-1, 1)), len(tri.simplices[0]), 1).ravel().tolist()
        cols = []
        vals = []

        for i in range(len(data)):
            cols += tri.simplices[tetrahedra[i]].tolist()
            vals += barycoords[i].tolist()
        weights_list = scipy.sparse.coo_matrix((vals, (rows, cols)), shape=(len(data), len(Hull_vertices))).tocsr()

    elif option == 3:
        rows = np.repeat(np.arange(len(data)).reshape((-1, 1)), len(tri.simplices[0]), 1).ravel()
        # cols = np.empty(rows.shape, rows.dtype)
        # vals = np.empty(rows.shape)

        # d = len(tri.simplices[0])
        # for i in range(len(data)):
        #     cols[d*i:d*(i+1)] = tri.simplices[tetrahedra[i]]
        #     vals[d*i:d*(i+1)] = barycoords[i]

        cols = tri.simplices[tetrahedra].ravel()
        vals = barycoords.ravel()
        weights_list = scipy.sparse.coo_matrix((vals, (rows, cols)), shape=(len(data), len(Hull_vertices))).tocsr()

    end3 = time.time()

    # print(end1 - start, end2 - end1, end3 - end2)
    return weights_list


def Get_ASAP_weights_using_Tan_2016_triangulation_and_then_barycentric_coordinates(img_label_origin,
                                                                                   origin_order_tetra_prime, outprefix="",
                                                                                   order=0,
                                                                                   img_shape=None,
                                                                                   ii=None):
    img_label = img_label_origin.copy()  ### do not modify img_label_origin

    if isinstance(order, (list, tuple, np.ndarray)):
        pass

    elif order == 0:  ## use black as first pigment
        diff = abs(origin_order_tetra_prime - np.array([[0, 0, 0]])).sum(axis=-1)
        order = np.argsort(diff)

    elif order == 1:  ## use white
        diff = abs(origin_order_tetra_prime - np.array([[1, 1, 1]])).sum(axis=-1)
        order = np.argsort(diff)

    tetra_prime = origin_order_tetra_prime[order]
    # print(tetra_prime[0])
    if img_shape is None:
        img_shape = img_label.shape
    img_label = img_label.reshape((-1, 3))
    img_label_backup = img_label.copy()

    hull = ConvexHull(tetra_prime)
    test_inside = Delaunay(tetra_prime)
    label = test_inside.find_simplex(img_label, tol=1e-8)
    # print(len(label[label==-1]))

    ### modify img_label[] to make all points are inside the simplified convexhull
    for i in range(img_label.shape[0]):
        #     print i
        if label[i] < 0:
            dist_list = []
            cloest_points = []
            for j in range(hull.simplices.shape[0]):
                result = DCPPointTriangle(img_label[i], hull.points[hull.simplices[j]])
                dist_list.append(result['distance'])
                cloest_points.append(result['closest'])
            dist_list = np.asarray(dist_list)
            index = np.argmin(dist_list)
            img_label[i] = cloest_points[index]



    ### assert
    test_inside = Delaunay(tetra_prime)
    label = test_inside.find_simplex(img_label, tol=1e-8)
    # assert (len(label[label == -1]) == 0)

    ### colors2xy dict
    colors2xy = {}
    unique_image_label = list(set(list(tuple(element) for element in img_label)))

    for element in unique_image_label:
        colors2xy.setdefault(tuple(element), [])

    for index in range(len(img_label)):
        element = img_label[index]
        colors2xy[tuple(element)].append(index)

    unique_colors = np.array(list(colors2xy.keys()))
    unique_image_label = unique_colors.copy()
    vertices_list = tetra_prime

    tetra_pixel_dict = {}
    for face_vertex_ind in hull.simplices:
        # print face_vertex_ind
        if (face_vertex_ind != 0).all():
            i, j, k = face_vertex_ind
            tetra_pixel_dict.setdefault(tuple((i, j, k)), [])

    index_list = np.array(list(np.arange(len(unique_image_label))))

    for face_vertex_ind in hull.simplices:
        if (face_vertex_ind != 0).all():
            # print face_vertex_ind
            i, j, k = face_vertex_ind
            tetra = np.array([vertices_list[0], vertices_list[i], vertices_list[j], vertices_list[k]])
            try:
                #### use try here, because sometimes the tetra is nearly flat, will cause qhull error to stop, we do not want to stop, we just skip.
                #             print (tetra)
                test_Del = Delaunay(tetra)
                # print len(index_list)
                if len(index_list) != 0:
                    label = test_Del.find_simplex(unique_image_label[index_list], tol=1e-8)
                    # label = test_Del.find_simplex(unique_image_label[index_list])
                    chosen_index = list(index_list[label >= 0])
                    tetra_pixel_dict[tuple((i, j, k))] += chosen_index
                    index_list = np.array(list(set(index_list) - set(chosen_index)))
            except Exception as e:
                pass
                # print (tetra)
                # print (e)

    # print index_list
    # print(len(index_list))
    assert (len(index_list) == 0)

    pixel_num = 0
    for key in tetra_pixel_dict:
        pixel_num += len(tetra_pixel_dict[key])
    # print pixel_num
    assert (pixel_num == unique_image_label.shape[0])

    ### input is like (0,1,2,3,4) then shortest_path_order is (1,2,3,4), 0th is background color, usually is white
    shortest_path_order = tuple(np.arange(len(tetra_prime))[1:])
    # print shortest_path_order

    unique_weights_list = np.zeros((unique_image_label.shape[0], len(tetra_prime)))

    for vertice_tuple in tetra_pixel_dict:
        # print vertice_tuple
        vertice_index_inglobalorder = np.asarray(shortest_path_order)[
            np.asarray(sorted(list(shortest_path_order).index(s) for s in vertice_tuple))]
        vertice_index_inglobalorder_tuple = tuple(list(vertice_index_inglobalorder))
        # print vertice_index_inglobalorder_tuple

        colors = np.array([vertices_list[0],
                           vertices_list[vertice_index_inglobalorder_tuple[0]],
                           vertices_list[vertice_index_inglobalorder_tuple[1]],
                           vertices_list[vertice_index_inglobalorder_tuple[2]]
                           ])

        pixel_index = np.array(tetra_pixel_dict[vertice_tuple])
        if len(pixel_index) != 0:
            arr = unique_image_label[pixel_index]
            Y = recover_ASAP_weights_using_scipy_delaunay(colors, arr)
            unique_weights_list[
                pixel_index[:, None], np.array([0] + list(vertice_index_inglobalorder_tuple))] = Y.reshape(
                (arr.shape[0], -1))

    #### from unique weights to original shape weights
    mixing_weights = np.zeros((len(img_label), len(tetra_prime)))
    for index in range(len(unique_image_label)):
        element = unique_image_label[index]
        index_list = colors2xy[tuple(element)]
        mixing_weights[index_list, :] = unique_weights_list[index, :]

    # barycentric_weights=barycentric_weights.reshape((img_shape[0],img_shape[1],-1))
    origin_order_mixing_weights = np.ones(mixing_weights.shape)
    #### to make the weights order is same as orignal input vertex order
    origin_order_mixing_weights[:, order] = mixing_weights
    if ii is not None:
        origin_order_mixing_weights = origin_order_mixing_weights[ii]

    return origin_order_mixing_weights


def get_one_image_weight(image_path, tetra_prime):
    image = Image.open(image_path).convert('RGB')
    img_label = np.asfarray(image)
    img_shape = img_label.shape
    img_label = img_label.reshape((-1, 3))
    ud, ii = np.unique(img_label, return_inverse=True, axis=0)
    w = Get_ASAP_weights_using_Tan_2016_triangulation_and_then_barycentric_coordinates(ud / 255.0, tetra_prime)
    w = w[ii]
    w = w.reshape((img_shape[0], img_shape[1], -1))
    return w


def get_images_weight(work_path, tetra_prime):  # tetra_prime value is 0-1
    start = time.perf_counter()
    masked_path = work_path + "masked/"
    import os
    # paths = [masked_path + img for img in os.listdir(masked_path)]
    paths = []
    for item in os.listdir(masked_path):
        paths.append((masked_path + item, tetra_prime))
    p = Pool(8)
    weights = p.starmap_async(get_one_image_weight, paths)

    while not weights.ready():
        QtTest.QTest.qWait(100)
    print("time: ", time.perf_counter() - start)

    return weights.get()


def get_images_weights_use_dict(work_path, tetra_prime):
    start = time.perf_counter()
    masked_path = work_path + "masked/"
    weights_dict = np.ones((256, 256, 256, len(tetra_prime)))
    ones_weight = np.ones((len(tetra_prime)))
    import os
    t = 0
    for img_item in os.listdir(masked_path):
        image = Image.open(masked_path + img_item).convert('RGB')
        img_label = np.asfarray(image).astype(np.uint8)
        img_shape = img_label.shape
        img_label = img_label.reshape((-1, 3))
        ud = np.unique(img_label, axis=0)
        # tmp = []
        # for rgb in ud[:, ]:
        #     if np.sum(weights_dict[rgb[0], rgb[1], rgb[2]]) == 0:
        #         tmp.append(rgb)
        #         weights_dict[rgb[0], rgb[1], rgb[2]] = [1, 1, 1, 1, 1, 1]
        i = (weights_dict[ud[:, 0], ud[:, 1], ud[:, 2]] == ones_weight)[:, 0]
        ud = ud[i]
        w = Get_ASAP_weights_using_Tan_2016_triangulation_and_then_barycentric_coordinates(ud / 255.0, tetra_prime)
        weights_dict[ud[:, 0], ud[:, 1], ud[:, 2], :] = w

    print("time: ", time.perf_counter() - start)
    return weights_dict


def images_recolor_use_dict(work_path, weights_dict, palette, object_color=None, recolor_again=False):
    start = time.perf_counter()
    images_path = work_path + "images/"
    if recolor_again:
        images_path = work_path + "recolored/"
    masks_path = work_path + "masks/"
    recolored_path = work_path + "recolored/"
    import os
    if not os.path.exists(recolored_path):
        os.makedirs(recolored_path)

    def one_image_recolor_use_dict(img_item):
        img_path = os.path.join(images_path, img_item)
        img_label = np.asfarray(Image.open(img_path).convert('RGB'))
        img_shape = img_label.shape
        img_label_tmp = img_label.copy()
        mask_path = os.path.join(masks_path, img_item[:-4] + '.png')
        img_label_tmp = img_label_tmp.reshape((-1, 3)).astype(np.uint8)
        weight = weights_dict[img_label_tmp[:, 0], img_label_tmp[:, 1], img_label_tmp[:, 2], :]
        recolored_label = (weight.reshape((img_shape[0], img_shape[1], -1, 1)) * palette.reshape((1, 1, -1, 3))).sum(
            axis=2)
        recolored_label = (recolored_label * 255).round().clip(0, 255).astype(np.uint8)
        # recolored_label = np.where(mask_label == 0, img_label, recolored_label)
        if object_color is None:
            mask_label = np.asfarray(Image.open(mask_path).convert('L'))
            recolored_label[np.where(mask_label == 0)] = img_label[np.where(mask_label == 0)]
        else:
            mask_label = np.asfarray(Image.open(mask_path).convert('RGB'))
            recolored_label[~np.all(mask_label == object_color, axis=-1)] = img_label[~np.all(mask_label == object_color, axis=-1)]
        recolored_label = np.ascontiguousarray(recolored_label)
        Image.fromarray(recolored_label.astype(np.uint8)).save(os.path.join(recolored_path, img_item[:-4] + '.png'))

    with ThreadPool(16) as p:
        p.map(one_image_recolor_use_dict, os.listdir(images_path))
    print("time: ", time.perf_counter() - start)
    return time.perf_counter() - start


def images_recolor(work_path, weights, palette, object_color=None, recolor_again=False):  # palette value is 0-1
    start = time.perf_counter()
    images_path = work_path + "images/"
    if recolor_again:
        images_path = work_path + "recolored/"
    masks_path = work_path + "masks/"
    recolored_path = work_path + "recolored/"
    import os
    if not os.path.exists(recolored_path):
        os.makedirs(recolored_path)

    def one_image_recolor(img_item, weight):
        img_path = os.path.join(images_path, img_item)
        img_label = np.asfarray(Image.open(img_path).convert('RGB'))
        img_shape = img_label.shape
        mask_path = os.path.join(masks_path, img_item[:-4] + '.png')
        recolored_label = (weight.reshape((img_shape[0], img_shape[1], -1, 1)) * palette.reshape((1, 1, -1, 3))).sum(
            axis=2)
        recolored_label = (recolored_label * 255).round().clip(0, 255).astype(np.uint8)
        # recolored_label = np.where(mask_label == 0, img_label, recolored_label)
        if object_color is None:
            mask_label = np.asfarray(Image.open(mask_path).convert('L'))
            recolored_label[np.where(mask_label == 0)] = img_label[np.where(mask_label == 0)]
        else:
            mask_label = np.asfarray(Image.open(mask_path).convert('RGB'))
            recolored_label[~np.all(mask_label == object_color, axis=-1)] = img_label[~np.all(mask_label == object_color, axis=-1)]
        recolored_label = np.ascontiguousarray(recolored_label)
        Image.fromarray(recolored_label.astype(np.uint8)).save(os.path.join(recolored_path, img_item[:-4] + '.png'))

    images = os.listdir(images_path)
    it = []
    for i in range(len(images)):
        it.append((images[i], weights[i]))

    with ThreadPool(16) as p:
        p.starmap(one_image_recolor, it)
    print("time: ", time.perf_counter() - start)
    return time.perf_counter() - start


if __name__ == "__main__":
    print("-----Debug-----")
    start = time.perf_counter()

    wp = "C:/Users/Administrator/Documents/Code/XMem/workspace/harmoe/"
    vertices_path = wp + "harmoe-final_simplified_hull_clip-06.js"
    tetra_prime = np.asfarray(json.load(open(vertices_path))['vs'])
    tetra_prime = tetra_prime / 255.0
    # w = get_images_weights_use_dict(wp, tetra_prime)
    # np.save(wp + "test", w)
    w = np.load(wp + "test.npy")
    start = time.perf_counter()
    recolor_palette = tetra_prime.copy()
    recolor_palette[5] = [0., 0.02, 0.99]
    images_recolor_use_dict(wp, w, recolor_palette)
    # wp = "C:/Users/Administrator/Documents/Code/XMem/workspace/harmoe/"
    # vertices_path = wp + "harmoe-final_simplified_hull_clip-06.js"
    # tetra_prime = np.asfarray(json.load(open(vertices_path))['vs'])
    # tetra_prime = tetra_prime / 255.0
    # weights = get_images_weight(wp, tetra_prime)
    # print("frame num: ", len(weights))
    # print("one frame weight shape", weights[0].shape)
    # print("time: ", time.perf_counter() - start)
    # mixing_weights_filename = wp + 'harmoe-' + str(
    #     len(tetra_prime)) + "-RGB_ASAP-using_Tan2016_triangulation_and_then_barycentric_coordinates-linear_mixing-weights.js"
    # with open(mixing_weights_filename, 'w') as myfile:
    #     for weight in weights:
    #         json.dump({'weights': weight.tolist()}, myfile, indent=0)

    # img_path = "C:/Users/Administrator/Documents/Code/Decompose-Single-Image-Into-Layers/examples/0000000.png"
    # vertices_path = "C:/Users/Administrator/Documents/Code/Decompose-Single-Image-Into-Layers/examples/0000000-final_simplified_hull_clip-06.js"
    # output_path = "./ex/test"
    # images = Image.open(img_path).convert('RGB')
    # tetra_prime = np.asfarray(json.load(open(vertices_path))['vs'])
    # tetra_prime = tetra_prime / 255.0
    # img_label = np.asfarray(images)
    # img_shape = img_label.shape
    # img_label = img_label.reshape((-1, 3))
    # ud, ii, pc = np.unique(img_label, return_inverse=True, return_counts=True, axis=0)
    # print("Img original shape", img_label.shape)
    # print("Unique data shape", ud.shape)
    # w = Get_ASAP_weights_using_Tan_2016_triangulation_and_then_barycentric_coordinates(ud / 255.0, tetra_prime)
    # w = w[ii]
    # w = w.reshape((img_shape[0], img_shape[1], -1))
    # print(tetra_prime)
    # recolor_palette = tetra_prime.copy()
    # # recolor_palette[5] = [0., 0.02, 0.99]
    # temp = (w.reshape((img_shape[0], img_shape[1], -1, 1)) * recolor_palette.reshape((1, 1, -1, 3))).sum(
    #     axis=2)
    # Image.fromarray((temp * 255).round().clip(0, 255).astype(np.uint8)).save("./test-composited.png")
    # start = time.perf_counter()
    # recolor_palette = tetra_prime.copy()
    # recolor_palette[5] = [0., 0.02, 0.99]
    # images_recolor(wp, weights, recolor_palette)
    # print("time: ", time.perf_counter() - start)
