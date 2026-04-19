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

        for i in 10 20 30 50 100; do
            # O [ -f ] garante que processamos apenas ARQUIVOS (pula pastas)
            if [ -f "$arquivo" ]; then
                echo "Processando: $(basename "$arquivo") tam_bloco $i"
                python main_blocos_cython_pypcap.py --block_size $i --service_class $service --app_class $app --file_name $arquivo
            fi
        done
    done
}


# python main.py --service_class be --app_class icq_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/be/nonvpn_icq_chat/
listar_arquivos "be" "icq_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/be/nonvpn_icq_chat" 

# python main.py --service_class be --app_class upload --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/be/nonvpn_upload/
listar_arquivos "be" "upload" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/be/nonvpn_upload" 

# python main.py --service_class be --app_class download --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/be/nonvpn_download/
listar_arquivos "be" "download" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/be/nonvpn_download"  
# ate aqui mais ou menos

# python main.py --service_class be --app_class skype_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/be/nonvpn_skype_chat/
listar_arquivos "be" "skype_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/be/nonvpn_skype_chat" 

# python main.py --service_class be --app_class skype_download --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/be/nonvpn_skype_download/
listar_arquivos "be" "skype_download" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/be/nonvpn_skype_download" 

# python main.py --service_class be --app_class upload --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/be/nonvpn_upload/
listar_arquivos "be" "upload" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/be/nonvpn_upload" 


