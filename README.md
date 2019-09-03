# texgen_py
A cython wrapper for [texgenpack](https://github.com/hglm/texgenpack).

## usage
```python
from texgenpy import TexImage

# open texture via filepath
tex = TexImage(filepath)

# open texture via bytes
data : bytes
filetype :str # PKM, KTX, DDS, ASTC
tex = TexImage(data, filetype)

# get pillow image
img = tex.image
```

## known errors and missing features
* EAC and signed RGTC textures don't work.
* Saving textures doesn't work.

* PNG won't be supported.
