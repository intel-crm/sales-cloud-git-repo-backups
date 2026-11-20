/***************************************************************************************************************************
 * Test Class: Level1ProductSettingServiceTest
 * Author And Date: Rohit Podder, 25 MAY 2026
 * Function: Test class for Level1ProductSettingService
 ****************************************************************************************************************************/
@isTest
public class Level1ProductSettingServiceTest {

    @isTest
    static void testCreateSettingsWhenNoneExist() {
        Map<String, String> productIds = new Map<String, String>{
            'Intel Core' => '1001',
            'Intel Xeon' => '1002'
        };

        Level1ProductSettingService service = new Level1ProductSettingService();

        Test.startTest();
        service.createOrUpdateSettings(productIds);
        Test.stopTest();

        Map<String, Core_Level1_Products__c> settings = Core_Level1_Products__c.getAll();
        System.assertEquals(2, settings.size());
    }

    @isTest
    static void testCreateNewSettingsWhenSomeExist() {
        Core_Level1_Products__c existing = new Core_Level1_Products__c();
        existing.Name = 'Intel Core';
        existing.Level_1_Id__c = '1001';
        existing.Is_Active__c = true;
        insert existing;

        Map<String, String> productIds = new Map<String, String>{
            'Intel Core' => '1001',
            'Intel Xeon' => '1002'
        };

        Level1ProductSettingService service = new Level1ProductSettingService();

        Test.startTest();
        service.createOrUpdateSettings(productIds);
        Test.stopTest();

        Map<String, Core_Level1_Products__c> settings = Core_Level1_Products__c.getAll();
        System.assertEquals(2, settings.size());
    }

    @isTest
    static void testDeactivateRemovedSettings() {
        Core_Level1_Products__c existing = new Core_Level1_Products__c();
        existing.Name = 'Intel Atom';
        existing.Level_1_Id__c = '9999';
        existing.Is_Active__c = true;
        insert existing;

        Map<String, String> productIds = new Map<String, String>{
            'Intel Core' => '1001'
        };

        Level1ProductSettingService service = new Level1ProductSettingService();

        Test.startTest();
        service.createOrUpdateSettings(productIds);
        Test.stopTest();

        Core_Level1_Products__c deactivated = [SELECT Is_Active__c FROM Core_Level1_Products__c WHERE Level_1_Id__c = '9999' LIMIT 1];
        System.assertEquals(false, deactivated.Is_Active__c);
    }
}