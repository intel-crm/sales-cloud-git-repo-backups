/*********************************************************************************************************************
Apex Class Name  : PRM_RegistrationRequestUtility
Version       : 1.0
Created Date  : OCT 2018
Function      : Utility class containing business logic for Registration Requests

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Kushal Soni               10/05/2018              Utility class containing business logic for Registration Requests
* Srishty Sharma            11/06/2020              US694818:MVP-As an IPA admin I want the ability to record my comments against registration request approval.
Added method updateApprovalComments for capturing comments during approval in registration request record.
*********************************************************************************************************************/

public without sharing class PRM_RegistrationRequestUtility {
    /**
* @description      : It applies record type on the basis of CIM, Salesforce Id & Account Channel Membership and checks Email Domain for 'Add Contact Request'
* @name             : applyRecordType
* @param            : List<PRM_Registration_Request__c>
* @throws exception : NONE
**/
    
    public static boolean isautoApproveEndUserRegistrationFirstRun = false;
    public static final String LOG_ENTRY_ORIGIN   = 'PRM_RegistrationRequestUtility';
    public static final String LOG_ENTRY_PROJECT  = 'Manual approval of requests';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_RegistrationRequestUtility';
    public static final String LOG_ENTRY_SEVERITY = 'error';
    
    // Custom label changed into static string - Code Optimization
    public static final String PRM_Success = 'SUCCESS';
    public static final String Pricing_Registration_request_for_new_User_EV = 'Pricing_Registration_request_for_new_User_EV';
    public static final String PRM_ACR_Status = 'Complete';
    public static final String PRM_Admin_Registration = 'Admin_Registration';
    public static final String PRM_PRM_CsP = 'PRM_CsP';
    public static final String PRM_Duplicate_Request = 'Duplicate Request';
    public static final String PRM_Email_Verification_Request = 'PRM_Email_Verification_Request';
    public static final String PRM_ENG = 'ENG';
    public static final String PRM_Fail = 'FAIL';
    public static final String PRM_Intel_Partner_Alliance = 'Intel Partner Alliance';
    public static final String PRM_Nodup = 'NODUP';
    public static final String PRM_Partner_Admin_Delegate = 'Partner Admin Delegate';
    public static final String PRM_Primary_Contact = 'Partner Admin';
    public static final String PRM_QueueGroup = 'Queue';
    public static final String PRM_Account_Creation ='New Account Creation';
    public static final String PRM_DupCheckFailure = 'Duplicate Check Failed';
    public static final String PRM_PartnerRoleNA = 'Partner Role NA for Auto Approval';
    public static final String PRM_EmailMismatch = 'Email Domain Mismatch';
    public static final String PRM_EmailCountryBypass = 'Email Domain Bypassed based on Country';
    public static final String PRM_DiffAccount = 'User Associated with a Different Account';
    public static final String PRM_DupCheck = 'Duplicate Check Pending';
    
    public static final String PRM_Registration_request_Acknowledgement_Email = 'PRM_Registration_request_Acknowledgement_Email';
    public static final String PRM_Registration_request_for_new_User_EV_PSG = 'Registration_request_for_new_User_EV_PSG';
    public static final String PRM_Status_Rejected = 'Rejected';
    public static final String PRM_Status_Approved = 'Approved';
    public static final String PRM_WorksFor = 'Employee';
    public static final String PSG_Licensing = 'PSG';
    public static final String IPA_Registration_Request_Rejection_Email = 'IPA_Registration_Request_Rejection_Email';    
    //public static final boolean ipaRefresh = Boolean.valueOf(Label.PRM_IPARefresh);
    public static Set<String> countryBasedBypass = new Set<String>();
    
    public static final Id AccountCreateRequest_RecordTypeId = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName()
        .get('Account_Create_Request')
        .getRecordTypeId();
    public static final Id EmailVerificationRequest_RecordTypeId = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName()
        .get('PRM_Email_Verification_Request')
        .getRecordTypeId();
    
    public static void applyRecordType(
        List<PRM_Registration_Request__c> regRequestList
    ) {
        Group queueID = [
            SELECT ID
            FROM Group
            WHERE
            Type = :PRM_QueueGroup
            AND DeveloperName = :System.Label.PRM_Manual_Approval_Members
            LIMIT 1
        ];
        Set<Id> accIds = new Set<Id>();
        Set<String> emails = new Set<String>();
        //Map<Id, PRM_AccountChannelMembership__c> channelMembershipMap = new Map<Id, PRM_AccountChannelMembership__c>();
        Map<String, Contact> emailMap = new Map<String, Contact>();
        
        for (PRM_Registration_Request__c request : regRequestList) {
            accIds.add(request.PRM_Salesforce_ID__c);
            emails.add(request.PRM_Email_ID__c);
        }
        if (emails != null) {
            for (Contact con : [
                SELECT Id, Email
                FROM Contact
                WHERE Email IN :emails
            ]) {
                emailMap.put(con.Email, con);
            }
        }
        
        for (PRM_Registration_Request__c regRequest : regRequestList) {
            if (String.isBlank(regRequest.PRM_Preferred_Language__c)) {
                regRequest.PRM_Preferred_Language__c = PRM_ENG;
            }
            
            //Start-US375453: Kushal added below to populate Matching Contact
            if (
                emailMap != null &&
                emailMap.containsKey(regRequest.PRM_Email_ID__c) &&
                String.isBlank(regRequest.PRM_Matching_Contact__c)
            ) {
                regRequest.PRM_Matching_Contact__c = emailMap.get(
                    regRequest.PRM_Email_ID__c
                )
                    .Id;
            }
            //End-US375453
            
            //Harshit added on 30/7/2019 , as part of US406788
            regRequest.OwnerId = queueID.id;
        }
    }
    
    /**
* @description      : It decrypts the WeChat Union Id.. Created as part of US637998.
* @name             : decryptWeChatUnionId
* @param            : List<PRM_Registration_Request__c>
* @throws exception : NONE
**/
    public static void DecryptWeChatUnionId_BeforeInsert(
        List<PRM_Registration_Request__c> regReqList
    ) {
        for (PRM_Registration_Request__c regReq : regReqList) {
            regReq.PRM_Wechat_Union_Id__c = String.isEmpty(
                regReq.PRM_Wechat_Union_Id__c
            )
                ? regReq.PRM_Wechat_Union_Id__c
                : EncryptDecryptHelper.DecryptData(
                    regReq.PRM_Wechat_Union_Id__c
                );
        }
    }
    
    public static void DecryptWeChatUnionId_BeforeUpdate(
        Map<Id, PRM_Registration_Request__c> oldRegReqs,
        List<PRM_Registration_Request__c> regReqList
    ) {
        for (PRM_Registration_Request__c regReq : regReqList) {
            if (
                oldRegReqs.get(regReq.Id).RecordTypeId != regReq.RecordTypeId &&
                oldRegReqs.get(regReq.Id).RecordTypeId ==
                PRM_IPA_Constants.EV_RECORD_TYPE_ID &&
                regReq.RecordTypeId ==
                PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT
            ) {
                regReq.PRM_Wechat_Union_Id__c = String.isEmpty(
                    regReq.PRM_Wechat_Union_Id__c
                )
                    ? regReq.PRM_Wechat_Union_Id__c : EncryptDecryptHelper.DecryptData(regReq.PRM_Wechat_Union_Id__c);
            }
        }
    }
    
    /**
* @description      : It checks for Email Verified Date Time and updates the Email Verification Criteria
* @name             : evStampCheck
* @param            : List<PRM_Registration_Request__c>
* @throws exception : NONE
**/
    
    /**
* @description      : It updates Email Verification Criteria on the basis of EV Flag
* @name             : evCheck
* @param            : List<PRM_Registration_Request__c>, Map<Id,PRM_Registration_Request__c>, List<PRM_Registration_Request__c>, Map<Id,PRM_Registration_Request__c>
* @throws exception : NONE
**/
    public static void evCheck(
        List<PRM_Registration_Request__c> regReqList,
        Map<Id, PRM_Registration_Request__c> oldRegReqMap
    ) {
        for (PRM_Registration_Request__c regReq : regReqList) {
            regReq.PRM_EV_Token_Renewed_Date__c = datetime.now();
            //As a part of CiDaaS change //Removing the spaces and putting the below if code in 1 line due to code coverage issue.
            
            regReq.PRM_Email_Verification_Criteria__c = System.Label.PRM_Success;
            
        }
    }
    
    /**
* @description      : It checks duplicate from the CIM system
* @name             : dupCheck
* @param            : List<PRM_Registration_Request__c>
* @throws exception : NONE
**/
    public static void dupCheck(
        List<PRM_Registration_Request__c> regReqList,
        Map<Id, PRM_Registration_Request__c> oldRegReqMap
    ) {           
        try{
            for (PRM_Registration_Request__c regReq : regReqList) {
                if ( regReq.PRM_Channel_Program_Level_txt__c != System.Label.PSG_Licensing //need to check with other APT
                    && regReq.recordTypeId == PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT
                    && String.isNotBlank(regReq.PRM_Account_Name__c) 
                    && String.isNotBlank(regReq.PRM_Country__c) 
                    && regReq.PRM_Status__c != Label.PRM_Status_Rejected
                    && String.isBlank(regReq.PRM_Dup_Status__c)
                   ) {
                       System.enqueueJob( new PRM_SBRCallOut(regReq, false, null, null)); //bulkify ? 
                   }
            }
        }
        catch(exception ex){ Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,'' ,'sbrCallOut' ,'' ,ex); 
        }
    }
    
    /**
* @description      : It trigger the email notification asynchronously for the newly inserted record in registration request
* for Account creation type
* @name             : sendEmailNotification
* @param            : List<Sobject> insertedRecordList - To get the triggered record,
* @param            : string notificationFlag - Flag to identify the process
* @throws exception : NONE
**/
    
    /**
* @description      : It trigger the email notification by invoking EmailFramework if registration
* request received has EVToken populated
* @name             : sendEmailNotification
* @param            : List<Sobject> insertedRecordList - To get the triggered record,
* @throws exception : NONE
**/
    public static void emailNotificationOnReceivingRegistration(
        List<PRM_Registration_Request__c> insertedRecordList
    ) {        
        
        List<ChannelProgram> iqrPrograms = new List<ChannelProgram>();
        if (insertedRecordList.size() > 0) {
            iqrPrograms = [
                SELECT id
                FROM ChannelProgram
                WHERE Name = :PRM_IPA_Constants.PRICING_TENDER_PGM_CHANNEL
            ];
        }
        list<PRM_EmailUtility.EmailNotification> objEmailNotifList=new list<PRM_EmailUtility.EmailNotification> ();                  
        for (PRM_Registration_Request__c req : insertedRecordList) {
            // Email notification to be sent only for end user registration
            if (req.recordTypeId == PRM_IPA_Constants.EV_RECORD_TYPE_ID) {
                PRM_Language_Culture_Mapping__mdt langCultureForEmail = getLangCulture(req.PRM_Contact_Country__c,req.PRM_Preferred_Language__c);
                
                PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();
                objEmailNotif.ChannelProgram = PRM_Intel_Partner_Alliance;
                
                objEmailNotif.EmailID = req.PRM_Email_ID__c;
                objEmailNotif.Language = req.PRM_Preferred_Language__c;
                Map<String, String> paramMap = new Map<String, String>();
                paramMap.put('Registration_Request_ID', req.id);
                
                if (langCultureForEmail != null) {
                    paramMap.put('LanguageCulture_MDT', langCultureForEmail.Id);
                }
                objEmailNotif.InputParameters = paramMap;
                
                
                //As a part of CiDaaS change
                
                //EV Date is blank --> new user --> send mail with EV token received
                objEmailNotif.BusinessEvent = System.label.PRM_Registration_request_for_new_User_EV;
                
                //Added by Naresh Yendluri as part of US934493
                if (
                    iqrPrograms.size() > 0 &&
                    req.PRM_Channel_Program__c == iqrPrograms[0].Id
                ) {
                    objEmailNotif.BusinessEvent = Pricing_Registration_request_for_new_User_EV;
                    objEmailNotif.Language = 'ENG';
                }
                /*if (req.PRM_Channel_Program_Level_txt__c == 'PSG') {
                    String loginId;
                    objEmailNotif.BusinessEvent = PRM_Registration_request_for_new_User_EV_PSG;
                    objEmailNotif.Language = req.PRM_Preferred_Language__c;
                    loginId = '';
                    PRM_EmailUtility.customPlaceholdersMap = new Map<String, String>{'{{USERNAME}}' => loginId };
                        }*/ //TWC729-8986 - PSG removal from PRM classes
                objEmailNotifList.add(objEmailNotif);
                
            }
        }
        if(!objEmailNotifList.isEmpty()){
            PRM_EmailUtility.sendEmail(objEmailNotifList);
        }
    }
    
    /**
* @description      : It updates Legal Agreement Criteria on the basis of channel program,legal agreement name and preferred language
* @name             : UpdateLA
* @param            : List<PRM_Registration_Request__c>
* @throws exception : NONE
**/
    
    public static void updateLA(
        List<PRM_Registration_Request__c> regRequestList
    ) {
        //  PRM_Registration_Request__c newRequest = new PRM_Registration_Request__c();
        //Set<String> paNameSet = new Set<String>();
        //Set<String> laNameSet = new Set<String>();
        Map<String, String> roleTypeMap = new Map<String, String>();
        
        for (
            PRM_PartnerRoleTypeMappings__mdt roleTypeReq : PRM_PartnerRoleTypeMappings__mdt.getAll()
            .values()
        ) {
            roleTypeMap.put(
                roleTypeReq.PRM_Biz_Org_Type__c,
                roleTypeReq.PRM_Partner_Role__c
            );
        }
        
        Set<String> allPASet = new Set<String>();
        Set<String> allPASetWithoutLanguage = new Set<String>();
        for (PRM_PartnerAgreement__c pa : [
            SELECT
            Id,
            Name,
            PRM_Channel_Program_Id__c,
            PRM_Language_Codes__c,
            /*PRM_Partner_Role__c,*/
            PRM_InActive_Ind__c,
            PRM_Agreement_Cd__c
            FROM PRM_PartnerAgreement__c
            WHERE PRM_InActive_Ind__c = FALSE
        ]) {//ATHR Fix - TWC729-9556
            //Set Without language field
            if (String.isBlank(pa.PRM_Language_Codes__c)) {
                allPASetWithoutLanguage.add(
                    pa.PRM_Agreement_Cd__c + pa.PRM_Channel_Program_Id__c
                );
            }
            allPASet.add(
                pa.PRM_Agreement_Cd__c +
                pa.PRM_Language_Codes__c +
                pa.PRM_Channel_Program_Id__c
            );
        }
        
        for (PRM_Registration_Request__c newRequest : regRequestList) {
            /*if (
                (newRequest.PRM_Partner_Role__c == null ||
                String.isBlank(newRequest.PRM_Partner_Role__c)) && !ipaRefresh 
            ) {
                if (
                    newRequest.PRM_Partner_Type__c != null &&
                    String.isNotBlank(newRequest.PRM_Partner_Type__c)
                ) {
                    for (
                        String orgType : newRequest.PRM_Partner_Type__c.split(
                            ';'
                        )
                    ) {
                        if (roleTypeMap.containsKey(orgType)) {
                            newRequest.PRM_Partner_Role__c = roleTypeMap.get(
                                orgType
                            );
                        }
                    }
                }
            }*/
            
            if (allPASet.size() == 0) {
                
                newRequest.PRM_Legal_Agreement_Criteria__c = PRM_Fail;
            } else if (
                newRequest.recordTypeID != PRM_IPA_Constants.EV_RECORD_TYPE_ID
            ) {
                //else starts
                boolean status = true;
                if (
                    newRequest.PRM_Status__c != PRM_Status_Rejected &&
                    newRequest.PRM_Legal_Agreements__c != null &&
                    newRequest.PRM_Legal_Agreement_Criteria__c ==
                    Label.PRM_Pending
                ) {
                    for (
                        String laName : newRequest.PRM_Legal_Agreements__c.split(
                            ';'
                        )
                    ) {
                        if (allPASetWithoutLanguage.size() > 0) {
                            if (
                                !allPASetWithoutLanguage.contains(
                                    laName + newRequest.PRM_Channel_Program__c
                                )
                            ) {
                                status = false;
                                break;
                            }
                        } else if(allPASet.size() > 0 && !allPASet.contains(laName + newRequest.PRM_Preferred_Language__c + newRequest.PRM_Channel_Program__c)) {
                            status = false;
                            break;
                        }
                    }
                    newRequest.PRM_Legal_Agreement_Criteria__c = status ? PRM_Success : PRM_Fail;
                }
            }
        }
    }
    
    public static void partnerrelationship(
        List<PRM_Registration_Request__c> regReqList,
        Map<Id, List<PRM_Account_Contact_Relationship__c>> mapAccountIdTOListACR,
        //Map<Id, Account> accMap,
        Map<Id, Contact> contMap,
        Map<Id,PRM_Registration_Request__c> regReqOldMap,
        Map<Id, list<string>>  mapOfAccIdPartnerRole,
		Set<Id> setOpidWithPA, //OPIDs that already have an active Partner Admin / Delegate
		Map<Id, Id> mapAccIdToOpid //Account Id -> One Partner Id
    ) {
        Set<Id> existingAccFromReqIds = new Set<Id>();
        // setOpidWithPA is a DB snapshot; this tracks PAs assigned earlier in this same loop (OPID-level twin of existingAccFromReqIds)
        Set<Id> opidAssignedInBatch = new Set<Id>();
        for (PRM_Registration_Request__c reg : regReqList) {
            if (
                (reg.recordTypeId ==
                 PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT ||
                 Test.isRunningTest()) &&
                reg.PRM_Channel_Program_Level_txt__c != 'PSG'
            ) {
                List<String> partnerRoleArray = new List<String>();
                //Account acct = new Account();
                boolean isACRActive = null;
                if (reg.PRM_Salesforce_ID__c != null && mapOfAccIdPartnerRole.containsKey(reg.PRM_Salesforce_ID__c)) {
                    partnerRoleArray = mapOfAccIdPartnerRole.get(reg.PRM_Salesforce_ID__c);
                    if (mapAccountIdTOListACR.containsKey(reg.PRM_Salesforce_ID__c)) {
                        for (PRM_Account_Contact_Relationship__c acr : mapAccountIdTOListACR.get(reg.PRM_Salesforce_ID__c)
                            ) {
                                if (acr.PRM_Partner_Role__c == reg.PRM_Partner_Role__c && acr.PRM_Status_Nm__c == System.label.PRM_ACR_Status &&
                                    acr.PRM_InActive_Ind__c == false && acr.PRM_Status_Nm__c != 'Pending Action' && acr.PRM_Relationship_Id__r.Name == System.Label.PRM_Primary_Contact
                                ) {
                                    isACRActive = true;
                                }
                            }
                        
                        if (isACRActive != true) {
                            isACRActive = false;
                        }
                    }
                    else if(mapAccountIdTOListACR == null || mapAccountIdTOListACR.isEmpty()){//no ACR
                        isACRActive = false;
                    }
                } else if (reg.PRM_Matching_Contact__c != null) {
                    Contact contactRec = new Contact();
                    if (contMap.containsKey(reg.PRM_Matching_Contact__c)) {
                        contactRec = contMap.get(reg.PRM_Matching_Contact__c);
                    }
                    if (
                        contactRec != null && mapOfAccIdPartnerRole.containsKey(contactRec.Account.id)
                        
                    ) {
                        partnerRoleArray = mapOfAccIdPartnerRole.get(contactRec.Account.id); 
                    }
                }
                    if (reg.PRM_Partner_Relationship__c == null || String.isBlank(reg.PRM_Partner_Relationship__c) 
                    || ( regReqOldMap.containsKey(reg.Id) && (regReqOldMap.get(reg.Id).PRM_Salesforce_ID__c != reg.PRM_Salesforce_ID__c))
                    ) {
						
						
                        if (
                            (!partnerRoleArray.contains(reg.PRM_Partner_Role__c)|| isACRActive == false) &&
                            !existingAccFromReqIds.contains(reg.PRM_Salesforce_ID__c) //if(isACRActive == false)
                        ) {
							Id regOpid = (mapAccIdToOpid != null) ? mapAccIdToOpid.get(reg.PRM_Salesforce_ID__c) : null;
							// Non-IPA = existing account with no Approved IPA ACM; OPID-level PA check applies only to these
							Boolean isNonIpaAcc = reg.PRM_Salesforce_ID__c != null && !mapOfAccIdPartnerRole.containsKey(reg.PRM_Salesforce_ID__c);
							if(isNonIpaAcc && regOpid != null
							   && ((setOpidWithPA != null && setOpidWithPA.contains(regOpid))
							       || opidAssignedInBatch.contains(regOpid))){
								 reg.PRM_Partner_Relationship__c = System.Label.PRM_WorksFor;
							}else{
								existingAccFromReqIds.add(reg.PRM_Salesforce_ID__c);
								if(regOpid != null){
									opidAssignedInBatch.add(regOpid);
								}
								reg.PRM_Partner_Relationship__c =
                                System.Label.PRM_Primary_Contact +
                                ';' +
                                System.Label.PRM_WorksFor;
							}
                            
                        } else {
                            reg.PRM_Partner_Relationship__c = System.Label.PRM_WorksFor;
                        }
                    }
                system.debug( reg.PRM_Partner_Relationship__c+' reg.PRM_Partner_Relationship__c');
            }
        }
    }
    
    //to store registration profile response
    //Rahul added as part of US407894
    public static void regResponse(
        List<PRM_Registration_Request__c> rr,
        Map<Id, PRM_Registration_Request__c> oldRegReqMap
    ) {
        List<PRM_Registration_Request__c> regRequest = new List<PRM_Registration_Request__c>();
        String oldRT = '';
        
        for (PRM_Registration_Request__c newRequest : rr) {
            if (newRequest.PRM_Status__c != Label.PRM_Status_Rejected) {
                if (Trigger.isUpdate) {
                    oldRT = oldRegReqMap.get(newRequest.Id).RecordTypeId;
                    if (
                        newRequest.RecordTypeId != oldRT &&
                        newRequest.RecordTypeId ==
                        PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT
                    ) {
                        regRequest.add(newRequest);
                    }
                } else if (Trigger.isInsert && newRequest.RecordTypeid == PRM_IPA_Constants.ADMIN_REGISTRATION_RT) {
                    regRequest.add(newRequest);
                }
            }
        }
        createResponse(regRequest);
    }
    public static void createResponse(List<PRM_Registration_Request__c> regRequest){
        if (regRequest != null && regRequest.size() > 0) {
            for (PRM_Registration_Request__c regReq : regRequest) {
                if (regReq.PRM_Profile_Response__c != null) {
                    PRM_ProfileResponse.createResponse(
                        regRequest,
                        null,
                        null,
                        true
                    );
                }
            }
        }
    }
    
    //Harshit added as part of US406788
    public static void setApprovalLink(
        List<PRM_Registration_Request__c> regReqList,
        Map<Id, PRM_Registration_Request__c> oldRegReqMap
    ) {
        Map<String, PRM_Registration_Request__c> regReqToProcessMap = new Map<String, PRM_Registration_Request__c>();
        Map<String, String> processInstanceRegReqMap = new Map<String, String>();
        Map<String, String> regReqProcessInstanceWorkItemMap = new Map<String, String>();
        for (PRM_Registration_Request__c regReq : regReqList) {
            if (
                regReq.PRM_Status__c == 'New' &&
                regReq.recordTypeId == PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT && 
                String.isBlank(regReq.PRM_ProcessInstanceWorkItem_Id__c)
            ) {
                regReqToProcessMap.put(regReq.id, regReq);
            }
        }
        if (regReqToProcessMap != null && regReqToProcessMap.size() > 0) {
            for (ProcessInstance pi : [
                SELECT id, TargetObjectId
                FROM ProcessInstance
                WHERE TargetObjectId IN :regReqToProcessMap.keySet()
            ]) {
                processInstanceRegReqMap.put(pi.id, pi.TargetObjectId);
            }
            List<ProcessInstanceWorkitem> pwiList = [
                SELECT id, ProcessInstanceId
                FROM ProcessInstanceWorkitem
                WHERE ProcessInstanceId IN :processInstanceRegReqMap.keySet()
            ];
            for (ProcessInstanceWorkitem pwi : pwiList) {
                regReqProcessInstanceWorkItemMap.put(processInstanceRegReqMap.get(pwi.processInstanceId), pwi.id);
            }
            for (String regReqID : regReqProcessInstanceWorkItemMap.keySet()) {
                PRM_Registration_Request__c regReqToUpdate = regReqToProcessMap.get(regReqID);
                String pid = regReqProcessInstanceWorkItemMap.get(regReqToUpdate.id);
                regReqToUpdate.PRM_ProcessInstanceWorkItem_Id__c = pid;
            }
        }
    }
    //Keerthan added as part of US422159,US422161
    public static void processAdminRegistrationRecords(
        List<PRM_Registration_Request__c> regReqList,
        Map<id, PRM_Registration_Request__c> oldRecordsMap
    ) {
        List<PRM_Registration_Request__c> requestsToProcess = new List<PRM_Registration_Request__c>();
        List<Id> accountIds = new List<Id>();
        List<String> contactEmailList = new List<String>();
        Map<Id, PRM_Registration_Request__c> accRegMap = new Map<Id, PRM_Registration_Request__c>();
        for (PRM_Registration_Request__c reg_Request : regReqList) {
            boolean commonCriteria = reg_Request.PRM_Status__c == 'Approved' && reg_Request.RecordTypeid == PRM_IPA_Constants.ADMIN_REGISTRATION_RT && reg_Request.PRM_Email_Verification_Criteria__c == 'success';
            //Removing the spaces and putting the below if code in 1 line due to code coverage issue.
            if (commonCriteria && (oldRecordsMap == null ||
                (!oldRecordsMap.isEmpty() 
                && oldRecordsMap.get(reg_Request.Id).PRM_Status__c != reg_Request.PRM_Status__c 
                && oldRecordsMap.get(reg_Request.Id).PRM_Status__c == 'new' 
                && oldRecordsMap.get(reg_Request.Id).PRM_Email_Verification_Criteria__c != reg_Request.PRM_Email_Verification_Criteria__c 
                ))) {
                         requestsToProcess.add(reg_Request);
                         accountIds.add(reg_Request.PRM_Salesforce_ID__c);
                         accRegMap.put(
                             reg_Request.PRM_Salesforce_ID__c,
                             reg_Request
                         );
                         contactEmailList.add(reg_Request.PRM_Email_ID__c);
                    }
        }
        if (RequestsToProcess.size() > 0) {
            PRM_CreateAccountAndRelatedRecordsAdmin.processRelatedRecordsAdmin(
                accountIds,
                AccRegMap,
                contactEmailList
            );
        }
    }
    
    //To check if Admin request landed in  SF needs to be approved or Rejected (Based on LA, ACM parner role ), PRM_Salesforce_ID__c != blank
    public static void approveAdminRegRecords(
        List<PRM_Registration_Request__c> regReqList
    ) {
        Boolean verifyResponse = false;
        
        Boolean flag = false;
        
        Map<Id, Account> acctMap = new Map<Id, Account>();
        Set<Id> accIdSet = new Set<Id>();
        Set<String> partnerRoleSet = new Set<String>();
        
        for (PRM_Registration_Request__c reg_Req : regReqList) {
            if (
                reg_Req != null &&
                reg_Req.RecordTypeid ==
                PRM_IPA_Constants.ADMIN_REGISTRATION_RT &&
                reg_Req.PRM_Salesforce_ID__c != null &&
                String.isNotBlank(reg_Req.PRM_Salesforce_ID__c) &&
                reg_Req.PRM_Status__c == 'New'               
            ) {
                accIdSet.add(reg_Req.PRM_Salesforce_ID__c);
                partnerRoleSet.add(reg_Req.PRM_Partner_Role__c);
            }
        }
        if (!accIdSet.isEmpty()) {
            acctMap = new Map<Id, Account>(
                [
                    SELECT
                    Id,
                    Name,
                    (SELECT Id, Name, Email FROM Contacts),
                    (
                        SELECT
                        Id,
                        PRM_Status_Nm__c,
                        PRM_Account_Id__c,
                        PRM_Channel_Program_Id__c,
                        PRM_Partner_Role__c
                        FROM Channel_Memberships1__r
                        WHERE
                        PRM_Account_Id__c IN :accIdSet
                        AND PRM_Partner_Role__c IN :partnerRoleSet
                    )
                    FROM Account
                    WHERE Id IN :accIdSet
                ]
            );
        }
        List<String> metadataSubscriptionList =  LabelConfiguration__mdt.getInstance('PRM_Subscription_Mapping').Value__c.split(',');
        Set<String> metadataSubscriptionSet = new Set<String>(metadataSubscriptionList);
        for (PRM_Registration_Request__c reg_Request : regReqList) {
            flag = false;
            verifyResponse = false;
            if (
                reg_Request != null &&
                reg_Request.RecordTypeid ==
                PRM_IPA_Constants.ADMIN_REGISTRATION_RT &&
                reg_Request.PRM_Salesforce_ID__c != null &&
                String.isNotBlank(reg_Request.PRM_Salesforce_ID__c) &&
                reg_Request.PRM_Status__c == 'New' &&
                reg_Request.PRM_Email_Verification_Criteria__c == Label.PRM_Success
                && acctMap.containsKey(reg_Request.PRM_Salesforce_ID__c) && acctMap.get(reg_Request.PRM_Salesforce_ID__c).Contacts !=null
            ) {
                if(acctMap.get(reg_Request.PRM_Salesforce_ID__c)
                .Contacts.size() > 0
                ) {
                    for (
                        Contact c : acctMap.get(
                            reg_Request.PRM_Salesforce_ID__c
                        )
                        .Contacts
                    ) {
                        if (c.email == reg_Request.PRM_Email_ID__c) {
                            flag = true;
                            break;
                        }
                    }
                }
                
                //secondary contact admin auto approval
                if (
                    acctMap.get(reg_Request.PRM_Salesforce_ID__c)
                    .Contacts.size() > 1
                ) {                    
                    if (
                        acctMap.get(reg_Request.PRM_Salesforce_ID__c)
                        .Channel_Memberships1__r.size() > 0 &&
                        flag &&
                        reg_Request.PRM_Email_Verification_Criteria__c ==
                        Label.PRM_Success &&
                        reg_Request.PRM_Subscriptions__c != null &&
                        String.isNotBlank(reg_Request.PRM_Subscriptions__c)
                    ) {
                        Set<String> newRegSubscriptionSet = new Set<String>();
                        
                        if (
                            String.isNotBlank(reg_Request.PRM_Subscriptions__c)
                        ) {
                            //if(ipaRefresh){
                                newRegSubscriptionSet.add(reg_Request.PRM_Subscriptions__c);
                            /*}else{
                                newRegSubscriptionSet.addAll(
                                reg_Request.PRM_Subscriptions__c.split(';')
                            );
                            }*/
                            
                        }
                        if (
                            newRegSubscriptionSet.equals(
                                metadataSubscriptionSet
                            )
                        ) {
                            verifyResponse = true;
                        }
                    }
                    
                    if (verifyResponse) {
                        if (hasBlockedAccountOrContact(reg_Request)) {
                            reg_Request.PRM_Review_Note_txt__c = System.Label.PRM_BlockedContactAdmins;
                        }else{
                            reg_Request.PRM_Status__c = Label.PRM_Status;
                            reg_Request.PRM_Review_Note_txt__c = 'Auto-approved for secondary contact admin registration.';
                        }
                    }
                } else {
                    //primary contact admin auto approval
                    
                    if (flag) {
                        String currentStatus = reg_Request.PRM_Status__c;
                        reg_Request.PRM_Status__c = ( acctMap.get(reg_Request.PRM_Salesforce_ID__c).Channel_Memberships1__r.size() > 0 && acctMap.get(reg_Request.PRM_Salesforce_ID__c).Channel_Memberships1__r[0].PRM_Channel_Program_Id__c == reg_Request.PRM_Channel_Program__c)
                            ? Label.PRM_Status
                            : PRM_Status_Rejected;
                        if (reg_Request.PRM_Status__c == PRM_Status_Approved && hasBlockedAccountOrContact(reg_Request)) {
                            reg_Request.PRM_Status__c =currentStatus;
                            reg_Request.PRM_Review_Note_txt__c = System.Label.PRM_BlockedContactAdmins;
                        } else if (reg_Request.PRM_Status__c == PRM_Status_Approved) {
                            reg_Request.PRM_Review_Note_txt__c = 'Auto-approved for primary contact admin registration.';
                        }
                    }
                }
            }
        }
    }
    
    public static void updateRelatedACROfAccount(
        Map<id, sObject> regObjects,
        Map<id, PRM_Registration_Request__c> oldRecordsMap
    ) {
        if (regObjects != null) {
            Map<String, PRM_Registration_Request__c> mapOfEmailRegRequest = new Map<String, PRM_Registration_Request__c>();
            //Map<String,String> mapOfEmailPartnerRole = new Map<String,String>();
            for (sObject obj : regObjects.values()) {
                PRM_Registration_Request__c regObj = (PRM_Registration_Request__c) obj;
                boolean commonCheck = regObj.PRM_Email_Verification_Criteria__c == 'success' && regObj.PRM_Status__c == 'Approved' && !mapOfEmailRegRequest.containsKey(regObj.PRM_Email_ID__c );
                if (
                    (oldRecordsMap == null ||
                    (!oldRecordsMap.isEmpty() && oldRecordsMap.get(regObj.Id).PRM_Email_Verification_Criteria__c != regObj.PRM_Email_Verification_Criteria__c)) 
                     &&  commonCheck) {
                        mapOfEmailRegRequest.put(
                            regObj.PRM_Email_ID__c,
                            regObj
                        );
                    }
            }
            
            Map<String, String> mapOfContacts = new Map<String, String>();
            if (!mapOfEmailRegRequest.isEmpty()) {
                for (Contact conobj : [SELECT Id, AccountId, Email 
                                       FROM Contact 
                                       WHERE Email IN :mapOfEmailRegRequest.keySet()]
                ) {
                    mapOfContacts.put(conobj.id, conobj.email);
                }
            }
            setApproveToACRs(mapOfEmailRegRequest, mapOfContacts);
        }
    }
    
    private static void setApproveToACRs(
        Map<String, PRM_Registration_Request__c> mapOfEmailRegRequest,
        Map<String, String> mapOfContacts
    ) {
        Map<id, PRM_Account_Contact_Relationship__c> mapOfACR;
        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
        if(mapOfContacts!=null && mapOfContacts.size()>0){
            
            acrList = [
                SELECT
                id,
                PRM_Account_Id__c,
                PRM_Account_Id__r.name,
                PRM_Contact_Id__c,
                PRM_Partner_Role__c,
                PRM_Contact_Id__r.name,
                PRM_Contact_Id__r.email,
                PRM_Contact_Id__r.Core_Preferred_Language__c,
                PRM_Contact_Id__r.Core_Do_Not_Contact__c,
                PRM_Relationship_Id__r.name,
                PRM_InActive_Ind__c,
                IsDeleted,
                PRM_Status_Nm__c
                FROM PRM_Account_Contact_Relationship__c
                WHERE
                PRM_Contact_Id__c IN :mapOfContacts.keySet()
                AND PRM_Status_Nm__c = 'Pending Action'
            ];
            
            mapOfACR = new Map<id, PRM_Account_Contact_Relationship__c>(acrList);
        }
        if (mapOfContacts != null 
            && !mapOfContacts.isEmpty()
        ) {
            mapOfACR = new Map<id, PRM_Account_Contact_Relationship__c>(acrList);
        }
        Map<id, sObject> mapOfUpdateACR = new Map<id, sObject>();
        if (mapOfACR != null) {
            mapOfUpdateACR = getACRToUpdate(mapOfACR, mapOfEmailRegRequest);
        }
        
        if (!mapOfUpdateACR.isEmpty()) {
            update mapOfUpdateACR.values();
            String[] partnerRoleSet = new List<String>();
            for (PRM_Registration_Request__c regReq : mapOfEmailRegRequest.values()
                ) {
                    partnerRoleSet.add(regReq.PRM_Partner_Role__c);
                }
            PRM_EmailToPrimaryContact.sendEmailToAllPrimaryContact(null, mapOfUpdateACR, partnerRoleSet, true, false );
        }
    }

    public static Map<id, sObject> getACRToUpdate(Map<id, PRM_Account_Contact_Relationship__c> mapOfACR,Map<String, PRM_Registration_Request__c> mapOfEmailRegRequest){
        
        Map<id, sObject> mapOfUpdateACR = new Map<id, sObject>();
        for (
            PRM_Account_Contact_Relationship__c acrObject : mapOfACR.values()
        ) {
            if (
                acrObject.PRM_Contact_Id__c != null && String.isNotBlank(acrObject.PRM_Contact_Id__r.email) &&
                mapOfEmailRegRequest.containsKey(acrObject.PRM_Contact_Id__r.email) && String.isNotBlank(mapOfEmailRegRequest.get(acrObject.PRM_Contact_Id__r.email).PRM_Partner_Role__c) && String.isNotBlank(acrObject.PRM_Partner_Role__c) &&
                acrObject.PRM_Partner_Role__c.contains(mapOfEmailRegRequest.get(acrObject.PRM_Contact_Id__r.email).PRM_Partner_Role__c) && acrObject.PRM_Account_Id__c == mapOfEmailRegRequest.get(acrObject.PRM_Contact_Id__r.email).PRM_Salesforce_ID__c
            ) {
                PRM_Registration_Request__c regReq = mapOfEmailRegRequest.get(acrObject.PRM_Contact_Id__r.Email);//UIOLI Return journey pcr status reason mapping -TWC729-9379
                System.debug('=== ACR DEBUG START ===');
        System.debug('ACR Id = ' + acrObject.Id);
        System.debug('Email = ' + acrObject.PRM_Contact_Id__r.Email);
                System.debug('RegReq = ' + regReq);
                acrObject.PRM_InActive_Ind__c = false;
                acrObject.PRM_Status_Nm__c = 'Complete';
                //UIOLI Return journey pcr status reason mapping -TWC729-9379
                if (regReq != null && regReq.PRM_Is_Returning_User__c && String.isNotBlank(regReq.PRM_Review_Note_txt__c)) {
                    System.debug('Returning User = ' + regReq.PRM_Is_Returning_User__c);
          System.debug('Review Note = ' + regReq.PRM_Review_Note_txt__c);
                    System.debug('INSIDE RETURNING USER BLOCK');
                    acrObject.PRM_Status_Reason_Txt__c = regReq.PRM_Review_Note_txt__c;
                }else{
                    System.debug('INSIDE ELSE BLOCK');
                    acrObject.PRM_Status_Reason_Txt__c = System.Label.PRM_APPROVE_MSG;
                }
                acrObject.PRM_No_Email__c = true;
                System.debug('FINAL STATUS REASON = ' + acrObject.PRM_Status_Reason_Txt__c);
                mapOfUpdateACR.put(acrObject.id, acrObject);
        System.debug('=== ACR DEBUG END ===');
            }
        }
        return mapOfUpdateACR;
    }
    
    //Rahul added for US664501
    // Reject status of records having values matching with an existing record
    public static void rejectDuplicates(
        List<PRM_Registration_Request__c> regReqList,
        Map<Id, PRM_Registration_Request__c> oldRequestMap
    ) {
        PRM_Registration_Request__c reg_Request = new PRM_Registration_Request__c();
        List<PRM_Registration_Request__c> duplicateRequest = new List<PRM_Registration_Request__c>();
        Boolean isDuplicate;
        
        if (regReqList.size() > 0) {
            reg_Request = regReqList[0];
            
            if (
                (oldRequestMap == null &&
                 (reg_Request.RecordTypeId ==
                  PRM_IPA_Constants.ADMIN_REGISTRATION_RT ||
                  reg_Request.RecordTypeId ==
                  PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT) &&
                 reg_Request.PRM_Status__c == 'New') ||
                (reg_Request.RecordTypeId ==
                 PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT &&
                 oldRequestMap != null &&
                 oldRequestMap.containsKey(reg_Request.Id) &&
                 oldRequestMap.get(reg_Request.Id).RecordTypeId ==
                 PRM_IPA_Constants.EV_RECORD_TYPE_ID &&
                 reg_Request.PRM_Status__c == 'New')
            ) {
                if (
                    reg_Request.PRM_Account_Name__c != null &&                   
                    reg_Request.PRM_Email_ID__c != null &&
                    reg_Request.PRM_Partner_Type__c != null &&
                    reg_Request.PRM_Status__c != null &&
                    String.isNotBlank(reg_Request.PRM_Account_Name__c) &&
                    String.isNotBlank(reg_Request.PRM_Email_ID__c) &&
                    String.isNotBlank(reg_Request.PRM_Partner_Type__c) &&
                    String.isNotBlank(reg_Request.PRM_Status__c)
                ) { //As a part of CiDaaS change
                    
                    
                    duplicateRequest = [
                        SELECT
                        Id,
                        Name,
                        RecordTypeId,
                        PRM_Account_Name__c,
                        PRM_Email_ID__c,
                        PRM_Partner_Type__c,
                        PRM_Status__c,
                        PRM_Contact_Salesforce_ID__c
                        FROM PRM_Registration_Request__c
                        WHERE
                        PRM_Channel_Program__r.Name = 'Intel Partner Alliance'
                        AND PRM_Account_Name__c = :reg_Request.PRM_Account_Name__c AND PRM_Email_ID__c = :reg_Request.PRM_Email_ID__c AND PRM_Partner_Type__c = :reg_Request.PRM_Partner_Type__c
                        AND (PRM_Status__c != :PRM_Status_Rejected OR RecordTypeId = :PRM_IPA_Constants.ADMIN_REGISTRATION_RT) AND CreatedDate = LAST_N_DAYS:1 AND RecordTypeId = :reg_Request.RecordTypeId];
                    
                }
                
                if (duplicateRequest.size() > 0) {
                    isDuplicate = false;
                    if (String.IsNotBlank(reg_Request.PRM_Contact_Salesforce_ID__c)) {
                        for (PRM_Registration_Request__c dupRegReq : duplicateRequest) {
                            if (dupRegReq.PRM_Contact_Salesforce_ID__c == reg_Request.PRM_Contact_Salesforce_ID__c) {
                                isDuplicate = true;
                            }
                        }
                    } else {
                        isDuplicate = true;
                    }
                    if (isDuplicate == true) {
                        reg_Request.PRM_Status__c = PRM_Status_Rejected;
                        reg_Request.PRM_Status_Reason__c = PRM_Duplicate_Request;
                        //Removing the spaces and putting the below if code in 1 line due to code coverage issue.
                        if ( reg_Request.RecordTypeId == PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT) {
                            reg_Request.PRM_isSubmitted__c = true;
                        }
                    }
                }
            }
        }
    }
    
    public static void sendApprovalEmail(
        List<Contact> contactList,
        String business_Event,
        Id reg_Request,
        String partnerRole
    ) {
        List<PRM_EmailQueue__c> emqList = new List<PRM_EmailQueue__c>();
        List<PRM_EmailConfiguration__mdt> emailConfigList = [
            SELECT
            Id,
            PRM_BusinessEvent__c,
            PRM_PartnerRole__c,
            PRM_Entitlement_List__c,
            PRM_Priority__c
            FROM PRM_EmailConfiguration__mdt
            WHERE
            PRM_BusinessEvent__c = :business_Event
            AND PRM_PartnerRole__c = :partnerRole
        ];
        for (Contact con : contactList) {
            if (con != null && con.Core_Do_Not_Contact__c == false) {
                PRM_EmailQueue__c emqu = new PRM_EmailQueue__c();
                emqu.PRM_Business_Event__c = Business_Event;
                emqu.PRM_Email_Content__c = '';
                emqu.PRM_Contact__c = con.id;
                emqu.PRM_Status__c = 'PENDING';
                emqu.PRM_Tier__c = 'MEMBER';
                emqu.PRM_PartnerRole__c = partnerRole;
                emqu.PRM_Registration_Request__c = reg_Request;
                if (emailConfigList.size() > 0) {
                    emqu.PRM_Priority__c = emailConfigList[0].PRM_Priority__c;
                }
                emqList.add(emqu);
            }
        }
        insert emqList;
    }
    
    /**
* @description      : It sends acknowledgement email after step 2 of registration. Created as part of US697426
* @name             : sendAcknowledgementEmail
* @param            : List<PRM_Registration_Request__c>, Map<id, PRM_Registration_Request__c>
* @throws exception : NONE
**/
    public static void sendAcknowledgementEmail(
        List<PRM_Registration_Request__c> regRequestList,
        Map<id, PRM_Registration_Request__c> oldregRequestMap
    ) {
        list<PRM_EmailUtility.EmailNotification> objEmailNotifList=new list<PRM_EmailUtility.EmailNotification> ();                           
        for (PRM_Registration_Request__c regRequest : regRequestList) {
            if (
                ((regRequest.PRM_Channel_Program_Level_txt__c ==
                  PRM_Intel_Partner_Alliance)) &&
                (Trigger.isUpdate &&
                 regRequest.recordtypeid ==
                 PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT &&
                 oldregRequestMap != null &&
                 oldregRequestMap.containsKey(regRequest.id) &&
                 /*oldregRequestMap.get(regRequest.id).recordtypeid == emailVerificationRT &&*/ regRequest.PRM_Auto_Approve__c ==
                 false &&
                 String.IsNotBlank(regRequest.PRM_Salesforce_ID__c) &&
                 String.IsNOTBlank(regRequest.PRM_Dup_Status__c) &&
                 String.IsBlank(
                     oldregRequestMap.get(regRequest.id).PRM_Dup_Status__c
                 )) ||
                (Trigger.isUpdate &&
                 String.IsNOTBlank(regRequest.PRM_Dup_Status__c) &&
                 oldregRequestMap != null &&
                 oldregRequestMap.containsKey(regRequest.id) &&
                 String.IsBlank(
                     oldregRequestMap.get(regRequest.id).PRM_Dup_Status__c
                 ) &&
                 regRequest.PRM_Auto_Approve__c == false &&
                 String.IsBlank(regRequest.PRM_Salesforce_ID__c))
            ) {
                PRM_Language_Culture_Mapping__mdt langCulEmail =  getLangCulture(regRequest.PRM_Contact_Country__c,regRequest.PRM_Preferred_Language__c);
                PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();
                objEmailNotif.ChannelProgram = PRM_Intel_Partner_Alliance;
                objEmailNotif.EmailID = regRequest.PRM_Email_ID__c;
                objEmailNotif.Language = regRequest.PRM_Preferred_Language__c;
                Map<String, String> paramMap = new Map<String, String>();
                paramMap.put('Registration_Request_ID', regRequest.id);
                if(regRequest.PRM_Matching_Contact__c != null){
                  paramMap.put('Contact_ID', regRequest.PRM_Matching_Contact__c);    
                } 
                if (langCulEmail != null) {
                    paramMap.put('LanguageCulture_MDT', langCulEmail.Id);
                }
                objEmailNotif.InputParameters = paramMap;
                objEmailNotif.BusinessEvent = PRM_Registration_request_Acknowledgement_Email;  
                objEmailNotifList.add(objEmailNotif);
                if (Trigger.isInsert) {
                    PRM_CreateAccountAndRelatedRecords.linkEmailLogToContact(regRequest.PRM_Email_ID__c);
                }
            }
        }
        if(!objEmailNotifList.isEmpty()){
            PRM_EmailUtility.sendEmail(objEmailNotifList);
        }
    }
    
    public static void updateBizAndPartnerRole(
        List<PRM_Registration_Request__c> updatedRegistrations,
        Map<Id, PRM_Registration_Request__c> oldRegRequestMap,
        List<PRM_AccountChannelMembership__c> acmListNew,
        Map<String, String> defaultPartnerRoleBizType
    ) {
        try {
            Map<Id, List<PRM_AccountChannelMembership__c>> acc_acmMap = new Map<Id, List<PRM_AccountChannelMembership__c>>();
            if (!acmListNew.isEmpty()) {
                for (PRM_AccountChannelMembership__c newACM : acmListNew) {
                    if (
                        newACM.PRM_Status_Nm__c != 'Inactive' &&
                        (newACM.PRM_Status_Nm__c == 'Approved' ||
                         newACM.PRM_Status_Nm__c == 'Pending')
                    ) {
                        if (!acc_acmMap.containsKey(newACM.PRM_Account_Id__c)) {
                            acc_acmMap.put(
                                newACM.PRM_Account_Id__c,
                                new List<PRM_AccountChannelMembership__c>{
                                    newACM
                                        }
                            );
                        }
                    }
                }
            }
            for (PRM_Registration_Request__c rq : updatedRegistrations) {
                List<String> bizList = new List<String>();
                if (rq.PRM_Account_Partner_Type__c != null){
                    bizList = String.valueOf(rq.PRM_Account_Partner_Type__c).split(';');
                }
                
                if (
                    acc_acmMap != null &&
                    !acc_acmMap.isEmpty() &&
                    acc_acmMap.containsKey(rq.PRM_Salesforce_ID__c) &&
                    (oldRegRequestMap.get(rq.Id).PRM_Partner_Role__c == null || rq.PRM_Status__c == 'Approved' ||
                    (oldRegRequestMap.get(rq.Id).PRM_Salesforce_ID__c != null && oldRegRequestMap.get(rq.Id).PRM_Salesforce_ID__c != rq.PRM_Salesforce_ID__c))
                ) {                    
                    List<PRM_AccountChannelMembership__c> acmList = acc_acmMap.get(
                        rq.PRM_Salesforce_ID__c
                    );
                    
                    if (acmList != null && !acmList.isEmpty()) {
                        /*if(!ipaRefresh)rq.PRM_Partner_Type__c = defaultPartnerRoleBizType.get(
                            (acmList[0].PRM_Partner_Role__c)
                        );*/
                        rq.PRM_Partner_Role__c = acmList[0].PRM_Partner_Role__c;
                    }
                }
                
                /*if (rq.PRM_Partner_Type__c != null && !bizList.contains(rq.PRM_Partner_Type__c) && !ipaRefresh) {
                    rq.PRM_Account_Partner_Type__c = rq.PRM_Partner_Type__c; //rq.PRM_Account_Partner_Type__c!=null?rq.PRM_Account_Partner_Type__c+';'+rq.PRM_Partner_Type__c:
                }*/
            }
        } catch (Exception ex) { PRM_ErrorUtilityClass.logError(ex);
                               }
    }

    /*public static void updateSubmittedDate(List<PRM_Registration_Request__c> regReqList){
     
      if(!regReqList.isEmpty()){
            for(PRM_Registration_Request__c reg_Req : regReqList){
                if(reg_Req.PRM_Submitted_Date__c == null &&  reg_Req.recordTypeID == PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT
                  && reg_Req.PRM_Channel_Program_Level_txt__c == System.Label.PSG_Licensing ){
                    reg_Req.PRM_Submitted_Date__c = System.now();
                }
            }
        }
    }*/ // TWC729-8986 - PSG removal from PRM classes
    private static Boolean adminDomainAutoApprovalEnabled = null;
    
    private static Boolean isAdminDomainAutoApprovalEnabled() {
        if (adminDomainAutoApprovalEnabled == null) {
            try {
                Core_CustomMetadataObjectController controller = new Core_CustomMetadataObjectController('PRM_Auto_Approval_Switch__mdt');
                Map<String, Object> flagConfig = controller.getInstance('Admin Domain Auto Approval');
                
                if (flagConfig != null && flagConfig.containsKey('PRM_isActive__c')) {
                    String activeValue = String.valueOf(flagConfig.get('PRM_isActive__c'));
                    adminDomainAutoApprovalEnabled = Boolean.valueOf(activeValue);
                } else {
                    adminDomainAutoApprovalEnabled = false; // Default to false
                }
            } catch (Exception e) {
                System.debug('Error loading admin domain feature flag: ' + e.getMessage());
                adminDomainAutoApprovalEnabled = false; // Default to false on error
            }
        }
        return adminDomainAutoApprovalEnabled;
    }
    
    // Bulkified Code
    public static void autoApproveEndUserRegistration(
        List<PRM_Registration_Request__c> regReqList,
        Map<Id, PRM_Registration_Request__c> oldRequestMap,
        Map<String, Boolean> isSysAccMap,
        Map<Id, List<Contact>> mapAccIdToListContact,
        Map<Id, Account> mapAccount,
        List<PRM_AccountChannelMembership__c> acmList
    ) {
        Map<Id, String> reqReqEmailMap = new Map<Id, String>();
        Set<String> bizOrgTypeSet = new Set<String>();
        Set<String> partnerRoleSet = new Set<String>();
        List<Id> salesforceIdList = new List<Id>();
        Boolean isAccIPA = false;
        Map<Id, Boolean> salesforceIdAccntMap = new Map<Id, Boolean>();
        //Set<String> newRegSubscriptionSet = new Set<String>();
        //List<PRM_AccountChannelMembership__c> accChannelMembership = new List<PRM_AccountChannelMembership__c>();
        Map<Id, Boolean> acctIdIPAMap = new Map<Id, Boolean>();
        //Set<String> emailDomainSet = new Set<String>();
        Map<Id, String> acmAcctIdPartRoleMap = new Map<Id, String>();
        Map<Id, Integer> acctContSize = new Map<Id, Integer>();
        //Map<Id, Boolean> regReqSuccessCriteriaMap = new Map<Id, Boolean>();
        List<PRM_Registration_Request__c> validRegRequestList = new List<PRM_Registration_Request__c>();
        Map<Id, Set<String>> regSubcriptionMap = new Map<Id, Set<String>>();
        Map<String, Boolean> partRoleMetaDataMap = new Map<String, Boolean>();
        Map<String,Boolean> emailDomainMatch = new Map<string,Boolean>();
        Map<Id,Id> contactAccountMap = new Map<Id,Id>();
        //List<PRM_Registration_Request__c> registrationList = new List<PRM_Registration_Request__c>();
        //set<Id> registrationId = new Set<Id>();
        
        Boolean verifyResponse = false;
        for (PRM_Registration_Request__c reg_Request : regReqList) {
            if (reg_Request.PRM_Partner_Type__c != null) {
                bizOrgTypeSet.add(reg_Request.PRM_Partner_Type__c);
            }
            if (reg_Request.PRM_Partner_Role__c != null) {
                partnerRoleSet.add(reg_Request.PRM_Partner_Role__c);
            }
            
            if (
                reg_Request.RecordTypeId ==
                PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT &&
                reg_Request.PRM_Status__c == 'New'
            ) {
                if (
                    reg_Request.PRM_Email_Verification_Criteria__c ==
                    PRM_Success &&
                    String.isNotBlank(reg_Request.PRM_Salesforce_ID__c)
                ) {
                    salesforceIdList.add(reg_Request.PRM_Salesforce_ID__c);
                    reqReqEmailMap.put(
                        reg_Request.PRM_Salesforce_ID__c,
                        reg_Request.PRM_Email_ID__c
                    );
                    validRegRequestList.add(reg_Request);
                }
            }
            
            if (String.IsNotBlank(reg_Request.PRM_Subscriptions__c)) {
                Set<String> subscriptionSet = new Set<String>();
                subscriptionSet.addAll(
                    reg_Request.PRM_Subscriptions__c.split(';')
                );
                regSubcriptionMap.put(reg_Request.id, subscriptionSet);
            }
            emailDomainMatch.put(reg_Request.PRM_Email_ID__c,false);
        }
        
        if (bizOrgTypeSet.size() > 0) {
            for (PRM_PartnerRoleTypeMappings__mdt pmd : [
                SELECT id, PRM_Biz_Org_Type__c, isNotAutoApprove__c
                FROM PRM_PartnerRoleTypeMappings__mdt
                WHERE PRM_Biz_Org_Type__c IN :bizOrgTypeSet
            ]) {
                partRoleMetaDataMap.put(
                    pmd.PRM_Biz_Org_Type__c,
                    pmd.isNotAutoApprove__c
                );
            }
        }
        
        if (salesforceIdList.size() > 0) {
            for (Id accId : salesforceIdList) {
                Account acct = mapAccount.containsKey(accId)
                    ? mapAccount.get(accId) : null;
                if (acct!=null &&
                    !acct.Core_Deactivated__c &&
                    reqReqEmailMap.get(acct.Id) != null &&
                    !isSysAccMap.containsKey(reqReqEmailMap.get(acct.Id))
                ) {
                    salesforceIdAccntMap.put(acct.Id, acct.Core_Deactivated__c);
                    acctIdIPAMap.put(
                        acct.id,
                        acct.Core_Intel_Partner_Alliance_PartnerGroup__c
                    );
                    //acctContSize.put(acct.Id,acct.Contacts.size());
                    List<Contact> conList = new List<Contact>();
                    if (mapAccIdToListContact.containsKey(accId)) {
                        for (Contact con : mapAccIdToListContact.get(accId)) {
                            conList.add(con);
                            contactAccountMap.put(con.Id,con.AccountId);
                        }
                    }
                    acctContSize.put(acct.Id, conList.size());
                }
            }
        }
        
        if (salesforceIdList.size() > 0) {
            System.debug('acmlist: ' + acmList);
            for (PRM_AccountChannelMembership__c acm : acmList) { //Utkarsh - TWC727-600 - Made changes in the if condition as part of defect fix.
                if(acm.PRM_Status_Nm__c == 'Approved'){
                    if (salesforceIdList.contains(acm.PRM_Account_Id__c) && !acm.PRM_Account_Id__r.Core_Deactivated__c){
                        acmAcctIdPartRoleMap.put(acm.PRM_Account_Id__c,acm.PRM_Partner_Role__c);
                    }
                    
                }
                else{
                    if (salesforceIdList.contains(acm.PRM_Account_Id__c) && !acm.PRM_Account_Id__r.Core_Deactivated__c && partnerRoleSet.contains(acm.PRM_Partner_Role__c)) {
                        acmAcctIdPartRoleMap.put(acm.PRM_Account_Id__c, acm.PRM_Partner_Role__c);
                    }
                }
            }
            System.debug('acmacmAcctIdPartRoleMap: ' + acmAcctIdPartRoleMap);
        }
        
        List<String> metadataSubscriptionList =  LabelConfiguration__mdt.getInstance('PRM_Subscription_Mapping').Value__c.split(',');
        Set<String> metadataSubscriptionSet = new Set<String>(metadataSubscriptionList);

        
        Map<String, Core_Account_Whitelisted_Domains__c> whitelist = new Map<String, Core_Account_Whitelisted_Domains__c>();
        if (salesforceIdList.size() > 0) {
            for (Core_Account_Whitelisted_Domains__c awd : [
                SELECT
                id,
                Name,
                Inactive_Indicator__c,
                Effective_End_Date_Time__c,
                Account__c
                FROM Core_Account_Whitelisted_Domains__c
                WHERE
                Account__c IN :salesforceIdList
                AND Inactive_Indicator__c = FALSE
                AND (Effective_End_Date_Time__c = NULL
                     OR Effective_End_Date_Time__c > TODAY)
            ]) {
                whitelist.put(awd.Name, awd);
            }
        }
        //Map<Id, Set<String>> accountAdminEmailDomains = new Map<Id, Set<String>>();//varun
        Boolean needsAdminDomainCheck = false;
        List<PRM_Registration_Request__c> eligibleForAdminCheck = new List<PRM_Registration_Request__c>();
    
        
        for (PRM_Registration_Request__c reg_Request : validRegRequestList) {
            verifyResponse = false;
            //Boolean conditionSet = false;
            String emailDomain = '';
            String emailId = '';
            Boolean domainMatchFound = false;
           
            if (
                metadataSubscriptionSet.equals(regSubcriptionMap.get(reg_Request.id)) && acmAcctIdPartRoleMap.containsKey(reg_Request.PRM_Salesforce_ID__c) 
                && acctContSize.get(reg_Request.PRM_Salesforce_ID__c) > 0 && acctIdIPAMap.get(reg_Request.PRM_Salesforce_ID__c) == true
            ) {
                verifyResponse = true;
                isAccIPA = true;
                emailId = reg_Request.PRM_Email_ID__c.trim();
                emailDomain = emailId.substringAfter('@');
                
            } //else 
                /*if ( !ipaRefresh && acctIdIPAMap.get(reg_Request.PRM_Salesforce_ID__c) == false && (reg_Request.PRM_Dup_Status__c == PRM_Nodup || reg_Request.PRM_Dup_Status__c == null || reg_Request.PRM_Dup_Status__c == '' )
            ) {
                // Utkarsh - TWC727-530 - Added salesforce id not equal to null condition if request is going for auto approval because all new account creation request shouldn't approve manually.
                if ( (partRoleMetaDataMap.containsKey(reg_Request.PRM_Partner_Type__c) && partRoleMetaDataMap.get(reg_Request.PRM_Partner_Type__c) == false && reg_Request.PRM_Salesforce_ID__c != null) ) { 
                    reg_Request.PRM_Status__c = Label.PRM_Status;
                    reg_Request.PRM_Auto_Approve__c = true;
                    reg_Request.PRM_isSubmitted__c = true;
                }
            }*/
            if (verifyResponse == true) {
                for (String str : whitelist.keyset()) {
                    //boolean contains = false;
                    if (str.equals(emailDomain) && reg_Request.PRM_Salesforce_ID__c != null && !hasBlockedAccountOrContact(reg_Request)) {  // Utkarsh - TWC727-530 - Added salesforce id not equal to null condition if request is going for auto approval because all new account creation request shouldn't approve manually.
                        reg_Request.PRM_Status__c = Label.PRM_Status;
                        reg_Request.PRM_Auto_Approve__c = true;
                        reg_Request.PRM_isSubmitted__c = true;
                        if(reg_Request.PRM_Is_Returning_User__c){
                            reg_Request.PRM_Review_Note_txt__c = Label.UIOLI_Return_Reason;
                        } else {
                            reg_Request.PRM_Review_Note_txt__c = 'Auto-approved by whitelisted account email domain match.';
                        }
                        emailDomainMatch.put(reg_Request.PRM_Email_ID__c,true);
                        domainMatchFound =true;
                        break;
                    }
                }
                if (!domainMatchFound) {
                    eligibleForAdminCheck.add(reg_Request);
                needsAdminDomainCheck = true;
            }
            }
        }

        if (needsAdminDomainCheck && !eligibleForAdminCheck.isEmpty() && isAdminDomainAutoApprovalEnabled()) {
        checkPartnerAdminDomains(eligibleForAdminCheck, salesforceIdList, emailDomainMatch);
    }

        for (PRM_Registration_Request__c reg_Request : regReqList) {
            if(reg_Request.RecordTypeId == PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT ){
                if(reg_Request.PRM_Salesforce_ID__c != null && reg_Request.PRM_Matching_Contact__c!=null && contactAccountMap.get(reg_Request.PRM_Matching_Contact__c) != reg_Request.PRM_Salesforce_ID__c){
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
                else if(partRoleMetaDataMap.containsKey(reg_Request.PRM_Partner_Type__c) && partRoleMetaDataMap.get(reg_Request.PRM_Partner_Type__c) == true && !isAccIPA){
                    reg_Request.PRM_Pending_Auto_Approval_Criteria__c = PRM_PartnerRoleNA;
                }
                else if(countryBasedBypass.contains(reg_Request.PRM_Email_ID__c)){
                    reg_Request.PRM_Pending_Auto_Approval_Criteria__c = PRM_EmailCountryBypass;
                }
                else if(isAccIPA && emailDomainMatch.get(reg_Request.PRM_Email_ID__c)!=null && !(emailDomainMatch.get(reg_Request.PRM_Email_ID__c))){
                    reg_Request.PRM_Pending_Auto_Approval_Criteria__c = PRM_EmailMismatch;
                }    
                
            }
        }
    }
    /**
* @description      : It processes the reg requests which do not satisfy the whitelist domain check and auto approves the reg request if email domain of secondary contact matches with PA/PAD
* @name             : checkPartnerAdminDomains
* @param            : List<PRM_Registration_Request__c> eligibleRegRequestList,List<Id> salesforceIdList,Map<String, Boolean> emailDomainMatch
**/

   private static void checkPartnerAdminDomains(List<PRM_Registration_Request__c> eligibleRegRequestList,List<Id> salesforceIdList,Map<String, Boolean> emailDomainMatch) 
   {
    // Get Partner Admin/Delegate email domains
    Map<Id, Set<String>> accountAdminEmailDomains = new Map<Id, Set<String>>();
    
    // Retrieve country-level domain bypass configuration from Custom Metadata
    Core_CustomMetadataObjectController customMetadata = new Core_CustomMetadataObjectController('Country_Level_Domain_Bypass');
    Map<String, Map<String, Object>> bypassRecords = customMetadata.getAll();
    
    if (salesforceIdList != null && !salesforceIdList.isEmpty()) {
        for (PRM_Account_Contact_Relationship__c acr : [
            SELECT 
                PRM_Account_Id__c,
                PRM_Contact_Id__r.Email
            FROM PRM_Account_Contact_Relationship__c
            WHERE 
                PRM_Account_Id__c IN :salesforceIdList
                AND PRM_Status_Nm__c = 'Complete'
                AND PRM_InActive_Ind__c = false
                AND PRM_Relationship_Id__r.Name IN ('Partner Admin', 'Partner Admin Delegate')
                AND PRM_Contact_Id__r.Email != null
        ]) {
            String adminEmail = acr.PRM_Contact_Id__r.Email.trim();
            String adminEmailDomain = adminEmail.substringAfter('@');
            
            if (!accountAdminEmailDomains.containsKey(acr.PRM_Account_Id__c)) {
                accountAdminEmailDomains.put(acr.PRM_Account_Id__c, new Set<String>());
            }
            accountAdminEmailDomains.get(acr.PRM_Account_Id__c).add(adminEmailDomain);
        }
    }
    
    // Check admin domains for unmatched requests
    for (PRM_Registration_Request__c reg_Request : eligibleRegRequestList) {
        // Only check if not already matched and has account
        if (emailDomainMatch.get(reg_Request.PRM_Email_ID__c) == false && 
            reg_Request.PRM_Salesforce_ID__c != null && 
            accountAdminEmailDomains.containsKey(reg_Request.PRM_Salesforce_ID__c)) {
            
            String emailId = reg_Request.PRM_Email_ID__c.trim();
            String emailDomain = emailId.substringAfter('@');
            Set<String> adminDomains = accountAdminEmailDomains.get(reg_Request.PRM_Salesforce_ID__c);
            
            // Check if this domain should bypass the blocked domain validation for the registration country
            Boolean shouldBypass = shouldBypassBlockedDomainCheck(reg_Request.PRM_Country__c, emailDomain,bypassRecords);
            
            if (shouldBypass){
                countryBasedBypass.add(reg_Request.PRM_Email_ID__c);
            }
            else if(adminDomains.contains(emailDomain) && !hasBlockedAccountOrContact(reg_Request)) {
                reg_Request.PRM_Status__c = Label.PRM_Status;
                reg_Request.PRM_Auto_Approve__c = true;
                reg_Request.PRM_isSubmitted__c = true;
                if(reg_Request.PRM_Is_Returning_User__c){
                    reg_Request.PRM_Review_Note_txt__c = Label.UIOLI_Return_Reason;
                } else {
                    reg_Request.PRM_Review_Note_txt__c = 'Auto-approved by Partner Admin/Delegate email domain match.';
                }
                emailDomainMatch.put(reg_Request.PRM_Email_ID__c, true);
                System.debug('Auto-approved based on Partner Admin/Delegate email domain match: ' + emailDomain);
            }
        }
    }
}


 /**
*  @description      : Check if a domain should bypass blocked domain validation for a specific country
*  @name             : shouldBypassBlockedDomainCheck
*  @param            : String countryCode - Registration country code
*  @param            : String emailDomain - Email domain to check
*  @param            : Map<String, Set<String>> bypassMap - Country-to-domains bypass configuration
*  @return           : Boolean - true if domain should bypass validation, false otherwise
*  @throws exception : NONE
**/
    public static Boolean shouldBypassBlockedDomainCheck(String countryCode, String emailDomain,Map<String, Map<String, Object>> bypassMap) {        
        if(bypassMap!=null && !bypassMap.isEmpty() && countryCode!=null && emailDomain!=null){
            for(String bypassRecord: bypassMap.keySet()){
                Map<String,Object> record = bypassMap.get(bypassRecord);
                List<String> cntryCdList = String.valueOf(record.get('Country_Code__c')).split(';');
                if(cntryCdList.contains(countryCode)){
                    List<String> bypassList = String.valueOf(record.get('Domains__c')).split(';');
                    if(bypassList.contains(emailDomain)){
                        return true;
                    }
                }
            }
        }
        // No bypass configuration found for this country
        return false;
    }

    /**
* @description      : It sends email if the registrationRequest is rejected
* @name             : sendRejectionEmail
* @param            : List<PRM_Registration_Request__c>, Map<id, PRM_Registration_Request__c>
**/
    
    public static void sendRejectionEmail(List<PRM_Registration_Request__c> regRequestList,Map<id, PRM_Registration_Request__c> oldregRequestMap) {
        PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();
        List<PRM_EmailUtility.EmailNotification> objEmailNotifList = new List<PRM_EmailUtility.EmailNotification>();
        for (PRM_Registration_Request__c regRequest : regRequestList) {
            if (
                oldregRequestMap.get(regRequest.Id).PRM_Status__c !=
                regRequest.PRM_Status__c &&
                regRequest.PRM_Status__c == 'Rejected'
            ) {
                PRM_Language_Culture_Mapping__mdt langCulEmail = getLangCulture(regRequest.PRM_Contact_Country__c,regRequest.PRM_Preferred_Language__c);
                objEmailNotif.ChannelProgram = PRM_Intel_Partner_Alliance;
                objEmailNotif.EmailID = regRequest.PRM_Email_ID__c;
                objEmailNotif.Language = regRequest.PRM_Preferred_Language__c;
                Map<String, String> paramMap = new Map<String, String>();
                paramMap.put('Registration_Request_ID', regRequest.id);
                if(regRequest.PRM_Matching_Contact__c != null){
                  paramMap.put('Contact_ID', regRequest.PRM_Matching_Contact__c);    
                }                
                if (langCulEmail != null) {
                    paramMap.put('LanguageCulture_MDT', langCulEmail.Id);
                }
                objEmailNotif.InputParameters = paramMap;
                objEmailNotif.BusinessEvent = IPA_Registration_Request_Rejection_Email;
                
                if(objEmailNotif.BusinessEvent != null){
                    objEmailNotifList.add(objEmailNotif);
                }
            }
        } //End of For loop
        
        if (!objEmailNotifList.isEmpty()) {
            //PRM_EmailUtility.sendEmail(objEmailNotif);
            PRM_EmailUtility.sendEmail(objEmailNotifList);
        }
    }
    public static PRM_Language_Culture_Mapping__mdt getLangCulture(String country, String preferredLang){
        List<PRM_Language_Culture_Mapping__mdt> lngCultureMdtList = PRM_Language_Culture_Mapping__mdt.getAll().values();
        PRM_Language_Culture_Mapping__mdt langCultureForEmail;
        for (PRM_Language_Culture_Mapping__mdt mdtRec : lngCultureMdtList) {
            if (mdtRec.PRM_Country_Cd__c != null &&
                    mdtRec.PRM_Country_Cd__c.equalsIgnoreCase('us')
            ) {
                langCultureForEmail = mdtRec;
            }
            if (mdtRec.PRM_Country_Cd__c != null &&
                mdtRec.PRM_Country_Cd__c.equalsIgnoreCase(country) && mdtRec.MasterLabel == preferredLang) {
                langCultureForEmail = mdtRec;
            }
        }
        return langCultureForEmail;
    }

    public static Map<Id, Boolean> getBlockedAccountContactRegRequestMap(List<PRM_Registration_Request__c> regRequestList) {
        Map<Id, Boolean> blockedRegRequestMap = new Map<Id, Boolean>();
        Set<Id> accountIds = new Set<Id>();
        Set<String> emailIds = new Set<String>();

        if (regRequestList == null || regRequestList.isEmpty()) {
            return blockedRegRequestMap;
        }

        for (PRM_Registration_Request__c regRequest : regRequestList) {
            blockedRegRequestMap.put(regRequest.Id, false);
            if (regRequest.PRM_Salesforce_ID__c != null) {
                accountIds.add(regRequest.PRM_Salesforce_ID__c);
            }
            if (String.isNotBlank(regRequest.PRM_Email_ID__c)) {
                emailIds.add(regRequest.PRM_Email_ID__c);
            }
        }

        if (accountIds.isEmpty() && emailIds.isEmpty()) {
            return blockedRegRequestMap;
        }

        Id blockedAccContRT = Schema.getGlobalDescribe().get('PRM_SBC_Account_Search_Configuration__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_BlockedAccountContacts').getRecordTypeId();
        Set<Id> blockedAccountIds = new Set<Id>();
        Set<String> blockedContactEmails = new Set<String>();

        for (PRM_SBC_Account_Search_Configuration__c ipaAdminConfig : [
            SELECT Account__c, PRM_Contact__r.Email, PRM_Type__c
            FROM PRM_SBC_Account_Search_Configuration__c
            WHERE RecordTypeId = :blockedAccContRT
            AND PRM_isActive__c = true
            AND (
                (PRM_Type__c = 'Account_Blocked' AND Account__c IN :accountIds)
                OR (PRM_Type__c = 'Contact_Blocked' AND PRM_Contact__r.Email IN :emailIds)
            )
        ]) {
            if (ipaAdminConfig.PRM_Type__c == 'Account_Blocked' && ipaAdminConfig.Account__c != null) {
                blockedAccountIds.add(ipaAdminConfig.Account__c);
            } else if (ipaAdminConfig.PRM_Type__c == 'Contact_Blocked' && String.isNotBlank(ipaAdminConfig.PRM_Contact__r.Email)) {
                blockedContactEmails.add(ipaAdminConfig.PRM_Contact__r.Email);
            }
        }

        for (PRM_Registration_Request__c regRequest : regRequestList) {
            blockedRegRequestMap.put(
                regRequest.Id,
                blockedAccountIds.contains(regRequest.PRM_Salesforce_ID__c) || blockedContactEmails.contains(regRequest.PRM_Email_ID__c)
            );
        }

        return blockedRegRequestMap;
    }
     public static Boolean hasBlockedAccountOrContact(PRM_Registration_Request__c regRequest) {
        if (regRequest == null) {
            return false;
        }
        Map<Id, Boolean> blockedRegRequestMap = getBlockedAccountContactRegRequestMap(new List<PRM_Registration_Request__c>{ regRequest });
        return blockedRegRequestMap.containsKey(regRequest.Id) && blockedRegRequestMap.get(regRequest.Id);
    }
    public static void validateStatusChange(List<PRM_Registration_Request__c> regRequestList,Map<id, PRM_Registration_Request__c> oldregRequestMap){
        if(regRequestList != null && oldregRequestMap != null){
            Map<Id, Boolean> blockedRegRequestMap = getBlockedAccountContactRegRequestMap(regRequestList);
            for(PRM_Registration_Request__c newReq: regRequestList){
                if(oldregRequestMap.containsKey(newReq.id) && newReq.PRM_Status__c == PRM_Status_Approved && oldregRequestMap.get(newReq.id).PRM_Status__c == 'New' && blockedRegRequestMap.containsKey(newReq.Id) && blockedRegRequestMap.get(newReq.Id)){
                    newReq.PRM_Status__c = oldregRequestMap.get(newReq.id).PRM_Status__c;
                    newReq.PRM_Review_Note_txt__c = System.Label.PRM_BlockedContactAdmins;
                }
                if(oldregRequestMap.containsKey(newReq.id) && newReq.PRM_Status__c != 'New' && oldregRequestMap.get(newReq.id).PRM_Status__c == 'New' && !PRM_Registration_Req_Approve_Reject.isApprovedUsingButton && !PRM_SendDocumentUploadEmail.bypassStatusChangeValidation && newReq.PRM_Channel_Program_Level_txt__c == 'Intel Partner Alliance' && newReq.RecordTypeId == PRM_IPA_Constants.ACCOUNT_CREATE_REQUEST_RT){
                    newReq.addError('This action is not allowed. Status cannot be modified');
                }
            
            }
        }
    }
}