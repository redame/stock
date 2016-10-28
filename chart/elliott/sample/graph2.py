#!/bin/env python
# coding:utf-8

#
import matplotlib.pyplot as plt
import numpy as np

t = np.linspace(-np.pi*2, np.pi*2, 1000)

x1 = np.sin(2*t)
x2 = np.cos(2*t)

fig, (axL, axR) = plt.subplots(ncols=2, figsize=(10,4), sharex=True)

axL.plot(t, x1, linewidth=2)
axL.set_title('sin')
axL.set_xlabel('t')
axL.set_ylabel('x')
axL.set_xlim(-np.pi, np.pi)
axL.grid(True)

axR.plot(t, x2, linewidth=2)
axR.set_title('cos')
axR.set_xlabel('t')
axR.set_ylabel('x')
axR.grid(True)

#fig.show()
plt.show()

