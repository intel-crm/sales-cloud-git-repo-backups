/*********************************
Class Name  : Core_MDF_Outcome_Claim_Rejection_Batch
Function    : [IPA] Outcome based: Notification to RIM and Program office on repeated Claim rejections
Modification Log :
* Developer              Date          Description
* ---------------------------------------------------------------------------- 
* Akash Bawankar     20/08/2025    Original version
**********************************/
global class Core_MDF_Outcome_Claim_Rejection_Batch implements Database.Batchable<SObject>, Database.Stateful {
    
    public Set<Id> iupgmUserIdSet = new Set<Id>();
    
    global static Database.QueryLocator start(Database.BatchableContext context) {
        String programName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name');
        String status = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Pending_Acct_Mgr_Clarification');
        String latestReviewCycleNo = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_latestReviewCycleNo');

        String query = 'SELECT Id, Core_MDF_Status__c, Core_MDF_Ultimate_Account_ID__c, Core_MDF_Program__c, '
                        + 'Core_MDF_Latest_Review_Cycle_Number_nbr__c '
                        + 'FROM PartnerFundClaim '
                        + 'WHERE Core_MDF_Program__c = \'' + programName + '\' ' 
                        + 'AND Core_MDF_Status__c = \'' + status + '\' ' 
                        + 'AND Core_MDF_Latest_Review_Cycle_Number_nbr__c >= ' + latestReviewCycleNo + ' '
                        + 'AND Core_MDF_OutcomeBased_Ind__c = TRUE';
        
        return Database.getQueryLocator(query);
    }
    
global void execute(Database.BatchableContext bc, List<PartnerFundClaim> claimObj) {
    Set<String> ultimateAccountIds = new Set<String>();
    try {
        if (claimObj != null && !claimObj.isEmpty()) {
            List<String> programAdminRole = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_ProgramAdmin_Role');
            List<String> regionalAdminRole = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_RegionalAdmin_Role');
            for (PartnerFundClaim claim : claimObj) {
                String accId = claim.Core_MDF_Ultimate_Account_ID__c;
                if (String.isNotBlank(accId)) {
                    ultimateAccountIds.add(accId);
                }
            }
            for (Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Id, Core_MDF_Account_id__c, Core_MDF_User_id__c, Core_MDF_Active_Ind__c, Core_MDF_Account_id__r.Name,
                                                                    Core_MDF_User_id__r.Email, Core_MDF_Role_nm__c, Core_MDF_is_User_Active_ind__c, Core_MDF_All_Accounts_cd__c
                                                                    FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                    WHERE Core_MDF_is_User_Active_ind__c = TRUE 
                                                                    AND Core_MDF_Active_Ind__c = TRUE
                                                                    AND (
                                                                        (Core_MDF_All_Accounts_cd__c = 'Yes' AND Core_MDF_Role_nm__c IN : programAdminRole)
                                                                        OR (Core_MDF_Account_id__c IN :ultimateAccountIds AND Core_MDF_Role_nm__c IN :programAdminRole AND Core_MDF_All_Accounts_cd__c = 'No')
                                                                        OR (Core_MDF_All_Accounts_cd__c = 'Yes' AND Core_MDF_Role_nm__c IN :regionalAdminRole)
                                                                        )
                                                                ]){
                iupgmUserIdSet.add(iupgm.Core_MDF_User_id__c);
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
                Core_MDF_Email_NotificationLoggingBatch emailNotifyLogBatch = new Core_MDF_Email_NotificationLoggingBatch(iupgmUserIdSet,null,Core_MDF_CCP_ConstantClass.Outcome_Claim_Rejection_Notification,null);
                //  custom metadata with batch size value 
                Integer batchSize = Core_MDF_CustomLabelConfig.getIntegerValues('Core_MDF_CP_NotifyLogBatchSize');
                Id batchInstanceId = Database.executeBatch(emailNotifyLogBatch,batchSize); 
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
}