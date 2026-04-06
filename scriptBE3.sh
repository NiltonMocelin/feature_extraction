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

# python main.py --service_class be --app_class tor_browsing --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/be/tor_browsing/
listar_arquivos "be" "tor_browsing" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/be/tor_browsing"

# python main.py --service_class be --app_class tor_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/be/tor_chat/
listar_arquivos "be" "tor_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/be/tor_chat"

# python main.py --service_class be --app_class tor_data_transfer --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/be/tor_data_transfer/
listar_arquivos "be" "tor_data_transfer" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/be/tor_data_transfer"
# ate aqui marromenso

python main.py --service_class be --app_class tor_mail --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/be/tor_mail/
listar_arquivos "be" "tor_mail" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/be/tor_mail"

# python main.py --service_class be --app_class tor_p2p --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/be/tor_p2p/
listar_arquivos "be" "tor_p2p" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/be/tor_p2p"

# python main.py --service_class be --app_class vpn_aim_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/be/vpn_aim_chat/
listar_arquivos "be" "vpn_aim_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/be/vpn_aim_chat"