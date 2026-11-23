/****************************************************************************************************
Apex Class Name : PSG_BatchPridECPInactive
Version         : 1.0 
Created Date    : 03/08/2022
Function        : This class is used to process the Non-CP PRID where the End Customer Parent is Inactive/Blocked.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Adarsh                    03/08/2022                Created
*****************************************************************************************************/
@isTest
global class PSG_BatchPridECPInactive {
    /*implements Database.Batchable<Sobject>, Database.Stateful{
    Map<Id,String> failedPRIDMap = new Map<Id,String>();
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT id, name, core_cpq_update_underlying_quotelines_cb__c, core_cpq_sap_ecp_nm__r.Name from price_prid__c WHERE core_cpq_sap_ecp_nm__r.Core_Direct_Account_Active_Ind__c = false AND core_cpq_active_cb__c = true
                                        AND core_cpq_cps_cb__c = false]);
    }
    public void execute(Database.BatchableContext bc, List<SObject> sobjLst){
        try{
            List<price_prid__c> pridIdList = (List<price_prid__c>) sobjLst;
            List<price_prid__c> pridList = new List<price_prid__c>();
            for(price_prid__c prid : pridIdList){
                prid.core_cpq_active_cb__c = false;
                prid.core_cpq_update_underlying_quotelines_cb__c = true;
                prid.Inactivation_Reason__c = 'Deactivated as the ECP \''+ prid.core_cpq_sap_ecp_nm__r.Name+'\' is blocked.';
                pridList.add(prid);
            }
            if(!pridList.isEmpty()){
                update pridList;
            }
        }
        catch(Exception e){
            failedPRIDMap.put((String)sobjLst[0].get('Id'),e.getMessage());
        }
    }
    public void finish(Database.BatchableContext bc) {
        if(!failedPRIDMap.isEmpty()){
            PSG_Utility.createCoreLogEntry('PSG_BatchPridECPInactive','PSG_BatchPridECPInactive','Failed PRIDs while processing through PSG_BatchPridECPInactive',''+failedPRIDMap
                                         ,'price_prid__c','High','');
        }
    }*/
}