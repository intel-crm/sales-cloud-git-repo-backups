/*********************************************************************************************************************
Class Name    : PRM_MatchingAccounts
Version       : 1.0
Created Date  : June 2019
Function      : Displaying CIM results and matching account results 

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Rahul Kainth/Nishant      13 June,2019            Displaying CIM results and matching account results
* Nishant Dhar              13 Feb,2020             Modified to display sorted results for Matched Accounts
* Shraddha More             26 Nov 2023             Displaying UCD SBR Results Instead of CIM
*********************************************************************************************************************/
public without sharing class PRM_MatchingAccounts {
            
    public static Map<String, String> defaultPartnerRoleBizType = new Map<String, String>();
    public static Map<Id, List<PRM_AccountChannelMembership__c>> acc_acmMap = new Map<Id, List<PRM_AccountChannelMembership__c>>();
    //public static boolean ipaRefresh = Boolean.valueOf(label.PRM_IPARefresh);
    //blocked account:
    @AuraEnabled
    public static map<string,boolean> getBlockedAccount(list<String> accntId){
        system.debug('accntId'+accntId);
        //Id blocedAccContRT = Schema.getGlobalDescribe().get('PRM_SBC_Account_Search_Configuration__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_BlockedAccountContacts').getRecordTypeId();
        Id blocedAccContRT = PRM_SBC_Account_Search_Configuration__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_BlockedAccountContacts').getRecordTypeId();
       list<PRM_SBC_Account_Search_Configuration__c> ipaAdminConfigLst=[SELECT Id,RecordTypeId,PRM_Type__c, Account__c, Account__r.id,PRM_isActive__c, PRM_Contact__c, PRM_Contact__r.id, PRM_Contact__r.email,Email_Domain__c,
        Country__c, PRM_RegContactEmail__c  from PRM_SBC_Account_Search_Configuration__c  
        where RecordTypeId=:blocedAccContRT and Account__r.id IN:accntId and PRM_Type__c='Account_Blocked' and PRM_isActive__c=true];
        map<string,boolean> mapOfAccWithActive=new Map<String,Boolean>();
        if(ipaAdminConfigLst.size()>0){
            for(PRM_SBC_Account_Search_Configuration__c sbc:ipaAdminConfigLst){
                if(sbc.PRM_isActive__c){
                    mapOfAccWithActive.put(sbc.Account__r.id,true);
                   }else{
                    if(!mapOfAccWithActive.containsKey(sbc.Account__r.id))
                    mapOfAccWithActive.put(sbc.Account__r.id,false);
                   }
            }
            system.debug('ipaAdminConfigLst'+ipaAdminConfigLst);
            system.debug('mapOfAccWithActive'+mapOfAccWithActive);
        }
      
        return mapOfAccWithActive;
    }
    //Rahul added it as part of US584803
    /** @description      : Returning account result on the basis of account Id and Intel account Record Type
    *   @name             : searchAccount
    *   @param            : String accntId - Getting account Id from lightning component
    */
    @AuraEnabled
    public static MatchingAccountList searchAccount(String accntId){
        MatchingAccountList wrapperList = new MatchingAccountList();
        Boolean isAccountActive=false;
        String errorMsg = 'Please provide a valid Account Id with record type as Intel Account';
        Account acc;
        Account parentAcc;//TWC729-7054 - Nandana - new logic as part of removal of Core_Unified_Global_Customer__c
        //Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id intelaccountRT = Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        map<string,boolean> mapOfAccWithBlokedStatus=new Map<String,Boolean>(); 
        list<string> accIdList=new list<string>();
        try {
            accIdList.add(accntId);
            mapOfAccWithBlokedStatus=getBlockedAccount(accIdList);
            if(mapOfAccWithBlokedStatus.containsKey(accntId)){
                wrapperList.blockedAccount= mapOfAccWithBlokedStatus.get(accntId);
            }
            else{
                wrapperList.blockedAccount=false;
            }
            acc = [Select Id,Name,AccountNumber,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,/*Core_CIM_ID__c,*/Core_Intel_Partner_Alliance_PartnerGroup__c,
                  Core_Account_Type__c,toLabel(Core_IPA_Partner_Role__c),Industry,Owner.Name, Unified_Hierarchy_View__c, Core_Business_Party_Id__c, Core_Address_Details__c, 
                  RecordType.Name, Core_Export_Compliance_Block__c, Core_Unified_Global_Customer_BP_Id__c
                  from Account where Id =:accntId AND RecordTypeId = :intelaccountRT];
            if (acc != null) {
                wrapperList.accountList = acc;
                //TWC729-7054 - Nandana - new logic as part of removal of Core_Unified_Global_Customer__c
                if(acc.Core_Unified_Global_Customer_BP_Id__c!=null){
                    parentAcc = [Select id from Account where Core_Business_Party_Id__c =: acc.Core_Unified_Global_Customer_BP_Id__c];
                }
                if(parentAcc!=null){
                    wrapperList.parentAccId = parentAcc.id;
                }
                //TWC729-7054 - Nandana - new logic as part of removal of Core_Unified_Global_Customer__c
            }
        }catch(Exception e){
            PRM_ErrorUtilityClass.logError(e);
            if (acc == null) {
                wrapperList.errorMsg = errorMsg;
            }
        }
        return wrapperList;
    }
    
    //Added by bishal as part of US
    /** @description      : refresh matching accounts
    *   @name             : refreshRegistrationRequest
    */
    @AuraEnabled
    public static Id refreshRegistrationRequest(String recordId,Boolean checkExistingPartnerRole, String country, String state) {
        List<PRM_Registration_Request__c> regReqNew = new List<PRM_Registration_Request__c>();
        PRM_Registration_Request__c regReq = new PRM_Registration_Request__c();
        Id queueId;
        
        try {
            //get CIM Search Results matching with registration request Id
            
            regReqNew = [Select id, Name, PRM_Salesforce_ID__c,PRM_Account_Partner_Type__c,PRM_Account_URL__c,PRM_Zip_Postal_Code__c,PRM_CIMStatusDetails__c,PRM_State_Province__c,PRM_City__c,PRM_Company_Email_Domain__c,PRM_Account_Name__c,PRM_CIM_ID__c,PRM_Address_Line_1__c,PRM_Address_Line_2__c,PRM_Email_Verification_Criteria__c,PRM_country__c,PRM_Matching_Contact__c,PRM_Email_id__c,PRM_DeDup_Criteria__c,PRM_Dup_Status__c,PRM_Partner_Role__c,PRM_Partner_Type__c,PRM_Auto_Approve__c from PRM_Registration_Request__c where id=:recordId];
            
            regReq = regReqNew[0];
            // Code for the first row in CIM(only account details)
            if (regReq.PRM_Email_ID__c != null) {
                List<contact> conta = [select id,Email from Contact where Email =: regReq.PRM_Email_ID__c];
                
                if (conta!= null && conta.size()>0) {
                    regReq.PRM_Matching_Contact__c = conta[0].id;
                    update regReq;
                }
            }
            if (checkExistingPartnerRole == false) {
                //SBR CallOut
                PRM_SBRCallOut.sbrCallOut(regReq, true, country, state);
            }  
        }
        catch(exception ex) { throw new AuraHandledException(ex.getMessage());
        }
        return queueId;
    }
    
    /*MatchingAccountList*/
    public class MatchingAccountList {       
        @AuraEnabled
        public Map<string,Account> accountMap = new Map<string,Account>();
        @AuraEnabled
        public String accountContactEmail = '';
        @AuraEnabled
        public PRM_Registration_Request__c accList = new PRM_Registration_Request__c();
        @AuraEnabled
        public String errorMsg = '';
        @AuraEnabled
        public Account accountList;
        @AuraEnabled
        public String existingAccountContactEmail='';
        @AuraEnabled
        public String salesforceAccountId;
        @AuraEnabled
        public Account existingAccInfo;
        @AuraEnabled
        public Boolean isRegRequestDuplicate;
        @AuraEnabled
        public Boolean isExistingPartnerRole;
        @AuraEnabled
        public String existingContactPartnerRole = '';
        @AuraEnabled
        public Boolean accountExistingPartnerRoleACMCheck;
        @AuraEnabled
        public Boolean isAccountInactive; //Added by Vijay Agate as a part of TWC729-1727
        @AuraEnabled
        public Boolean isSysAccount;
        @AuraEnabled
        public String parentAccId;//TWC729-7054 - Nandana - new logic as part of removal of Core_Unified_Global_Customer__c
        @AuraEnabled
        public Boolean blockedAccount;
    }
    
    /*UCD SBR - Parameter Change*/
    @AuraEnabled
    public static String insertRecords(String regRequestId,Id AccountId,String recordId) {

        PRM_Registration_Req_Approve_Reject.isApprovedUsingButton = true;
        
        String stepId;
        List<PRM_Registration_Request__c> regRList = new List<PRM_Registration_Request__c>();
        List<PRM_Registration_Request__c> updatedRegistrations = new List<PRM_Registration_Request__c>();
        
        try { 
            
            regRList=  [Select id,CreatedDate, Name, OwnerId, PRM_Account_Name__c, PRM_Account_Partner_Type__c, PRM_Account_Phone__c, PRM_Account_URL__c, PRM_Address_Line_1__c, 
                        PRM_Address_Line_2__c, PRM_Auto_Approve__c, PRM_Channel_Program__c, PRM_Channel_Program_Level__c, PRM_CIM_ID__c, PRM_CIMStatusDetails__c, 
                        PRM_City__c, PRM_Company_Email_Domain__c, PRM_Company_National_ID__c, PRM_Company_Size__c, PRM_Contact_Country__c, 
                        PRM_Contact_Salesforce_Id__c, PRM_Country__c, PRM_DeDup_Criteria__c, PRM_Dup_Status__c, PRM_Email_Domain_Check__c, PRM_Email_ID__c, 
                        PRM_Email_Log__c, PRM_Email_Verification_Criteria__c, PRM_Enterprise_ID__c, PRM_EV_flag__c, PRM_First_Name__c, 
                        // PRM_isLocked__c, PRM_isSubmitted__c, PRM_Job_Function__c, PRM_Last_Name__c, PRM_Legal_Agreement_Criteria__c, PRM_Legal_Agreements__c, 
                        PRM_isLocked__c, PRM_isSubmitted__c, PRM_Profession__c, PRM_Last_Name__c, PRM_Legal_Agreement_Criteria__c, PRM_Legal_Agreements__c, 
                        PRM_manualRecordCheck__c, PRM_Matching_Contact__c, PRM_Partner_Relationship__c, PRM_Partner_Role__c, PRM_Partner_Segment__c, 
                        PRM_Partner_Type__c, PRM_PC_Approve_Reject_Flag__c, PRM_Person_Phone_Number__c, PRM_Phy_Address_Line_1__c, PRM_Phy_Address_Line_2__c, 
                        PRM_Phy_City__c, PRM_Phy_Country__c, PRM_Phy_State_Province__c, PRM_Phy_Zip_Postal_Code__c, PRM_Preferred_Language__c, 
                        PRM_ProcessInstanceWorkItem_Id__c, PRM_Profile_Response__c, PRM_Review_Note_txt__c, PRM_Salesforce_ID__c, PRM_State_Province__c, 
                        PRM_Status__c, PRM_Status_Reason__c, PRM_Subscriptions__c, PRM_Tax_ID_Registration__c, PRM_TriggerProcess__c, PRM_Wechat_Union_Id__c, 
                        PRM_Zip_Postal_Code__c,PRM_Channel_Program_Level_txt__c, PRM_Is_Returning_User__c,RecordTypeId from PRM_Registration_Request__c where Id=: regRequestId];            
            for (PRM_Registration_Request__c regR : regRList) {
                if ((regR.PRM_Status__c=='New' || regR.PRM_Status__c == 'Pending') && regR.PRM_Channel_Program_Level_txt__c== Label.PRM_Intel_Partner_Alliance && regR.RecordTypeid != /*Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId())*/PRM_Registration_Request__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId()) {
                    regR.PRM_Salesforce_ID__c = AccountId;
                    regR.PRM_TriggerProcess__c = true;
                    regR.PRM_Status__c = 'Approved';
                    updatedRegistrations.add(regR);
                    
                }
            }
            
             for(PRM_PartnerRoleTypeMappings__mdt Temp : [Select Id,PRM_Biz_Org_Type__c,PRM_Partner_Role__c from PRM_PartnerRoleTypeMappings__mdt where Grouping_Method__c != null]){
                defaultPartnerRoleBizType.put(Temp.PRM_Partner_Role__c,Temp.PRM_Biz_Org_Type__c);
            }
            processACMApprdPendList(AccountId);
            processUpdatedRegistrations(updatedRegistrations,regRequestId);
            stepId = callApprovalProcess(recordId, 'Approve', 'Existing account Reused for IPA.');
            
        }catch(Exception ex) { PRM_ErrorUtilityClass.logError(ex);
        }
        return stepId;
    }
    
    /* Process ACM*/
    private static void processACMApprdPendList(Id AccountId) {
        
        List<PRM_AccountChannelMembership__c> acmApprovedList =  new List<PRM_AccountChannelMembership__c>();
        List<PRM_AccountChannelMembership__c> acmPendingList =  new List<PRM_AccountChannelMembership__c>();
        try{
            for (PRM_AccountChannelMembership__c acm :[select id, PRM_Status_Nm__c,PRM_Partner_Role__c,PRM_Account_Id__c,PRM_Channel_Program_Level_Id__c from PRM_AccountChannelMembership__c 
                                                      where PRM_Account_Id__c =: AccountId and PRM_Status_Nm__c !='Inactive' ORDER BY CREATEDDATE ASC]) {
                                                          if (acm.PRM_Status_Nm__c == 'Approved') {
                                                              acmApprovedList.add(acm);
                                                          }
                                                          if(acm.PRM_Status_Nm__c == 'Pending'){
                                                              acmPendingList.add(acm);
                                                          }
                                                      }
            if(!acmApprovedList.isEmpty()){
                for(PRM_AccountChannelMembership__c approvedACM:acmApprovedList){
                    if(!acc_acmMap.containsKey(approvedACM.PRM_Account_Id__c)){
                        acc_acmMap.put(approvedACM.PRM_Account_Id__c,new List<PRM_AccountChannelMembership__c>{approvedACM});
                    } 
                }
            }
            if(!acmPendingList.isEmpty()){
                for(PRM_AccountChannelMembership__c PendingACM:acmPendingList){
                    if(!acc_acmMap.containsKey(PendingACM.PRM_Account_Id__c)){
                        acc_acmMap.put(PendingACM.PRM_Account_Id__c,new List<PRM_AccountChannelMembership__c>{PendingACM});
                    }
                }
            }
        }catch(Exception ex) { PRM_ErrorUtilityClass.logError(ex);
        }
    }
    
    /*Update Registration request*/
    private static void processUpdatedRegistrations(List<PRM_Registration_Request__c> updatedRegistrations,String regRequestId) {   
        List<PRM_Registration_Request__c> tobeUpdatedRR = new List<PRM_Registration_Request__c>();
            for (PRM_Registration_Request__c rq : updatedRegistrations) {
                List<String> bizList =new List<String>();
                /*if (rq.PRM_Account_Partner_Type__c!=null && !ipaRefresh) {
                    bizList =  String.valueOf(rq.PRM_Account_Partner_Type__c).split(';');
                }*/ //Switch Removal
                if (acc_acmMap!=null && !acc_acmMap.isEmpty() && acc_acmMap.containsKey(rq.PRM_Salesforce_ID__c)) {
                    List<PRM_AccountChannelMembership__c> acmList = acc_acmMap.get(rq.PRM_Salesforce_ID__c);    
                    if (acmList !=null && !acmList.isEmpty()) {                       
                        //if(!ipaRefresh)rq.PRM_Partner_Type__c = defaultPartnerRoleBizType.get((acmList[0].PRM_Partner_Role__c)); //Switch Removal
                        rq.PRM_Partner_Role__c = acmList[0].PRM_Partner_Role__c;                        
                    }
                }
                
                /*if(rq.PRM_Partner_Type__c!=null && !ipaRefresh){
                    if(!bizList.contains(rq.PRM_Partner_Type__c) ){
                        rq.PRM_Account_Partner_Type__c =rq.PRM_Partner_Type__c; //rq.PRM_Account_Partner_Type__c!=null?rq.PRM_Account_Partner_Type__c+';'+rq.PRM_Partner_Type__c:
                    }
                    tobeUpdatedRR.add(rq);
                }*/ //Switch Removal

                //if(ipaRefresh){
                    tobeUpdatedRR.add(rq);
                //}
            }  
            if(!tobeUpdatedRR.isEmpty()){
                update tobeUpdatedRR;
                List<PRM_Registration_Request__c> regRList01 = new List<PRM_Registration_Request__c>();
                regRList01=  [Select id,CreatedDate, Name, OwnerId, PRM_Account_Name__c, PRM_Account_Partner_Type__c, PRM_Account_Phone__c, PRM_Account_URL__c, PRM_Address_Line_1__c, 
                              PRM_Address_Line_2__c, PRM_Auto_Approve__c, PRM_Channel_Program__c, PRM_Channel_Program_Level__c, PRM_CIM_ID__c, PRM_CIMStatusDetails__c, 
                              PRM_City__c, PRM_Company_Email_Domain__c, PRM_Company_National_ID__c, PRM_Company_Size__c, PRM_Contact_Country__c, PRM_Contact_Login_ID__c, 
                              PRM_Contact_Salesforce_Id__c, PRM_Country__c, PRM_DeDup_Criteria__c, PRM_Dup_Status__c, PRM_Email_Domain_Check__c, PRM_Email_ID__c, 
                              PRM_Email_Log__c, PRM_Email_Verification_Criteria__c, PRM_EmailVerifiedDateTime__c, PRM_Enterprise_ID__c, PRM_EV_flag__c, PRM_First_Name__c, 
                              // PRM_isLocked__c, PRM_isSubmitted__c, PRM_Job_Function__c, PRM_Last_Name__c, PRM_Legal_Agreement_Criteria__c, PRM_Legal_Agreements__c, 
                              PRM_isLocked__c, PRM_isSubmitted__c, PRM_Profession__c, PRM_Last_Name__c, PRM_Legal_Agreement_Criteria__c, PRM_Legal_Agreements__c,                                         
                              PRM_manualRecordCheck__c, PRM_Matching_Contact__c, PRM_Partner_Relationship__c, PRM_Partner_Role__c, PRM_Partner_Segment__c, 
                              PRM_Partner_Type__c, PRM_PC_Approve_Reject_Flag__c, PRM_Person_Phone_Number__c, PRM_Phy_Address_Line_1__c, PRM_Phy_Address_Line_2__c, 
                              PRM_Phy_City__c, PRM_Phy_Country__c, PRM_Phy_State_Province__c, PRM_Phy_Zip_Postal_Code__c, PRM_Preferred_Language__c, 
                              PRM_ProcessInstanceWorkItem_Id__c, PRM_Profile_Response__c, PRM_Review_Note_txt__c, PRM_Salesforce_ID__c, PRM_State_Province__c, 
                              PRM_Status__c, PRM_Status_Reason__c, PRM_Subscriptions__c, PRM_Tax_ID_Registration__c, PRM_TriggerProcess__c, PRM_Wechat_Union_Id__c, 
                              PRM_Zip_Postal_Code__c,PRM_Channel_Program_Level_txt__c,PRM_Is_Returning_User__c, RecordTypeId from PRM_Registration_Request__c where Id=: regRequestId];
                PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(regRList01);
            }
    }
    /*get approval process details*/
    public static String callApprovalProcess(String recordId, String action, String comment) {
        String stepId1;    
            if (recordId != null &&  recordId != '') {
                List<ProcessInstanceWorkitem> ListWorkItems = [Select Id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstance.targetObjectId =: recordId];
                if (ListWorkItems != null && !ListWorkItems.isEmpty()) {
                String instanceId = ListWorkItems[0].ProcessInstanceId;
                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                req2.setComments(comment);//US846750: Updated automated comment while approving through reuse button.
                req2.setAction(action);
                req2.setWorkitemId(ListWorkItems[0].id);
                /*  Approval.ProcessResult result2 = */ Approval.process(req2);
                ProcessInstanceStep instanceStep = [Select Id,ProcessInstanceId,StepNodeId,StepStatus from ProcessInstanceStep where ProcessInstanceId=:instanceId AND StepStatus =: System.Label.PRM_Engagement_Status_Approved];
                stepId1=instanceStep.Id;
                }
            }
            

        return stepId1;
    }
}