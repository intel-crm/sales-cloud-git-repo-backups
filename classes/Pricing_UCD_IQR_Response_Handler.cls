/****************************************************************************************************
Apex Class Name : Pricing_UCD_IQR_Response_Handler
Version         : 1.0 
Created Date    : -
Function        : This class is used to process the UCD responses from ACM
Modifications   :
*****************************************************************************************************
* Developer : Grishma/Anjali                               
*****************************************************************************************************/

public without sharing class Pricing_UCD_IQR_Response_Handler {
    public static id QueueId ;
    //Process the ACM_Account_Change_Event__e event responses
    public static void processACMResponseForUnification (List<ACM_Account_Change_Event__e> acmAccChangeEventList) {     
        try{ 
            List<Pricing_UCD_ResponseWrapper.ResponseData> ucdResponseObjectList = new List<Pricing_UCD_ResponseWrapper.ResponseData>();
            List<Pricing_UCD_ResponseWrapper.ResponseData> ucdRejectedResponseObjList = new List<Pricing_UCD_ResponseWrapper.ResponseData>();
            if(acmAccChangeEventList.size() > 0) {
                for(ACM_Account_Change_Event__e acmAccChangeEventRec: acmAccChangeEventList){                    
                    if(acmAccChangeEventRec.Headers__c != null && acmAccChangeEventRec.Message__c != null){
                        Pricing_UCD_ResponseWrapper.Header header = (Pricing_UCD_ResponseWrapper.Header)System.JSON.deserialize(acmAccChangeEventRec.Headers__c, Pricing_UCD_ResponseWrapper.Header.class);
                        
                        if(header.CustomerAggregationType != null && header.CustomerProcessEngagement != null) {
                            if(header.CustomerAggregationType == Label.Pricing_UCD_Customer_Aggregation_Type &&  header.CustomerProcessEngagement.contains(Label.Pricing_UCD_Customer_Process_Engagement)) {
                                Pricing_UCD_ResponseWrapper.ResponseData jsonResponseObject = (Pricing_UCD_ResponseWrapper.ResponseData)System.JSON.deserialize(acmAccChangeEventRec.Message__c, Pricing_UCD_ResponseWrapper.ResponseData.class);

                                //check all the conditions for rejected account scenario if all condition are met add to the rejected response list else to normal response list
                                if (String.isNotBlank(jsonResponseObject.RecordType) && jsonResponseObject.RecordType == Label.Pricing_UCD_Record_Type_Rejected_Account && String.isNotBlank(jsonResponseObject.SurvivorAccountId)) {
                                    ucdRejectedResponseObjList.add(jsonResponseObject);
                                } 
                                //Responses with record type as End customer deal account (Normal Requests)
                                else if (String.isNotBlank(jsonResponseObject.RecordType) && jsonResponseObject.RecordType == Label.Pricing_UCD_Account_Record_Type){
                                    ucdResponseObjectList.add(jsonResponseObject);
                                }
                            }
                        }
                    }
                }
                if(ucdResponseObjectList.size()>0){
                    processUCDResponses(ucdResponseObjectList);
                }
                if(ucdRejectedResponseObjList.size() > 0) {
                    processRejectedResponses(ucdRejectedResponseObjList);
                }
            }           
        }catch(Exception ex){Pricing_Tender_Utility.logError(ex);}
    }
    
    public static void processUCDResponses(List<Pricing_UCD_ResponseWrapper.ResponseData> ucdResponseObjectList) {
        List<Pricing_UCD_ResponseWrapper.ResponseData> ucdResponseValidObjectList = new List<Pricing_UCD_ResponseWrapper.ResponseData>();
        Map<String,String> l2IdL1IdResponseMap= new Map<String,String>(); //Map of L2 Id and L1 Id from UCD Responses
        Map<String,Map<String,String>> l1IdAccountIdsMap = new Map<String,Map<String,String>>(); //Map of L1 Ids and Map of Account Id and L1 Obj Id for Unique Check
        Map<String,Pricing_UnifiedEndCustomerCountryMapping__c> l2IdL2ObjRecordMap = new Map<String,Pricing_UnifiedEndCustomerCountryMapping__c>();  //Map of L2 id with L2 object record for Unique Check
        Set<String> ucdResponseAccountIdSet = new Set<String>(); //Set of RequestIds from UCD
        Map<String,List<String>> requestIdToQuoteIdsMap = new Map<String,List<String>>(); //Map of RequestIds to List of Quote Ids
        Map<String,String> quoteIdsToRequestIdMap = new Map<String,String>();  //Map of quoteIds to Request Ids
        //Map<String,SBQQ__Quote__c> quoteIdQuoteRecMap = new Map<String,SBQQ__Quote__c>(); //Map of Quote Id to Quote Record
        Map<String,String> quoteIdAccountCountryMap = new Map<String,String>(); //Map Quote Id to Quote Account : Quote Country
        Map<String,String> requestIdL2IdMap = new Map<String,String>(); //Map of request Id to L2 Id
        Set<String> quoteIdsToBeUnified = new Set<String>(); //Set of Quote Ids that are not unified
        List<Pricing_UnifiedEndCustomerAccountMapping__c> l1ToInsertList = new List<Pricing_UnifiedEndCustomerAccountMapping__c>(); //List of L1 object records to be inserted
        List<Pricing_UnifiedEndCustomerCountryMapping__c> l2ToInsertList = new List<Pricing_UnifiedEndCustomerCountryMapping__c>(); //List of L2 object records to be inserted 
        List<Pricing_UnifiedEndCustomerCountryMapping__c> l2RecordsCWLToUpdateList = new List<Pricing_UnifiedEndCustomerCountryMapping__c>(); //List of L2 object records to be updated
        Map<String,String> l2l1IdInsertedMap = new Map<String,String>(); //Map of L2 Id to L1 Id of newly inserted records
        //Set<String> cwlUcdResponse = new Set<String>();
        //String cwlListString = '';
        Map<String, String> requestIdToCountryMap = new Map<String,String>();// Map of Account/Request Id from UCD to Country in the response.
        List<String> countryMismatchRequestIds = new List<String>(); //List of Account/Request Ids where country is mismatched.

        if(ucdResponseObjectList.size() > 0) {
            for(Pricing_UCD_ResponseWrapper.ResponseData ucdResponseObj : ucdResponseObjectList) {
                //Check if required attributes are present
                if(String.isNotBlank(ucdResponseObj.AccountId) && String.isNotBlank(ucdResponseObj.AccountName) && String.isNotBlank(ucdResponseObj.BusinessPartyIdentifier)
                   && ucdResponseObj.ParentAccount != null && String.isNotBlank(ucdResponseObj.ParentAccount.BusinessPartyIdentifier) && String.isNotBlank(ucdResponseObj.MasteredSimplifiedAccountName) && 
                   String.isNotBlank(ucdResponseObj.SecondaryAddress.CountryName)) {
                    ucdResponseValidObjectList.add(ucdResponseObj);
                    requestIdToCountryMap.put(ucdResponseObj.AccountId,ucdResponseObj.SecondaryAddress.CountryName);
                    if(!ucdResponseAccountIdSet.contains(ucdResponseObj.AccountId)){
                        ucdResponseAccountIdSet.add(ucdResponseObj.AccountId);
                    }
                    if(!l2IdL1IdResponseMap.containsKey(ucdResponseObj.BusinessPartyIdentifier)){
                        l2IdL1IdResponseMap.put(ucdResponseObj.BusinessPartyIdentifier,ucdResponseObj.ParentAccount.BusinessPartyIdentifier);
                    }
                }                         
            }
            //Create Map of Quote Ids with Account Ids(Request Ids) received from UCD
            if(ucdResponseAccountIdSet.size() > 0) {
                List<Pricing_Integration_Staging__c> ucdPISRecordList = [SELECT Id,Pricing_RequestID__c,Pricing_SObjectId__c,Pricing_Message_Type__c,Pricing_Status__c,Pricing_UCD_Response_Type__c,Pricing_QuoteID__c,
                                                                        Pricing_QuoteID__r.Name,Pricing_QuoteID__r.SBQQ__Account__c,Pricing_QuoteID__r.Pricing_End_Customer_Name__c,Pricing_QuoteID__r.Pricing_End_Customer_Country_Nm__c,Pricing_QuoteID__r.Pricing_Status_Precedence_Number__c,
                                                                        Pricing_QuoteID__r.Pricing_IsUnifiedCustomer__c FROM Pricing_Integration_Staging__c WHERE Pricing_RequestID__c IN:ucdResponseAccountIdSet AND 
                                                                        Pricing_Message_Type__c = 'UnifiedEndCustomer' AND Pricing_Status__c = 'Successful' AND
                                                                        Pricing_UCD_Response_Type__c IN: Label.Pricing_UCDResponseType_AllPicklistValues_Except_Resubmitted.split(',') order by CreatedDate desc ];
                if(ucdPISRecordList.size() > 0) {
                    for(Pricing_Integration_Staging__c pisRec: ucdPISRecordList) {
                        //Map of QuoteIds to RequestIds
                        if(!quoteIdsToRequestIdMap.containsKey(pisRec.Pricing_SObjectId__c)) {
                            quoteIdsToRequestIdMap.put(pisRec.Pricing_SObjectId__c,pisRec.Pricing_RequestID__c);
                        }
                        //Map of requestIds to List of QuoteIds
                        if(!requestIdToQuoteIdsMap.containsKey(pisRec.Pricing_RequestID__c)) {
                            requestIdToQuoteIdsMap.put(pisRec.Pricing_RequestID__c,new List<String> {pisRec.Pricing_SObjectId__c});
                        }else if(requestIdToQuoteIdsMap.containsKey(pisRec.Pricing_RequestID__c) ) {
                            if(!requestIdToQuoteIdsMap.get(pisRec.Pricing_RequestID__c).contains(pisRec.Pricing_SObjectId__c)) {
                                requestIdToQuoteIdsMap.get(pisRec.Pricing_RequestID__c).add(pisRec.Pricing_SObjectId__c);
                            }  
                        }    
                        
                        if(pisRec.Pricing_QuoteID__r.Pricing_Status_Precedence_Number__c!= 10 && pisRec.Pricing_QuoteID__r.Pricing_IsUnifiedCustomer__c!=true) {
                            quoteIdsToBeUnified.add(pisRec.Pricing_QuoteID__c); 
                            //Map of quote ids to quote account : quote country
                            if(!quoteIdAccountCountryMap.containsKey(pisRec.Pricing_QuoteID__c)) {
                                quoteIdAccountCountryMap.put(pisRec.Pricing_QuoteID__c,pisRec.Pricing_QuoteID__r.SBQQ__Account__c+':'+pisRec.Pricing_QuoteID__r.Pricing_End_Customer_Country_Nm__c);
                            }
                            if(requestIdToCountryMap.containsKey(pisRec.Pricing_RequestID__c) && (requestIdToCountryMap.get(pisRec.Pricing_RequestID__c) != pisRec.Pricing_QuoteID__r.Pricing_End_Customer_Country_Nm__c)) {
                                //Set of Request Ids with Quote country mismatch
                                if(!countryMismatchRequestIds.contains(pisRec.Pricing_RequestID__c)) {
                                    countryMismatchRequestIds.add(pisRec.Pricing_RequestID__c);           
                                }
                            }
                        }
                    }
                }
            }

            if(!l2IdL1IdResponseMap.isEmpty()){
                //Query the existing L1 Id records from database for unique check (1111=>(Dell,SFID),(HPE,SFID))
                for(Pricing_UnifiedEndCustomerAccountMapping__c l1ObjRec : [SELECT Id,Name,Pricing_Account_Nm__c,Pricing_Unified_EndCustomer_Id__c FROM Pricing_UnifiedEndCustomerAccountMapping__c 
                                                                            WHERE Pricing_Unified_EndCustomer_Id__c IN :l2IdL1IdResponseMap.values()]){
                                                                                if(!l1IdAccountIdsMap.containsKey(l1ObjRec.Pricing_Unified_EndCustomer_Id__c)){
                                                                                    l1IdAccountIdsMap.put(l1ObjRec.Pricing_Unified_EndCustomer_Id__c,new Map<String,String>{l1ObjRec.Pricing_Account_Nm__c => l1ObjRec.Id});
                                                                                }else if(!l1IdAccountIdsMap.get(l1ObjRec.Pricing_Unified_EndCustomer_Id__c).containsKey(l1ObjRec.Pricing_Account_Nm__c)){
                                                                                    l1IdAccountIdsMap.get(l1ObjRec.Pricing_Unified_EndCustomer_Id__c).put(l1ObjRec.Pricing_Account_Nm__c,l1ObjRec.Id);
                                                                                }
                                                                            }
                //Query the existing L2 Id records from database for unique check (l2Id==>l2 object record)
                for(Pricing_UnifiedEndCustomerCountryMapping__c l2ObjRec : [SELECT Id,Name,Pricing_Unified_EndCustomer_Id__c,Pricing_Unified_Country_EndCustomer_Id__c,Pricing_Compliance_Watch_List__c ,Pricing_RequestID__c
                                                                            FROM Pricing_UnifiedEndCustomerCountryMapping__c WHERE Pricing_Unified_Country_EndCustomer_Id__c IN:l2IdL1IdResponseMap.keySet() ]){
                                                                                if(!l2IdL2ObjRecordMap.containsKey(l2ObjRec.Pricing_Unified_Country_EndCustomer_Id__c)) {
                                                                                    l2IdL2ObjRecordMap.put(l2ObjRec.Pricing_Unified_Country_EndCustomer_Id__c,l2ObjRec);
                                                                                }
                                                                            }
            }
            
            if(ucdResponseObjectList.Size()>0){
                QueueId = [select Id from Group where Type = 'Queue' and DeveloperName = 'Pricing_L1_L2_Owner_Queue'].id;
            }

            for(Pricing_UCD_ResponseWrapper.ResponseData ucdResponseObj : ucdResponseValidObjectList) {
                Set<String> cwlUcdResponse = new Set<String>();
                String cwlListString = '';
                if(!countryMismatchRequestIds.contains(ucdResponseObj.AccountId)){   //Check if country mismatch
                    //CHeck the compliance watch list
                    if(ucdResponseObj.ComplianceWatchList!=null && ucdResponseObj.ComplianceWatchList.size()>0){ 
                        for(Pricing_UCD_ResponseWrapper.ComplianceWatchList cwl:ucdResponseObj.ComplianceWatchList) {
                            if(!cwlUcdResponse.contains(cwl.Code)){
                                cwlUcdResponse.add(cwl.Code);
                                if(cwlListString == ''){
                                    cwlListString = cwl.Code;
                                } else {
                                    cwlListString += ';' + cwl.Code; 
                                }
                            }
                        }
                    }
                    if(ucdResponseObj.ComplianceStatus!=null){
                            if(!cwlUcdResponse.contains(ucdResponseObj.ComplianceStatus)){
                                cwlUcdResponse.add(ucdResponseObj.ComplianceStatus);
                                if(cwlListString == ''){
                                    cwlListString = ucdResponseObj.ComplianceStatus;
                                } else {
                                    cwlListString += ';' + ucdResponseObj.ComplianceStatus;
                                }
                            }
                    }
                    //Creation of L1,L2 records 
                    //Insert L1 records
                    if(requestIdToQuoteIdsMap.size()>0 && requestIdToQuoteIdsMap.containsKey(ucdResponseObj.AccountId)) {
                        for(String quoteId : requestIdToQuoteIdsMap.get(ucdResponseObj.AccountId)) { 
                            if(quoteIdAccountCountryMap.containsKey(quoteId)){
                                String accountId = quoteIdAccountCountryMap.get(quoteId).split(':')[0];//.SBQQ__Account__c ;
                                Pricing_UnifiedEndCustomerAccountMapping__c newEndCustAccountL1 = new Pricing_UnifiedEndCustomerAccountMapping__c();
                                newEndCustAccountL1 = createEndCustomerAccountMapping(ucdResponseObj,l1IdAccountIdsMap,accountId);
                                if(newEndCustAccountL1 != null) {
                                    if(!l1ToInsertList.contains(newEndCustAccountL1)) {
                                        l1ToInsertList.add(newEndCustAccountL1);
                                    }
                                }
                            }
                        } 
                    
                        //Insert L2 records
                        if(!l2IdL2ObjRecordMap.containskey(ucdResponseObj.BusinessPartyIdentifier)){ // l2 not present
                            //Insert L2 records
                            if(quoteIdAccountCountryMap.containsKey(requestIdToQuoteIdsMap.get(ucdResponseObj.AccountId)[0])) {
                                Pricing_UnifiedEndCustomerCountryMapping__c newEndCustCountryL2 = new Pricing_UnifiedEndCustomerCountryMapping__c();
                                newEndCustCountryL2.Name = ucdResponseObj.MasteredSimplifiedAccountName;
                                newEndCustCountryL2.Pricing_Country_Nm__c = quoteIdAccountCountryMap.get(requestIdToQuoteIdsMap.get(ucdResponseObj.AccountId)[0]).split(':')[1];
                                //quoteIdCountryMap.get(requestIdToQuoteIdsMap.get(ucdResponseObj.AccountId)[0]);//.Pricing_End_Customer_Country_Nm__c; //ucdResponseObj.PrimaryAddress.CountryName;
                                newEndCustCountryL2.Pricing_Unified_Country_EndCustomer_Id__c = ucdResponseObj.BusinessPartyIdentifier;
                                newEndCustCountryL2.Pricing_RequestID__c = ucdResponseObj.AccountId;
                                newEndCustCountryL2.OwnerId = QueueId;
                                //Stamping of the CWL values
                                if(cwlUcdResponse.size()>0 && cwlUcdResponse!=null){   
                                    newEndCustCountryL2.Pricing_Compliance_Watch_List__c = cwlListString;
                                }
                                //Stamp L1 lookup value in L2 record for existing L1 record
                                if(l1IdAccountIdsMap.containsKey(ucdResponseObj.ParentAccount.BusinessPartyIdentifier)) { 
                                    newEndCustCountryL2.Pricing_Unified_EndCustomer_Act_Mapping__c = l1IdAccountIdsMap.get(ucdResponseObj.ParentAccount.BusinessPartyIdentifier).values()[0]; //Add existing L1 SF Id 
                                } else {
                                    newEndCustCountryL2.Pricing_Unified_EndCustomer_Act_Mapping__c = null;
                                }
                            
                                if(!l2ToInsertList.contains(newEndCustCountryL2)) {
                                    l2ToInsertList.add(newEndCustCountryL2);                      
                                }
                            }
                            
                            if(!l2l1IdInsertedMap.containsKey(ucdResponseObj.BusinessPartyIdentifier)){
                                l2l1IdInsertedMap.put(ucdResponseObj.BusinessPartyIdentifier,ucdResponseObj.ParentAccount.BusinessPartyIdentifier);
                            }
                        }
                        if(!requestIdL2IdMap.containsKey(ucdResponseObj.AccountId)) {
                            requestIdL2IdMap.put(ucdResponseObj.AccountId,ucdResponseObj.BusinessPartyIdentifier);
                        }
                    }
                    //Update the existing records with CWL values
                    if(cwlUcdResponse.size()>0 && l2IdL2ObjRecordMap.containsKey(ucdResponseObj.BusinessPartyIdentifier)) {
                        if(l2IdL2ObjRecordMap.get(ucdResponseObj.BusinessPartyIdentifier).Pricing_RequestID__c == ucdResponseObj.AccountId) {
                            List<String> existingCwlInL2 = new List<String>(); //List to store existing CWL values for L2 record
                            l2IdL2ObjRecordMap.get(ucdResponseObj.BusinessPartyIdentifier).Pricing_Compliance_Watch_List__c = cwlListString;
                            if(!l2RecordsCWLToUpdateList.contains(l2IdL2ObjRecordMap.get(ucdResponseObj.BusinessPartyIdentifier))){
                                l2RecordsCWLToUpdateList.add(l2IdL2ObjRecordMap.get(ucdResponseObj.BusinessPartyIdentifier));
                            }
                        } 
                    }    
                } 
                
            }
            
            //Insert l1 object records
            Map<String,String> l1Idl1SFIdMap = new Map<String,String>(); //Map of L1 Id to L1 SF Id for new L1 records
            if(l1ToInsertList.size() > 0){
                insert l1ToInsertList;
                for(Pricing_UnifiedEndCustomerAccountMapping__c l1Rec : l1ToInsertList){
                    if(!l1Idl1SFIdMap.containsKey(l1Rec.Pricing_Unified_EndCustomer_Id__c)){
                        l1Idl1SFIdMap.put(l1Rec.Pricing_Unified_EndCustomer_Id__c,l1Rec.Id);
                    }
                }
            }
            
            //Map newly created l1 object salesforce id to L2 object and create new l2 records
            Map<String,String> l2IdL2SFIDNewMap = new Map<String,String>(); //Map of End Cust Name to End Cust Country and SFID
            if(l2ToInsertList.size()>0){
                for(Pricing_UnifiedEndCustomerCountryMapping__c l2ObjRec: l2ToInsertList) {
                    if(l2ObjRec.Pricing_Unified_EndCustomer_Act_Mapping__c==null ){
                        l2ObjRec.Pricing_Unified_EndCustomer_Act_Mapping__c = l1Idl1SFIdMap.get(l2l1IdInsertedMap.get(l2ObjRec.Pricing_Unified_Country_EndCustomer_Id__c));
                    }
                }
                insert l2ToInsertList;
                //To map the quotes with new l2 records
                for(Pricing_UnifiedEndCustomerCountryMapping__c l2ObjRec: l2ToInsertList) {
                    if(!l2IdL2SFIDNewMap.containsKey(l2ObjRec.Pricing_Unified_Country_EndCustomer_Id__c)) {
                        l2IdL2SFIDNewMap.put(l2ObjRec.Pricing_Unified_Country_EndCustomer_Id__c, l2ObjRec.Id);
                    } 
                }
            }
            
            //Update Quotes with Unified Global End Customer i.e. L2 value
            if(quoteIdsToBeUnified.size() > 0) {
                List<SBQQ__Quote__c> quotesToBeUnifiedList = new List<SBQQ__Quote__c>();
                for(SBQQ__Quote__c quote: [SELECT Id,Pricing_Unified_Global_End_Customer_Nm__c FROM SBQQ__Quote__c
                                           WHERE Id IN:quoteIdsToBeUnified]) {
                    if(quoteIdsToRequestIdMap.containsKey(quote.Id)){
                        if(l2IdL2SFIDNewMap.containsKey(requestIdL2IdMap.get(quoteIdsToRequestIdMap.get(quote.Id)))) {
                            quote.Pricing_Unified_Global_End_Customer_Nm__c = l2IdL2SFIDNewMap.get(requestIdL2IdMap.get(quoteIdsToRequestIdMap.get(quote.Id)));
                        } else {
                            if(l2IdL2ObjRecordMap.containsKey(requestIdL2IdMap.get(quoteIdsToRequestIdMap.get(quote.Id)))){
                                quote.Pricing_Unified_Global_End_Customer_Nm__c = l2IdL2ObjRecordMap.get(requestIdL2IdMap.get(quoteIdsToRequestIdMap.get(quote.Id))).Id;
                            }
                        }
                        if(!quotesToBeUnifiedList.contains(quote)) {
                            quotesToBeUnifiedList.add(quote);
                        }
                    }    
                }
                update quotesToBeUnifiedList;
            }
            //Update exisiting CWL on existing L2 records
            if(l2RecordsCWLToUpdateList.size() > 0) {
                update l2RecordsCWLToUpdateList;
            } 
        }       
    }
    
    //Method to create End customer Account Mapping records(L1)
    public static Pricing_UnifiedEndCustomerAccountMapping__c createEndCustomerAccountMapping(Pricing_UCD_ResponseWrapper.ResponseData ucdResponseObj,Map<String,Map<String,String>> l1IdAccountIdsMap,String accountId ) {
        Boolean isL1Present = true; 
        if(l1IdAccountIdsMap.containsKey(ucdResponseObj.ParentAccount.BusinessPartyIdentifier)) {  //L1 present for different Accounts
            Set<String> existingL1AccountSet = l1IdAccountIdsMap.get(ucdResponseObj.ParentAccount.BusinessPartyIdentifier).keySet(); //Set of Account id for which L1 is present in database
            if(!existingL1AccountSet.contains(accountId)) {
                isL1Present = false;  //L1 not present for particular account
            }
        } else { //L1 not present for any account
            isL1Present = false;
        }
        if(!isL1Present) {
            Pricing_UnifiedEndCustomerAccountMapping__c newEndCustAccountL1 = new Pricing_UnifiedEndCustomerAccountMapping__c();
            newEndCustAccountL1.Name = ucdResponseObj.ParentAccount.MasteredSimplifiedAccountName;
            newEndCustAccountL1.Pricing_Account_Nm__c = accountId;  //To insert the L1 account for the Quote's account
            newEndCustAccountL1.Pricing_Active_cb__c = true;
            newEndCustAccountL1.Pricing_Unified_EndCustomer_Id__c = ucdResponseObj.ParentAccount.BusinessPartyIdentifier;
            newEndCustAccountL1.OwnerId = QueueId;
            return newEndCustAccountL1;
        } else {
            return null;
        }
    }

    //Method to process the publisher responses which are rejected and update the survior id and the PIS record status to Survivor Account
    public static void processRejectedResponses(List<Pricing_UCD_ResponseWrapper.ResponseData> ucdResponseObjectList) {
        Map<Id, Id> rejectedIdToSurvivorIdMap = new Map<Id, Id>();//rejected account Id ==> Survivor account Id
        List<Pricing_Integration_Staging__c> pisRecordsToUpdate = new List<Pricing_Integration_Staging__c> ();//PUS records to be updated with survivor acc id

        for(Pricing_UCD_ResponseWrapper.ResponseData responseObj : ucdResponseObjectList) {
            if(!rejectedIdToSurvivorIdMap.containsKey(responseObj.AccountId)) {
                rejectedIdToSurvivorIdMap.put(responseObj.AccountId, responseObj.SurvivorAccountId);
            }
        }

        for(Pricing_Integration_Staging__c pisRecord : [SELECT Id,Pricing_UCD_Response_Type__c,Pricing_RequestID__c FROM Pricing_Integration_Staging__c WHERE Pricing_RequestID__c IN : rejectedIdToSurvivorIdMap.keySet()]) {
            if(rejectedIdToSurvivorIdMap.containsKey(pisRecord.Pricing_RequestID__c)) {
                pisRecord.Pricing_RequestID__c = rejectedIdToSurvivorIdMap.get(pisRecord.Pricing_RequestID__c);
                pisRecord.Pricing_UCD_Response_Type__c = Label.Pricing_UCD_Type_Survivor_Account;
                pisRecordsToUpdate.add(pisRecord);
            }
        }

        if(pisRecordsToUpdate.size() > 0) {
            update pisRecordsToUpdate;
        }
    }

    //Methods lauched from flow "Pricing IQR UCD Process Rejected Request" when the response type is changed to Survivor Account and call the API for duplicate account
    @InvocableMethod(label='getSurvivorIdFromPIS' description='To get the Survivor Account Id')
    public static void getSurvivorIdFromPISSendRequest (List<Id> survivorAccIdList) {
        List<Id> survivorAccountIdList = new List<Id>();
        for(Id survivorId : survivorAccIdList) {
            if(!survivorAccountIdList.contains(survivorId)) {
                survivorAccountIdList.add(survivorId);
            }
        }

        //call the method which calls the api to UCD
        if(survivorAccountIdList.size() > 0) {
            Pricing_UCD_IQR_FormRequest.sendSurvivorRequest(survivorAccountIdList);
        }
        
    }
}