from setuptools import setup, Extension
from Cython.Build import cythonize
import numpy as np

# Definimos as extensões individualmente
# O Cython encontrará os arquivos .pxd automaticamente se eles tiverem o mesmo nome do .pyx
ext_modules = [
    Extension(
        "TIME_features_cython",
        ["TIME_features_cython.pyx"],
        include_dirs=[np.get_include()],
        # language="c++" # Descomente se usar vector ou string
    ),
    Extension(
        "PKT_features_cython",
        ["PKT_features_cython.pyx"],
        include_dirs=[np.get_include()],
    ),
    # Extension(
    #     "feature_extractor_cython",
    #     ["feature_extractor_cython.pyx"],
    #     include_dirs=[np.get_include()],
    # ),
]

setup(
    name="MeuProjetoPacketFeatures",
    # Passamos a lista de extensões para o cythonize
    ext_modules=cythonize(
        ext_modules, 
        annotate=True, 
        compiler_directives={'language_level': "3"}
    )
)
# python setup.py build_ext --inplace
