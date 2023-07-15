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

import pyclp

def example1():
    """Simple unification
    """
    pyclp.init()                        #Init ECLiPSe engine
    myVar=pyclp.Var()                   #Create a prolog variable
    my_goal=pyclp.Compound("=",myVar,1) # Create goal
    my_goal.post_goal()                 #Post goal
    result,dummy =pyclp.resume()        #Resume execution of ECLiPSe engine
    if result != pyclp.SUCCEED:
        raise
    print(myVar.value +1)               #myVar.value get the var value back.
    print(myVar)                        #print value
    pyclp.cleanup()                     #Shutdown ECLiPSe engine
    
    

def example2():
    """Using streams
    """
    pyclp.init()
    goal1=pyclp.Compound('writeln','Hello world')
    goal1.post_goal()
    result,stream_num=pyclp.resume()
    if result==pyclp.FLUSHIO:
        output_stream=pyclp.Stream(stream_num)
        print(output_stream.readall())
        output_stream.close()
    else:
        raise
    result,dummy=pyclp.resume()
    if result != pyclp.SUCCEED:
        raise
    pyclp.cleanup()

if __name__ == '__main__':
    example1()
    example2()