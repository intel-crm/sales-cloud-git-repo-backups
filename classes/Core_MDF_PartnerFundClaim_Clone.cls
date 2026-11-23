/******************************************************************************************************
* Class Name  : Core_MDF_PartnerFundClaim 
* Version     : 1.0 
* Created Date: 10-30-2018
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Intel - SM      10/30/2018          Controller class for New Claim creation functionality
Aura enabled class calling from Create claim lightning component.
*******************************************************************************************************/

public without sharing class Core_MDF_PartnerFundClaim_Clone {
    /****************************************************************************************************** 
Method Name:        saveClaim
@return  :          String value (Upsert record Id / Failed)
@parameters:        PartnerFundClaim object
Description:        This method is used to create and save new claim data.
Added By:           Accenture - JV - 10/30/2018
Modified By:        Date:       Changes: 
Areefa          25-Sept-19    POP changes added to saveClaim method
*******************************************************************************************************/
    
   @AuraEnabled
    public static string saveClaim(PartnerFundClaim claim, List<Core_MDF_Audit_Document__c> auditDocList){
        try{
            List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
            if(claim != null){
                if(claim.Id == null){
                    Database.insert(claim);
                   
                } else
                {   
                     Database.update(claim);
                }   
                //call assignDocumentList to attach documents to claimID if documents are uploaded  
                if(claim.id!=null && auditDocList!=null && auditDocList.size()>0){
                    assignDocumentList(auditDocList,claim);
                }
                return claim.Id;
            }else{   return ''; }
        }catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            return 'Exception: '+e.getMessage();            
        }
    }
    /****************************************************************************************************** 
    Method Name:        assignDocumentList
    @return  :          boolean
    @parameters:        auditDocList and claimId
    Description:        This method is used to assignDocumentList to claimId .
    Added By:           Intel - Areefa - 15 Oct 2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static boolean assignDocumentList(List<Core_MDF_Audit_Document__c> auditDocList,PartnerFundClaim claim) {
        try {
            //list of content document link to be insert/update
            List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
            if(auditDocList != null && auditDocList.size() >0){
                for(Core_MDF_Audit_Document__c auditDoc : auditDocList){
                    //ContentDocumentLink instance will not be created , if record already exists
                    if(String.isBlank(auditDoc.Core_MDF_Claim__c)){
                        ContentDocumentLink conDocLink = new ContentDocumentLink();
                        auditDoc.Core_MDF_Claim__c = claim.Id;  
                        //Documents uploaded during claim edit should be attached over case as well.
                        if(claim.Core_MDF_Claim_Review_Case__c!=null){
                            auditDoc.Core_MDF_Audit__c = claim.Core_MDF_Claim_Review_Case__c;
                        }
                        conDocLink.ContentDocumentId = auditDoc.Core_MDF_Document_Id__c;    // documentId
                        conDocLink.LinkedEntityId = claim.Id;                                //LinkedEntityId: attaching to ClaimId
                        conDocLink.ShareType='I';
                        conDocLink.Visibility='AllUsers';
                        contentDocLinkList.add(conDocLink);
                    }
                }
                if(auditDocList != null && auditDocList.size() > 0){
                    Database.upsert(auditDocList); 
                }
                if(contentDocLinkList.size()>0){
                    Database.upsert(contentDocLinkList);
                }
                return true;
            }
            else { return false;}            
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
        
    }
    
    /****************************************************************************************************** 
Method Name:        getActivityFields
@return  :          PartnerFundRequest object
@parameters:        Activity record ID
Description:        This method is used to fetch record based on activity ID.
Added By:           Accenture JV- 10/30/2018
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static PartnerFundRequest getActivityFields(Id activityId){
        
        try{
            PartnerFundRequest activityObj = [SELECT Id,Core_MDF_Activity_Number__c,Core_MDF_ActivityCategory__c,Core_MDF_End_Date__c,
                                              Core_MDF_Start_Date__c,Core_MDF_Activity_Types__c,
                                              /*Core_MDF_Brand__c,*/toLabel(Core_MDF_Country_nm__c) countryNameLocalized,Status,Core_MDF_Country_nm__c,Core_MDF_Fund_Request_Status__c,Title,
                                              Core_MDF_TargetAudience__c,Core_MDF_Reimbursement_Rate__c,
                                              ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name,
                                              ChannelPartner.Name,ChannelPartner.Id,RecordType.DeveloperName, /*Core_MDF_Budget_Type_txt__c,*/ 
                                              RequestedAmount, Core_MDF_Program__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,
                                              CampaignId,Campaign.Name,Campaign.Description,toLabel(Core_MDF_Activity_SubType_nm__c) LocalizedActivitySubType,Core_MDF_Activity_SubType_nm__c,Core_MDF_POP_Requirements_txt__c,Core_MDF_Activity_Closure_Type__c
                                              FROM PartnerFundRequest WHERE Id=:activityId LIMIT 1];
            if(activityObj != null){
                return activityObj;
            }
            else{return null;}
        }catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }
    
    /****************************************************************************************************** 
Method Name:        getPickListvalues
@return  :          List<String>
@parameters:        Object Name and api name
Description:        This method is used to fetch pick list values for specific field.
Added By:           Accenture - AD - 11/1/2018
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static Map<String,String> getPickListvalues(String objectName, String fieldApiName){
             Map<String,String> optionlist = new Map<String,String>();
        try {
            Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
            Map<String, Schema.SObjectField> fieldmap = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap(); 
            List<Schema.PicklistEntry> picklistValues = fieldmap.get(fieldApiName).getDescribe().getPickListValues();
            
            for (Schema.PicklistEntry pv : picklistValues) {
                optionlist.put(pv.getValue(),pv.getLabel());
            }
            
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        return optionlist;
    }

    /****************************************************************************************************** 
Method Name:        fetchClaimSubmitters
@return  :          List<Id>
@parameters:        ultimateAccountId and techProgramName
Description:        This method is used to fetch claim submitters
Added By:           Accenture - VD - 03/12/2020
Modified By:        Date:      Changes: 
*******************************************************************************************************/    
    @AuraEnabled
    public static List<Id> fetchClaimSubmitters(Id ultimateAccountId, String techProgramName){
        Set<Id> listOfClaimSubId = new Set<Id>();   
        Map<Id,Id> contIdUserIdMap = new Map<Id,Id>();

        for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Core_MDF_Account__c, Core_MDF_User__c, Core_MDF_User__r.ContactId 
                                                          FROM Core_MDF_Partner_Node_User_Mapping__c 
                                                          WHERE Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c =: ultimateAccountId 
                                                          AND Core_MDF_User__r.IsActive = TRUE
                                                          AND Core_MDF_Account__r.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =: techProgramName])
        {
            contIdUserIdMap.put(pnum.Core_MDF_User__r.ContactId,pnum.Core_MDF_User__c);
        }
        Core_MDF_ChannelProgram__mdt channelProgRec = [Select Core_MDF_Technical_Program_Name__c,Core_MDF_ClaimSubEntitlementName_Txt__c 
                                                          from Core_MDF_ChannelProgram__mdt where Core_MDF_Technical_Program_Name__c =:techProgramName LIMIT 1];                  
        
        Set<String> claimSubEntNameSet = new Set<String>();
        if(channelProgRec != Null && channelProgRec.Core_MDF_ClaimSubEntitlementName_Txt__c != Null){
            claimSubEntNameSet.addAll(channelProgRec.Core_MDF_ClaimSubEntitlementName_Txt__c.split(';'));       
        }

        if(contIdUserIdMap!=null && contIdUserIdMap.size()>0 && claimSubEntNameSet != Null && claimSubEntNameSet.size()>0){
            for(Core_Contact_Entitlement__c contEnt : [select id,Core_Contact_Id__c, Core_Entitlement_Id__r.name 
                                                       from Core_Contact_Entitlement__c 
                                                       where Core_Contact_Id__c IN : contIdUserIdMap.keyset() 
                                                       AND Core_Selected__c = true AND Core_Status__c='Complete' 
                                                       AND Core_Entitlement_Id__r.name IN : claimSubEntNameSet])
            {        
                if(contIdUserIdMap.containskey(contEnt.Core_Contact_Id__c)){
                    listOfClaimSubId.add(contIdUserIdMap.get(contEnt.Core_Contact_Id__c));
                }                
            }
        }
        
        // Adding logic for to add mystery shopper user into the list, based on IUPGM
        if(techProgramName == Label.Core_MDF_Retail_Program_Name) {
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm:[SELECT id,Core_MDF_User_id__c FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c WHERE Core_MDF_User_id__r.IsActive = true and Core_MDF_Active_Ind__c = true and Core_MDF_Program_nm__c =: Label.Core_MDF_Retail_Program_Name and Core_MDF_Account_id__r.Core_MDF_CoMarketing_Ultimate_Account__c =:ultimateAccountId and Core_MDF_Role_nm__c =:Label.Core_MDF_CCP_PRC_ClaimSubmitter]) {
                if(iupgm.Core_MDF_User_id__c <> null) { listOfClaimSubId.add(iupgm.Core_MDF_User_id__c);                   
                }
            }
        }
        
        // Additionally adding the users from the exceptional permission set - Core_MDF_CCP_Internal_System_User
        for(PermissionSetAssignment psa: [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name =: 'Core_MDF_CCP_Internal_System_User']){
            if(!listOfClaimSubId.contains(psa.AssigneeId)){
                listOfClaimSubId.add(psa.AssigneeId);
            }
        }                    
        return new List<Id>(listOfClaimSubId);
    }
    
    
    /****************************************************************************************************** 
Method Name:        fetchBankRecords
@return  :          List<sObject>
@parameters:        N/A
Description:        This method is used to fetch bank object records
Added By:           Accenture - AD - 11/2/2018
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static List<sObject> fetchBankRecords(Id accountId){
        List<sObject> listValues= new List<sObject>();
        try {
            Set<String> bankStatusSet = new Set<String>();
            String bankStatusList = System.label.Core_MDF_Claim_Bank_StatusList;
            if(!String.IsBlank(bankStatusList)){
                for(String bankStatus : bankStatusList.split(';')){
                    bankStatusSet.add(bankStatus);
                }
            } 
            listValues = [SELECT Core_MDF_Bank__r.Id, Core_MDF_Bank__r.Name, Core_MDF_Bank__r.Core_MDF_Bank_Status__c, Core_MDF_Bank__r.Core_MDF_Bank_Alias_Name__c,Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c FROM Core_MDF_Account_Bank_Mapping__c Where Core_MDF_Bank__r.Core_MDF_Bank_Status__c IN: bankStatusSet and Core_MDF_Account__r.id =: accountId and Core_MDF_Active_ind__c=TRUE];
            
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
        return listValues;
    }
    
    /****************************************************************************************************** 
Method Name:        checkClaimFromActivity
@return  :          Wrapper which will hold Activity Record and Create Permission Flag
@parameters:        N/A
Description:        This method is used to fetch create permission and activity Record
Added By:           Accenture - AH - 11/7/2018
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static CreateClaimWrapper checkClaimFromActivity(String objectName,Id activityId){
        try {
            CreateClaimWrapper ccw = new CreateClaimWrapper();
            ccw.checkCreate= Core_MDF_checkSObjectCRUDPermission.checkSObjectCreatePermission(objectName);
            ccw.activityObj=getActivityFields(activityId);
            return ccw;
        } catch (Exception e) { 
            Core_MDF_CCP_UtilityClass.logError(e); 
            return null;
        }
    }
    
    /****************************************************************************************************** 
Class Name:        CreateClaimWrapper
@parameters:        N/A
Description:        Wrapper which will hold Activity Record and Create Permission Flag
Added By:           Accenture - AH - 11/7/2018
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    public class CreateClaimWrapper{
        @AuraEnabled   
        public PartnerFundRequest activityObj; 
        @AuraEnabled
        public Boolean checkCreate;
    }
    
    /***************************************************************************************************** 
Method Name:        duplicateClaimCheck
@return  :          List of Duplicate Claims from Database
@parameters:        claimList - This will contain all the pfc records to be inserted/updated.
Description:        Whenever a record is inserted/updated of Partner Fund Claim, this method checks whether the current record is duplicate or not
@Added By:          Accenture - AH - 11-11-2018
Modified By:        Date:       Changes: 
******************************************************************************************************/
    @AuraEnabled
    public static List<PartnerFundClaim> duplicateClaimCheck(PartnerFundClaim newClaim) {
        List<PartnerFundClaim> duplicateClaimList= new List<PartnerFundClaim>();
        try {
            List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
            claimList.add(newClaim);
            if(claimList!=null && claimList.size()>0){
            duplicateClaimList = Core_MDF_Claim_Utility.duplicateClaimCheckOnInsert(claimList);
            }
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}     
        return duplicateClaimList;
    }
    
    /****************************************************************************************************** 
Method Name:        isInternalAuditUser
@return  :          Boolean
@parameters:        String userId,String permissionName
Description:        This method is used to check the permission set over logged in user
Added By:           Accenture - AD - 11/26/2018
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static Boolean isInternalAuditUser(String custPermissionName){
        Boolean isAuditUser = false;
        try {
            Boolean hasCustomPermission = FeatureManagement.checkPermission(custPermissionName);
            if(hasCustomPermission){
                isAuditUser=true;
            }
            return isAuditUser;
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }
    
    /****************************************************************************************************** 
Class Name:        UserAndPicklistInfoWrapper
@parameters:        N/A
Description:        Wrapper which will hold logged in user and currency pickList information
Added By:           Accenture - AD - 12/12/2018
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    public class UserAndPicklistInfoWrapper{
        @AuraEnabled   
        public Map<String,String> pickListValuesMap; 
        @AuraEnabled
        public User userDtls;
    }  
    
    /****************************************************************************************************** 
Method Name:        fetchUserAndPicklistInfo
@return  :          Wrapper which will hold logged in user and currency pickList information
@parameters:        object name and field api name
Description:        This method is used to fetch Logged in user details and currency pickList values
Added By:           Accenture - AD - 12/12/2018
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static UserAndPicklistInfoWrapper fetchUserAndPicklistInfo(String objectName, String fieldApiName){
        try{
            UserAndPicklistInfoWrapper userAndPicklistWrapper = new UserAndPicklistInfoWrapper();
            userAndPicklistWrapper.pickListValuesMap= getPickListvalues(objectName, fieldApiName);
            userAndPicklistWrapper.userDtls=fetchLoggedInUserDetails();
            return userAndPicklistWrapper;
        }catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null;}
    } 
    
    /****************************************************************************************************** 
Method Name:        fetchLoggedInUserDetails
@return  :          User Info
@parameters:        N/A
Description:        This method is used to fetch Logged in user information
Added By:           Accenture - AH - 12/12/2018
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    
    @AuraEnabled 
    public static User fetchLoggedInUserDetails(){
        
        // query current user information  
        User oUser = [select id,Name,Email,FirstName,LastName,IsActive,IsPortalEnabled,UserType 
                      FROM User Where id =: userInfo.getUserId()];
        return oUser;        
    }
    
    /****************************************************************************************************** 
Class Name:        UserInfoWrapper
@parameters:        N/A
Description:        Wrapper which will hold logged in user information
Added By:           Accenture - VD - 14/06/2019
Modified By:        Date:      Changes: 
******************************************************************************************************/
    public class UserInfoWrapper{
        @AuraEnabled
        public User userInfo;
        @AuraEnabled
        public Boolean isUserClaimCaseReviewerOrManager;
        @AuraEnabled
        public Boolean isUserPaymentAdmin;
        @AuraEnabled
        public Boolean isRetailClaimSubmitter;
        @AuraEnabled
        public Boolean isRMFPRCClaimOperation;
    }
    
    /****************************************************************************************************** 
Method Name:        fetchUserDetails
@return  :          Wrapper
@parameters:        N/A
Description:        This method is used to fetch Logged in user information
Added By:           Accenture - VD - 14/06/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    
    @AuraEnabled 
    public static UserInfoWrapper fetchUserDetails(){
        try {
            String pRCRMFClaimOperationCustPerName = Core_MDF_Configuration__c.getValues('PRC_CLAIM_OPERATION_CUSTOM_PERMISSION').Core_MDF_Value__c;
            UserInfoWrapper userInfoWrap = new UserInfoWrapper(); 
            // query current user information 
            userInfoWrap.userInfo =[select id,Name,Email,FirstName,LastName,IsActive,IsPortalEnabled,UserType 
                                    FROM User Where id =: userInfo.getUserId()];
            //checking if user has custom permission to create claim on closed activity
            userInfoWrap.isUserClaimCaseReviewerOrManager = FeatureManagement.checkPermission(Label.Core_MDF_ClaimCaseReviewerManager);            
            //Core_MDF_PaymentAdmin
            userInfoWrap.isUserPaymentAdmin = FeatureManagement.checkPermission(Label.Core_MDF_PaymentAdmin);            
            //Retail Claim Submitter
            userInfoWrap.isRetailClaimSubmitter = FeatureManagement.checkPermission(Label.Core_MDF_RetailClaimSubmitter); 
            userInfoWrap.isRMFPRCClaimOperation = FeatureManagement.checkPermission(pRCRMFClaimOperationCustPerName);//added by vaishali to check if user is RMF PRC Internal claim submitter
            return userInfoWrap;
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }
    
    /****************************************************************************************************** 
Method Name:        fetchRecordTypeMetaData
@return  :          Map of claim and activity recordtype 
@parameters:        N/A
Description:        This method is used to fetch record type meta data and create a map
Added By:           Accenture - AD - 3/4/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/    
    @AuraEnabled
    public static Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt> fetchRecordTypeMetaData(){
        Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt> mapOfRecordTypes = new Map<String,Core_MDF_ClaimActAllocRecTypeMapping__mdt>();
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt recTypeMetaData:[Select Id,Core_MDF_Claim_Activity_Name_Swap_Ind__c,Core_MDF_POP_Mandatory_Ind__c,Core_MDF_Activity_RecordType_txt__c,Core_MDF_Allocation_RecordType_txt__c,Core_MDF_Claim_RecordType_txt__c,Core_MDF_Enable_Fund_Reservation_chk__c 
                                                                       from Core_MDF_ClaimActAllocRecTypeMapping__mdt]){
                                                                           mapOfRecordTypes.put(recTypeMetaData.Core_MDF_Claim_RecordType_txt__c,recTypeMetaData);
                                                                       }
        return mapOfRecordTypes;
    }
    
    /****************************************************************************************************** 
Method Name:        getEscalationFields
@return  :          Escalation object
@parameters:        Escalation record ID
Description:        This method is used to fetch record based on escalation ID.
Added By:           Accenture AD - 3/4/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled
    public static Core_MDF_Escalation__c getEscalationFields(Id escalationId){    
        try{
            Core_MDF_Escalation__c escalationObj = [SELECT Id,Name,RecordType.DeveloperName,Core_MDF_Claim_Submitter_Id__c FROM Core_MDF_Escalation__c WHERE Id=:escalationId LIMIT 1];            
            if(escalationObj != null){
                return escalationObj;
            }
            else{return null;}
        }catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }
    
    /****************************************************************************************************** 
    Method Name:        ckeckProgramLEForVatOptIn
    @return  :          Boolean value
    @parameters:        Bank'sLegal Entity, CLaim's Program
    Description:        This method returns whether for Selected Banks legal Entity and Claim's 
                        Program Will the Vat Process would be Required Or will be Optional for the User
    Added By:           Pranav - 20/01/2021
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/

    @AuraEnabled
    public static Boolean ckeckProgramLEForVatOptIn(String legalEntity, String channelProgram){
        
        // Query Vat Config metadata for Selected legal Entity and Channel Program
        // For Mandatory Vat - Core_MDF_VAT_Mandatory__c is checked and return false
        // For Optional Vat - Core_MDF_VAT_Opt_in_Option_Required__c is checked and return true Else Return NULL
        List<Core_MDF_CCP_VAT_Config__mdt> vatConfigList = new List<Core_MDF_CCP_VAT_Config__mdt>();            
        vatConfigList = [Select DeveloperName,MasterLabel,Core_MDF_VAT_Mandatory__c,Core_MDF_Program__c,Core_MDF_VAT_Opt_in_Option_Required__c,Core_MDF_Legal_Entity__c from Core_MDF_CCP_VAT_Config__mdt WHERE Core_MDF_Legal_Entity__c =:legalEntity AND Core_MDF_Program__c =:channelProgram AND Core_MDF_Is_Active__c =: true limit 1];
        // Return false if Core_MDF_VAT_Mandatory__c is true
        if(vatConfigList!=null && vatConfigList.size()>0 && vatConfigList[0].Core_MDF_VAT_Mandatory__c){
            return false;                
        }
        // Return true if Core_MDF_VAT_Opt_in_Option_Required__c is true
        else if(vatConfigList!=null && vatConfigList.size()>0 && vatConfigList[0].Core_MDF_VAT_Opt_in_Option_Required__c){
            return true;
        }
        // If both checkboxes are untrue return Null
        else{ 
            return null;
        }        
    }
}