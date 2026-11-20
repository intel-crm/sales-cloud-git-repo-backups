global without sharing class Core_IPS_SSLCCase_EmailHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        // Email plainTextBody 
        String emailPlainText = email.plainTextBody.replaceAll('\n',' ').replaceAll('\r',' ');
        
        try{
            //Case create handler
            result.message = Core_IPS_SSLCCaseCreateHandler.createCase(emailPlainText);
            
        }catch(Exception ex){
        }
        /*    
            String extUserProfileName = System.Label.Core_IPS_Profile_Name; 
            if(mailSubj.contains('[500') && mailSubj.endsWith(']')){ 
            List<String> splitmailSubj = mailSubj.split(' ');
            caseRefId = splitmailSubj.size()>3 ? splitmailSubj.get(splitmailSubj.size()-2).substring(1):''; 
            commentType=splitmailSubj.size()>3 ? splitmailSubj.get(splitmailSubj.size()-1).substring(0,2):''; 
            }     
        */
        result.success=true;  
        if( result.message!=null){
            // Sending mail to groupmembers
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            sendTo.addAll(getMailAddresses());
            mail.setToAddresses(sendTo);
            String htmlBody = result.message;
            String emailSubject='SSLC Case Create Error';
            mail.setSubject(emailSubject);
            mail.setHtmlBody(htmlBody );
            mails.add(mail);
            Messaging.sendEmail(mails);
          }
       
        result.message=null;
        return result;
      }
    //get all group member from this Core_IPS_Email_Service_Group
    public List<String> getMailAddresses()
    {
        List<String> mailList = new List<String>();
        List<String> mailAddresses = new List<String>(); 
        
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE DeveloperName= 'Core_IPS_Email_Service_Group'];
        for (GroupMember gm : g.groupMembers) 
        {
            mailList.add(gm.userOrGroupId);
        }
        User[] usr = [SELECT email FROM user WHERE id IN :mailList];
        for(User u : usr) 
        {
            mailAddresses.add(u.email);
        } 
        return mailAddresses;
    }
}