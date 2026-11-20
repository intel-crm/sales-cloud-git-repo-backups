/**************************************************************************************
* Apex Class Name   : Core_SSR_Controller 
* Created Date      : July 27th, 2017
* Description       : Creates Sales Support Request in DRD system
* Modification Log  :
* Developer           Date               Description
* ----------------------------------------------------------------------------    
* Rangesh Kona	  -  Aug 22nd, 2017  Initial Deployed Version
* Rangesh Kona	  -  Aug 31st, 2017  bug: capture Inbound Message to Integration Inbound Object
*************************************************************************************/

public without sharing class Core_SSR_Controller {
    public String opportunity_id{get;set;}
    public String opportunity_name{get;set;}
    public String Support_Request_Type{get;set;}	  // SSG Support Request Type
    public String Subject{get;set;}					  // SSG Support Request Subject
    public String Description{get;set;}				  // SSG Support Request Description
    public String SSR_JSON{get;set;}    			  // JSON Data sent to SSG System
    public String Response_Msg{get;set;}			  // Response from SSG Ssytem after webservice call
    public Id SMGSupportRequestID{get;set;}			  // Sales Support Request ID
    public String DRDSupportRequestID{get;set;}			  // Support Request Id from DRD System
    public Boolean runAction {get;set;}                 // decides whether to run webservice or not, used in VF Page
    public Boolean User_Agreed_to_Share_Opty{get;set;}  // VF Page form field requesting user to 'Agree' 
    public Date deadlineForResults{get;set;}            // VF Page form field to capture deadlineForResults 
    public Core_Sales_Support_Request__C dummy_obj_for_date {get;set;} // dummy obj to display date dropdown
    public Boolean hasWebserviceCallFailed {get;set;}	// webservice failed ?? 
    public String WebserviceCallErrorMsg{get;set;}		// to capture webservice failed message
    public String WebserviceCallErrorMsg_truncated{get;set;}	// truncate error message as Inbound doesn't store more than 255 characters
    public String webserviceCallStatus{get;set;}		// check the status of webservice call 
    public Boolean hasOptyUpdated{get;set;}				// to make sure user can opty Opty share flag to true
    public String smgSSRName{get;set;}					// to store SMG SSR Name
    
    // Controller Method
    public Core_SSR_Controller() { 
        opportunity_id = ApexPages.currentPage().getParameters().get('id');
        hasWebserviceCallFailed = false;
        if (opportunity_id == null || opportunity_id == '') {
            runAction = false;
        }
        else {
            runAction           = true;
            Opportunity opty    = [select Id, name, account.Name  from Opportunity where Id = :opportunity_id];
            opportunity_name    = opty.Name;
            opportunity_id      = opty.Id;
            // used to display date field on Visualforce page 
            dummy_obj_for_date  = new Core_Sales_Support_Request__C();
        }
    }
    
    // Before calling Webservice 
    public PageReference pre_webservice_call_save() {
        /* Perform following operations */
        /* Insert Sales Support Request Record into Sales Support request Object */
        /* Update Opportunity record for the DRD Request flag to true to enable criteria based sharing */
        /* Insert Opportunity Salesforce Support Request record */
        /* Insert data sent to DRD into Integration Outbound Message Object */
        deadLineForResults  = dummy_obj_for_date.Core_DRD_Deadline_for_Results__C;
        runAction =  performValidations();
        if (runAction == true) {
            hasOptyUpdated = updateOptyRecord(opportunity_id);
            if (hasOptyUpdated == true) {
                InsertSSRRecord();
                updateOptyRecord(opportunity_id);
                InsertOptySSRRecord(opportunity_id,SMGSupportRequestID );
                InsertOutboundMessage(); 
            }
        }
        
        return null;
    }
    
    // Validations to ensure used has filled all the data in the SSG Support Request form
    public boolean performValidations() {    
        runAction = true;
        if (Support_Request_Type == null || Support_Request_Type == '' || Support_Request_Type == 'None') {
            runAction = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Core_SSR_Support_Request_Error));
            
        }
        if (Subject == null || Subject == '') {
            runAction = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Core_SSR_Subject_Error));
            
        }
        if (Description == null || Description == '') {
            runAction = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Core_SSR_Description_Error));
            
        }
        if (deadlineForResults == null)  {
            runAction = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Core_SSR_Deadline_Error));
            
        }
        if (User_Agreed_to_Share_Opty == null || User_Agreed_to_Share_Opty == false) {
            runAction = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,System.Label.Core_SSR_Opportunity_Checkflag_Error));
        }     
        return runAction;
    }
    
    
    /* Create Sales Support request record */
    public void InsertSSRRecord() {  
        Date deadLineForResults = dummy_obj_for_date.Core_DRD_Deadline_for_Results__C;
        Id recordTypeId = Schema.SObjectType.Core_Sales_Support_Request__c.getRecordTypeInfosByName().get(System.Label.Core_SSR_Record_Type).getRecordTypeId();
        
        // truncate in case if user enter more than 1000 characters
        if( description.length() > 1000 ) { description = description.substring(0,1000);}
        // String.escapeSingleQuotes added to opportunity_id for security
        Core_Sales_Support_Request__C SMGSupportRequest = 
            new Core_Sales_Support_Request__C(Core_DRD_Description__c = description, 
                                              Core_Opportunity__C = String.escapeSingleQuotes(opportunity_id),
                                              Core_DRD_Request_Type__c=Support_Request_Type,
                                              Core_DRD_Subject__c=subject,
                                              Core_DRD_Deadline_for_Results__C=deadLineForResults,
                                              RecordTypeId=recordTypeId
                                              
                                             );
        
        try {
            insert SMGSupportRequest;
            SMGSupportRequestID = SMGSupportRequest.Id;
            Core_Sales_Support_Request__C 	cssr 		= [select Name from Core_Sales_Support_Request__C where ID = :SMGSupportRequest.Id];
            smgSSRName 	=  cssr.Name;
            
        }
        catch (dmlexception e) {
            apexpages.addmessages(e);
        }
        
    }
    
    /* update opportunity to set the Opty share flag to true : enables record for criteria based sharing*/
    public Boolean updateOptyRecord(Id OptyId) {
        Opportunity opty = [select Id from Opportunity where Id = :OptyId];
        opty.Core_DRD_Support_Request_Created__c = User_Agreed_to_Share_Opty;
        Boolean hasOptyUpdated = false;
        runAction	   = false;
        try {
            update opty;
            hasOptyUpdated = true;
            runAction = true;
        }
        catch(dmlexception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, System.Label.Core_SSR_Opty_Share_Error));
            apexpages.addmessages(e);
        }
        return hasOptyUpdated;
    }
    
    /* Create junction record in Sales support Request Opportunity Object */
    public void InsertOptySSRRecord(Id optyId, Id ssr_id ) {
        Core_Sales_Support_Request_Opportunity__c opty_ssr =  
            new Core_Sales_Support_Request_Opportunity__c(Core_Opportunity__c = optyId , Core_Sales_Support_Request__c = ssr_id );        
        try {
            insert opty_ssr;
        }
        catch(dmlexception e) {
            apexpages.addmessages(e);
        }
    }
    
    
    /* Insert data sent via webservice to Integration Outbound Message */
    public void InsertOutboundMessage() {
        Id userId              = UserInfo.getUserId();
        String SSR_Requestor_Name = UserInfo.getName();
        String SSR_Requestor_Email = UserInfo.getUserEmail();
        Date deadLineForResults = dummy_obj_for_date.Core_DRD_Deadline_for_Results__C;
        // String.escapeSingleQuotes added to opportunity_id for security
        SSR_JSON =            
            '{"SupportRequest":[ {' +
            '"Opportunity_Id"   : "' + String.escapeSingleQuotes(opportunity_id) + '",' +
            '"Support_Request_Id"   : "' + smgSSRName + '",' +
            '"Support_Request_Type"    : "' + Support_Request_Type  + '",' +
            '"Requestor"    : "' + userId  + '",' +
            '"Description"    : "' + Description  + '",' +  
            '"Subject"         : "' + Subject  + '",' +
            '"Deadline_For_Results" : "' + deadlineForResults +  '"' +
            '}]}';
        
        Core_Integration_Outbound_Message__c integrationOuboundMessage = 
            new Core_Integration_Outbound_Message__c(Core_MessageType__c = System.Label.Core_SSR_Record_Type, 
                                                     Core_Payload__c=SSR_JSON
                                                    );
        try {
            insert  integrationOuboundMessage;
        }
        catch (dmlexception e) {
            apexpages.addmessages(e);
            
        }
    }
    
    /* Call DRD REST Webservice to create record in SSG Support Request object */
    public PageReference Create_SSR_In_DRD_via_REST_Call() {  
        HttpRequest request;
        Http		http;
        HttpResponse response;
        
        webserviceCallStatus = System.Label.Core_SSR_Pending;
        
        try {
        	request = new HttpRequest();
            request.setEndpoint('callout:DRD/services/apexrest/SSRSupportRequest/createSSR/');   
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            String json_string = SSR_JSON;
            request.setBody(json_string);
            http = new Http();
            response = http.send(request);
            Response_Msg = response.getBody();
            
            if ((response.getStatusCode() == 200 && response.getStatus() == 'OK') ) {
                String  DRD_Name =Response_Msg;
                DRD_Name =  DRD_Name.removeStart('"');
                DRD_Name =  DRD_Name.removeEnd('"');
                DRDSupportRequestID = DRD_Name;
                webserviceCallStatus = System.Label.Core_SSR_Successful;
            }
            else { 
                webserviceCallStatus = System.Label.Core_SSR_Failed;
                WebservicecallErrorMsg = Response_Msg;
                webserviceCallFailed(Response_Msg + response.getStatus() );
                
            }
        }
        catch(Exception ex ) {
               webserviceCallStatus = System.Label.Core_SSR_Failed;
                WebservicecallErrorMsg = ex.getMessage();
                Response_Msg = WebservicecallErrorMsg;
                webserviceCallFailed(Response_Msg + ex.getMessage() );
        }
                    
        return null;
    }
    
    // method to perform webservice failed actions
    public void webserviceCallFailed(String erroMsg) {
        runAction = false;
        WebservicecallErrorMsg = System.Label.Core_SSR_Integration_Issue;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, WebservicecallErrorMsg + erroMsg));
        if(WebservicecallErrorMsg.length() > 255 ) { WebserviceCallErrorMsg_truncated = WebservicecallErrorMsg.substring(0,255);}
        hasWebserviceCallFailed = true;
        webserviceCallStatus = System.Label.Core_SSR_Failed;
    }
    
    /* Log Inbound Message */
    public void InsertInboundMessage() {
        updateSaleSupportRequest(DRDSupportRequestID, SMGSupportRequestID);
        String Inbound_Msg_Details = Response_Msg;
        String Exception_Msg	   = '';
        String tag				   = SMGSupportRequestID;
        
        if (webserviceCallStatus == System.Label.Core_SSR_Failed ) {
            Inbound_Msg_Details = '';
            Exception_Msg 		= Response_Msg;
        }
        Core_Integration_Inbound_Message__c ciim = new Core_Integration_Inbound_Message__c ( 
            									Core_Source_System__c = System.Label.Core_SSR_DRD_Label, 
            									Core_Tags__c = SMGSupportRequestID,
            									Core_Payload__c = Inbound_Msg_Details, Core_Message_Type__c = System.Label.Core_SSR_Support_Request, 
            									Core_Processing_Status__c=webserviceCallStatus, 
            									Core_Exception_Message__C = Exception_Msg,
            									Core_Error_Description__c = WebserviceCallErrorMsg_truncated);
        try {
            insert ciim;
        }
        catch (dmlexception e) {
            apexpages.addmessages(e);
        }
    }
    
    // update SalesSupport Request Record with obtained DRD Sale Support Request Id
    public void updateSaleSupportRequest(String DRDSupportRequestId, ID SMGSupportRequestID) {
        Core_Sales_Support_Request__C SSR_Obj =  [select Id,Core_External_id__c from Core_Sales_Support_Request__C where ID = :SMGSupportRequestID];
        SSR_Obj.Core_External_id__C = DRDSupportRequestId;
        try {
            update SSR_Obj;
        }
        catch(DMLException e) {
            apexpages.addmessages(e);
        }
    }
    
    
    /* generate Support Request Type picklist values */
    public List<SelectOption> getSupport_Request_Type_Picklist_Values() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =
            Core_Sales_Support_Request__c.Core_DRD_Request_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        boolean none_value = true;
        for( Schema.PicklistEntry f : ple)
        {
            if (none_value == true) {
                options.add(new SelectOption('None', ''));
                none_value = false;
            }
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    /* Final page redirection */
    public PageReference FinalPageRedirect() {
        PageReference pageRef = new PageReference('/' + SMGSupportRequestID );
        return pageRef;
    } 
}