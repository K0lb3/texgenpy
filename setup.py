import os
from setuptools import Extension, setup

try:
    from Cython.Build import cythonize
except ImportError:
    cythonize = None


def ALL_C(folder, exclude=[]):
    return [
        '/'.join([folder, f])
        for f in os.listdir(folder)
        if f[-2:] == '.c' and f not in exclude
    ]


extensions = [
    Extension(
        name="texgenpy",
        sources=[
            "texgen.pyx",
            *ALL_C('texgenpack'),
        ],
        include_dirs=[
            "texgenpack",
        ],
    )
]
if cythonize:
    extensions = cythonize(extensions)

setup(ext_modules=extensions)
