# enviar para node-6
# enviar BE1
IP="c220g5-111221.wisc.cloudlab.us"
PORT=25215

# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/be/nonvpn_aimchat niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/be/nonvpn_email niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/be/nonvpn_facebook_chat niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/be/nonvpn_download niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/be/nonvpn_gmail_chat niltonm@$IP:/users/niltonm/Data
# scp -P $PORT -r /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/be/nonvpn_hangouts_chat niltonm@$IP:/users/niltonm/Data

scp -P $PORT -r /media/nnmoc/Data/material_traffic_classification2/extracao_features/extrator_cython niltonm@$IP:/users/niltonm/