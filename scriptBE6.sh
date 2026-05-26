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


# python main.py --service_class be --app_class facebook_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/facebookchat/
listar_arquivos "be" "facebook_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/facebookchat" 

# python main.py --service_class be --app_class hangouts_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/hangout_chat/
listar_arquivos "be" "hangouts_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/hangout_chat" 

# python main.py --service_class be --app_class hangouts_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/hangoutschat/
listar_arquivos "be" "hangouts_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/hangoutschat" 

# python main.py --service_class be --app_class icq_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/icqchat/
listar_arquivos "be" "icq_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/icqchat" 

# python main.py --service_class be --app_class icq_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/ICQ_Chat/
listar_arquivos "be" "icq_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/ICQ_Chat" 

# python main.py --service_class be --app_class pop_filetransfer --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/POP_filetransfer/
listar_arquivos "be" "pop_filetransfer" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/POP_filetransfer" 



# python main.py --service_class be --app_class download --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/SFTP_filetransfer2/
listar_arquivos "be" "download" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/SFTP_filetransfer2" 

# python main.py --service_class be --app_class skype_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/skype_chat/
listar_arquivos "be" "skype_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/skype_chat" 

# python main.py --service_class be --app_class download --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/skype_transfer/
listar_arquivos "be" "download" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/skype_transfer" 

# python main.py --service_class be --app_class browsing --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/SSL_Browsing/
listar_arquivos "be" "browsing" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/SSL_Browsing" 
