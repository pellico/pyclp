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
    init()                        #Init ECLiPSe engine
    myVar=Var()                   #Create a prolog variable
    my_goal=Compound("=",myVar,1) # Create goal
    my_goal.post_goal()                 #Post goal
    result,dummy =resume()        #Resume execution of ECLiPSe engine
    if result != SUCCEED:
        raise
    print(myVar.value() +1)               #myVar.value get the var value back.
    print(myVar)                        #print value
    cleanup()                     #Shutdown ECLiPSe engine
    
    

def example2():
    """Using streams
    """
    init()
    goal1=Compound('writeln','Hello world')
    goal1.post_goal()
    result,stream_num=resume()
    if result==FLUSHIO:
        output_stream=Stream(stream_num)
        print(output_stream.readall())
        output_stream.close()
    else:
        raise
    result,dummy=resume()
    if result != SUCCEED:
        raise
    cleanup()
    
    
def example3():
    """
    Search example using ic library
    """
    print("Search example")
    init()                                         # Init ECLiPSe engine
    Compound("lib",Atom("ic")).post_goal()   # Load ic library
    A_var=Var()                                    # Create variable A
    B_var=Var()                                    # Create variable B
    Compound("#::",PList([A_var,B_var]),Compound("..",1,10)).post_goal() # [A,B]#::1..10
    Compound("#<",A_var,B_var).post_goal()         # A#<B
    Compound("#=",A_var,5).post_goal()             # A#=5
    Compound("labeling",PList([A_var,B_var])).post_goal()  # labeling([A,B])
    # Loop on all solution and print them.
    while (resume()[0]==SUCCEED):
        print(B_var)
        Atom("fail").post_goal()                   # Post fail for backtracking over solutions
         
    cleanup()                                      #Shutdown ECLiPSe engine


def example4():
    """
    Cut example using ic library
    """
    print("Cut Example")
    init() # Init ECLiPSe engine
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

if __name__ == '__main__':
    example1()
    example2()
    example3()
    example4()