/*********************************************************************************************************************
Apex Class Name  : PRM_RegistrationRequestUtility
Version       : 1.0
Created Date  : OCT 2018
Function      : Utility class containing business logic for Registration Requests

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Kushal Soni               10/05/2018              Utility class containing business logic for Registration Requests

*********************************************************************************************************************/

public without sharing class PRM_RegistrationRequestUtility{
    
    /**
* @description      : It applies record type on the basis of CIM, Salesforce Id & Account Channel Membership and checks Email Domain for 'Add Contact Request'
* @name             : applyRecordType
* @param            : List<PRM_Registration_Request__c>
* @throws exception : NONE
**/
    public static void applyRecordType(List<PRM_Registration_Request__c> regRequestList){
        Id accountCreateRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        Group QueueID = [Select ID from Group where Type =: System.Label.PRM_QueueGroup and DeveloperName =: System.Label.PRM_Manual_Approval_Members Limit 1];
        Set<Id> accIds = new Set<Id>();
        Set<String> emails = new Set<String>();
        Map<Id,PRM_AccountChannelMembership__c> channelMembershipMap = new Map<Id, PRM_AccountChannelMembership__c>();
        Map<String,Contact> emailMap = new Map<String,Contact>();
        
        for(PRM_Registration_Request__c request: regRequestList){
            accIds.add(request.PRM_Salesforce_ID__c);
            emails.add(request.PRM_Email_ID__c);
        }
        
        for(Contact con: [Select Id, Email from Contact where Email in: emails]){
            emailMap.put(con.Email,con);
        }
        
        //Map<Id,Account> accMap = new Map<Id,Account>([Select Id, Company_Domain__c from Account where Id in: accIds]);
        //for(PRM_AccountChannelMembership__c channelMember: [Select Id, PRM_Account_Id__c, PRM_Channel_Program_Id__r.Name,PRM_Partner_Role__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c in: accIds]){
          //  channelMembershipMap.put(channelMember.PRM_Account_Id__c, channelMember);
        //}
        system.debug('regRequest --> '+regRequestList);
        
        for(PRM_Registration_Request__c regRequest: regRequestList){
            
            //Harshit added:  to make relationship default
            if(regRequest.PRM_Partner_Relationship__c == null || String.isBlank(regRequest.PRM_Partner_Relationship__c))
            {
                system.debug('inside IF@@');
                regRequest.PRM_Partner_Relationship__c = System.Label.PRM_Primary_Contact+';'+System.Label.PRM_WorksFor ; 
            }
                                    
            if(String.isBlank(regRequest.PRM_Preferred_Language__c))
            {
                system.debug('inside IF@@');
                regRequest.PRM_Preferred_Language__c = System.Label.PRM_ENG ; 
            }
            
            //Start-US375453: Kushal added below to populate Matching Contact
            if(emailMap!= null && emailMap.containsKey(regRequest.PRM_Email_ID__c) && String.isBlank(regRequest.PRM_Matching_Contact__c)){
                regRequest.PRM_Matching_Contact__c = emailMap.get(regRequest.PRM_Email_ID__c).Id;
            }
            //End-US375453
            system.debug('RECORD TYPE ID : '+regRequest.RecordTypeId);
            
            //Harshit added on 30/7/2019 , as part of US406788 
            regRequest.OwnerId = QueueID.id; 
            
        } 
    }
    
    /**
* @description      : It checks for Email Verified Date Time and updates the Email Verification Criteria
* @name             : evStampCheck
* @param            : List<PRM_Registration_Request__c>
* @throws exception : NONE
**/
    public static void evStampCheck(List<PRM_Registration_Request__c> regReqList){
        for(PRM_Registration_Request__c regReq: regReqList){
            if(String.isNotBlank(String.valueOf(regReq.PRM_EmailVerifiedDateTime__c))){
                regReq.PRM_Email_Verification_Criteria__c = System.Label.PRM_Success;
            }
        }
    }
    
    /**
* @description      : It updates Email Verification Criteria on the basis of EV Flag
* @name             : evCheck
* @param            : List<PRM_Registration_Request__c>, Map<Id,PRM_Registration_Request__c>, List<PRM_Registration_Request__c>, Map<Id,PRM_Registration_Request__c>
* @throws exception : NONE
**/ 
    public static void evCheck(List<PRM_Registration_Request__c> regReqList, Map<Id,PRM_Registration_Request__c> oldRegReqMap){
        for(PRM_Registration_Request__c regReq: regReqList){
            if(oldRegReqMap.containsKey(regReq.Id) && (oldRegReqMap.get(regReq.Id).PRM_Email_Verification_Criteria__c == System.Label.PRM_Pending) && ((String.isBlank(String.valueOf(oldRegReqMap.get(regReq.Id).PRM_EmailVerifiedDateTime__c))) && String.isNotBlank(String.valueOf(regReq.PRM_EmailVerifiedDateTime__c)))){
                System.debug('@@ EV CHECK INVOKED ');
                regReq.PRM_Email_Verification_Criteria__c = System.Label.PRM_Success;
            }
        } 
    }
    
    /**
* @description      : It checks duplicate from the CIM system
* @name             : dupCheck
* @param            : List<PRM_Registration_Request__c>
* @throws exception : NONE
**/
    public static void dupCheck(List<PRM_Registration_Request__c> regReqList,Map<Id,PRM_Registration_Request__c> oldRegReqMap){
        Id accountCreateRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        PRM_Registration_Request__c regReq = regReqList[0];
        String oldRequestStatus = '';
        if(regReq.PRM_Dup_Status__c == null){
            regReq.PRM_Dup_Status__c = '';
        }
        if(oldRegReqMap != null){
            if(oldRegReqMap.containsKey(regReq.Id)){
                oldRequestStatus = oldRegReqMap.get(regReq.Id).PRM_Dup_Status__c;
            }
        }
        System.debug('oldRequestStatus'+oldRequestStatus);
        System.debug('regReq.PRM_Dup_Status__c'+regReq.PRM_Dup_Status__c);
        if(((regReq.recordTypeId == accountCreateRequestRT) && String.isNotBlank(regReq.PRM_Account_Name__c) && String.isNotBlank(regReq.PRM_Address_Line_1__c) && String.isNotBlank(regReq.PRM_Zip_Postal_Code__c) && String.isNotBlank(regReq.PRM_City__c) && ((String.isBlank(regReq.PRM_Dup_Status__c)) || ( (regReq.PRM_Dup_Status__c == 'NOT PROC') && String.isNotBlank(oldRequestStatus) && (oldRequestStatus == 'ERROR')))) ||
           ((regReq.recordTypeId == accountCreateRequestRT) && (String.isNotBlank(regReq.PRM_Salesforce_ID__c)) && ((String.isBlank(regReq.PRM_Dup_Status__c)) || ((regReq.PRM_Dup_Status__c == 'NOT PROC') && String.isNotBlank(oldRequestStatus) && (oldRequestStatus == 'ERROR'))))){
               //PRM_CIMCallout.dupCheck(regReq.PRM_Account_Name__c, regReq.PRM_Zip_Postal_Code__c, regReq.PRM_City__c, regReq.PRM_Address_Line_1__c, regReq.PRM_Country__c);
               //Harshit commented below line on 2/5/2019 :  as CIM system has not been integrated with sandbox currently, because of which it is throwing exception. 
               System.debug('Call CIMCALLOUT');
               Id queueId = System.enqueueJob(new PRM_CIMCallout(regReq,0,null,null,null));
               
                /*if (regReq.PRM_Partner_Type__c == 'FPGA Design Services'){
                    regReq.PRM_Dup_Status__c = System.Label.PRM_Nodup;
                    regReq.PRM_DeDup_Criteria__c = System.Label.PRM_Success;
                }
                else{
                    Id queueId = System.enqueueJob(new PRM_CIMCallout(regReq,0,null,null,null));
                }*/
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
    public static void sendEmailNotification(List<Sobject> insertedRecordList,string notificationFlag){
        // PRM_Reg_Req_Async_Handler class implements Queable and so here we need to enqueue the Job.
        system.debug('Coming to sendEmailNotification');
        /*if(notificationFlag == 'EmailNotificationOnAccountCreation'){
ID jobID = System.enqueueJob(new PRM_Reg_Req_Async_Handler(insertedRecordList));
system.debug('Job ID is  : '+jobID);
}*/
    }
    
    /**
* @description      : It trigger the email notification by invoking EmailFramework if registration 
* request received has EVToken populated
* @name             : sendEmailNotification
* @param            : List<Sobject> insertedRecordList - To get the triggered record,
* @throws exception : NONE
**/
    public static void emailNotificationOnReceivingRegistration(List<PRM_Registration_Request__c> insertedRecordList){
        //Id accountCreateRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        for(PRM_Registration_Request__c req : insertedRecordList)
        {
            System.debug('@@@ req'+req.PRM_Person_Phone_Number__c);
            // Email notification to be sent only for end user registration
            if(req.recordTypeId == emailVerificationRT)
            {
                PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();  
                objEmailNotif.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;
                //objEmailNotif.PartnerType=System.Label.PRM_CsP;
                //objEmailNotif.PartnerType=req.PRM_Partner_Role__c;
                PRM_Email_Content_DataSetup__c emailSetup = PRM_Email_Content_DataSetup__c.getValues(req.PRM_Partner_Role__c);  
                objEmailNotif.EmailID= req.PRM_Email_ID__c ;
                objEmailNotif.Language = req.PRM_Preferred_Language__c ;
                Map<String,String> paramMap = new Map<String,String>();
                paramMap.put('Registration_Request_ID',req.id);
                if(emailSetup != null){
                    paramMap.put('EmailContent_Setup',emailSetup.Id);    
                }
                objEmailNotif.InputParameters=paramMap;
                if(String.isBlank(String.valueOf(req.PRM_EmailVerifiedDateTime__c))){
                    //EV Date is blank --> new user --> send mail with EV token received
                    if(String.isNotBlank(String.valueOf(req.PRM_EV_Token__c))){
                        objEmailNotif.BusinessEvent=System.label.PRM_Registration_request_for_new_User_EV;   
                        PRM_EmailUtility.sendEmail(objEmailNotif);  
                        system.debug('mail sent for new User!!!');
                    }
                } /*else{
//EV Date is already set--> Existing User
//send mail if its an external User || existing salesforce User with Core_Do_Not_Contact__c as false
system.debug(req.PRM_Matching_Contact__c);
Contact c = new Contact();
if(req.PRM_Matching_Contact__c != null)
{
c = [Select id,Core_Do_Not_Contact__c from Contact where id =: req.PRM_Matching_Contact__c];
}
if(req.PRM_Matching_Contact__c == null || (req.PRM_Matching_Contact__c != null && c.Core_Do_Not_Contact__c  == false))
{
system.debug(c.Core_Do_Not_Contact__c);
objEmailNotif.BusinessEvent='Registration_request_for_existing_User';   
PRM_EmailUtility.sendEmail(objEmailNotif);
system.debug('mail sent for existing User!!!');

} 
} */ 
            } 
        } 
    }
    
    /**
* @description      : It updates Legal Agreement Criteria on the basis of channel program,legal agreement name and preferred language
* @name             : UpdateLA
* @param            : List<PRM_Registration_Request__c>
* @throws exception : NONE
**/ 
    
    public static void updateLA(List<PRM_Registration_Request__c> regRequest){
        
        PRM_Registration_Request__c newRequest = new PRM_Registration_Request__c();
        Set<String> paNameSet = new Set<String>();
        Set<String> laNameSet = new Set<String>();
        if(regRequest!= null && regRequest.size()>0){
            newRequest = regRequest[0];
        }
        System.debug('@@ newRequest'+newRequest);
        System.debug('@@ newRequest.PRM_Partner_Role__c'+newRequest.PRM_Partner_Role__c);
        
        if(newRequest.PRM_Partner_Role__c == null || String.isBlank(newRequest.PRM_Partner_Role__c)){
            if(newRequest.PRM_Partner_Type__c !=null && String.isNotBlank(newRequest.PRM_Partner_Type__c)){
                Map<String,String> roleTypeMap = new Map<String,String>();
                for(PRM_PartnerRoleTypeMappings__mdt roleTypeReq : [Select Id,PRM_Biz_Org_Type__c,PRM_Partner_Role__c   
                                                                    from PRM_PartnerRoleTypeMappings__mdt]){
                                                                        roleTypeMap.put(roleTypeReq.PRM_Biz_Org_Type__c, roleTypeReq.PRM_Partner_Role__c);
                                                                    }
                
                System.debug('roleTypeMap'+roleTypeMap);
                for(String orgType : newRequest.PRM_Partner_Type__c.split(';')){
                    if(roleTypeMap.containsKey(orgType)){
                        system.debug('orgType'+orgType);
                        newRequest.PRM_Partner_Role__c = roleTypeMap.get(orgType);
                    }
                }
            }
        }

        
        Set<String> allPASet = new Set<String>();
        Set<String> allPASetWithoutLanguage = new Set<String>();
        for(PRM_PartnerAgreement__c pa : [Select Id,Name,PRM_Channel_Program_Id__c,PRM_Language_Codes__c,PRM_Partner_Role__c,PRM_InActive_Ind__c,PRM_Agreement_Cd__c
                                          From PRM_PartnerAgreement__c where PRM_InActive_Ind__c = false AND PRM_Partner_Role__c =:newRequest.PRM_Partner_Role__c])
        {
            //Set Without language field
            if(String.isBlank(pa.PRM_Language_Codes__c)){
                allPASetWithoutLanguage.add(pa.PRM_Agreement_Cd__c+pa.PRM_Channel_Program_Id__c);
            }
            allPASet.add(pa.PRM_Agreement_Cd__c+pa.PRM_Language_Codes__c+pa.PRM_Channel_Program_Id__c);
        }
        System.debug('@@ allPASetWithoutLanguage'+allPASetWithoutLanguage);
        system.debug(allPASet.size());
        system.debug('@@ allPASet'+allPASet);
        if(allPASet.size() == 0){
            System.debug('@@ No Records in Partner Agreement');
            newRequest.PRM_Legal_Agreement_Criteria__c = Label.PRM_Fail;
        }
        //else starts
        else{
            for(PRM_Registration_Request__c rr : regRequest)
            {
                if(rr.recordTypeID != Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId())
                {
                    System.debug('rr'+rr);
                    boolean status = true ;
                    if(rr.PRM_Legal_Agreements__c != null && rr.PRM_Legal_Agreement_Criteria__c == Label.PRM_Pending){
                        for(String laName : rr.PRM_Legal_Agreements__c.split(';'))
                        {
                            system.debug(laName);
                            if(allPASetWithoutLanguage.size()>0){
                                if(!allPASetWithoutLanguage.contains(laName+rr.PRM_Channel_Program__c)){
                                    system.debug('@@ inside if');
                                    status= false;
                                    break;
                                }
                            }
                            else{
                                if(allPASet.size()>0){
                                    if(!allPASet.contains(laName+rr.PRM_Preferred_Language__c+rr.PRM_Channel_Program__c))
                                    {
                                        system.debug('@@ inside else');
                                        status= false;
                                        break;
                                    }
                                }
                            }
                        }
                        
                        if(status){
                            System.debug('@@ Success');
                            rr.PRM_Legal_Agreement_Criteria__c = Label.PRM_Success ;
                        }
                        else{
                            System.debug('@@ Fail');
                            rr.PRM_Legal_Agreement_Criteria__c = Label.PRM_Fail;
                        }
                    }
                }
            }
        }//else ends
    }
    
    //to store registration profile response
    //Rahul added as part of US407894
    public static void regResponse(List<PRM_Registration_Request__c> rr,Map<Id,PRM_Registration_Request__c> oldRegReqMap){
        System.debug(' rr '+rr);
        List<PRM_Registration_Request__c> regRequest = new List<PRM_Registration_Request__c>();
        Id accountCreateRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        String oldRT = '';
        
        for(PRM_Registration_Request__c newRequest : rr){
            if(trigger.isUpdate)
            {oldRT = oldRegReqMap.get(newRequest.Id).RecordTypeId;
             System.debug('oldRT'+oldRT);
             if(newRequest.RecordTypeId != oldRT && newRequest.RecordTypeId == accountCreateRequestRT){
                 regRequest.add(newRequest);
             }
            }
            else if(trigger.isInsert && newRequest.RecordTypeid == Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId())
            {
                regRequest.add(newRequest);
            }
        }
        if(regRequest != null && regRequest.size()>0){
            System.debug('call create Response');
            PRM_ProfileResponse.createResponse(regRequest,null,null,true);
        }
    }
    
    //Harshit added as part of US406788
    public static void setApprovalLink(List<PRM_Registration_Request__c> regReqList, Map<Id,PRM_Registration_Request__c> oldRegReqMap){
        System.debug(' regRequest '+regReqList);
        Map<String,PRM_Registration_Request__c> regReqToProcessMap = new Map<String,PRM_Registration_Request__c>();
        Map<String,String> processInstanceRegReqMap = new Map<String,String>();
        Map<String,String> regReqProcessInstanceWorkItemMap = new Map<String,String>();
        for(PRM_Registration_Request__c regReq : regReqList)
        {
            if(regReq.recordTypeId ==  Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId())
            {
                if(String.isBlank(regReq.PRM_ProcessInstanceWorkItem_Id__c)) {
                    regReqToProcessMap.put(regReq.id,regReq);
                    system.debug('@@@regReqToProcessMap:  '+regReqToProcessMap);
                }
            }     
        }
        if(regReqToProcessMap!= null && regReqToProcessMap.size()>0)
        {
            for(ProcessInstance pi : [Select id,TargetObjectId from ProcessInstance where TargetObjectId in : regReqToProcessMap.keySet()]){
                system.debug('@@@PI:: '+pi);
                processInstanceRegReqMap.put(pi.id,pi.TargetObjectId);
                system.debug('@@@processInstanceRegReqMap:: '+processInstanceRegReqMap);
            }
            List<ProcessInstanceWorkitem> pwiList = [Select id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId in : processInstanceRegReqMap.keySet()];
            system.debug('@@@pwiList :: '+pwiList);
            for(ProcessInstanceWorkitem pwi : pwiList){
                system.debug('@@@PWI:: '+pwi);
                regReqProcessInstanceWorkItemMap.put(processInstanceRegReqMap.get(pwi.processInstanceId),pwi.id);
                system.debug('@@@regReqProcessInstanceWorkItemMap:: '+regReqProcessInstanceWorkItemMap);
            }
            for(String regReqID : regReqProcessInstanceWorkItemMap.keySet()){
                PRM_Registration_Request__c regReqToUpdate = regReqToProcessMap.get(regReqID);
                String pid = regReqProcessInstanceWorkItemMap.get(regReqToUpdate.id) ;
                system.debug('@@@@@@@'+pid);
                //String approvalLink =  '<a href=\"/lightning/r/ProcessInstanceWorkitem/'+pid+'/view\">Approve-Reject</a>';
                //String link = '/lightning/r/ProcessInstanceWorkitem/'+pid+'/view';
                regReqToUpdate.PRM_ProcessInstanceWorkItem_Id__c = pid;
            } 
        }    
    }
    //Keerthan added as part of US422159,US422161
    public static void processAdminRegistrationRecords(List<PRM_Registration_Request__c> regReqList){
        system.debug('Process_Admin_Registration');
        List<PRM_Registration_Request__c> RequestsToProcess = new List<PRM_Registration_Request__c>();
        List<Id> accountIds = new List<Id>();
        List<String> contactEmailList = new List<String>();
        Map<Id,PRM_Registration_Request__c> accRegMap = new Map<Id,PRM_Registration_Request__c>();
        for(PRM_Registration_Request__c reg_Request : regReqList){
            system.debug('Reg Req record for admin Processing--> '+'reg_Request.PRM_Status__c:'+reg_Request.PRM_Status__c+',reg_Request.RecordTypeid:'+reg_Request.RecordTypeid+'reg_Request.PRM_Legal_Agreement_Criteria__c:'+reg_Request.PRM_Legal_Agreement_Criteria__c);
            //if((reg_Request.PRM_Status__c=='Approved') && reg_Request.RecordTypeid == Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId() && reg_Request.PRM_Legal_Agreement_Criteria__c==Label.PRM_Success)
            if((reg_Request.PRM_Status__c=='Approved') && reg_Request.RecordTypeid == Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId())
            {
                RequestsToProcess.add(reg_Request);
                accountIds.add(reg_Request.PRM_Salesforce_ID__c);
                accRegMap.put(reg_Request.PRM_Salesforce_ID__c,reg_Request);
                contactEmailList.add(reg_Request.PRM_Email_ID__c);
                system.debug('Request'+reg_Request);
            }   
            
        }
        if(RequestsToProcess.size() > 0){
            //PRM_RegistrationRequestUtility.regResponse(regReqList,null);
            PRM_CreateAccountAndRelatedRecordsAdmin.processRelatedRecordsAdmin(accountIds,AccRegMap,contactEmailList);
        }
    }
    
    //To check if Admin request landed in  SF needs to be approved or Rejected (Based on LA, ACM parner role ), PRM_Salesforce_ID__c != blank
    public static void approveAdminRegRecords(List<PRM_Registration_Request__c> regReqList){        
         PRM_Registration_Request__c reg_Request = regReqList[0];
         Account acct = new Account();
         List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
         List<Contact> conList = new List<Contact>();
         Boolean verifyResponse = false;
         String emailDomain = '';
       
        
         if(reg_Request!= null && reg_Request.RecordTypeid == Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId()
              && reg_Request.PRM_Salesforce_ID__c != null && String.isNotBlank(reg_Request.PRM_Salesforce_ID__c))
            {
                //acct = [Select Id,Name,(Select Id,Name from Contacts) from Account where Id=:reg_Request.PRM_Salesforce_ID__c];
                acmList =  [Select Id,PRM_Status_Nm__c,PRM_Account_Id__c,PRM_Channel_Program_Id__c,PRM_Partner_Role__c From PRM_AccountChannelMembership__c Where PRM_Account_Id__c =: reg_Request.PRM_Salesforce_ID__c And PRM_Partner_Role__c =: reg_Request.PRM_Partner_Role__c];
                conList = [Select Id,AccountId From Contact where Email =: reg_Request.PRM_Email_ID__c];
                
                //System.debug('@@ Contact Size '+acct.Contacts.size());
                
                //secondary contact admin auto approval
                /*if(acct.Contacts != null && acct.Contacts.size() > 1){
                    
                    System.debug(' <--- Secondary contact approval ---> ');
                    
                    if(acmList.size()>0 && conList.size()>0 && conList[0].AccountId != null && conList[0].AccountId == reg_Request.PRM_Salesforce_ID__c
                      && reg_Request.PRM_Email_Verification_Criteria__c == Label.PRM_Success && reg_Request.PRM_Subscriptions__c != null
                       && String.isNotBlank(reg_Request.PRM_Subscriptions__c)){
                           
                           for(PRM_Subscription_Mapping__mdt subscriptionMetadata : [Select DeveloperName,PRM_Subscription__c from PRM_Subscription_Mapping__mdt]){
                               if(reg_Request.PRM_Subscriptions__c.contains(subscriptionMetadata.PRM_Subscription__c)){
                                   verifyResponse = true;
                                   emailDomain = reg_Request.PRM_Email_ID__c.substringAfter('@');
                                   System.debug('@@ emailDomain '+emailDomain);
                                   break;
                               }
                           }
                       }
                    
                    System.debug('@@ verifyResponse'+verifyResponse);
                    if(verifyResponse){
                        for(PRM_Profile_Responses__c resp : [SELECT PRM_Account_Id__c, PRM_Profile_Answer_Id__c, Id, Name , PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c,PRM_Response_Txt__c
                                                             from PRM_Profile_Responses__c where PRM_Account_Id__c =: reg_Request.PRM_Salesforce_ID__c AND 
                                                             PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c = 'PRM_AcceptableDomainAns']){
                                                                 System.debug('@@ Response Exist');
                                                                 if(String.isNotBlank(resp.PRM_Response_Txt__c) && resp.PRM_Response_Txt__c.contains(emailDomain)){
                                                                     
                                                                     System.debug('@@ Auto Approve Admin Registration');
                                                                     reg_Request.PRM_Status__c = Label.PRM_Status;
                                                                 }
                                                             }
                    }
                }
                
                //primary contact admin auto approval
                else{*/
                //List<PRM_AccountChannelMembership__c> acmList =  [Select Id,PRM_Status_Nm__c,PRM_Account_Id__c,PRM_Channel_Program_Id__c,PRM_Partner_Role__c From PRM_AccountChannelMembership__c Where PRM_Account_Id__c =: reg_Request.PRM_Salesforce_ID__c And PRM_Channel_Program_Id__c =:reg_Request.PRM_Channel_Program__c And PRM_Partner_Role__c =: reg_Request.PRM_Partner_Role__c];
                //List<Contact> conList = [Select Id,AccountId From Contact where Email =: reg_Request.PRM_Email_ID__c];
                if(conList.size()>0){
                    System.debug(' <--- Primary contact approval ---> ');
                    //if((reg_Request.PRM_Salesforce_ID__c != null && (!String.isBlank(reg_Request.PRM_Salesforce_ID__c )))&&(reg_Request.PRM_Legal_Agreement_Criteria__c == Label.PRM_Success)&&(acmList.size()>0)&&(conList[0].AccountId == reg_Request.PRM_Salesforce_ID__c)&&(conList[0].AccountId != null)){
                    if((acmList.size()>0)&&(acmList[0].PRM_Channel_Program_Id__c == reg_Request.PRM_Channel_Program__c)&&(conList[0].AccountId != null) && (conList[0].AccountId == reg_Request.PRM_Salesforce_ID__c)){
                        reg_Request.PRM_Status__c='Approved';
                    }
                    else{
                        reg_Request.PRM_Status__c='Rejected';
                    }
                }
            }
    }
    
    public static void sendEmailOnReceivingAccountCreateRequest(List<PRM_Registration_Request__c> newRegReqList,Map<Id, PRM_Registration_Request__c> oldRegReqMap){
        System.debug('oldRegReqMap'+oldRegReqMap);
        System.debug('newRegReqList'+newRegReqList);
        Id accountCreateRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        String oldRT = '';
        for(PRM_Registration_Request__c newRequest : newRegReqList){
            oldRT = oldRegReqMap.get(newRequest.Id).RecordTypeId;
            System.debug('oldRT'+oldRT);
            if(newRequest.RecordTypeId != oldRT && newRequest.RecordTypeId ==accountCreateRequestRT){
                System.debug('Now do Changes');
            }
        }
    }
    
    public static void updateRelatedACROfAccount(Map<id,sObject> regObjects){     
        System.debug('regObjects: '+regObjects);
        if(regObjects != null){
            Map<String,String> mapOfEmailAcc = new Map<String,String>();
            Map<String,String> mapOfEmailPartnerRole = new Map<String,String>();
            for(sObject obj : regObjects.values()){
                PRM_Registration_Request__c regObj = (PRM_Registration_Request__c)obj;
                
                if(regObj.PRM_Status__c=='Approved' && !mapOfEmailAcc.containsKey(regObj.PRM_Email_ID__c)){
                    mapOfEmailAcc.put(regObj.PRM_Email_ID__c,regObj.PRM_Salesforce_ID__c);
                    mapOfEmailPartnerRole.put(regObj.PRM_Email_ID__c,regObj.PRM_Partner_Role__c);
                }
            }
            
            Map<String,String> mapOfContacts =new Map<String,String>();
            for(Contact conobj : [Select Id,AccountId,Email from Contact where Email in :mapOfEmailAcc.keySet()]){
                mapOfContacts.put(conobj.id,conobj.email);
            }
            System.debug('mapOfContacts >>>> '+mapOfContacts);
            setApproveToACRs(mapOfEmailPartnerRole,mapOfEmailAcc,mapOfContacts);
        }        
    } 
    
    
    private static void setApproveToACRs(Map<String,String> mapOfEmailPartnerRole, Map<String, String> mapOfEmailAcc,Map<String,String> mapOfContacts){
        Map<id,PRM_Account_Contact_Relationship__c> mapOfACR = new Map<id,PRM_Account_Contact_Relationship__c>([select id,PRM_Account_Id__c, PRM_Account_Id__r.name, PRM_Contact_Id__c, PRM_Partner_Role__c, PRM_Contact_Id__r.name, PRM_Contact_Id__r.email, PRM_Contact_Id__r.Core_Login_Id__c,PRM_Contact_Id__r.Core_Preferred_Language__c,PRM_Contact_Id__r.Core_Do_Not_Contact__c, PRM_Relationship_Id__r.name, PRM_InActive_Ind__c, IsDeleted,PRM_Status_Nm__c from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c in :mapOfContacts.keySet() and PRM_Status_Nm__c ='Pending Action']);
        System.debug('>>>>>> mapOfACR : '+mapOfACR);
        Map<id, sObject> mapOfUpdateACR = new Map<id, sObject>();
        if(mapOfACR != null){
            for(PRM_Account_Contact_Relationship__c acrObject : mapOfACR.values()){
                if(acrObject.PRM_Partner_Role__c.contains(mapOfEmailPartnerRole.get(acrObject.PRM_Contact_Id__r.email))
                   && acrObject.PRM_Account_Id__c == mapOfEmailAcc.get(acrObject.PRM_Contact_Id__r.email)){
                       acrObject.PRM_InActive_Ind__c = false;
                       acrObject.PRM_Status_Nm__c ='Complete';
                       acrObject.PRM_No_Email__c = true;                       
                       mapOfUpdateACR.put(acrObject.id,acrObject);
                   }
            }
 
            system.debug('Total queries executed after ACR creation Part1--->'+Limits.getQueries());
            update mapOfUpdateACR.values(); 
            system.debug('Total queries executed after ACR creation Part2--->'+Limits.getQueries()); 
        }

        System.debug('mapOfUpdateACR >>>> '+mapOfUpdateACR);
        if(!mapOfUpdateACR.isEmpty()){
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            system.debug('ProfileName :- '+profileName);
           // if(String.isNotEmpty(profileName) && profileName.toUpperCase() != System.Label.PRM_INTEGRATION_PROFILE.toUpperCase()){
                PRM_EmailToPrimaryContact.sendEmailToAllPrimaryContact(null, mapOfUpdateACR,mapOfEmailPartnerRole.values(),true, false);
          //  }
        }
    } 
   
    //added by Anish for US - US638327 Trigger an email for Primary contacts of the account to approve pending secondary contact addition requests
 /*   public static void sendMailtoPrimaryContactAfterSecondaryReq(List<PRM_Registration_Request__c> regReqList,Map<Id, PRM_Registration_Request__c> oldRegisterReqMap){   
        if(regReqList.size()>0){
            PRM_Registration_Request__c reg_Request = regReqList[0];
            String oldRecordID = '';
            oldRecordID = oldRegisterReqMap.get(regReqList[0].Id).RecordTypeId;
            System.debug('regReqList'+regReqList);
            Map<String, String> mapMailToContactID = new Map<String, String>();
            Map<String, String> mapContPreferedLang = new Map<String, String>();
            
            System.debug('reg_Request.PRM_Salesforce_ID__c'+reg_Request.PRM_Salesforce_ID__c);
            System.debug('reg_Request.PRM_Partner_Role__c'+reg_Request.PRM_Partner_Role__c);
            System.debug('reg_Request.RecordTypeid'+reg_Request.RecordTypeid);
            System.debug('reg_Request.old'+oldRecordID);
            System.debug('reg_Request.sys'+Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId());
            
            // for(PRM_Registration_Request__c reg_Request : regReqList){
            if((reg_Request.PRM_Salesforce_ID__c != null && (!String.isBlank(reg_Request.PRM_Salesforce_ID__c )) && reg_Request.PRM_Status__c != Label.PRM_Status_Rejected) &&
               (reg_Request.PRM_Partner_Role__c != null && reg_Request.PRM_Partner_Role__c != '') && ( reg_Request.RecordTypeid == Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId())  
               &&  (oldRecordID != reg_Request.RecordTypeid)){
                   List<PRM_Account_Contact_Relationship__c> containsPrimaryContactDetail = [select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Account_Id__r.name, PRM_Contact_Id__c,PRM_Contact_Id__r.name,PRM_Contact_Id__r.Core_IPA_Partner_Role__c, PRM_Contact_Id__r.email,PRM_Contact_Id__r.Core_Preferred_Language__c,PRM_Contact_Id__r.Core_Do_Not_Contact__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c = :reg_Request.PRM_Salesforce_ID__c  and PRM_Contact_Id__r.Core_IPA_Partner_Role__c = :reg_Request.PRM_Partner_Role__c and PRM_Relationship_Id__r.name = 'Primary Contact'];
                   System.debug('Size.q'+containsPrimaryContactDetail.size());
                   if(containsPrimaryContactDetail.size() > 0){
                       PRM_EmailUtility.EmailNotification objEmailtoSend= new PRM_EmailUtility.EmailNotification();        
                       
                       Map<String, String> mapPlaceholders = new Map<String, String>();
                       mapPlaceholders.put('FirstName',reg_Request.PRM_First_Name__c);
                       mapPlaceholders.put('Account',reg_Request.PRM_Account_Name__c);
                       mapPlaceholders.put('Login_ID',reg_Request.PRM_Contact_Login_ID__c);
                       mapPlaceholders.put('Email_ID',reg_Request.PRM_Email_ID__c);
                       // mapPlaceholders.get('Contact_Relationship')
                       
                       for(PRM_Account_Contact_Relationship__c acrMailsToBeSend : containsPrimaryContactDetail){
                           
                           if(!acrMailsToBeSend.PRM_Contact_Id__r.Core_Do_Not_Contact__c){
                               
                               objEmailtoSend.BusinessEvent = 'Contact_Addition';
                               mapMailToContactID.put(acrMailsToBeSend.PRM_Contact_Id__c,acrMailsToBeSend.PRM_Contact_Id__r.email);  
                               mapContPreferedLang.put(acrMailsToBeSend.PRM_Contact_Id__c,acrMailsToBeSend.PRM_Contact_Id__r.Core_Preferred_Language__c);
                               objEmailtoSend.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;
                               mapPlaceholders.put('Account_ID',acrMailsToBeSend.PRM_Account_Id__c);
                               
                               PRM_Email_Content_DataSetup__c emailSetup = PRM_Email_Content_DataSetup__c.getValues(acrMailsToBeSend.PRM_Partner_Role__c);
                               System.debug('emailSetup '+emailSetup);
                               if(emailSetup != null){
                                   mapPlaceholders.put('EmailContent_Setup',emailSetup.Id);    
                               }
                               objEmailtoSend.InputParameters = mapPlaceholders;
                               PRM_EmailUtility.customPlaceholdersMap = new Map<String,String> {'{!PRM_Registration_Request__c.PRM_First_Name__c}' =>mapPlaceholders.get('FirstName'), '{!Account.Name}' => mapPlaceholders.get('Account'), '{!ContactLoginId}' => mapPlaceholders.get('Login_ID'),'{!ContactEmail}'=> mapPlaceholders.get('Email_ID')}; 
                                   
                                   }
                           System.debug('time');
                       }
                       System.debug('time2');
                       if(String.isNotBlank(objEmailtoSend.BusinessEvent)){
                           System.debug('time3');
                           objEmailtoSend.mailToContactID = mapMailToContactID;
                           objEmailtoSend.contactPreferdLang = mapContPreferedLang;
                           PRM_EmailUtility.sendEmail(objEmailtoSend);
                       }
                   }
                   
               }
        }
    }  */
    
    //Rahul added for US664501
    // Reject status of records having values matching with an existing record
   /* public static void rejectDuplicates(List<PRM_Registration_Request__c> regReqList,Map<Id, PRM_Registration_Request__c> oldRequestMap){
        PRM_Registration_Request__c reg_Request = new PRM_Registration_Request__c();
        List<PRM_Registration_Request__c> duplicateRequest = new List<PRM_Registration_Request__c>();
        System.debug('@@ oldRequestMap'+oldRequestMap);
        
        if(regReqList.size()>0){
            reg_Request = regReqList[0];
            System.debug(' @@ Partner Type'+reg_Request.PRM_Partner_Type__c);
            Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
            Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
            
            System.debug('@@ oldRequestMap.get(reg_Request.Id)'+oldRequestMap.get(reg_Request.Id).RecordTypeId);
            if(reg_Request.RecordTypeId == accCreateRequestId && oldRequestMap != null && oldRequestMap.containsKey(reg_Request.Id) && 
               oldRequestMap.get(reg_Request.Id).RecordTypeId == emailVerificationRT){
                   
                if(reg_Request.PRM_Account_Name__c != null && reg_Request.PRM_Contact_Login_ID__c != null && reg_Request.PRM_Email_ID__c != null &&
                  reg_Request.PRM_Partner_Type__c != null && reg_Request.PRM_Status__c != null && String.isNotBlank(reg_Request.PRM_Account_Name__c)
                  && String.isNotBlank(reg_Request.PRM_Contact_Login_ID__c) && String.isNotBlank(reg_Request.PRM_Email_ID__c) && String.isNotBlank(reg_Request.PRM_Partner_Type__c)
                   && String.isNotBlank(reg_Request.PRM_Status__c)){
                       
                       duplicateRequest = [Select Id,Name,RecordTypeId,PRM_Account_Name__c,PRM_Contact_Login_ID__c,PRM_Email_ID__c,PRM_Partner_Type__c,PRM_Status__c
                                            from PRM_Registration_Request__c where PRM_Account_Name__c =: reg_Request.PRM_Account_Name__c AND 
                                            PRM_Contact_Login_ID__c =: reg_Request.PRM_Contact_Login_ID__c AND PRM_Email_ID__c =: reg_Request.PRM_Email_ID__c
                                           AND PRM_Partner_Type__c =: reg_Request.PRM_Partner_Type__c AND PRM_Status__c =: reg_Request.PRM_Status__c AND
                                           RecordTypeId =: accCreateRequestId];
                       System.debug('@@ Duplicate FOUND'+duplicateRequest);
                       System.debug('@@ duplicateRequest'+duplicateRequest.size());
                   }
                   
                   if(duplicateRequest.size()>0){
                       System.debug('@@ Update Record');
                       reg_Request.PRM_Status__c = Label.PRM_Status_Rejected;
                       reg_Request.PRM_Status_Reason__c = Label.PRM_Duplicate_Request;
                       reg_Request.PRM_isSubmitted__c = true;
            }

            }
            
        }
        
    }*/
    
    
   //Rahul added for US626612/US638396
   /* public static void autoApproveEndUserRegistration(List<PRM_Registration_Request__c> regReqList,Map<Id, PRM_Registration_Request__c> oldRequestMap){
        PRM_Registration_Request__c reg_Request = new PRM_Registration_Request__c();
        List<PRM_Registration_Request__c> duplicateRequest = new List<PRM_Registration_Request__c>();
        Account acct = new Account();
        //List<PRM_Subscription_Mapping__mdt> subscriptionMap = new List<PRM_Subscription_Mapping__mdt>();
        Boolean verifyResponse = false;
        String emailDomain = '';
        
        if(regReqList.size()>0){
            reg_Request = regReqList[0];
            System.debug(' @@ Partner Type'+reg_Request.PRM_Partner_Type__c);
            Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
            Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
            
            System.debug('@@ reg_Request.RecordTypeId'+reg_Request.RecordTypeId);
            System.debug('@@ oldRequestMap.get(reg_Request.Id).RecordTypeId'+oldRequestMap.get(reg_Request.Id).RecordTypeId);            
            if(reg_Request.PRM_Status__c == 'New' && reg_Request.RecordTypeId == accCreateRequestId && oldRequestMap != null && oldRequestMap.containsKey(reg_Request.Id) && 
               oldRequestMap.get(reg_Request.Id).RecordTypeId == emailVerificationRT){
                   
                   if(reg_Request.PRM_Email_Verification_Criteria__c == Label.PRM_Success && reg_Request.PRM_Subscriptions__c != null
                     && String.isNotBlank(reg_Request.PRM_Subscriptions__c) && reg_Request.PRM_Salesforce_ID__c != null && 
                     String.isNotBlank(reg_Request.PRM_Salesforce_ID__c)){
                       
                         acct = [Select Id,Name,(Select Id,Name from Contacts) from Account where Id=:reg_Request.PRM_Salesforce_ID__c];
                         System.debug('@@ Contact Size '+acct.Contacts.size());
                       //subscriptionMap = [Select DeveloperName,PRM_Subscription__c    from PRM_Subscription_Mapping__mdt];
                       for(PRM_Subscription_Mapping__mdt subscriptionMetadata : [Select DeveloperName,PRM_Subscription__c from PRM_Subscription_Mapping__mdt]){
                           if(reg_Request.PRM_Subscriptions__c.contains(subscriptionMetadata.PRM_Subscription__c) && acct.Contacts.size() > 0){
                               verifyResponse = true;
                               emailDomain = reg_Request.PRM_Email_ID__c.substringAfter('@');
                               System.debug('@@ emailDomain '+emailDomain);
                               break;
                           }
                       }
                   }
               }
            
            System.debug('@@ verifyResponse'+verifyResponse);
            if(verifyResponse){
                for(PRM_Profile_Responses__c resp : [SELECT PRM_Account_Id__c, PRM_Profile_Answer_Id__c, Id, Name , PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c,PRM_Response_Txt__c
                    from PRM_Profile_Responses__c where PRM_Account_Id__c =: reg_Request.PRM_Salesforce_ID__c AND 
                    PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c = 'PRM_AcceptableDomainAns']){
                        System.debug('@@ Response Exist');
                        if(String.isNotBlank(resp.PRM_Response_Txt__c) && resp.PRM_Response_Txt__c.contains(emailDomain)){
                            System.debug('@@ Auto Approve End User Registration');
                            reg_Request.PRM_Status__c = Label.PRM_Status;
                            reg_Request.PRM_isSubmitted__c = true; //for not meeting first criteria of process builder
                            //reg_Request.PRM_TriggerProcess__c = true; //for not meeting second criteria of process builder
                        }
                    }
            }
    }
    }*/
    
    //Rahul added for US626612/US638396
    //creating end user registration related records
    /*public static void createRelatedRecords(List<PRM_Registration_Request__c> regReqList,Map<Id, PRM_Registration_Request__c> oldRequestMap){
        
        System.debug(' Create Related Records ');
        System.debug(' @@ regReqList' + regReqList);
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        List<PRM_Registration_Request__c> regRequestList = new List<PRM_Registration_Request__c>();
        
        for(PRM_Registration_Request__c rr : regReqList){
            
            System.debug(' @@ oldRequestMap.get(rr.Id).RecordTypeId'+oldRequestMap.get(rr.Id).RecordTypeId);
            System.debug(' @@ rr.RecordTypeID'+rr.RecordTypeId);
            if(rr.PRM_Status__c == Label.PRM_Status && rr.RecordTypeId == accCreateRequestId && oldRequestMap != null && oldRequestMap.containsKey(rr.Id) && 
               oldRequestMap.get(rr.Id).RecordTypeId == emailVerificationRT){
                   //createRecords = true;
                   regRequestList.add(rr);
               }
        }
        
        System.debug('regRequestList'+regRequestList);
        if(regRequestList.size()>0){
            System.debug(' Call Create Related Record Class ');
            PRM_CreateAccountAndRelatedRecords.createAccountAndRelatedRecords(regRequestList);
        }
    }*/
    
    
    //Added by Bishal as part of US626882/US638376/US638377
    /*public static void autoApprovalOnPartnerRole(List<PRM_Registration_Request__c> regRequestListNew){
    system.debug('@@@@@@PartnerRoleRegRequest'+regRequestListNew);
    PRM_Registration_Request__c reg_Req = regRequestListNew[0];
    system.debug('@@ is submitted'+reg_req.PRM_isSubmitted__c);
    String bizorgtype ='';
    List<PRM_PartnerRoleTypeMappings__mdt> pmd = [select id,PRM_Biz_Org_Type__c,
                                          isNotAutoApprove__c from PRM_PartnerRoleTypeMappings__mdt where PRM_Biz_Org_Type__c =: reg_Req.PRM_Partner_Type__c ];
    system.debug('@@@'+pmd);
  //  for(PRM_PartnerRoleTypeMappings__mdt m : pmd){
   //  if(m.isNotAutoApprove__c == true)
    // {
     //   bizorgtype = m.PRM_Biz_Org_Type__c;
    // }
  // }
   // system.debug('$$'+bizorgtype);
    if(!pmd[0].isNotAutoApprove__c){
    if(reg_Req!= null && reg_Req.PRM_Status__c != Label.PRM_Status_Rejected && reg_Req.RecordTypeid == Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId() && reg_Req.PRM_Salesforce_ID__c == null && reg_Req.PRM_Legal_Agreement_Criteria__c == system.Label.PRM_Success && reg_Req.PRM_Dup_Status__c == system.Label.PRM_Nodup &&  reg_Req.PRM_Email_Verification_Criteria__c == system.Label.PRM_Success && reg_Req.PRM_Matching_Contact__c == null){
     system.debug('@@inside if');
     reg_req.PRM_Status__c='Approved';
     reg_req.PRM_isSubmitted__c = true;
    }
    }
    }*/  
}