#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu Aug 29 12:27:42 2019

@author: paolo
"""
from numpy import linspace, argmax

def power(l, a):
        return [(0.5*(100-k)**a + 0.5*(100+2*k)**a) for k in l]
    
def findmax(a):
    k = linspace(1,100,1000)
    return argmax(power(k,a))