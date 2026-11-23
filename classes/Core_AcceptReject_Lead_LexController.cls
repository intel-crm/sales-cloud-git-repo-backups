/*-------------------------------------------------------------------------------------------
Apex Class  : Core_AcceptReject_Lead_LexController
Version     : 1.0 
Created Date: 11 JUNE 2018
Function    : Apex class for lead accept/reject lightning component
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            11/06/2018              Original Version
-------------------------------------------------------------------------------------------*/

public class Core_AcceptReject_Lead_LexController {
   
 
    @auraEnabled
    public static String updateLead(String leadId){
        String alertMsg = 'You have successfully accepted the Lead.';
        Lead leadUpdate = [select Id, OwnerId, RecordTypeId, Core_Lead_State__c, Core_Rejection_Comments__c, Core_Rejection__c,
                           Core_Partner_Lead_Owner__c from Lead where Id =: leadId];
        
        String recTypeName = [select Id, Name from RecordType where Id =: leadUpdate.RecordTypeId].Name;
        
        if(recTypeName.equalsIgnoreCase('Lead')){
            if(leadUpdate.OwnerId <> UserInfo.getUserId()){
                alertMsg = 'Please take the ownership of the Lead before Accepting.';
            }else{
                leadUpdate.Core_Lead_State__c = 'Accepted'; 
                leadUpdate.Core_Rejection_Comments__c = null; 
                leadUpdate.Core_Rejection__c = null;
                update leadUpdate;
            }
        }else if(recTypeName.equalsIgnoreCase('Partner Lead')){
            leadUpdate.Status = 'Partner Qualified Lead'; 
            leadUpdate.Core_Lead_State__c = 'Accepted'; 
            leadUpdate.Core_Partner_Lead_Owner__c = UserInfo.getUserId(); 
            leadUpdate.Core_Rejection_Comments__c = null; 
            leadUpdate.Core_Rejection__c = null;
            update leadUpdate;
        }else if(recTypeName.equalsIgnoreCase('Prospect')){
            if(leadUpdate.OwnerId <> UserInfo.getUserId()){
                alertMsg = 'Please take the ownership of the Prospect before Accepting.';
            }else{
                leadUpdate.Core_Lead_State__c = 'Accepted'; 
                leadUpdate.Core_Rejection_Comments__c = null; 
                leadUpdate.Core_Rejection__c = null;
                update leadUpdate;
            }
        }
        return alertMsg;
    }
    
    
    //To update lead status to 'Tele Qualified Lead' through Convert to Lead button link on Lead detailPage added by Rajesh//
    @auraEnabled
    public static void updateTeleQualifiedLead(String leadId){
        lead ld=new lead(Id=leadId,Status='Tele Qualified Lead');
        update ld;
    } 
    
    @auraEnabled
    public static void updateToLead(Lead leadObj){
        Lead leadToUpdate = new Lead();
        leadToUpdate.Id = leadObj.Id;
        leadToUpdate.Core_Rejection__c = leadObj.Core_Rejection__c;
   		leadToUpdate.Core_Rejection_Comments__c = leadObj.Core_Rejection_Comments__c;
        leadToUpdate.Core_Lead_State__c = 'Rejected';
        update leadToUpdate;
    }
    
    @auraEnabled
    public static picklistMsgWrapper getPicklistValues(String leadId, String objectType, String fieldName){
        picklistMsgWrapper picklistWrap = new picklistMsgWrapper();
        Lead leadUpdate = [select Id, OwnerId, RecordTypeId, Core_Rejection__c, Core_Rejection_Comments__c from Lead where Id =: leadId];
        String recTypeName = [select Id, DeveloperName from RecordType where Id =: leadUpdate.RecordTypeId].DeveloperName;
        if(recTypeName.equalsIgnoreCase('Lead')){
            if(leadUpdate.OwnerId == UserInfo.getUserId()){
                picklistWrap.pickListValueList = fetchPicklistValuesByRecType(objectType, fieldName, leadUpdate.RecordTypeId);
                picklistWrap.message = 'success';
            }else{
                picklistWrap.pickListValueList = null;
                picklistWrap.message = 'Please take the ownership of the Lead before Rejecting.';
            }
        }else if(recTypeName.equalsIgnoreCase('Partner_Lead')){
            picklistWrap.pickListValueList = fetchPicklistValuesByRecType(objectType, fieldName, leadUpdate.RecordTypeId);
            picklistWrap.message = 'success';
        }else if(recTypeName.equalsIgnoreCase('Prospect')){
            if(leadUpdate.OwnerId == UserInfo.getUserId()){
                picklistWrap.pickListValueList = fetchPicklistValuesByRecType(objectType, fieldName, leadUpdate.RecordTypeId);
                picklistWrap.message = 'success';
            }else{
                picklistWrap.pickListValueList = null;
                picklistWrap.message = 'Please take the ownership of the Prospect before Rejecting.';
            }
        }
        picklistWrap.leadObj = leadUpdate;
        return picklistWrap;
    }
    
    public static List<String> fetchPicklistValuesByRecType(String objectType, String fieldName, String recordTypeId){
        String content;
        if(Test.isRunningTest()){
           content = 'Start_Of_Session_Id'+UserInfo.getSessionId()+'End_Of_Session_Id';
        }
         else{       
        content = Page.Core_Fetch_SessionId.getContent().toString();
        }
        Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                e = content.indexOf('End_Of_Session_Id');
        String sessionId = content.substring(s, e);
        
        String endpoint = URL.getSalesforceBaseUrl().toExternalForm();
        system.debug('endpoint '+endpoint);
        endpoint += '/services/data/v41.0';
        endpoint += '/ui-api/object-info/{0}/picklist-values/{1}/{2}';
        endpoint = String.format(endpoint, new String[]{ objectType, recordTypeId, fieldName });
        EncodingUtil.urlEncode(endpoint,'UTF-8');
        
        //HTTP Request send
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        //Parse response
        system.debug('Res '+res.getBody());
        List<String> result = new List<String>();
        Map<String,Object> root = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
        if(!root.containsKey('values')){ 
            return result; 
        }
        List<Object> pValues = (List<Object>)root.get('values');
        for(Object pValue : pValues){
            Map<String,Object> pValueMap = (Map<String,Object>)pValue;
            result.add((String)pValueMap.get('value'));
            System.debug(result);
        }
        return result;
    }
    
    
    public class picklistMsgWrapper{
        @auraEnabled
        public Lead leadObj{get;set;}
        @auraEnabled
        public List<String> pickListValueList{get;set;}
        @auraEnabled
        public String message{get;set;}
    }
}