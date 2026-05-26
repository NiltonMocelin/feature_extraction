echo "Extraindo features BE e QOS"
sh scriptQoS1.sh #PC
sh scriptQoS2.sh #PC
sh scriptQoS3.sh #PC
sh scriptQoS4.sh #PC

sh scriptQoS5.sh #PC
sh scriptQoS6.sh #PC


sh scriptBE1.sh #PC
sh scriptBE2.sh #PC

sh scriptBE3.sh #NOT
sh scriptBE4.sh #NOT
sh scriptBE5.sh #NOT
sh scriptBE6.sh #NOT
# wait

sh scriptBE7.sh #PC
sh scriptBE8.sh #PC



echo "TERMINOU"