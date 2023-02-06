require(hadron)
require(dplyr)
require(ggplot2)
require(ggh4x)
require(ggrepel)

dat <- read.table("scaling.dat", header=TRUE)

dat <- dplyr::mutate(dat, gpus = nodes * 4,
                          traj_tts = traj_tts * 0.06667, # the timings here are not real trajectories
                          traj_nodeh = nodes * traj_tts / 3600,
                          type = "")
tikzfiles <- tikz.init("Booster_LUMIG_HMC_Scaling", width = 3.0, height = 2.0)

for (l in unique(dat$L)){
  ldat <- dplyr::filter(dat, L == l)
  for(m in unique(ldat$machine)){
    lmdat <- dplyr::filter(ldat, machine == m) %>%
             dplyr::mutate(speedup = max(traj_tts)/traj_tts,
                           peff    = min(nodes) * speedup / nodes)
  
    print(lmdat)
  
    p <- ggplot2::ggplot(lmdat, aes(x = nodes, y = speedup, 
  				                          colour = interaction(machine, type, sep = " "),
  				                          linetype = interaction(machine, type, sep = " "),
  				                          shape = interaction(machine, type, sep = " "))) +
         ggplot2::geom_abline(data = mutate(subset(lmdat, nodes == min(nodes)),
  					                                machine = " ideal",
  					                                type = ""),
  			                      aes(intercept = 0, 
  				                        slope = min(speedup)/nodes,
  				                        colour = interaction(machine, type, sep = " "),
  				                        linetype = interaction(machine, type, sep = " "),
  				                        shape = interaction(machine, type, sep = " ")
  				                        ),
  			                      lwd = 1 
  			                      ) +
         ggplot2::scale_linetype_manual(values = c("dashed", NA), name = "") +
         ggplot2::scale_colour_manual(values = c("black", ifelse(m == "lumig", "red", "blue")), name = "") +
         ggplot2::scale_shape_manual(values = c(18, 18), name = "") +
         ggplot2::geom_point() +
         ggplot2::theme_bw() +
         ggplot2::labs(x = "Nodes",
                       y = "Speed-up",
  		     colour = "",
  		     linetype = "",
  		     shape = ""
                       #title = sprintf("$%d^3 \\cdot %d$ HMC @ phys.point", l, 2*l)
  		     ) +
         ggplot2::guides(x = ggh4x::guide_axis_manual(breaks = lmdat$nodes, labels = lmdat$nodes)) +
         ggplot2::lims(y = c(0.9, max(lmdat$nodes)/min(lmdat$nodes))) +
         ggplot2::theme(legend.position = c(0.16, 0.77),
                        legend.box.background = element_rect(colour = "black",
                        fill = "white"),
                	      legend.box.margin = margin(.2,.2,.2,.2,"pt"),
                	      legend.margin = margin(-1,1,1,1,"pt"),
                	      legend.key.size = unit(10, "pt"),
                	      legend.text = element_text(size = 6)) +
         ggplot2::guides(colour = guide_legend(title = NULL),
                	       linetype = guide_legend(title = NULL),
                	       shape = guide_legend(title = NULL)) +
         ggrepel::geom_label_repel(aes(label=sprintf("%.0f s", traj_tts)), 
                                   show.legend = FALSE,
                                   #nudge_x = min(lmdat$nodes)/2,
                                   nudge_y = max(lmdat$nodes)/min(lmdat$nodes)/4,
                                   size = 2)
         #if( "lumig" %in% ldat$machine ){
         #  cat("lumig found\n")
         #  p <- p + 
         #           ggplot2::geom_abline(data = mutate(subset(subset(ldat, machine == "lumig"), 
         #                                                     nodes == min(nodes)), 
  			 #            	                                 machine = "lumig (IDEAL)",
  			 #            	                                 type = ""),
  			 #                                 aes(intercept = 0, 
  			 #                                     slope = 1.0/nodes,
  			 #                                     colour = interaction(machine, type, sep = " "),
  			 #                                     linetype = interaction(machine, type, sep = " "),
  			 #                                     shape = interaction(machine, type, sep = " ")
  			 #                                     ),
  			 #                                 lwd = 1 
  			 #                                 )
         #}
    plot(p)
  }
}

tikz.finalize(tikzfiles, crop = FALSE)

