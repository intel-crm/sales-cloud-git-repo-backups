/**
 * @description       :
 * @author            : Rajesh Gajul
 * @group             :
 * @last modified on  : 09-26-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public without sharing class Pricing_MyDeals_Integration {
    public class CustomException extends Exception {}
    public static Map<String,Id> sObjectNameToRecordIdMap = new Map<String,Id>();
    @InvocableMethod(label='sendPayloadToMydeals' description='To send payloads to myDeals')
    public static void sendPayloadToMydeals(List<Id> OBMIds){
        /*for(Id obmId : OBMIds){
            makeCallout(obmId);
        }*/
        makeCallout(OBMIds);
    }
    
    @Future(callout=True)
    public static void makeCallout(List<Id> OBMIds){
        /*//Pricing_Integration_Staging__c
        List<Pricing_Integration_Staging__c> obms = [SELECT id,Name,Pricing_Payload__c,Pricing_Retry_Number__c,Pricing_Status__c, Pricing_Bulk_ChangeRequest_chk__c 
FROM Pricing_Integration_Staging__c WHERE Id=:OBMId];
        if(obms.size() > 0){
            //Integer retryCounter = 0;
            If(!obms[0].Pricing_Bulk_ChangeRequest_chk__c){
                sendPayload(obms[0], 0);
            }
        }*/
        for(Pricing_Integration_Staging__c obms : [SELECT id,Name,Pricing_Payload__c,Pricing_Retry_Number__c,Pricing_Status__c, Pricing_Bulk_ChangeRequest_chk__c FROM Pricing_Integration_Staging__c WHERE Id In :OBMIds]){
            If(!obms.Pricing_Bulk_ChangeRequest_chk__c){
                sendPayload(obms, 0);
            }
        }
    }
    public static void updateStatus(Pricing_Integration_Staging__c obm, String status){
        obm.Pricing_Status__c = status;
        obm.Pricing_Retry_Number__c = (obm.Pricing_Retry_Number__c==null) ? 1 : obm.Pricing_Retry_Number__c+1;
        //obm.Pricing_Retry_Time_Stamp__c = System.now();
        update obm;
        if(obm.Pricing_Status__c == 'Failed' && obm.Pricing_Retry_Number__c > 2) {
            createLogEntry(obm);
        }
    }
    public static void sendPayload(Pricing_Integration_Staging__c obm, Integer retryCounter){
        //Integer retryCounter = 0;
        try{
            if(retryCounter==3){
                updateStatus(obm, 'Failed');
                return;
            }
        }catch(Exception exp){
            Pricing_Tender_Utility.logError(exp);
            return;
        }
        
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:APIGEE_MyDeals');
            req.setMethod('POST');
            req.setHeader('Content-Type' , 'application/json');
            req.setBody(obm.Pricing_Payload__c);
            req.setTimeout(Integer.valueOf(Label.Pricing_MyDeals_Timeout_Duration));
            HttpResponse resp = new Http().send(req);
            if(resp.getStatus() == 'SUCCESS' || resp.getStatus() == 'OK'){
                //throw new CustomException('Test Error');
                insertInboundMessage(resp.getBody());
                updateStatus(obm, 'Successful');
            }else{
                retryCounter++;
                sendPayload(obm,retryCounter);
            }
        }catch(Exception exp){
            retryCounter++;
            sendPayload(obm,retryCounter);
            Pricing_Tender_Utility.logError(exp);
        }
    }
    
    public static void insertInboundMessage(String payload){
        try{
            Pricing_JSONString jsonMap = (Pricing_JSONString) System.JSON.deserialize(payload, Pricing_JSONString.class);
            List<Core_Integration_Inbound_Message__c> iimList = new List<Core_Integration_Inbound_Message__c>();
            Core_Integration_Inbound_Message__c iim = new Core_Integration_Inbound_Message__c();
            String tag = jsonMap.RecordDetails.Quote.Id != null ? jsonMap.RecordDetails.Quote.Id + ' - ' : '';
            if(jsonMap.RecordDetails.Quote.QuoteLine != null && jsonMap.RecordDetails.Quote.QuoteLine.Size() > 0){
                tag += jsonMap.RecordDetails.Quote.QuoteLine[0].Id;
            }
            iim.Core_Payload__c = JSON.serialize(jsonMap);
            iim.Core_Message_Type__c = jsonMap.Header.target_system;
            iim.Core_Processing_Status__c = 'Successful';
            iim.Core_Error_Code__c = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200;
            iim.Core_Source_System__c = jsonMap.Header.source_system;
            iim.Core_Tags__c = tag;
            iimList.add(iim);
            Database.insert(iimList, true);
        }catch(Exception exp){
            Pricing_Tender_Utility.logError(exp);
        }
    }
    
    public static void createLogEntry(Pricing_Integration_Staging__c obm) {
        Map<String,String> errorMap = new Map<String,String>();
        Map<String,Id> sObjectNameToRecordIdMap = new Map<String,Id>();
        errorMap.put(obm.Name,Label.Pricing_Tender_Staging_Outbound_Failed_Error);
        List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
        if(!errorMap.isEmpty()){
            logEntryList.addAll(Pricing_Tender_Utility.logErrorinLogObjectIntegration(errorMap,sObjectNameToRecordIdMap,'Critical'));
        }
        if(logEntryList.size() > 0){
            insert logEntryList;
        }
    }
    
    /*
    //Pricing_MyDeals_Integration.sendPayloadToMydeals();
    public static void sendPayloadToMydeals(){
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:APIGEE_MyDeals');
            req.setMethod('POST');
            req.setHeader('Content-Type' , 'application/json');
            String json = '{"RecordDetails":{"Quote":{"ShipmentStartDate":"2020-08-31","ShipmentEndDate":"2020-09-04","ServerDealType":"Storage","Region":"EMEA","QuoteLine":[{"WWID":null,"Status":"Pending Further Intel Review","ReferenceQuoteLineNumber":null,"QuoteLineNumber":"Q-00636-011","Product":{"ProductNameEPMID":"91154","Name":"Intel® Core™ i3-6167U Processor (3M Cache, 2.70 GHz)","Id":"01t1J00000AptbpQAB"},"PerformanceMetric":[{"Weighting":null,"PerformanceMetric":"LAMMPS","Name":"PM - 00002516","IntelSKUPerformance":1.00,"Id":"a8d2i00000005iuAAA","CompSKUPerformance":1.00}],"OtherProduct":null,"OtherCompetitorProduct":null,"Name":"QL-0002790","MeetCompPrice":10.00,"MarketSegment":"Corp;SMB;Education","IntegrationStatus":null,"Id":"a7k2i0000008RnZAAU","GroupType":"Mutually Exclusive","ExcludeAutomation":false,"ErrorMessages":null,"DealRFQStatus":null,"DealRFQId":null,"CompetitorProduct":{"Name":"1S AMD EPYC 3451 (32M Cache, 16C, 2.15GHz/2.45GHz), 100W","Id":"a8c2i000000CadrAAC"},"BillingStartDate":"2020-08-31","BillingEndDate":"2020-09-30","BackdateReason":"Data Entry Error","ApprovedStartDate":"2020-08-31","ApprovedQuantity":100,"ApprovedEndDate":"2020-09-30","ApprovedECAPPrice":200.00,"ApprovedByInfo":null,"AdditionalTandC":null}],"ProjectName":"Test","Name":"Q-00636","Id":"a7o2i000000CcYcAAK","FolioName":"DELL INC. - EMEA - Test-1","FolioID":"7055","EndCustomerCountry":"Andorra","EndCustomer":"Test","DealType":"ECAP","Account":{"Name":"DELL INC.","Id":"001o000000O6IBjAAN","CIMId":"23544531"}}},"Header":{"xid":"e6770e4f-edd2-d118-de66-867af9583059","target_system":"MyDeals","source_system":"Tender","action":"Create"}}';
            req.setBody(json);
            HttpResponse resp = new Http().send(req);
        }catch(Exception exp){
            Pricing_Tender_Utility.logError(exp);
        }
    }
     */
}