# código extrair fluxos: ip_Src, ip_dst, port_src, port_dst, proto

#entrada: um pcap
#saida: varios pcaps de fluxos separados

import argparse
import os
import sys

from scapy.utils import rdpcap, PcapReader, PcapNgReader, PcapWriter, wrpcap #, RawPcapReader, 
from scapy.all import IP, UDP, TCP, Ether
# from scapy.all import *

#mapear arquivos pcap para pastas
# app_map = {'youtube':'video_estatico', 'netflix':'video_estatico', 'vimeo':'video_estatico',
#             'facebook_video':'video_real', 'hangouts_video':'video_real', 'skype_video':'video_real',
#             'bittorrent':'p2p',
#             'email':'be',
#             'down':'down', 'ftps':'down', 'Down':'down',
#             'sftp':'up', 'chat':'chat', '':'audio_real', '':'audio_est'}

prefixo = 'flow_total_' # +app + proto + ip_src + ip_dst + sport + dport 

def salvar_pacotes(fluxos_dict):
    for aux_nome_arquivo in fluxos_dict:
                
        print('escrevendo ', len(fluxos_dict[aux_nome_arquivo]), '-> ', aux_nome_arquivo)

        if fluxos_dict[aux_nome_arquivo] == []:
            continue

        _linktype = 101 # raw_ip

        if fluxos_dict[aux_nome_arquivo][0].haslayer(Ether):
            _linktype = 1 # ethernet

        wrpcap(aux_nome_arquivo, fluxos_dict[aux_nome_arquivo], append=True, linktype = _linktype)
        

def process_pcap(file_name):

    print('Opening {}...'.format(file_name))
    folder_saida = file_name.split('.')[0]
    arquivo_saida = prefixo + folder_saida

    #criar folder saida se não existir
    if not os.path.exists(folder_saida):
        os.makedirs(folder_saida)

    caminho_saida = folder_saida + '/' + arquivo_saida

    fluxos_dict = {} # nome arquivo : lista pacotes
    contador_pacotes = 0

    leitor = PcapReader
    if '.pcapng' in file_name:
        leitor = PcapNgReader

    for pkt in leitor(file_name):
    # for pkt in rdpcap(file_name):

        if(not pkt.haslayer(IP)): # and (pkt.haslayer(UDP) == False or pkt.haslayer(TCP) == False)) :
            continue

        if(pkt.haslayer(TCP)):
            proto='TCP'
        elif(pkt.haslayer(UDP)):
            proto='UDP'
        else:
            continue

        contador_pacotes += 1

        ip_src = pkt[IP].src
        ip_dst = pkt[IP].dst
        sport = pkt[proto].sport #ja é int
        dport = pkt[proto].dport #ja é int

        # a menor porta é do host A (para padronizar)
        if( sport > dport ):
            aux = sport
            sport = dport
            dport = aux

            aux=ip_src
            ip_src = ip_dst
            ip_dst = aux

        # pktdump = RawPcapWriter(newfile_name +".pcap", append=True, sync=True)
        # +app + proto + ip_src + ip_dst + sport + dport 
        # print('escrevendo: ' + ip_src)
        # linktype dos pcap são importantes para serem interpretados pelo tcptrace (aparentemente linktype 228 não tem suporte no tcptrace)
        # Tive erros com scapy escrevendo com linktype incompativel (PcapWriter, RawPcapWriter, wrpacp ...) -- com tshark não deu problema
        nome_arquivo = caminho_saida + '_' + proto + '_' + ip_src + '_' + ip_dst + '_' + str(sport) + '_' + str(dport) +".pcap"

        if nome_arquivo not in fluxos_dict:
            fluxos_dict[nome_arquivo] = []

        fluxos_dict[nome_arquivo].append(pkt)

        if contador_pacotes % 10000 == 0: # a cada 10k pacotes, escrever nos arquivos correspondentes
            salvar_pacotes(fluxos_dict)
            fluxos_dict.clear() # recomeçar 
    
    #caso nao tenha fechado 10k pacotes
    salvar_pacotes(fluxos_dict)
    fluxos_dict.clear()


if __name__ == '__main__':
    print("Extrator de fluxos: proto, ip_src, ip_dst, sport, dport")
    print("Lendo arquivos .pcap e .pcapng")
    for file in os.listdir():
        if os.path.isfile(file):
            if '.pcap' in file or '.pcapng' in file:
                #tratar o arquivo .pcap
                process_pcap(file)
                
#printar tempo de chegada de um pacote

# print('First packet in connection: Packet #{} {}'.
#           format(first_pkt_ordinal,
#                  printable_timestamp(first_pkt_timestamp,
#                                      first_pkt_timestamp_resolution)))

# import time

# def printable_timestamp(ts, resol):
#     ts_sec = ts // resol
#     ts_subsec = ts % resol
#     ts_sec_str = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(ts_sec))
#     return '{}.{}'.format(ts_sec_str, ts_subsec)