# import tcptrace_api
import operador_pypcap as opcap

# O nome do arquivo que você quer passar para o C
file_name = "/mnt/usb-JMicron_Tech_DD564198838E0-0:0-part4/Data_lake/Tor/qos/tor_facebook_audio/flow_total_VOIP_gate_facebook_Audio_TCP_198.52.200.39_10.0.2.15_443_55139.pcap"

header_pcapfile = opcap.get_pcap_global_header(file_name)
pkts_pcapfile = opcap.ler_binario_direto(file_name, 10)
i=0
try:
    for ts, pkt in pkts_pcapfile:
        i+=1
        print(f'[{i}]: {opcap.montar_pkt(pkt)}')
    # Chamando a função que criamos no .pyx
    # Se você usou o nome 'wrapper_extrair_features' no seu código:
    # for i in range(100):
        
        # resultado = tcptrace_api.wrapper_extrair_features(file_name)
    #     print(f"Resultado do tcptrace: {resultado}")
except Exception as e:
    print(f"Erro ao chamar a função: {e}")
    
    # temos duas opcoes - chamadas independentes ou multiprocess com pool de processos. A primeira é mais simples, mas a segunda pode ser mais eficiente se você tiver muitos arquivos para processar. Vou mostrar um exemplo de chamadas independentes, e depois um exemplo usando multiprocessing.