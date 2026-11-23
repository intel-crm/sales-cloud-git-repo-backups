public with sharing class Core_MDF_TargetSettingController {
    
    public class CustomException extends Exception{}
    
    @AuraEnabled (cacheable=true)
    Public static List<Core_MDF_Target_Setting_Line_Item__c> getLineItemRecords ( String recordId) {
        try {
            List<Core_MDF_Target_Setting_Line_Item__c> lineItemRecordList = new List<Core_MDF_Target_Setting_Line_Item__c> ([ SELECT Id, Name, Core_MDF_Account__r.Name, Core_MDF_Account__r.Core_MDF_Active_Ind__c, Core_MDF_Priority_nm__c, Core_MDF_Priority_Percentage__c,
                                                                       Core_MDF_Bucket_nm__c,Core_MDF_Budget_Type_nm__c, Core_MDF_Country_Name_nm__c,Core_MDF_Campaign_Id__c,Core_MDF_Campaign_Id__r.Name,  Core_MDF_Region_Name_nm__c, Core_MDF_Amount__c, 
                                                                       Core_MDF_Campaign_Name__c, Core_MDF_Focus_Area_nm__c, RecordTypeId, RecordType.DeveloperName 
                                                                       FROM Core_MDF_Target_Setting_Line_Item__c
                                                                       WHERE Core_MDF_Spending_Targets_Version__c =: recordId ]);
            return lineItemRecordList;
        }
        catch ( Exception e ){
            Core_MDF_CCP_UtilityClass.logError ( e );
            throw new AuraHandledException ( e.getMessage() );
        }
    }
    @AuraEnabled
    public static void updateCampaignIdtoSTLI(List<Id> selectedLineItmIdList, Id campaignId){
        try {
            System.debug('@@selectedLineItmIdList->'+selectedLineItmIdList);
            System.debug('@@campaignId->'+campaignId);
            if (!selectedLineItmIdList.isEmpty()) {
                List<Core_MDF_Target_Setting_Line_Item__c> TargetLineItemToUpdateList = new List<Core_MDF_Target_Setting_Line_Item__c>();
                
                // Collect records to be updated in a list
                for (Id selectedLineItm : selectedLineItmIdList) {
                    Core_MDF_Target_Setting_Line_Item__c TargetLineItm = new Core_MDF_Target_Setting_Line_Item__c();
                    TargetLineItm.Id = selectedLineItm;
                    TargetLineItm.Core_MDF_Campaign_Id__c = campaignId;
                    TargetLineItemToUpdateList.add(TargetLineItm);
                }
            
                System.debug('@@TargetLineItemToUpdateList->' + TargetLineItemToUpdateList);
            
                // Update all records in a single DML statement
                if (!TargetLineItemToUpdateList.isEmpty()) {
                    Database.update(TargetLineItemToUpdateList);
                }
            }
        } catch (Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    @AuraEnabled
    public static UserPermissionAccesss checkLoggedInUserhasAccess(String channelProgram){
    // Highlight: Unused Local Variable - 14285 
    // List<PermissionSetAssignment> permissionSetsAssigned = new List<PermissionSetAssignment>();
    UserPermissionAccesss userPermission = new UserPermissionAccesss();
        
        List<String> permissionsetList = new List<String>();
        
        if(channelProgram == Core_MDF_CCP_ConstantClass.CCF_PROGRAM){
            permissionsetList.add(Core_MDF_CCP_ConstantClass.CCF_Internal_Acct_Mgr);
        }
        if(channelProgram == Core_MDF_CCP_ConstantClass.DCF_PROGRAM){
            permissionsetList.add(Core_MDF_CCP_ConstantClass.DCF_Internal_Acct_Mgr);
        }
        
        
        if(!permissionsetList.isEmpty()){
            userPermission.isCreateCampaignButtonAccess = Core_MDF_PaymentRunAccounts.checkLoggedInUserhasReqdRole(permissionsetList);   
        }
        Schema.DescribeSObjectResult targetSettingSObj = Schema.sObjectType.Core_MDF_Target_Setting_Line_Item__c;
    userPermission.isNewButtonAccess = targetSettingSObj.isCreateable();
        userPermission.isEditAccess = targetSettingSObj.isUpdateable();
        
    return userPermission;
    }
    
    public class UserPermissionAccesss{
        @AuraEnabled
        public Boolean isNewButtonAccess = false;
        @AuraEnabled
        public Boolean isEditAccess = false;
        @AuraEnabled
        public Boolean isCreateCampaignButtonAccess = false;
    }
  
    
    
    /* Method to Create a new version and clone the Line Items associated to the previous version on the new version */
    @Invocablemethod(label='Get Comments entered by user for Version')
    public static void createVersionRecord (List<flowParametersWrapper> flowParameters){
        
        try{
            
            String comment = flowParameters[0].userComment;
            Id recordId = flowParameters[0].SpendingTargetRecordId;
            Double versionNumber;
            Id oldVersionId;
            List<Core_MDF_Target_Setting_Line_Item__c> lineItemsList = new List<Core_MDF_Target_Setting_Line_Item__c>();

            List<Core_MDF_Target_Setting_Line_Item__c> lineItemRecordList = new List<Core_MDF_Target_Setting_Line_Item__c> ([SELECT Id, Core_MDF_Spending_Targets_Version__c, Core_MDF_Budget_Type_nm__c, Core_MDF_Account__c, 
                                                                        Core_MDF_Priority_nm__c, Core_MDF_Priority_Percentage__c, Core_MDF_Bucket_nm__c, Core_MDF_Country_Name_nm__c,Core_MDF_Campaign_Id__c,
                                                                        Core_MDF_Campaign_Name__c, Core_MDF_Amount__c, Core_MDF_Region_Name_nm__c, Core_MDF_Focus_Area_nm__c, Core_MDF_All_Accounts_nm__c,
                                                                        RecordTypeId, Core_MDF_Spending_Targets_Version__r.Core_MDF_Is_Active_Ind__c, Core_MDF_Spending_Targets_Version__r.Core_MDF_Version_nbr__c                                                               
                                                                        FROM Core_MDF_Target_Setting_Line_Item__c
                                                                        WHERE Core_MDF_Spending_Targets_Version__r.Core_MDF_Spending_Targets__c =: recordId
                                                                        AND Core_MDF_Spending_Targets_Version__r.Core_MDF_Is_Active_Ind__c = TRUE]);

            if(!lineItemRecordList.isEmpty()){
                versionNumber = lineItemRecordList[0].Core_MDF_Spending_Targets_Version__r.Core_MDF_Version_nbr__c;
                oldVersionId = lineItemRecordList[0].Core_MDF_Spending_Targets_Version__c;
            }

            Core_MDF_Spending_Targets_Version__c versionRecord = new Core_MDF_Spending_Targets_Version__c();
            versionRecord.Core_MDF_Comments_txt__c = comment;
            versionRecord.Core_MDF_Spending_Targets__c = recordId;
            versionRecord.Core_MDF_Version_nbr__c = versionNumber + 1;
            versionRecord.Core_MDF_Is_Active_Ind__c = TRUE;
            Insert versionRecord;

            Core_MDF_Spending_Targets_Version__c oldVersionRecord = new Core_MDF_Spending_Targets_Version__c();
            oldVersionRecord.Core_MDF_Is_Active_Ind__c = FALSE;
            oldVersionRecord.Id = oldVersionId != null ? oldVersionId : '';
            Update oldVersionRecord;

            for( Core_MDF_Target_Setting_Line_Item__c lineItemRecords : lineItemRecordList){
                Core_MDF_Target_Setting_Line_Item__c cloneLineItem = lineItemRecords.clone(); // Cloning the existing Line Items
                cloneLineItem.Core_MDF_Spending_Targets_Version__c = versionRecord.Id;  
                lineItemsList.add(cloneLineItem);
            }
            insert lineItemsList;
        }
        catch ( Exception e ){
            Core_MDF_CCP_UtilityClass.logError ( e );
            throw new CustomException(Label.Core_MDF_ApplicationErrorMessage);
        }
    }
    
    /***************************************************************************************************** 
Method Name   :        validateUserRegion (Method called from LWC)
@return       :        boolean
@parameters   :        recordId, country
Description   :        validate user region access based on IUPGM while creating/editing Line Item record
Added By      :        Leela   06-10-2024
Modified By   :        Date:           Changes: 

******************************************************************************************************/
    @AuraEnabled
    Public Static boolean validateUserRegion(Id recordId, String country){        
    return Core_MDF_Target_Setting_Utility.getvalidateUserRegion(recordId, country);
    }
    
    public class flowParametersWrapper{
        @InvocableVariable(label='Comments')
        public string userComment;
        
        @InvocableVariable(label='RecordId')
        public Id SpendingTargetRecordId;
    }
}