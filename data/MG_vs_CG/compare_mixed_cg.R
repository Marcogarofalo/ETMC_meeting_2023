require(ggplot2)
require(hadron)
require(dplyr)

dat <- read.table(file = "timings.dat", header = TRUE, stringsAsFactors = FALSE) %>%
       dplyr::filter(solver == "cg") %>%
       dplyr::select(-solver) %>%
       dplyr::group_by(mu, sloppy, rel_delta, max_res_increase) %>%
       dplyr::mutate(converged = all(res < 1e-9) ) %>%
       dplyr::ungroup() %>%
       dplyr::group_by(mu, sloppy, rel_delta, max_res_increase) %>%
       dplyr::summarize(tts_avg = max(tts), converged = unique(converged)) %>%
       dplyr::ungroup()


tikzfiles <- hadron::tikz.init(width = 8, height = 8, basename = "compare_mixed_cg")

no_alt_dat <- dplyr::filter(dat, rel_delta != "alt")

p <- ggplot2::ggplot(no_alt_dat, 
		     aes(x = mu, y = tts_avg, 
			 colour = interaction(sloppy, rel_delta, max_res_increase, sep = " / "), 
			 shape = converged,
			 lty = converged)) + 
     ggplot2::geom_jitter(width = ggplot2:::resolution(log10(no_alt_dat$mu), FALSE) * 0.1,
			  height = 0) +
     ggplot2::geom_line() +
     ggplot2::scale_y_continuous(trans = 'log10') +
     ggplot2::scale_x_continuous(trans = 'log10', limits = c(0.0006, 0.3)) +
     ggplot2::scale_linetype_manual(values = c("dotted", "solid")) +
     ggplot2::coord_cartesian(clip = "off") +
     ggplot2::geom_vline(xintercept = c(0.0008, 0.0008*24, 0.0008*320), lty = 'dashed') +
     ggplot2::annotation_logticks(base = 10, 
				  short = unit(0.05, "cm"), mid = unit(0.05, "cm"), long = unit(0.15, "cm"),
				  outside = TRUE, scaled = TRUE) +
     ggplot2::labs(y = "inversion timing [sec]",
		   x = "$a\\mu$",
		   colour = "sloppy / $\\delta$ / max\\_res\\_inc",
		   shape = "converged") +
     ggplot2::annotate(geom = "text", x = c(0.0008, 0.0008*24, 0.0008*320),
		       y = 2e-1, label = sprintf("$\\mu_%s$", c("{u,d}", "s", "c")),
		       hjust = -0.1) +
     ggplot2::theme_bw() #+ 
plot(p)

no_small_mu_no_alt_dat <- dplyr::filter(dat, mu >= 0.0064, rel_delta != "alt")

p <- ggplot2::ggplot(no_small_mu_no_alt_dat, 
		     aes(x = mu, y = tts_avg, 
			 colour = interaction(sloppy, rel_delta, max_res_increase, sep = " / "), 
			 shape = converged,
			 lty = converged)) + 
     ggplot2::geom_jitter(width = ggplot2:::resolution(log10(no_small_mu_no_alt_dat$mu), FALSE) * 0.1,
			  height = 0) +
     ggplot2::geom_line() +
     ggplot2::scale_y_continuous(trans = 'log10') +
     ggplot2::scale_x_continuous(trans = 'log10', limits = c(0.006, 0.3)) +
     ggplot2::scale_linetype_manual(values = c("solid")) +
     ggplot2::scale_shape_manual(values = c(17)) +
     ggplot2::coord_cartesian(clip = "off") +
     ggplot2::geom_vline(xintercept = c(0.0008, 0.0008*24, 0.0008*320), lty = 'dashed') +
     ggplot2::annotation_logticks(base = 10, 
				  short = unit(0.05, "cm"), mid = unit(0.05, "cm"), long = unit(0.15, "cm"),
				  outside = TRUE, scaled = TRUE) +
     ggplot2::labs(y = "inversion timing [sec]",
		   x = "$a\\mu$",
		   colour = "sloppy / $\\delta$ / max\\_res\\_inc",
		   shape = "converged") +
     ggplot2::annotate(geom = "text", x = c(0.0008, 0.0008*24, 0.0008*320),
		       y = 2e-1, label = sprintf("$\\mu_%s$", c("{u,d}", "s", "c")),
		       hjust = -0.1) +
     ggplot2::theme_bw() #+ 

plot(p)

alt_dat <- dplyr::filter(dat, rel_delta == "alt")

p <- ggplot2::ggplot(alt_dat,
		     aes(x = mu, y = tts_avg, 
			 colour = interaction(sloppy, rel_delta, max_res_increase, sep = " / "), 
			 shape = converged,
			 lty = converged)) + 
     ggplot2::geom_jitter(width = ggplot2:::resolution(log10(alt_dat$mu), FALSE) * 0.05,
			  height = 0) +
     ggplot2::geom_line() +
     ggplot2::scale_y_continuous(trans = 'log10') +
     ggplot2::scale_x_continuous(trans = 'log10', limits = c(0.0008, 0.3)) +
     ggplot2::scale_linetype_manual(values = c("dotted", "solid")) +
     ggplot2::coord_cartesian(clip = "off") +
     ggplot2::geom_vline(xintercept = c(0.0008, 0.0008*24, 0.0008*320), lty = 'dashed') +
     ggplot2::annotation_logticks(base = 10, 
				  short = unit(0.05, "cm"), mid = unit(0.05, "cm"), long = unit(0.15, "cm"),
				  outside = TRUE, scaled = TRUE) +
     ggplot2::labs(y = "inversion timing [sec]",
		   x = "$a\\mu$",
		   colour = "sloppy / $\\delta$ / max\\_res\\_inc",
		   shape = "converged") +
     ggplot2::annotate(geom = "text", x = c(0.0008, 0.0008*24, 0.0008*320),
		       y = 2e-1, label = sprintf("$\\mu_%s$", c("{u,d}", "s", "c")),
		       hjust = -0.1) +
     ggplot2::theme_bw() #+ 
plot(p)

hadron::tikz.finalize(tikzfiles, crop = FALSE)

