global class Core_FutureSchedulableControler implements Schedulable {    
     
   global void execute(SchedulableContext SC){      
      executeInFuture();
      //TestFutureController.executeInFuture();
   }
    
   @future
   public static void executeInFuture(){
      System.debug('Future Method is getting called....');
   }

}