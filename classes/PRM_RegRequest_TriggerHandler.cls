/*********************************************************************************************************************
Apex Class Name  : PRM_RegRequest_TriggerHandler
Version       : 1.0
Created Date  : OCT 2018
Function      : 

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Kushal Soni               10/05/2018                    
* Srishty Sharma            11/06/2020              US694818:It updates the approval comments on PRM_Registration_Request__c object
*********************************************************************************************************************/
public without sharing class PRM_RegRequest_TriggerHandler extends TriggerHandler{
    /**
*  @description      : calls 'applyRecordType','dupCheck' and 'evStampCheck' method of 'PRM_RegistrationRequestUtility'
*  @name             : beforeInsert
*  @param            : NONE
*  @throws exception : NONE
**/
    public static boolean IPAfirstRun = true;
    public static boolean ER_AckFirstRun = true;
    public static boolean ER_DupFirstRun = true;
    public static boolean isBeforeUpdateRun = false;
    public static boolean trackereRun = true;
    public static Set<string> registrationTypes = ER_RegistrationUtility.GetRegistrationTypes((List<PRM_Registration_Request__c>)Trigger.new);
    public static Map<String,Trigger_Execution__mdt> triggerExecution = Trigger_Execution__mdt.getAll();
    
    public static boolean IPArejectionemail = false;
    public static boolean IPAdupcheckRun = true;
    public static Final String ORIGIN  = 'PRM_RegRequest_TriggerHandler';
    public static Final String SEVERITY  = 'Error';
    public static Final String PROJECT  = 'IPA';
    public static final String SCOPE    = 'PRM_RegRequest_TriggerHandler';
    
    public override void beforeInsert(){ 
        
        for(string registrationType : registrationTypes) {
            if(registrationType != Label.RegistrationTypeProgram) {
                /*if(isActive('ER_SetEVAndLanguage')){
                    ER_RegistrationUtility.SetEVAndLanguage((List<PRM_Registration_Request__c>)Trigger.new);
                }
                if(isActive('ER_Reject_Duplicate_ResultsInsert')){
                    ER_DuplicationUtility.rejectDuplicates((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }
                if(isActive('ER_Legal_Agreement_CheckInsert')){
                    ER_LegalAgreementUtility.updateLA((List<PRM_Registration_Request__c>)Trigger.new);
                }
                if(isActive('ER_Dup_CheckInsert')){
                    ER_DuplicationUtility.DupCheck((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);                 
                }
                if(isActive('ER_Prfl_Resp_CheckInsert')) {
                    //Added by Gaurav - Eloqua Lead field update - Project size, Project Time Frame
                  ER_RegistrationProfileResponse.getProfileResponseValues((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                } */                 
                if(isActive('ER_SetAssignedTo')) {
                  //Added for Assigning Default value for Assigned to field on New Registration                
                  //Added By Quest
                  ER_RegistrationUtility.setAssignedTo((List<PRM_Registration_Request__c>)Trigger.new);
                }               
            }
            else {
                Map<String,Core_Intel_System_Accounts__mdt> mapSysAcc = Core_Intel_System_Accounts__mdt.getAll();
                Map<String,Boolean> isSysAccMap = new Map<String,Boolean>();
                Map<String,Contact> mapEmailToContact = new Map<String,Contact>();
                
                Set<Id> setExistingAcc = new Set<Id>();
                Map<Id, List<Contact>> mapAccIdToListContact = new Map<Id, List<Contact>>();
                Map<Id, Account> mapAccount= new Map<Id, Account>();
                Set<String> regEmail = new Set<String>();
                Set<Id> sysAccIdSet = new Set<Id>();
                List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
                
                for(String keySetString : mapSysAcc.keySet()){
                    sysAccIdSet.add(mapSysAcc.get(keySetString).AccountId__c);
                }
                
                for (PRM_Registration_Request__c regReq : (List<PRM_Registration_Request__c>)Trigger.new) {
                    if(!PRM_RegistrationRequestUtility.isautoApproveEndUserRegistrationFirstRun){
                        if(String.isNotBlank(regReq.PRM_Email_ID__c)){
                            regEmail.add(regReq.PRM_Email_ID__c);
                        }
                        if(regReq.PRM_Salesforce_ID__c != null && !sysAccIdSet.contains(regReq.PRM_Salesforce_ID__c)){
                            setExistingAcc.add(regReq.PRM_Salesforce_ID__c);
                        }
                    }
                }                                
                
                if( !regEmail.isEmpty()){
                    for(Contact con : [
                        SELECT 
                        AccountId,
                        Account.Core_IPA_Partner_Role__c,
                        Email 
                        FROM contact
                        WHERE Email in: regEmail
                        OR AccountId IN: setExistingAcc]
                       ){
                           if(sysAccIdSet.contains(con.AccountId) && regEmail.contains(con.email) ){
                               if(!isSysAccMap.containskey(con.Email)){
                                   isSysAccMap.put(con.Email, True);
                               }
                               setExistingAcc.add(con.AccountId);                               
                           }
                           mapEmailToContact.put(con.Email,con);
                           if(setExistingAcc.contains(con.AccountId)){
                               if(mapAccIdToListContact.containsKey(con.AccountId)){
                                   mapAccIdToListContact.get(con.AccountId).add(con);
                               }else {
                                   mapAccIdToListContact.put(con.AccountId, new List<Contact>{con});
                               }
                           }
                           
                       }
                }
                for(PRM_Registration_Request__c regReq : (List<PRM_Registration_Request__c>)Trigger.new){
                    if(String.isBlank(regReq.PRM_Matching_Contact__c) && mapEmailToContact.containsKey(regReq.PRM_Email_ID__c)){
                        regReq.PRM_Matching_Contact__c = mapEmailToContact.get(regReq.PRM_Email_ID__c)?.Id;
                    }
                }
                if(!setExistingAcc.isEmpty()){
                    mapAccount= new Map<Id, Account>([
                        SELECT 
                        Id,
                        Core_IPA_Partner_Role__c,
                        Name,
                        Core_Intel_Partner_Alliance_PartnerGroup__c,
                        Core_Deactivated__c
                        FROM Account 
                        WHERE id IN: setExistingAcc]);
                }
                
                if( !setExistingAcc.isEmpty()) {
                    for(PRM_AccountChannelMembership__c acm :[
                        SELECT 
                        id,
                        PRM_Status_Nm__c,
                        PRM_Partner_Role__c,
                        PRM_Account_Id__c,
                        PRM_Channel_Program_Level_Id__c,
                        PRM_Account_Id__r.Core_Deactivated__c
                        FROM PRM_AccountChannelMembership__c 
                        WHERE  PRM_Account_Id__c IN :setExistingAcc]
                       ){
                           acmList.add(acm);
                       }
                }
                
                if(isActive('Assign_Record_Type_to_Reg_Requests')){
                    PRM_RegistrationRequestUtility.applyRecordType((List<PRM_Registration_Request__c>)Trigger.new);
                }
                if(isActive('EV_Stamp_Check')){
                    PRM_RegistrationRequestUtility.evCheck((List<PRM_Registration_Request__c>)Trigger.new,null);
                }
                /*if(isActive('PSG_Approval_Check')){
                    PRM_PSG_RegistrationReqUtility.checkEVAndContactExistance((List<PRM_Registration_Request__c>)Trigger.new, null);         
                }*/ // commenting PSG related code
                //LA check needs to be implemented for admin reg req at time of insertion (for AccountCreateReq--> in before update)
                if(isActive('Legal_Agreement_Check')){
                    //String recordTypeId == Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId()
                    PRM_RegistrationRequestUtility.updateLA((List<PRM_Registration_Request__c>)Trigger.new);            
                }
                
                //US781670
                if(isActive('Reject_Duplicate_Results')){
                    PRM_RegistrationRequestUtility.rejectDuplicates((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }
                
                if(isActive('Admin_Reg_Approve')){
                    PRM_RegistrationRequestUtility.approveAdminRegRecords((List<PRM_Registration_Request__c>)Trigger.new);
                }
                //US637998 - capturing encrypted WeChatUnionId and Decrypt it before storing in DB
                if(isActive('Req_Request_WeChatId_Decryption')){
                    PRM_RegistrationRequestUtility.DecryptWeChatUnionId_BeforeInsert((List<PRM_Registration_Request__c>)Trigger.new);            
                }
                /*if(isActive('Update_Submitted_Date')){
                    PRM_RegistrationRequestUtility.updateSubmittedDate((List<PRM_Registration_Request__c>)Trigger.new);
                }*/
                if(isActive('Auto_Approve_User_Registration') && PRM_RegistrationRequestUtility.isautoApproveEndUserRegistrationFirstRun==false){            
                    PRM_RegistrationRequestUtility.isautoApproveEndUserRegistrationFirstRun=true;
                    PRM_RegistrationRequestUtility.autoApproveEndUserRegistration((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap, isSysAccMap, mapAccIdToListContact , mapAccount, acmList);
                }

                //IQR changes moved method call from before update to before insert as part of CidaaS - atb
                if(isActive('Pricing_RegRequest_Auto_Approve')){
                    Pricing_RegistrationReqUtility.autoApproveIQRRegReq((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }             
            }  
        }
    }
    public override void beforeUpdate(){
        
        
        for(string registrationType : registrationTypes) {
            
            if(registrationType != Label.RegistrationTypeProgram) {
                //Has been inactivated as part of TWC722-734 CiDaas : Team Quest - ATB
                //Added in Before Insert
                /*if(isActive('ER_Reject_Duplicate_Results')){
                     ER_DuplicationUtility.rejectDuplicates((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }*/
                //ER_EV_Check has been inactivated as part of TWC722-672 : Team Quest - Harshitha
                if(isActive('ER_EV_Check')){
                    ER_EmailVerificationUtility.UpdateEVCriteriaToSuccess((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }
                //Has been inactivated as part of TWC722-734 CiDaas : Team Quest - ATB
                //Added in Before Insert
                /*if(isActive('ER_Legal_Agreement_Check')){
                   ER_LegalAgreementUtility.updateLA((List<PRM_Registration_Request__c>)Trigger.new);
                } */            
                //Has been inactivated as part of TWC722-734 CiDaas : Team Quest - ATB
                //Added in Before Insert
                /*if(isActive('ER_Prfl_Resp_Check')) {
                  //Added by Gaurav - Eloqua Lead field update - Project size, Project Time Frame
                  ER_RegistrationProfileResponse.getProfileResponseValues((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }*/                                
            }
            else {
                //List<PRM_Registration_Request__c> listREgReqForIQR= new List<PRM_Registration_Request__c>();
                Set<id> accountIds = new Set<Id>();
                Map<String, String> defaultPartnerRoleBizType = new Map<String, String>();
                Map<Id, List<PRM_Account_Contact_Relationship__c>> mapAccountIdTOListACR =  new Map<Id, List<PRM_Account_Contact_Relationship__c>>();
                List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
                Set<Id> setExistingAcc = new Set<Id>();
                Set<Id> setMatchingContact = new Set<Id>();
                Map<Id, Contact> contMap = new Map<Id, Contact>();
                Map<String, Contact> emailTOContMap = new Map<String, Contact>();
                Map<String,PRM_PartnerRoleTypeMappings__mdt> mdRecrds = new Map<String,PRM_PartnerRoleTypeMappings__mdt>();
                Map<String,Core_Intel_System_Accounts__mdt> mapSysAcc = Core_Intel_System_Accounts__mdt.getAll();
                Set<Id> sysAccIdSet = new Set<Id>();
                Map<Id, Account> mapAccount= new Map<Id, Account>();
                Map<String,Boolean> isSysAccMap = new Map<String,Boolean>();
                Map<Id, List<Contact>> mapAccIdToListContact = new Map<Id, List<Contact>>();
                //Map<Id, List<PRM_AccountChannelMembership__c>> mapAccToListACM = new Map<Id, List<PRM_AccountChannelMembership__c>>();
                Set<String> regEmail = new Set<String>();
                Map<Id, list<string>>  mapOfAccIdPartnerRole=new map<Id,list<string>>();
                List<PRM_Registration_Request__c> updatedRegistrations = new List<PRM_Registration_Request__c>();
                Map<Id, PRM_Registration_Request__c> oldMap = (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap;
                list<PRM_AccountChannelMembership__c> acmNewList=new list<PRM_AccountChannelMembership__c>();
                
                if(isActive('Validate_IPA_Request_Status_Change')){
                    PRM_RegistrationRequestUtility.validateStatusChange((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }
                for(PRM_PartnerRoleTypeMappings__mdt Temp : [Select Id,PRM_Biz_Org_Type__c,PRM_Partner_Role__c from PRM_PartnerRoleTypeMappings__mdt where Grouping_Method__c != null]){
                    mdRecrds.put(Temp.PRM_Partner_Role__c,Temp);
                }           
                                                                        
                                                          for(String keySetString : mapSysAcc.keySet()){
                    sysAccIdSet.add(mapSysAcc.get(keySetString).AccountId__c);
                }
                                                          
                for (PRM_Registration_Request__c regReq : (List<PRM_Registration_Request__c>)Trigger.new) {
                    PRM_Registration_Request__c oldRegReq =  oldMap.get(regReq.Id);
                    
                    if((regReq.PRM_Status__c=='New' || regReq.PRM_Status__c=='Approved') && regReq.PRM_Channel_Program_Level_txt__c== Label.PRM_Intel_Partner_Alliance 
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
                    if(regReq.PRM_Salesforce_ID__c != null && !sysAccIdSet.contains(regReq.PRM_Salesforce_ID__c)){
                        setExistingAcc.add(regReq.PRM_Salesforce_ID__c);
                    }
                    if(String.isNotBlank(regReq.PRM_Email_ID__c)){
                        regEmail.add(regReq.PRM_Email_ID__c);
                    }
                }
                for(String keySetString : mapSysAcc.keySet()){
                    sysAccIdSet.add(mapSysAcc.get(keySetString).AccountId__c);
                }
                for(String mdt : mdRecrds.keySet()){               
                    defaultPartnerRoleBizType.put(mdRecrds.get(mdt).PRM_Partner_Role__c,mdRecrds.get(mdt).PRM_Biz_Org_Type__c);
                }
                if(!setMatchingContact.isEmpty() || !regEmail.isEmpty() || !setExistingAcc.isEmpty()){
                    for(Contact con : [
                        SELECT 
                        Id,
                        AccountId,
                        Account.Core_IPA_Partner_Role__c,
                        Email 
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
                                                                                                        setExistingAcc.add(con.AccountId);
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
                    mapAccount= new Map<Id, Account>([
                        SELECT 
                        Id,
                        Core_IPA_Partner_Role__c,
                        Name,
                        Core_Intel_Partner_Alliance_PartnerGroup__c,
                        Core_Deactivated__c
                        FROM Account 
                        WHERE id IN: setExistingAcc
                    ]);
                }
                
                if(!setExistingAcc.isEmpty()){
                    for(PRM_Account_Contact_Relationship__c acrRec : [
                        SELECT 
                        Id,
                        PRM_Account_Id__c,
                        PRM_InActive_Ind__c,
                        PRM_Partner_Role__c,
                        PRM_Status_Nm__c,
                        PRM_Relationship_Id__r.Name
                        FROM PRM_Account_Contact_Relationship__c
                        WHERE PRM_Account_Id__c IN: setExistingAcc]){
                            if(mapAccountIdTOListACR.containsKey(acrRec.PRM_Account_Id__c)){
                                mapAccountIdTOListACR.get(acrRec.PRM_Account_Id__c).add(acrRec);
                            }else{
                                mapAccountIdTOListACR.put(acrRec.PRM_Account_Id__c, new List<PRM_Account_Contact_Relationship__c>{acrRec});
                            }
                        }
                }
                
                
                if(!accountIds.isEmpty() || !setExistingAcc.isEmpty()) {
                    for(PRM_AccountChannelMembership__c acm :[
                        SELECT 
                        id,
                        PRM_Status_Nm__c,
                        PRM_Partner_Role__c,
                        PRM_Account_Id__c,
                        PRM_Channel_Program_Level_Id__c,
                        PRM_Channel_Program_Id__c,
                        PRM_Account_Id__r.Core_Deactivated__c
                        FROM PRM_AccountChannelMembership__c 
                        WHERE PRM_Channel_Program_Id__r.Name = 'Intel Partner Alliance' 
                        AND (PRM_Account_Id__c IN :accountIds
                        OR PRM_Account_Id__c IN :setExistingAcc)
                        ORDER BY CREATEDDATE ASC]
                       ){
                          // acmList.add(acm);
                           if(acm.PRM_Status_Nm__c=='Approved'){
                            acmNewList.add(acm);
                           if(mapOfAccIdPartnerRole.containsKey(acm.PRM_Account_Id__c)){
                            mapOfAccIdPartnerRole.get(acm.PRM_Account_Id__c).add(acm.PRM_Partner_Role__c);
                        }else {
                            mapOfAccIdPartnerRole.put(acm.PRM_Account_Id__c,new list<string>{acm.PRM_Partner_Role__c});
                        }
                    }
                  }
                }
                for(PRM_Registration_Request__c regReq : (List<PRM_Registration_Request__c>)Trigger.new){
                    if(String.isBlank(regReq.PRM_Matching_Contact__c) 
                       && emailTOContMap.containsKey(regReq.PRM_Email_ID__c) 
                       && (regReq.PRM_Status__c == 'New' 
                           || (regReq.PRM_Status__c == 'Approved' 
                               && oldMap.get(regReq.id).PRM_Status__c == 'New'))
                      ){
                        regReq.PRM_Matching_Contact__c = emailTOContMap.get(regReq.PRM_Email_ID__c)?.Id;
                    }
                }
                //Added by Naresh Yendluri for 
                if(!isBeforeUpdateRun && !acmNewList.isEmpty() && !updatedRegistrations.isEmpty()){
                    isBeforeUpdateRun= true;
                    PRM_RegistrationRequestUtility.updateBizAndPartnerRole(updatedRegistrations,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap, acmNewList, defaultPartnerRoleBizType);
                }
                //Rahul added for US664501
                if(isActive('Reject_Duplicate_Results')){
                    PRM_RegistrationRequestUtility.rejectDuplicates((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);           
                    
                    //PRM_RegistrationRequestUtility.updateAccountPartnerType((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }                
                
                if(isActive('EV_Check')){
                    PRM_RegistrationRequestUtility.evCheck((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                    
                }
                /*if(isActive('PSG_Approval_Check')){
                    PRM_PSG_RegistrationReqUtility.checkEVAndContactExistance((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }*/ //commenting PSG related code
                
                
                if(isActive('Legal_Agreement_Check')){
                    PRM_RegistrationRequestUtility.updateLA((List<PRM_Registration_Request__c>)Trigger.new);
                }
                 
                
                if(isActive('Partner_Relationship') && IPAfirstRun){
                 PRM_RegistrationRequestUtility.partnerrelationship((List<PRM_Registration_Request__c>)Trigger.new, mapAccountIdTOListACR, contMap, (Map<Id,PRM_Registration_Request__c>)Trigger.oldMap,mapOfAccIdPartnerRole);
                    IPAfirstRun = false;
                }   
                //Rahul added for US626612/US638396
                if(isActive('Auto_Approve_User_Registration') && PRM_RegistrationRequestUtility.isautoApproveEndUserRegistrationFirstRun==false){
                    PRM_RegistrationRequestUtility.isautoApproveEndUserRegistrationFirstRun =  true;
                    PRM_RegistrationRequestUtility.autoApproveEndUserRegistration((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap, isSysAccMap, mapAccIdToListContact, mapAccount, acmList);                    
                    
                }

                //Call Reltio API to get duplicate account details
                if(isActive('Dup_Check') && IPAdupcheckRun){
                    PRM_RegistrationRequestUtility.dupCheck((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                    IPAdupcheckRun = false;
                }  

                // Code for calling CIM on Duplicate Account status update
                if(isActive('Dup_Check')){                    
                    //Added by bishal as part of US626882/US638376/US638377
                    if(isActive('Auto_Approval')){
                        //commenting below method callout as new account scenario is not eligible for auto approval anymore
                        // PRM_RegistrationRequestUtility.autoApprovalOnPartnerRole((List<PRM_Registration_Request__c>)Trigger.new);
                    }
                    
                    
                    //Harshit added on 30/7/2019 , as part of US406788 
                    if(isActive('Populate_Approval_Link'))
                    {
                        PRM_RegistrationRequestUtility.setApprovalLink((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap); 
                    }
                    
                    if(isActive('Registration_Profile_Response')){
                        PRM_RegistrationRequestUtility.regResponse((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                    }
                    if(isActive('Admin_Reg_Approve')){
                        PRM_RegistrationRequestUtility.approveAdminRegRecords((List<PRM_Registration_Request__c>)Trigger.new);
                    }
                    
                    if(isActive('Req_Request_WeChatId_Decryption')){
                        PRM_RegistrationRequestUtility.DecryptWeChatUnionId_BeforeUpdate((Map<Id,PRM_Registration_Request__c>)Trigger.OldMap, (List<PRM_Registration_Request__c>)Trigger.new);
                    }
                }
            }           
        }
        
    }
    public override void afterInsert(){
        
        List<PRM_Registration_Request__c> regReqListForEnqueue = new List<PRM_Registration_Request__c>();    
        for(string registrationType : registrationTypes) {
            if(registrationType != Label.RegistrationTypeProgram) {
                //ER_EmailNotificationOnReceivingRegistrat has been inactivated as part of TWC722-672 : Team Quest - Harshitha
                if(isActive('ER_EmailNotificationOnReceivingRegistrat'))
                {
                    ER_EmailVerificationUtility.emailNotificationOnReceivingRegistration((List<PRM_Registration_Request__c>)Trigger.new);
                }
                if(isActive('ER_Ack_Email_Check_Update') && ER_AckFirstRun){
                    ER_AckFirstRun = false;
                    ER_AcknowledgementEmailUtility.sendAcknowledgementEmail((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }
                if(isActive('ER_Dup_CheckInsert')){
                    ER_DuplicationUtility.DupCheck((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);                 
                }
            }
            else {
                //Moved code from after update to after insert as part of CidaaS requirments - atb
                //ATHR Fix - TWC729-9556 - JB
                //Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
                Id accCreateRequestId = PRM_Registration_Request__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
                List<PRM_Registration_Request__c> listREgReqForIQR= new List<PRM_Registration_Request__c>();
                for (PRM_Registration_Request__c regReq : (List<PRM_Registration_Request__c>)Trigger.new) {
                    if(regReq.PRM_Channel_Program_Level_txt__c == 'Intel Quote Request'
                       && regReq.RecordTypeId == accCreateRequestId && regReq.PRM_Status__c == 'Approved' && !String.isEmpty(regReq.PRM_Salesforce_ID__c)
                      ){
                          listREgReqForIQR.add(regReq);
                      }
                }
                //Moved code from after update to after insert as part of CidaaS requirments - atb
                if(!listREgReqForIQR.isEmpty() && isActive('Pricing_RegRequest_Auto_Approve')){
                    Pricing_RegistrationReqUtility.createIQRContacts(listREgReqForIQR, null);
                }
                               
                if(isActive('EmailNotificationOnAccountCreation')){
                    List<Sobject> objectList = new List<Sobject>();
                    for (SObject registrationRequest : Trigger.new) {
                        objectList.add(registrationRequest);
                    }
                    //PRM_RegistrationRequestUtility.sendEmailNotification(objectList, 'EmailNotificationOnAccountCreation');
                }
                // Only for EV recordType 
                if(isActive('EmailNotificationOnReceivingRegistration'))
                {
                    PRM_RegistrationRequestUtility.EmailNotificationOnReceivingRegistration((List<PRM_Registration_Request__c>)Trigger.new);
                }
                if(isActive('Process_Admin_Registration')){
                    PRM_RegistrationRequestUtility.processAdminRegistrationRecords((List<PRM_Registration_Request__c>)Trigger.new, null);
                }
                
                if(isActive('Admin_Reg_Approve')){            
                    //System.enqueueJob(new PRM_AccountACRUpdateQueueable(Trigger.newMap));
                    PRM_RegistrationRequestUtility.updateRelatedACROfAccount(Trigger.newMap, null);
                }              
                
                if(isActive('sendAcknowledgementEmail')){
                    PRM_RegistrationRequestUtility.sendAcknowledgementEmail((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }
                
                if(trackereRun  && System.Label.PRM_Tracker_Enabled=='true'){   
                    system.debug('trackereRun508'+trackereRun);            
                    //System.enqueueJob(new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable ((List<PRM_Registration_Request__c>) Trigger.new,null,false,false));
                    regReqListForEnqueue.addAll((List<PRM_Registration_Request__c>) Trigger.new);
                    }
                // Agate - TWC729-2483 - Start
                if(isActive('Dup_Check')  && PRM_CimDupErrorUtility.isFirstRunCheck ){
                    PRM_CimDupErrorUtility.isFirstRunCheck = false ;
                    PRM_CimDupErrorUtility.dupCheck((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                } 
                // Agate - TWC729-2483 - End 
                
            }  
	
        }
        if(regReqListForEnqueue.size() >0 && !regReqListForEnqueue.isempty()){
            system.debug('regReqListForEnqueue'+regReqListForEnqueue);
            system.debug('trackereRun523'+trackereRun);
            System.enqueueJob(new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable (regReqListForEnqueue,null,false,false));
            trackereRun =false;
        }
        //Publishing an event to make a CDB callout for Company Validation
        if(triggerExecution.containsKey('PRM_NewRegCDBCallOut_Switch') && triggerExecution.get('PRM_NewRegCDBCallOut_Switch').Active__c/*isActive('PRM_NewRegCDBCallOut_Switch')*/){
            List<PRM_CDB_Platform_Event__e> events = new List<PRM_CDB_Platform_Event__e>();
            for (PRM_Registration_Request__c regReq : (List<PRM_Registration_Request__c>)Trigger.new) {
                system.debug('regReq.PRM_Status__c>>'+regReq.PRM_Status__c);
                if(regReq.PRM_Status__c=='New' && regReq.PRM_Salesforce_ID__c == null && regReq.PRM_Channel_Program_Level_txt__c=='Intel Partner Alliance'){
                    events.add(new PRM_CDB_Platform_Event__e(
                        Core_Record_Id__c = regReq.Id
                        
                    ));
                }
            }
           if (!events.isEmpty()) {
                Database.SaveResult[] results = EventBus.publish(events);
                System.debug('Published Events: ' + results.size());
                for (Database.SaveResult sr : results) {
                    if (!sr.isSuccess()){
                        String errorMessage = PRM_CDB_CompanyValidation_APICallout.stringifyErrors(sr.getErrors());
                        Core_Log_Entry.logEntryWithDetails(ORIGIN,PROJECT,SCOPE,SEVERITY,'',+errorMessage,'', 'PRM_RegRequest_TriggerHandler', '');
                        
                    }                   
                }     
            }
        }  
    }
    public override void afterUpdate(){
        List<PRM_Registration_Request__c> regReqListForEnqueue = new List<PRM_Registration_Request__c>();    
        for(string registrationType : registrationTypes) {
            if(registrationType != Label.RegistrationTypeProgram) {
                if(isActive('ER_Rejection_Email_Check')){
                    ER_RejectionEmailUtility.SendRejectionEmailNotifications((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }
                //Has been inactivated as part of TWC722-672 : Team Quest - Harshitha
                if(isActive('ER_Ack_Email_Check') && ER_AckFirstRun){
                    ER_AckFirstRun = false;
                    ER_AcknowledgementEmailUtility.sendAcknowledgementEmail((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }
                if(isActive('ER_Dup_Check') && ER_DupFirstRun){
                    ER_DupFirstRun = false;
                    ER_DuplicationUtility.DupCheck((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);                   
                }
            }
            else
            {   
                /*Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
                Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
                List<PRM_Registration_Request__c> listREgReqForIQR= new List<PRM_Registration_Request__c>();*/
                List<PRM_Registration_Request__c> listREgReqForTracker= new List<PRM_Registration_Request__c>();
                Map<Id, PRM_Registration_Request__c> oldMap = (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap;
                for (PRM_Registration_Request__c regReq : (List<PRM_Registration_Request__c>)Trigger.new) {
                    PRM_Registration_Request__c oldRegReq =  oldMap.get(regReq.Id);
                    //Moved below code to after insert as part of CidaaS requirments - atb
                    /*if(regReq.PRM_Channel_Program_Level_txt__c == 'Intel Quote Request' && oldRegReq.RecordTypeId != regReq.RecordTypeId 
                       && oldRegReq.RecordTypeId == emailVerificationRT
                       && regReq.RecordTypeId == accCreateRequestId && regReq.PRM_Status__c == 'Approved' && !String.isEmpty(regReq.PRM_Salesforce_ID__c)
                      ){
                          listREgReqForIQR.add(regReq);
                      }*/
                      
                      listREgReqForTracker.add(regReq);

                if(isActive('EmailNotificationOnAccountCreateRequest')){
                    // PRM_RegistrationRequestUtility.sendEmailOnReceivingAccountCreateRequest((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }
                if(isActive('Process_Admin_Registration')){
                    PRM_RegistrationRequestUtility.processAdminRegistrationRecords((List<PRM_Registration_Request__c>)Trigger.new,(Map<id,PRM_Registration_Request__c>)Trigger.oldMap);// newmap, oldmap
                }
                if(isActive('Admin_Reg_Approve')){            
                    //System.enqueueJob(new PRM_AccountACRUpdateQueueable(Trigger.newMap));
                    PRM_RegistrationRequestUtility.updateRelatedACROfAccount(Trigger.newMap, (Map<id,PRM_Registration_Request__c> )Trigger.oldMap);// newmap, oldmap
                }
                if(isActive('sendRejectionEmail') && IPArejectionemail == false){
                    PRM_RegistrationRequestUtility.sendRejectionEmail((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);                    
                    IPArejectionemail = true;
                }
                if(isActive('sendAcknowledgementEmail')){
                    
                    PRM_RegistrationRequestUtility.sendAcknowledgementEmail((List<PRM_Registration_Request__c>)Trigger.new, (Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                    
                }
                // Agate - TWC729-2483 - Start
                if(isActive('Dup_Check') && PRM_CimDupErrorUtility.isFirstRunCheck ){
                    PRM_CimDupErrorUtility.isFirstRunCheck = false ;
                    PRM_CimDupErrorUtility.dupCheck((List<PRM_Registration_Request__c>)Trigger.new,(Map<Id, PRM_Registration_Request__c>)Trigger.oldMap);
                }
                
                if(listREgReqForTracker.size()>0 && trackereRun && System.Label.PRM_Tracker_Enabled=='true'){
                    system.debug('trackereRun600'+trackereRun);
                    if(System.isBatch() || System.isQueueable() || System.isFuture()){
                       //PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable regTrackerUtility = new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable (listREgReqForTracker,null,false,false);
                       PRM_RegistrationTrackerUtility.executeMethod(listREgReqForTracker,null,false,false);
                    }else{
                        regReqListForEnqueue.addAll(listREgReqForTracker);
                        //System.enqueueJob(new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable (listREgReqForTracker,null,false,false));                
                    }
                }
            }
        }
    }
    if(regReqListForEnqueue.size() > 0 && !regReqListForEnqueue.isempty()){
        system.debug('regReqListForEnqueue'+regReqListForEnqueue);
        system.debug('trackereRun614'+trackereRun);
        System.enqueueJob(new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable (regReqListForEnqueue,null,false,false));
        trackereRun = false;
    }
}
}