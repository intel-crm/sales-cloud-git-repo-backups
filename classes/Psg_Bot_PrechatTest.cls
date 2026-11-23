/****************************************************************************************************
Apex Class Name : Psg_Bot_PrechatTest
Version         : 1.0 
Created Date    : 12/16/2022
Function        : 
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ranjit                    02/08/2023                Created
*****************************************************************************************************/

@isTest
public class Psg_Bot_PrechatTest {
    
    @isTest
   static void testGetCurrentUser() {
   Profile profileId = [SELECT Id FROM Profile WHERE Name='IT Admin'];
        
        String uniqueUserName = 'userNameIntial' + String.valueof((Integer)(Math.random()*100)) + '@intel.com';
        UserRole admin = [SELECT Id from UserRole where Name = 'Admin' limit 1];
        
        User user = new User(FirstName='testbot',LastName='test Last', ProfileId = profileId.Id , Email=uniqueUserName,
                             LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',LanguageLocaleKey='en_US',
                             Alias= (String.valueOf(datetime.now()).substring(0,8)), UserRoleId = admin.Id,
                            UserName=uniqueUserName, EmailEncodingKey='UTF-8'   );
   insert user;
       
    Test.startTest();
    User u = [SELECT Id, FirstName, LastName, Email FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(u) {
        String result = Psg_Bot_Prechat.getCurrentUser();
        Map<String, Object> output = (Map<String, Object>) JSON.deserializeUntyped(result);

        System.assertEquals(u.Id, output.get('userId'));
        System.assertEquals(u.FirstName, output.get('firstName'));
        System.assertEquals(u.LastName, output.get('lastName'));
        System.assertEquals(u.Email, output.get('email'));
    }
    Test.stopTest();
}


}