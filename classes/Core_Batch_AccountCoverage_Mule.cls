//
public class Core_Batch_AccountCoverage_Mule implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    //TODO where clause where status = processed count > 0
    public Database.QueryLocator start(Database.BatchableContext batchcontext) {
        //return Database.getQueryLocator([Select Id, Name, Core_Status__c, Core_Operation__c FROM Core_AccountCoverage_Export__c WHERE Core_Operation__c != 'NC' LIMIT 1] );
           return Database.getQueryLocator('');
    }
    
    //Process the sObject 
    public void execute(Database.BatchableContext BC, list<sObject> scope){ 
   //     String status = Core_AccountCoverageExportUtil.callMuleService();
     //   System.debug(' Mule Service Response '+status);
    }
    
    //Finish the Batch
    public void finish(Database.BatchableContext batchcontext){  
        
    }
     
      public static String dummyMethod1() {
        return null;
    } 
     public static String dummyMethod2() {
        return null;
    } 
     
     public static String dummyMethod3() {
        return null;
    } 
     public static String dummyMethod4() {
        return null;
    } 
     public static String dummyMethod5() {
        return null;
    } 
     public static String dummyMethod6() {
        return null;
    } 
    public static String dummyMethod7() {
        return null;
    } 
    public static String dummyMethod8() {
        return null;
    } 
    public static String dummyMethod9() {
        return null;
    } 
}