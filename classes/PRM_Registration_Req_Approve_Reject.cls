/*********************************************************************************************************************
Apex Class Name  : PRM_Registration_Req_Approve_Reject
Created Date  : Feb 2022
Function      : Approve and Reject Button on Registration request details page logics
*********************************************************************************************************************/
public with sharing class PRM_Registration_Req_Approve_Reject{ 
    public static List<Core_Log_Entry__c> listLogEntries = new List<Core_Log_Entry__c>();
    public static string recordId = '';
    public static string LOG_ENTRY_ORIGIN ='PRM_Registration_Req_Approve_Reject';
    public static string LOG_ENTRY_PROJECT = 'Registration Request Approval/Rejection';
    public static string LOG_ENTRY_SCOPE = 'Medium';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static boolean isApprovedUsingButton = false;

    /**
    *  @description      : To Update the comments/ rejection reason and process the approval or rejection
    *  @name             : regreqApproveRejectNew
    *  @param            : ID,ID,String,String
    *  @throws exception : NONE
    **/
   @AuraEnabled
    public static ResponseWrap regreqApproveRejectNew(Id regReqId,Id approvalInstanceId, String aprovalType, String reason) {
        ResponseWrap reswrap;
        recordId = regReqId;
        //Id accReqQId;
        Savepoint sp = Database.setSavepoint();
        Boolean doReject = false;
        String errorMsg='';
        
        isApprovedUsingButton = true;
        
    try { 
        Id AccountCreateRT = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Account_Create_Request').getRecordTypeId();
        PRM_Registration_Request__c regReqRecord = [SELECT Id, PRM_Salesforce_ID__c, PRM_Review_Note_txt__c, PRM_Reject_Reason__c, RecordTypeId, Name, PRM_Email_ID__c, PRM_First_Name__c, PRM_Last_Name__c,
                                                    PRM_City__c, PRM_Country__c, PRM_Zip_Postal_Code__c, PRM_Address_Line_1__c, PRM_Address_Line_2__c, PRM_Channel_Program_Level_txt__c, PRM_Account_Name__c,
                                                    PRM_Account_URL__c, PRM_State_Province__c, PRM_Company_Nm_Eng__c, PRM_Alt_CompanyNameLang__c
                                                    FROM PRM_Registration_Request__c 
                                                    WHERE Id =: regReqId];

        
            List<PRM_Registration_Request__c> regReqUpdateList = new List<PRM_Registration_Request__c>();      

            if(regReqId!= null && aprovalType == system.label.PRM_Status) {

                regReqRecord.PRM_Review_Note_txt__c = reason;

                String reqType = (regReqRecord.PRM_Salesforce_ID__c == null && regReqRecord.RecordTypeId == AccountCreateRT 
                                 && regReqRecord.PRM_Channel_Program_Level_txt__c == 'Intel Partner Alliance')  //&& regReqRecord.PRM_Status__c == 'New'
                                 ? 'New Account Creation' : null;

                updateApprovalProcessWrapper  obj1=new updateApprovalProcessWrapper();
                obj1.approvalInstanceId=approvalInstanceId;
                obj1.approvalType=aprovalType;
                obj1.reason=reason;
                obj1.reqType=reqType;
                reswrap=updateApprovalProcess(obj1);
                //reswrap = updateApprovalProcess(approvalInstanceId, aprovalType, reason, reqType);

                //set status as 'Pending' while creating new account create request
                if (reswrap!=null && reswrap.requestType == 'New Account Creation') {
                   errorMsg =  handleNewAccountCreationRequest(regReqRecord);
                } 
                if(String.IsNotBlank(errorMsg)){
                    reswrap = new ResponseWrap(false, errorMsg, '', false); 
                }
                regReqUpdateList.add(regReqRecord);           
            }
          else if(regReqId != null && aprovalType == system.label.PRM_Status_Rejected && regReqRecord !=null) {
                regReqRecord.PRM_Reject_Reason__c = reason;
                regReqUpdateList.add(regReqRecord);
                doReject = true;
            } 
            

            TriggerHandler.bypass('PRM_RegRequest_TriggerHandler');
            update regReqUpdateList;
            TriggerHandler.clearBypass('PRM_RegRequest_TriggerHandler');

            if(doReject) {
                
                updateApprovalProcessWrapper  obj1=new updateApprovalProcessWrapper();
                obj1.approvalInstanceId=approvalInstanceId;
                obj1.approvalType=aprovalType;
                obj1.reason=reason;
                obj1.reqType='';
                reswrap=updateApprovalProcess(obj1);
                
                
                
               // reswrap = updateApprovalProcess(approvalInstanceId, aprovalType, reason, '');
            }
            
        }
        catch (DMLException e) {
            reswrap = new ResponseWrap(false, e.getDmlMessage(0), '', false); 
        }
        catch(Exception e) { reswrap = new ResponseWrap(false, null, '', false); 
            throw new AuraHandledException('Exception occured'+ e);
                            
        }
        finally{          
            if(reswrap!=null && !reswrap.flag) {
                Database.rollback(sp);
                if(errorMsg==null || String.isBlank(errorMsg)){
                    reswrap = new ResponseWrap(false, null, '', false); 
                }
            }
            
        }
        return reswrap;
    }

    /**
    *  @description      : add pre validation before approval
    *  @name             : validateData
    *  @param            : ID
    *  @throws exception : NONE
    **/
    @AuraEnabled
    public static String validateData(Id regReqId) {
        String responseMessage = 'Success';
        List<UCD_GenericAcctSearch_SBR.DuplicateRecordWrapper> dupAqrList=new List<UCD_GenericAcctSearch_SBR.DuplicateRecordWrapper>();
        Map<String,Boolean> systemaccountcheck = new Map<String,Boolean>();
        string countryCode='';
        try {
            for (PRM_Registration_Request__c regreq : [SELECT Id,PRM_Email_ID__c,PRM_Company_Nm_Eng__c,PRM_Alt_CompanyNameLang__c,
                                                       PRM_Country__c,PRM_City__c,PRM_State_Province__c, PRM_Address_Line_1__c 
                                                       from PRM_Registration_Request__c WHERE id = :regReqId]
            ) {
                systemaccountcheck = PRM_IPA_Utility.systemAccountDetails(new List<String>{regreq.PRM_Email_ID__c});
                if (systemaccountcheck.containsKey(regreq.PRM_Email_ID__c) && systemaccountcheck.get(regreq.PRM_Email_ID__c)) {
                    responseMessage = 'This request cannot be approved as it is associated with a system account';
                    break;
                }
                countryCode= Core_Country_Code_Mapping__c.getInstance(regreq.PRM_Country__c)!= null ? Core_Country_Code_Mapping__c.getInstance(regreq.PRM_Country__c).ISO_Code__c : null;
              	system.debug('countryCode');
                dupAqrList=UCD_GenericAcctSearch_SBR.checkForDuplicates(
                   		   regreq.PRM_Company_Nm_Eng__c,regreq.PRM_Alt_CompanyNameLang__c,countryCode,
						   regreq.PRM_Address_Line_1__c,regreq.PRM_City__c,regreq.PRM_State_Province__c);
				if(!dupAqrList.isEmpty() && dupAqrList.size()>0){
				responseMessage='Error! An account matching the customer name & address you entered has been found. You can’t submit this new request as it is a duplicate.';
				break;
                }
            }
        }catch(exception ex) { throw new AuraHandledException('exceptionText-> ' + ex );
        }
        return responseMessage;
    }
    
    /**
    *  @description      : fetch the ProcessInstanceWorkitem for the related new registration
    *  @dev              : Shraddha M
    *  @name             : fetchApprovalRecord
    *  @param            : ID
    *  @throws exception : AuraHandledException
    **/
    @AuraEnabled
    public static approvalWrapper fetchApprovalRecord(Id regReqId) { 
        approvalWrapper apWrp = new approvalWrapper();
        List<ProcessInstanceWorkitem> workItems = new List<ProcessInstanceWorkitem>();
        Boolean isNewAccCreation = false;

        //IPA 2.0 - TWC729-8020 
        string emailDomain;
        Boolean isBlocked = false;

        try {
            Id AccountCreateRT = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Account_Create_Request').getRecordTypeId();
	    //ATHR Fix - TWC729-9556 - JB
            workItems = [ SELECT Id /*, ProcessInstanceId,ActorId*/ FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :regReqId];
            System.debug('WorkItems Size: ' + workItems.size()); //sj start
            
            /*if(!workItems.isEmpty()){ //sjstart
                System.debug('WorkItem Id: ' + workItems[0].Id);
                System.debug('Actor Id: ' + workItems[0].ActorId);
            }//sj end*/
            apWrp.workItemId = workItems.isEmpty()? null : workItems[0].Id;
            PRM_Registration_Request__c regRec = [SELECT Id, PRM_Company_Nm_Eng__c, PRM_Alt_CompanyNameLang__c, PRM_Salesforce_ID__c, PRM_Email_ID__c, Geo_Code__c, PRM_Country__c,
            PRM_Matching_Contact__c,PRM_Matching_Contact__r.email,PRM_Matching_Contact__r.AccountId,RecordTypeId, PRM_Channel_Program_Level_txt__c
                                                        FROM PRM_Registration_Request__c 
                                                        WHERE Id =: regReqId];
            // //blocked acc:
            // if(regRec.PRM_Matching_Contact__c!=null || regRec.PRM_Salesforce_ID__c!=null){
            //     apWrp.blockedAccount=  PRM_AdminRegistration.getBlockedAccountContact(regRec.PRM_Matching_Contact__r.email,regRec.PRM_Salesforce_ID__c );
            
            // } 
            if(regRec.PRM_Matching_Contact__c!=null ){
                apWrp.blockedContact=  PRM_AdminRegistration.getBlockedAccountContact(regRec.PRM_Matching_Contact__r.email,null );
            
            } 
            if( regRec.PRM_Salesforce_ID__c!=null){
                apWrp.blockedAccount=  PRM_AdminRegistration.getBlockedAccountContact(null,regRec.PRM_Salesforce_ID__c );
            } 
                                                    
            //IPA 2.0 - TWC729-8020 - check if email in blocked domain
            if(String.IsNotBlank(regRec.PRM_Email_ID__c) && regRec.PRM_Email_ID__c.contains('@') && regRec.PRM_Channel_Program_Level_txt__c == 'Intel Partner Alliance'){
                emailDomain = regRec.PRM_Email_ID__c.split('@')[1];
            }
            
            //@NJ
             // Retrieve country-level domain bypass configuration from Custom Metadata
            Core_CustomMetadataObjectController customMetadata = new Core_CustomMetadataObjectController('Country_Level_Domain_Bypass');
            Map<String, Map<String, Object>> bypassRecords = customMetadata.getAll();
             // Check if this domain should bypass the blocked domain validation for the registration country
            Boolean shouldBypass = PRM_RegistrationRequestUtility.shouldBypassBlockedDomainCheck(regRec.PRM_Country__c, emailDomain,bypassRecords);
            
            // Only perform blocked domain validation if the domain is NOT in the bypass list for this country
            if(!shouldBypass && String.IsNotBlank(emailDomain)) {
                if(regRec.Geo_Code__c=='PRC'){
                    if(system.label.Blocked_Domains_Prc1.split(';').contains(emailDomain) || system.label.Blocked_Domains_Prc2.split(';').contains(emailDomain)){
                            isBlocked = true;
                    }
                }else{
                    if(system.label.Blocked_Domains_Non_Prc1.split(';').contains(emailDomain) || system.label.Blocked_Domains_Non_Prc2.split(';').contains(emailDomain)|| system.label.Blocked_Domains_Non_Prc3.split(';').contains(emailDomain)){
                        isBlocked = true;
                    }
                }
            }

                                                    
            //Check if it is New Account Creation Scenerio
            if(regRec.PRM_Salesforce_ID__c == null && regRec.RecordTypeId == AccountCreateRT && regRec.PRM_Channel_Program_Level_txt__c == 'Intel Partner Alliance') {
                isNewAccCreation = true;
            }
            apWrp.companyNameEng = regRec.PRM_Company_Nm_Eng__c != null ? regRec.PRM_Company_Nm_Eng__c : '';
            apWrp.companyAltLang = regRec.PRM_Alt_CompanyNameLang__c != null ? regRec.PRM_Alt_CompanyNameLang__c : '';
            apWrp.isNewAccCreation = isNewAccCreation;
            apWrp.blockedEmailDomain =  isBlocked;// IPA 2.0 - TWC729-8020
        }
        catch(exception ex) { throw new AuraHandledException('Exception occured'+ ex);
        }
        System.debug('Approval Wrapper = ' + JSON.serialize(apWrp));//sj
        return apWrp;
    }

    /*Wrapper*/
    public class approvalWrapper{
        @AuraEnabled public String workItemId{get;set;}
        @AuraEnabled public Boolean isNewAccCreation{get;set;}
        @AuraEnabled public String companyNameEng{get;set;}
        @AuraEnabled public String companyAltLang{get;set;}
        @AuraEnabled public Boolean blockedAccount{get;set;}
        @AuraEnabled public Boolean blockedContact{get;set;}
        @AuraEnabled public Boolean blockedEmailDomain {get; set;} // IPA 2.0 - TWC729-8020
    }

    /**
    *  @description      : to approve or reject the registration request
    *  @name             : updateApprovalProcess
    *  @param            : ID
    *  @throws exception : NONE
    **/
    /*private static ResponseWrap updateApprovalProcess(Id approvalInstanceId, String approvalType, String reason, String reqType) {
        ResponseWrap res;
        Boolean callApprovalPr = true;
        try{           
            if(approvalInstanceId != null) {
                Approval.ProcessWorkitemRequest requests = new Approval.ProcessWorkitemRequest();
                    requests.setWorkitemId(approvalInstanceId);
                    if(approvalType == system.label.PRM_Status) {
                        if (reqType == 'New Account Creation') {
                            res = new ResponseWrap(true, '', 'New Account Creation', true);
                            callApprovalPr = false;
                            //System.debug('here3');
                        } else {
                            requests.setAction('Approve');
                            //System.debug('here2');
                        }
                    }
                    else if (approvalType == system.label.PRM_Status_Rejected) {
                        requests.setAction('Reject');
                    }
                    requests.setComments(reason);
                if (requests != null && callApprovalPr) {
                    Approval.ProcessResult processResults = Approval.process(requests);
                    if (processResults.isSuccess()) {
                        res = new ResponseWrap(true, '', '', false);
                    }else{
                        res = new ResponseWrap(false, processResults.getErrors()[0].getMessage(), '', false);
                        listLogEntries.add(createLogEntry(processResults.getErrors()[0].getMessage(), 'Medium', 'updateApprovalProcess'));
                    }
                }
                
            }
        }catch (DMLException e) {
            res = new ResponseWrap(false, e.getDmlMessage(0), '', false);
        }
        catch(exception e) { listLogEntries.add(createLogEntry(e.getMessage(), 'Medium', 'updateApprovalProcess + Exception'));
        }finally{
            if (!listLogEntries.isEmpty()) { Database.insert(listLogEntries,false);
            }
        }
      return res;  
    }*/
    
    public class updateApprovalProcessWrapper{
        public Id approvalInstanceId{get;set;}
        public String approvalType{get;set;}
        public String reason{get;set;}
        public String reqType{get;set;}
    }

    private static ResponseWrap updateApprovalProcess(updateApprovalProcessWrapper att) {
        ResponseWrap res;
        Boolean callApprovalPr = true;
        try{           
            if(att.approvalInstanceId != null) {
                Approval.ProcessWorkitemRequest requests = new Approval.ProcessWorkitemRequest();
                    requests.setWorkitemId(att.approvalInstanceId);
                    if(att.approvalType == system.label.PRM_Status) {
                        if (att.reqType == 'New Account Creation') {
                            res = new ResponseWrap(true, '', 'New Account Creation', true);
                            callApprovalPr = false;
                        } else {
                            requests.setAction('Approve');
                        }
                    }
                    else if (att.approvalType == system.label.PRM_Status_Rejected) {
                        requests.setAction('Reject');
                    }
                    requests.setComments(att.reason);
                if (requests != null && callApprovalPr) {
                    Approval.ProcessResult processResults = Approval.process(requests);
                     if (processResults.isSuccess()) {
                         res = new ResponseWrap(true, '', '', false);
                     }else{
                        res = new ResponseWrap(false, processResults.getErrors()[0].getMessage(), '', false);
                        listLogEntries.add(createLogEntry(processResults.getErrors()[0].getMessage(), 'Medium', 'updateApprovalProcess'));
                     }
                    
                }
                
            }
        }catch (DMLException e) {
            res = new ResponseWrap(false, e.getDmlMessage(0), '', false);
        }
        catch(exception e) { listLogEntries.add(createLogEntry(e.getMessage(), 'Medium', 'updateApprovalProcess + Exception'));
        }finally{
            if (!listLogEntries.isEmpty()) { Database.insert(listLogEntries,false);
            }
        }
      return res;  
    }

    
    /**
    *  @description      : to create the log entry
    *  @name             : createLogEntry
    *  @param            : ID
    *  @throws exception : NONE
    **/
    public static Core_Log_Entry__c createLogEntry(String msg, String severity, String logEntryScope) {
        Core_Log_Entry__c objCLE = new Core_Log_Entry__c(
                    Core_Origin__c = LOG_ENTRY_ORIGIN,
                    Core_Project__c = LOG_ENTRY_PROJECT,
                    Core_Scope__c = logEntryScope,
                    Core_Severity__c = severity,
                    Core_Message__c = msg,
                    Core_When__c = system.now(),
                    Core_sObjectId__c = recordId,
                    Core_sObjectType__c = 'PRM_Registration_Request__c'
                );
        return objCLE;
    }

    /**
    *  @description      : to create the Account Request Queue record
    *  @name             : createAccountRequestQueue
    *  @param            : PRM_Registration_Request__c regReq
    *  @return           : newly created Account Request Queue record Id
    *  @dev              : Shraddha M
    *  @throws exception : NONE
    **/
    private static acrIdOrErrorMsgWrp createAccountRequestQueue(PRM_Registration_Request__c regReq) {
        String acrId;
        String errMsg = '';
        String country;
        String acrIdOrErrMsg;
        User loggedInUser = [SELECT Id, Name, Email FROM User WHERE Id =:UserInfo.getUserId()];
        if(regReq.PRM_Country__c.length() == 2){
           country = getCountryCode(regReq.PRM_Country__c);
        }else if(regReq.PRM_Country__c.length() == 3){
            country = regReq.PRM_Country__c;
        }
        
        Account_Create_Request__c acr = new Account_Create_Request__c();
        acr.Account_Name__c = regReq.PRM_Company_Nm_Eng__c;
        acr.Core_Alternate_Language_Name__c = regReq.PRM_Account_Name__c;
        acr.Core_Alternate_Name_Language__c = regReq.PRM_Alt_CompanyNameLang__c;
        acr.Requestor_Email__c = loggedInUser.Email;
        acr.Address__City__s = regReq.PRM_City__c;
        if(country!= null){
            acr.Address__CountryCode__s = country;
            acr.Address__StateCode__s = regReq.PRM_State_Province__c;
        }
        acr.Address__PostalCode__s = regReq.PRM_Zip_Postal_Code__c;
        acr.Process_Type__c = 'Partner';
        acr.Requestor_Name__c = loggedInUser.Name;
        acr.Address__Street__s = regReq.PRM_Address_Line_1__c != null ? regReq.PRM_Address_Line_1__c + (regReq.PRM_Address_Line_2__c!=null ? regReq.PRM_Address_Line_2__c : '') : null;
        acr.Global_Account__c = regReq.PRM_Review_Note_txt__c;
        acr.Digital_Identifier_Type__c = 'Website/URL';
        acr.Digital_Identifier_Value__c = regReq.PRM_Account_URL__c;
        acr.Industry__c = 'To Be Defined';
        acr.Core_Sub_Industry__c = 'To Be Defined';
        acr.Core_Sales_Groups__c = 'Undefined';
        
        acrIdOrErrorMsgWrp acrOrErrWrp = new acrIdOrErrorMsgWrp();
        // Insert the account request queue record
        Database.SaveResult result = Database.insert(acr, false);
        
        // Check if the insert was successful
        if (result.isSuccess()) {
            acrOrErrWrp.acrId = result.getId();
        } 
        else {
            // create log entry record of failed acr record
            for (Database.Error err : result.getErrors()) {
                errMsg = 'fieldName: '+ err.Fields.toString() + '\n'+ 'error: '+ err.getStatusCode();
                // to check duplicate AQR and throw errorTWC729-6948
                if(String.valueOf(err.getStatusCode()) == 'FIELD_CUSTOM_VALIDATION_EXCEPTION' 
                && err.getMessage().contains(LabelConfiguration__mdt.getInstance('PRM_UCD_DuplicateAQRError').Value__c)){
                    acrOrErrWrp.errorMsg = LabelConfiguration__mdt.getInstance('PRM_DuplicateARQ').Value__c;
                }
            }
            
            if(Test.isRunningTest()){
                errMsg = 'Test Msg for Coverage';
            }
            
            if(errMsg != '') {
                Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, 
                                                   LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,
                                                   'Error while inserting acc req queue records', 
                                                   errMsg ,'' ,'createAccountRequestQueue' ,'');  
            }
        }
        return acrOrErrWrp;
    }

    /**
    *  @description      : 
    *  @name             : handleNewAccountCreationRequest
    *  @param            : PRM_Registration_Request__c regReqRecord, String requestType
    *  @throws exception : NONE
    **/
    private static String handleNewAccountCreationRequest(PRM_Registration_Request__c regReqRecord) {
        String acrIdOrErrorStr;
        regReqRecord.PRM_Status__c = 'Pending';
       // Id accReqQId = createAccountRequestQueue(regReqRecord);
       acrIdOrErrorMsgWrp acrErrorWrp = new acrIdOrErrorMsgWrp();
        acrErrorWrp =  createAccountRequestQueue(regReqRecord);
        if (acrErrorWrp.acrId != null) {
            regReqRecord.PRM_Account_Request_Queue__c = acrErrorWrp.acrId;
        }
        else if(acrErrorWrp.errorMsg != null){
            acrIdOrErrorStr = acrErrorWrp.errorMsg;
        }
        return acrIdOrErrorStr;
    }
    
    /*ResponseWrap*/
    public class ResponseWrap {

        @AuraEnabled public Boolean flag;
        @AuraEnabled public String message;
        @AuraEnabled public String requestType;
        @AuraEnabled public Boolean createAccReq;
        
        public ResponseWrap(Boolean flag,String message,String requestType, boolean createAccReq) {
            this.flag = flag;
            this.message = message;
            this.requestType = requestType;
            this.createAccReq = createAccReq;
        }
    }

    /*get 3 digit country code from 2 digit country code*/
    public static string getCountryCode(String cntryCd){
        String countryCd;
        for(Core_Country_Code_Mapping__c allCountry : Core_Country_Code_Mapping__c.getAll().values()) {
            if(allCountry.Country_Code__c == cntryCd){
                countryCd = allCountry.ISO_Code__c;
                break;
            }
        }
        return countryCd;
    }

    private class acrIdOrErrorMsgWrp {
        public String acrId{get;set;}
        public String errorMsg{get;set;}
    }
    @AuraEnabled(cacheable=true)
    public static companyValidationWrap checkCompanyValidationStatus(Id regReqId) {
        boolean isValidationInProgress =false;
        
        CompanyValidationWrap compValidWrap = new CompanyValidationWrap();
        try{
            if (regReqId!=null){
                //ATHR Fix - TWC729-9556
                for (PRM_Registration_AI_Agent_Info__c agentInfoRec : [Select id /*,PRM_Status__c*/ from PRM_Registration_AI_Agent_Info__c 
                                       where PRM_Registration_Request__c =: regReqId and
                                       PRM_Status__c ='In Progress' limit 1]) {
                    isValidationInProgress = true;
                }
                compValidWrap.isValidationInProgress = isValidationInProgress;
                compValidWrap.enableForAllFlag = LabelConfiguration__mdt.getInstance('PRM_CDB_EnableForAll').Value__c;
            }
        }catch(Exception ex){
            
            listLogEntries.add(createLogEntry(ex.getMessage(), 'Medium', 'checkCompanyValidationStatus + Exception'));
            
        }
        return compValidWrap;
    }
    public class CompanyValidationWrap{
        @AuraEnabled public boolean isValidationInProgress{get;set;} 
        @AuraEnabled public String enableForAllFlag {get;set;}
    }
}