# coding:utf-8

__author__ = 'kunihiro'

class ArrayUtils:
    @classmethod
    def splice(cls, array, start, num):
        return array[0: start] + array[start + num: len(array)]
