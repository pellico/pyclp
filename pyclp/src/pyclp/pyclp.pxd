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

#@PydevCodeAnalysisIgnore
cdef extern from "eclipse.h":
    cdef struct eclipse_ref_:
        pass
    cdef struct s_pword:
        pass
    cdef struct dict_item:
        pass
    ctypedef eclipse_ref_ *ec_ref
    ctypedef ec_ref ec_refs
    ctypedef s_pword pword
    ctypedef dict_item *dident
    int ec_exec_string(char*,ec_ref Vars)
    int ec_var_lookup(ec_ref Vars,char*,pword* pw)
    int ec_init()
    int ec_cleanup()
    pword ec_string(char*)
    pword ec_long(int)
    pword ec_double(double)
    dident ec_did(char*,int)
    int DidArity(dident)
    char* DidName(dident)
    pword ec_atom( dident)
    pword ec_term_array( dident, pword[])
    pword ec_nil()
    pword ec_list(pword,pword)
    void ec_post_goal(pword)
    int ec_resume()
    int ec_resume1(ec_ref ToC)
    int ec_resume2(pword FromC,ec_ref ToC)
    void ec_cut_to_chp(ec_ref)
    int ec_set_option_long(int, long)
    int ec_set_option_ptr(int, char *)
    cdef enum dummy:
        PSUCCEED
        PFAIL
        PFLUSHIO
        PWAITIO
        PYIELD
        EC_OPTION_IO
        MEMORY_IO
        RANGE_ERROR
        EC_OPTION_MAPFILE
        EC_OPTION_PARALLEL_WORKER
        EC_OPTION_ARGC
        EC_OPTION_ARGV
        EC_OPTION_LOCALSIZE
        EC_OPTION_GLOBALSIZE
        EC_OPTION_PRIVATESIZE
        EC_OPTION_SHAREDSIZE
        EC_OPTION_PANIC
        EC_OPTION_ALLOCATION
        EC_OPTION_DEFAULT_MODULE
        EC_OPTION_ECLIPSEDIR
        EC_OPTION_INIT
        EC_OPTION_DEBUG_LEVEL

        
    int ec_get_string ( pword,char**)
    int ec_get_string_length ( pword,char**,long*)
    int ec_get_atom ( pword,dident*)
    int ec_get_long ( pword,long*)
    int ec_get_double ( pword,double*)
    int ec_get_nil ( pword)
    int ec_get_list ( pword,pword*,pword*)
    int ec_get_functor ( pword,dident*)
    int ec_arity ( pword)
    int ec_get_arg ( int,pword,pword*)
    int ec_is_var ( pword)
    int ec_stream_nr (char *name)
    int ec_queue_write (int stream, char *data, int size)
    int ec_queue_read (int stream, char *data, int size)
    int ec_queue_avail (int stream)
    void ec_ref_destroy(ec_ref)
    ec_ref ec_ref_create_newvar()
    void ec_ref_set(ec_ref,pword)
    pword ec_ref_get (ec_ref)
    int ec_compare(pword pw1, pword pw2)
    
    