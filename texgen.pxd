from libcpp cimport bool
from libc.stdint cimport uint8_t, uint32_t, uint64_t

cdef extern from "texgenpack.h":
	cdef unsigned short NU_FILE_TYPES = 6
	
	cdef unsigned short FILE_TYPE_PNG = 0x101
	cdef unsigned short FILE_TYPE_PPM = 0x102
	cdef unsigned short FILE_TYPE_KTX = 0x210
	cdef unsigned short FILE_TYPE_PKM = 0x201
	cdef unsigned short FILE_TYPE_DDS = 0x212
	cdef unsigned short FILE_TYPE_ASTC = 0x203
	cdef unsigned short FILE_TYPE_IMAGE_BIT = 0x100
	cdef unsigned short FILE_TYPE_TEXTURE_BIT = 0x200
	cdef unsigned short FILE_TYPE_MIPMAPS_BIT = 0x010
	cdef unsigned short FILE_TYPE_UNDEFINED = 0x000
	cdef unsigned short FILE_TYPE_IMAGE_UNKNOWN = 0x100
	
	# Structures.
	
	ctypedef struct Image:
		unsigned int *pixels
		int width
		int height
		int extended_width
		int extended_height
		int alpha_bits			# 0 for no alpha, 1 if alpha is limited to 0 and 0xFF, 8 otherwise.
		int nu_components		# Indicates the number of components.
		int bits_per_component		# 8 or 16.
		int is_signed			# 1 if the components are signed, 0 if unsigned.
		int srgb			# Whether the image is stored in sRGB format.
		int is_half_float		# The image pixels are combinations of half-floats. The pixel size is 64-bit.
	
	
	cdef unsigned short TEXTURE_TYPE_UNCOMPRESSED_RGB8 = 0x2000
	cdef unsigned short TEXTURE_TYPE_UNCOMPRESSED_RGBA8 = 0x2021
	cdef unsigned short TEXTURE_TYPE_UNCOMPRESSED_ARGB8 = 0x2022
	cdef unsigned short TEXTURE_TYPE_UNCOMPRESSED_RGB_HALF_FLOAT = 0x6402
	cdef unsigned short TEXTURE_TYPE_UNCOMPRESSED_RGBA_HALF_FLOAT = 0x6422
	cdef unsigned short TEXTURE_TYPE_UNCOMPRESSED_RG16 = 0x2400
	cdef unsigned short TEXTURE_TYPE_UNCOMPRESSED_RG_HALF_FLOAT = 0x6800
	cdef unsigned short TEXTURE_TYPE_UNCOMPRESSED_R16 = 0x2401
	cdef unsigned short TEXTURE_TYPE_UNCOMPRESSED_R_HALF_FLOAT = 0x6400
	cdef unsigned short TEXTURE_TYPE_UNCOMPRESSED_RG8 = 0x2001
	cdef unsigned short TEXTURE_TYPE_UNCOMPRESSED_R8 = 0x2002
	cdef unsigned short TEXTURE_TYPE_UNCOMPRESSED_SIGNED_RG16 = 0x2C00
	cdef unsigned short TEXTURE_TYPE_UNCOMPRESSED_SIGNED_R16 = 0x2C01
	cdef unsigned short TEXTURE_TYPE_UNCOMPRESSED_SIGNED_RG8 = 0x2801
	cdef unsigned short TEXTURE_TYPE_UNCOMPRESSED_SIGNED_R8 = 0x2802
	cdef unsigned short TEXTURE_TYPE_ETC1 = 0x0100
	cdef unsigned short TEXTURE_TYPE_ETC2_RGB8 = 0x0101
	cdef unsigned short TEXTURE_TYPE_ETC2_EAC = 0x0162
	cdef unsigned short TEXTURE_TYPE_ETC2_PUNCHTHROUGH = 0x0123
	cdef unsigned short TEXTURE_TYPE_R11_EAC = 0x0400
	cdef unsigned short TEXTURE_TYPE_RG11_EAC = 0x0440
	cdef unsigned short TEXTURE_TYPE_SIGNED_R11_EAC = 0x0C00
	cdef unsigned short TEXTURE_TYPE_SIGNED_RG11_EAC = 0x0C40
	cdef unsigned short TEXTURE_TYPE_ETC2_SRGB8 = 0x1104
	cdef unsigned short TEXTURE_TYPE_ETC2_SRGB_PUNCHTHROUGH = 0x1125
	cdef unsigned short TEXTURE_TYPE_ETC2_SRGB_EAC = 0x1166
	cdef unsigned short TEXTURE_TYPE_DXT1 = 0x0200
	cdef unsigned short TEXTURE_TYPE_DXT3 = 0x0261
	cdef unsigned short TEXTURE_TYPE_DXT5 = 0x0262
	cdef unsigned short TEXTURE_TYPE_DXT1A = 0x0223
	cdef unsigned short TEXTURE_TYPE_BPTC = 0x0064
	cdef unsigned short TEXTURE_TYPE_BPTC_FLOAT = 0x4445
	cdef unsigned short TEXTURE_TYPE_BPTC_SIGNED_FLOAT = 0x4C46
	cdef unsigned short TEXTURE_TYPE_RGTC1 = 0x0001
	cdef unsigned short TEXTURE_TYPE_SIGNED_RGTC1 = 0x0C01
	cdef unsigned short TEXTURE_TYPE_RGTC2 = 0x0041
	cdef unsigned short TEXTURE_TYPE_SIGNED_RGTC2 = 0x0C41
	cdef unsigned short TEXTURE_TYPE_RGBA_ASTC_4X4 = 0x8000
	cdef unsigned short TEXTURE_TYPE_RGBA_ASTC_5X4 = 0x8001
	cdef unsigned short TEXTURE_TYPE_RGBA_ASTC_5X5 = 0x8002
	cdef unsigned short TEXTURE_TYPE_RGBA_ASTC_6X5 = 0x8003
	cdef unsigned short TEXTURE_TYPE_RGBA_ASTC_6X6 = 0x8004
	cdef unsigned short TEXTURE_TYPE_RGBA_ASTC_8X5 = 0x8005
	cdef unsigned short TEXTURE_TYPE_RGBA_ASTC_8X6 = 0x8006
	cdef unsigned short TEXTURE_TYPE_RGBA_ASTC_8X8 = 0x8007
	cdef unsigned short TEXTURE_TYPE_RGBA_ASTC_10X5 = 0x8008
	cdef unsigned short TEXTURE_TYPE_RGBA_ASTC_10X6 = 0x8009
	cdef unsigned short TEXTURE_TYPE_RGBA_ASTC_10X8 = 0x800A
	cdef unsigned short TEXTURE_TYPE_RGBA_ASTC_10X10 = 0x800B
	cdef unsigned short TEXTURE_TYPE_RGBA_ASTC_12X10 = 0x800C
	cdef unsigned short TEXTURE_TYPE_RGBA_ASTC_12X12 = 0x800D
	cdef unsigned short TEXTURE_TYPE_SRGB8_ALPHA8_ASTC_4X4 = 0x9000
	
	cdef unsigned short TEXTURE_TYPE_ALPHA_BIT = 0x0020
	cdef unsigned short TEXTURE_TYPE_ETC_BIT = 0x0100
	cdef unsigned short TEXTURE_TYPE_DXTC_BIT = 0x0200
	cdef unsigned short TEXTURE_TYPE_128BIT_BIT = 0x0040
	cdef unsigned short TEXTURE_TYPE_16_BIT_COMPONENTS_BIT = 0x0400
	cdef unsigned short TEXTURE_TYPE_SIGNED_BIT = 0x0800
	cdef unsigned short TEXTURE_TYPE_SRGB_BIT = 0x1000
	cdef unsigned short TEXTURE_TYPE_UNCOMPRESSED_BIT = 0x2000
	cdef unsigned short TEXTURE_TYPE_HALF_FLOAT_BIT = 0x4000
	cdef unsigned short TEXTURE_TYPE_ASTC_BIT = 0x8000
	
	ctypedef struct TextureInfo:
		int type
		int ktx_support
		int dds_support
		const char *text1
		const char *text2
		int block_width		# The block width (1 for uncompressed textures).
		int block_height		# The block height (1 for uncompressed textures).
		int bits_per_block		# The number of bits per block (per pixel for uncompressed textures).
		int internal_bits_per_block	# The number of bits per block as stored internally (per pixel for uncompressed).
		int alpha_bits
		int nu_components
		int gl_internal_format
		int gl_format
		int gl_type
		const char *dx_four_cc
		int dx10_format
		uint64_t red_mask, green_mask, blue_mask, alpha_mask

	ctypedef BlockUserData_t BlockUserData
	
	ctypedef int (*TextureDecodingFunction)(const unsigned char *bitstring, unsigned int *image_buffer, int flags)
	ctypedef double (*TextureComparisonFunction)(unsigned int *image_buffer, BlockUserData *user_data)
	ctypedef int (*TextureGetModeFunction)(const unsigned char *bitstring)
	ctypedef void (*TextureSetModeFunction)(unsigned char *bitstring, int flags)
	
	ctypedef struct Texture:
		unsigned int *pixels
		int width
		int height
		int extended_width
		int extended_height
		int type
		int bits_per_block		# The bits per block of the real format. The internally used bits per block is
						# given by info->internal_bits_per_block.
		int block_width
		int block_height
		TextureDecodingFunction decoding_function
		TextureComparisonFunction comparison_function
		TextureComparisonFunction perceptive_comparison_function
		TextureGetModeFunction get_mode_function
		TextureSetModeFunction set_mode_function
		TextureInfo *info
	
	struct BlockUserData_t:
		unsigned int *image_pixels
		int image_rowstride
		int x_offset
		int y_offset
		int flags
		Texture *texture
		unsigned char *alpha_pixels
		unsigned int *colors
		int stop_signalled
		int _pass
		unsigned int *texture_pixels
		unsigned int *texture_pixels_above
		unsigned int *texture_pixels_left
	
	ctypedef void (*CompressCallbackFunction)(BlockUserData *user_data)
	
	# Command line options defined in texgenpack.c
	
	cdef unsigned short COMMAND_COMPRESS = 0
	cdef unsigned short COMMAND_DECOMPRESS = 1
	cdef unsigned short COMMAND_COMPARE = 2
	cdef unsigned short COMMAND_CALIBRATE = 3
	
	cdef unsigned short ORIENTATION_DOWN = 1
	cdef unsigned short ORIENTATION_UP = 2
	
	# Compression levels (0 to 50).
	
	# Compression level class 0 (levels 0 to 7).
	# Compress different blocks concurrently, populations_size = 256,
	# nu_generations = 100 + level * 25.
	cdef unsigned short COMPRESSION_LEVEL_CLASS_0 = 0
	# Compression level class 1 (levels 8 to 32)
	# Compress the same block concurrently, number of tries is equal to
	# level value (8 to 32), nu_generations = 100.
	cdef unsigned short COMPRESSION_LEVEL_CLASS_1 = 8
	# Compression level class 2 (levels 33 to 50)
	# Compress the same block concurrently, number of tries is 32,
	# nu_generations = 100 + 25 * (level - 32)
	cdef unsigned short COMPRESSION_LEVEL_CLASS_2 = 33
	
	# Ultra preset: Compress different blocks concurrenty, nu_generations = 100.
	cdef unsigned short SPEED_ULTRA = COMPRESSION_LEVEL_CLASS_0
	# Fast preset: Eight tries per block, nu_generations = 100.
	cdef unsigned short SPEED_FAST = COMPRESSION_LEVEL_CLASS_1
	# Medium preset: 16 tries per block, nu_generations = 100.
	cdef unsigned short SPEED_MEDIUM = 16#COMPRESSION_LEVEL_CLASS_1 + 8
	# Slow preset 32 tries per block, nu_generations = 100.
	cdef unsigned short SPEED_SLOW = 32#COMPRESSION_LEVEL_CLASS_1 + 24
	
	extern int command
	extern int option_verbose
	extern int option_max_threads
	extern int option_orientation
	extern int option_compression_level
	extern int option_progress
	extern int option_modal_etc2
	extern int option_allowed_modes_etc2
	extern int option_generations
	extern int option_islands
	extern int option_generations_second_pass
	extern int option_islands_second_pass
	extern int option_texture_format
	extern int option_flip_vertical
	extern int option_quiet
	extern int option_block_width
	extern int option_block_height
	extern int option_half_float
	extern int option_deterministic
	extern int option_hdr
	extern int option_perceptive
	
	# Defined in image.c
	
	cdef void load_image(const char *filename, int filetype, Image *image)
	cdef int load_mipmap_images(const char *filename, int filetype, int max_images, Image *image)
	cdef void save_image(Image *image, const char *filename, int filetype)
	cdef double  compare_images(Image *image1, Image *image2)
	cdef int load_texture(const char *filename, int filetype, int max_mipmaps, Texture *texture)
	cdef void save_texture(Texture *texture, int nu_mipmaps, const char *filename, int filetype)
	cdef void convert_texture_to_image(Texture *texture, Image *image)
	cdef void destroy_texture(Texture *texture)
	cdef void destroy_image(Image *image)
	cdef void clone_image(Image *image1, Image *image2)
	cdef void clear_image(Image *image)
	cdef void pad_image_borders(Image *image)
	cdef void check_1bit_alpha(Image *image)
	cdef void convert_image_from_srgb_to_rgb(Image *source_image, Image *dest_image)
	cdef void convert_image_from_rgb_to_srgb(Image *source_image, Image *dest_image)
	cdef void copy_image_to_uncompressed_texture(Image *image, int texture_type, Texture *texture)
	cdef void flip_image_vertical(Image *image)
	cdef void print_image_info(Image *image)
	cdef void calculate_image_dynamic_range(Image *image, float *range_min_out, float *range_max_out)
	cdef void convert_image_from_half_float(Image *image, float range_min, float range_max, float gamma)
	cdef void convert_image_to_half_float(Image *image)
	cdef void extend_half_float_image_to_rgb(Image *image)
	cdef void remove_alpha_from_image(Image *image)
	cdef void add_alpha_to_image(Image *image)
	cdef void convert_image_from_16_bit_format(Image *image)
	cdef void convert_image_to_16_bit_format(Image *image, int nu_components, int signed_format)
	cdef void convert_image_from_8_bit_format(Image *image)
	cdef void convert_image_to_8_bit_format(Image *image, int nu_components, int signed_format)
	
	# Defined in compress.c
	
	cdef void compress_image(Image *image, int texture_type, CompressCallbackFunction func, Texture *texture,
		int genetic_parameters, float mutation_prob, float crossover_prob)
	
	# Defined in mipmap.c
	
	cdef void generate_mipmap_level_from_original(Image *source_image, int level, Image *dest_image)
	cdef void generate_mipmap_level_from_previous_level(Image *source_image, Image *dest_image)
	cdef int count_mipmap_levels(Image *image)
	
	# Defined in file.c
	
	cdef void load_pkm_file(const char *filename, Texture *texture)
	cdef void save_pkm_file(Texture *texture, const char *fikename)
	cdef int load_ktx_file(const char *filename, int max_mipmaps, Texture *texture)
	cdef void save_ktx_file(Texture *texture, int nu_mipmaps, const char *filename)
	cdef int load_dds_file(const char *filename, int max_mipmaps, Texture *texture)
	cdef void save_dds_file(Texture *texture, int nu_mipmaps, const char *filename)
	cdef void load_astc_file(const char *filename, Texture *texture)
	cdef void save_astc_file(Texture *texture, const char *filename)
	cdef void load_ppm_file(const char *filename, Image *image)
	cdef void load_png_file(const char *filename, Image *image)
	cdef void save_png_file(Image *image, const char *filename)
	
	# Defined in texture.c
	
	TextureInfo *match_texture_type(int type)
	TextureInfo *match_texture_description(const char *s)
	TextureInfo *match_ktx_id(int gl_internal_format, int gl_format, int gl_type)
	TextureInfo *match_dds_id(const char *four_cc, int dx10_format, uint32_t pixel_format_flags, int bitcount,
	uint32_t red_mask, uint32_t green_mask, uint32_t blue_mask, uint32_t alpha_mask)
	const char *texture_type_text(int texture_type)
	cdef int get_number_of_texture_formats()
	const char *get_texture_format_index_text(int i, int j)
	cdef void set_texture_decoding_function(Texture *texture, Image *image)
	
	# Defined in compare.c
	
	extern float *half_float_table
	extern float *gamma_corrected_half_float_table
	extern float *normalized_float_table
	
	cdef double  compare_block_any_size_rgba(unsigned int *image_buffer, BlockUserData *user_data)
	cdef double  compare_block_4x4_rgb(unsigned int *image_buffer, BlockUserData *user_data)
	cdef double  compare_block_perceptive_4x4_rgb(unsigned int *image_buffer, BlockUserData *user_data)
	cdef double  compare_block_4x4_rgba(unsigned int *image_buffer, BlockUserData *user_data)
	cdef double  compare_block_perceptive_4x4_rgba(unsigned int *image_buffer, BlockUserData *user_data)
	cdef void calculate_normalized_float_table()
	cdef double  compare_block_4x4_rgb8_with_half_float(unsigned int *image_buffer, BlockUserData *user_data)
	cdef double  compare_block_4x4_rgba8_with_half_float(unsigned int *image_buffer, BlockUserData *user_data)
	cdef double  compare_block_4x4_8_bit_components(unsigned int *image_buffer, BlockUserData *user_data)
	cdef double  compare_block_4x4_signed_8_bit_components(unsigned int *image_buffer, BlockUserData *user_data)
	cdef double  compare_block_4x4_8_bit_components_with_16_bit(unsigned int *image_buffer, BlockUserData *user_data)
	cdef double  compare_block_4x4_signed_8_bit_components_with_16_bit(unsigned int *image_buffer, BlockUserData *user_data)
	cdef double  compare_block_4x4_r16(unsigned int *image_buffer, BlockUserData *user_data)
	cdef double  compare_block_4x4_rg16(unsigned int *image_buffer, BlockUserData *user_data)
	cdef double  compare_block_4x4_r16_signed(unsigned int *image_buffer, BlockUserData *user_data)
	cdef double  compare_block_4x4_rg16_signed(unsigned int *image_buffer, BlockUserData *user_data)
	cdef void calculate_half_float_table()
	cdef double  compare_block_4x4_rgb_half_float(unsigned int *image_buffer, BlockUserData *user_data)
	cdef double  compare_block_4x4_rgba_half_float(unsigned int *image_buffer, BlockUserData *user_data)
	cdef double  compare_block_4x4_r_half_float(unsigned int *image_buffer, BlockUserData *user_data)
	cdef double  compare_block_4x4_rg_half_float(unsigned int *image_buffer, BlockUserData *user_data)
	cdef void calculate_gamma_corrected_half_float_table()
	cdef double  compare_block_4x4_rgb_half_float_hdr(unsigned int *image_buffer, BlockUserData *user_data)
	cdef double  compare_block_4x4_rgba_half_float_hdr(unsigned int *image_buffer, BlockUserData *user_data)
	
	# Defined in half_float.c
	
	cdef int halfp2singles(void *target, void *source, int numel)
	cdef int singles2halfp(void *target, void *source, int numel)
	
	# Defined in calibrate.c
	
	cdef void calibrate_genetic_parameters(Image *image, int texture_type)

