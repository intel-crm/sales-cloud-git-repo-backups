public without sharing class Core_Quip_UserDeactivation { //TWC3123-5376: code scan fix
    
/*
TWC3123-5363- Removal of Quip PS from inactive users after getting deactivated at QUIP system.
*/
    @future(callout=true)
    public static void deactivateQUIPUser(List<String> inactiveUserEmails) {
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        List<PermissionSetAssignment> psaQuip = [SELECT Id, AssigneeId,Assignee.email FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Quip' AND Assignee.Email IN :inactiveUserEmails];
        
        if (inactiveUserEmails != null && !inactiveUserEmails.isEmpty() && !psaQuip.isEmpty()) {
            for(PermissionSetAssignment psa : psaQuip) {
                String userEmail = psa.Assignee.email ;
                QUIP__c customSetting = QUIP__c.getInstance(); //Stored Token and other URLs in Custom setting
                String quipAccessToken = customSetting.Token__c;
                String getEmailUrl = customSetting.Email_EndPoint_URL__c;
                String deleteUserUrl = customSetting.Delete_EndPoint_URL__c;
                
                String endpoint = getEmailUrl+userEmail ;
                // String endpoint = 'https://scim.quip.com/1/users/' + userEmail;                
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('GET');
                req.setHeader(System.Label.Core_AuthHeader, 'Bearer ' + quipAccessToken); //TWC3123-5376: code scan fix :Avoid Using Hard Coded Credentials for Authentication
                
                Http http = new Http();
                HttpResponse res = http.send(req);
                
                String responseBody = res.getBody(); // Assuming res.getBody() returns the response body as a string
                Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(responseBody);
                List<Object> resources = (List<Object>) responseMap.get('Resources');
                String quipUserId; 
                boolean active = false;
                if (!resources.IsEmpty()) {
                    Map<String, Object> resource = (Map<String, Object>) resources[0];
                    quipUserId = (String) resource.get('id')  ; 
                    active = (boolean) resource.get('active')  ; 
                }
                if(active == true) {
                    HttpRequest deleterequest = new HttpRequest();   
                    // deleterequest.setEndpoint( https://scim.quip.com/2/Users/ + quipUserId); 
                    deleterequest.setEndpoint( deleteUserUrl + quipUserId);            
                    deleterequest.setMethod('DELETE');  
                    deleterequest.setHeader(System.Label.Core_AuthHeader, 'Bearer ' + quipAccessToken); //TWC3123-5376: code scan fix :Avoid Using Hard Coded Credentials for Authentication    
                    
                    HttpResponse response = http.send(deleterequest);
                    if (response.getStatusCode() == 200) {
                        //System.debug('Access removed successfully for item: ' + quipUserId);
                    } 
                    else {
                        logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = response.getBody(), Core_Origin__c='Core_Quip_UserDeactivation.deactivateQUIPUser', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
                    }
                }
            }
            //TWC3123-5363------Removal of Quip PS from the users which get deactivated;
            Database.DeleteResult[] deleteResults = database.delete(psaQuip,false);
            if(!logEntries.isEmpty()) { 
                database.insert(logEntries,false);
            }
        }
    } 
/*
Call the Apex method deactivateQUIPUser() and pass the inactive user emails as a parameter
*/
    public static void inactiveUserQuip(List<User> newUserList, Map<Id, User> userOldMap ) {
        
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        List<String> inactiveUserEmails = new List<String>();
        try {
            for (User us : newUserList) {
                User oldUser = userOldMap.get(us.Id);
                
                // Check if the user's status changed to inactive
                if (oldUser.isActive && !us.IsActive) {
                    inactiveUserEmails.add(us.Email);
                }            
            }
            if (!inactiveUserEmails.isEmpty()) {
                // Call the Apex class and pass the inactive user emails as a parameter
                deactivateQUIPUser(inactiveUserEmails);
            }
        } 
        catch(Exception e) {
            logEntries.add(new Core_Log_Entry__c(Core_Message__c ='Error',Core_Details__c = e.getMessage(), Core_Origin__c='Core_Quip_UserDeactivation.inactiveUserQuip', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
            if(!logEntries.isEmpty()) { 
                database.insert(logEntries,false);
            }
        }
    } 
}