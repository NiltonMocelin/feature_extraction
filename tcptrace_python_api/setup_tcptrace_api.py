from setuptools import setup, Extension
from Cython.Build import cythonize
import os

# Converta suas DEFS do Makefile para este formato:
macros = [
    ('LOAD_MODULE_HTTP', None),
    ('HTTP_SAFE', None),
    ('STDC_HEADERS', '1'),
    ('HAVE_SYS_TYPES_H', '1'),
    ('HAVE_STDLIB_H', '1'),
    ('SIZEOF_UNSIGNED_INT', '4'),
    ('SIZEOF_UNSIGNED_LONG_INT', '8'),
    # Adicione as outras que são importantes para os tipos, como:
    ('USE_LLU', '1'),
]

ext = Extension(
    name="tcptrace_api",
    sources=["tcptrace_api.pyx"], # Mudei para .pyx, pois o .c é gerado automaticamente
    include_dirs=["."],
    define_macros=macros,      # <-- ISSO É O QUE FALTA
    libraries=["tcptrace"],
    library_dirs=[os.path.abspath(".")],
    runtime_library_dirs=[os.path.abspath(".")],
)

setup(
    ext_modules=cythonize([ext], compiler_directives={'language_level': "3"})
)