require(hadron)
require(ggplot2)
require(dplyr)
require(ggbrace)

dat <- read.table('dslash_test.dat', header=TRUE)

adat <- dplyr::filter(dat, gpu == "MI250")
ndat <- dplyr::filter(dat, gpu == "A100")

tikzfiles <- hadron::tikz.init(basename = 'hip_vs_cuda_dslash_bench', width = 4, height = 3)

p <- ggplot2::ggplot(dat, aes(x = L^4, y = gflops_per_task*ntask, 
                              fill = as.factor(gpu),
                              shape = as.factor(gpu)),
                     colour = 'black') +
     ggplot2::geom_line(aes(colour = as.factor(gpu)), lwd = 1) +
     ggbrace::geom_brace(aes(x = c(24^4, 4*32^4), y = c(200,230), 
                             label = "most relevant region"),
                         colour = 'black', labelsize = 3,
                         inherit.data = FALSE) +
     ggplot2::geom_point(size = 2.5) +
     ggplot2::scale_shape_manual(values = c(21, 23)) +
     ggplot2::scale_colour_manual(values = c('green', 'red')) +
     ggplot2::scale_fill_manual(values = c('green', 'red')) +
     ggplot2::scale_x_continuous(trans = 'log10',
                                 breaks = unique(dat$L)^4,
                                 labels = sprintf("$%d^4$", unique(dat$L))) +
     ggplot2::scale_y_continuous(trans = 'log10',
                                 breaks = as.vector(outer(c(0, 2^(0:2)), 10^(0:5)))) +
     ggplot2::labs(x = "4D fine-grid lattice sites",
                   fill = "GPU type",
                   colour = "GPU type",
                   shape = "GPU type",
                   y = "Gflop/s (whole node)") +
     ggplot2::theme_bw() +
     ggplot2::theme(legend.position = c(0.13, 0.82),
                    legend.box.background = element_rect(colour = 'black', fill = 'white'),
                    legend.title = element_text(size = 8),
                    legend.text = element_text(size = 8),
                    legend.spacing.y = unit(4, 'pt'),
                    legend.box.margin = margin(1, 1, 1, 1, 'pt') )
plot(p)

hadron::tikz.finalize(tikzfiles)
