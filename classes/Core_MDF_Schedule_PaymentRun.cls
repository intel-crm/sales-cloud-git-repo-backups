/******************************************************************************************************
* Class Name  : Core_MDF_Schedule_PaymentRun  
* Version     : 1.0 
* Created Date: 01-22-2019
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - AD      01/22/2019          It is a schedulable class to run batch                                      
*******************************************************************************************************/
public without sharing class Core_MDF_Schedule_PaymentRun implements Schedulable {
    
    //To hold payment run object
    public Core_MDF_Payment_Run__c paymentRunInstance;
    
    //Constructor  - To assign payment run instance
    public Core_MDF_Schedule_PaymentRun(Core_MDF_Payment_Run__c paymentRunInstance){
        this.paymentRunInstance = paymentRunInstance;
    }
    
    public void execute(SchedulableContext sc) {
        //Call the batch class to be scheduled
        Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator (paymentRunInstance);
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(paymentbatch,200);
        
    }
}