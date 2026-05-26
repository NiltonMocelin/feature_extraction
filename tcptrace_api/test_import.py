#!/usr/bin/env python3
import sys
sys.path.insert(0, '/home/nnmoc/traffic_classification02/tcptrace_api')

from tcptrace_api import TcptraceAnalyzer

analyzer = TcptraceAnalyzer()
print("TcptraceAnalyzer created successfully")
print("Methods:", dir(analyzer))