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

listar_arquivos "qos" "facebook_audio_estatico" "/users/niltonm/facebook_Audio" & 
listar_arquivos "qos" "hangouts_audio_real" "/users/niltonm/Hangouts_voice_Workstation" &
listar_arquivos "qos" "vimeo_video_estatico" "/users/niltonm/Vimeo_Workstation" &

wait
listar_arquivos "qos" "facebook_audio_real" "/users/niltonm/Facebook_Voice_Workstation" &
listar_arquivos "qos" "skype_audio_estatico" "/users/niltonm/Skype_Audio" &
listar_arquivos  "qos" "hangouts_audio_estatico" "/users/niltonm/Hangout_Audio" &

wait

listar_arquivos  "qos" "skype_audio_real" "/users/niltonm/Skype_Voice_Workstation" &

wait


