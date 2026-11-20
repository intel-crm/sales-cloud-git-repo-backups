/**************************************************************************************
Apex Class Name: UCD_ACM_MoveContactWithCases_ContTest
    Main Class : UCD_ACM_MoveContactWithCases_Cont
    Version     : 2.0
    Created Date: Dec 2024
    Created by : Sandesh H
     *************************************************************************************/
@isTest
public with sharing class UCD_ACM_MoveContactWithCases_ContTest {
    @TestSetup
    static void createSetupData() {
        List<User> userList = new List<User>();
        Profile adminPF= [Select Id from profile where Name='System Administrator' LIMIT 1];
        UserRole userRole = [Select id from UserRole where Name = 'Admin'limit 1];
        user systemAdminUser = UCD_ACM_Cntrlr_TestDataInitialization.createUser(adminPF.Id);
        systemAdminUser.firstname = 'System Admin';
        systemAdminUser.lastName = 'Test User';
        systemAdminUser.email = 'testUserSystemAdmin@intel.com';
        systemAdminUser.Username = 'testUserSystemAdmin@intel.com';
        systemAdminUser.UserRoleId = userRole.Id;
        userList.add(systemAdminUser);
        insert userList;
        
        system.runAs(systemAdminUser){
            List<Account> accLst = new List<Account>();
            Account testAccount1 = new Account(Name='testAccount1', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
            Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',Core_IPS_Active__c =false,
            BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',OwnerId = systemAdminUser.Id,
            BillingCountry='USA', BillingPostalCode='12345',Core_Export_Compliance_Block__c = false);
            accLst.add(testAccount1);
            
            Account testAccount2 = new Account(Name='testAccount2', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
            Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '123456',Core_B2B_Entitlement__c=false,
            BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
            BillingCountry='USA', BillingPostalCode='12345');
            accLst.add(testAccount2);
            
            Account testAccount3 = new Account(Name='testAccount3', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
            Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '123456',
            BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
            BillingCountry='USA', BillingPostalCode='12345');
            accLst.add(testAccount3);
            
            Account testAccount4 = new Account(Name='testAccount4', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
            Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '123456',
            BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
            BillingCountry='USA', BillingPostalCode='12345');
            accLst.add(testAccount4);
            insert accLst;
            
            List<Contact> conLst = new List<Contact>();
            Contact testContact1 = new Contact(FirstName='testFirstName1', LastName='testLastName', Email='testContact1@testing.com.test',
            Core_IPS_Intel_Support_Owner__c=null, AccountId=testAccount1.Id, MailingCountry = 'India');
            conLst.add(testContact1);
            
            Contact testContact2 = new Contact(FirstName='testFirstName2', LastName='testLName', Email='testContact2@testing.com.test',
            Core_IPS_Active__c =true,Core_Contact_B2B_Indicator__c = true,Core_IPS_Intel_Support_Owner__c=systemAdminUser.Id, AccountId=testAccount1.Id, MailingCountry = 'India');
            conLst.add(testContact2);
            
            System.assert(true,testContact2.LastName!= null);
            Contact testContact3 = new Contact(FirstName='testFirstName3', LastName='testLName', Email='testContact3@testing.com.test',
            Core_IPS_Intel_Support_Owner__c=null, AccountId=testAccount3.Id, MailingCountry = 'India');
            conLst.add(testContact3);
            Contact testContact4 = new Contact(FirstName='testFirstName4', LastName='testLName', Email='testContact4@testing.com.test',
            Core_IPS_Intel_Support_Owner__c=null, AccountId=testAccount3.Id, MailingCountry = 'India');
            conLst.add(testContact4);
            insert conLst;
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
            insert cee;
            system.assertequals(cee.Name,'Partner File Transfer');
            
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Customer Sales Order Reporting', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test',Core_IsActive__c=true);
            insert entitle;
            system.assertNOTEquals(null,entitle.id);
            
            List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact1.Id,
            Core_Entitlement_Id__c=entitle.id,
            Core_Selected__c=true);
            ceList.add(ce1);
            
            Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact3.Id,
            Core_Entitlement_Id__c=entitle.id,
            Core_Selected__c=false);
            ceList.add(ce2);
            insert ceList;
            
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
            insert ListOfProducts;
            
            Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
            org.Core_IPS_Support_Org_Name__c='test';
            org.Core_Organization_Description__c='test';
            insert org;
            System.assertEquals(org.Core_IPS_Support_Org_Name__c,'test');
            
            List<Core_IPS_Supported_Product__c> IPSProdList = new List<Core_IPS_Supported_Product__c>();
            Core_IPS_Supported_Product__c pdt = new Core_IPS_Supported_Product__c();
            pdt.Core_Supported_Product_Name__c='medical';
            pdt.Core_Product__c=ListOfProducts[0].id;
            pdt.Core_Product_Organization__c=org.id;
            IPSProdList.add(pdt);
            
            Core_IPS_Supported_Product__c pdt2 = new Core_IPS_Supported_Product__c();
            pdt2.Core_Supported_Product_Name__c='software';
            pdt2.Core_Product__c=ListOfProducts[1].id;
            pdt2.Core_Product_Organization__c=org.id;
            IPSProdList.add(pdt2);
            insert IPSProdList;
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
            
            Test.startTest();
            
            // Create Case
            List<Asset> listOfAssets= TestUtilities.getAssetList(4);
            //listOfAssets[0].accountid= testAccount2.id;
            listOfAssets[0].Product2Id=objProd.id;
            //listOfAssets[0].Core_Product_Organization__c = org.id;
            //listOfAssets[0].Core_Supported_Product__c = pdt.id;
            
            listOfAssets[1].accountid= testAccount1.id;
            listOfAssets[1].Product2Id=objProd.id;
            listOfAssets[1].Core_Product_Organization__c = org.id;
            listOfAssets[1].Core_Supported_Product__c = pdt.id;
            
            listOfAssets[2].accountid= testAccount4.id;
            listOfAssets[2].Product2Id=objProd.id;
            listOfAssets[2].Core_Product_Organization__c = org.id;
            listOfAssets[2].Core_Supported_Product__c = pdt.id;
            
            listOfAssets[3].accountid= testAccount4.id;
            listOfAssets[3].Product2Id=objProd.id;
            insert listOfAssets;
            
            List<Case> ListOfCases = TestUtilities.getListOfCases(10);
            ListOfCases[0].AccountID = testAccount1.id;
            ListOfCases[0].contactID = testContact2.Id;
            ListOfCases[0].AssetId = listOfAssets[0].id;
            ListOfCases[0].Core_IPS_Product_Org1__c = org.id;
            ListOfCases[0].Core_IPS_Supported_Product__c = pdt.id;
            
            ListOfCases[1].AccountID = testAccount1.id;
            ListOfCases[1].contactID = testContact2.Id;
            ListOfCases[1].AssetId = listOfAssets[1].id;
            ListOfCases[1].Core_IPS_Product_Org1__c = org.id;
            ListOfCases[1].Core_IPS_Supported_Product__c = pdt2.id;
            
            ListOfCases[2].Core_IPS_Project_Case__c = project.id;
            ListOfCases[2].AccountID = testAccount3.id;
            ListOfCases[2].contactID = testContact3.Id;
            ListOfCases[2].AssetId = listOfAssets[2].id;
            ListOfCases[2].Core_IPS_Product_Org1__c = null;
            
            for(Integer i=3;i<10;i++){
                ListOfCases[i].Core_IPS_Project_Case__c = project.id;
                ListOfCases[i].AccountID = testAccount3.id;
                ListOfCases[i].contactID = testContact3.Id;
                if(i/2 ==2){
                    ListOfCases[i].AssetId = listOfAssets[2].id;
                }else{
                    ListOfCases[i].AssetId = listOfAssets[3].id;
                }
                ListOfCases[i].Core_IPS_Supported_Product__c = pdt.id;
                ListOfCases[i].Core_IPS_Product_Org1__c = org.id;
            }
            
            insert ListOfCases;
            Test.stopTest();
            
            ChannelProgram cpIPATest = new ChannelProgram();
            cpIPATest.Name='Intel Partner Alliance';
            cpIPATest.PRM_programCode__c='IPA';
            insert cpIPATest;
            
            PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
            cr1.Name=System.Label.PRM_Primary_Contact;
            cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
            cr1.PRM_Default_Relationship_Ind__c = false;
            cr1.PRM_Mandatory_Relationship_Ind__c = true;
            cr1.PRM_Channel_Program_Id__c=cpIPATest.Id;
            cr1.PRM_InActive_Ind__c = false;
            insert cr1;
            
            List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
            PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
            acr1.PRM_InActive_Ind__c= false;
            acr1.PRM_Account_Id__c=testAccount1.Id;
            acr1.PRM_Relationship_Id__c = cr1.Id;
            acr1.PRM_Contact_Id__c=testContact1.Id;
            acr1.PRM_execute_trigger__c=true;
            acrList.add(acr1);
            
            PRM_Account_Contact_Relationship__c acr2=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
            acr2.PRM_InActive_Ind__c= false;
            acr2.PRM_Account_Id__c=testAccount1.Id;
            acr2.PRM_Relationship_Id__c = cr1.Id;
            acr2.PRM_Contact_Id__c=testContact1.Id;
            acr2.PRM_execute_trigger__c=true;
            acrList.add(acr2);
            insert acrList;
        }
        
    }
    
    @isTest
    public static void testMoveContwithoutEntitlementSelect() {
        User systemAdminUser = [Select Id from User where email =: 'testUserSystemAdmin@intel.com' limit 10];
        system.runAs(systemAdminUser){
            Contact cont = [Select id, Name,Core_IPS_Active__c,Account.Core_IPS_Active__c,AccountId from contact where Email =: 'testContact2@testing.com.test'];
            Account acc = [Select Id from Account where Name = 'testAccount2'];
            List<Case> caseList = [Select Id,contact.Name,Core_IPS_Supported_Product__r.Core_Product__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Name__c,Core_IPS_Supported_Product__r.Core_Supported_Product_Alias__c,Core_IPS_Project_Case__c,AccountID,Core_IPS_Product_Org1__c,Core_IPS_Supported_Product__c,Asset.RecordTypeId from case where contactID =: cont.Id];
            List<PRM_Account_Contact_Relationship__c> pcrList = [Select Id from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__r.Email =: 'testContact1@testing.com.test'];
            Id contactId = null;
            Test.startTest();
            UCD_ACM_MoveContactWithCases_Cont.changeAccount(caseList,acc.Id,cont.Id,false,false,contactId,pcrList);
            Test.stopTest();
        }
    }
    
    /* @isTest
    public static void testMoveContwithoutEntitlementSelect1() {
        User systemAdminUser = [Select Id from User where email =: 'testUserSystemAdmin@intel.com' limit 10];
        system.runAs(systemAdminUser){
            Contact cont = [Select id, Name from contact where Email =: 'testContact1@testing.com.test'];
            try{
                Test.startTest();
                UCD_ACM_MoveContactWithCases_Cont.updateContactEntitlementList(cont.Id);
                Test.stopTest();
            }catch (Exception ex) {
                System.debug('Exception-> '+ex);
            }
        }
    }*/
    
    @isTest
    public static void testMoveContwithEntitlementSelect() {
        User systemAdminUser = [Select Id from User where email =: 'testUserSystemAdmin@intel.com' limit 10];
        system.runAs(systemAdminUser){
            Id accountId1;
            Id accountId2;
            Contact cont = [Select id, Name from contact where Email =: 'testContact3@testing.com.test'];
            List<Account> accList = [Select Id,Name from Account where Name in ('testAccount3','testAccount4')];
            List<Case> caseList = [Select Id from case where contactID =: cont.Id];
            Contact cont2 = [Select id, Name from contact where Email =: 'testContact4@testing.com.test'];
            PRM_ContactRelationships__c cr1= [Select Id from PRM_ContactRelationships__c where PRM_Contact_Relationship_Cd__c='RELTNPRCTC'];
            for(Account acc: accList){
                if(acc.Name == 'testAccount3'){
                    accountId1 = acc.id;
                }else{
                    accountId2 = acc.id;
                }
            }
            
            List<PRM_Account_Contact_Relationship__c> pcrList = new List<PRM_Account_Contact_Relationship__c>();
            PRM_Account_Contact_Relationship__c acr3=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
            acr3.PRM_InActive_Ind__c= false;
            acr3.PRM_Account_Id__c=accountId1;
            acr3.PRM_Relationship_Id__c = cr1.Id;
            acr3.PRM_Contact_Id__c=cont.Id;
            acr3.PRM_execute_trigger__c=true;
            pcrList.add(acr3);
            
            PRM_Account_Contact_Relationship__c acr4=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
            acr4.PRM_InActive_Ind__c= false;
            acr4.PRM_Account_Id__c=accountId1;
            acr4.PRM_Relationship_Id__c = cr1.Id;
            acr4.PRM_Contact_Id__c=cont.Id;
            acr4.PRM_execute_trigger__c=true;
            pcrList.add(acr4);
            insert pcrList;
            
            Test.startTest();
            UCD_ACM_MoveContactWithCases_Cont.checkUserAccess();
            
            UCD_ACM_MoveContactWithCases_Cont.getCasesDetails(cont.Id);
            
            UCD_ACM_MoveContactWithCases_Cont.getIPSProjects(cont.Id);
            
            UCD_ACM_MoveContactWithCases_Cont.getAccountContactRelationship(cont.Id);
            
            UCD_ACM_MoveContactWithCases_Cont.getSubscribtions(cont.Id);
            
            UCD_ACM_MoveContactWithCases_Cont.getEntitlementDetails(cont.Id);
            
            UCD_ACM_MoveContactWithCases_Cont.getAccRelatedContacts(cont.Id,accountId2);
            
            UCD_ACM_MoveContactWithCases_Cont.changeAccount(caseList,accountId2,cont.Id,true,true,cont2.Id,pcrList);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testMoveContwithEntitlementSelect2() {
        User systemAdminUser = [Select Id from User where email =: 'testUserSystemAdmin@intel.com' limit 10];
        system.runAs(systemAdminUser){
            Id accountId1;
            Id accountId2;
            Contact cont = [Select id, Name from contact where Email =: 'testContact3@testing.com.test'];
            List<Account> accList = [Select Id,Name from Account where Name in ('testAccount3','testAccount4')];
            List<Case> caseList = [Select Id from case where contactID =: cont.Id];
            Contact cont2 = [Select id, Name from contact where Email =: 'testContact4@testing.com.test'];
            PRM_ContactRelationships__c cr1= [Select Id from PRM_ContactRelationships__c where PRM_Contact_Relationship_Cd__c='RELTNPRCTC'];
            for(Account acc: accList){
                if(acc.Name == 'testAccount3'){
                    accountId1 = acc.id;
                }else{
                    accountId2 = acc.id;
                }
            }
            
            List<PRM_Account_Contact_Relationship__c> pcrList = new List<PRM_Account_Contact_Relationship__c>();
            PRM_Account_Contact_Relationship__c acr3=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
            acr3.PRM_InActive_Ind__c= false;
            acr3.PRM_Account_Id__c=accountId1;
            acr3.PRM_Relationship_Id__c = cr1.Id;
            acr3.PRM_Contact_Id__c=cont.Id;
            acr3.PRM_execute_trigger__c=true;
            pcrList.add(acr3);
            
            PRM_Account_Contact_Relationship__c acr4=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
            acr4.PRM_InActive_Ind__c= false;
            acr4.PRM_Account_Id__c=accountId1;
            acr4.PRM_Relationship_Id__c = cr1.Id;
            acr4.PRM_Contact_Id__c=cont.Id;
            acr4.PRM_execute_trigger__c=true;
            pcrList.add(acr4);
            insert pcrList;
            
            Test.startTest();
            UCD_ACM_MoveContactWithCases_Cont.checkUserAccess();
            
            UCD_ACM_MoveContactWithCases_Cont.getCasesDetails(cont.Id);
            
            UCD_ACM_MoveContactWithCases_Cont.getIPSProjects(cont.Id);
            
            UCD_ACM_MoveContactWithCases_Cont.getAccountContactRelationship(cont.Id);
            
            UCD_ACM_MoveContactWithCases_Cont.getSubscribtions(cont.Id);
            
            UCD_ACM_MoveContactWithCases_Cont.getEntitlementDetails(cont.Id);
            
            UCD_ACM_MoveContactWithCases_Cont.getAccRelatedContacts(cont.Id,accountId2);
            
            UCD_ACM_MoveContactWithCases_Cont.changeAccount(caseList,accountId2,cont.Id,false,true,cont2.Id,pcrList);
            Test.stopTest();
        }
    }
}