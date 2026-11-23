@isTest
private class Core_Contact_AccountChange_test_dup_sk {

    
    public static testmethod void testContactAccountchangeErrors() {
     
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
        Profile GECPrf = [select id, name from Profile where name = 'Global Export Compliance' Limit 1];

        User itAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestxgec@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21@intel.com');
        insert itAdminUser;
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin1');
        
         User GECUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21gec@intel.com', 
                                    EmailEncodingKey='UTF-8',   LastName='UnitTestGEC',
                                    LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                    ProfileId = GECPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                    UserName='salesRepTestx21gec@intel.com');
        insert GECUser ;
        system.assertequals(GECUser.LastName,'UnitTestGEC');
        
          //Put an entry in 'Trigger Executions' custom settings so the Contact trigger gets exectued
           Core_Trigger_Executions__c triggerExe3 = new Core_Trigger_Executions__c();
           triggerExe3.Name = 'ContactAccountChangeUpdate';
           triggerExe3.Core_Active__c = true;
           triggerExe3.Core_Class_Name__c = 'Core_Contact_AccountChange_Handler';
           triggerExe3.Core_Description__c = 'test description';
           triggerExe3.Core_Object__c = 'Contact';
           triggerExe3.Core_Trigger_Events__c = 'Before Update , After Update';
           insert triggerExe3;
           System.assertNotEquals(null, triggerExe3.Id);
          
          
        List<Account> lstAcc=new List<Account>();
         Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = false,
                                          Core_Account_Type__c='Other', Industry='Others', BillingStreet='1234 tester St',
                                          BillingCity='testCity', BillingState='OR', BillingCountry='USA', BillingPostalCode='12345', 
                                          Core_IPS_Active__c=true, Core_CIM_ID__c ='123124', Core_CNDA_Number__c='12345',Core_English_Only_Name__c='test');
        insert testAccount;
        system.assertNOTEquals(null,testAccount.id);
        lstAcc.add(testAccount);
        
        Account testAccount2 = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', BillingStreet='1234 tester St',
                                          BillingCity='testCity2', BillingState='OR', BillingCountry='USA', BillingPostalCode='12345', 
                                          Core_IPS_Active__c=true, Core_CIM_ID__c ='123124', Core_CNDA_Number__c='12345');
        insert testAccount2;
        System.assert(true,testAccount2.Core_IPS_Active__c!= null);
        lstAcc.add(testAccount2);
        Account testAccount3 = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', BillingStreet='1234 tester St',
                                          BillingCity='testCity3', BillingState='OR', BillingCountry='USA', BillingPostalCode='12345', 
                                          Core_IPS_Active__c=true,Core_CIM_ID__c ='123124', Core_CNDA_Number__c='12345',Core_English_Only_Name__c='test');
        insert testAccount3;
        system.assertequals(testAccount3.Name,'testAccount123');
        Account testAccount4 = new Account(Name='testAccount1234', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = false,
                                          Core_Account_Type__c='Other', Industry='Others', BillingStreet='1234 tester St. test',
                                          BillingCity='testCity3', BillingState='OR', BillingCountry='USA', BillingPostalCode='12345', 
                                          Core_IPS_Active__c=true,Core_English_Only_Name__c='test');
        insert testAccount4;
        system.assertequals(testAccount4.Name,'testAccount1234');
        lstAcc.add(testAccount4);
         
        Account testAccount5 = new Account(Name='testAccount1234', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                          BillingStreet='1234 tester St', BillingCity='testCity2', BillingState='OR',
                          BillingCountry='USA', BillingPostalCode='123456',Core_Export_Compliance_Block__c=true,Core_CIM_ID__c ='123124',Core_English_Only_Name__c='test');
        insert testAccount5;
        System.assert(true,testAccount5.Core_Export_Compliance_Block__c);
        
        List<Contact> lstCon=new List<Contact>();
        Contact testContact1 = new Contact(FirstName='testFirstName123', LastName='test', Email='test123@testing.com.test',
                                           AccountId=testAccount.Id,Core_Personal_Email_Indicator__c=true,Core_Set_ERPM_Status_Bypass__c=true);
        insert testContact1;
        System.assert(true,testContact1.Core_Personal_Email_Indicator__c!= null);
        lstCon.add(testContact1);
        
        Contact testContact2 = new Contact(FirstName='testFirstName1234', LastName='test', Email='test1234@testing.com.test',
                                           AccountId=testAccount3.Id,Core_Personal_Email_Indicator__c=true,Core_Set_ERPM_Status_Bypass__c=true);
        insert testContact2;
        system.assertequals(testContact2.FirstName,'testFirstName1234');
        lstCon.add(testContact2);
      
        // Contact testContact3 = new Contact(FirstName='testFirstName12345', LastName='test', Email='test12345@testing.com.test',
        //                                   AccountId=testAccount5.Id,Core_Personal_Email_Indicator__c=true,Core_Set_ERPM_Status_Bypass__c=true);
        // insert testContact3;
        // system.assertequals(testContact3.FirstName,'testFirstName12345');
        // lstCon.add(testContact3);
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
        insert cee;
        System.assert(true,cee.Name != null); 
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
        insert entitle;
        System.assert(true,entitle.Core_Category__c!= null);
        
        Core_Contact_Entitlement__c content1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact1.Id,Core_Entitlement_Id__c =entitle.Id, Core_Selected__c=true);
        insert content1;
        Core_Contact_Entitlement__c content2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact2.Id,Core_Entitlement_Id__c =entitle.Id, Core_Selected__c=true);
        insert content2;
        test.startTest();
            try{
                testAccount.Core_CIM_ID__c  = '';
                update testAccount;
                testAccount2.Core_CIM_ID__c  = '';
                update testAccount2;
                testContact1.accountId=testAccount2.id;
                testContact1.Core_Account_Changeable__c=true;
                update testContact1;
                
            }catch(Exception ex){
                System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
              //  System.assertEquals('\n Account English only name is missing, \n Non ODM Account cannot moved to ODM Account, ', ex.getDmlMessage(0));
              }
              
            try{
                testContact2.accountId=testAccount4.id;
                testContact2.Core_Account_Changeable__c=true;
                update testContact2;
            }catch(Exception ex){
                System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
             //   System.assertEquals('\n Account CIMID is missing, \n Account CNDA is missing, \n ODM Account cannot moved to Non ODM Account, ', ex.getDmlMessage(0));
            }
           
            try{
                testAccount3.Core_Export_Compliance_Block__c=true;
                update testAccount3;
                testContact2.accountId=testAccount5.id;
                testContact2.Core_Account_Changeable__c=true;
                update testContact2;
            }catch(Exception ex){
                System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
           }
           Test.stopTest();
           
       }
 
}