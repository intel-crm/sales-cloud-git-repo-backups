/* Class Name : Core_MDF_CampaignCreatePage
* Test class : Core_MDF_CampaignCreatePageTest
*/ 

public without sharing class Core_MDF_CampaignCreatePage {
    
    Public static string TYPE_CLAIM = Core_MDF_CCP_ConstantClass.TYPE_CLAIM;
    Public static string ESC_APPROVED_STATUS = Core_MDF_CCP_ConstantClass.ESC_APPROVED_STATUS;
    public static string EEF_PROGRAM = Core_MDF_CCP_ConstantClass.EEF_PROGRAM;
    public static string ActPartner_RR_Pct = Core_MDF_CCP_ConstantClass.ActPartner_RR_Pct;
    public static String EEF_Primary_Partner_Account_Manager = Core_MDF_CCP_ConstantClass.EEF_Primary_Partner_Account_Manager;
    //added by JK to replace prime id with UCD id field
    public static boolean isUnifiedIdEnabled = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_UnifiedIdCheck');
    public static List<Core_MDF_BudgetType_Benefit_Mappings__c> budgetTypeBenefitMapping = new List<Core_MDF_BudgetType_Benefit_Mappings__c>();
    
    public static String objectApiName = 'Core_MDF_BudgetType_Benefit_Mappings__c';
    public static String Proposal_based_Indicator = Core_MDF_CCP_ConstantClass.Proposal_based_Indicator;
    public static String Account_based_Indicator = Core_MDF_CCP_ConstantClass.Account_based_Indicator;
    public static primPartIUPGMAccWrapper getIUPGMAccounts(){       
        primPartIUPGMAccWrapper primPartAccWrp = new primPartIUPGMAccWrapper();
        //String iupgmQuery = 'Select id,name,Core_MDF_Account_id__c, Core_MDF_Account_id__r.name,Core_MDF_All_Accounts_cd__c,Core_MDF_Active_Ind__c from Core_MDF_Int_Users_Partner_Geo_Mapping__c where Core_MDF_Role_nm__c = :EEF_Primary_Partner_Account_Manager and Core_MDF_Active_Ind__c = true'; //TWC3117-16123
        //String userId = String.valueOf(UserInfo.getUserId()); //TWC3117-16123
        //iupgmQuery+=' and Core_MDF_User_id__c = :userId'; //TWC3117-16123
        boolean allAccountflag = false;
        //List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = database.query(iupgmQuery); //TWC3117-16123
        List<Id> accountList = new List<Id>();
        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm:[Select id,name,Core_MDF_Account_id__c, Core_MDF_Account_id__r.name,Core_MDF_All_Accounts_cd__c,Core_MDF_Active_Ind__c from Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                            where Core_MDF_Role_nm__c = :EEF_Primary_Partner_Account_Manager and Core_MDF_Active_Ind__c = true and Core_MDF_User_id__c = :UserInfo.getUserId()]){
            if(iupgm.Core_MDF_All_Accounts_cd__c == 'Yes'){
                allAccountflag = true;  
                break;
            }
            else{
                accountList.add(iupgm.Core_MDF_Account_id__c);
            }
        }
        primPartAccWrp.allAccountsFlag = allAccountflag;
        if(!allAccountflag){
            primPartAccWrp.iupgmUltimateAccountIds = accountList;
        }
        return primPartAccWrp;     
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, string myObject, String filter, Boolean bypassSharing) {
        if(bypassSharing){
            return getSearch(searchTerm,myObject,filter);
        }else{
            Core_MDF_Generic_With_Sharing_Utility searchAcc = new Core_MDF_Generic_With_Sharing_Utility();
            return searchAcc.getSearch(searchTerm,myObject,filter); 
        }      
    }
    public with sharing class Core_MDF_Generic_With_Sharing_Utility{
        public List<sObject> getSearch(String searchTerm, string myObject, String filter) {
            List<String> bypassProfileIds = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Camp_Bypass_ProfileIds').split(',');
            String usrProfileId = (String)userinfo.getProfileid();
            if(filter.contains(EEF_PROGRAM) && !bypassProfileIds.contains(usrProfileId)){
                primPartIUPGMAccWrapper primPartAccWrp = new primPartIUPGMAccWrapper();
                List<Id> iupgmUltimateAccIds = new List<Id>();
                primPartAccWrp = getIUPGMAccounts();
                if(primPartAccWrp.allAccountsFlag == false && primPartAccWrp.iupgmUltimateAccountIds !=null){
                        iupgmUltimateAccIds = primPartAccWrp.iupgmUltimateAccountIds;
                        filter+=' and Core_MDF_Parent_Fund_Account__c in :iupgmUltimateAccIds';
                }
            }
            String myQuery = null;
            String sanitizedMyObj = String.escapeSingleQuotes(myObject);
            String searchTrm = String.escapeSingleQuotes(searchTerm);
            String filt = String.escapeSingleQuotes(filter);
            filt = filt.replaceAll('\\\\','');
            if(filter != null && filter != ''){
                myQuery = 'SELECT Id, Name, Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Virtual_Corp_Account_Id__c,Core_MDF_Channel_Program__c  FROM '+sanitizedMyObj+' WHERE Name LIKE  \'%' + searchTrm + '%\' AND '+filt+' LIMIT  10';
            }
            List<sObject> lookUpList = database.query(myQuery);
            return lookUpList;
        }
    }

    public static List<sObject> getSearch(String searchTerm, string myObject, String filter) {
        // Validate inputs
 
        if (searchTerm == null || searchTerm.trim() == '' || myObject == null || myObject.trim() == '') {
            return new List<sObject>();
        }
        
        
        String myQuery = null;
        String sanitizedMyObj = String.escapeSingleQuotes(myObject);
        String searchTrm = String.escapeSingleQuotes(searchTerm);
        String filt = String.escapeSingleQuotes(filter);
        filt = filt.replaceAll('\\\\','');
        if(filter != null && filter != ''){
            myQuery = 'SELECT Id, Name FROM '+sanitizedMyObj+' WHERE Name LIKE  \'%' + searchTrm + '%\' AND '+filt+' LIMIT  10';
        }
        
        // Ensure query is not null before executing
        if (myQuery != null) {
            List<sObject> lookUpList = database.query(myQuery);
            return lookUpList;
        } else {
            return new List<sObject>();
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<sObject> searchParentAcc(String searchTerm, string myObject, String filter) {
        String myQuery = null;
        String sanitizedMyObjt = String.escapeSingleQuotes(myObject);
        String filtr = String.escapeSingleQuotes(filter);
        String schTerm = String.escapeSingleQuotes(searchTerm);
        filtr = filtr.replaceAll('\\\\','');
        if(filter != null && filter != ''){
            myQuery = 'SELECT Core_MDF_Parent_Fund_Account__r.Id, Core_MDF_Parent_Fund_Account__r.Name FROM '+sanitizedMyObjt+' WHERE Core_MDF_Parent_Fund_Account__r.Name LIKE  \'%' + schTerm + '%\' AND '+filtr+' ORDER BY Core_MDF_Parent_Fund_Account__r.Name ASC LIMIT  10';
        }
        List<Account> lookUpList = database.query(myQuery);
        Map<String,Account> parentAccMap = new Map<String,Account>();
        for(Account acc:lookUpList){
            parentAccMap.put(acc.Core_MDF_Parent_Fund_Account__r.Id,acc);
        }
        return parentAccMap.values();
    }
    
    @AuraEnabled
    public  static Map<String,List<String>> geoToCountryMappingValueConnectedCallBack(){
        List<Core_MDF_CCP_Country_Geo_Mapping__mdt> cList= [select id,Core_MDF_Code_2_Digits__c, Core_MDF_Geo__c, Core_MDF_Sub_Geo__c, DeveloperName,MasterLabel,Core_MDF_Blocked_in_UI_ind__c from Core_MDF_CCP_Country_Geo_Mapping__mdt where Core_MDF_Blocked_in_UI_ind__c = false ORDER BY MasterLabel];
        
        Map<String,List<String>> displayGeoCorrespondingToCountry = new Map<String,List<String>>();
        for(Core_MDF_CCP_Country_Geo_Mapping__mdt countryList : cList){
            if(displayGeoCorrespondingToCountry.containsKey(countryList.Core_MDF_Geo__c) ){
                displayGeoCorrespondingToCountry.get(countryList.Core_MDF_Geo__c).add(countryList.MasterLabel);
            } 
            else{
                displayGeoCorrespondingToCountry.put(countryList.Core_MDF_Geo__c,new List<String>{countryList.MasterLabel});
            }
        }
        return displayGeoCorrespondingToCountry;
    }
    public class CustomException extends Exception{}
    @AuraEnabled 
    public static String saveCampaign(Campaign campaignObj, List<CampaignBudgetWrapperClass> campaignBudgets, List<PartnerFundRequest> pfrList, String campAmountFields, String selectedActPartners, List<Map<String, String>> contractLineItemRecordsToSave, List<OutcomeWrapper> outcomeWrapperList, List<ActivityToActivityAttributesWrapper> activityToActivityAttrWrapperList, Boolean hasTacticMetrics) {
        String returnValue='';
         List<String> validOutcomeMetricProgram = Core_MDF_CCP_ConstantClass.validOutcomeMetricProgramName;
        //US1082875: [IPA MDF] - Campaign - Clone a Proposal - Save capability
        List<PartnerFundRequest> insertPFR = new List<PartnerFundRequest>();
        List<String> conDocListIds = new List<String>();
        Map<id,List<String>> pfrmap = new Map<id,List<String>>();
        // List<String> cdocumentids = contentDocId;
        Map<Id,String> mapIdSeg = new  Map<Id,String>();
        String ipaProgram = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name');
        // Creating savepoint before campaign upsert
        Savepoint sp = Database.setSavepoint();
        try{
            Boolean proposalBasedInd = campaignObj.Core_MDF_Proposal_Based_Ind__c;

            if(campaignObj.Core_MDF_Program__c == ipaProgram && proposalBasedInd && campAmountFields != '' && campAmountFields != null) {
                ipaAmountFieldsWrapper wrapper=(ipaAmountFieldsWrapper)JSON.deserialize(campAmountFields,ipaAmountFieldsWrapper.class);  
                if(wrapper.totalCampaignCost != null && wrapper.totalCampaignCost != ''){
                    campaignObj.Core_MDF_Total_Campaign_Cost_Amt__c = decimal.valueOf(wrapper.totalCampaignCost);
                }
                if(wrapper.reimbursementAmount != null && wrapper.reimbursementAmount != '') {
                    campaignObj.Core_MDF_Reimbursement_Amt__c = decimal.valueOf(wrapper.reimbursementAmount); 
                }
        
            }
            campaignObj.Core_MDF_Partner_Mapping_Txt__c   = selectedActPartners;
            upsert campaignObj;
            returnValue = campaignObj.Id;
            Campaign camRecord = [SELECT Id, Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Program__c,Core_MDF_Channel_Program__c,Core_MDF_CampOutcomeOpt_In_Ind__c,Core_MDF_Outcome_Detail_Edited_Ind__c from Campaign where id = :campaignObj.Id LIMIT 1];
            if(camRecord.Core_MDF_Opal_Budget_Type_Txt__c != null){                
                if(campaignBudgets != null && !campaignBudgets.isEmpty()){
                    AdminOperations aoObj = new AdminOperations();
                    aoObj.saveCampaignBudgets(campaignObj.Id,campaignBudgets,camRecord.Core_MDF_Program__c);   
                }
            }
            if(campaignObj.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_TECHNICAL_PROGRAM && !contractLineItemRecordsToSave.isEmpty()){
                saveCampaignContractLineItems(campaignObj.Id, contractLineItemRecordsToSave);
            }
            if(campaignObj.Core_MDF_Program__c == EEF_PROGRAM){
                saveCampToISVMapping(campaignObj);
            }
            if(validOutcomeMetricProgram.contains(campaignObj.Core_MDF_Program__c)){
                saveCampaignOutcomes(campaignObj.Id, camRecord.Core_MDF_CampOutcomeOpt_In_Ind__c, outcomeWrapperList);
            }
            //US1082875: [IPA MDF] - Campaign - Clone a Proposal - Save capability

            if((pfrList != null && !pfrList.isEmpty() && !hasTacticMetrics) || (activityToActivityAttrWrapperList != null && hasTacticMetrics) ) {
                Map<string,string> errIdToMsg = new Map<string,string>();
                string oppValidationMsg = System.Label.Core_MDF_OpportunityID_Error;

                 //Executes only when IPA Outcome based campaign clone
                List<PartnerFundRequest> outcomeBasedActivityList = new List<PartnerFundRequest>();
                if(hasTacticMetrics){
                    // Filter activities to only those whose Id is present in pfrList (to avoid unwanted data)
                    Set<Id> validPfrIds = new Set<Id>();
                    for(PartnerFundRequest pfrRec : pfrList){
                        if(pfrRec != null && pfrRec.Id != null){
                            validPfrIds.add(pfrRec.Id);
                        }
                    }

                    List<ActivityToActivityAttributesWrapper> activityToActivityAttrWrapperTempList = new List<ActivityToActivityAttributesWrapper>();
                    for(ActivityToActivityAttributesWrapper wrap : activityToActivityAttrWrapperList){
                        if(wrap != null && wrap.activity != null && wrap.activity.Id != null){
                            if(!validPfrIds.isEmpty() && validPfrIds.contains(wrap.activity.Id)){
                                outcomeBasedActivityList.add(wrap.activity);
                                activityToActivityAttrWrapperTempList.add(wrap);
                            }
                        }
                    }
                    activityToActivityAttrWrapperList = activityToActivityAttrWrapperTempList;
                }

                for(PartnerFundRequest p : (hasTacticMetrics ? outcomeBasedActivityList : pfrList)){
                    p.Id = null;
                    p.Core_MDF_EndTime_dtm__c = System.now(); //Capturing End Time while creating proposal
                    p.Core_MDF_Fund_Request_Status__c = 'Draft';
                    p.CampaignId = campaignObj.Id;
                    
                    if(p.AllocationId != NULL){
                        p.AllocationId = NULL;
                    }
                    if(p.BudgetId != NULL){
                        p.BudgetId = NULL;
                    }
                    //Blank out Closure Type while cloning IPA proposal
                    if(p.Core_MDF_Activity_Closure_Type__c != '' ){
                        p.Core_MDF_Activity_Closure_Type__c = '';
                    }
                    if(p.Core_MDF_Activity_Types__c == ''){
                        throw new CustomException(System.Label.Core_MDF_ActivityTypeError);
                    }
                    
                    //add check for Opportunity ID 
                 if(String.isNotBlank(p.Core_MDF_Opportunity_id__c)){
                        String objName = '';
                        String oppId = p.Core_MDF_Opportunity_id__c;
                     try{
                        //ATHR - Deeply Nested if 16209
                        //if(oppId instanceOf Id){
                            objName = oppId instanceOf Id ? Id.valueOf(oppId).getSObjectType().getDescribe().getName() : '';
                        //}
                        if(String.isBlank(objName) || objName != Core_MDF_CCP_ConstantClass.OPPORTUNITY_OBJECT_NAME ){
                            errIdToMsg.put(p.Core_MDF_Opportunity_id__c,oppValidationMsg);
                        }}
                     catch(exception ex){ errIdToMsg.put(p.Core_MDF_Opportunity_id__c,oppValidationMsg); }
                    }
                    insertPFR.add(p); 
                } 
                if(!errIdToMsg.isEmpty()){
                      throw new CustomException(JSON.serialize(errIdToMsg)); // Error : Please enter a valid Opportunity Id. 
                }
                insert insertPFR;
                
            }
            //Added by Hema
            //ATHR - Deeply Nested if 16209
            if(insertPFR.isEmpty()){
               return returnValue;
            }
            //if(!insertPFR.isEmpty()){
                for(PartnerFundRequest pfr : insertPFR)
                { 
                    if(pfr.Core_MDF_Content_DocumentIds_txt__c !=null){
                        String pfrContentDocumentIds = pfr.Core_MDF_Content_DocumentIds_txt__c;
                        conDocListIds.addAll(pfrContentDocumentIds.split(','));
                        pfrmap.put(pfr.id,pfrContentDocumentIds.split(','));
                    } 
                }
                List<ContentDocumentLink> conDocuLink = new List<ContentDocumentLink>();  
                List<FeedItem> chatterfiles = new List<FeedItem>();
                if(!conDocListIds.isEmpty()){
                    for(ContentDocument docuLink : [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE Id IN: conDocListIds]){
                        for(Id pfrId : pfrmap.keySet()){
                            //ATHR - Deeply Nested if 16209
                            if(docuLink == null || docuLink.Id == null || pfrmap.get(pfrId) == null || !pfrmap.get(pfrId).contains(docuLink.Id)) {
                                continue;
                            }
                            //if(pfrmap.get(pfrId).contains(docuLink.Id)){ 
                                ContentDocumentLink odocLink = new ContentDocumentLink(ContentDocumentId = docuLink.Id,LinkedEntityId=pfrId,ShareType='I',Visibility='AllUsers');
                                FeedItem chatterDetail = new FeedItem();
                                chatterDetail.ParentId = pfrId;
                                chatterDetail.RelatedRecordId = docuLink.LatestPublishedVersionId;
                                chatterDetail.Type = 'ContentPost';
                                chatterDetail.Visibility = 'AllUsers';
                                chatterfiles.add(chatterDetail);
                                conDocuLink.add(odocLink);
                            //}
                        }
                    }  
                    insert(conDocuLink);
                    insert(chatterfiles);
                }

                //For IPA Outcome based Proposal Clone - Create Activity Attribute(Tactic Metrics) records
                List<Core_MDF_Activity_Attributes__c> activityAttributeListToInsert = new List<Core_MDF_Activity_Attributes__c>();
                for(ActivityToActivityAttributesWrapper wrapper : activityToActivityAttrWrapperList){
                    Id activityId = (wrapper != null && wrapper.activity != null) ? wrapper.activity.Id : null;
                    for(Core_MDF_Activity_Attributes__c activityAttribute : wrapper.activityAttribute){
                        if(activityId != null && activityAttribute != null && activityAttribute.Core_MDF_Is_Active_Ind__c){
                                activityAttribute.Id = null;
                                activityAttribute.Core_MDF_Is_Active_Ind__c = true;
                                activityAttribute.Core_MDF_Co_Marketing_Activity__c = activityId;
                                activityAttributeListToInsert.add(activityAttribute);
                        }
                    }
                }

                if(!activityAttributeListToInsert.isEmpty()){
                    insert activityAttributeListToInsert;
                }

            //}
        }
        
        catch(Exception e){
            if(!e.getMessage().contains(System.Label.Core_MDF_OpportunityID_Error)){
            Core_MDF_CCP_UtilityClass.logError(e);
            }
            returnValue = 'Exception: '+e.getMessage();
            // Rollback to previous savepoint
            Database.rollback(sp);
            String errMessage = returnValue;
            throw new AuraHandledException(errMessage);
        }
        return returnValue;
    }
    
    @AuraEnabled
    public static List<FieldSetMemberWrapperClass> getObjectFields(String objectName, List<String> fieldSetNameList, Boolean isCommunityUser) {
        List<String> fieldList = new List<String>();
        List<FieldSetMemberWrapperClass> wrapperList = new List<FieldSetMemberWrapperClass>();
        Map<String, String> options = new Map<String, String>();
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
    for(String fieldSetName : fieldSetNameList)
    {
        for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){
            String fieldName = fieldMember.getFieldPath();
            if((isCommunityUser && fieldName != 'Core_MDF_Proposal_Score_nbr__c' && fieldName != 'Core_MDF_Reason_for_Back_Dating_Nm__c' && fieldName != 'Core_MDF_PCT_Notes_txt__c') || !isCommunityUser) {
                if(!fieldList.contains(fieldMember.getFieldPath()))
                {
                    FieldSetMemberWrapperClass wrapper = new FieldSetMemberWrapperClass();
                    wrapper.isRequired = fieldMember.getRequired();
                    wrapper.fieldType = String.valueOf(fieldMember.getType());
                    wrapper.fieldLabel = fieldMember.getLabel();
                    wrapper.fieldAPIName = fieldMember.getFieldPath();
                    wrapper.helpText = fieldMember.getSObjectField().getDescribe().getInlineHelpText();
                    fieldList.add(fieldMember.getFieldPath());
                    if(String.valueOf(fieldMember.getType()) == 'PICKLIST' || String.valueOf(fieldMember.getType()) == 'MULTIPICKLIST') {
                        options = new Map<String, String>();
                        for (Schema.PicklistEntry p: sObj.getDescribe().fields.getMap().get(fieldMember.getFieldPath()).getDescribe().getPicklistValues()) {
                            options.put(p.getValue(), p.getLabel());
                        }

                    wrapper.pickListValues = options;
                }
                wrapperList.add(wrapper);
                }   
            }
            }
        }
        return wrapperList;
    } 
    
    @AuraEnabled
    public static AccountIdBudgetTypeWrapper getAccSpecificBudgetTypes(Id accountId,String program){
        AdminOperations aoObj = new AdminOperations();
        AccountIdBudgetTypeWrapper abtw = new AccountIdBudgetTypeWrapper();
        abtw = aoObj.getAccSpecificBudgetTypes(accountId,program);
        return abtw;
    }
    
    @AuraEnabled
    public static Map<String,Object> mainPicklistFetcher(String recordTypeName){ 
        String rec = recordTypeName;
        return Core_Intel_customPicklistController.picklistFetcher(rec);
    }
    
    @AuraEnabled
    public static Map<String,Object> PicklistFetcher(String recordTypeName){ 
        String rec = recordTypeName;
        return Core_Intel_customPicklistController.customPicklistFetcher(rec);
    }
    
    @AuraEnabled
    public static Map<string,string> getAccPropBasedValues(String campBudgetType, String program){
        String typeOfCampaign = '';
        Map<string,string> result = new Map<string,string>();
        //added by Jk to use the generic meta data method to fetch the metadata records
        String whereClause = 'Core_MDF_RecordType__c != null AND Core_MDF_Budget_Type__c =\''+campBudgetType+'\' '+' AND Core_MDF_Program_Nm__c =\''+program+'\' '+' AND Core_MDF_IsActive__c=true LIMIT 1';
        budgetTypeBenefitMapping = Core_MDF_CampaignUtility.getBudgetTypeBenefitRec(objectApiName, whereClause);
        
        List<Core_MDF_BudgetType_Benefit_Mappings__c> budgetType = budgetTypeBenefitMapping/*[Select Id, MasterLabel, Core_MDF_RecordType__c,Core_MDF_Record_Developer_Nm__c 
                                                                     from Core_MDF_BudgetType_Benefit_Mapping__mdt 
                                                                     where Core_MDF_RecordType__c != null 
                                                                     and Core_MDF_Budget_Type__c =: campBudgetType 
                                                                     and Core_MDF_Program_Nm__c =: program 
                                                                     and Core_MDF_IsActive__c=true LIMIT 1]*/;
        if(!budgetType.isEmpty()){
            result.put(budgetType[0].Core_MDF_RecordType__c,budgetType[0].Core_MDF_Record_Developer_Nm__c);
        }
        return result;
    }
    
    @AuraEnabled
    public static List<Id> fetchIUPGMPNUMAccounts(){
        String loggedInUserId = UserInfo.getUserId();
        List<Id> accountlist = new List<Id>();
        List<Core_MDF_Partner_Node_User_Mapping__c> PNUMAccounts = [Select id, Core_MDF_Account__c, Core_MDF_User__c from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_User__c =: loggedInUserId];
        for(Core_MDF_Partner_Node_User_Mapping__c pnum : PNUMAccounts){
            accountlist.add(pnum.Core_MDF_Account__c);
        } 
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> IUPGMAccounts = [Select id,Core_MDF_Account_id__c,Core_MDF_User_id__c from Core_MDF_Int_Users_Partner_Geo_Mapping__c where Core_MDF_User_id__c =: loggedInUserId];
        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c IUPGM : IUPGMAccounts){
            accountlist.add(IUPGM.Core_MDF_Account_id__c);
        }
        return accountlist;
    }
    
    /*public static String getBudgetType(Id accId, string operation, string isProposalBased, string program){
List<String> budgetTypeValues = new List<String>();
set<String> budgetFromMetaData = new set<String>();
set<String> mdfBudgetType = new set<String>();
List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
List<Core_MDF_Partner_Group_Mapping__c> pgmRec = new List<Core_MDF_Partner_Group_Mapping__c>();
string budgetTypeString,recordType,AccountId;
Set<String> budgetTypeFromPGM = new Set<String>();
Map<string,set<string>> recordTypeBudgetMap = new Map<string,set<string>>();
String channelMDFProgram;
Map<string,string> budgetTypeValuesMap = new Map<string,string>();

try{
//NP - WW33 Added separate flow for IPA to get Budget types from Account-Benefit
if(program == 'Intel Partner Alliance'){
AdminOperations aoObj = new AdminOperations();
AccountIdBudgetTypeWrapper abtw = new AccountIdBudgetTypeWrapper();
abtw = aoObj.getAccSpecificBudgetTypes(accId,program);
budgetTypeValuesMap = abtw.accIdBudgetTypeMap.get(accId);
budgetTypeFromPGM = budgetTypeValuesMap.keySet();
}
//Existing flow for Channel MDF to get Budget types from PGM
else if (program == 'Channel MDF'){
channelMDFProgram = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ChannelMDF_Program_Name');
List<Account> accList = [SELECT Id,Core_MDF_Parent_Fund_Account__c FROM Account WHERE Id =: accId];

if(!accList.isEmpty()){
AccountId = accList[0].Core_MDF_Parent_Fund_Account__c;
}

if(string.isNotBlank(channelMDFProgram) && string.isNotBlank(AccountId)){
pgmRec = [SELECT Id, Core_MDF_Account__c,Core_MDF_Budget_Type_Access_nm__c,Core_MDF_Type_of_Access__c,Core_MDF_Channel_Program__c 
FROM Core_MDF_Partner_Group_Mapping__c 
WHERE Core_MDF_Channel_Program__r.Name =: channelMDFProgram and Core_MDF_Type_of_Access__c = 'External' and Core_MDF_Account__c =: AccountId LIMIT 1];
}

if(!pgmRec.isEmpty()){
budgetTypeValues.add(pgmRec[0].Core_MDF_Budget_Type_Access_nm__c);
}
if(!budgetTypeValues.isEmpty()){
budgetTypeFromPGM = new Set<String>(budgetTypeValues[0].split(';'));
}
}

List<Core_MDF_BudgetType_Benefit_Mapping__mdt> budgetMappingsList = [SELECT Id, MasterLabel, Core_MDF_Budget_Type__c, Core_MDF_RecordType__c 
FROM Core_MDF_BudgetType_Benefit_Mapping__mdt 
WHERE Core_MDF_RecordType__c != null 
AND Core_MDF_Budget_Type__c = :budgetTypeFromPGM
AND Core_MDF_IsActive__c = true
AND Core_MDF_Program_Nm__c =: program];

if(!budgetMappingsList.isEmpty()){
for(Core_MDF_BudgetType_Benefit_Mapping__mdt budgetTypeMapping : budgetMappingsList){
budgetFromMetaData.add(budgetTypeMapping.Core_MDF_Budget_Type__c);
if(recordTypeBudgetMap.get(budgetTypeMapping.Core_MDF_RecordType__c) != null){
recordTypeBudgetMap.get(budgetTypeMapping.Core_MDF_RecordType__c).add(budgetTypeMapping.Core_MDF_Budget_Type__c);
}else{
recordTypeBudgetMap.put(budgetTypeMapping.Core_MDF_RecordType__c, new set<string>{budgetTypeMapping.Core_MDF_Budget_Type__c});
}
}
} 

if(!budgetFromMetaData.isEmpty()){
if(operation == 'edit'){
if(String.isNotBlank(isProposalBased)){
recordType = isProposalBased == 'true' ? label.Proposal_based_Channel_MDF_Indicator : label.Account_based_Channel_MDF_Indicator;
}
if(string.isNotBlank(recordType)){
if(recordTypeBudgetMap.get(recordType) != null){
mdfBudgetType = recordTypeBudgetMap.get(recordType);
}
}

budgetTypeString = string.join((Iterable<String>)mdfBudgetType,';');
}else{
if(UserInfo.getUserType() == 'PowerPartner'){
if(recordTypeBudgetMap.get(label.Proposal_based_Channel_MDF_Indicator) != null){
mdfBudgetType = recordTypeBudgetMap.get(label.Proposal_based_Channel_MDF_Indicator);
}
budgetTypeString = string.join((Iterable<String>)mdfBudgetType,';');
}
else{
budgetTypeString = string.join((Iterable<String>)budgetFromMetaData,';');
}
}    
}

}catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);
}  
return budgetTypeString;
}*/
    
    @AuraEnabled
    public static Map<string,string> getBudgetType(Id accId, string operation, string isProposalBased, string program){
        List<String> budgetTypeValues = new List<String>();
        set<String> budgetFromMetaData = new set<String>();
        set<String> mdfBudgetType = new set<String>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<Core_MDF_Partner_Group_Mapping__c> pgmRec = new List<Core_MDF_Partner_Group_Mapping__c>();
        string budgetTypeString,recordType,AccountId;
        Set<String> budgetTypeFromPGM = new Set<String>();
        Map<string,set<string>> recordTypeBudgetMap = new Map<string,set<string>>();
        Map<string,string> budgetTypeValuesMap = new Map<string,string>();
        Map<string,string> budgetTypeMap = new Map<string,string>();
        
        try{
            
            Map<String,String> validBudgetTypeOptions = new Map<String,String>();
            Schema.DescribeFieldResult fieldResult = Campaign.Core_MDF_Opal_Budget_Type_Txt__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            for( Schema.PicklistEntry f : ple)
            {
                validBudgetTypeOptions.put(f.getValue(), f.getLabel());
            }       
            
            
            
            //NP - WW33 Added separate flow for IPA to get Budget types from Account-Benefit
            if(program == 'Intel Partner Alliance'){
                AdminOperations aoObj = new AdminOperations();
                AccountIdBudgetTypeWrapper abtw = new AccountIdBudgetTypeWrapper();
                abtw = aoObj.getAccSpecificBudgetTypes(accId,program);
                budgetTypeValuesMap = abtw.accIdBudgetTypeMap.get(accId);
                budgetTypeFromPGM = budgetTypeValuesMap.keySet();
            }
            //Existing flow for Channel MDF to get Budget types from PGM
            String budgetTypeForQuery = '(\''+String.join(new List<String>(budgetTypeFromPGM), '\', \'') + '\')';
            String whereClause = ' Core_MDF_RecordType__c != null AND Core_MDF_Budget_Type__c IN'+budgetTypeForQuery+' AND Core_MDF_Program_Nm__c =\''+program+'\' '+' AND Core_MDF_IsActive__c=true';
            budgetTypeBenefitMapping = Core_MDF_CampaignUtility.getBudgetTypeBenefitRec(objectApiName, whereClause);
            
            List<Core_MDF_BudgetType_Benefit_Mappings__c> budgetMappingsList = budgetTypeBenefitMapping/*[SELECT Id, MasterLabel, Core_MDF_Budget_Type__c, Core_MDF_RecordType__c 
                                                                                 FROM Core_MDF_BudgetType_Benefit_Mapping__mdt 
                                                                                 WHERE Core_MDF_RecordType__c != null 
                                                                                 AND Core_MDF_Budget_Type__c = :budgetTypeFromPGM
                                                                                 AND Core_MDF_IsActive__c = true
                                                                                 AND Core_MDF_Program_Nm__c =: program]*/;
            
            if(!budgetMappingsList.isEmpty()){
                
                for(Core_MDF_BudgetType_Benefit_Mappings__c budgetTypeMapping : budgetMappingsList){
                    budgetFromMetaData.add(budgetTypeMapping.Core_MDF_Budget_Type__c);
                    if(recordTypeBudgetMap.get(budgetTypeMapping.Core_MDF_RecordType__c) != null){
                        recordTypeBudgetMap.get(budgetTypeMapping.Core_MDF_RecordType__c).add(budgetTypeMapping.Core_MDF_Budget_Type__c);
                    }else{
                        recordTypeBudgetMap.put(budgetTypeMapping.Core_MDF_RecordType__c, new set<string>{budgetTypeMapping.Core_MDF_Budget_Type__c});
                    }
                }
            } 
            //ATHR - Deeply Nested if 16209
            if(budgetFromMetaData == null || budgetFromMetaData.isEmpty()){
                return budgetTypeMap;
            }
            //if(!budgetFromMetaData.isEmpty()){
                if(operation == 'edit'){
                    if(String.isNotBlank(isProposalBased)){
                        recordType = isProposalBased == 'true' ? Proposal_based_Indicator : Account_based_Indicator;
                    }
                    //ATHR - Deeply Nested if 16209
                    if(string.isNotBlank(recordType) && recordTypeBudgetMap.get(recordType) != null){
                        //if(recordTypeBudgetMap.get(recordType) != null){
                            mdfBudgetType = recordTypeBudgetMap.get(recordType);
                            for(String b:mdfBudgetType){
                                budgetTypeMap.put(b,validBudgetTypeOptions.get(b));
                            }
                            
                        //}
                    }
                    
                    budgetTypeString = string.join((Iterable<String>)mdfBudgetType,';');
                    
                }else{
                    if(UserInfo.getUserType() == 'PowerPartner'){
                        if(recordTypeBudgetMap.get(Proposal_based_Indicator) != null){
                            mdfBudgetType = recordTypeBudgetMap.get(Proposal_based_Indicator);
                        }
                        for(String b:mdfBudgetType){
                            budgetTypeMap.put(b,validBudgetTypeOptions.get(b));
                        }
                        budgetTypeString = string.join((Iterable<String>)mdfBudgetType,';');
                    }
                    else{
                        for(String b:budgetFromMetaData){
                            budgetTypeMap.put(b,validBudgetTypeOptions.get(b));
                        }
                        budgetTypeString = string.join((Iterable<String>)budgetFromMetaData,';');
                    }
                }    
            //}
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}  
        return budgetTypeMap;
    }
    
    
    
    
    
    @AuraEnabled
    public static List<String> getFieldEditibilityMapping(String objectName, String recTypeDevloperName, String status, Id campaignId, Boolean proposalBasedIndicator, Boolean claimAssociatedIndicator){
        
        List<String> fieldApiNameList = new List<String>();
        Set<String> fieldApiNameSet = new Set<String>();
        String userId = UserInfo.getUserId();
        Set<String> psNameSet = new Set<String>();
        //Boolean isPropInd ;
        //List<Core_MDF_Field_Editability_Mapping__mdt> fieldEditibilityList = [SELECT Core_MDF_Field_API_Name__c, Core_MDF_Permission_Set_API_Name__c,Core_MDF_Field_ReadOnly_API_Name__c FROM Core_MDF_Field_Editability_Mapping__mdt WHERE Core_MDF_Object_API_Name__c =:objectName AND Core_MDF_Record_Type_Developer_Name__c =:recTypeDevloperName AND Core_MDF_Status__c =:status AND Active__c = true]; //TWC3117-16123
        for(PermissionSetAssignment psa : [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :userId]) {
            psNameSet.add(psa.PermissionSet.Name);
        }
        
        for(Core_MDF_Field_Editability_Mapping__mdt fem : [SELECT Core_MDF_Field_API_Name__c, Core_MDF_Permission_Set_API_Name__c,Core_MDF_Proposal_Based_Ind__c, Core_MDF_Field_ReadOnly_API_Name__c FROM Core_MDF_Field_Editability_Mapping__mdt WHERE Core_MDF_Object_API_Name__c =:objectName AND Core_MDF_Record_Type_Developer_Name__c =:recTypeDevloperName AND Core_MDF_Status__c =:status AND Active__c = true AND Core_MDF_Proposal_Based_Ind__c =:proposalBasedIndicator AND Core_MDF_Is_Claim_Associated_Ind__c =:claimAssociatedIndicator]) {
            if(psNameSet != null && psNameSet.contains(fem.Core_MDF_Permission_Set_API_Name__c) && String.isNotBlank(fem.Core_MDF_Field_API_Name__c)) {
                fieldApiNameSet.addAll(fem.Core_MDF_Field_API_Name__c.split(','));
            }
            //added by aditya
            if(psNameSet != null && psNameSet.contains(fem.Core_MDF_Permission_Set_API_Name__c) && String.isNotBlank(fem.Core_MDF_Field_ReadOnly_API_Name__c)) {
                fieldApiNameSet.addAll(fem.Core_MDF_Field_ReadOnly_API_Name__c.split(','));
            }
        }
        
        if(fieldApiNameSet != null) {
            fieldApiNameList.addAll(fieldApiNameSet);
        }
        return fieldApiNameList;
    }
    //US1082871: [IPA MDF] - Campaign - Clone a Proposal - get fieldset for ipa activities 
    @AuraEnabled
    public static List<ActivityFieldSVisibility> getActivityFields( String fieldSetName){ 
        List<ActivityFieldSVisibility> actFldVisblist = new  List<ActivityFieldSVisibility>();
        
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get('PartnerFundRequest');
        for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){
            ActivityFieldSVisibility wrapper = new ActivityFieldSVisibility();
            wrapper.fieldLabel = fieldMember.getLabel();
            wrapper.fieldAPIName = fieldMember.getFieldPath();
            actFldVisblist.add(wrapper); 
        }
        return actFldVisblist;
    }
    
    @AuraEnabled
    public static sObject loadRecord(String recordId,String operation, String objectName, List<String> fieldSetName){
        List<String> fieldstoExclude = Core_MDF_CCP_ConstantClass.CAMPAIGN_EXCLUDED_FIELDS;
        sObject recordObj;
        String sanitiziedCampaignId = String.escapeSingleQuotes(recordId);
        String sanitizedObjectName = String.escapeSingleQuotes(objectName);
        String sQuery = 'SELECT Id, ';
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(sanitizedObjectName);//ATHR Fix
        for(string fieldSet : fieldSetName){
            if(String.isNotBlank(recordId) && String.isNotBlank(sanitizedObjectName) && String.isNotBlank(fieldSet) ) {
                //Schema.SObjectType sObj = Schema.getGlobalDescribe().get(sanitizedObjectName);
                for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSet).getFields()){
                    if((operation == 'clone' && !fieldstoExclude.contains(fieldMember.getFieldPath())) || operation == 'edit'){
                    sQuery += fieldMember.getFieldPath() + ', ';
                    }
                }
        }
        sQuery += ' RecordTypeId, RecordType.Name, RecordType.DeveloperName, Core_MDF_Account__r.Name, Core_MDF_Account__r.Core_MDF_Active_Ind__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Account__r.Core_MDF_Virtual_Corp_Account_Id__c, Core_MDF_Channel_Program__c, Core_MDF_Approver_1_id__c, Core_MDF_Approver_2_id__c,Core_MDF_Approver_3_id__c,Core_MDF_Approver_4_id__c,Core_MDF_Approver_5_id__c,Core_MDF_Approver_6_id__c,Core_MDF_Approver_7_id__c,Core_MDF_Approver_8_id__c,Core_MDF_Approver_9_id__c,Core_MDF_Approver_10_id__c ';
        sQuery += ' FROM ' + sanitizedObjectName + ' WHERE Id =:sanitiziedCampaignId ';
        }
    recordObj = Database.query(sQuery);
        return recordObj;
    }
    
    @AuraEnabled
    public static List<FieldSetMemberWrapperClass> loadDynamicFields(String pickListObj, List<String> budType, String objectName){
        //Metadata disposition - changed text field references to picklist fields
        List<Core_MDF_RecordType_FieldSet_Mapping__mdt> fieldSetMap = [SELECT Core_MDF_Record_Type_DeveloperName_nm__c, Core_MDF_Field_Set_API_Name_nm__c, Core_MDF_Budget_Type_nm__c FROM Core_MDF_RecordType_FieldSet_Mapping__mdt WHERE Core_MDF_Object_API_Name_nm__c =:pickListObj and Core_MDF_Controlling_Field_nm__c IN: budType and Core_MDF_Current_Object_nm__c  =:objectName];
        
        List<FieldSetMemberWrapperClass> wrapperList = new List<FieldSetMemberWrapperClass>();
        List<String> fieldList = new List<String>();
        Map<String, String> options = new Map<String, String>();
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(pickListObj);
        List<String> fieldSetNameList = new List<String>();
        //ATHR - Deeply Nested if 16209
        if(fieldSetMap == null || fieldSetMap.isEmpty()){
            return wrapperList;
        }
        //if(!fieldSetMap.isEmpty()){
            for(Core_MDF_RecordType_FieldSet_Mapping__mdt fieldSet : fieldSetMap)
            {
              //Metadata disposition - changed text field references to picklist fields
                fieldSetNameList.add(fieldSet.Core_MDF_Field_Set_API_Name_nm__c);
            }
            for(string fieldSetName : fieldSetNameList){
                for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){
                    //ATHR - Deeply Nested if 16209
                    if(fieldList.contains(fieldMember.getFieldPath())){
                        continue;
                    }
                    //if(!fieldList.contains(fieldMember.getFieldPath()))
                    //{
                        FieldSetMemberWrapperClass wrapper = new FieldSetMemberWrapperClass();
                        wrapper.isRequired = fieldMember.getRequired();
                        wrapper.fieldType = String.valueOf(fieldMember.getType());
                        wrapper.fieldLabel = fieldMember.getLabel();
                        wrapper.fieldAPIName = fieldMember.getFieldPath();
                        wrapper.helpText = fieldMember.getSObjectField().getDescribe().getInlineHelpText();
                        fieldList.add(fieldMember.getFieldPath());
                        if(String.valueOf(fieldMember.getType()) == 'PICKLIST' || String.valueOf(fieldMember.getType()) == 'MULTIPICKLIST') {
                            options = new Map<String, String>();
                            for (Schema.PicklistEntry p: sObj.getDescribe().fields.getMap().get(fieldMember.getFieldPath()).getDescribe().getPicklistValues()) {
                                options.put(p.getValue(), p.getLabel());
                            }
                            wrapper.pickListValues = options;
                        }
                        wrapperList.add(wrapper);
                    //}
                }
            }        
        //}
        return wrapperList;
        
    }
    @AuraEnabled
    public static List<String> getFieldSetName(String pickListObj, List<String> budType, String objectName, String recordTypeDevName){
        List<String> fieldSetNames = new List<String>();
        //Metadata disposition - changed text field references to picklist fields
        List<Core_MDF_RecordType_FieldSet_Mapping__mdt> fieldSetList = [SELECT Core_MDF_Field_Set_API_Name_nm__c FROM Core_MDF_RecordType_FieldSet_Mapping__mdt WHERE Core_MDF_Object_API_Name_nm__c=:pickListObj and Core_MDF_Controlling_Field_nm__c IN :budType and Core_MDF_Current_Object_nm__c=:objectName and Core_MDF_Record_Type_DeveloperName_nm__c =: recordTypeDevName];
        
        for(Core_MDF_RecordType_FieldSet_Mapping__mdt fieldSet : fieldSetList)
        {
            //Metadata disposition - changed text field references to picklist fields
            fieldSetNames.add(fieldSet.Core_MDF_Field_Set_API_Name_nm__c);
        }
        return fieldSetNames;
    }
    
    @AuraEnabled
    public static Map<Id,PartnerMarketingBudget> getBudgetsForCampaign(id campAccountId,date campStartDate, date campEndDate, List<string> campBudgetType){
        try {
            AdminOperations aoObj = new AdminOperations();
            Map<id,PartnerMarketingBudget> availableBudgetsForCampaign = new Map<id,PartnerMarketingBudget>();
            availableBudgetsForCampaign = aoObj.getBudgetsForCampaign(campAccountId,campStartDate,campEndDate,campBudgetType);
            return availableBudgetsForCampaign;
            
        } catch (Exception e) { throw new AuraHandledException(e.getMessage());}
    }
    
    @AuraEnabled
    public static List<Core_MDF_Campaign_Budgets__c> getCampaignBudgetsForCampaign(id campaignId){
        try {
            AdminOperations aoObj = new AdminOperations();
            List<Core_MDF_Campaign_Budgets__c> budgetCampaignRecordsForCampaign = new List<Core_MDF_Campaign_Budgets__c>();
            budgetCampaignRecordsForCampaign = aoObj.getCampaignBudgetsForCampaign(campaignId);
            return budgetCampaignRecordsForCampaign;
            
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }
    
    
    @AuraEnabled
    public static List<Id> getBudgetsOnActiveActivities(Id campaignId){
        List<Id> budgetIdsList = new List<Id>();
        try{
            AdminOperations aoObj = new AdminOperations();
            Set<Id> budgetIds = aoObj.getBudgetsOnActiveActivities(campaignId);
            if(budgetIds != null && !budgetIds.isEmpty()) {
                budgetIdsList.addAll(budgetIds);   
            }
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}  
        return budgetIdsList;
    }
    @AuraEnabled
    public static Map<Id,Decimal> getBudgetsAmountOnActiveActivities(Id campaignId,Id budgetId){
        Map<Id,Decimal> budgetIdsAmtMap = new Map<Id,Decimal>();
        try{
            AdminOperations aoObj = new AdminOperations();
            Map<Id,Decimal> budgetidAmountMap = aoObj.getBudgetsAmountOnActiveActivities(campaignId,budgetId);
            if(budgetidAmountMap != null && !budgetidAmountMap.isEmpty()) {
                budgetIdsAmtMap.putAll(budgetidAmountMap);
            }
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}  
        return budgetIdsAmtMap;
    }
    
    
    @AuraEnabled
    public static Boolean multipleGeosSelected(List<String> campaignSelectedCountries, string program){
        Boolean isMultipleGeosSelected = False;
        String geo = Core_MDF_ProcessCCP_Campaign.returnsGeoForCampaign(campaignSelectedCountries);
        //ATHR - Deeply Nested if 16209
        /*if(geo.split(';').Size() > 1){
            //NP - WW33 Consider ASMO LAR/NAR as one Region for IPA
            if(program == 'Intel Partner Alliance'){
                for(string geoVal : geo.split(';')){
                    if(!geoVal.contains('ASMO')){isMultipleGeosSelected = true;}               
                }
            }
            else{isMultipleGeosSelected = true;}  
        }
        else {
            isMultipleGeosSelected = false;
        }*/
        if (geo.split(';').size() <= 1) {
            isMultipleGeosSelected = false;
        } else if (program != 'Intel Partner Alliance') {
            isMultipleGeosSelected = true;
        } else {
            isMultipleGeosSelected = false;
            for (String geoVal : geo.split(';')) {
                if (!geoVal.contains('ASMO')) {
                    isMultipleGeosSelected = true;
                    break;
                }
            }
        }
        return isMultipleGeosSelected;
    }
    
    @AuraEnabled
    public static List<PartnerFundRequest> getIPAActivities(Id campaignId){
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        try{
            pfrList = [select Id,Core_MDF_End_Date__c,Core_MDF_Fund_Request_Status__c, Core_MDF_Country_nm__c from PartnerFundRequest where Campaign.Id = :campaignId];
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
        return pfrList;
    }
    
    @AuraEnabled
    public static Boolean checkClaimsAssociatedToCampaign(Id campaignId){
        Boolean isClaimsAssociated = false;
        try{
            Integer noOfClaims = [Select count() from PartnerFundClaim where Core_MDF_Program__c = 'Intel Partner Alliance' and Core_MDF_Status__c != 'Cancelled' and Core_MDF_Campaign_Id__c = :campaignId];
            isClaimsAssociated = (noOfClaims > 0);
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
        return isClaimsAssociated;
    }

    @AuraEnabled
    public Static List<CampISVMapWrapper> fetchCampToActPartnerData(Id campaignId){
        List<Core_MDF_Camp_to_ActPartner__c> CampToActPartnerList = new List<Core_MDF_Camp_to_ActPartner__c>();
        List<CampISVMapWrapper> actPartIdRateWrapper = new List<CampISVMapWrapper>();
        try {
            CampToActPartnerList = [select id, Core_MDF_Campaign_Id__c, Core_MDF_Activating_Partner_Account_id__c,Core_MDF_Activating_Partner_Account_id__r.Name, Core_MDF_Reimbursement_Rate_pct__c from Core_MDF_Camp_to_ActPartner__c where Core_MDF_Campaign_Id__c=:campaignId and Core_MDF_Active_Ind__c=true];
            if(CampToActPartnerList != null && CampToActPartnerList.size() > 0) {
                for(Core_MDF_Camp_to_ActPartner__c campToActPartnerRec: CampToActPartnerList) {
                    CampISVMapWrapper wrap = new CampISVMapWrapper();
                    wrap.accountId = campToActPartnerRec.Core_MDF_Activating_Partner_Account_id__c;
                    wrap.accName = campToActPartnerRec.Core_MDF_Activating_Partner_Account_id__r.Name;
                    wrap.reimbursementRate = campToActPartnerRec.Core_MDF_Reimbursement_Rate_pct__c;
                    actPartIdRateWrapper.add(wrap);    
                }
            }

        }catch(Exception ex) { Core_MDF_CCP_UtilityClass.logError(ex); throw new AuraHandledException(ex.getMessage()); }
        return actPartIdRateWrapper;
    }
    
    
    public without sharing class AdminOperations {
        public AccountIdBudgetTypeWrapper getAccSpecificBudgetTypes(Id accountId, String program){
            //List<Id> accIdList = new List<Id>();
            Set<Id> accIdList = new Set<Id>();
            Map<Id,Map<String,String>> accIdBudgetTypeMap = new Map<Id,Map<String,String>>();
            Map<Id,Set<String>> benefitsApplicable = new Map<Id,Set<String>>();
            Set<String> unifiedIdSet =new Set<String>();//changed from primeIdSet to unifiedIdSet
            Set<Id> setOfAccIds=new Set<Id>();
            Map<Id,String> coMktAcctToUnifiedIdMap = new Map<Id,String>();//changed from coMktAcctToPrimeIdMap to coMktAcctToUnifiedIdMap
            //Map<Id,Id> intelAcctToCoMktAcctMap = new Map<Id,Id>();
            Map<String, Set<String>> applicableBenefitsFromMdt = new Map<String, Set<String>>();  //Roshan
            Map<String,String> budgetTypeToRecTypeMap = new Map<String,String>();
            Map<String,Set<String>> unifiedIdToBenefitList = new Map<String,Set<String>>();//changed from primeIdToBenefitList to unifiedIdToBenefitList
            Map<Id,String> mapOfIntelAccountandUnifiedId = new Map<Id,String>();//changed from mapOfIntelAccountandPrimeId to mapOfIntelAccountandUnifiedId
            Map<String,String> validBudgetTypeOptions = new Map<String,String>();
            List<Id> MDFExcluded = new List<id>();
            Map<String, String> budgetTypesFromCampObj = new Map<String, String>();
            List<String> recTypeNameLst = new List<String>();
      
            //Roshan
            Boolean optAccountBenefitAssociation = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_OptAccountBenefitAssoc'); 
            Set<Id> setOfOnePartnerIds = new Set<Id>();
            Map<Id, Set<Id>> mapOfOPIDtoSetofAccountId = new Map<Id, Set<Id>>();  

            Schema.DescribeFieldResult fieldResult = Campaign.Core_MDF_Opal_Budget_Type_Txt__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

            for( Schema.PicklistEntry f : ple)
            {
                budgetTypesFromCampObj.put(f.getValue(), f.getLabel());
            }
            recTypeNameLst.add('Core_MDF_Intel_Partner_Alliance_Proposal_Based');
            recTypeNameLst.add('Core_MDF_Intel_Partner_Alliance_Account_Based');
            List<String> ipaValidBudgetTypesList = getDependentPicklistValues('Core_MDF_Opal_Budget_Type_Txt__c',recTypeNameLst, program);

            for(String budType: budgetTypesFromCampObj.keySet()) {
                if(ipaValidBudgetTypesList.contains(budType)) {
                    validBudgetTypeOptions.put(budType, budgetTypesFromCampObj.get(budType));
                }
            }
            accIdList.add(accountId);
            //added by jk for budget type benefit mapping
            String whereClauseForBudgetType = 'Core_MDF_Program_Nm__c =\''+program+'\' '+' AND Core_MDF_IsActive__c=true';
            budgetTypeBenefitMapping = Core_MDF_CampaignUtility.getBudgetTypeBenefitRec(objectApiName, whereClauseForBudgetType);
            
            for(Core_MDF_BudgetType_Benefit_Mappings__c budToBenMdt:budgetTypeBenefitMapping/*[select Core_MDF_Budget_Type__c,Core_MDF_RecordType__c,Core_MDF_Partner_Benefit__c  from Core_MDF_BudgetType_Benefit_Mapping__mdt where Core_MDF_IsActive__c=true and Core_MDF_Program_Nm__c =: program]*/){
                //applicableBenefitsFromMdt.put(budToBenMdt.Core_MDF_Partner_Benefit__c, budToBenMdt.Core_MDF_Budget_Type__c);

                //Roshan
                if (!applicableBenefitsFromMdt.containsKey(budToBenMdt.Core_MDF_Partner_Benefit__c)) {
                    applicableBenefitsFromMdt.put(budToBenMdt.Core_MDF_Partner_Benefit__c, new Set<String>());
                }
                applicableBenefitsFromMdt.get(budToBenMdt.Core_MDF_Partner_Benefit__c).add(budToBenMdt.Core_MDF_Budget_Type__c);
                budgetTypeToRecTypeMap.put(budToBenMdt.Core_MDF_Budget_Type__c,budToBenMdt.Core_MDF_RecordType__c);
            }

            //for retriving accounts added by jk
            //String unifiedIdOrPrimeIdField = isUnifiedIdEnabled?' AND Core_MDF_CoMarketing_Ultimate_Account__r.Core_Unified_Global_Customer_BP_Id__c!= null':' AND Core_MDF_CoMarketing_Ultimate_Account__r.Core_Prime_Id__c != null';
            String unifiedIdOrPrimeIdField = ' AND Core_MDF_CoMarketing_Ultimate_Account__r.Core_Unified_Global_Customer_BP_Id__c!= null';
            String accIdListQuery = '(\''+String.join(new List<Id>(accIdList), '\', \'') + '\')';
            String whereClause = ' Id IN '+accIdListQuery+unifiedIdOrPrimeIdField;
            List<Account> accounts = Core_MDF_Account_Utility.fetchAccounts(whereClause);
            Set<Id> accountIds = new Set<Id>();
            for(Account acc : accounts){
               //String primeOrUnifiedField = isUnifiedIdEnabled?acc.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Unified_Global_Customer_BP_Id__c:null;
               String primeOrUnifiedField = acc.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Unified_Global_Customer_BP_Id__c;    
                                        coMktAcctToUnifiedIdMap.put(acc.Id, primeOrUnifiedField);
                                        unifiedIdSet.add(primeOrUnifiedField);  
                                        accountIds.add(acc.Id);           
            }
            
            if(!unifiedIdSet.isEmpty())
            {
                List<PRM_IPA_Affiliation__c> prmIPAAff = Core_MDF_Account_Utility.fetchPRMIPAAffiliation(accountIds,null);
                for(PRM_IPA_Affiliation__c accIpaAff :prmIPAAff){
                    MDFExcluded.add(accIpaAff.PRM_Account__c);
                }
                List<Account> unifiedAccounts = Core_MDF_Account_Utility.fetchUnifiedIdAccounts(unifiedIdSet);
            for(Account acc : unifiedAccounts){
                    String primeIdOrUnifiedField = acc.Core_Unified_Global_Customer_BP_Id__c;
                                            if(!MDFExcluded.contains(acc.Id))
                                            {                       
                        mapOfIntelAccountandUnifiedId.put(acc.Id,primeIdOrUnifiedField);
                                                setOfAccIds.add(acc.Id);

                        //Roshan 
                        if (acc.Core_IPA_One_Partner_Id__c != null) {
                            setOfOnePartnerIds.add(acc.Core_IPA_One_Partner_Id__c);
                            if (!mapOfOPIDtoSetofAccountId.containsKey(acc.Core_IPA_One_Partner_Id__c)) {
                                mapOfOPIDtoSetofAccountId.put(acc.Core_IPA_One_Partner_Id__c, new Set<Id>());
                            }
                            mapOfOPIDtoSetofAccountId.get(acc.Core_IPA_One_Partner_Id__c).add(acc.Id);
                        }

                    }                          
                                            
                }

                //Get the benefits for all accts: PAG accts as well as all the related accts
                /*for(PRM_Account_Specialty_Association__c asa : [SELECT ID, PRM_Account_Id__c, PRM_Specialty_Id__r.name from PRM_Account_Specialty_Association__c 
                                                                WHERE PRM_Account_Id__c IN:setOfAccIds and PRM_Specialty_Id__r.name IN: applicableBenefitsFromMdt.keySet() and PRM_InActive_Ind__c = FALSE ]){
                                                                    
                                                                    if(mapOfIntelAccountandUnifiedId.containsKey(asa.PRM_Account_Id__c) && mapOfIntelAccountandUnifiedId.get(asa.PRM_Account_Id__c) != NULL && unifiedIdToBenefitList.containsKey(mapOfIntelAccountandUnifiedId.get(asa.PRM_Account_Id__c)) ){
                                                                        unifiedIdToBenefitList.get(mapOfIntelAccountandUnifiedId.get(asa.PRM_Account_Id__c)).add(asa.PRM_Specialty_Id__r.name);
                                                                    }else{
                                                                        unifiedIdToBenefitList.put(mapOfIntelAccountandUnifiedId.get(asa.PRM_Account_Id__c), new Set<String> {asa.PRM_Specialty_Id__r.name});
                                                                    }   
                                                                    
                }*/
    
    //Roshan
                String setOfGeneralizedAccountds = optAccountBenefitAssociation ? '(\'' + String.join(new List<Id>(setOfOnePartnerIds), '\', \'') + '\')' : '(\'' + String.join(new List<Id>(setOfAccIds), '\', \'') + '\')';

                Map<Id, Set<String>> accountIdToBenefitMap = Core_MDF_CampaignCreatePage.getAccountToBenefitsMap(optAccountBenefitAssociation, setOfGeneralizedAccountds);

                if (optAccountBenefitAssociation) {
                    for (Id opid : accountIdToBenefitMap.keySet()) {
                        if (mapOfOPIDtoSetofAccountId.containsKey(opid)) {
                            Set<String> benefits = accountIdToBenefitMap.get(opid);
                            for (Id intelAccId : mapOfOPIDtoSetofAccountId.get(opid)) {
                                accountIdToBenefitMap.put(intelAccId, new Set<String>(benefits));
                            }
                        }
                    }
                }
                for (Id accId : accountIdToBenefitMap.keySet()) {
                    String unifiedId = mapOfIntelAccountandUnifiedId.get(accId);
                    if (String.isNotBlank(unifiedId)) {
                        if (!unifiedIdToBenefitList.containsKey(unifiedId)) {
                            unifiedIdToBenefitList.put(unifiedId, new Set<String>());
                        }
                        unifiedIdToBenefitList.get(unifiedId).addAll(accountIdToBenefitMap.get(accId));
                    }
                }
            }                                        

            for(Id acctId:accIdList){
                Set<String> benList = new Set<String>();
                Map<String,String> budgetTypeMap = new Map<String,String>();
                String unifiedId ='';//changed from primeId to unifiedId
                if(coMktAcctToUnifiedIdMap.containsKey(acctId) && coMktAcctToUnifiedIdMap.get(acctId) !=Null){
                    unifiedId = coMktAcctToUnifiedIdMap.get(acctId);
                }
            
                if(String.isNotBlank(unifiedId) && unifiedIdToBenefitList.containsKey(unifiedId) && unifiedIdToBenefitList.get(unifiedId) !=Null){
                    benList.addAll(unifiedIdToBenefitList.get(unifiedId));
                }
                
                /*for(String benifit : benList) {                    
                    if(validBudgetTypeOptions.containsKey(applicableBenefitsFromMdt.get(benifit))) {
                        if(UserInfo.getUserType() == 'PowerPartner' && budgetTypeToRecTypeMap.get(applicableBenefitsFromMdt.get(benifit)) == 'Proposal Based'){
                            budgetTypeMap.put(applicableBenefitsFromMdt.get(benifit), validBudgetTypeOptions.get(applicableBenefitsFromMdt.get(benifit)));
                        }
                        else if(UserInfo.getUserType() != 'PowerPartner'){
                            budgetTypeMap.put(applicableBenefitsFromMdt.get(benifit), validBudgetTypeOptions.get(applicableBenefitsFromMdt.get(benifit)));
                            
                        }
                    }
                }*/

                //Roshan
                for(String benifit : benList) {
                    if (applicableBenefitsFromMdt.containsKey(benifit)) {
                        for (String budgetType : applicableBenefitsFromMdt.get(benifit)) {
                            if (validBudgetTypeOptions.containsKey(budgetType)) {
                                if (UserInfo.getUserType() == 'PowerPartner' && budgetTypeToRecTypeMap.get(budgetType) == 'Proposal Based') {
                                    budgetTypeMap.put(budgetType, validBudgetTypeOptions.get(budgetType));
                                } else if (UserInfo.getUserType() != 'PowerPartner') {
                                    budgetTypeMap.put(budgetType, validBudgetTypeOptions.get(budgetType));
                                }
                            }
                        }
                    }
                }

                accIdBudgetTypeMap.put(acctId, budgetTypeMap);
                benefitsApplicable.put(acctId,benList);
            }  
            
            AccountIdBudgetTypeWrapper abtw = new AccountIdBudgetTypeWrapper();
            abtw.accIdBudgetTypeMap = accIdBudgetTypeMap;
            return abtw;
            
        }
        
        public Map<id,PartnerMarketingBudget> getBudgetsForCampaign(id accountID, date campStartDate, date campEndDate, List<string> campBudgetType){
            
            //List<string> budgetList = new List<string>(); 
            //Map<id,string> budgetMap = new Map<id,string>(); 
            List<string> budgetStatuses = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Opal_Available_Budget_Status').split(',');
            Map<id,PartnerMarketingBudget> pmbMap = new Map<id,PartnerMarketingBudget>();
            
            //Roshan - Removed CoGTM condition to allow cross year budgets
            try{
                for(PartnerMarketingBudget budgetRecord :[select Title,Core_MDF_Budget_Type_Txt__c, StartDate, EndDate, id, Core_MDF_Budget_Status__c, Core_MDF_Budget_Partner__c,Core_MDF_budget_ref_nbr__c
                                                          from PartnerMarketingBudget 
                                                          where ((StartDate <= :campStartDate AND EndDate >= :campStartDate) OR (StartDate >= :campStartDate AND StartDate <= :campEndDate))
                                                          and Core_MDF_Budget_Partner__c = :accountID
                                                          and Core_MDF_Budget_Type_Txt__c in :campBudgetType 
                                                          and TotalAllocatedAmount >0 ]){
                                                              // and (Core_MDF_Budget_Status__c in :budgetStatuses OR (Core_MDF_Budget_Status__c = 'Approved' And TotalAllocatedAmount > 0)) ]){
                                                              pmbMap.put(budgetRecord.id,budgetRecord);
                                                          }
            }
            
            catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
            return pmbMap;
        }
        
        public List<Core_MDF_Campaign_Budgets__c> getCampaignBudgetsForCampaign (id campaignId){
            List<Core_MDF_Campaign_Budgets__c> campBudgets = new List<Core_MDF_Campaign_Budgets__c>();
            // US1022967 changes start :: Added filter condition to the SOQL query for hiding Campaign Budget Secton to External users for MDF/MDF+ Budget Types
            String query = 'select id, Core_MDF_Active_ind__c, Core_MDF_Budget_Name_Id__r.Title, Core_MDF_Budget_Type_Nm__c,Core_MDF_Start_Date_Dt__c,Core_MDF_End_Date_Dt__c,  Core_MDF_Budget_Amt__c,Core_MDF_Reimbursement_Rate_Pct__c, Core_MDF_Reimbursement_Amt__c,Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c from  Core_MDF_Campaign_Budgets__c';
            
            try{
                String userType = UserInfo.getUserType();
                if(String.isNotBlank(userType) && userType == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Partner_User_Type')){
                    query = query + ' where Core_MDF_Campaign_Id__c = :campaignId and Core_MDF_Budget_Type_Nm__c not in (\'MDF\',\'MDF+\')';
                } else {
                    query = query + ' where Core_MDF_Campaign_Id__c =:campaignId';
                }
                List<Core_MDF_Campaign_Budgets__c> campaignBudgets = Database.query(query);
                if(campaignBudgets != null && !campaignBudgets.isEmpty()){
                    for(Core_MDF_Campaign_Budgets__c campaignBudgetRecord : campaignBudgets){
                        campBudgets.add(campaignBudgetRecord);
                    }
                }
            }
            catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
            return campBudgets;
        }
        
        public string saveCampaignBudgets(id campaign, List<CampaignBudgetWrapperClass> campaignBudgets, String progName){
            List<Core_MDF_Campaign_Budgets__c> toBeSavedCampaignBudgets = new List<Core_MDF_Campaign_Budgets__c>();
            Map<Id, Decimal> budgetIdToAmtMap = new Map<Id, Decimal>();
            if(progName == Core_MDF_CCP_ConstantClass.CCF_PROGRAM || progName == Core_MDF_CCP_ConstantClass.DCF_PROGRAM) {
                budgetIdToAmtMap = getBudgetsAmountOnActiveActivities(campaign, null);
            }
            String returnValue;
            String errs = '';
            List<String> budgetsAmountErrorList = new List<String>();
            
            //try{
            Set<Id> cmpBudgetsSetId = new Set<Id>();        // US920364
            for(CampaignBudgetWrapperClass i :campaignBudgets ){
                Core_MDF_Campaign_Budgets__c campaignBudget = new Core_MDF_Campaign_Budgets__c();
                // US920364 - start
                if(String.isNotBlank(i.campaignBudgetId)) {
                    campaignBudget.Id = i.campaignBudgetId;
                    campaignBudget.Core_MDF_Active_ind__c = i.isActive;
                    cmpBudgetsSetId.add(i.campaignBudgetId);
                } else {
                    campaignBudget.Core_MDF_Active_ind__c = true;
                }   
                // US920364 - end
                campaignBudget.Core_MDF_Campaign_Id__c = campaign;
                campaignBudget.Core_MDF_Budget_Name_Id__c = i.budgetId;
                //PRB10049874 fix - Appear error "Sum of all activities cannot exceed Campaign Amount"
                campaignBudget.Core_MDF_Reimbursement_Amt__c = i.budgetRAmount.setScale(2,RoundingMode.HALF_UP);
                if(budgetIdToAmtMap != null && budgetIdToAmtMap.size() > 0) {
                  Decimal actBudgetAmount = budgetIdToAmtMap.get(i.budgetId);
                    if(i.budgetRAmount < actBudgetAmount) {
                      Decimal rrPercentOnBudget = (i.budgetRR != null) ? Decimal.valueOf(i.budgetRR.removeEnd('%')) : 0;
                      Decimal calculatedTotalAmount = (actBudgetAmount * (100 / rrPercentOnBudget));
                        budgetsAmountErrorList.add('Campaign Spending Limit (USD) entered should be Greater than or equal to $' + calculatedTotalAmount.setScale(2,RoundingMode.HALF_UP) );
                        continue;
                    }
                }
                campaignBudget.Core_MDF_Reimbursement_Rate_Pct__c = i.budgetRR;
                campaignBudget.Core_MDF_Budget_Amt__c = i.budgetAmount;
                toBeSavedCampaignBudgets.add(campaignBudget);
            }
            if(!budgetsAmountErrorList.isEmpty()){
                errs = String.join(budgetsAmountErrorList, ' | ');
            }
            //Database.SaveResult[] saveList = Database.insert(toBeSavedCampaignBudgets,true);
            if(toBeSavedCampaignBudgets != null && toBeSavedCampaignBudgets.size() > 0) {
                Database.UpsertResult[] saveList = Database.upsert(toBeSavedCampaignBudgets,true);
                for(Database.UpsertResult sr : saveList) {
                    if(sr.isSuccess()){
                        returnValue = 'Success';
                    } else {                         
                            for(Database.Error err : sr.getErrors()) { errs += ' ' + err.getMessage(); }
                    }
                }
            }
            if(String.isNotBlank(errs)) { errs = 'CAMPAIGN_BUDGETS_EXCEPTION : ' + errs; throw new Core_MDF_CampaignBudgetException(errs); }
            
            return returnValue;
            
        }
        
        public Set<Id> getBudgetsOnActiveActivities(Id campaignId){
            Set<Id> budgetIds = new Set<Id>();
            try {
                List<String> opalBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_OPAL_BudgetTypes').split(';');
                for(PartnerFundRequest pfrObj : [SELECT Id, BudgetId FROM PartnerFundRequest WHERE Core_MDF_Fund_Request_Status__c  != 'Cancelled' AND Campaign.Id =:campaignId]) {
                    if(String.isNotBlank(pfrObj.BudgetId)) {
                        budgetIds.add(pfrObj.BudgetId);  
                        
                    }
                }
            }
            catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
            return budgetIds;
        }   
        
        public Map<Id,Decimal> getBudgetsAmountOnActiveActivities(Id campaignId,Id budgetId){
            Set<Id> budgetIds = new Set<Id>();
            Map<Id,Decimal> budgetIdAmtMap = new Map<Id,Decimal>();
            Decimal i=0;
            Decimal Amt=0;
            try {
                List<String> mdfBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MDF_BudgetTypes').split(';');
                List<String> cmpBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NonMDF_BudgetTypes').split(';');
                Map<Id,PartnerFundRequest> cmpPFRMap = new Map<Id,PartnerFundRequest>();
                Map<Id,Decimal> pfrIdClaimAmtMap = new Map<Id,Decimal>();
                Map<Id,Decimal> pfrIdEscAmtMap = new Map<Id,Decimal>();
                Set<ID> pfrIdToQueryClaimAmount = new Set<ID>();
                for(PartnerFundRequest pfrObj : [SELECT Id, CampaignId, Core_MDF_Fund_Request_Status__c, Amount,BudgetId,
                                                 Core_MDF_Start_Date__c, Core_MDF_End_Date__c,Core_MDF_Budget_Type_nm__c,RequestedAmount,Core_MDF_Activity_Closure_Type__c ,
                                                 Core_MDF_Activity_Reimbursement_Amt_nbr__c,Core_MDF_Country_nm__c
                                                 FROM PartnerFundRequest
                                                 WHERE Campaign.Id =:campaignId AND Core_MDF_Fund_Request_Status__c != 'Cancelled' AND 
                                                 ((Core_MDF_Fund_Request_Status__c = 'Closed' AND Core_MDF_Activity_Closure_Type__c IN ('Auto', 'Manual')) OR (Core_MDF_Fund_Request_Status__c != 'Closed'))]){
                                                     if(mdfBudgetTypeList.contains(pfrObj.Core_MDF_Budget_Type_nm__c)){
                                                         if(budgetIdAmtMap.containsKey(pfrObj.BudgetId)){
                                                             budgetIdAmtMap.put(pfrObj.BudgetId, budgetIdAmtMap.get(pfrObj.BudgetId) + pfrObj.Amount);
                                                         }
                                                         else{budgetIdAmtMap.put(pfrObj.BudgetId, pfrObj.Amount);
                                                             }
                                                     }
                                                     else if(cmpBudgetTypeList.contains(pfrObj.Core_MDF_Budget_Type_nm__c)){
                                                         
                                                         if(pfrObj.Core_MDF_Fund_Request_Status__c == 'Closed'){
                                                             pfrIdToQueryClaimAmount.add(pfrObj.Id);
                                                             cmpPFRMap.put(pfrObj.Id,pfrObj);
                                                         }
                                                         else
                                                         {
                                                             if(budgetIdAmtMap.containsKey(pfrObj.BudgetId)){
                                                                 budgetIdAmtMap.put(pfrObj.BudgetId, budgetIdAmtMap.get(pfrObj.BudgetId) + pfrObj.Core_MDF_Activity_Reimbursement_Amt_nbr__c);
                                                             }
                                                             else{budgetIdAmtMap.put(pfrObj.BudgetId, pfrObj.Core_MDF_Activity_Reimbursement_Amt_nbr__c);
                                                                 }                                                            
                                                         }
                                                         
                                                     }
                                                 }
                List<String> validClaimStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimStatus_ActivityAutoClose').split(';');
                if(cmpPFRMap.keySet().size() > 0)
                {
                    for(PartnerFundClaim pfcObj : [SELECT Id, Amount, Core_MDF_Status__c, RequestId,BudgetId FROM PartnerFundClaim WHERE RequestId IN :cmpPFRMap.keySet()
                                                   and Core_MDF_Status__c IN :validClaimStatus and Core_MDF_Type_Txt__c =: TYPE_CLAIM AND Core_MDF_Escalation_Id__c = null])
                    {
                        if(pfrIdClaimAmtMap.containsKey(pfcObj.RequestId)){
                            pfrIdClaimAmtMap.put(pfcObj.RequestId, pfrIdClaimAmtMap.get(pfcObj.RequestId) + pfcObj.Amount);
                        }
                        else{pfrIdClaimAmtMap.put(pfcObj.RequestId, pfcObj.Amount);
                            }  
                    }
                    for(Core_MDF_Escalation__c escObj : [SELECT Core_MDF_Co_Marketing_Activity_id__c,Core_MDF_Approved_Amount_amt__c,Core_MDF_Co_Marketing_Activity_id__r.BudgetId
                                                         FROM Core_MDF_Escalation__c
                                                         WHERE Core_MDF_Co_Marketing_Activity_id__c IN:cmpPFRMap.keySet() AND Core_MDF_Escalation_Status_nm__c =: ESC_APPROVED_STATUS])
                    {
                        if(pfrIdEscAmtMap.containsKey(escObj.Core_MDF_Co_Marketing_Activity_id__c)){
                            pfrIdEscAmtMap.put(escObj.Core_MDF_Co_Marketing_Activity_id__c, pfrIdEscAmtMap.get(escObj.Core_MDF_Co_Marketing_Activity_id__c) + escObj.Core_MDF_Approved_Amount_amt__c);
                        }
                        else{pfrIdEscAmtMap.put(escObj.Core_MDF_Co_Marketing_Activity_id__c, escObj.Core_MDF_Approved_Amount_amt__c);
                            }
                    }
                    for(PartnerFundRequest pfr : cmpPFRMap.values())
                    {
                        decimal totalEscAmt = 0.0;
                        decimal totalClaimedAmt = 0.0;
                        decimal totalClaimEscConsumedAmt = 0.0;
                        decimal amount = 0.0;
                        
                        //String cmpIdBudgetIdBudgetType = String.ValueOf(pfr.CampaignId) + pfr.BudgetId + pfr.Core_MDF_Budget_Type_nm__c;
                        //ATHR - Deeply Nested if 16209
                        if(pfr.Amount == null){
                            continue;
                        }
                        //if(pfr.Amount != null){
                            totalEscAmt = pfrIdEscAmtMap.containskey(pfr.Id) ? pfrIdEscAmtMap.get(pfr.Id) : 0;
                            totalClaimedAmt = pfrIdClaimAmtMap.containskey(pfr.Id) ? pfrIdClaimAmtMap.get(pfr.Id) : 0;
                            totalClaimEscConsumedAmt = totalEscAmt + totalClaimedAmt;
                            amount = totalClaimEscConsumedAmt >= pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c
                                ? pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c : totalClaimEscConsumedAmt;
                            
                            if(budgetIdAmtMap.containsKey(pfr.BudgetId)){
                                amount += budgetIdAmtMap.get(pfr.BudgetId);
                                budgetIdAmtMap.put(pfr.BudgetId, amount);
                            }else{
                                budgetIdAmtMap.put(pfr.BudgetId, amount); 
                            }                                                                        
                        //}
                        
                    }
                }
                
            } 
            catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
            return budgetIdAmtMap;
        }  
        
    }
    
    public static void saveCampaignOutcomes(Id campaignId, Boolean campaignOptIn, List<OutcomeWrapper> outcomeWrapperList) {
        try {
            Map<String, Core_MDF_Campaign_Outcomes__c> existingOutcomeMap = new Map<String, Core_MDF_Campaign_Outcomes__c>();
            for (Core_MDF_Campaign_Outcomes__c existing : [SELECT Id, Core_MDF_Outcomes_nm__c, Core_MDF_Campaign_Id__r.Core_MDF_CampOutcomeOpt_In_Ind__c, Core_MDF_Active_Ind__c FROM Core_MDF_Campaign_Outcomes__c WHERE Core_MDF_Campaign_Id__c = :campaignId]) {
                existingOutcomeMap.put(existing.Core_MDF_Outcomes_nm__c, existing);
            }    
            List<Core_MDF_Campaign_Outcomes__c> recordsToUpsert = new List<Core_MDF_Campaign_Outcomes__c>();
            Set<String> incomingOutcomes = new Set<String>();    
             if (outcomeWrapperList != null && !outcomeWrapperList.isEmpty()) {
                for (OutcomeWrapper wrapper : outcomeWrapperList) {
                    //ATHR - Deeply Nested if 16209
                    if (wrapper == null || String.isBlank(wrapper.outcome)){
                        continue;
                    }                
                    //if (String.isNotBlank(wrapper.outcome)) {
                        incomingOutcomes.add(wrapper.outcome);
                        Core_MDF_Campaign_Outcomes__c record;
                        if (existingOutcomeMap.containsKey(wrapper.outcome)) {
                            record = existingOutcomeMap.get(wrapper.outcome);
                        } else {
                            record = new Core_MDF_Campaign_Outcomes__c();
                            record.Core_MDF_Campaign_Id__c = campaignId;
                            record.Core_MDF_Outcomes_nm__c = wrapper.outcome;
                        }
                        record.Core_MDF_Active_Ind__c = true;
                       record.Core_MDF_Initial_Baseline_Quantity_nbr__c = wrapper.baselineQuantity != null ? Integer.valueOf(wrapper.baselineQuantity) : null;
                        record.Core_MDF_Goal_Quantity_nbr__c = wrapper.goalQuantity != null ? Integer.valueOf(wrapper.goalQuantity) : null;
                        record.Core_MDF_Outcome_Criteria_txt__c = wrapper.outcomeCriteria;
                        record.Core_MDF_Baseline_Period_nm__c = String.isNotBlank(wrapper.baselinePeriod) ? wrapper.baselinePeriod : null;
                        record.Core_MDF_Quantity_nbr__c = String.isNotBlank(wrapper.quantity) ? Integer.valueOf(wrapper.quantity) : null;
                        record.Core_MDF_Campaign_Purpose_Desc_txt__c = wrapper.campaignPurposeDescription;
                        recordsToUpsert.add(record);
                    //}
                }
            } 
            for (Core_MDF_Campaign_Outcomes__c existingOutcome : existingOutcomeMap.values()) {
                    if (((incomingOutcomes != null && !incomingOutcomes.contains(existingOutcome.Core_MDF_Outcomes_nm__c)) ) && existingOutcome.Core_MDF_Active_Ind__c) {
                    existingOutcome.Core_MDF_Active_Ind__c = false;
                    recordsToUpsert.add(existingOutcome);
                }
            }  
            if (!recordsToUpsert.isEmpty()) {upsert recordsToUpsert;}    
        } catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(e.getMessage());}
    }
    
    @AuraEnabled(cacheable=true)
    public static List<OutcomeWrapper> getCampaignOutcomes(Id campaignId) {
        List<OutcomeWrapper> wrapperList = new List<OutcomeWrapper>();
        try{
            for (Core_MDF_Campaign_Outcomes__c rec : [SELECT Id,Core_MDF_Outcomes_nm__c, Core_MDF_Initial_Baseline_Quantity_nbr__c, Core_MDF_Goal_Quantity_nbr__c, Core_MDF_Outcome_Criteria_txt__c, Core_MDF_Baseline_Period_nm__c, Core_MDF_Quantity_nbr__c
                FROM Core_MDF_Campaign_Outcomes__c WHERE Core_MDF_Campaign_Id__c = :campaignId AND Core_MDF_Active_Ind__c = true]) {
                wrapperList.add(new OutcomeWrapper(rec.Id, rec.Core_MDF_Outcomes_nm__c,rec.Core_MDF_Outcomes_nm__c, String.valueOf(rec.Core_MDF_Initial_Baseline_Quantity_nbr__c), String.valueOf(rec.Core_MDF_Goal_Quantity_nbr__c), rec.Core_MDF_Outcome_Criteria_txt__c, rec.Core_MDF_Baseline_Period_nm__c, String.valueOf(rec.Core_MDF_Quantity_nbr__c)));
            }
        }catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        return wrapperList;
    }

    public class OutcomeWrapper {
        @AuraEnabled public String recordId { get; set; }
        @AuraEnabled public String outcome { get; set; }         // internal value
        @AuraEnabled public String outcomeLabel { get; set; }    // translated label
        @AuraEnabled public String baselineQuantity { get; set; }
        @AuraEnabled public String goalQuantity { get; set; }
        @AuraEnabled public String outcomeCriteria { get; set; }
        @AuraEnabled public String baselinePeriod { get; set; }
        @AuraEnabled public String quantity { get; set; } 
        @AuraEnabled public String campaignPurposeDescription { get; set; }
    
        public OutcomeWrapper() {}
    
        public OutcomeWrapper(Id recordId, String outcome, String outcomeLabel, String baselineQuantity, String goalQuantity, String outcomeCriteria, String baselinePeriod, String quantity) {
            this.recordId = recordId;
            this.outcome = outcome;
            this.outcomeLabel = outcomeLabel;
            this.baselineQuantity = baselineQuantity;
            this.goalQuantity = goalQuantity;
            this.outcomeCriteria = outcomeCriteria;
            this.baselinePeriod = baselinePeriod;
            this.quantity = quantity; 
        }
    }
    
    
/***********************************************************************************************************   
Method Name:        getDependentPicklistValues 
@return  :          Map<String,List<String>> (Control values, List of Dependent values)
Parameter :         String, String, Id(Object api name, Field api name, recordTypeId)
Description:        This method is used to get dependent picklist values for each control value
Added By:           Accenture - NB - 25/03/2024
Modified By:        Date:       Changes: 
*************************************************************************************************************/   
public static List<String> getDependentPicklistValues(String fieldAPI, List<String> recTypeList, String program){
    Map<String, List<String>> fdvaluesmap=new Map<String, List<String>>();
    List<String> budgetTypesList = new List<String>();
    Set<Id> recordTypeIds = new Set<Id>();
    try{
       
        for(String recType : recTypeList) {
            Map<String, Object> jsonResponse = Core_Intel_customPicklistController.customPicklistFetcher(recType);
            Map<String, List<String>> returnData = Core_MDF_Smart_Picklist_Maintainence.parseDependentPicklistValues(jsonResponse, fieldAPI);
            if(returnData != null && returnData.size() > 0) {
                budgetTypesList.addAll(returnData.get(program));
            }
        }
    }
    catch(Exception e){
        Core_MDF_CCP_UtilityClass.logError(e);
        throw new AuraHandledException(e.getMessage());
    }

    return budgetTypesList;
}
    
    
    //TWC702-979: WW03 | Devint3 | IPA L1, L1's Manager, L2 Non SPIF & L2 SPIF Approver are able to Edit a Proposal which is not in their Queue.
    @AuraEnabled
    public static EditCampaignLockWrapper checkEditProposalAccess(Id campaignId, String recTypeDevloperName){
        
        EditCampaignLockWrapper editCampWrap = new EditCampaignLockWrapper();
        List<ProcessInstanceWorkItem> piwiList = new List<ProcessInstanceWorkItem>();
        Boolean isUserApprover = false;
        Boolean isPriceReviewer = false;
        Boolean isL1Approver = false;
        Boolean isL2Approver = false;
        Boolean isLegalReviewer = false;
        Boolean isBusinessApprover = false;
        try{
            editCampWrap.isEditProposalAccess = true;
            editCampWrap.returnValue = '';
            String loggedInUserId = UserInfo.getUserId();
            Campaign campRecord = [SELECT Id ,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Claims_Created_Ind__c,Status,Core_MDF_Market__c,Core_MDF_Approval_Stage_nm__c,Core_MDF_Account__c, recordType.DeveloperName,Core_MDF_Ultimate_Account_txt__c,Core_MDF_Region_cd__c,Core_MDF_Sub_Region_cd__c,Core_MDF_Host_Region_cd__c,Core_MDF_Budget_Type_txt__c,Core_MDF_Program__c  from Campaign where Id = :campaignId];
            List<String> ctryList = new List<String>();
            
            if(recTypeDevloperName == Core_MDF_CCP_ConstantClass.CMP_CO_GTM_RECORDTYPE){
                if(campRecord.Core_MDF_Market__c != null && campRecord.Core_MDF_Market__c.contains(';')){
                    ctryList.addAll(campRecord.Core_MDF_Market__c.split(';'));
                } 
                else{
                    ctryList.add(campRecord.Core_MDF_Market__c);
                }
            }
            if(campRecord.Status == 'Pending Review'){ 
                //isPriceReviewer = true; 
                isL2Approver = Core_MDF_CampaignPFR_Controller.isCustomPermissionAssigned('Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver') == true ? true : false;
                //isPriceReviewer = Core_MDF_CampaignPFR_Controller.isCustomPermissionAssigned('Core_MDF_PriceReviewer') == true ? true : false;
                
                if(recTypeDevloperName == 'Core_MDF_Intel_Partner_Alliance'){
                    isL1Approver = Core_MDF_CampaignPFR_Controller.isCustomPermissionAssigned('Core_MDF_CCP_Int_IPA_ProposalL1_Approver') == true ? true : false;
                    isPriceReviewer = Core_MDF_CampaignPFR_Controller.isCustomPermissionAssigned('Core_MDF_PriceReviewer') == true ? true : false;
                }
                if(recTypeDevloperName == Core_MDF_CCP_ConstantClass.CMP_CO_GTM_RECORDTYPE){
                    isLegalReviewer = Core_MDF_CampaignPFR_Controller.isCustomPermissionAssigned('Core_MDF_CCP_Internal_Co_GTM_Legal_Reviewer') == true ? true : false;
                    isBusinessApprover = Core_MDF_CampaignPFR_Controller.isCustomPermissionAssigned('Core_MDF_PriceReviewer') == true ? true : false;
                }
            }  
            
            if(campRecord.Core_MDF_Approval_Stage_nm__c != null && 
               (campRecord.Core_MDF_Approval_Stage_nm__c == 'L1 approval' || campRecord.Core_MDF_Approval_Stage_nm__c == 'L2 approval' ||campRecord.Core_MDF_Approval_Stage_nm__c == 'L2 Regional Sales' || campRecord.Core_MDF_Approval_Stage_nm__c ==  'L2 Regional Marketing'
                || campRecord.Core_MDF_Approval_Stage_nm__c == 'Price Reviewer' || campRecord.Core_MDF_Approval_Stage_nm__c == 'Legal Reviewer' || campRecord.Core_MDF_Approval_Stage_nm__c == 'Business Approver') 
                && (((isPriceReviewer || isL1Approver) && recTypeDevloperName == 'Core_MDF_Intel_Partner_Alliance') || isL2Approver || ((isLegalReviewer || isBusinessApprover) && recTypeDevloperName == Core_MDF_CCP_ConstantClass.CMP_CO_GTM_RECORDTYPE))){
                    isUserApprover = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(campRecord, UserInfo.getUserId());
            }

            
            
            
            editCampWrap.isProposalBased = campRecord.Core_MDF_Proposal_Based_Ind__c;
            if (campRecord.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM && (campRecord.Status == Core_MDF_CCP_ConstantClass.CAMPAIGN_IN_PROGRESS || campRecord.Status == Core_MDF_CCP_ConstantClass.CAMPAIGN_PLANNED)) {
                editCampWrap.isClaimAssociated = checkClaimsAssociatedToCampaign(campaignId);
            } else {
                editCampWrap.isClaimAssociated = campRecord.Core_MDF_Claims_Created_Ind__c;
            }
            editCampWrap.isUserL1Approver = isL1Approver && isUserApprover ? true : false;
            editCampWrap.isUserL2Approver = isL2Approver && isUserApprover ? true : false;
            editCampWrap.isUserPriceReviewer = isPriceReviewer && isUserApprover ? true : false;
            editCampWrap.isUserLegalReviewer = isLegalReviewer && isUserApprover ? true : false;
            editCampWrap.isUserBusinessApprover = isBusinessApprover && isUserApprover ? true : false;
            
            if((recTypeDevloperName == 'Core_MDF_Intel_Partner_Alliance' || recTypeDevloperName == Core_MDF_CCP_ConstantClass.CMP_CO_GTM_RECORDTYPE) && campRecord.Core_MDF_Proposal_Based_Ind__c == true){  
                if(!isUserApprover)
                {
                    piwiList = [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Type, ProcessInstance.TargetObject.Name, 
                                ActorId FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :campaignId and ActorId = :loggedInUserId];                                 
                    if(Approval.isLocked(campaignId) && piwiList.isEmpty()){
                        editCampWrap.isEditProposalAccess = false;
                        editCampWrap.returnValue = System.label.Core_MDF_CloneAccessError;
                    }
                }
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        return editCampWrap;
    }
    
    /****************************************************************************************************** 
Method Name:        getSIOrISVAccounts
@return       :     Map<String, Id>
@parameters   :     Id,String
Description   :     To fetch the list of activating partners based on partner_mapping records and effective dates 
created By: Namratha        Date: 1st April 2024   
******************************************************************************************************/
    @AuraEnabled
    public static Map<String, Id> getSIOrISVAccounts(Id accountId){
        Map<String, Id> isvAccountsMap = new Map<String, Id>();
        List<Core_MDF_Partner_Mapping__c> isvAccountsList = new List<Core_MDF_Partner_Mapping__c>();
        String query = 'select Id, Core_MDF_Primary_Partner_Account_id__c, Name, Core_MDF_Activating_Partner_Account_id__c, Core_MDF_Activating_Partner_Account_id__r.Name from Core_MDF_Partner_Mapping__c where Core_MDF_Primary_Partner_Account_id__c =: accountId and Core_MDF_Effective_Start_Date__c<=TODAY and Core_MDF_Effective_End_Date__c>=TODAY';
        try {
            isvAccountsList = Database.query(query);
            for(Core_MDF_Partner_Mapping__c isvAcc: isvAccountsList) {
                isvAccountsMap.put(isvAcc.Core_MDF_Activating_Partner_Account_id__r.Name, isvAcc.Core_MDF_Activating_Partner_Account_id__c);
            }
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); throw new AuraHandledException(e.getMessage()); }
        return isvAccountsMap;
    }

        public static List<Id> getPartnerAccList(String partAcc){
            List<Id> partAccList = new List<Id>();
            if( String.isNotBlank(partAcc)){
                if(partAcc.contains(';')){
                    partAccList = (List<Id>)partAcc.split(';');
                }
                else{
                    Id pId = (Id)partAcc;
                    partAccList.add(pId);
                }
            }
            return partAccList;
        }

/****************************************************************************************************** 
Method Name:        saveCampToISVMapping
@return       :     void
@parameters   :     Campaign
Description   :     To create/update campaign to activating partners mapping based on user input 
created By: Namratha        Date: 1st April 2024   
******************************************************************************************************/
        @AuraEnabled
        public static void saveCampToISVMapping (Campaign camp) {
            Id cmpId = camp.Id;
            Map<Id,Core_MDF_Camp_to_ActPartner__c> accPartMap = new Map<Id,Core_MDF_Camp_to_ActPartner__c>();
            List<Id> actPartAccounts = new List<Id>();
            //List of activating partners selected by user
            List<Id> partnerAccList = (camp.Core_MDF_Partner_Mapping_Txt__c).split(';');
            //fetching list of existing Camp to actPartner Records
            List<Core_MDF_Camp_to_ActPartner__c> existingActPartners = [select id,Core_MDF_Activating_Partner_Account_id__c, Core_MDF_Campaign_Id__c,Core_MDF_Active_Ind__c from Core_MDF_Camp_to_ActPartner__c where Core_MDF_Campaign_Id__c=:cmpId];
            List<Core_MDF_Camp_to_ActPartner__c> campToISVList = new List<Core_MDF_Camp_to_ActPartner__c>();
            List<Core_MDF_Camp_to_ActPartner__c> updatedExistActPartList = new List<Core_MDF_Camp_to_ActPartner__c>();
            ChannelProgram prog = [select id , Core_MDF_Technical_Program_Name__c from ChannelProgram where Core_MDF_Technical_Program_Name__c='Ecosystem Extension Fund' limit 1];
            try {
                if(existingActPartners!=null && existingActPartners.size()>0){
                    for(Core_MDF_Camp_to_ActPartner__c aObj: existingActPartners){
                        accPartMap.put(aObj.Core_MDF_Activating_Partner_Account_id__c,aObj);
                        actPartAccounts.add(aObj.Core_MDF_Activating_Partner_Account_id__c);
                        Core_MDF_Camp_to_ActPartner__c partObj = new Core_MDF_Camp_to_ActPartner__c();
                        partObj.Id = aObj.Id;
                        if(partnerAccList!=null && !partnerAccList.contains(aObj.Core_MDF_Activating_Partner_Account_id__c) && aObj.Core_MDF_Active_Ind__c){
                            partObj.Core_MDF_Active_Ind__c = false;
                        }else if(partnerAccList!=null && partnerAccList.contains(aObj.Core_MDF_Activating_Partner_Account_id__c) && !aObj.Core_MDF_Active_Ind__c){
                            partObj.Core_MDF_Active_Ind__c = true;
                        }
                        
                        //Inactivate if partner mapping removed during edit
                        updatedExistActPartList.add(partObj);
                    }
                }
                for(Id accId : partnerAccList) {
                    //adding actPartner account during edit or during initial campaign creation
                    if((actPartAccounts!=null && (!actPartAccounts.contains(accId))) || actPartAccounts==null){
                        Core_MDF_Camp_to_ActPartner__c obj = new Core_MDF_Camp_to_ActPartner__c();
                        obj.Core_MDF_Campaign_Id__c = cmpId;
                        obj.Core_MDF_Activating_Partner_Account_id__c = accId;
                        obj.Core_MDF_Reimbursement_Rate_pct__c = ActPartner_RR_Pct;
                        obj.Core_MDF_Channel_Program__c=prog.Id;
                        obj.Core_MDF_External_ID__c = (String)cmpId + (String)accId;
                        obj.Core_MDF_Active_Ind__c = true;
                        campToISVList.add(obj);
                    }
                }
                if(updatedExistActPartList!=null && !updatedExistActPartList.isEmpty()){
                    campToISVList.addAll(updatedExistActPartList);
                }
                if(campToISVList!=null && !campToISVList.isEmpty()){
                    Database.upsert(campToISVList);
                }
            }
            catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); }
        }
    @AuraEnabled(cacheable=true)
    public static List<Core_MDF_Contract_Line_Item__c> getCampaignContractLineItems(Id parentId) {
        return [SELECT Id, Core_MDF_Contract_Section_Details_txt__c, Core_MDF_Contract_Section_Details_Histry__c from Core_MDF_Contract_Line_Item__c where Core_MDF_Campaign_Id__c = :parentId and Core_MDF_Inactive_Ind__c = false order by CreatedDate];
    }
    
    public static void saveCampaignContractLineItems(Id campaignId, List<Map<String, String>> contractLineItemRecordsToSave){
        List<Core_MDF_Contract_Line_Item__c> contractLineItemsToUpsert = new List<Core_MDF_Contract_Line_Item__c>();
        for (Map<String, String> record : contractLineItemRecordsToSave) {
            // Skip saving new blank contract line items
            if (record.get('type') == 'new' && (String.isBlank(record.get('value')) || record.get('value').trim() == '')) {
                continue;
            }
            // History field initialization
            String historyFieldValue = '';
            String currentUser = UserInfo.getName();
            String timestamp = String.valueOf(System.now());
            
            Core_MDF_Contract_Line_Item__c lineItem = new Core_MDF_Contract_Line_Item__c();
            
            // For existing records
            if (record.get('type') == 'existing') {
                lineItem.Id = record.get('Id');
                
                // If value is blank, mark the record as inactive and append "Deleted" to history
                if (String.isBlank(record.get('value'))) {
                    lineItem.Core_MDF_Inactive_Ind__c = true;
                    historyFieldValue = record.get('existingHistoryValue') + '\n' + 'Deleted by ' + currentUser + ' at ' + timestamp + '\n' + record.get('value');
                } else {
                    // In case of update append existing value and timestamp to history
                    historyFieldValue = record.get('existingHistoryValue') + '\n' + 'Updated by ' + currentUser + ' at ' + timestamp + '\n' + record.get('value');
                }                
            } else {
                // For new records add new value and timestamp to history
                lineItem.Core_MDF_Campaign_Id__c = campaignId;
                historyFieldValue = 'Created by ' + currentUser + ' at ' + timestamp + '\n' + record.get('value');
            }
            
            lineItem.Core_MDF_Contract_Section_Details_txt__c = record.get('value');
            
            // Check the size of the history field once all changes are appended
            if (historyFieldValue.length() <= 130000) {
                lineItem.Core_MDF_Contract_Section_Details_Histry__c = historyFieldValue;
            } else {
                lineItem.Core_MDF_Contract_Section_Details_Histry__c = historyFieldValue.substring(0, 130000);
            }
            contractLineItemsToUpsert.add(lineItem);
        }
        if(!contractLineItemsToUpsert.isEmpty()){
            try{
                upsert contractLineItemsToUpsert;
            }
            catch(Exception e){
                Core_MDF_CCP_UtilityClass.logError(e);
            }
        }
    }
    
    /****************************************************************************************************** 
    Method Name:        getInternalAndExternalUsersByAccount
    @return  :          Map of field name to list of records and default user
    @parameters:        Account Id and Ultimate Account Id
    Description:        This method is used to get IUPGM and PNUM records by account id
    Created By:         Accenture - Vikas Soni | Date: 10/04/2025
    Modified By:        Accenture - Vikas Soni | Date: 16/06/2025 | Changes: Core_MDF_CCP_Internal_Co_GTM_Technical_Approver enablement for Intel Verifier
    *******************************************************************************************************/ 
    @AuraEnabled(cacheable=false)
    public static Map<String, UserRecordsAndDefaultUserWrapper> getInternalAndExternalUsersByAccount(String selectedAccountId, String selectedAccParentFundAccId, String coGtmChannelProgramId) {
        try {
            if((selectedAccountId == null || selectedAccountId == '') || (selectedAccParentFundAccId == null || selectedAccParentFundAccId == '')){
                return null;
            }
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmRecordsList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            List<Core_MDF_Partner_Node_User_Mapping__c> pnumRecordsList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
            Map<String, UserRecordsAndDefaultUserWrapper> returnWrapperMap = new Map<String, UserRecordsAndDefaultUserWrapper>();
            Map<Id,DualListboxWrapper> accManagerIUPGMUserIdToIUPGMWrapperMap = new Map<Id,DualListboxWrapper>();
            Map<Id,DualListboxWrapper> techApprIUPGMUserIdToIUPGMWrapperMap = new Map<Id,DualListboxWrapper>();
            Map<Id,DualListboxWrapper> pnumUserIdToPNUMWrapperMap = new Map<Id,DualListboxWrapper>();
            
            //create default logged-in user
            DualListboxWrapper loggedInUser = new DualListboxWrapper(UserInfo.getUserId(), UserInfo.getName());
            
            //fetch IUPGM users
            Core_MDF_CCP_GenericUtility.QueryIUPGMRecordsWrapper queryIUPGMRecordsWrapperObj = new Core_MDF_CCP_GenericUtility.QueryIUPGMRecordsWrapper();
            queryIUPGMRecordsWrapperObj.psNameList = (new List<String>{'Core_MDF_CCP_Internal_Co_GTM_Account_Manager', 'Core_MDF_CCP_Internal_Co_GTM_Technical_Approver'});
            queryIUPGMRecordsWrapperObj.channelProgramIds = (new Set<Id>{Id.valueOf(coGtmChannelProgramId)});
            queryIUPGMRecordsWrapperObj.accountIdsForIUPGMSet = (new Set<Id>{Id.valueOf(selectedAccParentFundAccId)});
            queryIUPGMRecordsWrapperObj.isPermissionSetAssignmentBased = true;
            queryIUPGMRecordsWrapperObj.queryAllAccounts = true;
            queryIUPGMRecordsWrapperObj.isPSCheckReqForIUPGM = true;
            
            iupgmRecordsList = Core_MDF_CCP_GenericUtility.getIUPGMRecordsByWrapper(queryIUPGMRecordsWrapperObj);
            if(!iupgmRecordsList.isEmpty()){
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmRecordsList){
                    if(iupgm.Core_MDF_Role_nm__c == 'Core_MDF_CCP_Internal_Co_GTM_Technical_Approver') {
                        techApprIUPGMUserIdToIUPGMWrapperMap.put(iupgm.Core_MDF_User_id__c, new DualListboxWrapper(iupgm.Core_MDF_User_id__c, iupgm.Core_MDF_User_id__r.Name));
                    } else if(iupgm.Core_MDF_Role_nm__c == 'Core_MDF_CCP_Internal_Co_GTM_Account_Manager' && iupgm.Core_MDF_All_Accounts_cd__c == 'No'){                        
                        accManagerIUPGMUserIdToIUPGMWrapperMap.put(iupgm.Core_MDF_User_id__c, new DualListboxWrapper(iupgm.Core_MDF_User_id__c, iupgm.Core_MDF_User_id__r.Name));
                    }
                }                
            }
            UserRecordsAndDefaultUserWrapper accManagerIUPGMsWrapper = new UserRecordsAndDefaultUserWrapper();
            accManagerIUPGMsWrapper.defaultOptions = (new List<String>{String.valueOf(UserInfo.getUserId())});
            accManagerIUPGMsWrapper.options = accManagerIUPGMUserIdToIUPGMWrapperMap.values();            
            
            UserRecordsAndDefaultUserWrapper techApprIUPGMsWrapper = new UserRecordsAndDefaultUserWrapper();
            techApprIUPGMsWrapper.defaultOptions = (new List<String>{String.valueOf(UserInfo.getUserId())});
            techApprIUPGMsWrapper.options = techApprIUPGMUserIdToIUPGMWrapperMap.values();
            
            //fetch PNUM users
            Core_MDF_CCP_GenericUtility.QueryPNUMRecordsWrapper queryPNUMRecordsWrapperObj = new Core_MDF_CCP_GenericUtility.QueryPNUMRecordsWrapper();
            queryPNUMRecordsWrapperObj.psNameList = (new List<String>{'Core_MDF_CCP_External_Co_GTM_Project_Approver'});
            queryPNUMRecordsWrapperObj.channelProgramIds = (new Set<Id>{Id.valueOf(coGtmChannelProgramId)});
            queryPNUMRecordsWrapperObj.accountIdsForPNUMSet = (new Set<Id>{Id.valueOf(selectedAccountId)});
            queryPNUMRecordsWrapperObj.isPermissionSetAssignmentBased = true;
            queryPNUMRecordsWrapperObj.queryAllAccounts = false;
            
            pnumRecordsList = Core_MDF_CCP_GenericUtility.getPNUMRecordsByWrapper(queryPNUMRecordsWrapperObj);
            if(!pnumRecordsList.isEmpty()){
                for(Core_MDF_Partner_Node_User_Mapping__c pnum : pnumRecordsList){
                    pnumUserIdToPNUMWrapperMap.put(pnum.Core_MDF_User__c , new DualListboxWrapper(pnum.Core_MDF_User__c, pnum.Core_MDF_User__r.name));
                }
            }
            UserRecordsAndDefaultUserWrapper pnumsWrapper = new UserRecordsAndDefaultUserWrapper();
            if (pnumUserIdToPNUMWrapperMap.containsKey(UserInfo.getUserId())) {
                pnumsWrapper.defaultOptions = (new List<String>{String.valueOf(UserInfo.getUserId())});
            }
            pnumsWrapper.options = pnumUserIdToPNUMWrapperMap.values();
            
            returnWrapperMap.put('Core_MDF_Intel_Owner_id__c', accManagerIUPGMsWrapper);
            returnWrapperMap.put('Core_MDF_Member_Acceptor_id__c', pnumsWrapper);
            returnWrapperMap.put('Core_MDF_Intel_Verifier_id__c', techApprIUPGMsWrapper);
            return returnWrapperMap;
        } catch (Exception err) {
            Core_MDF_CCP_UtilityClass.logError(err);
            throw new AuraHandledException(err.getMessage());
        }
    }

     /****************************************************************************************************** 
    Method Name:        getAccountToBenefitsMap
    @return  :          Map of Intel/OPID account Id to the set of benefits
    Description:        This method is used to get the benefits associated to accounts
    Created By:         Accenture - Roshan | Date: 10/06/2025
    Modified By:  
    *******************************************************************************************************/ 
    public static Map<Id, Set<String>> getAccountToBenefitsMap(Boolean optAccountBenefitAssociation, String setOfGeneralizedAccountIdsStr) {

        Map<Id, Set<String>> accountToBenefitMap = new Map<Id, Set<String>>();
        
        Set<String> applicableBenefitsSet = new Set<String>();
        for (Core_MDF_BudgetType_Benefit_Mappings__c mdfPartnerBenefit : [SELECT Core_MDF_Partner_Benefit__c FROM Core_MDF_BudgetType_Benefit_Mappings__c WHERE Core_MDF_Program_Nm__c = :Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name') AND Core_MDF_IsActive__c = TRUE]) {
            applicableBenefitsSet.add(mdfPartnerBenefit.Core_MDF_Partner_Benefit__c);
        }
        String applicableBenefits = '(\'' + String.join(new List<String>(applicableBenefitsSet), '\', \'') + '\')';

        if (optAccountBenefitAssociation) {
            String query = 'SELECT PRM_Account_Id__c, PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c FROM PRM_AccountBenefitAssociation__c WHERE PRM_Account_Id__r.RecordType.DeveloperName = \'' + Label.PRM_Partner_Account_Group_Record_Type + '\' ' +
                        'AND PRM_Account_Id__c IN ' + setOfGeneralizedAccountIdsStr + ' AND PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c IN ' + applicableBenefits + ' AND PRM_Status_Nm__c = \'Active\'';

            List<PRM_AccountBenefitAssociation__c> accBenefitAssoc = Database.query(query);
            
            for (PRM_AccountBenefitAssociation__c aba : accBenefitAssoc) {
                if (!accountToBenefitMap.containsKey(aba.PRM_Account_Id__c)) {
                    accountToBenefitMap.put(aba.PRM_Account_Id__c, new Set<String>());
                }
                accountToBenefitMap.get(aba.PRM_Account_Id__c).add(aba.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c);
            }

        } else {
            String query = 'SELECT PRM_Account_Id__c, PRM_Specialty_Id__r.Name FROM PRM_Account_Specialty_Association__c WHERE PRM_Account_Id__c IN ' + setOfGeneralizedAccountIdsStr + ' ' +
                        'AND PRM_Specialty_Id__r.Name IN ' + applicableBenefits + ' ' + 'AND PRM_InActive_Ind__c = FALSE';
            
            List<PRM_Account_Specialty_Association__c> accSpecialtyAssoc = Database.query(query);

            for (PRM_Account_Specialty_Association__c asa : accSpecialtyAssoc) {
                if (!accountToBenefitMap.containsKey(asa.PRM_Account_Id__c)) {
                    accountToBenefitMap.put(asa.PRM_Account_Id__c, new Set<String>());
                }
                accountToBenefitMap.get(asa.PRM_Account_Id__c).add(asa.PRM_Specialty_Id__r.Name);
            }
        }

        return accountToBenefitMap;
    }

    /****************************************************************************************************** 
    Method Name:        getDomainsForAccount
    @return  :          List of domains
    Description:        This method is used to get the domains associated with accounts
    Created By:         Accenture - Aditya | Date: 28/06/2026
    Modified By:  
    *******************************************************************************************************/ 
    @AuraEnabled
    public static List<Core_MDF_Partner_Group_Domain_Mapping__c> getDomainsForAccount(String accountId) {
        try {
            if (String.isBlank(accountId)) {
                return new List<Core_MDF_Partner_Group_Domain_Mapping__c>();
            }

            List<Core_MDF_Partner_Group_Domain_Mapping__c> domains = [ SELECT Name FROM Core_MDF_Partner_Group_Domain_Mapping__c WHERE Core_MDF_Partner_Group_Mapping_Id__r.Core_MDF_Virtual_Corp_nm__c = :accountId and Core_MDF_Active_Ind__c = true];
            
            return domains;
        } catch (Exception err) {
            Core_MDF_CCP_UtilityClass.logError(err);
            throw new AuraHandledException(err.getMessage());
        }
    }
    
    public class EditCampaignLockWrapper {
        @AuraEnabled public Boolean isEditProposalAccess  { get; set; }
        @AuraEnabled public String returnValue  { get; set; }
        @AuraEnabled public Boolean isProposalBased  { get; set; }
        @AuraEnabled public Boolean isClaimAssociated { get; set; }
        @AuraEnabled public Boolean isUserL1Approver {get; set; }
        @AuraEnabled public Boolean isUserL2Approver {get; set; }
        @AuraEnabled public Boolean isUserPriceReviewer {get; set; }
        @AuraEnabled public Boolean isUserLegalReviewer {get; set; }
        @AuraEnabled public Boolean isUserBusinessApprover {get; set; }
    }
    
    public class AccountIdBudgetTypeWrapper {
        @AuraEnabled public Map<Id,Map<String,String>> accIdBudgetTypeMap  { get; set; }
    }
    
    public class CampaignBudgetWrapperClass {
        @AuraEnabled public Id campaignBudgetId { get; set; }
        @AuraEnabled public Boolean isActive { get; set; }
        @AuraEnabled public Id budgetId { get; set; }
        @AuraEnabled public String budgetName { get; set; }
        @AuraEnabled public Decimal budgetAmount { get; set; }
        @AuraEnabled public String budgetRR { get; set; }
        @AuraEnabled public Decimal budgetRAmount { get; set; }
    }
    
    public class FieldSetMemberWrapperClass {
        @AuraEnabled public Boolean isRequired { get; set; }
        @AuraEnabled public String fieldType { get; set; }
        @AuraEnabled public String fieldLabel { get; set; }
        @AuraEnabled public String fieldAPIName { get; set; }
        @AuraEnabled public String helpText { get; set; }
        @AuraEnabled public Map<String, String> pickListValues { get; set; }
    }
    
    @TestVisible private class PicklistValue{
        @AuraEnabled public string label;
        @AuraEnabled public string value;
    }
    
    public class CampaignWrapper {
        List<Campaign> campaignObj;
        List<CampaignBudgetWrapperClass> campaignBudgets;
    }
    public class ActivityFieldSVisibility {
        @AuraEnabled public String fieldLabel { get; set; }
        @AuraEnabled public String fieldAPIName { get; set; }
    }
    public class ipaAmountFieldsWrapper {
    @AuraEnabled
    public string totalCampaignCost{get;set;}
    @AuraEnabled
    public string reimbursementAmount{get;set;}
    }
    public class CampISVMapWrapper {
        @AuraEnabled public Id accountId { get; set; }
        @AuraEnabled public String reimbursementRate { get; set; }
        @AuraEnabled public String accName { get; set; }
    }
    public class primPartIUPGMAccWrapper {
        @AuraEnabled public boolean allAccountsFlag { get; set; }
        @AuraEnabled public List<Id> iupgmUltimateAccountIds { get; set; }
    }
    
    public class UserRecordsAndDefaultUserWrapper{
        @AuraEnabled public List<String> defaultOptions {get;set;}
        @AuraEnabled public List<DualListboxWrapper> options {get;set;}
        
        public UserRecordsAndDefaultUserWrapper() {
            this.defaultOptions = new List<String>();
            this.options = new List<DualListboxWrapper>();
        }
    }
    
    public class DualListboxWrapper{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        
        public DualListboxWrapper(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }

    public class ActivityToActivityAttributesWrapper{
        @AuraEnabled public PartnerFundRequest activity {get;set;}
        @AuraEnabled public List<Core_MDF_Activity_Attributes__c> activityAttribute {get;set;}
        
        public ActivityToActivityAttributesWrapper() {
            this.activity = new PartnerFundRequest();
            this.activityAttribute = new List<Core_MDF_Activity_Attributes__c>();
        }
        public ActivityToActivityAttributesWrapper(PartnerFundRequest activity, List<Core_MDF_Activity_Attributes__c> activityAttribute) {
            this.activity = activity;
            this.activityAttribute = activityAttribute;
        }
    }
}