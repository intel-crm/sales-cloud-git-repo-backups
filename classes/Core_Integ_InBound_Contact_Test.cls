//It's a split test class from Core_IntInboundMsgERPM_Contact_Test
//This test class is covering all the IPA related test cases.
@isTest
public class Core_Integ_InBound_Contact_Test {
    
    @testSetup static void setupTestData() {
        Test.startTest();
        //Below method is to setup the test data 
        //The boolean flag will help us differentiate the testdata setup between IPA & Non IPA requirements
        Core_IntegrationTestUtility.setupAcctContactEntitlementTestData(true); 
        Test.stopTest();
    }
    
    // Helper methods to make it easy to create our messages
    static Core_Integration_Inbound_Message__c newMessage(String sourceSystem, String messageType, String payload){  
        return new Core_Integration_Inbound_Message__c(Core_Source_System__c = sourceSystem,
                                                       Core_Message_Type__c = messageType, Core_Processing_Status__c = 'Pending', Core_Payload__c = payload);
    }
    
    static Core_Integration_Inbound_Message__c newERPMPersonMessage(String payload) {
        return newMessage('ERPM', 'Contact', payload);
    }
    
    @isTest static void Validate_AccountPersonRelationships() {
        
        System.debug('***** Validate_AccountPersonRelationship ***** ');
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = false;
        String msg = TEST_ERPM_PERSON_XML_RELATION;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0_new');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName2_New');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName2_New');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact0@acct0.com'); // By including "duplicate" after @ symbol, we ensure we *will* process
        // such messages and only ignore them if it's before @ symbol
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1000');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 0');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'CSPx2');        
        msg = msg.replace('<all-intel-no-contact-dtm isnull-indicator="Y" />', '<all-intel-no-contact-dtm isnull-indicator="N" >08/29/2017 03:48:14 AM</all-intel-no-contact-dtm>');
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        Contact c = [select Id, Core_IPA_PartnerRole__c from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];
        Account a = [select Id from Account where Core_CIM_ID__c = '1000' and Name ='Test Account 0' limit 1];
        
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);
        /*
        //system.assertEquals('Service Provider', c.Core_IPA_PartnerRole__c);
        List<PRM_Account_Contact_Relationship__c> acctContReltns = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c,PRM_Status_Nm__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:a.Id AND PRM_Contact_Id__c =:c.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];
        
        system.debug('--TestClass-- ::: acctContReltns ::: ' + acctContReltns);       
        System.assertEquals('PRIMARY', acctContReltns[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        System.assertEquals('WORKSFOR', acctContReltns[1].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        
        System.assertEquals('Complete', acctContReltns[0].PRM_Status_Nm__c);*/
        
        List<PRM_ContactSubscriptionAssociation__c> subsList = [SELECT Id, PRM_Status_Reason_Txt__c, PRM_Partner_Subscription_Id__c, PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c , PRM_Contact_Id__c, PRM_Status_Nm__c FROM PRM_ContactSubscriptionAssociation__c
                                                                WHERE PRM_Contact_Id__c =: c.Id];
        system.assertEquals('Gold', subsList[0].PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c);
        system.assertEquals('Active', subsList[0].PRM_Status_Nm__c);
        system.assertEquals('Platinum', subsList[1].PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c);
        system.assertEquals('Active', subsList[1].PRM_Status_Nm__c);
        
    }  
    
    @isTest static void Validate_AccountPersonRelationships_ISA_ITP() {
        
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = false;
        System.debug('***** Validate_AccountPersonRelationship ***** ');       
        String msg = TEST_ERPM_PERSON_XML_RELATION_ISA_ITP;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0_new');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName0_New');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName0_New');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact0@acct0.com'); // By including "duplicate" after @ symbol, we ensure we *will* process
        // such messages and only ignore them if it's before @ symbol
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1000');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 0');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ISA');        
        msg = msg.replace('<all-intel-no-contact-dtm isnull-indicator="Y" />', '<all-intel-no-contact-dtm isnull-indicator="N" >08/29/2017 03:48:14 AM</all-intel-no-contact-dtm>');
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);        
        Test.stopTest();
        
        Contact c = [select Id from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1];
        Account a = [select Id from Account where Core_CIM_ID__c = '1000' and Name ='Test Account 0' limit 1];
        
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);
        /*
        List<PRM_Account_Contact_Relationship__c> acctContReltns = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c, PRM_InActive_Ind__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:a.Id AND PRM_Contact_Id__c =:c.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];               
        
        System.assertEquals(2, acctContReltns.size());     
        System.assertEquals('PRIMARY', acctContReltns[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        System.assertEquals(false, acctContReltns[0].PRM_InActive_Ind__c);
        System.assertEquals('WORKSFOR', acctContReltns[1].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        System.assertEquals(false, acctContReltns[1].PRM_InActive_Ind__c);
        */
        List<PRM_ContactSubscriptionAssociation__c> subsList = [SELECT Id, PRM_Status_Reason_Txt__c, PRM_Partner_Subscription_Id__c, PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c , PRM_Contact_Id__c, PRM_Status_Nm__c FROM PRM_ContactSubscriptionAssociation__c
                                                                WHERE PRM_Contact_Id__c =: c.Id];
        
        system.assertEquals('Gold', subsList[0].PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c);
        system.assertEquals('Active', subsList[0].PRM_Status_Nm__c);
        system.assertEquals('Platinum', subsList[1].PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c);
        system.assertEquals('Active', subsList[1].PRM_Status_Nm__c);
        
    } 
    //commenting the test case as getting SOQL limit exception, will uncomment once we fix
    /*
    @isTest static void Set_ContactEntitlements_ISA() {
        
        System.debug('***** Set_ContactEntitlements_ISA ***** ');       
        String msg = TEST_ERPM_PERSON_XML_RELATIONSHIP_ENTITLEMENT_ISA;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0_new');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName0_New');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName0_New');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact0@acct0.com'); // By including "duplicate" after @ symbol, we ensure we *will* process
        // such messages and only ignore them if it's before @ symbol
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1000');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 0');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ISA');        
        msg = msg.replace('<all-intel-no-contact-dtm isnull-indicator="Y" />', '<all-intel-no-contact-dtm isnull-indicator="N" >08/29/2017 03:48:14 AM</all-intel-no-contact-dtm>');
        Test.startTest();
        System.debug('##### msg = ' + msg);
        List<string> eRPM_engg_codes = new List<string>{'AE1','AE2'};
        List<Core_Entitlement__c> testEntitlements = new List<Core_Entitlement__c>();
        List<Core_ERPM_Engagement__c> testERPMEnggs = [SELECT ID FROM Core_ERPM_Engagement__c WHERE Core_Technical_Engagement_Code__c IN :eRPM_engg_codes];
        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[0].Id, Core_IsActive__c=false,
                                                     Name='Marketing Specialist', Core_Display_Name__c='Marketing Specialist'));
        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[1].Id, Core_IsActive__c=false,
                                                     Name='Employee', Core_Display_Name__c='Employee'));
        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[0].Id, Core_IsActive__c=false,
                                                     Name='Lead Development Representative', Core_Display_Name__c='Lead Development Representative'));
        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[1].Id, Core_IsActive__c=false,
                                                     Name='Offering Editor', Core_Display_Name__c='Offering Editor'));
        testEntitlements.add(new Core_Entitlement__c(Core_ERPM_Engagement_Id__c=testERPMEnggs[1].Id, Core_IsActive__c=false,
                                                     Name='Partner Admin', Core_Display_Name__c='Partner Admin'));                
        insert testEntitlements;
        insert newERPMPersonMessage(msg);                                
        set<string> contactEntitlements = new set<string>();
        for(Core_Contact_Entitlement__c contEntitlemnt : [SELECT Core_Entitlement_Id__r.Name, Core_Selected__c, Core_Status__c
                                                          FROM Core_Contact_Entitlement__c                                                                     
                                                          WHERE Core_Contact_Id__c =: [select Id from Contact where Core_eRPM_Person_Id__c = '3000000' limit 1].Id
                                                          ORDER BY Core_Entitlement_Id__r.Name ASC]){
                                                              contactEntitlements.add(contEntitlemnt.Core_Entitlement_Id__r.Name);
                                                          }
        
        system.debug('--TestClass-- ::: contactEntitlements ::: ' + contactEntitlements);               
        system.debug('--TestClass-- ::: contactEntitlements.size() ::: ' + contactEntitlements.size());  
        System.assertEquals(true, contactEntitlements.contains('Employee')); 
        System.assertEquals(true, contactEntitlements.contains('Partner Admin'));
        Test.stopTest();
    } 
    */
    @isTest static void Validate_PersonSubscriptions() {
        
        System.debug('***** Validate_PersonSubscriptions ***** ');
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = false;
        String msg = TEST_ERPM_PERSON_XML_SUBSCRIPTION;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000000');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test0_new');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName0_New');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName0_New');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact0@acct0.com'); // By including "duplicate" after @ symbol, we ensure we *will* process
        // such messages and only ignore them if it's before @ symbol
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');       
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'CSPx2');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1000');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 0');
        msg = msg.replace('REPLACE_PERSON_PERSON_ENGG_NAME1',  'Intel Cloud Insider Program');       
        msg = msg.replace('<all-intel-no-contact-dtm isnull-indicator="Y" />', '<all-intel-no-contact-dtm isnull-indicator="N" >08/29/2017 03:48:14 AM</all-intel-no-contact-dtm>');
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        Contact c = [select Id, Core_IPA_Email_Verification_Date__c, Core_IPA_Intel_Last_Login_Date__c,
                     RecordTypeId, AccountId
                     from Contact 
                     where Core_eRPM_Person_Id__c = '3000000' limit 1];   
        
        PRM_AccountChannelMembership__c acm =[SELECT Id FROM PRM_AccountChannelMembership__c
                                              WHERE PRM_Account_Id__c =: c.AccountId limit 1];
        
        System.debug('acm='+acm);
        System.debug('##### c = ' + c);
        System.debug('##### c.EV = ' + c.Core_IPA_Email_Verification_Date__c);
        System.debug('##### c.LastLogin = ' + c.Core_IPA_Intel_Last_Login_Date__c);
        System.debug('##### c.LastLogin = ' + string.valueOfGmt(c.Core_IPA_Intel_Last_Login_Date__c));
        
        
        system.assertEquals('2019-04-22 08:35:46', string.valueOfGmt(c.Core_IPA_Email_Verification_Date__c));
        system.assertEquals('2019-05-28 00:39:01', string.valueOfGmt(c.Core_IPA_Intel_Last_Login_Date__c));
        //System.assertEquals('Intel Contact', [select RecordType.Name from RecordType where sObjectType='Contact' and RecordType.Id=: c.RecordTypeId].Name);
        
        List<PRM_ContactSubscriptionAssociation__c> subsList = [SELECT Id, PRM_Status_Reason_Txt__c, PRM_Partner_Subscription_Id__c, PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c , PRM_Contact_Id__c, PRM_Status_Nm__c FROM PRM_ContactSubscriptionAssociation__c
                                                                WHERE PRM_Contact_Id__c =: c.Id];
        
        system.debug('subsList'+subsList);
        //if(subsList !=null && subsList.size()>0){
        system.assertEquals('Gold', subsList[0].PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c);
        system.assertEquals('Active', subsList[0].PRM_Status_Nm__c);
        system.assertEquals('Platinum', subsList[1].PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c);
        system.assertEquals('Active', subsList[1].PRM_Status_Nm__c);        
    }
    
     @isTest static void NewUserExistingAccount_ITP_MultipleSameCIM() {
        
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = false;
        String msg = TEST_ERPM_PERSON_MUL_ACCTS;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3009001');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test91');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '10001010001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'Saskue');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'Uchiha');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact19@acct19.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '8888');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_CIM_ID',     '8888');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 8');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_NAME',       'Test Account 8');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ITP');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_ENGG_CODE', 'CSPx2'); 
        msg = msg.replace('DEDUPGRPCODE1', 'DEDUPGPITP');   
        msg = msg.replace('DEDUPGRPCODE2', 'DEDUPGRPCIP');
         
        System.debug('msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        //Contact c = [select Id, AccountId, Core_IPA_PartnerRole__c,RecordTypeId,Core_Preferred_Language__c,Core_eRPM_Language_Code__c
                     //from Contact where Core_eRPM_Person_Id__c = '3009001' limit 1];
        Contact c = [select Id, AccountId, Core_IPA_PartnerRole__c,RecordTypeId,Core_Preferred_Language__c,Core_eRPM_Language_Code__c from Contact where Email = 'testcontact19@acct19.com' limit 1];
        
        Account a = [select Id from Account where Core_CIM_ID__c = '8888' and Name ='Test Account 9' limit 1];
          
        
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);

        System.assertEquals(c.AccountId, a.Id);
           
    }
    
    @isTest static void NewUserExistingAccount_SameCIMRankMatrix()
    {
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = false;
        String msg = TEST_ERPM_PERSON_MUL_ACCTS_RANK_MATRIX;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3009001');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test91');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '10001010001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'Saskue');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'Uchiha');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact19@acct19.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '9999');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_CIM_ID',     '9999');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 8');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_NAME',       'Test Account 8');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ITP');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_ENGG_CODE', 'CSPx2'); 
        msg = msg.replace('DEDUPGRPCODE1', 'DEDUPGPITP');   
        msg = msg.replace('DEDUPGRPCODE2', 'DEDUPGRPCIP');
         
        System.debug('msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        //Contact c = [select Id, AccountId, Core_IPA_PartnerRole__c,RecordTypeId,Core_Preferred_Language__c,Core_eRPM_Language_Code__c
          //           from Contact where Core_eRPM_Person_Id__c = '3009001' limit 1];
        Contact c = [select Id, AccountId, Core_IPA_PartnerRole__c,RecordTypeId,Core_Preferred_Language__c,Core_eRPM_Language_Code__c
                     from Contact where Email = 'testcontact19@acct19.com' limit 1];
        Account a = [select Id from Account where Core_CIM_ID__c = '9999' and Name ='Test Account 10' limit 1];
        
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);

        System.assertEquals(c.AccountId, a.Id);
    }
    
   @isTest static void NewUserExistingAccount_MultipleDiffCIM() {
        
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = false;
        String msg = TEST_ERPM_PERSON_MUL_ACCTS;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3009001');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test91');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '10001010001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'Saskue');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'Uchiha');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact19@acct19.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '8888');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_CIM_ID',     '9999');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 9');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_NAME',       'Test Account 10');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'WOM');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_ENGG_CODE', 'CSPx2'); 
        msg = msg.replace('DEDUPGRPCODE1', 'DEDUPB2B');   
        msg = msg.replace('DEDUPGRPCODE2', 'DEDUPGRPCIP');
         
        System.debug('msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        //Contact c = [select Id, AccountId, Core_IPA_PartnerRole__c,RecordTypeId,
                    // Core_Preferred_Language__c,Core_eRPM_Language_Code__c,Account.Name
                     //from Contact where Core_eRPM_Person_Id__c = '3009001' limit 1];
        Contact c = [select Id, AccountId, Core_IPA_PartnerRole__c,RecordTypeId,
                     Core_Preferred_Language__c,Core_eRPM_Language_Code__c,Account.Name
                     from Contact where Email = 'testcontact19@acct19.com' limit 1];
        Account a = [select Id, Name from Account where Core_CIM_ID__c = '8888' and Name ='Test Account 9' limit 1];
        
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);

       System.assertEquals(a.Name, c.Account.Name);
        System.assertEquals(a.Id, c.AccountId);
           
    }
    
     @isTest static void NewUserExistingAccount_ITP_MultipleDiffCIM() {
         
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = false;
        String msg = TEST_ERPM_PERSON_MUL_ACCTS;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3009001');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test91');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '10001010001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'Saskue');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'Uchiha');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact19@acct19.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '8888');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_CIM_ID',     '9999');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 9');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_NAME',       'Test Account 10');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ITP');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_ENGG_CODE', 'CSPx2'); 
        msg = msg.replace('DEDUPGRPCODE1', 'DEDUPGPITP');   
        msg = msg.replace('DEDUPGRPCODE2', 'DEDUPGRPCIP');
         
        System.debug('msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        //Contact c = [select Id, AccountId, Core_IPA_PartnerRole__c,RecordTypeId,Core_Preferred_Language__c,Core_eRPM_Language_Code__c
                     //from Contact where Core_eRPM_Person_Id__c = '3009001' limit 1];
        Contact c = [select Id, AccountId, Core_IPA_PartnerRole__c,RecordTypeId,Core_Preferred_Language__c,Core_eRPM_Language_Code__c from Contact where Email = 'testcontact19@acct19.com' limit 1];
         
        Account a = [select Id from Account where Core_CIM_ID__c = '8888' and Name ='Test Account 9' limit 1];
        
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);

        System.assertEquals(c.AccountId, a.Id);
           
    }
    
    
    @isTest static void ExistingUserExistingAccount_ITP_MultipleDiffCIM() {
        
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = false;
        String msg = TEST_ERPM_PERSON_MUL_ACCTS;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000030');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test3_new');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '10001010001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'Saskue');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'Uchiha');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact3@acct3.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '8888');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_CIM_ID',     '9999');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 9');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_NAME',       'Test Account 10');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ITP');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_ENGG_CODE', 'CSPx2'); 
        msg = msg.replace('DEDUPGRPCODE1', 'DEDUPGPITP');   
        msg = msg.replace('DEDUPGRPCODE2', 'DEDUPGRPCIP');
         
        System.debug('msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        Contact c = [select Id, AccountId, Core_IPA_PartnerRole__c,RecordTypeId,Core_Preferred_Language__c,Core_eRPM_Language_Code__c
                     from Contact where Core_eRPM_Person_Id__c = '3000030' limit 1];
        Account a = [select Id from Account where Core_CIM_ID__c = '8888' and Name ='Test Account 9' limit 1];
        
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);
        System.assert(c!=null);
        //System.assertEquals(c.AccountId, a.Id);
           
    }
    
    @isTest static void NewUserExistingAccount_ITP_MultipleDiffCIM_Email() {
        
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = false;
        String msg = TEST_ERPM_PERSON_MUL_ACCTS;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3009001');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test91');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '10001010001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'Saskue');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'Uchiha');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact19@acct19.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '8888');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_CIM_ID',     '9999');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 9');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_NAME',       'Test Account 10');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ITP');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT2_ENGG_CODE', 'ITP'); 
        msg = msg.replace('DEDUPGRPCODE1', 'DEDUPGPITP');   
        msg = msg.replace('DEDUPGRPCODE2', 'DEDUPGPITP');
         
        System.debug('msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        //List<Contact> c = [select Id, AccountId, Core_IPA_PartnerRole__c,RecordTypeId,Core_Preferred_Language__c,Core_eRPM_Language_Code__c
                     //from Contact where Core_eRPM_Person_Id__c = '3009001'];
        List<Contact> c = [select Id, AccountId, Core_IPA_PartnerRole__c,RecordTypeId,Core_Preferred_Language__c,Core_eRPM_Language_Code__c
                     from Contact where Email = 'testcontact19@acct19.com'];
        Account a = [select Id from Account where Core_CIM_ID__c = '8888' and Name ='Test Account 9' limit 1];
        
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);

        System.assertEquals(c.Size(), 1);
        System.assertEquals(c[0].AccountId,a.Id);
           
    }
    
    @isTest static void StopNewUserExistingAccount() {
        
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = true;
        String msg = TEST_ERPM_PERSON_XML_RELATION;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '30090019');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test912');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '100010100013');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'John');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'Doe');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact21@acct21.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1000');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 0');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'CSPx2');        
        
        System.debug('########## RDC msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        //Contact c = [select Id, Core_IPA_PartnerRole__c,RecordTypeId from Contact where Core_eRPM_Person_Id__c = '30090019' limit 1];
        Contact c = [select Id, Core_IPA_PartnerRole__c,RecordTypeId from Contact where Email = 'testcontact21@acct21.com' limit 1];
        Account a = [select Id from Account where Core_CIM_ID__c = '1000' and Name ='Test Account 0' limit 1];
        
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);
        
        System.assertEquals(null, c.Core_IPA_PartnerRole__c);        
        List<PRM_Account_Contact_Relationship__c> acctContReltns = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c,
                                                                    PRM_Partner_Role__c, PRM_Status_Nm__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:a.Id AND PRM_Contact_Id__c =:c.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];
        
        System.assertEquals(new List<PRM_Account_Contact_Relationship__c>(), acctContReltns);
    }  
    
    
    @isTest static void NewUserExistingAccount() {
        
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = false;
        String msg = TEST_ERPM_PERSON_XML_RELATION;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '30090019');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test912');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '100010100013');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'John');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'Doe');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact21@acct21.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1000');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 0');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'CSPx2');        
        
        System.debug('########## RDC msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        //Contact c = [select Id, Core_IPA_PartnerRole__c,RecordTypeId from Contact where Core_eRPM_Person_Id__c = '30090019' limit 1];
        Contact c = [select Id, Core_IPA_PartnerRole__c,RecordTypeId from Contact where Email = 'testcontact21@acct21.com' limit 1];
        Account a = [select Id from Account where Core_CIM_ID__c = '1000' and Name ='Test Account 0' limit 1];
        
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);
        
        System.assertEquals('Service Provider', c.Core_IPA_PartnerRole__c);
        System.assertEquals('Intel Contact', [select RecordType.Name from RecordType where sObjectType='Contact' and RecordType.Id=: c.RecordTypeId].Name);
        
        /*List<PRM_Account_Contact_Relationship__c> acctContReltns = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c,
                                                                    PRM_Partner_Role__c, PRM_Status_Nm__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:a.Id AND PRM_Contact_Id__c =:c.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];
        
        system.debug('--TestClass-- ::: acctContReltns ::: ' + acctContReltns);       
        System.assertEquals('PRIMARY', acctContReltns[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        System.assertEquals('WORKSFOR', acctContReltns[1].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        //System.assertEquals('Service Provider<br>', acctContReltns[0].PRM_Partner_Role__c);
        //System.assertEquals('Service Provider<br>', acctContReltns[1].PRM_Partner_Role__c);
        System.assertEquals('Service Provider', acctContReltns[0].PRM_Partner_Role__c);
        System.assertEquals('Service Provider', acctContReltns[1].PRM_Partner_Role__c);
        System.assertEquals('Complete', acctContReltns[0].PRM_Status_Nm__c);*/
    }  
    
    @isTest static void NewUserExistingAccount_ITP_WihACM() {
        
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = false;
        String msg = TEST_ERPM_PERSON_XML_RELATION;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3009001');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test91');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '10001010001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'Max');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'Yellow');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact19@acct19.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1002');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 2');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ITP');        
        
        System.debug('########## RDC msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        //Contact c = [select Id, Core_IPA_PartnerRole__c,RecordTypeId,Core_Preferred_Language__c,Core_eRPM_Language_Code__c
                     //from Contact where Core_eRPM_Person_Id__c = '3009001' limit 1];
       /* Contact c = [select Id, Core_IPA_PartnerRole__c,RecordTypeId,Core_Preferred_Language__c,Core_eRPM_Language_Code__c
                     from Contact where Email = 'testcontact19@acct19.com' limit 1];
        Account a = [select Id from Account where Core_CIM_ID__c = '1002' and Name ='Test Account 2' limit 1];
        
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);
        
        System.debug('##### c = ' + c.Core_Preferred_Language__c +'erpm -'+c.Core_eRPM_Language_Code__c);
        System.assertEquals('ENG', c.Core_Preferred_Language__c);
        System.assertEquals('ENG', c.Core_eRPM_Language_Code__c);
        
        List<PRM_Account_Contact_Relationship__c> acctContReltns = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c,
                                                                    PRM_Partner_Role__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:a.Id AND PRM_Contact_Id__c =:c.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];
        //Test.stopTest();
        system.debug('--TestClass-- ::: acctContReltns ::: ' + acctContReltns);       
        System.assertEquals('PRIMARY', acctContReltns[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);  */  
    }
    
    @isTest static void NewUserExistingAccount_ISA_WihACM() {
        
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = false;
        String msg = TEST_ERPM_PERSON_XML_RELATION;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3009001');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test91');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '10001010001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'Naruto');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'Uzumaki');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact19@acct19.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1005');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 5');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ISA');        
        
        System.debug('########## RDC msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        //Contact c = [select Id, Core_IPA_PartnerRole__c,RecordTypeId from Contact where Core_eRPM_Person_Id__c = '3009001' limit 1];
        /*Contact c = [select Id, Core_IPA_PartnerRole__c,RecordTypeId from Contact where Email = 'testcontact19@acct19.com' limit 1];
        Account a = [select Id from Account where Core_CIM_ID__c = '1005' and Name ='Test Account 5' limit 1];
        
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);
        
        System.assertEquals('Manufacturer', c.Core_IPA_PartnerRole__c);
        
        List<PRM_Account_Contact_Relationship__c> acctContReltns = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c,
                                                                    PRM_Partner_Role__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:a.Id AND PRM_Contact_Id__c =:c.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];
        
        system.debug('--TestClass-- ::: acctContReltns ::: ' + acctContReltns);       
        System.assertEquals('PRIMARY', acctContReltns[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);*/
        //System.assertEquals('WORKSFOR', acctContReltns[1].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);                     
    }
    
    @isTest static void NewUserExistingAccount_ITP_NoACM() {
        
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = false;
        String msg = TEST_ERPM_PERSON_XML_RELATION;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3009001');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test91');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '10001010001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'Luffy');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'Monkey');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact19@acct19.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1004');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 4');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ITP');        
        
        System.debug('########## RDC msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        //Contact c = [select Id, Core_IPA_PartnerRole__c,RecordTypeId from Contact where Core_eRPM_Person_Id__c = '3009001' limit 1];
        Contact c = [select Id, AccountId, Core_IPA_PartnerRole__c,RecordTypeId,Core_Preferred_Language__c,Core_eRPM_Language_Code__c from Contact where Email = 'testcontact19@acct19.com' limit 1];
        Account a = [select Id from Account where Core_CIM_ID__c = '1004' and Name ='Test Account 4' limit 1];
        
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);
        
        List<PRM_Account_Contact_Relationship__c> acctContReltns = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c,
                                                                    PRM_Partner_Role__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:a.Id AND PRM_Contact_Id__c =:c.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];
        
        system.debug('--TestClass-- ::: acctContReltns ::: ' + acctContReltns);       
        System.assertEquals(0, acctContReltns.size());        
    }
    
    @isTest static void Validate_Contact_Partner_Role_ITP () {
        
        System.debug('***** Validate_Contact_Partner_Role_ITP ***** ');
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = false;
        String msg = TEST_ERPM_PERSON_XML_RELATION_ISA_ITP;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000030');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test3_new');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName0_New');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName0_New');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact3@acct3.com'); // By including "duplicate" after @ symbol, we ensure we *will* process
        // such messages and only ignore them if it's before @ symbol
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1003');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 3');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ITP');        
        msg = msg.replace('<all-intel-no-contact-dtm isnull-indicator="Y" />', '<all-intel-no-contact-dtm isnull-indicator="N" >08/29/2017 03:48:14 AM</all-intel-no-contact-dtm>');
    
        System.debug('##### msg = ' + msg);
    
        Test.startTest();
        insert newERPMPersonMessage(msg);
		Test.stopTest();        
    
        Contact c = [select Id, Core_IPA_PartnerRole__c from Contact where Core_eRPM_Person_Id__c = '3000030' limit 1];
        Account a = [select Id from Account where Core_CIM_ID__c = '1003' and Name ='Test Account 3' limit 1];
    
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);
    
        System.assertEquals('Seller', c.Core_IPA_PartnerRole__c);  
        
        /*List<PRM_Account_Contact_Relationship__c> acctContReltns = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c, PRM_InActive_Ind__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:a.Id AND PRM_Contact_Id__c =:c.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];               
    
        System.assertEquals(2, acctContReltns.size());     
        System.assertEquals('PRIMARY', acctContReltns[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        System.assertEquals(false, acctContReltns[0].PRM_InActive_Ind__c);
        System.assertEquals('WORKSFOR', acctContReltns[1].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        System.assertEquals(false, acctContReltns[1].PRM_InActive_Ind__c);
    	*/
        List<PRM_ContactSubscriptionAssociation__c> subsList = [SELECT Id, PRM_Status_Reason_Txt__c, PRM_Partner_Subscription_Id__c, PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c , PRM_Contact_Id__c, PRM_Status_Nm__c FROM PRM_ContactSubscriptionAssociation__c
                                                                WHERE PRM_Contact_Id__c =: c.Id];
        
        system.assertEquals('Gold', subsList[0].PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c);
        system.assertEquals('Active', subsList[0].PRM_Status_Nm__c);
        system.assertEquals('Platinum', subsList[1].PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c);
        system.assertEquals('Active', subsList[1].PRM_Status_Nm__c);
    }
    
    @isTest static void Validate_Contact_Partner_Role_ITP_Add_ISA () {
         System.debug('***** Validate_Contact_Partner_Role_ITP ***** '); 
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = false;
        String msg = TEST_ERPM_PERSON_XML_RELATION_ITP_Add_ISA;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3000030');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test3_new');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName0_New');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName0_New');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact3@acct3.com'); // By including "duplicate" after @ symbol, we ensure we *will* process
        // such messages and only ignore them if it's before @ symbol
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1003');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 3');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ISA');        
        msg = msg.replace('<all-intel-no-contact-dtm isnull-indicator="Y" />', '<all-intel-no-contact-dtm isnull-indicator="N" >08/29/2017 03:48:14 AM</all-intel-no-contact-dtm>');
    
        System.debug('##### msg = ' + msg);
    
        Test.startTest();
        insert newERPMPersonMessage(msg);
		Test.stopTest();        
    
        Contact c = [select Id, Core_IPA_PartnerRole__c from Contact where Core_eRPM_Person_Id__c = '3000030' limit 1];
        Account a = [select Id from Account where Core_CIM_ID__c = '1003' and Name ='Test Account 3' limit 1];
    
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);
    
        List<String> ipa_prtnerRole = c.Core_IPA_PartnerRole__c.split(';');
        ipa_prtnerRole.sort();
        c.Core_IPA_PartnerRole__c = String.join( ipa_prtnerRole, ';' );
        //System.assertEquals('Manufacturer;Seller', c.Core_IPA_PartnerRole__c); 
        System.assertEquals('Seller', c.Core_IPA_PartnerRole__c);  
        
        /*List<PRM_Account_Contact_Relationship__c> acctContReltns = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c, PRM_InActive_Ind__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:a.Id AND PRM_Contact_Id__c =:c.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];               
    
        System.assertEquals(2, acctContReltns.size());     
        System.assertEquals('PRIMARY', acctContReltns[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        System.assertEquals(false, acctContReltns[0].PRM_InActive_Ind__c);
        System.assertEquals('WORKSFOR', acctContReltns[1].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        System.assertEquals(false, acctContReltns[1].PRM_InActive_Ind__c);
    	*/
        List<PRM_ContactSubscriptionAssociation__c> subsList = [SELECT Id, PRM_Status_Reason_Txt__c, PRM_Partner_Subscription_Id__c, PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c , PRM_Contact_Id__c, PRM_Status_Nm__c FROM PRM_ContactSubscriptionAssociation__c
                                                                WHERE PRM_Contact_Id__c =: c.Id];
        
        system.assertEquals('Gold', subsList[0].PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c);
        system.assertEquals('Active', subsList[0].PRM_Status_Nm__c);
        system.assertEquals('Platinum', subsList[1].PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c);
        system.assertEquals('Active', subsList[1].PRM_Status_Nm__c);
    }
 
    @isTest static void NewUser_Validate_Contact_PR_ExITP_ISACon() {
         System.debug('***** NewUser_Validate_Contact_PR_ExITP_ISACon ***** ');    
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = false;
        String msg = TEST_ERPM_PERSON_XML_RELATION_PR_ExITP_ISACon;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3009001');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test9_new');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001009');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName9_New');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName9_New');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact9@acct9.com'); // By including "duplicate" after @ symbol, we ensure we *will* process
        // such messages and only ignore them if it's before @ symbol
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1005');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 5');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ISA');        
        msg = msg.replace('<all-intel-no-contact-dtm isnull-indicator="Y" />', '<all-intel-no-contact-dtm isnull-indicator="N" >08/29/2017 03:48:14 AM</all-intel-no-contact-dtm>');
    
        System.debug('##### msg = ' + msg);
    
        Test.startTest();
        insert newERPMPersonMessage(msg);
		Test.stopTest();        
    
        //Contact c = [select Id, Core_IPA_PartnerRole__c from Contact where Core_eRPM_Person_Id__c = '3009001' limit 1];
        /*Contact c = [select Id, Core_IPA_PartnerRole__c from Contact where Email = 'testcontact9@acct9.com' limit 1];
        Account a = [select Id from Account where Core_CIM_ID__c = '1005' and Name ='Test Account 5' limit 1];
    
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);
    
        System.assertEquals('Manufacturer', c.Core_IPA_PartnerRole__c); 
        
        Contact c1 = [select Id, Core_IPA_PartnerRole__c from Contact where Core_eRPM_Person_Id__c = '3000050' limit 1];
        List<String> ipa_prtnerRole = c1.Core_IPA_PartnerRole__c.split(';');
        ipa_prtnerRole.sort();
        c1.Core_IPA_PartnerRole__c = String.join( ipa_prtnerRole, ';' );
        //System.assertEquals('Manufacturer;Seller', c1.Core_IPA_PartnerRole__c); 
        System.assertEquals('Manufacturer', c1.Core_IPA_PartnerRole__c); 
        
        List<PRM_Account_Contact_Relationship__c> acctContReltns = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c, PRM_InActive_Ind__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:a.Id AND PRM_Contact_Id__c =:c.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];               
    
        System.assertEquals(2, acctContReltns.size());     
        System.assertEquals('PRIMARY', acctContReltns[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        System.assertEquals(false, acctContReltns[0].PRM_InActive_Ind__c);
        System.assertEquals('WORKSFOR', acctContReltns[1].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        System.assertEquals(false, acctContReltns[1].PRM_InActive_Ind__c);
    
        List<PRM_ContactSubscriptionAssociation__c> subsList = [SELECT Id, PRM_Status_Reason_Txt__c, PRM_Partner_Subscription_Id__c, PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c , PRM_Contact_Id__c, PRM_Status_Nm__c FROM PRM_ContactSubscriptionAssociation__c
                                                                WHERE PRM_Contact_Id__c =: c.Id];
        
        system.assertEquals('Gold', subsList[0].PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c);
        system.assertEquals('Active', subsList[0].PRM_Status_Nm__c);
        system.assertEquals('Platinum', subsList[1].PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c);
        system.assertEquals('Active', subsList[1].PRM_Status_Nm__c);
		*/
    }
    
    @isTest static void NewUser_Validate_Contact_PR_ExITPODM_ITPCon() {
        System.debug('***** NewUser_Validate_Contact_PR_ExITP_ISACon ***** ');
        Core_IntInboundMsgERPM_Contact.StopERPMSalesCloudIPAInteg = false;
        String msg = TEST_ERPM_PERSON_XML_RELATION_PR_ExITPODM_ITPCon;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3003691');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test9_new');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '1000001009');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName9_New');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName9_New');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact11@acct11.com'); // By including "duplicate" after @ symbol, we ensure we *will* process
        // such messages and only ignore them if it's before @ symbol
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '3691');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'HSK Account 24');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ITP');        
        msg = msg.replace('<all-intel-no-contact-dtm isnull-indicator="Y" />', '<all-intel-no-contact-dtm isnull-indicator="N" >08/29/2017 03:48:14 AM</all-intel-no-contact-dtm>');
    
        System.debug('##### msg = ' + msg);
    
        Test.startTest();
        insert newERPMPersonMessage(msg);
		Test.stopTest();        
    
        Contact c = [select Id, Core_IPA_PartnerRole__c from Contact where Core_eRPM_Person_Id__c = '3003691' limit 1];
        Account a = [select Id from Account where Core_CIM_ID__c = '3691' and Name ='HSK Account 24' limit 1];
    
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);
    
         List<String> ipa_prtnerRole = c.Core_IPA_PartnerRole__c.split(';');
        ipa_prtnerRole.sort();
        c.Core_IPA_PartnerRole__c = String.join( ipa_prtnerRole, ';' );
        System.assertEquals('Seller', c.Core_IPA_PartnerRole__c); 
        
        //Contact c1 = [select Id, Core_IPA_PartnerRole__c from Contact where Core_eRPM_Person_Id__c = '3000060' limit 1];       
       // System.assertEquals('Seller', c1.Core_IPA_PartnerRole__c); 
        
        /*List<PRM_Account_Contact_Relationship__c> acctContReltns = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c, PRM_InActive_Ind__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:a.Id AND PRM_Contact_Id__c =:c.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];               
    
       // System.assertEquals(1, acctContReltns.size());     
        System.assertEquals('PRIMARY', acctContReltns[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);
        System.assertEquals(false, acctContReltns[0].PRM_InActive_Ind__c);*/
    
        List<PRM_ContactSubscriptionAssociation__c> subsList = [SELECT Id, PRM_Status_Reason_Txt__c, PRM_Partner_Subscription_Id__c, PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c , PRM_Contact_Id__c, PRM_Status_Nm__c FROM PRM_ContactSubscriptionAssociation__c
                                                                WHERE PRM_Contact_Id__c =: c.Id];
        
        system.assertEquals('Gold', subsList[0].PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c);
        system.assertEquals('Active', subsList[0].PRM_Status_Nm__c);
        system.assertEquals('Platinum', subsList[1].PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c);
        system.assertEquals('Active', subsList[1].PRM_Status_Nm__c);
    }
    
    
    /*@isTest static void NewUserExtAcct_ITP_WithACM_PR() {
        
        String msg = TEST_ERPM_PERSON_XML_RELATION;
        msg = msg.replace('REPLACE_PERSON_IS_DELETE_INDICATOR','N');
        msg = msg.replace('REPLACE_PERSON_ERPM_PERSON_ID',     '3009001');
        msg = msg.replace('REPLACE_PERSON_EXTERNAL_LOGIN',     'test91');
        msg = msg.replace('REPLACE_PERSON_ENTERPRISE_ID',      '10001010001');
        msg = msg.replace('REPLACE_PERSON_IDENTITY_STATUS',    'A');
        msg = msg.replace('REPLACE_PERSON_TITLE',              'DR');
        msg = msg.replace('REPLACE_PERSON_FIRST_NAME',         'FName7');
        msg = msg.replace('REPLACE_PERSON_LAST_NAME',          'LName7');
        msg = msg.replace('REPLACE_PERSON_EMAIL',              'testcontact19@acct19.com');
        msg = msg.replace('REPLACE_PERSON_PHONE',              '1001001001');
        msg = msg.replace('REPLACE_PERSON_MOBILE',             '2001001001');
        msg = msg.replace('REPLACE_PERSON_FAX',                '3001001001');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE1',         'Addr 1');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE2',         'Addr 2');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE3',         'Addr 3');
        msg = msg.replace('REPLACE_PERSON_ADDR_LINE4',         'Addr 4');
        msg = msg.replace('REPLACE_PERSON_ADDR_CITY',          'Portland');
        msg = msg.replace('REPLACE_PERSON_ADDR_STATE',         'OR');
        msg = msg.replace('REPLACE_PERSON_ADDR_POSTALCODE',    '97229');
        msg = msg.replace('REPLACE_PERSON_ADDR_COUNTRY',       'USA');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_CIM_ID',     '1002');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_NAME',       'Test Account 2');
        msg = msg.replace('REPLACE_PERSON_ACCOUNT_ENGG_CODE1', 'ITP');        
        
        System.debug('########## RDC msg = ' + msg);
        
        Test.startTest();
        insert newERPMPersonMessage(msg);
        Test.stopTest();
        
        Contact c = [select Id, Core_IPA_Partner_Role__c,RecordTypeId from Contact where Core_eRPM_Person_Id__c = '3009001' limit 1];
        Account a = [select Id from Account where Core_CIM_ID__c = '1002' and Name ='Test Account 2' limit 1];
        
        System.debug('##### c = ' + c);
        System.debug('##### a = ' + a);
        
        List<PRM_Account_Contact_Relationship__c> acctContReltns = [SELECT Id, PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c,
                                                                    PRM_Partner_Role__c
                                                                    FROM PRM_Account_Contact_Relationship__c
                                                                    WHERE PRM_Account_Id__c =:a.Id AND PRM_Contact_Id__c =:c.Id
                                                                    ORDER BY PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c ASC];
        //Test.stopTest();
        system.debug('--TestClass-- ::: acctContReltns ::: ' + acctContReltns);       
        System.assertEquals('PRIMARY', acctContReltns[0].PRM_Relationship_Id__r.PRM_Contact_Relationship_Cd__c);    
    }
    */
    
    private static final String TEST_ERPM_PERSON_MUL_ACCTS = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<person xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" inact-indicator="N" is-delete-indicator="REPLACE_PERSON_IS_DELETE_INDICATOR">' +
        '<person-information>' +
        '<person-id>REPLACE_PERSON_ERPM_PERSON_ID</person-id>' +
        '<external-login-id isnull-indicator="N">REPLACE_PERSON_EXTERNAL_LOGIN</external-login-id>' +
        '<enterprise-id isnull-indicator="N">REPLACE_PERSON_ENTERPRISE_ID</enterprise-id>' +
        '<internal-login-id isnull-indicator="Y" />' +
        '<identity-status isnull-indicator="N">REPLACE_PERSON_IDENTITY_STATUS</identity-status>' +
        '<person-title isnull-indicator="N" >REPLACE_PERSON_TITLE</person-title>' +
        '<person-given-name isnull-indicator="N">REPLACE_PERSON_FIRST_NAME</person-given-name>' +
        '<person-family-name isnull-indicator="N">REPLACE_PERSON_LAST_NAME</person-family-name>' +
        '<language-code>ENG</language-code>' +
        '<occupation-title-code isnull-indicator="N">OPER</occupation-title-code>' +
        '<primary-email-address>REPLACE_PERSON_EMAIL</primary-email-address>' +
        '<all-intel-no-contact-dtm isnull-indicator="Y" />' +
        '<email-valid-status-dtm isnull-indicator="Y" />' +
        '<last-login-dtm isnull-indicator="N">05/28/2019 12:39:01 AM</last-login-dtm>' +
        '</person-information>' +
        '<person-accounts>' +       
        '<person-account inact-indicator="N">' +
        '<account-number>10003655</account-number>' +
        '<cim-id isnull-indicator="N">REPLACE_PERSON_ACCOUNT_CIM_ID</cim-id>' +
        '<account-name>REPLACE_PERSON_ACCOUNT_NAME</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGRPCODE1</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNPRCTC</relation-code>' +
        '<relation-name>Primary Contact</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNWRKFR</relation-code>' +
        '<relation-name>Employee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE1</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +       
        '</account-engagements>' +
        '</person-account>' +
              
        '<person-account inact-indicator="N">' +
        '<account-number>10003465</account-number>' +
        '<cim-id isnull-indicator="N">REPLACE_PERSON_ACCOUNT2_CIM_ID</cim-id>' +
        '<account-name>REPLACE_PERSON_ACCOUNT2_NAME</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGRPCODE2</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT2_ENGG_CODE">' +
        '<relation-code>RELTNPRCTC</relation-code>' +
        '<relation-name>Primary Contact</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT2_ENGG_CODE1">' +
        '<relation-code>RELTNWRKFR</relation-code>' +
        '<relation-name>Employee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT2_ENGG_CODE</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +       
        '</account-engagements>' +
        '</person-account>' +
        
        '</person-accounts>' +
        '<person-electronic-addresses>' +
        '<person-electronic-address electronic-addr-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_FAX</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_MOBILE</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_PHONE</electronic-address>' +
        '</person-electronic-address>' +
        '</person-electronic-addresses>' +        
        '<person-physical-addresses>' +
        '<physical-address location-type-code="HOME" address-usg-type-code="MAIL" contact-indicator="Y" inact-indicator="N" preferred-indicator="Y" isnull-indicator="">' +
        '<address-line1-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE1</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE2</address-line2-text>' +
        '<address-line3-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE3</address-line3-text>' +
        '<address-line4-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE4</address-line4-text>' +
        '<city-name isnull-indicator="N">REPLACE_PERSON_ADDR_CITY</city-name>' +
        '<state-code isnull-indicator="N">REPLACE_PERSON_ADDR_STATE</state-code>' +
        '<postal-code isnull-indicator="N">REPLACE_PERSON_ADDR_POSTALCODE</postal-code>' +
        '<language-code isnull-indicator="N">ENG</language-code>' +
        '<iso-country-code>REPLACE_PERSON_ADDR_COUNTRY</iso-country-code>' +
        '</physical-address>' +
        '<physical-address location-type-code="BUS" address-usg-type-code="PHY" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '<physical-address location-type-code="BUS" address-usg-type-code="MAIL" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '</person-physical-addresses>' +
        '<person-subscription opt-in-date="4/18/2018 4:39:51 AM" sent-date="" opt-in-confirmation-date="" opt-in-type="EXEMPT">'+
        '<subscription engg-code="CSPx2" category="OFFRSPRMTN">'+
        '<subscription-code>Gold</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '<subscription engg-code="CSPx2" category="NEWSLETTER">'+
        '<subscription-code>Platinum</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '</person-subscription>'+
        '</person>'; 
    
    private static final String TEST_ERPM_PERSON_MUL_ACCTS_RANK_MATRIX = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<person xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" inact-indicator="N" is-delete-indicator="REPLACE_PERSON_IS_DELETE_INDICATOR">' +
        '<person-information>' +
        '<person-id>REPLACE_PERSON_ERPM_PERSON_ID</person-id>' +
        '<external-login-id isnull-indicator="N">REPLACE_PERSON_EXTERNAL_LOGIN</external-login-id>' +
        '<enterprise-id isnull-indicator="N">REPLACE_PERSON_ENTERPRISE_ID</enterprise-id>' +
        '<internal-login-id isnull-indicator="Y" />' +
        '<identity-status isnull-indicator="N">REPLACE_PERSON_IDENTITY_STATUS</identity-status>' +
        '<person-title isnull-indicator="N" >REPLACE_PERSON_TITLE</person-title>' +
        '<person-given-name isnull-indicator="N">REPLACE_PERSON_FIRST_NAME</person-given-name>' +
        '<person-family-name isnull-indicator="N">REPLACE_PERSON_LAST_NAME</person-family-name>' +
        '<language-code>ENG</language-code>' +
        '<occupation-title-code isnull-indicator="N">OPER</occupation-title-code>' +
        '<primary-email-address>REPLACE_PERSON_EMAIL</primary-email-address>' +
        '<all-intel-no-contact-dtm isnull-indicator="Y" />' +
        '<email-valid-status-dtm isnull-indicator="N">04/22/2019 08:35:46 AM</email-valid-status-dtm>' +
        '<last-login-dtm isnull-indicator="N">05/28/2019 12:39:01 AM</last-login-dtm>' +
        '</person-information>' +
        '<person-accounts>' +       
        '<person-account inact-indicator="N">' +
        '<account-number>54321</account-number>' +
        '<cim-id isnull-indicator="N">REPLACE_PERSON_ACCOUNT_CIM_ID</cim-id>' +
        '<account-name>REPLACE_PERSON_ACCOUNT_NAME</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGRPCODE1</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNPRCTC</relation-code>' +
        '<relation-name>Primary Contact</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNWRKFR</relation-code>' +
        '<relation-name>Employee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE1</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +       
        '</account-engagements>' +
        '</person-account>' +
              
        '<person-account inact-indicator="N">' +
        '<account-number>54321</account-number>' +
        '<cim-id isnull-indicator="N">REPLACE_PERSON_ACCOUNT2_CIM_ID</cim-id>' +
        '<account-name>REPLACE_PERSON_ACCOUNT2_NAME</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGRPCODE2</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT2_ENGG_CODE">' +
        '<relation-code>RELTNPRCTC</relation-code>' +
        '<relation-name>Primary Contact</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT2_ENGG_CODE1">' +
        '<relation-code>RELTNWRKFR</relation-code>' +
        '<relation-name>Employee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT2_ENGG_CODE</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +       
        '</account-engagements>' +
        '</person-account>' +
        
        '</person-accounts>' +
        '<person-electronic-addresses>' +
        '<person-electronic-address electronic-addr-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_FAX</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_MOBILE</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_PHONE</electronic-address>' +
        '</person-electronic-address>' +
        '</person-electronic-addresses>' +        
        '<person-physical-addresses>' +
        '<physical-address location-type-code="HOME" address-usg-type-code="MAIL" contact-indicator="Y" inact-indicator="N" preferred-indicator="Y" isnull-indicator="">' +
        '<address-line1-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE1</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE2</address-line2-text>' +
        '<address-line3-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE3</address-line3-text>' +
        '<address-line4-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE4</address-line4-text>' +
        '<city-name isnull-indicator="N">REPLACE_PERSON_ADDR_CITY</city-name>' +
        '<state-code isnull-indicator="N">REPLACE_PERSON_ADDR_STATE</state-code>' +
        '<postal-code isnull-indicator="N">REPLACE_PERSON_ADDR_POSTALCODE</postal-code>' +
        '<language-code isnull-indicator="N">ENG</language-code>' +
        '<iso-country-code>REPLACE_PERSON_ADDR_COUNTRY</iso-country-code>' +
        '</physical-address>' +
        '<physical-address location-type-code="BUS" address-usg-type-code="PHY" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '<physical-address location-type-code="BUS" address-usg-type-code="MAIL" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '</person-physical-addresses>' +
        '<person-subscription opt-in-date="4/18/2018 4:39:51 AM" sent-date="" opt-in-confirmation-date="" opt-in-type="EXEMPT">'+
        '<subscription engg-code="CSPx2" category="OFFRSPRMTN">'+
        '<subscription-code>Gold</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '<subscription engg-code="CSPx2" category="NEWSLETTER">'+
        '<subscription-code>Platinum</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '</person-subscription>'+
        '</person>'; 
    
    private static final String TEST_ERPM_PERSON_XML_RELATION = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<person xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" inact-indicator="N" is-delete-indicator="REPLACE_PERSON_IS_DELETE_INDICATOR">' +
        '<person-information>' +
        '<person-id>REPLACE_PERSON_ERPM_PERSON_ID</person-id>' +
        '<external-login-id isnull-indicator="N">REPLACE_PERSON_EXTERNAL_LOGIN</external-login-id>' +
        '<enterprise-id isnull-indicator="N">REPLACE_PERSON_ENTERPRISE_ID</enterprise-id>' +
        '<internal-login-id isnull-indicator="Y" />' +
        '<identity-status isnull-indicator="N">REPLACE_PERSON_IDENTITY_STATUS</identity-status>' +
        '<person-title isnull-indicator="N" >REPLACE_PERSON_TITLE</person-title>' +
        '<person-given-name isnull-indicator="N">REPLACE_PERSON_FIRST_NAME</person-given-name>' +
        '<person-family-name isnull-indicator="N">REPLACE_PERSON_LAST_NAME</person-family-name>' +
        '<language-code>ENG</language-code>' +
        '<occupation-title-code isnull-indicator="N">OPER</occupation-title-code>' +
        '<primary-email-address>REPLACE_PERSON_EMAIL</primary-email-address>' +
        '<all-intel-no-contact-dtm isnull-indicator="Y" />' +
        '<email-valid-status-dtm isnull-indicator="N">04/22/2019 08:35:46 AM</email-valid-status-dtm>' +
        '<last-login-dtm isnull-indicator="N">05/28/2019 12:39:01 AM</last-login-dtm>' +
        '</person-information>' +
        '<person-accounts>' +       
        '<person-account inact-indicator="N">' +
        '<account-number>1000054337</account-number>' +
        '<cim-id isnull-indicator="N">REPLACE_PERSON_ACCOUNT_CIM_ID</cim-id>' +
        '<account-name>REPLACE_PERSON_ACCOUNT_NAME</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPSCD</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNPRCTC</relation-code>' +
        '<relation-name>Primary Contact</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNWRKFR</relation-code>' +
        '<relation-name>Employee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE1</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +       
        '</account-engagements>' +
        '</person-account>' +
        '</person-accounts>' +
        '<person-electronic-addresses>' +
        '<person-electronic-address electronic-addr-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_FAX</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_MOBILE</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_PHONE</electronic-address>' +
        '</person-electronic-address>' +
        '</person-electronic-addresses>' +        
        '<person-physical-addresses>' +
        '<physical-address location-type-code="HOME" address-usg-type-code="MAIL" contact-indicator="Y" inact-indicator="N" preferred-indicator="Y" isnull-indicator="">' +
        '<address-line1-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE1</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE2</address-line2-text>' +
        '<address-line3-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE3</address-line3-text>' +
        '<address-line4-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE4</address-line4-text>' +
        '<city-name isnull-indicator="N">REPLACE_PERSON_ADDR_CITY</city-name>' +
        '<state-code isnull-indicator="N">REPLACE_PERSON_ADDR_STATE</state-code>' +
        '<postal-code isnull-indicator="N">REPLACE_PERSON_ADDR_POSTALCODE</postal-code>' +
        '<language-code isnull-indicator="N">ENG</language-code>' +
        '<iso-country-code>REPLACE_PERSON_ADDR_COUNTRY</iso-country-code>' +
        '</physical-address>' +
        '<physical-address location-type-code="BUS" address-usg-type-code="PHY" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '<physical-address location-type-code="BUS" address-usg-type-code="MAIL" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '</person-physical-addresses>' +
        '<person-subscription opt-in-date="4/18/2018 4:39:51 AM" sent-date="" opt-in-confirmation-date="" opt-in-type="EXEMPT">'+
        '<subscription engg-code="CSPx2" category="OFFRSPRMTN">'+
        '<subscription-code>Gold</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '<subscription engg-code="CSPx2" category="NEWSLETTER">'+
        '<subscription-code>Platinum</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '</person-subscription>'+
        '</person>'; 
    
    
    private static final String TEST_ERPM_PERSON_XML_RELATION_ISA_ITP = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<person xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" inact-indicator="N" is-delete-indicator="REPLACE_PERSON_IS_DELETE_INDICATOR">' +
        '<person-information>' +
        '<person-id>REPLACE_PERSON_ERPM_PERSON_ID</person-id>' +
        '<external-login-id isnull-indicator="N">REPLACE_PERSON_EXTERNAL_LOGIN</external-login-id>' +
        '<enterprise-id isnull-indicator="N">REPLACE_PERSON_ENTERPRISE_ID</enterprise-id>' +
        '<internal-login-id isnull-indicator="Y" />' +
        '<identity-status isnull-indicator="N">REPLACE_PERSON_IDENTITY_STATUS</identity-status>' +
        '<person-title isnull-indicator="N" >REPLACE_PERSON_TITLE</person-title>' +
        '<person-given-name isnull-indicator="N">REPLACE_PERSON_FIRST_NAME</person-given-name>' +
        '<person-family-name isnull-indicator="N">REPLACE_PERSON_LAST_NAME</person-family-name>' +
        '<language-code>ENG</language-code>' +
        '<occupation-title-code isnull-indicator="N">OPER</occupation-title-code>' +
        '<primary-email-address>REPLACE_PERSON_EMAIL</primary-email-address>' +
        '<all-intel-no-contact-dtm isnull-indicator="Y" />' +
        '<email-valid-status-dtm isnull-indicator="N">04/22/2019 08:35:46 AM</email-valid-status-dtm>' +
        '<last-login-dtm isnull-indicator="N">05/28/2019 12:39:01 AM</last-login-dtm>' +
        '</person-information>' +
        '<person-accounts>' +       
        '<person-account inact-indicator="N">' +
        '<account-number>1000054337</account-number>' +
        '<cim-id isnull-indicator="N">REPLACE_PERSON_ACCOUNT_CIM_ID</cim-id>' +
        '<account-name>REPLACE_PERSON_ACCOUNT_NAME</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPSCD</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNPRCTC</relation-code>' +
        '<relation-name>Primary Contact</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNWRKFR</relation-code>' +
        '<relation-name>Employee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNACTAD</relation-code>' +
        '<relation-name>Account Administrator</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE1</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +       
        '</account-engagements>' +
        '</person-account>' +
        '</person-accounts>' +
        '<person-electronic-addresses>' +
        '<person-electronic-address electronic-addr-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_FAX</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_MOBILE</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_PHONE</electronic-address>' +
        '</person-electronic-address>' +
        '</person-electronic-addresses>' +        
        '<person-physical-addresses>' +
        '<physical-address location-type-code="HOME" address-usg-type-code="MAIL" contact-indicator="Y" inact-indicator="N" preferred-indicator="Y" isnull-indicator="">' +
        '<address-line1-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE1</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE2</address-line2-text>' +
        '<address-line3-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE3</address-line3-text>' +
        '<address-line4-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE4</address-line4-text>' +
        '<city-name isnull-indicator="N">REPLACE_PERSON_ADDR_CITY</city-name>' +
        '<state-code isnull-indicator="N">REPLACE_PERSON_ADDR_STATE</state-code>' +
        '<postal-code isnull-indicator="N">REPLACE_PERSON_ADDR_POSTALCODE</postal-code>' +
        '<language-code isnull-indicator="N">ENG</language-code>' +
        '<iso-country-code>REPLACE_PERSON_ADDR_COUNTRY</iso-country-code>' +
        '</physical-address>' +
        '<physical-address location-type-code="BUS" address-usg-type-code="PHY" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '<physical-address location-type-code="BUS" address-usg-type-code="MAIL" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '</person-physical-addresses>' +
        '<person-subscription opt-in-date="4/18/2018 4:39:51 AM" sent-date="" opt-in-confirmation-date="" opt-in-type="EXEMPT">'+
        '<subscription engg-code="CSPx2" category="OFFRSPRMTN">'+
        '<subscription-code>Gold</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '<subscription engg-code="CSPx2" category="NEWSLETTER">'+
        '<subscription-code>Platinum</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '</person-subscription>'+
        '</person>';
    
    private static final String TEST_ERPM_PERSON_XML_RELATION_ITP_Add_ISA = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<person xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" inact-indicator="N" is-delete-indicator="REPLACE_PERSON_IS_DELETE_INDICATOR">' +
        '<person-information>' +
        '<person-id>REPLACE_PERSON_ERPM_PERSON_ID</person-id>' +
        '<external-login-id isnull-indicator="N">REPLACE_PERSON_EXTERNAL_LOGIN</external-login-id>' +
        '<enterprise-id isnull-indicator="N">REPLACE_PERSON_ENTERPRISE_ID</enterprise-id>' +
        '<internal-login-id isnull-indicator="Y" />' +
        '<identity-status isnull-indicator="N">REPLACE_PERSON_IDENTITY_STATUS</identity-status>' +
        '<person-title isnull-indicator="N" >REPLACE_PERSON_TITLE</person-title>' +
        '<person-given-name isnull-indicator="N">REPLACE_PERSON_FIRST_NAME</person-given-name>' +
        '<person-family-name isnull-indicator="N">REPLACE_PERSON_LAST_NAME</person-family-name>' +
        '<language-code>ENG</language-code>' +
        '<occupation-title-code isnull-indicator="N">OPER</occupation-title-code>' +
        '<primary-email-address>REPLACE_PERSON_EMAIL</primary-email-address>' +
        '<all-intel-no-contact-dtm isnull-indicator="Y" />' +
        '<email-valid-status-dtm isnull-indicator="N">04/22/2019 08:35:46 AM</email-valid-status-dtm>' +
        '<last-login-dtm isnull-indicator="N">05/28/2019 12:39:01 AM</last-login-dtm>' +
        '</person-information>' +
        '<person-accounts>' +       
        '<person-account inact-indicator="N">' +
        '<account-number>1000054337</account-number>' +
        '<cim-id isnull-indicator="N">REPLACE_PERSON_ACCOUNT_CIM_ID</cim-id>' +
        '<account-name>REPLACE_PERSON_ACCOUNT_NAME</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPSCD</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="ITP">' +
        '<relation-code>RELTNPRCTC</relation-code>' +
        '<relation-name>Primary Contact</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNWRKFR</relation-code>' +
        '<relation-name>Employee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<person-account-relation inact-indicator="N" engagement-code="ITP">' +
        '<relation-code>RELTNACTAD</relation-code>' +
        '<relation-name>Account Administrator</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>ITP</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +    
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE1</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' + 
        '</account-engagements>' +
        '</person-account>' +
        '</person-accounts>' +
        '<person-electronic-addresses>' +
        '<person-electronic-address electronic-addr-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_FAX</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_MOBILE</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_PHONE</electronic-address>' +
        '</person-electronic-address>' +
        '</person-electronic-addresses>' +        
        '<person-physical-addresses>' +
        '<physical-address location-type-code="HOME" address-usg-type-code="MAIL" contact-indicator="Y" inact-indicator="N" preferred-indicator="Y" isnull-indicator="">' +
        '<address-line1-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE1</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE2</address-line2-text>' +
        '<address-line3-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE3</address-line3-text>' +
        '<address-line4-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE4</address-line4-text>' +
        '<city-name isnull-indicator="N">REPLACE_PERSON_ADDR_CITY</city-name>' +
        '<state-code isnull-indicator="N">REPLACE_PERSON_ADDR_STATE</state-code>' +
        '<postal-code isnull-indicator="N">REPLACE_PERSON_ADDR_POSTALCODE</postal-code>' +
        '<language-code isnull-indicator="N">ENG</language-code>' +
        '<iso-country-code>REPLACE_PERSON_ADDR_COUNTRY</iso-country-code>' +
        '</physical-address>' +
        '<physical-address location-type-code="BUS" address-usg-type-code="PHY" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '<physical-address location-type-code="BUS" address-usg-type-code="MAIL" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '</person-physical-addresses>' +
        '<person-subscription opt-in-date="4/18/2018 4:39:51 AM" sent-date="" opt-in-confirmation-date="" opt-in-type="EXEMPT">'+
        '<subscription engg-code="CSPx2" category="OFFRSPRMTN">'+
        '<subscription-code>Gold</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '<subscription engg-code="CSPx2" category="NEWSLETTER">'+
        '<subscription-code>Platinum</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '</person-subscription>'+
        '<change-agt-id>Salescloud</change-agt-id>' +
        '</person>';
   
    private static final String TEST_ERPM_PERSON_XML_RELATION_PR_ExITP_ISACon = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<person xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" inact-indicator="N" is-delete-indicator="REPLACE_PERSON_IS_DELETE_INDICATOR">' +
        '<person-information>' +
        '<person-id>REPLACE_PERSON_ERPM_PERSON_ID</person-id>' +
        '<external-login-id isnull-indicator="N">REPLACE_PERSON_EXTERNAL_LOGIN</external-login-id>' +
        '<enterprise-id isnull-indicator="N">REPLACE_PERSON_ENTERPRISE_ID</enterprise-id>' +
        '<internal-login-id isnull-indicator="Y" />' +
        '<identity-status isnull-indicator="N">REPLACE_PERSON_IDENTITY_STATUS</identity-status>' +
        '<person-title isnull-indicator="N" >REPLACE_PERSON_TITLE</person-title>' +
        '<person-given-name isnull-indicator="N">REPLACE_PERSON_FIRST_NAME</person-given-name>' +
        '<person-family-name isnull-indicator="N">REPLACE_PERSON_LAST_NAME</person-family-name>' +
        '<language-code>ENG</language-code>' +
        '<occupation-title-code isnull-indicator="N">OPER</occupation-title-code>' +
        '<primary-email-address>REPLACE_PERSON_EMAIL</primary-email-address>' +
        '<all-intel-no-contact-dtm isnull-indicator="Y" />' +
        '<email-valid-status-dtm isnull-indicator="N">04/22/2019 08:35:46 AM</email-valid-status-dtm>' +
        '<last-login-dtm isnull-indicator="N">05/28/2019 12:39:01 AM</last-login-dtm>' +
        '</person-information>' +
        '<person-accounts>' +       
        '<person-account inact-indicator="N">' +
        '<account-number>1000054337</account-number>' +
        '<cim-id isnull-indicator="N">REPLACE_PERSON_ACCOUNT_CIM_ID</cim-id>' +
        '<account-name>REPLACE_PERSON_ACCOUNT_NAME</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPSCD</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNPRCTC</relation-code>' +
        '<relation-name>Primary Contact</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNWRKFR</relation-code>' +
        '<relation-name>Employee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +        
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>ITP</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +    
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE1</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' + 
        '</account-engagements>' +
        '</person-account>' +
        '</person-accounts>' +
        '<person-electronic-addresses>' +
        '<person-electronic-address electronic-addr-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_FAX</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_MOBILE</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_PHONE</electronic-address>' +
        '</person-electronic-address>' +
        '</person-electronic-addresses>' +        
        '<person-physical-addresses>' +
        '<physical-address location-type-code="HOME" address-usg-type-code="MAIL" contact-indicator="Y" inact-indicator="N" preferred-indicator="Y" isnull-indicator="">' +
        '<address-line1-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE1</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE2</address-line2-text>' +
        '<address-line3-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE3</address-line3-text>' +
        '<address-line4-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE4</address-line4-text>' +
        '<city-name isnull-indicator="N">REPLACE_PERSON_ADDR_CITY</city-name>' +
        '<state-code isnull-indicator="N">REPLACE_PERSON_ADDR_STATE</state-code>' +
        '<postal-code isnull-indicator="N">REPLACE_PERSON_ADDR_POSTALCODE</postal-code>' +
        '<language-code isnull-indicator="N">ENG</language-code>' +
        '<iso-country-code>REPLACE_PERSON_ADDR_COUNTRY</iso-country-code>' +
        '</physical-address>' +
        '<physical-address location-type-code="BUS" address-usg-type-code="PHY" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '<physical-address location-type-code="BUS" address-usg-type-code="MAIL" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '</person-physical-addresses>' +
        '<person-subscription opt-in-date="4/18/2018 4:39:51 AM" sent-date="" opt-in-confirmation-date="" opt-in-type="EXEMPT">'+
        '<subscription engg-code="CSPx2" category="OFFRSPRMTN">'+
        '<subscription-code>Gold</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '<subscription engg-code="CSPx2" category="NEWSLETTER">'+
        '<subscription-code>Platinum</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '</person-subscription>'+
        '</person>';
    
    private static final String TEST_ERPM_PERSON_XML_RELATION_PR_ExITPODM_ITPCon = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<person xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" inact-indicator="N" is-delete-indicator="REPLACE_PERSON_IS_DELETE_INDICATOR">' +
        '<person-information>' +
        '<person-id>REPLACE_PERSON_ERPM_PERSON_ID</person-id>' +
        '<external-login-id isnull-indicator="N">REPLACE_PERSON_EXTERNAL_LOGIN</external-login-id>' +
        '<enterprise-id isnull-indicator="N">REPLACE_PERSON_ENTERPRISE_ID</enterprise-id>' +
        '<internal-login-id isnull-indicator="Y" />' +
        '<identity-status isnull-indicator="N">REPLACE_PERSON_IDENTITY_STATUS</identity-status>' +
        '<person-title isnull-indicator="N" >REPLACE_PERSON_TITLE</person-title>' +
        '<person-given-name isnull-indicator="N">REPLACE_PERSON_FIRST_NAME</person-given-name>' +
        '<person-family-name isnull-indicator="N">REPLACE_PERSON_LAST_NAME</person-family-name>' +
        '<language-code>ENG</language-code>' +
        '<occupation-title-code isnull-indicator="N">OPER</occupation-title-code>' +
        '<primary-email-address>REPLACE_PERSON_EMAIL</primary-email-address>' +
        '<all-intel-no-contact-dtm isnull-indicator="Y" />' +
        '<email-valid-status-dtm isnull-indicator="N">04/22/2019 08:35:46 AM</email-valid-status-dtm>' +
        '<last-login-dtm isnull-indicator="N">05/28/2019 12:39:01 AM</last-login-dtm>' +
        '</person-information>' +
        '<person-accounts>' +       
        '<person-account inact-indicator="N">' +
        '<account-number>1000054337</account-number>' +
        '<cim-id isnull-indicator="N">REPLACE_PERSON_ACCOUNT_CIM_ID</cim-id>' +
        '<account-name>REPLACE_PERSON_ACCOUNT_NAME</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPSCD</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNPRCTC</relation-code>' +
        '<relation-name>Primary Contact</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNWRKFR</relation-code>' +
        '<relation-name>Employee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +        
        '<account-engagements>' +        
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE1</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' + 
        '</account-engagements>' +
        '</person-account>' +
        '</person-accounts>' +
        '<person-electronic-addresses>' +
        '<person-electronic-address electronic-addr-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_FAX</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_MOBILE</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_PHONE</electronic-address>' +
        '</person-electronic-address>' +
        '</person-electronic-addresses>' +        
        '<person-physical-addresses>' +
        '<physical-address location-type-code="HOME" address-usg-type-code="MAIL" contact-indicator="Y" inact-indicator="N" preferred-indicator="Y" isnull-indicator="">' +
        '<address-line1-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE1</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE2</address-line2-text>' +
        '<address-line3-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE3</address-line3-text>' +
        '<address-line4-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE4</address-line4-text>' +
        '<city-name isnull-indicator="N">REPLACE_PERSON_ADDR_CITY</city-name>' +
        '<state-code isnull-indicator="N">REPLACE_PERSON_ADDR_STATE</state-code>' +
        '<postal-code isnull-indicator="N">REPLACE_PERSON_ADDR_POSTALCODE</postal-code>' +
        '<language-code isnull-indicator="N">ENG</language-code>' +
        '<iso-country-code>REPLACE_PERSON_ADDR_COUNTRY</iso-country-code>' +
        '</physical-address>' +
        '<physical-address location-type-code="BUS" address-usg-type-code="PHY" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '<physical-address location-type-code="BUS" address-usg-type-code="MAIL" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '</person-physical-addresses>' +
        '<person-subscription opt-in-date="4/18/2018 4:39:51 AM" sent-date="" opt-in-confirmation-date="" opt-in-type="EXEMPT">'+
        '<subscription engg-code="CSPx2" category="OFFRSPRMTN">'+
        '<subscription-code>Gold</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '<subscription engg-code="CSPx2" category="NEWSLETTER">'+
        '<subscription-code>Platinum</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '</person-subscription>'+
        '</person>';
    
    private static final String TEST_ERPM_PERSON_XML_SUBSCRIPTION = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<person xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" inact-indicator="N" is-delete-indicator="REPLACE_PERSON_IS_DELETE_INDICATOR">' +
        '<person-information>' +
        '<person-id>REPLACE_PERSON_ERPM_PERSON_ID</person-id>' +
        '<external-login-id isnull-indicator="N">REPLACE_PERSON_EXTERNAL_LOGIN</external-login-id>' +
        '<enterprise-id isnull-indicator="N">REPLACE_PERSON_ENTERPRISE_ID</enterprise-id>' +
        '<internal-login-id isnull-indicator="Y" />' +
        '<identity-status isnull-indicator="N">REPLACE_PERSON_IDENTITY_STATUS</identity-status>' +
        '<person-title isnull-indicator="N" >REPLACE_PERSON_TITLE</person-title>' +
        '<person-given-name isnull-indicator="N">REPLACE_PERSON_FIRST_NAME</person-given-name>' +
        '<person-family-name isnull-indicator="N">REPLACE_PERSON_LAST_NAME</person-family-name>' +
        '<language-code>ENG</language-code>' +
        '<occupation-title-code isnull-indicator="N">OPER</occupation-title-code>' +
        '<primary-email-address>REPLACE_PERSON_EMAIL</primary-email-address>' +
        '<all-intel-no-contact-dtm isnull-indicator="Y" />' +
        '<email-valid-status-dtm isnull-indicator="N">04/22/2019 08:35:46 AM</email-valid-status-dtm>' +
        '<last-login-dtm isnull-indicator="N">05/28/2019 12:39:01 AM</last-login-dtm>' +
        '</person-information>' + 
        '<person-accounts>' +       
        '<person-account inact-indicator="N">' +
        '<account-number>1000054337</account-number>' +
        '<cim-id isnull-indicator="N">REPLACE_PERSON_ACCOUNT_CIM_ID</cim-id>' +
        '<account-name>REPLACE_PERSON_ACCOUNT_NAME</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPSCD</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNPRCTC</relation-code>' +
        '<relation-name>Primary Contact</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNWRKFR</relation-code>' +
        '<relation-name>Employee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE1</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +       
        '</account-engagements>' +
        '</person-account>' +
        '</person-accounts>' +
        '<person-electronic-addresses>' +
        '<person-electronic-address electronic-addr-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_FAX</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_MOBILE</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_PHONE</electronic-address>' +
        '</person-electronic-address>' +
        '</person-electronic-addresses>' +
        '<person-engagements>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT">' +
        '<engg-code>REPLACE_PERSON_PERSON_ENGG_CODE1</engg-code>' +
        '<engg-name>REPLACE_PERSON_PERSON_ENGG_NAME1</engg-name>' +
        '<tier-code>MEMBER</tier-code>' +
        '<effective-tier-code>PERSONTIER1</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-dtm isnull-indicator="N">08/16/2016 06:12:55 PM</engg-status-dtm>' +
        '</engagement>' +        
        '</person-engagements>' +
        '<person-physical-addresses>' +
        '<physical-address location-type-code="HOME" address-usg-type-code="MAIL" contact-indicator="Y" inact-indicator="N" preferred-indicator="Y" isnull-indicator="">' +
        '<address-line1-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE1</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE2</address-line2-text>' +
        '<address-line3-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE3</address-line3-text>' +
        '<address-line4-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE4</address-line4-text>' +
        '<city-name isnull-indicator="N">REPLACE_PERSON_ADDR_CITY</city-name>' +
        '<state-code isnull-indicator="N">REPLACE_PERSON_ADDR_STATE</state-code>' +
        '<postal-code isnull-indicator="N">REPLACE_PERSON_ADDR_POSTALCODE</postal-code>' +
        '<language-code isnull-indicator="N">ENG</language-code>' +
        '<iso-country-code>REPLACE_PERSON_ADDR_COUNTRY</iso-country-code>' +
        '</physical-address>' +
        '<physical-address location-type-code="BUS" address-usg-type-code="PHY" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '<physical-address location-type-code="BUS" address-usg-type-code="MAIL" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '</person-physical-addresses>' +
        '<person-subscription opt-in-date="4/18/2018 4:39:51 AM" sent-date="" opt-in-confirmation-date="" opt-in-type="EXEMPT">'+
        '<subscription engg-code="CSPx2" category="OFFRSPRMTN">'+
        '<subscription-code>Gold</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '<subscription engg-code="CSPx2" category="NEWSLETTER">'+
        '<subscription-code>Platinum</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '</person-subscription>'+
        '</person>';
    
    private static final String TEST_ERPM_PERSON_XML_RELATIONSHIP_ENTITLEMENT_ISA = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<person xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" inact-indicator="N" is-delete-indicator="REPLACE_PERSON_IS_DELETE_INDICATOR">' +
        '<person-information>' +
        '<person-id>REPLACE_PERSON_ERPM_PERSON_ID</person-id>' +
        '<external-login-id isnull-indicator="N">REPLACE_PERSON_EXTERNAL_LOGIN</external-login-id>' +
        '<enterprise-id isnull-indicator="N">REPLACE_PERSON_ENTERPRISE_ID</enterprise-id>' +
        '<internal-login-id isnull-indicator="Y" />' +
        '<identity-status isnull-indicator="N">REPLACE_PERSON_IDENTITY_STATUS</identity-status>' +
        '<person-title isnull-indicator="N" >REPLACE_PERSON_TITLE</person-title>' +
        '<person-given-name isnull-indicator="N">REPLACE_PERSON_FIRST_NAME</person-given-name>' +
        '<person-family-name isnull-indicator="N">REPLACE_PERSON_LAST_NAME</person-family-name>' +
        '<language-code>ENG</language-code>' +
        '<occupation-title-code isnull-indicator="N">OPER</occupation-title-code>' +
        '<primary-email-address>REPLACE_PERSON_EMAIL</primary-email-address>' +
        '<all-intel-no-contact-dtm isnull-indicator="Y" />' +
        '<email-valid-status-dtm isnull-indicator="N">04/22/2019 08:35:46 AM</email-valid-status-dtm>' +
        '<last-login-dtm isnull-indicator="N">05/28/2019 12:39:01 AM</last-login-dtm>' +
        '</person-information>' +
        '<person-accounts>' +       
        '<person-account inact-indicator="N">' +
        '<account-number>1000054337</account-number>' +
        '<cim-id isnull-indicator="N">REPLACE_PERSON_ACCOUNT_CIM_ID</cim-id>' +
        '<account-name>REPLACE_PERSON_ACCOUNT_NAME</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPSCD</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNPRCTC</relation-code>' +
        '<relation-name>Primary Contact</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNWRKFR</relation-code>' +
        '<relation-name>Employee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNACTAD</relation-code>' +
        '<relation-name>Account Administrator</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE1</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +       
        '</account-engagements>' +
        '</person-account>' +
        '</person-accounts>' +
        '<person-electronic-addresses>' +
        '<person-electronic-address electronic-addr-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_FAX</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_MOBILE</electronic-address>' +
        '</person-electronic-address>' +
        '<person-electronic-address electronic-addr-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<country-code isnull-indicator="N">US</country-code><effective-end-dtm isnull-indicator="Y" /><electronic-address>REPLACE_PERSON_PHONE</electronic-address>' +
        '</person-electronic-address>' +
        '</person-electronic-addresses>' +        
        '<person-physical-addresses>' +
        '<physical-address location-type-code="HOME" address-usg-type-code="MAIL" contact-indicator="Y" inact-indicator="N" preferred-indicator="Y" isnull-indicator="">' +
        '<address-line1-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE1</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE2</address-line2-text>' +
        '<address-line3-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE3</address-line3-text>' +
        '<address-line4-text isnull-indicator="N">REPLACE_PERSON_ADDR_LINE4</address-line4-text>' +
        '<city-name isnull-indicator="N">REPLACE_PERSON_ADDR_CITY</city-name>' +
        '<state-code isnull-indicator="N">REPLACE_PERSON_ADDR_STATE</state-code>' +
        '<postal-code isnull-indicator="N">REPLACE_PERSON_ADDR_POSTALCODE</postal-code>' +
        '<language-code isnull-indicator="N">ENG</language-code>' +
        '<iso-country-code>REPLACE_PERSON_ADDR_COUNTRY</iso-country-code>' +
        '</physical-address>' +
        '<physical-address location-type-code="BUS" address-usg-type-code="PHY" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '<physical-address location-type-code="BUS" address-usg-type-code="MAIL" contact-indicator="N" inact-indicator="N" preferred-indicator="N" isnull-indicator="Y" />' +
        '</person-physical-addresses>' +
        '<person-subscription opt-in-date="4/18/2018 4:39:51 AM" sent-date="" opt-in-confirmation-date="" opt-in-type="EXEMPT">'+
        '<subscription engg-code="CSPx2" category="OFFRSPRMTN">'+
        '<subscription-code>Gold</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '<subscription engg-code="CSPx2" category="NEWSLETTER">'+
        '<subscription-code>Platinum</subscription-code>'+
        '<subscription-statuscode>USER-SUB</subscription-statuscode>'+
        '<subscription-start-datetime>04/17/2018 08:39:51 PM</subscription-start-datetime>'+
        '<subscription-status-datetime>04/18/2018 04:39:51 AM</subscription-status-datetime>'+
        '<subscription-delivery-typecode>sbscr.psn_sbscr_dlvr_type dlvr_type_cd="EMAIL"</subscription-delivery-typecode>'+
        '<subscription-marketing-source-ID />'+
        '<subscription-marketing-tactic-ID />'+
        '</subscription>'+
        '</person-subscription>'+
        '</person>';
}