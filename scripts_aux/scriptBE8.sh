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

listar_arquivos "be" "gaming_chess" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/chess_1/be" &
listar_arquivos "be" "gaming_chess" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/chess_2/be" &
listar_arquivos "be" "gaming_cs2" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/cs2/be" &
listar_arquivos "be" "gaming_cs2" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/cs2-deathmatch-15ms/be" &
listar_arquivos "be" "gaming_cs2" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/cs2-deathmatch2-15ms/be" &
listar_arquivos "be" "meeting_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/gmeeting_audio_real/be" &

wait

listar_arquivos "be" "gaming_chess" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/online-chess/be" &
listar_arquivos "be" "spotify_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/spotify_audio_estatico/be" &
listar_arquivos "be" "twitch_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_twitch_real_1080p60fps/be" &
listar_arquivos "be" "twitch_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_twitch_static_1080p60fps/be" &
listar_arquivos "be" "youtube_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_yt_real_480p_apenasudp/be" &
listar_arquivos "be" "youtube_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_yt_real_fullhd_ou_hd/be" &

wait

listar_arquivos "be" "youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_yt_static_1080p60fps/be" &
listar_arquivos "be" "youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_yt_static_360p/be" &
listar_arquivos "be" "twitch_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_real_1080p60_1/be" &
listar_arquivos "be" "twitch_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_real_1080p60_2/be" &
listar_arquivos "be" "twitch_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_real_480_1/be" &
listar_arquivos "be" "twitch_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_real_480_2/be" &

wait


listar_arquivos "be" "twitch_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_real_720p60_1/be" &
listar_arquivos "be" "twitch_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_1080p60_1/be" &
listar_arquivos "be" "twitch_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_1080p60_2/be" &
listar_arquivos "be" "twitch_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_480_1/be" &
listar_arquivos "be" "twitch_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_480_2/be" &
listar_arquivos "be" "twitch_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_720p60_1/be" &

wait


listar_arquivos "be" "twitch_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_720p60_2/be" &
listar_arquivos "be" "ufc_video_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/ufc_streaming/be" &
listar_arquivos "be" "youtube_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_audio_estatico/be" &
listar_arquivos "be" "youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_1080p_1/be" &
listar_arquivos "be" "youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_1080p_2/be" &
listar_arquivos "be" "youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_480p_1/be" &

wait

listar_arquivos "be" "youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_480p_2/be" &
listar_arquivos "be" "youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_720p_1/be" &
listar_arquivos "be" "youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_720p_2/be" &
wait
