/*********************************
Class Name  : Core_MDF_CampaignPurposeBatchForReminder
Function    : Collect Ultimate Account IDs and iupgmUserId from Campaign purpose object
Modification Log :
* Developer              Date          Description
* ---------------------------------------------------------------------------- 
* Rishabh Srivastava     07/07/2025    Original version
**********************************/
global class Core_MDF_CampaignPurposeBatchForReminder implements Database.Batchable<SObject>, Database.Stateful {
    
    
    public Set<Id> ultimateAccountIds = new Set<Id>();
    public Set<Id> iupgmUserIdSet = new Set<Id>();
    global static Database.QueryLocator start(Database.BatchableContext context) {
        
        String query = 'SELECT Id, Name, Core_MDF_Active_Ind__c, Core_MDF_Campaign_Id__c, Core_MDF_Quantity_nbr__c,Core_MDF_Campaign_Id__r.Core_MDF_Channel_Program__c, '
            + 'Core_MDF_Campaign_Id__r.Core_MDF_Ultimate_Account_txt__c, Core_MDF_Campaign_Id__r.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Campaign_Id__r.Status '
            + 'FROM Core_MDF_Campaign_Outcomes__c '
            + 'WHERE Core_MDF_Campaign_Id__r.Status = \'Completed\' '  
            + 'AND Core_MDF_Active_Ind__c = TRUE '
            + 'AND Core_MDF_Quantity_nbr__c = null'; 
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<Core_MDF_Campaign_Outcomes__c> campaignOutObj) {
        try {
            
            List<String> accMgrRolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Account_Manager_Roles');
            Set<String> uniqueKeyOfPrgAndAccId= new Set<String>();
            Set<Id> allowedProgramIds = new Set<Id>();//added  
            Set<Id> setOfCampaignIds = new Set<Id>();
            Map<Id, Id> activityIdsVsCamIdsMap = new Map<Id, Id>(); 
            Set<Id> SetOfCamIdsWithPaidClaim = new Set<Id>();
            string paidstatus=Core_MDF_CCP_ConstantClass.PAID_CLAIMS;
            string cancelledActivtyStatus = Core_MDF_CCP_ConstantClass.PFR_CANCELLED_STATUS;
            
            
            
            for (Core_MDF_Campaign_Outcomes__c camprpose : campaignOutObj) {
                if(camprpose.Core_MDF_Campaign_Id__c != null){
                    setOfCampaignIds.add(camprpose.Core_MDF_Campaign_Id__c);
                }
            }
            if(!setOfCampaignIds.isEmpty()){
                for(PartnerFundRequest pfr : [SELECT Id, CampaignId  FROM PartnerFundRequest where CampaignId IN:setOfCampaignIds and Core_MDF_Fund_Request_Status__c!=:cancelledActivtyStatus]){// exclude --cancelled PFR
                    activityIdsVsCamIdsMap.put(pfr.Id,pfr.CampaignId); 
                }
            }
            if(activityIdsVsCamIdsMap!=null && !activityIdsVsCamIdsMap.isEmpty()){  
                for (AggregateResult pfc : [SELECT RequestId requestId, COUNT(Id) claimCount FROM PartnerFundClaim WHERE RequestId IN :activityIdsVsCamIdsMap.keySet() AND Core_MDF_Status__c = :paidstatus GROUP BY RequestId]) {
                    SetOfCamIdsWithPaidClaim.add(activityIdsVsCamIdsMap.get((Id) pfc.get('requestId')));  
                }
            }
            if(!SetOfCamIdsWithPaidClaim.isEmpty()){
                for (Core_MDF_Campaign_Outcomes__c cam : campaignOutObj) {
                    if(cam.Core_MDF_Campaign_Id__c!=null && SetOfCamIdsWithPaidClaim.contains(cam.Core_MDF_Campaign_Id__c)){
                        if (cam.Core_MDF_Campaign_Id__r == null || cam.Core_MDF_Campaign_Id__r.Core_MDF_Account__r == null ||cam.Core_MDF_Campaign_Id__r.Core_MDF_Channel_Program__c == null) {
                            continue;
                        }
                        Id acct = cam.Core_MDF_Campaign_Id__r.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c;
                        if (acct == null) continue;
                        ultimateAccountIds.add(acct);
                        allowedProgramIds.add(cam.Core_MDF_Campaign_Id__r.Core_MDF_Channel_Program__c);
                        String uniqueKey = acct + '-' + cam.Core_MDF_Campaign_Id__r.Core_MDF_Channel_Program__c;
                        uniqueKeyOfPrgAndAccId.add(uniqueKey);
                    }
                }
            }
            if(!ultimateAccountIds.isEmpty() && !allowedProgramIds.isEmpty() && !uniqueKeyOfPrgAndAccId.isEmpty()){
                
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Id,Core_MDF_Account_id__c,Core_MDF_User_id__c,Core_MDF_Active_Ind__c,Core_MDF_Account_id__r.Name,
                                                                       Core_MDF_User_id__r.Email,Core_MDF_Role_nm__c,Core_MDF_is_User_Active_ind__c,Core_MDF_Program_nm__c,Core_MDF_Channel_Program_id__c
                                                                       FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                       WHERE Core_MDF_Account_id__c  IN: ultimateAccountIds
                                                                       AND Core_MDF_Role_nm__c IN:accMgrRolesList 
                                                                       AND Core_MDF_Channel_Program_id__c IN :allowedProgramIds//added
                                                                       AND Core_MDF_is_User_Active_ind__c = TRUE 
                                                                       AND Core_MDF_Active_Ind__c = TRUE
                                                                      ]){
                                                                          String iupgmUniqueKey = iupgm.Core_MDF_Account_id__c + '-' + iupgm.Core_MDF_Channel_Program_id__c;
                                                                          
                                                                          if (uniqueKeyOfPrgAndAccId.contains(iupgmUniqueKey)) {
                                                                              iupgmUserIdSet.add(iupgm.Core_MDF_User_id__c);
                                                                          }
                                                                      }
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
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
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
}