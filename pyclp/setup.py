#!/usr/bin/env python

#Simplified BSD License
#Copyright (c) 2012, Oreste Bernardi
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
#    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
#    in the documentation and/or other materials provided with the distribution.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, 
#BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
#IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, 
#OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
#OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
#OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
#THE POSSIBILITY OF SUCH DAMAGE.
"""
setup.py file for pyclp
"""

import distutils
from distutils.core import setup
from distutils.extension import Extension
from distutils.msvccompiler import MSVCCompiler as oldMSVCCompiler
import platform

class mymsvcompiler(oldMSVCCompiler):
    def link (self,*arg,**kargs):
		#Generate .lib file if not yet done
        self.announce("Microsoft Visual C requires eclipse.lib\n Building it") 
        bits, linkage= platform.architecture()
        if bits=="32bit":
            machine_option="/MACHINE:X86"
        elif bits=="64bit":
            machine_option="/MACHINE:X64"
        else:
            raise "Architecture not supported"
        lib_cmd=self.find_exe('lib.exe')
        option="/def:" + os.path.join(eclipse_lib_path,"eclipse.def")
        self.spawn([lib_cmd,machine_option,option])
        oldMSVCCompiler.link(self,*arg,**kargs)

#Substitute msvcompiler with one subclass.       
distutils.msvccompiler.MSVCCompiler=mymsvcompiler


from Cython.Distutils import build_ext
from os import environ
import os.path

    

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

if platform.system()=='Linux':
    arch='i386_linux'
elif platform.system()=='Windows':
    arch='i386_nt'
else:
    print ("Platform not supported")
    raise

eclise_include_path=os.path.join(eclipsedir,'include',arch)
eclipse_lib_path=os.path.join(eclipsedir,'lib',arch)
pyclp_module = Extension('pyclp.pyclp',
                           ['src/pyclp/pyclp.pyx'],
                           library_dirs=[eclipse_lib_path],
                           libraries=['eclipse'],
                           include_dirs=[eclise_include_path,'src/pyclp/']
                           )

with open('README.txt') as file:
    long_description_read = file.read()

setup (name = 'PyCLP',
       version = '0.3',
       author      = "Oreste Bernardi",
       maintainer = "Oreste Bernardi",
       author_email= "<name>@<name>.eu  name=oreste",
       url = "pyclp.berlios.de",
       description = """Interface to ECLiPSe CLP""",
       license= "Simplified BSD",
       cmdclass = {'build_ext': build_ext},
       ext_modules = [pyclp_module],
       package_dir={'': 'src'},
       packages=['pyclp'],
       long_description=long_description_read,
       classifiers=["Development Status :: 4 - Beta",
                    "Programming Language :: Prolog" 
                    ]
       #py_modules = ["pyclp"],
       )