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

listar_arquivos "aux" "netflix_video_static" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_netflix_capture1
listar_arquivos "aux" "netflix_video_static" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_netflix_capture2
listar_arquivos "aux" "rdp_interativo" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_rdp_capture1
listar_arquivos "aux" "rdp_interativo" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_rdp_capture2
listar_arquivos "aux" "rdp_interativo" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_rdp_capture3
listar_arquivos "aux" "rdp_interativo" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_rdp_capture4
listar_arquivos "aux" "rdp_interativo" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_rdp_capture_5
listar_arquivos "aux" "rsync" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_rsync_capture1
listar_arquivos "aux" "rsync" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_rsync_newcapture1
listar_arquivos "aux" "scp" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_scp_capture1
listar_arquivos "aux" "scp" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_scp_long_capture1
listar_arquivos "aux" "scp" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_scp_newcapture1
listar_arquivos "aux" "sftp" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_sftp_capture1
listar_arquivos "aux" "sftp" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_sftp_capture2
listar_arquivos "aux" "sftp" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_sftp_capture3
listar_arquivos "aux" "sftp" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_sftp_newcapture1
listar_arquivos "aux" "sftp" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_sftp_newcapture2
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture1
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture10
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture11
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture12
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture13
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture14
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture15
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture16
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture17
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture18
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture19
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture2
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture20
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture21
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture22
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture23
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture24
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture25
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture26
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture27
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture28
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture29
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture3
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture30
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture31
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture32
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture33
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture34
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture35
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture36
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture37
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture38
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture39
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture40
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture41
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture42
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture43
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture44
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture45
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture46
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture47
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture48
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture49
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture5
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture50
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture51
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture52
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture53
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture54
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture6
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture7
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture8
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_skype-chat_capture9
listar_arquivos "aux" "ssh" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_ssh_capture1
listar_arquivos "aux" "ssh" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_ssh_capture2
listar_arquivos "aux" "ssh" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_ssh_capture3
listar_arquivos "aux" "ssh" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_ssh_capture4
listar_arquivos "aux" "ssh" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_ssh_capture5
listar_arquivos "aux" "vimeo_video_static" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_vimeo_capture1
listar_arquivos "aux" "voip_audio_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_voip_capture1
listar_arquivos "aux" "voip_audio_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_voip_capture2
listar_arquivos "aux" "voip_audio_real" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_voip_capture3
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_youtube_capture1
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_youtube_capture2
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_youtube_capture3
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/vnat/vnat/nonvpn_youtube_capture4
listar_arquivos "aux" "netflix_static" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_netflix_capture2
listar_arquivos "aux" "rdp_iterativo" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_rdp_capture1
listar_arquivos "aux" "rdp_iterativo" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_rdp_capture2
listar_arquivos "aux" "rdp_iterativo" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_rdp_capture_3
listar_arquivos "aux" "rsync" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_rsync_capture1
listar_arquivos "aux" "rsync" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_rsync_capture2
listar_arquivos "aux" "rsync" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_rsync_capture3
listar_arquivos "aux" "scp" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_scp_capture1
listar_arquivos "aux" "sftp" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_scp_capture2
listar_arquivos "aux" "sftp" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_sftp_capture1
listar_arquivos "aux" "sftp" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_sftp_capture3
listar_arquivos "aux" "sftp" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_sftp_capture4
listar_arquivos "aux" "sftp" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_sftp_capture5
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture1
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture10
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture11
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture12
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture13
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture14
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture15
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture16
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture17
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture18
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture19
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture2
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture20
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture21
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture22
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture23
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture24
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture25
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture26
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture27
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture28
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture29
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture3
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture30
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture31
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture32
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture33
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture34
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture35
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture36
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture37
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture38
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture39
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture4
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture40
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture41
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture42
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture43
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture44
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture45
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture46
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture47
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture48
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture49
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture5
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture50
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture51
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture52
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture53
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture54
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture55
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture56
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture57
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture6
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture7
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture8
listar_arquivos "aux" "skype_chat_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_skype-chat_capture9
listar_arquivos "aux" "ssh" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_ssh_capture1
listar_arquivos "aux" "ssh" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_ssh_capture2
listar_arquivos "aux" "ssh" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_ssh_capture3
listar_arquivos "aux" "ssh" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_ssh_capture4
listar_arquivos "aux" "ssh" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_ssh_capture5
listar_arquivos "aux" "vimeo_video_static" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_vimeo_capture1
listar_arquivos "aux" "voip_audio_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_voip_capture1
listar_arquivos "aux" "voip_audio_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_voip_capture2
listar_arquivos "aux" "voip_audio_real" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_voip_capture3
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_youtube_capture1
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_youtube_capture2
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/vnat/vnat/vpn_youtube_capture3