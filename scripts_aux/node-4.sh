# enviar para node-4
# enviar QoS5
IP="c220g5-111221.wisc.cloudlab.us"
PORT=25213

# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/qos/nonvpn_facebook_audio niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/qos/nonvpn_facebook_video niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/qos/nonvpn_hangouts_audio niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/qos/nonvpn_hangouts_video niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/qos/nonvpn_netflix niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_skype_audio niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_skype_video niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_spotify niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_vimeo niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_voipbuster niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_youtube niltonm@$IP:/users/niltonm/Data

scp -P $PORT -r /media/nnmoc/Data/material_traffic_classification2/extracao_features/extrator_cython niltonm@$IP:/users/niltonm/

# ssh -p 25213 niltonm@c220g5-111221.wisc.cloudlab.us