require(ggplot2)
require(dplyr)
require(hadron)
require(ggrepel)
require(ggtext)
require(scales)
require(RColorBrewer)

# these are rough coefficients determined from real runs for the pre-factors of the scaling
c_2mn <- 0.03
c_2mnfg <- 0.23
cg_fac <- 3

cpu_cores_per_node <- 48

gpu_to_cpu_factor <- 3.32

dat <- read.table(file="ensembles.dat", header=TRUE)

gpu_speedup <- read.table(file="gpu_speedup.dat", header=TRUE) %>%
               dplyr::mutate(nds = ifelse(gpus == 0, ncores / cpu_cores_per_node, gpus),
                             ndhrs_per_traj = hrs_per_traj * nds,
                             N = 2 * L^4)


dat <- dplyr::mutate(dat,
                     Lfm = a * L,
                     N = 2 * L^4,
                     nds = floor(N / (16*8^3)) / cpu_cores_per_node,
                     ndhrs_per_traj = c_2mnfg * N^(1/8) * nds,
                     ndhrs = ndhrs_per_traj * ntraj,
                     O_ndhrs = floor(log10(ndhrs)),
                     sc_nsdhrs = sprintf("$\\sim %.0f \\cdot 10^%d$", ndhrs / 10^O_ndhrs, O_ndhrs))

a_colours <- RColorBrewer::brewer.pal(n = length(unique(dat$a)),
                                      name = "Set2")

tikzfiles <- hadron::tikz.init(basename="ndhrs_per_traj", width = 3.6, height = 3.32)
 
fn_2mnfg <- function(x) c_2mnfg * (2*x^4)^(1/8) * (2 * x^4 / (16*8^3)) / cpu_cores_per_node

fn_2mn <- function(x) c_2mn * (2*x^4)^(1/4) * (2 * x^4 / (16*8^3)) / cpu_cores_per_node

fn_2mn_cg <- function(x) cg_fac * fn_2mn(x)

fn_2mnfg_gpu <- function(x) fn_2mnfg(x) / gpu_to_cpu_factor

errwidth <- 0.2

ribbon_2mnfg <- data.frame(x = seq(12, 160, length.out = 1000)) %>%
                dplyr::mutate(y = fn_2mnfg(x), ymin = (1.0-errwidth)*y, ymax = (1.0+errwidth)*y)

ribbon_2mn <- data.frame(x = seq(12, 160, length.out = 1000)) %>%
              dplyr::mutate(y = fn_2mn(x), ymin = (1.0-errwidth)*y, ymax = (1.0+errwidth)*y)

ribbon_2mn_cg <- data.frame(x = seq(12, 160, length.out = 1000)) %>%
                 dplyr::mutate(y = fn_2mn_cg(x), ymin = (1.0-errwidth)*y, ymax = (1.0+errwidth)*y)

ribbon_2mnfg_gpu <- data.frame(x = seq(12, 160, length.out = 1000)) %>%
                    dplyr::mutate(y = fn_2mnfg_gpu(x), ymin = (1.0-errwidth)*y, ymax = (1.0+errwidth)*y)

p <- ggplot2::ggplot(dat, aes(x = L,  
                              y = ndhrs_per_traj)) +
     ggplot2::stat_function(fun = fn_2mnfg,  colour = 'red', lty = 'solid', lwd = 1) +
     ggplot2::stat_function(fun = fn_2mnfg_gpu, colour = 'purple', lty = 'dashed', lwd = 1) +
     ggplot2::geom_ribbon(data = ribbon_2mnfg, aes(x = x, ymin = ymin, ymax = ymax), inherit.aes = FALSE,
                          colour = NA, alpha = 0.2, fill = 'red') +
     ggplot2::geom_ribbon(data = ribbon_2mnfg_gpu, aes(x = x, ymin = ymin, ymax = ymax), inherit.aes = FALSE,
                          colour = NA, alpha = 0.2, fill = 'purple') +
     ggplot2::geom_point(data = gpu_speedup, size = 3, 
                         aes(colour = as.factor(machine), shape = as.factor(machine))) +
     ggplot2::scale_colour_manual(values = c('red', 'purple')) +
     ggplot2::scale_y_continuous(trans = "log10", 
                                 breaks = 10^(0:10),
                                 labels = sprintf("$10^{%d}$",0:10)) +
     ggplot2::scale_x_continuous(breaks = c(8, 16, 24, 32, 48, 64, 80, 96, 112, 128, 144)) +
     ggplot2::coord_cartesian(ylim = c(1e0, 1e4), xlim = c(44,150)) +
     ggplot2::labs(x = "$L/a$",
                   y = "[Node/GPU]-hours per traj.",
                   colour = "",
                   shape = "") +
     ggplot2::annotate(geom = 'label', x = 90, y = 6e0, hjust = 0.0,
                       label = "4$^\\mathrm{th}$order + MG (CPU)", colour = 'red') +
     ggplot2::annotate(geom = 'segment', x = 74, xend = 88, y = 6e0, yend = 6e0, colour = 'red', lty = 'solid', lwd = 1.5) +

     ggplot2::annotate(geom = 'label', x = 90, y = 1.4e0, hjust = 0.0,
                       label = "4$^\\mathrm{th}$order + MG (GPU)", colour = 'purple') +
     ggplot2::annotate(geom = 'segment', x = 74, xend = 88, y = 1.4e0, yend = 1.4e0, colour = 'purple', lty = 'dashed', lwd = 1.5) +

     ggplot2::theme_bw() +
     ggplot2::theme(legend.position = "top",
                    legend.direction = "vertical",
                    legend.justification = "right",
                    #legend.key.size = unit(8, 'pt'),
                    legend.text = element_text(size = 8))#,
                    #legend.box.margin = margin(0.1,0.1,0.1,0.1),
                    #legend.background = element_rect(colour = 'black',
                    #                                 fill = 'white'))
plot(p)

hadron::tikz.finalize(tikzfiles, crop = TRUE)
