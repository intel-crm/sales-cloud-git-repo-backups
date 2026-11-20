/*********************************
Class Name  : Core_MDF_ActivityPurposeBatchForReminder
Function    : Collect Ultimate Account IDs and iupgmUserId from Activity purpose object
Modification Log :
* Developer              Date          Description
* ---------------------------------------------------------------------------- 
* Rishabh Srivastava     07/07/2025    Original version
**********************************/
global class Core_MDF_ActivityPurposeBatchForReminder implements Database.Batchable<SObject>, Database.Stateful {
    
    
    
    public Set<Id> iupgmUserIdSet = new Set<Id>();
    global static Database.QueryLocator start(Database.BatchableContext context) {
        
        String query = 'SELECT Id, Name, Core_MDF_Active_Ind__c, Core_MDF_Result_Value_nbr__c, Core_MDF_Activity_Id__c, ' +
            'Core_MDF_Activity_Id__r.Core_MDF_Fund_Request_Status__c, ' +
            'Core_MDF_Activity_Id__r.ChannelPartner.Core_MDF_Channel_Program__c, ' +
            'Core_MDF_Activity_Id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, ' +
            'Core_MDF_Activity_Id__r.Core_MDF_Is_Outcome_Based_Ind__c ' +
            'FROM Core_MDF_Activity_Outcome__c ' +
            'WHERE Core_MDF_Activity_Id__r.Core_MDF_Fund_Request_Status__c = \'Closed\' ' + // store in the custom meta data
            'AND Core_MDF_Activity_Id__r.Core_MDF_Is_Outcome_Based_Ind__c = TRUE ' +
            'AND Core_MDF_Result_Value_nbr__c = null ' +
            'AND Core_MDF_Active_Ind__c = TRUE';
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<Core_MDF_Activity_Outcome__c> activityPurposeObj) {
        try {
            
            List<String> accMgrRolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Account_Manager_Roles');
            Set<Id> allowedProgramIds = new Set<Id>();//added  
            Map<Id, Set<Id>> ultimateAccountToProgramsId = new Map<Id, Set<Id>>();
            // Rishabh
            Set<Id> setOfPfrIds = new Set<Id>();
            Set<Id> setOfPfrIdsWithPaidClaim = new Set<Id>();
            Map<Id,Id> subActVsSuperActMap = new Map<Id,Id>();
            string cancelledActivtyStatus = Core_MDF_CCP_ConstantClass.PFR_CANCELLED_STATUS;
            string paidstatus=Core_MDF_CCP_ConstantClass.PAID_CLAIMS;
            
            
            for (Core_MDF_Activity_Outcome__c actpurpose : activityPurposeObj) {
                if(actpurpose.Core_MDF_Activity_Id__c != null){
                    setOfPfrIds.add(actpurpose.Core_MDF_Activity_Id__c); 
                }
            }
            if(!setOfPfrIds.isEmpty()){
                for(Partnerfundclaim pfc : [Select id,Core_MDF_Claim_Id__r.RequestId from partnerfundclaim 
                                            WHERE Core_MDF_Claim_Id__r.RequestId=:setOfPfrIds
                                            And Core_MDF_Status__c = :paidstatus]){
                                                setOfPfrIdsWithPaidClaim.add(pfc.Core_MDF_Claim_Id__r.RequestId);          
                                            }
            }
            if(!setOfPfrIdsWithPaidClaim.isEmpty()){
                for (Core_MDF_Activity_Outcome__c actpurpose : activityPurposeObj) {
                    if(actpurpose.Core_MDF_Activity_Id__c !=null && setOfPfrIdsWithPaidClaim.contains(actpurpose.Core_MDF_Activity_Id__c)){
                        // NULL SAFETY CHECKS
                        if (actpurpose.Core_MDF_Activity_Id__r == null ||
                            actpurpose.Core_MDF_Activity_Id__r.ChannelPartner == null ||
                            actpurpose.Core_MDF_Activity_Id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c == null ||
                            actpurpose.Core_MDF_Activity_Id__r.ChannelPartner.Core_MDF_Channel_Program__c == null) {
                                continue;
                            }
                        
                        Id ultimateAccountId =
                            actpurpose.Core_MDF_Activity_Id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c;
                        
                        Id programId =
                            actpurpose.Core_MDF_Activity_Id__r.ChannelPartner.Core_MDF_Channel_Program__c;
                        
                        // MAP INITIALIZATION
                        if (!ultimateAccountToProgramsId.containsKey(ultimateAccountId)) {
                            ultimateAccountToProgramsId.put(ultimateAccountId, new Set<Id>());
                        }
                        
                        // ADD PROGRAM TO ACCOUNT
                        ultimateAccountToProgramsId.get(ultimateAccountId).add(programId);
                        allowedProgramIds.add(programId);
                    }
                }
            }
            if(!ultimateAccountToProgramsId.isEmpty() && !allowedProgramIds.isEmpty()){
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Id,Core_MDF_Account_id__c,Core_MDF_User_id__c,Core_MDF_Active_Ind__c,Core_MDF_Account_id__r.Name,
                                                                       Core_MDF_User_id__r.Email,Core_MDF_Role_nm__c,Core_MDF_is_User_Active_ind__c,Core_MDF_Program_nm__c,Core_MDF_Channel_Program_id__c
                                                                       FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                       WHERE Core_MDF_Account_id__c  IN: ultimateAccountToProgramsId.keySet()
                                                                       AND Core_MDF_Role_nm__c IN:accMgrRolesList 
                                                                       AND Core_MDF_Channel_Program_id__c IN :allowedProgramIds
                                                                       AND Core_MDF_is_User_Active_ind__c = TRUE 
                                                                       AND Core_MDF_Active_Ind__c = TRUE
                                                                      ]){
                                                                          Id accountId = iupgm.Core_MDF_Account_id__c;
                                                                          Id programId = iupgm.Core_MDF_Channel_Program_id__c;
                                                                          if (ultimateAccountToProgramsId.containsKey(accountId)) {
                                                                              if (ultimateAccountToProgramsId.get(accountId).contains(programId)) {
                                                                                  iupgmUserIdSet.add(iupgm.Core_MDF_User_id__c);
                                                                              }
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
                Core_MDF_Email_NotificationLoggingBatch emailNotifyLogBatch = new Core_MDF_Email_NotificationLoggingBatch(iupgmUserIdSet,null,Core_MDF_CCP_ConstantClass.Activity_Purpose_Notification,null);
                //  custom metadata with batch size value 
                Integer batchSize = Core_MDF_CustomLabelConfig.getIntegerValues('Core_MDF_CP_NotifyLogBatchSize');
                Id batchInstanceId = Database.executeBatch(emailNotifyLogBatch,batchSize); 
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
}