/*************************************************************************************************************************************************************************^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* Class Name  : PMP_PartnerOnGoingVisitNotifyBatch 
* Version     : 1.0 
* Created Date: 04/30/2020
* Modification Log :
*
* Developer             Modification Log                Date                               Description
* --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Tarangini                                             04/30/2020                         This batch will notify partners if they have not logged in to MP community for a given number of days. 
Command to execute this batch class manually-Database.executeBatch(new PMP_PartnerOnGoingVisitNotifyBatch(),batchSize);
* Ajay					Optimization					10/20/2022							Optimized logic.
****************************************************************************************************************************************************************************************************************/
//IPA2.0 - As part of TWC729-7977 commented the entire class & added dummy syntax to override error
global class PMP_PartnerOnGoingVisitNotifyBatch implements Database.Batchable<sObject>,Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // added dummy syntax to override error
       return null;
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        // added dummy syntax to override error
    }

    global void finish(Database.BatchableContext bc) {
        // added dummy syntax to override error
    }
 /*   
    private String emailObjectRecordName = 'Partner_OnGoing_Visit';
    private static Set<Id> usersInScope = New set<Id>();
    global  map<id, date> userLoginMap = New Map<id, date>();
    private Core_Apex_EmailNotification__c emailObjectRecord = PMP_Utility.getApexEmailRecord(emailObjectRecordName);
    DateTime notificationDateTime;
    DateTime notificationDateTimeStart;

    //querying the network Id specific to the marketplace community
    Network myNetwork = [SELECT Id FROM Network WHERE Name = :PMP_Utility.getValue('Marketplace_Community_Name') ];
    
    //Start - Method
    global Database.QueryLocator start(Database.BatchableContext bc) {

        integer noOfDays = integer.valueOf(emailObjectRecord.Core_NumberOfDays_Nbr__c);
        notificationDateTime = (Datetime)Date.Today().addDays(-noOfDays);
        notificationDateTimeStart = (Datetime)Date.Today().addDays(-noOfDays-1);

		List<string> permissionSetNames = emailObjectRecord.Core_Allowed_Permission_Nm__c.split(',') ;

        if(Test.isRunningTest()) {   
            return Database.getQueryLocator([SELECT id, Name FROM User 
                                             WHERE profile.Name = 'Partner'
                                             AND isActive = true limit 100]);  
        }        
        else {
            return Database.getQueryLocator([SELECT id,Name FROM User 
                                             WHERE profile.Name = 'Partner'
                                             AND isActive = true
                                             AND Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name IN:permissionSetNames AND Assignee.isActive=true)]);
        }
    }

    global void execute(Database.BatchableContext bc, List<User> usersToSendEmail) {

        Set<Id> userIds = (new Map<Id,SObject>(usersToSendEmail)).keySet();
        Map<Id,Id> userIdsWithoutLogin = new Map<Id,Id>();

        for(AggregateResult loginHistoryRecord : [SELECT UserId, MAX(LoginTime) FROM LoginHistory WHERE networkId =: myNetwork.Id AND UserId IN: userIds GROUP BY UserId HAVING MAX(LoginTime) >= 2024-05-13T00:00:00Z AND MAX(LoginTime) < 2024-05-15T00:00:00Z]) {
            userIdsWithoutLogin.put((Id)loginHistoryRecord.get('UserId'),null);
        }

        if(!usersToSendEmail.isEmpty()) {
            PMP_Utility.sendEmailAndLogData(emailObjectRecord.Core_Email_Template_Nm__c,userIdsWithoutLogin);
        }
    }   

    global void finish(Database.BatchableContext bc) {
        
    }*/
}