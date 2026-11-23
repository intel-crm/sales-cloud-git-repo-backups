public class SmartPicklistBackfill {

@AuraEnabled
public static String getOrgName() { 
    String orgName;
    System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
    orgName = d.getSandboxName();
    system.debug('Apex orgNAME:'+orgName);
    return orgName;
}
@AuraEnabled
public static void getBackFillDetails(PicklistWrapperClass pwcParams) {   
    system.debug('PWC PARAMS:'+pwcParams);
    String serializedWrapper = JSON.serialize(pwcParams);
    system.debug('WRAPPER IS:'+serializedWrapper);
	backFillCallout(serializedWrapper);
}
@AuraEnabled
public static void getBackFillRecTypesDetails(RecordTypeWrapperClass recTypeParams) {   
    system.debug('RECTYPE PARAMS:'+recTypeParams);
    String serializedWrapper = JSON.serialize(recTypeParams);
    system.debug('WRAPPER IS:'+serializedWrapper);
	backFillCallout(serializedWrapper);
}
@future(callout=true)
public static void backFillCallout(String serializedWrapper) {
 try {
        system.debug('Inside backfill callout'+serializedWrapper);
    	HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SmartPicklist_Named_Cred/services/apexrest/TargetEndPoint/');
        req.setHeader('content-type','application/json; charset=UTF-8');
        req.setHeader('Accept', 'application/json');
        req.setBody(serializedWrapper);
        //req.setBody('{"ABC":"ABC"}');
        req.setMethod('POST');
        Http http = new Http();
        HttpResponse response = http.send(req);
        System.debug('response code:'+response.getStatusCode());
        System.debug('response body : '+response.getBody());
     	system.debug('RESPONSE:'+response);
     
    } catch (Exception e) {
        System.debug('Exception caught: ' + e.getMessage());
        System.debug('Line no: ' + e.getLineNumber());
    }
}
    //Wrapper Classes
    public class PicklistWrapperClass {
        @AuraEnabled
        public String objectName { get; set; }
        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public String fieldAPIName { get; set; }
        @AuraEnabled
        public List<PickListWrapper> picklistValues { get; set;}
        @AuraEnabled
        public boolean sorted {get; set;}
    }
     public class PickListWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
        @AuraEnabled
        public Boolean isActive {get; set;}
        @AuraEnabled
        public Boolean isDefaultValue {get; set;}
        @AuraEnabled
        public boolean isNew {get;set;}
    }
    public class RecordTypeWrapperClass {
        @AuraEnabled
        public String recordTypeName { get; set; }
        @AuraEnabled
        public String recordTypeFullName { get; set; }
        @AuraEnabled
        public PicklistWrapperClass pLWrapperParams {get; set;}
    }
    
}