from enum import IntEnum
import tempfile
from libc.stdlib cimport malloc, free
from PIL import Image as PImage

cdef extern from "texgenpack_py.h":
	ctypedef unsigned int uint64_t
	ctypedef unsigned int uint32_t

	ctypedef struct Image:
		unsigned int* pixels
		int	width
		int	height
		int	extended_width
		int	extended_height
		int	alpha_bits			# 0 for no alpha, 1 if alpha is limited to 0 and 0xFF, 8 otherwise.
		int	nu_components		# Indicates the number of components.
		int	bits_per_component	# 8 or 16.
		int	is_signed			# 1 if the components are signed, 0 if unsigned.
		int	srgb				# Whether the image is stored in sRGB format.
		int	is_half_float		# The image pixels are combinations of half-floats. The pixel size is 64-bit.

	#void load_image(const char* filename, int filetype, Image* image)
	#void save_image(Image* image, const char* filename, int filetype)
	void convert_stexture_to_simage(const char* filename, int filetype, const char* dstname); 

class FileType(IntEnum):
	UNDEFINED		=	0x000
	IMAGE_UNKNOWN	=	0x100
	PNG				=	0x101
	PPM				=	0x102
	KTX				=	0x210
	PKM				=	0x201
	DDS				=	0x212
	ASTC			=	0x203


class File:
	def __init__(self, data, filetype : FileType):
		self.data  = data
		self.filetype = filetype

	def decompress(self, dst_filetype : FileType = FileType.PNG):
		# init
		cdef Image *image = <Image *> malloc(sizeof(Image))

		src = tempfile.NamedTemporaryFile(suffix=self.filetype.name.lower(), delete=True)
		dst = tempfile.NamedTemporaryFile(suffix=dst_filetype.name.lower(), delete=True)

		#write image data to tempfile
		src.write(self.data)

		#load temp file as texture -> image
		#load_image(<const char *>src.name, <int> self.filetype, *image)

		#save image as png
		#save_image(*image, <const char> *dst.name, <int> dst_filetype)

		#alternative - convert file
		#cdef const char* src_name = src.name
		#cdef const char* dst_name = dst.name
		#convert_stexture_to_simage(src_name, <int> self.filetype,dst_name)

		#load converted file via pillow
		img = PImage.open(dst.name)
		
		#delete tempfiles
		src.close()
		dst.close()
		
		return img

class FileTypeBit(IntEnum):
	IMAGE_BIT		=	0x100
	TEXTURE_BIT		=	0x200
	MIPMAPS_BIT		=	0x010

class TextureBit(IntEnum):
	ALPHA_BIT	=	0x0020
	ETC_BIT		=	0x0100
	DXTC_BIT	=	0x0200
	_128BIT_BIT	=	0x0040
	_16_BIT_COMPONENTS_BIT	=	0x0400
	SIGNED_BIT	=	0x0800
	SRGB_BIT	=	0x1000
	UNCOMPRESSED_BIT	=	0x2000
	HALF_FLOAT_BIT	=	0x4000
	ASTC_BIT	=	0x8000

class TextureType(IntEnum):
	UNCOMPRESSED_RGB8			=	0x2000
	UNCOMPRESSED_RGBA8			=	0x2021
	UNCOMPRESSED_ARGB8 			=	0x2022
	UNCOMPRESSED_RGB_HALF_FLOAT		=	0x6402
	UNCOMPRESSED_RGBA_HALF_FLOAT 	=	0x6422
	UNCOMPRESSED_RG16			=	0x2400
	UNCOMPRESSED_RG_HALF_FLOAT	=	0x6800
	UNCOMPRESSED_R16			=	0x2401
	UNCOMPRESSED_R_HALF_FLOAT	=	0x6400
	UNCOMPRESSED_RG8			=	0x2001
	UNCOMPRESSED_R8				=	0x2002
	UNCOMPRESSED_SIGNED_RG16	=	0x2C00
	UNCOMPRESSED_SIGNED_R16		=	0x2C01
	UNCOMPRESSED_SIGNED_RG8		=	0x2801
	UNCOMPRESSED_SIGNED_R8		=	0x2802
	ETC1			=	0x0100
	ETC2_RGB8		=	0x0101
	ETC2_EAC		=	0x0162
	ETC2_PUNCHTHROUGH	=	0x0123
	R11_EAC			=	0x0400
	RG11_EAC		=	0x0440
	SIGNED_R11_EAC	=	0x0C00
	SIGNED_RG11_EAC	=	0x0C40
	ETC2_SRGB8		=	0x1104
	ETC2_SRGB_PUNCHTHROUGH	=	0x1125
	ETC2_SRGB_EAC	=	0x1166
	DXT1			=	0x0200
	DXT3			=	0x0261
	DXT5			=	0x0262
	DXT1A			=	0x0223
	BPTC			=	0x0064
	BPTC_FLOAT		=	0x4445
	BPTC_SIGNED_FLOAT	=	0x4C46
	RGTC1			=	0x0001
	SIGNED_RGTC1	=	0x0C01
	RGTC2			=	0x0041
	SIGNED_RGTC2	=	0x0C41
	RGBA_ASTC_4X4	=	0x8000
	RGBA_ASTC_5X4	=	0x8001
	RGBA_ASTC_5X5	=	0x8002
	RGBA_ASTC_6X5	=	0x8003
	RGBA_ASTC_6X6	=	0x8004
	RGBA_ASTC_8X5	=	0x8005
	RGBA_ASTC_8X6	=	0x8006
	RGBA_ASTC_8X8	=	0x8007
	RGBA_ASTC_10X5	=	0x8008
	RGBA_ASTC_10X6	=	0x8009
	RGBA_ASTC_10X8	=	0x800A
	RGBA_ASTC_10X10	=	0x800B
	RGBA_ASTC_12X10	=	0x800C
	RGBA_ASTC_12X12	=	0x800D
	SRGB8_ALPHA8_ASTC_4X4	=	0x9000