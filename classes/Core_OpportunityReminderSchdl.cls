/********************************************************************************************************************************************************************
Apex Class Name:  Core_OpportunityReminderSchdl
Version     : 1.0 
Created Date: 12/07/2023
Function    : Schedule class for Core_OpportunityReminderBatch batch class

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Bharath Indla               12/07/2023               Original Version developed
*******************************************************************************************************************************************************************/
global without sharing class Core_OpportunityReminderSchdl  implements Schedulable { 
    
    global void execute(SchedulableContext sc) {
        
        //String remDays = Core_CRM_Utility.getCRMLabel('core_reminderDays'); // '-12,-15,-18'
        //String[] remDaysVal = remDays.split('\\,'); // ['-12','-15','-18']
        
        Date twelveDaysAgo = System.today().addDays(-12);
        Date fifteenDaysAgo = System.today().addDays(-15);
        Date eighteenDaysAgo = System.today().addDays(-18);
        
        
        List<Opportunity> listofOppty = [SELECT Id, Name, OwnerId,Owner.Email,Owner.Manager.Email,owner.ManagerId,Owner.Manager.delegatedApproverId,
                                         Core_Date_Submitted_for_Approval__c, Core_Technical_Owner__c,Core_Technical_Owner__r.Email,Core_Technical_Owner__r.Manager.Email,Core_Technical_Owner__r.Manager.delegatedapproverId,
                                         Core_Technical_Owner__r.ManagerId ,core_approval_status__c FROM Opportunity 
                                         WHERE (Core_Date_Submitted_for_Approval__c = :twelveDaysAgo OR Core_Date_Submitted_for_Approval__c = :fifteenDaysAgo OR Core_Date_Submitted_for_Approval__c = :eighteenDaysAgo) and     
                                          (( StageName = 'Design' and  core_approval_status__c = 'Submitted') or (StageName = 'Design Win' and Core_PW_Approval_Status__c = 'Submitted'))  ORDER BY createddate];
        
        if(listofOppty != null)   {
            Database.executeBatch(new Core_OpportunityReminderBatch(), 20);
        }
    }
}