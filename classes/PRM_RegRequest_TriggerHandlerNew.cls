/*********************************************************************************************************************
Apex Class Name  : PRM_RegRequest_TriggerHandlerNew
Created Date  : 19 jan 2023
Function      : 
*********************************************************************************************************************/

public without sharing class PRM_RegRequest_TriggerHandlerNew extends TriggerHandler{
    public static boolean IPAfirstRun = true;
    public static boolean ER_AckFirstRun = true;
    public static boolean ER_DupFirstRun = true;
    public static boolean isBeforeUpdateRun = false;
    public static boolean trackereRun = true;
    public static Set<string> registrationTypes = ER_RegistrationUtility.GetRegistrationTypes((List<PRM_Registration_Request__c>)Trigger.new);
    public static boolean IPArejectionemail = false;
    public static Boolean IS_CIDAAS_ENABLED = !Test.isRunningTest()?Boolean.valueof(Label.PRM_CiDaaS_Enabled):True; //As Per CiDaaS Change
    public static boolean IPAAttributeCreationCalled = false;
    public static boolean isautoApproveEndUserRegistrationFirstRun = false;
    public static final String PRM_Success = 'SUCCESS';
    public static final String Pricing_Registration_request_for_new_User_EV = 'Pricing_Registration_request_for_new_User_EV';
    public static final String PRM_ACR_Status = 'Complete';
    public static final String PRM_Admin_Registration = 'Admin_Registration';
    public static final String PRM_Duplicate_Request = 'Duplicate Request';
    public static final String PRM_Email_Verification_Request = 'PRM_Email_Verification_Request';
    public static final String PRM_ENG = 'ENG';
    public static final String PRM_Fail = 'FAIL';
    public static final String PRM_Intel_Partner_Alliance = 'Intel Partner Alliance';
    public static final String PRM_Nodup = 'NODUP';
    public static final String PRM_Primary_Contact = 'Partner Admin';
    public static final String PRM_QueueGroup = 'Queue';
    public static final String PRM_Account_Creation ='New Account Creation';
    public static final String PRM_DupCheckFailure = 'Duplicate Check Failed';
    public static final String PRM_PartnerRoleNA = 'Partner Role NA for Auto Approval';
    public static final String PRM_EmailMismatch = 'Email Domain Mismatch';
    public static final String PRM_DiffAccount = 'User Associated with a Different Account';
    public static final String PRM_DupCheck = 'Duplicate Check Pending';
    public static final String PRM_Registration_request_Acknowledgement_Email = 'PRM_Registration_request_Acknowledgement_Email';
    public static final String PRM_Registration_request_for_new_User_EV_PSG = 'Registration_request_for_new_User_EV_PSG';
    public static final String PRM_Status_Rejected = 'Rejected';
    public static final String PRM_WorksFor = 'Employee';
    public static final String PSG_Licensing = 'PSG';
    public static final String IPA_Registration_Request_Rejection_Email = 'IPA_Registration_Request_Rejection_Email';
    
    
    public override void beforeInsert(){ 
       
        Map<Id, PRM_Registration_Request__c> oldRegReqMap = (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap;
        List<PRM_Registration_Request__c> regReqNewList = (List<PRM_Registration_Request__c>)Trigger.new;
        List<PRM_Registration_Request__c> regReqOldList = (List<PRM_Registration_Request__c>)Trigger.old;
        
        for(string registrationType : registrationTypes){
            if(registrationType != Label.RegistrationTypeProgram){
                if(isActive('ER_SetEVAndLanguage')){
                    ER_RegistrationUtility.SetEVAndLanguage((List<PRM_Registration_Request__c>)Trigger.new);
                }
                if(isActive('ER_Reject_Duplicate_ResultsInsert')){
                    ER_DuplicationUtility.rejectDuplicates((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }
                if(isActive('ER_Legal_Agreement_CheckInsert')){
                    ER_LegalAgreementUtility.updateLA((List<PRM_Registration_Request__c>)Trigger.new);
                }
                if(isActive('ER_Prfl_Resp_CheckInsert')){
                    //Added by Gaurav - Eloqua Lead field update - Project size, Project Time Frame
                    System.debug('before Update inside');
                    ER_RegistrationProfileResponse.getProfileResponseValues((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }                	
                if(isActive('ER_SetAssignedTo')){
                    //Added for Assigning Default value for Assigned to field on New Registration                
                    //Added By Quest
                    System.debug('inserting in Assign value');
                    ER_RegistrationUtility.setAssignedTo((List<PRM_Registration_Request__c>)Trigger.new);
                }               
            }else {
                Map<String,Core_Intel_System_Accounts__mdt> mapSysAcc = Core_Intel_System_Accounts__mdt.getAll();
                Map<String,Boolean> isSysAccMap = new Map<String,Boolean>();
                Set<Id> setExistingAcc = new Set<Id>();
                Map<Id, List<Contact>> mapAccIdToListContact = new Map<Id, List<Contact>>();
                Map<Id, Account> mapAccount= new Map<Id, Account>();
                Set<String> regEmail = new Set<String>();
                Set<Id> sysAccIdSet = new Set<Id>();
                List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
                Set<Id> accIds = new Set<Id>();
                Set<String> emails = new Set<String>();
                Map<Id, PRM_AccountChannelMembership__c> channelMembershipMap = new Map<Id, PRM_AccountChannelMembership__c>();
                Map<String, Contact> emailMap = new Map<String, Contact>();
                Map<Id, String> reqReqEmailMap = new Map<Id, String>();
                Set<String> bizOrgTypeSet = new Set<String>();
                Set<String> partnerRoleSet = new Set<String>();
                List<Id> salesforceIdList = new List<Id>();
                List<PRM_Registration_Request__c> validRegRequestList = new List<PRM_Registration_Request__c>();
                Map<Id, Set<String>> regSubcriptionMap = new Map<Id, Set<String>>();
                Group queueID = new Group();
                Map<String,Boolean> emailDomainMatch = new Map<string,Boolean>();
                Map<Id, Account> acctMap = new Map<Id, Account>();
                Set<Id> accIdSet = new Set<Id>();
                Set<String> regReqPartnerRoleSet = new Set<String>();
                // Custom label changed into static string - Code Optimization
                
                for (PRM_Registration_Request__c regReq : regReqNewList){
                    if(!isautoApproveEndUserRegistrationFirstRun){
                        if(String.isNotBlank(regReq.PRM_Email_ID__c)){
                            regEmail.add(regReq.PRM_Email_ID__c);
                        }
                        if(regReq.PRM_Salesforce_ID__c != null){
                            setExistingAcc.add(regReq.PRM_Salesforce_ID__c);
                        }
                    }
                    
                    //PRM_RegistrationRequestUtility.applyRecordType
                    if(isActive('Assign_Record_Type_to_Reg_Requests') && String.isBlank(regReq.PRM_Preferred_Language__c)){ 
                            regReq.PRM_Preferred_Language__c = PRM_ENG;
                    }
                    
                    //PRM_RegistrationRequestUtility.evCheck((List<PRM_Registration_Request__c>)Trigger.new,null);
                    if(isActive('EV_Stamp_Check')){
                        regReq.PRM_EV_Token_Renewed_Date__c = datetime.now();
                        //As a part of CiDaaS change
                        if(IS_CIDAAS_ENABLED 
                           ||( regReq.PRM_EmailVerifiedDateTime__c != null 
                              && String.isNotBlank(String.valueOf(regReq.PRM_EmailVerifiedDateTime__c)))
                          ){
                              regReq.PRM_Email_Verification_Criteria__c = System.Label.PRM_Success;
                          }              
                    } 

                    //PRM_RegistrationRequestUtility.approveAdminRegRecords
                    if(isActive('Admin_Reg_Approve')
                        && regReq != null 
                        && regReq.RecordTypeid == PRM_IPA_Constants.ADMIN_REGISTRATION_RT 
                        && regReq.PRM_Salesforce_ID__c != null 
                        && String.isNotBlank(regReq.PRM_Salesforce_ID__c) 
                        && regReq.PRM_Status__c == 'New' 
                        && regReq.PRM_Email_Verification_Criteria__c == Label.PRM_Success
                    ){
                        accIdSet.add(regReq.PRM_Salesforce_ID__c);
                        regReqPartnerRoleSet.add(regReq.PRM_Partner_Role__c);
                    }
                    
                    //PRM_RegistrationRequestUtility.DecryptWeChatUnionId_BeforeInsert((List<PRM_Registration_Request__c>)Trigger.new); 
                    //It decrypts the WeChat Union Id
                    if(isActive('Req_Request_WeChatId_Decryption')){
                        regReq.PRM_Wechat_Union_Id__c = String.isEmpty(regReq.PRM_Wechat_Union_Id__c) 
                            ? regReq.PRM_Wechat_Union_Id__c : EncryptDecryptHelper.DecryptData(regReq.PRM_Wechat_Union_Id__c);
                    }
                    
                    // PRM_RegistrationRequestUtility.autoApproveEndUserRegistration
                    if(isActive('Auto_Approve_User_Registration')){
                        if(regReq.PRM_Partner_Type__c != null){
                            bizOrgTypeSet.add(regReq.PRM_Partner_Type__c);
                        }
                        if(regReq.PRM_Partner_Role__c != null){
                            partnerRoleSet.add(regReq.PRM_Partner_Role__c);
                        }
                        
                        if(regReq.RecordTypeId == PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT && regReq.PRM_Status__c == 'New'){
                            if(regReq.PRM_Email_Verification_Criteria__c ==PRM_Success &&
                               String.isNotBlank(regReq.PRM_Salesforce_ID__c) &&
                               String.isNotBlank(regReq.PRM_Partner_Role__c)
                              ){
                                  salesforceIdList.add(regReq.PRM_Salesforce_ID__c);
                                  reqReqEmailMap.put(regReq.PRM_Salesforce_ID__c, regReq.PRM_Email_ID__c );
                                  validRegRequestList.add(regReq);
                              }
                        }
                        if(String.IsNotBlank(regReq.PRM_Subscriptions__c)){
                            Set<String> subscriptionSet = new Set<String>();
                            subscriptionSet.addAll(regReq.PRM_Subscriptions__c.split(';'));
                            regSubcriptionMap.put(regReq.id, subscriptionSet);
                        }
                        // emailId = reg_Request.PRM_Email_ID__c.trim();
                        // emailDomain = emailId.substringAfter('@');
                        emailDomainMatch.put(regReq.PRM_Email_ID__c,false);
                    }   
                }
                
                for(String keySetString : mapSysAcc.keySet()){
                    sysAccIdSet.add(mapSysAcc.get(keySetString).AccountId__c);
                }
                
                if( !regEmail.isEmpty()){
                    for(Contact con : [SELECT Id, AccountId, Account.Core_IPA_Partner_Role__c, Email 
                                       FROM contact
                                       WHERE Email IN: regEmail
                                       OR AccountId IN: setExistingAcc]
                    ){
                        if(sysAccIdSet.contains(con.AccountId) && regEmail.contains(con.email) ){
                            if(!isSysAccMap.containskey(con.Email)){
                                isSysAccMap.put(con.Email, True);
                            }
                        }
                        if(setExistingAcc.contains(con.AccountId)){
                            if(mapAccIdToListContact.containsKey(con.AccountId)){
                                mapAccIdToListContact.get(con.AccountId).add(con);
                            }else{
                                mapAccIdToListContact.put(con.AccountId, new List<Contact>{con});
                            }
                        }
                        if(regEmail.contains(con.Email)){
                            emailMap.put(con.Email, con);
                        }     
                    }
                }
                
                if(!setExistingAcc.isEmpty() || !accIdSet.isEmpty()){
                    for(Account acc : [SELECT Id, Name, Core_IPA_Partner_Role__c, Core_Intel_Partner_Alliance_PartnerGroup__c, Core_Deactivated__c,
                                        (SELECT Id, Name, Email 
                                        FROM Contacts),
                                        (SELECT Id, PRM_Status_Nm__c, PRM_Account_Id__c, PRM_Channel_Program_Id__c, PRM_Partner_Role__c
                                        FROM Channel_Memberships1__r
                                        WHERE PRM_Account_Id__c IN :accIdSet
                                        AND PRM_Partner_Role__c IN :regReqPartnerRoleSet)
                                        FROM Account 
                                        WHERE Id IN :accIdSet
                                        OR id IN: setExistingAcc]
                    ){
                        if(setExistingAcc.contains(acc.Id)){
                            mapAccount.put(acc.id, acc);
                        }
                        if(accIdSet.contains(acc.Id)){
                            acctMap.put(acc.id, acc);
                        }
                    }
                }
                
                if( !setExistingAcc.isEmpty()){
                    for(PRM_AccountChannelMembership__c acm :[SELECT id, PRM_Status_Nm__c, PRM_Partner_Role__c, PRM_Account_Id__c, PRM_Channel_Program_Level_Id__c,
                                                              PRM_Account_Id__r.Core_Deactivated__c
                                                              FROM PRM_AccountChannelMembership__c 
                                                              WHERE  PRM_Account_Id__c IN :setExistingAcc]
                    ){
                        acmList.add(acm);
                    }
                }
                
                // PRM_RegistrationRequestUtility.applyRecordType((List<PRM_Registration_Request__c>)Trigger.new);
                if(isActive('Assign_Record_Type_to_Reg_Requests')){
                    queueID = [SELECT ID
                               FROM Group
                               WHERE type = :PRM_QueueGroup
                               AND DeveloperName = :System.Label.PRM_Manual_Approval_Members
                               LIMIT 1];
                }
                
                for(PRM_Registration_Request__c regRequest : regReqNewList){
                    if(isActive('Assign_Record_Type_to_Reg_Requests')
                        && emailMap != null 
                        && emailMap.containsKey(regRequest.PRM_Email_ID__c)
                        && String.isBlank(regRequest.PRM_Matching_Contact__c)
                        ){
                            regRequest.PRM_Matching_Contact__c = emailMap.get(regRequest.PRM_Email_ID__c).Id;
                        }
                    regRequest.OwnerId = queueID.id;
                }
                
                if(isActive('PSG_Approval_Check')){
                    PRM_PSG_RegistrationReqUtility.checkEVAndContactExistance(regReqNewList, null);         
                }
                //LA check needs to be implemented for admin reg req at time of insertion (for AccountCreateReq--> in before update)
                if(isActive('Legal_Agreement_Check')){
                    updateLA(regReqNewList);            
                }
                
                //US781670
                if(isActive('Reject_Duplicate_Results')){
                    rejectDuplicates(regReqNewList, oldRegReqMap);
                }
                
                if(isActive('Admin_Reg_Approve')){
                    approveAdminRegRecords(regReqNewList, acctMap);
                }
                
                if(isActive('Auto_Approve_User_Registration') && PRM_RegistrationRequestUtility.isautoApproveEndUserRegistrationFirstRun==false){            
                    isautoApproveEndUserRegistrationFirstRun=true;
                    autoApproveEndUserRegistration(regReqNewList,oldRegReqMap, isSysAccMap, mapAccIdToListContact , mapAccount, acmList, bizOrgTypeSet,
                                                   partnerRoleSet, salesforceIdList, reqReqEmailMap, validRegRequestList, regSubcriptionMap);
                }
                //IQR changes moved method call from before update to before insert as part of CidaaS - atb
                if(isActive('Pricing_RegRequest_Auto_Approve')){
                    Pricing_RegistrationReqUtility.autoApproveIQRRegReq((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }             
            }  
        }
    }
    
    public override void beforeUpdate(){
        for(string registrationType : registrationTypes){         
            if(registrationType != Label.RegistrationTypeProgram){
                //Has been inactivated as part of TWC722-734 CiDaas : Team Quest - ATB
                if(isActive('ER_Reject_Duplicate_Results')){
                    ER_DuplicationUtility.rejectDuplicates((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }
                //ER_EV_Check has been inactivated as part of TWC722-672 : Team Quest - Harshitha
                if(isActive('ER_EV_Check')){
                    ER_EmailVerificationUtility.UpdateEVCriteriaToSuccess((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }
                //Has been inactivated as part of TWC722-734 CiDaas : Team Quest - ATB
                if(isActive('ER_Legal_Agreement_Check')){
                    ER_LegalAgreementUtility.updateLA((List<PRM_Registration_Request__c>)Trigger.new);
                }
                
                //Has been inactivated as part of TWC722-734 CiDaas : Team Quest - ATB
                if(isActive('ER_Prfl_Resp_Check')){
                    //Eloqua Lead field update - Project size, Project Time Frame
                    System.debug('before Update inside');
                    ER_RegistrationProfileResponse.getProfileResponseValues((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }                
                system.debug('registrationTypes'+registrationTypes);     
            }
            else {
                List<PRM_Registration_Request__c> listREgReqForIQR= new List<PRM_Registration_Request__c>();
                Set<id> accountIds = new Set<Id>();
                Map<String, String> defaultPartnerRoleBizType = new Map<String, String>();
                Map<Id, List<PRM_Account_Contact_Relationship__c>> mapAccountIdTOListACR =  new Map<Id, List<PRM_Account_Contact_Relationship__c>>();
                List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
                Set<Id> setExistingAcc = new Set<Id>();
                Set<Id> setMatchingContact = new Set<Id>();
                Map<Id, Contact> contMap = new Map<Id, Contact>();
                Map<String, Contact> emailTOContMap = new Map<String, Contact>();
                Map<String,PRMPartner_Role_Biz_Type_Default_Mapping__mdt> mdRecrds = PRMPartner_Role_Biz_Type_Default_Mapping__mdt.getAll();
                Map<String,Core_Intel_System_Accounts__mdt> mapSysAcc = Core_Intel_System_Accounts__mdt.getAll();
                Set<Id> sysAccIdSet = new Set<Id>();
                Map<Id, Account> mapAccount= new Map<Id, Account>();
                Map<String,Boolean> isSysAccMap = new Map<String,Boolean>();
                Map<Id, List<Contact>> mapAccIdToListContact = new Map<Id, List<Contact>>();
                Map<Id, List<PRM_AccountChannelMembership__c>> mapAccToListACM = new Map<Id, List<PRM_AccountChannelMembership__c>>();
                Set<String> regEmail = new Set<String>();
                Map<Id, List<PRM_AccountChannelMembership__c>> acc_acmMap = new Map<Id, List<PRM_AccountChannelMembership__c>>();
                List<PRM_Registration_Request__c> updatedRegistrations = new List<PRM_Registration_Request__c>();
                Set<Id> existingAccFromReqIds = new Set<Id>();
                Map<Id, String> reqReqEmailMap = new Map<Id, String>();
                Set<String> bizOrgTypeSet = new Set<String>();
                Set<String> partnerRoleSet = new Set<String>();
                List<Id> salesforceIdList = new List<Id>();
                List<PRM_Registration_Request__c> validRegRequestList = new List<PRM_Registration_Request__c>();
                Map<Id, Set<String>> regSubcriptionMap = new Map<Id, Set<String>>();
                Map<String, PRM_Registration_Request__c> regReqToProcessMap = new Map<String, PRM_Registration_Request__c>();
                Map<String, String> processInstanceRegReqMap = new Map<String, String>();
                Map<String, String> regReqProcessInstanceWorkItemMap = new Map<String, String>();
                List<PRM_Registration_Request__c> regRequest = new List<PRM_Registration_Request__c>();
                String oldRT = '';
                Boolean verifyResponse = false;
                Boolean flag = false;
                Map<Id, Account> acctMap = new Map<Id, Account>();
                Set<Id> accIdSet = new Set<Id>();
                Map<String,Boolean> emailDomainMatch = new Map<string,Boolean>();
                Set<String> regReqPartnerRoleSet = new Set<String>();
                
                Map<Id, PRM_Registration_Request__c> oldRegReqMap = (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap;
                List<PRM_Registration_Request__c> regReqNewList = (List<PRM_Registration_Request__c>)Trigger.new;
                List<PRM_Registration_Request__c> regReqOldList = (List<PRM_Registration_Request__c>)Trigger.old;
                
                for (PRM_Registration_Request__c regReq :regReqNewList){
                    PRM_Registration_Request__c oldRegReq =  oldRegReqMap.get(regReq.Id);
                    
                    if((regReq.PRM_Status__c=='New' || regReq.PRM_Status__c=='Approved') 
                       && regReq.PRM_Channel_Program_Level_txt__c== Label.PRM_Intel_Partner_Alliance 
                       && regReq.RecordTypeid != PRM_IPA_Constants.ADMIN_REGISTRATION_RT
                    ){
                        accountIds.add(regReq.PRM_Salesforce_ID__c);
                        updatedRegistrations.add(regReq);
                    }else if(oldRegReq.PRM_Partner_Type__c != regReq.PRM_Partner_Type__c){
                        regReq.PRM_Account_Partner_Type__c = regReq.PRM_Partner_Type__c;
                    }                    
                    if(regReq.PRM_Matching_Contact__c != null){
                        setMatchingContact.add(regReq.PRM_Matching_Contact__c);
                    }
                    if(regReq.PRM_Salesforce_ID__c != null){
                        setExistingAcc.add(regReq.PRM_Salesforce_ID__c);
                    }
                    if(String.isNotBlank(regReq.PRM_Email_ID__c)){
                        regEmail.add(regReq.PRM_Email_ID__c);
                    }
                    
                    
                    // PRM_RegistrationRequestUtility.evCheck((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                    if(isActive('EV_Check')){
                        regReq.PRM_EV_Token_Renewed_Date__c = datetime.now();
                        //As a part of CiDaaS change
                        if(IS_CIDAAS_ENABLED 
                           || (regReq.PRM_EmailVerifiedDateTime__c != null && (regReq.PRM_Status__c != Label.PRM_Status_Rejected &&  oldRegReqMap.containsKey(regReq.Id) 
                                                                                   && (oldRegReqMap.get(regReq.Id).PRM_Email_Verification_Criteria__c == System.Label.PRM_Pending) 
                                                                                   && ((String.isBlank(String.valueOf(oldRegReqMap.get(regReq.Id).PRM_EmailVerifiedDateTime__c))) 
                                                                                       && String.isNotBlank(String.valueOf(regReq.PRM_EmailVerifiedDateTime__c)))))
                        ){
                            regReq.PRM_Email_Verification_Criteria__c = System.Label.PRM_Success;
                        }
                    }
                    
                    // PRM_RegistrationRequestUtility.autoApproveEndUserRegistration
                    if(isActive('Auto_Approve_User_Registration')){
                        if(regReq.PRM_Partner_Type__c != null){
                            bizOrgTypeSet.add(regReq.PRM_Partner_Type__c);
                        }
                        if(regReq.PRM_Partner_Role__c != null){
                            regReqPartnerRoleSet.add(regReq.PRM_Partner_Role__c);
                        }
                        
                        if(regReq.RecordTypeId == PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT && regReq.PRM_Status__c == 'New'){
                            if(regReq.PRM_Email_Verification_Criteria__c ==PRM_Success 
                            && String.isNotBlank(regReq.PRM_Salesforce_ID__c) 
                            && String.isNotBlank(regReq.PRM_Partner_Role__c)
                            ){
                                salesforceIdList.add(regReq.PRM_Salesforce_ID__c);
                                reqReqEmailMap.put(regReq.PRM_Salesforce_ID__c, regReq.PRM_Email_ID__c );
                                validRegRequestList.add(regReq);
                            }
                        }
                        
                        if(String.IsNotBlank(regReq.PRM_Subscriptions__c)){
                            Set<String> subscriptionSet = new Set<String>();
                            subscriptionSet.addAll(regReq.PRM_Subscriptions__c.split(';'));
                            regSubcriptionMap.put(regReq.id, subscriptionSet);
                        }
                        // emailId = reg_Request.PRM_Email_ID__c.trim();
                        // emailDomain = emailId.substringAfter('@');
                        emailDomainMatch.put(regReq.PRM_Email_ID__c,false);
                    }   
                    
                    // PRM_RegistrationRequestUtility.dupCheck((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                    if(isActive('Dup_Check')){
                        if(regReq.PRM_Channel_Program_Level_txt__c != System.Label.PSG_Licensing){
                            String oldRequestStatus = '';
                            if(regReq.PRM_Dup_Status__c == null){
                                regReq.PRM_Dup_Status__c = '';
                            }
                            if(oldRegReqMap != null){
                                if(oldRegReqMap.containsKey(regReq.Id)){
                                    oldRequestStatus = oldRegReqMap.get(regReq.Id).PRM_Dup_Status__c;
                                }
                            }
                            Boolean cimCall = true;
                            if((regReq.recordTypeId == PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT
                                && regReq.PRM_Status__c != Label.PRM_Status_Rejected 
                                && String.isNotBlank(regReq.PRM_Account_Name__c) 
                                && String.isNotBlank(regReq.PRM_Address_Line_1__c) 
                                && String.isNotBlank(regReq.PRM_Zip_Postal_Code__c) 
                                && String.isNotBlank(regReq.PRM_City__c) 
                                && ((String.isBlank(regReq.PRM_Dup_Status__c)) 
                                    || ((regReq.PRM_Dup_Status__c == 'NOT PROC') 
                                        && String.isNotBlank(oldRequestStatus) 
                                        && (oldRequestStatus == 'ERROR'))))
                               ||
                               ((regReq.recordTypeId == PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT) 
                                && (String.isNotBlank(regReq.PRM_Salesforce_ID__c)) 
                                && ((String.isBlank(regReq.PRM_Dup_Status__c)) 
                                    || ((regReq.PRM_Dup_Status__c == 'NOT PROC') 
                                        && String.isNotBlank(oldRequestStatus) 
                                        && (oldRequestStatus == 'ERROR'))))
                            ){
                                PRM_CIMCallout.prmCIMCalloutWrapper obj=new PRM_CIMCallout.prmCIMCalloutWrapper();
                                obj.regRequest=regReq;
                                obj.countReattempt=0;
                                obj.rcdLimit=null;
                                obj.searchScore=null;
                                obj.companyWebsite=null;
                                obj.cimCall=cimCall;
                                Id queueId = System.enqueueJob(new PRM_CIMCallout(obj));//Athr fixes
                                //Id queueId = System.enqueueJob(new PRM_CIMCallout(regReq, 0, null, null, null, cimCall));
                            }
                        }
                        
                        //PRM_RegistrationRequestUtility.setApprovalLink
                        if(isActive('Populate_Approval_Link')){
                            if(regReq.PRM_Status__c == 'New' 
                               && regReq.recordTypeId ==PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT
                               && String.isBlank(regReq.PRM_ProcessInstanceWorkItem_Id__c)
                            ){      
                                regReqToProcessMap.put(regReq.id, regReq);
                            }
                        } 
                        
                        //PRM_RegistrationRequestUtility.regResponse
                        if(isActive('Registration_Profile_Response')){
                            if(regReq.PRM_Status__c != Label.PRM_Status_Rejected){
                                oldRT = oldRegReqMap.get(regReq.Id).RecordTypeId;
                                System.debug('oldRT' + oldRT);
                                if(regReq.RecordTypeId != oldRT 
                                && regReq.RecordTypeId == PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT
                                ){
                                    regRequest.add(regReq);
                                }
                            }
                        }
                        
                        //PRM_RegistrationRequestUtility.DecryptWeChatUnionId_BeforeUpdate
                        if(isActive('Req_Request_WeChatId_Decryption')){
                            if(oldRegReqMap.get(regReq.Id).RecordTypeId != regReq.RecordTypeId 
                               && oldRegReqMap.get(regReq.Id).RecordTypeId == PRM_IPA_Constants.EV_RECORD_TYPE_ID 
                               && regReq.RecordTypeId == PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT
                              ){
                                  regReq.PRM_Wechat_Union_Id__c = String.isEmpty(regReq.PRM_Wechat_Union_Id__c)
                                      ? regReq.PRM_Wechat_Union_Id__c : EncryptDecryptHelper.DecryptData(regReq.PRM_Wechat_Union_Id__c);
                              }
                        }
                    }
                    
                }
                
                if(isActive('Partner_Relationship') && IPAfirstRun){
                    IPAfirstRun = false;
                }
                
                for(String keySetString : mapSysAcc.keySet()){
                    sysAccIdSet.add(mapSysAcc.get(keySetString).AccountId__c);
                }
                
                for(String mdt : mdRecrds.keySet()){               
                    defaultPartnerRoleBizType.put(mdRecrds.get(mdt).PRM_Partner_Role__c,mdRecrds.get(mdt).PRM_Bizorg_Type__c);
                }
                
                if(!setMatchingContact.isEmpty() || !regEmail.isEmpty() || !setExistingAcc.isEmpty()){
                    for(Contact con : [SELECT Id, AccountId, Account.Core_IPA_Partner_Role__c, Email 
                                       FROM Contact
                                       WHERE Id IN :setMatchingContact 
                                       OR Email IN :regEmail 
                                       OR AccountId IN :setExistingAcc]
                    ){
                        if(setMatchingContact.contains(con.id)){
                            contMap.put(con.id, con);
                        }
                        if(regEmail.contains(con.email)){
                            emailTOContMap.put(con.email, con);
                            contMap.put(con.id, con);
                        }
                        if(sysAccIdSet.contains(con.AccountId)){
                            if(!isSysAccMap.containskey(con.Email)){
                                isSysAccMap.put(con.Email, True);
                            }
                        }
                        if(setExistingAcc.contains(con.AccountId)){
                            if(mapAccIdToListContact.containsKey(con.AccountId)){
                                mapAccIdToListContact.get(con.AccountId).add(con);
                            }else {
                                mapAccIdToListContact.put(con.AccountId, new List<Contact>{con});
                            }
                        }
                    }
                }
                
                if(!setExistingAcc.isEmpty()){
                    for(Account acc: [SELECT Id, Core_IPA_Partner_Role__c, Name, Core_Intel_Partner_Alliance_PartnerGroup__c, Core_Deactivated__c,
                                                    (SELECT Id, Name, Email 
                                                    FROM Contacts),
                                                    (SELECT Id, PRM_Status_Nm__c, PRM_Account_Id__c, PRM_Channel_Program_Id__c, PRM_Partner_Role__c
                                                    FROM Channel_Memberships1__r
                                                    WHERE PRM_Account_Id__c IN :accIdSet
                                                    AND PRM_Partner_Role__c IN :regReqPartnerRoleSet)
                                                    FROM Account
                                                    WHERE Id IN :accIdSet                              
                                                    OR id IN: setExistingAcc
                                                    ]
                    ){
                        if(setExistingAcc.contains(acc.Id)){
                            mapAccount.put(acc.id, acc);
                        }
                        if(accIdSet.contains(acc.Id)){
                            acctMap.put(acc.id, acc);
                        }
                    }
                }
                
                if(!setExistingAcc.isEmpty()){
                    for(PRM_Account_Contact_Relationship__c acrRec : [SELECT Id, PRM_Account_Id__c, PRM_InActive_Ind__c, PRM_Partner_Role__c, PRM_Status_Nm__c, PRM_Relationship_Id__r.Name
                                                                      FROM PRM_Account_Contact_Relationship__c 
                                                                      WHERE PRM_Account_Id__c IN: setExistingAcc]
                    ){
                        if(mapAccountIdTOListACR.containsKey(acrRec.PRM_Account_Id__c)){
                            mapAccountIdTOListACR.get(acrRec.PRM_Account_Id__c).add(acrRec);
                        }else{
                            mapAccountIdTOListACR.put(acrRec.PRM_Account_Id__c, new List<PRM_Account_Contact_Relationship__c>{acrRec});
                        }
                    }
                }
                
                
                if(!accountIds.isEmpty() || !setExistingAcc.isEmpty()){
                    for(PRM_AccountChannelMembership__c acm :[SELECT id, PRM_Status_Nm__c, PRM_Partner_Role__c, PRM_Account_Id__c, PRM_Channel_Program_Level_Id__c,
                                                              PRM_Account_Id__r.Core_Deactivated__c
                                                              FROM PRM_AccountChannelMembership__c 
                                                              WHERE PRM_Account_Id__c IN :accountIds
                                                              OR PRM_Account_Id__c IN :setExistingAcc
                                                              ORDER BY CREATEDDATE ASC]
                    ){
                        acmList.add(acm);
                        if(acm.PRM_Status_Nm__c != 'Inactive' 
                           && (acm.PRM_Status_Nm__c == 'Approved' 
                               || acm.PRM_Status_Nm__c == 'Pending')
                        ){
                            if(!acc_acmMap.containsKey(acm.PRM_Account_Id__c)){
                                acc_acmMap.put(acm.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{acm});
                            }
                        }
                    }
                }
                
                for(PRM_Registration_Request__c regReq : regReqNewList){
                    PRM_Registration_Request__c oldRegReq =  oldRegReqMap.get(regReq.Id);
                    if(String.isBlank(regReq.PRM_Matching_Contact__c) 
                       && emailTOContMap.containsKey(regReq.PRM_Email_ID__c) 
                       && (regReq.PRM_Status__c == 'New' 
                           || (regReq.PRM_Status__c == 'Approved' 
                               && oldRegReqMap.get(regReq.id).PRM_Status__c == 'New'))
                    ){
                        regReq.PRM_Matching_Contact__c = emailTOContMap.get(regReq.PRM_Email_ID__c)?.Id;
                    }

                    if(regReq.PRM_Status__c=='Approved' 
                       && regReq.PRM_Status__c!=oldRegReq.PRM_Status__c 
                       && regReq.PRM_Channel_Program_Level_txt__c== Label.PRM_Intel_Partner_Alliance 
                    ){
                        regReq.PRM_IPA_Approved_Time__c=system.now();
                        List<String> bizList = new List<String>();
                        if(regReq.PRM_Account_Partner_Type__c != null){
                            bizList = String.valueOf(regReq.PRM_Account_Partner_Type__c).split(';');
                        }
                        if(acc_acmMap != null && !acc_acmMap.isEmpty() 
                           && acc_acmMap.containsKey(regReq.PRM_Salesforce_ID__c)
                           && (oldRegReqMap.get(regReq.Id).PRM_Partner_Role__c == null || regReq.PRM_Status__c == 'Approved')
                        ){
                            List<PRM_AccountChannelMembership__c> acmTempList = acc_acmMap.get(regReq.PRM_Salesforce_ID__c);       
                            if(acmTempList != null && !acmTempList.isEmpty()){
                                regReq.PRM_Partner_Type__c = defaultPartnerRoleBizType.get((acmTempList[0].PRM_Partner_Role__c));
                                regReq.PRM_Partner_Role__c = acmTempList[0].PRM_Partner_Role__c;
                            }
                        }
                        if(regReq.PRM_Partner_Type__c != null && !bizList.contains(regReq.PRM_Partner_Type__c)){
                            regReq.PRM_Account_Partner_Type__c = regReq.PRM_Partner_Type__c;     
                        }
                    } 
                    
                    //PRM_RegistrationRequestUtility.partnerrelationship((List<PRM_Registration_Request__c>)Trigger.new, mapAccountIdTOListACR, mapAccount, contMap,(List<PRM_Registration_Request__c>)Trigger.old);
                    if(isActive('Partner_Relationship') && IPAfirstRun){
                        if(regReq.recordTypeId == PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT  && regReq.PRM_Channel_Program_Level_txt__c != 'PSG'){
                            List<String> partnerRoleArray = new List<String>();
                            Account acct = new Account();
                            boolean isACRActive = null;
                            if(regReq.PRM_Salesforce_ID__c != null){
                                acct = mapAccount.get(regReq.PRM_Salesforce_ID__c);
                                if(acct.Core_IPA_Partner_Role__c != null){
                                    partnerRoleArray = acct.Core_IPA_Partner_Role__c.split(';');
                                }
                                if(mapAccountIdTOListACR.containsKey(acct.Id)){
                                    for(PRM_Account_Contact_Relationship__c acr : mapAccountIdTOListACR.get(acct.Id)){
                                        if(acr.PRM_Partner_Role__c == regReq.PRM_Partner_Role__c 
                                           && acr.PRM_Status_Nm__c == System.label.PRM_ACR_Status 
                                           && acr.PRM_InActive_Ind__c == false
                                           && acr.PRM_Status_Nm__c != 'Pending Action'
                                          ){
                                              isACRActive = true;
                                          }
                                    }
                                    if(isACRActive != true){
                                        isACRActive = false;
                                    }
                                }
                                else if(mapAccountIdTOListACR == null || mapAccountIdTOListACR.isEmpty()){//no ACR
                                    isACRActive = false;}
                            }else if(regReq.PRM_Matching_Contact__c != null){
                                Contact contactRec = new Contact();
                                if(contMap.containsKey(regReq.PRM_Matching_Contact__c)){
                                    contactRec = contMap.get(regReq.PRM_Matching_Contact__c);
                                }
                                if(contactRec != null && contactRec.Account.Core_IPA_Partner_Role__c != null){
                                    partnerRoleArray = contactRec.Account.Core_IPA_Partner_Role__c.split(';');
                                }
                            }
                            
                            for (PRM_Registration_Request__c oldreq : regReqOldList){
                                if((regReq.PRM_Partner_Relationship__c == null 
                                    || String.isBlank(regReq.PRM_Partner_Relationship__c) 
                                    || oldreq.PRM_Salesforce_ID__c != acct.Id 
                                    || regReq.PRM_Status__c == 'Approved')
                                ){
                                    if((!partnerRoleArray.contains(regReq.PRM_Partner_Role__c) 
                                        || isACRActive == false) 
                                        && !existingAccFromReqIds.contains(regReq.PRM_Salesforce_ID__c) //if(isACRActive == false)
                                    ){
                                        existingAccFromReqIds.add(regReq.PRM_Salesforce_ID__c);
                                        regReq.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact + ';' + System.Label.PRM_WorksFor;
                                    }else{
                                        regReq.PRM_Partner_Relationship__c = System.Label.PRM_WorksFor;
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                //PRM_RegistrationRequestUtility.updateBizAndPartnerRole(updatedRegistrations,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap, acmList, defaultPartnerRoleBizType);
                // if(!isBeforeUpdateRun && !acmList.isEmpty() && !updatedRegistrations.isEmpty()){
                //     isBeforeUpdateRun= true;
                //     for (PRM_AccountChannelMembership__c newACM : acmList){
                //         if(newACM.PRM_Status_Nm__c != 'Inactive' 
                //            && (newACM.PRM_Status_Nm__c == 'Approved' 
                //                || newACM.PRM_Status_Nm__c == 'Pending')
                //         ){
                //             if(!acc_acmMap.containsKey(newACM.PRM_Account_Id__c)){
                //                 acc_acmMap.put(newACM.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{newACM});
                //             }
                //         }
                //     }
                    
                    // for (PRM_Registration_Request__c rq : updatedRegistrations){
                    //     List<String> bizList = new List<String>();
                    //     if(rq.PRM_Account_Partner_Type__c != null){
                    //         bizList = String.valueOf(rq.PRM_Account_Partner_Type__c).split(';');
                    //     }
                    //     if(acc_acmMap != null && !acc_acmMap.isEmpty() 
                    //        && acc_acmMap.containsKey(rq.PRM_Salesforce_ID__c)
                    //        && (oldRegReqMap.get(rq.Id).PRM_Partner_Role__c == null || rq.PRM_Status__c == 'Approved')
                    //     ){
                    //         List<PRM_AccountChannelMembership__c> acmTempList = acc_acmMap.get(rq.PRM_Salesforce_ID__c);       
                    //         if(acmTempList != null && !acmTempList.isEmpty()){
                    //             rq.PRM_Partner_Type__c = defaultPartnerRoleBizType.get((acmTempList[0].PRM_Partner_Role__c));
                    //             rq.PRM_Partner_Role__c = acmTempList[0].PRM_Partner_Role__c;
                    //         }
                    //     }
                    //     if(rq.PRM_Partner_Type__c != null && !bizList.contains(rq.PRM_Partner_Type__c)){
                    //         rq.PRM_Account_Partner_Type__c = rq.PRM_Partner_Type__c;     
                    //     }
                    // }
                // }
                
                if(isActive('Reject_Duplicate_Results')){
                    rejectDuplicates(regReqNewList, oldRegReqMap);           
                }                
                
                if(isActive('PSG_Approval_Check')){
                    PRM_PSG_RegistrationReqUtility.checkEVAndContactExistance(regReqNewList, oldRegReqMap);
                }
                
                
                if(isActive('Legal_Agreement_Check')){
                    PRM_RegistrationRequestUtility.updateLA(regReqNewList);
                }
                
                if(isActive('Auto_Approve_User_Registration') && !isautoApproveEndUserRegistrationFirstRun){
                    isautoApproveEndUserRegistrationFirstRun =  true;
                    autoApproveEndUserRegistration(regReqNewList, oldRegReqMap, isSysAccMap, mapAccIdToListContact, mapAccount, acmList, 
                                                   bizOrgTypeSet, partnerRoleSet, salesforceIdList, reqReqEmailMap, validRegRequestList, 
                                                   regSubcriptionMap);
                }   
                
                
                
                if(isActive('Dup_Check')){       
                    if(isActive('Populate_Approval_Link')){
                        List<ProcessInstanceWorkitem> pwiList = new List<ProcessInstanceWorkitem>();
                        if(regReqToProcessMap != null && regReqToProcessMap.size() > 0){                           
                            for (ProcessInstanceWorkitem pwi : [
                                SELECT id, ProcessInstanceId, ProcessInstance.TargetObjectId  
                                FROM ProcessInstanceWorkitem Where ProcessInstance.TargetObjectId IN:regReqToProcessMap.keySet()]
                            ){           
                                PRM_Registration_Request__c regReqToUpdate = regReqToProcessMap.get(pwi.ProcessInstance.TargetObjectId);
                                String pid = regReqProcessInstanceWorkItemMap.get(regReqToUpdate.id);
                                regReqToUpdate.PRM_ProcessInstanceWorkItem_Id__c = pid;
                            }                           
                        }
                    }
                    
                    if(isActive('Registration_Profile_Response')){
                        if(regRequest != null && regRequest.size() > 0){
                            for (PRM_Registration_Request__c regReq : regRequest){
                                if(regReq.PRM_Profile_Response__c != null){
                                    PRM_profileResponse.createResponseWrapper obj1= new PRM_profileResponse.createResponseWrapper();
                                    obj1.regRequest=regRequest;
                                    obj1.accList=null;
                                    obj1.contList=null;
                                    obj1.flag=true;
                                    PRM_profileResponse.createResponse(obj1);//Athr fixes
                                    //PRM_ProfileResponse.createResponse(regRequest, null, null, true);
                                }
                            }
                        }
                    }
                    
                    if(isActive('Admin_Reg_Approve')){
                        approveAdminRegRecords(regReqNewList, acctMap);
                    }
                    
                }
            }           
        }    
    }
    
    public override void afterInsert(){
        system.debug('---testRTrun');                
        for(string registrationType : registrationTypes){
            if(registrationType != Label.RegistrationTypeProgram){
                //ER_EmailNotificationOnReceivingRegistrat has been inactivated as part of TWC722-672 : Team Quest - Harshitha
                if(isActive('ER_EmailNotificationOnReceivingRegistrat'))
                {
                    ER_EmailVerificationUtility.emailNotificationOnReceivingRegistration((List<PRM_Registration_Request__c>)Trigger.new);
                }
                if(isActive('ER_Ack_Email_Check_Update') && ER_AckFirstRun){
                    system.debug('inside sendAcknowledgementEmail');
                    ER_AckFirstRun = false;
                    ER_AcknowledgementEmailUtility.sendAcknowledgementEmail((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }
                if(isActive('ER_Dup_CheckInsert')){
                    system.debug('inside Dupcheck after insert');
                    ER_DuplicationUtility.DupCheck((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);                 
                }
            }
            else {
                //Moved code from after update to after insert as part of CidaaS requirments - atb
                Map<Id, PRM_Registration_Request__c> oldRegReqMap = (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap;
                Map<Id, PRM_Registration_Request__c> newRegReqMap = (Map<Id, PRM_Registration_Request__c>)Trigger.newMap;
                List<PRM_Registration_Request__c> regReqNewList = (List<PRM_Registration_Request__c>)Trigger.new;
                List<PRM_Registration_Request__c> regReqOldList = (List<PRM_Registration_Request__c>)Trigger.old;
                
                Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
                List<PRM_Registration_Request__c> listREgReqForIQR= new List<PRM_Registration_Request__c>();
                List<ChannelProgram> iqrPrograms = new List<ChannelProgram>();
                list<PRM_EmailUtility.EmailNotification> objEmailNotifList=new list<PRM_EmailUtility.EmailNotification> (); 
                List<PRM_Language_Culture_Mapping__mdt> lngCultureMdtList = PRM_Language_Culture_Mapping__mdt.getAll().values();
                List<PRM_Registration_Request__c> requestsToProcess = new List<PRM_Registration_Request__c>();
                List<Id> accountIds = new List<Id>();
                List<String> contactEmailList = new List<String>();
                Map<Id, PRM_Registration_Request__c> accRegMap = new Map<Id, PRM_Registration_Request__c>();
                
                if(regReqNewList.size() > 0){
                    iqrPrograms = [SELECT id
                                   FROM ChannelProgram
                                   WHERE Name = :PRM_IPA_Constants.PRICING_TENDER_PGM_CHANNEL];
                }
                
                for (PRM_Registration_Request__c regReq : regReqNewList){
                    if(regReq.PRM_Channel_Program_Level_txt__c == 'Intel Quote Request'
                       && regReq.RecordTypeId == accCreateRequestId && regReq.PRM_Status__c == 'Approved' 
                       && !String.isEmpty(regReq.PRM_Salesforce_ID__c)){
                           listREgReqForIQR.add(regReq);
                       }
                    
                    //EmailNotificationOnReceivingRegistration
                    if(isActive('EmailNotificationOnReceivingRegistration') && regReq.recordTypeId == PRM_IPA_Constants.EV_RECORD_TYPE_ID){
                        PRM_Language_Culture_Mapping__mdt langCultureForEmail;
                        for (PRM_Language_Culture_Mapping__mdt mdtRec : lngCultureMdtList){
                            if(langCultureForEmail == null 
                            && (mdtRec.PRM_Country_Cd__c != null 
                            && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase('us'))
                            ){
                                langCultureForEmail = mdtRec;
                            }
                            if(mdtRec.PRM_Country_Cd__c != null 
                                && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase(regReq.PRM_Contact_Country__c) 
                                && mdtRec.MasterLabel == regReq.PRM_Preferred_Language__c
                            ){
                                langCultureForEmail = mdtRec;
                            }
                        }
                        
                        PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();
                        objEmailNotif.ChannelProgram = PRM_Intel_Partner_Alliance;
                        
                        objEmailNotif.EmailID = regReq.PRM_Email_ID__c;
                        objEmailNotif.Language = regReq.PRM_Preferred_Language__c;
                        Map<String, String> paramMap = new Map<String, String>();
                        paramMap.put('Registration_Request_ID', regReq.id);
                        
                        if(langCultureForEmail != null){
                            paramMap.put('LanguageCulture_MDT', langCultureForEmail.Id);
                        }
                        objEmailNotif.InputParameters = paramMap;
                        if((IS_CIDAAS_ENABLED) || String.isBlank(String.valueOf(regReq.PRM_EmailVerifiedDateTime__c))){ 
                            //As a part of CiDaaS change
                            //EV Date is blank --> new user --> send mail with EV token received
                            if(IS_CIDAAS_ENABLED || String.isNotBlank(String.valueOf(regReq.PRM_EV_Token__c))){ //As a part of CiDaaS change
                                objEmailNotif.BusinessEvent = System.label.PRM_Registration_request_for_new_User_EV;
                                //Added by Naresh Yendluri as part of US934493
                                if(iqrPrograms.size() > 0 && regReq.PRM_Channel_Program__c == iqrPrograms[0].Id){
                                    objEmailNotif.BusinessEvent = Pricing_Registration_request_for_new_User_EV;
                                    objEmailNotif.Language = 'ENG';
                                }
                                if(regReq.PRM_Channel_Program_Level_txt__c == 'PSG'){
                                    String loginId;
                                    objEmailNotif.BusinessEvent = PRM_Registration_request_for_new_User_EV_PSG;
                                    objEmailNotif.Language = regReq.PRM_Preferred_Language__c;
                                    if(IS_CIDAAS_ENABLED){ //As a part of CiDaaS change
                                        loginId = '';
                                    }
                                    else{
                                        loginId = regReq.PRM_Contact_Login_ID__c != null
                                                ? regReq.PRM_Contact_Login_ID__c : regReq.PRM_Email_ID__c;
                                    }
                                    PRM_EmailUtility.customPlaceholdersMap = new Map<String, String>{'{{USERNAME}}' => loginId};
                                }
                                objEmailNotifList.add(objEmailNotif);
                                system.debug('mail sent for new User!!');
                            }
                        }
                    }
                    
                    //processAdminRegistrationRecords
                    if(isActive('Process_Admin_Registration') 
                        && ((oldRegReqMap == null 
                            && regReq.PRM_Email_Verification_Criteria__c == 'success') 
                            || ((oldRegReqMap != null 
                            && oldRegReqMap.size() > 0) 
                            && oldRegReqMap.get(regReq.Id).PRM_Status__c != regReq.PRM_Status__c 
                            && regReq.PRM_Status__c == 'Approved' 
                            && oldRegReqMap.get(regReq.Id).PRM_Status__c == 'new' 
                            && oldRegReqMap.get(regReq.Id).PRM_Email_Verification_Criteria__c != regReq.PRM_Email_Verification_Criteria__c 
                            && regReq.PRM_Email_Verification_Criteria__c == 'success'))
                    ){
                        if((regReq.PRM_Status__c == 'Approved') && regReq.RecordTypeid == PRM_IPA_Constants.ADMIN_REGISTRATION_RT){
                            requestsToProcess.add(regReq);
                            accountIds.add(regReq.PRM_Salesforce_ID__c);
                            accRegMap.put(regReq.PRM_Salesforce_ID__c,regReq);
                            contactEmailList.add(regReq.PRM_Email_ID__c);
                        }
                    }
                }
                
                //Moved code from after update to after insert as part of CidaaS requirments - atb
                if(!listREgReqForIQR.isEmpty() && isActive('Pricing_RegRequest_Auto_Approve')){
                    Pricing_RegistrationReqUtility.createIQRContacts(listREgReqForIQR, null);
                }
                
                //EmailNotificationOnReceivingRegistration
                if(!objEmailNotifList.isEmpty()){
                    PRM_EmailUtility.sendEmail(objEmailNotifList);
                }
                
                //processAdminRegistrationRecords
                if(RequestsToProcess.size() > 0){
                    PRM_CreateAccountAndRelatedRecordsAdmin.processRelatedRecordsAdmin(accountIds,AccRegMap,contactEmailList);
                }
                
                //updateRelatedACROfAccount
                if(isActive('Admin_Reg_Approve')){
                    updateRelatedACROfAccount(newRegReqMap, null);
                }
                
                //sendAcknowledgementEmail
                if(isActive('sendAcknowledgementEmail')){  
                    sendAcknowledgementEmail(regReqNewList, oldRegReqMap);   
                }
                
                if(trackereRun ){               
                    System.enqueueJob(new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable ((List<PRM_Registration_Request__c>) Trigger.new,null,false,false));
                    trackereRun =false;
                }

                // Agate - TWC729-2483 - Start
                if(isActive('Dup_Check')  && PRM_CimDupErrorUtility.isFirstRunCheck ){
                    PRM_CimDupErrorUtility.isFirstRunCheck = false ;
                    PRM_CimDupErrorUtility.dupCheck((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }                          
            }  
        }      
    }

    public override void afterUpdate(){
        system.debug('in afterUpdate: ');
        for(string registrationType : registrationTypes){
            system.debug('in afterUpdate: ' + 'registrationType: ' + registrationType + ' registrationTypes: '+ registrationTypes + ' Label.RegistrationTypeProgram: '+ Label.RegistrationTypeProgram );
            if(registrationType != Label.RegistrationTypeProgram){
                if(isActive('ER_Rejection_Email_Check')){
                    ER_RejectionEmailUtility.SendRejectionEmailNotifications((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }
                //Has been inactivated as part of TWC722-672 : Team Quest - Harshitha
                if(isActive('ER_Ack_Email_Check') && ER_AckFirstRun){
                    system.debug('inside sendAcknowledgementEmail');
                    ER_AckFirstRun = false;
                    ER_AcknowledgementEmailUtility.sendAcknowledgementEmail((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }
                if(isActive('ER_Dup_Check') && ER_DupFirstRun){
                    system.debug('inside Dupcheck after update');
                    ER_DupFirstRun = false;
                    ER_DuplicationUtility.DupCheck((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);                   
                }
            }else{   
                Map<Id, PRM_Registration_Request__c> oldRegReqMap = (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap;
                Map<Id, PRM_Registration_Request__c> newRegReqMap = (Map<Id, PRM_Registration_Request__c>)Trigger.newMap;
                List<PRM_Registration_Request__c> regReqNewList = (List<PRM_Registration_Request__c>)Trigger.new;
                List<PRM_Registration_Request__c> regReqOldList = (List<PRM_Registration_Request__c>)Trigger.old;
                Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
                Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
                Id adminRegistrationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId();
                Map<String, PRM_Registration_Request__c> mapOfEmailRegRequest = new Map<String, PRM_Registration_Request__c>();
                List<PRM_Registration_Request__c> listREgReqForIQR= new List<PRM_Registration_Request__c>();
                List<PRM_Registration_Request__c> listREgReqForTracker= new List<PRM_Registration_Request__c>();
                //Map<Id, PRM_Registration_Request__c> oldMap = (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap;
                List<PRM_Registration_Request__c> approvedRegReqList = new List<PRM_Registration_Request__c> ();
                List<PRM_Registration_Request__c> requestsToProcess = new List<PRM_Registration_Request__c>();
                List<Id> accountIds = new List<Id>();
                List<String> contactEmailList = new List<String>();
                Map<Id, PRM_Registration_Request__c> accRegMap = new Map<Id, PRM_Registration_Request__c>();
                Map<String, String> mapOfContacts = new Map<String, String>();
                List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
                Map<id, PRM_Account_Contact_Relationship__c> mapOfACR;
                Map<id, sObject> mapOfUpdateACR = new Map<id, sObject>();
                List<PRM_Language_Culture_Mapping__mdt> lngmapping = PRM_Language_Culture_Mapping__mdt.getAll().values();
                PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();
                List<PRM_EmailUtility.EmailNotification> objEmailNotifList = new List<PRM_EmailUtility.EmailNotification>();
                
                for(PRM_Registration_Request__c regReq : regReqNewList){
                    PRM_Registration_Request__c oldRegReq =  oldRegReqMap.get(regReq.Id);
                    if(regReq.PRM_Channel_Program_Level_txt__c == Label.PRM_Intel_Partner_Alliance 
                       && (oldRegReq.RecordTypeId != regReq.RecordTypeId ) 
                       || (IS_CIDAAS_ENABLED) 
                       || (oldRegReq.PRM_Status__c != regReq.PRM_Status__c 
                       && (regReq.PRM_Status__c=='Rejected' || regReq.PRM_Status__c=='Approved' )) 
                       || oldRegReq.PRM_Email_Log__c!=regReq.PRM_Email_Log__c
                    ){
                        listREgReqForTracker.add(regReq);
                    }else if(regReq.PRM_Channel_Program_Level_txt__c == Label.PRM_Intel_Partner_Alliance 
                        && (oldRegReq.RecordTypeId != regReq.RecordTypeId ) 
                        || (oldRegReq.PRM_EmailVerifiedDateTime__c!=regReq.PRM_EmailVerifiedDateTime__c) 
                        || (oldRegReq.PRM_Status__c != regReq.PRM_Status__c 
                        && (regReq.PRM_Status__c=='Rejected' || regReq.PRM_Status__c=='Approved' )) 
                        || oldRegReq.PRM_Email_Log__c!=regReq.PRM_Email_Log__c       
                    ){
                        listREgReqForTracker.add(regReq);
                    }

                    if(oldRegReqMap.get(regReq.Id).PRM_Status__c !=  regReq.PRM_Status__c 
                       && regReq.PRM_Status__c == 'Approved' 
                       && regReq.RecordTypeId != adminRegistrationRT
                       && regReq.PRM_TriggerProcess__c == False
                       && regReq.PRM_Auto_Approve__c == False
                       && regReq.Entitlement_Details__c == null
                       && regReq.PRM_Channel_Program_Level_txt__c != 'PSG'
                    ){ 
                        approvedRegReqList.add(regReq);
                    }  
                    
                    //processAdminRegistrationRecords
                    if(isActive('Process_Admin_Registration') 
                       && ((oldRegReqMap == null 
                            && regReq.PRM_Email_Verification_Criteria__c == 'success') 
                            || ((oldRegReqMap != null 
                            && oldRegReqMap.size() > 0)
                            && oldRegReqMap.get(regReq.Id).PRM_Status__c != regReq.PRM_Status__c 
                            && regReq.PRM_Status__c == 'Approved' 
                            && oldRegReqMap.get(regReq.Id).PRM_Status__c == 'new' 
                            && oldRegReqMap.get(regReq.Id).PRM_Email_Verification_Criteria__c != regReq.PRM_Email_Verification_Criteria__c 
                            && regReq.PRM_Email_Verification_Criteria__c == 'success'))
                    ){
                        //if((regReq.PRM_Status__c=='Approved') && regReq.RecordTypeid == Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId() && regReq.PRM_Legal_Agreement_Criteria__c==Label.PRM_Success)
                        if((regReq.PRM_Status__c == 'Approved') 
                            && regReq.RecordTypeid == PRM_IPA_Constants.ADMIN_REGISTRATION_RT
                        ){
                            requestsToProcess.add(regReq);
                            accountIds.add(regReq.PRM_Salesforce_ID__c);
                            accRegMap.put(regReq.PRM_Salesforce_ID__c,regReq);
                            contactEmailList.add(regReq.PRM_Email_ID__c);
                        }
                    }  
                    
                    
                    //sendRejectionEmail 
                    if(isActive('sendRejectionEmail') 
                        && !IPArejectionemail 
                        && oldRegReqMap.get(regReq.Id).PRM_Status__c !=regReq.PRM_Status__c 
                        && regReq.PRM_Status__c == 'Rejected'
                    ){
                        PRM_Language_Culture_Mapping__mdt langCulEmail;
                        for (PRM_Language_Culture_Mapping__mdt mdtRec : lngmapping){
                            if(langCulEmail == null 
                                && (mdtRec.PRM_Country_Cd__c != null
                                && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase('us'))
                            ){
                                langCulEmail = mdtRec;
                            }
                            if(mdtRec.PRM_Country_Cd__c != null 
                                && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase(regReq.PRM_Contact_Country__c) 
                                && mdtRec.MasterLabel == regReq.PRM_Preferred_Language__c
                            ){
                                langCulEmail = mdtRec;
                            }
                            objEmailNotif.ChannelProgram = PRM_Intel_Partner_Alliance;
                            objEmailNotif.EmailID = regReq.PRM_Email_ID__c;
                            objEmailNotif.Language = regReq.PRM_Preferred_Language__c;
                            
                            Map<String, String> paramMap = new Map<String, String>();
                            paramMap.put('Registration_Request_ID', regReq.id);
                            
                            if(langCulEmail != null){
                                paramMap.put('LanguageCulture_MDT', langCulEmail.Id);
                            }
                            objEmailNotif.InputParameters = paramMap;
                            objEmailNotif.BusinessEvent = IPA_Registration_Request_Rejection_Email;
                        }
                        
                        if(objEmailNotif.BusinessEvent != null){
                            objEmailNotifList.add(objEmailNotif);
                        }
                    }   
                }
                
                //processAdminRegistrationRecords
                if(RequestsToProcess.size() > 0){
                    PRM_CreateAccountAndRelatedRecordsAdmin.processRelatedRecordsAdmin(accountIds,AccRegMap,contactEmailList);
                }
                
                //updateRelatedACROfAccount
                if(isActive('Admin_Reg_Approve')){
                    updateRelatedACROfAccount(newRegReqMap, oldRegReqMap);
                }
                
                //sendRejectionEmail
                if(isActive('sendRejectionEmail') && !IPArejectionemail && !objEmailNotifList.isEmpty()){
                    PRM_EmailUtility.sendEmail(objEmailNotifList);
                    IPArejectionemail = true;
                }
                
                //sendAcknowledgementEmail
                if(isActive('sendAcknowledgementEmail')){  
                    sendAcknowledgementEmail(regReqNewList, oldRegReqMap);   
                }
                
                
                // Agate - TWC729-2483 - Start
                if(isActive('Dup_Check') && PRM_CimDupErrorUtility.isFirstRunCheck ){
                    PRM_CimDupErrorUtility.isFirstRunCheck = false ;
                    PRM_CimDupErrorUtility.dupCheck((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }
                if(listREgReqForTracker.size()>0 && trackereRun && System.Label.PRM_Tracker_Enabled=='true' ){
                    if(System.isBatch() || System.isQueueable() || System.isFuture()){
                        new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable (listREgReqForTracker,null,false,false);
                        trackereRun = false;
                    }else{
                        System.enqueueJob(new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable (listREgReqForTracker,null,false,false));
                        trackereRun = false;                 
                    }                    
                }
                
                /* PLEASE DO NOT ADD ANY LINES AFTER THIS CONDITION */
                if(!approvedRegReqList.isEmpty() && !IPAAttributeCreationCalled){
                    PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(approvedRegReqList);
                    IPAAttributeCreationCalled = true;
                }    
            }
        }
    }
    
    //It updates Legal Agreement Criteria on the basis of channel program,legal agreement name and preferred language
    public static void updateLA(List<PRM_Registration_Request__c> regRequestList){
        //  PRM_Registration_Request__c newRequest = new PRM_Registration_Request__c();
        Set<String> paNameSet = new Set<String>();
        Set<String> laNameSet = new Set<String>();
        Map<String, String> roleTypeMap = new Map<String, String>();
        
        for(PRM_PartnerRoleTypeMappings__mdt roleTypeReq : PRM_PartnerRoleTypeMappings__mdt.getAll().values()){
            roleTypeMap.put(roleTypeReq.PRM_Biz_Org_Type__c, roleTypeReq.PRM_Partner_Role__c);
        }
        
        Set<String> allPASet = new Set<String>();
        Set<String> allPASetWithoutLanguage = new Set<String>();
        for (PRM_PartnerAgreement__c pa : [SELECT Id, Name, PRM_Channel_Program_Id__c, PRM_Language_Codes__c, PRM_Partner_Role__c, PRM_InActive_Ind__c, PRM_Agreement_Cd__c
                                           FROM PRM_PartnerAgreement__c
                                           WHERE PRM_InActive_Ind__c = FALSE]
        ){
            //Set Without language field
            if(String.isBlank(pa.PRM_Language_Codes__c)){
                allPASetWithoutLanguage.add(pa.PRM_Agreement_Cd__c + pa.PRM_Channel_Program_Id__c);
            }
            allPASet.add(pa.PRM_Agreement_Cd__c + pa.PRM_Language_Codes__c + pa.PRM_Channel_Program_Id__c);
        }
        
        for (PRM_Registration_Request__c newRequest : regRequestList){
            if(newRequest.PRM_Partner_Role__c == null || String.isBlank(newRequest.PRM_Partner_Role__c)){
                if(newRequest.PRM_Partner_Type__c != null && String.isNotBlank(newRequest.PRM_Partner_Type__c) ){
                    for (String orgType : newRequest.PRM_Partner_Type__c.split(';')){
                        if(roleTypeMap.containsKey(orgType)){
                            newRequest.PRM_Partner_Role__c = roleTypeMap.get(orgType);
                        }
                    }
                }
            }
            
            if(allPASet.size() == 0){
                newRequest.PRM_Legal_Agreement_Criteria__c = PRM_Fail;
                System.debug('@@ No Records in Partner Agreement');
            }else if( newRequest.recordTypeID != PRM_IPA_Constants.EV_RECORD_TYPE_ID){
                boolean status = true;
                if(newRequest.PRM_Status__c != PRM_Status_Rejected 
                   && newRequest.PRM_Legal_Agreements__c != null 
                   && newRequest.PRM_Legal_Agreement_Criteria__c == Label.PRM_Pending
                ){
                    for (String laName : newRequest.PRM_Legal_Agreements__c.split(';')){
                        if(allPASetWithoutLanguage.size() > 0 && !allPASetWithoutLanguage.contains(laName + newRequest.PRM_Channel_Program__c)){
                            status = false;
                            break;
                        }else if(allPASet.size() > 0 && !allPASet.contains(laName + newRequest.PRM_Preferred_Language__c + newRequest.PRM_Channel_Program__c)){        
                            status = false;
                            break;
                        }        
                    }
                    
                    if(status){
                        System.debug('@@ Success');
                        newRequest.PRM_Legal_Agreement_Criteria__c = PRM_Success;
                    }else{
                        newRequest.PRM_Legal_Agreement_Criteria__c = PRM_Fail;
                        System.debug('@@ Fail');
                    }
                }
            }
        }
    }
    
    //TODO - Check if this can we shifted to duplicate rule
    // Reject status of records having values matching with an existing record
    public static void rejectDuplicates(List<PRM_Registration_Request__c> regReqList,Map<Id, PRM_Registration_Request__c> oldRequestMap){
        PRM_Registration_Request__c reg_Request = new PRM_Registration_Request__c();
        List<PRM_Registration_Request__c> duplicateRequest = new List<PRM_Registration_Request__c>();
        Boolean isDuplicate;
        System.debug('@@ oldRequestMap' + oldRequestMap);
        
        if(regReqList.size() > 0){
            reg_Request = regReqList[0];
            System.debug(' @@ Partner Type' + reg_Request.PRM_Partner_Type__c);
            
            if((oldRequestMap == null 
            && (reg_Request.RecordTypeId == PRM_IPA_Constants.ADMIN_REGISTRATION_RT 
               || reg_Request.RecordTypeId == PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT) 
            && reg_Request.PRM_Status__c == 'New') ||
               (reg_Request.RecordTypeId == PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT &&
               oldRequestMap != null &&
               oldRequestMap.containsKey(reg_Request.Id) &&
               oldRequestMap.get(reg_Request.Id).RecordTypeId == PRM_IPA_Constants.EV_RECORD_TYPE_ID &&
               reg_Request.PRM_Status__c == 'New')
            ){
                if(reg_Request.PRM_Account_Name__c != null &&
                (IS_CIDAAS_ENABLED || reg_Request.PRM_Contact_Login_ID__c != null) &&
                reg_Request.PRM_Email_ID__c != null &&
                reg_Request.PRM_Partner_Type__c != null &&
                reg_Request.PRM_Status__c != null &&
                String.isNotBlank(reg_Request.PRM_Account_Name__c) &&
                (IS_CIDAAS_ENABLED || String.isNotBlank(reg_Request.PRM_Contact_Login_ID__c)) &&
                String.isNotBlank(reg_Request.PRM_Email_ID__c) &&
                String.isNotBlank(reg_Request.PRM_Partner_Type__c) &&
                String.isNotBlank(reg_Request.PRM_Status__c)
                ){ //As a part of CiDaaS change
                    if(IS_CIDAAS_ENABLED){//As a part of CiDaaS change
                        duplicateRequest = [SELECT Id, Name, RecordTypeId, PRM_Account_Name__c, PRM_Email_ID__c, PRM_Partner_Type__c, PRM_Status__c, PRM_Contact_Salesforce_ID__c
                                            FROM PRM_Registration_Request__c
                                            WHERE PRM_Account_Name__c = :reg_Request.PRM_Account_Name__c
                                            AND PRM_Email_ID__c = :reg_Request.PRM_Email_ID__c
                                            AND PRM_Partner_Type__c = :reg_Request.PRM_Partner_Type__c
                                            AND (PRM_Status__c != :PRM_Status_Rejected
                                                OR RecordTypeId = :PRM_IPA_Constants.ADMIN_REGISTRATION_RT)
                                            AND CreatedDate = LAST_N_DAYS:1
                                            AND RecordTypeId = :reg_Request.RecordTypeId];
                    }else{
                        duplicateRequest = [SELECT Id, Name, RecordTypeId, PRM_Account_Name__c, PRM_Contact_Login_ID__c, PRM_Email_ID__c, PRM_Partner_Type__c, 
                                            PRM_Status__c, PRM_Contact_Salesforce_ID__c
                                            FROM PRM_Registration_Request__c
                                            WHERE PRM_Account_Name__c = :reg_Request.PRM_Account_Name__c
                                            AND PRM_Contact_Login_ID__c = :reg_Request.PRM_Contact_Login_ID__c
                                            AND PRM_Email_ID__c = :reg_Request.PRM_Email_ID__c
                                            AND PRM_Partner_Type__c = :reg_Request.PRM_Partner_Type__c
                                            AND (PRM_Status__c != :PRM_Status_Rejected
                                                OR RecordTypeId = :PRM_IPA_Constants.ADMIN_REGISTRATION_RT)
                                            AND CreatedDate = LAST_N_DAYS:1
                                            AND RecordTypeId = :reg_Request.RecordTypeId];
                    }
                }
                
                if(duplicateRequest.size() > 0){
                    isDuplicate = false;
                    if( String.IsNotBlank( reg_Request.PRM_Contact_Salesforce_ID__c)){
                        for(PRM_Registration_Request__c dupRegReq : duplicateRequest){
                            if(dupRegReq.PRM_Contact_Salesforce_ID__c == reg_Request.PRM_Contact_Salesforce_ID__c){
                                isDuplicate = true;
                            }
                        }
                    }else{
                        isDuplicate = true;
                    }
                    
                    if(isDuplicate == true){
                        System.debug('@@ Update Record');
                        reg_Request.PRM_Status__c = PRM_Status_Rejected;
                        reg_Request.PRM_Status_Reason__c = PRM_Duplicate_Request;
                        if(reg_Request.RecordTypeId ==PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT){
                            reg_Request.PRM_isSubmitted__c = true;
                        }
                    }
                }
            }
        }
    }
    
    //To check if Admin request landed in  SF needs to be approved or Rejected (Based on LA, ACM parner role ), PRM_Salesforce_ID__c != blank
    public static void approveAdminRegRecords(List<PRM_Registration_Request__c> regReqList, Map<Id, Account> acctMap){
        Boolean verifyResponse = false;
        Boolean flag = false;
        
        Set<String> metadataSubscriptionSet = new Set<String>();
        for(PRM_Subscription_Mapping__mdt subscriptionMetadata : PRM_Subscription_Mapping__mdt.getAll().values()){
            metadataSubscriptionSet.add(subscriptionMetadata.PRM_Subscription__c);
        }
        
        for(PRM_Registration_Request__c reg_Request : regReqList){
            flag = false;
            verifyResponse = false;
            if(reg_Request != null 
               && reg_Request.RecordTypeid == PRM_IPA_Constants.ADMIN_REGISTRATION_RT 
               && reg_Request.PRM_Salesforce_ID__c != null 
               && String.isNotBlank(reg_Request.PRM_Salesforce_ID__c) 
               && reg_Request.PRM_Status__c == 'New' 
               && reg_Request.PRM_Email_Verification_Criteria__c == Label.PRM_Success
            ){
                if(acctMap.containsKey(reg_Request.PRM_Salesforce_ID__c) 
                && acctMap.get(reg_Request.PRM_Salesforce_ID__c).Contacts != null 
                && acctMap.get(reg_Request.PRM_Salesforce_ID__c).Contacts.size() > 0
                ){
                    for (Contact c : acctMap.get(reg_Request.PRM_Salesforce_ID__c).Contacts){
                        if(c.email == reg_Request.PRM_Email_ID__c){
                            flag = true;
                            break;
                        }
                    }
                }
                
                  //secondary contact admin auto approval
                if(acctMap.containsKey(reg_Request.PRM_Salesforce_ID__c) &&
                    acctMap.get(reg_Request.PRM_Salesforce_ID__c).Contacts !=null &&
                    acctMap.get(reg_Request.PRM_Salesforce_ID__c).Contacts.size() > 1
                ){
                    System.debug(' <--- Secondary contact approval ---> ');
                    if(acctMap.get(reg_Request.PRM_Salesforce_ID__c).Channel_Memberships1__r.size() > 0 &&
                        flag &&
                        reg_Request.PRM_Email_Verification_Criteria__c == Label.PRM_Success &&
                        reg_Request.PRM_Subscriptions__c != null &&
                        String.isNotBlank(reg_Request.PRM_Subscriptions__c)
                        ){
                            Set<String> newRegSubscriptionSet = new Set<String>();
                            if(String.isNotBlank(reg_Request.PRM_Subscriptions__c)){
                                newRegSubscriptionSet.addAll(reg_Request.PRM_Subscriptions__c.split(';'));
                            }
                            if(newRegSubscriptionSet.equals(metadataSubscriptionSet)){
                                verifyResponse = true;
                            }
                        }
                    System.debug('@@ verifyResponse' + verifyResponse);
                    if(verifyResponse){
                        System.debug('@@ Auto Approve Admin Registration');
                        reg_Request.PRM_Status__c = Label.PRM_Status;
                    }
                }else{
                    //primary contact admin auto approval
                    System.debug('@@ PRIMARY APPROVAL');
                    if(flag){
                        System.debug('<--- Primary contact approval --->');
                        if((acctMap.get(reg_Request.PRM_Salesforce_ID__c).Channel_Memberships1__r.size() > 0) 
                            && (acctMap.get(reg_Request.PRM_Salesforce_ID__c).Channel_Memberships1__r[0].PRM_Channel_Program_Id__c == reg_Request.PRM_Channel_Program__c)
                        ){
                            reg_Request.PRM_Status__c = Label.PRM_Status;
                        }else{
                            reg_Request.PRM_Status__c = PRM_Status_Rejected;
                        }
                    }
                }
              }
        }
    }
    
    // Bulkified Code
    public static void autoApproveEndUserRegistration(List<PRM_Registration_Request__c> regReqList,
                                                      Map<Id, PRM_Registration_Request__c> oldRequestMap,
                                                      Map<String, Boolean> isSysAccMap,
                                                      Map<Id, List<Contact>> mapAccIdToListContact,
                                                      Map<Id, Account> mapAccount,
                                                      List<PRM_AccountChannelMembership__c> acmList,
                                                      Set<String> bizOrgTypeSet,
                                                      Set<String> partnerRoleSet,
                                                      List<Id> salesforceIdList,
                                                      Map<Id, String> reqReqEmailMap,
                                                      List<PRM_Registration_Request__c> validRegRequestList,
                                                      Map<Id, Set<String>> regSubcriptionMap
    ){
        Boolean isAccIPA = false;
        Map<Id, Boolean> salesforceIdAccntMap = new Map<Id, Boolean>();
        Set<String> newRegSubscriptionSet = new Set<String>();
        List<PRM_AccountChannelMembership__c> accChannelMembership = new List<PRM_AccountChannelMembership__c>();
        Map<Id, Boolean> acctIdIPAMap = new Map<Id, Boolean>();
        Set<String> emailDomainSet = new Set<String>();
        Map<Id, String> acmAcctIdPartRoleMap = new Map<Id, String>();
        Map<Id, Integer> acctContSize = new Map<Id, Integer>();
        Map<Id, Boolean> regReqSuccessCriteriaMap = new Map<Id, Boolean>();
        Map<String, Boolean> partRoleMetaDataMap = new Map<String, Boolean>();
        Map<String,Boolean> emailDomainMatch = new Map<string,Boolean>();
        Boolean verifyResponse = false;
        Map<Id,Id> contactAccountMap = new  Map<Id,Id>();
        
        if(bizOrgTypeSet.size() > 0){
            //pmd = [select id,PRM_Biz_Org_Type__c,isNotAutoApprove__c from PRM_PartnerRoleTypeMappings__mdt where  PRM_Biz_Org_Type__c in :bizOrgTypeSet];
            for (PRM_PartnerRoleTypeMappings__mdt pmd : [SELECT id, PRM_Biz_Org_Type__c, isNotAutoApprove__c
                                                        FROM PRM_PartnerRoleTypeMappings__mdt
                                                        WHERE PRM_Biz_Org_Type__c IN :bizOrgTypeSet]
            ){
                partRoleMetaDataMap.put(pmd.PRM_Biz_Org_Type__c, pmd.isNotAutoApprove__c);
            }           
        }
        
        if(salesforceIdList.size() > 0){
            for (Id accId : salesforceIdList){
                Account acct = mapAccount.containsKey(accId)? mapAccount.get(accId): null;
                if(!acct.Core_Deactivated__c 
                && reqReqEmailMap.get(acct.Id) != null 
                && !isSysAccMap.containsKey(reqReqEmailMap.get(acct.Id))
                ){
                    salesforceIdAccntMap.put(acct.Id, acct.Core_Deactivated__c);
                    acctIdIPAMap.put(acct.id,acct.Core_Intel_Partner_Alliance_PartnerGroup__c);
                    //acctContSize.put(acct.Id,acct.Contacts.size());
                    List<Contact> conList = new List<Contact>();
                    if(mapAccIdToListContact.containsKey(accId)){
                        for (Contact con : mapAccIdToListContact.get(accId)){
                            conList.add(con);
                            contactAccountMap.put(con.Id,con.AccountId);
                        }
                    }
                    acctContSize.put(acct.Id, conList.size());
                    System.debug('acctContSize--->' + acctContSize);
                }
            }
        }
        
        if(salesforceIdList.size() > 0){
            for (PRM_AccountChannelMembership__c acm : acmList){
                if(salesforceIdList.contains(acm.PRM_Account_Id__c) 
                && !acm.PRM_Account_Id__r.Core_Deactivated__c 
                && partnerRoleSet.contains(acm.PRM_Partner_Role__c)
                ){
                    acmAcctIdPartRoleMap.put(acm.PRM_Account_Id__c,acm.PRM_Partner_Role__c);
                }
            }
        }
        
        Set<String> metadataSubscriptionSet = new Set<String>();
        for(PRM_Subscription_Mapping__mdt subscriptionMetadata : PRM_Subscription_Mapping__mdt.getAll().values()){
            metadataSubscriptionSet.add(subscriptionMetadata.PRM_Subscription__c);
        }
        
        Map<String, Core_Account_Whitelisted_Domains__c> whitelist = new Map<String, Core_Account_Whitelisted_Domains__c>();
        if(salesforceIdList.size() > 0){
            for (Core_Account_Whitelisted_Domains__c awd : [SELECT id, Name, Inactive_Indicator__c, Effective_End_Date_Time__c, Account__c
                                                            FROM Core_Account_Whitelisted_Domains__c
                                                            WHERE Account__c IN :salesforceIdList
                                                            AND Inactive_Indicator__c = FALSE
                                                            AND (Effective_End_Date_Time__c = NULL
                                                                OR Effective_End_Date_Time__c > TODAY)
            ]){
                whitelist.put(awd.Name, awd);
            }
        }
        
        for(PRM_Registration_Request__c reg_Request : validRegRequestList){              
            Boolean conditionSet = false;
            String emailDomain = '';
            String emailId = '';
            if(metadataSubscriptionSet.equals(regSubcriptionMap.get(reg_Request.id)) &&
            acmAcctIdPartRoleMap.containsKey(reg_Request.PRM_Salesforce_ID__c) &&
            acctContSize.get(reg_Request.PRM_Salesforce_ID__c) > 0 &&
            acctIdIPAMap.get(reg_Request.PRM_Salesforce_ID__c) == true
            ){
                verifyResponse = true;
                isAccIPA = true;
                emailId = reg_Request.PRM_Email_ID__c.trim();
                emailDomain = emailId.substringAfter('@');
            }else if(acctIdIPAMap.get(reg_Request.PRM_Salesforce_ID__c) == false 
                    && reg_Request.PRM_Dup_Status__c == PRM_Nodup && partRoleMetaDataMap.containsKey(reg_Request.PRM_Partner_Type__c) 
                    && partRoleMetaDataMap.get(reg_Request.PRM_Partner_Type__c) ==false 
                    && reg_Request.PRM_Salesforce_ID__c != null
            ){
                reg_Request.PRM_Status__c = Label.PRM_Status;
                reg_Request.PRM_Auto_Approve__c = true;
                reg_Request.PRM_isSubmitted__c = true;
            }           
            
            if(verifyResponse = true){
                for (String str : whitelist.keyset()){
                    boolean contains = false;
                    system.debug('@@' + str);
                    emailDomainMatch.put(reg_Request.PRM_Email_ID__c,false);
                    if(str.equals(emailDomain) && reg_Request.PRM_Salesforce_ID__c != null){ // Utkarsh - TWC727-530 - Added salesforce id not equal to null condition if request is going for auto approval because all new account creation request shouldn't approve manually.
                        System.debug('@@ Auto Approve End User Registration');
                        reg_Request.PRM_Status__c = Label.PRM_Status;
                        reg_Request.PRM_Auto_Approve__c = true;
                        reg_Request.PRM_isSubmitted__c = true;
                        emailDomainMatch.put(reg_Request.PRM_Email_ID__c,true);
                    }
                }
            }
        }
        
        for (PRM_Registration_Request__c reg_Request : regReqList){
            if(reg_Request.RecordTypeId == PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT && reg_Request.PRM_Status__c == 'New'){
                if(reg_Request.PRM_Salesforce_ID__c != null 
                && reg_Request.PRM_Matching_Contact__c!=null 
                && contactAccountMap.get(reg_Request.PRM_Matching_Contact__c) != reg_Request.PRM_Salesforce_ID__c
                ){
                    reg_Request.PRM_Pending_Auto_Approval_Criteria__c = PRM_DiffAccount;
                } 
                else if(reg_Request.PRM_Salesforce_ID__c == null){ 
                    reg_Request.PRM_Pending_Auto_Approval_Criteria__c = PRM_Account_Creation;
                }
                else if(reg_Request.PRM_DeDup_Criteria__c == 'PENDING' && !isAccIPA){
                    reg_Request.PRM_Pending_Auto_Approval_Criteria__c =  PRM_DupCheck;
                }
                else if(reg_Request.PRM_Dup_Status__c != PRM_Nodup && !isAccIPA){
                    reg_Request.PRM_Pending_Auto_Approval_Criteria__c = PRM_DupCheckFailure;
                }
                else if(partRoleMetaDataMap.containsKey(reg_Request.PRM_Partner_Type__c) 
                && partRoleMetaDataMap.get(reg_Request.PRM_Partner_Type__c) == true && !isAccIPA
                ){
                    reg_Request.PRM_Pending_Auto_Approval_Criteria__c = PRM_PartnerRoleNA;
                }
                else if(isAccIPA && emailDomainMatch.get(reg_Request.PRM_Email_ID__c)!=null && !(emailDomainMatch.get(reg_Request.PRM_Email_ID__c))){
                    reg_Request.PRM_Pending_Auto_Approval_Criteria__c = PRM_EmailMismatch;
                }    
                
            }
        }
    }
    
    public static void sendAcknowledgementEmail(List<PRM_Registration_Request__c> regRequestList,Map<id, PRM_Registration_Request__c> oldregRequestMap){
        List<PRM_Language_Culture_Mapping__mdt> lngmapping = PRM_Language_Culture_Mapping__mdt.getAll().values();
        list<PRM_EmailUtility.EmailNotification> objEmailNotifList=new list<PRM_EmailUtility.EmailNotification> (); 
        
        for (PRM_Registration_Request__c regRequest : regRequestList){
            if(((regRequest.PRM_Channel_Program_Level_txt__c == PRM_Intel_Partner_Alliance)) 
                && (Trigger.isUpdate && regRequest.recordtypeid == PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT 
                    && oldregRequestMap != null 
                    && oldregRequestMap.containsKey(regRequest.id) 
                    /*oldregRequestMap.get(regRequest.id).recordtypeid == emailVerificationRT &&*/ 
                    && regRequest.PRM_Auto_Approve__c == false
                    && String.IsNotBlank(regRequest.PRM_Salesforce_ID__c) 
                    && String.IsNOTBlank(regRequest.PRM_Dup_Status__c) 
                    && String.IsBlank(oldregRequestMap.get(regRequest.id).PRM_Dup_Status__c)) 
                || (Trigger.isUpdate && String.IsNOTBlank(regRequest.PRM_Dup_Status__c) 
                    && oldregRequestMap != null 
                    && oldregRequestMap.containsKey(regRequest.id) 
                    && String.IsBlank(oldregRequestMap.get(regRequest.id).PRM_Dup_Status__c ) 
                    && regRequest.PRM_Auto_Approve__c == false 
                    && String.IsBlank(regRequest.PRM_Salesforce_ID__c))
            ){
                System.debug('Inside if');
                PRM_Language_Culture_Mapping__mdt langCulEmail;
                for (PRM_Language_Culture_Mapping__mdt mdtRec : lngmapping){
                    if(langCulEmail == null && (mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase('us'))){
                        langCulEmail = mdtRec;
                    }
                    if(mdtRec.PRM_Country_Cd__c != null 
                        && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase(regRequest.PRM_Contact_Country__c)
                        && mdtRec.MasterLabel == regRequest.PRM_Preferred_Language__c
                    ){
                        langCulEmail = mdtRec;
                    }
                }
                PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();
                objEmailNotif.ChannelProgram = PRM_Intel_Partner_Alliance;
                objEmailNotif.EmailID = regRequest.PRM_Email_ID__c;
                objEmailNotif.Language = regRequest.PRM_Preferred_Language__c;
                Map<String, String> paramMap = new Map<String, String>();
                paramMap.put('Registration_Request_ID', regRequest.id);
                if(langCulEmail != null){
                    paramMap.put('LanguageCulture_MDT', langCulEmail.Id);
                }
                objEmailNotif.InputParameters = paramMap;
                objEmailNotif.BusinessEvent = PRM_Registration_request_Acknowledgement_Email;
                
                objEmailNotifList.add(objEmailNotif);
                if(Trigger.isInsert){
                    PRM_CreateAccountAndRelatedRecords.linkEmailLogToContact(regRequest.PRM_Email_ID__c);
                }
            }
        }
        if(!objEmailNotifList.isEmpty()){
            PRM_EmailUtility.sendEmail(objEmailNotifList);
        }
    }
    
    public static void updateRelatedACROfAccount(Map<id, sObject> regObjects,Map<id, PRM_Registration_Request__c> oldRegReqMap){
        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
        Map<String, PRM_Registration_Request__c> mapOfEmailRegRequest = new Map<String, PRM_Registration_Request__c>();
        Map<String, String> mapOfContacts = new Map<String, String>();
        Map<id, sObject> mapOfUpdateACR = new Map<id, sObject>();
        
        for (sObject obj : regObjects.values()){
            PRM_Registration_Request__c regReq = (PRM_Registration_Request__c) obj;
            if(isActive('Admin_Reg_Approve') && ((oldRegReqMap == null 
                && regReq.PRM_Email_Verification_Criteria__c == 'success' 
                && regReq.PRM_Status__c == 'Approved') 
                || ((oldRegReqMap != null 
                    && oldRegReqMap.size() > 0) 
                    && oldRegReqMap.get(regReq.Id).PRM_Email_Verification_Criteria__c != regReq.PRM_Email_Verification_Criteria__c 
                    && regReq.PRM_Email_Verification_Criteria__c == 'success'
                    && regReq.PRM_Status__c == 'Approved'))
            ){
                if(!mapOfEmailRegRequest.containsKey(regReq.PRM_Email_ID__c)){
                    mapOfEmailRegRequest.put(regReq.PRM_Email_ID__c,regReq);
                }
            }
        }

        if(!mapOfEmailRegRequest.isEmpty()){
            for (Contact conobj : [SELECT Id, AccountId, Email
                                   FROM Contact
                                   WHERE Email IN :mapOfEmailRegRequest.keySet()]
            ){
                mapOfContacts.put(conobj.id, conobj.email);
            }
        }
        
        if(IS_CIDAAS_ENABLED){
            if(mapOfContacts!=null && mapOfContacts.size()>0){
                acrList = [SELECT id, PRM_Account_Id__c, PRM_Account_Id__r.name, PRM_Contact_Id__c, PRM_Partner_Role__c, PRM_Contact_Id__r.name,
                           PRM_Contact_Id__r.email, PRM_Contact_Id__r.Core_Preferred_Language__c, PRM_Contact_Id__r.Core_Do_Not_Contact__c,
                           PRM_Relationship_Id__r.name, PRM_InActive_Ind__c, IsDeleted, PRM_Status_Nm__c
                           FROM PRM_Account_Contact_Relationship__c
                           WHERE PRM_Contact_Id__c IN :mapOfContacts.keySet() AND PRM_Status_Nm__c = 'Pending Action'];
            }
        }
        else{
            if(mapOfContacts!=null && mapOfContacts.size()>0){
                acrList = [SELECT id, PRM_Account_Id__c, PRM_Account_Id__r.name, PRM_Contact_Id__c, PRM_Partner_Role__c, PRM_Contact_Id__r.name,
                           PRM_Contact_Id__r.email, PRM_Contact_Id__r.Core_Login_Id__c, PRM_Contact_Id__r.Core_Preferred_Language__c,
                           PRM_Contact_Id__r.Core_Do_Not_Contact__c, PRM_Relationship_Id__r.name, PRM_InActive_Ind__c, IsDeleted,  PRM_Status_Nm__c
                           FROM PRM_Account_Contact_Relationship__c
                           WHERE PRM_Contact_Id__c IN :mapOfContacts.keySet() AND PRM_Status_Nm__c = 'Pending Action'];   
            }
        }
        
        if(acrList != null){
            for (PRM_Account_Contact_Relationship__c acrObject : acrList){
                if(acrObject.PRM_Contact_Id__c != null 
                    && String.isNotBlank(acrObject.PRM_Contact_Id__r.email) 
                    && mapOfEmailRegRequest.containsKey(acrObject.PRM_Contact_Id__r.email) 
                    && String.isNotBlank(mapOfEmailRegRequest.get(acrObject.PRM_Contact_Id__r.email).PRM_Partner_Role__c ) 
                    && String.isNotBlank(acrObject.PRM_Partner_Role__c)
                    && acrObject.PRM_Partner_Role__c.contains(mapOfEmailRegRequest.get(acrObject.PRM_Contact_Id__r.email).PRM_Partner_Role__c) 
                    && acrObject.PRM_Account_Id__c == mapOfEmailRegRequest.get(acrObject.PRM_Contact_Id__r.email).PRM_Salesforce_ID__c
                ){
                    acrObject.PRM_InActive_Ind__c = false;
                    acrObject.PRM_Status_Nm__c = 'Complete';
                    acrObject.PRM_Status_Reason_Txt__c = System.Label.PRM_APPROVE_MSG;
                    acrObject.PRM_No_Email__c = true;
                    mapOfUpdateACR.put(acrObject.id, acrObject);
                }
            }
            
            system.debug('Total queries executed after ACR creation Part1--->' + Limits.getQueries());
            if(mapOfUpdateACR.size()>0 && !mapOfUpdateACR.isEmpty()){
                //List<Database.SaveResult> updateACRResult = PRM_DMLUtility.doupdate(mapOfUpdateACR.values(), acrList[0], 'PRM_RegRequest_TriggerHandlerNew.updateRelatedACROfAccount');
            } 
            system.debug('Total queries executed after ACR creation Part2--->' +Limits.getQueries());
        }
        
        if(!mapOfUpdateACR.isEmpty()){
            String[] partnerRoleSet = new List<String>();
            for (PRM_Registration_Request__c regReq : mapOfEmailRegRequest.values()){
                partnerRoleSet.add(regReq.PRM_Partner_Role__c);
            }
            
            PRM_EmailToPrimaryContact.sendEmailToAllPrimaryContactWrapper obj=new PRM_EmailToPrimaryContact.sendEmailToAllPrimaryContactWrapper();
            obj.accConRelMap=null;
            obj.accConNewMap=mapOfUpdateACR;
            obj.inputPartnerRole=partnerRoleSet;
            obj.isAfterInsert=true;
            obj.isAfterDelete=false;
            PRM_EmailToPrimaryContact.sendEmailToAllPrimaryContact(obj);//Athr fixes
            //PRM_EmailToPrimaryContact.sendEmailToAllPrimaryContact(null,mapOfUpdateACR,partnerRoleSet,true,false);
        }
    }
}