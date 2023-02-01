require(hadron)
require(ggplot2)
require(dplyr)

dat <- read.table('hip_cuda_32c64.dat', header=TRUE)

adat <- dplyr::filter(dat, gpu == "MI250")
ndat <- dplyr::filter(dat, gpu == "A100")

tikzfiles <- hadron::tikz.init(basename = 'hip_vs_cuda_32c64', width = 4, height = 3)

p <- ggplot2::ggplot(dat, aes(x = mu / 0.0008, y = tts/3600, 
                              fill = as.factor(gpu),
                              shape = as.factor(gpu)),
                     colour = 'black') +
     ggplot2::geom_line(aes(colour = as.factor(gpu)), lwd = 1) +
     ggplot2::geom_point(size = 2.5) +
     ggplot2::scale_shape_manual(values = c(21, 23)) +
     ggplot2::scale_colour_manual(values = c('green', 'red')) +
     ggplot2::scale_fill_manual(values = c('green', 'red')) +
     ggplot2::labs(x = "$(M_\\pi / M_\\pi^{\\mathrm{phys}})^2$",
                   fill = "GPU type",
                   shape = "GPU type",
                   colour = "GPU type",
                   y = "time per trajectory [h]") +
     ggplot2::theme_bw() +
     ggplot2::theme(legend.position = c(0.84, 0.80),
                    legend.box.background = element_rect(colour = 'black'),
                    legend.box.margin = margin(1, 1, 1, 1, 'pt') )
plot(p)

hadron::tikz.finalize(tikzfiles)
