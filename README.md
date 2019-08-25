# texgen_py
A cython wrapper around [texgenpack](https://github.com/hglm/texgenpack).
EAC and RGTC textures aren't supported.

## usage
```python
from texgenpy import TexImage

# open texture
tex = TexImage(filepath)

# get pillow image
img = tex.image
```