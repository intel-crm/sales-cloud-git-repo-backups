public class TestFutureController {
    
    @future
   public static void executeInFuture(){
      System.debug('Future Method is getting called through Schedulable....');
   }

}