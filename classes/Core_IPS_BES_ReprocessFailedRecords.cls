public class Core_IPS_BES_ReprocessFailedRecords implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    
    public String objAPIName;
    public Integer numOfDays;
    
    public Core_IPS_BES_ReprocessFailedRecords(String objAPIName,Integer numOfDays){ 
        this.objAPIName = objAPIName;
        this.numOfDays = numOfDays;
    } 
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String whereCondition = '';
        if(objAPIName == 'Case'){
            whereCondition = 'Core_IPS_New_Backend_System__c != NULL AND Status != \'CLOSED\'';
        }
        else if(objAPIName == 'Core_IPS_Case_Comments__c'){
           whereCondition = 'Core_IPS_Case__r.Core_IPS_New_Backend_System__c != NULL AND Core_IPS_Case__r.Core_IPS_BackendID__c != NULL AND Core_IPS_Case__r.Status != \'CLOSED\' AND (Core_IPS_Comment_Author_Type__c !=\'Backend Integration\' OR Core_IPS_Comment_Attachment_Id__c !=NULL)';
        }
        else if(objAPIName == 'Core_IPS_Case_Attachments__c'){
            whereCondition = 'Core_Case__r.Core_IPS_New_Backend_System__c != NULL AND Core_Case__r.Core_IPS_BackendID__c != NULL AND Core_Upload_Status__c = \'Complete\' AND Core_Case__r.Status != \'CLOSED\'';
        }
        String query = 'SELECT Core_IPS_BES_Promote_Status__c FROM ' + objAPIName +' WHERE '+ whereCondition +' AND Core_IPS_BES_Promote_Status__c = \'FAILED\' AND CreatedDate >= LAST_N_DAYS:' + numOfDays + ' ORDER BY CreatedDate ASC';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> reprocessRecords){
        
        List<sObject> finalRecList = new List<sObject>();
        for(sObject rec : reprocessRecords){
            rec.put('Core_IPS_BES_Promote_Status__c','In Progress');
            finalRecList.add(rec);
        }
        if(!finalRecList.isEmpty()){
            update finalRecList;
        }
        
    }
    
    
    public void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        
        // Send an email to the Apex job's submitter notifying of job completion.
        //Begin-TWC745-9181-Email relay changes-capturing IPS OrgWideEmailAddress -Gangadhar 23042026
        String orgwideemaillabel= System.label.Core_IPS_Org_Wide_Email_Display_Name;
        OrgWideEmailAddress orgwideEA = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName =:orgwideemaillabel LIMIT 1];   
        //End-TWC745-9181-Email relay changes-capturing IPS OrgWideEmailAddress -Gangadhar 23042026
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //Begin-TWC745-9181-Email relay changes -Gangadhar 23042026
        if(orgwideEA != null)
        {
    		mail.setOrgWideEmailAddressId(orgwideEA.Id);
        } //End-TWC745-9181-Email relay changes -Gangadhar 23042026
        String emailIds = System.Label.Core_IPS_BES_Job_EmailIds;
        String[] toAddresses = emailIds.split('\\,');
        mail.setToAddresses(toAddresses);
        
        mail.setSubject('Reprocess IPS Backend System Records - ' + a.Status);
        mail.setPlainTextBody
            ('The batch Apex job processed ' + a.TotalJobItems +
             ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}