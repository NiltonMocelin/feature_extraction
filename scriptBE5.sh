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

# python main.py --service_class be --app_class aim_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/aimchat/
listar_arquivos "be" "aim_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/aimchat" 

# python main.py --service_class be --app_class aim_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/AIM_Chat/
listar_arquivos "be" "aim_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/AIM_Chat" 

# python main.py --service_class be --app_class browsing --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/browsing/
listar_arquivos "be" "browsing" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/browsing" 

# python main.py --service_class be --app_class browsing --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/browsing2/
listar_arquivos "be" "browsing" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/browsing2" 

# python main.py --service_class be --app_class browsing --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/browsing2-1/
listar_arquivos "be" "browsing" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/browsing2-1" 

# python main.py --service_class be --app_class browsing --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/browsing2-2/
listar_arquivos "be" "browsing" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/browsing2-2" 


# 

# python main.py --service_class be --app_class browsing --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/browsing_ara/
listar_arquivos "be" "browsing" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/browsing_ara" 

# python main.py --service_class be --app_class browsing --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/browsing_ara2/
listar_arquivos "be" "browsing" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/browsing_ara2" 

# python main.py --service_class be --app_class browsing --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/browsing_ger/
listar_arquivos "be" "browsing" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/browsing_ger" 

# python main.py --service_class be --app_class email_filetransfer --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/Email_IMAP_filetransfer/
listar_arquivos "be" "email_filetransfer" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/Email_IMAP_filetransfer" 

# python main.py --service_class be --app_class facebook_chat --folder_name /mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/facebook_chat/
listar_arquivos "be" "facebook_chat" "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/be/facebook_chat" 

