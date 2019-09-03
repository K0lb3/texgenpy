/*

Copyright (c) 2015 Harm Hanemaaijer <fgenfb@yahoo.com>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

*/

#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#ifndef __clang__
# include <malloc.h>
#endif
#include "texgenpack.h"
#include "decode.h"
#include "packing.h"

void load_image_from_memory(Buffer *buf, int filetype, Image *image) {
	if (filetype & FILE_TYPE_TEXTURE_BIT) {
		Texture texture;
		switch (filetype) {
		case FILE_TYPE_PKM :
			load_pkm_buffer(buf, &texture);
			break;
		case FILE_TYPE_KTX :
			load_ktx_buffer(buf, 1, &texture);
			break;
		case FILE_TYPE_DDS :
			load_dds_buffer(buf, 1, &texture);
			break;
		case FILE_TYPE_ASTC :
			load_astc_buffer(buf, &texture);
			break;
		default :
			printf("Error -- no support for loading texture file format.\n");
			exit(1);
		}
		const char *texture_type_str = texture_type_text(texture.type);
		if (!option_quiet)
			printf("Texture format: %s\n", texture_type_str);
		set_texture_decoding_function(&texture, NULL);
		convert_texture_to_image(&texture, image);
		destroy_texture(&texture);
	}
	else {
		switch (filetype) {
//		case FILE_TYPE_PPM :
//			load_ppm_file(filename, image);
//			break;
		default :
			printf("Error -- no support for loading image file format.\n");
			exit(1);
		}
		// Optionally convert to half-float format.
		if (option_half_float)
			convert_image_to_half_float(image);
	}
}

// Load a .pkm texture.

void load_pkm_buffer(Buffer *f, Texture *texture) {
	if (!option_quiet)
		printf("Reading .pkm file.\n");
	//FILE *f = fopen(filename, "rb");
	unsigned char header[16];
	bufread(header, 1, 16, f);
	if (header[0] != 'P' || header[1] != 'K' || header[2] != 'M' || header[3] != ' ') {
		printf("Error -- couldn't find PKM signature.\n");
		exit(1);
	}
	int texture_type = ((int)header[6] << 8) | header[7];
	if (texture_type != 0 && texture_type != 1) {
		printf("Error -- unsupported format (only ETC1 and ETC2 RGB8 supported).\n");
		exit(1);
	}
	int ext_width = ((int)header[8] << 8) | header[9];
	int ext_height = ((int)header[10] << 8) | header[11];
	int width = ((int)header[12] << 8) | header[13];
	int height = ((int)header[14] << 8) | header[15];
	int n = (ext_width / 4) * (ext_height / 4);
	texture->bits_per_block = 64;
	texture->pixels = (unsigned int *)malloc(n * (texture->bits_per_block / 8));
	if (bufread(texture->pixels, 1, n * (texture->bits_per_block / 8), f) < n * (texture->bits_per_block / 8)) {
		printf("Error reading file.\n");
		exit (1);
	}
	//fclose(f);
	texture->extended_width = ext_width;
	texture->extended_height = ext_height;
	texture->width = width;
	texture->height = height;
	texture->block_width = 4;
	texture->block_height = 4;
	if (texture->type == 0)
		texture->type = TEXTURE_TYPE_ETC1;
	else
		texture->type = TEXTURE_TYPE_ETC2_RGB8;
}

// Load a .ktx texture. At most max_mipmaps are stored in the array of Textures texture. The number of
// mipmaps loaded is returned.

static unsigned char ktx_id[12] = { 0xAB, 0x4B, 0x54, 0x58, 0x20, 0x31, 0x31, 0xBB, 0x0D, 0x0A, 0x1A, 0x0A };

int load_ktx_buffer(Buffer *f, int max_mipmaps, Texture *texture) {
	if (!option_quiet)
		printf("Reading .ktx file.\n");
	//FILE *f = fopen(filename, "rb");
	int header[16];
	bufread(header, 1, 64, f);
	if (memcmp(header, ktx_id, 12) != 0) {
		printf("Error -- couldn't find KTX signature.\n");
		exit(1);
	}
	int wrong_endian = 0;
	if (header[3] == 0x01020304) {
		// Wrong endian .ktx file.
		wrong_endian = 1;
		for (int i = 3; i < 16; i++) {
			unsigned char *b = (unsigned char *)&header[i];
			unsigned char temp = b[0];
			b[0] = b[3];
			b[3] = temp;
			temp = b[1];
			b[1] = b[2];
			b[2] = temp;
		}
	}
	int type;
	int glType = header[4];
	int glFormat = header[6];
	int glInternalFormat = header[7];
	int pixelDepth = header[11];
	TextureInfo *info = match_ktx_id(glInternalFormat, glFormat, glType);
	if (info == NULL) {
		printf("Error -- unsupported format in .ktx file (glInternalFormat = 0x%04X).\n", glInternalFormat);
		exit(1);
	}
	type = info->type;
	if (type == TEXTURE_TYPE_DXT1 && option_texture_format == TEXTURE_TYPE_DXT1A) {
		info = match_texture_type(TEXTURE_TYPE_DXT1A);
		type = TEXTURE_TYPE_DXT1A;
	}
	int bits_per_block = info->internal_bits_per_block;
	int block_width = info->block_width;
	int block_height = info->block_height;
	int ktx_block_size = info->bits_per_block;
	if (!option_quiet)
		printf("File is texture.\n", info->text1);
	int width = header[9];
	int height = header[10];
	int extended_width = ((width + block_width - 1) / block_width) * block_width;
	int extended_height = ((height + block_height - 1) / block_height) * block_height;
	int nu_mipmaps = header[14];
	if (nu_mipmaps > 1 && max_mipmaps == 1) {
		printf("Disregarding mipmaps beyond the first level.\n");
	}
 	if (header[15] > 0) {
		// Skip metadata.
		unsigned char *metadata = (unsigned char *)malloc(header[15]);
		if (bufread(metadata, 1, header[15], f) < header[15]) {
			printf("Error reading metadata.\n");
			exit(1);
		}
		free(metadata);
	}
	for (int i = 0; i < max_mipmaps && i < nu_mipmaps; i++) {
		unsigned char image_size[4];
		int r = bufread(image_size, 1, 4, f);
		if (wrong_endian) {
			unsigned char temp = image_size[0];
			image_size[0] = image_size[3];
			image_size[3] = temp;
			temp = image_size[1];
			image_size[1] = image_size[2];
			image_size[2] = temp;
		}
		int n = (extended_height / block_height) * (extended_width / block_width);
		if (type != TEXTURE_TYPE_UNCOMPRESSED_RGB8 && type != TEXTURE_TYPE_UNCOMPRESSED_RGB_HALF_FLOAT &&
		type != TEXTURE_TYPE_UNCOMPRESSED_R8 &&	type != TEXTURE_TYPE_UNCOMPRESSED_RG8 &&
		type != TEXTURE_TYPE_UNCOMPRESSED_SIGNED_R8 && type != TEXTURE_TYPE_UNCOMPRESSED_SIGNED_RG8 &&
		type != TEXTURE_TYPE_UNCOMPRESSED_R16 && type != TEXTURE_TYPE_UNCOMPRESSED_SIGNED_R16 &&
		type != TEXTURE_TYPE_UNCOMPRESSED_R_HALF_FLOAT &&
		*(int *)&image_size[0] != n * (ktx_block_size / 8)) {
			printf("Error -- image size field of mipmap level %d does not match (%d vs %d).\n",
				i, *(int *)&image_size[0], n * (ktx_block_size / 8));
			exit(1);
		}
		texture[i].info = info;
		texture[i].width = width;
		texture[i].height = height;
		texture[i].extended_width = extended_width;
		texture[i].extended_height = extended_height;
		texture[i].bits_per_block = bits_per_block;
		texture[i].type = type;
		texture[i].block_width = block_width;
		texture[i].block_height = block_height;
		texture[i].pixels = (unsigned int *)malloc(n * (bits_per_block / 8));
		if (bits_per_block != ktx_block_size) {
			// Have to read row by row due to row padding, and convert 24-bit pixels to to 32-bit pixels
			// or 48-bit pixels to 64-bit pixels.
			int bpp = ktx_block_size / 8;
			int row_size = (width * bpp + 3) & ~3;
			int row_size_no_padding = width * bpp; 
			if (*(int *)&image_size[0] != height * row_size) {
				if (*(int *)&image_size[0] == height * row_size_no_padding) {
					// This file violates .ktx specification by have no 32-bit row alignment.
					// Load it anyway.
					printf("Warning: file violates KTX row alignment specification for "
						"uncompressed textures.\n");
					row_size = row_size_no_padding;
				}
				else {
					printf("Error -- image size field of mipmap level %d does not match (%d vs %d).\n",
						i, *(int *)&image_size[0], height * row_size);
					printf("bpp = %d, ktx_block_size == %d\n", bpp, ktx_block_size);
					exit(1);
				}
			}
			unsigned char *row = (unsigned char *)alloca(row_size);
			for (int y = 0; y < height; y++) {
				if (bufread(row, 1, row_size, f) < row_size) {
					printf("Error reading file.\n");
					exit(1);
				}
				for (int x = 0; x < width; x++) {
					unsigned int pixel;
					if (bpp == 3) {
						pixel = pack_rgb_alpha_0xff(row[x * 3], row[x * 3 + 1],	row[x * 3 + 2]);
						texture[i].pixels[y * extended_width + x] = pixel;
					}
					else
					if (bpp == 6) {
						texture[i].pixels[(y * extended_width + x) * 2] = pack_half_float(
							*(unsigned short *)&row[x * 6],
							*(unsigned short *)&row[x * 6 + 2]);
						texture[i].pixels[(y * extended_width + x) * 2 + 1] = pack_half_float(
							*(unsigned short *)&row[x * 6 + 4], 0);
					}
					else
					if (bpp == 2) {
						if (bits_per_block == 64)
							*(uint64_t *)&texture[i].pixels[(y * extended_width + x) * 2] = *(unsigned short *)&row[x * 2];
						else
							// This might present a problem on big-endian systems.
							texture[i].pixels[y * extended_width + x] = *(unsigned short *)&row[x * 2];
					}
					else
					if (bpp == 1)
						texture[i].pixels[y * extended_width + x] = row[x];
					else
					if (bpp == 4 && bits_per_block == 64)
						*(uint64_t *)&texture[i].pixels[(y * extended_width + x) * 2] = pack_half_float(*(uint16_t *)&row[x * 4],
							*(uint16_t *)&row[x * 4 + 2]);
					else {
						printf("Error -- cannot handle combination of internal size and real size of texture data.\n");
							exit(1);
					}
				}
			}
		}
		else
			if (bufread(texture[i].pixels, 1, n * (ktx_block_size / 8), f) < n * (ktx_block_size / 8)) {
				printf("Error reading file.\n");
				exit (1);
			}
		// Divide by two for the next mipmap level, rounding down.
		width >>= 1;
		height >>= 1;
		extended_width = ((width + block_width - 1) / block_width) * block_width;
		extended_height = ((height + block_height - 1) / block_height) * block_height;
		// Read mipPadding. But not if we have already read everything specified.
		char buffer[4];
		if (i + 1 < max_mipmaps && i + 1 < nu_mipmaps)
			bufread(buffer, 1, 3 - ((*(int *)&image_size[0] + 3) % 4), f);
	}
	//fclose(f);
	// Return the number of stored textures.
	if (max_mipmaps < nu_mipmaps)
		return max_mipmaps;
	else
		return nu_mipmaps;
}

// Save a .ktx texture. texture is a pointer to an array of Texture structures.

static char ktx_orientation_key_down[24] = { 'K', 'T', 'X', 'o', 'r', 'i', 'e', 'n', 't', 'a', 't', 'i', 'o', 'n', 0,
	'S', '=', 'r', ',', 'T', '=', 'd', 0, 0 };	// Includes one byte of padding.
static char ktx_orientation_key_up[24] = { 'K', 'T', 'X', 'o', 'r', 'i', 'e', 'n', 't', 'a', 't', 'i', 'o', 'n', 0,
	'S', '=', 'r', ',', 'T', '=', 'u', 0, 0 };	// Includes one byte of padding.

// Load a .dds texture.

int load_dds_buffer(Buffer *f, int max_mipmaps, Texture *texture) {
	if (!option_quiet)
		printf("Reading .dds file.\n");
	//FILE *f = fopen(filename, "rb");
	if (f == NULL) {
		printf("Error opening file.\n");
		exit(1);
	}
	char id[4];
	bufread(id, 1, 4, f);
	if (id[0] != 'D' || id[1] != 'D' || id[2] != 'S' || id[3] != ' ') {
		printf("Error -- couldn't find DDS signature.\n");
		exit(1);
	}
	unsigned char header[124];
	bufread(header, 1, 124, f);
	int width = *(unsigned int *)&header[12];
	int height = *(unsigned int *)&header[8];
	int pitch = *(unsigned int *)&header[16];
	int pixel_format_flags = *(unsigned int *)&header[76];
	int type;
	int block_width = 4;
	int block_height = 4;
	int internal_bits_per_block = 64;
	int dds_block_size = 64;
	int bitcount = *(unsigned int *)&header[84];
	unsigned int red_mask = *(unsigned int *)&header[88];
	unsigned int green_mask = *(unsigned int *)&header[92];
	unsigned int blue_mask = *(unsigned int *)&header[96];
	unsigned int alpha_mask = *(unsigned int *)&header[100];
	char four_cc[5];
	strncpy(four_cc, (char *)&header[80], 4);
	four_cc[4] = '\0';
	unsigned int dx10_format = 0;
	if (strncmp(four_cc, "DX10", 4) == 0) {
		unsigned char dx10_header[20];
		bufread(dx10_header, 1, 20, f);
		dx10_format = *(unsigned int *)&dx10_header[0];
		unsigned int resource_dimension = *(unsigned int *)&dx10_header[4];
		if (resource_dimension != 3) {
			printf("Error -- only 2D textures supported for .dds files.\n");
			exit(1);
		}
	}
	TextureInfo *info = match_dds_id(four_cc, dx10_format, pixel_format_flags, bitcount, red_mask, green_mask, blue_mask, alpha_mask);
	if (info == NULL) {
		printf("Error -- unsupported format in .dds file (fourCC =, DX10 format = %d).\n", four_cc, dx10_format);
		exit(1);
	}
	type = info->type;
	if (type == TEXTURE_TYPE_DXT1 && option_texture_format == TEXTURE_TYPE_DXT1A) {
		info = match_texture_type(TEXTURE_TYPE_DXT1A);
		type = TEXTURE_TYPE_DXT1A;
	}
	internal_bits_per_block = info->internal_bits_per_block;
	block_width = info->block_width;
	block_height = info->block_height;
	dds_block_size = info->bits_per_block;
	if (!option_quiet)
		printf("File is texture.\n", info->text1);
	int extended_width = ((width + block_width - 1) / block_width) * block_width;
	int extended_height = ((height + block_height - 1) / block_height) * block_height;
	unsigned int flags = *(unsigned int *)&header[4];
	int nu_mipmaps = 1;
	if (flags & 0x20000) {
		nu_mipmaps = *(unsigned int *)&header[24];
		if (nu_mipmaps > 1 && max_mipmaps == 1) {
			if (!option_quiet)
				printf("Disregarding mipmaps beyond the first level.\n");
			nu_mipmaps = 1;
		}
	}
	for (int i = 0; i < max_mipmaps && i < nu_mipmaps; i++) {
		int n = (extended_height / block_width) * (extended_width / block_height);
		texture[i].info = info;
		texture[i].width = width;
		texture[i].height = height;
		texture[i].extended_width = extended_width;
		texture[i].extended_height = extended_height;
		texture[i].bits_per_block = info->bits_per_block;	// Real format bits_per_block
		texture[i].type = type;
		texture[i].block_width = block_width;
		texture[i].block_height = block_height;
		if (internal_bits_per_block != dds_block_size) {
			// This happens when we have 24-bit RGB data.
			// Convert to 32-bit.
			int bpp = dds_block_size / 8;
			int row_size = pitch;
			unsigned char *row = (unsigned char *)alloca(row_size);
			texture[i].pixels = (unsigned int *)malloc(n * (internal_bits_per_block / 8));
			for (int y = 0; y < height; y++) {
				if (bufread(row, 1, row_size, f) < row_size) {
					printf("Error reading file.\n");
					exit(1);
				}
				if (bpp == 3)
					for (int x = 0; x < width; x++)
						texture[i].pixels[y * extended_width + x] = pack_rgb_alpha_0xff(
							row[x * 3], row[x * 3 + 1], row[x * 3 + 2]);
				else
				if (bpp == 2)
					for (int x = 0; x < width; x++)
						if (internal_bits_per_block == 64)
							*(uint64_t *)&texture[i].pixels[(y * extended_width + x) * 2] =
								*(unsigned short *)&row[x * 2];
						else
							texture[i].pixels[y * extended_width + x] = pack_r(row[x * 2])  |
								pack_g(row[x * 2 + 1]);
				else
				if (bpp == 1)
					for (int x = 0; x < width; x++)
						texture[i].pixels[y * extended_width + x] = pack_r(row[x]);
				else
				if (bpp == 4 && internal_bits_per_block == 64)
					for (int x = 0; x < width; x++)
						*(uint64_t *)&texture[i].pixels[(y * extended_width + x) * 2] =
							pack_half_float(*(uint16_t *)&row[x * 4],
							*(uint16_t *)&row[x * 4 + 2]);
				else {
					printf("Error -- cannot handle combination of internal size and real size "
						"of texture data.\n");
					exit(1);
				}
			}
		}
		else {
			texture[i].pixels = (unsigned int *)malloc(n * (internal_bits_per_block / 8));
			int r = bufread(texture[i].pixels, 1, n * (internal_bits_per_block / 8), f);
			if (r < n * (internal_bits_per_block / 8)) {
				printf("Error reading file.\n");
				printf("%d bytes read vs. %d requested.\n", r, n * (internal_bits_per_block / 8));
				exit(1);
			}
		}
		// Divide by two for the next mipmap level, rounding down.
		width >>= 1;
		height >>= 1;
		extended_width = ((width + block_width - 1) / block_width) * block_width;
		extended_height = ((height + block_height - 1) / block_height) * block_height;
	}
	//fclose(f);
	// Return the number of stored textures.
	if (max_mipmaps < nu_mipmaps)
		return max_mipmaps;
	else
		return nu_mipmaps;
}

// Load an .astc file.

void load_astc_buffer(Buffer *f, Texture *texture) {
	if (!option_quiet)
		printf("Reading .astc file.\n");
	//FILE *f = fopen(filename, "rb");
	unsigned char header[16];
	bufread(header, 1, 16, f);
	if (header[0] != 0x13 || header[1] != 0xAB || header[2] != 0xA1 || header[3] != 0x5c) {
		printf("Error -- couldn't find ASTC signature.\n");
		exit(1);
	}
	int blockdim_x = header[4];
	int blockdim_y = header[5];
	int blockdim_z = header[6];
	if (blockdim_z != 1) {
		printf("Error -- 3D blocksize not supported.\n");
		exit(1);
	}
	int i = match_astc_block_size(blockdim_x, blockdim_y);
	if (i == - 1) {
		printf("Error -- unrecognized block size in .astc file.\n");
		exit(1);
	}
	texture->block_width = blockdim_x;
	texture->block_height = blockdim_y;
	int width = header[7] + (int)header[8] * 256 + (int)header[9] * 65536;
	int height = header[10] + (int)header[11] * 256 + (int)header[12] * 65536;
	int zsize = header[13] + (int)header[14] * 256 + (int)header[15] * 65536;
	if (zsize != 1) {
		printf("Error -- 3D textures not supported.\n");
		exit(1);
	}
	int xblocks = (width + blockdim_x - 1) / blockdim_x;
	int yblocks = (height + blockdim_y - 1) / blockdim_y;
	int zblocks = (zsize + blockdim_z - 1) / blockdim_z;
	int n = xblocks * yblocks * zblocks;
	texture->pixels = (unsigned int *)malloc(n * 16);
	texture->bits_per_block = 128;
	if (bufread(texture->pixels, 1, n * 16, f) < n * 16) {
		printf("Error reading file.\n");
		exit (1);
	}
	//fclose(f);
	texture->extended_width = xblocks * blockdim_x;
	texture->extended_height = yblocks * blockdim_y;
	texture->width = width;
	texture->height = height;
	texture->type = TEXTURE_TYPE_RGBA_ASTC_4X4 + i;
	texture->info = match_texture_type(texture->type);
}

// Load a .ppm file.

void load_ppm_buffer(Buffer *f, Image *image) {
	if (!option_quiet)
		printf("Reading .ppm file.\n");
	//FILE *f = fopen(filename, "rb");
	//fclose(f);
}

