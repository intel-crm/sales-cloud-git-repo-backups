public without sharing class Sales_ContactCustomerSupportChatbot {
    private static final string ORIGIN = 'Sales_ContactCustomerSupportChatbot';
    private static final string SEVERITY = 'info';
    private static final string PROJECT = 'Sales';
    public static final String FROM_EMAIL=System.label.sales_NonIpsFromemail; 
    public static final String SENT_EMAIL=System.label.sales_NonIpsToemail;
    public class ComputerInput {
        @InvocableVariable
        public String PoNo;
        @InvocableVariable
        public String LacSerialNo;
        @InvocableVariable
        public String HostId;
        @InvocableVariable
        public String ProdName;
        @InvocableVariable
        public String description;
        @InvocableVariable
        public Sales_NonIpsCaseCreationChatbot.pickListWrapper WrapperObj;
        @InvocableVariable
        public String ContactId;
    }
    @InvocableMethod(label='Sending Email for Non Ips Case')
    public static void CreateNonIpsCase(List<ComputerInput> computerInputs) {
        String subject;
        String subjectemail;
        String emailBody;
        String contactId;
        for (ComputerInput compInput : computerInputs) {
            subject=compInput.WrapperObj.value;
            contactId=compInput.ContactId;
        }
        OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address=:FROM_EMAIL];//query email address 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{SENT_EMAIL}); 
        mail.setOrgWideEmailAddressId(orgWideEmailAdd.Id); 
        Sales_Non_IPS_Service__mdt subjectline=[SELECT Id,Type_of_License_Issue__c,Subject__c FROM Sales_Non_IPS_Service__mdt  where Active__c = true AND Type_of_License_Issue__c =:subject ];
        subjectemail=subjectline.Subject__c;
        mail.setSubject(subjectemail+'(from SSLC form)');
        contact c=[select id,email,name from contact where id=:contactId ];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (ComputerInput compInput : computerInputs) {
            emailBody = '{'+'<br/>';
            emailBody = emailBody + '\"Description\": {'+'<br/>';
            emailBody = emailBody + '\"Contact Email\": \"'+c.Email+'\",'+'<br/>';
            emailBody = emailBody + '\"License Activation Code/Serial No\": \"'+compInput.LacSerialNo+'\",'+'<br/>';
            emailBody = emailBody + '\"Description\": \"'+compInput.description+'\",'+'<br/>';
            emailBody = emailBody + '\"Contact Name\": \"'+c.Name+'\",'+'<br/>';
            emailBody = emailBody + '\"Product Name\": \"'+compInput.ProdName+'\",'+'<br/>';
            emailBody = emailBody + '\"NIC/Host/Guard ID\": \"'+compInput.HostId+'\",'+'<br/>';
            emailBody = emailBody + '\"PO": \"'+compInput.PoNo+'\"'+'<br/>';
            emailBody = emailBody + '},'+'<br/>';
            emailBody = emailBody +'\"subject\": \"'+subjectemail+'\"'+'<br/>';
            emailBody = emailBody +'}';
            mail.setHtmlBody(emailBody);
            emailBody.deleteWhitespace();
            emails.add(mail);
            //Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY,null, emailBody,null,'NON IPS EMAIL', '');
        }
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    public static User userManagement(){
        User u1 = [SELECT Id,Contact.Core_IPS_Active__c,Contact.Email,Contact.Name,usertype from User where Id =: userInfo.getUserId()];
        return u1;
    }
}