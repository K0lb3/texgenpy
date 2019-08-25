# texgenpy
A cython wrapper around [texgenpack](https://github.com/hglm/texgenpack).
EAC and RGTC textures aren't supported.

Install via
``python setup.py install``
- Cython is required

## usage
```python
from texgenpy import TexImage

# open texture
tex = TexImage(filepath)

# get pillow image
img = tex.image
```
