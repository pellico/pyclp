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

'''
Created on Apr 20, 2012

@author: radice
'''
#@PydevCodeAnalysisIgnore
import unittest

from pyclp import *

    
  
class Test_atom(unittest.TestCase):
    def setUp(self):
        init()
        self.stdout=Stream('stdout')
    def tearDown(self):
        self.stdout.close()
        cleanup()
    def test_atom(self):
        atom=Atom('ciao')
        self.assertEqual(atom.__str__(),'ciao','Wrong atom name')
  
class Test_Compound(unittest.TestCase):
    def setUp(self):
        init()
        self.stdout=Stream('stdout')
    def tearDown(self):
        self.stdout.close()
        cleanup()
    def test_str(self):
        func=Compound('ciao',1,2,"pippo")
        self.assertEqual(func.__str__(),'ciao(1,2,"pippo")','Wrong functor name')
        func=Compound('ciao',Compound('test','stringa',1),2)
        self.assertEqual(func.__str__(),'ciao(test("stringa",1),2)','Wrong functor arity')
    def test_arity(self):
        func=Compound('ciao',1,2)
        self.assertEqual(func.arity(),2,'Wrong functor arity')
        var=Var()
        Compound('=',func,var).post_goal()
        self.assertTrue(resume(),"Failed resume")
        self.assertEqual(var.value().arity(),2,"Wrong arity from unified var")
    def test_functor(self):
        func=Compound('ciao',1,2)
        self.assertEqual(func.functor(),'ciao','Wrong functor string')
    def test_argumentsIterator(self):
        func=Compound('ciao',1,2)
        list_out=list(func.arguments())
        self.assertEqual(list_out,[1,2],'Failed test arguments() iterator')
    def test_Iterator(self):
        func=Compound('ciao',1,2)
        list_out=list(func)
        self.assertEqual(list_out,[1,2],'Failed test iterator')
    def test_len(self):
        func=Compound('ciao',1,2)
        self.assertEqual(len(func),2,'Wrong Compound lenght')
    def test_index(self):
        func=Compound('ciao',Compound('set',"test",Atom('doppio')),2)
        my_var=Var()
        Compound('=',my_var,func).post_goal()
        self.assertEqual(resume(),(SUCCEED,None), "Failed resume")
        var_value=my_var.value()
        self.assertEqual(var_value[0][0],"test","Failed test string")
        self.assertEqual(var_value[0][1],Atom("doppio"),"Failed test atom")
        self.assertEqual(var_value[0][-2],"test","Failed test with negative index")
   
    def test_comparison(self):
        comp1=Compound("Ciao",1,"a")
        comp1b=Compound("Ciao",1,"a")
        atom1=Atom("Zao")
        atom2=Atom("aoo")
        self.assertEqual(comp1 > atom2,True)
        self.assertEqual(atom2 > comp1,False)
        
        self.assertEqual(comp1 >= atom2,True)
        self.assertEqual(atom2 >= comp1,False)
        self.assertEqual(comp1 >= comp1b,True)
        
        self.assertEqual(comp1 < atom2,False)
        self.assertEqual(atom2 < comp1,True)
        
        self.assertEqual(comp1 <= atom2,False)
        self.assertEqual(atom2 <= comp1,True)
        self.assertEqual(comp1 <= comp1b,True)
        
        self.assertEqual(comp1 == atom2,False)
        self.assertEqual(comp1 == comp1b,True)
        
        self.assertEqual(comp1 != atom2,True)
        self.assertEqual(comp1 != comp1b,False)
        
        self.assertEqual(comp1 >= atom2,True)
    def testComparison2None(self):
        comp1=Compound("Ciao",1,"a")
        self.assertEqual(comp1==None,False)
        self.assertEqual(comp1!=None,True)
    def testInitList(self):
        comp1=Compound("my_list","no_list",[1,2,3,Atom("solo"),Var()])
        self.assertEqual(comp1.__str__(),'my_list("no_list",[1,2,3,solo,_])')
        
        
        
                
            

        
            

class Test_Term(unittest.TestCase):
    def setUp(self):
        init()
        self.stdout=Stream('stdout')
    def tearDown(self):
        self.stdout.close()
        cleanup()
    
    def test_post_resume(self):
        my_goal=Compound('writeln',Term('Ciao'))
        my_goal.post_goal()
        my_goal=Atom('fail')
        my_goal.post_goal()
        self.assertEqual(resume()[0],FLUSHIO,'Failed resume not output') 
        self.assertEqual(self.stdout.read(),'Ciao\n'.encode('ascii'),'Wrong output')
        self.assertEqual(resume(),(False,None),'Not failed')  
       
    def test_atom(self):
        my_goal=Compound('writeln',Atom('Ciao'))
        my_goal.post_goal()
        resume()
        self.assertEqual(self.stdout.read(),'Ciao\n'.encode('ascii'),'Wrong atom')
        self.assertEqual(resume(),(SUCCEED,None),'Failed resume')
    
    # Test to check bugs found by Federico Ferri  
    def test_0value(self):
        X=pyclp.Var()
        goal=pyclp.Compound('is', X, pyclp.Compound('+', 0, 3))
        self.assertEqual(goal.__str__(),"is(_,+(0,3))")
        goal.post_goal()
        ret,arg=pyclp.resume()
        self.assertEqual(X.value(),3,"Wrong result")
        

class Test_PList(unittest.TestCase):
    def setUp(self):
        init()
        self.stdout=Stream('stdout')
    def tearDown(self):
        self.stdout.close()
        cleanup()
    def testInit(self): 
        my_list=PList([1,2,3,"A",Atom("ciao"),Compound("my_func",1,"ciao",PList((1,2,"hello")))])
        Compound("writeln",my_list).post_goal()
        self.assertNotEqual(resume(),False)
        self.assertEqual(self.stdout.read(),b'[1, 2, 3, A, ciao, my_func(1, ciao, [1, 2, hello])]\n')
        self.assertNotEqual(resume(),False)
    def testConversion2String(self):
        my_list=PList([1,2,3,"A",Atom("ciao"),Compound("my_func",1,"ciao",PList((1,2,Var())))])
        self.assertEqual(my_list.__str__(),'[1,2,3,"A",ciao,my_func(1,"ciao",[1,2,_])]')
    def testLen(self):
        my_list=PList([1,2,3,"A",Atom("ciao"),Compound("my_func",1,"ciao",PList((1,2,Var())))])
        self.assertEqual(len(my_list),6)
    def testIterator(self):
        input_list=[1,2,4,"Ciao",Atom("ciccio")]
        my_list=PList(input_list)
        self.assertEqual(list(my_list),input_list)
        my_var=Var()
        Compound("=",my_var,my_list).post_goal()
        self.assertTrue(resume())
        self.assertIsInstance(my_var.value(), PList)
        self.assertEqual(list(my_var.value()),input_list)
    def testHeadTailIter(self):
        input_list=(1,2,4,"Ciao",Atom("ciccio"))
        prolog_list=PList(input_list)
        k=0
        for head,tail in prolog_list.iterheadtail():
            self.assertEqual(head,input_list[k])
            self.assertEqual(tuple(tail),input_list[(k+1):])
            k+=1
    def testIndex(self):
        input_tuple=(1,2,4,"Ciao",Atom("ciccio"))
        my_var=Var()
        Compound("=",my_var,input_tuple).post_goal()
        self.assertTrue(resume())
        returned_value=my_var.value()
        for i in range(len(input_tuple)):
            self.assertEqual(input_tuple[i],returned_value[i])
            self.assertEqual(input_tuple[-i],returned_value[-i])

        
        
class Test_Stream(unittest.TestCase):
    def setUp(self):
        init()
    def tearDown(self):
        cleanup()
    def test_read(self):
        Compound("writeln","ciao").post_goal()
        self.assertEqual(resume(),(FLUSHIO,1))
        s=Stream(1)
        self.assertEqual(s.read(),b"ciao\n")
        s.close()
        self.assertEqual(resume(),(SUCCEED,None))
    def test_readall(self):
        Compound("writeln","Hallo").post_goal()
        self.assertEqual(resume(),(FLUSHIO,1))
        s=Stream(1)
        self.assertEqual(s.readall(),b"Hallo\n")
        s.close()
        self.assertEqual(resume(),(SUCCEED,None))
    def test_write(self):
        read_term=Var()
        Compound('read',read_term).post_goal()
        self.assertEqual(resume(),(WAITIO,0))
        s=Stream(0)
        s.write(b'"Ciao pylclp2"')
        self.assertEqual(resume(),(SUCCEED,None))
        self.assertEqual(read_term.value(),'Ciao pylclp2')
        
        
class Test_Var(unittest.TestCase):
    def setUp(self):
        init()
        self.stdout=Stream('stdout')
    def tearDown(self):
        self.stdout.close()
        cleanup()
    def testDoubleReference(self):
        """This test verify if a Var (alias Reference) is
        correctly returned by a predicate after resume.
        """ 
        my_var=Var()
        list_var=Var()
        my_list=PList([my_var,2,3])
        Compound("=",list_var,my_list).post_goal()
        self.assertNotEqual(resume(),False)
        Compound("=",list_var.value()[0],3).post_goal()
        self.assertNotEqual(resume(),False)
        self.assertEqual(my_var.value(),3)
        
        
class Test_Others(unittest.TestCase):
    """Check persistence of constructed terms after
    resume.
    """
    def setUp(self):
        init()
        self.stdout=Stream('stdout')
    def tearDown(self):
        self.stdout.close()
        cleanup()
    def testCompound(self):
        """
        Test persistence of constructed compound
        """
        Compound("lib",Atom("listut")).post_goal()
        self.assertEqual(resume(), (SUCCEED,None), "Failed loading library")
        args_list=[1,2,3,4,5,6,7,8,10]
        my_compound=Compound("pippo",*args_list) #This term shall persist across the invocation
        for index in range(len(args_list)):
            Compound("lib",Atom("listut")).post_goal()
            list_var=Var()
            element_var=Var()
            Compound("=..",my_compound,list_var).post_goal()
            Compound("nth0",index+1,list_var,element_var).post_goal()
            self.assertEqual(resume(),(SUCCEED,None),"Failed resume at element {0}".format((index,)))
            self.assertEqual(element_var.value(),args_list[index],"Failed recovering of element {0}".format((index,)))
    def testCut(self):
        """
        Test cut
        """
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
        self.assertEqual(A_var.value(),2,"Failed A_var result")
        self.assertEqual(B_var.value(),3,"Failed B_var result")

    def testAbort(self):
        """
        Test when a query abort
        """
        Compound("asd","dsa").post_goal()
        result,stream_id=resume()
        outStream=Stream(stream_id)
        self.assertEqual(outStream.readall(),b"calling an undefined procedure asd(\"dsa\") in module eclipse\n")
        result,myAtom=resume()
        self.assertEqual(result,THROW)
        self.assertIsInstance(myAtom,Atom)
        self.assertEqual(myAtom.__str__(),"abort")
        
class Test_set_option(unittest.TestCase):
    """Test set_option.
    """
    def test_local_size(self):
        set_option(OPTION_LOCALSIZE,50*1024*1024)
        init()
        my_var=Var()
        Compound('get_flag',Atom("max_local_control"),my_var).post_goal()
        resume()
        self.assertEqual(my_var.value(), 50*1024*1024, "Failed test OPTION_LOCALSIZE")
        cleanup()
    def test_global_size(self):
        set_option(OPTION_GLOBALSIZE,122*1024*1024)
        init()
        my_var=Var()
        Compound('get_flag',Atom("max_global_trail"),my_var).post_goal()
        resume()
        self.assertEqual(my_var.value(), 122*1024*1024, "Failed test OPTION_LOCALSIZE")
        cleanup()
        
class Test_initialization(unittest.TestCase):
    def test_init_cleanup_loop(self):
        my_var=None
        for x in range(4):
            init()
            my_var=Var()
            Compound("=",Atom("test"),my_var).post_goal()
            resume()
            self.assertEqual(my_var.__str__(),"test","Failed unification with multi init")
            cleanup()
    def test_double_init(self):
        init()
        with self.assertRaises(pyclpEx):
            init()
        cleanup()
    def test_double_cleanup(self):
        init()
        cleanup()
        with self.assertRaises(pyclpEx):
            cleanup()
   
        
     
class Test_external_predicates(unittest.TestCase):
    """
    Test calling python function from eclipse.
    """
    def setUp(self):
        init()
        self.stdout=Stream('stdout')
    def tearDown(self):
        self.stdout.close()
        cleanup()
    def test_call_with_arguments_and_unify(self):
        eclipse_name='p_func'
        
        def called_from_eclipse(arguments):
            return unify(arguments[0],arguments[1])
        
        addPythonFunction(eclipse_name,called_from_eclipse)
        my_var=Var()
        Compound('call_python_function',Atom(eclipse_name),[1,my_var]).post_goal()
        self.assertEqual(resume(),(SUCCEED,None),"Failed resume ")
        self.assertEqual(my_var.value(),1,"Failed unification")
    def test_call_with_exception(self):
        """Test python exception generated by eclispe when calling an external predicate
        implemented in python 
        """
        eclipse_name='p_func'
        def called_from_eclipse(arguments):
            a=a +1 
            return SUCCEED
        addPythonFunction(eclipse_name,called_from_eclipse)
        my_var=Var()
        Compound('call_python_function',Atom(eclipse_name),[1,my_var]).post_goal()
        with self.assertRaises(UnboundLocalError) as exp:
            resume()
        
        

if __name__ == '__main__':
   unittest.main()
   #test1()