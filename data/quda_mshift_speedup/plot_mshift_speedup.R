require(ggplot2)
require(dplyr)
require(hadron)
require(stringr)

dat <- read.table(file = "timings.dat", header = TRUE) %>%
       dplyr::mutate(prec = stringr::str_replace(prec, '_', ' / ')) %>% 
       dplyr::group_by(prec) %>%
       dplyr::mutate(call = row_number()) %>%
       dplyr::ungroup()

tikzfiles <- hadron::tikz.init(basename = "quda_mshift_speedup", width = 3, height = 3)

label <- "precision / refinement"

prec_order <- c('double', 'single / single', 'single / half')

p <- ggplot2::ggplot(data = dplyr::filter(dat, call < 30 & call > 1), 
                     aes(x = call, y = tts, colour = prec, linetype = prec, shape = prec)) +
     ggplot2::geom_line() +
     ggplot2::geom_point() +
     ggplot2::theme_bw() +
     ggplot2::scale_y_continuous() +
     ggplot2::scale_colour_discrete(breaks = prec_order) +
     ggplot2::scale_linetype_discrete(breaks  = prec_order) +
     ggplot2::scale_shape_discrete(breaks = prec_order) +
     ggplot2::labs(y = "solve time [sec]",
                   x = "call \\#",
                   shape = label,
                   colour = label,
                   linetype = label) +
     ggplot2::theme(legend.position = c(0.74, 0.8),
                    legend.background = element_rect(colour = 'black',
                                                     fill = 'white'),
                    legend.text = element_text(size = 7),
                    legend.title = element_text(size = 8))
plot(p)

hadron::tikz.finalize(tikzfiles)
