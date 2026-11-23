@isTest(SeeAllData=false)
public class UCD_AccountRecordTypeController_Test {
    
    public static testMethod void fetchAccountRecordTypes(){
        List<UCD_AccountRecordTypeController.AccountRecordTypeWrapper> recTypeWrap = UCD_AccountRecordTypeController.fetchAccountRecordTypes();	
        System.assert(recTypeWrap != null, 'Record type list is empty');
    }
    @TestSetup
    static void setupTestData(){
    Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    
         User us = new User();
        us.FirstName = 'test';
        us.LastName = 'user';
        us.Email = 'testuser@intel.com';
        us.Username = 'testinguser@inteltest.com';
        us.Alias = 'testu';
        us.CommunityNickname = 'test.userqwert';
        us.TimeZoneSidKey = 'America/Los_Angeles';
        us.LocaleSidKey = 'en_US';
        us.EmailEncodingKey = 'UTF-8';
        us.ProfileId = profileId.Id;
        us.LanguageLocaleKey = 'en_US';
        insert us;
    }
    
     public static testMethod void fetchAccountRecordType(){
         	User testUser = [SELECT Id FROM User WHERE alias = 'testu'];
        test.startTest();
	   System.runAs(testUser){
        try{
        List<UCD_AccountRecordTypeController.AccountRecordTypeWrapper> recTypeWrap = UCD_AccountRecordTypeController.fetchAccountRecordTypes();	
        } catch (DmlException ex) {
            System.assertEquals('expected text', ex.getMessage());
        }  
        test.stopTest();

     //   List<UCD_AccountRecordTypeController.AccountRecordTypeWrapper> recTypeWrap = UCD_AccountRecordTypeController.fetchAccountRecordTypes();	
      //  System.assert(recTypeWrap != null, 'Record type list is empty');
       }
     }
    
}