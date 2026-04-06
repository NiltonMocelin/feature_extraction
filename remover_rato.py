import os
import sys
from scapy.all import *
from scapy.utils import PcapReader

QTD_MIN = 10 #pkts

if __name__ == "__main__":


	if len(sys.argv) < 2:
		print("informe o caminho da pasta onde estao os pcap (python remover_rato.py <caminho>)")
	
	caminho_folder = sys.argv[1]

	for arquivo in os.listdir(caminho_folder):
		if ".pcap" in arquivo:

			file_path = os.path.join(caminho_folder,arquivo)

			contador_pkts = 0
			for pkt in PcapReader(file_path):
				contador_pkts+=1

				if contador_pkts >= QTD_MIN:
					break
			
			if contador_pkts < QTD_MIN:
				os.remove(file_path)
