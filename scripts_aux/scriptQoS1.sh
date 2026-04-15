# for file in 

listar_arquivos() {
    local service="$1"
    local app="$2"
    local caminho="$3"

    # Verifica se o diretório existe
    if [ ! -d "$caminho" ]; then
        echo "Erro: O diretório '$caminho' não existe."
        return 1
    fi

    # Loop pelos itens do diretório
    for arquivo in "$caminho"/*; do

        for i in 10 20 30 50 100; do
            # O [ -f ] garante que processamos apenas ARQUIVOS (pula pastas)
            if [ -f "$arquivo" ]; then
                echo "Processando: $(basename "$arquivo") tam_bloco $i"
                python main_blocos_cython_pypcap.py --block_size $i --service_class $service --app_class $app --file_name $arquivo
            fi
        done
    done
}

# python main.py --service_class qos --app_class vpn_facebook_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/qos/vpn_facebook_audio/ 
listar_arquivos "qos" "vpn_facebook_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/qos/vpn_facebook_audio" &

#exit(0)

# python main.py --service_class qos --app_class vpn_hangouts_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/qos/vpn_hangouts_audio/
listar_arquivos "qos" "vpn_hangouts_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/qos/vpn_hangouts_audio" &

# python main.py --service_class qos --app_class vpn_netflix_video_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_netflix/
listar_arquivos "qos" "vpn_netflix_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_netflix" &

# python main.py --service_class qos --app_class vpn_skype_audio_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_skype_audio/ 
listar_arquivos "qos" "vpn_skype_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_skype_audio" &

# python main.py --service_class qos --app_class vpn_spotify_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_spotify/ 
listar_arquivos "qos" "vpn_spotify_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_spotify" &

# python main.py --service_class qos --app_class vpn_vimeo_video_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_vimeo/ 
listar_arquivos "qos" "vpn_vimeo_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_vimeo" &

wait

# python main.py --service_class qos --app_class vpn_voipbuster_audio_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_voipbuster/ 
listar_arquivos "qos" "vpn_voipbuster_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_voipbuster" &

# python main.py --service_class qos --app_class vpn_youtube_video_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_youtube/ 
listar_arquivos "qos" "vpn_youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_youtube" &

wait
