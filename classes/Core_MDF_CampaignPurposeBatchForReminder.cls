/*********************************
Class Name  : Core_MDF_CampaignPurposeBatchForReminder
Function    : Collect Ultimate Account IDs and iupgmUserId from Campaign purpose object
Modification Log :
* Developer              Date          Description
* ---------------------------------------------------------------------------- 
* Rishabh Srivastava     07/07/2025    Original version
**********************************/
global class Core_MDF_CampaignPurposeBatchForReminder implements Database.Batchable<SObject>, Database.Stateful {
    
    
    public Set<String> ultimateAccountIds = new Set<String>();
    public Set<Id> iupgmUserIdSet = new Set<Id>();
    
    global static Database.QueryLocator start(Database.BatchableContext context) {
        
        String query = 'SELECT Id, Name, Core_MDF_Active_Ind__c, Core_MDF_Campaign_Id__c, Core_MDF_Quantity_nbr__c, '
            + 'Core_MDF_Campaign_Id__r.Core_MDF_Ultimate_Account_txt__c, Core_MDF_Campaign_Id__r.Status '
            + 'FROM Core_MDF_Campaign_Outcomes__c '
            + 'WHERE Core_MDF_Campaign_Id__r.Status = \'Completed\' '  
            + 'AND Core_MDF_Active_Ind__c = TRUE '
            + 'AND Core_MDF_Quantity_nbr__c = null'; 
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Core_MDF_Campaign_Outcomes__c> campaignOutObj) {
        try {
            List<String> accMgrRolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Account_Manager_Roles');
            for (Core_MDF_Campaign_Outcomes__c cam : campaignOutObj) {
                String acct = cam.Core_MDF_Campaign_Id__r.Core_MDF_Ultimate_Account_txt__c;
                if (String.isNotBlank(acct)) {
                    ultimateAccountIds.add(acct);
                }
            }
            if(!ultimateAccountIds.isEmpty()){
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Id,Core_MDF_Account_id__c,Core_MDF_User_id__c,Core_MDF_Active_Ind__c,Core_MDF_Account_id__r.Name,
                                                                       Core_MDF_User_id__r.Email,Core_MDF_Role_nm__c,Core_MDF_is_User_Active_ind__c
                                                                       FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                       WHERE Core_MDF_Account_id__c  IN: ultimateAccountIds
                                                                       AND Core_MDF_Role_nm__c IN:accMgrRolesList 
                                                                       AND Core_MDF_is_User_Active_ind__c = TRUE 
                                                                       AND Core_MDF_Active_Ind__c = TRUE
                                                                      ]){
                                                                          iupgmUserIdSet.add(iupgm.Core_MDF_User_id__c);
                                                                      }
            }
            
        } catch (Exception ex) {
            System.debug('Exception in execute: ' + ex.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext context) {
        try {
            if(iupgmUserIdSet != null && iupgmUserIdSet.size() > 0){
                // calling batch to send email and log entries      
                Core_MDF_Email_NotificationLoggingBatch emailNotifyLogBatch = new Core_MDF_Email_NotificationLoggingBatch(iupgmUserIdSet,null,Core_MDF_CCP_ConstantClass.Campaign_Purpose_Notification,null);
                //  custom metadata with batch size value 
                Integer batchSize = Core_MDF_CustomLabelConfig.getIntegerValues('Core_MDF_CP_NotifyLogBatchSize');
                Id batchInstanceId = Database.executeBatch(emailNotifyLogBatch,batchSize); 
            }
        } catch (Exception ex) {
            System.debug('Exception in finish: ' + ex.getMessage());
        }
    }
}