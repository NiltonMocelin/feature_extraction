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



# python main.py --service_class be --app_class aim_chat --folder_name  /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/be/nonvpn_aimchat
listar_arquivos "be" "aim_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/be/nonvpn_aimchat"

# python main.py --service_class be --app_class email --folder_name  /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/be/nonvpn_email
listar_arquivos "be" "email" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/be/nonvpn_email"

# python main.py --service_class be --app_class facebook_chat --folder_name  /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/be/nonvpn_facebook_chat
listar_arquivos "be" "facebook_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/be/nonvpn_facebook_chat"

# python main.py --service_class be --app_class download --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/be/nonvpn_download
listar_arquivos "be" "download" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/be/nonvpn_download"

python main.py --service_class be --app_class gmail_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/be/nonvpn_gmail_chat
listar_arquivos "be" "gmail_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/be/nonvpn_gmail_chat"

# # python main.py --service_class be --app_class hangouts_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/be/nonvpn_hangouts_chat
listar_arquivos "be" "hangouts_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/be/nonvpn_hangouts_chat"