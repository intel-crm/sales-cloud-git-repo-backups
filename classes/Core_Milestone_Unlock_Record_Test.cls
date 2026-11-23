/**************************************************************************************
Apex Class Name:  Core_Milestone_Unlock_Record_Test
Version     : 1.0 
Created Date: 11th Jan 2015
Function    : Test Class for Core_Milestone_Unlock_Record
Modification Log :
* Developer             Date                   Description
* ----------------------------------------------------------------------------                 
* Goutham               01/11/2015              Original version
*************************************************************************************/

@isTest
public with sharing class Core_Milestone_Unlock_Record_Test {

     /*
     * Method name  : UnlockMilestoneTest_Approved
     * Description  : Method to test UnlockMilestone functionality when the Status is Approved
     * Return Type  : void
     * Parameters   : None
     */
     
    static testmethod void UnlockMilestoneTest_Approved()
    {
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        System.assertEquals('System Administrator', p.name);
        
        // Create test user
        User testUser = new User(LastName = 'Test', Alias = 'Test', Email = 'test.user1@intel.com', UserName = 'test.user1@intel.com.crm.testclass', ProfileId = p.id,
                EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert testUser;
        
        // Set the test user's manager to itself
        testUser.Manager = testUser;
        update testUser;
        
        // Create Test Opportunity
        Opportunity opp = Core_Test_Utility.createOpportunity(1)[0];
        
        insert opp;
        System.assertNotEquals(null, opp.id);
        
        // Create Test Milestone for the Test opportunity
        Core_Solution_Milestone__c milestone = new Core_Solution_Milestone__c();
        milestone.Core_Opportunity__c = opp.Id;
        milestone.Core_Milestone_Focus_Area__c = 'Test';
        milestone.Core_Milestone_Focus__c = 'Test';
        milestone.Core_Milestone__c = 'Test';        
        milestone.Core_Status__c = 'Pending'; // Initial State
        milestone.Core_Milestone_Claim_Date__c = System.Today();
        milestone.Core_Owner__c = testUser.Id;
        
        insert milestone;
        System.assertNotEquals(null, milestone.id);
          
        // Create an approval request for the Milestone
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Test Comment');
        req1.setObjectId(milestone.id);
        req1.setNextApproverIds(new Id[]{testUser.id});
    
        // Submit the approval request for the Milestone
        Approval.ProcessResult result = Approval.process(req1);
        
        // Verify the result
        System.assert(result.isSuccess());
        System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status' + result.getInstanceStatus());
 
        
        // Approve the submitted request
        // First, get the ID of the newly created item
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        system.debug('result.getNewWorkitemIds()' + result.getNewWorkitemIds());
    
        // Instantiate the new ProcessWorkitemRequest object and populate it
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approved');
        req2.setAction('Approve');
        req2.setNextApproverIds(new ID[] {testUser.id});
    
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(newWorkItemIds.get(0));
    
        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req2);
    
        // Verify the results
        system.debug('--------->'+result2);
        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
    
        System.assertEquals('Approved', result2.getInstanceStatus(), 'Instance Status' + result2.getInstanceStatus());  

        // Change the status to Approved
        milestone.Core_Status__c = 'Approved';
        
        // Calling the unlock method
        apexpages.currentpage().getparameters().put('id', milestone.id);
        ApexPages.StandardController controller = new ApexPages.StandardController(milestone);
        Core_Milestone_Unlock_Record coreMileStone = new Core_Milestone_Unlock_Record(controller);
                
        PageReference pageRef = Page.Core_Milestone_Unlock_Record;
        Test.setCurrentPage(pageRef);
        coreMileStone.UnlockMilestone();
    }
    
    
    /*
     * Method name  : UnlockMilestoneTest_Pending
     * Description  : Method to test UnlockMilestone functionality when the Status is Pending
     * Return Type  : void
     * Parameters   : None
     */

    static testmethod void UnlockMilestoneTest_Pending()
    {        
         // Create Test Opportunity
        Opportunity opp = Core_Test_Utility.createOpportunity(1)[0];
        
        insert opp;
        System.assertNotEquals(null, opp.id);
        
        // Create Test Milestone for the Test opportunity
        Core_Solution_Milestone__c milestone = new Core_Solution_Milestone__c();
        milestone.Core_Opportunity__c = opp.Id;
        milestone.Core_Milestone_Focus_Area__c = 'Test';
        milestone.Core_Milestone_Focus__c = 'Test';
        milestone.Core_Milestone__c = 'Test';        
        milestone.Core_Status__c = 'Pending';
        milestone.Core_Milestone_Claim_Date__c = System.Today();
        
        insert milestone;
        System.assertNotEquals(null, milestone.id);
        
        // Calling the unlock method
        apexpages.currentpage().getparameters().put('id',milestone.id);
        ApexPages.StandardController controller = new ApexPages.StandardController(milestone);
        Core_Milestone_Unlock_Record coreMileStone = new Core_Milestone_Unlock_Record(controller);
                
        PageReference pageRef = Page.Core_Milestone_Unlock_Record;
        Test.setCurrentPage(pageRef);
        coreMileStone.UnlockMilestone();
        coreMileStone.BackToMileStone();
    }  
}