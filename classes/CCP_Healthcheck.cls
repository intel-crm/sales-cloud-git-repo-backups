public with sharing class CCP_Healthcheck  { 
    
    public static void apisHealthCheck(List<CCP_Apis_Healthheck__c> apis){
        List<CCP_Healthcheck_Report__c> reports = new List<CCP_Healthcheck_Report__c>();
        try{
            if(apis!=null && apis.size()>0){
                for(CCP_Apis_Healthheck__c api:apis ){                
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();  
                    String calloutString = api.Name;
                    if(api.params__c!=null){
                        calloutString +='?'+api.params__c;
                    }
                    request.setEndpoint('callout:'+calloutString);
                    request.setMethod(api.method__c);
                    request.setTimeout(120000);
                    /*if(api.Authentication_Type__c == 'OAuth 2.0'){
                        request.setHeader('Authorization', api.AccessToken__c);
                        request.setHeader('grant_type', 'password');
                        request.setHeader('client_id', api.client_id__c);
                        request.setHeader('client_secret', api.client_secret__c);
                    } */               
                    
                    HttpResponse response;
                    response = http.send(request);
                    system.debug('getStatusCode:'+response.getStatusCode());
                    system.debug('email:'+api.User__r.Email);
                    system.debug('response:'+response.getBody());
                    CCP_Healthcheck_Report__c report = new CCP_Healthcheck_Report__c();
                    report.CCP_Apis_Healthheck__c = api.Id;
                    report.Status__c = response.getStatusCode()==200?'successful':'failed';
                    report.log__c = response.getBody();
                    reports.add(report);
                    if(response.getStatusCode()!=200){
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.setTargetObjectId(api.User__r.Id); 
                        message.setSenderDisplayName('Company Support'); 
                        message.setReplyTo('gireesh.k@intel.com');
                        message.setUseSignature(false); 
                        message.setBccSender(false); 
                        message.setSaveAsActivity(false); 
                        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'CCP HealthCheck'];
                        message.setTemplateID(emailTemplate.Id); 
                        //message.setWhatId(api.User__r.Id); //This is important for the merge fields in template to work
                        message.toAddresses = new String[] { api.User__r.Email};
                            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                        
                        if (results[0].success) 
                        {
                            System.debug('The email was sent successfully.');
                        } else {
                            System.debug('The email failed to send: ' +  results[0].errors[0].message);
                        }
                    }
                    
                    
                }
            }
        }
        catch(Exception e){
            system.debug('error:'+e.getCause()+e.getLineNumber()+e.getMessage());
        }
        finally{
            //insert reports;
        }
    }
}