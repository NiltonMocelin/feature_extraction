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


listar_arquivos "qos" "tor_hangouts_audio_estatico" "/users/niltonm/tor_hangouts_audio" &


listar_arquivos  "qos" "tor_hangouts_audio_real" "/users/niltonm/tor_hangouts_voip" &


listar_arquivos  "qos" "tor_skype_audio_estatico" "/users/niltonm/tor_skype_audio" &

wait

listar_arquivos  "qos" "tor_skype_audio_real" "/users/niltonm/tor_skype_voip" &




listar_arquivos "qos" "tor_spotify_audio_estatico" "/users/niltonm/tor_spotify" &


listar_arquivos "qos" "tor_vimeo_video_estatico" "/users/niltonm/tor_vimeo"  &

wait


listar_arquivos "qos" "tor_facebook_audio_estatico" "/users/niltonm/tor_facebook_audio" 

listar_arquivos "qos" "tor_facebook_audio_real" "/users/niltonm/tor_facebook_voip" 

listar_arquivos "qos" "tor_youtube_video_estatico" "/users/niltonm/tor_youtube" 

wait