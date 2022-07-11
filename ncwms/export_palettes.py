#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Export colormaps (cmaps) from python to ncWMS2 format.
"""

import numpy as np
import matplotlib
import cmocean


def rgb2hex(rgb, alpha=100):

    def clamp(x):
        return max(0, min(x, 255))

    r, g, b = rgb

    return "#{:02X}{:02X}{:02X}{:02X}".format(clamp(int(round(255 * alpha / 100))),
                                              clamp(r),
                                              clamp(g),
                                              clamp(b))


def cmap2pal(cmap):

    if hasattr(cmap, 'colors'):
        colors = np.asarray(cmap.colors)
    else:
        colors = cmap(np.linspace(0, 1, 256))[:, 0:3]

    # convert 0-1 to 0-255
    colors = np.round(np.r_[colors] * 255).astype(int)

    # convert to hex
    colors = np.apply_along_axis(rgb2hex, 1, colors)

    return colors


cmaps = [matplotlib.cm.turbo]
cmaps_prefix = 'mpl'

# cmaps = [getattr(cmocean.cm, x) for x in cmocean.cm.cmapnames]
# cmaps_prefix = 'cmocean'

for cmap in cmaps:
    pal = cmap2pal(cmap)

    outfile = f'{cmaps_prefix}-{cmap.name}.pal'
    print(f'Saving {outfile}')
    pal.tofile(outfile, sep='\n', format='%s')
