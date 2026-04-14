# enviar para node-7
# enviar BE2
IP="c220g5-111221.wisc.cloudlab.us"
PORT=25216

# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/be/nonvpn_icq_chat niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/be/nonvpn_upload niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/be/nonvpn_download niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/be/nonvpn_skype_chat niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/be/nonvpn_skype_download niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/be/nonvpn_upload niltonm@$IP:/users/niltonm/Data

scp -P $PORT -r /media/nnmoc/Data/material_traffic_classification2/extracao_features/extrator_cython niltonm@$IP:/users/niltonm/