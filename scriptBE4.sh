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

# python main.py --service_class be --app_class vpn_download --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/be/vpn_download/
listar_arquivos "be" "vpn_download" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/be/vpn_download"

# python main.py --service_class be --app_class vpn_email --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/be/vpn_email/
listar_arquivos "be" "vpn_email" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/be/vpn_email"

# python main.py --service_class be --app_class vpn_facebook_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/be/vpn_facebook_chat/
listar_arquivos "be" "vpn_facebook_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/be/vpn_facebook_chat"

# python main.py --service_class be --app_class vpn_hangouts_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/be/vpn_hangouts_chat/
listar_arquivos "be" "vpn_hangouts_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/be/vpn_hangouts_chat"

# python main.py --service_class be --app_class vpn_p2p --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/be/vpn_p2p/
listar_arquivos "be" "vpn_p2p" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/be/vpn_p2p"

# ate aqui

python main.py --service_class be --app_class vpn_download --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/be/vpn_download/
listar_arquivos "be" "vpn_download" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/be/vpn_download"

# python main.py --service_class be --app_class vpn_icq_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/be/vpn_icq_chat/
listar_arquivos "be" "vpn_icq_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/be/vpn_icq_chat"

# python main.py --service_class be --app_class vpn_skype_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/be/vpn_skype_chat/
listar_arquivos "be" "vpn_skype_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/be/vpn_skype_chat"