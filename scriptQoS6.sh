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

listar_arquivos "qos" "gaming_chess" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/chess_1" 
listar_arquivos "qos" "gaming_chess" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/chess_2" 
listar_arquivos "qos" "gaming_cs2" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/cs2" 
listar_arquivos "qos" "gaming_cs2" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/cs2-deathmatch-15ms" 
listar_arquivos "qos" "gaming_cs2" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/cs2-deathmatch2-15ms" 
listar_arquivos "qos" "meeting_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/gmeeting_audio_real" 




listar_arquivos "qos" "gaming_chess" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/online-chess" 
listar_arquivos "qos" "spotify_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/spotify_audio_estatico" 
listar_arquivos "qos" "twitch_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_twitch_real_1080p60fps" 
listar_arquivos "qos" "twitch_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_twitch_static_1080p60fps" 
listar_arquivos "qos" "youtube_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_yt_real_480p_apenasudp" 
listar_arquivos "qos" "youtube_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_yt_real_fullhd_ou_hd" 



listar_arquivos "qos" "youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_yt_static_1080p60fps" 
listar_arquivos "qos" "youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_yt_static_360p" 
listar_arquivos "qos" "twitch_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_real_1080p60_1" 
listar_arquivos "qos" "twitch_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_real_1080p60_2" 
listar_arquivos "qos" "twitch_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_real_480_1" 
listar_arquivos "qos" "twitch_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_real_480_2" 




listar_arquivos "qos" "twitch_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_real_720p60_1" 
listar_arquivos "qos" "twitch_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_1080p60_1" 
listar_arquivos "qos" "twitch_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_1080p60_2" 
listar_arquivos "qos" "twitch_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_480_1" 
listar_arquivos "qos" "twitch_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_480_2" 
listar_arquivos "qos" "twitch_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_720p60_1" 



listar_arquivos "qos" "twitch_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_720p60_2" 
listar_arquivos "qos" "ufc_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/ufc_streaming" 
listar_arquivos "qos" "youtube_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_audio_estatico" 
listar_arquivos "qos" "youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_1080p_1" 
listar_arquivos "qos" "youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_1080p_2" 
listar_arquivos "qos" "youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_480p_1" 




listar_arquivos "qos" "youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_480p_2" 
listar_arquivos "qos" "youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_720p_1" 
listar_arquivos "qos" "youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_720p_2" 


