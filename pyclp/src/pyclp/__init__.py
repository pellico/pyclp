#Simplified BSD License
#Copyright (c) 2023, Oreste Bernardi
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

import os,platform
from pathlib import Path
if "ECLIPSEDIR" not in os.environ:
    raise ImportError("ECLIPSEDIR enviroment varibale is not defined.")

platform_system=platform.system()
platform_architecture=platform.architecture()[0]

if platform_system=='Linux':
    dll_ext=".so"
    if platform_architecture=='32bit':
        arch='i386_linux'
    elif platform_architecture=='64bit':
        arch='x86_64_linux'
    else:
        raise ImportError("Architecture not supported")
elif platform_system=='Windows':
    dll_ext=".dll"
    if platform_architecture=='64bit':
        arch='x86_64_nt'
    elif platform_architecture=='32bit':
        arch='i386_nt'
    else:
        raise ImportError("Architecture not supported")
else:
    raise ImportError("Platform not supported")

dll_folder_path=Path(os.environ["ECLIPSEDIR"],"lib",arch)
lib_path=dll_folder_path / f"eclipse{dll_ext}"
if not lib_path.exists():
    raise ImportError(f"Share library not existing at {lib_path}")

os.add_dll_directory(dll_folder_path)

from pyclp.pyclp import *