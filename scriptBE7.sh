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

        for i in 10 30 50; do
            # O [ -f ] garante que processamos apenas ARQUIVOS (pula pastas)
            if [ -f "$arquivo" ]; then
                echo "Processando: $(basename "$arquivo") tam_bloco $i"
                python main_blocos_cython.py --block_size $i --service_class $service --app_class $app --file_name $arquivo
            fi
        done
    done
}

# python main.py --service_class qos --app_class vpn_facebook_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/qos/vpn_facebook_audio/
listar_arquivos "be" "vpn_facebook_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/qos/vpn_facebook_audio/be"

# python main.py --service_class qos --app_class vpn_hangouts_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/qos/vpn_hangouts_audio/
listar_arquivos "be" "vpn_hangouts_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/qos/vpn_hangouts_audio/be"

# python main.py --service_class qos --app_class vpn_netflix_video_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_netflix/
listar_arquivos "be" "vpn_netflix_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_netflix/be"

# python main.py --service_class qos --app_class vpn_skype_audio_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_skype_audio/
listar_arquivos "be" "vpn_skype_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_skype_audio/be"

# python main.py --service_class qos --app_class vpn_spotify_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_spotify/
listar_arquivos "be" "vpn_spotify_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_spotify/be"

# python main.py --service_class qos --app_class vpn_vimeo_video_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_vimeo/
listar_arquivos "be" "vpn_vimeo_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_vimeo/be"

# python main.py --service_class qos --app_class vpn_voipbuster_audio_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_voipbuster/
listar_arquivos "be" "vpn_voipbuster_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_voipbuster/be"

# python main.py --service_class qos --app_class vpn_youtube_video_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_youtube/
listar_arquivos "be" "vpn_youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_youtube/be"



#python main.py --service_class qos --app_class tor_hangouts_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_hangouts_audio/
listar_arquivos "be" "tor_hangouts_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_hangouts_audio/be"

#python main.py --service_class qos --app_class tor_hangouts_audio_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_hangouts_voip/
listar_arquivos  "be" "tor_hangouts_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_hangouts_voip/be"

#python main.py --service_class qos --app_class tor_skype_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_skype_audio/
listar_arquivos  "be" "tor_skype_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_skype_audio/be"

#python main.py --service_class qos --app_class tor_skype_audio_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_skype_voip/
listar_arquivos  "be" "tor_skype_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_skype_voip/be"



#python main.py --service_class qos --app_class tor_spotify_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_spotify/
listar_arquivos "be" "tor_spotify_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_spotify/be"

#python main.py --service_class qos --app_class tor_vimeo_video_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_vimeo/
listar_arquivos "be" "tor_vimeo_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_vimeo/be"

#python main.py --service_class qos --app_class tor_facebook_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_facebook_audio/
listar_arquivos "be" "tor_facebook_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_facebook_audio/be"

#python main.py --service_class qos --app_class tor_facebook_audio_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_facebook_voip/
listar_arquivos "be" "tor_facebook_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_facebook_voip/be"

#python main.py --service_class qos --app_class tor_youtube_video_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_youtube/
listar_arquivos "be" "tor_youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_youtube/be"


# python main.py --service_class qos --app_class facebook_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/facebook_Audio/
listar_arquivos "be" "facebook_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/facebook_Audio/be"

# python main.py --service_class qos --app_class hangouts_audio_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Hangouts_voice_Workstation/
listar_arquivos "be" "hangouts_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Hangouts_voice_Workstation/be"

# python main.py --service_class qos --app_class vimeo_video_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Vimeo_Workstation/
listar_arquivos "be" "vimeo_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Vimeo_Workstation/be"

# python main.py --service_class qos --app_class facebook_audio_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Facebook_Voice_Workstation/
listar_arquivos "be" "facebook_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Facebook_Voice_Workstation/be"

# python main.py --service_class qos --app_class skype_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Skype_Audio/
listar_arquivos "be" "skype_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Skype_Audio/be"

# python main.py --service_class qos --app_class hangouts_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Hangout_Audio/
listar_arquivos  "be" "hangouts_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Hangout_Audio/be"

# python main.py --service_class qos --app_class skype_audio_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Skype_Voice_Workstation/
listar_arquivos  "be" "skype_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Skype_Voice_Workstation/be"



# python main.py --service_class qos --app_class facebook_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/qos/nonvpn_facebook_audio/
listar_arquivos "be" "facebook_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/qos/nonvpn_facebook_audio/be"

# python main.py --service_class qos --app_class facebook_video_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/qos/nonvpn_facebook_video/
listar_arquivos "be" "facebook_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/qos/nonvpn_facebook_video/be"

# python main.py --service_class qos --app_class hangouts_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/qos/nonvpn_hangouts_audio/
listar_arquivos "be" "hangouts_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/qos/nonvpn_hangouts_audio/be"

# python main.py --service_class qos --app_class hangouts_video_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/qos/nonvpn_hangouts_video/
listar_arquivos "be" "hangouts_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/qos/nonvpn_hangouts_video/be"

# python main.py --service_class qos --app_class netflix_video_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/qos/nonvpn_netflix/
listar_arquivos "be" "netflix_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/qos/nonvpn_netflix/be"

# python main.py --service_class qos --app_class skype_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_skype_audio/
listar_arquivos "be" "skype_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_skype_audio/be"



# python main.py --service_class qos --app_class skype_video_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_skype_video/
listar_arquivos "be" "skype_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_skype_video/be"

# python main.py --service_class qos --app_class spotify_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_spotify/
listar_arquivos "be" "spotify_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_spotify/be"

# python main.py --service_class qos --app_class vimeo_video_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_vimeo/
listar_arquivos "be" "vimeo_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_vimeo/be"

# python main.py --service_class qos --app_class voipbuster_audio_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_voipbuster/
listar_arquivos "be" "voipbuster_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_voipbuster/be"

# python main.py --service_class qos --app_class youtube_video_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_youtube/
listar_arquivos "be" "youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_youtube/be"

