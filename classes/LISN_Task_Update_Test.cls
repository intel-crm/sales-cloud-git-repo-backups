@IsTest
public class LISN_Task_Update_Test {
    
    @isTest static void LISNTaskTest() {


        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUser@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@intel.com',FirstName='Test');
        insert testUser;
        
        List<Task> tskList = new List<Task>();
        Task tsk1 = new Task();
        tsk1.Subject = 'InMail from Sales Navigator';
        tsk1.Status = 'Completed';
        tsk1.OwnerId=testUser.Id;
        tskList.add(tsk1);
        
        Task tsk2 = new Task();
        tsk2.Subject = 'Message from Sales Navigator';
        tsk2.Status = 'Completed';
        tsk2.OwnerId=testUser.Id;
        tskList.add(tsk2);

        Task tsk3 = new Task();
        tsk3.Subject = 'Phone Call from Sales Navigator';
        tsk3.Status = 'Completed';
        tsk3.OwnerId=testUser.Id;
        tskList.add(tsk3);

        insert tskList;
        
        //System.assertEquals('LinkedIn', tsk1.Core_Activity_Source__c);
        //System.assertEquals('LinkedIn', tsk2.Core_Activity_Source__c);
        //System.assertEquals('LinkedIn', tsk3.Core_Activity_Source__c);

    }
    
}