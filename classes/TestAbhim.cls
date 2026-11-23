public without sharing class TestAbhim {
    public static void testMainMethod(){
     Boolean c=false;
     processMsg(c);
     System.debug('c'+c);
    }
    public static void processMsg(boolean c){
     c=true;
     System.debug('c'+c);
    }
}