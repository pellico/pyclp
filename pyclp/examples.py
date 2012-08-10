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

from pyclp import *

def example1():
    """Simple unification
    """
    init()                        # Init ECLiPSe engine
    myVar=Var()                   # Create a prolog variable
    my_goal=Compound("=",myVar,1) # Create goal
    my_goal.post_goal()           # Post goal
    result,dummy =resume()        # Resume execution of ECLiPSe engine
    if result != SUCCEED:
        raise
    print(myVar.value() +1)       # myVar.value get the var value back.
    print(myVar)                  # print value
    cleanup()                     # Shutdown ECLiPSe engine
    
    
    
    
def example2():
    """
    Search example using ic library
    """
    print("Search example")
    init()                                         # Init ECLiPSe engine
    Compound("lib",Atom("ic")).post_goal()         # Load ic library
    A_var=Var()                                    # Create variable A
    B_var=Var()                                    # Create variable B
    Compound("#::",PList([A_var,B_var]),\
             Compound("..",1,10)).post_goal()      # [A,B]#::1..10
    Compound("#<",A_var,B_var).post_goal()         # A#<B
    Compound("#=",A_var,5).post_goal()             # A#=5
    Compound("labeling",\
             PList([A_var,B_var])).post_goal()     # labeling([A,B])
    # Loop on all solution and print them.
    while (resume()[0]==SUCCEED):
        print(B_var)
        Atom("fail").post_goal()                   # Post fail for backtracking over solutions
         
    cleanup()                                      # Shutdown ECLiPSe engine


def example3():
    """
    Cut example using ic library
    """
    print("Cut Example")
    init()                                              # Init ECLiPSe engine
    Compound("lib","lists").post_goal()                 # lib(lists)
    A_var=Var()                                         # Create variable A
    Compound("member",A_var,PList([1,2,3])).post_goal() # member(A_var,[1,2,3])
    # Loop on all solution and print them.
    while (resume()[0]==SUCCEED):                       
        if A_var.value()==2:                            # When value == 2 cut all other solutions.
            cut()
            break
        Atom("fail").post_goal()                        # Post fail for backtracking over solutions
    B_var=Var()                                         # Create variable B
    Compound("is",B_var,\
             Compound("+",A_var,1)).post_goal()         # B_Var is A_var + 1
    resume()
    print(A_var,B_var)
    cleanup()                                           #Shutdown ECLiPSe engine
    
def example4():
    """Output data Example
    """    
    print ("Input Example")
    init()                                          # Init ECLiPSe engine
    Compound("writeln","Hello world").post_goal()
    result,stream_num=resume()
    if result != FLUSHIO:                           # Check for output data
        raise
    else:
        outStream=Stream(stream_num)                # Open output stream
        data=outStream.readall()                    # Return data in a bytes object
        print(data) 
        outStream.close()                           # Not required but implemented to support RawIO protocol
    cleanup()                                       # Shutdown ECLiPSe engine


def example5():
    """Input/Output data Example
    """    
    print ("I/O Example")
    init()                                # Init ECLiPSe engine
    stdin=Stream('stdin')                 # Open stdin stream
    stdout=Stream('stdout')               # Open stdout stream
    A_var=Var()                           # Variable where to store the input term.
    Compound ("read",A_var).post_goal()   # read(A)
    Compound("writeln",A_var).post_goal() # writeln(A)  

    while (1):                          
        result,stream=resume()
        if result==WAITIO:                # ECLiPSe is waiting for data
            stdin.write(b'Hello_World')
        elif result==FLUSHIO:
            print(stdout.readall())       # ECLiPSe send data to stdout stream
        else:
            break                     
    stdin.close()                         # Not required but implemented to support RawIO protocol
    stdout.close()                        # Not required but implemented to support RawIO protocol
    cleanup()                             # Shutdown ECLiPSe engine


if __name__ == '__main__':
    example1()
    example2()
    example3()
    example4()
    example5()