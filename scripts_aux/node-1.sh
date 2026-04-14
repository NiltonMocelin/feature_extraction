# enviar para node-0
# enviar QoS2

IP="c220g5-111221.wisc.cloudlab.us"
PORT=25211

# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_hangouts_audio niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_hangouts_voip niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_skype_audio niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_skype_voip niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_spotify niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_vimeo niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_facebook_audio niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_facebook_voip niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_youtube niltonm@$IP:/users/niltonm/Data

scp -P $PORT -r /media/nnmoc/Data/material_traffic_classification2/extracao_features/extrator_cython niltonm@$IP:/users/niltonm/