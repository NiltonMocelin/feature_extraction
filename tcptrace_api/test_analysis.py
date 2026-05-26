#!/usr/bin/env python3
import sys
import os


sys.path.insert(0, '/home/nnmoc/traffic_classification02/tcptrace_api')
sys.path.insert(1, '/home/nnmoc/traffic_classification02/extrator_cython/')  
from tcptrace_api import TcptraceAnalyzer
import operador_pypcap

pcap_file = sys.argv[1] if len(sys.argv) > 1 else None
if not pcap_file:
    print("Usage: test_tcptrace.py <pcap_file>")
    sys.exit(1)

if not os.path.exists(pcap_file):
    print(f"Error: File not found: {pcap_file}")
    sys.exit(1)

print(f"Analyzing: {pcap_file}")


def test_tcptrace_analysis_batch(pcap_file):
    lista_ts_pkts, linktype = operador_pypcap.ler_binario_direto(pcap_file, 5000)

    analyzer = TcptraceAnalyzer()
    analyzer.analyze_batch(lista_ts_pkts, linktype)

    results = analyzer.get_results()
    print("\n=== Results ===")
    for key, value in results.items():
        print(f"  {key}: {value}")

    print(f"\nTCP Connections: {results['num_tcp_connections']}")
    print(analyzer.get_tcp_connections())


    print(f"\nUDP Connections: {results['num_udp_connections']}")
    print(analyzer.get_udp_connections())

def test_tcptrace_analysis(pcap_file):

    analyzer = TcptraceAnalyzer()
    analyzer.analyze(pcap_file)
    
    results = analyzer.get_results()
    print("\n=== Results ===")
    for key, value in results.items():
        print(f"  {key}: {value}")
    
    tcp_conns = analyzer.get_tcp_connections()
    print(f"\nTCP Connections: {len(tcp_conns)}")
    for i, conn in enumerate(tcp_conns[:3]):
        print(f"  Connection {i+1}:")
        print(f"    a_endpoint: {conn.get('a_endpoint', '')}")
        print(f"    b_endpoint: {conn.get('b_endpoint', '')}")
        print(f"    a2b_packets: {conn.get('a2b_packets', 0)}")
        print(f"    b2a_packets: {conn.get('b2a_packets', 0)}")

if __name__ == "__main__":
    print("Testing TcptraceAnalyzer with batch analysis...")
    
    for i in range(3):
        print(f"\nRun {i+1}:")
        test_tcptrace_analysis_batch(pcap_file)


    # print("\nTesting TcptraceAnalyzer with file analysis...")
    # test_tcptrace_analysis(pcap_file)