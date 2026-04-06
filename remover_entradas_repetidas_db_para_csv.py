import pandas as pd
import json
import os
import sys

def carregar_jsons_e_remover_repetidos(folder_origem, folder_destino):
    db_name = folder_origem.split('/')[-1]

    lista_jsons = []
    contador = 0
    for file_name in os.listdir(folder_origem):
        if '.db' not in file_name:
            continue

        print(f"Abrindo arquivo {folder_origem}/{file_name}")
        try:
            with open(f"{folder_origem}/{file_name}") as file:
                nova_linha = file.readline()
                while(nova_linha):
                    lista_jsons.append(json.loads(nova_linha))
                    
                    if len(lista_jsons) == 500000:
                        remover_entradas_repetidas_db_salvar_csv(lista_jsons, folder_destino, f"db_{db_name}_{contador}.csv")
                        contador+=1
                        lista_jsons.clear()
                    
                    nova_linha = file.readline()
        except:
            print(f"Problema ao carregar {folder_origem}/{file_name} -> ignorado")
    if lista_jsons!=[]:
        remover_entradas_repetidas_db_salvar_csv(lista_jsons, folder_destino, f"db_{db_name}_{contador}.csv")
        contador+=1
        lista_jsons.clear()
    print(f"len list jsons {len(lista_jsons)}")
    return lista_jsons


def remover_entradas_repetidas_db_salvar_csv(lista_dicionarios, folder_destino, file_name):
    lista_col_rm = ["filename", "host_a", "host_b", "a_port", "b_port", "id_bloco"]
    
    df = pd.DataFrame(lista_dicionarios)

    colunas_para_considerar = df.columns.to_list()

    for col in lista_col_rm:
        colunas_para_considerar.remove(col)

    df_sem_duplicatas = df.drop_duplicates(subset=colunas_para_considerar, keep='first')

    print(f"exportando - len pos remover_dup {len(df_sem_duplicatas)}")
    # Export to a CSV file named 'people.csv'
    df.to_csv(f'{folder_destino}/{file_name}', index=False)
    
    return

# {"filename":"1_aux_flow_total_skype_video2b_TCP_23.96.89.49_131.202.240.86_443_1967.pcap","service_class":"qos","app_class":"skype_video_real","host_a":"131.202.240.86","host_b":"23.96.89.49","a_port":1967,"b_port":443,"id_bloco":1,"proto":0,"bandwidth":0,"delay":0,"jitter":0,"loss":0,"qtd_pkts_total":10,"ab_mean_IAT_198":0.016871,"ab_med_IAT_197":0.013999,"ab_std_IAT_201":0.015716,"ab_min_IAT_195":0.0,"ab_max_IAT_200":0.037645,"ab_q1_IAT_196":0.000336,"ab_q3_IAT_199":0.033208,"ab_sum_IAT":0.168706,"ab_below_mean_IAT":6,"ab_above_mean_IAT":4,"No_transitions_bulkTrans_210":6,"Time_spent_in_bulk_211":0.060884,"Duration_Connection_duration_212":0.168706,"bulk_Percent_of_time_spent_213":0.360888,"Time_spent_idle_214":0.168706,"idle_Percent_of_time_215":1.0,"ab_kbytes_per_sec":34.29635,"ab_mean_data_control_163":544.6,"ab_med_data_control_162":201.5,"ab_var_data_control_166":587.877402,"ab_min_data_control_160":20,"ab_max_data_control_165":1370,"ab_q1_data_control_161":20,"ab_q3_data_control_164":1370,"ab_mean_data_ip_163":564.6,"ab_med_data_ip_162":221.5,"ab_var_data_ip_166":587.877402,"ab_min_data_ip_160":40,"ab_max_data_ip_165":1390,"ab_q1_data_ip_161":40,"ab_q3_data_ip_164":1390,"ab_min_data_control_307":523.4,"ab_q1_data_control_308":181.5,"ab_med_data_control_309":588.933816,"ab_mean_data_control_310":0,"ab_q3_data_control_311":1350,"ab_max_data_control_312":0,"ab_var_data_control_313":1350,"ab_mean_data_pkt_156":578.6,"ab_med_data_pkt_155":235.5,"ab_var_data_pkt_159":587.877402,"ab_min_data_pkt_153":54,"ab_max_data_pkt_158":1404,"ab_q1_data_pkt_154":54,"ab_q3_data_pkt_157":1404,"ab_mean_header_ip_ref321":20.0,"ab_med_header_ip_ref322":20.0,"ab_std_header_ip_ref323":0.0,"ab_min_header_ip_ref324":20,"ab_max_header_ip_ref325":20,"ab_q1_header_ip_ref326":20,"ab_q3_header_ip_ref327":20,"ab_pkts_abv_1024":3,"ab_pays_bel_128":4,"ab_pays_in_128_1024":3,"ab_pkts_abv_mean":4,"ab_pkts_bel_mean":6,"ab_pkts_header_sum":212.0,"ab_pkts_len_sum":5786,"ab_pkts_per_sec":59.274715}
if len(sys.argv) < 2:
	print("informe o caminho da pasta onde estao os .db")

folder_origem = sys.argv[1]

folder_destino = f"{folder_origem}/"

carregar_jsons_e_remover_repetidos(folder_origem, folder_destino)
