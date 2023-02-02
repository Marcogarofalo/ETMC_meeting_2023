L <- c(64, 80, 96, 112, 128, 144)   
ngpus <- c(32, 80, 144, 224, 512, 648)

# time per trajectory on 64^3*128 ~ 1.6 hours on 32 GPUs
# scaled with the power of (1/8) coming from the 2mnfg integrator at constant acceptance
# and assuming perfect weak scaling of the whole algorithm based on running a 64^3*128 on 32 GPUs
times <- 1.6*(L^4/64^4)^(1/8) * (L^4/ngpus)/(64^4/32)

# number of trajectories achievable using a typical Juwels Booster contingent (15 mio corehrs)
gpuhrs_booster <- (15*10^6/48)*4 # (corehrs / cores per node)*(gpus per node)

ntraj_booster <- gpuhrs_booster / (times * ngpus)

# 2 replicas running 24 hours per day, 350 days per year
ntraj_year <- 2*24*350 / times

print(data.frame(L=L, ngpu=ngpus, t_traj=times, gpuhrs_traj=ngpus*times, ntraj_booster=ntraj_booster, ntraj_year = ntraj_year))

