
# MUIIITO LENTO (cada filtro precisa ler todo o arquivo pcap !!!)
# código extrair fluxos: ip_Src, ip_dst, port_src, port_dst, proto

#entrada: um pcap
#saida: varios pcaps de fluxos separados

import os
import pyshark

from scapy.utils import PcapReader, PcapNgReader
from scapy.all import *
# from scapy.all import *

prefixo = 'flow_total_' # +app + proto + ip_src + ip_dst + sport + dport 

def pyshark_filter_to_file(input_file, filter_string, output_file):
    # Open the input file with a display filter and specify an output file
    # The packets will be automatically written to the output file
    capture = pyshark.FileCapture(
        input_file,
        display_filter=filter_string,
        output_file=output_file
    )

    # Iterate through the packets to process them and trigger the save operation
    # This loads the packets into memory, so be mindful of file size
    try:
        capture.load_packets()
        print(f"Filtered packets saved to {output_file}")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        # It is good practice to close the capture object
        capture.close()

def get_filtros(file_name):
    dict_fluxos = {} # ip_src, ip_dst, proto, src_port, dst_port

    leitor = PcapReader

    if '.pcapng' in file_name:
        leitor = PcapNgReader

    # for pkt in leitor(file_name):
    for pkt in leitor(file_name):

        if(not pkt.haslayer('IP')): # and (pkt.haslayer(UDP) == False or pkt.haslayer(TCP) == False)) :
            continue

        if(pkt.haslayer('TCP')):
            proto='TCP'
        elif(pkt.haslayer('UDP')):
            proto='UDP'
        else:
            continue

        ip_src = pkt.getlayer('IP').src
        ip_dst = pkt.getlayer('IP').dst
        sport = pkt.getlayer(proto).sport #ja é int
        dport = pkt.getlayer(proto).dport #ja é int

        # manter o padrão -- o ip com a menor porta é a origem -- pode dar problema, mas é muito raro
        if sport > dport:
            aux = ip_src
            ip_src = ip_dst
            ip_dst = aux

            aux = sport
            sport = dport
            dport = aux

        aux_proto = 'tcp' if proto == 'TCP' else 'udp'
        filtro = f'(ip.src == {ip_src} and ip.dst == {ip_dst} and {aux_proto}.srcport == {sport} and {aux_proto}.dstport == {dport}) || (ip.src == {ip_dst} and ip.dst == {ip_src} and {aux_proto}.srcport == {dport} and {aux_proto}.dstport == {sport})'

        if filtro not in dict_fluxos:
            dict_fluxos[filtro]= f"_{proto}_{ip_src}_{ip_dst}_{sport}_{dport}.pcap"
    
    return dict_fluxos

def process_pcap(file_name):

    print('Opening {}...'.format(file_name))
    folder_saida = file_name.split('.')[0]
    arquivo_saida = prefixo + folder_saida

    #criar folder saida se não existir
    if not os.path.exists(folder_saida):
        os.makedirs(folder_saida)

    caminho_saida = folder_saida + '/' + arquivo_saida

    dict_fluxos = get_filtros(file_name)

    # linktype dos pcap são importantes para serem interpretados pelo tcptrace (aparentemente linktype 228 não tem suporte no tcptrace)
    for key in dict_fluxos:
        print('escrevendo em: ', caminho_saida)
        pyshark_filter_to_file(file_name, key, caminho_saida+dict_fluxos[key])
        # saida = subprocess.run(["tshark", "-r", file_name, "-Y", key, "-w", caminho_saida + dict_fluxos[key]], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        # print(saida.stdout, ' err? :', saida.stderr)

if __name__ == '__main__':
    print("Extrator de fluxos: proto, ip_src, ip_dst, sport, dport")
    print("Lendo arquivos .pcap e .pcapng")
    for file in sorted(os.listdir()):
        if os.path.isfile(file):
            if '.pcap' in file or '.pcapng' in file:
                #tratar o arquivo .pcap
                process_pcap(file)



#flow_total_vpn_facebook_chat1a_TCP_10.8.8.178_23.63.99.130_42603_443
