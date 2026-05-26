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

listar_arquivos "aux" "netflix_video_real" /media/nnmoc/Data/data_lake/valencia/valencia/netflix_linux_10m_01
listar_arquivos "aux" "netflix_video_real" /media/nnmoc/Data/data_lake/valencia/valencia/netflix_linux_20m_01
listar_arquivos "aux" "netflix_video_real" /media/nnmoc/Data/data_lake/valencia/valencia/netflix_linux_20m_02
listar_arquivos "aux" "netflix_video_real" /media/nnmoc/Data/data_lake/valencia/valencia/netflix_linux_20m_03
listar_arquivos "aux" "netflix_video_real" /media/nnmoc/Data/data_lake/valencia/valencia/netflix_linux_25m_01
listar_arquivos "aux" "netflix_video_real" /media/nnmoc/Data/data_lake/valencia/valencia/netflix_linux_35m_01
listar_arquivos "aux" "netflix_video_real" /media/nnmoc/Data/data_lake/valencia/valencia/netflix_linux_50m_01
listar_arquivos "aux" "netflix_video_real" /media/nnmoc/Data/data_lake/valencia/valencia/netflix_windows_10m_01
listar_arquivos "aux" "netflix_video_real" /media/nnmoc/Data/data_lake/valencia/valencia/netflix_windows_20m_01
listar_arquivos "aux" "prime_video_real" /media/nnmoc/Data/data_lake/valencia/valencia/prime_linux_20m_01
listar_arquivos "aux" "prime_video_real" /media/nnmoc/Data/data_lake/valencia/valencia/prime_linux_20m_02
listar_arquivos "aux" "prime_video_real" /media/nnmoc/Data/data_lake/valencia/valencia/prime_windows_20m_01
listar_arquivos "aux" "prime_video_real" /media/nnmoc/Data/data_lake/valencia/valencia/prime_windows_20m_02
listar_arquivos "aux" "game_roblox_real" /media/nnmoc/Data/data_lake/valencia/valencia/roblox_windows_20m_01
listar_arquivos "aux" "game_roblox_real" /media/nnmoc/Data/data_lake/valencia/valencia/roblox_windows_20m_02
listar_arquivos "aux" "game_roblox_real" /media/nnmoc/Data/data_lake/valencia/valencia/roblox_windows_20m_03
listar_arquivos "aux" "game_roblox_real" /media/nnmoc/Data/data_lake/valencia/valencia/roblox_windows_30m_01
listar_arquivos "aux" "game_roblox_real" /media/nnmoc/Data/data_lake/valencia/valencia/roblox_windows_30m_02
listar_arquivos "aux" "game_roblox_real" /media/nnmoc/Data/data_lake/valencia/valencia/roblox_windows_35m_01
listar_arquivos "aux" "spotify_static" /media/nnmoc/Data/data_lake/valencia/valencia/spotify_linux_30m_01
listar_arquivos "aux" "spotify_static" /media/nnmoc/Data/data_lake/valencia/valencia/spotify_linux_30m_02
listar_arquivos "aux" "spotify_static" /media/nnmoc/Data/data_lake/valencia/valencia/spotify_linux_30m_03
listar_arquivos "aux" "spotify_static" /media/nnmoc/Data/data_lake/valencia/valencia/spotify_windows_30m_01
listar_arquivos "aux" "spotify_static" /media/nnmoc/Data/data_lake/valencia/valencia/spotify_windows_30m_02
listar_arquivos "aux" "spotify_static" /media/nnmoc/Data/data_lake/valencia/valencia/spotify_windows_33m_01
listar_arquivos "aux" "teams_real" /media/nnmoc/Data/data_lake/valencia/valencia/teams_linux_20m_01
listar_arquivos "aux" "teams_real" /media/nnmoc/Data/data_lake/valencia/valencia/teams_linux_20m_02
listar_arquivos "aux" "teams_real" /media/nnmoc/Data/data_lake/valencia/valencia/teams_linux_20m_03
listar_arquivos "aux" "teams_real" /media/nnmoc/Data/data_lake/valencia/valencia/teams_windows_20m_01
listar_arquivos "aux" "teams_real" /media/nnmoc/Data/data_lake/valencia/valencia/teams_windows_20m_02
listar_arquivos "aux" "teams_real" /media/nnmoc/Data/data_lake/valencia/valencia/teams_windows_20m_03
listar_arquivos "aux" "browser" /media/nnmoc/Data/data_lake/valencia/valencia/web_linux_2m_owin6g
listar_arquivos "aux" "browser" /media/nnmoc/Data/data_lake/valencia/valencia/web_linux_2m_wikipedia
listar_arquivos "aux" "browser" /media/nnmoc/Data/data_lake/valencia/valencia/web_linux_3m_owin6g
listar_arquivos "aux" "browser" /media/nnmoc/Data/data_lake/valencia/valencia/web_linux_3m_wikipedia
listar_arquivos "aux" "browser" /media/nnmoc/Data/data_lake/valencia/valencia/web_linux_5m_amazon
listar_arquivos "aux" "browser" /media/nnmoc/Data/data_lake/valencia/valencia/web_linux_5m_bbc
listar_arquivos "aux" "browser" /media/nnmoc/Data/data_lake/valencia/valencia/web_linux_5m_google
listar_arquivos "aux" "browser" /media/nnmoc/Data/data_lake/valencia/valencia/web_linux_5m_linkedin
listar_arquivos "aux" "browser" /media/nnmoc/Data/data_lake/valencia/valencia/web_windows_3m_owin6g
listar_arquivos "aux" "browser" /media/nnmoc/Data/data_lake/valencia/valencia/web_windows_3m_wikipedia
listar_arquivos "aux" "browser" /media/nnmoc/Data/data_lake/valencia/valencia/web_windows_5m_amazon
listar_arquivos "aux" "browser" /media/nnmoc/Data/data_lake/valencia/valencia/web_windows_5m_bbc
listar_arquivos "aux" "browser" /media/nnmoc/Data/data_lake/valencia/valencia/web_windows_5m_google
listar_arquivos "aux" "browser" /media/nnmoc/Data/data_lake/valencia/valencia/web_windows_5m_linkedin
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/valencia/valencia/youtube_linux_20m_01
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/valencia/valencia/youtube_linux_20m_02
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/valencia/valencia/youtube_linux_20m_03
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/valencia/valencia/youtube_linux_20m_04
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/valencia/valencia/youtube_linux_20m_05
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/valencia/valencia/youtube_linux_20m_06
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/valencia/valencia/youtube_linux_25m_04
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/valencia/valencia/youtube_linux_30m_01
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/valencia/valencia/youtube_linux_30m_02
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/valencia/valencia/youtube_linux_30m_03
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/valencia/valencia/youtube_windows_20m_01
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/valencia/valencia/youtube_windows_25m_01
listar_arquivos "aux" "youtube_video_static" /media/nnmoc/Data/data_lake/valencia/valencia/youtube_windows_25m_02