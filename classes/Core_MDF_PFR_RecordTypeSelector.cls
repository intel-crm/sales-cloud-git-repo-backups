/*****Core_************************************************************************************************ 
Class Name :    Core_MDF_PFR_RecordTypeSelector
Description:    Server side controller for Core_MDF_PFR_RecordTypeSelector component
Added By   :    Accenture - AS 
Modified By:                      Date:07/25/2018                     Changes:None  
******************************************************************************************************/
public with sharing class Core_MDF_PFR_RecordTypeSelector {
    public static Map<String, String> newrecordtypemapdevname;
    public static Map<String, Id> newrecordtypemap;
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public static List<String> restrictedRecTypesList = Label.Core_MDF_LegacyRestrictedRecordTypes.split(',');
/***************************************************************************************************** 
Method Name :   fetchRecordTypeValues Map(RecordTypeDeveloperName , RecordTypeLabelName)
Added By   :    Accenture - SS 
Modified By:                      Date:10/25/2018                     Changes:None  
******************************************************************************************************/
    @AuraEnabled
    public static Map<String, String> fetchRecordTypeValues(String objectName){
        List<Schema.RecordTypeInfo> recordtypes = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfos();
        newrecordtypemapdevname = new Map<String, String>();
        for(RecordTypeInfo rt : recordtypes){
            if( rt.isMaster() == false && rt.getName().trim() != '' &&  rt.isAvailable() && rt.isActive() && !restrictedRecTypesList.contains(rt.getDeveloperName())){  //&& rt.getDeveloperName() != label.Core_MDF_Intel_MDF_Account_Based && rt.getDeveloperName() != label.Core_MDF_Intel_MDF_Proposal_Based //rt.getName() != label.Core_MDF_Master 
                  newrecordtypemapdevname.put(rt.getDeveloperName(), rt.getName());
            }    
        }
        return newrecordtypemapdevname;
    }
/***************************************************************************************************** 
Method Name :   fetchRecordTypeValues_string_id // map(RecordTypeDeveloperName , RecordTypeId)
Added By   :    Accenture - SS 
Modified By:                      Date:10/25/2018                     Changes:None  
******************************************************************************************************/
    @AuraEnabled
    public static Map<String, Id> fetchRecordTypeValues_string_id(String objectName){
        List<Schema.RecordTypeInfo> recordtypes = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfos();
        newrecordtypemap = new Map<String, Id>();
        for(RecordTypeInfo rt : recordtypes){
            if( rt.isMaster() == false && rt.getName().trim() != '' &&  rt.isAvailable() && rt.isActive() && !restrictedRecTypesList.contains(rt.getDeveloperName())){ //&& rt.getDeveloperName() != label.Core_MDF_Intel_MDF_Account_Based && rt.getDeveloperName() != label.Core_MDF_Intel_MDF_Proposal_Based //rt.getName() != label.Core_MDF_Master
                  newrecordtypemap.put( rt.getDeveloperName() , rt.getRecordTypeId());
            }    
        }
        return newrecordtypemap;
    }
/***************************************************************************************************** 
Method Name :   fetchRecordType // Wrapper(Map(String, String) , Map(String,Id))
Added By   :    Accenture - SS 
Modified By:                      Date:10/25/2018                     Changes:None  
******************************************************************************************************/
    @AuraEnabled
    public static recordTypeWrapper fetchRecordType(String objectName) {
        String objName = objectName;
        recordTypeWrapper recTypeInst = new recordTypeWrapper();
        recTypeInst.recordTypeDevNameAndLabelName = fetchRecordTypeValues(objName);
        recTypeInst.recordTypeDevNameAndId = fetchRecordTypeValues_string_id(objName);        
        return recTypeInst;
    }
    /****************************************************************************************************** 
Method Name:        getCampaign
@return  :          Campaign object
@parameters:        Campaign record ID
Description:        This method is used to fetch record based on campaign ID.
Added By:           
Modified By:        Date:      Changes: 
Ganapati        26/06/2020      US700986: [Tech] - [IPA] Hide Country/Region field in Activity form layout - Added Core_MDF_Market__c field into the query
Accenture NZ	09/07/2021		US946761 [IPA - Budget CAP]  - [OOC - P8] - Internal Account Manager/External - Validation Reimbursement Amount against Budget CAP - Added Core_MDF_Available_BudgetCap_amt__c in the query
*******************************************************************************************************/
@AuraEnabled
public static Campaign getCampaignFields(Id recordId){
    
    try{
        Campaign campObj = [SELECT Id, Name, Core_MDF_Account__c, Core_MDF_Account__r.Name,Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Budget_Type_txt__c,Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Brand__c,Core_MDF_Industry_Nm__c,Core_MDF_Initiative_nm__c,Core_MDF_Ecosystem_Partner_Nm__c,Core_MDF_Focus_Area_nm__c,Core_MDF_Audience__c,Core_MDF_Product_Type__c,Core_MDF_IPA_Priority_nm__c,
                                 tolabel(Campaign.Core_MDF_Opal_Budget_Type_Txt__c) localizedBudType, Core_MDF_Priority__c, Core_MDF_Priority_2_nm__c, Core_MDF_Priority_3_nm__c, Core_MDF_Channel_Program__c,Core_MDF_Budget_Cap__c,Core_MDF_Program__c,StartDate,EndDate,RecordTypeId,RecordType.DeveloperName,RecordType.Name,
                                 Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Channel_Program__r.Name, Core_MDF_Technology__c, Status, Core_MDF_Market__c, Core_MDF_Reimbursement_Rate__c,Core_MDF_ReimbursementRate_pct__c,Core_MDF_Available_BudgetCap_amt__c,Core_MDF_Reimbursement_Amount_Amt__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Strategic_Marketing_Fund_Ind__c, Core_MDF_Activity_Category_Type__c, Core_MDF_Activity_Category__c
                                 FROM Campaign WHERE Id=:recordId LIMIT 1];
        
        if(campObj != null){
            return campObj;
        }
        else{return null;}}catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e); return null; }
}

/***************************************************************************************************** 
Method Name :	checkSObjectCreatePermission
Added By   :    Accenture - HA
Modified By:                      Date:                    Changes:None  
*******************************************************************************************************/
    @AuraEnabled
    public static Boolean checkSObjectCreatePermission(String objectName){
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(objectName);
		Schema.DescribeSObjectResult obj = sobjType.getDescribe();
        Boolean checkCreate = obj.createable;
       	return checkCreate;
    }
/***************************************************************************************************** 
Method Name :	getRtFieldSetMappings
Added By   :    Accenture
Modified By:                      Date:                    Changes:None  
*******************************************************************************************************/
   
    @AuraEnabled
    public static List<Core_MDF_RecordType_FieldSet_Mapping__mdt> getRtFieldSetMappings(String objectName, String pickListObj, String executionContext){
        String objectNameStr =  String.escapeSingleQuotes(objectName);
        
	//Metadata disposition - changed text field references to picklist fields
        return [SELECT Core_MDF_Record_Type_DeveloperName_nm__c, Core_MDF_Field_Set_API_Name_nm__c FROM Core_MDF_RecordType_FieldSet_Mapping__mdt WHERE Core_MDF_Object_API_Name_nm__c =:pickListObj and Core_MDF_Current_Object_nm__c =:objectNameStr and Core_MDF_Execution_Context_nm__c =:executionContext];
    }
    
/***************************************************************************************************** 
Method Name :	getRtBudTypeFieldSetMappings
Added By   :    Accenture
Modified By:                      Date:                    Changes:None  
*******************************************************************************************************/
    @AuraEnabled
    public static List<Core_MDF_RecordType_FieldSet_Mapping__mdt> getRtBudTypeFieldSetMappings(String objectName, string budType){
        
       	//Metadata disposition - changed text field references to picklist fields
        return [SELECT Core_MDF_Record_Type_DeveloperName_nm__c, Core_MDF_Field_Set_API_Name_nm__c,Core_MDF_Budget_Type_nm__c FROM Core_MDF_RecordType_FieldSet_Mapping__mdt WHERE Core_MDF_Object_API_Name_nm__c =:objectName and Core_MDF_Budget_Type_nm__c =: budType];
    }    
/***************************************************************************************************** 
Method Name :   recordTypeWrapper (Created a Wrapper to reduce the server side call)
Added By   :    Accenture - SS 
Modified By:                      Date:10/25/2018                     Changes:None  
******************************************************************************************************/

    public class recordTypeWrapper
    {   @AuraEnabled   
        public Map<String, String> recordTypeDevNameAndLabelName  ; 
        @AuraEnabled
        public Map<String, Id> recordTypeDevNameAndId;
    }
    
    public static Boolean isCustomPermissionAssigned(String customPermissionNameStr){
        return String.isNotBlank(customPermissionNameStr) ? FeatureManagement.checkPermission(customPermissionNameStr) : false;
    }
    
    @AuraEnabled
    public static UserPermissionSetWrapper userHasPermissionSet(Map<String,List<String>> permissionsets){
        UserPermissionSetWrapper usrprmissionWrapper = new UserPermissionSetWrapper();
        try{
       
        Map<String,boolean> userPermissions = new Map<String,boolean>();
        List<PermissionSetAssignment> userPerSets = new List<PermissionSetAssignment>();
        for(String perKey : permissionsets.keySet())
        {
            for(String customPermissionStr : permissionsets.get(perKey))
            {
                if(isCustomPermissionAssigned(customPermissionStr) && !userPermissions.containsKey(perKey)){
                     
                    userPermissions.put(perKey,true);
                }
            }
            if (!userPermissions.containsKey(perKey))
            {
                userPermissions.put(perKey,false);
            }

        }
        if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_isActivityReviewRequired') &&
           mapFunctionalityNameTriggerExecution.get('Core_MDF_isActivityReviewRequired').Core_Active__c){ usrprmissionWrapper.isActivityReviewRequired = true; }
        usrprmissionWrapper.userPermissions = userPermissions;
        
        }catch(Exception ex){
	    //Avoid empty catch blocks
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
         return usrprmissionWrapper; 
    }
    
    public class UserPermissionSetWrapper{
        @AuraEnabled   
        public Map<String,boolean> userPermissions;
        @AuraEnabled
        public Boolean isActivityReviewRequired;
    }


}