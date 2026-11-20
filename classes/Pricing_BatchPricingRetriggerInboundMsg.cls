/**
 * @description       : 
 * @author            : Rajesh Gajul
 * @group             : 
 * @last modified on  : 04-14-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global without sharing class Pricing_BatchPricingRetriggerInboundMsg  implements Database.Batchable<sObject>{
    public DateTime dtWhen;
    global integer resursiveCounter;
    public Pricing_BatchPricingRetriggerInboundMsg(){
        dtWhen = system.now();
    }
    public Database.querylocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,Name,CreatedDate,Core_Error_Code__c,Core_Retry_Counter__c,Core_Message_Type__c,Core_Log_Entry__c,Core_Payload__c,Core_Source_System__c from Core_Integration_Inbound_Message__c 
                                         where Core_Processing_Status__c =: Label.Pricing_Tender_Inbound_Status_Failed
                                         and Core_Reprocess_Message__c = true and (Core_Retry_Counter__c < 3 or Core_Retry_Counter__c = null)
                                         and Core_Source_System__c =: Label.Pricing_Tender_Inbound_Source_MyDeals
                                         and Core_Message_Type__c =: Label.Pricing_Tender_Inbound_MsgType_Tender]);
    }
    public void execute(Database.BatchableContext bc, List<sObject> scope){
     Pricing_IntegrationSFDCToPricingSystems integrationInstance = new Pricing_IntegrationSFDCToPricingSystems();
     try{
            //Execute Batch Only if the Limit is not reached
            integrationInstance.processMessages(scope);
        }catch(exception ex){
            List<Core_Integration_Inbound_Message__c> inboundStatusUpdate = new List<Core_Integration_Inbound_Message__c>();
            for(Core_Integration_Inbound_Message__c inbound : (List<Core_Integration_Inbound_Message__c>)scope){
               inbound.Core_Processing_Status__c = Label.Pricing_Tender_Inbound_Status_Failed;
               Pricing_IntegrationSFDCToPricingSystems.inboundStatusUpdate(inbound);
            }
            update inboundStatusUpdate;
            Pricing_Tender_Utility.logError(ex);
       }
    }
    public void finish(Database.BatchableContext bc){
          // Get the batch job information
          List<Core_Integration_Inbound_Message__c> inboundList = new List<Core_Integration_Inbound_Message__c>();
          inboundList = [SELECT Id,Name,CreatedDate,Core_Error_Code__c,Core_Retry_Counter__c,Core_Message_Type__c,Core_Log_Entry__c,Core_Payload__c,Core_Source_System__c from Core_Integration_Inbound_Message__c 
                                         where Core_Processing_Status__c =: Label.Pricing_Tender_Inbound_Status_Failed
                                         and Core_Reprocess_Message__c = true and (Core_Retry_Counter__c < 3 or Core_Retry_Counter__c = null)
                                         and Core_Source_System__c =: Label.Pricing_Tender_Inbound_Source_MyDeals
                                         and Core_Message_Type__c =: Label.Pricing_Tender_Inbound_MsgType_Tender];
          List<Core_Integration_Inbound_Message__c> recursiveInboundList = new List<Core_Integration_Inbound_Message__c>();                              
          if(!inboundList.isEmpty() || Test.isRunningTest()){
              Integer batchSize = 1;                               
              String batchSizeStr = Label.Pricing_Tender_inbound_Retrigger_Batch_Size;
              if(batchSizeStr.isNumeric()){
                  batchSize = Integer.valueOf(batchSizeStr);
              }
              //Retrigger Batch if there are Inbound Records to be preocessed
              Pricing_BatchPricingRetriggerInboundMsg retriggerBatch = new Pricing_BatchPricingRetriggerInboundMsg();
              resursiveCounter = resursiveCounter == null ? 0:resursiveCounter;
              retriggerBatch.resursiveCounter = resursiveCounter + 1;
                  if(!Test.isRunningTest() && resursiveCounter < Integer.valueof(Label.Pricing_Recursive_Counter_Label)){
                      database.executeBatch(retriggerBatch,batchSize);
                  }else{
                      for(Core_Integration_Inbound_Message__c inRec : inboundList){
                          inRec.Core_Reprocess_Message__c = false;
                          inRec.Core_Retry_Counter__c = 5;
                          recursiveInboundList.add(inRec);
                      }
                  }
              if(!recursiveInboundList.isEmpty()){
                  update recursiveInboundList;
              }          
          }
          // In future send email to L2 regarding batch status ??
         // Send email summary for the batch, number of users added/removed licence used / remaining.
        List<Core_Log_Entry__c> lstLogEntryRecords = createLogEntryRecords();
        List<Database.SaveResult> resultsCreateLogRecords = Database.insert(lstLogEntryRecords, false);
    }
    private List<Core_Log_Entry__c> createLogEntryRecords(){
        List<Core_Log_Entry__c> lstLogEntry = new List<Core_Log_Entry__c>();
        DateTime dtnow = system.now();
        decimal duration = ((dtnow.getTime())/1000) - ((dtWhen.getTime())/1000);
        
        // Create Assign log Entry
        Core_Log_Entry__c addLogEntry = new Core_Log_Entry__c ();
        addLogEntry.Core_Origin__c = 'Pricing_BatchPricingRetriggerInboundMsg/Batch for Retriggering Inbonunds';
        addLogEntry.Core_Project__c = 'Intel Quote Request (IQR)';
        addLogEntry.Core_Scope__c = 'IQR Inbound Processing';
        addLogEntry.Core_Severity__c = 'Information';
        addLogEntry.Core_Message__c = 'Batch for Retriggering Inbonunds';
        addLogEntry.Core_When__c = dtWhen;
        addLogEntry.Core_Details__c = 'Duration: ' + duration+' for processing batch';

        lstLogEntry.add(addLogEntry);        
        return(lstLogEntry);
    }
}