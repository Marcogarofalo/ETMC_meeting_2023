require(ggplot2)
require(hadron)
require(dplyr)

dat <- read.table("real_ensembles.dat", header = TRUE) %>%
       dplyr::mutate(corehrs_per_traj = hrs_per_traj * ncores)

tikzfiles <- hadron::tikz.init(basename = "corehrs_real_enembles")

p <- ggplot2::ggplot(dat, aes(x = L, y = corehrs_per_traj, colour = as.factor(integrator))) +
     ggplot2::geom_point() +
     ggplot2::labs(x = "$L/a$", y = "core-hours per traj.") +
     ggplot2::scale_y_continuous(trans = "log10") +
     ggplot2::stat_function(fun = function(x) 0.21 * (2*x^4)^(1/8) * (2 * x^4 / (16*8^3)),
                            colour = 'blue') +
     ggplot2::stat_function(fun = function(x) 0.033 * (2*x^4)^(1/4) * (2 * x^4 / (16*8^3)),
                            colour = 'red') +
     ggplot2::theme_bw()

plot(p)

hadron::tikz.finalize(tikzfiles, crop = FALSE)
