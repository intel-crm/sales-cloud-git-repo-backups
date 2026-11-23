public with sharing class PRM_RepublishContactsForRoleTier {
    //public static List<Contact> conQueueFullLst=new List<Contact>();
    public static void UpdateRepublishOnContact(List<Id> conList){
         system.debug('conList--->'+conList);
         list<string> emailToSendAddresses=new list<string>();
        List<Contact> conQueueFullLst=new List<Contact>();
        if(!conList.isEmpty() && conList.size()>0){
        for(contact con: [select Core_ERPM_Integration_Queue_txt__c,Id,Email, Core_Republish_OBM_s__c from contact where Id in: conList]){
            emailToSendAddresses.add(con.email);
            contact repCon = new contact();
            repCon.Id = con.Id;
            repCon.Core_Republish_OBM_s__c = true;
                conQueueFullLst.add(repCon);
            system.debug('con added');
            }
            system.debug('conQueueFullLst--->'+conQueueFullLst);
            if(!conQueueFullLst.isEmpty() && conQueueFullLst.size()>0){
                update conQueueFullLst;
            }
  	  }
system.debug('emailToSendAddresses--->'+emailToSendAddresses);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailToSendAddresses);     
        String emailBody = [select HtmlValue from EmailTemplate where DeveloperName ='BATCH_JOB_NOTIFICATION' limit 1].HtmlValue;
        string sub=[select subject from EmailTemplate where DeveloperName ='BATCH_JOB_NOTIFICATION' limit 1].subject;
        System.debug('subject -->'+sub);
        mail.setHtmlBody(emailBody); 
        mail.setSubject('welcome to intel');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }
    
}