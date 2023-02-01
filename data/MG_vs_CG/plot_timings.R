require(ggplot2)
require(hadron)
require(dplyr)

dat <- read.table(file = "timings.dat", header = TRUE, stringsAsFactors = FALSE) %>%
       dplyr::group_by(mu, solver, sloppy, rel_delta, max_res_increase) %>%
       dplyr::mutate(converge = all(res < 1e-9) ) %>%
       dplyr::ungroup() %>%
       dplyr::filter(converge) %>%
       dplyr::group_by(mu, solver, sloppy, rel_delta, max_res_increase) %>%
       dplyr::summarize(tts_avg = mean(tts)) %>%
       dplyr::ungroup() %>%
       dplyr::group_by(mu, solver) %>%
       dplyr::summarize(tts = ifelse(solver == "mg", 2, 1) * min(tts_avg)      # two inversions in the derivative 
		              + ifelse(solver == "mg", 0.7, 0) ) %>%           # + constant offset for updateMultigridQuda
       dplyr::ungroup() %>%
       dplyr::mutate(solver = toupper(solver))


tikzfiles <- hadron::tikz.init(width = 3, height = 2.25, basename = "mg_vs_cg")

p <- ggplot2::ggplot(dat, aes(x = mu, y = tts, colour = solver, shape = solver)) + 
     ggplot2::geom_vline(xintercept = c(0.0008, 0.0008*24, 0.0008*320), lty = 'dashed') +
     ggplot2::geom_point() +
     ggplot2::geom_line() +
     ggplot2::scale_y_continuous(trans = 'log10') +
     ggplot2::scale_x_continuous(trans = 'log10', limits = c(0.0008, 0.35)) +
     ggplot2::coord_cartesian(clip = "off") +
     ggplot2::annotation_logticks(base = 10, 
				  short = unit(0.05, "cm"), mid = unit(0.05, "cm"), long = unit(0.15, "cm"),
				  outside = TRUE, scaled = TRUE) +
     ggplot2::labs(y = "inversion timing [sec]",
		   x = "$a\\mu$",
		   colour = "Solver",
		   shape = "Solver") +
     ggplot2::annotate(geom = "text", x = c(0.0008, 0.0008*24, 0.0008*320),
		       y = 3e-1, label = sprintf("$m_%s$", c("{u,d}", "s", "c")),
		       hjust = -0.1) +
     ggplot2::theme_bw() + 
     ggplot2::theme(legend.position=c(0.75, 0.7),
                    legend.box.background = element_rect(colour = "black"),
                    legend.box.margin = margin(.5,.5,.5,.5,"pt"),
		    legend.margin = margin(4,4,4,4,"pt"),
                    legend.key.size = unit(12, "pt"))

plot(p)


hadron::tikz.finalize(tikzfiles, crop = FALSE)

