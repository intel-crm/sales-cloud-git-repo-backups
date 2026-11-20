/**************************************************************************************
Test Class Name :  Core_IPS_MoveContactWithCases_Batch_Test
for             : Core_IPS_MoveContactWithCases_Batch
Version         : 1.0 
Created Date    : 03 Oct 2019

* Modification Log :
* Developer                   Date                   Description
* ------------------------------------------------------------------------------------
* Ganapati                    03/10/2019              Created for US436541
***************************************************************************************/

@isTest(seeAllData=false)
public class Core_IPS_MoveContactWithCases_Batch_Test {
    static testMethod void testMoveContactCasesBatch1(){
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
        
        System.runAs(itAdminUser){ 
            Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345');
            insert testAccount;
            System.assert(true,testAccount.Core_CNDA_Number__c!= null);
            
            Contact testContact = new Contact(FirstName='testFirstName123',LastName='testLastName', Email='test123@testing.com.test',
                                              Core_IPS_Intel_Support_Owner__c = itAdminUser.id, AccountId=testAccount.Id,MailingCountry='India');
            insert testContact;
            system.assertequals(testContact.LastName,'testLastName'); 
            
            Contact testContact2 = new Contact(FirstName='testFirstName123', LastName='testLName', Email='test1234@testing.com.test',
                                               Core_IPS_Intel_Support_Owner__c = null, AccountId=testAccount.Id,MailingCountry='India');
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
            
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
            insert ListOfProducts;
            
            Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
            org.Core_IPS_Support_Org_Name__c='test';
            org.Core_Organization_Description__c='test';
            insert org;
            
            Core_IPS_Supported_Product__c pdt = new Core_IPS_Supported_Product__c();
            pdt.Core_Supported_Product_Name__c='medical';
            pdt.Core_Product__c=ListOfProducts[0].id;
            pdt.Core_Product_Organization__c=org.id;
            insert pdt;
            
            Core_IPS_Project__c project = new Core_IPS_Project__c();
            project.Core_IPS_Group_Name__c='test';
            project.Core_MPNDA__c='test1234';
            insert project;
            
            // Creates product for a case
            Product2 objProd = new Product2();
            objProd.name = 'Test Local Control Panel';
            objProd.IsActive = true;
            insert objProd;            
            
            List<Asset> listOfAssets= TestUtilities.getAssetList(3);
            for(Asset AssetRec : listOfAssets){
                AssetRec.accountid= testAccount.id;
                AssetRec.Product2Id=objProd.id;
            }
            insert listOfAssets;
            
            List<Case> ListOfCases = TestUtilities.getListOfCases(3);
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
            
            Core_IPS_Account_Change_Status__c accChangeSts = new Core_IPS_Account_Change_Status__c();
            accChangeSts.Core_IPS_Contact__c = testContact.Id;
            accChangeSts.Core_IPS_Status__c = 'In Progress';
            insert accChangeSts;
            
            Test.startTest();
            Core_IPS_MoveContactWithCases_Batch moveContactsBatch = new Core_IPS_MoveContactWithCases_Batch(ListOfCases, testAccount.Id, testAccount, testContact);
            Database.executeBatch(moveContactsBatch, 50);
            Test.stopTest();
        }
    }
}