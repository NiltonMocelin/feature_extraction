# Feature extractor cython + tcptrace api for python

1. check setup.sh

2. inspect the code:

2.1 tcptrace_python_api:
    - Two files were modified: tcptrace.c and output.c
    - There is a cython api for tcptrace memory calls - faster than file calls
    - tcptrace cannot be called more than once, without reseting the global variables. This is why we use multiprocess

2.2 compilar_cython:
    - My cython experiments.
    - A couple of flow features are calculated there as well.
    - It is in a format that can help newers to learn cython.
    - pyx is the cython code and pxd is the header file for the code.
    - a setup.py file is always the best option for compilling
    - inspect compile.sh to understand the process.

# About TCPTRACE
It is a powerfull tool written by Shawn Ostermann
ostermann@cs.ohiou.edu

tcptrace is a TCP connection analysis tool.  It can tell you detailed information about TCP connections by sifting through dump files.

Original repository: <a href"https://github.com/blitz/tcptrace">github</a>
