/**************************************************************************************
Apex Class Name:  Core_Milestone_Unlock_Record
Version     : 1.0 
Created Date: 22nd Jan   2016
Function    : Control of Core_Milestone_Unlock_Record page to unlock the Approved Milestone record based on conditions
Modification Log :
* Developer             Date                   Description
* ----------------------------------------------------------------------------                 
* Goutham               01/22/2016              Original version
*************************************************************************************/ 

public without sharing class Core_Milestone_Unlock_Record {

    public List<Core_Solution_Milestone__c> lstMileStone {get; set;}
    public id mileStoneId {get; set;}
    public Core_Solution_Milestone__c milestone {get; set;}
    private String returnUrl;

    
    // Constructor
    public Core_Milestone_Unlock_Record(ApexPages.StandardController controller) {
        if (!Test.isRunningTest())
            controller.addFields(new List<String>{'Core_Status__c', 'Core_Owner__c'});
        mileStoneId = ApexPages.CurrentPage().getParameters().get('id');
        milestone =(Core_Solution_Milestone__c)controller.getRecord();

        returnUrl = ApexPages.currentPage().getUrl();
    }
    

    // Main method to unlock the record and change the status to 'Pending'
    public pageReference UnlockMilestone() {

        lstMileStone = new List<Core_Solution_Milestone__c>();
        Id currentUserId = UserInfo.getUserId();
        Id managerId = null;
        map<Id, Id> mapMilestoneIdApproverId = new map <Id, Id>();

        lstMileStone = database.query(getQuery());
        
        // Get the Manager Id
        if (milestone.Core_Owner__c != null) {
            for (User user: [SELECT Id, ManagerId FROM user WHERE Id =: milestone.Core_Owner__c LIMIT 1]) {
                managerId = user.ManagerId;
            }
        }
        
        // Get the Last Approver
        for (ProcessInstance inst : [SELECT Id, LastActorId, Status, TargetObjectId FROM ProcessInstance WHERE Status = 'Approved' AND TargetObjectId = :mileStoneId ORDER BY LastModifiedDate DESC LIMIT 1]) {
            mapMilestoneIdApproverId.put(inst.TargetObjectId, inst.LastActorId);
        }

        // Retrun error if the current status in not Approved
        if (milestone.Core_Status__c != 'Approved') {
            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Operation. Milestone must be approved to Recall Approval.'));
            return null;
        }
        
        

        // Unlock if the current user is manager of the record owner or if the current user is the last approver
        if ((currentUserId == managerId) || (mapMilestoneIdApproverId != null && currentUserId == mapMilestoneIdApproverId.get(milestone.id))) {   
            // Unlock the Core_Solution_Milestone__c 
            Approval.UnLockResult[] lstResult = System.Approval.unlock(lstMileStone, false);
            
            // Iterate through each returned result
            for (Approval.UnLockResult result : lstResult) {
                if (result.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully unlocked Core_Solution_Milestone__c with ID: ' + result.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for (Database.Error err : result.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Core_Solution_Milestone__c fields that affected this error: ' + err.getFields());
                    }
                }
            }

            // Change the status to Pending
            milestone.Core_Status__c ='Pending';
            update milestone;
        }
        else {
            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Contact previous Approver or the Manager of the Milestone Owner to Recall Approval.'));
            return null;
        }

        pageReference pg = new pageReference('/' + mileStoneId);
        return pg;
    }
    

    private String getQuery() {
    
        String query ='';

        if (mileStoneId != null) {
            query = 'SELECT Id FROM Core_Solution_Milestone__c WHERE id';
            query = query + '=\'' + String.escapeSingleQuotes(mileStoneId) + '\''+ ' LIMIT 1';
        }

        return query; 
    }
    

    public pageReference BackToMilestone() {
        
        pageReference pg = new pageReference('/' + mileStoneId);
        pg.setRedirect(true);
        return pg;
    }  
}