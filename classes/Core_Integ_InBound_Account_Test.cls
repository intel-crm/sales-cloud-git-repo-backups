//It's a split test class from Core_IntInboundMsgERPM_Account_Test
//This test class is covering all the IPA related test cases.
@isTest
public class Core_Integ_InBound_Account_Test {
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
    
    static Core_Integration_Inbound_Message__c newERPMPersonMessageSplit() {     
        return new Core_Integration_Inbound_Message__c(Core_Source_System__c = 'ERPM',
                                                       Core_Message_Type__c = 'Contact', Core_Processing_Status__c = 'Pending', Core_Payload__c = TEST_ERPM_PERSON_XML1, Core_Payload1__c = TEST_ERPM_PERSON_XML2,Core_Payload2__c = TEST_ERPM_PERSON_XML3,Core_Payload3__c = TEST_ERPM_PERSON_XML4);
    }
    
    @isTest static void Set_AccountProfiles() {
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        System.debug('***** Set_AccountProfileResponses ****** ');               
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1000' limit 1];
        
        String msg = TEST_ERPM_ACCOUNT_XML_ACM_PROFILE_RESPONSES;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 0');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1000');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
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
        msg = msg.replace('REPLACE_ACCT_ENGG_CODE1',     'CSPx2');
        msg = msg.replace('REPLACE_ACCT_ENGG_NAME1',     'Account Engg 1');        
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        
        Account acct = [select ID,Name,Core_User_Defined_Number_of_Employees__c, Core_User_Defined_Website__c,Core_User_Defined_Phone_Number__c, Core_Intel_Partner_Alliance_PartnerGroup__c  
                        from Account where Core_CIM_ID__c = '1000' limit 1];
        system.debug('***** Set_AccountProfileResponses ****** acct' + acct);
        
        
        
        List<PRM_Profile_Responses__c> profResponses =     [SELECT Id, PRM_Account_Id__c, PRM_Profile_Questions_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,
                                                            PRM_Profile_Answer_Id__c, PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c,PRM_Response_Txt__c, PRM_InActive_Ind__c
                                                            FROM PRM_Profile_Responses__c 
                                                            WHERE PRM_Account_Id__c =: acct.Id AND PRM_Profile_Questions_Id__r.PRM_Question_Cd__c ='PQ-000011'
                                                            ORDER BY PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c ASC];
        
        system.debug('***** Set_AccountProfileResponses ****** profResponses' + profResponses);
        
        System.assertEquals('Test Account 0', acct.Name);
        //System.assertEquals(true, acct.Core_Intel_Partner_Alliance_PartnerGroup__c);
        System.assertEquals('www.bbluechip3.com', acct.Core_User_Defined_Website__c);
        System.assertEquals('1-9', acct.Core_User_Defined_Number_of_Employees__c);
        System.assertEquals('1001001001',acct.Core_User_Defined_Phone_Number__c);
        /*
        System.assertEquals('PQ-000011', profResponses[0].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PA-000012', profResponses[0].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);
		*/
    }
    
      @isTest static void StopERPMSFInteg_ACM_New(){
        
        System.debug('***** Set_AccountChannelMembership ****** ');  
          
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = true;
        Core_IntInboundMsgERPM_Account.IsIPAAccountInsertAllowed = 'N';
          
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1001' limit 1];
        
        String msg = TEST_ERPM_ACCOUNT_XML_ITP_ISA;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 1');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1001');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
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
        
        
        Account acct = [select ID,Name,Core_User_Defined_Number_of_Employees__c, Core_User_Defined_Website__c, 
                        Core_IPA_Partner_Role__c , Core_User_Defined_Phone_Number__c, Core_Account_Type__c , 
                        //Core_IPA_Partner_Speciality__c, 
                        Core_Intel_Partner_Alliance_PartnerGroup__c
                        from Account where Core_CIM_ID__c = '1001' limit 1];
        System.debug('acct = ' + acct.Core_IPA_Partner_Role__c);
        System.assertEquals(false, acct.Core_Intel_Partner_Alliance_PartnerGroup__c);              
        System.assertEquals(new List<PRM_AccountChannelMembership__c>(), acm);        
    }
    
    @isTest static void Set_AccountChannelMembership_New(){
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        System.debug('***** Set_AccountChannelMembership ****** ');               
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1001' limit 1];
        
        String msg = TEST_ERPM_ACCOUNT_XML_ITP_ISA;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 1');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1001');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
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
        
        
        Account acct = [select ID,Name,Core_User_Defined_Number_of_Employees__c, Core_User_Defined_Website__c, 
                        Core_IPA_Partner_Role__c , Core_User_Defined_Phone_Number__c, Core_Account_Type__c , 
                        //Core_IPA_Partner_Speciality__c, 
                        Core_Intel_Partner_Alliance_PartnerGroup__c
                        from Account where Core_CIM_ID__c = '1001' limit 1];
        System.debug('acct = ' + acct.Core_IPA_Partner_Role__c);
        System.assertEquals(true, acct.Core_Intel_Partner_Alliance_PartnerGroup__c);
        System.assertEquals('www.bbluechip9.com', acct.Core_User_Defined_Website__c);
        System.assertEquals('1-9', acct.Core_User_Defined_Number_of_Employees__c);
        System.assertEquals('1001001001',acct.Core_User_Defined_Phone_Number__c);
        System.assertEquals('Seller', acct.Core_IPA_Partner_Role__c);
        //System.debug('Partner Speciality - ' + acct.Core_IPA_Partner_Speciality__c);
        //System.assertEquals('Enthusiast PC Specialist',acct.Core_IPA_Partner_Speciality__c);
        System.assertEquals('Reseller', acct.Core_Account_Type__c);
        
        system.debug('acm : ' +acm[0] );
        System.assertEquals('Approved', acm[0].PRM_Status_Nm__c);
        System.assertEquals('IPA', acm[0].PRM_Channel_Program_Id__r.PRM_programCode__c);
        System.assertEquals('Member', acm[0].PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c); 
        System.assertEquals('Seller', acm[0].PRM_Partner_Role__c);
        //System.assertEquals('Manufacturer', acm.PRM_Partner_Role__c);
        
        
        /*
        List<PRM_Profile_Responses__c> profResponses =     [SELECT Id, PRM_Account_Id__c, PRM_Profile_Questions_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,
                                                            PRM_Profile_Answer_Id__c, PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c,PRM_Response_Txt__c
                                                            FROM PRM_Profile_Responses__c 
                                                            WHERE PRM_Account_Id__c =: acct.Id AND PRM_Profile_Questions_Id__r.PRM_Question_Cd__c ='PQ-000011'
                                                            ORDER BY PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c ASC];
        
        System.assertEquals('PQ-000011', profResponses[0].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PA-000012', profResponses[0].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c); 
		*/
        
    }
    
    
    @isTest static void Set_ACM_ITP_ET_ODM_New(){
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        System.debug('***** Set_AccountChannelMembership ****** ');
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1000' limit 1];

        String msg = TEST_ERPM_ACCOUNT_XML_ITP_ET_ODM;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 0');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1000');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
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
        
        
        Account acct = [select ID,Name,Core_User_Defined_Number_of_Employees__c, Core_User_Defined_Website__c, Core_IPA_Partner_Role__c , Core_User_Defined_Phone_Number__c,
                        Core_Account_Type__c
                        //Core_IPA_Partner_Speciality__c  
                        from Account where Core_CIM_ID__c = '1000' limit 1];
        System.debug('acct = ' + acct);
        /*System.assertEquals('www.bbluechip9.com', acct.Core_User_Defined_Website__c);
        System.assertEquals('1-9', acct.Core_User_Defined_Number_of_Employees__c);
        System.assertEquals('1001001001',acct.Core_User_Defined_Phone_Number__c);
        System.assertEquals('Manufacturer;Seller', acct.Core_IPA_Partner_Role__c);
        System.debug('Partner Speciality - ' + acct.Core_IPA_Partner_Speciality__c);
        List<String> ipa_prtnerSplty = acct.Core_IPA_Partner_Speciality__c.split(';');
        ipa_prtnerSplty.sort();
        acct.Core_IPA_Partner_Speciality__c = String.join( ipa_prtnerSplty, ';' );
        System.assertEquals('Enthusiast PC Specialist;LOEM-ODM Partner Program', acct.Core_IPA_Partner_Speciality__c);
        System.debug('acct = Biz Org Type : ' + acct.Core_Account_Type__c);
        System.assertEquals('Reseller;Original Design Manufacturer (ODM)', acct.Core_Account_Type__c);*/

        System.debug('acm : ' +acm[0] );
        System.assertEquals('Approved', acm[0].PRM_Status_Nm__c);
        System.assertEquals('IPA', acm[0].PRM_Channel_Program_Id__r.PRM_programCode__c);
       // System.assertEquals('Titanium', acm[0].PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c);
        System.assertEquals('Manufacturer', acm[0].PRM_Partner_Role__c);
        //System.assertEquals('Manufacturer', acm.PRM_Partner_Role__c);

        /*System.assertEquals('Approved', acm[1].PRM_Status_Nm__c);
        System.assertEquals('IPA', acm[1].PRM_Channel_Program_Id__r.PRM_programCode__c);
        System.assertEquals('Member', acm[1].PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c);
        System.assertEquals('Seller', acm[1].PRM_Partner_Role__c);*/

        /*
        List<PRM_Profile_Responses__c> profResponses =     [SELECT Id, PRM_Account_Id__c, PRM_Profile_Questions_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,
                                                            PRM_Profile_Answer_Id__c, PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c,PRM_Response_Txt__c
                                                            FROM PRM_Profile_Responses__c 
                                                            WHERE PRM_Account_Id__c =: acct.Id AND PRM_Profile_Questions_Id__r.PRM_Question_Cd__c ='PQ-000011'
                                                            ORDER BY PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c ASC];
        
        System.assertEquals('PQ-000011', profResponses[0].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PA-000012', profResponses[0].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);  
		*/
        
    }
    
    @isTest static void Set_AccountChannelMembership_New_ITP_ISA(){       
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        System.debug('***** Set_AccountChannelMembership ****** ');               
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1001' limit 1];
        
        String msg = TEST_ERPM_ACCOUNT_XML_ITP_ISA_BOTH;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 1');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1001');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
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
        
        
        Account acct = [select ID,Name,Core_User_Defined_Number_of_Employees__c, Core_User_Defined_Website__c, Core_IPA_Partner_Role__c, Core_User_Defined_Phone_Number__c, 
                        Core_Account_Type__c //, Core_IPA_Partner_Speciality__c 
                        from Account where Core_CIM_ID__c = '1001' limit 1];
        
       /* List<String> ipa_prtner = acct.Core_IPA_Partner_Speciality__c.split(';');
        ipa_prtner.sort();
        acct.Core_IPA_Partner_Speciality__c = String.join( ipa_prtner, ';' );*/
        
        System.debug('acct = ' + acct.Core_IPA_Partner_Role__c);
        System.assertEquals('www.bbluechip9.com', acct.Core_User_Defined_Website__c);
        System.assertEquals('1-9', acct.Core_User_Defined_Number_of_Employees__c);
        System.assertEquals('1001001001',acct.Core_User_Defined_Phone_Number__c);
        System.assertEquals('Manufacturer;Seller', acct.Core_IPA_Partner_Role__c);
        //System.debug('Partner Speciality - ' + acct.Core_IPA_Partner_Speciality__c);
        //System.assertEquals('Artificial Intelligence Specialist;Enthusiast PC Specialist;Video Specialist',acct.Core_IPA_Partner_Speciality__c);
        System.debug('acct = Biz Org Type : ' + acct.Core_Account_Type__c);
        System.assertEquals('Reseller;Original Design Manufacturer (ODM)', acct.Core_Account_Type__c);
        
        system.debug('acm : ' +acm[0] );
        System.assertEquals('Approved', acm[0].PRM_Status_Nm__c);
        System.assertEquals('IPA', acm[0].PRM_Channel_Program_Id__r.PRM_programCode__c);
        System.assertEquals('Member', acm[0].PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c); 
        System.assertEquals('Manufacturer', acm[0].PRM_Partner_Role__c);
        
        System.assertEquals('Approved', acm[1].PRM_Status_Nm__c);
        System.assertEquals('IPA', acm[1].PRM_Channel_Program_Id__r.PRM_programCode__c);
        System.assertEquals('Member', acm[1].PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c); 
        System.assertEquals('Seller', acm[1].PRM_Partner_Role__c);
        
        
        /*
        List<PRM_Profile_Responses__c> profResponses =     [SELECT Id, PRM_Account_Id__c, PRM_Profile_Questions_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,
                                                            PRM_Profile_Answer_Id__c, PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c,PRM_Response_Txt__c
                                                            FROM PRM_Profile_Responses__c 
                                                            WHERE PRM_Account_Id__c =: acct.Id AND PRM_Profile_Questions_Id__r.PRM_Question_Cd__c ='PQ-000011'
                                                            ORDER BY PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c ASC];
        
        System.assertEquals('PQ-000011', profResponses[0].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PA-000012', profResponses[0].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c); 
		*/
        
    }
    
    @isTest static void Set_ACM_New_ITP_NoBenefit_ISA(){
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        System.debug('***** Set_AccountChannelMembership ****** ');               
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1001' limit 1];
        
        String msg = TEST_ERPM_ACCOUNT_XML_ITP_NoBenefit_ISA_BOTH;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 1');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1001');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
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
        
        
        Account acct = [select ID,Name,Core_User_Defined_Number_of_Employees__c, Core_User_Defined_Website__c, Core_IPA_Partner_Role__c, Core_User_Defined_Phone_Number__c, 
                        //Core_IPA_Partner_Speciality__c,
                        Core_Account_Type__c  from Account where Core_CIM_ID__c = '1001' limit 1];
        System.debug('acct = ' + acct.Core_IPA_Partner_Role__c);
        System.assertEquals('www.bbluechip9.com', acct.Core_User_Defined_Website__c);
        System.assertEquals('1-9', acct.Core_User_Defined_Number_of_Employees__c);
        System.assertEquals('1001001001',acct.Core_User_Defined_Phone_Number__c);
        System.assertEquals('Manufacturer', acct.Core_IPA_Partner_Role__c);
        System.debug('acct = Biz Org Type : ' + acct.Core_Account_Type__c);
        System.assertEquals('Original Design Manufacturer (ODM)', acct.Core_Account_Type__c);
        
        system.debug('acm : ' +acm[0] );
        System.assertEquals('Approved', acm[0].PRM_Status_Nm__c);
        System.assertEquals('IPA', acm[0].PRM_Channel_Program_Id__r.PRM_programCode__c);
        System.assertEquals('Member', acm[0].PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c); 
        System.assertEquals('Manufacturer', acm[0].PRM_Partner_Role__c);
        
        /*
        List<PRM_Profile_Responses__c> profResponses =     [SELECT Id, PRM_Account_Id__c, PRM_Profile_Questions_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,
                                                            PRM_Profile_Answer_Id__c, PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c,PRM_Response_Txt__c
                                                            FROM PRM_Profile_Responses__c 
                                                            WHERE PRM_Account_Id__c =: acct.Id AND PRM_Profile_Questions_Id__r.PRM_Question_Cd__c ='PQ-000011'
                                                            ORDER BY PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c ASC];
        
        System.assertEquals('PQ-000011', profResponses[0].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PA-000012', profResponses[0].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);  
		*/
        
    }
    
    @isTest static void Set_ACM_Update_ITP_Add_ISA(){
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        System.debug('***** Set_AccountChannelMembership ****** ');               
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1002' limit 1];
        
        String msg = TEST_ERPM_ACCOUNT_XML_ITP_ISA_BOTH;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 2');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1002');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
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
        
        
        Account acct = [select ID,Name,Core_User_Defined_Number_of_Employees__c, Core_User_Defined_Website__c, Core_IPA_Partner_Role__c , 
                        //Core_IPA_Partner_Speciality__c, 
                        Core_User_Defined_Phone_Number__c, Core_Account_Type__c from Account where Core_CIM_ID__c = '1002' limit 1];
        
        /*List<String> ipa_prtner = acct.Core_IPA_Partner_Speciality__c.split(';');
        ipa_prtner.sort();
        acct.Core_IPA_Partner_Speciality__c = String.join( ipa_prtner, ';' );*/
        
        System.debug('acct = ' + acct.Core_IPA_Partner_Role__c);
        System.debug('acct = ' + acct.Core_Account_Type__c);
        System.assertEquals('www.bbluechip9.com', acct.Core_User_Defined_Website__c);
        System.assertEquals('1-9', acct.Core_User_Defined_Number_of_Employees__c);
        System.assertEquals('1001001001',acct.Core_User_Defined_Phone_Number__c);
        System.assertEquals('Manufacturer;Seller', acct.Core_IPA_Partner_Role__c);
       // System.debug('Partner Speciality - ' + acct.Core_IPA_Partner_Speciality__c);
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
    
     @isTest static void Set_ACM_Update_ITP_ISA_Optimization_CIMID_Acct_no(){
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
         System.debug('***** Set_AccountChannelMembership ****** ');               
         Account testAcct = [select Id from Account where Core_CIM_ID__c = '1002' limit 1];
         System.debug('erpmAccountIds'+testAcct.Id);                              
                                                   
        String msg = TEST_ERPM_ACCOUNT_XML_ITP_ISA_BOTH;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 2');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1002');     // Bogus CIM ID
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
        
        
        Account acct = [select ID,Name,Core_User_Defined_Number_of_Employees__c, Core_User_Defined_Website__c, Core_IPA_Partner_Role__c ,
                        //Core_IPA_Partner_Speciality__c, 
                        Core_User_Defined_Phone_Number__c, Core_Account_Type__c from Account where Core_CIM_ID__c = '1002' limit 1];
        
       /* List<String> ipa_prtner = acct.Core_IPA_Partner_Speciality__c.split(';');
        ipa_prtner.sort();
        acct.Core_IPA_Partner_Speciality__c = String.join( ipa_prtner, ';' );*/
        
        System.debug('acct = ' + acct.Core_IPA_Partner_Role__c);
        System.debug('acct = ' + acct.Core_Account_Type__c);
        System.assertEquals('www.bbluechip9.com', acct.Core_User_Defined_Website__c);
        System.assertEquals('1-9', acct.Core_User_Defined_Number_of_Employees__c);
        System.assertEquals('1001001001',acct.Core_User_Defined_Phone_Number__c);
        System.assertEquals('Manufacturer;Seller', acct.Core_IPA_Partner_Role__c);
       // System.debug('Partner Speciality - ' + acct.Core_IPA_Partner_Speciality__c);
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
    
      @isTest static void Set_ACM_Update_ITP_ISA_Optimization_Only_CIMID(){
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
         System.debug('***** Set_AccountChannelMembership ****** ');               
         Account testAcct = [select Id from Account where Core_CIM_ID__c = '1003' limit 1];                   
                                                   
        String msg = TEST_ERPM_ACCOUNT_XML_ITP_ISA_BOTH;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 3');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1003');     // Bogus CIM ID
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
        
        
        Account acct = [select ID,Name,Core_User_Defined_Number_of_Employees__c, Core_User_Defined_Website__c, Core_IPA_Partner_Role__c ,// Core_IPA_Partner_Speciality__c, 
                        Core_User_Defined_Phone_Number__c, Core_Account_Type__c from Account where Core_CIM_ID__c = '1003' limit 1];
        
       /* List<String> ipa_prtner = acct.Core_IPA_Partner_Speciality__c.split(';');
        ipa_prtner.sort();
        acct.Core_IPA_Partner_Speciality__c = String.join( ipa_prtner, ';' );*/
        
        System.debug('acct = ' + acct.Core_IPA_Partner_Role__c);
        System.debug('acct = ' + acct.Core_Account_Type__c);
        System.assertEquals('www.bbluechip9.com', acct.Core_User_Defined_Website__c);
        System.assertEquals('1-9', acct.Core_User_Defined_Number_of_Employees__c);
        System.assertEquals('1001001001',acct.Core_User_Defined_Phone_Number__c);
        System.assertEquals('Manufacturer;Seller', acct.Core_IPA_Partner_Role__c);
        //System.debug('Partner Speciality - ' + acct.Core_IPA_Partner_Speciality__c);
       // System.assertEquals('Artificial Intelligence Specialist;Enthusiast PC Specialist;Video Specialist',acct.Core_IPA_Partner_Speciality__c);
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
    
    @isTest static void Set_AccountChannelMembership_CSP_withoutAccount_No(){
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1001' limit 1];
        
        //String msg = TEST_ERPM_ACCOUNT_XML_ACM_PROFILE_RESPONSES;
        String msg = TEST_ERPM_ACCOUNT_XML_ACM_PROFILE_RESPONSES_Dup ;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 2');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '999999');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1001');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
        msg = msg.replace('REPLACE_ACCT_PHONE',          '1001001001');
        msg = msg.replace('REPLACE_ACCT_PHONE_HOME',     '1001001023');
        msg = msg.replace('REPLACE_ACCT_FAX',            '3001001001');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE1',     'Addr Line 1');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE2',     'Addr Line 2');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE3',     'Addr Line 3');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE4',     'Addr Line 4');
        msg = msg.replace('REPLACE_ACCT_ADDR_CITY',      'Sydney');
        msg = msg.replace('REPLACE_ACCT_ADDR_STATE',     'OR');
        msg = msg.replace('REPLACE_ACCT_ADDR_POSTALCODE','97229');
        msg = msg.replace('REPLACE_ACCT_ADDR_COUNTRY',   'USA');
        msg = msg.replace('REPLACE_ACCT_ENGG_CODE1',     'CSPx2');
        msg = msg.replace('REPLACE_ACCT_ENGG_NAME1',     'Account Engg 1');        
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        List<Core_Account_ERPM_Engagement__c> eRPMEngagements= [SELECT Core_Account_Id__c, Core_ERPM_Account_Number__c  
                                                                FROM Core_Account_ERPM_Engagement__c  WHERE  Core_Account_Id__r.Core_CIM_ID__c ='1001'];
                                                                                            
      	System.debug('eRPMEngagements[0].Core_ERPM_Account_Number__c'+eRPMEngagements[0].Core_ERPM_Account_Number__c);
        System.assertEquals('999999',  eRPMEngagements[0].Core_ERPM_Account_Number__c);
    }
     @isTest static void Set_AccountChannelMembership_OnlySFIdUpdateAccount(){
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1001' limit 1];
        
        //String msg = TEST_ERPM_ACCOUNT_XML_ACM_PROFILE_RESPONSES;
        String msg = TEST_ERPM_ACCOUNT_XML_ACM_PROFILE_RESPONSES_Dup ;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 2');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '999999');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
        msg = msg.replace('REPLACE_ACCT_PHONE',          '1001001001');
        msg = msg.replace('REPLACE_ACCT_PHONE_HOME',     '1001001023');
        msg = msg.replace('REPLACE_ACCT_FAX',            '3001001001');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE1',     'Addr Line 1');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE2',     'Addr Line 2');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE3',     'Addr Line 3');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE4',     'Addr Line 4');
        msg = msg.replace('REPLACE_ACCT_ADDR_CITY',      'Sydney');
        msg = msg.replace('REPLACE_ACCT_ADDR_STATE',     'OR');
        msg = msg.replace('REPLACE_ACCT_ADDR_POSTALCODE','97229');
        msg = msg.replace('REPLACE_ACCT_ADDR_COUNTRY',   'USA');
        msg = msg.replace('REPLACE_ACCT_ENGG_CODE1',     'CSPx2');
        msg = msg.replace('REPLACE_ACCT_ENGG_NAME1',     'Account Engg 1');        
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        List<Core_Account_ERPM_Engagement__c> eRPMEngagements= [SELECT Core_Account_Id__c, Core_ERPM_Account_Number__c  
                                                                FROM Core_Account_ERPM_Engagement__c  WHERE  Core_Account_Id__r.Core_CIM_ID__c ='1001'];
                                                                                            
      	System.debug('eRPMEngagements[0].Core_ERPM_Account_Number__c'+eRPMEngagements[0].Core_ERPM_Account_Number__c);
        System.assertEquals('999999',  eRPMEngagements[0].Core_ERPM_Account_Number__c);
    }
     @isTest static void Set_AccountChannelMembership_CSP_withAccountNo(){
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1003' limit 1];
        System.debug('sfid'+testAcct.Id);
        //String msg = TEST_ERPM_ACCOUNT_XML_ACM_PROFILE_RESPONSES;
        String msg = TEST_ERPM_ACCOUNT_XML_ACM_PROFILE_RESPONSES_Dup ;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 2');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '999999');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1003');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
        msg = msg.replace('REPLACE_ACCT_PHONE',          '1001001001');
        msg = msg.replace('REPLACE_ACCT_PHONE_HOME',     '1001001023');
        msg = msg.replace('REPLACE_ACCT_FAX',            '3001001001');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE1',     'Addr Line 1');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE2',     'Addr Line 2');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE3',     'Addr Line 3');
        msg = msg.replace('REPLACE_ACCT_ADDR_LINE4',     'Addr Line 4');
        msg = msg.replace('REPLACE_ACCT_ADDR_CITY',      'Sydney');
        msg = msg.replace('REPLACE_ACCT_ADDR_STATE',     'OR');
        msg = msg.replace('REPLACE_ACCT_ADDR_POSTALCODE','97229');
        msg = msg.replace('REPLACE_ACCT_ADDR_COUNTRY',   'USA');
        msg = msg.replace('REPLACE_ACCT_ENGG_CODE1',     'CSPx2');
        msg = msg.replace('REPLACE_ACCT_ENGG_NAME1',     'Account Engg 1');        
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        List<Core_Account_ERPM_Engagement__c> eRPMEngagements= [SELECT Core_Account_Id__c, Core_ERPM_Account_Number__c  
                                                                FROM Core_Account_ERPM_Engagement__c  WHERE  Core_Account_Id__r.Core_CIM_ID__c ='1003'];
                                                                                            
      	System.debug('eRPMEngagements[0].Core_ERPM_Account_Number__c'+eRPMEngagements[0].Core_ERPM_Account_Number__c);
        System.assertEquals('654789',  eRPMEngagements[0].Core_ERPM_Account_Number__c);
    }
    
    /*@isTest static void Set_ACM_Update_ITP_ET_ODM_Add_ISA(){


System.debug('***** Set_AccountChannelMembership ****** ');               
Account testAcct = [select Id from Account where Core_CIM_ID__c = '1003' limit 1];

String msg = TEST_ERPM_ACCOUNT_XML_ITP_ET_ODM_ISA_BOTH;
msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 3');
msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1003');     // Bogus CIM ID
msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
msg = msg.replace('REPLACE_ACCT_PHONE',          '1001001001');
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


Account acct = [select ID,Name,Core_User_Defined_Number_of_Employees__c, Core_User_Defined_Website__c, Core_IPA_Partner_Role__c  from Account where Core_CIM_ID__c = '1003' limit 1];
System.debug('acct = ' + acct.Core_IPA_Partner_Role__c);
System.assertEquals('www.bbluechip9.com', acct.Core_User_Defined_Website__c);
System.assertEquals('1-9', acct.Core_User_Defined_Number_of_Employees__c);
System.assertEquals('Manufacturer;Seller', acct.Core_IPA_Partner_Role__c);

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

}*/
    
    @isTest static void Set_ACM_Update_ITP_Rem_ISA(){
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        System.debug('***** Set_AccountChannelMembership ****** ');               
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1002' limit 1];
        
        String msg = TEST_ERPM_ACCOUNT_XML_ITP_ISA_BOTH;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 2');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1002');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
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
        msg = msg.replace('REPLACE_ACCT_ENGG_ISA_STATUS',     'ENGSTSRJTD');
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
        
        
        Account acct = [select ID,Name,Core_User_Defined_Number_of_Employees__c, Core_User_Defined_Website__c, Core_IPA_Partner_Role__c, Core_User_Defined_Phone_Number__c, 
                        Core_Account_Type__c//, Core_IPA_Partner_Speciality__c 
                        from Account where Core_CIM_ID__c = '1002' limit 1];
        System.debug('acct = ' + acct.Core_IPA_Partner_Role__c);
        
        /*List<String> ipa_prtner = acct.Core_IPA_Partner_Speciality__c.split(';');
        ipa_prtner.sort();
        acct.Core_IPA_Partner_Speciality__c = String.join( ipa_prtner, ';' );*/
        
        System.assertEquals('www.bbluechip9.com', acct.Core_User_Defined_Website__c);
        System.assertEquals('1-9', acct.Core_User_Defined_Number_of_Employees__c);
        System.assertEquals('1001001001',acct.Core_User_Defined_Phone_Number__c);
        System.assertEquals('Manufacturer;Seller', acct.Core_IPA_Partner_Role__c);
       // System.debug('Partner Speciality - ' + acct.Core_IPA_Partner_Speciality__c);
       // System.assertEquals('Artificial Intelligence Specialist;Enthusiast PC Specialist;Video Specialist',acct.Core_IPA_Partner_Speciality__c);
        System.debug('acct = Biz Org Type : ' + acct.Core_Account_Type__c);
        System.assertEquals('Reseller;Original Design Manufacturer (ODM)', acct.Core_Account_Type__c);
        
        
        system.debug('acm0 : ' +acm[0] );
        System.assertEquals('Inactive', acm[0].PRM_Status_Nm__c);
        System.assertEquals('IPA', acm[0].PRM_Channel_Program_Id__r.PRM_programCode__c);
        System.assertEquals('Member', acm[0].PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c); 
        System.assertEquals('Manufacturer', acm[0].PRM_Partner_Role__c);
        
        system.debug('acm1 : ' +acm[0] );
        System.assertEquals('Approved', acm[1].PRM_Status_Nm__c);
        System.assertEquals('IPA', acm[1].PRM_Channel_Program_Id__r.PRM_programCode__c);
        System.assertEquals('Member', acm[1].PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c); 
        System.assertEquals('Seller', acm[1].PRM_Partner_Role__c);
        
    }
    
    @isTest static void Set_AccountChannelMembership_Update() {
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        System.debug('***** Set_AccountChannelMembership_Update ****** ');               
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1001' limit 1];
        
        String msg = TEST_ERPM_ACCOUNT_XML_ITP_ISA;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 2');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1001');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
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
        msg = msg.replace('REPLACE_ACCT_ENGG_TIER',     'PLATINUM');  
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        List<PRM_AccountChannelMembership__c> acm = [SELECT Id, PRM_Account_Id__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c,
                                                     PRM_Channel_Program_Id__r.PRM_programCode__c, PRM_Status_Nm__c, PRM_Status_Reason_Txt__c,
                                                     PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c, PRM_Partner_Role__c
                                                     FROM PRM_AccountChannelMembership__c 
                                                     WHERE PRM_Account_Id__c =: testAcct.Id];
        
        //system.debug('acm : ' +acm[0] );
        System.assertEquals('Approved', acm[0].PRM_Status_Nm__c);
        System.assertEquals('IPA', acm[0].PRM_Channel_Program_Id__r.PRM_programCode__c);
        System.assertEquals('Titanium', acm[0].PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c);    
        System.assertEquals('Seller', acm[0].PRM_Partner_Role__c);
    }
    
    @isTest static void Set_AccountChannelMembership_Benefit_Postive(){
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        System.debug('***** Set_AccountChannelMembership ****** ');
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1000' limit 1];

        String msg = TEST_ERPM_ACCOUNT_XML_ITP_ISA_Benefit;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 0');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1000');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
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
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        List<PRM_AccountChannelMembership__c> acm = [SELECT Id, PRM_Account_Id__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c,
                                                     PRM_Channel_Program_Id__r.PRM_programCode__c, PRM_Status_Nm__c, PRM_Status_Reason_Txt__c,
                                                     PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c
                                                     FROM PRM_AccountChannelMembership__c 
                                                     WHERE PRM_Account_Id__c =: testAcct.Id];
        
        //system.debug('acm Benefit : ' +acm[0] );
        System.assertEquals('Approved', acm[0].PRM_Status_Nm__c);
        System.assertEquals('IPA', acm[0].PRM_Channel_Program_Id__r.PRM_programCode__c);
        System.assertEquals('Titanium', acm[0].PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c);


        /*Account acct = [select ID, Name, Core_User_Defined_Number_of_Employees__c, Core_User_Defined_Website__c ,ShippingCity , Core_User_Defined_Phone_Number__c  from Account where Core_CIM_ID__c = '1001' limit 1];
        System.assertEquals('www.bbluechip6.com', acct.Core_User_Defined_Website__c);
        System.assertEquals('1-9', acct.Core_User_Defined_Number_of_Employees__c);
        System.assertEquals('1001001001',acct.Core_User_Defined_Phone_Number__c);

        System.assertEquals('Portland',  acct.ShippingCity);*/
        /*
        List<PRM_Profile_Responses__c> profResponses =     [SELECT Id, PRM_Account_Id__c, PRM_Profile_Questions_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,
                                                            PRM_Profile_Answer_Id__c, PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c,PRM_Response_Txt__c
                                                            FROM PRM_Profile_Responses__c 
                                                            WHERE PRM_Account_Id__c =: acct.Id AND PRM_Profile_Questions_Id__r.PRM_Question_Cd__c ='PQ-000011'
                                                            ORDER BY PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c ASC];
        
        System.assertEquals('PQ-000011', profResponses[0].PRM_Profile_Questions_Id__r.PRM_Question_Cd__c);
        System.assertEquals('PA-000012', profResponses[0].PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c);  
		*/
        
    }
    
    @isTest static void Set_AccountChannelMembership_Benefit_Negative(){
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        System.debug('***** Set_AccountChannelMembership ****** ');               
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1001' limit 1];
        
        String msg = TEST_ERPM_ACCOUNT_XML_ITP_ISA_No_Benefit;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 1');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1001');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
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
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        System.debug('test stopped');
        List<PRM_AccountChannelMembership__c> acm = [SELECT Id, PRM_Account_Id__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c,
                                                     PRM_Channel_Program_Id__r.PRM_programCode__c, PRM_Status_Nm__c, PRM_Status_Reason_Txt__c,
                                                     PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c
                                                     FROM PRM_AccountChannelMembership__c 
                                                     WHERE PRM_Account_Id__c =: testAcct.Id];
        
        Account testAcct1 = [select Id,Core_User_Defined_Website__c  from Account where Core_CIM_ID__c = '1001' limit 1];
        System.assertEquals(0, acm.Size());  
        System.assertEquals(null, testAcct1.Core_User_Defined_Website__c);
    }
    
     @isTest static void Set_AccountChannelMembership_Benefit_Negative_ITP_ODM(){
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        System.debug('***** Set_AccountChannelMembership ****** ');               
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1001' limit 1];
        
        String msg = TEST_ERPM_ACCOUNT_XML_ITP_ODM_ACCT;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 1');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1001');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
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
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        System.debug('test stopped');
        List<PRM_AccountChannelMembership__c> acm = [SELECT Id, PRM_Account_Id__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c,
                                                     PRM_Channel_Program_Id__r.PRM_programCode__c, PRM_Status_Nm__c, PRM_Status_Reason_Txt__c,
                                                     PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c
                                                     FROM PRM_AccountChannelMembership__c 
                                                     WHERE PRM_Account_Id__c =: testAcct.Id];
        
        Account testAcct1 = [select Id,Core_User_Defined_Website__c  from Account where Core_CIM_ID__c = '1001' limit 1];
        System.assertEquals(0, acm.Size());  
        System.assertEquals(null, testAcct1.Core_User_Defined_Website__c);
    }
    
    @isTest static void Set_AccountChannelMembership_Benefit_NonITP(){
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1000' limit 1];
        
        //String msg = TEST_ERPM_ACCOUNT_XML_ACM_PROFILE_RESPONSES;
        String msg = TEST_ERPM_ACCOUNT_XML_ACM_PROFILE_RESPONSES_Dup ;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 0');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1000');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
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
        msg = msg.replace('REPLACE_ACCT_ENGG_CODE1',     'CSPx2');
        msg = msg.replace('REPLACE_ACCT_ENGG_NAME1',     'Account Engg 1');        
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        Account acct = [select ID,ShippingCity,Name,Core_User_Defined_Phone_Number__c  from Account where Core_CIM_ID__c = '1000' limit 1];
        System.assertEquals('Test Account 0', acct.Name);
        System.assertEquals('Portland',  acct.ShippingCity);
        System.assertEquals('1001001001',acct.Core_User_Defined_Phone_Number__c);
        
    }
    
    @isTest static void Set_AddressForAccount(){
        
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        Account testAcct = [select Id from Account where Core_CIM_ID__c = '1000' limit 1];
        
        //String msg = TEST_ERPM_ACCOUNT_XML_ACM_PROFILE_RESPONSES;
        String msg = TEST_ERPM_ACCOUNT_XML_ACM_PROFILE_RESPONSES ;
        msg = msg.replace('REPLACE_ACCT_NAME',           'Test Account 0');
        msg = msg.replace('REPLACE_ACCT_LEGAL_NAME',     'COMPUTER CONTACT, INC.');
        msg = msg.replace('REPLACE_ACCT_ERPM_NUMBER',    '98765');
        msg = msg.replace('REPLACE_ACCT_CIM_ID',         '1000');     // Bogus CIM ID
        msg = msg.replace('REPLACE_ACCT_SFDC_ID',        testAcct.Id); // Real SFDC ID
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
        msg = msg.replace('REPLACE_ACCT_ENGG_CODE1',     'CSPx2');
        msg = msg.replace('REPLACE_ACCT_ENGG_NAME1',     'Account Engg 1');        
        
        System.debug('##### msg = ' + msg);
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        Account acct = [select ID,ShippingCity,Name, Core_User_Defined_Phone_Number__c  from Account where Core_CIM_ID__c = '1000' limit 1];
        System.assertEquals('Test Account 0', acct.Name);
        System.assertEquals('Portland',  acct.ShippingCity);
        System.assertEquals('1001001001',acct.Core_User_Defined_Phone_Number__c);
        
    }
    
    @isTest static void Stop_Create_Account_ISA()
    {
        String msg = TEST_ERPM_CREATE_ACCOUNT_ISA;
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = true;
        Core_IntInboundMsgERPM_Account.IsIPAAccountInsertAllowed = 'N';
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        List<Account> acct = [select ID,Name  from Account where Core_CIM_ID__c = '22803681'];
        System.assertEquals(0, acct.size());
        
    }
    
    /*@isTest static void Create_Account_ISA()
    {
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        Core_IntInboundMsgERPM_Account.IsIPAAccountInsertAllowed = 'Y';
        String msg = TEST_ERPM_CREATE_ACCOUNT_ISA;
        
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        Account acct = [select ID,Name  from Account where Core_CIM_ID__c = '22803681' limit 1];
        System.assertEquals('Jet Pack ai', acct.Name);
        
    }*/
    
    @isTest static void Create_Account_CSPx2()
    {
        String msg = TEST_ERPM_CSPx2_ACCOUNT_CREATE;
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        List<Account> acct = [select ID  from Account where Core_CIM_ID__c = '22803681' limit 1];
        System.assertEquals(true, acct.isEmpty());
        
    }
    
    @isTest static void No_CIM_Id_Check()
    {
        String msg = TEST_ERPM_NO_CIMID_CASE;
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        List<Account> acct = [select ID  from Account where Core_CIM_ID__c = '22803681' limit 1];
        System.assertEquals(true, acct.isEmpty());
        
    }
    
    @isTest static void RDC_Create_Account_Check()
    {
        String msg = TEST_ERPM_CREATE_RDC_TEST;
        Core_IntInboundMsgERPM_Account.StopERPMSalesCloudIPAInteg = false;
        Test.startTest();
        insert newERPMAccountMessage(msg);
        Test.stopTest();
        
        List<Account> acct = [select ID  from Account where Core_B2B_ERPM_Account_Number__c = '1000377130'];
        System.assertEquals(1, acct.size());
        
        
    }
    
    private static final String TEST_ERPM_CREATE_RDC_TEST = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<account xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" test-account-indicator="N" inact-indicator="N">' +
        '<account-information>' +
        '<account-name>Jet Pack ai</account-name>' +
        '<account-names>' +
        '<account-name type="Alias Name" isnull-indicator="Y" />' +
        '<account-name type="Doing Business As" isnull-indicator="Y" />' +
        '<account-name type="Legal Name" isnull-indicator="N" >REPLACE_ACCT_LEGAL_NAME</account-name>' +
        '</account-names>' +
        '<account-number>1000377130</account-number>' +
        '<engg-dedup-group-code>DEDUPB2B</engg-dedup-group-code>' +
        '<language-code>ENG</language-code>' +
        '<primary-addr-type-code>PHY</primary-addr-type-code>' +
        '</account-information>' +
        '<account-external-systems>' +
        '<account-external-system system-name="CIM" inact-indicator="N">22943668</account-external-system>'+
        '</account-external-systems>' +
        '<electronic-addresses>' +
        '<electronic-address electronic-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="N">REPLACE_ACCT_FAX</electronic-address>' +
        '<electronic-address electronic-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="N">REPLACE_ACCT_PHONE</electronic-address>' +
        '<electronic-address electronic-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="HOME" isnull-indicator="N">REPLACE_ACCT_PHONE_HOME</electronic-address>' +
        '<electronic-address electronic-type-code="URL" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="Y" />' +
        '<electronic-address electronic-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '</electronic-addresses>' +
        '<physical-addresses>' +
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
        '<physical-address address-usg-type-code="PHY" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
        '<physical-address address-usg-type-code="PHY" contact-indicator="Y" preferred-indicator="N" inact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<address-line1-text>oijugytftest</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">oijugytf</address-line2-text>' +
        '<address-line3-text isnull-indicator="N"/>' +
        '<address-line4-text isnull-indicator="N"/>' +
        '<city-name>Bangalore</city-name>' +
        '<state-code isnull-indicator="N">KA</state-code>' +
        '<state-name isnull-indicator="N">Karnataka</state-name>' +
        '<postal-code isnull-indicator="N">560003</postal-code>' +
        '<country-code>IN</country-code>' +
        '<country-name isnull-indicator="N">India</country-name>' +
        '<iso-country-code>IND</iso-country-code>' +
        '</physical-address>' +
        '</physical-addresses>' +
        '<engagements>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD11" engg-type-code="ENGTYPSECR">' +
        '<engg-id>10118</engg-id>' +
        '<engg-code>IRDC_Priv</engg-code>' +
        '<engg-name>Resource &amp; Design Center (Priv)</engg-name>' +
        '<effective-tier-code>MEMBER</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-reason-code isnull-indicator="Y" />' +
        '</engagement>' +
        '</engagements>' +
        '</account>';
    
    private static final String TEST_ERPM_NO_CIMID_CASE = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<account xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" test-account-indicator="N" inact-indicator="N">' +
        '<account-information>' +
        '<account-name>Jet Pack ai</account-name>' +
        '<account-names>' +
        '<account-name type="Alias Name" isnull-indicator="Y" />' +
        '<account-name type="Doing Business As" isnull-indicator="Y" />' +
        '<account-name type="Legal Name" isnull-indicator="N" >REPLACE_ACCT_LEGAL_NAME</account-name>' +
        '</account-names>' +
        '<account-number>1000377130</account-number>' +
        '<engg-dedup-group-code>DEDUPGPITP</engg-dedup-group-code>' +
        '<language-code>ENG</language-code>' +
        '<primary-addr-type-code>MAIL</primary-addr-type-code>' +
        '</account-information>' +
        '<account-external-systems>' +
        '</account-external-systems>' +
        '<electronic-addresses>' +
        '<electronic-address electronic-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="N">REPLACE_ACCT_FAX</electronic-address>' +
        '<electronic-address electronic-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="N">REPLACE_ACCT_PHONE</electronic-address>' +
        '<electronic-address electronic-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="HOME" isnull-indicator="N">REPLACE_ACCT_PHONE_HOME</electronic-address>' +
        '<electronic-address electronic-type-code="URL" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="Y" />' +
        '<electronic-address electronic-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '</electronic-addresses>' +
        '<physical-addresses>' +
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
        '<physical-address address-usg-type-code="PHY" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
        '<physical-address address-usg-type-code="MAIL" contact-indicator="Y" preferred-indicator="N" inact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<address-line1-text>oijugytftest</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">oijugytf</address-line2-text>' +
        '<address-line3-text isnull-indicator="N"/>' +
        '<address-line4-text isnull-indicator="N"/>' +
        '<city-name>Bangalore</city-name>' +
        '<state-code isnull-indicator="N">KA</state-code>' +
        '<state-name isnull-indicator="N">Karnataka</state-name>' +
        '<postal-code isnull-indicator="N">560003</postal-code>' +
        '<country-code>IN</country-code>' +
        '<country-name isnull-indicator="N">India</country-name>' +
        '<iso-country-code>IND</iso-country-code>' +
        '</physical-address>' +
        '</physical-addresses>' +
        '<engagements>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD11" engg-type-code="ENGTYPSECR">' +
        '<engg-id>10118</engg-id>' +
        '<engg-code>ISA</engg-code>' +
        '<engg-name>Intel® Internet of Things Solution Alliance</engg-name>' +
        '<tier-code>GENERAL</tier-code>' +
        '<effective-tier-code>GENERAL</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-reason-code isnull-indicator="Y" />' +
        '</engagement>' +
        '</engagements>' +
        '</account>';
    
    private static final String TEST_ERPM_CSPx2_ACCOUNT_CREATE = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<account xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" test-account-indicator="N" inact-indicator="N">' +
        '<account-information>' +
        '<account-name>Jet Pack ai</account-name>' +
        '<account-names>' +
        '<account-name type="Alias Name" isnull-indicator="Y" />' +
        '<account-name type="Doing Business As" isnull-indicator="Y" />' +
        '<account-name type="Legal Name" isnull-indicator="N" >REPLACE_ACCT_LEGAL_NAME</account-name>' +
        '</account-names>' +
        '<account-number>1000377130</account-number>' +
        '<engg-dedup-group-code>DEDUPGPITP</engg-dedup-group-code>' +
        '<language-code>ENG</language-code>' +
        '<primary-addr-type-code>MAIL</primary-addr-type-code>' +
        '</account-information>' +
        '<account-external-systems>' +
        '<account-external-system system-name="CIM" inact-indicator="N">22803681</account-external-system>' +
        '</account-external-systems>' +
        '<electronic-addresses>' +
        '<electronic-address electronic-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="N">REPLACE_ACCT_FAX</electronic-address>' +
        '<electronic-address electronic-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="N">REPLACE_ACCT_PHONE</electronic-address>' +
        '<electronic-address electronic-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="HOME" isnull-indicator="N">REPLACE_ACCT_PHONE_HOME</electronic-address>' +
        '<electronic-address electronic-type-code="URL" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="Y" />' +
        '<electronic-address electronic-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '</electronic-addresses>' +
        '<physical-addresses>' +
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
        '<physical-address address-usg-type-code="PHY" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
        '<physical-address address-usg-type-code="MAIL" contact-indicator="Y" preferred-indicator="N" inact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<address-line1-text>oijugytftest</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">oijugytf</address-line2-text>' +
        '<address-line3-text isnull-indicator="N"/>' +
        '<address-line4-text isnull-indicator="N"/>' +
        '<city-name>Bangalore</city-name>' +
        '<state-code isnull-indicator="N">KA</state-code>' +
        '<state-name isnull-indicator="N">Karnataka</state-name>' +
        '<postal-code isnull-indicator="N">560003</postal-code>' +
        '<country-code>IN</country-code>' +
        '<country-name isnull-indicator="N">India</country-name>' +
        '<iso-country-code>IND</iso-country-code>' +
        '</physical-address>' +
        '</physical-addresses>' +
        '<engagements>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD11" engg-type-code="ENGTYPSECR">' +
        '<engg-id>10118</engg-id>' +
        '<engg-code>CSPx2</engg-code>' +
        '<engg-name>Intel® Cloud Insider</engg-name>' +
        '<tier-code>GENERAL</tier-code>' +
        '<effective-tier-code>GENERAL</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-reason-code isnull-indicator="Y" />' +
        '</engagement>' +
        '</engagements>' +
        '</account>';
    
    private static final String TEST_ERPM_CREATE_ACCOUNT_ISA = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<account xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" test-account-indicator="N" inact-indicator="N">' +
        '<account-information>' +
        '<account-name>Jet Pack ai</account-name>' +
        '<account-names>' +
        '<account-name type="Alias Name" isnull-indicator="Y" />' +
        '<account-name type="Doing Business As" isnull-indicator="Y" />' +
        '<account-name type="Legal Name" isnull-indicator="N" >REPLACE_ACCT_LEGAL_NAME</account-name>' +
        '</account-names>' +
        '<account-number>1000377130</account-number>' +
        '<engg-dedup-group-code>DEDUPGPITP</engg-dedup-group-code>' +
        '<language-code>ENG</language-code>' +
        '<primary-addr-type-code>MAIL</primary-addr-type-code>' +
        '</account-information>' +
        '<account-external-systems>' +
        '<account-external-system system-name="CIM" inact-indicator="N">22803681</account-external-system>' +
        '</account-external-systems>' +
        '<electronic-addresses>' +
        '<electronic-address electronic-type-code="FAX" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="N">REPLACE_ACCT_FAX</electronic-address>' +
        '<electronic-address electronic-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="N">REPLACE_ACCT_PHONE</electronic-address>' +
        '<electronic-address electronic-type-code="PHONE" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="HOME" isnull-indicator="N">REPLACE_ACCT_PHONE_HOME</electronic-address>' +
        '<electronic-address electronic-type-code="URL" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="Y" />' +
        '<electronic-address electronic-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '</electronic-addresses>' +
        '<physical-addresses>' +
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
        '<physical-address address-usg-type-code="PHY" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
        '<physical-address address-usg-type-code="MAIL" contact-indicator="Y" preferred-indicator="N" inact-indicator="N" location-type-code="BUS" isnull-indicator="N">' +
        '<address-line1-text>oijugytftest</address-line1-text>' +
        '<address-line2-text isnull-indicator="N">oijugytf</address-line2-text>' +
        '<address-line3-text isnull-indicator="N"/>' +
        '<address-line4-text isnull-indicator="N"/>' +
        '<city-name>Bangalore</city-name>' +
        '<state-code isnull-indicator="N">KA</state-code>' +
        '<state-name isnull-indicator="N">Karnataka</state-name>' +
        '<postal-code isnull-indicator="N">560003</postal-code>' +
        '<country-code>IN</country-code>' +
        '<country-name isnull-indicator="N">India</country-name>' +
        '<iso-country-code>IND</iso-country-code>' +
        '</physical-address>' +
        '</physical-addresses>' +
        '<engagements>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD11" engg-type-code="ENGTYPSECR">' +
        '<engg-id>10118</engg-id>' +
        '<engg-code>ISA</engg-code>' +
        '<engg-name>Intel® Internet of Things Solution Alliance</engg-name>' +
        '<tier-code>GENERAL</tier-code>' +
        '<effective-tier-code>GENERAL</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-reason-code isnull-indicator="Y" />' +
        '</engagement>' +
        '</engagements>' +
        '</account>';
    
    private static final String TEST_ERPM_PERSON_XML1 = '<?xml version="1.0" encoding="UTF-8"?>' +
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
        '</person-information>' +
        '<person-accounts>' +
        '<person-account inact-indicator="Y">' +
        '<account-number>10450334</account-number>' +
        '<cim-id isnull-indicator="N">11154430</cim-id>' +
        '<account-name>Sistemas y Servicios Erazo Cia. Ltda.</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPITP</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="ITP">' +
        '<relation-code>RELTNTRNFR</relation-code>' ;
    
    
    
    private static final String TEST_ERPM_PERSON_XML2 =  +
        '<relation-name>Trainee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' +
        '<engg-code>ITP</engg-code>' +
        '<eff-tier-cd>GOLD</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">02/22/2006 12:00:00 AM</engg-status-dtm>' +
        '</engagement>' +
        '</account-engagements>' +
        '</person-account>' +
        '<person-account inact-indicator="N">' +
        '<account-number>1000054337</account-number>' +
        '<cim-id isnull-indicator="N">REPLACE_PERSON_ACCOUNT_CIM_ID</cim-id>' +
        '<account-name>REPLACE_PERSON_ACCOUNT_NAME</account-name>' +
        '<engg_dedup_grp_cd isnull-indicator="N">DEDUPGPSCD</engg_dedup_grp_cd>' +
        '<person-account-relation inact-indicator="N" engagement-code="REPLACE_PERSON_ACCOUNT_ENGG_CODE1">' +
        '<relation-code>RELTNTRNFR</relation-code>' +
        '<relation-name>Trainee</relation-name>' +
        '<effective-end-dtm isnull-indicator="N">08/16/2016 06:29:37 PM</effective-end-dtm>' +
        '</person-account-relation>' +
        '<account-engagements>' +
        '<engagement>' ;
    
    
    
    private static final String TEST_ERPM_PERSON_XML3 =  +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE1</engg-code>' +
        '<eff-tier-cd>ACCTTIER1</eff-tier-cd>' +
        '<engg-status-dtm isnull-indicator="N">04/18/2016 06:16:40 PM</engg-status-dtm>' +
        '</engagement>' +
        '<engagement>' +
        '<engg-code>REPLACE_PERSON_ACCOUNT_ENGG_CODE2</engg-code>' +
        '<eff-tier-cd>ACCTTIER2</eff-tier-cd>' +
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
        '</person-electronic-address>' ;
    
    
    
    private static final String TEST_ERPM_PERSON_XML4 =  +
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
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD16" engg-type-code="ENGTYPSOFT">' +
        '<engg-code>REPLACE_PERSON_PERSON_ENGG_CODE2</engg-code>' +
        '<engg-name>REPLACE_PERSON_PERSON_ENGG_NAME2</engg-name>' +
        '<tier-code>MEMBER</tier-code>' +
        '<effective-tier-code>PERSONTIER2</effective-tier-code>' +
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
        '</person>';
    
    
    private static final String TEST_ERPM_ACCOUNT_XML = '<?xml version="1.0" encoding="UTF-8"?>' +
        '<account xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" test-account-indicator="N" inact-indicator="N">' +
        '<account-information>' +
        '<account-name>REPLACE_ACCT_NAME</account-name>' +
        '<account-names>' +
        '<account-name type="Alias Name" isnull-indicator="Y" />' +
        '<account-name type="Doing Business As" isnull-indicator="Y" />' +
        '<account-name type="Legal Name" isnull-indicator="N" >REPLACE_ACCT_LEGAL_NAME</account-name>' +
        '</account-names>' +
        '<account-number>REPLACE_ACCT_ERPM_NUMBER</account-number>' +
        '<engg-dedup-group-code>DEDUPB2B</engg-dedup-group-code>' +
        '<language-code>SPA</language-code>' +
        '<primary-addr-type-code>MAIL</primary-addr-type-code>' +
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
        '<electronic-address electronic-type-code="URL" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="Y" />' +
        '<electronic-address electronic-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '</electronic-addresses>' +
        '<physical-addresses>' +
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
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
        '<engg-code>REPLACE_ACCT_ENGG_CODE1</engg-code>' +
        '<engg-name>REPLACE_ACCT_ENGG_NAME1</engg-name>' +
        '<tier-code>GOLD</tier-code>' +
        '<effective-tier-code>GOLD</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-reason-code isnull-indicator="Y" />' +
        '</engagement>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD11" engg-type-code="ENGTYPSECR">' +
        '<engg-id>10118</engg-id>' +
        '<engg-code>REPLACE_ACCT_ENGG_CODE2</engg-code>' +
        '<engg-name>REPLACE_ACCT_ENGG_NAME2</engg-name>' +
        '<tier-code>GOLD</tier-code>' +
        '<effective-tier-code>GOLD</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-reason-code isnull-indicator="Y" />' +
        '</engagement>' +
        '</engagements>' +
        '</account>';
    
    // Added Nishant
    
    private static final String TEST_ERPM_ACCOUNT_XML_ACM = '<?xml version="1.0" encoding="UTF-8"?>' +
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
        '<electronic-address electronic-type-code="URL" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="Y" />' +
        '<electronic-address electronic-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '</electronic-addresses>' +
        '<physical-addresses>' +
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
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
        '<engg-code>CSPx2</engg-code>' +
        '<engg-name>General</engg-name>' +
        '<tier-code>General</tier-code>' +
        '<effective-tier-code>General</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-reason-code isnull-indicator="Y" />' +
        '</engagement>' +
        '<engagement inact-indicator="N" engg-cat-code="ENGCATCD11" engg-type-code="ENGTYPSECR">' +
        '<engg-id>10118</engg-id>' +
        '<engg-code>CSPx2</engg-code>' +
        '<engg-name>General</engg-name>' +
        '<tier-code>General</tier-code>' +
        '<effective-tier-code>General</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
        '<engg-status-reason-code isnull-indicator="Y" />' +
        '</engagement>' +
        '</engagements>' +
        '</account>';
    
    private static final String TEST_ERPM_ACCOUNT_XML_ACM_PROFILE_RESPONSES = '<?xml version="1.0" encoding="UTF-8"?>' +
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
        '<electronic-address electronic-type-code="URL" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="N" >www.bbluechip3.com</electronic-address>' +
        '<electronic-address electronic-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '</electronic-addresses>' +
        '<physical-addresses>' +
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
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
        '<engg-code>CSPx2</engg-code>' +
        '<engg-name>General</engg-name>' +
        '<tier-code>General</tier-code>' +
        '<effective-tier-code>General</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
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
        '</account>';
    
    private static final String TEST_ERPM_ACCOUNT_XML_ITP_ISA = '<?xml version="1.0" encoding="UTF-8"?>' +
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
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
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
        '</account-benefits>'+
        '</account>';
    
    private static final String TEST_ERPM_ACCOUNT_XML_ITP_ET_ODM = '<?xml version="1.0" encoding="UTF-8"?>' +
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
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
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
        '<benefit-code>BNFODMLOEM</benefit-code>'+
        '<benefit-name>ODM-LOEM</benefit-name>'+
        '<engagement-code>ITP</engagement-code>'+
        '<benefit-start-dtm>07/09/2019 12:00:00 AM</benefit-start-dtm>'+
        '<benefit-eff-end-dtm isnull-indicator="Y" />'+
        '<benefit-note-txt isnull-indicator="Y" />'+
        '<inact-ind>N</inact-ind>'+
        '<benefit-inact-reason-code isnull-indicator="Y" />'+
        '</benefit>'+
        '</account-benefits>'+
        '</account>';
    
    private static final String TEST_ERPM_ACCOUNT_XML_ITP_ET_ODM_ISA_BOTH = '<?xml version="1.0" encoding="UTF-8"?>' +
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
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
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
        '<benefit-code>BNFODMLOEM</benefit-code>'+
        '<benefit-name>ODM-LOEM</benefit-name>'+
        '<engagement-code>ITP</engagement-code>'+
        '<benefit-start-dtm>07/09/2019 12:00:00 AM</benefit-start-dtm>'+
        '<benefit-eff-end-dtm isnull-indicator="Y" />'+
        '<benefit-note-txt isnull-indicator="Y" />'+
        '<inact-ind>N</inact-ind>'+
        '<benefit-inact-reason-code isnull-indicator="Y" />'+
        '</benefit>'+
        '</account-benefits>'+
        '</account>';
    
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
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
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
    
    private static final String TEST_ERPM_ACCOUNT_XML_ITP_NoBenefit_ISA_BOTH = '<?xml version="1.0" encoding="UTF-8"?>' +
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
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
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
        '<account-benefits isnull-indicator="Y" />'+
        '</account>';
    
    private static final String TEST_ERPM_ACCOUNT_XML_ITP_ISA_Benefit = '<?xml version="1.0" encoding="UTF-8"?>' +
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
        '<electronic-address electronic-type-code="URL" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="N" >www.bbluechip6.com</electronic-address>' +
        '<electronic-address electronic-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '</electronic-addresses>' +
        '<physical-addresses>' +
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
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
        '<benefit-code>BNFODMLOEM</benefit-code>'+
        '<benefit-name>ODM-LOEM Specialty</benefit-name>'+
        '<engagement-code>ITP</engagement-code>'+
        '<benefit-start-dtm>07/09/2019 12:00:00 AM</benefit-start-dtm>'+
        '<benefit-eff-end-dtm isnull-indicator="Y" />'+
        '<benefit-note-txt isnull-indicator="Y" />'+
        '<inact-ind>N</inact-ind>'+
        '<benefit-inact-reason-code isnull-indicator="Y" />'+
        '</benefit>'+
        '</account-benefits>'+
        '</account>';
    
    private static final String TEST_ERPM_ACCOUNT_XML_ITP_ISA_No_Benefit = '<?xml version="1.0" encoding="UTF-8"?>' +
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
        '<electronic-address electronic-type-code="URL" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="N" >www.bbluechip99.com</electronic-address>' +
        '<electronic-address electronic-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '</electronic-addresses>' +
        '<physical-addresses>' +
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
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
        '<benefit-code>BNFODMLOEM</benefit-code>'+
        '<benefit-name>ODM-LOEM Specialty</benefit-name>'+
        '<engagement-code>ITP</engagement-code>'+
        '<benefit-start-dtm>07/09/2019 12:00:00 AM</benefit-start-dtm>'+
        '<benefit-eff-end-dtm isnull-indicator="Y" />'+
        '<benefit-note-txt isnull-indicator="Y" />'+
        '<inact-ind>Y</inact-ind>'+
        '<benefit-inact-reason-code isnull-indicator="Y" />'+
        '</benefit>'+
        '</account-benefits>'+
        '</account>';
    
    private static final String TEST_ERPM_ACCOUNT_XML_ACM_PROFILE_RESPONSES_Dup = '<?xml version="1.0" encoding="UTF-8"?>' +
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
        '<electronic-address electronic-type-code="URL" inact-indicator="N" preferred-indicator="N" contact-indicator="Y" location-type-code="BUS" isnull-indicator="N" >www.bbluechip3.com</electronic-address>' +
        '<electronic-address electronic-type-code="MOB" inact-indicator="N" preferred-indicator="N" contact-indicator="N" location-type-code="BUS" isnull-indicator="Y" />' +
        '</electronic-addresses>' +
        '<physical-addresses>' +
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
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
        '<engg-code>CSPx2</engg-code>' +
        '<engg-name>General</engg-name>' +
        '<tier-code>General</tier-code>' +
        '<effective-tier-code>General</effective-tier-code>' +
        '<engg-status-code>ENGSTSAPRD</engg-status-code>' +
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
        '<benefit-code>BFTMKTSTD</benefit-code>'+
        '<benefit-name>Marketing Studio</benefit-name>'+
        '<engagement-code>CSPx2</engagement-code>'+
        '<benefit-start-dtm>07/16/2019 02:05:17 AM</benefit-start-dtm>'+
        '<benefit-eff-end-dtm isnull-indicator="Y" />'+
        '<benefit-note-txt isnull-indicator="Y" />'+
        '<inact-ind>N</inact-ind>'+
        '<benefit-inact-reason-code isnull-indicator="Y" />'+
        '</benefit>'+
        '<benefit>'+
        '<benefit-code>BFTPTSVIEW</benefit-code>'+
        '<benefit-name>Points Accruals – View</benefit-name>'+
        '<engagement-code>CSPx2</engagement-code>'+
        '<benefit-start-dtm>07/16/2019 02:05:16 AM</benefit-start-dtm>'+
        '<benefit-eff-end-dtm isnull-indicator="Y" />'+
        '<benefit-note-txt isnull-indicator="Y" />'+
        '<inact-ind>N</inact-ind>'+
        '<benefit-inact-reason-code isnull-indicator="Y" />'+
        '</benefit>'+
        '<benefit>'+
        '<benefit-code>BFTSECLIB</benefit-code>'+
        '<benefit-name>Secure Content Library</benefit-name>'+
        '<engagement-code>CSPx2</engagement-code>'+
        '<benefit-start-dtm>07/16/2019 02:05:17 AM</benefit-start-dtm>'+
        '<benefit-eff-end-dtm isnull-indicator="Y" />'+
        '<benefit-note-txt isnull-indicator="Y" />'+
        '<inact-ind>N</inact-ind>'+
        '<benefit-inact-reason-code isnull-indicator="Y" />'+
        '</benefit>'+
        '<benefit>'+
        '<benefit-code>BFTTRGUNI</benefit-code>'+
        '<benefit-name>Partner University</benefit-name>'+
        '<engagement-code>CSPx2</engagement-code>'+
        '<benefit-start-dtm>07/16/2019 02:05:17 AM</benefit-start-dtm>'+
        '<benefit-eff-end-dtm isnull-indicator="Y" />'+
        '<benefit-note-txt isnull-indicator="Y" />'+
        '<inact-ind>N</inact-ind>'+
        '<benefit-inact-reason-code isnull-indicator="Y" />'+
        '</benefit>'+
        '</account-benefits>'+
        '</account>';
    private static final String TEST_ERPM_ACCOUNT_XML_ITP_ODM_ACCT = '<?xml version="1.0" encoding="UTF-8"?>' +
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
        '<physical-address address-usg-type-code="MAIL" contact-indicator="N" preferred-indicator="N" inact-indicator="N" location-type-code="" isnull-indicator="Y" />' +
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
        '<engg-id>10373</engg-id>'+
        '<engg-code>ODM-LOEM</engg-code>'+
        '<engg-name>ODM LOEM Program for solution directory</engg-name>' +
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
        '<inact-ind>Y</inact-ind>'+
        '<benefit-inact-reason-code isnull-indicator="Y" />'+
        '</benefit>'+
        '<benefit>'+
        '<benefit-code>BNFODMLOEM</benefit-code>'+
        '<benefit-name>ODM-LOEM</benefit-name>'+
        '<engagement-code>ITP</engagement-code>'+
        '<benefit-start-dtm>07/09/2019 12:00:00 AM</benefit-start-dtm>'+
        '<benefit-eff-end-dtm isnull-indicator="Y" />'+
        '<benefit-note-txt isnull-indicator="Y" />'+
        '<inact-ind>Y</inact-ind>'+
        '<benefit-inact-reason-code isnull-indicator="Y" />'+
        '</benefit>'+
        '</account-benefits>'+
        '</account>';
    
}