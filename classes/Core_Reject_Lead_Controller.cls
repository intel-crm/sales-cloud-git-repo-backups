/*-------------------------------------------------------------------------------------------
Apex Class  : Core_Reject_Lead_Controller
Version     : 1.0 
Created Date: 2nd August 2019
Function    : Apex class for partner lead rejection
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            02/08/2019              Original Version
-------------------------------------------------------------------------------------------*/

public class Core_Reject_Lead_Controller {

    /*
     * Method name  : updateToLead
     * Description  : Update lead with rejection reason, rejection comments and lead state field.
     * Return Type  : void
     * Parameter    : Lead leadObj
     */
    @auraEnabled
    public static void updateToLead(Lead leadObj){
        Lead leadToUpdate = prepareRejectLead(leadObj.Id, leadObj.Core_Rejection__c, leadObj.Core_Rejection_Comments__c);
        /*leadToUpdate.Id = leadObj.Id;
        leadToUpdate.Core_Rejection__c = leadObj.Core_Rejection__c;
        leadToUpdate.Core_Rejection_Comments__c = leadObj.Core_Rejection_Comments__c;
        leadToUpdate.Core_Lead_State__c = 'Terminated';*/
        try{
            update leadToUpdate;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*
     * Method name  : prepareRejectLead
     * Description  : prepare the rejected lead data
     * Return Type  : Lead
     * Parameter    : Lead leadObj, String rejectionReason, String rejectionComments
     */
    public static Lead prepareRejectLead(String leadId, String rejectionReason, String rejectionComments){
        Lead leadObj = new Lead();
        leadObj.Id = leadId;
        leadObj.Core_Lead_State__c = 'Terminated';
        leadObj.Core_Rejection__c = rejectionReason;
        leadObj.Core_Rejection_Comments__c = rejectionComments;
        return leadObj;
    }
    
    /*
     * Method name  : rejectSelectedLeads
     * Description  : Bulk reject partner lead
     * Return Type  : void
     * Parameter    : List<Lead> selectedLeads, String rejectionReason, String rejectionComments
     */
    @auraEnabled
    public static void rejectSelectedLeads(String selectedLeads, String rejectionReason, String rejectionComments){
        selectedLeads = selectedLeads.replace(']', '').replace('[', '');
        List<String> leadIdList = selectedLeads.split(',');
        List<Lead> leadList = new List<Lead>();	
        for(String ledId : leadIdList){
            leadList.add(prepareRejectLead(ledId.trim().left(15), rejectionReason, rejectionComments));
        }
        try{
            update leadList;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*
     * Method name  : getPicklistValuesRejection
     * Description  : Method to fetch picklist values as per recordtype.
     * Return Type  : picklistMsgWrapper
     * Parameter    : String leadId, String objectType, String fieldName
     */
    @auraEnabled
    public static picklistMsgWrapper getPicklistValuesRejection(String leadId, String objectType, String fieldName){
        picklistMsgWrapper picklistWrap = new picklistMsgWrapper();
        Lead leadUpdate = [select Id, OwnerId, RecordTypeId, Core_Rejection__c, Core_Rejection_Comments__c from Lead where Id =: leadId];
        String recTypeName = [select Id, DeveloperName from RecordType where Id =: leadUpdate.RecordTypeId].DeveloperName;
        if(recTypeName.equalsIgnoreCase('Partner_Lead')){
            picklistWrap.pickListValueList = fetchPicklistValuesByRecType(objectType, fieldName, leadUpdate.RecordTypeId);
            system.debug('picklistWrap.pickListValueList '+picklistWrap.pickListValueList);
            picklistWrap.message = 'success';
        }else{
            picklistWrap.message = system.label.Core_Reject_NotPartnerLead;
        }
        picklistWrap.leadObj = leadUpdate;
        return picklistWrap;
    }
    
    /*
     * Method name  : getPicklistValues
     * Description  : Method to fetch picklist values as per recordtype.
     * Return Type  : List<String>
     * Parameter    : String objectType, String fieldName
     */
    @auraEnabled
    public static List<String> getPicklistValues(String objectType, String fieldName){
        String partnerRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Partner Lead').getRecordTypeId();
        return fetchPicklistValuesByRecType(objectType, fieldName, partnerRecTypeId);
    }
    
    /*
     * Method name  : fetchPicklistValuesByRecType
     * Description  : This is a generic method to fetch any picklist field values of any object as per recordtype.
     * Return Type  : List<String>
     * Parameter    : String objectType, String fieldName, String recordTypeId
     */
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
        system.debug('root '+root);
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