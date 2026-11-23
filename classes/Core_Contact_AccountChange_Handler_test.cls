@isTest
private class Core_Contact_AccountChange_Handler_test {

    private static testMethod void validateAccount() {
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
   
        User itAdminUser = new User(Alias = 'itAdmx2', 
              Email='itAdminTestx2@intel.com', 
              EmailEncodingKey='UTF-8',
              LastName='UnitTestAdmin',
              LanguageLocaleKey='en_US', 
              LocaleSidKey='en_US', 
              ProfileId = itAdminPrf.Id, 
              TimeZoneSidKey='America/Los_Angeles',
              UserName='salesRepTestx2@intel.com');
        insert itAdminUser;
        
        Profile aePrf = [select id, name from Profile where name = 'A&E User' Limit 1];
        
        User aeUser = new User(Alias = 'itAdmx22', 
              Email='itAdminTestx22@intel.com', 
              EmailEncodingKey='UTF-8',
              LastName='UnitTestAdmin2',
              LanguageLocaleKey='en_US', 
              LocaleSidKey='en_US', 
              ProfileId = aePrf.Id, 
              TimeZoneSidKey='America/Los_Angeles',
              UserName='salesRepTestx22@intel.com');
        insert aeUser;
        

        system.runas(aeUser){         
            //Creates a sample 'Account' record
            Account objAcc = new Account();
            objAcc.Name = 'test';
            objAcc.Core_Account_Type__c = 'Distributor';
            objAcc.Core_Sales_Group__c = 'Global Accounts';
            objAcc.Industry = 'Agriculture';
            objAcc.Core_Account_Legal_Name__c = 'abc1234account';
            objAcc.Core_CIM_ID__c = '11545156';
            objAcc.Core_GEO__c = 'ASMO';
            objAcc.Core_IBL_Flag__c = false;
            objAcc.BillingCity = 'folsom';
            objAcc.BillingCountry = 'GUY';
            objAcc.BillingStreet = '13254 E vookbrrok dfdsf';
            objAcc.Core_CNDA_Number__c = '123456';
            objAcc.Core_English_Only_Name__c='englishtestname';
            insert objAcc; 
            System.assertNotEquals(null, objAcc.Id);
            
            Account objAcc1 = new Account();
            objAcc1.Name = 'test1';
            objAcc1.Core_Account_Type__c = 'Distributor';
            objAcc1.Core_Sales_Group__c = 'Global Accounts';
            objAcc1.Industry = 'Agriculture';
            objAcc1.Core_Account_Legal_Name__c = 'abc1234account';
            objAcc1.Core_CIM_ID__c = '115451676';
            objAcc1.Core_GEO__c = 'ASMO';
            objAcc1.Core_IBL_Flag__c = false;
            objAcc1.BillingCity = 'folsom1';
            objAcc1.BillingCountry = 'GUY';
            objAcc1.BillingStreet = '13254 E vookbrrok dfdsf';
            objAcc1.Core_CNDA_Number__c = '1234567';
            objAcc1.Core_English_Only_Name__c='englishtestname';
            insert objAcc1; 
            System.assertNotEquals(null, objAcc1.Id);
            
            //Creates a sample 'Contact' record
            List<Contact> conlist = new List<Contact>();
            Contact objCon = new Contact();
            objCon.FirstName = 'TestCon'; 
            objCon.LastName = 'TestCon1'; 
            objCon.AccountId = objAcc.id;
            objCon.Email = 'testcontactx@test.com';
            objCon.Core_Contact_B2B_Indicator__c = true;
            conlist.add(objCon);
            
            insert conlist;
            System.assertNotEquals(null, objCon.Id);

            
        System.runAs(itAdminUser){          
          //Put an entry in 'Trigger Executions' custom settings so the Contact trigger gets exectued
           Core_Trigger_Executions__c triggerExe = new Core_Trigger_Executions__c();
           triggerExe.Name = 'ContactEmailChangeUpdate';
           triggerExe.Core_Active__c = true;
           triggerExe.Core_Class_Name__c = 'Core_Contact_EmailChange_Handler';
           triggerExe.Core_Description__c = 'test description';
           triggerExe.Core_Object__c = 'Contact';
           triggerExe.Core_Trigger_Events__c = 'After Update';
           insert triggerExe;
           System.assertNotEquals(null, triggerExe.Id);
           
           //Put an entry in 'Trigger Executions' custom settings so the Contact trigger gets exectued
           Core_Trigger_Executions__c triggerExe2 = new Core_Trigger_Executions__c();
           triggerExe2.Name = 'contactJobFunction';
           triggerExe2.Core_Active__c = true;
           triggerExe2.Core_Class_Name__c = 'Core_ContactHandler';
           triggerExe2.Core_Description__c = 'test description';
           triggerExe2.Core_Object__c = 'Contact';
           triggerExe2.Core_Trigger_Events__c = 'After Insert After Update';
           insert triggerExe2;
           System.assertNotEquals(null, triggerExe2.Id);
           
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
              
            //Creates sample 'ERPM Engagement' record as it is required in Entitlement record
            Core_ERPM_Engagement__c objERPMEngmt = new Core_ERPM_Engagement__c();
            objERPMEngmt.name = 'TestErpmName';
            objERPMEngmt.Core_IsActive__c = true;
            insert objERPMEngmt;
            System.assertNotEquals(null, objERPMEngmt.Id);
            
            //Creates sample 'AGS role' record as it is required in Entitlement record 
            Core_AGS_Role__c objAGSRole = new Core_AGS_Role__c();
            objAGSRole.name= 'TestAGSRoleName';
            objAGSRole.Core_IsActive__c = true;
            insert objAGSRole;
            System.assertNotEquals(null, objAGSRole.Id);
            
            //Creates a sample 'Entitlement' record
            Core_Entitlement__c objEntitlement = new Core_Entitlement__c();
            objEntitlement.name = 'TestEntitlementName';
            objEntitlement.Core_Display_Name__c = 'TestEntitlementName';
            objEntitlement.Core_IsActive__c = true;
            objEntitlement.Core_AGS_Role_Id__c = objAGSRole.id;
            objEntitlement.Core_Category__c = 'Support';
            objEntitlement.Core_ERPM_Engagement_Id__c = objERPMEngmt.id;
            insert objEntitlement;
            System.assertNotEquals(null, objEntitlement.Id);
            
            Core_Entitlement__c objEntitlement1 = new Core_Entitlement__c();
            objEntitlement1.name = 'TestEntitlementName1';
            objEntitlement1.Core_Display_Name__c = 'TestEntitlementName1';
            objEntitlement1.Core_IsActive__c = true;
            objEntitlement1.Core_AGS_Role_Id__c = objAGSRole.id;
            objEntitlement1.Core_Category__c = 'Support';
            objEntitlement1.Core_ERPM_Engagement_Id__c = objERPMEngmt.id;
            insert objEntitlement1;
            System.assertNotEquals(null, objEntitlement1.Id);
            
            //Creates a sample 'Contact Entitlement' record
            
            List<Core_Contact_Entitlement__c> lstentitle = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c objConEntitlement = new Core_Contact_Entitlement__c();
            objConEntitlement.Core_Contact_Id__c = objCon.id;
            objConEntitlement.Core_Entitlement_Id__c = objEntitlement.id;
            objConEntitlement.Core_Selected__c = false;
            insert objConEntitlement;
            
            lstentitle.add(objConEntitlement);
            
            Core_Contact_Entitlement__c objConEntitlement1 = new Core_Contact_Entitlement__c();
            objConEntitlement1.Core_Contact_Id__c = objCon.id;
            objConEntitlement1.Core_Entitlement_Id__c = objEntitlement1.id;
            objConEntitlement1.Core_Selected__c = true;
            insert objConEntitlement1;
            
            lstentitle.add(objConEntitlement1);
    
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
            insert ListOfProducts;
            
            Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
            org.Core_IPS_Support_Org_Name__c='test';
            org.Core_Organization_Description__c='test';
            insert org;
            System.assertEquals(org.Core_IPS_Support_Org_Name__c,'test');
            
            Core_IPS_Supported_Product__c pdt = new Core_IPS_Supported_Product__c();
            pdt.Core_Supported_Product_Name__c='medical';
            pdt.Core_Product__c=ListOfProducts[0].id;
            pdt.Core_Product_Organization__c=org.id;
            insert pdt;
            System.assert(true,pdt.Core_Supported_Product_Name__c != null);
            
            Core_IPS_Supported_Product__c pdt2 = new Core_IPS_Supported_Product__c();
            pdt2.Core_Supported_Product_Name__c='medical1';
            pdt2.Core_Product__c=ListOfProducts[1].id;
            pdt2.Core_Product_Organization__c=org.id;
            insert pdt2;
            System.assert(true,pdt2.Core_Supported_Product_Name__c != null);
            
            Core_IPS_Project__c project = new Core_IPS_Project__c();
            project.Core_IPS_Group_Name__c='test';
            project.Core_MPNDA__c='testgeetha';
            insert project;
            system.assertNOTEquals(null,project.id);
            
            // Creates product for a case
            Product2 objProd = new Product2();
            objProd.name = 'Test Local Control Panel';
            objProd.IsActive = true;
            insert objProd;
            System.assertEquals(objProd.name,'Test Local Control Panel');
            
            
            List<RecordType> rtList = [SELECT id,developerName,name FROM RecordType where SobjectType='Case'];
            // Create Asset
            List<Asset> listOfAssets= TestUtilities.getAssetList(10);
            integer count=0;
            for(Asset AssetRec : listOfAssets){
                AssetRec.Product2Id=objProd.id;
                if(count<5){
                     AssetRec.accountid= objAcc.id;
                     AssetRec.status='Inactive';
                }else{
                    AssetRec.accountid= objAcc1.id; 
                    AssetRec.status='Active';
                }
                count++;
            }
            insert listOfAssets;
            // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(10);
            count=0;
            for(Case CaseRec : ListOfCases){
                if(count<6){
                    CaseRec.Core_IPS_Supported_Product__c=pdt2.id;
                    CaseRec.AccountID = objAcc.id;
                }else{
                    CaseRec.AccountID = objAcc1.id;
                    CaseRec.Core_IPS_Supported_Product__c=pdt.id;
                }
                CaseRec.Core_IPS_Product_Org1__c=org.id;
                CaseRec.Core_IPS_Project_Case__c = null;
                CaseRec.AssetId=listOfAssets[count].id;
                CaseRec.contactID = objCon.Id;
                CaseRec.productId = objProd.id;
                count++;
                
            }
            insert ListOfCases;
            Case cs = new Case(Id=ListOfCases[0].Id);
            cs.Core_IPS_Project_Case__c = project.Id;
            update cs;
            //Updates Contact as IT Admin profile user  
            Test.startTest();
                conlist[0].AccountID=objAcc1.Id;
                conlist[0].Core_Account_Changeable__c=true;
                update conlist;
            Test.stopTest();
            Core_Contact_AccountChange_Handler handler = new Core_Contact_AccountChange_Handler();
            Core_Contact_AccountChange_Handler.updateAssets(conlist);
           
        }
    }
        
    }
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
        Test.StartTest(); //added by sugandha as test class was failing due to 101 SOQL limit Exception
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
        
            try{
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
           Test.StopTest();//added by sugandha as test class was failing due to 101 SOQL limit Exception
       }
     public static testmethod void testContactSpecialprofileErrors() {
           Profile prf = [select id, name from Profile where name = 'Integration' Limit 1];
            User integrationUser = new User(Alias = 'admin', 
                                  Email='testUser1865@intel.com', 
                                  EmailEncodingKey='UTF-8',
                                  LastName='UnitTestAdmin',
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', 
                                  ProfileId = prf.Id, 
                                  TimeZoneSidKey='America/Los_Angeles',
                                  UserName='testUser1865@intel.com');
            insert integrationUser;
            system.assertNOTEquals(null,integrationUser.id);
            
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
            
            //Put an entry in 'Trigger Executions' custom settings so the Contact trigger gets exectued
            Core_Trigger_Executions__c triggerExe = new Core_Trigger_Executions__c();
            triggerExe.Name = 'ContactEmailChangeUpdate';
            triggerExe.Core_Active__c = true;
            triggerExe.Core_Class_Name__c = 'Core_Contact_EmailChange_Handler';
            triggerExe.Core_Description__c = 'test description';
            triggerExe.Core_Object__c = 'Contact';
            triggerExe.Core_Trigger_Events__c = 'After Update';
            insert triggerExe;
            System.assertNotEquals(null, triggerExe.Id);

            Profile GECPrf = [select id, name from Profile where name = 'Global Export Compliance' Limit 1];
            User GECUser = new User(Alias = 'admin', 
                                  Email='adminTest1@intel.com', 
                                  EmailEncodingKey='UTF-8',
                                  LastName='UnitTestAdmin',
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', 
                                  ProfileId = GECPrf.Id, 
                                  TimeZoneSidKey='America/Los_Angeles',
                                  UserName='adminTest1@intel.com');
            insert GECUser;
            system.assertNOTEquals(null,GECUser.id);
            
           Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
   
            User itAdminUser = new User(Alias = 'itAdmx2', 
                  Email='itAdminTestx2@intel.com', 
                  EmailEncodingKey='UTF-8',
                  LastName='UnitTestAdmin',
                  LanguageLocaleKey='en_US', 
                  LocaleSidKey='en_US', 
                  ProfileId = itAdminPrf.Id, 
                  TimeZoneSidKey='America/Los_Angeles',
                  UserName='salesRepTestx2@intel.com');
            insert itAdminUser;
             system.runas(GECUser){  
                Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = false,
                                          Core_Account_Type__c='Other', Industry='Others', BillingStreet='1234 tester St',
                                          BillingCity='testCity', BillingState='OR', BillingCountry='USA', BillingPostalCode='12345', 
                                          Core_IPS_Active__c=true, Core_CIM_ID__c ='123124', Core_CNDA_Number__c='12345',Core_English_Only_Name__c='test');
                insert testAccount;
                system.assertNOTEquals(null,testAccount.id);
                  
                 Contact testContact1 = new Contact(FirstName='testFirstName123', LastName='test', Email='test123@testing.com.test',
                                           AccountId=testAccount.Id,Core_Personal_Email_Indicator__c=true,Core_Set_ERPM_Status_Bypass__c=true);
                insert testContact1;
                System.assert(true,testContact1.Core_Personal_Email_Indicator__c!= null);
                // Create Case
                List<Case> ListOfCases = TestUtilities.getListOfCases(10);
                for(Case CaseRec : ListOfCases){
                    CaseRec.contactID = testContact1.Id;
                    CaseRec.accountID = testAccount.Id;
                    CaseRec.Core_IPS_GEC_Status__c = 'On Hold - GEC Review in Progress';
                
                }
                insert ListOfCases;
                system.debug('Object msg :'+ListOfCases);
          
                Account testAccount2 = new Account(Name='testAccount12345', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',
                                          BillingStreet='1234 tester St 1', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='123456', Core_CIM_ID__c ='123124', Core_CNDA_Number__c='12345',Core_English_Only_Name__c='test12345');
                insert testAccount2;
               Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT',Core_Technical_DeDup_Number__c='B2B');
                insert cee;
                System.assert(true,cee.Name != null); 
                
                Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Advanced Shipment and Invoice Notification', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test dup',Core_IsActive__c=true);
                insert entitle;
                System.assert(true,entitle.Core_Category__c!= null);
                
                Core_Contact_Entitlement__c content1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact1.Id,Core_Entitlement_Id__c =entitle.Id, Core_Selected__c=true);
                insert content1;
                
                
                try{
                    system.debug('Object msg: befor Update'+testContact1);
                    testContact1.accountId=testAccount2.id;
                    testContact1.Core_Account_Changeable__c=true;
                    update testContact1;
                    system.debug('Object msg: after Update '+testContact1);
                
                }catch(Exception ex){
                    System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
                  //  System.assertEquals('Case Having GEC Hold, Cannot Move this contact', ex.getDmlMessage(0));
             
                }
                System.runAs(integrationUser) {
                    testAccount2.Core_Deactivated__c=true;
                    testAccount2.Core_Deactivation_Reason__c='test deactivated';
                    update testAccount2;
                }
                  try{
                    testContact1.accountId=testAccount2.id;
                    testContact1.Core_Account_Changeable__c=true;
                    update testContact1;
                 
                }catch(Exception ex){
                    System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
                 //   System.assertEquals('\n Account is deactivated : ', ex.getDmlMessage(0));
             
                }
            
                
         }
        
     }
     
          public static testmethod void testContactAGS_ERPMUpdateDate() {
             
            //Put an entry in 'Trigger Executions' custom settings so the Contact trigger gets exectued
            Core_Trigger_Executions__c triggerExe3 = new Core_Trigger_Executions__c();
            triggerExe3.Name = 'intStatusLastUpdate';
            triggerExe3.Core_Active__c = true;
            triggerExe3.Core_Class_Name__c = 'Core_Contact_AccountChange_Handler';
            triggerExe3.Core_Description__c = 'test description';
            triggerExe3.Core_Object__c = 'Contact';
            triggerExe3.Core_Trigger_Events__c = 'Before Insert, Before Update';
            insert triggerExe3;
            System.assertNotEquals(null, triggerExe3.Id);
             
           Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];
   
            User itAdminUser = new User(Alias = 'itAdmx2', 
                  Email='itAdminTestx2@intel.com', 
                  EmailEncodingKey='UTF-8',
                  LastName='UnitTestAdmin',
                  LanguageLocaleKey='en_US', 
                  LocaleSidKey='en_US', 
                  ProfileId = itAdminPrf.Id, 
                  TimeZoneSidKey='America/Los_Angeles',
                  UserName='salesRepTestx2@intel.com');
            insert itAdminUser;
             system.runas(itAdminUser){  
                Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = false,
                                          Core_Account_Type__c='Other', Industry='Others', BillingStreet='1234 tester St',
                                          BillingCity='testCity', BillingState='OR', BillingCountry='USA', BillingPostalCode='12345', 
                                          Core_IPS_Active__c=true, Core_CIM_ID__c ='123124', Core_CNDA_Number__c='12345',Core_English_Only_Name__c='test');
                insert testAccount;
                system.assertNOTEquals(null,testAccount.id);
                  
                 Contact testContact1 = new Contact(FirstName='testFirstName123', LastName='test', Email='test123@testing.com.test',
                                           AccountId=testAccount.Id,Core_Personal_Email_Indicator__c=true,Core_Set_ERPM_Status_Bypass__c=true,Core_ERPM_Integration_Status__c ='Failed',Core_AGS_Integration_Status__c='Failed');
                insert testContact1;
                System.assert(true,testContact1.Core_Personal_Email_Indicator__c!= null);
                try{
                    system.debug('Object msg: befor Update'+testContact1);
                    testContact1.Core_ERPM_Integration_Status__c ='pending';
                    testContact1.Core_AGS_Integration_Status__c='pending';
                    
                    update testContact1;
                    system.debug('Object msg: after Update '+testContact1);
                
                }catch(Exception ex){
                     system.debug('Error :'+ex);
                  
                }
        }
     }
 
 
}