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

public without sharing class Core_MDF_PartnerFundClaim {
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
            }else{   return null; }
        }catch(Exception e){
            System.debug('Exception'+e);
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
            List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();         
            if(auditDocList != null && auditDocList.size() >0){
                for(Core_MDF_Audit_Document__c auditDoc : auditDocList){
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
                if(auditDocList != null && auditDocList.size() > 0){
                    Database.insert(auditDocList);
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
                                              Core_MDF_Brand__c,toLabel(Core_MDF_Country_nm__c) countryNameLocalized,Core_MDF_Country_nm__c,Status,Core_MDF_Fund_Request_Status__c,Title,
                                              Core_MDF_TargetAudience__c,Core_MDF_Reimbursement_Rate__c,
                                              ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name,
                                              ChannelPartner.Name,ChannelPartner.Id,RecordType.DeveloperName
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
        
        try {
            Map<String,String> optionlist = new Map<String,String>();
            Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
            Map<String, Schema.SObjectField> fieldmap = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap(); 
            List<Schema.PicklistEntry> picklistValues = fieldmap.get(fieldApiName).getDescribe().getPickListValues();
            
            for (Schema.PicklistEntry pv : picklistValues) {
                optionlist.put(pv.getValue(),pv.getLabel());
            }
            return optionlist;
            
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            return null;
        }
        
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
        try {
            Set<String> bankStatusSet = new Set<String>();
            String bankStatusList = System.label.Core_MDF_Claim_Bank_StatusList;
            if(!String.IsBlank(bankStatusList)){
                for(String bankStatus : bankStatusList.split(';')){
                    bankStatusSet.add(bankStatus);
                }
            } 
            List<sObject> listValues = [SELECT Core_MDF_Bank__r.Id, Core_MDF_Bank__r.Name, Core_MDF_Bank__r.Core_MDF_Bank_Status__c, Core_MDF_Bank__r.Core_MDF_Bank_Alias_Name__c FROM Core_MDF_Account_Bank_Mapping__c Where Core_MDF_Bank__r.Core_MDF_Bank_Status__c IN: bankStatusSet and Core_MDF_Account__r.id =: accountId and Core_MDF_Active_ind__c=TRUE];
            return listValues;
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null;}
        
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
        try {
            List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
            claimList.add(newClaim);
            List<PartnerFundClaim> duplicateClaimList = Core_MDF_Claim_Utility.duplicateClaimCheckOnInsert(claimList);
            return duplicateClaimList;
        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }     
    
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
        // try {
        // query current user information  
        User oUser = [select id,Name,Email,FirstName,LastName,IsActive,IsPortalEnabled,UserType 
                      FROM User Where id =: userInfo.getUserId()];
        return oUser;
        //} catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
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
            UserInfoWrapper userInfoWrap = new UserInfoWrapper(); 
            // query current user information 
            userInfoWrap.userInfo =[select id,Name,Email,FirstName,LastName,IsActive,IsPortalEnabled,UserType 
                                    FROM User Where id =: userInfo.getUserId()];
            //checking if user has custom permission to create claim on closed activity
            userInfoWrap.isUserClaimCaseReviewerOrManager = FeatureManagement.checkPermission(Label.Core_MDF_ClaimCaseReviewerManager);
            //Core_MDF_PaymentAdmin
            userInfoWrap.isUserPaymentAdmin = FeatureManagement.checkPermission(Label.Core_MDF_PaymentAdmin);
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
    public static Map<String,String> fetchRecordTypeMetaData(){
        Map<String,String> mapOfRecordTypes = new Map<String,String>();
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt recTypeMetaData:[Select Id,Core_MDF_Activity_RecordType_txt__c,Core_MDF_Allocation_RecordType_txt__c,Core_MDF_Claim_RecordType_txt__c,Core_MDF_Enable_Fund_Reservation_chk__c 
                                                                       from Core_MDF_ClaimActAllocRecTypeMapping__mdt]){
                                                                           mapOfRecordTypes.put(recTypeMetaData.Core_MDF_Claim_RecordType_txt__c,recTypeMetaData.Core_MDF_Activity_RecordType_txt__c);  
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
            Core_MDF_Escalation__c escalationObj = [SELECT Id,Name FROM Core_MDF_Escalation__c WHERE Id=:escalationId LIMIT 1];
            
            if(escalationObj != null){
                return escalationObj;
            }
            else{return null;}
        }catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e); return null; }
    }
}