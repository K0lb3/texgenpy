from PIL import Image as PILImage
from texgen cimport *

KNOWN_FILE_TYPES = {
    "PNG": 0x101,
    "PPM": 0x102,
    "KTX": 0x210,
    "PKM": 0x201,
    "DDS": 0x212,
    "ASTC": 0x203,
}

cdef class TexImage:
    cdef Image image

    def __init__(self, src, filetype = -1):
        """
        :param src: filepath or bytes
        :param filetype: PNG/KTX/PKM/DDS/ASTC, -1 = auto (filepath only)
        """
        if isinstance(filetype, str):
            filetype = KNOWN_FILE_TYPES.get(filetype.upper(), -1)
        if isinstance(src, str):
            self.load_file(src, filetype)
        elif isinstance(src, bytes):
            self.load_bytes(src, filetype)

    def load_bytes(self, data : bytes, filetype : int = -1):
        cdef Buffer buf
        if filetype == -1:
            raise TypeError('The file type has to be set for bytes input.')
        buf.ptr = <size_t> 0
        buf.len = <size_t> len(data)
        buf.data = <unsigned char*> data
        load_image_from_memory(&buf, <int> filetype, &self.image)

    def load_file(self, srcfile : str, filetype : int = -1):
        if filetype == -1:
            filetype = KNOWN_FILE_TYPES.get(srcfile.rsplit('.')[1].upper(), 0x000)
        # convert filepath to const char
        src_b = (u"%s" % srcfile).encode('ascii')
        cdef const char*src = src_b
        load_image(src, <int> filetype, &self.image)

    @property
    def width(self) -> int:
        return self.image.width

    @property
    def height(self) -> int:
        return self.image.height

    @property
    def pixels(self) -> list[int]:
        return [self.image.pixels[x] for x in range(self.image.width * self.image.height)]

    @property
    def extended_width(self) -> int:
        return self.image.extended_width,

    @property
    def extended_height(self) -> int:
        return self.image.extended_height,

    @property
    def alpha_bits(self) -> int:
        return self.image.alpha_bits,

    @property
    def nu_components(self) -> int:
        return self.image.nu_components,

    @property
    def bits_per_component(self) -> int:
        return self.image.bits_per_component,

    @property
    def is_signed(self) -> bool:
        return True if self.image.is_signed else False,

    @property
    def srgb(self) -> bool:
        return True if self.image.srgb else False,

    @property
    def is_half_float(self) -> bool:
        return True if self.image.is_half_float else False,

    @property
    def image(self) -> PILImage:
        # prepare tmp image in case of required conversion
        cdef Image tmp_image
        clone_image(&self.image, &tmp_image)

        # convert image type
        if tmp_image.is_half_float:
            convert_image_from_half_float(&tmp_image, 0, 1.0, 1.0)
        elif tmp_image.bits_per_component != 8:
            print("Error -- cannot write PNG file with non 8-bit components.\n")
            return None

        if tmp_image.nu_components == 1:  #grayscale
            img = PILImage.new('L', (tmp_image.width, tmp_image.height))
            img_data = img.load()
            for y in range(tmp_image.height):
                for x in range(tmp_image.width):
                    img_data[y, x] = (tmp_image.pixels[y * tmp_image.height + x])
        elif tmp_image.alpha_bits > 0:
            img = PILImage.new('RGBA', (tmp_image.width, tmp_image.height))
            img_data = img.load()
            for y in range(tmp_image.height):
                for x in range(tmp_image.width):
                    img_data[y, x] = calc_color_rgba(tmp_image.pixels[y * tmp_image.height + x])
        else:
            img = PILImage.new('RGB', (tmp_image.width, tmp_image.height))
            img_data = img.load()
            for y in range(tmp_image.height):
                for x in range(tmp_image.width):
                    img_data[y, x] = calc_color(tmp_image.pixels[y * tmp_image.height + x])
        return img

def calc_color(color : int):
    red = color & 0xFF
    green = (color >> 8) & 0xFF
    blue = (color >> 16) & 0xFF
    return red, green, blue

def calc_color_rgba(color : int):
    red = color & 0xFF
    green = (color >> 8) & 0xFF
    blue = (color >> 16) & 0xFF
    alpha = (color >> 24) & 0xFF
    return red, green, blue, alpha
