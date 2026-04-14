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


listar_arquivos "be" "icq_chat" "/users/niltonm/nonvpn_icq_chat" &

listar_arquivos "be" "upload" "/users/niltonm/nonvpn_upload" &

listar_arquivos "be" "download" "/users/niltonm/nonvpn_download"  &


wait
listar_arquivos "be" "skype_chat" "/users/niltonm/nonvpn_skype_chat" &

listar_arquivos "be" "skype_download" "/users/niltonm/nonvpn_skype_download" &

listar_arquivos "be" "upload" "/users/niltonm/nonvpn_upload" &


wait