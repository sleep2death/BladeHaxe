import os
import shutil

import sys
import glob
import copy
import traceback

from PIL import Image
import pyglet
from pyglet.image.codecs.dds import DDSImageDecoder
from pyglet.image.codecs.png import PNGImageEncoder

env=""
OUTPUT = "/output"

PNG = ".png"
DDS = ".dds"

BIN_WIDTH = 2048;
BIN_HEIGHT = 2048;

class Rect:
    def __init__(self, x=0, y=0, w=0, h=0, img = None):
        self.x = x
        self.y = y
        self.w = w
        self.h = h
        self.img = img

    def bottom(self):
        return self.y + self.h

    def right(self):
        return self.x + self.w

    def containsRect(self, rect):
        if (rect.w <= 0 or rect.h <= 0):
        	return rect.x > self.x and rect.y > self.y and rect.right < self.right and rect.bottom < self.bottom
        else:
        	return rect.x >= self.x and rect.y >= self.y and rect.right <= self.right and rect.bottom and self.bottom

    def __str__(self):
        return '''x:%d, y:%d, w:%d, h:%d'''% (self.x, self.y, self.w, self.h)

class Score:
    def __init__(self, score1 = sys.maxint, score2 = sys.maxint):
        self.score1 = score1
        self.score2 = score2

def fun(path):
    global env
    env = path

    if(os.path.exists(path + OUTPUT) and OUTPUT != ""):
        shutil.rmtree(path + OUTPUT)

    os.mkdir(path + OUTPUT)

    rects = ConvertAndMove(path)
    FindSolution(rects)

def ConvertAndMove(path):
    rects = []
    for root, dirs, files in os.walk( path ):
        for file in files:
            name = os.path.splitext(file)[0]
            sufix = os.path.splitext(file)[1]
            if(sufix == DDS):
                o = pyglet.image.load(root + "/"+ name + DDS, decoder=DDSImageDecoder())
                o.get_texture().get_image_data().save(root  + "/"  + name + PNG, encoder=PNGImageEncoder())
                im = Image.open(root  + "/"  + name + PNG)
                im.name = root  + "/"  + name + PNG

                rect = Rect(0, 0, im.size[0], im.size[1], im)
                rect.img = im
                rects.append(rect)
    return rects


def FindSolution(rects, method = 0):
    rects.sort(key=lambda f: f.w * f.h, reverse=True)
    print("Total Rects: " + str(len(rects)))
    packer = MaxRectsBinPacker(1024, 2048)
    packer.insertRects(rects)

class MaxRectsBinPacker:

    def __init__(self, width = 2048, height = 2048, flip = False):
        self.binWidth = width
        self.binHeight = height
        #put the first rect into the free list
        self.usedRects = []
        self.freeRects = []
        self.freeRects.append(Rect(0, 0, self.binWidth, self.binHeight))

        self.allowFlip = flip

    def insertRects(self, rects, method = 0):

        while len(rects) > 0:
            bestScore = Score()
            bestNode = Rect()
            bestRect = None

            for rect in rects:
                score = Score()
                newNode = self.findPositionForNewNodeBestShortSideFit(rect.w, rect.h, score)

                if score.score1 < bestScore.score1 or (score.score1 == bestScore.score1 and score.score2 < bestScore.score2):
                    bestScore.score1 = score.score1
                    bestScore.score2 = score.score2
                    bestNode = newNode
                    bestRect = rect

                if bestRect == None:
                    print("NONE NODE FIND, EXIT")
                    break

            self.placeRect(bestNode)
            rects.remove(bestRect)

        for rect in self.freeRects:
            print(rect)

    def findPositionForNewNodeBestShortSideFit(self, width, height, score):
        bestNode = Rect()
        for rect in self.freeRects:
            if rect.w >= width and rect.h >= height:
                leftoverHoriz = abs(rect.w - width)
                leftoverVert = abs(rect.h - height)
                shortSideFit = min(leftoverHoriz, leftoverVert)
                longSideFit = max(leftoverHoriz, leftoverVert)

                if shortSideFit < score.score1 or (shortSideFit == score.score1 and longSideFit < score.score2):
                    bestNode.x = rect.x
                    bestNode.y = rect.y
                    bestNode.w = width
                    bestNode.h = height
                    score.score1 = shortSideFit
                    score.score2 = longSideFit

        return bestNode

    def placeRect(self, node):
        for rect in self.freeRects:
            if(self.splitFreeNode(rect, node)):
                self.freeRects.remove(rect)

        self.pruneFreeList()
        self.usedRects.append(node)

    def splitFreeNode(self, freeNode, usedNode):
    	# Test with SAT if the rectangles even intersect.
    	if (usedNode.x >= freeNode.x + freeNode.w or \
    		usedNode.x + usedNode.w <= freeNode.x or \
    		usedNode.y >= freeNode.y + freeNode.h or \
    		usedNode.y + usedNode.h <= freeNode.y):
    		return False

        if (usedNode.x < freeNode.x + freeNode.w and usedNode.x + usedNode.w > freeNode.x):
            # New node at the top side of the used node.
            if (usedNode.y > freeNode.y and usedNode.y < freeNode.y + freeNode.h):
                newNode = Rect(freeNode.x, freeNode.y, freeNode.w, freeNode.h)
                newNode.h = usedNode.y - newNode.y
                self.freeRects.append(newNode)
                #print("append: top")

            # New node at the bottom side of the used node.
            if (usedNode.y + usedNode.h < freeNode.y + freeNode.h):
                newNode = Rect(freeNode.x, freeNode.y, freeNode.w, freeNode.h)
                newNode.y = usedNode.y + usedNode.h
                newNode.h = freeNode.y + freeNode.h - (usedNode.y + usedNode.h)
                self.freeRects.append(newNode)
                #print("append: bottom")


        if (usedNode.y < freeNode.y + freeNode.h and usedNode.y + usedNode.h > freeNode.y):
            # New node at the left side of the used node.
            if (usedNode.x > freeNode.x and usedNode.x < freeNode.x + freeNode.w):
                newNode = Rect(freeNode.x, freeNode.y, freeNode.w, freeNode.h)
                newNode.w = usedNode.x - newNode.x
                self.freeRects.append(newNode)
                #print("append: left")

            # New node at the right side of the used node.
            if (usedNode.x + usedNode.w < freeNode.x + freeNode.w):
                newNode = Rect(freeNode.x, freeNode.y, freeNode.w, freeNode.h)
                newNode.x = usedNode.x + usedNode.w
                newNode.w = freeNode.x + freeNode.w - (usedNode.x + usedNode.w)
                self.freeRects.append(newNode)
                #print("append: right")

		return True

    def pruneFreeList(self):
        for rect1 in self.freeRects:
            for rect2 in self.freeRects:
                if rect1 != rect2:
                    if(rect1.containsRect(rect2)):
                        self.freeRects.remove(rect2)

fun(r'./assets/fashi')
