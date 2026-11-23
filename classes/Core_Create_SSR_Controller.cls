/**************************************************************************************
* Apex Class Name   : Core_Create_SSR_Controller 
* Created Date      : June 12nd, 2023
* Description       : Creates Sales Support Request in DRD system
* Modification Log  :
* Developer           Date               Description
* ----------------------------------------------------------------------------    
* Pratik Padwal   -  June 12nd, 2023  Initial Deployed Version
* Pratik Padwal   -  August 9th, 2023 TWC3123-4852- Added PSG quote logic
*************************************************************************************/

public without sharing class Core_Create_SSR_Controller {
    public static id SMGSupportRequestID;
    public static String smgSSRName;
    public static String SSR_JSON;
    public static String WebserviceCallErrorMsg;
    public static String webserviceCallStatus;
    public static String Response_Msg;
    public static String DRDSupportRequestID;
    public static  String WebserviceCallErrorMsg_truncated;
    static final String STATUS_CANCELLED  = 'Cancelled';
    static final String STATUS_PROD_CANCELLED  = 'Production Cancelled';
    public static String errorMsg;
    
    
    @auraEnabled
    public static SSR_RequestDetails CreateSSR(String OppsId,String RequestType,String Subject, String Description, Date DeadlineDate, boolean UserAgreed) {
        /* Perform following operations */
        /* Insert Sales Support Request Record into Sales Support request Object */
        /* Update Opportunity record for the DRD Request flag to true to enable criteria based sharing */
        /* Insert Opportunity Salesforce Support Request record */
        /* Insert data sent to DRD into Integration Outbound Message Object */     
        if (OppsId != Null) {
            boolean hasOptyUpdated = updateOptyRecord(OppsId,UserAgreed);
            if (hasOptyUpdated == true) {
                InsertSSRRecord(OppsId,RequestType,Subject,Description,DeadlineDate);
                updateOptyRecord(OppsId,UserAgreed);
                InsertOptySSRRecord(OppsId,SMGSupportRequestID );
                InsertOutboundMessage(OppsId,RequestType,Subject,Description,DeadlineDate);
            }
            
            SSR_RequestDetails srrDetails = new SSR_RequestDetails(SMGSupportRequestID,smgSSRName,SSR_JSON);
            return srrDetails;
        }
        
        return null;
    }
    
    /* Create Sales Support request record */
    public static void InsertSSRRecord(String OppsId,String RequestType,String Subject, String Description, Date DeadlineDate) {  
        Id recordTypeId = Schema.SObjectType.Core_Sales_Support_Request__c.getRecordTypeInfosByName().get(System.Label.Core_SSR_Record_Type).getRecordTypeId();
        
        // truncate in case if user enter more than 1000 characters
        if( Description.length() > 1000 ) { Description = Description.substring(0,1000);}
        
        Core_Sales_Support_Request__C SMGSupportRequest = 
            new Core_Sales_Support_Request__C(Core_DRD_Description__c = Description, 
                                              Core_Opportunity__C = OppsId,
                                              Core_DRD_Request_Type__c=RequestType,
                                              Core_DRD_Subject__c=Subject,
                                              Core_DRD_Deadline_for_Results__C=DeadlineDate,
                                              RecordTypeId=recordTypeId
                                              
                                             );
        
        try {
            insert SMGSupportRequest;
            SMGSupportRequestID = SMGSupportRequest.Id;
            Core_Sales_Support_Request__C   cssr        = [select Name from Core_Sales_Support_Request__C where ID = :SMGSupportRequest.Id];
            smgSSRName  =  cssr.Name;
            
        }
        catch (dmlexception e) {
            String errorMsg = e.getMessage();
            String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
            pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
            throw new AuraHandledException(ErrorMsg);
        }
    }
    // Intel Partner Led OPTY hide the section -- Pricing or Quoting
    @AuraEnabled
    public static boolean showPricingAndQuoting(Id recordId){
        List<Opportunity> oppId = [Select Id from Opportunity 
                                   where Core_Opportunity_Coverage_Nm__c= 'Partner-Led Opportunity' 
                                   and Core_Coverage_Type_Nm__c= 'Deal Registration' and Id =: recordId ];
        if(oppId.IsEmpty()){
            return true;              
        }
        else{
            return false;
        }
    }
    
    
    public static void InsertOptySSRRecord(Id optyId, Id ssr_id ) {
        Core_Sales_Support_Request_Opportunity__c opty_ssr =  
            new Core_Sales_Support_Request_Opportunity__c(Core_Opportunity__c = optyId , Core_Sales_Support_Request__c = ssr_id );        
        try {
            insert opty_ssr;
        }
        catch(dmlexception e) {
            String errorMsg = e.getMessage();
            String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
            pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
            throw new AuraHandledException(ErrorMsg);
        }
    }
    /* update opportunity to set the Opty share flag to true : enables record for criteria based sharing*/
    public static Boolean updateOptyRecord(Id OptyId, boolean UserAgreed) {
        Opportunity opty = [select Id,Core_DRD_Support_Request_Created__c from Opportunity where Id = :OptyId];
        opty.Core_DRD_Support_Request_Created__c = UserAgreed;
        Boolean hasOptyUpdated = false;
        try {
            update opty;
            hasOptyUpdated = true;
        }
        catch(dmlexception e) {
            String errorMsg = e.getMessage();
            String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
            pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
            throw new AuraHandledException(ErrorMsg);
        }
        return hasOptyUpdated;
    }
    
    /* Insert data sent via webservice to Integration Outbound Message */
    public static void InsertOutboundMessage(String OppsId,String RequestType,String Subject, String Description, Date DeadlineDate) {
        Id userId              = UserInfo.getUserId();
        String SSR_Requestor_Name = UserInfo.getName();
        String SSR_Requestor_Email = UserInfo.getUserEmail();
        Date deadLineForResults = DeadlineDate;
        
        SSR_JSON =            
            '{"SupportRequest":[ {' +
            '"Opportunity_Id"   : "' + OppsId + '",' +
            '"Support_Request_Id"   : "' + smgSSRName + '",' +
            '"Support_Request_Type"    : "' + RequestType  + '",' +
            '"Requestor"    : "' + userId  + '",' +
            '"Description"    : "' + Description  + '",' +  
            '"Subject"         : "' + Subject  + '",' +
            '"Deadline_For_Results" : "' + deadlineForResults +  '"' +
            '}]}';
        
        Core_Integration_Outbound_Message__c integrationOuboundMessage = 
            new Core_Integration_Outbound_Message__c(Core_MessageType__c = System.Label.Core_SSR_Record_Type, 
                                                     Core_Payload__c=SSR_JSON);
        try {
            insert  integrationOuboundMessage;
        }
        catch (dmlexception e) {
            String errorMsg = e.getMessage();
            String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
            pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
            throw new AuraHandledException(ErrorMsg);
        }
    }
    /* Call DRD REST Webservice to create record in SSG Support Request object */
    @AuraEnabled
    public static string  SSR_In_DRD_via_REST_Call(String SMGSupportRequestID, String SSR_JSON ) {  
        HttpRequest request;
        Http        http;
        HttpResponse response;
        webserviceCallStatus = System.Label.Core_SSR_Pending;
        SMGSupportRequestID = SMGSupportRequestID;
        
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
                InsertInboundMessage(DRDSupportRequestID,SMGSupportRequestID,Response_Msg);
                return webserviceCallStatus;
            }
            else { 
                webserviceCallStatus = System.Label.Core_SSR_Failed;
                WebservicecallErrorMsg = Response_Msg;
                string ErrMsg = webserviceCallFailed(Response_Msg + response.getStatus());
                InsertInboundMessage('',SMGSupportRequestID,Response_Msg);
                return ErrMsg;
                
            }
        }
        catch(Exception e ) {
            webserviceCallStatus = System.Label.Core_SSR_Failed;
            WebservicecallErrorMsg = e.getMessage();
            Response_Msg = WebservicecallErrorMsg;
            throw new AuraHandledException('SSR_In_DRD_via_REST_Call '+webserviceCallFailed(Response_Msg + e.getMessage()));
        }
    }
    
    // method to perform webservice failed actions
    public static string webserviceCallFailed(String erroMsg) {
        WebservicecallErrorMsg = System.Label.Core_SSR_Integration_Issue;
        if(WebservicecallErrorMsg.length() > 255 ) { WebserviceCallErrorMsg_truncated = WebservicecallErrorMsg.substring(0,255);}
        return WebservicecallErrorMsg +' '+ erroMsg;
    }
    
    /* Log Inbound Message */
    public static void InsertInboundMessage(String DRDSupportRequestID, String SMGSupportRequestID , String Response_Msg) {
        updateSaleSupportRequest(DRDSupportRequestID, SMGSupportRequestID);
        String Inbound_Msg_Details = Response_Msg;
        String Exception_Msg       = '';
        String tag                 = SMGSupportRequestID;
        
        
        if (webserviceCallStatus == System.Label.Core_SSR_Failed ) {
            Inbound_Msg_Details = '';
            Exception_Msg       = Response_Msg;
        }
        Core_Integration_Inbound_Message__c ciim = new Core_Integration_Inbound_Message__c ( 
            Core_Source_System__c = System.Label.Core_SSR_DRD_Label, 
            Core_Tags__c = SMGSupportRequestID,
            Core_Payload__c = Inbound_Msg_Details, 
            Core_Message_Type__c = System.Label.Core_SSR_Support_Request, 
            Core_Processing_Status__c=webserviceCallStatus, 
            Core_Exception_Message__C = Exception_Msg,
            Core_Error_Description__c = WebserviceCallErrorMsg_truncated);
        try {
            insert ciim;
        }
        catch (dmlexception e) {
            String errorMsg = e.getMessage();
            String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
            pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
            throw new AuraHandledException('InsertInboundMessage '+ErrorMsg);
        }
    }
    
    // update SalesSupport Request Record with obtained DRD Sale Support Request Id
    public static void updateSaleSupportRequest(String DRDSupportRequestId, ID SMGSupportRequestID) {
        Core_Sales_Support_Request__C SSR_Obj =  [select Id,Core_External_id__c from Core_Sales_Support_Request__C where ID = :SMGSupportRequestID];
        SSR_Obj.Core_External_id__C = DRDSupportRequestId;
        try {
            update SSR_Obj;
        }
        catch(DMLException e) {
            String errorMsg = e.getMessage();
            String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
            pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
            throw new AuraHandledException('updateSaleSupportRequest '+ErrorMsg);
        }
    }
    
    //TWC3123-4852- Start
    /**********************************
* Method Name : createPSGQuoteonSiebel 
* Created On  : Dec-05-2016
* Created By  : Accenture 
* Description : Intel Altera Phase1: 
*               Below method is used for validating the opportunity and 
*               for creating the Payload before sending the data to Siebel.
***********************************/
    /*@auraEnabled
    public static quoteResponse createPSGQuoteonSiebel(String soppId) {
        try{ 
            UserRecordAccess recordAccessObj = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :soppId];
            if (recordAccessObj == null || recordAccessObj.HasEditAccess != true){                          
                Core_SalesSupportHomeController.SharingInnerClass innerClass = new Core_SalesSupportHomeController.SharingInnerClass();
                innerClass.insertSharing(String.valueof(soppId));
            }
            
            quoteResponse quoteDetails = new quoteResponse();
            if(validateOpportuntyBeforeQuoteCreation(soppId)) {
                String quoteName = PSG_CreateQuoteController.createQuote(soppId);
                if(quoteName!=null){
                    String quoteNumber = quoteName.substringBefore(':');
                    String quoteId =    quoteName.substringAfter(':');
                    quoteDetails.quoteID =quoteNumber;
                    quoteDetails.quoteRecId=quoteId;
                    quoteDetails.status='Success';
                    quoteDetails.errorMsg=null;
                }else{
                    quoteDetails.quoteID =null;
                    quoteDetails.quoteRecId=null;
                    quoteDetails.status='Fail';
                    quoteDetails.errorMsg=null;
                }
                return quoteDetails;
            }
            else{
                quoteDetails.quoteID=null;
                quoteDetails.status='Fail';
                quoteDetails.quoteRecId=null;
                quoteDetails.errorMsg=errorMsg;
                return quoteDetails;
            }
        }catch(Exception e) {
            String errorMsg = e.getMessage();
            String pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
            pureErrorMsg = pureErrorMsg.Substring(0, (pureErrorMsg.length()-4));
            throw new AuraHandledException(ErrorMsg);
        }finally{
            Core_SalesSupportHomeController.SharingInnerClass innClass = new Core_SalesSupportHomeController.SharingInnerClass();
            innClass.deleteSharing(string.valueof(soppId), UserInfo.getUserID());
        }
    }
    */
    //TWC3123-4852 - End    
    /* generate Support Request Type picklist values */
    @auraEnabled
    public static List<SelectOption> getSupport_Request_Type_Picklist_Values() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =
            Core_Sales_Support_Request__c.Core_DRD_Request_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            if(f.isActive()){
                options.add(new SelectOption(f.getLabel(), f.getValue()));                
            }
        }       
        return options;
    }
    
    
    //TWC3123-4475 - Start Code Block for IT@intel
    @Auraenabled(cacheable=true)
    
    public static List<String> getUserRegionUITheme() {
        
        List<String> UserRegionUITheme = new String[2];
        
        User userObj = [select Id, Core_WWID__c, Core_User_Geo__c, Profile.Name from User where Id = :UserInfo.getUserID()];
        
        UserRegionUITheme.add(0,UserInfo.getUiThemeDisplayed());
        
        if(userObj.Core_User_Geo__c != null){        
            
            UserRegionUITheme.add(1,userObj.Core_User_Geo__c);
            
        }
        
      
        
        return UserRegionUITheme;        
        
    }
    //TWC3123-4475 - End
    @Auraenabled(cacheable=true)
    public static List<Core_AAQ_Profile_Handler__c> getURL() {
        List<Core_AAQ_Profile_Handler__c> categoryColumn  = [Select Name, Core_Profile_Url__c,Core_Active__c, Core_Description__c,Core_Description2__c,Core_Profile_Image__c,Core_Order__c FROM Core_AAQ_Profile_Handler__c where Core_Active__c=true and Name ='Sales CRM (Salesforce)' ORDER BY Core_Order__c ];
        return categoryColumn;
    }
    
    //TWC3123-4852 - Get Seed and Sample URL
    @AuraEnabled(cacheable=true)
    
    public static SeedSampleDetails getSeedSampleURL(Id OpportunityId, Id AccountId, String sUCDId, String sCIMId) {
        
        map<String,Core_System_Credentials__c> mapStringToCS = new map<String,Core_System_Credentials__c>();
        // Set the reference to the system url name to system credentials 
        for(Core_System_Credentials__c sobjCS : Core_System_Credentials__c.getAll().Values()){
            mapStringToCS.put(sobjCS.Name, sobjCS);
        }
        string cimOrUnifiedIdPassed = (String.isBlank(sUCDId))? sCIMId : sUCDId; //TWC4767-3983
        SeedSampleDetails getDetails = new SeedSampleDetails();
        getDetails.SeedURL = mapStringToCS.get(System.Label.Core_DemoDepotOrder).Core_End_Point_URL__c + System.Label.Core_CIMID + '=' + AccountId + '&'+ System.Label.Core_aceOppID + '=' + OpportunityId;
        getDetails.SampleURL = mapStringToCS.get('My Samples Request Placement').Core_End_Point_URL__c +'CIMId='+cimOrUnifiedIdPassed+'&OpportunityId=';
        return getDetails; 
        
    }
    
    //TWC3123-4852-Start
    /*public static Boolean validateOpportuntyBeforeQuoteCreation(String soppId) {
        
        // Check if Opportunity Id values exists
        if (String.isEmpty(soppId)) {
            writeErrorMessage(System.Label.Core_PSG_Validate_Quote_Opportunity);
            return false;
        }
        
        // Check if the user has Read/Write Access to the Opportunity
        UserRecordAccess recordAccessObj = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :soppId];
        if (recordAccessObj == null || recordAccessObj.HasEditAccess != true) {
            writeErrorMessage(System.Label.Core_PSG_Validate_Opportunity_Access);
            return false;
        }
        
        // Get the Opportunity Details
        Opportunity oppObj = [SELECT Id, Core_PSG_Quote_Last_Processed_Status__c, AccountId, Core_First_Customer_Ship_Date__c, Core_Volume__c FROM Opportunity WHERE Id = :soppId];
       
        // Check if there is a quote request is progress
        if (oppObj.Core_PSG_Quote_Last_Processed_Status__c == 'Processing') {
            writeErrorMessage(System.Label.Core_PSG_Opportunity_Quote_Creation_Status);
            return false;
        }
        
        // Check if the Account associated to the Opportunity is a PSG Account
        Account accObj = [SELECT Id,Core_Account_Type__c, Core_PSG_Account__c FROM Account WHERE Id = :oppObj.AccountId];
        if(!accObj.Core_PSG_Account__c) {
            writeErrorMessage(System.Label.Core_PSG_Validate_Quote_Account);
            return false; 
        }
        
        
        // Check if First Customer Ship Date and Volume have values
        
        if (oppObj.Core_First_Customer_Ship_Date__c == null || oppObj.Core_Volume__c == null ) {
            writeErrorMessage(System.Label.Core_PSG_Opportunity_Fields_Required);
            return false;
        }
        
        // Get the list of PSG Products associated to the Opportunity
        List<OpportunityLineItem> opportunityProducts = [SELECT Id, Product2.Name, Product2Id, Quantity FROM OpportunityLineItem WHERE Core_Product_Type__c = 'Intel® FPGAs' AND OpportunityId =: oppObj.Id AND Core_Status__c != :STATUS_CANCELLED AND Core_Status__c != :STATUS_PROD_CANCELLED];
        
        // Check if there are any PSG Products associated to the Opportunity
        if (opportunityProducts.isEmpty()) {
            writeErrorMessage(System.Label.Core_PSG_Product_Required);
            return false;
        }
        
        // No validation errors
        return true;
    }*/
    
    public static void writeErrorMessage(String errorMessage) {
        errorMsg=errorMessage;       
    }
    @AuraEnabled
    public static checkOpptyStageresult checkOpptyStage(Id recordId){
        checkOpptyStageresult cheOptyWrp = new checkOpptyStageresult();
        cheOptyWrp.statusApp = false;
        cheOptyWrp.stageName = '';
        Opportunity opp = [Select id,StageName,Core_Approval_Status__c from Opportunity where id =:recordId limit 1 ];
        if((opp!= null) && (opp.Core_Approval_Status__c =='Approved')){
            cheOptyWrp.statusApp = true; 
            cheOptyWrp.stageName = opp.StageName;
        }else{
            cheOptyWrp.statusApp = false;
            cheOptyWrp.stageName = opp.StageName;
        }
        
        return cheOptyWrp;
    }
    
    @AuraEnabled
    public static String getIQRTenderURL(){
        String tenderURL;
        tenderURL = Core_CRM_Utility.getCRMLabel('IQR_Tender_URL');   
        return tenderURL;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getAtRiskURL(){
        String riskURL;
        riskURL = Core_CRM_Utility.getCRMLabel('AtRisk_URL');   
        return riskURL;
    }
    
    @AuraEnabled
    public static String getaiInferenceURL(Id OpportunityId, Double dwAmt, String VertMart, String accname, String accgeo, String useremail, String accsalesgrp, String oppname){
      
        Core_System_Credentials__c sysCred = Core_System_Credentials__c.getValues('AI inference');
        String URL = sysCred.Core_End_Point_URL__c;
        String getAIURL;
        String dwAmtStr = (dwAmt == null)? '' :String.valueOf(dwAmt.format());
        Core_SmartSheet_URL__c smartSheetForm= 	Core_SmartSheet_URL__c.getValues('AI inference form fields');
        dwAmtStr = (String.isEmpty(dwAmtStr)) ? ' ' : dwAmtStr;
        //accsalesgrp = (accsalesgrp.contains('&')) ? accsalesgrp.replace('&','%26') : accsalesgrp ;
        oppname = EncodingUtil.urlEncode(oppname,'UTF-8');
        accname = EncodingUtil.urlEncode(accname,'UTF-8');
        accsalesgrp = EncodingUtil.urlEncode(accsalesgrp,'UTF-8');
        getAIURL = URL +smartSheetForm.SFDC_CRM_Oppty_ID__c+OpportunityId+'&'+smartSheetForm.Expected_Design_Win__c+dwAmtStr+'&'+smartSheetForm.Vertical_Market__c+VertMart+'&'
            +smartSheetForm.Account_Name__c+accname+'&'+smartSheetForm.Account_Geo__c+accgeo+'&'+smartSheetForm.Requestor_Email__c+useremail+'&'+smartSheetForm.Sales_Group__c+accsalesgrp
            +'&'+smartSheetForm.Opportunity_Name__c+oppname;
        return getAIURL;
    }
    //TWC3123-4852- End
    public class SeedSampleDetails{
        
        @AuraEnabled
        public String SeedURL;
        @AuraEnabled
        public String SampleURL;
    }
    //TWC3123-4852 - End
    
    public class SelectOption {
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;
        }    
        @AuraEnabled
        public String label { get;set; }
        @AuraEnabled
        public String value { get;set; }
    }   
    public class SSR_RequestDetails{
        public SSR_RequestDetails(String SSRId, String smgSSRName,String SMGJosn){
            
            this.SSRId = SSRId;
            this.smgSSRName = smgSSRName;
            this.SMGJosn = SMGJosn;
        }
        @AuraEnabled
        public String SSRId { get;set; }
        @AuraEnabled
        public String smgSSRName { get;set; }
        @AuraEnabled
        public String SMGJosn { get;set; } 
        
    }
    //TWC3123-4852 - Quote Reponse
    public class quoteResponse{
        @AuraEnabled
        public String quoteID;
        @AuraEnabled
        public String quoteRecId;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String errorMsg;
        
    }
    //TWC3123-4852-End   
    public Class checkOpptyStageresult{
        @AuraEnabled
        public boolean statusApp { get;set;}
        @AuraEnabled
        public String stageName { get;set;}
    }
}