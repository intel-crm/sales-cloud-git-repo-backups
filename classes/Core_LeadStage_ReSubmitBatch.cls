global class Core_LeadStage_ReSubmitBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    global Database.QueryLocator start(Database.BatchableContext BC){
        String failedStatus = 'Failed';
        String query = 'select Id, Core_First_Name__c, Core_Last_Name__c, Core_Company__c, Core_Country__c, Core_State__c, PMP_Offering_ExpDelivery_Dt__c, Core_Lead_Notes__c, Core_Email__c, Core_Business_Phone__c, PMP_MDA_BizOrg_Id__c, Core_Partner_Name__c, PMP_Offering_Id__c, PMP_Offering_Referring_URL__c, PMP_MktProfile_BizSegment__c, Core_Notify_Owner__c, Core_Specific_Lead_Source__c, Core_Lead_PMP_Action__c, Core_Web_Visit_Session_ID__c, Core_Lead_Form_Submit_Date__c, Core_Lead_Source__c, Core_Lead_Conversion_Point__c, Core_MktCampaign_Id__c, Core_Marketing_Tactic_ID__c, Core_Source_Id__c, Core_Status__c from Core_Lead_Staging__c where Core_Status__c =: failedStatus';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Core_Lead_Staging__c> leadStageList){
        String userDetailsBody = '{"fieldValues": ';
        List<JsonSerializer> JsonSerializerList = new List<JsonSerializer>();
        Map<String, Core_Eloqua_Integration_Setting__mdt> eloquaIntMap = new Map<String, Core_Eloqua_Integration_Setting__mdt>();
        List<Core_Eloqua_Integration_Setting__mdt> eloquaIntList = [select Id, MasterLabel, DeveloperName, Core_Value__c from Core_Eloqua_Integration_Setting__mdt];
        system.debug('eloquaIntList '+eloquaIntList);
        for(Core_Eloqua_Integration_Setting__mdt eloquaInt : eloquaIntList){
            eloquaIntMap.put(eloquaInt.DeveloperName, eloquaInt);
        }
        JsonSerializer js = new JsonSerializer();
        String value;
        for(String eloquaInt : eloquaIntMap.keyset()){
            js = new JsonSerializer();
            js.type = 'FieldValue';
            js.id = eloquaIntMap.get(eloquaInt).MasterLabel;
            value = eloquaIntMap.get(eloquaInt).Core_Value__c;
            if(eloquaInt.equalsIgnoreCase('firstName') && leadStageList[0].Core_First_Name__c <> null){
                js.value = leadStageList[0].Core_First_Name__c;
            }
            if(eloquaInt.equalsIgnoreCase('lastName') && leadStageList[0].Core_Last_Name__c <> null){
                js.value = leadStageList[0].Core_Last_Name__c;
            }
            if(eloquaInt.equalsIgnoreCase('companyName') && leadStageList[0].Core_Company__c <> null){
                js.value = leadStageList[0].Core_Company__c;
            }
            /*if(eloquaInt.equalsIgnoreCase('jobFunction') && leadStageList[0].Core_Job_Title__c <> null){
                js.value = leadStageList[0].Core_Job_Title__c;
            }*/
            if(eloquaInt.equalsIgnoreCase('country') && leadStageList[0].Core_Country__c <> null){
                js.value = leadStageList[0].Core_Country__c;
            }
            if(eloquaInt.equalsIgnoreCase('state') && leadStageList[0].Core_State__c <> null){
                js.value = leadStageList[0].Core_State__c;
            }
            if(eloquaInt.equalsIgnoreCase('deliveryDate') && leadStageList[0].PMP_Offering_ExpDelivery_Dt__c <> null){
                js.value = String.valueOf(leadStageList[0].PMP_Offering_ExpDelivery_Dt__c);
            }
            if(eloquaInt.equalsIgnoreCase('leadNotes') && leadStageList[0].Core_Lead_Notes__c <> null){
                js.value = leadStageList[0].Core_Lead_Notes__c;
            }
            if(eloquaInt.equalsIgnoreCase('email') && leadStageList[0].Core_Email__c <> null){
                js.value = leadStageList[0].Core_Email__c;
            }
            if(eloquaInt.equalsIgnoreCase('phone') && leadStageList[0].Core_Business_Phone__c <> null){
                js.value = leadStageList[0].Core_Business_Phone__c;
            }
            if(eloquaInt.equalsIgnoreCase('volume') && leadStageList[0].Core_Lead_Quotation_Cnt__c <> null){
                js.value = String.valueOf(leadStageList[0].Core_Lead_Quotation_Cnt__c);
            }
            if(eloquaInt.equalsIgnoreCase('PartnerMDA_ID') && leadStageList[0].PMP_MDA_BizOrg_Id__c <> null){
                js.value = leadStageList[0].PMP_MDA_BizOrg_Id__c;
            }
            if(eloquaInt.equalsIgnoreCase('partnerName') && leadStageList[0].Core_Partner_Name__c <> null){
                js.value = leadStageList[0].Core_Partner_Name__c;
            }
            if(eloquaInt.equalsIgnoreCase('OfferingId') && leadStageList[0].PMP_Offering_Id__c <> null){
                js.value = leadStageList[0].PMP_Offering_Id__c;
            }
            if(eloquaInt.equalsIgnoreCase('Offering_Referring_URL') && leadStageList[0].PMP_Offering_Referring_URL__c <> ''){
                js.value = leadStageList[0].PMP_Offering_Referring_URL__c;
            }
            if(eloquaInt.equalsIgnoreCase('partnerProgramSegment') && leadStageList[0].PMP_MktProfile_BizSegment__c <> null){
                js.value = String.valueOf(leadStageList[0].PMP_MktProfile_BizSegment__c);
            }
            if(eloquaInt.equalsIgnoreCase('NotifyOwner')){
                js.value = value;
                //leadStageList[0].Core_Notify_Owner__c = Boolean.valueOf(value);
            }
            if(eloquaInt.equalsIgnoreCase('specificLeadSource')){
                js.value = value;
                //leadStageList[0].Core_Specific_Lead_Source__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('LeadAction') && leadStageList[0].Core_Lead_PMP_Action__c <> null){
                js.value = leadStageList[0].Core_Lead_PMP_Action__c;
            }
            if(eloquaInt.equalsIgnoreCase('WebVisitSessionId') && leadStageList[0].Core_Web_Visit_Session_ID__c <> null){
                js.value = leadStageList[0].Core_Web_Visit_Session_ID__c;
            }
            if(eloquaInt.equalsIgnoreCase('LeadFormSubmitDate') && leadStageList[0].Core_Lead_Form_Submit_Date__c <> null){
                js.value = String.valueOf(leadStageList[0].Core_Lead_Form_Submit_Date__c);
            }
            if(eloquaInt.equalsIgnoreCase('leadSource')){
                js.value = value;
                //leadStageList[0].Core_Lead_Source__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('leadConversionPoint')){
                js.value = value;
                //leadStageList[0].Core_Lead_Conversion_Point__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('sfdcCampaignID')){
                js.value = value;
                //leadStageList[0].Core_MktCampaign_Id__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('marketingTacticID')){
                js.value = value;
                //leadStageList[0].Core_Marketing_Tactic_ID__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('sourceID')){
                js.value = value;
                //leadStageList[0].Core_Source_Id__c = value;
            }
            
            if(js.value <> null){
                JsonSerializerList.add(js);
            }
        }
        
        String serializeData = JSON.serialize(JsonSerializerList);
        userDetailsBody = userDetailsBody + serializeData + '}';
        
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HTTPResponse httpResp = new HTTPResponse();
        
        httpReq.setEndpoint('callout:Core_IPALeadEloquaIntegration'); 
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setTimeout(120000);
        httpReq.setBody(userDetailsBody);
        httpResp = http.send(httpReq);
        //sendEmailNotification(formType,leadStageList[0],offeringName,partnerName);
        system.debug('Response body '+httpResp.getBody());
        System.debug('*STATUS_CODE:'+httpResp.getStatusCode());
        if(httpResp.getStatusCode() == 201){
            leadStageList[0].Core_Status__c = 'Success';
        }else{
            leadStageList[0].Core_Status__c = 'Failed';
            leadStageList[0].Core_Eloqua_Error__c = httpResp.getBody();
        }
        update leadStageList[0];
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    /*@AuraEnabled
    public static void submit(UserDetails user, String formType, String partnerId, String partnerName, String offeringId, String offeringName, String offeringRecId){
        String userDetailsBody = '{"fieldValues": ';
        List<JsonSerializer> JsonSerializerList = new List<JsonSerializer>();
        Map<String, Core_Eloqua_Integration_Setting__mdt> eloquaIntMap = new Map<String, Core_Eloqua_Integration_Setting__mdt>();
        List<Core_Eloqua_Integration_Setting__mdt> eloquaIntList = [select Id, MasterLabel, DeveloperName, Core_Value__c from Core_Eloqua_Integration_Setting__mdt];
        system.debug('eloquaIntList '+eloquaIntList);
        for(Core_Eloqua_Integration_Setting__mdt eloquaInt : eloquaIntList){
            eloquaIntMap.put(eloquaInt.DeveloperName, eloquaInt);
        }
        Core_Lead_Staging__c leadStageObj = new Core_Lead_Staging__c();
        JsonSerializer js = new JsonSerializer();
        String value;
        for(String eloquaInt : eloquaIntMap.keyset()){
            js = new JsonSerializer();
            js.type = 'FieldValue';
            js.id = eloquaIntMap.get(eloquaInt).MasterLabel;
            value = eloquaIntMap.get(eloquaInt).Core_Value__c;
            if(eloquaInt.equalsIgnoreCase('firstName') && user.firstName <> null){
                js.value = user.firstName;
                leadStageObj.Core_First_Name__c = user.firstName;
            }
            if(eloquaInt.equalsIgnoreCase('lastName') && user.lastName <> null){
                js.value = user.lastName;
                leadStageObj.Core_Last_Name__c = user.lastName;
            }
            if(eloquaInt.equalsIgnoreCase('companyName') && user.companyName <> null){
                js.value = user.companyName;
                leadStageObj.Core_Company__c = user.companyName;
            }*/
            /*if(eloquaInt.equalsIgnoreCase('jobFunction') && user.jobTitle <> null){
                js.value = user.jobTitle;
                leadStageObj.Core_Job_Title__c = user.jobTitle;
            }*/
            /*if(eloquaInt.equalsIgnoreCase('country') && user.country <> null){
                js.value = user.country;
                leadStageObj.Core_Country__c = user.country;
            }
            if(eloquaInt.equalsIgnoreCase('state') && user.state <> null){
                js.value = user.state;
                leadStageObj.Core_State__c = user.state;
            }
            if(eloquaInt.equalsIgnoreCase('deliveryDate') && user.deliveryDate <> null){
                js.value = String.valueOf(user.deliveryDate);
                leadStageObj.PMP_Offering_ExpDelivery_Dt__c = user.deliveryDate;
            }
            if(eloquaInt.equalsIgnoreCase('leadNotes') && user.description <> null){
                js.value = user.description;
                leadStageObj.Core_Lead_Notes__c = user.description;
            }
            if(eloquaInt.equalsIgnoreCase('email') && user.email <> null){
                js.value = user.email;
                leadStageObj.Core_Email__c = user.email;
            }
            if(eloquaInt.equalsIgnoreCase('phone') && user.phone <> null){
                js.value = user.phone;
                leadStageObj.Core_Business_Phone__c = user.phone;
            }
            if(eloquaInt.equalsIgnoreCase('volume') && user.volume <> null){
                js.value = String.valueOf(user.volume);
                leadStageObj.Core_Lead_Quotation_Cnt__c = String.valueOf(user.volume);
            }
            if(eloquaInt.equalsIgnoreCase('PartnerMDA_ID') && partnerId <> null){
                js.value = partnerId;
                leadStageObj.PMP_MDA_BizOrg_Id__c = partnerId;
            }
            if(eloquaInt.equalsIgnoreCase('partnerName') && partnerName <> null){
                js.value = partnerName;
                leadStageObj.Core_Partner_Name__c = partnerName;
            }
            if(eloquaInt.equalsIgnoreCase('OfferingId') && offeringId <> null){
                js.value = offeringId;
                leadStageObj.PMP_Offering_Id__c = offeringId;
            }
            if(eloquaInt.equalsIgnoreCase('Offering_Referring_URL') && offeringRecId <> null && offeringRecId <> ''){
                js.value = System.Label.Core_Marketplace_Url + '/s/offering/' + offeringRecId;
                leadStageObj.PMP_Offering_Referring_URL__c = System.Label.Core_Marketplace_Url + '/s/offering/'+ offeringRecId;
            }
            if(eloquaInt.equalsIgnoreCase('partnerProgramSegment') && user.partnerProgramSegment <> null){
                js.value = String.valueOf(user.partnerProgramSegment);
                leadStageObj.PMP_MktProfile_BizSegment__c = user.partnerProgramSegment;
            }
            if(eloquaInt.equalsIgnoreCase('NotifyOwner')){
                js.value = value;
                leadStageObj.Core_Notify_Owner__c = Boolean.valueOf(value);
            }
            if(eloquaInt.equalsIgnoreCase('specificLeadSource')){
                js.value = value;
                leadStageObj.Core_Specific_Lead_Source__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('LeadAction') && formType == 'quote'){
                js.value = 'Requested Quote';
                leadStageObj.Core_Lead_PMP_Action__c = 'Requested Quote';
            }
            if(eloquaInt.equalsIgnoreCase('LeadAction') && formType == 'contact'){
                js.value = 'Asked for Follow-Up';
                leadStageObj.Core_Lead_PMP_Action__c = 'Asked for Follow-Up';
            }
            if(eloquaInt.equalsIgnoreCase('WebVisitSessionId') && user.sessionId <> null){
                js.value = user.sessionId;
                leadStageObj.Core_Web_Visit_Session_ID__c = user.sessionId;
            }
            if(eloquaInt.equalsIgnoreCase('LeadFormSubmitDate')){
                js.value = String.valueOf(system.now());
                leadStageObj.Core_Lead_Form_Submit_Date__c = system.now();
            }
            if(eloquaInt.equalsIgnoreCase('leadSource')){
                js.value = value;
                leadStageObj.Core_Lead_Source__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('leadConversionPoint')){
                js.value = value;
                leadStageObj.Core_Lead_Conversion_Point__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('sfdcCampaignID')){
                js.value = value;
                leadStageObj.Core_MktCampaign_Id__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('marketingTacticID')){
                js.value = value;
                leadStageObj.Core_Marketing_Tactic_ID__c = value;
            }
            if(eloquaInt.equalsIgnoreCase('sourceID')){
                js.value = value;
                leadStageObj.Core_Source_Id__c = value;
            }
            
            if(js.value <> null){
                JsonSerializerList.add(js);
            }
        }
        
        String serializeData = JSON.serialize(JsonSerializerList);
        userDetailsBody = userDetailsBody + serializeData + '}';
        
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HTTPResponse httpResp = new HTTPResponse();
        
        httpReq.setEndpoint('callout:Core_IPALeadEloquaIntegration'); 
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setTimeout(120000);
        httpReq.setBody(userDetailsBody);
        httpResp = http.send(httpReq);
        sendEmailNotification(formType,leadStageObj,offeringName,partnerName);
        system.debug('Response body '+httpResp.getBody());
        System.debug('*STATUS_CODE:'+httpResp.getStatusCode());
        if(httpResp.getStatusCode() == 201){
            leadStageObj.Core_Status__c = 'Success';
        }else{
            leadStageObj.Core_Status__c = 'Failed';
            leadStageObj.Core_Eloqua_Error__c = httpResp.getBody();
        }
        insert leadStageObj;
    }*/
    
    public class JsonSerializer{
        public String type;
        public String id;
        public String value;
    }
}