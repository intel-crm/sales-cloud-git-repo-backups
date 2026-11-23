public class Test2 {

      public static void testm2(){
          try{
              Account acc = new Account(name='Test1');
              insert acc;
          }catch(Exception ex){
              System.debug('Test2==>'+ex);
          }
    }
}