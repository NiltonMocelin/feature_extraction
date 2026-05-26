import struct
import pcap
import time
import sys
import binascii
import os

def get_pcap_global_header(caminho_arquivo): # header permite manter a consistencia do arquivo pcap quando copiado seus pacotes
    with open(caminho_arquivo, "rb") as f:
        raw_header = f.read(24) # O Global Header tem sempre 24 bytes
        
        if len(raw_header) < 24:
            return None

        return raw_header
    return None

def pcap_header_to_dict(header_bytes):
    header = struct.unpack('<IHHIIII', header_bytes)
    
    return {
            "magic_number": hex(header[0]), # 0xa1b2c3d4 significa que o arquivo está ok
            "version_major": header[1],
            "version_minor": header[2],
            "thiszone": header[3],
            "sigfigs": header[4],
            "snaplen": header[5],
            "network": header[6] # 1 = Ethernet
        }

def gerar_global_header_proprio(snaplen=65535, network=1):
    """
    Gera os 24 bytes do PCAP Global Header.
    snaplen: Tamanho máximo do pacote (padrão 65535).
    network: Tipo de rede (1 para Ethernet).
    """
    return struct.pack(
        "<IHHIIII", 
        0xa1b2c3d4,  # Magic Number (Little Endian)
        2, 4,        # Version Major (2) e Minor (4)
        0,           # Timezone offset (sempre 0)
        0,           # Sigfigs (sempre 0)
        snaplen,     # Max packet size
        network      # Data Link Type (1 = Ethernet)
    )

def ler_binario_direto(arquivo_pcap, max_pacotes):
    # Abre o arquivo pcap usando a interface direta da libpcap
    # O pypcap trata o objeto como um iterador
    sniffer = pcap.pcap(name=arquivo_pcap, timeout_ms=0)

    # OBTENDO O LINKTYPE AQUI
    link_type = sniffer.datalink()
    
    # print(f"Lendo pacotes de: {arquivo_pcap}")
    # print("-" * 50)
    lista_ = []
    contador = 0
    # ts = timestamp (float)
    # pkt = buffer de bytes (o conteúdo binário bruto)
    for ts, pkt in sniffer:
        # 1. Print do conteúdo bruto (como bytes Python)
        # print(f"Timestamp: {ts}")
        # print(f"Conteúdo Bruto (Bytes):\n{pkt}")

        # 2. Print em Hexadecimal (mais fácil de ler binário assim)
        # hex_data = binascii.hexlify(pkt).decode('utf-8')
        # Formata para mostrar pares de hex (ex: 00 1a 2b...)
        # hex_formatado = ' '.join(hex_data[i:i+2] for i in range(0, len(hex_data), 2))
        
        # print(f"Conteúdo Hexadecimal:\n{hex_formatado}")
        # print(montar_pkt(pkt))
        # print("-" * 50)
        contador+=1
        lista_.append((ts,pkt))
        if contador  == max_pacotes:
            break
    return lista_, link_type

def criar_pcap_com_header_original(global_header, arquivo_destino, lista_de_pacotes):
    """
    arquivo_origem: PCAP de onde vira o Global Header (24 bytes)
    arquivo_destino: Novo arquivo PCAP
    lista_de_pacotes: Lista de tuplas [(timestamp, dados_brutos), ...]
    """
        
    with open(arquivo_destino, "wb") as f_dest:
        # 2. Escreve o Global Header no novo arquivo
        f_dest.write(global_header)
        
        print(f"Escrevendo {len(lista_de_pacotes)} pacotes...")

        for ts, pkt in lista_de_pacotes:
            # 3. Preparar o Packet Header (16 bytes)
            # Separamos o timestamp float em segundos e microsegundos
            ts_sec = int(ts)
            ts_usec = int((ts % 1) * 1000000)
            
            caplen = len(pkt)
            origlen = caplen
            
            # Formato <IIII (Little Endian: sec, usec, caplen, origlen)
            pkt_header = struct.pack("<IIII", ts_sec, ts_usec, caplen, origlen)
            
            # 4. Escrever Header + Dados
            f_dest.write(pkt_header)
            f_dest.write(pkt)

    print("Arquivo PCAP consistente gerado com sucesso.")


def criar_pcap_com_header_proprio(nome_arquivo, lista_de_pacotes):
    """
    lista_de_pacotes: [(timestamp, dados_brutos), ...]
    """
    with open(nome_arquivo, "wb") as f:
        # 1. Escreve o cabeçalho que acabamos de criar
        f.write(gerar_global_header_proprio())
        
        # 2. Escreve cada pacote da lista
        for ts, pkt in lista_de_pacotes:
            ts_sec = int(ts)
            ts_usec = int((ts % 1) * 1000000)
            caplen = len(pkt)
            origlen = caplen
            
            # Packet Header (16 bytes)
            pkt_header = struct.pack("<IIII", ts_sec, ts_usec, caplen, origlen)
            
            f.write(pkt_header)
            f.write(pkt)

def contar_pacotes_pcap(caminho_arquivo):
    sniffer = pcap.pcap(name=caminho_arquivo)
    count = 0
    
    for ts, pkt in sniffer:
        count += 1
        
    return count

def contar_pacotes_pcap_ver_binario_rapido(caminho_arquivo):
    with open(caminho_arquivo, 'rb') as f:
        # Pula o Global Header (24 bytes)
        f.seek(24)
        count = 0
        
        while True:
            # Lê apenas o header do pacote (16 bytes)
            header = f.read(16)
            if not header or len(header) < 16:
                break
            
            # O campo 'caplen' (bytes capturados) está nos bytes 8-12 do header
            # Formato <IIII (ts_sec, ts_usec, caplen, origlen)
            _, _, caplen, _ = struct.unpack('<IIII', header)
            
            # Pula o corpo do pacote para ir direto para o próximo header
            f.seek(caplen, os.SEEK_CUR)
            count += 1
            
    return count


def pkt_is_ipv4(pkt_bytes):
    try:
        # O EtherType fica nos bytes 12 e 13 do cabeçalho Ethernet
        eth_type = struct.unpack('!H', pkt_bytes[12:14])[0]
        if eth_type != 0x0800:
            return False  # Pula se não for IPv4 (ex: ARP, IPv6, etc)
    except:
        print("erro pkt_is_ipv4")
        return False
    return True

def pkt_is_tcp(pkt_bytes):
    # --- 2. VERIFICAR O PROTOCOLO NO CABEÇALHO IP ---
    # O campo 'Protocol' no cabeçalho IPv4 fica no offset 23 (byte 23)
    # O valor para TCP é 6. Para UDP é 17.
    protocolo_ip = pkt_bytes[23] 
    if protocolo_ip == 6:
        return True
    return False
    
def pkt_is_udp(pkt_bytes):
    # --- 2. VERIFICAR O PROTOCOLO NO CABEÇALHO IP ---
    # O campo 'Protocol' no cabeçalho IPv4 fica no offset 23 (byte 23)
    # O valor para TCP é 6. Para UDP é 17.
    protocolo_ip = pkt_bytes[23] 
    if protocolo_ip == 17:
        return True
    return False

def get_tcp_header_to_dict(pkt_bytes, offset):
    ihl = (pkt_bytes[offset] & 0x0F) * 4
    tcp_start = offset + ihl
    
    tcp_data = pkt_bytes[tcp_start : tcp_start + 20]
    if len(tcp_data) < 20:
        return None

    # Formato corrigido: !HHIIHHHH
    # fields[4] conterá os 16 bits de controle (Offset + Reservado + Flags)
    fields = struct.unpack('!HHIIHHHH', tcp_data)

    # 3. Tratamento de campos de controle (16 bits)
    control_field = fields[4]
    
    # O Data Offset são os 4 bits mais significativos (dos 16 bits)
    tcp_header_len = (control_field >> 12) * 4  
    
    # As Flags são os 9 bits menos significativos (NS até FIN)
    # 0x1FF = 0000 0001 1111 1111 em binário
    flags = control_field & 0x1FF 
    
    payload_start = tcp_start + tcp_header_len
    payload = pkt_bytes[payload_start:]
    
    header = {
        "src_port":    fields[0],
        "dst_port":    fields[1],
        "seq_num":     fields[2],
        "ack_num":     fields[3],
        "header_len":  tcp_header_len,
        "flags": {
            "ns":  bool(flags & 0x100), 
            "cwr": bool(flags & 0x80),
            "ece": bool(flags & 0x40),
            "urg": bool(flags & 0x20),
            "ack": bool(flags & 0x10),
            "psh": bool(flags & 0x08),
            "rst": bool(flags & 0x04),
            "syn": bool(flags & 0x02),
            "fin": bool(flags & 0x01)
        },
        "window":      fields[5], # No unpack HHIIHHHH, Window é o índice 5
        "checksum":    fields[6], # Checksum é o índice 6
        "urgent_ptr":  fields[7], # Urgent Ptr é o índice 7
        "payload_start": payload_start,
        "payload": payload
    }
    
    return header

def get_udp_header_to_dict(pkt_bytes, offset):
    """
    Extrai os campos do cabeçalho UDP e identifica o início do payload.
    Assume que o pacote já foi validado como IPv4 e Protocolo 17 (UDP).
    """
    # 1. Calcular onde o IP termina (IHL)
    # Byte 14: Versão (4 bits) + IHL (4 bits)
    ihl = (pkt_bytes[offset] & 0x0F) * 4
    udp_start = offset + ihl
    
    # 2. Extrair os 8 bytes do cabeçalho UDP
    # Estrutura: !HHHH (4 unsigned shorts em Network Byte Order)
    udp_data = pkt_bytes[udp_start : udp_start + 8]
    
    if len(udp_data) < 8:
        return None

    # Desempacotando os campos
    fields = struct.unpack('!HHHH', udp_data)
    payload = pkt_bytes[(udp_start + 8):]
    payload_size = len(payload)
    
    header = {
        "src_port": fields[0],      # Porta de Origem
        "dst_port": fields[1],      # Porta de Destino
        "length":   fields[2],      # Tamanho (Header + Payload)
        "checksum": fields[3],      # Checksum (opcional em IPv4)
        "payload_start": udp_start + 8,
        "payload" : payload,
        "payload_size": len(payload)
    }
    
    return header

import struct

def get_ipv4_header_to_dict(pkt_bytes, offset):
    """
    Extrai todos os campos do cabeçalho IPv4.
    Assume que o EtherType já foi validado como 0x0800.
    """
    # O cabeçalho IP começa após os 14 bytes da Ethernet
    ip_start = offset
    
    # Extraímos os primeiros 20 bytes (tamanho fixo padrão)
    # Formato: !BBHHHBBHII
    # B=1byte, H=2bytes, I=4bytes
    ip_data = pkt_bytes[ip_start : ip_start + 20]
    
    if len(ip_data) < 20:
        return None

    fields = struct.unpack('!BBHHHBBHII', ip_data)

    # 1. Versão e IHL (estão no mesmo byte)
    version_ihl = fields[0]
    version = version_ihl >> 4
    ihl = (version_ihl & 0x0F) * 4 # Tamanho do header em bytes

    # 2. Type of Service e Flags/Fragment
    tos = fields[1]
    total_len = fields[2]
    identification = fields[3]
    
    flags_fragment = fields[4]
    flags = flags_fragment >> 13
    fragment_offset = flags_fragment & 0x1FFF

    # 3. TTL, Protocolo e Checksum
    ttl = fields[5]
    protocol = fields[6]
    checksum = fields[7]

    # 4. Endereços IP (Convertendo de inteiros para string x.x.x.x)
    def format_ip(ip_int):
        return ".".join(map(str, struct.pack('!I', ip_int)))

    protocol_name = "unkown"
    if protocol == 17:
        protocol_name = "udp"
    elif protocol == 6:
         protocol_name = "tcp"
         
    header = {
        "version": version,
        "header_len": ihl,
        "tos": tos,
        "total_len": total_len,
        "id": identification,
        "flags": flags,
        "fragment_offset": fragment_offset,
        "ttl": ttl,
        "protocol": protocol,
        "transport_proto": protocol_name,
        "checksum": checksum,
        "src_ip": format_ip(fields[8]),
        "dst_ip": format_ip(fields[9]),
        "next_layer_start": ip_start + ihl
    }
    
    return header

def get_eth_header_to_dict(pkt_bytes, linktype):
    
    # def gerar_ethernet_falso():
    #     """
    #     Gera 14 bytes de um cabeçalho Ethernet fake.
    #     MAC Destino: 00:00:00:00:00:00
    #     MAC Origem:  00:00:00:00:00:00
    #     EtherType:   0x0800 (IPv4)
    #     """
    #     # 6s (6 bytes) + 6s (6 bytes) + H (unsigned short / 2 bytes)
    #     # ! indica Network Byte Order (Big Endian)
    #     # return # Retornamos (MAC_DST, MAC_SRC, ETHER_TYPE)
    #     return (b'\x00'*6, b'\x00'*6, 0x0800)
    
    eth_data = pkt_bytes[:14]
    fields = struct.unpack('!6s6sH', eth_data)
    
    if linktype != 1: # se nao for uma captura com cabecalho eth, pode ser 101 (raw pkts=comeca na ip) ou 113: linux SSL, ou 12: loopback
        fields = (b'\x00'*6, b'\x00'*6, 0x0800) # dummy eth
    
    eth_type = fields[2]
    
    offset = 14
    if eth_type == 0x8100: # VLAN detectada
        offset = 18
        # O EtherType real está 4 bytes à frente
        eth_type = struct.unpack('!H', pkt_bytes[16:18])[0]
   # Função auxiliar para formatar os bytes do MAC em string legível (ff:ff:ff...)
    def format_mac(bytes_mac):
        return ":".join(f"{b:02x}" for b in bytes_mac)

    return {
        "dst_mac": format_mac(fields[0]),
        "src_mac": format_mac(fields[1]),
        "eth_type": eth_type,
        "next_layer_start": offset # Use isso para as próximas funções
    }



def get_payload_data(pkt_bytes, offset):
    # 1. Extrair informações do IP de forma relativa ao offset
    ihl = (pkt_bytes[offset] & 0x0F) * 4
    
    # Total Length do IP (bytes 2 e 3 do cabeçalho IP)
    # Serve para ignorar o padding da Ethernet no final
    ip_total_len = struct.unpack('!H', pkt_bytes[offset+2 : offset+4])[0]
    
    # Protocolo IP está no byte 9 após o início do IP
    protocolo_ip = pkt_bytes[offset + 9] 
    
    transport_start = offset + ihl
    # Onde o pacote IP realmente termina (ignora lixo de preenchimento da rede)
    ip_end = offset + ip_total_len
    
    payload = b""
    
    if protocolo_ip == 17: # UDP
        udp_header_len = 8
        payload_start = transport_start + udp_header_len
        # Cortamos do início do payload até o fim real do IP
        payload = pkt_bytes[payload_start : ip_end]
        
        # print(f"UDP Payload ({len(payload)} bytes): {payload.hex()}")

    elif protocolo_ip == 6: # TCP
        # Data Offset (4 bits superiores do byte 12 do TCP)
        # transport_start + 12 é a posição correta
        data_offset_byte = pkt_bytes[transport_start + 12]
        tcp_header_len = (data_offset_byte >> 4) * 4

        payload_start = transport_start + tcp_header_len
        payload = pkt_bytes[payload_start : ip_end]

        # print(f"TCP Payload ({len(payload)} bytes): {payload.hex()}")
        
    return len(payload) #, payload

def montar_pkt_to_dict(pkt_bytes, linktype):
    pkt_dict = {}
    pkt_dict['eth'] = get_eth_header_to_dict(pkt_bytes, linktype)
    
    if pkt_dict["eth"] == None:
        print("[mnt-pkt] no eth")
        return None
    
    offset=0 # Assume Raw IP se não for Ethernet/Cooked
    if linktype == 1: # tem camada eth
        offset = 14
    elif linktype == 113: # linux ssl
        offset = 16
    
    pkt_dict["ipv4"] = get_ipv4_header_to_dict(pkt_bytes, offset)
    if pkt_dict['ipv4'] == None:
        print("[mnt-pkt] no ipv4")
        return None
    
    # print(f"[mnt-pkt] proto: {pkt_dict['ipv4']['protocol']}")
    # print(f"pkt:{pkt_dict}")
    if pkt_dict['ipv4']['transport_proto'] == 'tcp':
        pkt_dict['tcp'] = get_tcp_header_to_dict(pkt_bytes, offset)
        return pkt_dict
    
    if pkt_dict['ipv4']['transport_proto'] == 'udp':
        pkt_dict['udp'] = get_udp_header_to_dict(pkt_bytes, offset)
        return pkt_dict
    
    print("[mnt-pkt] pkt failed")
    return None

def clonar_pcap(arquivo_origem, arquivo_destino):
    # 1. Abrir o arquivo original com pypcap
    sniffer = pcap.pcap(name=arquivo_origem)
    
    with open(arquivo_destino, "wb") as f:
        # 2. Escrever o Global Header (24 bytes)
        # Pegamos as propriedades direto do objeto pypcap
        # Network 1 = Ethernet, Snaplen geralmente 65535
        global_header = struct.pack("<IHHIIII", 
                                    0xa1b2c3d4, # Magic Number
                                    2, 4,       # Version 2.4
                                    0, 0,       # Timezone/Sigfigs
                                    sniffer.snaplen, 
                                    sniffer.datalink())
        f.write(global_header)

        # 3. Iterar e copiar cada pacote mantendo o Header de Pacote
        for ts, pkt in sniffer:
            # Converter o timestamp float de volta para sec e usec
            ts_sec = int(ts)
            ts_usec = int((ts % 1) * 1000000)
            caplen = len(pkt)
            origlen = caplen # No pypcap, pkt já é o dado capturado
            
            # Packet Header (16 bytes)
            pkt_header = struct.pack("<IIII", ts_sec, ts_usec, caplen, origlen)
            
            f.write(pkt_header)
            f.write(pkt)

def capturar_e_salvar(interface, nome_arquivo, total_pacotes=10):
    # 1. Iniciar o Sniffer na interface desejada
    # promisc=True permite capturar tráfego não destinado apenas ao seu PC
    sniffer = pcap.pcap(name=interface, promisc=True, immediate=True)
    
    print(f"Capturando na interface {interface}...")

    with open(nome_arquivo, "wb") as f:
        # 2. ESCREVER O GLOBAL HEADER (Obrigatório no início)
        # Formato: Magic(4), Ver_Maj(2), Ver_Min(2), TZ(4), Sig(4), Snaplen(4), Network(4)
        # 0xa1b2c3d4 = Little Endian padrão
        # 1 = Ethernet (DLT_EN10MB)
        global_header = struct.pack("<IHHIIII", 0xa1b2c3d4, 2, 4, 0, 0, 65535, 1)
        f.write(global_header)
        f.flush() # Garante a escrita imediata do cabeçalho

        cont = 0
        try:
            # 3. Loop de Captura
            for ts, pkt in sniffer:
                # O 'ts' retornado pelo pypcap é o tempo real do Kernel (fidelidade máxima)
                ts_sec = int(ts)
                ts_usec = int((ts % 1) * 1000000)
                
                caplen = len(pkt)
                origlen = caplen
                
                # 4. ESCREVER O PACKET HEADER (16 bytes)
                pkt_header = struct.pack("<IIII", ts_sec, ts_usec, caplen, origlen)
                
                f.write(pkt_header)
                f.write(pkt)
                f.flush() # Mantém o arquivo consistente mesmo se o script cair
                
                cont += 1
                print(f"Pacote {cont} salvo ({caplen} bytes)", end="\r")
                
                if cont >= total_pacotes:
                    break
        except KeyboardInterrupt:
            print("\nCaptura interrompida pelo usuário.")

    print(f"\nArquivo {nome_arquivo} criado com sucesso e consistente.")

# Uso: (Verifique o nome da sua interface com 'ip link' ou 'ifconfig')
# capturar_e_salvar("eth0", "captura_viva.pcap", 20)