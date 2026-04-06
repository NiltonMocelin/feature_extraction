# echo "Extraindo features BE e QOS"
sh scriptQoS1.sh &
sh scriptQoS2.sh &
sh scriptQoS3.sh &
sh scriptQoS4.sh &

wait
sh scriptQoS5.sh &
sh scriptQoS6.sh &
sh scriptBE1.sh &
sh scriptBE2.sh &

wait 

sh scriptBE3.sh &
sh scriptBE4.sh &
sh scriptBE5.sh &
sh scriptBE6.sh &
wait

sh scriptBE7.sh &
sh scriptBE8.sh &

echo "TERMINOU"