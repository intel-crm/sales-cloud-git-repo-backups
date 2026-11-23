public without sharing class espy_ApexJobsEmail {
    
    @InvocableMethod(label='Email Holding Batch Details' description='Use to share report of holding batches' category='ApexJobsEmail')
    public static void sendJobsEmail(){
        List<AsyncApexJob> holdingJobs = [SELECT Id,ApexClass.name,JobType FROM AsyncApexJob WHERE Status = 'Holding'];
        
        if(holdingJobs.size() < 1 && !Test.isRunningTest()){
            return;
        }
        OrgWideEmailAddress orgAddress = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address='wsm-postmaster@intel.com' LIMIT 1];
        String subject = 'Sandbox QA9: List of Holding Job Name - '+holdingJobs.size()+'.';        
        String fontStyle = 'font-family:intel clear;';
        String borderStyle = 'style="border: 1px solid #d3d3d3;padding-left:5px;padding-top:5px;padding-bottom:5px;font-size: 14px;"';
        String emailBody = '<html><body>';
        emailBody = emailBody + '<p>Here are the list of Apex Job in holding state : <br></p>';
        
        emailBody = emailBody + '<table style="'+fontStyle+'"><thead><tr><th '+borderStyle+'>Apex Class Name</th><th '+borderStyle+'>Job Type</th></tr></thead><tbody>';            
        
        for(AsyncApexJob job: holdingJobs){
            if(job.ApexClass.Name == null){
                continue;
            }else{
                emailBody = emailBody + '<tr><td '+borderStyle+'><p>' + job.ApexClass.Name + '</p></td>'+ '<td '+borderStyle+'><p>' + job.JobType + '</p></td></tr>';               
            }
        }
        
        emailBody = emailBody + '</tbody></table></body></html>';
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(orgAddress.Id);
        email.setToAddresses(Label.espy_SalesTechLeadEmails.split(';'));
        email.setSubject(subject);
        email.setHtmlBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}