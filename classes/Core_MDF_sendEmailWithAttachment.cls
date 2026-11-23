public class Core_MDF_sendEmailWithAttachment {
    
    public static void sendEmailToGSPO(){
        List<id> ContentDocumentids = new List<id>();
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        for(contentDocumentLink CDLink : [SELECT LinkedEntityid, ContentDocumentid FROM contentDocumentLink WHERE ContentDocumentid IN ('069g0000001Xp0g','069g0000001XtIPAA0','069g0000001PpCOAA0','069g0000001XtIZAA0','069g0000001XtItAAK')])
        {
            ContentDocumentids.add(CDLink.ContentDocumentid);  
        }
        system.debug('contdocid'+ContentDocumentids);
        for ( ContentVersion cversion : [SELECT title, 
                                         PathOnClient, FileType,
                                         versiondata 
                                         FROM contentversion 
                                         WHERE ContentDocumentId IN :ContentDocumentids])
        {
            system.debug('cversion1'+cversion);
            blob WOCFbody = cversion.versiondata;			  
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName('VAT Invoice'+'-'+cversion.title+'.'+cversion.FileType);
            efa.setBody(WOCFbody);
            fileAttachments.add(efa); 
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();  
        Id userId = UserInfo.getUserId();
        String[] toAddresses = new String[] {'vaishalix.dewangan@intel.com'};
            mail.setToAddresses(toAddresses);
        mail.setOrgWideEmailAddressId('0D21J0000008U6X');
        mail.setTemplateId('00Xg0000000Ji06');
        mail.setFileAttachments(fileAttachments);
        mail.targetObjectId = userId;
        mail.setSaveAsActivity(false);
        emailsToSend.add(mail);
        Messaging.sendEmail(emailsToSend);
    }
}