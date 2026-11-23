/**************************************************************************************
Apex Class Name:  ContatGECQueable
Version     : 1.0 
Created Date: 27 Sep 2021
Function    : To Send Summary email to send the GEC information
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda             27/09/2020             Original Version
*************************************************************************************/
global class Core_FailedGEC_Summary_Email implements Database.Batchable<sObject>, Database.Stateful {
    public Integer GECFailedRecordsize =0;
	public Integer GECSuccessRecordsize =0;
	public Integer GECBlockedContactSize=0;
	public Integer GECUnBlockedContactSize=0;
    public static String fromEmailAddress = System.Label.Core_SetFromEmailAddress;
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Id,Core_Status__c,Core_Contact_ID__c from Core_Contact_GEC_Staging__c where CreatedDate = TODAY'; 
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Core_Contact_GEC_Staging__c> scope){
        
        List<Core_Contact_GEC_Staging__c> GECFailedRecords=[SELECT Id,Core_Status__c,Core_Contact_ID__c from Core_Contact_GEC_Staging__c where CreatedDate = TODAY AND Core_Status__c='Failed'];
		List<Core_Contact_GEC_Staging__c> GECBlockedRecords=[SELECT Id,Core_Status__c,Core_Contact_ID__c from Core_Contact_GEC_Staging__c where CreatedDate = YESTERDAY AND Core_Status__c='Successful' AND Core_GEC_Blocked__c=true];
		List<Core_Contact_GEC_Staging__c> GECUnBlockedRecords=[SELECT Id,Core_Status__c,Core_Contact_ID__c from Core_Contact_GEC_Staging__c where CreatedDate = YESTERDAY AND Core_Status__c='Successful' AND Core_GEC_Blocked__c=false];
		
		if(GECFailedRecords.size()>0){
        GECFailedRecordsize=GECFailedRecords.size();
		}
		if(GECBlockedRecords.size()>0){
        GECBlockedContactSize=GECBlockedRecords.size();
		}
        if(GECUnBlockedRecords.size()>0){
        GECUnBlockedContactSize=GECUnBlockedRecords.size();
		}
        
    }
    global void finish(Database.BatchableContext BC){  
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[]();
        List<String> toAddresses = new List<String>();
        List < Messaging.SingleEmailMessage > emails = new List < Messaging.SingleEmailMessage > ();
        
        List<User> userList = [SELECT Id, Name, Email, isActive, Profile.Name, userrole.name, usertype 
                               FROM User 
                               WHERE Id IN (SELECT userorgroupid FROM groupmember WHERE group.name = 'Core_Contact_GEC_EmailNotify_list')];
        for(User u : userList){           
            toAddresses.add(u.email);
        }
        if(Test.isRunningTest()){
            User U=[Select id,Email from User Where isActive=true limit 1];
            toAddresses.add(u.email);
        }
        system.debug('List'+toAddresses);
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('baseUrl'+baseUrl);
        
        String body='Hi All,'+'<br/>'+'<br/>';
		body +='Please find the below summary of Contacts which have been Blocked/Unblocked as a result of  GEC update on their associated accounts.'+'<br/>'+'<br/>';
		body += 'Number of Contacts blocked : '+GECBlockedContactSize+'<br/>';
		body += 'Number of Contacts Unblocked : '+GECUnBlockedContactSize+'<br/>';
		body += 'Number of Records that failed to sync with AGS : '+GECFailedRecordsize+'<br/>';
		
        body +='<br/>'+ 'Please check the below report to see the details of '+String.valueOf(system.today()-1)+' records.'+'<br/>';
        body += baseUrl+'/'+Label.Core_GEC_SummaryReport+'<br/>';
		body +='Please check the below dashboard to get a summary of today’s and overall GEC Blocked Records.'+'<br/>';
		body += baseUrl+'/'+Label.Core_GEC_Dashboard;

        body +='<br/>'+'<br/>'+'<br/>'+'Thanks,'+'<br/>'+'Intel Support team';
        //List<string> toAddresses; 
        mail.setToAddresses(toAddresses);
        mail.setSubject('Summary  of Contacts Blocked/Unblocked due to GEC');
        mail.setHtmlBody(body);  
        //mail.setTargetObjectId(conList[0].Id);
        mail.setSaveAsActivity(false); 
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setOrgWideEmailAddressId(fromEmailAddress);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    
}