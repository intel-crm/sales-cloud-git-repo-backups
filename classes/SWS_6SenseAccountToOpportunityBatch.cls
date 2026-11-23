/********************************************************************************************************************************************************************
Apex Class Name: SWS_6SenseAccountToOpportunityBatch 
Version: 1.0
Created Date: 12/18/2024
Function: 6Sense integration related batch for updating opportunities based on Opportunity Account update. This batch is called from Account triggered Flow
Modification Log :
* Developer                 Date                Description
* ----------------------------------------------------------------------------
* Shijas KM          11/18/2024          Original Version developed (Not Using anymore -> Bishal) 
******************************************************************************************************************************/
global class SWS_6SenseAccountToOpportunityBatch implements Database.Batchable<Sobject>, Database.Stateful {
    
    public String accountId;   
    public List<Opportunity> OpportunityData= new List<Opportunity>();    
    global SWS_6SenseAccountToOpportunityBatch(String param) {
        this.accountId = param;
    }
    
    global List<Opportunity> start(Database.BatchableContext BC) {   
        system.debug('updated records start');
        system.debug('this.accountId: ' + this.accountId);        
        List<Opportunity> optyData = [SELECT id, Account.Is_6Sense_Integration_Enabled__c, Account.RecordType.name, Account.Core_Covered_Account__c , account.Industry, Core_Military_Aerospace_Govmt_End_Use__c, Core_Consumption_Market__c, Core_Opportunity_Coverage_Nm__c, Core_Design_Registration_Id__c FROM Opportunity WHERE Core_Opportunity_Coverage_Nm__c='Intel-Led Opportunity' AND AccountId =: this.accountId];
        return optyData;
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        try {
            //logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error SWS_6SenseAccountToOpportunityBatch execute method1',Core_Details__c = e.getMessage(),Core_Origin__c = 'SWS_6SenseAccountToOpportunityBatch',Core_Severity__c = 'High',Core_When__c = System.now(),Core_Project__c = 'Software Sales'));
            OpportunityData = new List<Opportunity>();
            for (Opportunity rec : scope) {
                if (rec.Account.Is_6Sense_Integration_Enabled__c== true && rec.Core_Military_Aerospace_Govmt_End_Use__c=='No' && rec.Core_Consumption_Market__c !='Government' && rec.Core_Opportunity_Coverage_Nm__c == 'Intel-Led Opportunity' && rec.Core_Design_Registration_Id__c =='' ){
                    rec.Is_6Sense_Integration_Enabled__c = true;
                }else{
                	rec.Is_6Sense_Integration_Enabled__c = false;
                }                
                OpportunityData.add(rec);
            }
            if (OpportunityData.size()> 0) {
                update OpportunityData;
            }            
            system.debug('--------updated records' + OpportunityData.size());
        }
        catch (Exception e) { 
            system.debug('Exception');
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error SWS_6SenseAccountToOpportunityBatch execute method',Core_Details__c = e.getMessage(),Core_Origin__c = 'SWS_6SenseAccountToOpportunityBatch',Core_Severity__c = 'High',Core_When__c = System.now(),Core_Project__c = 'Software Sales'));
        } 
        finally {     
            if (!logEntries.isEmpty()) {
                insert logEntries;
            }       
        }
    }   
    global void finish(Database.BatchableContext BC) {
        system.debug('updated records finish');
    }
}