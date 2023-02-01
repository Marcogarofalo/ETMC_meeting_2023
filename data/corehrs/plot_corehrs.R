require(ggplot2)
require(dplyr)
require(hadron)
require(ggrepel)
require(ggtext)
require(scales)
require(RColorBrewer)

dat <- read.table(file="real_ensembles.dat", header=TRUE)


# these are rough coefficients determined from real runs for the pre-factors of the scaling
c_2mn <- 0.033
c_2mnfg <- 0.21
cg_fac <- 3

dat <- dplyr::mutate(dat,
                     N = 2 * L^4,
                     corehrs_per_traj = ncores * hrs_per_traj)

integrator_colours <- c('blue', 'red')

tikzfiles <- hadron::tikz.init(basename="corehrs_per_traj", width = 3.6, height = 3)
 
fn_2mnfg <- function(x) c_2mnfg * (2*x^4)^(1/8) * (2 * x^4 / (16*8^3))

fn_2mn <- function(x) c_2mn * (2*x^4)^(1/4) * (2 * x^4 / (16*8^3))

fn_2mn_cg <- function(x) cg_fac * fn_2mn(x)

errwidth <- 0.2

ribbon_2mnfg <- data.frame(x = seq(12, 160, length.out = 1000)) %>%
                dplyr::mutate(y = fn_2mnfg(x), ymin = (1.0-errwidth)*y, ymax = (1.0+errwidth)*y)

ribbon_2mn <- data.frame(x = seq(12, 160, length.out = 1000)) %>%
              dplyr::mutate(y = fn_2mn(x), ymin = (1.0-errwidth)*y, ymax = (1.0+errwidth)*y)

ribbon_2mn_cg <- data.frame(x = seq(12, 160, length.out = 1000)) %>%
                 dplyr::mutate(y = fn_2mn_cg(x), ymin = (1.0-errwidth)*y, ymax = (1.0+errwidth)*y)

segx <- c(85,105)
lblx <- c(107)

p <- ggplot2::ggplot(dat, aes(x = L,
                              shape = as.factor(integrator),
                              colour = as.factor(integrator), 
                              y = corehrs_per_traj)) +
     ggplot2::scale_colour_manual(values = integrator_colours,
                                  breaks = unique(dat$integrator)) +
     ggplot2::stat_function(fun = fn_2mnfg,  colour = 'red', lty = 'solid', lwd = 1) +
     ggplot2::stat_function(fun = fn_2mn,    colour = 'blue', lty = 'dashed', lwd = 1) +
     ggplot2::stat_function(fun = fn_2mn_cg, colour = 'black', lty = 'dotted', lwd = 1) +
     ggplot2::geom_ribbon(data = ribbon_2mnfg, aes(x = x, ymin = ymin, ymax = ymax), inherit.aes = FALSE,
                          colour = NA, alpha = 0.2, fill = 'red') +
     ggplot2::geom_ribbon(data = ribbon_2mn, aes(x = x, ymin = ymin, ymax = ymax), inherit.aes = FALSE,
                          colour = NA, alpha = 0.2, fill = 'blue') +
     ggplot2::geom_ribbon(data = ribbon_2mn_cg, aes(x = x, ymin = ymin, ymax = ymax), inherit.aes = FALSE,
                          colour = NA, alpha = 0.2, fill = 'black') +
     ggplot2::geom_point(size = 3) +
     ggplot2::scale_y_continuous(trans = "log10", 
                                 breaks = 10^(0:10),
                                 labels = sprintf("$10^{%d}$",0:10)) +
     ggplot2::scale_x_continuous(breaks = c(8, 16, 24, 32, 48, 64, 80, 96, 112, 128, 144)) +
     ggplot2::coord_cartesian(ylim = c(1e3, 1e6), xlim = c(44,144)) +
     ggplot2::labs(x = "$L/a$",
                   y = "core-hours per traj.",
                   colour = "integrator",
                   shape = "integrator") +
     ggplot2::annotate(geom = 'label', x = lblx, y = 4e3, hjust = 0.0,
                       label = "2$^\\mathrm{nd}$order", colour = 'black') +
     ggplot2::annotate(geom = 'segment', x = segx[1], xend = segx[2], y = 4e3, yend = 4e3, 
                       colour = 'black', lty = 'dotted', lwd = 1.5) +
     ggplot2::annotate(geom = 'label', x = lblx, y = 2e3, hjust = 0.0,
                       label = "2$^\\mathrm{nd}$order + MG", colour = 'blue') +
     ggplot2::annotate(geom = 'segment', x = segx[1], xend = segx[2], y = 2e3, yend = 2e3, 
                       colour = 'blue', lty = 'dashed', lwd = 1.5) +
     ggplot2::annotate(geom = 'label', x = lblx, y = 1e3, hjust = 0.0,
                       label = "4$^\\mathrm{th}$order + MG", colour = 'red') +
     ggplot2::annotate(geom = 'segment', x = segx[1], xend = segx[2], y = 1e3, yend = 1e3, 
                       colour = 'red', lty = 'solid', lwd = 1.5) +
     ggplot2::theme_bw() +
     ggplot2::theme(legend.position = c(0.15, 0.84),
                    legend.background = element_rect(colour = 'black'))
plot(p)

hadron::tikz.finalize(tikzfiles, crop = TRUE)

