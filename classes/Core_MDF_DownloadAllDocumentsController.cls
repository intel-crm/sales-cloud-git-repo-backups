public without sharing class Core_MDF_DownloadAllDocumentsController {
    /****************************************************************************************************** 
    Method Name:        getUserDetails
    @return  :          UserDetailsWrapper
    @parameters:        Case Id
    Description:        fetch the logged in user details and audit document list based on the case id
    Added By:           Accenture - VB       25/7/2022
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public static UserDetailsWrapper getUserDetails(Id caseId){
        UserDetailsWrapper userWrapper = new UserDetailsWrapper();
        try {
            userWrapper.isClaimCaseReviewerOrManager = checkForClaimCaseReviewerOrManager();
            userWrapper.auditDocumentList = fetchAuditDocumentsFromCase(caseId);
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        return userWrapper;
    }

    /****************************************************************************************************** 
    Method Name:        checkForClaimCaseReviewerOrManager
    @return  :          Boolean
    @parameters:        NA
    Description:        To check whether the logged in user is CCR/CCRM or not
    Added By:           Accenture - VB       25/7/2022
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static Boolean checkForClaimCaseReviewerOrManager() {
        Boolean isClaimCaseReviewerOrManager = false;
        if(FeatureManagement.checkPermission(Label.Core_MDF_ClaimCaseReviewerManager)) {
            isClaimCaseReviewerOrManager = true;
        } else {
            isClaimCaseReviewerOrManager = false;
        }
        return isClaimCaseReviewerOrManager;
    }

    /****************************************************************************************************** 
    Method Name:        fetchAuditDocumentsFromCase
    @return  :          List<Core_MDF_Audit_Document__c>
    @parameters:        Case Id
    Description:        It returns the audit document list based on the case Id
    Added By:           Accenture - VB       25/7/2022
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static List<Core_MDF_Audit_Document__c> fetchAuditDocumentsFromCase(Id caseId){
        List<Core_MDF_Audit_Document__c> auditDocList = new List<Core_MDF_Audit_Document__c>();
        auditDocList = [select Id, Core_MDF_Document_Id__c,Core_MDF_SFT_File_Download_Ind__c,Core_MDF_SFT_File_Download_URL__c from Core_MDF_Audit_Document__c where Core_MDF_Claim__r.Core_MDF_Claim_Review_Case__c =: caseId];
        return auditDocList;
    }

    //User Details Wrapper
    public class UserDetailsWrapper {
        @AuraEnabled
        public Boolean isClaimCaseReviewerOrManager{get;set;}
        @AuraEnabled
        public List<Core_MDF_Audit_Document__c> auditDocumentList{get;set;}
    }
}