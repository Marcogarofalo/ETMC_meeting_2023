require(hadron)
require(ggplot2)
require(dplyr)
require(ggbrace)

dat <- read.table('dslash_test.dat', header=TRUE)

adat <- dplyr::filter(dat, gpu == "MI250")
ndat <- dplyr::filter(dat, gpu == "A100")

tikzfiles <- hadron::tikz.init(basename = 'hip_vs_cuda_single_gpu_dslash_bench', width = 4, height = 3)

p <- ggplot2::ggplot(dat, aes(x = 0.25*L^4, y = gflops_per_task, 
                              fill = as.factor(gpu),
                              shape = as.factor(gpu),
                              alpha = as.factor(ntask),
                              linetype = as.factor(ntask)),
                     colour = 'black') +
     ggplot2::geom_line(aes(colour = as.factor(gpu)), lwd = 1) +
     ggplot2::geom_point(size = 2.5) +
     ggbrace::geom_brace(aes(x = c(16^4, 32^4), y = c(20,25), 
                             label = "most relevant region"),
                         colour = 'black', labelsize = 3,
                         inherit.data = FALSE) +
     ggplot2::scale_shape_manual(values = c(21, 23)) +
     ggplot2::scale_alpha_manual(values = c(0.4, 1.0)) +
     ggplot2::scale_colour_manual(values = c('green', 'red')) +
     ggplot2::scale_fill_manual(values = c('green', 'red')) +
     ggplot2::scale_linetype_manual(values = c('dashed', 'solid')) +
     ggplot2::scale_x_continuous(trans = 'log10',
                                 breaks = 0.25*unique(dat$L)^4,
                                 labels = sprintf("$%d^3 \\cdot %d$", unique(dat$L), unique(dat$L)/4)) +
     ggplot2::scale_y_continuous(trans = 'log10',
                                 breaks = as.vector(outer(c(0, 2^(0:2)), 10^(0:5)))) +
     ggplot2::labs(x = "4D fine-grid lattice sites",
                   fill = "GPU type",
                   colour = "GPU type",
                   shape = "GPU type",
                   alpha = "\\# GPUs / GCDs",
                   linetype = "\\# GPUs / GCDs",
                   y = "Gflop/s (per GPU/GCD)") +
     ggplot2::theme_bw() +
     ggplot2::theme(legend.position = c(0.84, 0.43),
                    legend.box.background = element_rect(colour = 'black', fill = 'white'),
                    legend.title = element_text(size = 6),
                    legend.text = element_text(size = 6),
                    legend.spacing.y = unit(2, 'pt'),
                    legend.box.margin = margin(1, 1, 1, 1, 'pt') )
plot(p)

hadron::tikz.finalize(tikzfiles)
