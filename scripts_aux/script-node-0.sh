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

listar_arquivos "qos" "vpn_facebook_audio_estatico" "/users/niltonm/vpn_facebook_audio" &

listar_arquivos "qos" "vpn_hangouts_audio_estatico" "/users/niltonm/vpn_hangouts_audio" &

listar_arquivos "qos" "vpn_netflix_video_estatico" "/users/niltonm/vpn_netflix" &

wait

listar_arquivos "qos" "vpn_skype_audio_real" "/users/niltonm/vpn_skype_audio" &

listar_arquivos "qos" "vpn_spotify_audio_estatico" "/users/niltonm/vpn_spotify" &

listar_arquivos "qos" "vpn_vimeo_video_estatico" "/users/niltonm/vpn_vimeo" &

wait

listar_arquivos "qos" "vpn_voipbuster_audio_real" "/users/niltonm/vpn_voipbuster" &

listar_arquivos "qos" "vpn_youtube_video_estatico" "/users/niltonm/vpn_youtube" &

wait
