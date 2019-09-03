from texgenpy import TexImage
from PIL import Image
import os

RES = os.path.join(os.path.dirname(__file__),'res')
TEST_PNG_RGB = Image.open(os.path.join('RES','test-texture.png'))
TEST_PNG_RGBA = Image.open(os.path.join('RES','test-texture-transparent.png'))

TEST = 1

i = 1
for fp in os.listdir(RES):
	if fp[-4:] == '.png':
		continue
	try:
		ip = os.path.join(RES, fp)
		if TEST == 0:
			tex = TexImage(ip)
		elif TEST == 1:
			data = open(ip, 'rb').read()
			tex = TexImage(data, fp[-3:])
		img = tex.image
		#img.show()

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


