global class Core_PrimeAccountNameScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      Core_PrimeAccountName_BatchClass primeAccNamebatch= new Core_PrimeAccountName_BatchClass(); 
      database.executebatch(primeAccNamebatch,200);
   }
}