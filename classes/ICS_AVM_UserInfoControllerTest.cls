@isTest
public with sharing class ICS_AVM_UserInfoControllerTest {
   
    
    @isTest
    static void testgetUserSuccess(){
        Test.startTest();
           Id profileIds = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
            
            system.debug('profileId'+profileIds);
        	list<User> checkUsrList =[SELECT FirstName, LastName,Languagelocalekey ,ProfileId, Email, FederationIdentifier FROM User WHERE ProfileId =:profileIds];
            ICS_AVM_UserInfoController icsAvmUser = new ICS_AVM_UserInfoController();
            
        Test.stopTest();
    }
    
}