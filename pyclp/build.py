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

class BuildExt( build_ext ):
    def build_extensions(self):
        # Dirty trick to generate the required eclipse.lib file before linking
        # At this stage the path to toolchain is configured
        link_func = self.compiler.link
        def link_f (self_loc,*arg,**kargs):
            #Generate .lib file if not yet done
            self_loc.announce("Microsoft Visual C requires eclipse.lib\n Building it") 
            bits, _linkage= platform.architecture()
            if bits=="32bit":
                machine_option="/MACHINE:X86"
            elif bits=="64bit":
                machine_option="/MACHINE:X64"
            else:
                raise "Architecture not supported"
            option="/def:" + os.path.join(eclipse_lib_path,"eclipse.def")
            self_loc.spawn([self_loc.lib,machine_option,option])
            link_func(*arg,**kargs)
        self.compiler.link=MethodType(link_f,self.compiler)
        
        build_ext.build_extensions(self)    

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

if platform_system=='Windows':
    class BuildExt( build_ext ):
        def build_extensions(self):
            # Dirty trick to generate the required eclipse.lib file before linking
            # At this stage the path to toolchain is configured
            link_func = self.compiler.link
            def link_f (self_loc,*arg,**kargs):
                #Generate .lib file if not yet done
                self_loc.announce("Microsoft Visual C requires eclipse.lib\n Building it") 
                bits, _linkage= platform.architecture()
                if bits=="32bit":
                    machine_option="/MACHINE:X86"
                elif bits=="64bit":
                    machine_option="/MACHINE:X64"
                else:
                    raise "Architecture not supported"
                option="/def:" + os.path.join(eclipse_lib_path,"eclipse.def")
                self_loc.spawn([self_loc.lib,machine_option,option])
                link_func(*arg,**kargs)
            self.compiler.link=MethodType(link_f,self.compiler)
            
            build_ext.build_extensions(self)
    pyclp_build_ext=BuildExt
else:
    pyclp_build_ext=build_ext   


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
            cmdclass=dict(build_ext=pyclp_build_ext),
            ext_modules=[pyclp_module],
            #zip_safe=False
        )
    )