/****************************************************************************************************************************************
* Class Name  : PMP_PIMServiceCallout
* Version     : 1.0 
* Created Date: 02-13-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Gireesh                   02/13/2019                    Method 'serviceCallout' publish JSON to PIM
****************************************************************************************************************************************************************/


//IPA2.0:US-4497-1631_OfferingEOL
@isTest
public without sharing class PMP_PIMServiceCallout  { 


//    public static void isFuturepublishProduct (List<String> jsonStrings, List<String> methods, List<Id> offeringIds, List<String> pimProductIds, List<String> languageCodes, List<String> localeNames, Boolean isFuture, Boolean isTranslations){
//        // system.debug('isFuture:'+isFuture); 
//        //Boolean calloutResult=False;
//         if(isFuture){
//             publishProductAsync(jsonStrings,methods, offeringIds,pimProductIds, languageCodes,localeNames, isTranslations);
//         }else{
//             publishProductList(jsonStrings,methods, offeringIds,pimProductIds, languageCodes,localeNames, isTranslations);
//         }
//         //return calloutResult;
//     }

//     @future(callout=True)
//     public static void  publishProductAsync(List<String> jsonStrings, List<String> methods, List<Id> offeringIds, List<String> pimProductIds, List<String> languageCodes, List<String> localeNames, Boolean isTranslations) {
//         publishProductList(jsonStrings,methods, offeringIds,pimProductIds, languageCodes,localeNames, isTranslations);
//     }
    

//     public static void publishProductList(List<String> jsonStrings, List<String> methods, List<Id> offeringIds, List<String> pimProductIds, List<String> languageCodes, List<String> localeNames, Boolean isTranslations) {
//         /*Boolean isCalloutSuccessful=False;
//         List<Core_Log_Failed_Callout_Entry__c> logEntry;
//         logEntry= [Select Id,Core_Status__c, Core_sObjectId__c,Core_Retry_Count__c,LastModifiedDate from Core_Log_Failed_Callout_Entry__c   where Core_sObjectId__c=:offeringId and Core_Status__c = 'Investigating'];
//         */
//         List<PMP_Partner_Offering_json__c> offeringJsons=new List<PMP_Partner_Offering_json__c>();
//         //List<PMP_Partner_Offering__c> syncOfferings=new List<PMP_Partner_Offering__c>();
//         Map<Id, PMP_Partner_Offering__c> offeringMap = new Map<Id, PMP_Partner_Offering__c>();
//         for(Integer idx=0; idx<offeringIds.size(); idx++){
            
            
            
//             // system.debug('languageCode:'+languageCodes[idx]);
//             // system.debug('localeName:'+localeNames[idx]);
//             //system.debug('offeringId:'+offeringIds[idx]);
//             //system.debug('pimProductId:'+pimProductIds[idx]);
            
            
//             Http http = new Http();
//             HttpRequest request = new HttpRequest();
            
//             //Get credentails and end point from named value credentials 
//             if(methods[idx]==PMP_StaticConstants_Offering.POST && languageCodes[idx]!=null && localeNames[idx]!=null){
//                 request.setEndpoint('callout:PMP_PIMServiceNamedCredentials?language='+localeNames[idx]+'&locale_geo_id='+languageCodes[idx]);
//             }
//             else if(methods[idx]==PMP_StaticConstants_Offering.PUT && !String.isEmpty(pimProductIds[idx]) && languageCodes[idx]!=null && localeNames[idx]!=null){
//                 request.setEndpoint('callout:PMP_PIMServiceNamedCredentials/'+pimProductIds[idx]+'?language='+localeNames[idx]+'&locale_geo_id='+languageCodes[idx]);
//             }
            
//             request.setMethod(methods[idx]);
//             request.setTimeout(PMP_StaticConstants_Offering.TIME_OUT);
            
            
//             //Get the API-Key value from the custom settings
//             //PMP_Product_API_Key__c apiKey = PMP_Product_API_Key__c.getValues(PMP_StaticConstants_Offering.API_KEY); 
//             //request.setHeader(PMP_StaticConstants_Offering.API_KEY, apiKey.PMP_API_KEY__c);
//             request.setHeader(PMP_StaticConstants_Offering.CONTENT_TYPE, PMP_StaticConstants_Offering.CONTENT_TYPE_JSON);
            
            
//             HttpResponse response;
//             //PMP_Partner_Offering__c offering;
//             PMP_Partner_Offering__c offering = new PMP_Partner_Offering__c();
//             offering.Id = offeringIds[idx];            
//             try{
//                 request.setBody(jsonStrings[idx]);
//                      //system.debug('jsonStrings[idx] PPPP.....'+jsonStrings[idx]);  
//                 //publish constructed JSON to PIM
//                 response = http.send(request);
//                 //system.debug('response:'+response.getBody());
                
//                 if (response!=Null && response.getStatusCode() == 200) {
                    
//                     JSONParser parser=JSON.createParser(response.getBody());
//                     string returnValue;
//                     Boolean status=False;
      
//                     while (parser.nextToken() != null) {
//                         //if current token==status
//                         if (parser.getText() == PMP_StaticConstants_Offering.STATUS) {
//                             // Get the value.
//                             parser.nextToken();    
//                             status=True;                          
//                             //if current token==success or token==fail ex: {status:success} or {status:fail} then store it in variable
//                             if(parser.getText()==PMP_StaticConstants_Offering.SUCCESS ){
//                                 //isCalloutSuccessful=True;
//                                 returnValue=parser.getText();
//                             }
//                             else{
//                                 if(returnValue!=PMP_StaticConstants_Offering.SUCCESS){
//                                     //system.debug('else:case:'+parser.getText());
//                                     //isCalloutSuccessful=False;
//                                     //system.debug('failed:outofSync');
//                                     offering.PMP_Partner_Offering_Sync_Status_Nm__c=PMP_StaticConstants_Offering.OUT_OF_SYNC;
//                                     //syncOfferings.add(offering);
//                                     offeringMap.put(offering.Id, offering);
//                                     /*if (Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()){
//                                         update offering;
//                                     }*/  
//                                 }   
//                             } 
//                         }             
//                         //if the {status:success}  and product_no has value, then set the PIM Product Id and PIM Status
//                         else if(returnValue==PMP_StaticConstants_Offering.SUCCESS && parser.getText()==PMP_StaticConstants_Offering.PRODUCT_NO){
//                             parser.nextToken();
//                             offering.PMP_Partner_Offering_Id__c=parser.getText();
//                             offering.PMP_Partner_Offering_Sync_Status_Nm__c=PMP_StaticConstants_Offering.IN_SYNC;
//                             //syncOfferings.add(offering);
//                             offeringMap.put(offering.Id, offering);
//                             /*if (Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()){
//                                 update offering;
//                             }*/
//                         }
//                         else if(!status && parser.getText()!='{'){
//                             //system.debug('unable to process:');
//                             offering.PMP_Partner_Offering_Sync_Status_Nm__c=PMP_StaticConstants_Offering.OUT_OF_SYNC;
//                             //syncOfferings.add(offering);
//                             offeringMap.put(offering.Id, offering);
//                         }
//                     }
                    
//                 }
//                 //if the status code is not 200, then set PIM Status
//                 else {
                    
//                     if(response!=Null){
//                         //isCalloutSuccessful=False;
//                         //system.debug('Service Unavailable out of sync:'+response.getStatusCode());
//                     }
                    
//                     offering.PMP_Partner_Offering_Sync_Status_Nm__c=PMP_StaticConstants_Offering.OUT_OF_SYNC;
//                     //syncOfferings.add(offering); 
//                     offeringMap.put(offering.Id, offering);
//                 }
//             }catch(Exception e){
//                 //isCalloutSuccessful=False;
//                 //Set status to Out Of Sync in case of any exception
//                 /*system.debug('PIM Callout e1:'+e.getMessage());
//                 system.debug('e2:'+e.getLineNumber());
//                 system.debug('e3:'+e.getCause());
//                 system.debug('not in sync');*/
//                 offering.PMP_Partner_Offering_Sync_Status_Nm__c=PMP_StaticConstants_Offering.OUT_OF_SYNC;
//                 //syncOfferings.add(offering);
//                 offeringMap.put(offering.Id, offering);
//                 PMP_Utility.logError(e,'PMP_PIMPublish');
                
//             }
//             finally {
//                 //saving constructed JSON
//                 PMP_Partner_Offering_json__c json= new PMP_Partner_Offering_json__c();
//                 json.PMP_Offering_Id__c=offeringIds[idx];
//                 json.PMP_Offering_JSON_Txt__c=jsonStrings[idx];
//                 offeringJsons.add(json);
                
//                 /*if (Schema.sObjectType.PMP_Partner_Offering_json__c.isAccessible()){
//                     insert json;
//                     System.debug('JSON:   '+json.Id);
//                 }*/
//                 //Create a log to re-try when the offering becomes out of sync
//                 //check the log if not already exist with the status as 'Investigating'
//                 /*if(!isCalloutSuccessful && logEntry.size()==0){
//                 PMP_Utility.creatFailedCalloutLogEntryRecord(offeringId,'PMP_RetryPublishToPIM','PMP','PMP_Partner_Offering__c');
//                 }*/
                
//             }
//             //return isCalloutSuccessful;
//         }
        
//         //All DMLs at the end
//         try{
            
//             //Insert JSON
//             if (Schema.sObjectType.PMP_Partner_Offering_json__c.isAccessible() && 
//             Schema.sObjectType.PMP_Partner_Offering_json__c.fields.PMP_Offering_JSON_Txt__c.isCreateable() ){
//                 insert offeringJsons;
//                 //system.debug('offeringJsons:'+offeringJsons);
//             }
            
//             //Update offering Sync Status OutOfSync/In Sync 
//        //     if (Schema.sObjectType.PMP_Partner_Offering__c.isAccessible() && 
//               if (!offeringMap.isEmpty() && Schema.sObjectType.PMP_Partner_Offering__c.isUpdateable() ){
//       //      Schema.sObjectType.PMP_Partner_Offering__c.fields.PMP_Partner_Offering_Sync_Status_Nm__c.isUpdateable() ){
//                 /*List<PMP_Partner_Offering__c> syncOfferingsNew=new List<PMP_Partner_Offering__c>();
//                 for(PMP_Partner_Offering__c syncOffering: syncOfferings){
//                     if(!syncOfferingsNew.contains(syncOffering)){
//                         syncOfferingsNew.add(syncOffering);
//                     }
//                 }*/
//                 // system.debug('syncOfferings before update:'+offeringMap.values());
//                 //update syncOfferings;
//                 update offeringMap.values();
//                 //system.debug('syncOfferings after update:'+offeringMap.values());
//             }
            
//         }
//         catch(Exception e){
//             /*system.debug('e1:'+e.getMessage());
//             system.debug('e2:'+e.getLineNumber());
//             system.debug('e3:'+e.getCause());*/
//             PMP_Utility.logError(e,'PMP_PIMPublish');
//         }finally{
            
//             // check if any other tranlations are present to publish to PIM
//             if(!isTranslations){
//                 //PMP_PIMProduct.checkExistingTranslatedDataList(offeringIds);
//                 //system.debug('scheduleBatch');//IPA2.0 Offering changess
//                 //String cronId = System.scheduleBatch(new PMP_CheckForTranslations(offeringIds), 'checkExistingTranslatedDataList'+ System.now().getTime(),1);
//                 //system.debug('scheduleBatch:cronId:'+cronId);
//             }
            
//         }
        
//     }
}