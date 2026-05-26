import os
import sys
from setuptools import setup, Extension
from Cython.Build import cythonize

script_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.dirname(script_dir)
tcptrace_dir = os.path.join(project_root, 'tcptrace')

define_macros = [
    ('_GNU_SOURCE', '1'),
    ('HAVE_CONFIG_H', '1'),
    ('SIZEOF_UNSIGNED_INT=4', None),
    ('SIZEOF_UNSIGNED_SHORT=2', None),
    ('SIZEOF_UNSIGNED_LONG=8', None),
    ('BUILT_USER', '"tcptrace"'),
    ('BUILT_DATE', '"today"'),
    ('BUILT_HOST', '"local"'),
]

include_dirs = [tcptrace_dir, project_root]

libraries = ['m', 'pthread', 'pcap']

extra_compile_args = [
    '-fPIC',
    '-O2',
    '-w',
    '-DHAVE_LONG_LONG',
]

extra_link_args = ['-fopenmp']

sources = ['tcptrace_api.pyx']

tcptrace_sources = [
    'tcptrace.c',
    'trace.c',
    'udp.c',
    'output.c',
    'names.c',
    'print.c',
    'plotter.c',
    'pool.c',
    'poolaccess.c',
    'dstring.c',
    'dyncounter.c',
    'avl.c',
    'filter.c',
    'snoop.c',
    'tcpdump.c',
    'thruput.c',
    'rexmit.c',
    'netscout.c',
    'mfiles.c',
    'ipv6.c',
    'compress.c',
    'erf.c',
    'ns.c',
    'nlanr.c',
    'netm.c',
    'version.c',
    'tcptrace_accessors.c',
    'flex_bison/filt_parser.c',
    'flex_bison/filt_scanner.c',
    'etherpeek.c',
    'gcache.c',
    'mod_collie.c',
    'mod_http.c',
    'mod_inbounds.c',
    'mod_realtime.c',
    'mod_rttgraph.c',
    'mod_slice.c',
    'mod_tcplib.c',
    'mod_traffic.c',
    'snprintf_vms.c',
]

for src in tcptrace_sources:
    src_path = os.path.join(tcptrace_dir, src)
    if os.path.exists(src_path):
        sources.append(src_path)

ext = Extension(
    'tcptrace_api',
    sources=sources,
    include_dirs=include_dirs,
    define_macros=define_macros,
    libraries=libraries,
    extra_compile_args=extra_compile_args,
    extra_link_args=extra_link_args,
    language='c',
)

setup(
    name='tcptrace_api',
    version='1.0',
    description='Python wrapper for tcptrace TCP analysis',
    ext_modules=cythonize([ext], language_level=3),
    author='tcptrace',
    author_email='tcptrace@example.org',
)