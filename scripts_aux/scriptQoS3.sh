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

# python main.py --service_class qos --app_class facebook_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/facebook_Audio/
listar_arquivos "qos" "facebook_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/facebook_Audio" & 

# python main.py --service_class qos --app_class hangouts_audio_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Hangouts_voice_Workstation/
listar_arquivos "qos" "hangouts_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Hangouts_voice_Workstation" &

# python main.py --service_class qos --app_class vimeo_video_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Vimeo_Workstation/
listar_arquivos "qos" "vimeo_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Vimeo_Workstation" &

# python main.py --service_class qos --app_class facebook_audio_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Facebook_Voice_Workstation/
listar_arquivos "qos" "facebook_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Facebook_Voice_Workstation" &

# python main.py --service_class qos --app_class skype_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Skype_Audio/
listar_arquivos "qos" "skype_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Skype_Audio" &

# python main.py --service_class qos --app_class hangouts_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Hangout_Audio/
listar_arquivos  "qos" "hangouts_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Hangout_Audio" &

wait

# python main.py --service_class qos --app_class skype_audio_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Skype_Voice_Workstation/
listar_arquivos  "qos" "skype_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Skype_Voice_Workstation" &

wait


