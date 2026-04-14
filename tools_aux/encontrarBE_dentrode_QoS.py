# estrategia 3
import os
from scapy.all import * # corrige erro "PcapReader: unknown LL type [1]/[0x1]. Using Raw packets
import numpy as np


def number_of_packets(pcap_file):
    count = 0
    with PcapReader(pcap_file) as pcap_reader:
        for packet in pcap_reader:
            count += 1
            
            ## PROVISORIO REMOVER
            if count >= 1200:
                break
    return count

def ler_pcap(pcap_file, parar_em=1200):
    nparray_pacotes = np.empty(number_of_packets(pcap_file), dtype=object)

    index = 0
    with PcapReader(pcap_file) as pcap_reader:
        for packet in pcap_reader:
            if packet is None:
                print(f"Pacote nulo encontrado no arquivo {pcap_file} no índice {index}. Pulando este pacote.")
            nparray_pacotes[index] = Raw(packet)
            index += 1
    
            if index >= parar_em:
                break
    return nparray_pacotes

def listar_qtd_blocos_sem_pacotes(chunks_pacotes):
    
    qtd_blocos_sem_pacotes = 0
    
    for packet in chunks_pacotes:
        if packet is None:
            qtd_blocos_sem_pacotes += 1
            
    print(f"Quantidade de blocos sem pacotes: {qtd_blocos_sem_pacotes}")

def mover_arquivo_para_pasta(pcap_file, pasta_destino):
    if not os.path.exists(pasta_destino):
        os.makedirs(pasta_destino)
    
    nome_arquivo = os.path.basename(pcap_file)
    destino = os.path.join(pasta_destino, nome_arquivo)
    
    os.rename(pcap_file, destino)
    # print(f"Arquivo {nome_arquivo} movido para {pasta_destino}")

def getchunksPacotes_tempoFixo(array_pacotes, qtd_chunks, duracao_chunk):
    
    if len(array_pacotes) == 0:
        return np.array([])  # Retorna um array vazio se não houver pacotes
    
    lista_chunks = [] 

    tempo_primeiro_pkt = float(array_pacotes[0].time)
    delta = duracao_chunk #5/10 == 0.5s

    for _ in range(qtd_chunks):
        lista_chunks.append([])

    for pkt in array_pacotes:
        tempo_decorrido = float(pkt.time) - tempo_primeiro_pkt
        indice = int(tempo_decorrido/delta)

        if tempo_decorrido >= duracao_chunk * qtd_chunks:
            indice = -1
        lista_chunks[indice].append(pkt)
    return np.array(lista_chunks, dtype=object)

def contar_tam_pkts_chunks(nparray_chunks_pacotes):
    volume = 0
    for chunk in nparray_chunks_pacotes:
        volume += np.sum([len(pkt) for pkt in chunk])
    return volume

def contar_blocos_sem_pacotes(narray_chunks_pacotes):
    count = 0
    for i, row in enumerate(narray_chunks_pacotes):
        count += np.sum(len(row) == 0)
        # count += np.sum(len(row))
    return count

def print_tamanho_chunks(chunks_pacotes):
    index = 0
    for chunk in chunks_pacotes:
        print(f"[{index}]{len(chunk)}", end=", ")
        index+=1  
    print()          
def estrategia3(folder_pcaps):
    
    TEMPO_OBSERVADO_TOTAL = 25 # 5 subfluxos do mesmo fluxo == 25s, 20s de cada fluxo, gerando 10 arquivos de saida
    TEMPO_SUBFLOW = 5 #segundos hardtimeout
    QTD_CHUNKS = 10 # 0.5 segundos
    TEMPO_CHUNK = TEMPO_SUBFLOW / QTD_CHUNKS # 0.5 segundos
    PROTO = 'TCP'
    
    for pcap_file in os.listdir(folder_pcaps):
        if pcap_file.endswith('.pcap') and (PROTO in pcap_file or PROTO.lower() in pcap_file):
            caminho_pcap = os.path.join(folder_pcaps, pcap_file)
            nparray_pacotes = ler_pcap(caminho_pcap)
            qtd_pacotes = len(nparray_pacotes)# qtd_pacotes            
            duracao = float(nparray_pacotes[qtd_pacotes-1].time - nparray_pacotes[0].time)
            nparray_chunks_pacotes = getchunksPacotes_tempoFixo(nparray_pacotes, QTD_CHUNKS, TEMPO_CHUNK)
            # print_tamanho_chunks(nparray_chunks_pacotes)
            qtd_blocos_sem_pacotes = contar_blocos_sem_pacotes(nparray_chunks_pacotes)
            volume = contar_tam_pkts_chunks(nparray_chunks_pacotes)
            lb = volume / duracao
            volume_por_chunk =  np.array([contar_tam_pkts_chunks(chunk) for chunk in nparray_chunks_pacotes], dtype=int)
            lb_por_chunk = volume_por_chunk/ TEMPO_CHUNK
    
            # contar qtd fluxos com mais de 3 blocos sem pacotes
            # if qtd_blocos_sem_pacotes > 3:
            if lb < 50*1024: # 100 kbps
            # if qtd_pacotes < 100:
                # print(f"{qtd_blocos_sem_pacotes} blocos sem pacotes, {qtd_pacotes} pacotes, volume: {volume} bytes, duração: {duracao:.2f} s, lb: {lb:.2f} bytes/s, volume por chunk: {volume_por_chunk}, lb por chunk: {lb_por_chunk}: {pcap_file}")
                mover_arquivo_para_pasta(caminho_pcap,f"{folder_pcaps}/be/")
                
    return

# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/facebook_Audio")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Facebook_Voice_Workstation")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Hangout_Audio")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Hangouts_voice_Workstation")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Skype_Audio")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Skype_Voice_Workstation")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonTor-fixed/qos/Vimeo_Workstation")

# # listando arquivos com mais de 3 blocos sem pacotes, ou seja, com mais de 1.5s sem pacotes
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/qos/nonvpn_facebook_audio")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-01/qos/nonvpn_facebook_video")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/qos/nonvpn_hangouts_audio/")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-02/qos/nonvpn_hangouts_video/")


# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_skype_audio")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_skype_video")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_spotify")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_vimeo")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_voipbuster")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/NonVPN-PCAPs-03/qos/nonvpn_youtube")

# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_facebook_audio")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_facebook_voip")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_hangouts_audio")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_hangouts_voip")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_skype_audio")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_skype_voip")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_spotify")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_vimeo")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_youtube")

# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/qos/vpn_facebook_audio")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPS-01/qos/vpn_hangouts_audio")

# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_netflix")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_skype_audio")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_spotify")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_vimeo")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_voipbuster")
# estrategia3("/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/VPN-PCAPs-02/qos/vpn_youtube")

# minha base
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/chess_1')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/chess_2')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/cs2')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/cs2-deathmatch-15ms')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/cs2-deathmatch2-15ms')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/gmeeting_audio_real')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/online-chess')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_twitch_real_1080p60fps')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_twitch_static_1080p60fps')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_yt_real_480p_apenasudp')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_yt_real_fullhd_ou_hd')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_yt_static_1080p60fps')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/teste_yt_static_360p')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_real_1080p60_1')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_real_1080p60_2')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_real_480_1')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_real_480_2')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_real_720p60_1')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_1080p60_1')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_1080p60_2')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_480_1')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_480_2')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_720p60_1')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/twitch_static_720p60_2')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/ufc_streaming')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_1080p_1')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_1080p_2')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_480p_1')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_480p_2')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_720p_1')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_static_720p_2')


estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/spotify_audio_estatico')
estrategia3('/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/minha_base/qos/youtube_audio_estatico')
