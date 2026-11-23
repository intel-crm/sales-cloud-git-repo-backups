@isTest
public class Sales_Bot_PreChatCmpCnt_Test {
    @isTest
    public static void testvalidScenerio(){
        Sales_CreateComputerDetails_Bot.ComputerInput Input1 = new Sales_CreateComputerDetails_Bot.ComputerInput();      
        Sales_CreateComputerDetails_Bot.ComputerInput Input2 = new Sales_CreateComputerDetails_Bot.ComputerInput();   
        Sales_CreateComputerDetails_Bot.ComputerInput Input3 = new Sales_CreateComputerDetails_Bot.ComputerInput();   
       User u1=createUserWithProfile();
        System.runAs(u1){
            Account acc = Sales_TestDataFactory.createDefaultAccount();
            insert acc;
            Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
            insert con1;
            Test.startTest();
            String output = Sales_Bot_PreChatCmpCnt.getCurrentUser();
            test.stopTest();
        }
    }
     public static User createUserWithProfile() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name='IT Admin'];
        String uniqueUserName = 'userNameIntial' + String.valueof((Integer)(Math.random()*100)) + '@intel.com';
        UserRole admin = [SELECT Id from UserRole where Name = 'Admin' limit 1];
        User user = new User(FirstName='test',LastName='test Last', ProfileId = profileId.Id , Email=uniqueUserName,
                             LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',LanguageLocaleKey='en_US',
                             Alias= (String.valueOf(datetime.now()).substring(0,8)), UserRoleId = admin.Id,
                            UserName=uniqueUserName, EmailEncodingKey='UTF-8'   );
        return user;
    }
}