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
                python main_blocos_cython_pypcap.py --block_size $i --service_class $service --app_class $app --file_name $arquivo
            fi
        done
    done
}

# python main.py --service_class qos --app_class vpn_facebook_audio_estatico --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/qos/vpn_facebook_audio/ 
listar_arquivos "qos" "vpn_facebook_audio_estatico" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/qos/vpn_facebook_audio" 
