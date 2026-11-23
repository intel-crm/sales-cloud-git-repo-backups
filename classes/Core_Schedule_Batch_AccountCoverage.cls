//Scheduler for Account Coverage 
public class Core_Schedule_Batch_AccountCoverage implements Schedulable{
    
    public void execute(SchedulableContext SC) {
        //Check the mule service previous run status . if Failed Do not run the job but consider calling the mule service again.
        Core_AccountCoverage_Batch_Status__c status = [Select Core_Batch_Status__c FROM Core_AccountCoverage_Batch_Status__c where Name ='Core_Batch_AccountCoverage_MuleService'];
        if('FAILED'.equalsIgnoreCase(status.Core_Batch_Status__c)){
            Database.executeBatch(new Core_Batch_AccountCoverage_Mule());
        }else{
            Database.executeBatch(new Core_Batch_AccountCoverage_Delete(),1500);    
        }
    }
    
}