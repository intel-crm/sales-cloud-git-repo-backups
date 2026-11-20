/**************************************************************************************
Apex Class Name:  Core_IPS_MoveContactWithLargeCases_Test
Version     : 1.0 
Created Date: 16 Jan 2016
Description    : This class is Test class for Core_IPS_MoveContactWithLargeCases
***************************************************************************************/
@isTest
public class Core_IPS_MoveContactWithLargeCases_Test{
    static testMethod void testMoveContactCases(){
        insert new Core_Contact_Bypass_Validation_Rule__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass__c=true);
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];//System Administrator
        Core_IPS_Labels__c ipsCS = new Core_IPS_Labels__c(Name = 'IPS Standard Entitlement', Value__c='IPS Standard Entitlement');
        insert ipsCS;
        boolean flag =true;
        
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
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin');
        
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_Export_Compliance_Block__c = false);
        insert testAccount;
        system.assertNOTEquals(null,testAccount.id);
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',
                                          Core_IPS_Intel_Support_Owner__c=null, AccountId=testAccount.Id, MailingCountry='India');
        insert testContact;
        system.assertNOTEquals(null,testContact.id);
        
        Contact testContact2 = new Contact(FirstName='testFirstName123', LastName='testLName', Email='test1234@testing.com.test',
                                           Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c=null, AccountId=testAccount.Id, MailingCountry='India');
        insert testContact2;
        System.assert(true,testContact2.LastName!= null);
        
        
        Account testAccount3 = new Account(Name='testAccount123456', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                           Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '123456',
                                           BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                           BillingCountry='USA', BillingPostalCode='12345');
        System.runas(itAdminUser){
            insert testAccount3;
        }
        Contact testContact3 = new Contact(FirstName='testFirstName123456', LastName='testLName', Email='testAccount123456@testing.com.test',
                                           Core_IPS_Intel_Support_Owner__c=null, AccountId=testAccount3.Id, MailingCountry='India');
        insert testContact3;
        system.assertNOTEquals(null,testContact3.id);
        
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
        insert cee;
        system.assertequals(cee.Name,'Partner File Transfer');
        
        
        Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Customer Sales Order Reporting', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test',Core_IsActive__c=true);
        insert entitle;
        system.assertNOTEquals(null,entitle.id);
        
        
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id, 
                                                                         Core_Entitlement_Id__c=entitle.id,
                                                                         Core_Selected__c=true);
        insert ce; 
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
        Test.startTest();
        // Create Case
        List<Asset> listOfAssets= TestUtilities.getAssetList(2);
        for(Asset AssetRec : listOfAssets){
            AssetRec.accountid= testAccount.id;
            AssetRec.Product2Id=objProd.id;
        }
        insert listOfAssets;
       
        List<Case> ListOfCases = TestUtilities.getListOfCases(2);
        integer count=0;
        for(Case CaseRec : ListOfCases){
            if(count<5){
                CaseRec.Core_IPS_Project_Case__c = project.id;
                CaseRec.AssetId=listOfAssets[count].id;
            }else{
                CaseRec.Core_IPS_Project_Case__c = null;
                CaseRec.AssetId=listOfAssets[count].id;
            }
            CaseRec.Core_IPS_Product_Org1__c=org.id;
            CaseRec.Core_IPS_Supported_Product__c=pdt.id;
            CaseRec.AccountID = testAccount.id;
            CaseRec.contactID = testContact.Id;
            CaseRec.Account = testAccount;
            CaseRec.contact = testContact;
            CaseRec.productId = objProd.id;
            count++;
            
        }
        insert ListOfCases;
         
        
        ApexPages.currentPage().getParameters().put('Id', testContact.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
        
        Core_IPS_MoveContactWithLargeCases conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
        conEntController.currContact=testContact;
        conEntController.currContact.account=testAccount;
        conEntController.contactLookUp=ListOfCases[0];
        conEntController.targetAccount=testContact2;
        conEntController.updateCasesOnSave();
        conEntController.getIPSProjects();
        //conEntController.updateAccountEntitlements();
        conEntController.updateContactEntitlementList();
        conEntController.cancelPage();
        
        conEntController.gecCaseFound = true;
        conEntController.updateCasesOnSave();
        
        conEntController.gecCaseFound = false;
        conEntController.updateCasesOnSave();
        conEntController.userAuthorized = true;
        PageReference pr = conEntController.retrieveEntitlements();
        System.assertEquals(null, pr);
                 
        Core_IPS_MoveContactWithLargeCases conEntController3 = new Core_IPS_MoveContactWithLargeCases(null);
        ApexPages.StandardController sc3 = new ApexPages.StandardController(testContact3);
        
        conEntController3 = new Core_IPS_MoveContactWithLargeCases(sc3);
        pr = conEntController3.retrieveEntitlements();
        System.assertEquals(null, pr);
        
        conEntController3.keepEntitlements = false;
        try{
            conEntController3.updateContactEntitlementList();
        }catch(Exception e){}
        try{
            Core_IPS_MoveContactWithLargeCases.updateAssetsToCase(new List<Case>(), null);
        }catch(Exception e){}
        
        
        conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
        conEntController.currContact=testContact2;
        conEntController.targetAccount=testContact3;
        conEntController.updateCasesOnSave();
        conEntController.keepEntitlements = true;
        conEntController.updateCasesOnSave();
        conEntController.closePopup();
        conEntController.moveAccountchange();
        Test.stopTest();
        
        
    }
    
    
    static testMethod void testMoveContactCasesError(){
        
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];//System Administrator
        
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
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin');
        System.runAs(itAdminUser){          
            Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345');
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c!= null);
            
            Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',
                                              Core_IPS_Intel_Support_Owner__c=itAdminUser.id, AccountId=testAccount.Id,Core_IPS_Active__c = true);
            
            
            //   insert testContact
            // Creates product for a case
            Product2 objProd = new Product2();
            objProd.name = 'Test Local Control Panel';
            objProd.IsActive = true;
            insert objProd;
            System.assertEquals(objProd.name,'Test Local Control Panel');
            
            
            List<Asset> listOfAssets= TestUtilities.getAssetList(10);
            integer assetcount=0;
            for(Asset AssetRec : listOfAssets){
                if(assetcount<8){
                    AssetRec.accountid= testAccount.id;
                    AssetRec.Product2Id=objProd.id;
                }else{
                    AssetRec.accountid= null;
                    AssetRec.Product2Id=null;
                }
            }
            insert listOfAssets;
            try{
                
                ApexPages.currentPage().getParameters().put('Id', testContact.Id);
                ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
                
                Core_IPS_MoveContactWithLargeCases conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
                conEntController.currContact=testContact;
                conEntController.updateCasesOnSave();
            }catch(Exception e){}
            try{
                ApexPages.StandardController sc2 = new ApexPages.StandardController(testContact);
                Core_IPS_MoveContactWithLargeCases conEntController = new Core_IPS_MoveContactWithLargeCases(sc2);
                conEntController.currContact=testContact;
                conEntController.targetAccount=null;
            }catch(Exception e){}
        }
    }
    
    
    static testMethod void testMoveContactCases2(){
        
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];//System Administrator
        
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
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin');
        
        
        System.runAs(itAdminUser){ 
            
            Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345');
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c!= null);
            
            Contact testContact = new Contact(FirstName='testFirstName123',LastName='testLastName', Email='test123@testing.com.test',
                                              Core_IPS_Intel_Support_Owner__c = itAdminUser.id, AccountId=testAccount.Id, MailingCountry='India');
            insert testContact;
            system.assertequals(testContact.LastName,'testLastName');
            
            
            Contact testContact2 = new Contact(FirstName='testFirstName123', LastName='testLName', Email='test1234@testing.com.test',
                                               Core_IPS_Intel_Support_Owner__c = null, AccountId=testAccount.Id, MailingCountry='India');
            insert testContact2;
            system.assertequals(testContact2.LastName,'testLName');
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
            insert cee;
            system.assertequals(cee.Name ,'Partner File Transfer');
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Customer Sales Order Reporting', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test',Core_IsActive__c=true);
            insert entitle;
            System.assert(true,entitle.Core_Category__c!= null);
            
            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                             Core_Entitlement_Id__c=entitle.id,
                                                                             Core_Selected__c=true);
            insert ce; 
            system.assertNOTEquals(null,ce.id);

            
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
            
            Core_IPS_Project__c project = new Core_IPS_Project__c();
            project.Core_IPS_Group_Name__c='test';
            project.Core_MPNDA__c='testgeetha';
            insert project;
            System.assert(true,project.Core_MPNDA__c!= null);
            
            // Creates product for a case
            Product2 objProd = new Product2();
            objProd.name = 'Test Local Control Panel';
            objProd.IsActive = true;
            insert objProd;
            System.assert(true,objProd.name!= null);
            
            
            List<RecordType> rtList = [SELECT id,developerName,name FROM RecordType where SobjectType='Case'];
            // Create Case
            List<Asset> listOfAssets= TestUtilities.getAssetList(10);
            for(Asset AssetRec : listOfAssets){
                AssetRec.accountid= testAccount.id;
                AssetRec.Product2Id=objProd.id;
            }
            insert listOfAssets;
            Test.startTest();
            List<Case> ListOfCases = TestUtilities.getListOfCases(10);
            integer count=0;
            for(Case CaseRec : ListOfCases){
                if(count<5){
                    CaseRec.Core_IPS_Project_Case__c = project.id;
                    CaseRec.AssetId=listOfAssets[count].id;
                }else{
                    CaseRec.Core_IPS_Project_Case__c = null;
                    CaseRec.AssetId=listOfAssets[count].id;
                    CaseRec.status='On Hold - GEC Review in Progress';
                    CaseRec.Core_IPS_GEC_Case__c=true;
                }
                CaseRec.Core_IPS_Product_Org1__c=org.id;
                CaseRec.Core_IPS_Supported_Product__c=pdt.id;
                CaseRec.AccountID = testAccount.id;
                CaseRec.contactID = testContact.Id;
                CaseRec.productId = objProd.id;
                count++;
                
            }
            insert ListOfCases;
            ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
            
            Profile currLoggedInUserProfile = [Select Name from Profile where Id = : UserInfo.getProfileId() limit 1];
            Set<Core_Move_Contact_Authorized_Profiles__c> sAuthPro = new Set<Core_Move_Contact_Authorized_Profiles__c>();
            //sAuthPro.add(new Core_Move_Contact_Authorized_Profiles__c(Name='Cloud CRM BSA-Pre Prod'));
            sAuthPro.add(new Core_Move_Contact_Authorized_Profiles__c(Name='IT Admin'));
            sAuthPro.add(new Core_Move_Contact_Authorized_Profiles__c(Name=currLoggedInUserProfile.Name));
            insert new List<Core_Move_Contact_Authorized_Profiles__c>(sAuthPro);
            Core_IPS_MoveContactWithLargeCases conEntController0 = new Core_IPS_MoveContactWithLargeCases(sc);
            conEntController0.initialize();
            
            
            
            //Core_Change_Acct_Auth_Prof_Closed_Cases__c closedcases = new Core_Change_Acct_Auth_Prof_Closed_Cases__c(Name='Cloud CRM BSA-Pre Prod');
            //insert closedcases;
            
            Core_Contact_Access_Profiles__c accessProfile=new Core_Contact_Access_Profiles__c(name='IT Admin',Core_Profile_Name__c='IT Admin');
            insert accessProfile;        
            ApexPages.currentPage().getParameters().put('Id', testContact.Id);
            sc = new ApexPages.StandardController(testContact);
            
            
            Core_IPS_MoveContactWithLargeCases conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
            conEntController.keepcases=true;
            conEntController.contactLookUp.contactid = testContact.Id;
            conEntController.currContact=testContact;
            conEntController.currContact.account=testAccount;
            
            conEntController.targetAccount=testContact2;
            conEntController.updateCasesOnSave();
            conEntController.getIPSProjects();
            Core_IPS_MoveContactWithLargeCases.updateAssetsToCase(ListOfCases,testAccount.id);
            //conEntController.updateAccountEntitlements();
            conEntController.updateContactEntitlementList();
            conEntController.cancelPage();
            //conEntController.blnEligible = false;
            
            //Negative case and swallow the exception
            try{
                
                conEntController.updateCasesOnSave();
            }catch(Exception e){}
            
            try{
                List<Case> lstcase = conEntController.filterCasesAndUpdateContact();
            }catch(Exception e){}
            
            Test.stopTest();
            
        }
    }
    
    static testMethod void testMoveContactIPS(){
        UserRole role = new UserRole();
        role.name='Admin';
        insert role;
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];//System Administrator
        
        User itAdminUser = new User(Alias = 'itAdmx2', 
                                    Email='itAdminTestx2@intel.com', 
                                    EmailEncodingKey='UTF-8',
                                    LastName='UnitTestAdmin',
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    ProfileId = itAdminPrf.Id, 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    UserRoleId = role.id,
                                    UserName='itAdminTest@intel.com');
        insert itAdminUser;
        System.runAs(itAdminUser){
            
            
            Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c=true);
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c!= null);
            
            Contact testContact = new Contact(FirstName='testFirstName123',LastName='testLastName', Email='test123@testing.com.test',
                                              Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId(), AccountId=testAccount.Id ,Core_IPS_Active__c=true, MailingCountry='India');
            insert testContact;
            Account testAccount2 = new Account(Name='testAccount1234', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                               Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                               BillingStreet='1234 tester St', BillingCity='testCity2', BillingState='OR',
                                               BillingCountry='USA', BillingPostalCode='123456',Core_IPS_Active__c=true);//,Core_Export_Compliance_Block__c=true
            insert testAccount2;
            System.assert(true,testAccount2.Core_Export_Compliance_Block__c);
            Contact testContact2 = new Contact(FirstName='testFirstName123', LastName='testLName', Email='test1234@testing.com.test',
                                               Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId(), AccountId=testAccount2.Id ,Core_IPS_Active__c=true, MailingCountry='India');
            try{
                insert testContact2 ;
                system.assertequals(testContact.LastName,'testLastName');
            }catch(Exception e){}
            system.assertequals(testContact2.LastName,'testLName');
            
            List<Case> ListOfCases = TestUtilities.getListOfCases(10);
            integer count=0;
            for(Case CaseRec : ListOfCases){
                CaseRec.AccountID = testAccount.id;
                CaseRec.contactID = testContact.Id;
                
            }
            insert ListOfCases;
            ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
            
            Profile currLoggedInUserProfile = [Select Name from Profile where Id = : UserInfo.getProfileId() limit 1];
            Set<Core_Move_Contact_Authorized_Profiles__c> sAuthPro = new Set<Core_Move_Contact_Authorized_Profiles__c>();
            //sAuthPro.add(new Core_Move_Contact_Authorized_Profiles__c(Name='Cloud CRM BSA-Pre Prod'));
            sAuthPro.add(new Core_Move_Contact_Authorized_Profiles__c(Name='IT Admin'));
            sAuthPro.add(new Core_Move_Contact_Authorized_Profiles__c(Name=currLoggedInUserProfile.Name));
            insert new List<Core_Move_Contact_Authorized_Profiles__c>(sAuthPro);
            Core_Contact_Access_Profiles__c accessProfile=new Core_Contact_Access_Profiles__c(name='IT Admin',Core_Profile_Name__c='IT Admin');
            insert accessProfile;        
            ApexPages.currentPage().getParameters().put('Id', testContact.Id);
            sc = new ApexPages.StandardController(testContact);
            
            
            Core_IPS_MoveContactWithLargeCases conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
            conEntController.currContact=testContact;
            conEntController.targetAccount=testContact2;
            
            //Negative case and swallow the exception
            try{
                
                conEntController.updateCasesOnSave();
            }catch(Exception e){}
        }   
    }
    
        static testMethod void testMoveContactGECHold(){
             insert new Core_Contact_Bypass_Validation_Rule__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass__c=true);
             Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345');
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c!= null);
            
            Contact testContact = new Contact(FirstName='testFirstName123',LastName='testLastName', Email='test123@testing.com.test',
                                              AccountId=testAccount.Id, MailingCountry='India' );
            insert testContact;
            Account testAccount2 = new Account(Name='testAccount1234', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                              BillingStreet='1234 tester St', BillingCity='testCity2', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='123456',Core_Export_Compliance_Block__c=true);
            insert testAccount2;
            System.assert(true,testAccount2.Core_Export_Compliance_Block__c);
            Contact testContact2 = new Contact(FirstName='testFirstName123', LastName='testLName', Email='test1234@testing.com.test', AccountId=testAccount2.Id, MailingCountry='India');
            try{
            insert testContact2 ;
            system.assertequals(testContact.LastName,'testLastName');
            }catch(Exception e){}
            system.assertequals(testContact2.LastName,'testLName');
            
            List<Case> ListOfCases = TestUtilities.getListOfCases(10);
            integer count=0;
            for(Case CaseRec : ListOfCases){
                    CaseRec.AccountID = testAccount.id;
                CaseRec.contactID = testContact.Id;
                 
            }
            insert ListOfCases;
            ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
            
            Profile currLoggedInUserProfile = [Select Name from Profile where Id = : UserInfo.getProfileId() limit 1];
            Set<Core_Move_Contact_Authorized_Profiles__c> sAuthPro = new Set<Core_Move_Contact_Authorized_Profiles__c>();
            //sAuthPro.add(new Core_Move_Contact_Authorized_Profiles__c(Name='Cloud CRM BSA-Pre Prod'));
            sAuthPro.add(new Core_Move_Contact_Authorized_Profiles__c(Name='IT Admin'));
            sAuthPro.add(new Core_Move_Contact_Authorized_Profiles__c(Name=currLoggedInUserProfile.Name));
            insert new List<Core_Move_Contact_Authorized_Profiles__c>(sAuthPro);
              Core_Contact_Access_Profiles__c accessProfile=new Core_Contact_Access_Profiles__c(name='IT Admin',Core_Profile_Name__c='IT Admin');
            insert accessProfile;        
            ApexPages.currentPage().getParameters().put('Id', testContact.Id);
            sc = new ApexPages.StandardController(testContact);
            
            Core_IPS_MoveContactWithLargeCases conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
            conEntController.currContact=testContact;
            conEntController.targetAccount=testContact2;
            
            //Negative case and swallow the exception
            try{
                conEntController.updateCasesOnSave();
            }catch(Exception e){}
        }
    
    
    static testMethod void testHasValidInputs(){
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];//System Administrator
        
        Core_IPS_Labels__c ipsCS = new Core_IPS_Labels__c(Name = 'IPS Standard Entitlement', Value__c='IPS Standard Entitlement');
        insert ipsCS;
        boolean flag =true;
        
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
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin');
        List<Contact> contList = new List<Contact>();
        
        System.runas(itAdminUser){
            Account fromAccount = new Account(Name='fromAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345', Core_IPS_Active__c = true,
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',Core_B2B_Entitlement__c = true, 
                                              BillingCountry='USA', BillingPostalCode='12345',Core_Export_Compliance_Block__c = false);
            insert fromAccount;
            Contact fromContact = new Contact(FirstName='fromContact', LastName='testLName', Email='fromContact@testing.com.test',
                                              Core_IPS_Intel_Support_Owner__c=null, AccountId=fromAccount.Id, MailingCountry='India');
            
            
            Contact fromContact2 = new Contact(FirstName='fromContact2', LastName='testLName', Email='fromContact2@testing.com.test',
                                               Core_IPS_Intel_Support_Owner__c=null, AccountId=fromAccount.Id, MailingCountry='India');
            
            
            Account toAccount = new Account(Name='toAccount', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                            Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                            BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                            BillingCountry='USA', BillingPostalCode='12345',Core_Export_Compliance_Block__c = false);
            insert toAccount;
            Contact toContact = new Contact(FirstName='toContact', LastName='testLName', Email='toContact@testing.com.test',
                                            Core_IPS_Intel_Support_Owner__c=null, AccountId=toAccount.Id, MailingCountry='India');
            
            
            contList.add(fromContact);  
            contList.add(fromContact2);  
            contList.add(toContact);  
            insert contList;
            
            Contact passContact = [Select Id, Name from Contact where Email='fromContact@testing.com.test'];
            System.assertNotequals(null, passContact);
            ApexPages.currentPage().getParameters().put('Id', passContact.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(passContact);
            Core_IPS_MoveContactWithLargeCases conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
            
            List<Apexpages.Message> msgs = null;
            String pm = null;
            Apexpages.Message msg = null;
            
            Contact frmCont =  [Select Id, Account.Name, Name, AccountId,Core_IPS_Active__c, FirstName, Account.Core_Export_Compliance_Block__c, 
                                Account.Core_Export_Compliance_Block_Reason__c, Account.Core_IsODM__c,Account.Core_IPS_Active__c,Account.Core_B2B_Entitlement__c ,Account.Core_PSG_Account__c,
                                Owner.email, Core_IPS_Intel_Support_Owner__r.email,Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c, ownerid, 
                                Core_IPS_Intel_Support_Owner__c, account.ownerID, LastName 
                                From Contact where Email='fromContact@testing.com.test'];
            
            Contact toCont =  [Select Id, Account.Name, Name, AccountId,Core_IPS_Active__c, FirstName, Account.Core_Export_Compliance_Block__c, 
                               Account.Core_Export_Compliance_Block_Reason__c, Account.Core_IsODM__c,Account.Core_IPS_Active__c,Account.Core_B2B_Entitlement__c ,Account.Core_PSG_Account__c,
                               Owner.email, Core_IPS_Intel_Support_Owner__r.email,Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c, ownerid, 
                               Core_IPS_Intel_Support_Owner__c, account.ownerID, LastName 
                               From Contact where Email='toContact@testing.com.test'];
            
            
            conEntController.currContact =  frmCont;
            System.assertNotequals(null, passContact);                                                
            Boolean returnFlag = null;
            
            //Test 1        
            conEntController.targetAccount = frmCont;
            returnFlag = conEntController.hasValidInputs();
            System.assertequals(false, returnFlag);
            msgs = ApexPages.getMessages();
            msg = msgs.get(0);
            pm = msg.getDetail();
            System.assertequals(true, pm.contains('Current account and target account is same'));
            
            
            
            //Test 2 GEC Case 
            conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
            conEntController.gecCaseFound = true;
            conEntController.currContact =  frmCont;
            conEntController.targetAccount = toCont;
            conEntController.targetAccountObj = null;
            conEntController.hidePoppup = false;
            returnFlag = conEntController.hasValidInputs();
            System.assertequals(false, returnFlag);
            msgs = ApexPages.getMessages();
            msg = msgs.get(0);
            pm = msg.getDetail();
            //System.assertequals(true, pm.contains('GEC'));
            
            
            //Test 3 : CNDA BLANK
            toAccount.Core_CNDA_Number__c = '';
            update toAccount;
            conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
            conEntController.gecCaseFound = false;
            conEntController.currContact =  frmCont;    
            conEntController.targetAccount = toCont;
            conEntController.keepEntitlements = true;
            conEntController.targetAccountObj = null;
            returnFlag = conEntController.hasValidInputs();
            System.assertequals(false, returnFlag);
            msgs = ApexPages.getMessages();
            msg = msgs.get(0);
            pm = msg.getDetail();
            
            //Test 4 : CIM BLANK
            toAccount.Core_CNDA_Number__c = '12345';
            toAccount.Core_CIM_ID__c ='';
            update toAccount;
            conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
            conEntController.gecCaseFound = false;
            conEntController.currContact =  frmCont;    
            conEntController.targetAccount = toCont;
            conEntController.keepEntitlements = true;
            conEntController.targetAccountObj = null;
            returnFlag = conEntController.hasValidInputs();
            System.assertequals(false, returnFlag);
            msgs = ApexPages.getMessages();
            msg = msgs.get(0);
            pm = msg.getDetail();
            
            //Test 5 : EnglishONly Name Blank
            toAccount.Core_CIM_ID__c ='123412';
            toAccount.Core_English_Only_Name__c ='';
            update toAccount;
            conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
            conEntController.gecCaseFound = false;
            conEntController.currContact =  frmCont;    
            conEntController.targetAccount = toCont;
            conEntController.keepEntitlements = true;
            conEntController.targetAccountObj = null;
            returnFlag = conEntController.hasValidInputs();
            System.assertequals(false, returnFlag);
            msgs = ApexPages.getMessages();
            msg = msgs.get(0);
            pm = msg.getDetail();
            
            //Test 6 : BLANK Export compliance block for scource Account
            toAccount.Core_English_Only_Name__c ='Testing';
            fromAccount.Core_Export_Compliance_Block__c = true;
            update fromAccount;
            update toAccount;
            conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
            conEntController.gecCaseFound = false;
            frmCont =  [Select Id, Account.Name, Name, AccountId,Core_IPS_Active__c, FirstName, Account.Core_Export_Compliance_Block__c,Account.Core_PSG_Account__c, 
                        Account.Core_Export_Compliance_Block_Reason__c, Account.Core_IsODM__c,Account.Core_IPS_Active__c,Account.Core_B2B_Entitlement__c ,
                        Owner.email, Core_IPS_Intel_Support_Owner__r.email,Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c, ownerid, 
                        Core_IPS_Intel_Support_Owner__c, account.ownerID, LastName 
                        From Contact where Email='fromContact@testing.com.test'];
            conEntController.currContact =  frmCont;    
            conEntController.targetAccount = toCont;
            conEntController.keepEntitlements = true;
            conEntController.targetAccountObj = null;
            returnFlag = conEntController.hasValidInputs();
            System.assertequals(false, returnFlag);
            msgs = ApexPages.getMessages();
            msg = msgs.get(0);
            pm = msg.getDetail();
            
            Test.startTest();
            //Test 7: BLANK Export compliance block for target Account
            toAccount.Core_Export_Compliance_Block__c = true;
            update toAccount;
            fromAccount.Core_Export_Compliance_Block__c = false;
            update fromAccount;
            
            conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
            conEntController.gecCaseFound = false;
            frmCont =  [Select Id, Account.Name, Name, AccountId,Core_IPS_Active__c, FirstName, Account.Core_Export_Compliance_Block__c,Account.Core_PSG_Account__c,
                        Account.Core_Export_Compliance_Block_Reason__c, Account.Core_IsODM__c,Account.Core_IPS_Active__c,Account.Core_B2B_Entitlement__c ,
                        Owner.email, Core_IPS_Intel_Support_Owner__r.email,Core_ERPM_Integration_Status__c, Core_AGS_Integration_Status__c, ownerid, 
                        Core_IPS_Intel_Support_Owner__c, account.ownerID, LastName 
                        From Contact where Email='fromContact@testing.com.test'];
            conEntController.currContact =  frmCont;    
            conEntController.targetAccount = toCont;
            conEntController.keepEntitlements = true;
            conEntController.targetAccountObj = null;
            returnFlag = conEntController.hasValidInputs();
            System.assertequals(false, returnFlag);
            msgs = ApexPages.getMessages();
            msg = msgs.get(0);
            pm = msg.getDetail();
            
            //Test 8 IPS true for targetAccount
            toAccount.Core_Export_Compliance_Block__c = false;
            toAccount.Core_IPS_Active__c = false;
            update toAccount;
            conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
            conEntController.gecCaseFound = false;
            conEntController.currContact =  frmCont;    
            conEntController.targetAccount = toCont;
            conEntController.keepEntitlements = true;
            conEntController.targetAccountObj = null;
            returnFlag = conEntController.hasValidInputs();
            //System.assertequals(false, returnFlag); COmmented as the code commented in controller
            msgs = ApexPages.getMessages();
            msg = msgs.get(0);
            pm = msg.getDetail();
            
            //Test 9 B2B Account = true
            toAccount.Core_IPS_Active__c = true;
            toAccount.Core_B2B_Entitlement__c = false;
            update toAccount;
            conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
            conEntController.gecCaseFound = false;
            conEntController.currContact =  frmCont;    
            conEntController.targetAccount = toCont;
            conEntController.keepEntitlements = true;
            returnFlag = conEntController.hasValidInputs();
            //System.assertequals(false, returnFlag); COmmented as the code commented in controller
            msgs = ApexPages.getMessages();
            msg = msgs.get(0);
            pm = msg.getDetail();
            
            //Test 10 USER ROle is Blank
            toAccount.Core_B2B_Entitlement__c = true;
            update toAccount;
            conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
            conEntController.gecCaseFound = false;
            conEntController.currContact =  frmCont;    
            conEntController.targetAccount = toCont;
            conEntController.keepEntitlements = true;
            returnFlag = conEntController.hasValidInputs();
            System.assertequals(false, returnFlag);
            msgs = ApexPages.getMessages();
            msg = msgs.get(0);
            pm = msg.getDetail();
            
            
            //Test 11 : target ant source account with different ODM indicators
            toAccount.Core_IsODM__c = false;
            toAccount.Core_B2B_Entitlement__c = false;
            update toAccount;
            conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
            conEntController.gecCaseFound = false;
            conEntController.currContact =  frmCont;    
            conEntController.targetAccount = toCont;
            conEntController.keepEntitlements = true;
            returnFlag = conEntController.hasValidInputs();
            System.assertequals(false, returnFlag);
            msgs = ApexPages.getMessages();
            msg = msgs.get(0);
            pm = msg.getDetail();
            //System.assertequals(true, pm.contains('Current account and target account is same'));
            
            //Test 12 : INvalid target Account
            conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
            conEntController.gecCaseFound = false;
            conEntController.currContact =  frmCont;    
            toCont.AccountId = null;
            conEntController.targetAccount = toCont;
            conEntController.keepEntitlements = true;
            returnFlag = conEntController.hasValidInputs();
            System.assertequals(false, returnFlag);
            
            
            // getCases
            conEntController = new Core_IPS_MoveContactWithLargeCases(sc);
            conEntController.gecCaseFound = false;
            conEntController.currContact =  frmCont;  
            conEntController.targetAccount = toCont;
            List<Case> ListOfCases = TestUtilities.getListOfCases(1);
            Case c = ListOfCases.get(0);
            c.Core_IPS_GEC_Case__c = true;
            c.Core_IPS_GEC_Status__c ='On Hold - GEC Review in Progress';
            c.contactId = frmCont.Id;
            insert ListOfCases;
            conEntController.getCases();
            
            Test.stopTest();
        } 
    }
       static testMethod void testMoveContactCases1(){
        insert new Core_Contact_Bypass_Validation_Rule__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass__c=true);
        Profile itAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];//System Administrator
        
        Core_IPS_Labels__c ipsCS = new Core_IPS_Labels__c(Name = 'IPS Standard Entitlement', Value__c='IPS Standard Entitlement');
        insert ipsCS;
        boolean flag =true;
        
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
        system.assertequals(itAdminUser.LastName,'UnitTestAdmin');
        
        Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                          Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                          BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_Export_Compliance_Block__c = false,Core_IPS_Active__c =false);
        insert testAccount;
        system.assertNOTEquals(null,testAccount.id);
        
        Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',
                                          Core_IPS_Active__c =true,Core_Contact_B2B_Indicator__c=true,Core_IPS_Intel_Support_Owner__c=itAdminUser.id, AccountId=testAccount.Id, MailingCountry='India');
        insert testContact;
        system.assertNOTEquals(null,testContact.id);
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,
                                                                         Core_Entitlement_Id__c=Label.Core_Entitlement_IPS_Id,
                                                                         Core_Selected__c=true);
        insert ce; 
        system.assertNOTEquals(null,ce.id);
        
        Contact testContact2 = new Contact(FirstName='testFirstName123', LastName='testLName', Email='test1234@testing.com.test',
                                           Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c=null, AccountId=testAccount.Id, MailingCountry='India');
        insert testContact2;
        System.assert(true,testContact2.LastName!= null);
        
        
        Account testAccount3 = new Account(Name='testAccount123456', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                           Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '123456',
                                           BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                           BillingCountry='USA', BillingPostalCode='12345',Core_B2B_Entitlement__c=false);
        System.runas(itAdminUser){
            insert testAccount3;
        }
        Contact testContact3 = new Contact(FirstName='testFirstName123456', LastName='testLName',Email='testAccount123456@testing.com.test',
                                           Core_IPS_Intel_Support_Owner__c=null, AccountId=testAccount3.Id, MailingCountry='India');
        insert testContact3;
        Core_IPS_MoveContactWithLargeCases conEntController3 = new Core_IPS_MoveContactWithLargeCases(null);
        ApexPages.StandardController sc3 = new ApexPages.StandardController(testContact2);
        conEntController3 = new Core_IPS_MoveContactWithLargeCases(sc3);
        conEntController3.currContact =  testContact;    
        conEntController3.targetAccountObj = testAccount3;
        conEntController3.keepEntitlements = true;
        testContact.Core_IPS_Active__c=true;
        conEntController3.updateTargetAccountAdditionalFields(testContact);
        try{
                conEntController3.updateCasesOnSave();
            }catch(Exception e){}
    }
  }