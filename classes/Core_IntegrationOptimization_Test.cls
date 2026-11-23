@isTest
public class Core_IntegrationOptimization_Test {
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
    
    static Core_Integration_Inbound_Message__c newERPMAccountMessage(String payload) {
        return newMessage('ERPM', 'Account', payload);
    }
 
    @isTest static void GetRankedAccounts_Test(){
        
        Test.startTest();
        integer rankNumber=Core_IntegrationOptimization.GetRankedAccounts('1000');
        Test.stopTest();
        System.assertEquals(8, rankNumber);
    }
    
    @isTest static void GetTop1Account()
    {
        Test.startTest();
        String acct = Core_IntegrationOptimization.GetMatchingAccountSFIDfromCIMID(new Set<String> {'8888'},new Set<String>{'54321'});
        Test.stopTest();
        List<Account> testAcct = [select Id from Account where Name = 'Test Account 9'];
        System.debug('testAcct : ' + testAcct); 
        System.assertEquals(testAcct[0].Id,acct);
    }
    
    @isTest static void cimIDAcctNumberComboTest()
    {
        String msg = TEST_ERPM_ACCOUNT_XML_ITP_ISA_BOTH;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 8');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '3698574');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '3690');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        ''); // Real SFDC ID
        msg = msg.replace('REPLACE_ACCT_PHONE',          '1001001001');
        msg = msg.replace('REPLACE_ACCT_PHONE_HOME',     '1001001023');
        msg = msg.replace('REPLACE_ACCT_FAX',            '3001001001');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE1',     'Addr Line 1');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE2',     'Addr Line 2');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE3',     'Addr Line 3');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE4',     'Addr Line 4');
        msg = msg.replace('REPLACE_ACCT_ADDR_CITY',      'Portland');
        msg = msg.replace('REPLACE_ACCT_ADDR_STATE',     'OR');
        msg = msg.replace('REPLACE_ACCT_ADDR_POSTALCODE','97229');
        msg = msg.replace('REPLACE_ACCT_ADDR_COUNTRY',   'USA');
        msg = msg.replace('REPLACE_ACCT_ENGG_CODE1',     'ITP');
        msg = msg.replace('REPLACE_ACCT_ENGG_NAME1',     'Account Engg 1');  
        msg = msg.replace('REPLACE_ACCT_ENGG_STATUS',     'ENGSTSAPRD');
        msg = msg.replace('REPLACE_ACCT_ENGG_TIER',     'REGISTERED');  
        msg = msg.replace('REPLACE_ACCT_ENGG_ISA_STATUS',     'ENGSTSAPRD');
        msg = msg.replace('REPLACE_ACCT_ENGG_ISA_TIER',     'GENERAL'); 
        System.debug('##### msg = ' + msg);
        
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();        
        
        List<Account> testAcctList = [select ID,Name,Core_User_Defined_Number_of_Employees__c, Core_User_Defined_Website__c, Core_IPA_Partner_Role__c , //Core_IPA_Partner_Speciality__c, 
                                      Core_User_Defined_Phone_Number__c, Core_Account_Type__c,OwnerId,Owner.Name from Account where Core_CIM_ID__c ='3690' and Name='HSK Account 19' ORDER BY CreatedDate];
        System.debug('testAcctList'+testAcctList);
        System.debug('testAcctList'+testAcctList.size());
        
        List<PRM_AccountChannelMembership__c> acm = [SELECT Id, PRM_Account_Id__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c,
                                                     PRM_Channel_Program_Id__r.PRM_programCode__c, PRM_Status_Nm__c, PRM_Status_Reason_Txt__c,
                                                     PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c, PRM_Partner_Role__c
                                                     FROM PRM_AccountChannelMembership__c 
                                                     WHERE PRM_Account_Id__c =: testAcctList[0].Id
                                                     ORDER BY PRM_Partner_Role__c ASC];
        
/*        System.debug('acct.Core_IPA_Partner_Speciality__c'+testAcctList[0].Core_IPA_Partner_Speciality__c);
        List<String> ipa_prtner = testAcctList[0].Core_IPA_Partner_Speciality__c.split(';');
        System.debug('ipa_prtner'+ipa_prtner);
        ipa_prtner.sort();
        testAcctList[0].Core_IPA_Partner_Speciality__c = String.join( ipa_prtner, ';' );*/
        
        System.debug('acct = ' + testAcctList[0].Core_IPA_Partner_Role__c);
        System.debug('acct = ' + testAcctList[0].Core_Account_Type__c);
        //System.assertEquals('www.bbluechip9.com', testAcctList[0].Core_User_Defined_Website__c);
        System.assertEquals('1-9', testAcctList[0].Core_User_Defined_Number_of_Employees__c);
        System.assertEquals('1001001001',testAcctList[0].Core_User_Defined_Phone_Number__c);
        System.assertEquals('Manufacturer;Seller', testAcctList[0].Core_IPA_Partner_Role__c);
       // System.debug('Partner Speciality - ' + testAcctList[0].Core_IPA_Partner_Speciality__c);
        //System.assertEquals('Artificial Intelligence Specialist;Enthusiast PC Specialist;Video Specialist',testAcctList[0].Core_IPA_Partner_Speciality__c);
        System.debug('acct = Biz Org Type : ' + testAcctList[0].Core_Account_Type__c);
        System.assertEquals('Reseller;Original Design Manufacturer (ODM)', testAcctList[0].Core_Account_Type__c);
        
        system.debug('acm0 : ' +acm[0] );
        System.assertEquals('Approved', acm[0].PRM_Status_Nm__c);
        System.assertEquals('IPA', acm[0].PRM_Channel_Program_Id__r.PRM_programCode__c);
        System.assertEquals('Member', acm[0].PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c); 
        System.assertEquals('Manufacturer', acm[0].PRM_Partner_Role__c);
        
        system.debug('acm1 : ' +acm[1] );
        System.assertEquals('Approved', acm[1].PRM_Status_Nm__c);
        System.assertEquals('IPA', acm[1].PRM_Channel_Program_Id__r.PRM_programCode__c);
        System.assertEquals('Member', acm[1].PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c); 
        System.assertEquals('Seller', acm[1].PRM_Partner_Role__c);
        
    }
    
    @isTest static void Set_ACM_Update_ITP_ISA_Optimization_Matrix_1()
    {
        
        String msg = TEST_ERPM_ACCOUNT_XML_ITP_ISA_BOTH;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 8');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '12345');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '8970');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        ''); // Real SFDC ID
        msg = msg.replace('REPLACE_ACCT_PHONE',          '1001001001');
        msg = msg.replace('REPLACE_ACCT_PHONE_HOME',     '1001001023');
        msg = msg.replace('REPLACE_ACCT_FAX',            '3001001001');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE1',     'Addr Line 1');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE2',     'Addr Line 2');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE3',     'Addr Line 3');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE4',     'Addr Line 4');
        msg = msg.replace('REPLACE_ACCT_ADDR_CITY',      'Portland');
        msg = msg.replace('REPLACE_ACCT_ADDR_STATE',     'OR');
        msg = msg.replace('REPLACE_ACCT_ADDR_POSTALCODE','97229');
        msg = msg.replace('REPLACE_ACCT_ADDR_COUNTRY',   'USA');
        msg = msg.replace('REPLACE_ACCT_ENGG_CODE1',     'ITP');
        msg = msg.replace('REPLACE_ACCT_ENGG_NAME1',     'Account Engg 1');  
        msg = msg.replace('REPLACE_ACCT_ENGG_STATUS',     'ENGSTSAPRD');
        msg = msg.replace('REPLACE_ACCT_ENGG_TIER',     'REGISTERED');  
        msg = msg.replace('REPLACE_ACCT_ENGG_ISA_STATUS',     'ENGSTSAPRD');
        msg = msg.replace('REPLACE_ACCT_ENGG_ISA_TIER',     'GENERAL'); 
        System.debug('##### msg = ' + msg);

        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        List<Account> testAcctList = [select ID,Name,Core_User_Defined_Number_of_Employees__c, Core_User_Defined_Website__c, Core_IPA_Partner_Role__c , //Core_IPA_Partner_Speciality__c, 
                        Core_User_Defined_Phone_Number__c, Core_Account_Type__c,OwnerId,Owner.Name from Account where Core_CIM_ID__c ='8970'  and Name='HSK Account 15' ORDER BY CreatedDate];
        System.debug('testAcctList'+testAcctList);
        System.debug('testAcctList'+testAcctList.size());
        
        List<PRM_AccountChannelMembership__c> acm = [SELECT Id, PRM_Account_Id__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c,
                                                     PRM_Channel_Program_Id__r.PRM_programCode__c, PRM_Status_Nm__c, PRM_Status_Reason_Txt__c,
                                                     PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c, PRM_Partner_Role__c
                                                     FROM PRM_AccountChannelMembership__c 
                                                     WHERE PRM_Account_Id__c =: testAcctList[0].Id
                                                     ORDER BY PRM_Partner_Role__c ASC];   
        
        /*System.debug('acct.Core_IPA_Partner_Speciality__c'+testAcctList[0].Core_IPA_Partner_Speciality__c);
        List<String> ipa_prtner = testAcctList[0].Core_IPA_Partner_Speciality__c.split(';');
        System.debug('ipa_prtner'+ipa_prtner);
        ipa_prtner.sort();
        testAcctList[0].Core_IPA_Partner_Speciality__c = String.join( ipa_prtner, ';' );*/
        
            System.debug('acct = ' + testAcctList[0].Core_IPA_Partner_Role__c);
        System.debug('acct = ' + testAcctList[0].Core_Account_Type__c);
        //System.assertEquals('www.bbluechip9.com', testAcctList[0].Core_User_Defined_Website__c);
        System.assertEquals('1-9', testAcctList[0].Core_User_Defined_Number_of_Employees__c);
        System.assertEquals('1001001001',testAcctList[0].Core_User_Defined_Phone_Number__c);
        System.assertEquals('Manufacturer;Seller', testAcctList[0].Core_IPA_Partner_Role__c);
        //System.debug('Partner Speciality - ' + testAcctList[0].Core_IPA_Partner_Speciality__c);
        //System.assertEquals('Artificial Intelligence Specialist;Enthusiast PC Specialist;Video Specialist',testAcctList[0].Core_IPA_Partner_Speciality__c);
        System.debug('acct = Biz Org Type : ' + testAcctList[0].Core_Account_Type__c);
        System.assertEquals('Reseller;Original Design Manufacturer (ODM)', testAcctList[0].Core_Account_Type__c);
        
        system.debug('acm0 : ' +acm[0] );
        System.assertEquals('Approved', acm[0].PRM_Status_Nm__c);
        System.assertEquals('IPA', acm[0].PRM_Channel_Program_Id__r.PRM_programCode__c);
        System.assertEquals('Member', acm[0].PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c); 
        System.assertEquals('Manufacturer', acm[0].PRM_Partner_Role__c);
        
        system.debug('acm1 : ' +acm[0] );
        System.assertEquals('Approved', acm[1].PRM_Status_Nm__c);

        System.assertEquals('Member', acm[1].PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c); 
        System.assertEquals('Seller', acm[1].PRM_Partner_Role__c);
        
        List<Contact> contact=[SELECT email FROM Contact where AccountId =: testAcctList[0].Id];
        System.debug('contact'+contact);
        contact.sort();
        System.assertEquals('johny@mailinator.com', contact[0].Email);
    }
    
    
     @isTest static void Set_ACM_Update_ITP_ISA_Optimization_Matrix_2(){
               
         Account testAcct = [select Id from Account where Core_CIM_ID__c = '9999' limit 1];
         System.debug('testAcct'+testAcct.Id);    
                                                   
        String msg = TEST_ERPM_ACCOUNT_XML_ITP_ISA_BOTH;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 10');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '54321');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '9999');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        ''); // Real SFDC ID
        msg = msg.replace('REPLACE_ACCT_PHONE',          '1001001001');
        msg = msg.replace('REPLACE_ACCT_PHONE_HOME',     '1001001023');
        msg = msg.replace('REPLACE_ACCT_FAX',            '3001001001');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE1',     'Addr Line 1');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE2',     'Addr Line 2');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE3',     'Addr Line 3');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE4',     'Addr Line 4');
        msg = msg.replace('REPLACE_ACCT_ADDR_CITY',      'Portland');
        msg = msg.replace('REPLACE_ACCT_ADDR_STATE',     'OR');
        msg = msg.replace('REPLACE_ACCT_ADDR_POSTALCODE','97229');
        msg = msg.replace('REPLACE_ACCT_ADDR_COUNTRY',   'USA');
        msg = msg.replace('REPLACE_ACCT_ENGG_CODE1',     'ITP');
        msg = msg.replace('REPLACE_ACCT_ENGG_NAME1',     'Account Engg 1');  
        msg = msg.replace('REPLACE_ACCT_ENGG_STATUS',     'ENGSTSAPRD');
        msg = msg.replace('REPLACE_ACCT_ENGG_TIER',     'REGISTERED');  
        msg = msg.replace('REPLACE_ACCT_ENGG_ISA_STATUS',     'ENGSTSAPRD');
        msg = msg.replace('REPLACE_ACCT_ENGG_ISA_TIER',     'GENERAL'); 
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        List<PRM_AccountChannelMembership__c> acm = [SELECT Id, PRM_Account_Id__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c,
                                                     PRM_Channel_Program_Id__r.PRM_programCode__c, PRM_Status_Nm__c, PRM_Status_Reason_Txt__c,
                                                     PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c, PRM_Partner_Role__c
                                                     FROM PRM_AccountChannelMembership__c 
                                                     WHERE PRM_Account_Id__c =: testAcct.Id
                                                     ORDER BY PRM_Partner_Role__c ASC];
        
        
        Account acct = [select ID,Name,Core_User_Defined_Number_of_Employees__c, Core_User_Defined_Website__c, Core_IPA_Partner_Role__c , //Core_IPA_Partner_Speciality__c, 
                        Core_User_Defined_Phone_Number__c, Core_Account_Type__c,OwnerId,Owner.Name from Account where Core_CIM_ID__c = '9999' ORDER by Core_CIM_ID__c, CreatedDate limit 1];
               System.debug('testAcct'+acct.Id);    
        
        /*System.debug('acct.Core_IPA_Partner_Speciality__c'+acct.Core_IPA_Partner_Speciality__c);
        List<String> ipa_prtner = acct.Core_IPA_Partner_Speciality__c.split(';');
       	System.debug('ipa_prtner'+ipa_prtner);
        ipa_prtner.sort();
        acct.Core_IPA_Partner_Speciality__c = String.join( ipa_prtner, ';' );*/
        
        System.debug('acct = ' + acct.Core_IPA_Partner_Role__c);
        System.debug('acct = ' + acct.Core_Account_Type__c);
        System.assertEquals(testAcct.Id,acct.Id);
        //System.assertEquals('www.bbluechip9.com', acct.Core_User_Defined_Website__c);
        System.assertEquals('1-9', acct.Core_User_Defined_Number_of_Employees__c);
        System.assertEquals('1001001001',acct.Core_User_Defined_Phone_Number__c);
        System.assertEquals('Manufacturer;Seller', acct.Core_IPA_Partner_Role__c);
        //System.debug('Partner Speciality - ' + acct.Core_IPA_Partner_Speciality__c);
        //System.assertEquals('Artificial Intelligence Specialist;Enthusiast PC Specialist;Video Specialist',acct.Core_IPA_Partner_Speciality__c);
        System.debug('acct = Biz Org Type : ' + acct.Core_Account_Type__c);
        System.assertEquals('Reseller;Original Design Manufacturer (ODM)', acct.Core_Account_Type__c);
        
        system.debug('acm0 : ' +acm[0] );
        System.assertEquals('Approved', acm[0].PRM_Status_Nm__c);
        System.assertEquals('IPA', acm[0].PRM_Channel_Program_Id__r.PRM_programCode__c);
        System.assertEquals('Member', acm[0].PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c); 
        System.assertEquals('Manufacturer', acm[0].PRM_Partner_Role__c);
        
        system.debug('acm1 : ' +acm[0] );
        System.assertEquals('Approved', acm[1].PRM_Status_Nm__c);
        System.assertEquals('IPA', acm[1].PRM_Channel_Program_Id__r.PRM_programCode__c);
        System.assertEquals('Member', acm[1].PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c); 
        System.assertEquals('Seller', acm[1].PRM_Partner_Role__c);
     }
    
     private static final String TEST_ERPM_ACCOUNT_XML_ITP_ISA_BOTH = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<account xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" test-account-indicator="N" inact-indicator="N">' +
        '<account-information>' +
        '<account-name>REPLACE_ACCT_NAME</account-name>' +
        '<account-names>' +
        '<account-name type="Alias Name" isnull-indicator="Y" />' +
        '<account-name type="Doing Business As" isnull-indicator="Y" />' +
        '<account-name type="Legal Name" isnull-indicator="N" >REPLACE_ACCT_LEGAL_NAME</account-name>' +
        '</account-names>' +
        '<account-number>REPLACE_ACCT_ERPM_NUMBER</account-number>' +
        '<engg-dedup-group-code>DEDUPB2B1</engg-dedup-group-code>' +
        '<language-code>SPA</language-code>' +
        '<primary-addr-type-code>MAIL</primary-addr-type-code>' +
        '<employee-size-code isnull-indicator="N">15</employee-size-code>' +
        '<employee-size-grp-code isnull-indicator="N">1-9</employee-size-grp-code>' +
        '</account-information>' +
        '<account-external-systems>' +
        '<account-external-system system-name="SAPID" inact-indicator="N">8000242150</account-external-system>' +
        '<account-external-system system-name="CIM" inact-indicator="N">REPLACE_ACCT_CIM_ID</account-external-system>' +
        '<account-external-system system-name="SLSCLDID" inact-indicator="N">REPLACE_ACCT_SFDC_ID</account-external-system>' +
        '</account-external-systems>' +
        '<electronic-addresses>' +
        '<electronic-address electronic-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="N">REPLACE_ACCT_FAX</electronic-address>' +
        '<electronic-address electronic-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="N">REPLACE_ACCT_PHONE</electronic-address>' +
        '<electronic-address electronic-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="HOME" isnull-indicator="N">REPLACE_ACCT_PHONE_HOME</electronic-address>' +
        '<electronic-address electronic-type-code="URL" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="N" >www.bbluechip9.com</electronic-address>' +
        '<electronic-address electronic-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '</electronic-addresses>' +
        '<physical-addresses>' +
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="N">' +
         '<address-line1-text>REPLACE_ACCT_ADDR_LINE1</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">REPLACE_ACCT_ADDR_LINE2</address-line2-text>' +
        '<address-line3-text isnull-indicator="N">REPLACE_ACCT_ADDR_LINE3</address-line3-text>' +
        '<address-line4-text isnull-indicator="N">REPLACE_ACCT_ADDR_LINE4</address-line4-text>' +
        '<city-name>REPLACE_ACCT_ADDR_CITY</city-name>' +
        '<state-code isnull-indicator="N">REPLACE_ACCT_ADDR_STATE</state-code>' +
        '<state-name isnull-indicator="N">Guayas</state-name>' +
        '<postal-code isnull-indicator="N">REPLACE_ACCT_ADDR_POSTALCODE</postal-code>' +
        '<country-code>EC</country-code>' +
        '<country-name isnull-indicator="N">Ecuador</country-name>' +
        '<iso-country-code>REPLACE_ACCT_ADDR_COUNTRY</iso-country-code>' +
        '</physical-address>' +
        '<physical-address address-usg-type-code="PHY" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
        '<physical-address address-usg-type-code="PHY" contact-indicator="Y" preferred-indicator="N" inact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<address-line1-text>REPLACE_ACCT_ADDR_LINE1</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">REPLACE_ACCT_ADDR_LINE2</address-line2-text>' +
        '<address-line3-text isnull-indicator="N">REPLACE_ACCT_ADDR_LINE3</address-line3-text>' +
        '<address-line4-text isnull-indicator="N">REPLACE_ACCT_ADDR_LINE4</address-line4-text>' +
        '<city-name>REPLACE_ACCT_ADDR_CITY</city-name>' +
        '<state-code isnull-indicator="N">REPLACE_ACCT_ADDR_STATE</state-code>' +
        '<state-name isnull-indicator="N">Guayas</state-name>' +
        '<postal-code isnull-indicator="N">REPLACE_ACCT_ADDR_POSTALCODE</postal-code>' +
        '<country-code>EC</country-code>' +
        '<country-name isnull-indicator="N">Ecuador</country-name>' +
        '<iso-country-code>REPLACE_ACCT_ADDR_COUNTRY</iso-country-code>' +
        '</physical-address>' +
        '</physical-addresses>' +
        '<engagements>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD11" engg-type-code="ENGTYPSECR">' +
        '<engg-id>10118</engg-id>' +
        '<engg-code>ITP</engg-code>' +
        '<engg-name>Intel Technology Provider</engg-name>' +
        '<tier-code>REPLACE_ACCT_ENGG_TIER</tier-code>' +
        '<effective-tier-code>Registered</effective-tier-code>' +
        '<engg-status-code>REPLACE_ACCT_ENGG_STATUS</engg-status-code>' +
        '<engg-status-reason-code isnull-indicator="Y" />' +
        '</engagement>' +          
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD11" engg-type-code="ENGTYPSECR">' +
        '<engg-id>10178</engg-id>'+
        '<engg-code>ISA</engg-code>'+
        '<engg-name>Intel Internet of Things Solution Alliance</engg-name>' +
        '<tier-code>REPLACE_ACCT_ENGG_ISA_TIER</tier-code>' +
        '<effective-tier-code>REPLACE_ACCT_ENGG_ISA_TIER</effective-tier-code>' +
        '<engg-status-code>REPLACE_ACCT_ENGG_ISA_STATUS</engg-status-code>' +
        '<engg-status-reason-code isnull-indicator="Y" />' +
        '</engagement>' +
        '</engagements>' +
        '<account-responses isnull-indicator="N">' +
        '<response>' +
        '<answer-code>PA-000013</answer-code>' +
        '<question-code>PQ-000011</question-code>' +
        '<question-desc>Profile Last Updated</question-desc>' +
        '<response-value-text isnull-indicator="N">2019-02-05 22:23:08.857</response-value-text>'+
        '</response>'+
        '<response>' +
        '<answer-code>PA-000012</answer-code>' +
        '<question-code>PQ-000011</question-code>' +
        '<question-desc>Profile Last Updated</question-desc>' +
        '<response-value-text isnull-indicator="N">2019-02-05 22:23:08.857</response-value-text>'+
        '</response>'+
        '<response>'+
        '<answer-code>PA-000010</answer-code>'+
        '<question-code>PQ-000010</question-code>'+
        '<question-desc>Acceptable Domain 1</question-desc>'+
        '<response-value-text isnull-indicator="N" />'+
        '</response>'+
        '<response>' +
        '<answer-code>PA-000011</answer-code>'+
        '<question-code>PQ-000010</question-code>' +
        '<question-desc>What services do you offer today or plan on offering in the next 12 months? (Select all that apply.)</question-desc>' +
        '<response-value-text isnull-indicator="N">Container-as-a-Service</response-value-text>'+
        '</response>'+
        '</account-responses>'+
        '<account-benefits isnull-indicator="N">'+
        '<benefit>'+
        '<benefit-code>ET_Special</benefit-code>'+
        '<benefit-name>Enthusiast Specialist</benefit-name>'+
        '<engagement-code>ITP</engagement-code>'+
        '<benefit-start-dtm>07/09/2019 12:00:00 AM</benefit-start-dtm>'+
        '<benefit-eff-end-dtm isnull-indicator="Y" />'+
        '<benefit-note-txt isnull-indicator="Y" />'+
        '<inact-ind>N</inact-ind>'+
        '<benefit-inact-reason-code isnull-indicator="Y" />'+
        '</benefit>'+ 
        '<benefit>'+
        '<benefit-code>AI_Special</benefit-code>'+
        '<benefit-name>Artificial Intelligence Specialist</benefit-name>'+
        '<engagement-code>ITP</engagement-code>'+
        '<benefit-start-dtm>07/09/2019 12:00:00 AM</benefit-start-dtm>'+
        '<benefit-eff-end-dtm isnull-indicator="Y" />'+
        '<benefit-note-txt isnull-indicator="Y" />'+
        '<inact-ind>N</inact-ind>'+
        '<benefit-inact-reason-code isnull-indicator="Y" />'+
        '</benefit>'+
        '<benefit>'+
        '<benefit-code>VD_Special</benefit-code>'+
        '<benefit-name>Video Specialist</benefit-name>'+
        '<engagement-code>ISA</engagement-code>'+
        '<benefit-start-dtm>07/09/2019 12:00:00 AM</benefit-start-dtm>'+
        '<benefit-eff-end-dtm isnull-indicator="Y" />'+
        '<benefit-note-txt isnull-indicator="Y" />'+
        '<inact-ind>N</inact-ind>'+
        '<benefit-inact-reason-code isnull-indicator="Y" />'+
        '</benefit>'+
        '</account-benefits>'+
        '</account>';
}