/***************************************************************************************************
* Apex Class Name: Core_IPS_Entitlement_For_Migrated_Test
* Version     : 1.0 
* Created Date: 9th June 2016
* Function    : Test class for Core_IPS_Entitlement_For_Migrated_Cases
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Nareshbabu p               06/09/2016               Created
****************************************************************************************************/
@isTest
public class Core_IPS_Entitlement_For_Migrated_Test {
    static testmethod void Core_IPS_EntitlementForMigCaseClassTestMethod() {
        //   by the batch job.
    List<string> ListOfProfileNames = new List<string> {'System Administrator'};
        Map<String,ID> MapOfProfiles = new Map<String,ID>();
        for(Profile prof : [select id, name from Profile where name IN: ListOfProfileNames]){
            MapOfProfiles.put(prof.name, prof.id);
        }
    List<User> SysAdminUsr = TestUtilities.getListOfUser(1);
        SysAdminUsr.get(0).UserName = 'SysAdminUsr'+SysAdminUsr.get(0).UserName;
        SysAdminUsr.get(0).ProfileID =  MapOfProfiles.get('System Administrator');
        // Create UserRole Record
        UserRole role = new UserRole();
        role.name='CEO';
        // Creating SETUP OBJECT (USERROLE) RECORD
        System.RunAs(SysAdminUsr[0]){
            insert role;
        }
        List<User>  ListOfInternalSfUsers = TestUtilities.getListOfUser(1);
    ListOfInternalSfUsers.get(0).ProfileID =  MapOfProfiles.get('System Administrator');
        ListOfInternalSfUsers.get(0).userroleid = role.id;
        // Creating SETUP OBJECT (USER) RECORD
        System.RunAs(SysAdminUsr[0]){
            insert ListOfInternalSfUsers;
        }
        System.assertEquals(ListOfInternalSfUsers.get(0).profileid, MapOfProfiles.get('System Administrator'));
        
        //Added by Cornelius Nath
        List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];        
        //create account record
        List<Account> ListOfAccounts = new List<Account> ();
        Account AccountRec1 = TestUtilities.getAccount();
        AccountRec1.Core_IPS_Active__c = true;
        AccountRec1.ownerid = ListOfInternalSfUsers.get(0).id;
        AccountRec1.Core_Military_Aerospace_and_Government__c = true;
        ListOfAccounts.add(AccountRec1);
        insert ListOfAccounts;
        // Create contact Record
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        ListOfContacts.get(0).Accountid = ListOfAccounts.get(0).Id;
        ListOfContacts.get(0).Core_IPS_Intel_Support_Owner__c = ListOfInternalSfUsers.get(0).id;
        ListOfContacts.get(0).ownerid = ListOfInternalSfUsers.get(0).id;
        insert ListOfContacts;
        
       
        System.assert(ListOfContacts[0].Id != null, 'Contact Record not created');
        // Create support org Record
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
        List<Core_IPS_Project__c>  ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
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
        list<Asset> ListOfAssets = TestUtilities.getAssetList(1);
        ListOfAssets.get(0).Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
        ListOfAssets.get(0).accountId = ListOfAccounts.get(0).Id;
        ListOfAssets.get(0).core_supported_product__c = ListOfSupportedProduct[0].id; 
        insert ListOfAssets;
        //create case record
    Case CaseRecord = new Case ();
        CaseRecord.AccountId=ListOfAccounts.get(0).Id;
         CaseRecord.AssetId=ListOfAssets.get(0).Id;
        CaseRecord.ContactId=ListOfContacts.get(0).id;        
        CaseRecord.Core_IPS_Product_Org1__c=ListOfSupportOrg.get(0).id;
    //CaseRecord.Core_Case_Issue_Category__c = caseCat.id;
        //CaseRecord.Core_case_issue_sub_category__c = subCategory.id;
        CaseRecord.Core_Issue_Description__c = 'test';
        CaseRecord.Subject='TestSubject';
        CaseRecord.Core_CaseType__c='Issue';
        CaseRecord.status ='Open';
        // Added by Cornelius Nath : Added Business Id for Case milestone Batch 
        CaseRecord.BusinessHoursId=bhs[0].Id;
        CaseRecord.CORE_IPS_ISSUE_SOURCE__C='Legacy IPS';
        CaseRecord.Core_IPS_GEC_Flag__c = false;
        CaseRecord.Core_IPS_Legacy_IPS_ID__c ='123';
        CaseRecord.recordtypeID =[select id from  recordtype where sobjecttype='case' and name='IPS Case Create'].Id;
        insert CaseRecord;
    
        List<CaseMilestone> CaseMls=[select Id, completionDate, isCompleted,MileStoneTypeId,MileStoneType.Name from CaseMilestone where caseId =:CaseRecord.id];
       system.debug('CaseMls'+CaseMls);
        Test.startTest();
    Core_IPS_Entitlement_For_Migrated_Cases Entitlement = new Core_IPS_Entitlement_For_Migrated_Cases();
        Database.executeBatch(Entitlement);
    Test.stopTest();
       }
    }