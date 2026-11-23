global with sharing class Core_IntegrationOutboundAGSMsgPost {
 
    @InvocableMethod
    public static List<Results> Core_IntegrationOutboundAGSMsgPost(List<Requests> requests)
       {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('testing');
            request.setMethod('POST');
            HttpResponse response = http.send(request);
           
            Results curResult = new Results();
            String responseJSON = response.getBody();
           
            List<Results> resultsList = new List<Results>();
            resultsList.add(curResult);
            return resultsList;
       }
    
    global class Requests {
        @InvocableVariable
        global String myId;
        
        @InvocableVariable
        global String mySObject;
        
        @InvocableVariable
        global String myMessageType;
        
        @InvocableVariable
        global String myPayload;
    }
    
    global class Results {
        @InvocableVariable
        global Core_IntegrationOutboundAGSMsg Core_IntegrationOutboundAGSMsg;
    }

}