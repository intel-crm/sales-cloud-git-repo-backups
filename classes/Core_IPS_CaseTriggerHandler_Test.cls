/***************************************************************************************************
Class Name:  Core_IPS_CaseTriggerHandler_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 06 Nov 2015
Function    : This class contains test coverage for Core_IPS_CaseTriggerHandler class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_CaseTriggerHandler class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/06/2015                 Created
* Deepak Jetty              25/01/2016                 Modified
****************************************************************************************************/   
@isTest
public class Core_IPS_CaseTriggerHandler_Test{
    //Instance variables that are commonly used in multiple test methods
    static List<User> ListOfUser = new List<User> ();
    static Group grp = new Group();
    static Core_IPS_Product_Issue_Category__c caseCat = new Core_IPS_Product_Issue_Category__c();
    static  Core_IPS_Product_Issue_Category__c subCategory = new Core_IPS_Product_Issue_Category__c();
/***************************************************************************************************
Method Name:  getRecords()
Method Type: void
Version     : 1.0 
Created Date: 05 Nov 2015
Description:  Common Test data used for all test methods
Scenario Type:  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/05/2015              Created
****************************************************************************************************/
    static void getRecords (){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(2);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        System.runAs(ListOfUser.get(0)){
            //Create Group
            grp = TestUtilities.getQueue();
            grp.Type='Regular';
            insert grp;
            //Create Group Members
            List<GroupMember> ListGM = new List<GroupMember>();
            for(User usr:ListOfUser){
                GroupMember GM = new GroupMember();
                GM.GroupId = grp.Id;
                GM.UserOrGroupId = usr.Id;
                ListGM.add(GM);
            }
            //insert Group Memebers
            if(!ListGM.isEmpty()){
                insert ListGM;
            }
            List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
            insert ListofIpsLables;
            System.assert(ListofIpsLables[0].Id != null, 'Records not created');
            //Custom Setting - Ips Error Codes
            List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
            insert ListofIpsErrorCodes;
            System.assert(ListofIpsErrorCodes[0].Id != null, 'Records not created');
            //Custom Setting - Trigger Executions
            List<Core_Trigger_Executions__c> ListOfTriggerExecutions = TestUtilities.getListOfTriggerExecutions();
            insert ListOfTriggerExecutions;
            System.assert(ListOfTriggerExecutions[0].Id != null, 'Records not created');
            
                    }
    }

/***************************************************************************************************
Method Name: exerciseloadGroupByName_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 8/2/2016
Description:  Exercise the loadGroupByName function to obtain 85% coverage BKM
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews            8/2/2016                 Created
****************************************************************************************************/
    static testmethod void exerciseloadGroupByName_Test(){
        final String GROUP_NAME_TEXT = 'ORG_1';
        
        Map<String,Group> mapGroupByName = new Map<String,Group>();
        
        Core_IPS_CaseTriggerHandler.loadGroupByName(NULL, mapGroupByName);

        mapGroupByName.put(GROUP_NAME_TEXT, new Group());    
        Core_IPS_CaseTriggerHandler.loadGroupByName(NULL, NULL);
        Core_IPS_CaseTriggerHandler.loadGroupByName(NULL, mapGroupByName);
        Core_IPS_CaseTriggerHandler.loadGroupByName(GROUP_NAME_TEXT, mapGroupByName);        

        Group simpleGroup = new Group(Name=GROUP_NAME_TEXT, DeveloperName=GROUP_NAME_TEXT);
        insert simpleGroup;
        
        mapGroupByName.clear();
        Core_IPS_CaseTriggerHandler.loadGroupByName(GROUP_NAME_TEXT, mapGroupByName);        
        
    }
        
/***************************************************************************************************
Method Name:  assignEntitlementToCaseWithEntCon_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 06 Nov 2015
Description:  Testing with EntitlementContact record
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/06/2015                Created
* Deepak Jetty              25/01/2016                Modified
****************************************************************************************************/
    static testmethod void assignEntitlementToCaseWithEntCon_Test(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        System.runAs(ListOfUser.get(1)){
            // Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');
            // Create Asset
            list<Asset> AssetList = TestUtilities.getAssetList(1);
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
            }
            insert AssetList;
            System.assert(AssetList[0].Id != null, 'Record not created');
            // Create Entitlement
            List<Entitlement> ListOfEntitlement = TestUtilities.getListOfEntitlement(1);
            for(Entitlement EntitlementRec : ListOfEntitlement){
                EntitlementRec.AccountId = ListOfAccounts.get(0).Id;
                EntitlementRec.AssetId = AssetList.get(0).id;
            }
            insert ListOfEntitlement;
            System.assert(ListOfEntitlement[0].Id != null, 'Record not created');
            // Create EntitlementContact
            List<EntitlementContact> ListOfEntitlementContact = TestUtilities.getListOfEntitlementContact(1);
            for(EntitlementContact EntitlementContactRec : ListOfEntitlementContact){
                EntitlementContactRec.ContactId = ListOfContacts.get(0).Id;
                EntitlementContactRec.EntitlementId = ListOfEntitlement.get(0).id;
            }
            insert ListOfEntitlementContact;
            System.assert(ListOfEntitlementContact[0].Id != null, 'Record not created');
            // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(10);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
            }
            //get Business Hours
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Core_IPS_Q_Biz_hours_mapping__c QueueXBizHours = TestUtilities.getQueueXBizHours();
            QueueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            QueueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            QueueXBizHours.Queue_ID__c = grp.Id;
            QueueXBizHours.Queue_Name__c = grp.Name;
            //insert Queue Business Hours
            insert QueueXBizHours;
            Test.startTest();
            insert ListOfCases;
            System.assert(ListOfCases[0].Id != null, 'Record not created');
            update ListOfCases;
            List<Case> ListOfCase = [select id from case where id IN: ListOfCases];
            System.assert(ListOfCase[0].id != null, 'Record not updated');
            delete ListOfCase;
            List<Case> ListOfCase_Delete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase_Delete.isEmpty(), 'Record not deleted');
            undelete ListOfCase;
            List<Case> ListOfCase_UnDelete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase[0].id != null, 'Record not Undeleted');
            Test.stopTest();
        }
    }
    
/***************************************************************************************************
Method Name:  assignEntitlementToCaseWithoutEntCon_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 06 Nov 2015
Description:  Testing without EntitlementContact record
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/06/2015                Created
* Deepak Jetty              25/01/2016                Modified
****************************************************************************************************/
    static testmethod void assignEntitlementToCaseWithoutEntCon_Test(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        System.runAs(ListOfUser.get(1)){
            // Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');
            // Create Asset
            list<Asset> AssetList = TestUtilities.getAssetList(1);
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
            }
            insert AssetList;
            System.assert(AssetList[0].Id != null, 'Record not created');
            // Create Entitlement
            List<Entitlement> ListOfEntitlement = TestUtilities.getListOfEntitlement(1);
            for(Entitlement EntitlementRec : ListOfEntitlement){
                EntitlementRec.AccountId = ListOfAccounts.get(0).Id;
                EntitlementRec.AssetId = AssetList.get(0).id;
            }
            insert ListOfEntitlement;
            System.assert(ListOfEntitlement[0].Id != null, 'Record not created');
            // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(10);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
            }
            //get Business Hours
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Core_IPS_Q_Biz_hours_mapping__c QueueXBizHours = TestUtilities.getQueueXBizHours();
            QueueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            QueueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            QueueXBizHours.Queue_ID__c = grp.Id;
            QueueXBizHours.Queue_Name__c = grp.Name;
            //insert Queue Business Hours
            insert QueueXBizHours;
            Test.startTest();
            insert ListOfCases;
            System.assert(ListOfCases[0].Id != null, 'Record not created');
            update ListOfCases;
            List<Case> ListOfCase = [select id from case where id IN: ListOfCases];
            System.assert(ListOfCase[0].id != null, 'Record not updated');
            delete ListOfCase;
            List<Case> ListOfCase_Delete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase_Delete.isEmpty(), 'Record not deleted');
            undelete ListOfCase;
            List<Case> ListOfCase_UnDelete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase[0].id != null, 'Record not Undeleted');
            Test.stopTest();
        }
    }

/***************************************************************************************************
Method Name:  assignEntitlementToCase_NegativeTest
Method Type: Test Method
Version     : 1.0 
Created Date: 06 Nov 2015
Description:  Testing without Entitlement and EntitlementContact record
Scenario Type: Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/06/2015                Created
* Deepak Jetty              25/01/2016                Modified
****************************************************************************************************/
    static testmethod void assignEntitlementToCase_NegativeTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        System.runAs(ListOfUser.get(1)){
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');
            // Create Asset
            list<Asset> AssetList = TestUtilities.getAssetList(1);
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
            }
            insert AssetList;
            System.assert(AssetList[0].Id != null, 'Record not created');
            // Create Entitlement
            List<Entitlement> ListOfEntitlement = TestUtilities.getListOfEntitlement(1);
            for(Entitlement EntitlementRec : ListOfEntitlement){
                EntitlementRec.AccountId = ListOfAccounts.get(0).Id;
                EntitlementRec.AssetId = AssetList.get(0).id;
            }
            insert ListOfEntitlement;
            System.assert(ListOfEntitlement[0].Id != null, 'Record not created');
            //get Business Hours
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Core_IPS_Q_Biz_hours_mapping__c QueueXBizHours = TestUtilities.getQueueXBizHours();
            QueueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            QueueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            QueueXBizHours.Queue_ID__c = grp.Id;
            QueueXBizHours.Queue_Name__c = grp.Name;
            //insert Queue Business Hours
            insert QueueXBizHours;
            //Create Custom IPS Lables
            Core_IPS_Labels__c    IpsLabels = new Core_IPS_Labels__c();
            IpsLabels.Name = ListOfEntitlement.get(0).id;
            IpsLabels.Value__c = 'SelfAssignedCaseEntitlementId';
            //Insert IPS Labels
            insert IpsLabels;
            // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(10);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
            }
            Test.startTest();
            insert ListOfCases;
            System.assert(ListOfCases[0].Id != null, 'Record not created');
            update ListOfCases;
            List<Case> ListOfCase = [select id from case where id IN: ListOfCases];
            System.assert(ListOfCase[0].id != null, 'Record not updated');
            delete ListOfCase;
            List<Case> ListOfCase_Delete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase_Delete.isEmpty(), 'Record not deleted');
            undelete ListOfCase;
            List<Case> ListOfCase_UnDelete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase[0].id != null, 'Record not Undeleted');
            Test.stopTest();
        }
    } 
    
/***************************************************************************************************
Method Name:  assignCaseInformation_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 06 Nov 2015
Description:  Testing "assignCaseInformation" method. "assignCaseInformation" method invokes "getCaseInformationByAssetOrSuppProd" method. And hence "getCaseInformationByAssetOrSuppProd" method is also covered in this test class.
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/06/2015                Created
* Deepak Jetty              25/01/2016                Modified
***************************************************************************************************/
    static testmethod void assignCaseInformation_Test(){
        
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        System.runAs(ListOfUser.get(1)){ 
            // Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
            for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.core_ips_Active__c=true;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');
            
            //Insert Custom Setting
            Core_IPS_Labels__c setting = new Core_IPS_Labels__c();
            List<RecordType> settingID = [SELECT Id, Name, DeveloperName, Description, SobjectType FROM RecordType where SobjectType  ='Case' AND Name = 'IPS GEC ReadOnly' Limit 1];
            setting.Name = 'GEC Record Type Id';
            setting.Value__c = settingID[0].id;
            insert setting;
            
            // Create Support Org
            List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert ListOfSupportOrg;
            System.assert(ListOfSupportOrg != null, 'Record not created');
            integer counter = 0;
            // Create Product
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
            for(Product2 Product : ListOfProducts){
                if(counter==0){
                    Product.Core_Hierarchy_ID__c = '43';
                    Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                    Product.Core_Unique_ID__c = 'Product12345';
                    Product.Core_Code_Name__c = 'ProductCoreCodeName';
                }else{
                    Product.Core_Hierarchy_ID__c = '59';
                    Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                    Product.Core_Unique_ID__c = 'Product59';
                    Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                    
                }
                counter++;
            }
            insert ListOfProducts;
            
            System.assert(ListOfProducts[0].id != null,'Record not created');
            counter = 0;
            // Create Supported product
            List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
            for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
                if(counter==0){
                    SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                    SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                }else{
                    SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                    SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
                }
                counter++;
            }
            
            insert ListOfSupportedProduct;
            System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
            counter = 0;
            // Create Flat Product Hierarchy
            List<Core_Flat_Product_Hierarchy__c> ListOfFlatProductHierarchy = TestUtilities.getListOfFlatProductHierarchy(10);
            for(Core_Flat_Product_Hierarchy__c FlatProductHierarchy : ListOfFlatProductHierarchy){
                if(counter < 5){
                    FlatProductHierarchy.Core_EPM_Hierarchy_ID__c = ListOfProducts.get(0).Core_Hierarchy_ID__c;
                    FlatProductHierarchy.Core_EPM_Hierarchy_Name__c = ListOfProducts.get(0).Core_Hierarchy_Name__c;
                    FlatProductHierarchy.Core_L5_EPM_ID__c = ListOfProducts.get(0).Core_Unique_ID__c;
                }
                else{
                    FlatProductHierarchy.Core_EPM_Hierarchy_ID__c = ListOfProducts.get(1).Core_Hierarchy_ID__c;
                    FlatProductHierarchy.Core_EPM_Hierarchy_Name__c = ListOfProducts.get(1).Core_Hierarchy_Name__c;
                    FlatProductHierarchy.Core_L4_EPM_ID__c = ListOfProducts.get(1).Core_Unique_ID__c;
                }
                counter++;
            }
            
            insert ListOfFlatProductHierarchy;
            System.assert(ListOfFlatProductHierarchy[0].id != null,'Record not created');
            counter = 0;
            // Create Asset
            list<Asset> AssetList = TestUtilities.getAssetList(2);
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
                if(counter==0){
                    Asst.core_product_organization__c = ListOfSupportOrg.get(0).id;
                    Asst.core_supported_product__c = ListOfSupportedProduct.get(0).id;
                    Asst.product2Id = ListOfProducts.get(0).id;
                }else{
                    Asst.core_product_organization__c = ListOfSupportOrg.get(1).id;
                    Asst.core_supported_product__c = ListOfSupportedProduct.get(1).id;
                    Asst.product2Id = ListOfProducts.get(1).id;
                }
                counter++;
            }
            insert AssetList;
            System.assert(AssetList[0].Id != null, 'Record not created');
            counter = 0;
            // Create Ips Project
            List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
            
            insert ListOfIpsProjects;
            System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
            // Create Ips Account
            Counter=0;
            List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
            for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
                if(counter<1){
                    IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                    IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                } else {
                    IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                    IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(1).Id;
                }
                counter++;
            }
            counter = 0;
            
            insert ListOfIpsAccounts;
            System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
            // Create Project Member
            List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(5);
            for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
                If(counter<3){
                ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
                ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                ProjMem.Core_User__c = intelSupportOwner;
                }else{
                    ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
                ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(1).Id;
                ProjMem.Core_User__c = intelSupportOwner;
                }
                
            }
            insert ListOfProjectMembers;
            
            System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
            // Create Case
            counter=0;
            //Id ipsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId();
            
            List<Case> ListOfCases = TestUtilities.getListOfCases(5);
           
            for(Case CaseRec : ListOfCases){
                //CaseRec.recordtypeid =ipsRecordTypeId;
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                caseRec.Core_Issue_Description__c ='testing cases ';
                caseRec.Description='testing cases';
                caseRec.status='closed';
                caseRec.Core_IPS_Is_Notification_Active__c =true;
                caseRec.Core_IPS_GEC_Flag__c = true;
                //caseRec.Core_Request_Case_Close__c ='Close Case';
                
                if(counter < 2){
                    CaseRec.assetId = AssetList.get(0).Id;
                    // CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                    CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id; 
                }
                else if(counter>=2 && counter <5){
                    CaseRec.assetId = AssetList.get(1).Id;
                    CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                }
                else{
                    CaseRec.assetId = AssetList.get(1).Id;
                    CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                    CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id; 
                }
                     
                counter++;
            }
            
            //get Business Hours
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Core_IPS_Q_Biz_hours_mapping__c QueueXBizHours = TestUtilities.getQueueXBizHours();
            QueueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            QueueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            QueueXBizHours.Queue_ID__c = grp.Id;
            QueueXBizHours.Queue_Name__c = grp.Name;
            test.startTest();
            //insert Queue Business Hours
            insert QueueXBizHours;
           
            insert ListOfCases;
            
            System.assert(ListOfCases[0].Id != null, 'Record not created');
            counter = 0;
            
            for(Case CaseRec1 : ListOfCases){
                caseRec1.status='Open';
                CaseRec1.Core_Issue_Description__c ='testing cases update ';
                CaseRec1.Description='testing cases update';
                if(counter < 2){
                    CaseRec1.Core_IPS_GEC_Case__c=true;
                    //CaseRec1.Core_IPS_GEC_Status__c = 'Approved';
                    //CaseRec1.Core_IPS_Project_Case__c = ListOfIpsProjects.get(1).id;
                }
                else if(counter>=2 && counter <5){
                    CaseRec1.assetId = AssetList.get(1).Id;
                    CaseRec1.Core_IPS_Project_Case__c = null;
                }
                else{
                   // CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(1).id;
                    CaseRec1.AccountId = ListOfAccounts.get(1).id;
                }
                //if( counter == 9)
                //    CaseRec1.Core_IPS_GEC_Flag__c = true;
                    
                counter++;
            }
            
            counter = 0;
            Core_CaseTrigger_Dispatcher.recursivetrigger=true;
            Core_CaseTrigger_Dispatcher.recursivetrigger1=true;            
            update ListOfCases;
            
            //System.debug('The value is1: ' + CaseRec.Core_Sub_Status__c);
            List<Case> ListOfCase = [select id from case where id IN: ListOfCases];
            System.assert(ListOfCase[0].id != null, 'Record not updated');
            delete ListOfCase;
            List<Case> ListOfCase_Delete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase_Delete.isEmpty(), 'Record not deleted');
            undelete ListOfCase;
            Test.stopTest();
            //List<Case> ListOfCase_UnDelete = [select id from case where id IN: ListOfCase];
            //System.assert(ListOfCase[0].id != null, 'Record not Undelete');
            
        
        }
    }
    
/***************************************************************************************************
Method Name:  caseSLAManagement_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 06 Nov 2015
Description:  Testing caseSLAManagement method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/06/2015                Created
* Deepak Jetty              25/01/2016                Modified
****************************************************************************************************/
    static testmethod void caseSLAManagement_Test(){
        getRecords();
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and name = 'IPS GEC ReadOnly'];
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        System.runAs(ListOfUser.get(0)){
            // Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');
            // Create Asset
            list<Asset> AssetList = TestUtilities.getAssetList(1);
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
            }
            insert AssetList;
            System.assert(AssetList[0].Id != null, 'Record not created');
            // Create Entitlement
            List<Entitlement> ListOfEntitlement = TestUtilities.getListOfEntitlement(1);
            for(Entitlement EntitlementRec : ListOfEntitlement){
                EntitlementRec.AccountId = ListOfAccounts.get(0).Id;
                EntitlementRec.AssetId = AssetList.get(0).id;
            }
            insert ListOfEntitlement;
            System.assert(ListOfEntitlement[0].Id != null, 'Record not created');
            // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(10);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                caseRec.Core_Next_Response_Due_Date__c= Date.valueOf('2008-01-01 00:00:00');
                caseRec.Core_Sub_Status__c = 'Waiting for Customer Clarification*';
                caseRec.Core_Issue_Description__c = 'Test';
                caseRec.Core_IPS_GEC_Case__c = true;
            }
            //get Business Hours
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Core_IPS_Q_Biz_hours_mapping__c QueueXBizHours = TestUtilities.getQueueXBizHours();
            QueueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            QueueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            QueueXBizHours.Queue_ID__c = grp.Id;
            QueueXBizHours.Queue_Name__c = grp.Name;
            //insert Queue Business Hours
            insert QueueXBizHours;
            Core_IPS_Labels__c ipsLabel = new Core_IPS_Labels__c();
            ipsLabel.Name = 'GEC Record Type Id';
            ipsLabel.Value__c = RT.id;
            insert ipsLabel;
            Test.startTest();            
            insert ListOfCases;
            System.assert(ListOfCases[0].Id != null, 'Record not created');
            
            List<Casemilestone> cst = new List<Casemilestone>();    
            List<Casemilestone> csmstone = [Select caseid, StartDate,CompletionDate from Casemilestone where caseid in :ListOfCases];
            for(CaseMilestone cs :csmstone){
                cs.StartDate = system.today()-1;
                cs.CompletionDate = null;
                cst.add(cs);
            }
            update cst;
            
            
            List<Case> ListOfCase = [select isStopped, Core_Sub_Status__c from case where id IN: ListOfCases];
            integer counter = 0;
            for(Case CaseRec : ListOfCase){
                CaseRec.isStopped = false;
                caseRec.Core_Issue_Description__c = 'Test1';
                caseRec.Core_IPS_GEC_Case__c = false;
                caseRec.Core_Next_Response_Due_Date__c= Date.valueOf('2017-06-05 00:00:00');
                if(counter < 5){
                    CaseRec.Core_Sub_Status__c = 'Investigating';
                    CaseRec.RecordTypeId = RT.id;
                }else{
                    CaseRec.Core_Sub_Status__c = 'Investigating';
                    CaseRec.RecordTypeId = RT.id;
                    
                }
                counter++;
            }
            counter = 0;
            update ListOfCase;
            List<Case> ListOfCas = [select Core_Sub_Status__c, RecordTypeId from case where id IN: ListOfCase];
            System.assertEquals(ListOfCas[0].RecordTypeId,  RT.id);
            delete ListOfCas;
            List<Case> ListOfCase_Delete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase_Delete.isEmpty(), 'Record not deleted');
            undelete ListOfCas;
            List<Case> ListOfCase_UnDelete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCas[0].id != null, 'Record not Undelete');
            Test.stopTest();
            List<Casemilestone> cml = [Select caseid, StartDate,CompletionDate from Casemilestone];
            system.debug('  SK :'+cml);
        }
    }
    
/***************************************************************************************************
Method Name:  caseSLAManagementwithCaseRecordType_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 06 Nov 2015
Description:  Testing caseSLAManagement method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              28/01/2016                Created
****************************************************************************************************/
    static testmethod void caseSLAManagementwithCaseRecordType_Test(){
        getRecords();
        RecordType RT = [Select Name, Id From RecordType where sObjectType='Case' and name = 'IPS GEC ReadOnly'];
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        System.runAs(ListOfUser.get(0)){
            // Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');
            // Create Asset
            list<Asset> AssetList = TestUtilities.getAssetList(1);
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
            }
            insert AssetList;
            System.assert(AssetList[0].Id != null, 'Record not created');
            // Create Entitlement
            List<Entitlement> ListOfEntitlement = TestUtilities.getListOfEntitlement(1);
            for(Entitlement EntitlementRec : ListOfEntitlement){
                EntitlementRec.AccountId = ListOfAccounts.get(0).Id;
                EntitlementRec.AssetId = AssetList.get(0).id;
            }
            insert ListOfEntitlement;
            System.assert(ListOfEntitlement[0].Id != null, 'Record not created');
            // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(10);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                CaseRec.RecordTypeId = RT.id;
            }
            //get Business Hours
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Core_IPS_Q_Biz_hours_mapping__c QueueXBizHours = TestUtilities.getQueueXBizHours();
            QueueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            QueueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            QueueXBizHours.Queue_ID__c = grp.Id;
            QueueXBizHours.Queue_Name__c = grp.Name;
            //insert Queue Business Hours
            insert QueueXBizHours;
            Core_IPS_Labels__c ipsLabel = new Core_IPS_Labels__c();
            ipsLabel.Name = 'GEC Record Type Id';
            ipsLabel.Value__c = RT.id;
            insert ipsLabel;
            Test.startTest();            
            insert ListOfCases;
            System.assert(ListOfCases[0].Id != null, 'Record not created');
            List<Case> ListOfCase = [select isStopped, Core_Sub_Status__c from case where id IN: ListOfCases];
            integer counter = 0;
            for(Case CaseRec : ListOfCase){
                CaseRec.isStopped = true;
                if(counter < 5){
                    CaseRec.Core_Sub_Status__c = 'Investigating';
                }else{
                    CaseRec.Core_Sub_Status__c = 'Investigating';
                }
                counter++;
            }
            counter = 0;
            update ListOfCase;
            List<Case> ListOfCas = [select Core_Sub_Status__c, RecordTypeId from case where id IN: ListOfCase];
            System.assertEquals(ListOfCas[0].Core_Sub_Status__c,  'Investigating');
            delete ListOfCas;
            List<Case> ListOfCase_Delete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase_Delete.isEmpty(), 'Record not deleted');
            undelete ListOfCas;
            List<Case> ListOfCase_UnDelete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCas[0].id != null, 'Record not Undelete');
            Test.stopTest();
        }
    }
    
/***************************************************************************************************
Method Name:  executeCaseAssignmentRule_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 06 Nov 2015
Description:  Testing executeCaseAssignmentRule method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/06/2015                Created
* Deepak Jetty              25/01/2016                Modified
****************************************************************************************************/
    static testmethod void executeCaseAssignmentRule_Test(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        System.runAs(ListOfUser.get(1)){
            // Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');
            // Create Product
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
            insert ListOfProducts;
            system.debug('JD*********--->'+ ListOfProducts.get(0).id);
            system.debug('JD*********--->'+ ListOfProducts.get(1).id);
            System.assert(ListOfProducts[0].id != null,'Record not created');
            // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(10);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                //CaseRec.ProductId = ListOfProducts.get(0).id;
            }
            //get Business Hours
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Core_IPS_Q_Biz_hours_mapping__c QueueXBizHours = TestUtilities.getQueueXBizHours();
            QueueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            QueueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            QueueXBizHours.Queue_ID__c = grp.Id;
            QueueXBizHours.Queue_Name__c = grp.Name;
            //insert Queue Business Hours
            insert QueueXBizHours;
            Test.startTest();
            insert ListOfCases;
            Core_CaseTrigger_Dispatcher.triggerAssignmentRule = true;
            System.assert(ListOfCases[0].Id != null, 'Record not created');
            integer counter = 0;
            for(Case CaseRec : ListOfCases){
                if(counter < 5){
                    CaseRec.ProductId = ListOfProducts.get(0).id;
                }else{
                    CaseRec.ProductId = ListOfProducts.get(1).id;
                }
                counter++;
            }
            counter = 0;
            update ListOfCases;
            List<Case> ListOfCase = [select ProductId from case where id IN: ListOfCases];
            System.assert(ListOfCase[0].ProductId != null, 'Record not updated with product id');
            delete ListOfCase;
            List<Case> ListOfCase_Delete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase_Delete.isEmpty(), 'Record not deleted');
            undelete ListOfCase;
            List<Case> ListOfCase_UnDelete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase[0].id != null, 'Record not Undelete');
            Test.stopTest();
        }
    }
    
/***************************************************************************************************
Method Name:  ProvideCaseAccess_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 06 Nov 2015
Description:  Testing ProvideCaseAccess method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/06/2015                Created
****************************************************************************************************/
    static testmethod void ProvideCaseAccess_Test(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        System.runAs(ListOfUser.get(1)){
            // Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');
            // Create Ips Project
            List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            insert ListOfIpsProjects;
            System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
            // Create Ips Account
            List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            }
            insert ListOfIpsAccounts;
            System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
            // Create Project Member
            List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(1);
            for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
                ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
                ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                ProjMem.Core_User__c = intelSupportOwner;
            }
            insert ListOfProjectMembers;
            System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
            // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(10);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
            }
            //get Business Hours
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Core_IPS_Q_Biz_hours_mapping__c QueueXBizHours = TestUtilities.getQueueXBizHours();
            QueueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            QueueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            QueueXBizHours.Queue_ID__c = grp.Id;
            QueueXBizHours.Queue_Name__c = grp.Name;
            //insert Queue Business Hours
            insert QueueXBizHours;
            Test.startTest();
            insert ListOfCases;
            Core_CaseTrigger_Dispatcher.triggerAssignmentRule = true;
            System.assert(ListOfCases[0].Id != null, 'Record not created');
            integer counter = 0;
            for(Case CaseRec : ListOfCases){
                if(counter < 5){
                    CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                }else{
                    CaseRec.AccountId = ListOfAccounts.get(0).id;
                }
                counter++;
            }
            counter = 0;
            update ListOfCases;
            List<Case> ListOfCase = [select id from case where id IN: ListOfCases];
            System.assert(ListOfCase[0].id != null, 'Record not updated');
            delete ListOfCase;
            List<Case> ListOfCase_Delete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase_Delete.isEmpty(), 'Record not deleted');
            undelete ListOfCase;
            List<Case> ListOfCase_UnDelete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase[0].id != null, 'Record not Undeleted');
            Test.stopTest();
        }
    }
    
/***************************************************************************************************
Method Name:  assignMigratedCaseInformation_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 27 Jan 2016
Description:  Testing assignMigratedCaseInformation method
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/
    static testmethod void assignMigratedCaseInformation_Test(){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('IPS Data Migration');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(2);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(1).ProfileID =  profiles.get('IPS Data Migration');
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        System.assertEquals(ListOfUser.get(1).profileid, profiles.get('IPS Data Migration'));
        System.runAs(ListOfUser.get(0)){
             // Create Ips Labels added by Aayushi US79852    
       List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();    
       for(Core_IPS_Labels__c IL: IPSLabels){    
           if(IL.name=='ProjectGroupPrefix'){    
                IL.Value__c = 'IPS_Proj_';    
           }    
            if(IL.name=='CoreStatus_SPtoActive_Error'){    
                IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';    
            }    
            if(IL.name=='Core_OneProjProdMem_Error'){    
               IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';    
           }    
           if(IL.name=='CoreStatus_Draft'){    
              IL.Value__c = 'Draft';     
           }    
           if(IL.name=='CoreStatus_Active'){    
              IL.Value__c = 'Active' ;    
           }    
           if(IL.name=='CoreStatus_Inactive'){    
              IL.Value__c = 'Inactive' ;    
           }    
           if(IL.name=='CoreStatus_SP'){    
              IL.Value__c = 'Submitted Pending' ;    
           }    
       }    
          
           Insert IPSLabels;
            //Create Group
            grp = TestUtilities.getQueue();
            grp.Type='Regular';
            insert grp;
            //Create Group Members
            List<GroupMember> ListGM = new List<GroupMember>();
            for(User usr:ListOfUser){
                GroupMember GM = new GroupMember();
                GM.GroupId = grp.Id;
                GM.UserOrGroupId = usr.Id;
                ListGM.add(GM);
            }
            //insert Group Memebers
            if(!ListGM.isEmpty()){
                insert ListGM;
            }
            
        }
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(1).id;
        List<Account> ListOfAccounts=new List<Account>();
        System.runAs(ListOfUser.get(0)){
            // Create Accounts
             ListOfAccounts = TestUtilities.getListOfAccounts(1);
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        }
        
        System.runAs(ListOfUser.get(1)){
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts;
            // Create Ips Project
            List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            insert ListOfIpsProjects;
            System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
            // Create Ips Account
            List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            }
            insert ListOfIpsAccounts;
            System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
            // Create Project Member
            List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(1);
            for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
                ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
                ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                ProjMem.Core_User__c = intelSupportOwner;
            }
            insert ListOfProjectMembers;
            System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
            // Create Support Org
            List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert ListOfSupportOrg;
            System.assert(ListOfSupportOrg != null, 'Record not created');
            integer counter = 0;
            // Create Product
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
            for(Product2 Product : ListOfProducts){
                if(counter==0){
                    Product.Core_Hierarchy_ID__c = '43';
                    Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                    Product.Core_Unique_ID__c = 'Product12345';
                    Product.Core_Code_Name__c = 'ProductCoreCodeName';
                }else{
                    Product.Core_Hierarchy_ID__c = '59';
                    Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                    Product.Core_Unique_ID__c = 'Product59';
                    Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                    
                }
                counter++;
            }
            insert ListOfProducts;
            System.assert(ListOfProducts[0].id != null,'Record not created');
            counter = 0;
            // Create Supported product
            List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
            for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
                if(counter==0){
                    SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                    SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                }else{
                    SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                    SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
                }
                counter++;
            }
            insert ListOfSupportedProduct;
            System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
            // Create Asset
            list<Asset> AssetList = TestUtilities.getAssetList(2);
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
                if(counter==0){
                    Asst.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                    Asst.AccountId = ListOfAccounts.get(0).id;
                    Asst.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                    Asst.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                    Asst.product2Id = ListOfProducts.get(0).id;
                }else{
                    Asst.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                    Asst.AccountId = ListOfAccounts.get(0).id;
                    Asst.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
                    Asst.Core_Supported_Product__c = ListOfSupportedProduct.get(1).id;
                    Asst.product2Id = ListOfProducts.get(1).id;
                }
                counter++;
            }
            insert AssetList;
            System.assert(AssetList[0].Id != null, 'Record not created');
            
            counter = 0;
            // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(10);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                if(counter < 5){
                    //CaseRec.assetId = AssetList.get(0).Id;
                    CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                    CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                    CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(1).id;
                }else{
                    //CaseRec.assetId = AssetList.get(0).Id;
                    CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id;
                    CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                    CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(1).id;
                }
                counter++;
            }
            //get Business Hours
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Core_IPS_Q_Biz_hours_mapping__c QueueXBizHours = TestUtilities.getQueueXBizHours();
            QueueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            QueueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            QueueXBizHours.Queue_ID__c = grp.Id;
            QueueXBizHours.Queue_Name__c = grp.Name;
            //insert Queue Business Hours
            insert QueueXBizHours;
            Core_CaseTrigger_Dispatcher.triggerAssignmentRule = true;
            Test.startTest();
            insert ListOfCases;
            System.assert(ListOfCases[0].Id != null, 'Record not created');          
            update ListOfCases;
            List<Case> ListOfCase = [select id from case where id IN: ListOfCases];
            System.assert(ListOfCase[0].id != null, 'Record not updated');
            delete ListOfCase;
            List<Case> ListOfCase_Delete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase_Delete.isEmpty(), 'Record not deleted');
            undelete ListOfCase;
            List<Case> ListOfCase_UnDelete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase[0].id != null, 'Record not Undelete');
            Test.stopTest();
        }
    }
    
/***************************************************************************************************
Method Name:  assignMigratedCaseInformationwithoutAccandProj_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 27 Jan 2016
Description:  Testing assignMigratedCaseInformation method
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/
    static testmethod void assignMigratedCaseInformationwithoutAccandProj_Test(){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('IPS Data Migration');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(2);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(1).ProfileID =  profiles.get('IPS Data Migration');
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        System.assertEquals(ListOfUser.get(1).profileid, profiles.get('IPS Data Migration'));
        System.runAs(ListOfUser.get(0)){
             // Create Ips Labels added by Aayushi US79852    
       List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();    
       for(Core_IPS_Labels__c IL: IPSLabels){    
           if(IL.name=='ProjectGroupPrefix'){    
                IL.Value__c = 'IPS_Proj_';    
           }    
            if(IL.name=='CoreStatus_SPtoActive_Error'){    
                IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';    
            }    
            if(IL.name=='Core_OneProjProdMem_Error'){    
               IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';    
           }    
           if(IL.name=='CoreStatus_Draft'){    
              IL.Value__c = 'Draft';     
           }    
           if(IL.name=='CoreStatus_Active'){    
              IL.Value__c = 'Active' ;    
           }    
           if(IL.name=='CoreStatus_Inactive'){    
              IL.Value__c = 'Inactive' ;    
           }    
           if(IL.name=='CoreStatus_SP'){    
              IL.Value__c = 'Submitted Pending' ;    
           }    
       }    
          
           Insert IPSLabels;
            //Create Group
            grp = TestUtilities.getQueue();
            grp.Type='Regular';
            insert grp;
            //Create Group Members
            List<GroupMember> ListGM = new List<GroupMember>();
            for(User usr:ListOfUser){
                GroupMember GM = new GroupMember();
                GM.GroupId = grp.Id;
                GM.UserOrGroupId = usr.Id;
                ListGM.add(GM);
            }
            //insert Group Memebers
            if(!ListGM.isEmpty()){
                insert ListGM;
            }
            
        }
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(1).id;
        List<Account> ListOfAccounts=new List<Account>();
        System.runAs(ListOfUser.get(0)){
            // Create Accounts
            ListOfAccounts = TestUtilities.getListOfAccounts(1);
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        }
        System.runAs(ListOfUser.get(1)){
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts;
            // Create Ips Project
            List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            insert ListOfIpsProjects;
            System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
            // Create Ips Account
            List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            }
            insert ListOfIpsAccounts;
            System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
            // Create Project Member
            List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(1);
            for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
                ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
                ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                ProjMem.Core_User__c = intelSupportOwner;
            }
            insert ListOfProjectMembers;
            System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
            // Create Support Org
            List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert ListOfSupportOrg;
            System.assert(ListOfSupportOrg != null, 'Record not created');
            integer counter = 0;
            // Create Product
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
            for(Product2 Product : ListOfProducts){
                if(counter==0){
                    Product.Core_Hierarchy_ID__c = '43';
                    Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                    Product.Core_Unique_ID__c = 'Product12345';
                    Product.Core_Code_Name__c = 'ProductCoreCodeName';
                }else{
                    Product.Core_Hierarchy_ID__c = '59';
                    Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                    Product.Core_Unique_ID__c = 'Product59';
                    Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                    
                }
                counter++;
            }
            insert ListOfProducts;
            System.assert(ListOfProducts[0].id != null,'Record not created');
            counter = 0;
            // Create Supported product
            List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
            for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
                if(counter==0){
                    SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                    SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                }else{
                    SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                    SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
                }
                counter++;
            }
            insert ListOfSupportedProduct;
            System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
            // Create Asset
            list<Asset> AssetList = TestUtilities.getAssetList(2);
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
                if(counter==0){
                    Asst.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                    Asst.AccountId = ListOfAccounts.get(0).id;
                    Asst.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                    Asst.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                    Asst.product2Id = ListOfProducts.get(0).id;
                }else{
                    Asst.Core_IPS_Project__c = ListOfIpsProjects.get(0).id;
                    Asst.AccountId = ListOfAccounts.get(0).id;
                    Asst.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
                    Asst.Core_Supported_Product__c = ListOfSupportedProduct.get(1).id;
                    Asst.product2Id = ListOfProducts.get(1).id;
                }
                counter++;
            }
            insert AssetList;
            System.assert(AssetList[0].Id != null, 'Record not created');
            
            counter = 0;
            // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(10);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                if(counter < 5){
                    //CaseRec.assetId = AssetList.get(0).Id;
                    CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                    CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(1).id;
                }else{
                    //CaseRec.assetId = AssetList.get(0).Id;
                    CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id;
                    CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(1).id;
                }
                counter++;
            }
            //get Business Hours
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Core_IPS_Q_Biz_hours_mapping__c QueueXBizHours = TestUtilities.getQueueXBizHours();
            QueueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            QueueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            QueueXBizHours.Queue_ID__c = grp.Id;
            QueueXBizHours.Queue_Name__c = grp.Name;
            //insert Queue Business Hours
            insert QueueXBizHours;
            Core_CaseTrigger_Dispatcher.triggerAssignmentRule = true;
            Test.startTest();
            insert ListOfCases;
            System.assert(ListOfCases[0].Id != null, 'Record not created');          
            update ListOfCases;
            List<Case> ListOfCase = [select id from case where id IN: ListOfCases];
            System.assert(ListOfCase[0].id != null, 'Record not updated');
            delete ListOfCase;
            List<Case> ListOfCase_Delete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase_Delete.isEmpty(), 'Record not deleted');
            undelete ListOfCase;
            List<Case> ListOfCase_UnDelete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase[0].id != null, 'Record not Undelete');
            Test.stopTest();
        }
    }
    
/***************************************************************************************************
Method Name:  assignMigratedCaseInformationwithoutProjectinAsset_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 27 Jan 2016
Description:  Testing assignMigratedCaseInformation method
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/
    static testmethod void assignMigratedCaseInformationwithoutProjectinAsset_Test(){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('IPS Data Migration');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(2);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(1).ProfileID =  profiles.get('IPS Data Migration');
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        System.assertEquals(ListOfUser.get(1).profileid, profiles.get('IPS Data Migration'));
        System.runAs(ListOfUser.get(0)){
             // Create Ips Labels added by Aayushi US79852  
       List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();    
       for(Core_IPS_Labels__c IL: IPSLabels){    
           if(IL.name=='ProjectGroupPrefix'){    
                IL.Value__c = 'IPS_Proj_';    
           }    
            if(IL.name=='CoreStatus_SPtoActive_Error'){    
                IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';    
            }    
            if(IL.name=='Core_OneProjProdMem_Error'){    
               IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';    
           }    
           if(IL.name=='CoreStatus_Draft'){    
              IL.Value__c = 'Draft';     
           }    
           if(IL.name=='CoreStatus_Active'){    
              IL.Value__c = 'Active' ;    
           }    
           if(IL.name=='CoreStatus_Inactive'){    
              IL.Value__c = 'Inactive' ;    
           }    
           if(IL.name=='CoreStatus_SP'){    
              IL.Value__c = 'Submitted Pending' ;    
           }    
       }    
          
           Insert IPSLabels;
            //Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'assignCaseInformation';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution.Core_Description__c = 'To update Support Level On Case.';
            TriggerExecution.Core_Object__c = 'Case';
            TriggerExecution.Core_Trigger_Events__c = 'before update';
            insert TriggerExecution; 
            //Create Group
            grp = TestUtilities.getQueue();
            grp.Type='Regular';
            insert grp;
            //Create Group Members
            List<GroupMember> ListGM = new List<GroupMember>();
            for(User usr:ListOfUser){
                GroupMember GM = new GroupMember();
                GM.GroupId = grp.Id;
                GM.UserOrGroupId = usr.Id;
                ListGM.add(GM);
            }
            //insert Group Memebers
            if(!ListGM.isEmpty()){
                insert ListGM;
            }
            
        }
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(1).id;
        List<Account> ListOfAccounts=new List<Account>();
        System.runAs(ListOfUser.get(0)){
            // Create Accounts
            ListOfAccounts = TestUtilities.getListOfAccounts(1);
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        }
        System.runAs(ListOfUser.get(1)){
            // Create Support Org
            List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert ListOfSupportOrg;
            System.assert(ListOfSupportOrg != null, 'Record not created');
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Core_IPS_Alternate_Support_Owner__c =intelSupportOwner;
                ContactRec.Core_IPS_Alternate_Support_Org__c = ListOfSupportOrg[0].id;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts;
            // Create Ips Project
            List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            insert ListOfIpsProjects;
            System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
            // Create Ips Account
            List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            }
            insert ListOfIpsAccounts;
            System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
            // Create Project Member
            List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(1);
            for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
                ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
                ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                ProjMem.Core_User__c = intelSupportOwner;
            }
            insert ListOfProjectMembers;
            System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
            
            integer counter = 0;
            // Create Product
            List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
            for(Product2 Product : ListOfProducts){
                if(counter==0){
                    Product.Core_Hierarchy_ID__c = '43';
                    Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                    Product.Core_Unique_ID__c = 'Product12345';
                    Product.Core_Code_Name__c = 'ProductCoreCodeName';
                }else{
                    Product.Core_Hierarchy_ID__c = '59';
                    Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                    Product.Core_Unique_ID__c = 'Product59';
                    Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                    
                }
                counter++;
            }
            insert ListOfProducts;
            System.assert(ListOfProducts[0].id != null,'Record not created');
            counter = 0;
            // Create Supported product
            List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
            for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
                if(counter==0){
                    SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                    SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                }else{
                    SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                    SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
                }
                counter++;
            }
            insert ListOfSupportedProduct;
            System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
            // Create Asset
            list<Asset> AssetList = TestUtilities.getAssetList(2);
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
                if(counter==0){
                    Asst.AccountId = ListOfAccounts.get(0).id;
                    Asst.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                    Asst.Core_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                    Asst.product2Id = ListOfProducts.get(0).id;
                }else{
                    Asst.AccountId = ListOfAccounts.get(0).id;
                    Asst.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
                    Asst.Core_Supported_Product__c = ListOfSupportedProduct.get(1).id;
                    Asst.product2Id = ListOfProducts.get(1).id;
                }
                counter++;
            }
            insert AssetList;
            System.assert(AssetList[0].Id != null, 'Record not created');
            
            counter = 0;
            // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(10);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                if(counter < 5){
                    //CaseRec.assetId = AssetList.get(0).Id;
                    CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                    CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(1).id;
                }else{
                    //CaseRec.assetId = AssetList.get(0).Id;
                    CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id;
                    CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(1).id;
                }
                counter++;
            }
            //get Business Hours
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            //Create Queue Business Hours
            Core_IPS_Q_Biz_hours_mapping__c QueueXBizHours = TestUtilities.getQueueXBizHours();
            QueueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
            QueueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
            QueueXBizHours.Queue_ID__c = grp.Id;
            QueueXBizHours.Queue_Name__c = grp.Name;
            //insert Queue Business Hours
            insert QueueXBizHours;
            Core_CaseTrigger_Dispatcher.triggerAssignmentRule = true;
            Test.startTest();
            insert ListOfCases;
            System.assert(ListOfCases[0].Id != null, 'Record not created');          
            update ListOfCases;
            List<Case> ListOfCase = [select id from case where id IN: ListOfCases];
            System.assert(ListOfCase[0].id != null, 'Record not updated');
            delete ListOfCase;
            List<Case> ListOfCase_Delete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase_Delete.isEmpty(), 'Record not deleted');
            undelete ListOfCase;
            List<Case> ListOfCase_UnDelete = [select id from case where id IN: ListOfCase];
            System.assert(ListOfCase[0].id != null, 'Record not Undelete');
            
            Test.stopTest();
        }
    }   
    
    public  static testmethod void loadGroupById_Test(){                        
                getRecords();
                Group grp1;
                System.runAs(ListOfUser.get(0)){  
                  grp1 = new Group(Name='Queue11',Type='Queue');
                  insert grp1;
                  //start added by Aayushi US89551
                  GroupMember grpMem1 = new GroupMember();
                  grpMem1.UserOrGroupId = ListOfUser.get(0).Id;
                  grpMem1.GroupId = grp1.Id;
                  Insert grpMem1;
                  //end
                  QueueSobject mappingObject = new QueueSobject(QueueId = grp1.Id, SobjectType = 'Case');
                  insert mappingObject;
                }
                  Id intelSupportOwner = ListOfUser.get(0).id;
                System.runAs(ListOfUser.get(1)){
                     List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
                    //Create Queue Business Hours
                    Core_IPS_Q_Biz_hours_mapping__c QueueXBizHours = TestUtilities.getQueueXBizHours();
                    QueueXBizHours.Business_Hours_ID__c = bhs.get(0).id;
                    QueueXBizHours.Business_Hours_Name__c = 'Ashok_Test';
                    QueueXBizHours.Queue_ID__c = grp.Id;
                    QueueXBizHours.Queue_Name__c = grp.Name;
                    insert QueueXBizHours;
                    List<Case> caseList = new List<Case>();
                    Account account =  new Account();
                    Contact con =  new Contact();
                    Entitlement ent = new Entitlement();
                    account = TestUtilities.getAccountRecord();
                    insert account;
                    caseList = TestUtilities.getListOfCases(10);
                    ent = TestUtilities.getEntitlementRecord();
                    ent.accountid = account.id;
                    ent.startdate = System.today()-1;
                    ent.endDate = system.today()+760;    
                    //ent.SlaProcessId = Core_IPS_Labels__c.getValues('IPS Standard Entitlement Process ID').Value__c;
                    insert ent;
                    //Added by Geetha as per  DE33659
                    //Creating MasterCaseCategory
                    Core_IPS_Master_Issue_Category__c MasterCaseCategory = TestUtilities.getMasterCaseCategories();
                    MasterCaseCategory.Core_type__c = 'Case Category';
                    insert MasterCaseCategory;
                    //Creating MasterCategory
                    Core_IPS_Master_Issue_Category__c MasterCategory = TestUtilities.getMasterCaseCategories();
                    MasterCategory.Core_Master_Issue_Category__c = MasterCaseCategory.id;            
                    insert MasterCategory;
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
                
                    recordtype Rtype = [select id from  recordtype where Name ='IPS case create'];
                    for(case cs:caseList){
                        cs.accountId = account.id;
                        cs.entitlementId = ent.Id;
                        cs.ownerId = grp1.Id;
                        cs.recordtypeId = Rtype.Id;
                        cs.Core_First_Response_Completed__c =false;
                        cs.Core_Case_Issue_Category__c = caseCat.id;
                        cs.Core_case_issue_sub_category__c = subCategory.id;

                    }
                    insert caseList;
                    Core_IPS_CaseTriggerHandler.loadGroupById(caseList);
                }
    }
    /***************************************************************************************************
    Method Name:  IPSCaseFieldsInit_test()
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 5/24/2017
    Description:  Testing IPSCaseFieldsInit method
    Scenario Type:  Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Aparna                      5/24/2017                Created
    ****************************************************************************************************/
          public static testmethod void IPSCaseFieldsInit_test(){
        
                    List<Case> caseList = new List<Case>();
                    Account acct =  new Account();
                    Contact con =  new Contact();
                    Entitlement ent = new Entitlement();
                    acct = TestUtilities.getAccountRecord();
              acct.Core_CNDA_Number__c ='1691';
                    insert acct;
              Contact contactRecord;
        contactRecord = TestUtilities.getContact();
        contactRecord.Accountid = acct.id;
       // contactRecord.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        contactRecord.core_ips_Active__c=false;
        contactRecord.Email = 'ContactDellTest@gmail.com';
                insert contactRecord; 
        
        
                  //Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'IPSCaseFieldsInit';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution.Core_Description__c = 'To update Case fields.';
            TriggerExecution.Core_Object__c = 'Case';
            TriggerExecution.Core_Trigger_Events__c = 'before insert';
            insert TriggerExecution; 
            Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS Case Create').getRecordTypeId();
             Case c= new case(recordtypeId=devRecordTypeId,contactId=contactRecord.id,subject='testing case', Type='Test case', Origin='phone', Reason='Testing',Status='new',Priority='high',Core_Severity__c='1234');
              caseList.add(c);
              insert caseList;
                    Core_IPS_CaseTriggerHandler.IPSCaseFieldsInit(caseList);
        }
                        
        /***************************************************************************************************
    Method Name:  updateSupportLevelOnCase_Test
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 12 Oct 2017
    Description:  Testing updateSupportLevelOnCase method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Yogesh Sharma              10/12/2017                Created
    * Sandeep Sankhla       10/12/2017          Modified
    ****************************************************************************************************/
    static testmethod void updateSupportLevelOnCase_Test(){
        Test.startTest();
            Map<String,ID> profiles = new Map<String,ID>();
            List<String> strProf = new List<String>();
            strProf.add('System Administrator');
            strProf.add('IPS Data Migration');
            List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
            
            for(Profile prf : ProfileList){
                profiles.put(prf.name, prf.id);
            }
            
            //Create Users
            List<User> ListOfUser = new List<User>();
            ListOfUser = TestUtilities.getListOfUser(1); 
            ListOfUser.get(0).ProfileId =  profiles.get('System Administrator');
            insert ListOfUser.get(0);
            
            //Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'updateSupportLevelOnCase';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution.Core_Description__c = 'To update Support Level On Case.';
            TriggerExecution.Core_Object__c = 'Case';
            TriggerExecution.Core_Trigger_Events__c = 'before insert';
            insert TriggerExecution; 
            System.assert(TriggerExecution.id != null);
            
            //Custom Setting - Trigger Executions Sandeeep US84539: I2
            Core_Trigger_Executions__c  TriggerExecution1 = new Core_Trigger_Executions__c();
            TriggerExecution1.Name = 'checkCaseClosureParams';
            TriggerExecution1.Core_Active__c = true;
            TriggerExecution1.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution1.Core_Description__c = 'Check If Org number is same and Case closure is equal to custom setting closure and bugfix id is not empty.';
            TriggerExecution1.Core_Object__c = 'Case';
            TriggerExecution1.Core_Trigger_Events__c = 'before update';
            insert TriggerExecution1; 
            System.assert(TriggerExecution1.id != null);
            
          //Custom Setting Record inserted by Sandeep US84539: I2
          Core_IPS_Support_Org_Specification__c supportOrgCustomSetting = new Core_IPS_Support_Org_Specification__c();
          supportOrgCustomSetting.Core_IPS_Is_Active__c = true;
          supportOrgCustomSetting.Core_IPS_Case_Closure__c = 'Fix in Intel Documentation';
          supportOrgCustomSetting.Core_IPS_Field_Name__c = 'Core_IPS_Bug_Doc_Fix_ID__c';
          supportOrgCustomSetting.Core_IPS_Support_Org_Number__c = 'Org-027';
          supportOrgCustomSetting.Name = 'PSG';
          supportOrgCustomSetting.Core_IPS_Trigger_Field_Value__c= 'Close-Pending';
          supportOrgCustomSetting.Core_IPS_Trigger_Field_API__c = 'Core_Sub_Status__c';
          insert supportOrgCustomSetting;
            
            System.assert(supportOrgCustomSetting.id != NULL,'Custom setting is not Null');
        
            Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateSupportLevelOnCase');
            
            //Custom Setting - Core IPS Labels
            List<Core_IPS_Labels__c> ListofIpsLables = new List<Core_IPS_Labels__c>();
            Core_IPS_Labels__c ipsLables1 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_Case_Create',Value__c = 'IPS Case Create');
            Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_NoAssignedContact',Value__c = 'IPS No Assigned Contact Case');
            Core_IPS_Labels__c ipsLables3 = new Core_IPS_Labels__c(Name = 'Support_Level_Default',Value__c = 'ROW');
            Core_IPS_Labels__c ipsLables4 = new Core_IPS_Labels__c(Name = 'Support_Level_Default_No_Assigned_Cont',Value__c = 'Tier 3');
            ListofIpsLables.add(ipsLables1);
            ListofIpsLables.add(ipsLables2);
            ListofIpsLables.add(ipsLables3);  
          List<Core_IPS_Labels__c> IPSLabelsForGlobalAsset = TestUtilities.getIPSLabel();
            for(Core_IPS_Labels__c ipl : IPSLabelsForGlobalAsset){
                if(ipl.Name == 'Core_IPS_Global_Asset_RT'){
                    ipl.value__c = 'Core_Public_Product';
                }
            }
            ListofIpsLables.addAll(IPSLabelsForGlobalAsset);  

            insert ListofIpsLables;
            
            //Get intelSupportOwner Id (User Id)
            Id intelSupportOwner = ListOfUser.get(0).id;
            System.runAs(ListOfUser.get(0)){
            
                //Create Support Org
                List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
                insert ListOfSupportOrg;
                
                //System.assert(ListOfSupportOrg != null, 'Record not created');
                
                //Create Accounts
                List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
                insert ListOfAccounts;
                System.assert(ListOfAccounts[0].Id != null, 'Record not created');
                
                //Create Contact
                List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
                for(Contact ContactRec : ListOfContacts){
                    ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                    ContactRec.core_ips_Active__c=true;
                    ContactRec.Accountid = ListOfAccounts.get(0).Id;
                }
                insert ListOfContacts;
                System.assert(ListOfContacts[0].Id != null, 'Record not created');
                
                
                //Create Product
                Integer counter = 0;
                
                List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
                for(Product2 Product : ListOfProducts){
                    if(counter==0){
                        Product.Core_Hierarchy_ID__c = '43';
                        Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                        Product.Core_Unique_ID__c = 'Product12345';
                        Product.Core_Code_Name__c = 'ProductCoreCodeName';
                    }else{
                        Product.Core_Hierarchy_ID__c = '59';
                        Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                        Product.Core_Unique_ID__c = 'Product59';
                        Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                        
                    }
                    counter++;
                }
                insert ListOfProducts;
                System.assert(ListOfProducts[0].id != null,'Record not created');
                
                
                //Create Supported product
                counter = 0;
                List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
                for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
                    if(counter==0){
                        SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                        SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                    }else{
                        SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                        SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
                    }
                    counter++;
                }
                insert ListOfSupportedProduct;
                System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
                
                //Create Asset
                counter = 0;
                list<Asset> AssetList = TestUtilities.getAssetList(2);
                for(Asset Asst : AssetList){
                    Asst.accountId = ListOfAccounts.get(0).Id;
                    Asst.Contactid = ListOfContacts.get(0).id;
                    if(counter==0){
                        Asst.core_product_organization__c = ListOfSupportOrg.get(0).id;
                        Asst.core_supported_product__c = ListOfSupportedProduct.get(0).id;
                        Asst.product2Id = ListOfProducts.get(0).id;
                    }else{
                        Asst.core_product_organization__c = ListOfSupportOrg.get(1).id;
                        Asst.core_supported_product__c = ListOfSupportedProduct.get(1).id;
                        Asst.product2Id = ListOfProducts.get(1).id;
                    }
                    counter++;
                }
                insert AssetList;
                System.assert(AssetList[0].Id != null, 'Record not created');
                
                
                //Create Ips Project
                counter = 0;
                List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
                insert ListOfIpsProjects;
                System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
                
                // Create Ips Account
                Counter=0;
                List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
                for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
                    if(counter<1){
                        IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                        IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                    } else {
                        IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                        IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(1).Id;
                    }
                    counter++;
                }
                counter = 0;
                insert ListOfIpsAccounts;
                System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
                
                //Get Suport Level Picklist Values
                Schema.DescribeFieldResult fieldResult = Core_IPS_Support_Level__c.Core_IPS_Support_Level__c.getDescribe();
                List<SelectOption> options = new List<SelectOption>(); 
                for(Schema.PicklistEntry f : fieldResult.getPicklistValues()){
                    options.add(new SelectOption(f.getLabel(), f.getValue()));
                }   
                    
                //Created Support Level
                Core_IPS_Support_Level__c supLevel = new Core_IPS_Support_Level__c();
                supLevel.Core_IPS_Account__c = ListOfAccounts.get(0).Id;
                supLevel.Core_IPS_Support_Org__c = ListOfSupportOrg.get(0).Id;
                supLevel.Core_IPS_Support_Level__c = options.get(0).getValue();
                insert supLevel;
                
                // Create Case
                counter=0;
                List<Case> ListOfCases = TestUtilities.getListOfCases(10);
                
                for(Case CaseRec : ListOfCases){
                    CaseRec.ContactId = ListOfContacts.get(0).id;
                    CaseRec.accountId = ListOfAccounts.get(0).Id;
                    CaseRec.Core_IPS_GEC_Case__c=false;
                    if(counter < 2){
                        CaseRec.assetId = AssetList.get(0).Id;
                        // CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id; 
                    }
                    else if(counter>=2 && counter <5){
                        CaseRec.assetId = AssetList.get(1).Id;
                        CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                    }
                    else{
                        CaseRec.assetId = AssetList.get(1).Id;
                        CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id; 
                    }
                    counter++;
                }
                insert ListOfCases;
                System.assert(ListOfCases[0].Id != null, 'Record not created');
                
                String noAssignedContactCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact');
                Case c1 = TestUtilities.getListOfCases(10).get(0);
                c1.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
                c1.assetId = AssetList.get(1).Id;
                c1.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                c1.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id;  
                            
                insert c1;
                /*start added by Yogesh US72443*/
                c1.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id;
                
                update c1; 
                /*end */
                insert ipsLables4;
                Case c2 = TestUtilities.getListOfCases(10).get(0);
                c2.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
                c2.assetId = AssetList.get(1).Id;
                c2.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                c2.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id;  
                
                insert  c2; 
                //start added by Yogesh US72443
                c2.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                
                update c2; 
                //end
            }   
        Test.stopTest();
    }
    
    /***************************************************************************************************
    Method Name:  manageCaseAccessForCustomer_Test
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 10 Nov 2017
    Description:  Testing manageCaseAccessForCustomer method
    Scenario Type:  Positive and Negative
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Yogesh Sharma              10/11/2017                Created
    ****************************************************************************************************/
    static testmethod void manageCaseAccessForCustomer_Test(){
        Test.startTest();
            Map<String,ID> profiles = new Map<String,ID>();
            List<String> strProf = new List<String>();
            strProf.add('System Administrator');
            strProf.add('IPS Data Migration');
            List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
            
            for(Profile prf : ProfileList){
                profiles.put(prf.name, prf.id); 
            }
            
            //Create Users
            List<User> ListOfUser = new List<User>();
            ListOfUser = TestUtilities.getListOfUser(1); 
            ListOfUser.get(0).ProfileId =  profiles.get('System Administrator');
            insert ListOfUser.get(0);
            
            //Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'ProvideCaseAccess';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution.Core_Description__c = 'To Provide Access On Case.';
            TriggerExecution.Core_Object__c = 'Case';
            TriggerExecution.Core_Trigger_Events__c = 'after Update';
            insert TriggerExecution; 
            System.assert(TriggerExecution.id != null);
            
            // Create Ips Labels added by Aayushi US78952
            List<Core_IPS_Labels__c> IPSLabels = TestUtilities.getIPSLabel();
            for(Core_IPS_Labels__c IL: IPSLabels){
                if(IL.name=='ProjectGroupPrefix'){
                IL.Value__c = 'IPS_Proj_';
                }
                if(IL.name=='CoreStatus_SPtoActive_Error'){
                    IL.Value__c = 'Project Status cannot be changed from Submitted Pending to Active';
                }
                 if(IL.name=='Core_OneProjProdMem_Error'){
                    IL.Value__c = 'Project cannot be submitted without atleast one account and one Product and one Project Member';
                }
                if(IL.name=='CoreStatus_Draft'){
                   IL.Value__c = 'Draft'; 
                }
                if(IL.name=='CoreStatus_Active'){
                   IL.Value__c = 'Active' ;
                }
                if(IL.name=='CoreStatus_Inactive'){
                   IL.Value__c = 'Inactive' ;
                }
                if(IL.name=='CoreStatus_SP'){
                   IL.Value__c = 'Submitted Pending' ;
                }
                if(IL.name=='Core_IPS_Bug/Fix_ErrMsg'){
                  IL.Value__c = 'Error : Bug/Doc Fix ID is required in order to close a case.' ;  
                }
                if(IL.name=='Core_IPS_Bug/Fix_StatusValue'){
                  IL.Value__c = 'Closed' ;
                }
        }
         //Custom Setting - Core IPS Labels
            List<Core_IPS_Labels__c> ListofIpsLables = new List<Core_IPS_Labels__c>();
            Core_IPS_Labels__c ipsLables1 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_Case_Create',Value__c = 'IPS Case Create');
            Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_NoAssignedContact',Value__c = 'IPS No Assigned Contact Case');
            Core_IPS_Labels__c ipsLables3 = new Core_IPS_Labels__c(Name = 'Support_Level_Default',Value__c = 'ROW');
            Core_IPS_Labels__c ipsLables4 = new Core_IPS_Labels__c(Name = 'Support_Level_Default_No_Assigned_Cont',Value__c = 'Tier 2');
            //Core_IPS_Labels__c ipsLables5 = new Core_IPS_Labels__c(Name = 'Core_IPS_Bug/Fix_ErrMsg', Value__c = 'Error : Bug/Doc Fix ID is required in order to close a case.');
            //Core_IPS_Labels__c ipsLables6 = new Core_IPS_Labels__c(Name = 'Core_IPS_Bug/Fix_StatusValue', Value__c = 'Closed');
            
            ListofIpsLables.add(ipsLables1);
            ListofIpsLables.add(ipsLables2);
            ListofIpsLables.add(ipsLables3); 
            ListofIpsLables.add(ipsLables4);
            //ListofIpsLables.add(ipsLables5); 
            //ListofIpsLables.add(ipsLables6);
                       
            ListofIpsLables.addAll(IPSLabels);
            insert ListofIpsLables;
            
            //Get intelSupportOwner Id (User Id)
            Id intelSupportOwner = ListOfUser.get(0).id;
            System.runAs(ListOfUser.get(0)){
            
                //Create Support Org
                List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
                insert ListOfSupportOrg;
                
                //System.assert(ListOfSupportOrg != null, 'Record not created');
                
                //Create Accounts
                List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
                insert ListOfAccounts;
                System.assert(ListOfAccounts[0].Id != null, 'Record not created');
                
                //Create Contact
                List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
                for(Contact ContactRec : ListOfContacts){
                    ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                    ContactRec.core_ips_Active__c=true;
                    ContactRec.Accountid = ListOfAccounts.get(0).Id;
                }
                insert ListOfContacts;
                System.assert(ListOfContacts[0].Id != null, 'Record not created');
                
                
                //Create Product
                Integer counter = 0;
                
                List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
                for(Product2 Product : ListOfProducts){
                    if(counter==0){
                        Product.Core_Hierarchy_ID__c = '43';
                        Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                        Product.Core_Unique_ID__c = 'Product12345';
                        Product.Core_Code_Name__c = 'ProductCoreCodeName';
                    }else{
                        Product.Core_Hierarchy_ID__c = '59';
                        Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                        Product.Core_Unique_ID__c = 'Product59';
                        Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                        
                    }
                    counter++;
                }
                insert ListOfProducts;
                System.assert(ListOfProducts[0].id != null,'Record not created');
                
                
                //Create Supported product
                counter = 0;
                List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
                for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
                    if(counter==0){
                        SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                        SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                    }else{
                        SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                        SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
                    }
                    counter++;
                }
                insert ListOfSupportedProduct;
                System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
                
                //Create Asset
                counter = 0;
                list<Asset> AssetList = TestUtilities.getAssetList(2);
                for(Asset Asst : AssetList){
                    Asst.accountId = ListOfAccounts.get(0).Id;
                    Asst.Contactid = ListOfContacts.get(0).id;
                    if(counter==0){
                        Asst.core_product_organization__c = ListOfSupportOrg.get(0).id;
                        Asst.core_supported_product__c = ListOfSupportedProduct.get(0).id;
                        Asst.product2Id = ListOfProducts.get(0).id;
                    }else{
                        Asst.core_product_organization__c = ListOfSupportOrg.get(1).id;
                        Asst.core_supported_product__c = ListOfSupportedProduct.get(1).id;
                        Asst.product2Id = ListOfProducts.get(1).id;
                    }
                    counter++;
                }
                insert AssetList;
                System.assert(AssetList[0].Id != null, 'Record not created');
                
                
                //Create Ips Project
                counter = 0;
                List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
                insert ListOfIpsProjects;
                System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
                
                // Create Ips Account
                Counter=0;
                List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
                for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
                    if(counter<1){
                        IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                        IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                    } else {
                        IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                        IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(1).Id;
                    }
                    counter++;
                }
                counter = 0;
                insert ListOfIpsAccounts;
                System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
                
                //Get Suport Level Picklist Values
                Schema.DescribeFieldResult fieldResult = Core_IPS_Support_Level__c.Core_IPS_Support_Level__c.getDescribe();
                List<SelectOption> options = new List<SelectOption>(); 
                for(Schema.PicklistEntry f : fieldResult.getPicklistValues()){
                    options.add(new SelectOption(f.getLabel(), f.getValue()));
                }   
                    
                //Created Support Level
                Core_IPS_Support_Level__c supLevel = new Core_IPS_Support_Level__c();
                supLevel.Core_IPS_Account__c = ListOfAccounts.get(0).Id;
                supLevel.Core_IPS_Support_Org__c = ListOfSupportOrg.get(0).Id;
                supLevel.Core_IPS_Support_Level__c = options.get(0).getValue();
                insert supLevel;
                
                //Create Case For Customer Visible Checkbox
                List<Case> lstCase = TestUtilities.getListOfCases(5);
                
                lstCase.get(0).accountId = ListOfAccounts.get(0).Id;
                lstCase.get(0).ContactId = ListOfContacts.get(0).id;
                lstCase.get(0).Core_IPS_Customer_Visible__c = false;
                                
                lstCase.get(1).accountId = ListOfAccounts.get(0).Id;
                lstCase.get(1).ContactId = ListOfContacts.get(0).id;
                lstCase.get(1).Core_IPS_Customer_Visible__c = false;
                lstCase.get(1).assetId = AssetList.get(1).Id;
                lstCase.get(1).Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                
                lstCase.get(2).accountId = ListOfAccounts.get(0).Id;
                lstCase.get(2).ContactId = ListOfContacts.get(0).id;
                lstCase.get(2).Core_IPS_Customer_Visible__c = false;
                lstCase.get(2).assetId = AssetList.get(1).Id;
                lstCase.get(2).Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                
                lstCase.get(3).accountId = ListOfAccounts.get(0).Id;
                lstCase.get(3).ContactId = ListOfContacts.get(0).id;
                lstCase.get(3).Core_IPS_Customer_Visible__c = false;
                lstCase.get(3).assetId = AssetList.get(1).Id;
                lstCase.get(3).Core_IPS_Project_Case__c = null;
                
                lstCase.get(4).accountId = ListOfAccounts.get(0).Id;
                lstCase.get(4).ContactId = ListOfContacts.get(0).id;
                lstCase.get(4).Core_IPS_Customer_Visible__c = false;
                lstCase.get(4).assetId = AssetList.get(1).Id;
                lstCase.get(4).Core_IPS_Project_Case__c = null;
                
                insert lstCase;
                
                lstCase.get(1).Core_IPS_Project_Case__c  = null;
                lstCase.get(1).Core_IPS_Customer_Visible__c = false; 
                                
                lstCase.get(2).Core_IPS_Project_Case__c  = ListOfIpsProjects.get(1).id;
                lstCase.get(2).Core_IPS_Customer_Visible__c = false; 
                                
                lstCase.get(3).Core_IPS_Project_Case__c  = ListOfIpsProjects.get(1).id;
                lstCase.get(3).Core_IPS_Customer_Visible__c = false; 
                
                lstCase.get(4).accountId = ListOfAccounts.get(1).Id;
                lstCase.get(4).Core_IPS_Project_Case__c  = null;
                lstCase.get(4).Core_IPS_Customer_Visible__c = false;   
                
                update lstCase;
                Case cs= new Case();
                insert cs;
                /*CaseShare csShareRec = new CaseShare();
                csShareRec.CaseAccessLevel = 'Edit';
                csShareRec.CaseId = cs.Id;
                csShareRec.UserOrGroupId = ListOfUser.get(0).Id;
                insert csShareRec;  */         
            } 
        Test.stopTest(); 
    } 
    
     /***************************************************************************************************
    Method Name:  updateSupportLevelOnCase_Test2
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 21 Feb 2018
    Description:  Testing updateSupportLevelOnCase method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Sugandha              21/02/2018                Created
    * Aayushi               22/03/2018                Modified
    ****************************************************************************************************/
    static testmethod void updateSupportLevelOnCase_Test2(){
        Test.startTest();
            Map<String,ID> profiles = new Map<String,ID>();
            List<String> strProf = new List<String>();
            strProf.add('System Administrator');
            strProf.add('IPS Data Migration');
            List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
            
            for(Profile prf : ProfileList){
                profiles.put(prf.name, prf.id);
            }
            
            //Create Users
            List<User> ListOfUser = new List<User>();
            ListOfUser = TestUtilities.getListOfUser(1); 
            ListOfUser.get(0).ProfileId =  profiles.get('System Administrator');
            insert ListOfUser.get(0);
            
            //Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'updateSupportLevelOnCase';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution.Core_Description__c = 'To update Support Level On Case.';
            TriggerExecution.Core_Object__c = 'Case';
            TriggerExecution.Core_Trigger_Events__c = 'before insert';
            insert TriggerExecution; 
            System.assert(TriggerExecution.id != null);
            
            //Custom Setting - Trigger Executions Sandeeep US84539: I2
            Core_Trigger_Executions__c  TriggerExecution1 = new Core_Trigger_Executions__c();
            TriggerExecution1.Name = 'checkCaseClosureParams';
            TriggerExecution1.Core_Active__c = true;
            TriggerExecution1.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution1.Core_Description__c = 'Check If Org number is same and Case closure is equal to custom setting closure and bugfix id is not empty.';
            TriggerExecution1.Core_Object__c = 'Case';
            TriggerExecution1.Core_Trigger_Events__c = 'before update';
            insert TriggerExecution1; 
            System.assert(TriggerExecution1.id != null);
            
          //Custom Setting Record inserted by Sandeep US84539: I2
          Core_IPS_Support_Org_Specification__c supportOrgCustomSetting = new Core_IPS_Support_Org_Specification__c();
          supportOrgCustomSetting.Core_IPS_Is_Active__c = true;
          supportOrgCustomSetting.Core_IPS_Case_Closure__c = 'Fix in Intel Documentation';
          supportOrgCustomSetting.Core_IPS_Field_Name__c = 'Core_IPS_Bug_Doc_Fix_ID__c';
          supportOrgCustomSetting.Core_IPS_Support_Org_Number__c = 'Org-027';
          supportOrgCustomSetting.Name = 'PSG';
          insert supportOrgCustomSetting;
           //start added by Aayushi US89551
        Core_Trigger_Executions__c  TriggerExecutionRec = new Core_Trigger_Executions__c();
        TriggerExecutionRec.Name = 'provideProjCaseAccessToFAE';
        TriggerExecutionRec.Core_Active__c = true;
        TriggerExecutionRec.Core_Class_Name__c ='Core_IPS_Account_Handler';
        TriggerExecutionRec.Core_Description__c = 'Activate Or Deactivate Project Members';
        TriggerExecutionRec.Core_Object__c = 'Core_IPS_Account__c';
        TriggerExecutionRec.Core_Trigger_Events__c = 'after update';
        insert TriggerExecutionRec;
        //end
            System.assert(supportOrgCustomSetting.id != NULL,'Custom setting is not Null');
        
            Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateSupportLevelOnCase');
            
            //Custom Setting - Core IPS Labels
            List<Core_IPS_Labels__c> ListofIpsLables = new List<Core_IPS_Labels__c>();
            Core_IPS_Labels__c ipsLables1 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_Case_Create',Value__c = 'IPS Case Create');
            Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_NoAssignedContact',Value__c = 'IPS No Assigned Contact Case');
            Core_IPS_Labels__c ipsLables3 = new Core_IPS_Labels__c(Name = 'Support_Level_Default',Value__c = 'ROW');
            Core_IPS_Labels__c ipsLables4 = new Core_IPS_Labels__c(Name = 'Support_Level_Default_No_Assigned_Cont',Value__c = 'Tier 3');
            ListofIpsLables.add(ipsLables1);
            ListofIpsLables.add(ipsLables2);
            ListofIpsLables.add(ipsLables3);  
          List<Core_IPS_Labels__c> IPSLabelsForGlobalAsset = TestUtilities.getIPSLabel();
            for(Core_IPS_Labels__c ipl : IPSLabelsForGlobalAsset){
                if(ipl.Name == 'Core_IPS_Global_Asset_RT'){
                    ipl.value__c = 'Core_Public_Product';
                }
            }
            ListofIpsLables.addAll(IPSLabelsForGlobalAsset);  

            insert ListofIpsLables;
            
            //Get intelSupportOwner Id (User Id)
            Id intelSupportOwner = ListOfUser.get(0).id;
            System.runAs(ListOfUser.get(0)){
            
                //Create Support Org
                List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
                insert ListOfSupportOrg;
                
                //System.assert(ListOfSupportOrg != null, 'Record not created');
                
                //Create Accounts
                List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
                insert ListOfAccounts;
                System.assert(ListOfAccounts[0].Id != null, 'Record not created');
                
                //Create Contact
                List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
                for(Contact ContactRec : ListOfContacts){
                    ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                    ContactRec.core_ips_Active__c=true;
                    ContactRec.Accountid = ListOfAccounts.get(0).Id;
                }
                insert ListOfContacts;
                System.assert(ListOfContacts[0].Id != null, 'Record not created');
                
                
                //Create Product
                Integer counter = 0;
                
                List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
                for(Product2 Product : ListOfProducts){
                    if(counter==0){
                        Product.Core_Hierarchy_ID__c = '43';
                        Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                        Product.Core_Unique_ID__c = 'Product12345';
                        Product.Core_Code_Name__c = 'ProductCoreCodeName';
                    }else{
                        Product.Core_Hierarchy_ID__c = '59';
                        Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                        Product.Core_Unique_ID__c = 'Product59';
                        Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                        
                    }
                    counter++;
                }
                insert ListOfProducts;
                System.assert(ListOfProducts[0].id != null,'Record not created');
                
                
                //Create Supported product
                counter = 0;
                List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
                for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
                    if(counter==0){
                        SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                        SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                    }else{
                        SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                        SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
                    }
                    counter++;
                }
                insert ListOfSupportedProduct;
                System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
                
                //Create Asset
                counter = 0;
                list<Asset> AssetList = TestUtilities.getAssetList(2);
                for(Asset Asst : AssetList){
                    Asst.accountId = ListOfAccounts.get(0).Id;
                    Asst.Contactid = ListOfContacts.get(0).id;
                    if(counter==0){
                        Asst.core_product_organization__c = ListOfSupportOrg.get(0).id;
                        Asst.core_supported_product__c = ListOfSupportedProduct.get(0).id;
                        Asst.product2Id = ListOfProducts.get(0).id;
                    }else{
                        Asst.core_product_organization__c = ListOfSupportOrg.get(1).id;
                        Asst.core_supported_product__c = ListOfSupportedProduct.get(1).id;
                        Asst.product2Id = ListOfProducts.get(1).id;
                    }
                    counter++;
                }
                insert AssetList;
                System.assert(AssetList[0].Id != null, 'Record not created');
                
                
                //Create Ips Project
                counter = 0;
                List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
                insert ListOfIpsProjects;
                System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
                //insert fae added by Aayushi 20/03/2018 US89551
            List<user> userList = TestUtilities.getListofuser(1);
            profile prof = [select id, name from Profile where name = 'Sales Rep-BB' limit 1];
            userlist[0].profileid=prof.id;
            userlist[0].username='salesrep0202.abc@user.com';
            System.runAs(ListOfUser.get(0)){
            insert userlist;
            }
            //start added by Aayushi 20/03/2018 US89551
            String teamMemberRole = 'Team Member (100%)';
            String accountAccessLevel = 'Edit', opportunityAccessLevel = 'Edit', caseAccessLevel = 'None';
            List<AccountTeamMember> members = new list<AccountTeamMember>();
            List<AccountShare> sharingRules = new list<AccountShare>();
            //end
                // Create Ips Account
                Counter=0;
                List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
                for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
                    if(counter<1){
                        IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                        IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                        //start added by Aayushi 20/03/2018 US89551
                        members.add(New AccountTeamMember(AccountId = ListOfAccounts.get(0).Id, TeamMemberRole = teamMemberRole, UserId= userlist[0].Id));
                       sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = userlist[0].Id, AccountId = ListOfAccounts.get(0).Id));

                    } else {
                        IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                        IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(1).Id;
                        members.add(New AccountTeamMember(AccountId = ListOfAccounts.get(1).Id, TeamMemberRole = teamMemberRole, UserId= userlist[0].Id));
                sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = userlist[0].Id, AccountId = ListOfAccounts.get(1).Id));
            //end
                    }
                    counter++;
                }
                counter = 0;
                insert ListOfIpsAccounts;
                System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
                
                //Get Suport Level Picklist Values
                Schema.DescribeFieldResult fieldResult = Core_IPS_Support_Level__c.Core_IPS_Support_Level__c.getDescribe();
                List<SelectOption> options = new List<SelectOption>(); 
                for(Schema.PicklistEntry f : fieldResult.getPicklistValues()){
                    options.add(new SelectOption(f.getLabel(), f.getValue()));
                }   
                    
                //Created Support Level
                Core_IPS_Support_Level__c supLevel = new Core_IPS_Support_Level__c();
                supLevel.Core_IPS_Account__c = ListOfAccounts.get(0).Id;
                supLevel.Core_IPS_Support_Org__c = ListOfSupportOrg.get(0).Id;
                supLevel.Core_IPS_Support_Level__c = options.get(0).getValue();
                insert supLevel;
                
                // Create Case
                counter=0;
                List<Case> ListOfCases = TestUtilities.getListOfCases(10);
                
                for(Case CaseRec : ListOfCases){
                    CaseRec.ContactId = ListOfContacts.get(0).id;
                    CaseRec.accountId = ListOfAccounts.get(0).Id;
                    CaseRec.Core_IPS_GEC_Case__c=false;
                    if(counter < 2){
                        CaseRec.assetId = AssetList.get(0).Id;
                        // CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id; 
                    }
                    else if(counter>=2 && counter <5){
                        CaseRec.assetId = AssetList.get(1).Id;
                        CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                    }
                    else{
                        CaseRec.assetId = AssetList.get(1).Id;
                        CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id; 
                    }
                    counter++;
                }
                insert ListOfCases;
                System.assert(ListOfCases[0].Id != null, 'Record not created');
                
                String noAssignedContactCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact');
                Case c1 = TestUtilities.getListOfCases(10).get(0);
                c1.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
                c1.assetId = AssetList.get(1).Id;
                c1.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                c1.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id;  
                            
                insert c1;
                /*start added by Yogesh US72443*/
                c1.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id;
                
                update c1; 
                /*end */
                insert ipsLables4;
                Case c2 = TestUtilities.getListOfCases(10).get(0);
                c2.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
                c2.assetId = AssetList.get(1).Id;
                c2.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                c2.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id;  
                
                insert  c2; 
                //start added by Yogesh US72443
                c2.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                
                update c2; 
                //end
            }   
        Test.stopTest();
    }     
    
        //This is for testing negative test case
    public static testmethod void test_ProvideCaseAccessatFuture_Negative(){
        Core_IPS_CaseTriggerHandler.ProvideCaseAccessatFuture(null);
        Core_IPS_CaseTriggerHandler.IPSCaseFieldsInit(null);
        
    }
    
         /***************************************************************************************************
    Method Name:  updateSupportLevelOnCase_Test2
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 21 Feb 2018
    Description:  Testing updateSupportLevelOnCase method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Sugandha              21/02/2018                Created
    * Aayushi               22/03/2018                Modified
    ****************************************************************************************************/
    static testmethod void updateSupportLevelOnCase_Test3(){
        Test.startTest();
            Map<String,ID> profiles = new Map<String,ID>();
            List<String> strProf = new List<String>();
            strProf.add('System Administrator');
            strProf.add('IPS Data Migration');
            List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
            
            for(Profile prf : ProfileList){
                profiles.put(prf.name, prf.id);
            }
            
            //Create Users
            List<User> ListOfUser = new List<User>();
            ListOfUser = TestUtilities.getListOfUser(1); 
            ListOfUser.get(0).ProfileId =  profiles.get('System Administrator');
            insert ListOfUser.get(0);
            
            //Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'updateSupportLevelOnCase';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution.Core_Description__c = 'To update Support Level On Case.';
            TriggerExecution.Core_Object__c = 'Case';
            TriggerExecution.Core_Trigger_Events__c = 'before insert';
            insert TriggerExecution; 
            System.assert(TriggerExecution.id != null);
            
            //Custom Setting - Trigger Executions Sandeeep US84539: I2
            Core_Trigger_Executions__c  TriggerExecution1 = new Core_Trigger_Executions__c();
            TriggerExecution1.Name = 'checkCaseClosureParams';
            TriggerExecution1.Core_Active__c = true;
            TriggerExecution1.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution1.Core_Description__c = 'Check If Org number is same and Case closure is equal to custom setting closure and bugfix id is not empty.';
            TriggerExecution1.Core_Object__c = 'Case';
            TriggerExecution1.Core_Trigger_Events__c = 'before update';
            insert TriggerExecution1; 
            System.assert(TriggerExecution1.id != null);
            
          //Custom Setting Record inserted by Sandeep US84539: I2
          Core_IPS_Support_Org_Specification__c supportOrgCustomSetting = new Core_IPS_Support_Org_Specification__c();
          supportOrgCustomSetting.Core_IPS_Is_Active__c = true;
          supportOrgCustomSetting.Core_IPS_Case_Closure__c = 'Fix in Intel Documentation';
          supportOrgCustomSetting.Core_IPS_Field_Name__c = 'Core_IPS_Bug_Doc_Fix_ID__c';
          supportOrgCustomSetting.Core_IPS_Support_Org_Number__c = 'Org-027';
          supportOrgCustomSetting.Name = 'PSG';
          insert supportOrgCustomSetting;
           //start added by Aayushi US89551
        Core_Trigger_Executions__c  TriggerExecutionRec = new Core_Trigger_Executions__c();
        TriggerExecutionRec.Name = 'provideProjCaseAccessToFAE';
        TriggerExecutionRec.Core_Active__c = true;
        TriggerExecutionRec.Core_Class_Name__c ='Core_IPS_Account_Handler';
        TriggerExecutionRec.Core_Description__c = 'Activate Or Deactivate Project Members';
        TriggerExecutionRec.Core_Object__c = 'Core_IPS_Account__c';
        TriggerExecutionRec.Core_Trigger_Events__c = 'after update';
        insert TriggerExecutionRec;
        //end
            System.assert(supportOrgCustomSetting.id != NULL,'Custom setting is not Null');
        
            Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateSupportLevelOnCase');
            
            //Custom Setting - Core IPS Labels
            List<Core_IPS_Labels__c> ListofIpsLables = new List<Core_IPS_Labels__c>();
            Core_IPS_Labels__c ipsLables1 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_Case_Create',Value__c = 'IPS Case Create');
            Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_NoAssignedContact',Value__c = 'IPS No Assigned Contact Case');
            Core_IPS_Labels__c ipsLables3 = new Core_IPS_Labels__c(Name = 'Support_Level_Default',Value__c = 'ROW');
            Core_IPS_Labels__c ipsLables4 = new Core_IPS_Labels__c(Name = 'Support_Level_Default_No_Assigned_Cont',Value__c = 'Tier 3');
            ListofIpsLables.add(ipsLables1);
            ListofIpsLables.add(ipsLables2);
            ListofIpsLables.add(ipsLables3);  
          List<Core_IPS_Labels__c> IPSLabelsForGlobalAsset = TestUtilities.getIPSLabel();
            for(Core_IPS_Labels__c ipl : IPSLabelsForGlobalAsset){
                if(ipl.Name == 'Core_IPS_Global_Asset_RT'){
                    ipl.value__c = 'Core_Public_Product';
                }
            }
            ListofIpsLables.addAll(IPSLabelsForGlobalAsset);  

            insert ListofIpsLables;
            
            //Get intelSupportOwner Id (User Id)
            Id intelSupportOwner = ListOfUser.get(0).id;
            System.runAs(ListOfUser.get(0)){
            
                //Create Support Org
                List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
                insert ListOfSupportOrg;
                
                //System.assert(ListOfSupportOrg != null, 'Record not created');
                
                //Create Accounts
                List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(2);
                insert ListOfAccounts;
                System.assert(ListOfAccounts[0].Id != null, 'Record not created');
                
                //Create Contact
                List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
                for(Contact ContactRec : ListOfContacts){
                    ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                    ContactRec.core_ips_Active__c=true;
                    ContactRec.Accountid = ListOfAccounts.get(0).Id;
                }
                insert ListOfContacts;
                System.assert(ListOfContacts[0].Id != null, 'Record not created');
                
                
                //Create Product
                Integer counter = 0;
                
                List<Product2> ListOfProducts = TestUtilities.getListOfProduct(2);
                for(Product2 Product : ListOfProducts){
                    if(counter==0){
                        Product.Core_Hierarchy_ID__c = '43';
                        Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                        Product.Core_Unique_ID__c = 'Product12345';
                        Product.Core_Code_Name__c = 'ProductCoreCodeName';
                    }else{
                        Product.Core_Hierarchy_ID__c = '59';
                        Product.Core_Hierarchy_Name__c = 'ProdHierarchyName59';
                        Product.Core_Unique_ID__c = 'Product59';
                        Product.Core_Code_Name__c = 'ProductCoreCodeName59';
                        
                    }
                    counter++;
                }
                insert ListOfProducts;
                System.assert(ListOfProducts[0].id != null,'Record not created');
                
                
                //Create Supported product
                counter = 0;
                List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(2);
                for(Core_IPS_Supported_Product__c SupportedProduct : ListOfSupportedProduct){
                    if(counter==0){
                        SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                        SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                    }else{
                        SupportedProduct.Core_Product__c = ListOfProducts.get(1).id;
                        SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
                    }
                    counter++;
                }
                insert ListOfSupportedProduct;
                System.assert(ListOfSupportedProduct[0].id != null,'Record not created');
                
                //Create Asset
                counter = 0;
                list<Asset> AssetList = TestUtilities.getAssetList(2);
                for(Asset Asst : AssetList){
                    Asst.accountId = ListOfAccounts.get(0).Id;
                    Asst.Contactid = ListOfContacts.get(0).id;
                    if(counter==0){
                        Asst.core_product_organization__c = ListOfSupportOrg.get(0).id;
                        Asst.core_supported_product__c = ListOfSupportedProduct.get(0).id;
                        Asst.product2Id = ListOfProducts.get(0).id;
                    }else{
                        Asst.core_product_organization__c = ListOfSupportOrg.get(1).id;
                        Asst.core_supported_product__c = ListOfSupportedProduct.get(1).id;
                        Asst.product2Id = ListOfProducts.get(1).id;
                    }
                    counter++;
                }
                insert AssetList;
                System.assert(AssetList[0].Id != null, 'Record not created');
                
                
                //Create Ips Project
                counter = 0;
                List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
                insert ListOfIpsProjects;
                System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
                //insert fae added by Aayushi 20/03/2018 US89551
            List<user> userList = TestUtilities.getListofuser(1);
            profile prof = [select id, name from Profile where name = 'Sales Rep-BB' limit 1];
            userlist[0].profileid=prof.id;
            userlist[0].username='salesrep0202.abc@user.com';
            System.runAs(ListOfUser.get(0)){
            insert userlist;
            }
            //start added by Aayushi 20/03/2018 US89551
            String teamMemberRole = 'Team Member (100%)';
            String accountAccessLevel = 'Edit', opportunityAccessLevel = 'Edit', caseAccessLevel = 'None';
            List<AccountTeamMember> members = new list<AccountTeamMember>();
            List<AccountShare> sharingRules = new list<AccountShare>();
            //end
                // Create Ips Account
                Counter=0;
                List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(2);
                for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
                    if(counter<1){
                        IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                        IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                        //start added by Aayushi 20/03/2018 US89551
                        members.add(New AccountTeamMember(AccountId = ListOfAccounts.get(0).Id, TeamMemberRole = teamMemberRole, UserId= userlist[0].Id));
                       sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = userlist[0].Id, AccountId = ListOfAccounts.get(0).Id));

                    } else {
                        IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                        IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(1).Id;
                        members.add(New AccountTeamMember(AccountId = ListOfAccounts.get(1).Id, TeamMemberRole = teamMemberRole, UserId= userlist[0].Id));
                sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = userlist[0].Id, AccountId = ListOfAccounts.get(1).Id));
            //end
                    }
                    counter++;
                }
                counter = 0;
                insert ListOfIpsAccounts;
                System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
                
                //Get Suport Level Picklist Values
                Schema.DescribeFieldResult fieldResult = Core_IPS_Support_Level__c.Core_IPS_Support_Level__c.getDescribe();
                List<SelectOption> options = new List<SelectOption>(); 
                for(Schema.PicklistEntry f : fieldResult.getPicklistValues()){
                    options.add(new SelectOption(f.getLabel(), f.getValue()));
                }   
                    
                //Created Support Level
                Core_IPS_Support_Level__c supLevel = new Core_IPS_Support_Level__c();
                supLevel.Core_IPS_Account__c = ListOfAccounts.get(0).Id;
                supLevel.Core_IPS_Support_Org__c = ListOfSupportOrg.get(0).Id;
                supLevel.Core_IPS_Support_Level__c = options.get(0).getValue();
                insert supLevel;
                
                // Create Case
                counter=0;
                List<Case> ListOfCases = TestUtilities.getListOfCases(10);
                
                for(Case CaseRec : ListOfCases){
                    CaseRec.ContactId = ListOfContacts.get(0).id;
                    CaseRec.accountId = ListOfAccounts.get(0).Id;
                    CaseRec.Core_IPS_GEC_Case__c=false;
                    if(counter < 2){
                        CaseRec.assetId = AssetList.get(0).Id;
                        // CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id; 
                    }
                    else if(counter>=2 && counter <5){
                        CaseRec.assetId = AssetList.get(1).Id;
                        CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                    }
                    else{
                        CaseRec.assetId = AssetList.get(1).Id;
                        CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id; 
                    }
                    counter++;
                }
                insert ListOfCases;
                System.assert(ListOfCases[0].Id != null, 'Record not created');
                
                String noAssignedContactCaseRecordType = Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact');
                Case c1 = TestUtilities.getListOfCases(10).get(0);
                c1.RecordTypeId = Core_IPS_CaseTriggerHandler.getCaseRecordtypeIDByName(noAssignedContactCaseRecordType);
                c1.assetId = AssetList.get(1).Id;
                c1.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                c1.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id;  
                            
                insert c1;
                /*start added by Yogesh US72443*/
                c1.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id;
                
                update c1; 
                /*end */
                insert ipsLables4;
                Case c2 = TestUtilities.getListOfCases(10).get(0);
                c2.RecordTypeId = [SELECT id from RecordType where Name ='IPS Case Create'].Id;
                c2.assetId = AssetList.get(1).Id;
                c2.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                c2.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id;  
                c2.Core_Partner_Supported_Account__c = ListOfAccounts.get(0).id;
                c2.Core_IPS_Self_Assigned__c = true;
                
                insert  c2; 
                System.debug('cas1'+c2.Core_Partner_Supported_Account__c);
                c2.Core_Partner_Supported_Account__c = ListOfAccounts.get(1).id;
                
                update c2;
                System.debug('cas2'+c2.Core_Partner_Supported_Account__c);
            }   
        Test.stopTest();
    }     
    
    
    /***************************************************************************************************
    Method Name:  ProjectInterestedParties_Test
    Method Type: Test Method
    Version     : 1.0 
    Description:  ProjectInterestedParties Test method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Rakesh                    21/06/2018                Created - US107411
    * Amritesh                  1/2/2019                  DE28924
    ****************************************************************************************************/
    static testmethod void ProjectInterestedParties_Test(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        System.runAs(ListOfUser.get(1)){
            // Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
                ContactRec.Core_IPS_Active__c = true;
            }
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');
            // Create Ips Project
            List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
            insert ListOfIpsProjects;
            System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
            // Create Ips Account
            List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            }
            insert ListOfIpsAccounts;
            System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
            // Create Project Member
            List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(2);
            Integer i=1;
            for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
                ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
                if(i==1)
                    ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                else
                    ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(1).Id;    
                ProjMem.Core_User__c = intelSupportOwner;
                ProjMem.Add_as_Case_Interested_Party__c = true;
                i++;
            }
            insert ListOfProjectMembers;
            // Create IST Member
            List<Core_IPS_Intel_Support_Team__c> lstIST = new List<Core_IPS_Intel_Support_Team__c>();
            Core_IPS_Intel_Support_Team__c ist = new Core_IPS_Intel_Support_Team__c();
            ist.Core_IPS_Project__c = ListOfIpsProjects[0].Id;
            ist.Core_IPS_User__c = intelSupportOwner;
            ist.Status__c='Active';
            ist.Add_as_Case_Interested_Party__c = true;
            lstIST.add(ist);
            
            ist = new Core_IPS_Intel_Support_Team__c();
            ist.Core_IPS_Project__c = ListOfIpsProjects[1].Id;
            ist.Core_IPS_User__c = intelSupportOwner;
            ist.Status__c='Active';
            ist.Add_as_Case_Interested_Party__c = true;
            lstIST.add(ist);
            insert lstIST;
            System.assert(lstIST[0].Id != null, 'Record not created');
            
            // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(4);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects[0].Id;
            }
            
            for(Core_IPS_Project__c objproj : ListOfIpsProjects) {
                objproj.Core_IPS_Enable_ISTasInterested_Parties__c = true;
                objproj.Core_IPS_EnableMemberasInterestedParties__c = true;
            }
            update ListOfIpsProjects;
            
            List<Core_Trigger_Executions__c> lstTriggerExecution = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'create_InsterestedParties_UsingCase';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution.Core_Description__c = 'create_InsterestedParties_UsingCase';
            TriggerExecution.Core_Object__c = 'Case';
            TriggerExecution.Core_Trigger_Events__c = 'After Update';
            lstTriggerExecution.add(TriggerExecution);
            
            TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'create_IntrestedParties_ProjectMembers';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution.Core_Description__c = 'create_IntrestedParties_ProjectMembers';
            TriggerExecution.Core_Object__c = 'Case';
            TriggerExecution.Core_Trigger_Events__c = 'After Update';
            lstTriggerExecution.add(TriggerExecution);
            
            TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'case_Edit_projectDetails';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution.Core_Description__c = 'case_Edit_projectDetails';
            TriggerExecution.Core_Object__c = 'Case';
            TriggerExecution.Core_Trigger_Events__c = 'After Update';
            lstTriggerExecution.add(TriggerExecution);
            insert lstTriggerExecution;
                        
            Test.startTest();
            insert ListOfCases;
            System.assert(ListOfCases[0].Id != null, 'Record not created');
            for(Case CaseRec : ListOfCases){
                CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(1).id;
            }
            Core_CaseTrigger_Dispatcher.triggerAssignmentRule=true;
            update ListOfCases;
            //commented for DE28924   
            /*for(Case CaseRec : ListOfCases){
                CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
            }
            Core_CaseTrigger_Dispatcher.recursiveError = 0;
            Core_CaseTrigger_Dispatcher.triggerAssignmentRule=true;
            update ListOfCases;
            Core_CaseTrigger_Dispatcher.triggerAssignmentRule=false;*/
            Test.stopTest();
        }
    }
    
    /***************************************************************************************************
    Method Name:  validate_caseOwner_Test
    Method Type: Test Method
    Version     : 1.0 
    Description:  validate_caseOwner Test method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Sugandha                    25/06/2018             Created - DE40252
    ****************************************************************************************************/
    static testmethod void validate_caseOwner_Test(){
        getRecords();
        Id intelSupportOwner = ListOfUser.get(0).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name='IPS Agent-Partner' ];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        system.debug('profiles'+profiles);
        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        User userRecord = new User();
        System.runAs ( ListOfUser[0]) { 
            UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
            User portalAccountOwner1 = new User(
                                        UserRoleId = portalRole.Id,
                                        ProfileId = profile1.Id,
                                        Username = 'test1206@intel.com',
                                        Alias = 'batman',
                                        Email='newuser155@intel.com',
                                        EmailEncodingKey='UTF-8',
                                        Firstname='Bruce',
                                        Lastname='Wayne',
                                        LanguageLocaleKey='en_US',
                                        LocaleSidKey='en_US',
                                        TimeZoneSidKey='America/Chicago'
                                        );
            Database.insert(portalAccountOwner1);
            
            Account testAccount1=TestUtilities.getAccount(); 
            testAccount1.ownerid = portalAccountOwner1.id;      
            insert testAccount1;             
            Contact testContact1 = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234643@testing.com.testsetup',
                                 AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
            insert testContact1;
             
            UserRole ur = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert ur;
            
            userRecord.Alias = 'StdUser';
            userRecord.contactId =testContact1.id;
            userRecord.Email = 'newuser21@intel.com';
            userRecord.EmailEncodingKey ='UTF-8';
            userRecord.LastName = 'Testing';
            userRecord.FirstName = 'FName';
            userRecord.LanguageLocaleKey = 'en_US';
            userRecord.LocaleSidKey = 'en_US';
            userRecord.TimeZoneSidKey = 'America/Los_Angeles'; 
            userRecord.UserName = 'newuser' + String.valueOf(DateTime.Now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId();
            userRecord.isActive = true;
            
            userRecord.ProfileID =  profiles.get('IPS Agent-Partner');  
            
            insert userRecord; 
            
            // Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
                ContactRec.Core_IPS_Active__c = true;
            }
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');
            // Create Ips Project
            List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(2);
            insert ListOfIpsProjects;
            System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
            // Create Ips Account
            List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            }
            insert ListOfIpsAccounts;
            System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
            // Create Project Member
            List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(1);
            for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
                ProjMem.Core_IPS_Contact__c = testContact1.Id;
                ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                ProjMem.Core_Status__c = 'Active';
                ProjMem.Core_User__c = userRecord.id;
            }
            insert ListOfProjectMembers;
            
            Core_Trigger_Executions__c TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'Core_IPS_Execute_CaseOwnerValidation';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution.Core_Description__c = 'case_Edit_projectDetails';
            TriggerExecution.Core_Object__c = 'Case';
            TriggerExecution.Core_Trigger_Events__c = 'Before Update';
            
            insert TriggerExecution;
            
             // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(4);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                CaseRec.Core_IPS_Project_Case__c = ListOfIpsProjects[0].Id;
                CaseRec.ownerId = userRecord.id;
            }
            
            Test.startTest();
            insert ListOfCases;
            for(Case CaseRec : ListOfCases){
                CaseRec.ownerId = userRecord.id;
            }
            //update ListOfCases;
            
            Test.stopTest();
        
        }
    }
    
    static testmethod void assignCaseInformationfromProject_Test(){
        
     //Create Custom Setting - Trigger Executions
            List<Core_Trigger_Executions__c> triggerExecutionList=new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c  TriggerExecution1 = new Core_Trigger_Executions__c();
            TriggerExecution1.Name = 'assignCaseInformationfromProject';
            TriggerExecution1.Core_Active__c = true;
            TriggerExecution1.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution1.Core_Description__c = 'This method is used update the Project value on Case.';
            TriggerExecution1.Core_Object__c = 'Case';
            TriggerExecution1.Core_Trigger_Events__c = 'Before Insert';
            triggerExecutionList.add(TriggerExecution1);
            insert triggerExecutionList; 
            System.assert(triggerExecutionList[0].id != null);
        
        //added by amritesh - US137508
        Core_IPS_Labels__c ipsLables2 = new Core_IPS_Labels__c(Name = 'Case_RT_Name_IPS_NoAssignedContact',Value__c = 'IPS No Assigned Contact Case');        
        insert ipsLables2;
        
        getRecords ();
        Test.startTest();
        Id intelSupportOwner = ListOfUser.get(0).id;
        System.runAs(ListOfUser.get(1)){
         // Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');
        // Create Ips Project
            List<Core_IPS_Project__c> ListOfIpsProjects = TestUtilities.getListOfIpsProjects(1);
            ListOfIpsProjects[0].Core_IPS_Remove_Notification_Details__c=true;
            ListOfIpsProjects[0].Core_IPS_Support_Level__c='Tier 4';
            ListOfIpsProjects[0].Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
            ListOfIpsProjects[0].Core_IPS_Partner_Support_Owner__c = intelSupportOwner;
            insert ListOfIpsProjects;
        System.assert(ListOfIpsProjects[0].Id != null, 'Record not created');
            // Create Ips Account
            List<Core_IPS_Account__c> ListOfIpsAccounts = TestUtilities.getListOfIpsAccounts(1);
            for(Core_IPS_Account__c IpsAcc : ListOfIpsAccounts){
                IpsAcc.Core_Account__c = ListOfAccounts.get(0).Id;
                IpsAcc.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
            }
            insert ListOfIpsAccounts;
            System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
            // Create Project Member
            List<Core_IPS_Project_Member__c> ListOfProjectMembers = TestUtilities.getListOfProjectMembers(1);
            for(Core_IPS_Project_Member__c ProjMem : ListOfProjectMembers){
                ProjMem.Core_IPS_Contact__c = ListOfContacts.get(0).Id;
                ProjMem.Core_IPS_Project__c = ListOfIpsProjects.get(0).Id;
                ProjMem.Core_User__c = intelSupportOwner;
            }
            insert ListOfProjectMembers;
            System.assert(ListOfProjectMembers[0].Id != null, 'Record not created');
            // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(5);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                CaseRec.Core_IPS_Project_Case__c=ListOfIpsProjects.get(0).Id;
                
            }
            insert ListOfCases;
            Test.stopTest();
            
            //added by amritesh - US137508
            Core_CaseTrigger_Dispatcher.recursivetrigger1 = true;
            ListOfCases[0].Core_IPS_Project_Case__c = null;
            try{
            update ListOfCases[0];
            }catch(Exception exp){}
        }
    }
    
     /***************************************************************************************************
    Method Name:  assignUserManager_Test
    Method Type: Test Method
    Version     : 1.0 
    Description:  assignUserManager Test method
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Amritesh                    25/06/2018             Created - US176778
    ****************************************************************************************************/
    static testmethod void assignUserManager_Test(){
        getRecords();
        Id intelSupportOwner = ListOfUser.get(0).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name='IPS Agent' ];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        system.debug('profiles'+profiles);
        
        //User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        //User userRecord = new User();
        System.runAs ( ListOfUser[0]) { 
            //UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
            User sysadmin = new User(
                                        //UserRoleId = portalRole.Id,
                                        ProfileId = profile1.Id,
                                        Username = 'test1206@intel.com',
                                        Alias = 'testbaty',
                                        Email='newuser155@intel.com',
                                        EmailEncodingKey='UTF-8',
                                        Firstname='Bruce',
                                        Lastname='Wayne',
                                        LanguageLocaleKey='en_US',
                                        LocaleSidKey='en_US',
                                        TimeZoneSidKey='America/Chicago'
                                        );
            Database.insert(sysadmin);
            
            Account testAccount1=TestUtilities.getAccount(); 
            testAccount1.ownerid = sysadmin.id;      
            insert testAccount1;             
            Contact testContact1 = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234643@testing.com.testsetup',
                                 AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
            insert testContact1;
             
            //UserRole ur = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            //insert ur;
            User userRecord = new User();
            userRecord.Alias = 'StdUser';
            //userRecord.contactId =testContact1.id;
            userRecord.Email = 'newuser21@intel.com';
            userRecord.EmailEncodingKey ='UTF-8';
            userRecord.LastName = 'Testing';
            userRecord.FirstName = 'FName';
            userRecord.LanguageLocaleKey = 'en_US';
            userRecord.LocaleSidKey = 'en_US';
            userRecord.TimeZoneSidKey = 'America/Los_Angeles'; 
            userRecord.UserName = 'newuser' + String.valueOf(DateTime.Now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId();
            userRecord.isActive = true;            
            userRecord.ProfileID =  profiles.get('IPS Agent');  
            
            insert userRecord; 
            
            // Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
                ContactRec.Core_IPS_Active__c = true;
            }
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');
            
            Core_Trigger_Executions__c TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'assignUserManager';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution.Core_Description__c = 'assignUserManager';
            TriggerExecution.Core_Object__c = 'Case';
            TriggerExecution.Core_Trigger_Events__c = 'Before Insert, Before Update';
            
            insert TriggerExecution;
            
             // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(2);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;                
                CaseRec.ownerId = sysadmin.id;
            }
            
            Test.startTest();
            insert ListOfCases;
            for(Case CaseRec : ListOfCases){
                CaseRec.ownerId = userRecord.id;
            }
            update ListOfCases;
            
            Test.stopTest();
        
        }
    }
    
    static testmethod void caseOwnerGrp_Test(){
        getRecords();
        Id intelSupportOwner = ListOfUser.get(0).id;
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name='IPS Agent' ];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        system.debug('profiles'+profiles);
        
        //User thisUser = [select Id from User where Id = :UserInfo.getUserId()];
        //User userRecord = new User();
        System.runAs ( ListOfUser[0]) { 
            //UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
            User sysadmin = new User(
                                        //UserRoleId = portalRole.Id,
                                        ProfileId = profile1.Id,
                                        Username = 'test1206@intel.com',
                                        Alias = 'testbaty',
                                        Email='newuser155@intel.com',
                                        EmailEncodingKey='UTF-8',
                                        Firstname='Bruce',
                                        Lastname='Wayne',
                                        LanguageLocaleKey='en_US',
                                        LocaleSidKey='en_US',
                                        TimeZoneSidKey='America/Chicago'
                                        );
            Database.insert(sysadmin);
            
            Account testAccount1=TestUtilities.getAccount(); 
            testAccount1.ownerid = sysadmin.id;      
            insert testAccount1;             
            Contact testContact1 = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234643@testing.com.testsetup',
                                 AccountId=testAccount1.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful');
            insert testContact1;
             
            //UserRole ur = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            //insert ur;
            User userRecord = new User();
            userRecord.Alias = 'StdUser';
            //userRecord.contactId =testContact1.id;
            userRecord.Email = 'newuser21@intel.com';
            userRecord.EmailEncodingKey ='UTF-8';
            userRecord.LastName = 'Testing';
            userRecord.FirstName = 'FName';
            userRecord.LanguageLocaleKey = 'en_US';
            userRecord.LocaleSidKey = 'en_US';
            userRecord.TimeZoneSidKey = 'America/Los_Angeles'; 
            userRecord.UserName = 'newuser' + String.valueOf(DateTime.Now().getTime()) + '@intel.com.' + UserInfo.getOrganizationId();
            userRecord.isActive = true;            
            userRecord.ProfileID =  profiles.get('IPS Agent');  
            
            insert userRecord; 
            
            // Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            for(Account acc: ListOfAccounts){
                acc.Core_CNDA_Number__c='123';
            }
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            // Create Contact
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
                ContactRec.Core_IPS_Active__c = true;
            }
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');
            
            Core_Trigger_Executions__c TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'updateCaseOwnerGroup';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution.Core_Description__c = 'updateCaseOwnerGroup';
            TriggerExecution.Core_Object__c = 'Case';
            TriggerExecution.Core_Trigger_Events__c = 'Before Insert, Before Update';
            
            insert TriggerExecution;
            
            Core_IPS_Product_Organization__c prodOrg = TestUtilities.getSupportOrg();
            insert prodOrg;
            
            Product2 prod = TestUtilities.getProduct();
            insert prod; 
            
            Core_IPS_Supported_Product__c sp=TestUtilities.getSupportedProduct();
            sp.Core_Product__c = prod.id;
            sp.Core_Product_Organization__c = prodOrg.id;
            sp.Core_Flag_Status__c = 'Auto Approve';
            insert sp; 
            
            Core_IPS_Case_Owner_Group__c ownerGrp = new Core_IPS_Case_Owner_Group__c(
                Core_IPS_Case_Owner__c=sysadmin.Id,
                Core_IPS_Support_Org__c=prodOrg.Id,
                Core_IPS_Owner_Group_1__c = 'test'
            );
            insert  ownerGrp;
            
             // Create Case
            List<Case> ListOfCases = TestUtilities.getListOfCases(2);
            for(Case CaseRec : ListOfCases){
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;                
                CaseRec.ownerId = sysadmin.id;
                CaseRec.Core_IPS_Supported_Product__c = sp.Id; 
                //CaseRec.Core_IPS_Product_Org1__c = prodOrg.Id;
            }
            
            Test.startTest();
            
            insert ListOfCases;
            
            Test.stopTest();
        
        }
    }
    
    
    static testmethod void caseProjProdOwner_Test(){
        
            getrecords();
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('IPS Support Org Admin');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        
        //Create Role
        UserRole r = [SELECT Id, Name FROM UserRole WHERE DeveloperName = 'IPS_Product_Org_Admin' LIMIT 1];
        
        User userRecord = new User(
            Alias = 'StdUser', 
            Email = 'newuser211@intel.com', 
            EmailEncodingKey ='UTF-8',
            LastName = 'Testing',
            FirstName = 'FName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'nnnnewuser12300000@intel.com',
            isActive = true,
            UserRoleId = r.Id
            
        );
        
        
        List<User> ListOfUser1 = new List<User>{userRecord}; //TestUtilities.getListOfUser(1);
            ListOfUser1.get(0).ProfileID =  profiles.get('IPS Support Org Admin');
        //ListOfUser1.get(1).ProfileID =  profiles.get('IPS Support Org Admin');
        
        insert ListOfUser1; 
      
       List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
       System.runAs(ListOfUser.get(0)){
        insert ListofIpsLables;
       }
       /*List<Core_Trigger_Executions__c> ListOfTriggerExecutions = TestUtilities.getListOfTriggerExecutions();
        System.runAs(ListOfUser.get(0)){    
        insert ListOfTriggerExecutions;
        } */
      //  System.runAs(ListOfUser.get(1)){
        Product2 prod = TestUtilities.getProduct();
        System.runAs(ListOfUser1.get(0)){
                insert prod; 
                } 
        
        Account acctRecord=TestUtilities.getAccountRecord();
       // acctRecord.OwnerId= ListOfUser.get(1).id;
        acctRecord.Core_CNDA_Number__c='123';
        System.runAs(ListOfUser1.get(0)){
                insert acctRecord; 
                } 
        //insert acctRecord;
     //   System.debug('acctRecord>>'+acctRecord.Owner.UserRole.Name+' ListOfUser.get(1) '+ListOfUser.get(1));
        Contact contactRecord;
        contactRecord = TestUtilities.getContact();
        contactRecord.Accountid = acctRecord.id;
       // contactRecord.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        contactRecord.core_ips_Active__c=false;
        contactRecord.Email = 'ContactDellTest@gmail.com';
        System.runAs(ListOfUser.get(0)){
                insert contactRecord; 
                } 
        //insert contactRecord;
        System.debug('contactRecord '+contactRecord);
        
        Core_IPS_Product_Organization__c prodOrg = TestUtilities.getSupportOrg();
        System.runAs(ListOfUser.get(0)){
                insert prodOrg; 
                } 
        //insert prodOrg;
        Core_IPS_Supported_Product__c sp=TestUtilities.getSupportedProduct();
         sp.Core_Product__c = prod.id;
        sp.Core_Product_Organization__c = prodOrg.id;
        sp.Core_Flag_Status__c = 'Auto Approve';
        System.runAs(ListOfUser.get(0)){
                insert sp; 
                } 
       // insert sp;
    
    Id projectRecordTypeId = Schema.SObjectType.Core_IPS_Project__c.getRecordTypeInfosByName().get('Active').getRecordTypeId();
    Core_IPS_Project__c ipsProjectRecord = new Core_IPS_Project__c(
            Name = 'projIPSTestProject Grv',
            Core_Status__c = 'Draft',
            Core_MPNDA__c='12345',
            recordTypeId = projectRecordTypeId
        );
    test.startTest();
    List<Core_IPS_Project__c> ListOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
            System.runAs(ListOfUser1.get(0)){
                insert ListOfIpsProjects; 
                } 
        
    
           System.debug('>>SP>>'+sp);
        for(Core_IPS_Project__c proj: ListOfIpsProjects){
        
        core_ips_account__c projAccount= TestUtilities.getCoreIpsAccount();
        projAccount.Core_Account__c=acctRecord.Id;
        projAccount.Core_IPS_Project__c=proj.Id;
        System.runAs(ListOfUser1.get(0)){
                insert projAccount; 
                } 
           // insert projAccount;
        
        Core_IPS_Project_Member__c projectMember = TestUtilities.getProjectMember();
        projectMember.core_ips_contact__c = contactRecord.id;
        projectMember.Core_IPS_Project__c = proj.id;
        System.runAs(ListOfUser1.get(0)){
                insert projectMember; 
                } 
            //insert projectMember;
        
        Core_IPS_Product__c projProduct=TestUtilities.getIpsProduct();
        projProduct.Core_IPS_Project__c=proj.Id;
        projProduct.Core_Supported_Product__c=sp.Id;
        System.runAs(ListOfUser1.get(0)){
                insert projProduct; 
                } 
           // insert projProduct;
        System.debug('>>projProduct>>'+projProduct+'>>spId>>'+sp.Id);
        
      }

    //List<Core_IPS_Project__c> ListOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
            System.runAs(ListOfUser1.get(0)){
                ListOfIpsProjects.get(0).Core_Status__c = 'Submitted Pending';
                update ListOfIpsProjects;
                } 
        
    List<Entitlement> ListOfEntitlement = TestUtilities.getListOfEntitlement(1);
            for(Entitlement EntitlementRec : ListOfEntitlement){
                EntitlementRec.AccountId = acctRecord.Id;
                
            }
         System.runAs(ListOfUser.get(0)){
            insert ListOfEntitlement;
         }
    
      Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId();
      Case c2 = TestUtilities.getListOfCases(1).get(0);
                c2.RecordTypeId = devRecordTypeId;
                //c2.assetId = AssetList.get(1).Id;
                c2.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                c2.Core_IPS_Supported_Product__c = sp.Id;  
            c2.EntitlementId=ListOfEntitlement.get(0).id;
                System.runAs(ListOfUser1.get(0)){
                  insert  c2; 
                }
        List<Case> caseList = new List<Case>{c2};
        Core_IPS_CaseTriggerHandler.assignProjectCasesOwner(caseList); 
        System.runAs(ListOfUser.get(0)){
            c2.Subject='test Grv Prvt Proj Owner';      
            update  c2; 
                }
        test.stopTest();
       
    }
    
   static testmethod void caseProjProdOwnerUpdate_Test(){
        
            getrecords();
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('IPS Support Org Admin');
       
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        
        //Create Role
        UserRole r = [SELECT Id, Name FROM UserRole WHERE DeveloperName = 'IPS_Product_Org_Admin' LIMIT 1];
        
        User userRecord = new User(
            Alias = 'StdUser', 
            Email = 'newuser211@intel.com', 
            EmailEncodingKey ='UTF-8',
            LastName = 'Testing',
            FirstName = 'FName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'nnnnewuser12300000@intel.com',
            isActive = true,
            UserRoleId = r.Id
            
        );
        
        
        List<User> ListOfUser1 = new List<User>{userRecord}; //TestUtilities.getListOfUser(1);
            ListOfUser1.get(0).ProfileID =  profiles.get('IPS Support Org Admin');
        //ListOfUser1.get(1).ProfileID =  profiles.get('IPS Support Org Admin');
        
        insert ListOfUser1; 
      
      /* List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
       System.runAs(ListOfUser.get(0)){
        insert ListofIpsLables;
       } */
      //  System.runAs(ListOfUser.get(1)){
        Product2 prod1 = TestUtilities.getProduct();
        Product2 prod2 = TestUtilities.getProduct();
        prod2.Name='test Prod2';
        List<Product2> prodList = new List<Product2>();
        prodList.add(prod1);
        prodList.add(prod2);
        System.runAs(ListOfUser1.get(0)){
                insert prodList; 
                } 
        test.startTest();
        Account acctRecord=TestUtilities.getAccountRecord();
       // acctRecord.OwnerId= ListOfUser.get(1).id;
        acctRecord.Core_CNDA_Number__c='123';
        System.runAs(ListOfUser1.get(0)){
                insert acctRecord; 
                } 
        //insert acctRecord;
     //   System.debug('acctRecord>>'+acctRecord.Owner.UserRole.Name+' ListOfUser.get(1) '+ListOfUser.get(1));
        Contact contactRecord;
        contactRecord = TestUtilities.getContact();
        contactRecord.Accountid = acctRecord.id;
       // contactRecord.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        contactRecord.core_ips_Active__c=false;
        contactRecord.Email = 'ContactDellTest@gmail.com';
        System.runAs(ListOfUser.get(0)){
                insert contactRecord; 
                } 
        //insert contactRecord;
        System.debug('contactRecord '+contactRecord);
        List<Core_IPS_Product_Organization__c> suppOrgList = new List<Core_IPS_Product_Organization__c>();
        Core_IPS_Product_Organization__c prodOrg = TestUtilities.getSupportOrg();
        Core_IPS_Product_Organization__c prodOrg2 = TestUtilities.getSupportOrg();
         suppOrgList.add(prodOrg);
       suppOrgList.add(prodOrg2);
        System.runAs(ListOfUser.get(0)){
                insert suppOrgList; 
                } 
       
        List<Core_IPS_Supported_Product__c> spList = new List<Core_IPS_Supported_Product__c>();
        Core_IPS_Supported_Product__c sp1=TestUtilities.getSupportedProduct();
        sp1.Core_Product__c = prod1.id;
        sp1.Core_Product_Organization__c = prodOrg.id;
        sp1.Core_Flag_Status__c = 'Auto Approve';
        Core_IPS_Supported_Product__c sp2 = new Core_IPS_Supported_Product__c();
            sp2.Core_EOIS__c = false;
            sp2.Core_Supported_Product_Name__c = 'Haswell EP';
        sp2.Core_Product__c = prod2.id;
        sp2.Core_Product_Organization__c = prodOrg2.id;
        sp2.Core_Flag_Status__c = 'Auto Approve';
        spList.add(sp1);
        spList.add(sp2);
       System.runAs(ListOfUser.get(0)){
                insert spList; 
                } 
       // insert sp;
    
    Id projectRecordTypeId = Schema.SObjectType.Core_IPS_Project__c.getRecordTypeInfosByName().get('Active').getRecordTypeId();
    Core_IPS_Project__c ipsProjectRecord = new Core_IPS_Project__c(
            Name = 'projIPSTestProject Grv',
            Core_Status__c = 'Draft',
            Core_MPNDA__c='12345',
            core_ips_private__c=true,
            recordTypeId = projectRecordTypeId
        );
    
    List<Core_IPS_Project__c> ListOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
            System.runAs(ListOfUser1.get(0)){
                insert ListOfIpsProjects; 
                } 
        
        // insert projAccount;
        for(Core_IPS_Project__c proj: ListOfIpsProjects){
        core_ips_account__c projAccount= TestUtilities.getCoreIpsAccount();
        projAccount.Core_Account__c=acctRecord.Id;
        projAccount.Core_IPS_Project__c=proj.Id;
        System.runAs(ListOfUser1.get(0)){
                insert projAccount; 
                } 
        
        //insert projectMember;    
        Core_IPS_Project_Member__c projectMember = TestUtilities.getProjectMember();
        projectMember.core_ips_contact__c = contactRecord.id;
        projectMember.Core_IPS_Project__c = proj.id;
        System.runAs(ListOfUser1.get(0)){
                insert projectMember; 
                } 
        // insert projProduct
        List<Core_IPS_Product__c> projProdList = new List<Core_IPS_Product__c>();
        Core_IPS_Product__c projProduct1=TestUtilities.getIpsProduct();
        projProduct1.Core_IPS_Project__c=proj.Id;
        projProduct1.Core_Supported_Product__c=sp1.Id;
        //projProduct1.Core_IPS_Product_Case_Owner__c = ListOfUser1.get(0).Id;  
        
        Core_IPS_Product__c projProduct2=TestUtilities.getIpsProduct();
        projProduct2.Core_IPS_Project__c=proj.Id;
        projProduct2.Core_Supported_Product__c=sp2.Id;
        //projProduct2.Core_IPS_Product_Case_Owner__c = ListOfUser1.get(0).Id;      
        projProdList.add(projProduct1);
        projProdList.add(projProduct2);    
        System.runAs(ListOfUser1.get(0)){
                insert projProdList; 
        } 
      }
	test.stopTest();
    //List<Core_IPS_Project__c> ListOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
            System.runAs(ListOfUser1.get(0)){
                ListOfIpsProjects.get(0).Core_Status__c = 'Active';
                update ListOfIpsProjects;
                } 
    
     
       List<Asset> projAssetList = [Select Id,Core_IPS_Project__c,Core_Supported_Product__c from Asset where Core_IPS_Project__c =:ListOfIpsProjects.get(0).id];   
       
    
       List<Entitlement> ListOfEntitlement = TestUtilities.getListOfEntitlement(1);
            for(Entitlement EntitlementRec : ListOfEntitlement){
                EntitlementRec.AccountId = acctRecord.Id;
                
            }
         System.runAs(ListOfUser.get(0)){
            insert ListOfEntitlement;
         }
    
      Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId();
      
      Case c2 = TestUtilities.getListOfCases(1).get(0);
                c2.RecordTypeId = devRecordTypeId;
                c2.Core_IPS_Self_Assigned__c =true; 
                c2.assetId = projAssetList.get(0).Id;
                c2.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                c2.Core_IPS_Supported_Product__c = projAssetList.get(0).Core_Supported_Product__c;  
        	    c2.EntitlementId=ListOfEntitlement.get(0).id;
       			c2.Core_IPS_Private_Project__c = true;
                System.runAs(ListOfUser.get(0)){
                  insert  c2; 
                }
       final Map<Id,Case> mCase = new Map<Id,Case>();
       mCase.put(c2.Id,c2);
       System.debug('------------mCase1'+mCase); 
       /* System.runAs(ListOfUser.get(0)){
            c2.Subject='test Grv Prvt Proj Owner';
            c2.Core_IPS_Supported_Product__c = projAssetList.get(1).Core_Supported_Product__c;  
            c2.assetid = projAssetList.get(1).Id;
            update  c2; 
                } */
       System.debug('-----------------case c2:'+c2.AssetId+'-'+c2.Core_IPS_Supported_Product__c+'-'+c2.Core_IPS_Private_Project__c);
       
       List<Case> caseList = new List<Case>{c2};
           Case c3 = new Case();
       c3.Id=c2.Id;
       c3.assetId=projAssetList.get(1).Id;
       c3.Core_IPS_Supported_Product__c = projAssetList.get(1).Core_Supported_Product__c; 
       c3.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
       c3.Core_IPS_Private_Project__c = true;
       List<Case> newCaseList = new List<Case>{c3};
       Core_IPS_CaseTriggerHandler.assignCaseOwnerOnProdUpdate(mCase, newCaseList);
       
    }
    
  static testmethod void caseProjProdOwnerUpdate1_Test(){
        
            getrecords();
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('IPS Support Org Admin');
       
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        
        //Create Role
        UserRole r = [SELECT Id, Name FROM UserRole WHERE DeveloperName = 'IPS_Product_Org_Admin' LIMIT 1];
        
        User userRecord = new User(
            Alias = 'StdUser', 
            Email = 'newuser211@intel.com', 
            EmailEncodingKey ='UTF-8',
            LastName = 'Testing',
            FirstName = 'FName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'nnnnewuser12300000@intel.com',
            isActive = true,
            UserRoleId = r.Id
            
        );
        
        
        List<User> ListOfUser1 = new List<User>{userRecord}; //TestUtilities.getListOfUser(1);
            ListOfUser1.get(0).ProfileID =  profiles.get('IPS Support Org Admin');
        //ListOfUser1.get(1).ProfileID =  profiles.get('IPS Support Org Admin');
        
        insert ListOfUser1; 
      
      /* List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
       System.runAs(ListOfUser.get(0)){
        insert ListofIpsLables;
       } */
      //  System.runAs(ListOfUser.get(1)){
        Product2 prod1 = TestUtilities.getProduct();
        Product2 prod2 = TestUtilities.getProduct();
        prod2.Name='test Prod2';
        List<Product2> prodList = new List<Product2>();
        prodList.add(prod1);
        prodList.add(prod2);
        System.runAs(ListOfUser1.get(0)){
                insert prodList; 
                } 
        test.startTest();
        Account acctRecord=TestUtilities.getAccountRecord();
       // acctRecord.OwnerId= ListOfUser.get(1).id;
        acctRecord.Core_CNDA_Number__c='123';
        System.runAs(ListOfUser1.get(0)){
                insert acctRecord; 
                } 
        //insert acctRecord;
     //   System.debug('acctRecord>>'+acctRecord.Owner.UserRole.Name+' ListOfUser.get(1) '+ListOfUser.get(1));
        Contact contactRecord;
        contactRecord = TestUtilities.getContact();
        contactRecord.Accountid = acctRecord.id;
       // contactRecord.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        contactRecord.core_ips_Active__c=false;
        contactRecord.Email = 'ContactDellTest@gmail.com';
        System.runAs(ListOfUser.get(0)){
                insert contactRecord; 
                } 
        //insert contactRecord;
        System.debug('contactRecord '+contactRecord);
        List<Core_IPS_Product_Organization__c> suppOrgList = new List<Core_IPS_Product_Organization__c>();
        Core_IPS_Product_Organization__c prodOrg = TestUtilities.getSupportOrg();
        Core_IPS_Product_Organization__c prodOrg2 = TestUtilities.getSupportOrg();
         suppOrgList.add(prodOrg);
       suppOrgList.add(prodOrg2);
        System.runAs(ListOfUser.get(0)){
                insert suppOrgList; 
                } 
       
        List<Core_IPS_Supported_Product__c> spList = new List<Core_IPS_Supported_Product__c>();
        Core_IPS_Supported_Product__c sp1=TestUtilities.getSupportedProduct();
        sp1.Core_Product__c = prod1.id;
        sp1.Core_Product_Organization__c = prodOrg.id;
        sp1.Core_Flag_Status__c = 'Auto Approve';
        Core_IPS_Supported_Product__c sp2 = new Core_IPS_Supported_Product__c();
            sp2.Core_EOIS__c = false;
            sp2.Core_Supported_Product_Name__c = 'Haswell EP';
        sp2.Core_Product__c = prod2.id;
        sp2.Core_Product_Organization__c = prodOrg2.id;
        sp2.Core_Flag_Status__c = 'Auto Approve';
        spList.add(sp1);
        spList.add(sp2);
       System.runAs(ListOfUser.get(0)){
                insert spList; 
                } 
       // insert sp;
    
    Id projectRecordTypeId = Schema.SObjectType.Core_IPS_Project__c.getRecordTypeInfosByName().get('Active').getRecordTypeId();
    Core_IPS_Project__c ipsProjectRecord = new Core_IPS_Project__c(
            Name = 'projIPSTestProject Grv',
            Core_Status__c = 'Draft',
            Core_MPNDA__c='12345',
            core_ips_private__c=true,
            recordTypeId = projectRecordTypeId
        );
    
    List<Core_IPS_Project__c> ListOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
            System.runAs(ListOfUser1.get(0)){
                insert ListOfIpsProjects; 
                } 
        
        // insert projAccount;
        for(Core_IPS_Project__c proj: ListOfIpsProjects){
        core_ips_account__c projAccount= TestUtilities.getCoreIpsAccount();
        projAccount.Core_Account__c=acctRecord.Id;
        projAccount.Core_IPS_Project__c=proj.Id;
        System.runAs(ListOfUser1.get(0)){
                insert projAccount; 
                } 
        
        //insert projectMember;    
        Core_IPS_Project_Member__c projectMember = TestUtilities.getProjectMember();
        projectMember.core_ips_contact__c = contactRecord.id;
        projectMember.Core_IPS_Project__c = proj.id;
        System.runAs(ListOfUser1.get(0)){
                insert projectMember; 
                } 
        // insert projProduct
        List<Core_IPS_Product__c> projProdList = new List<Core_IPS_Product__c>();
        Core_IPS_Product__c projProduct1=TestUtilities.getIpsProduct();
        projProduct1.Core_IPS_Project__c=proj.Id;
        projProduct1.Core_Supported_Product__c=sp1.Id;
        projProduct1.Core_IPS_Product_Case_Owner__c = ListOfUser1.get(0).Id;  
        
        Core_IPS_Product__c projProduct2=TestUtilities.getIpsProduct();
        projProduct2.Core_IPS_Project__c=proj.Id;
        projProduct2.Core_Supported_Product__c=sp2.Id;
        projProduct2.Core_IPS_Product_Case_Owner__c=ListOfUser1.get(0).Id;
        //projProduct2.Core_IPS_Product_Case_Owner__c = ListOfUser1.get(0).Id;      
        projProdList.add(projProduct1);
        projProdList.add(projProduct2);    
        System.runAs(ListOfUser1.get(0)){
                insert projProdList; 
        } 
      }
	test.stopTest();
    //List<Core_IPS_Project__c> ListOfIpsProjects = new List<Core_IPS_Project__c>{ipsProjectRecord};
            System.runAs(ListOfUser1.get(0)){
                ListOfIpsProjects.get(0).Core_Status__c = 'Active';
                update ListOfIpsProjects;
                } 
    
     
       List<Asset> projAssetList = [Select Id,Core_IPS_Project__c,Core_Supported_Product__c from Asset where Core_IPS_Project__c =:ListOfIpsProjects.get(0).id];   
       
    
       List<Entitlement> ListOfEntitlement = TestUtilities.getListOfEntitlement(1);
            for(Entitlement EntitlementRec : ListOfEntitlement){
                EntitlementRec.AccountId = acctRecord.Id;
                
            }
         System.runAs(ListOfUser.get(0)){
            insert ListOfEntitlement;
         }
    
      Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId();
      
      Case c2 = TestUtilities.getListOfCases(1).get(0);
                c2.RecordTypeId = devRecordTypeId;
                c2.Core_IPS_Self_Assigned__c =true; 
                c2.assetId = projAssetList.get(0).Id;
                c2.Core_IPS_Project_Case__c = ListOfIpsProjects.get(0).id;
                c2.Core_IPS_Supported_Product__c = projAssetList.get(0).Core_Supported_Product__c;  
        	    c2.EntitlementId=ListOfEntitlement.get(0).id;
       			c2.Core_IPS_Private_Project__c = true;
                System.runAs(ListOfUser.get(0)){
                  insert  c2; 
                }
  }
}