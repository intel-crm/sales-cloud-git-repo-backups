public without sharing class TestAbhi {
   public static void testMainMethod(){
    List<String> listString=new List<String>();
    process(listString);
    System.debug('listString '+listString);
   }
   public static void process(List<String> listString){
    listString.add('Ak');
    System.debug('listString'+listString);
   }
}