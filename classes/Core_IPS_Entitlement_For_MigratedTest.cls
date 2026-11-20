@isTest
public class Core_IPS_Entitlement_For_MigratedTest
{               
        static List<User> SysAdminUsr = new List<User> ();
        static List<User> ListOfInternalSfUsers = new List<User> ();
        static List<Core_IPS_Project__c> ListOfIpsProjects = new List<Core_IPS_Project__c> ();
        static list<Asset> ListOfAssets = new list<Asset> ();
        static Core_IPS_Product_Issue_Category__c caseCat = new Core_IPS_Product_Issue_Category__c();
        static  Core_IPS_Product_Issue_Category__c subCategory = new Core_IPS_Product_Issue_Category__c();
        static Case CaseRecord = new Case();
        
       static void getRecords(integer tid){
        // Query Profiles
        List<string> ListOfProfileNames = new List<string> {'System Administrator'};
        Map<String,ID> MapOfProfiles = new Map<String,ID>();
        for(Profile prof : [select id, name from Profile where name IN: ListOfProfileNames]){
            MapOfProfiles.put(prof.name, prof.id);
        }
        SysAdminUsr = TestUtilities.getListOfUser(1);
        SysAdminUsr.get(0).UserName = 'SysAdminUsr'+SysAdminUsr.get(0).UserName;
        SysAdminUsr.get(0).ProfileID =  MapOfProfiles.get('System Administrator');
        // Create UserRole Record
        UserRole role = new UserRole();
        role.name='CEO';
        // Creating SETUP OBJECT (USERROLE) RECORD
        System.RunAs(SysAdminUsr[0]){
            insert role;
        }
        // Create Users
        ListOfInternalSfUsers = TestUtilities.getListOfUser(1);
        ListOfInternalSfUsers.get(0).ProfileID =  MapOfProfiles.get('System Administrator');
        ListOfInternalSfUsers.get(0).userroleid = role.id;
        // Creating SETUP OBJECT (USER) RECORD
        System.RunAs(SysAdminUsr[0]){
            insert ListOfInternalSfUsers;
        }
        System.assertEquals(ListOfInternalSfUsers.get(0).profileid, MapOfProfiles.get('System Administrator'));
        // Create Account Record
        List<Account> ListOfAccounts = new List<Account> ();
        Account AccountRec1 = TestUtilities.getAccount();
        AccountRec1.Core_IPS_Active__c = true;
        AccountRec1.ownerid = ListOfInternalSfUsers.get(0).id;
        AccountRec1.Core_Military_Aerospace_and_Government__c = true;
        ListOfAccounts.add(AccountRec1);
        insert ListOfAccounts;
        List<Core_IPS_Labels__c>  LstLabels = TestUtilities.getIPSLabel();
                insert LstLabels;
        System.assert(ListOfAccounts[0].Id != null, 'Account Record not created');
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        ListOfContacts.get(0).Accountid = ListOfAccounts.get(0).Id;
        ListOfContacts.get(0).Core_IPS_Intel_Support_Owner__c = ListOfInternalSfUsers.get(0).id;
        ListOfContacts.get(0).ownerid = ListOfInternalSfUsers.get(0).id;
        insert ListOfContacts;
        System.assert(ListOfContacts[0].Id != null, 'Contact Record not created');
        // Create Support Org Record
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(1);
        insert ListOfSupportOrg;
        System.assert(ListOfSupportOrg != null, 'Support Org Record not created');
        // Create Product2 Record
        List<Product2> ListOfProducts = TestUtilities.getListOfProduct(1);
        insert ListOfProducts;
        System.assert(ListOfProducts[0].id != null,'Product2 Record not created');
        // Create Supported product Record
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
        ListOfSupportedProduct.get(0).Core_Product__c = ListOfProducts.get(0).id;
        ListOfSupportedProduct.get(0).Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        insert ListOfSupportedProduct;
        System.assert(ListOfSupportedProduct[0].id != null,'Supported product Record not created');
        // Create Design Project Record
        ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
        insert ListOfIpsProjects;
        System.assert(ListOfIpsProjects.get(0).Id != null, 'Design Project Record not created');
        // Create IPS Product Record
        List<Core_IPS_Product__c> ListOfIpsProducts = TestUtilities.getListOfIpsProducts(1);
        ListOfIpsProducts.get(0).Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
        ListOfIpsProducts.get(0).Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
        ListOfIpsProducts.get(0).Status__c = 'Submitted';
        insert ListOfIpsProducts;
        System.assert(ListOfIpsProducts.get(0).Id != null, 'IPS Product Record not created');
        // Create Asset
        ListOfAssets = TestUtilities.getAssetList(1);
        ListOfAssets.get(0).Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        ListOfAssets.get(0).accountId = ListOfAccounts.get(0).Id;
       // if(tid!=1){
            ListOfAssets.get(0).core_supported_product__c = ListOfSupportedProduct[0].id;
        //}
        insert ListOfAssets;
        System.assert(ListOfAssets.get(0).Id != null, 'Asset Record not created');
        // Create Core Master Issue Category - Case Category
        List<Core_IPS_Master_Issue_Category__c> ListOfCoreMasterIssueCategory_CaseCat = TestUtilities.getListOfCoreMastIssCategory(1);
        ListOfCoreMasterIssueCategory_CaseCat.get(0).Core_type__c = 'Case Category';
        insert ListOfCoreMasterIssueCategory_CaseCat;
        System.assert(ListOfCoreMasterIssueCategory_CaseCat[0].Id != null, 'Record not Created');
        // Create Core Master Issue Category - Case Sub Category
        List<Core_IPS_Master_Issue_Category__c> ListOfCoreMasterIssueCategory_CaseSubCat = TestUtilities.getListOfCoreMastIssCategory(1);
        ListOfCoreMasterIssueCategory_CaseSubCat.get(0).Core_Master_Issue_Category__c = ListOfCoreMasterIssueCategory_CaseCat.get(0).id;
        insert ListOfCoreMasterIssueCategory_CaseSubCat;
        System.assert(ListOfCoreMasterIssueCategory_CaseSubCat[0].Id != null, 'Record not Created');
        // Create Core Product Issue Category - Case Category
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseCat = TestUtilities.getListOfCoreProdIssCategory(2);
        for(Core_IPS_Product_Issue_Category__c ProdIssuCat : ListOfCoreProdIssCategory_CaseCat){
            ProdIssuCat.Core_type__c = 'Case Category';
            ProdIssuCat.Core_Issue_Category_Name__c = ListOfCoreMasterIssueCategory_CaseCat.get(0).id;
            ProdIssuCat.Core_supported_product__c = ListOfSupportedProduct[0].id;
        }
        insert ListOfCoreProdIssCategory_CaseCat;
        System.assert(ListOfCoreProdIssCategory_CaseCat[0].Id != null, 'Record not Created');
        //Creating MasterCaseCategory
        Core_IPS_Master_Issue_Category__c MasterCaseCategory = TestUtilities.getMasterCaseCategories();
        MasterCaseCategory.Core_type__c = 'Case Category';
        insert MasterCaseCategory;
        System.assert(MasterCaseCategory.Id != null, 'Record not created'); 
        //Creating MasterCategory
        Core_IPS_Master_Issue_Category__c MasterCategory = TestUtilities.getMasterCaseCategories();
        MasterCategory.Core_Master_Issue_Category__c = MasterCaseCategory.id;            
        insert MasterCategory;
        System.assert(MasterCategory.Id != null, 'Record not created');
        caseCat = TestUtilities.getCaseCategories();
        caseCat.Core_Issue_Category_Name__c = MasterCategory.id;
        caseCat.Core_Type__c = 'Case Category';
        insert caseCat; 
        System.assert(caseCat.Id != null, 'Record not created');
        
        subCategory = TestUtilities.getCaseCategories();
        subCategory.Core_Issue_Sub_Category_Name__c = MasterCategory.id;
        subCategory.Core_Type__c = 'Case Subcategory';
        insert subCategory; 
                System.assert(subCategory.Id != null, 'Record not created');
        CaseRecord = new Case ();
        CaseRecord.AccountId=ListOfAccounts.get(0).Id;
        if(tid!=3){
            if(tid!=4){
            CaseRecord.AssetId=ListOfAssets.get(0).Id;
            }
            CaseRecord.Core_IPS_Supported_Product__c=ListOfSupportedProduct.get(0).id;
        }
        CaseRecord.ContactId=ListOfContacts.get(0).id;        
        CaseRecord.Core_IPS_Product_Org1__c=ListOfSupportOrg.get(0).id;
        CaseRecord.Core_Case_Issue_Category__c = caseCat.id;
        CaseRecord.Core_case_issue_sub_category__c = subCategory.id;
        CaseRecord.Core_Issue_Description__c = 'test';
        CaseRecord.Subject='TestSubject';
        CaseRecord.Core_CaseType__c='Issue';
        CaseRecord.entitlementId = null;
        CaseRecord.Core_IPS_GEC_Flag__c = false;
        CaseRecord.Core_IPS_Legacy_IPS_ID__c ='testclass1212132132143';
        CaseRecord.Core_IPS_GEC_Case__c = false;
        
        if(tid==1){
            CaseRecord.Core_Severity__c='Critical';
        }
        if(tid!=1){
            insert CaseRecord;}
        
        //create env Var
            List<Core_IPS_Environment_Variables__c> ListOfenvVars = new List<Core_IPS_Environment_Variables__c>();
            for(integer i=0;i<4;i++){
                Core_IPS_Environment_Variables__c envVar = TestUtilities.getEnvironmentalDetailMaster();
                envVar.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                ListOfenvVars.add(envVar);
            }
            
            ListOfenvVars[0].Core_Datatype__c= 'Picklist';
            ListOfenvVars[1].Core_Datatype__c= 'Text (255)';
            ListOfenvVars[2].Core_Datatype__c= 'Text Area (5000)';
            ListOfenvVars[3].Core_Datatype__c= 'Multiselect Picklist';
            
            insert ListOfenvVars;
            System.assert(ListOfenvVars[0].Id != null, 'Record not created');
            //Creating EnvironmentalDetails
            List<Core_IPS_Assigned_Environment_Variables__c> EnvironmentalDetailsList = new List<Core_IPS_Assigned_Environment_Variables__c>();
            for(integer i=0;i<4;i++){
            Core_IPS_Assigned_Environment_Variables__c EnvironmentalDetails = TestUtilities.getEnvironmentalDetailsOperational();
            EnvironmentalDetails.Core_Environment_Variable__c = ListOfenvVars[i].id;
                EnvironmentalDetails.Core_Required__c=true;
            EnvironmentalDetails.Core_supported_product__c = ListOfSupportedProduct[0].id;
            EnvironmentalDetailsList.add(EnvironmentalDetails);
            }
            insert EnvironmentalDetailsList;
            System.assert(EnvironmentalDetailsList[0].Id != null, 'Record not created');
            Core_IPS_Environment_Details__c envDetal = new Core_IPS_Environment_Details__c();
            envDetal.Name = 'Issue Resolution List';
            envDetal.Core_Question__c='intel';
            envDetal.Core_Answer__c='TestAnswer1;TestAns2;Testans3';
            envDetal.Core_Case__c = CaseRecord.id;
        if(tid!=1){
            insert envDetal;                
            System.assert(envDetal.Id != null, 'Record not created');}
            List<Core_IPS_Error_Code__c> errorCodes= TestUtilities.getListOfIpsErrorCodes();
            insert errorCodes;
            System.assert(errorCodes[0].Id != null, 'Record not created');
        /*
        // Create Core Product Issue Category - Case Sub Category
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory_CaseSubCat = TestUtilities.getListOfCoreProdIssCategory(1);
        ListOfCoreProdIssCategory_CaseSubCat.get(0).Core_Product_Issue_Category__c = ListOfCoreProdIssCategory_CaseCat.get(0).id;
        ListOfCoreProdIssCategory_CaseSubCat.get(0).Core_Issue_Sub_Category_Name__c = ListOfCoreMasterIssueCategory_CaseSubCat.get(0).id;
        ListOfCoreProdIssCategory_CaseSubCat.get(0).Core_supported_product__c = ListOfSupportedProduct[0].id;
        insert ListOfCoreProdIssCategory_CaseSubCat;
        System.assert(ListOfCoreProdIssCategory_CaseSubCat[0].Id != null, 'Record not Created');
        */
    }
        static testmethod void Core_IPS_Entitlement_MigratedTestMethod()
        {
            getRecords(0);
            Test.startTest();
            Core_IPS_Entitlement_For_Migrated_Cases atmBatch = new Core_IPS_Entitlement_For_Migrated_Cases();
            Database.executeBatch(atmBatch);            
            Test.stopTest();
        }
}