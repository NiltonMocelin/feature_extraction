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

#python main.py --service_class qos --app_class tor_hangouts_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_hangouts_audio/ 
listar_arquivos "qos" "tor_hangouts_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_hangouts_audio" 

#python main.py --service_class qos --app_class tor_hangouts_audio_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_hangouts_voip/  
listar_arquivos  "qos" "tor_hangouts_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_hangouts_voip" 

#python main.py --service_class qos --app_class tor_skype_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_skype_audio/    
listar_arquivos  "qos" "tor_skype_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_skype_audio" 

#python main.py --service_class qos --app_class tor_skype_audio_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_skype_voip/     
listar_arquivos  "qos" "tor_skype_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_skype_voip" 



#python main.py --service_class qos --app_class tor_spotify_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_spotify/        
listar_arquivos "qos" "tor_spotify_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_spotify" 

#python main.py --service_class qos --app_class tor_vimeo_video_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_vimeo/
listar_arquivos "qos" "tor_vimeo_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_vimeo"  



#python main.py --service_class qos --app_class tor_facebook_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_facebook_audio/
listar_arquivos "qos" "tor_facebook_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_facebook_audio" 

#python main.py --service_class qos --app_class tor_facebook_audio_real --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_facebook_voip/
listar_arquivos "qos" "tor_facebook_audio_real" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_facebook_voip" 

#python main.py --service_class qos --app_class tor_youtube_video_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_youtube/
listar_arquivos "qos" "tor_youtube_video_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_youtube" 

