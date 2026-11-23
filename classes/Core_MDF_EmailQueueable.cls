public class Core_MDF_EmailQueueable implements Queueable {

    List<Id> recordIds;

    public Core_MDF_EmailQueueable(List<Id> recordIds){
        this.recordIds = recordIds;
    }
	
    public void execute(QueueableContext context){

    System.debug('EMAIL JOB START');

    Id templateId = [
        SELECT Id 
        FROM EmailTemplate 
        WHERE DeveloperName = 'Core_MDF_IUPGM_Access_Status_Template'
        LIMIT 1
    ].Id;

    System.debug('TemplateId: ' + templateId);

    List<Core_MDF_User_Input__c> records = [
        SELECT Id, Core_MDF_IUPGM_User__c
        FROM Core_MDF_User_Input__c
        WHERE Id IN :recordIds
    ];

    System.debug('Records for email: ' + records);

    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

    for(Core_MDF_User_Input__c rec : records){

        System.debug('Processing email for: ' + rec.Id);

        if(rec.Core_MDF_IUPGM_User__c == null){
            System.debug('Skipped email: User is null');
            continue;
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setTemplateId(templateId);
        mail.setTargetObjectId(rec.Core_MDF_IUPGM_User__c);
        mail.setWhatId(rec.Id); 

        mails.add(mail);
    }

    System.debug(' Emails to send: ' + mails.size());

    if(!mails.isEmpty()){
        Messaging.sendEmail(mails);
        System.debug('Emails sent');
    }
}
}