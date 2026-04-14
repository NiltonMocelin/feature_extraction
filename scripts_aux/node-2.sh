# enviar para node-2
# enviar QoS3
IP="c220g5-111221.wisc.cloudlab.us"
PORT=25212

# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/facebook_Audio niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Hangouts_voice_Workstation niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Vimeo_Workstation niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Facebook_Voice_Workstation niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Skype_Audio niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Hangout_Audio niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Skype_Voice_Workstation niltonm@$IP:/users/niltonm/Data

scp -P $PORT -r /media/nnmoc/Data/material_traffic_classification2/extracao_features/extrator_cython niltonm@$IP:/users/niltonm/
# ssh -p 25212 niltonm@c220g5-111221.wisc.cloudlab.us
