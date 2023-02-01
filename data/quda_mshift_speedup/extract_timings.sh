echo tts prec > timings.dat
for i in double single single_half; do
  pr="$i"
  if [[ "$i" == "single" ]]; then
    pr="single_single"
  fi 
  awk -v prec="$pr" '{print $6 " " prec}' mshift_${i}.txt >> timings.dat
done 
