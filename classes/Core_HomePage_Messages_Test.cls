@isTest
public class Core_HomePage_Messages_Test {
     
    @testSetup
    static void setupTestData() {
        // Create Banner Setting
        Core_Banner_Setting__c bannerSetting = new Core_Banner_Setting__c(IsBannerVisible__c = true);
        insert bannerSetting;

        // Create Home Page Banner Message
        Core_Banner_Text__c homeBanner = new Core_Banner_Text__c(
            core_CRM_type__c = 'Home Page',
            core_isActive__c = true,
            Core_Start_Date__c = Date.today().addDays(-1),
            Core_End_Date__c = Date.today().addDays(1),
            Core_Text_Message__c = 'Welcome to the Home Page',
            Core_CRM_Project__c='CRM'
        );
        insert homeBanner;

        // Create Default Home Page Banner Message
        Core_Banner_Text__c defaultHomeBanner = new Core_Banner_Text__c(
            core_CRM_type__c = 'Home Page Default',
            Core_Text_Message__c = 'Default Home Page Message',
            Core_CRM_Project__c='CRM'
        );
        insert defaultHomeBanner;

        // Create KPI Header and Body Messages
        Core_Banner_Text__c kpiHeader = new Core_Banner_Text__c(
            core_CRM_type__c = 'KPI header',
            core_isActive__c = true,
            Core_Start_Date__c = Date.today().addDays(-1),
            Core_End_Date__c = Date.today().addDays(1),
            Core_Text_Message__c = 'KPI Header Message',
            Core_CRM_Project__c='CRM'
        );

        Core_Banner_Text__c kpiBody = new Core_Banner_Text__c(
            core_CRM_type__c = 'KPI body',
            core_isActive__c = true,
            Core_Start_Date__c = Date.today().addDays(-1),
            Core_End_Date__c = Date.today().addDays(1),
            Core_Text_Message__c = 'KPI Body Message',
            Core_CRM_Project__c='CRM'
        );

        insert new List<Core_Banner_Text__c>{ kpiHeader, kpiBody };

        // Default KPI Messages
        Core_Banner_Text__c kpiHeaderDefault = new Core_Banner_Text__c(
            core_CRM_type__c = 'KPI header default',
            Core_Text_Message__c = 'Default KPI Header Message',
            Core_CRM_Project__c='CRM'
        );

        Core_Banner_Text__c kpiBodyDefault = new Core_Banner_Text__c(
            core_CRM_type__c = 'KPI body default',
            Core_Text_Message__c = 'Default KPI Body Message',
            Core_CRM_Project__c='CRM'
        );

        insert new List<Core_Banner_Text__c>{ kpiHeaderDefault, kpiBodyDefault };
    }

    @isTest
    static void testGetBannerTextMsg() {
        Test.startTest();
        Core_HomePage_Messages.getBannerTextMsg();
        Test.stopTest();

        // Assert that the correct banner message is retrieved
        System.assertEquals('Welcome to the Home Page', Core_HomePage_Messages.message);
    }

    @isTest
    static void testGetBannerTextMsg_NoActiveBanner() {
        Test.startTest();
        
        // Delete active banner so default is used
        delete [SELECT Id FROM Core_Banner_Text__c WHERE core_CRM_type__c = 'Home Page'];
        
        Core_HomePage_Messages.getBannerTextMsg();
        Test.stopTest();

        // Assert fallback default banner message
        System.assertEquals('Default Home Page Message', Core_HomePage_Messages.message);
    }

    @isTest
    static void testGetkpiTextMsg() {
        Test.startTest();
        Core_HomePage_Messages.getkpiTextMsg();
        Test.stopTest();

        // Assert that KPI messages are retrieved correctly
        System.assertEquals('KPI Header Message', Core_HomePage_Messages.kpiheadermsg);
        System.assertEquals('KPI Body Message', Core_HomePage_Messages.kpibodymsg);
    }

    @isTest
    static void testGetkpiTextMsg_NoActiveMessages() {
        Test.startTest();

        // Delete active KPI messages so defaults are used
        delete [SELECT Id FROM Core_Banner_Text__c WHERE core_CRM_type__c IN ('KPI header', 'KPI body')];

        Core_HomePage_Messages.getkpiTextMsg();
        Test.stopTest();

        // Assert fallback default KPI messages
        System.assertEquals('Default KPI Header Message', Core_HomePage_Messages.kpiheadermsg);
        System.assertEquals('Default KPI Body Message', Core_HomePage_Messages.kpibodymsg);
    }

   /* @isTest
    static void testGetBannerTextMsgLWC() {
        Test.startTest();
        String bannerMessage = Core_HomePage_Messages.getBannerTextMsgLWC();
        Test.stopTest();

        // Assert that the LWC method retrieves the correct banner message
        System.assertEquals('Welcome to the Home Page', bannerMessage);
    }

    @isTest
    static void testGetkpiTextMsgLWC() {
        Test.startTest();
        Map<String, String> kpiMessages = Core_HomePage_Messages.getkpiTextMsgLWC();
        Test.stopTest();

        // Assert KPI header and body messages are retrieved
        System.assertEquals('KPI Header Message', kpiMessages.get('Head'));
        System.assertEquals('KPI Body Message', kpiMessages.get('Body'));
    }

    @isTest
    static void testGetkpiTextMsgLWC_NoActiveMessages() {
        Test.startTest();
        
        // Delete active KPI messages
        delete [SELECT Id FROM Core_Banner_Text__c WHERE core_CRM_type__c IN ('KPI header', 'KPI body')];

        Map<String, String> kpiMessages = Core_HomePage_Messages.getkpiTextMsgLWC();
        Test.stopTest();

        // Assert fallback default KPI messages
        System.assertEquals('Default KPI Header Message', null);
        System.assertEquals('Default KPI Body Message', null);
    }   */
 }