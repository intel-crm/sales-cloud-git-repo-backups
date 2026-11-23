/****************************************************************************************************
Apex Class Name : PSG_BatchQuoteECPInactive
Version         : 1.0 
Created Date    : 11/11/2021
Function        : This class is used to process the Approved Non-CP quotes where the CMF Pricing Parent is Inactive/Blocked. This will be scheduled to run daily.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Adarsh                    11/11/2021                Created
*****************************************************************************************************/
@isTest
global class PSG_BatchQuoteECPInactive {
    /*implements Database.Batchable<Sobject>, Database.Stateful, Schedulable{
    Map<Id,String> failedQuoteMap = new Map<Id,String>();
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT id, name from SBQQ__Quote__c WHERE core_cpq_sap_ecp_nm__r.Core_Direct_Account_Active_Ind__c = false AND Pricing_Quote_Program_Nm__c = 'PSG'
                                         AND SBQQ__Status__c = 'Approved' AND core_cpq_active_cb__c = true AND core_cpq_quote_type_nm__c != 'Contract Pricing']);
    }
    public void execute(Database.BatchableContext bc, List<SObject> sobjLst){
        try{
            List<SBQQ__Quote__c> QuoteIdList = (List<SBQQ__Quote__c>) sobjLst;
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            for(SBQQ__Quote__c quote : QuoteIdList){
                quote.core_cpq_active_cb__c = false;
                quoteList.add(quote);
            }
            if(!quoteList.isEmpty()){
                update quoteList;
            }
        }
        catch(Exception e){
            failedQuoteMap.put((String)sobjLst[0].get('Id'),e.getMessage());
        }
    }
    public void finish(Database.BatchableContext bc) {
        if(!failedQuoteMap.isEmpty()){
            PSG_Utility.createCoreLogEntry('PSG_BatchQuoteECPInactive','PSG_BatchQuoteECPInactive','Failed Quotes while processing through PSG_BatchQuoteECPInactive',''+failedQuoteMap
                                         ,'SBQQ__Quote__c','High','');
        }
        //Database.executeBatch(new PSG_SendBulkSAPRequestBatch(),1); 
        Database.executeBatch(new PSG_BatchPridECPInactive(),1);
    }
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new PSG_BatchQuoteECPInactive(), 1);
    }*/
}