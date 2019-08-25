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
#include <stdio.h>
#include <stdint.h>
#include <math.h>
#ifndef __clang__
# include <malloc.h>
#endif
#include <fgen.h>
#include "texgenpack.h"

// Calibrate genetic algorithm parameters.

static const int fixed_crossover_probability = 1;
static const int real_valued_ga = 0;
static const int deterministic = 0;

typedef struct {
	Image *image;
	int texture_format;
} FitUserData;

static FitUserData fit_user_data;

typedef struct {
	double cumulative_rmse;
	int count;
} MutationBin;

static MutationBin mutation_bin[100];

static void mutation_bin_initialize() {
	for (int i = 0; i < 100; i++) {
		mutation_bin[i].cumulative_rmse = 0;
		mutation_bin[i].count = 0;
	}
}

static void mutation_bin_add_measurement(double mutation_prob, double rmse) {
	int bin = floor(mutation_prob * 1000.0);
	if (bin >= 100)
		bin = 99;
	mutation_bin[bin].cumulative_rmse += rmse;
	mutation_bin[bin].count++;
}

static void mutation_bin_report() {
	printf("Binned results:\n");
	for (int i = 0; i < 100; i++) {
		if (mutation_bin[i].count > 0)
			printf("Range %.4lf - %.4lf: n = %3d RMSE %.4lf\n",
				(double)i / 1000.0, ((double)i + 1) / 1000.0, mutation_bin[i].count,
				mutation_bin[i].cumulative_rmse / mutation_bin[i].count);
	}
}

static void compress_callback(BlockUserData *user_data) {
}

static void calibrate_generation_callback(Ffit *fit, int generation, const double *best_param, double best_error) {
	float crossover_prob = best_param[1];
	if (fixed_crossover_probability)
		crossover_prob = 0.7;
	printf("Generation %d: Mut = %.4lf, Cross = %.3lf, RMSE = %.3lf\n", generation,
		best_param[0], crossover_prob, sqrt(best_error));
	if (generation == 5)
		ffit_signal_stop(fit);
	if (!deterministic)
		ffit_signal_model_change(fit);
}
