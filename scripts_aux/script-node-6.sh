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



listar_arquivos "be" "aim_chat" "/users/niltonm/nonvpn_aimchat" &

listar_arquivos "be" "email" "/users/niltonm/nonvpn_email" &
listar_arquivos "be" "facebook_chat" "/users/niltonm/nonvpn_facebook_chat" &
wait


listar_arquivos "be" "download" "/users/niltonm/nonvpn_download" & 


listar_arquivos "be" "gmail_chat" "/users/niltonm/nonvpn_gmail_chat" &


listar_arquivos "be" "hangouts_chat" "/users/niltonm/nonvpn_hangouts_chat" &

wait