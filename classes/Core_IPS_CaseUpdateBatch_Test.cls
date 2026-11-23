/***************************************************************************************************
* Class Name          : Core_IPS_CaseUpdateBatch_Test
* Version             : 1.0 
* Description         : Batch class to update manager fields on Case
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                    
* Amritesh                    10/19/2018             Created US194563
****************************************************************************************************/ 

@isTest
private class Core_IPS_CaseUpdateBatch_Test {
    private static User SystUserRunAs;    
    private static void getRecords(){
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
        List<User> userList = new List<user>();
        userList = TestUtilities.getListOfUser(1);
        userList[0].profileId=prof.id;
        insert userlist;        
        SystUserRunAs = userList[0];
        Core_IPS_User_Manager_Tracker__c managerTracker = new Core_IPS_User_Manager_Tracker__c(Name=userList.get(0).Id);
        insert managerTracker; 
        Integer recordLimit = 10;
        System.runAs(SystUserRunAs) {
        
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'managerChangelogger';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_UserTriggerHandler';
            TriggerExecution.Core_Description__c = 'managerChangelogger';
            TriggerExecution.Core_Object__c = 'User';
            TriggerExecution.Core_Trigger_Events__c = 'after update';
            insert TriggerExecution; 
            
            Profile agentprof = [select id from profile where name = 'IPS Agent' limit 1];
            
            Id intelSupportOwner;
            List<User> lstUser = TestUtilities.getListOfUser(5);
            for(User objUser : lstUser) {
                objUser.profileId = agentprof.Id;
            }
            insert lstUser;
            intelSupportOwner = lstUser[0].Id;
            
            lstUser[2].ManagerId = lstUser[1].Id;
            lstUser[3].ManagerId = lstUser[2].Id;
            update lstUser;
                        
            //Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(recordLimit);
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            
            //Create Contacts
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(recordLimit);
            Integer i=0;
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.core_ips_Active__c=true;
                ContactRec.Accountid = ListOfAccounts.get(i).Id; 
                i++;
            }
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');
            
            //Create Case
            List<Case> lstCase = TestUtilities.getListOfCases(10);
            i=0;
            for(Case objCase : lstCase) {
                objCase.accountId = ListOfAccounts.get(i).Id;
                objCase.ContactId = ListOfContacts.get(i).Id;
                objCase.Core_IPS_Owner_Manager__c = lstUser[1].Id;
                i++;
            }            
            insert lstCase; 
            i=0;
            for(Case objCase : lstCase) {  
                if(i<5)
                    objCase.OwnerId = lstUser[3].Id;
                else
                    objCase.OwnerId = lstUser[4].Id;
            }           
            //update lstCase;
        }
    }
    
    static testmethod void TestManagerChange(){
        getRecords();
        Test.startTest();
        Core_IPS_CaseUpdateBatch batchUCM = new Core_IPS_CaseUpdateBatch(Core_IPS_CaseUpdateBatch.batchMode.ManagerUpdate);
        Database.executeBatch(batchUCM);        
        Test.stopTest();
    }
    
    static testmethod void TestCore_IPS_ScheduleCaseUpdateBatch() {
    //getRecords();
    
       Test.startTest();        
    
          // Schedule the test job
    
        String jobId = System.schedule('Weekly Case Owners Manager Update', Core_IPS_ScheduleCaseUpdateBatch.CRON_EXP, new Core_IPS_ScheduleCaseUpdateBatch());
    
       Test.stopTest();

   }
}