/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_QuotesV3 
* Version     : 2.0 
* Created Date: 06 May 2022
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         06/05/2022              Rest API to create or submit all 4 sections

Rest API to get all 4 section details as response
POST=>
Sample API call:- /services/apexrest/v1.0/quoterequest/quotes?action=
action => create (to create all 4 sections with draft status)
action => submit (to submit all 4 sections with quote as submitted status)
action => getstatus (get status of all quotelines)

GET=>
Sample API call:- /services/apexrest/v1.0/quoterequest/quotes?type=&id=
type => quote (fetch section 1 details)
type => blank, all (fetch all 4 section details)
id => quoteId

Description=> Pass the quoteDetails as an input JSON and it will submit or create the Quote
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v3.0/quoterequest/quotes')
global without sharing class Pricing_RestAPI_QuotesV3 extends TriggerHandler{
    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_QuotesV2.class.getName();
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    public static boolean isGetStatus = false;
    public static boolean isCreateQuoteTeam = false;
    public static boolean isResubmit = false;
    public static boolean isRollBack = false;
    public static boolean isUpdatePrimaryContact = false;
    public static String type;
    public static String recId;
    public static String quoteName;
    public static Id quoteId;
    public static String days;
    public static String QUOTE = 'quote';
    public static Map<Id, List<Pricing_Performance_Metric__c>> pmMap = new Map<Id, List<Pricing_Performance_Metric__c>>();
    public static Map<String,List<SBQQ__QuoteLine__c>> qliTypeToQli = new Map<String,List<SBQQ__QuoteLine__c>>();
    public static QuoteWrapper quoteWrapper = new QuoteWrapper();
    public static QuoteWrapperClient quoteWrapperClient = new QuoteWrapperClient();
    public static String currentUserContactId;
    public static User currentUser;
    public static Boolean isSvdQuote = false;
    public static Boolean isClient = false;
    //public static Boolean isSubmitQuote = false;
    //public static Boolean isOverAllQtyLess = false;
    public static String primaryContactEmail;
    public static String actionType;
    public static Boolean isQuota = true; 
    
    /**
    * @description method to recive post request and validate the param
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
    * @return Pricing_RestAPI_Response 
    **/
    @HttpPost
    global static Pricing_RestAPI_Response doPost(){
        RestRequest req = RestContext.request;
        //currentUser = [Select Id,ContactId,AccountId,Email from User where Id = :UserInfo.getUserId()];
        //validate the action parameters if its create or submit
        if(validateActionParam()){
            if(isGetStatus){
                processRequest(req.requestBody.toString());
            }
            else if(isRollBack){
                processRollBackRequest(req.requestBody.toString());
            }
            else{
                processRequest(req.requestBody.toString());
            }
        }else{
            //action is invalid
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }

    /**
    * @description validating the request parameters for create api
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
    * @return boolean 
    **/
    public static boolean validateActionParam(){
        String typeParam = Pricing_RestAPI_Util.getRequestParam('type');
        String recId = Pricing_RestAPI_Util.getRequestParam('id');
        actionType = Pricing_RestAPI_Util.getRequestParam('action');
        if(typeParam != null && typeParam.toLowerCase() == Label.Pricing_RestAPI_Products_SVD_Param){
            isSvdQuote = true;
            Pricing_RestAPI_QuotesUtilityV2.isSvd =  true;
        }
        if(typeParam != null && typeParam.toLowerCase() == Label.Pricing_RestAPI_Products_Client_Param){
            Pricing_RestAPI_QuotesUtilityV2.isClient =  true;
        }
        if(actionType != null &&  actionType.toLowerCase() == 'submit' && (String.isblank(typeParam) || typeParam.toLowerCase() == 'datacenter' || typeParam.toLowerCase() == 'standard')){
            Pricing_RestAPI_QuotesUtilityV2.isDataCenterCPU = true;
        }
        if(actionType != null && (actionType.toLowerCase() == 'create' || actionType.toLowerCase() == 'submit' || actionType.toLowerCase() == 'getstatus' || actionType.toLowerCase() == 'quoteteam')){ 
            //if action is create then create Quote in draft status
            //if action is submit then create Quote and submit it for Intel Review
            Pricing_RestAPI_QuotesUtilityV2.isCreateDraftQuote = (actionType.toLowerCase()=='create') ? true : false;
            isGetStatus = (actionType.toLowerCase()=='getstatus') ? true : false;
            isCreateQuoteTeam = (actionType.toLowerCase()=='quoteteam') ? true : false;
            Pricing_RestAPI_QuotesUtilityV2.isSubmitQuote = (actionType.toLowerCase()=='submit') ? true : false;
            return true;  
        }else if(actionType != null && actionType.toLowerCase() == 'recall' && !String.isBlank(recId)){
            isRollBack = true;
            quoteId = recId instanceOf Id ? Id.valueOf(recId) : null;
            return true;
        }else{
            //invalid action parameter
            return false;
        }
    }

    /**
    * @description Method to update AE and FSE on Quote when doing from Quote Team API.
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 
    * @param quoteId 
    * @param FseEmails 
    * @param AeEmails 
    * @param accountId 
    **/
    public static void updateQuoteFseAeFromQtm(Id quoteId,String FseEmails, String AeEmails, Id accountId){

         Map<Id,SBQQ__Quote__c> quoteMap = new Map<Id,SBQQ__Quote__c>([select id,SBQQ__SalesRep__c,Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Account_Executive_Nm__c,Pricing_Intel_Sales_Rep_Email_Txt__c from SBQQ__Quote__c where  Id =:quoteId and SBQQ__Account__c = :accountId]);
        
        if(quoteMap.size() > 0){
        List<String> FseEmail =  new List<String>(Pricing_RestAPI_QuotesUtilityV2.getSplitedEmailList(FseEmails.toLowerCase()));
        List<String> AeEmail =  new List<String>(Pricing_RestAPI_QuotesUtilityV2.getSplitedEmailList(AeEmails.toLowerCase()));
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
            if(quoteMap.get(quoteId).Pricing_Intel_Sales_Rep_Email_Txt__c == null && !String.isBlank(FseEmail[0])){
                quoteMap.get(quoteId).Pricing_Intel_Sales_Rep_Email_Txt__c = FseEmail[0];
                quoteMap.get(quoteId).SBQQ__SalesRep__c = quoteMap.get(quoteId).SBQQ__SalesRep__c == null && Pricing_RestAPI_QuotesUtilityV2.validFSEEmailIdMap.containsKey(FseEmail[0]) ?  Pricing_RestAPI_QuotesUtilityV2.validFSEEmailIdMap.get(FseEmail[0]) :quoteMap.get(quoteId).SBQQ__SalesRep__c;
                quotesToUpdate.add(quoteMap.get(quoteId));
            }
            if(quoteMap.get(quoteId).Pricing_Intel_Account_Exec_Email_Txt__c == null && !String.isBlank(AeEmail[0])){
                quoteMap.get(quoteId).Pricing_Intel_Account_Exec_Email_Txt__c = AeEmail[0];
                if(Pricing_RestAPI_QuotesUtilityV2.validAeEmailIdMap.size() > 0 && Pricing_RestAPI_QuotesUtilityV2.validAeEmailIdMap.containsKey(AeEmail[0])){
                    quoteMap.get(quoteId).Pricing_Account_Executive_Nm__c =  Pricing_RestAPI_QuotesUtilityV2.validAeEmailIdMap.get(AeEmail[0]);
                }
                if(!quotesToUpdate.contains(quoteMap.get(quoteId))){
                quotesToUpdate.add(quoteMap.get(quoteId));
                }
            }
            if(quotesToUpdate.size() > 0){
                 update quotesToUpdate;
            }
        }
    }
    /**
* @description validate the request fileds anf insert the record
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @param reqBody 
**/
    public static void processRequest(String reqBody){ 
        try {
            if(isGetStatus){
                Set<Id> quoteIds = new Set<Id>();
                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(reqBody);
                List<Object> reqQuoteIds = (List<Object>) jsonMap.get('quoteIds');
                //Pricing_RestAPI_QuotesUtilityV2 quoteUtility = new Pricing_RestAPI_QuotesUtilityV2();
                //Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
                for(Object obj:reqQuoteIds){
                    String quoteId = (String)obj;
                    if(quoteId.length() == 18 && Pattern.matches('[a-zA-Z0-9]{15,18}',quoteId)){
                        quoteIds.add(quoteId);
                    }
                }
                getStatusDetails(quoteIds);
            }else if(isCreateQuoteTeam){
                Pricing_RestAPI_QuotesUtilityV2.QuoteWrapper quote = (Pricing_RestAPI_QuotesUtilityV2.QuoteWrapper) JSON.deserialize(reqBody, Pricing_RestAPI_QuotesUtilityV2.QuoteWrapper.class);
                Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
                Pricing_RestAPI_QuotesUtilityV2 quoteUtility = new Pricing_RestAPI_QuotesUtilityV2();
                boolean isValid = quoteUtility.validateQuote(quote, quoteErrors, true);
                String quoteId = quote.quoteId;

                if(isValid){
                    List<Pricing_Quote_Team__c> quoteTeamInsertList = new List<Pricing_Quote_Team__c>();
                    
                    if(Pricing_RestAPI_QuotesUtilityV2.ITSEmailUserList.size() > 0){
                        List<Pricing_Quote_Team__c> itsQTM = Pricing_RestAPI_QuotesUtilityV2.createITSQuoteTeam(quoteId);
                        if(itsQTM.size() > 0){
                            quoteTeamInsertList.addAll(itsQTM);
                        }
                    }
                    if(Pricing_RestAPI_QuotesUtilityV2.validFSEEmailIdMap.size() > 0){
                        List<Pricing_Quote_Team__c> fseQTM = Pricing_RestAPI_QuotesUtilityV2.createFSEQuoteTeam(quoteId);
                        if(fseQTM.size() > 0){
                            quoteTeamInsertList.addAll(fseQTM);
                        }
                    }
                    if(Pricing_RestAPI_QuotesUtilityV2.AEEmailUserList.size() > 0){
                        List<Pricing_Quote_Team__c> aeQTM = Pricing_RestAPI_QuotesUtilityV2.createAEQuoteTeam(quoteId);
                        if(aeQTM.size() > 0){
                            quoteTeamInsertList.addAll(aeQTM);
                        }
                    }
                    if(quoteTeamInsertList.size()>0){
                        Pricing_QuoteTeam_Trigger_Handler.isInertedFromQuoteTriggerorApi = true;
                        insert quoteTeamInsertList;
                        updateQuoteFseAeFromQtm(quoteId,quote.quoteDetails.intelSalesRepEmail, quote.quoteDetails.intelAccountExecutiveEmail, Pricing_RestAPI_QuotesUtilityV2.currentUser.AccountId);
                    }
                    response.totalRecords = Pricing_RestAPI_QuotesUtilityV2.AEEmailUserList.size() + Pricing_RestAPI_QuotesUtilityV2.ITSEmailUserList.size() + Pricing_RestAPI_QuotesUtilityV2.validFSEEmailIdMap.size();
                    response.successContent = new List<QuoteTeamCreation>();
                    response.successContent.add(new QuoteTeamCreation('Created Successfully'));                
                }else{
                    Pricing_RestAPI_Util.quoteErrMsgsV2 = quoteErrors;
                    Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                    //response.errorContent.errorMessage = Label.Pricing_AE_Bulk_Insert_Error_Msg;
                }
            }
            else{
                if((actionType.toLowerCase() == 'submit' || actionType.toLowerCase() == 'create') && (!isSvdQuote || TriggerHandler.isActive('Pricing_SVD_Quote_Disabled'))){
                    Pricing_RestAPI_QuotesUtilityV2.QuoteWrapper quote = (Pricing_RestAPI_QuotesUtilityV2.QuoteWrapper) JSON.deserialize(reqBody, Pricing_RestAPI_QuotesUtilityV2.QuoteWrapper.class);
                    Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
                    Pricing_RestAPI_QuotesUtilityV2 quoteUtility = new Pricing_RestAPI_QuotesUtilityV2();
                    List<SBQQ__QuoteLine__c> qoteLines = new List<SBQQ__QuoteLine__c>();
                    List<Pricing_Performance_Metric__c> perfMetricsList = new List<Pricing_Performance_Metric__c>();
                    boolean isValid = quoteUtility.validateQuote(quote, quoteErrors, true);//validate Quote, Quote Line, Performance Metrics, and Quote Comments 
                    
                    if(isValid){
                        SBQQ__Quote__c newQuote = Pricing_RestAPI_QuotesUtilityV2.createQuoteRecord(quote.quoteDetails);
                        insert newQuote;
                        List<Pricing_Quote_Team__c> quoteTeamInsertList = new List<Pricing_Quote_Team__c>();
                        if(Pricing_RestAPI_QuotesUtilityV2.validFSEEmailIdMap.size() > 1){
                            List<Pricing_Quote_Team__c> fseQTM = Pricing_RestAPI_QuotesUtilityV2.createFSEQuoteTeam(newQuote.Id);
                            if(fseQTM.size() > 0){
                                //insert fseQTM;
                                quoteTeamInsertList.addAll(fseQTM);
                            }
                        }
                        if(Pricing_RestAPI_QuotesUtilityV2.AEEmailUserList.size() > 1){
                            List<Pricing_Quote_Team__c> aeQTM = Pricing_RestAPI_QuotesUtilityV2.createAEQuoteTeam(newQuote.Id);
                            if(aeQTM.size() > 0){
                                //insert aeQTM;
                                quoteTeamInsertList.addAll(aeQTM);
                            }
                        }
                        if(Pricing_RestAPI_QuotesUtilityV2.ITSEmailUserList.size() > 0){
                            List<Pricing_Quote_Team__c> itsQTM = Pricing_RestAPI_QuotesUtilityV2.createITSQuoteTeam(newQuote.Id);
                            if(itsQTM.size() > 0){
                                //insert itsQTM;
                                quoteTeamInsertList.addAll(itsQTM);
                            }
                        }
                        if(quoteTeamInsertList.size()>0){
                            Pricing_QuoteTeam_Trigger_Handler.isInertedFromQuoteTriggerorApi = true;
                            insert quoteTeamInsertList;
                        }
                        
                        Map<Id,SBQQ__QuoteLine__c> quoteLineIdMap;
                        Set<Id> qlIdSet = new Set<Id>();
                        if(quote.quoteDetails.quoteLines!=null){
                            qoteLines = Pricing_RestAPI_QuotesUtilityV2.createQuoteLineRecords(newQuote.Id, quote.quoteDetails.quoteLines);
                            if(qoteLines.size() > 0){
                                insert qoteLines;                            
                                for(SBQQ__QuoteLine__c ql:qoteLines){
                                    qlIdSet.add(ql.Id);
                                }
                                quoteLineIdMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT id, Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,
                                                                                Pricing_Program_Type_Nm__c,RecordTypeId,Pricing_Ready_for_Review_cb__c,Pricing_Original_Submitted_By_Id__c,
                                                                                Pricing_Original_Submitted_Date_dt__c,Pricing_Last_Submitted_Date_dt__c,Pricing_Last_Submitted_By_Id__c,src_sys_id__c
                                                                                FROM SBQQ__QuoteLine__c WHERE Id IN:qlIdSet]);
                                
                                integer i = 0;
                                for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineCPU qli : quote.quoteDetails.quoteLines.DataCenterCPU){
                                    if(qli.performanceMetrics!=null){
                                        Pricing_RestAPI_QuotesUtilityV2.createPerformanceMetricsRecord(qoteLines[i].id, qli.performanceMetrics, perfMetricsList);
                                    }
                                    i++;                        
                                }     
                            }  
                        }else{
                            qoteLines = null;
                        }
                        if(perfMetricsList.size() > 0) {
                            insert perfMetricsList;
                        }else{
                            perfMetricsList = null;
                        }
                        List<Pricing_Comments__c> qComments = Pricing_RestAPI_QuotesUtilityV2.createQuoteComments(newQuote.Id, quote.quoteDetails.quoteComments);
                        List<CreatedQuoteComments> commentDetails = new List<CreatedQuoteComments>();
                        if(qComments.size() > 0){
                            upsert qComments;
                            for(Pricing_Comments__c cmt: qComments){
                                commentDetails.add(new CreatedQuoteComments(cmt.Id, cmt.Pricing_Comment_Ref_Id__c));
                            }
                        }else{
                            commentDetails = null;
                        }
                        if(!Pricing_RestAPI_QuotesUtilityV2.isCreateDraftQuote ){
                            //US1104158
                            Pricing_RestAPI_QuotesUtilityV2.publishQuoteAndQuoteLines(newQuote.Id, quote.quoteDetails.primaryContactEmail, Pricing_RestAPI_QuotesUtilityV2.currentUser.AccountId,quoteLineIdMap,Pricing_RestAPI_QuotesUtilityV2.validFSEEmailIdMap,qlIdSet,'SBQQ__Quote__c');                                                 
                        }
                        else if(Pricing_RestAPI_QuotesUtilityV2.isCreateDraftQuote && (!String.isBlank(quote.quoteDetails.primaryContactEmail) && Pricing_RestAPI_QuotesUtilityV2.currentUser.Email != quote.quoteDetails.primaryContactEmail)){
                            //Primary contact is not the currunet user
                            changePrimaryContact(newQuote.Id, quote.quoteDetails.primaryContactEmail, Pricing_RestAPI_QuotesUtilityV2.currentUser.AccountId);
                        }
                        //creating response
                        Integer i = 0;
                        List<CreatedQuoteLineDetails> quotelineDetailsList = new List<CreatedQuoteLineDetails>();
                        if(quote.quoteDetails.quoteLines!=null){
                            Integer j = 0;
                            for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineCPU qli : quote.quoteDetails.quoteLines.DataCenterCPU){                           
                                List<CreatedPMDetails> pmDetailsList = new List<CreatedPMDetails>();
                                if(qli.performanceMetrics!=null){
                                    for(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics pm : qli.performanceMetrics){
                                        pmDetailsList.add(new CreatedPMDetails(perfMetricsList[j].Id, pm.performanceMetricsReferenceId));
                                        j++;
                                    }
                                }
                                if(pmDetailsList.size() == 0){
                                    pmDetailsList = null;
                                }
                                quotelineDetailsList.add(new CreatedQuoteLineDetails(qoteLines[i].Id,quoteLineIdMap.get(qoteLines[i].id).Pricing_Quote_Line_Number__c, qli.quotelineReferenceID, pmDetailsList));
                                i++;
                            }
                            for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineGPU qli : quote.quoteDetails.quoteLines.DataCenterGPU){                           
                                quotelineDetailsList.add(new CreatedQuoteLineDetails(qoteLines[i].Id,quoteLineIdMap.get(qoteLines[i].id).Pricing_Quote_Line_Number__c, qli.quotelineReferenceID, null));
                                i++;
                            }
                            for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineSSD qli : quote.quoteDetails.quoteLines.OptaneSSD){                           
                                quotelineDetailsList.add(new CreatedQuoteLineDetails(qoteLines[i].Id,quoteLineIdMap.get(qoteLines[i].id).Pricing_Quote_Line_Number__c, qli.quotelineReferenceID, null));
                                i++;
                            }
                            for(Pricing_RestAPI_QuotesUtilityV2.QuoteLinePMem qli : quote.quoteDetails.quoteLines.OptanePMem){                           
                                quotelineDetailsList.add(new CreatedQuoteLineDetails(qoteLines[i].Id,quoteLineIdMap.get(qoteLines[i].id).Pricing_Quote_Line_Number__c, qli.quotelineReferenceID, null));
                                i++;
                            }
                            for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineEthernet qli : quote.quoteDetails.quoteLines.Ethernet){                           
                                quotelineDetailsList.add(new CreatedQuoteLineDetails(qoteLines[i].Id,quoteLineIdMap.get(qoteLines[i].id).Pricing_Quote_Line_Number__c, qli.quotelineReferenceID, null));
                                i++;
                            }
                            for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineClient qli : quote.quoteDetails.quoteLines.Client){                           
                                quotelineDetailsList.add(new CreatedQuoteLineDetails(qoteLines[i].Id,quoteLineIdMap.get(qoteLines[i].id).Pricing_Quote_Line_Number__c, qli.quotelineReferenceID, null));
                                i++;
                            }
                        }
                        if(quotelineDetailsList.size()==0){
                            quotelineDetailsList = null;
                        }
                        SBQQ__Quote__c quoteNew = new SBQQ__Quote__c();
                        quoteNew = [Select id, Name, SBQQ__Status__c from SBQQ__Quote__c where id =:newQuote.Id];
                        response.totalRecords = 1;
                        response.successContent = new List<CreatedQuoteDetails>();
                        response.successContent.add(new CreatedQuoteDetails(String.valueOf(newQuote.Id),quoteNew.Name,quoteNew.SBQQ__Status__c, quote.quoteDetails.referenceRequestID, quotelineDetailsList, commentDetails));
                    }else {
                        Pricing_RestAPI_Util.quoteErrMsgsV2 = quoteErrors;
                        Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                    }
                }
                else{
                    Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                    response.errorContent.errorMessage = Label.Pricing_Tender_API_Quote_SVD_Submit_Error_Msg;
                }
            }
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);            
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response,Pricing_RestAPI_QuotesUtilityV2.currentUser);            
        }        
    }
    
    public static void getStatusDetails(Set<Id> quoteIds){        
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>([SELECT Id,Name, SBQQ__Status__c, Pricing_Customer_Reference_Id__c,(SELECT Id,Pricing_Quote_Line_Number__c, Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c,Pricing_Lost_Reason_Nm__c,src_sys_id__c FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c where Id IN :quoteIds and SBQQ__Account__c = :Pricing_RestAPI_QuotesUtilityV2.currentUser.AccountId]);
        response.successContent = new List<GetStatusQuoteDetails>();
        Integer recordCount = 0;
        for(Id quoteId: quoteIds){
            if(quoteMap.get(quoteId)!=null){
                recordCount++;
                List<GetStatusQuoteLineDetails> quotelineDetailsList = new List<GetStatusQuoteLineDetails>();
                if(quoteMap.get(quoteId).SBQQ__LineItems__r != null){
                    List<SBQQ__QuoteLine__c> quoteLineList = quoteMap.get(quoteId).SBQQ__LineItems__r;
                    for(SBQQ__QuoteLine__c quoteline: quoteLineList){
                        string qliType = quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_QuoteLine || quoteLine.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote ? Label.Pricing_RestAPI_Products_CPU_Param : 
                        quoteLine.Pricing_Program_Type_Nm__c  == Label.Pricing_Tender_SSD_Quote ? Label.Pricing_RestAPI_Products_SSD_Param :
                        quoteLine.Pricing_Program_Type_Nm__c  == Label.Pricing_Tender_PMem_Quote ? Label.Pricing_RestAPI_Products_PMem_Param : 
                        quoteLine.Pricing_Program_Type_Nm__c  == Label.Pricing_Tender_NIC_Quote ? Label.Pricing_RestAPI_Products_NIC_Param : Label.Pricing_RestAPI_Products_Client_Param ;
                        quotelineDetailsList.add(new GetStatusQuoteLineDetails(String.valueOf(quoteline.Id),quoteline.Pricing_Quote_Line_Number__c, quoteline.Pricing_Status_Nm__c,qliType,quoteline.Pricing_Lost_Reason_Nm__c));
                    }
                }else{
                    quotelineDetailsList = null;
                }
                response.successContent.add(new GetStatusQuoteDetails(String.valueOf(quoteId),quoteMap.get(quoteId).Name, quoteMap.get(quoteId).Pricing_Customer_Reference_Id__c,quoteMap.get(quoteId).SBQQ__Status__c, quotelineDetailsList));
            }
        }
        response.totalRecords = recordCount;        
    }
    
    @future
    public static void changePrimaryContact(Id recId, String primaryContactEmailId, Id accountId){
        try{   
            List<User> usrs = [SELECT id,ContactId FROM User WHERE Email = :primaryContactEmailId AND AccountId= :accountId];
            if(usrs.size() > 0){
                List<SBQQ__Quote__c> quotes = [SELECT Id,SBQQ__PrimaryContact__c FROM SBQQ__Quote__c WHERE Id= :recId] ;
                if(quotes.size() > 0){
                    quotes[0].SBQQ__PrimaryContact__c = usrs[0].ContactId;
                    update quotes[0];
                }
            }
        }catch(Exception exp){Pricing_Tender_Utility.logError(exp);}
    }
    
    /**
* @description Recall all quotelines for given quoteId which is in Pending Intel Field Review
* @author Sandeep | 05-11-2023 
**/
    public static void processRollBackRequest(String reqBody) {
        try {
            Pricing_RestAPI_QuotelinesV2.RecallRequest recallReq = String.isBlank(reqBody) ? new Pricing_RestAPI_QuotelinesV2.RecallRequest() : (Pricing_RestAPI_QuotelinesV2.RecallRequest) JSON.deserialize(reqBody, Pricing_RestAPI_QuotelinesV2.RecallRequest.class);
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            quoteMsg.quoteErrors = new Map<String, Pricing_RestAPI_QuotesUtilityV2.ErrorMsg>();
            //Pricing_RestAPI_QuotesUtilityV2 quoteUtility = new Pricing_RestAPI_QuotesUtilityV2();
            String quoteLineNumbers = '';
            Boolean isValid = true;
            
            if(quoteId != null){
                List<SBQQ__QuoteLine__c> rollBackQLIList = [SELECT Id,Pricing_Quote_Line_Number__c,Pricing_Last_Submitted_By_Id__c,Pricing_Status_Nm__c,Pricing_Ready_for_Review_cb__c,Customer_Revision_Count_Cnt__c,Pricing_Reference_Quote_Line_Nbr__c,SBQQ__Quote__c,Pricing_Program_Type_Nm__c,src_sys_id__c
                                                            FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId AND SBQQ__Quote__r.SBQQ__Account__c =: Pricing_RestAPI_QuotesUtilityV2.currentUser.AccountId];
                if(rollBackQLIList.size() > 0){
                    if(rollBackQLIList[0].Pricing_Program_Type_Nm__c!=Label.Pricing_Tender_Small_Volume_Quote || TriggerHandler.isActive('Pricing_SVD_Quote_Disabled')){
                        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
                        for(SBQQ__QuoteLine__c qli: rollBackQLIList){
                            if(qli.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview && qli.Pricing_Reference_Quote_Line_Nbr__c == null){
                            quoteLineList.add(qli);
                            }
                        }
                        if(!String.isBlank(recallReq.comment) && recallReq.comment.length()>8000){
                        Pricing_RestAPI_QuotesUtilityV2.addValidationError(quoteMsg.quoteErrors, 'comment', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1019, new Map<String,String>{'{{dataMaxLimit}}'=> '8000'});
                        isValid = false;
                        }
                        if(quoteLineList.size() == 0){
                        Pricing_RestAPI_QuotesUtilityV2.addValidationError(quoteMsg.quoteErrors, 'quote', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1085, null);
                        isValid = false;
                        }
                        if(isValid){
                            
                            Pricing_BulkSalesRepActionController.recordApproval(quoteLineList, Label.Pricing_Tender_QuoteLine_Action_Rollback, null, false);
                            String res = 'Recall successful.';
                            List<QuoteLineMsg> qliList = new List<QuoteLineMsg>();
                            for(SBQQ__QuoteLine__c qli: quoteLineList){
                                qliList.add(new QuoteLineMsg(qli.Id, res, qli.Pricing_Status_Nm__c, qli.Pricing_Quote_Line_Number__c));
                                quoteLineNumbers += qli.Pricing_Quote_Line_Number__c + ',';
                            }
                            quoteLineNumbers = quoteLineNumbers.removeEnd(',') + '.';
                            
                            // creating a chatter post for the quote
                            FeedItem post = new FeedItem();
                            post.Body = String.isBlank(recallReq.comment) ? UserInfo.getName() + ' recalled ' + quoteLineNumbers : recallReq.comment;
                            post.ParentId = quoteLineList[0].SBQQ__Quote__c;
                            post.Visibility = 'AllUsers';
                            insert post;
                            
                            response.totalRecords = qliList.size();
                            response.successContent = new List<RollBackDetails>();
                            response.successContent.add(new RollBackDetails(qliList));
                        }
                        else{
                        Pricing_RestAPI_Util.quoteErrMsgsV2 = quoteMsg;
                        Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                        }
                    }else{
                            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                            response.errorContent.errorMessage = Label.Pricing_Tender_API_Quote_SVD_Recall_Error_Msg; 
                        }
                }
                else{
                    Pricing_RestAPI_QuotesUtilityV2.addValidationError(quoteMsg.quoteErrors, 'quote', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, null);
                    Pricing_RestAPI_Util.quoteErrMsgsV2 = quoteMsg;
                    Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                }
            }
            else{
                Pricing_RestAPI_QuotesUtilityV2.addValidationError(quoteMsg.quoteErrors, 'quote', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1007, null);
                Pricing_RestAPI_Util.quoteErrMsgsV2 = quoteMsg;
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }
            
        }catch(Exception exp) {
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200;
            }
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response,Pricing_RestAPI_QuotesUtilityV2.currentUser);
        }
    }
    
    /**
* @description Wrapper Class for Recall Success Response
* @author Sandeep | 06-15-2023 
**/
    public class RollBackDetails implements Pricing_RestAPI_SuccessContent {
        public List<QuoteLineMsg> quoteLines {set;get;} 
        public RollBackDetails(List<QuoteLineMsg> quotelineList){
            quoteLines = quotelineList;
        }
    }
    
    /**
* @description Wrapper Class for Recall Success Response
* @author Sandeep | 06-15-2023 
**/
    public class QuoteLineMsg {
        String quoteLineId {set;get;}
        String message {set;get;}
        String status {set;get;}
        String quoteLineNumber {set;get;}
        public QuoteLineMsg(String qliId, String successMsg, String qliStatus, String qliNumber){
            message = successMsg;
            quoteLineId = qliId;
            status = qliStatus;
            quoteLineNumber = qliNumber;
        }
    }
    
    public class CreatedQuoteDetails implements Pricing_RestAPI_SuccessContent {
        public String quoteId {set;get;} 
        public String quoteNumber {set;get;}
        public String quoteStatus {set;get;}
        public String referenceRequestID {set;get;}
        public List<CreatedQuoteLineDetails> quoteLineDetails {set;get;}
        public List<CreatedQuoteComments> commentDetails {set;get;}
        public CreatedQuoteDetails(String recId, String qNumber, String qStatus, String referenceId, List<CreatedQuoteLineDetails> quotelines, List<CreatedQuoteComments> comment){
            quoteId = recId;
            quoteNumber = qNumber;
            quoteStatus = qStatus;
            referenceRequestID = referenceId;
            quoteLineDetails = quotelines;
            commentDetails = comment;
        }
    }
    
    public class CreatedQuoteLineDetails {
        public String quoteLineId {set;get;} 
        public String quoteLineNumber {set;get;}
        public String quotelineReferenceID {set;get;}
        public List<CreatedPMDetails> performanceMetricsDetails {set;get;}
        public CreatedQuoteLineDetails(String recId,String qlNumber, String referenceId, List<CreatedPMDetails> pms){
            quoteLineId = recId;
            quoteLineNumber = qlNumber;
            quotelineReferenceID = referenceId;
            performanceMetricsDetails = pms;
        }
    }
    
    public class CreatedPMDetails {
        public String performanceMetricsId {set;get;} 
        public String performanceMetricsReferenceId {set;get;}
        public CreatedPMDetails(String recId, String referenceId){
            performanceMetricsId = recId;
            performanceMetricsReferenceId = referenceId;
        }
    }
    
    public class CreatedQuoteComments {
        public String quoteCommentReferenceId {set;get;}
        public String quoteCommentId {set;get;}
        public CreatedQuoteComments(String recId, String referenceId){
            quoteCommentId = recId;
            quoteCommentReferenceId = referenceId;
        }
    }
    
    public class GetStatusQuoteDetails implements Pricing_RestAPI_SuccessContent {
        public String quoteId {set;get;} 
        public String quoteNumber {set;get;}
        public String quoteStatus {set;get;}
        public String referenceRequestID {set;get;}
        public List<GetStatusQuoteLineDetails> quoteLineDetails {set;get;}
        public GetStatusQuoteDetails(String recId,String qNumber, String referenceId, String qStatus, List<GetStatusQuoteLineDetails> quotelines){
            quoteId = recId;
            quoteNumber = qNumber;
            quoteStatus = qStatus;
            referenceRequestID = referenceId;
            quoteLineDetails = quotelines;
        }
    }
    
    public class GetStatusQuoteLineDetails {
        public String quoteLineId {set;get;} 
        public String quoteLineNumber {set;get;}
        public String quotelineStatus {set;get;}
        public String quotelineType {set;get;}
        public String lostReason {set;get;}
        public GetStatusQuoteLineDetails(String recId, String qlNumber, String status, String qliType,String lostReasonVal){
            quoteLineId = recId;
            quoteLineNumber = qlNumber;
            quotelineStatus = status;
            quotelineType = qliType;
            lostReason = lostReasonVal;
        }
    }
    
    public class QuoteTeamCreation implements Pricing_RestAPI_SuccessContent {
        public String record {set;get;}
        public QuoteTeamCreation(String msg){
            record = msg;
        }
    }    

    //success content Wrapper for QuoteDetails where lastModified Date in N days.
    public class GetQuoteDetailsModifyInnDays implements Pricing_RestAPI_SuccessContent {
        public String quoteId {set;get;} 
        public String quoteNumber {set;get;}
        public String referenceRequestID {set;get;}
        public String LastModifiedById {set;get;}
        public Datetime lastModifiedDate {set;get;}

        public GetQuoteDetailsModifyInnDays(String recId,String qNumber, String referenceId, String lastModifyById, Datetime lastModifyDate){
            quoteId = recId;
            quoteNumber = qNumber;
            referenceRequestID = referenceId;
            LastModifiedById = lastModifyById;
            lastModifiedDate = lastModifyDate;
        }
    }

    //Success Wrapper for updating Contact and Sales Rep Details. 
    public class updateQuotePrimaryContactDetails implements Pricing_RestAPI_SuccessContent {
        public String quoteId {set;get;} 
        public String quoteNumber {set;get;}
        public String referenceRequestID {set;get;}
        public updateQuotePrimaryContactDetails(String recId, String qNumber, String referenceId){
            quoteId = recId;
            quoteNumber = qNumber;
            referenceRequestID = referenceId;
        }
    }
    
    //-----------------------------------------------------------------------------------------------------------------
    
    @HttpGet
    global static Pricing_RestAPI_Response doGet(){
        if(validateRequest()){
            //Valid Request
            if(type.toLowerCase() == 'quoteletter'){
                getQuoteLetter();
            }
            else if(type.toLowerCase() == 'isvalidprimarycontact') {
                getPrimaryContactDetails();
            }
            else if(isClient){
                getAllDetailsClient();
            }
            else if(!String.isBlank(days)){
                getQuoteDtlsModifyInnDays();
            }
            else{
                getAllDetails();
            }
        }else{
            //Not a Valid Request
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }
    
    //validating QuoteLineId and type
    private static boolean validateRequest(){
        boolean isValid=false;
        RestRequest restReq = RestContext.request;
        type = String.isBlank(restReq.params.get('type')) ? 'all' : restReq.params.get('type').toLowerCase();
        recId = restReq.params.get('id');
        quoteName = String.isBlank(restReq.params.get('quotename')) ? restReq.params.get('quoteName') : restReq.params.get('quotename');
        primaryContactEmail = restReq.params.get('email');  
        days =  restReq.params.get('days');
        user currentUser = [Select Id, ContactId,AccountId from User where Id = :UserInfo.getUserId()];
        try{                             
            if((!String.isBlank(recId) || !String.isBlank(quoteName)) && (String.isBlank(type) || type.toLowerCase() == 'all' || type.toLowerCase() == 'quote' || type.toLowerCase() == 'quoteletter')){
                try{
                    if(!String.isBlank(recId)) {
                        quoteId = Id.valueOf(recId);
                    }
                    SBQQ__Quote__c quote = !String.isBlank(recId) ? [Select Id, SBQQ__Account__c,Pricing_Program_Type_Nm__c from SBQQ__Quote__c where id = :quoteId and SBQQ__Account__c = :currentUser.AccountId Limit 1] 
                        : [Select Id, SBQQ__Account__c,Pricing_Program_Type_Nm__c from SBQQ__Quote__c where name = :quoteName and SBQQ__Account__c = :currentUser.AccountId Limit 1];
                            quoteId = quote.Id;
                    isClient = (quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_CCG_Quote)?true:false;
                    isValid=true;
                }catch(Exception  exp){
                    isValid=false;
                }
            }
            else if(String.isBlank(recId) && (type.toLowerCase() == 'getsvdquota' || type.toLowerCase() == 'getexceptionquota')){
                isValid = true;
            }
            else if((!String.isBlank(recId) || !String.isBlank(quoteName)) && type.toLowerCase() == 'quoteletter'){
                isValid = true;
            }
            else if(!String.isBlank(primaryContactEmail) && type.toLowerCase() == 'isvalidprimarycontact'){
                isValid = true;
            }
            else if(!String.isBlank(days)){
                isValid = true;
            }
            else{
                isValid = false;
            }
            if(!isValid){
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);  
            }
            
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response,currentUser);            
        } 
        return isValid;
    }

    /**
    * @description :Method to get Quote Details where modified Date in N Days.
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 09-17-2024 
    **/
    public static void getQuoteDtlsModifyInnDays() {
        Integer n = Integer.valueOf(days);

       if(n >= 0 && n <= 180){ 
            response.successContent = new List<GetQuoteDetailsModifyInnDays>();    
            String currentUserAccountId = [Select Id, AccountId from User where Id = :UserInfo.getUserId()].AccountId;
            String query = 'SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name,LastModifiedById, Pricing_Customer_Reference_Id__c ' + 
                           'FROM SBQQ__Quote__c WHERE SBQQ__Account__c = :currentUserAccountId AND LastModifiedDate = LAST_N_DAYS:' + n +' order by LastModifiedDate desc';
               
            List<SBQQ__Quote__c> quotesList = Database.query(query);
            if(quotesList.size() > 0){
                for(SBQQ__Quote__c quote : quotesList){
                    response.totalRecords = quotesList.size();
                    response.successContent.add(new GetQuoteDetailsModifyInnDays(String.valueOf(quote.Id),quote.Name,quote.Pricing_Customer_Reference_Id__c,quote.LastModifiedById,quote.LastModifiedDate));
                }
            }
            else{
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.NO_DATA_EXCEPTION_9001, response, RESTAPI_NAME, ENTRY_TIME);
            }
        }else {
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.NO_DATA_EXCEPTION_9001, response, RESTAPI_NAME, ENTRY_TIME);
        }

    }
    
    /**
* @description get all details for creating the response
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
**/
    public static void getAllDetails(){        
        if(type != null && type.toLowerCase() == 'getsvdquota'){
            response = getSVDQuotaDetails();
        }
        else if(type != null && type.toLowerCase() == 'getexceptionquota'){
            response = getDataCenterAndClientQuotaDetails();
        }
        else{
            SBQQ__Quote__c quotes = getAllQuoteDetails();
            if(quotes != null){
                quoteWrapper.quoteDetails = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteDetails();
                
                //for type = all or empty : get all four sections
                if(String.isEmpty(type) || type.toLowerCase() == 'all'){
                    quoteWrapper.quoteDetails.quoteLines = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLines();
                    quoteWrapper.quoteDetails.quoteLines.DataCenterCPU = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineCPU>();
                    quoteWrapper.quoteDetails.quoteLines.OptaneSSD= new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineSSD>();
                    quoteWrapper.quoteDetails.quoteLines.OptanePMem= new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLinePMem>();
                    quoteWrapper.quoteDetails.quoteLines.Ethernet = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineEthernet>();
                    quoteWrapper.quoteDetails.quoteLines.DataCenterGPU = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineGPU>();
                    getQuoteDetails(quotes, quoteWrapper.quoteDetails);
                    for(String qliType : qliTypeToQli.keySet()){
                        if(qliType == Label.Pricing_Tender_SSD_Quote ){
                            getQuoteLineDetailsSSD(quoteWrapper.quoteDetails,qliTypeToQli.get(qliType));
                        }
                        else if(qliType == Label.Pricing_Tender_PMem_Quote ){
                            getQuoteLineDetailsPMem(quoteWrapper.quoteDetails,qliTypeToQli.get(qliType));
                        }
                        else if(qliType == Label.Pricing_Tender_NIC_Quote ){
                            getQuoteLineDetailsNIC(quoteWrapper.quoteDetails,qliTypeToQli.get(qliType));
                        }
                        else if(qliType == Label.Pricing_Tender_DataCenter_GPU){
                            getQuoteLineDetailsGPU(quoteWrapper.quoteDetails,qliTypeToQli.get(qliType));
                        }
                        else {
                            getQuoteLineDetails(quoteWrapper.quoteDetails,qliTypeToQli.get(qliType));
                        }
                    }
                    getQuoteComments(quoteWrapper.quoteDetails, quotes.Comments__r );
                    
                    //for type = quote : get quote details only 
                }
                else if(type.toLowerCase() == 'quote'){
                    getQuoteDetails(quotes, quoteWrapper.quoteDetails);        
                }
                
                response.successContent = new List<QuoteWrapper>();
                response.successContent.add(quoteWrapper);
                response.totalRecords= 1;
            }       
            else{
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }
        }
    }
    
    public static Pricing_RestAPI_Response getSVDQuotaDetails(){
        Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
        //String currentUserAccountId = [Select Id, AccountId from User where Id = :UserInfo.getUserId()].AccountId;
        Pricing_RestAPI_QuotesUtilityV2 util = new Pricing_RestAPI_QuotesUtilityV2();
        Boolean isValid=util.validateSVDQuota(quoteErrors);
        
        if(isValid){
            List<String> capDetails = Pricing_Manage_Small_Volume_Deal.capSizeCheck(Pricing_RestAPI_QuotesUtilityV2.currentUser.AccountId).split(':');
            List<String> dateDetails = Pricing_RestAPI_QuotesUtilityV2.quarterStartEndDate().split(':');
            if(!capDetails.isEmpty()){
                response.successContent = new List<svdQuotaDetailsWrapper>();
                response.successContent.add(new svdQuotaDetailsWrapper(capDetails[1],capDetails[2],dateDetails[0],dateDetails[1]));
                response.totalRecords= 1;
            }
        }
        else{
            Pricing_RestAPI_Util.quoteErrMsgsV2 = quoteErrors;
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }

    public static Pricing_RestAPI_Response getDataCenterAndClientQuotaDetails(){
        Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
        Pricing_RestAPI_QuotesUtilityV2 util = new Pricing_RestAPI_QuotesUtilityV2();
        Boolean isValid=util.validateSVDQuota(quoteErrors);
        if(isValid){
           
            Map<String,String> capDetails = Pricing_Manage_Small_Volume_Deal.capSizeCheckToCreation(new Set<String>{Pricing_RestAPI_QuotesUtilityV2.currentUser.AccountId},true);
            List<String> dateDetails = Pricing_RestAPI_QuotesUtilityV2.quarterStartEndDate().split(':');
            if(!capDetails.isEmpty()){
                DataCenterQuotaWrapper dataCenterQuota;
                ClientQuotaWrapper clientQuota;
                String dataCenterRemQuota;
                String clientRemQuota;
                if(capDetails.containsKey(Label.Pricing_Tender_Standard_Quote)){
                    dataCenterRemQuota = (Integer.valueOf(capDetails.get(Label.Pricing_Tender_Standard_Quote).split(':')[2]) < 0)?'0':capDetails.get(Label.Pricing_Tender_Standard_Quote).split(':')[2];
                    dataCenterQuota = new DataCenterQuotaWrapper(capDetails.get(Label.Pricing_Tender_Standard_Quote).split(':')[1],dataCenterRemQuota,dateDetails[0],dateDetails[1]);
                }
                if(capDetails.containsKey(Label.Pricing_Tender_CCG_Quote)){
                    clientRemQuota = (Integer.valueOf(capDetails.get(Label.Pricing_Tender_CCG_Quote).split(':')[2]) < 0)?'0':capDetails.get(Label.Pricing_Tender_CCG_Quote).split(':')[2];
                    clientQuota = new ClientQuotaWrapper(capDetails.get(Label.Pricing_Tender_CCG_Quote).split(':')[1],clientRemQuota,dateDetails[0],dateDetails[1]);
                }
                response.successContent = new List<DataCenterAndClientQuotaDetailsWrapper>();
                response.successContent.add(new DataCenterAndClientQuotaDetailsWrapper(dataCenterQuota,clientQuota));
                response.totalRecords= 1;
            }
        }
        else{
            Pricing_RestAPI_Util.quoteErrMsgsV2 = quoteErrors;
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }
    
    /**
* @description Method written to retrieve the Client Quote, Quote Line and Quote Comments details to form the response
* @author Bharath Chandrashekar | 06-17-2022
**/
    public static void getAllDetailsClient(){        
        SBQQ__Quote__c quotes = getAllQuoteDetailsClient();
        if(quotes != null){
            quoteWrapperClient.quoteDetailsClient = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteDetailsClient();
            
            //for type = all or empty : get all four sections
            if(String.isEmpty(type) || type.toLowerCase() == 'all'){
                quoteWrapperClient.quoteDetailsClient.quoteLinesClient = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLinesClient();
                quoteWrapperClient.quoteDetailsClient.quoteLinesClient.Client = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineClient>();
                getQuoteDetailsClient(quotes, quoteWrapperClient.quoteDetailsClient);
                for(String qliType : qliTypeToQli.keySet()){
                    getQuoteLineDetailsClient(quoteWrapperClient.quoteDetailsClient,qliTypeToQli.get(qliType));
                }
                getQuoteCommentsClient(quoteWrapperClient.quoteDetailsClient, quotes.Comments__r);
                
                //for type = quote : get quote details only 
            }
            else if(type.toLowerCase() == 'quote'){
                getQuoteDetailsClient(quotes, quoteWrapperClient.quoteDetailsClient);        
            }
            
            response.successContent = new List<QuoteWrapperClient>();
            response.successContent.add(quoteWrapperClient);
            response.totalRecords= 1;
        }
        else{
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
    }
    
    /**
* @description retive the quote deatils to form the response
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @return SBQQ__Quote__c 
**/
    public static SBQQ__Quote__c getAllQuoteDetails(){
        SBQQ__Quote__c quotes = new SBQQ__Quote__c();
        //for type = empty or all : query all four sections
        if(String.isEmpty(type) || type.toLowerCase() == 'all'){
            quotes = Database.query(Label.Pricing_RestAPI_QuoteQuery + Label.Pricing_RestAPI_GetQuoteV2QLIQuery1  + Label.Pricing_RestAPI_GetQuoteV2QLIQuery2 + Label.Pricing_RestAPI_GetQuoteV2QLIQuery4 + Label.Pricing_RestAPI_GetQuoteV2QLIQuery3 + Label.Pricing_RestAPI_QuoteComments);
        }            
        //for type = quote : query section 1
        else if(type.toLowerCase() == 'quote'){
            quotes = Database.query(Label.Pricing_RestAPI_GetQuoteQuery);
        }
        Set<Id> quoteLineIds = new Set<Id>();
        for(SBQQ__QuoteLine__c qli :quotes.SBQQ__LineItems__r){
            quoteLineIds.add(qli.Id);
            if(qliTypeToQli.containsKey(qli.Pricing_Program_Type_Nm__c)) {
                qliTypeToQli.get(qli.Pricing_Program_Type_Nm__c).add(qli); 
            } 
            else {
                qliTypeToQli.put(qli.Pricing_Program_Type_Nm__c,new List<SBQQ__QuoteLine__c>{qli});
            }
        }
        
        if(quoteLineIds.size() > 0){
            List<Pricing_Performance_Metric__c> pmetrics= Database.query(Label.Pricing_RestAPI_PerfMetricsQuery);
            for(Pricing_Performance_Metric__c pm : pmetrics){
                if(pmMap.containsKey(pm.Pricing_Quote_Line__r.id)){
                    pmMap.get(pm.Pricing_Quote_Line__r.id).add(pm);
                }else{
                    pmMap.put(pm.Pricing_Quote_Line__r.id, new List<Pricing_Performance_Metric__c>{pm});
                }
            }
        }
        
        return quotes;
    }
    
    /**
* @description Method that returns the Client Quote Details to form the Response
* @author Bharath Chandrashekar | 06-17-2022 
* @return SBQQ__Quote__c 
**/
    public static SBQQ__Quote__c getAllQuoteDetailsClient(){
        SBQQ__Quote__c quotes = new SBQQ__Quote__c();
        //for type = empty or all : query all four sections
        if(String.isEmpty(type) || type.toLowerCase() == 'all'){
            quotes = Database.query(Label.Pricing_RestAPI_QuoteQuery + Label.Pricing_RestAPI_GetQuoteV2QLIQuery1  + Label.Pricing_RestAPI_GetQuoteV2QLIQuery2 + Label.Pricing_RestAPI_GetQuoteV2QLIQuery4  + Label.Pricing_RestAPI_GetQuoteV2QLIQuery3 + Label.Pricing_RestAPI_QuoteComments);
        }            
        //for type = quote : query section 1
        else if(type.toLowerCase() == 'quote'){
            quotes = Database.query(Label.Pricing_RestAPI_GetQuoteQuery);
        }
        
        Set<Id> quoteLineIds = new Set<Id>();
        for(SBQQ__QuoteLine__c qli :quotes.SBQQ__LineItems__r){
            quoteLineIds.add(qli.Id);
            if(qliTypeToQli.containsKey(qli.Pricing_Program_Type_Nm__c)) {
                qliTypeToQli.get(qli.Pricing_Program_Type_Nm__c).add(qli);   
            } 
            else {
                qliTypeToQli.put(qli.Pricing_Program_Type_Nm__c,new List<SBQQ__QuoteLine__c>{qli});
            }
        }
        
        return quotes;
    }
    
    //getting quoteDetails
    public static void getQuoteDetails(SBQQ__Quote__c quote, Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteDetails qDetails){
        
        qDetails.quoteId=quote.Id;
        qDetails.quoteName = quote.Name;
        qDetails.endCustomer= quote.Pricing_Customer_Nm__c;
        qDetails.unifiedEndCustomer= quote.Pricing_End_Customer__r.Name;
        qDetails.unifiedEndCustomerId= quote.Pricing_End_Customer__r.Id;
        qDetails.endCustomerCountry= quote.Pricing_End_Customer_Country_Nm__c;
        qDetails.endCustomerRegion = quote.Pricing_Region_Nm__c;
        qDetails.projectName = quote.Pricing_Project_Name_Nm__c;
        qDetails.application = quote.Pricing_Server_Deal_Type_Nm__c;
        qDetails.proposalDueDate = quote.Pricing_Bid_Dt__c; 
        qDetails.intelResponseRequestedDate = quote.Pricing_Intel_Response_Requested_By_Date__c; 
        qDetails.pricingStartDate = quote.Pricing_ShipmentStDate_Dt__c;
        qDetails.pricingEndDate = quote.Pricing_ShipmentEndDate_Dt__c;
        qDetails.intelSalesRepEmail = quote.Pricing_Intel_Sales_Rep_Email_Txt__c;
        qDetails.intelAccountExecutiveEmail = quote.Pricing_Intel_Account_Exec_Email_Txt__c;
        qDetails.primaryContactName = quote.SBQQ__PrimaryContact__r.Name;
        qDetails.referenceRequestID = quote.Pricing_Customer_Reference_Id__c;
        qDetails.secondaryContact = quote.Pricing_SecondaryContact_Nm__c;
        qDetails.quoteType = quote.Pricing_Program_Type_Nm__c;
        qDetails.quoteStatus = quote.SBQQ__Status__c;
        qDetails.additionalQuoteLetterRecipients= quote.Pricing_AdditionalRecipients__c;
        qDetails.partnerName = quote.Pricing_Partner_Name_Nm__c;
        qDetails.volumeExceptionQuote = quote.Pricing_Volume_Exception_Quota_Cb__c;
        qDetails.endCustomerUrl = quote.Pricing_End_Customer_URL__c;
       
    }
    
    
    /**
* @description Method to get the Quote details and assign the quote field values to the wrapper properties
* @author Bharath Chandrashekar | 06-17-2022 
* @param quote
* @param qDetailsClient 
**/
    public static void getQuoteDetailsClient(SBQQ__Quote__c quote, Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteDetailsClient qDetailsClient){
        
        qDetailsClient.quoteId=quote.Id;
        qDetailsClient.quoteName = quote.Name;
        qDetailsClient.endCustomer= quote.Pricing_Customer_Nm__c;
        qDetailsClient.unifiedEndCustomer= quote.Pricing_End_Customer__r.Name;
        qDetailsClient.unifiedEndCustomerId= quote.Pricing_End_Customer__r.Id;
        qDetailsClient.endCustomerCountry= quote.Pricing_End_Customer_Country_Nm__c;
        qDetailsClient.endCustomerRegion = quote.Pricing_Region_Nm__c;
        qDetailsClient.projectName = quote.Pricing_Project_Name_Nm__c;
        qDetailsClient.proposalDueDate = quote.Pricing_Bid_Dt__c;
        qDetailsClient.marketSegment = quote.Pricing_Market_Segment_values_Nm__c;
        qDetailsClient.intelResponseRequestedDate = quote.Pricing_Intel_Response_Requested_By_Date__c; 
        qDetailsClient.pricingStartDate = quote.Pricing_ShipmentStDate_Dt__c;
        qDetailsClient.pricingEndDate = quote.Pricing_ShipmentEndDate_Dt__c;
        qDetailsClient.intelSalesRepEmail = quote.Pricing_Intel_Sales_Rep_Email_Txt__c;
        qDetailsClient.intelAccountExecutiveEmail = quote.Pricing_Intel_Account_Exec_Email_Txt__c;
        qDetailsClient.primaryContactName = quote.SBQQ__PrimaryContact__r.Name;
        qDetailsClient.referenceRequestID = quote.Pricing_Customer_Reference_Id__c;
        qDetailsClient.secondaryContact = quote.Pricing_SecondaryContact_Nm__c;
        qDetailsClient.quoteType = quote.Pricing_Program_Type_Nm__c;
        qDetailsClient.quoteStatus = quote.SBQQ__Status__c;
        qDetailsClient.additionalQuoteLetterRecipients= quote.Pricing_AdditionalRecipients__c;
        qDetailsClient.partnerName = quote.Pricing_Partner_Name_Nm__c;
        qDetailsClient.volumeExceptionQuote = quote.Pricing_Volume_Exception_Quota_Cb__c;
        qDetailsClient.endCustomerUrl = quote.Pricing_End_Customer_URL__c;
    }
    
    public static void getQuoteComments(Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteDetails qDetails, List<Pricing_Comments__c> quoteComments){
        qDetails.quoteComments = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteComments>();
        for(Pricing_Comments__c comm : quoteComments){
            Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteComments qComment = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteComments();
            qComment.question=comm.Pricing_Question__c;
            qComment.answer=comm.Pricing_Answer__c;
            qComment.quoteCommentReferenceId = comm.Pricing_Comment_Ref_Id__c;
            qDetails.quoteComments.add(qComment); 
        }
    }
    
    /**
* @description Method to get the Client Quote Comments
* @author Bharath Chandrashekar | 06-17-2022 
* @param qDetailsClient 
* @param quoteComments 
**/
    public static void getQuoteCommentsClient(Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteDetailsClient qDetailsClient, List<Pricing_Comments__c> quoteComments){
        qDetailsClient.quoteComments = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteComments>();
        for(Pricing_Comments__c comm : quoteComments){
            Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteComments qComment = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteComments();
            qComment.question=comm.Pricing_Question__c;
            qComment.answer=comm.Pricing_Answer__c;
            qComment.quoteCommentReferenceId = comm.Pricing_Comment_Ref_Id__c;
            qDetailsClient.quoteComments.add(qComment);
        }
    }
    
    /**
* @description getting quoteline deatils based on quote line type
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @param qDetails 
* @param quoteLines 
**/
    public static void getQuoteLineDetails(Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteDetails qDetails, List<SBQQ__QuoteLine__c> quoteLines){   
        
        for(SBQQ__QuoteLine__c qli : quoteLines){
            Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineCPU qliWrapper = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineCPU();
            qliWrapper.quoteLineId = qli.id;
            qliWrapper.quoteId = qli.SBQQ__Quote__c;
            qliWrapper.quote = qli.SBQQ__Quote__r.Name;
            qliWrapper.quoteLineType = Label.Pricing_RestAPI_Products_CPU_Param ;
            qliWrapper.quoteLineNumber=qli.Pricing_Quote_Line_Number__c;
            qliWrapper.quoteLineStatus=qli.Pricing_Status_Nm__c;
            qliWrapper.changeRequest = qli.Pricing_New_Change_Request_cb__c;//Pricing_Change_Request_cb__c
            qliWrapper.approvedPricingStartDate= qli.Pricing_Approved_Start_Date_Dup_Dt__c;
            qliWrapper.approvedPricingEndDate=qli.Pricing_Approved_End_Date_Dup_Dt__c;
            qliWrapper.approvedQuantity = qli.Pricing_Approved_Unit_Dup_Qty__c;
            qliWrapper.effectivePricingStartDate = qli.Pricing_Revised_Pricing_Start_Date_D_dt__c; 
            qliWrapper.billingEndDate = qli.Pricing_Billing_End_Date_Dt__c;
            qliWrapper.billingStartDate = qli.Pricing_Billing_Start_Date_Dt__c;
            qliWrapper.additionalTermsandConditions = qli.Pricing_Additional_T_C_s_Txt__c;
            qliWrapper.newRequestedPrice = qli.Pricing_Request_Discount_Unit_Price_qty__c;
            qliWrapper.competitiveBidDiscount = qli.Pricing_Competitive_Bid_Discount_Pct__c;
            qliWrapper.approvedECAPPrice = qli.Pricing_ECAP_Price_Dup_Amt__c;
            qliWrapper.dealId = qli.Pricing_Deal_RFQ_Dup_Id__c;
            qliWrapper.newQuantity = qli.Pricing_New_Quantity_qty__c;
            qliWrapper.readyForReview= qli.Pricing_Ready_for_Review_cb__c;
            qliWrapper.lastSubmittedDate = qli.Pricing_Last_Submitted_Date_dt__c;
            qliWrapper.firstSubmittedDate = qli.Pricing_Original_Submitted_Date_dt__c;
            qliWrapper.approvedDate = qli.Pricing_Last_Approved_Date_dt__c;
            qliWrapper.lastSubmittedById = qli.Pricing_Last_Submitted_By_Id__c;
            qliWrapper.lastSubmittedByName = qli.Pricing_Last_Submitted_By_Id__r.Name;
            qliWrapper.quoteLinePricingEndDate = qli.Pricing_End_Date_dt__c;
            qliWrapper.quoteLinePricingStartDate = qli.Pricing_Start_Date_dt__c;
            qliWrapper.productId=qli.Pricing_Product_Nm__c;
            qliWrapper.productName = qli.SBQQ__ProductName__c;
            qliWrapper.processorNumber = qli.Pricing_Processor_Number_Nm__c;
            qliWrapper.quantity = qli.Pricing_Unit_Qty__c;
            qliWrapper.payableQuantity = qli.Pricing_Payable_Quantity__c;
            qliWrapper.writeInProduct=qli.Pricing_Other_Product_Nm__c;
            qliWrapper.systemModel=qli.Pricing_OEM_System_Model_Nm__c;
            qliWrapper.noOfSystems=qli.Pricing_Systems_qty__c;
            qliWrapper.noOfCPUsPerSystem = qli.Pricing_CPUs_per_system_qty__c;
            qliWrapper.singleSystemPricePoint = qli.Pricing_Single_System_Price_Amt__c;
            qliWrapper.customerStdUnitPrice=qli.Pricing_OEM_Standard_Unit_Price_Amt__c;
            qliWrapper.quotelineprogramtype=qli.Pricing_Program_Type_Nm__c;
            qliWrapper.requestedUnitPrice=qli.Pricing_Req_Discounted_Unit_Price__c;
            qliWrapper.totalBidWithoutDiscount= qli.Pricing_Total_Bid_without_Discount_Amt__c;
            qliWrapper.netIntelBidPrice = qli.Pricing_Net_IA_Bid_Price_Amt__c;
            qliWrapper.intelDiscount = qli.Pricing_Intel_Discount_Pct__c;
            qliWrapper.customerDiscount = qli.Pricing_OEM_Discount_Pct__c;
            qliWrapper.totalIntelDiscount =qli.Pricing_Total_Intel_Discount_Amt__c;
            qliWrapper.intelBidDiscount = qli.Pricing_IA_Bid_Discount_Pct__c;
            qliWrapper.additionalDiscount=qli.Pricing_Additional_OEM_Discount_Amt__c;
            qliWrapper.competitorName=qli.Pricing_Competitor_OEM_Nm__c;
            qliWrapper.competitorSystemModel=qli.Pricing_Competitor_System_Model_Nm__c;
            qliWrapper.competitorProductId=qli.Pricing_Competetor_Product__c;
            qliWrapper.competitorProductName = qli.Pricing_Competetor_Product__r.Name;
            qliWrapper.writeInCompetitorProduct=qli.Pricing_Other_Competitor_Product_Nm__c;
            qliWrapper.competitorProductProvider = qli.Pricing_comp_Product_Provider_nm__c;
            qliWrapper.competitorNoOfSystems = qli.Pricing_Competitor_Systems_Cnt__c;
            qliWrapper.competitorNoOfCPUsPerSystem = qli.Pricing_Comp_CPUs_per_system_Cnt__c;
            qliWrapper.competitorQuantity= qli.Pricing_Comp_Units_Cnt__c;
            qliWrapper.competitorSingleSystemPrice = qli.Pricing_Comp_Single_System_Price_Amt__c;
            qliWrapper.competitorAdditionalDiscount = qli.Pricing_Comp_Additional_OEM_Disc_Amt__c;
            qliWrapper.competitorTotalWithoutDiscount = qli.Pricing_Comp_Total_without_discount_Amt__c;
            qliWrapper.netCompetitorBidPrice = qli.Pricing_Net_Comp_Bid_Price_Amt__c;
            qliWrapper.additionalComments = qli.Pricing_Additional_Comments_Txt__c; 
            qliWrapper.referenceQuoteLineNumberId = qli.Pricing_Reference_Quote_Line_Nbr__c;
            qliWrapper.referenceQuoteLineNumber=qli.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c;
            qliWrapper.sourceQuoteLineId=qli.SBQQ__Source__c;
            qliWrapper.rejectionReason = qli.Pricing_Rejection_Reason__c;
            qliWrapper.rejectionComments = qli.Pricing_Rejection_Comments_nm__c;
            qliWrapper.createdByEmail = qli.CreatedBy.Email;
            qliWrapper.lostReason = qli.Pricing_Lost_Reason_Nm__c;
            qliWrapper.coreCount = qli.pricing_core_count__c;
            qliWrapper.consumptionPlatform = qli.Pricing_Consumption_Platform__c != null ?  qli.Pricing_Consumption_Platform__c.replace(', ', ',') : null;
            qliWrapper.consumptionSalesGeo = qli.Pricing_Consumption_Sale_Geo__c != null ?  qli.Pricing_Consumption_Sale_Geo__c.replace(', ', ',') : null;
            qliWrapper.consumptionCountry = qli.Pricing_Consumption_Country__c != null ? qli.Pricing_Consumption_Country__c.replace(', ', ',') : null;
            qliWrapper.consumptionRegion = qli.Pricing_Consumption_Region__c != null ? qli.Pricing_Consumption_Region__c.replace(', ', ',') : null;
            qliWrapper.consumptionSegment = qli.Pricing_Consumption_Segment__c != null ? qli.Pricing_Consumption_Segment__c.replace(', ', ',') : null;
            qliWrapper.tdp = qli.pricing_TDP__c;
            if(pmMap.containsKey(qli.Id)){
                getPerformanceMetricsDetails(qliWrapper, pmMap.get(qli.Id));
            }  
            qDetails.quoteLines.DataCenterCPU.add(qliWrapper);
        }
    }
    
    public static void getQuoteLineDetailsSSD(Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteDetails qDetails, List<SBQQ__QuoteLine__c> quoteLines){
        
        for(SBQQ__QuoteLine__c qli : quoteLines){
            Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineSSD qliWrapper = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineSSD();
            qliWrapper.quoteLineId = qli.id;
            qliWrapper.quoteId = qli.SBQQ__Quote__c;
            qliWrapper.quote = qli.SBQQ__Quote__r.Name;
            qliWrapper.quoteLineType = Label.Pricing_RestAPI_Products_SSD_Param;
            qliWrapper.quoteLineNumber=qli.Pricing_Quote_Line_Number__c;
            qliWrapper.quoteLineStatus=qli.Pricing_Status_Nm__c;
            qliWrapper.changeRequest = qli.Pricing_New_Change_Request_cb__c;//Pricing_Change_Request_cb__c
            qliWrapper.approvedPricingStartDate= qli.Pricing_Approved_Start_Date_Dup_Dt__c;
            qliWrapper.approvedPricingEndDate=qli.Pricing_Approved_End_Date_Dup_Dt__c;
            qliWrapper.approvedQuantity = qli.Pricing_Approved_Unit_Dup_Qty__c;
            qliWrapper.effectivePricingStartDate = qli.Pricing_Revised_Pricing_Start_Date_D_dt__c; 
            qliWrapper.billingEndDate = qli.Pricing_Billing_End_Date_Dt__c;
            qliWrapper.billingStartDate = qli.Pricing_Billing_Start_Date_Dt__c;
            qliWrapper.additionalTermsandConditions = qli.Pricing_Additional_T_C_s_Txt__c;
            qliWrapper.newRequestedPrice = qli.Pricing_Request_Discount_Unit_Price_qty__c;
            qliWrapper.approvedECAPPrice = qli.Pricing_ECAP_Price_Dup_Amt__c;
            qliWrapper.dealId = qli.Pricing_Deal_RFQ_Dup_Id__c;
            qliWrapper.newQuantity = qli.Pricing_New_Quantity_qty__c;
            qliWrapper.readyForReview= qli.Pricing_Ready_for_Review_cb__c;
            qliWrapper.lastSubmittedDate = qli.Pricing_Last_Submitted_Date_dt__c;
            qliWrapper.firstSubmittedDate = qli.Pricing_Original_Submitted_Date_dt__c;
            qliWrapper.approvedDate = qli.Pricing_Last_Approved_Date_dt__c;
            qliWrapper.lastSubmittedById = qli.Pricing_Last_Submitted_By_Id__c;
            qliWrapper.lastSubmittedByName = qli.Pricing_Last_Submitted_By_Id__r.Name;
            qliWrapper.quoteLinePricingEndDate = qli.Pricing_End_Date_dt__c;
            qliWrapper.quoteLinePricingStartDate = qli.Pricing_Start_Date_dt__c;
            qliWrapper.productId=qli.Pricing_Product_Nm__c;
            qliWrapper.productName = qli.SBQQ__ProductName__c;
            qliWrapper.familyName = qli.Pricing_Family_Name_Nm__c;
            qliWrapper.quantity = qli.Pricing_Total_Volume_Qty__c;
            qliWrapper.payableQuantity = qli.Pricing_Payable_Quantity__c;
            qliWrapper.requestedUnitPrice=qli.Pricing_Req_Discounted_Unit_Price__c;
            qliWrapper.requestedDiscountUnitPricePerGB = qli.Pricing_ReqDiscUnitPricePerGB_Amt__c;
            qliWrapper.competitorName=qli.Pricing_Competitor_OEM_Nm__c;
            qliWrapper.competitorProduct=qli.Pricing_Comp_Product_Txt__c;
            qliWrapper.competitorSingleSystemPricePoint=qli.Pricing_Comp_Unit_Price_Amt__c;
            qliWrapper.competitorUnitPricePerGB = qli.Pricing_CompUnitPricePerGB_Amt__c;
            qliWrapper.competitorDensity=qli.Pricing_Comp_Density_Nbr__c;
            qliWrapper.volumeByQuarterAndReasoning=qli.Pricing_VolumeByQuarterAndReasoning_Txt__c;
            qliWrapper.additionalComments = qli.Pricing_Additional_Comments_Txt__c; 
            qliWrapper.referenceQuoteLineNumberId = qli.Pricing_Reference_Quote_Line_Nbr__c;
            qliWrapper.referenceQuoteLineNumber=qli.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c; 
            qliWrapper.sourceQuoteLineId=qli.SBQQ__Source__c;
            qliWrapper.rejectionReason = qli.Pricing_Rejection_Reason__c;
            qliWrapper.rejectionComments = qli.Pricing_Rejection_Comments_nm__c;
            qliWrapper.createdByEmail = qli.CreatedBy.Email;
            qliWrapper.lostReason = qli.Pricing_Lost_Reason_Nm__c;
            qliWrapper.writeInProduct = qli.Pricing_Other_Product_Nm__c;
            qliWrapper.density = qli.Pricing_Density__c;
            qliWrapper.consumptionPlatform = qli.Pricing_Consumption_Platform__c != null ? qli.Pricing_Consumption_Platform__c.replace(', ', ',') : null;
            qliWrapper.consumptionSalesGeo = qli.Pricing_Consumption_Sale_Geo__c != null ? qli.Pricing_Consumption_Sale_Geo__c.replace(', ', ',') : null;
            qliWrapper.consumptionCountry = qli.Pricing_Consumption_Country__c != null ? qli.Pricing_Consumption_Country__c.replace(', ', ',') : null;
            qliWrapper.consumptionRegion = qli.Pricing_Consumption_Region__c != null ? qli.Pricing_Consumption_Region__c.replace(', ', ',') : null;
            qliWrapper.consumptionSegment = qli.Pricing_Consumption_Segment__c != null ? qli.Pricing_Consumption_Segment__c.replace(', ', ',') : null;
            qliWrapper.tdp = qli.pricing_TDP__c;
            qDetails.quoteLines.OptaneSSD.add(qliWrapper);
        }
    }
    
    public static void getQuoteLineDetailsPMem(Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteDetails qDetails, List<SBQQ__QuoteLine__c> quoteLines){   
        
        for(SBQQ__QuoteLine__c qli : quoteLines){
            Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLinePMem qliWrapper = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLinePMem();
            qliWrapper.quoteLineId = qli.id;
            qliWrapper.quoteId = qli.SBQQ__Quote__c;
            qliWrapper.quote = qli.SBQQ__Quote__r.Name;
            qliWrapper.quoteLineType = Label.Pricing_RestAPI_Products_PMem_Param;
            qliWrapper.quoteLineNumber=qli.Pricing_Quote_Line_Number__c;
            qliWrapper.quoteLineStatus=qli.Pricing_Status_Nm__c;
            qliWrapper.changeRequest = qli.Pricing_New_Change_Request_cb__c;//Pricing_Change_Request_cb__c
            qliWrapper.approvedPricingStartDate= qli.Pricing_Approved_Start_Date_Dup_Dt__c;
            qliWrapper.approvedPricingEndDate=qli.Pricing_Approved_End_Date_Dup_Dt__c;
            qliWrapper.approvedQuantity = qli.Pricing_Approved_Unit_Dup_Qty__c;
            qliWrapper.effectivePricingStartDate = qli.Pricing_Revised_Pricing_Start_Date_D_dt__c; 
            qliWrapper.billingEndDate = qli.Pricing_Billing_End_Date_Dt__c;
            qliWrapper.billingStartDate = qli.Pricing_Billing_Start_Date_Dt__c;
            qliWrapper.additionalTermsandConditions = qli.Pricing_Additional_T_C_s_Txt__c;
            qliWrapper.newRequestedPrice = qli.Pricing_Request_Discount_Unit_Price_qty__c;
            qliWrapper.approvedECAPPrice = qli.Pricing_ECAP_Price_Dup_Amt__c;
            qliWrapper.dealId = qli.Pricing_Deal_RFQ_Dup_Id__c;
            qliWrapper.newQuantity = qli.Pricing_New_Quantity_qty__c;
            qliWrapper.readyForReview= qli.Pricing_Ready_for_Review_cb__c;
            qliWrapper.lastSubmittedDate = qli.Pricing_Last_Submitted_Date_dt__c;
            qliWrapper.firstSubmittedDate = qli.Pricing_Original_Submitted_Date_dt__c;
            qliWrapper.approvedDate = qli.Pricing_Last_Approved_Date_dt__c;
            qliWrapper.lastSubmittedById = qli.Pricing_Last_Submitted_By_Id__c;
            qliWrapper.lastSubmittedByName = qli.Pricing_Last_Submitted_By_Id__r.Name;
            qliWrapper.quoteLinePricingEndDate = qli.Pricing_End_Date_dt__c;
            qliWrapper.quoteLinePricingStartDate = qli.Pricing_Start_Date_dt__c;
            qliWrapper.productId=qli.Pricing_Product_Nm__c;
            qliWrapper.productName = qli.SBQQ__ProductName__c;
            qliWrapper.quantity = qli.Pricing_Unit_Qty__c;
            qliWrapper.payableQuantity = qli.Pricing_Payable_Quantity__c;
            qliWrapper.requestedUnitPrice=qli.Pricing_Req_Discounted_Unit_Price__c;
            qliWrapper.competitorName=qli.Pricing_Competitor_OEM_Nm__c;
            qliWrapper.competitorSingleSystemPricePoint=qli.Pricing_Comp_Unit_Price_Amt__c;
            qliWrapper.competitorDensity=qli.Pricing_Comp_Density_Nbr__c;
            qliWrapper.writeInProduct = qli.Pricing_Other_Product_Nm__c;
            qliWrapper.systemModel = qli.Pricing_OEM_System_Model_Nm__c;
            qliWrapper.noOfSystems = qli.Pricing_Systems_qty__c;
            qliWrapper.noOfUnitsPerSystem = qli.Pricing_Units_per_system_qty__c;
            qliWrapper.pairedCPU = qli.Pricing_CPU_Txt__c;
            qliWrapper.dramDensity = qli.Pricing_DRAM_Density_Nbr__c;
            qliWrapper.noOfDRAMPerSystem = qli.Pricing_DRAM_per_System_qty__c;
            qliWrapper.competitorQuantity = qli.Pricing_Comp_Units_Cnt__c;
            qliWrapper.noOfCPUsPerSystem = qli.Pricing_CPU_Quantity_per_System_qty__c;
            qliWrapper.serverIntegration = qli.Pricing_Server_Integration_Nm__c;
            qliWrapper.workload = qli.Pricing_Workload_Txt__c;
            qliWrapper.pocTestingResults = qli.Pricing_POC_testing_results_Txt__c;
            qliWrapper.additionalComments = qli.Pricing_Additional_Comments_Txt__c; 
            qliWrapper.referenceQuoteLineNumberId = qli.Pricing_Reference_Quote_Line_Nbr__c;
            qliWrapper.referenceQuoteLineNumber=qli.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c;
            qliWrapper.sourceQuoteLineId=qli.SBQQ__Source__c;
            qliWrapper.competitorNoOfSystems = qli.Pricing_Competitor_Systems_Cnt__c;
            qliWrapper.competitorNoOfUnitsPerSystem = qli.Pricing_Comp_CPUs_per_system_Cnt__c;
            qliWrapper.forecastProductName = qli.Pricing_DealProduct_Nm__c;
            qliWrapper.requestedDiscountUnitPricePerGB = qli.Pricing_ReqDiscUnitPricePerGB_Amt__c;
            qliWrapper.competitorUnitPricePerGB = qli.Pricing_CompUnitPricePerGB_Amt__c;
            qliWrapper.rejectionReason = qli.Pricing_Rejection_Reason__c;
            qliWrapper.rejectionComments = qli.Pricing_Rejection_Comments_nm__c;
            qliWrapper.createdByEmail = qli.CreatedBy.Email;
            qliWrapper.lostReason = qli.Pricing_Lost_Reason_Nm__c;
            qliWrapper.density = qli.Pricing_Density__c;
            qliWrapper.customerStdUnitPrice = qli.Pricing_OEM_Standard_Unit_Price_Amt__c;
            qliWrapper.consumptionPlatform = qli.Pricing_Consumption_Platform__c != null ? qli.Pricing_Consumption_Platform__c.replace(', ', ',') : null;
            qliWrapper.consumptionSalesGeo = qli.Pricing_Consumption_Sale_Geo__c!= null ? qli.Pricing_Consumption_Sale_Geo__c.replace(', ', ',') : null;
            qliWrapper.consumptionCountry = qli.Pricing_Consumption_Country__c != null ? qli.Pricing_Consumption_Country__c.replace(', ', ',') : null;
            qliWrapper.consumptionRegion = qli.Pricing_Consumption_Region__c != null ? qli.Pricing_Consumption_Region__c.replace(', ', ',') : null;
            qliWrapper.consumptionSegment = qli.Pricing_Consumption_Segment__c != null ? qli.Pricing_Consumption_Segment__c.replace(', ', ',') : null;
            qliWrapper.tdp = qli.pricing_TDP__c;
            qDetails.quoteLines.OptanePMem.add(qliWrapper);
        }
    }
    
    public static void getQuoteLineDetailsNIC(Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteDetails qDetails, List<SBQQ__QuoteLine__c> quoteLines){
        
        for(SBQQ__QuoteLine__c qli : quoteLines){
            Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineEthernet qliWrapper = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineEthernet();
            qliWrapper.quoteLineId = qli.id;
            qliWrapper.quoteId = qli.SBQQ__Quote__c;
            qliWrapper.quote = qli.SBQQ__Quote__r.Name;
            qliWrapper.quoteLineType = Label.Pricing_RestAPI_Products_NIC_Param;
            qliWrapper.quoteLineNumber=qli.Pricing_Quote_Line_Number__c;
            qliWrapper.quoteLineStatus=qli.Pricing_Status_Nm__c;
            qliWrapper.changeRequest = qli.Pricing_New_Change_Request_cb__c;//Pricing_Change_Request_cb__c
            qliWrapper.approvedPricingStartDate= qli.Pricing_Approved_Start_Date_Dup_Dt__c;
            qliWrapper.approvedPricingEndDate=qli.Pricing_Approved_End_Date_Dup_Dt__c;
            qliWrapper.approvedQuantity = qli.Pricing_Approved_Unit_Dup_Qty__c;
            qliWrapper.effectivePricingStartDate = qli.Pricing_Revised_Pricing_Start_Date_D_dt__c; 
            qliWrapper.billingEndDate = qli.Pricing_Billing_End_Date_Dt__c;
            qliWrapper.billingStartDate = qli.Pricing_Billing_Start_Date_Dt__c;
            qliWrapper.additionalTermsandConditions = qli.Pricing_Additional_T_C_s_Txt__c;
            qliWrapper.newRequestedPrice = qli.Pricing_Request_Discount_Unit_Price_qty__c;
            qliWrapper.approvedECAPPrice = qli.Pricing_ECAP_Price_Dup_Amt__c;
            qliWrapper.dealId = qli.Pricing_Deal_RFQ_Dup_Id__c;
            qliWrapper.newQuantity = qli.Pricing_New_Quantity_qty__c;
            qliWrapper.readyForReview= qli.Pricing_Ready_for_Review_cb__c;
            qliWrapper.lastSubmittedDate = qli.Pricing_Last_Submitted_Date_dt__c;
            qliWrapper.firstSubmittedDate = qli.Pricing_Original_Submitted_Date_dt__c;
            qliWrapper.approvedDate = qli.Pricing_Last_Approved_Date_dt__c;
            qliWrapper.lastSubmittedById = qli.Pricing_Last_Submitted_By_Id__c;
            qliWrapper.lastSubmittedByName = qli.Pricing_Last_Submitted_By_Id__r.Name;
            qliWrapper.quoteLinePricingEndDate = qli.Pricing_End_Date_dt__c;
            qliWrapper.quoteLinePricingStartDate = qli.Pricing_Start_Date_dt__c;
            qliWrapper.productId=qli.Pricing_Product_Nm__c;
            qliWrapper.productName = qli.SBQQ__ProductName__c;
            qliWrapper.forecastProductName = qli.Pricing_DealProduct_Nm__c;
            qliWrapper.writeInProduct = qli.Pricing_Other_Product_Nm__c;
            qliWrapper.quantity = qli.Pricing_Total_Volume_Qty__c;
            qliWrapper.payableQuantity = qli.Pricing_Payable_Quantity__c;
            qliWrapper.requestedUnitPrice=qli.Pricing_Req_Discounted_Unit_Price__c;
            qliWrapper.competitorProduct=qli.Pricing_Comp_Product_Txt__c;
            qliWrapper.competitorSingleSystemPricePoint=qli.Pricing_Comp_Unit_Price_Amt__c;
            qliWrapper.competitorQuantity = qli.Pricing_Competitor_Quantity_nbr__c;
            qliWrapper.additionalComments = qli.Pricing_Additional_Comments_Txt__c; 
            qliWrapper.referenceQuoteLineNumberId = qli.Pricing_Reference_Quote_Line_Nbr__c;
            qliWrapper.referenceQuoteLineNumber=qli.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c;
            qliWrapper.sourceQuoteLineId=qli.SBQQ__Source__c;
            qliWrapper.rejectionReason = qli.Pricing_Rejection_Reason__c;
            qliWrapper.rejectionComments = qli.Pricing_Rejection_Comments_nm__c;
            qliWrapper.createdByEmail = qli.CreatedBy.Email;
            qliWrapper.lostReason = qli.Pricing_Lost_Reason_Nm__c;
            qliWrapper.consumptionPlatform = qli.Pricing_Consumption_Platform__c != null ? qli.Pricing_Consumption_Platform__c.replace(', ', ',') : null;
            qliWrapper.consumptionSalesGeo = qli.Pricing_Consumption_Sale_Geo__c != null ? qli.Pricing_Consumption_Sale_Geo__c.replace(', ', ',') : null;
            qliWrapper.consumptionCountry = qli.Pricing_Consumption_Country__c != null ? qli.Pricing_Consumption_Country__c.replace(', ', ',') : null;
            qliWrapper.consumptionRegion = qli.Pricing_Consumption_Region__c != null ? qli.Pricing_Consumption_Region__c.replace(', ', ',') : null;
            qliWrapper.consumptionSegment = qli.Pricing_Consumption_Segment__c != null ? qli.Pricing_Consumption_Segment__c.replace(', ', ',') : null;
            qliWrapper.tdp = qli.pricing_TDP__c;
            qDetails.quoteLines.Ethernet.add(qliWrapper);
        }
    }
    
    public static void getQuoteLineDetailsGPU(Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteDetails qDetails, List<SBQQ__QuoteLine__c> quoteLines){
        for(SBQQ__QuoteLine__c qli : quoteLines){
            Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineGPU qliWrapper = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineGPU();
            qliWrapper.quoteLineId = qli.id;
            qliWrapper.quoteId = qli.SBQQ__Quote__c;
            qliWrapper.quote = qli.SBQQ__Quote__r.Name;
            qliWrapper.quoteLineType = Label.Pricing_RestAPI_Products_GPU_Param;
            qliWrapper.quoteLineNumber=qli.Pricing_Quote_Line_Number__c;
            qliWrapper.quoteLineStatus=qli.Pricing_Status_Nm__c;
            //qliWrapper.noOfGPUs = qli.Pricing_No_of_GPUs__c;
            qliWrapper.writeInPairedCPU = qli.Pricing_Write_In_Paired_CPU_Nm__c;
            qliWrapper.noOfGPUsPerSystem = qli.Pricing_No_of_GPUs_per_system_nbr__c;
            qliWrapper.changeRequest = qli.Pricing_New_Change_Request_cb__c;//Pricing_Change_Request_cb__c
            qliWrapper.approvedPricingStartDate= qli.Pricing_Approved_Start_Date_Dup_Dt__c;
            qliWrapper.approvedPricingEndDate=qli.Pricing_Approved_End_Date_Dup_Dt__c;
            qliWrapper.approvedQuantity = qli.Pricing_Approved_Unit_Dup_Qty__c;
            qliWrapper.effectivePricingStartDate = qli.Pricing_Revised_Pricing_Start_Date_D_dt__c; 
            qliWrapper.billingEndDate = qli.Pricing_Billing_End_Date_Dt__c;
            qliWrapper.billingStartDate = qli.Pricing_Billing_Start_Date_Dt__c;
            qliWrapper.additionalTermsandConditions = qli.Pricing_Additional_T_C_s_Txt__c;
            qliWrapper.newRequestedPrice = qli.Pricing_Request_Discount_Unit_Price_qty__c;
            qliWrapper.competitiveBidDiscount = qli.Pricing_Competitive_Bid_Discount_Pct__c;
            qliWrapper.approvedECAPPrice = qli.Pricing_ECAP_Price_Dup_Amt__c;
            qliWrapper.dealId = qli.Pricing_Deal_RFQ_Dup_Id__c;
            qliWrapper.newQuantity = qli.Pricing_New_Quantity_qty__c;
            qliWrapper.readyForReview= qli.Pricing_Ready_for_Review_cb__c;
            qliWrapper.lastSubmittedDate = qli.Pricing_Last_Submitted_Date_dt__c;
            qliWrapper.firstSubmittedDate = qli.Pricing_Original_Submitted_Date_dt__c;
            qliWrapper.approvedDate = qli.Pricing_Last_Approved_Date_dt__c;
            qliWrapper.lastSubmittedById = qli.Pricing_Last_Submitted_By_Id__c;
            qliWrapper.lastSubmittedByName = qli.Pricing_Last_Submitted_By_Id__r.Name;
            qliWrapper.quoteLinePricingEndDate = qli.Pricing_End_Date_dt__c;
            qliWrapper.quoteLinePricingStartDate = qli.Pricing_Start_Date_dt__c;
            qliWrapper.productId=qli.Pricing_Product_Nm__c;
            qliWrapper.productName = qli.SBQQ__ProductName__c;
            qliWrapper.pairedCPUId=qli.Pricing_Paired_CPU_Nm__c;
            qliWrapper.quantity = qli.Pricing_Unit_Qty__c;
            qliWrapper.payableQuantity = qli.Pricing_Payable_Quantity__c;
            qliWrapper.writeInProduct=qli.Pricing_Other_Product_Nm__c;
            qliWrapper.systemModel=qli.Pricing_OEM_System_Model_Nm__c;
            qliWrapper.noOfSystems=qli.Pricing_Systems_qty__c;
            qliWrapper.noOfCPUsPerSystem = qli.Pricing_CPUs_per_system_qty__c;
            qliWrapper.pairedCPU = qli.Pricing_CPU_Txt__c;
            qliWrapper.singleSystemPricePoint = qli.Pricing_Single_System_Price_Amt__c;
            qliWrapper.customerStdUnitPrice=qli.Pricing_OEM_Standard_Unit_Price_Amt__c;
            qliWrapper.quotelineprogramtype=qli.Pricing_Program_Type_Nm__c;
            qliWrapper.requestedUnitPrice=qli.Pricing_Req_Discounted_Unit_Price__c;
            qliWrapper.totalBidWithoutDiscount= qli.Pricing_Total_Bid_without_Discount_Amt__c;
            qliWrapper.netIntelBidPrice = qli.Pricing_Net_IA_Bid_Price_Amt__c;
            qliWrapper.intelDiscount = qli.Pricing_Intel_Discount_Pct__c;
            qliWrapper.customerDiscount = qli.Pricing_OEM_Discount_Pct__c;
            qliWrapper.totalIntelDiscount =qli.Pricing_Total_Intel_Discount_Amt__c;
            qliWrapper.intelBidDiscount = qli.Pricing_IA_Bid_Discount_Pct__c;
            qliWrapper.additionalDiscount=qli.Pricing_Additional_OEM_Discount_Amt__c;
            qliWrapper.competitorName=qli.Pricing_Competitor_OEM_Nm__c;
            qliWrapper.competitorSystemModel=qli.Pricing_Competitor_System_Model_Nm__c;
            qliWrapper.competitorProductId=qli.Pricing_Competetor_Product__c;
            qliWrapper.competitorProductName = qli.Pricing_Competetor_Product__r.Name;
            qliWrapper.writeInCompetitorProduct=qli.Pricing_Other_Competitor_Product_Nm__c;
            qliWrapper.competitorNoOfGPUs = qli.Pricing_Competitor_No_of_GPUs__c;
            qliWrapper.competitorNoOfGPUsPerSystem = qli.Pricing_Comp_No_of_GPUs_per_Sys__c;
            qliWrapper.competitorPairedCPU = qli.Pricing_Competitor_Paired_CPU_Nm__c;
            qliWrapper.competitorNoOfSystems = qli.Pricing_Competitor_Systems_Cnt__c;
            qliWrapper.competitorNoOfCPUsPerSystem = qli.Pricing_Comp_CPUs_per_system_Cnt__c;
            qliWrapper.competitorQuantity= qli.Pricing_Comp_Units_Cnt__c;
            qliWrapper.competitorSingleSystemPrice = qli.Pricing_Comp_Single_System_Price_Amt__c;
            qliWrapper.competitorAdditionalDiscount = qli.Pricing_Comp_Additional_OEM_Disc_Amt__c;
            qliWrapper.competitorTotalWithoutDiscount = qli.Pricing_Comp_Total_without_discount_Amt__c;
            qliWrapper.netCompetitorBidPrice = qli.Pricing_Net_Comp_Bid_Price_Amt__c;
            qliWrapper.additionalComments = qli.Pricing_Additional_Comments_Txt__c; 
            qliWrapper.referenceQuoteLineNumberId = qli.Pricing_Reference_Quote_Line_Nbr__c;
            qliWrapper.referenceQuoteLineNumber=qli.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c;
            qliWrapper.sourceQuoteLineId=qli.SBQQ__Source__c;
            qliWrapper.rejectionReason = qli.Pricing_Rejection_Reason__c;
            qliWrapper.rejectionComments = qli.Pricing_Rejection_Comments_nm__c;
            qliWrapper.createdByEmail = qli.CreatedBy.Email;
            qliWrapper.lostReason = qli.Pricing_Lost_Reason_Nm__c;
            qliWrapper.consumptionPlatform = qli.Pricing_Consumption_Platform__c != null ? qli.Pricing_Consumption_Platform__c.replace(', ', ',') : null;
            qliWrapper.consumptionSalesGeo = qli.Pricing_Consumption_Sale_Geo__c!= null ? qli.Pricing_Consumption_Sale_Geo__c.replace(', ', ',') : null;
            qliWrapper.consumptionCountry = qli.Pricing_Consumption_Country__c != null ? qli.Pricing_Consumption_Country__c.replace(', ', ',') : null;
            qliWrapper.consumptionRegion = qli.Pricing_Consumption_Region__c != null ? qli.Pricing_Consumption_Region__c.replace(', ', ',') : null;
            qliWrapper.consumptionSegment = qli.Pricing_Consumption_Segment__c != null ? qli.Pricing_Consumption_Segment__c.replace(', ', ',') : null;
            qliWrapper.tdp = qli.pricing_TDP__c;
            qDetails.quoteLines.DataCenterGPU.add(qliWrapper);
        }
    }

    /**
* @description Method to get the Quote Line details and assign the Quote Line field values to the wrapper 
properties to form the response
* @author Bharath Chandrashekar | 06-17-2022 
* @param qDetailsClient 
* @param quoteLines 
**/
    public static void getQuoteLineDetailsClient(Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteDetailsClient qDetailsClient, List<SBQQ__QuoteLine__c> quoteLines){   
        
        for(SBQQ__QuoteLine__c qli : quoteLines){
            Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineClient qliWrapperClient = new Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineClient();
            qliWrapperClient.quoteLineId = qli.id;
            qliWrapperClient.quoteId = qli.SBQQ__Quote__c;
            qliWrapperClient.quote = qli.SBQQ__Quote__r.Name;
            qliWrapperClient.quoteLineType = Label.Pricing_Tender_CCG_Quote;
            qliWrapperClient.quoteLineNumber=qli.Pricing_Quote_Line_Number__c;
            qliWrapperClient.quoteLineStatus=qli.Pricing_Status_Nm__c;
            qliWrapperClient.changeRequest = qli.Pricing_New_Change_Request_cb__c;
            qliWrapperClient.approvedPricingStartDate= qli.Pricing_Approved_Start_Date_Dup_Dt__c;
            qliWrapperClient.approvedPricingEndDate=qli.Pricing_Approved_End_Date_Dup_Dt__c;
            qliWrapperClient.approvedQuantity = qli.Pricing_Approved_Unit_Dup_Qty__c;
            qliWrapperClient.effectivePricingStartDate = qli.Pricing_Revised_Pricing_Start_Date_D_dt__c; 
            qliWrapperClient.billingEndDate = qli.Pricing_Billing_End_Date_Dt__c;
            qliWrapperClient.billingStartDate = qli.Pricing_Billing_Start_Date_Dt__c;
            qliWrapperClient.additionalTermsandConditions = qli.Pricing_Additional_T_C_s_Txt__c;
            qliWrapperClient.newRequestedPrice = qli.Pricing_Request_Discount_Unit_Price_qty__c;
            qliWrapperClient.approvedECAPPrice = qli.Pricing_ECAP_Price_Dup_Amt__c;
            qliWrapperClient.dealId = qli.Pricing_Deal_RFQ_Dup_Id__c;
            qliWrapperClient.newQuantity = qli.Pricing_New_Quantity_qty__c;
            qliWrapperClient.readyForReview= qli.Pricing_Ready_for_Review_cb__c;
            qliWrapperClient.lastSubmittedDate = qli.Pricing_Last_Submitted_Date_dt__c;
            qliWrapperClient.firstSubmittedDate = qli.Pricing_Original_Submitted_Date_dt__c;
            qliWrapperClient.approvedDate = qli.Pricing_Last_Approved_Date_dt__c;
            qliWrapperClient.lastSubmittedById = qli.Pricing_Last_Submitted_By_Id__c;
            qliWrapperClient.lastSubmittedByName = qli.Pricing_Last_Submitted_By_Id__r.Name;
            qliWrapperClient.quoteLinePricingEndDate = qli.Pricing_End_Date_dt__c;
            qliWrapperClient.quoteLinePricingStartDate = qli.Pricing_Start_Date_dt__c;
            qliWrapperClient.productId=qli.Pricing_Product_Nm__c;
            qliWrapperClient.productName = qli.SBQQ__ProductName__c;
            qliWrapperClient.processorNumber = qli.Pricing_Processor_Number_Nm__c;
            qliWrapperClient.quantity = qli.Pricing_Total_Volume_Qty__c;
            qliWrapperClient.payableQuantity = qli.Pricing_Payable_Quantity__c;
            qliWrapperClient.writeInProduct=qli.Pricing_Other_Product_Nm__c;
            qliWrapperClient.systemModel=qli.Pricing_OEM_System_Model_Nm__c;
            qliWrapperClient.singleSystemPricePoint = qli.Pricing_Single_System_Price_Amt__c;
            qliWrapperClient.customerStdUnitPrice=qli.Pricing_OEM_Standard_Unit_Price_Amt__c;
            qliWrapperClient.requestedUnitPrice=qli.Pricing_Req_Discounted_Unit_Price__c;
            qliWrapperClient.formFactor=qli.Pricing_Form_Factor_Nm__c;
            qliWrapperClient.competitorName=qli.Pricing_Competitor_OEM_Nm__c;
            qliWrapperClient.competitorSystemModel=qli.Pricing_Competitor_System_Model_Nm__c;
            qliWrapperClient.competitorProductId=qli.Pricing_Competetor_Product__c;
            qliWrapperClient.competitorProductName = qli.Pricing_Competetor_Product__r.Name;
            qliWrapperClient.writeInCompetitorProduct=qli.Pricing_Other_Competitor_Product_Nm__c;
            qliWrapperClient.competitorProductProvider = qli.Pricing_comp_Product_Provider_nm__c;
            qliWrapperClient.competitorSingleSystemPricePoint = qli.Pricing_Comp_Unit_Price_Amt__c;
            qliWrapperClient.additionalComments = qli.Pricing_Additional_Comments_Txt__c; 
            qliWrapperClient.referenceQuoteLineNumberId = qli.Pricing_Reference_Quote_Line_Nbr__c;
            qliWrapperClient.referenceQuoteLineNumber=qli.Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c;
            qliWrapperClient.sourceQuoteLineId=qli.SBQQ__Source__c;
            qliWrapperClient.rejectionReason = qli.Pricing_Rejection_Reason__c;
            qliWrapperClient.rejectionComments = qli.Pricing_Rejection_Comments_nm__c;
            qliWrapperClient.createdByEmail = qli.CreatedBy.Email;
            qliWrapperClient.lostReason = qli.Pricing_Lost_Reason_Nm__c;
            qliWrapperClient.coreCount = qli.pricing_core_count__c;
            qliWrapperClient.consumptionPlatform = qli.Pricing_Consumption_Platform__c != null ? qli.Pricing_Consumption_Platform__c.replace(', ', ',') : null;
            qliWrapperClient.consumptionSalesGeo = qli.Pricing_Consumption_Sale_Geo__c != null ? qli.Pricing_Consumption_Sale_Geo__c.replace(', ', ',') : null;
            qliWrapperClient.consumptionCountry = qli.Pricing_Consumption_Country__c != null ? qli.Pricing_Consumption_Country__c.replace(', ', ',') : null;
            qliWrapperClient.consumptionRegion = qli.Pricing_Consumption_Region__c != null ? qli.Pricing_Consumption_Region__c.replace(', ', ',') : null;
            qliWrapperClient.consumptionSegment = qli.Pricing_Consumption_Segment__c != null ? qli.Pricing_Consumption_Segment__c.replace(', ', ',') : null;
            qliWrapperClient.tdp = qli.pricing_TDP__c;
            qDetailsClient.quoteLinesClient.Client.add(qliWrapperClient);
        }
    }
    
    public static void getPerformanceMetricsDetails(Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteLineCPU qliWrapper, List<Pricing_Performance_Metric__c> perfMetrics){
        
        qliWrapper.performanceMetrics = new List<Pricing_RestAPI_QuoteDetailsWrapperV2.PerformanceMetricsWrapper>(); 
        for(Pricing_Performance_Metric__c pm : perfMetrics){
            Pricing_RestAPI_QuoteDetailsWrapperV2.PerformanceMetricsWrapper pmetric = new Pricing_RestAPI_QuoteDetailsWrapperV2.PerformanceMetricsWrapper();
            pmetric.performanceMetricsId= pm.Id;
            pmetric.performanceMetricsUsed = pm.Pricing_Performance_Metric_Nm__c;
            pmetric.intelScore = pm.Pricing_Intel_SKU_Performance_Nbr__c.setScale(2);
            pmetric.compScore = pm.Pricing_Comp_SKU_Performance_Nbr__c.setScale(2);
            pmetric.weighting = pm.Pricing_Weighting_Pct__c;
            pmetric.otherText = pm.Pricing_Other_Nm__c;            
            qliWrapper.performanceMetrics.add(pmetric);
        }        
    }    
    
    public static void getQuoteLetter(){
        quoteName = !String.isBlank(recId) && !String.isBlank(quoteName) ? '':quoteName;
        String currentUserAccountId = [Select Id, AccountId from User where Id = :UserInfo.getUserId()].AccountId;
        List<SBQQ__QuoteDocument__c> quoteLetterLst = [SELECT Id,name,SBQQ__DocumentId__c,SBQQ__Quote__r.name,SBQQ__Quote__c,SBQQ__Version__c,createddate FROM SBQQ__QuoteDocument__c where SBQQ__Quote__c =: quoteId AND SBQQ__Quote__r.Pricing_Quote_Program_Nm__c =: Label.Pricing_Tender_Quote_Program and SBQQ__Quote__r.SBQQ__Account__c =: currentUserAccountId order by SBQQ__Version__c desc];
        if(!quoteLetterLst.isEmpty()){
            List<Document> doc = [SELECT Id,Body from Document where id=: quoteLetterLst[0].SBQQ__DocumentId__c];
            if(!doc.isEmpty()){
                String base64PDF = EncodingUtil.base64Encode(doc[0].body);
                response.successContent = new List<QuoteLetterDetails>();
                response.successContent.add(new QuoteLetterDetails(quoteLetterLst[0].SBQQ__Quote__c,quoteLetterLst[0].SBQQ__Quote__r.name,base64PDF,quoteLetterLst[0].SBQQ__Version__c,quoteLetterLst[0].name,quoteLetterLst[0].createddate));
                response.totalRecords= 1;
            }
            else{
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.NO_DATA_EXCEPTION_9001, response, RESTAPI_NAME, ENTRY_TIME);
            }
        }
        else{
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.NO_DATA_EXCEPTION_9001, response, RESTAPI_NAME, ENTRY_TIME);
        }
    }

    /**
    * @description Method to validate Primary Contact Email for Get API
    * @author Sandeep Chamate | 03-28-2024 
    **/
    public static void getPrimaryContactDetails(){
        Boolean isSelfReg = false;
        Boolean isValidContact = false;
        primaryContactEmail = primaryContactEmail.trim().toLowerCase();
        String regex = Label.Pricing_IQR_PrimaryContactEmail_Regex;
        if(Pattern.matches(regex, primaryContactEmail)) {
            String currentUserAccountId = [Select Id, AccountId from User where Id = :UserInfo.getUserId()].AccountId;
            List<Contact> con = [SELECT Id FROM Contact WHERE Email =: primaryContactEmail AND AccountId =: currentUserAccountId];
            if(con.size() > 0) {
                if(Pricing_RestAPI_QuotesUtilityV2.hasPartnerPermissionSet(primaryContactEmail)) {
                    isValidContact = true;
                }
            }
            else {
                isSelfReg = true;
            }
        }
        response.successContent = new List<ValidPrimaryContactDetails>();
        response.successContent.add(new ValidPrimaryContactDetails(isSelfReg, isValidContact, Label.Pricing_RestAPI_QuotesV2_RegistrationLinkforPrimaryContact));
        response.totalRecords= 1;
    }
    
    public class QuoteWrapper implements Pricing_RestAPI_SuccessContent {
        Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteDetails quoteDetails;
    }
    
    public class QuoteWrapperClient implements Pricing_RestAPI_SuccessContent {
        Pricing_RestAPI_QuoteDetailsWrapperV2.QuoteDetailsClient quoteDetailsClient;
    }
    
    public class QuoteLetterDetails implements Pricing_RestAPI_SuccessContent {
        public String quoteId {set;get;} 
        public String quoteName {set;get;}
        public String quoteLetter {set;get;}
        public string quoteDocumentName {set;get;}
        public Decimal version{set;get;}
        public String createdDate{set;get;}
        
        public QuoteLetterDetails(String recId, String qName, String qletter, Decimal ver, String qDocumentName, DateTime crDate){
            quoteId = recId;
            quoteName = qName;
            quoteLetter = qletter;
            quoteDocumentName = qDocumentName;
            version = ver;
            createdDate = DateTime.newInstance(crdate.year(),crdate.month(),crdate.day()).format('yyyy-MM-dd');
        }
    }
    
    public class svdQuotaDetailsWrapper implements Pricing_RestAPI_SuccessContent {
        public String maximumSVDQuotesAllowed {set;get;}
        public String remainingNoOfQuotes {set;get;}
        public String quarterStartDate {set;get;}
        public String quarterEndDate {set;get;}
        public svdQuotaDetailsWrapper( String maxSvd, String remSVD, String startDate, String endDate){
            maximumSVDQuotesAllowed = maxSvd;
            remainingNoOfQuotes = remSVD;
            quarterStartDate = startDate;
            quarterEndDate = endDate;
        }
    }

    public class DataCenterAndClientQuotaDetailsWrapper implements Pricing_RestAPI_SuccessContent {
        public DataCenterQuotaWrapper DataCenter {set;get;}
        public ClientQuotaWrapper Client {set;get;}
        public DataCenterAndClientQuotaDetailsWrapper(DataCenterQuotaWrapper dataCenterQuota,ClientQuotaWrapper clientQuota){
            DataCenter = dataCenterQuota;
            Client = clientQuota;
        }

    }
    
    public class DataCenterQuotaWrapper{
        public String maximumExceptionQuotesAllowed {set;get;}
        public String remainingNoOfQuotes {set;get;}
        public String quarterStartDate {set;get;}
        public String quarterEndDate {set;get;}
        public DataCenterQuotaWrapper(String maxExcptnQuote, String remExcptnQuote, String startDate, String endDate){
            maximumExceptionQuotesAllowed = maxExcptnQuote;
            remainingNoOfQuotes = remExcptnQuote;
            quarterStartDate = startDate;
            quarterEndDate = endDate;
        }
    }

    public class ClientQuotaWrapper{
        public String maximumExceptionQuotesAllowed {set;get;}
        public String remainingNoOfQuotes {set;get;}
        public String quarterStartDate {set;get;}
        public String quarterEndDate {set;get;}
        public ClientQuotaWrapper( String maxExcptnQuote, String remExcptnQuote, String startDate, String endDate){
            maximumExceptionQuotesAllowed = maxExcptnQuote;
            remainingNoOfQuotes = remExcptnQuote;
            quarterStartDate = startDate;
            quarterEndDate = endDate;
        }
    }

    //Wrapper Class for IsPrimaryContact Valid Get API
    public class ValidPrimaryContactDetails implements Pricing_RestAPI_SuccessContent {  
        public Boolean eligibleForSelfRegistration {set;get;} 
        public Boolean isValidPrimaryContact {set;get;}
        public String  primaryContactRegistrationLink {set;get;}
               
        public ValidPrimaryContactDetails(Boolean isSelfReg, Boolean isValidContact, String contactRegistrationLink){            
            eligibleForSelfRegistration = isSelfReg;
            isValidPrimaryContact = isValidContact;
            primaryContactRegistrationLink=contactRegistrationLink;
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------------
    
    @HttpPatch
    global static Pricing_RestAPI_Response doPatch(){
        RestRequest req = RestContext.request;
        //currentUser = [Select Id,ContactId,AccountId,Email from User where Id = :UserInfo.getUserId()];
        //validate the action parameters if its update
        if(validateUpdateParam()){
            if(isUpdatePrimaryContact){
                processUpdateContactDtlsRequest(req.requestBody.toString());
            }else{
                processUpdateRequest(req.requestBody.toString()); 
            } 
        }else{
            //action is invalid
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }

    /**
    * @description validate update API param
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
    * @return boolean 
    **/
    public static boolean validateUpdateParam(){
        
        actionType = Pricing_RestAPI_Util.getRequestParam('action');
        if(actionType != null && (actionType.toLowerCase() == 'update' || actionType.toLowerCase() == 'resubmit')){
            Pricing_RestAPI_QuotesUtilityV2.isCreateDraftQuote = (actionType.toLowerCase()=='update') ? true : false;
            Pricing_RestAPI_QuotesUtilityV2.isUpdateDraftQuote = (actionType.toLowerCase()=='update' || actionType.toLowerCase()=='resubmit') ? true : false;
            isResubmit = (actionType.toLowerCase()=='resubmit') ? true : false;
            return true;  
        }else if (actionType != null && actionType.toLowerCase() == 'updatecontactdetails'){
            isUpdatePrimaryContact = true;
            return true;
        }else{
            //invalid action parameter
            return false;
        }
    }

    /**
    * @description Method to process and Update contact and salesRep Details.
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 08-21-2024 
    * @param reqBody 
    **/
    public static void processUpdateContactDtlsRequest(String reqBody){
        try {
            Pricing_RestAPI_QuotesUtilityV2.QuotesWrapperForContactDtlsUpt quoteWrapForContactDtls = (Pricing_RestAPI_QuotesUtilityV2.QuotesWrapperForContactDtlsUpt) JSON.deserialize(reqBody, Pricing_RestAPI_QuotesUtilityV2.QuotesWrapperForContactDtlsUpt.class);
            Pricing_RestAPI_QuotesUtilityV2 quotesUtility = new Pricing_RestAPI_QuotesUtilityV2();
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg qErrorMsg = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            //Method to valdidate data from request payload
            Id quoteId = quoteWrapForContactDtls.quoteId;
            Map<Id,SBQQ__Quote__c> quoteMap = new Map<Id,SBQQ__Quote__c>([select id ,SBQQ__Status__c,SBQQ__SalesRep__c,Pricing_Primary_Contact_Email__c,Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Intel_Sales_Rep_Email_Txt__c,Pricing_SecondaryContact_Nm__c,Pricing_Customer_Reference_Id__c,Pricing_AdditionalRecipients__c from SBQQ__Quote__c where  Id =:quoteId and SBQQ__Account__c = :Pricing_RestAPI_QuotesUtilityV2.currentUser.AccountId]);
            boolean isValidQuoteLine = quotesUtility.validateQuoteContactDtlsWrapper(quoteWrapForContactDtls, qErrorMsg, quoteMap);
            
            if(isValidQuoteLine){
                List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
                        quoteMap.get(quoteId).Pricing_AdditionalRecipients__c = quoteWrapForContactDtls.additionalQuoteLetterRecipients;
                        quoteMap.get(quoteId).Pricing_Customer_Reference_Id__c = quoteWrapForContactDtls.referenceRequestID;
                        quoteMap.get(quoteId).Pricing_SecondaryContact_Nm__c = quoteWrapForContactDtls.secondaryContact;
                        quoteMap.get(quoteId).Pricing_Primary_Contact_Email__c = quoteWrapForContactDtls.primaryContactEmail;
                        quoteMap.get(quoteId).Pricing_Intel_Sales_Rep_Email_Txt__c = !String.isBlank(quoteWrapForContactDtls.intelSalesRepEmail) ?quoteWrapForContactDtls.intelSalesRepEmail : quoteMap.get(quoteWrapForContactDtls.quoteId).Pricing_Intel_Sales_Rep_Email_Txt__c;
                        quoteMap.get(quoteId).SBQQ__SalesRep__c = !String.isBlank(quoteWrapForContactDtls.intelSalesRepEmail) && Pricing_RestAPI_QuotesUtilityV2.validFSEEmailIdMap.containsKey(quoteWrapForContactDtls.intelSalesRepEmail) ?  Pricing_RestAPI_QuotesUtilityV2.validFSEEmailIdMap.get(quoteWrapForContactDtls.intelSalesRepEmail) :quoteMap.get(quoteWrapForContactDtls.quoteId).SBQQ__SalesRep__c;
                        quotesToUpdate.add(quoteMap.get(quoteId));
                    
                    update quotesToUpdate;
                SBQQ__Quote__c quote = [Select id, Name, Pricing_Customer_Reference_Id__c from SBQQ__Quote__c where id =:quotesToUpdate];
                response.totalRecords = 1;
                response.successContent = new List<updateQuotePrimaryContactDetails>();
                response.successContent.add(new updateQuotePrimaryContactDetails(String.valueOf(quote.Id),quote.Name,quote.Pricing_Customer_Reference_Id__c));
            }else{
                Pricing_RestAPI_Util.quoteErrMsgsV2 = qErrorMsg;
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }
          
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);            
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response,Pricing_RestAPI_QuotesUtilityV2.currentUser);            
        }
    } 
    /**
* @description validate request fields and update the record
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @param reqBody 
**/
    public static void processUpdateRequest(String reqBody){
        try {
            Pricing_RestAPI_QuotesUtilityV2.QuoteWrapper quote = (Pricing_RestAPI_QuotesUtilityV2.QuoteWrapper) JSON.deserialize(reqBody, Pricing_RestAPI_QuotesUtilityV2.QuoteWrapper.class);
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtilityV2 quoteUtility = new Pricing_RestAPI_QuotesUtilityV2();
            List<SBQQ__QuoteLine__c> qoteLines = new List<SBQQ__QuoteLine__c>();
            Map<String,Id> validFSEEmailIdMapDetails;
            List<Pricing_Performance_Metric__c> perfMetricsList = new List<Pricing_Performance_Metric__c>();
            boolean isValid = quoteUtility.validateQuote(quote, quoteErrors, true);//validate Quote, Quote Line, Performance Metrics, and Quote Comments 
            
            //if(Pricing_RestAPI_QuotesUtilityV2.isSvd && actionType.toLowerCase() == 'update'){
            if((!Pricing_RestAPI_QuotesUtilityV2.isSvd || TriggerHandler.isActive('Pricing_SVD_Quote_Disabled') && actionType.toLowerCase() == 'resubmit')|| actionType.toLowerCase() == 'update'){
                if(isValid){
                    SBQQ__Quote__c newQuote = Pricing_RestAPI_QuotesUtilityV2.createQuoteRecord(quote.quoteDetails);
                    newQuote.Id = quote.quoteId;
                    update newQuote;
                    List<Pricing_Quote_Team__c> quoteTeamInsertList = new List<Pricing_Quote_Team__c>();
                    if(Pricing_RestAPI_QuotesUtilityV2.validFSEEmailIdMap.size() > 1){
                        validFSEEmailIdMapDetails = new Map<String,Id>(Pricing_RestAPI_QuotesUtilityV2.validFSEEmailIdMap);
                        List<Pricing_Quote_Team__c> fseQTM = Pricing_RestAPI_QuotesUtilityV2.createFSEQuoteTeam(newQuote.Id);
                        if(fseQTM.size() > 0){
                            //insert fseQTM;
                            quoteTeamInsertList.addAll(fseQTM);
                        }
                    }
                    if(Pricing_RestAPI_QuotesUtilityV2.AEEmailUserList.size() > 1){
                        List<Pricing_Quote_Team__c> aeQTM = Pricing_RestAPI_QuotesUtilityV2.createAEQuoteTeam(newQuote.Id);
                        if(aeQTM.size() > 0){
                            //insert aeQTM;
                            quoteTeamInsertList.addAll(aeQTM);
                        }
                    }
                    if(Pricing_RestAPI_QuotesUtilityV2.ITSEmailUserList.size() > 0){
                        List<Pricing_Quote_Team__c> itsQTM = Pricing_RestAPI_QuotesUtilityV2.createITSQuoteTeam(newQuote.Id);
                        if(itsQTM.size() > 0){
                            //insert itsQTM;
                            quoteTeamInsertList.addAll(itsQTM);
                        }
                    }
                    if(quoteTeamInsertList.size()>0){
                        insert quoteTeamInsertList;
                    }
                    
                    Map<Id,SBQQ__QuoteLine__c> quoteLineIdMap;
                    if(quote.quoteDetails.quoteLines!=null){
                        qoteLines = Pricing_RestAPI_QuotesUtilityV2.createQuoteLineRecords(newQuote.Id, quote.quoteDetails.quoteLines);
                        Integer j = 0;
                        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineCPU qli : quote.quoteDetails.quoteLines.DataCenterCPU){
                            if(!String.isBlank(qli.quoteLineId)){
                                qoteLines[j].Id = qli.quoteLineId;
                            }
                            j++;
                        }
                        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineGPU qli : quote.quoteDetails.quoteLines.DataCenterGPU){
                            if(!String.isBlank(qli.quoteLineId)){
                                qoteLines[j].Id = qli.quoteLineId;
                            }
                            j++;
                        }
                        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineSSD qli : quote.quoteDetails.quoteLines.OptaneSSD){
                            if(!String.isBlank(qli.quoteLineId)){
                                qoteLines[j].Id = qli.quoteLineId;
                            }
                            j++;
                        }
                        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLinePMem qli : quote.quoteDetails.quoteLines.OptanePMem){
                            if(!String.isBlank(qli.quoteLineId)){
                                qoteLines[j].Id = qli.quoteLineId;
                            }
                            j++;
                        }
                        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineEthernet qli : quote.quoteDetails.quoteLines.Ethernet){
                            if(!String.isBlank(qli.quoteLineId)){
                                qoteLines[j].Id = qli.quoteLineId;
                            }
                            j++;
                        }
                        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineClient qli : quote.quoteDetails.quoteLines.Client){
                            if(!String.isBlank(qli.quoteLineId)){
                                qoteLines[j].Id = qli.quoteLineId;
                            }
                            j++;
                        }
                    }
                    Set<Id> qlIdSet = new Set<Id>();
                    if(qoteLines.size() > 0){
                        upsert qoteLines;               
                        for(SBQQ__QuoteLine__c ql:qoteLines){
                            qlIdSet.add(ql.Id);
                        }
                        quoteLineIdMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT id, Pricing_Quote_Line_Number__c,Pricing_Status_Nm__c,
                                                                        Pricing_Program_Type_Nm__c,RecordTypeId,Pricing_Ready_for_Review_cb__c,Pricing_Original_Submitted_By_Id__c,
                                                                        Pricing_Original_Submitted_Date_dt__c,Pricing_Last_Submitted_Date_dt__c,Pricing_Last_Submitted_By_Id__c,src_sys_id__c 
                                                                        FROM SBQQ__QuoteLine__c WHERE Id IN:qlIdSet]);
                        
                        Integer i = 0;                                                 
                        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineCPU qli : quote.quoteDetails.quoteLines.DataCenterCPU){
                            if(qli.performanceMetrics!=null) {
                                Pricing_RestAPI_QuotesUtilityV2.createPerformanceMetricsRecord(qoteLines[i].id, qli.performanceMetrics, perfMetricsList);
                                i++;
                            }
                        }
                    }else{
                        qoteLines = null;
                    }
                    if(perfMetricsList.size() > 0) {
                        upsert perfMetricsList;
                    }else{
                        perfMetricsList = null;
                    }
                    List<Pricing_Comments__c> qComments = Pricing_RestAPI_QuotesUtilityV2.createQuoteComments(newQuote.Id, quote.quoteDetails.quoteComments);
                    List<CreatedQuoteComments> commentDetails = new List<CreatedQuoteComments>();
                    if(qComments.size() > 0){
                        upsert qComments;
                        for(Pricing_Comments__c cmt: qComments){
                            commentDetails.add(new CreatedQuoteComments(cmt.Id, cmt.Pricing_Comment_Ref_Id__c));
                        }
                    }else{
                        commentDetails = null;
                    }
                    //update and submit quote
                    if(isResubmit){
                        //US1104158
                        Pricing_RestAPI_QuotesUtilityV2.publishQuoteAndQuoteLines(newQuote.Id, quote.quoteDetails.primaryContactEmail, Pricing_RestAPI_QuotesUtilityV2.currentUser.AccountId,quoteLineIdMap,validFSEEmailIdMapDetails,qlIdSet,'SBQQ__Quote__c');                         
                        
                    }
                    else if(!isResubmit && (!String.isBlank(quote.quoteDetails.primaryContactEmail) && Pricing_RestAPI_QuotesUtilityV2.currentUser.Email != quote.quoteDetails.primaryContactEmail)){
                        //Primary contact is not the currunet user
                        changePrimaryContact(newQuote.Id, quote.quoteDetails.primaryContactEmail, Pricing_RestAPI_QuotesUtilityV2.currentUser.AccountId);
                    }
                    
                    //creating response
                    Integer i = 0;
                    List<CreatedQuoteLineDetails> quotelineDetailsList = new List<CreatedQuoteLineDetails>();
                    if(quote.quoteDetails.quoteLines!=null){
                        Integer j = 0;
                        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineCPU qli : quote.quoteDetails.quoteLines.DataCenterCPU){
                            List<CreatedPMDetails> pmDetailsList = new List<CreatedPMDetails>();
                            if(qli.performanceMetrics!=null){
                                for(Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics pm : qli.performanceMetrics){
                                    pmDetailsList.add(new CreatedPMDetails(perfMetricsList[j].Id, pm.performanceMetricsReferenceId));
                                    j++;
                                }
                            }
                            if(pmDetailsList.size() == 0){
                                pmDetailsList = null;
                            }
                            quotelineDetailsList.add(new CreatedQuoteLineDetails(qoteLines[i].Id,quoteLineIdMap.get(qoteLines[i].id).Pricing_Quote_Line_Number__c, qli.quotelineReferenceID, pmDetailsList));
                            i++;
                        }
                        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineGPU qli : quote.quoteDetails.quoteLines.DataCenterGPU){
                            quotelineDetailsList.add(new CreatedQuoteLineDetails(qoteLines[i].Id,quoteLineIdMap.get(qoteLines[i].id).Pricing_Quote_Line_Number__c, qli.quotelineReferenceID, null));
                            i++;
                        }
                        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineSSD qli : quote.quoteDetails.quoteLines.OptaneSSD){
                            quotelineDetailsList.add(new CreatedQuoteLineDetails(qoteLines[i].Id,quoteLineIdMap.get(qoteLines[i].id).Pricing_Quote_Line_Number__c, qli.quotelineReferenceID, null));
                            i++;
                        }
                        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLinePMem qli : quote.quoteDetails.quoteLines.OptanePMem){
                            quotelineDetailsList.add(new CreatedQuoteLineDetails(qoteLines[i].Id,quoteLineIdMap.get(qoteLines[i].id).Pricing_Quote_Line_Number__c, qli.quotelineReferenceID, null));
                            i++;
                        }
                        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineEthernet qli : quote.quoteDetails.quoteLines.Ethernet){
                            quotelineDetailsList.add(new CreatedQuoteLineDetails(qoteLines[i].Id,quoteLineIdMap.get(qoteLines[i].id).Pricing_Quote_Line_Number__c, qli.quotelineReferenceID, null));
                            i++;
                        }
                        for(Pricing_RestAPI_QuotesUtilityV2.QuoteLineClient qli : quote.quoteDetails.quoteLines.Client){
                            quotelineDetailsList.add(new CreatedQuoteLineDetails(qoteLines[i].Id,quoteLineIdMap.get(qoteLines[i].id).Pricing_Quote_Line_Number__c, qli.quotelineReferenceID, null));
                            i++;
                        }
                    }
                    if(quotelineDetailsList.size()==0){
                        quotelineDetailsList = null;
                    }
                    SBQQ__Quote__c quoteNew = new SBQQ__Quote__c();
                    quoteNew = [Select id, Name, SBQQ__Status__c from SBQQ__Quote__c where id =:newQuote.Id];
                    response.totalRecords = 1;
                    response.successContent = new List<CreatedQuoteDetails>();
                    response.successContent.add(new CreatedQuoteDetails(String.valueOf(newQuote.Id),quoteNew.Name, quoteNew.SBQQ__Status__c , quote.quoteDetails.referenceRequestID, quotelineDetailsList, commentDetails));
                }else {
                    Pricing_RestAPI_Util.quoteErrMsgsV2 = quoteErrors;
                    Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                }
            }else{
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
		        response.errorContent.errorMessage = Label.Pricing_Tender_API_Quote_SVD_Resubmit_Error_Msg;
            }            
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);            
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response,Pricing_RestAPI_QuotesUtilityV2.currentUser);            
        }        
    }
    
    //------------------------------------------------------------------------------------------------------------------------------
    
    @HttpDelete
    global static Pricing_RestAPI_Response doDelete(){
        RestRequest req = RestContext.request;
        //currentUser = [Select Id,ContactId,AccountId,Email from User where Id = :UserInfo.getUserId()];
        if(validateDeleteParam()){
            processDeleteRequest(); 
        }else{
            //action is invalid
            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }
    /**
* @description validate delete API param
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @return boolean 
**/
    public static boolean validateDeleteParam(){
        
        recId = Pricing_RestAPI_Util.getRequestParam('id');
        return !String.isBlank(recId) && recId instanceOf Id ? true : false ;
    }
    /**
* @description validate request fields and delete the record
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 05-24-2022 
* @param reqBody 
**/
    public static void processDeleteRequest(){
        try {
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtilityV2 quoteUtility = new Pricing_RestAPI_QuotesUtilityV2();
            boolean isValid = quoteUtility.validateQuoteDelete(recId, quoteErrors);//validate Quote, Quote Line, Performance Metrics, and Quote Comments 
            
            if(isValid){
                Id currentUserid = userinfo.getUserId();
                List<Pricing_Comments__c> comList = new List<Pricing_Comments__c>();
                List<Pricing_Document__c> documentShareList = new List<Pricing_Document__c>();
                List<Pricing_Quote_Line_Status_Age__c> pricingTPTList = new List<Pricing_Quote_Line_Status_Age__c>();
                List<Pricing_Quote_Team__c> quoteTeamList = new List<Pricing_Quote_Team__c>();
                SBQQ__Quote__c quoteDel = [SELECT id,CreatedbyId,SBQQ__PrimaryContact__c,OwnerId from SBQQ__Quote__c where Id =:recId];
                comList = [SELECT id,Pricing_Quote__c FROM Pricing_Comments__c where Pricing_Quote__c =: recId];
                documentShareList = [SELECT id, Pricing_Quote_Id__c FROM Pricing_Document__c where Pricing_Quote_Id__c =: recId];
                pricingTPTList = [SELECT id FROM Pricing_Quote_Line_Status_Age__c where Pricing_TPT_Quote_Line_Number__r.SBQQ__Quote__c =: recId];
                quoteTeamList = [SELECT id, Pricing_Quote_Id__c FROM Pricing_Quote_Team__c where Pricing_Quote_Id__c =:recId];
                if(!comList.isEmpty()){
                    delete comList;
                }
                if(!documentShareList.isEmpty()){
                    delete documentShareList;
                }
                if(!pricingTPTList.isEmpty()){
                    delete pricingTPTList;
                }
                if(!quoteTeamList.isEmpty()){
                    delete quoteTeamList;
                }
                delete quoteDel; 
                String res = 'Record/s deleted successfully for Quote: '+recId;
                response.totalRecords = 1;
                response.successContent = new List<DeletedQuoteDetails>();
                response.successContent.add(new DeletedQuoteDetails(res));
                
            }else {
                Pricing_RestAPI_Util.quoteErrMsgsV2 = quoteErrors;
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }            
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);            
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response, Pricing_RestAPI_QuotesUtilityV2.currentUser);            
        }        
    }
    
    public class DeletedQuoteDetails implements Pricing_RestAPI_SuccessContent {
        String quote {set;get;}
        public DeletedQuoteDetails(String msg){
            quote = msg;
        }
    }
}