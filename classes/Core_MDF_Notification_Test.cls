@isTest(seeAlldata = false)
public class Core_MDF_Notification_Test {

    public static User createUser(){
        User user = new User();
        user.Username = 'test24446@test.com';
        user.LastName = 'TestLastName';
        user.Email = 'test@intel.com';
        user.Alias = 'test';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'UTF-8';
        user.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        user.LanguageLocaleKey = 'en_US';
        user.IsActive = true;
        return user;
    }
    
    public static testMethod void testGetContent(){
        //Create Custom Setting Record
        Core_Banner_Text__c customSetting = new Core_Banner_Text__c();
        customSetting.Name = 'Test Custom Setting';
        customSetting.Core_CRM_Project__c = 'CCP';
        customSetting.core_CRM_type__c = 'Community Home';
        customSetting.core_isActive__c = true;
        customSetting.Core_Text_Message__c = 'Test Message';
        customSetting.Core_Start_Date__c = System.today() - 5;
        customSetting.Core_End_Date__c = System.today() + 5;
        insert customSetting;
        
        User usr = createUser();
        System.runAs(usr){
            Test.startTest();
            String content = Core_MDF_Notification.getContent(customSetting.Core_CRM_Project__c, customSetting.core_CRM_type__c);
            Test.stopTest();
            System.assertEquals('Test Message', content, 'Content does not match');
        }
    }
    
    public static testMethod void testGetContentException(){
        User usr = createUser();
        System.runAs(usr){
            Test.startTest();
            String content = Core_MDF_Notification.getContent(null, null);
            Test.stopTest();
            System.assertEquals('', content, 'Content does not match');
        }
    }
    
}