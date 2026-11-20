/************************************************************************************
 class Name         : Core_MDF_Campaign_QuickActionController
 Test Class Name    : Core_MDF_Campaign_QuickActionCtrlTest
 Change History:
---------------------------------------------------------------------------------------
 #CH    Changes By       Date           Change Description
--------------------------------------------------------------------------------------
  1.    Anish            09/7/2021      Added changes for IPA 
************************************************************************************/

public without sharing class Core_MDF_Campaign_QuickActionController {
    public static String CMP_CCF_RECORDTYPE = 'Core_MDF_Client_CoMarketing_Fund';
    public static String CMP_DCF_RECORDTYPE = 'Core_MDF_Data_Center_CoMarketing_Fund';
    public static String CMP_IPA_RECORDTYPE = Core_MDF_CCP_ConstantClass.CMP_IPA_RECORDTYPE;
    public static String CMP_SPCMP_RECORDTYPE = Core_MDF_CCP_ConstantClass.CMP_SPCMP_RECORDTYPE;
    public static String CMP_CCFB_RECORDTYPE = Core_MDF_CCP_ConstantClass.CMP_CCFB_RECORDTYPE;
    public static String CMP_RMF_RECORDTYPE = Core_MDF_CCP_ConstantClass.CMP_RMF_RECORDTYPE;
    public static String CMP_EEF_RECORDTYPE = Core_MDF_CCP_ConstantClass.CMP_EEF_RECORDTYPE;
    public static string CMP_CO_GTM_RECORDTYPE = Core_MDF_CCP_ConstantClass.CMP_CO_GTM_RECORDTYPE;
    /****************************************************************
     * Method Name      : loadCampaignRecord
     * Input Paramaters : recordId - camapign recordId
     * Return Result    : Campaign
     * Description      :This method return the camapigndata for input 
     *                    camapign Id
    *****************************************************************/
    @AuraEnabled
    public static Campaign loadCampaignRecord(String recordId) {
        String sanitiziedCampaignId = String.escapeSingleQuotes(recordId);
        String sQuery = 'SELECT Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName, Status,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Market__c,Core_MDF_Claims_Created_Ind__c,Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Account__r.Core_MDF_Active_Ind__c ';
        sQuery += ' FROM Campaign WHERE Id =:sanitiziedCampaignId ';
        Campaign recordObj = Database.query(sQuery);
        return recordObj;
    }
    /*@AuraEnabled
    public static RecordType loadIPARecTypeInfo() {
       List<RecordType> recordObj = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType='Campaign' and name='Intel Partner Alliance'];
       return recordObj[0];
    }*/
    
    @AuraEnabled
    public static Campaign loadRecTypeInfo(Id RecordId) {
        Campaign recordObj =  [SELECT Id, Name, Core_MDF_Account__c, Core_MDF_Account__r.Name, Core_MDF_Budget_Type_txt__c,Core_MDF_Opal_Budget_Type_Txt__c,RecordType.Id,RecordType.Name,RecordType.DeveloperName,
                                 tolabel(Campaign.Core_MDF_Opal_Budget_Type_Txt__c) localizedBudType, Core_MDF_Priority__c, Core_MDF_Priority_2_nm__c, Core_MDF_Priority_3_nm__c, Core_MDF_Channel_Program__c,Core_MDF_Budget_Cap__c,
                                 Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Technology__c, Status, Core_MDF_Market__c, Core_MDF_Reimbursement_Rate__c,Core_MDF_Available_BudgetCap_amt__c,Core_MDF_Reimbursement_Amount_Amt__c,Core_MDF_Proposal_Based_Ind__c
                                 FROM Campaign WHERE Id=:RecordId];
        return recordObj;   
    }
    
    @AuraEnabled
    public static String getRtFieldSetMappings(String objectName, String recordTypeDeveloperName){            
        
        //Metadata disposition - changed text field references to picklist fields
        return [SELECT Core_MDF_Field_Set_API_Name_nm__c FROM Core_MDF_RecordType_FieldSet_Mapping__mdt WHERE Core_MDF_Object_API_Name_nm__c = :objectName AND Core_MDF_Record_Type_DeveloperName_nm__c = :recordTypeDeveloperName].Core_MDF_Field_Set_API_Name_nm__c;   
    } 
    
    @AuraEnabled
    public static Boolean checkForCloneAccess(String recordTypeDeveloperName, String campaignStatus) {
            Boolean hasCloneAccess = (((recordTypeDeveloperName == CMP_IPA_RECORDTYPE) && ((FeatureManagement.checkPermission('Core_MDF_CCP_Internal_IPA_Acct_Mgr')|| 
                                 FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Proposal_Manager'))))|| 
                                 ((recordTypeDeveloperName == CMP_CCF_RECORDTYPE) && FeatureManagement.checkPermission('Core_MDF_CCP_Internal_CCF_Acct_Mgr') && campaignStatus != 'Draft') ||
                                 ((recordTypeDeveloperName == CMP_DCF_RECORDTYPE) && FeatureManagement.checkPermission('Core_MDF_CCP_Internal_DCF_Acct_Mgr') && campaignStatus != 'Draft') ||
                                 ((recordTypeDeveloperName == CMP_RMF_RECORDTYPE) && FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Account_Manager')) ||
                                 ((recordTypeDeveloperName == CMP_EEF_RECORDTYPE) && (FeatureManagement.checkPermission('Core_MDF_CCP_Internal_EEF_Primary_Account_Manager'))) ||
                                 ((recordTypeDeveloperName == CMP_CO_GTM_RECORDTYPE) && (FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Co_GTM_Account_Manager') ||
                                 FeatureManagement.checkPermission('Core_MDF_CCP_External_Co_GTM_Project_Submitter')))
                                 ) ? true : false; 
       return hasCloneAccess;
        
    }
    
    @AuraEnabled
    public static Boolean checkForEditAccess(String objectName, String recTypeDevloperName, String status, Id campaignId, Boolean proposalBasedIndicator,Boolean claimAssociatedIndicator) {
        List<String> editableFieldsList = new List<String>();
        Boolean hasRecAndFieldEditAccess = false; 
        Boolean hasRecordEditAccess = true;  
        
        try {
        //Check whether user has edit access for the record
        if(recTypeDevloperName == Label.Core_MDF_EEF_RecordType) {
            hasRecordEditAccess = Core_MDF_checkSObjectCRUDPermission.checkRecordEditAccess(campaignId);
        }        
        //Check Whether user has field access
        editableFieldsList = Core_MDF_CampaignCreatePage.getFieldEditibilityMapping(objectName, recTypeDevloperName, status, campaignId, proposalBasedIndicator, claimAssociatedIndicator);
        if(hasRecordEditAccess && editableFieldsList != null && !editableFieldsList.isEmpty() && editableFieldsList.size() > 0 && (status !='Cancelled'|| recTypeDevloperName == CMP_CO_GTM_RECORDTYPE)) {
            hasRecAndFieldEditAccess = true;
        } 
        } catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }       
        return hasRecAndFieldEditAccess;
    }
    
    @AuraEnabled
    public static Boolean checkSObjectEditPermission(String objectName){
        return Core_MDF_checkSObjectCRUDPermission.checkSObjectEditPermission(objectName);
    }
    
    @AuraEnabled
    public static Boolean isCommunity(){
        Id siteId = Site.getSiteId();
        if (siteId != null) {
            return true;
        }
        return false;
    }
    /****************************************************************
     * Method Name      : loadPFRRecords
     * Input Paramaters : campId - campaign recordId
     * Return Result    : All activity associated to the campaign
     * Description      : Fetches all the activity associated to campaign for IPA Clone Proposal
     * UserStory        : US1082878 - [IPA MDF] - Campaign - Clone a Proposal - Apex class framwork development
    *****************************************************************/
     @AuraEnabled
     public static  Core_MDF_ResponseHandler loadPFRRecords(String campId, String mode){
         String pfrCancelledStatus = Core_MDF_CCP_ConstantClass.PFR_CANCELLED_STATUS;
         String campaignId = String.escapeSingleQuotes(campId);
         Core_MDF_ResponseHandler result;
         Set<String> sQueryfields = new Set<String>();
          Boolean isSuccess= true;
         String responseMessage='No Activity Records to Load';
         String sQuery='SELECT ';
         for(Schema.FieldSetMember f : Schema.SObjectType.PartnerFundRequest.FieldSets.Core_MDF_Activity_FieldList.getFields()) {
             sQueryfields.add(f.getFieldPath()); 

         }
         for(String fs : sQueryfields){
             sQuery += fs + ',';
         }
       
          sQuery += 'ChannelPartner.Core_MDF_Virtual_Corp_Account_Id__c, Campaign.Name,Campaign.StartDate, Campaign.EndDate,RecordType.Name,RecordType.DeveloperName,Id, tolabel(Campaign.Core_MDF_Opal_Budget_Type_Txt__c) localizedBudType,Campaign.Core_MDF_Proposal_Based_Ind__c,Campaign.Core_MDF_IPA_Priority_nm__c,Campaign.Core_MDF_Industry_Nm__c,Campaign.Core_MDF_Product_Type__c,Campaign.Core_MDF_Ecosystem_Partner_Nm__c,Campaign.Core_MDF_Brand__c,Campaign.Core_MDF_Audience__c,Campaign.Core_MDF_Initiative_nm__c,Campaign.Core_MDF_Focus_Area_nm__c,Core_MDF_Activity_Reimbursement_Amt_nbr__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,ChannelPartner.Core_MDF_Channel_Program__c, Campaign.Core_MDF_Market__c, Campaign.Core_MDF_Reimbursement_Rate__c,Campaign.Core_MDF_ReimbursementRate_pct__c,Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__r.name,Campaign.Core_MDF_Opal_Budget_Type_Txt__c,Budget.StartDate,Budget.EndDate, Campaign.Core_MDF_CampOutcomeOpt_In_Ind__c FROM PartnerFundRequest WHERE CampaignId =:campaignId ';
          //TWC3117-7922 [IPA] - [Proposal Based] - Don't clone Cancelled activity
          if(mode == 'clone') {
            sQuery += ' and Core_MDF_Fund_Request_Status__c!=:pfrCancelledStatus ';
          }

          if(mode == 'edit') {
             List<string> excludedActivityStatuses = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Excluded_Activity_Statuses').split(',');
             List<string> excludedActivityClosureTypes = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Excluded_Act_Closure_Types').split(',');
             String excludedActivityStatusesStr;
             String excludedActivityClosureTypesStr;
             if(!excludedActivityStatuses.isEmpty()){
                 excludedActivityStatusesStr ='(\'' + String.join(excludedActivityStatuses, '\', \'') + '\')';
             }
             if(!excludedActivityClosureTypes.isEmpty()){
                 excludedActivityClosureTypesStr ='(\'' + String.join(excludedActivityClosureTypes, '\', \'') + '\')';
             }
             sQuery +='and Core_MDF_Fund_Request_Status__c NOT IN '+excludedActivityStatusesStr+' and Core_MDF_Activity_Closure_Type__c NOT IN '+excludedActivityClosureTypesStr;
         }
         List<PartnerFundRequest> pfrRecord;
             pfrRecord = Database.query(sQuery);
             if(pfrRecord != null && !pfrRecord.isEmpty()){
                  isSuccess = true;
                 responseMessage = 'Success';
                 result = new Core_MDF_ResponseHandler(isSuccess,responseMessage,pfrRecord);
             }else{
                  isSuccess = false;
                 result = new Core_MDF_ResponseHandler(isSuccess,responseMessage,pfrRecord); 
             }
         return result;
     }
    
    @AuraEnabled
    public static Boolean isUserIPAExtUser(){
        Boolean externalIPAUsr = false;
        externalIPAUsr = FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Proposal_Manager');
        return externalIPAUsr;
    }
    
     @AuraEnabled
    public static Map<String,Object> customPicklistFetcher(String recordTypeName){ 
        String rec = recordTypeName;
        return Core_Intel_customPicklistController.customPicklistFetcher(rec);
        
    }
}