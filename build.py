import setuptools
from setuptools.extension import Extension
import platform
# import sys
# cython and python dependency is handled by pyproject.toml
from Cython.Build import cythonize

class exceptionPyClpSetup(Exception):
    def __init__(self,msg):
        self.msg=msg
    def __str__(self):
        return self.msg

from Cython.Distutils import build_ext
from os import environ
import os.path
from types import MethodType

if "ECLIPSEDIR" not in environ:
    while(1):
        eclipsedir=input('ECLIPSEDIR environmental variable is not defined \n\
please provide path to ECLiPSe installation: ')
        if os.path.exists(eclipsedir):
            break
        else:
            print('Invalid Path')
else:
    eclipsedir=environ["ECLIPSEDIR"]

platform_system=platform.system()
platform_architecture=platform.architecture()[0]

if platform_system=='Linux':
    if platform_architecture=='32bit':
        arch='i386_linux'
    elif platform_architecture=='64bit':
        arch='x86_64_linux'
    else:
        raise exceptionPyClpSetup("Architecture not supported")
elif platform_system=='Windows':
    if platform_architecture=='64bit':
        arch='x86_64_nt'
    elif platform_architecture=='32bit':
        arch='i386_nt'
    else:
        raise exceptionPyClpSetup("Architecture not supported")
else:
    raise exceptionPyClpSetup("Platform not supported")

eclise_include_path=os.path.join(eclipsedir,'include',arch)
eclipse_lib_path=os.path.join(eclipsedir,'lib',arch)


# Compilation of C module in c_lib

pyclp_module = Extension('pyclp.pyclp',
                           ['src/pyclp/pyclp.pyx'],
                           library_dirs=[eclipse_lib_path],
                           libraries=['eclipse'],
                           include_dirs=[eclise_include_path,'src/pyclp/'],
                           define_macros=[("USES_NO_ENGINE_HANDLE","")]
                           )



def build(setup_kwargs):
    setup_kwargs.update(
        dict(
            cmdclass=dict(build_ext=build_ext),
            ext_modules=[pyclp_module],
            #zip_safe=False
        )
    )