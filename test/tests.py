from texgenpy import TexImage
from PIL import Image
import os

RES = os.path.join(os.path.dirname(__file__),'res')
TEST_PNG_RGB = Image.open(os.path.join('RES','test-texture.png'))
TEST_PNG_RGBA = Image.open(os.path.join('RES','test-texture-transparent.png'))

i = 1
for fp in os.listdir(RES):
	if fp[-4:] == '.png':
		continue
	try:
		tex = TexImage(os.path.join(RES, fp))
		img = tex.image


		if img: 
			if img.mode == 'RGB':
				comp = TEST_PNG_RGB
			elif img.mode == 'RGBA':
				comp = TEST_PNG_RGBA
			else:
				comp = TEST_PNG_RGB
			res = 'SUCCESS'
		else:
			res = 'FAIL'
	except:
		res = 'FAIL'
	finally:
		print('%s. %s - %s'%(i, fp, res))
		i += 1


