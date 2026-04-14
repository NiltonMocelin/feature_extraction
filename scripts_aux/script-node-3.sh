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
listar_arquivos "qos" "facebook_audio_estatico" "/users/niltonm/nonvpn_facebook_audio" &

listar_arquivos "qos" "facebook_video_estatico" "/users/niltonm/nonvpn_facebook_video" &

listar_arquivos "qos" "hangouts_audio_estatico" "/users/niltonm/nonvpn_hangouts_audio" &

wait
listar_arquivos "qos" "hangouts_video_real" "/users/niltonm/nonvpn_hangouts_video" &

listar_arquivos "qos" "netflix_video_estatico" "/users/niltonm/nonvpn_netflix" &
listar_arquivos "qos" "skype_audio_estatico" "/users/niltonm/nonvpn_skype_audio" &

wait

listar_arquivos "qos" "skype_video_real" "/users/niltonm/nonvpn_skype_video" & 
listar_arquivos "qos" "spotify_audio_estatico" "/users/niltonm/nonvpn_spotify" &
listar_arquivos "qos" "vimeo_video_estatico" "/users/niltonm/nonvpn_vimeo" &
wait
listar_arquivos "qos" "voipbuster_audio_real" "/users/niltonm/nonvpn_voipbuster" &
listar_arquivos "qos" "youtube_video_estatico" "/users/niltonm/nonvpn_youtube" &

wait

