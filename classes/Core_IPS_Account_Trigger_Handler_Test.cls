/***************************************************************************************************
Class Name:  Core_IPS_Account_Trigger_Handler_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 08 Mar 2016
Function    : This class contains test coverage for Core_IPS_Account_Trigger_Handler class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_Account_Trigger_Handler class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Arya            25/01/2016           Modified
****************************************************************************************************/   
@isTest
public class Core_IPS_Account_Trigger_Handler_Test{
    //Instance variables that are commonly used in multiple test methods
    static List<User> ListOfUser = new List<User> ();
    static Group grp = new Group();
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
Method Name:  updateAccountOwner_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 08 Mar 2016
Description:  Testing with Account record
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Syed Moosa Nazir TN       11/06/2015                Created
* Deepak Jetty        25/01/2016          Modified
****************************************************************************************************/
    static testmethod void updateAccountOwner_Test(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;        
        System.runAs(ListOfUser.get(1)){ 
            
            Core_Trigger_Executions__c OpportunityFactsUpdate = new Core_Trigger_Executions__c();
            OpportunityFactsUpdate.name = 'accountObjectBeforeHandler';
            OpportunityFactsUpdate.Core_Object__c = 'Descriptive Feature';
            OpportunityFactsUpdate.Core_Trigger_Events__c = 'After insert';
            OpportunityFactsUpdate.Core_Active__c = TRUE;
            OpportunityFactsUpdate.Core_Description__c = 'This is test description';
            OpportunityFactsUpdate.Core_Class_Name__c = 'Test Class';
            
            Core_Trigger_Executions__c OpportunityFactsUpdate1 = new Core_Trigger_Executions__c();
            OpportunityFactsUpdate1.name = 'accountObjectAfterDelete';
            OpportunityFactsUpdate1.Core_Object__c = 'Descriptive Feature';
            OpportunityFactsUpdate1.Core_Trigger_Events__c = 'After insert';
            OpportunityFactsUpdate1.Core_Active__c = TRUE;
            OpportunityFactsUpdate1.Core_Description__c = 'This is test description';
            OpportunityFactsUpdate1.Core_Class_Name__c = 'Test Class';            
            insert OpportunityFactsUpdate;
            insert OpportunityFactsUpdate1 ;
            
            // Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            for(Account acc:ListOfAccounts){
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
            // Create Product Access
            List<Core_IPS_MAP_PAR__c> MapParList = TestUtilities.getMapParList(1);
            Map<string,ID> MapRecordtype = new Map<string,ID>();
            for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Core_IPS_MAP_PAR__c'])
            {  
                MapRecordtype.put(Rt.Name,Rt.ID);
            } 
            System.runAs(ListOfUser[0]){
                for(Core_IPS_MAP_PAR__c parObj:MapParList){
                    parObj.RecordTypeId = MapRecordtype.get('PAR');
                }
                insert MapParList;
            }
            List<Core_IPS_MAP_Account__c> IPSMAPAccountList = TestUtilities.getIPSMAPAccountList(200);
            for(Core_IPS_MAP_Account__c IPSMAPAccount:IPSMAPAccountList){
                IPSMAPAccount.Core_Account__c = ListOfAccounts[Counter].id;   
                IPSMAPAccount.Core_MAP_PAR__c = MapParList[0].id;
                //Counter++;
            }
            Counter = 0;
            System.runAs(ListOfUser[0]){
                insert IPSMAPAccountList;
            }
            System.assert(ListOfIpsAccounts[0].Id != null, 'Record not created');
            for(Account acnObj:ListOfAccounts){
                acnObj.OwnerId = intelSupportOwner;
            }            
            update ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            for(Account acnObj:ListOfAccounts){
                acnObj.Core_IPS_Active__c = False;
            }            
            update ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            for(Account acnObj:ListOfAccounts){
                acnObj.Core_IPS_Active__c = True;
            }            
            update ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        }
    }
    
    /***************************************************************************************************
Method Name : updateAccount_ECB_Scenario
Method Type: Test Method
Version     : 1.0 
Created Date: 16 Mar 2016
Description:  Testing with Account record
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Arya             16/03/2016                 Created
****************************************************************************************************/
    static testmethod void updateAccount_ECB_Scenario(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;        
        System.runAs(ListOfUser.get(1)){ 
            List<Core_Trigger_Executions__c> toggleList = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c OpportunityFactsUpdate = new Core_Trigger_Executions__c();
            OpportunityFactsUpdate.name = 'accountObjectBeforeHandler';
            OpportunityFactsUpdate.Core_Object__c = 'Descriptive Feature';
            OpportunityFactsUpdate.Core_Trigger_Events__c = 'After insert';
            OpportunityFactsUpdate.Core_Active__c = TRUE;
            OpportunityFactsUpdate.Core_Description__c = 'This is test description';
            OpportunityFactsUpdate.Core_Class_Name__c = 'Test Class';
            toggleList.add(OpportunityFactsUpdate);
            Core_Trigger_Executions__c OpportunityFactsUpdate1 = new Core_Trigger_Executions__c();
            OpportunityFactsUpdate1.name = 'accountObjectAfterDelete';
            OpportunityFactsUpdate1.Core_Object__c = 'Descriptive Feature';
            OpportunityFactsUpdate1.Core_Trigger_Events__c = 'After insert';
            OpportunityFactsUpdate1.Core_Active__c = TRUE;
            OpportunityFactsUpdate1.Core_Description__c = 'This is test description';
            OpportunityFactsUpdate1.Core_Class_Name__c = 'Test Class';            
            toggleList.add(OpportunityFactsUpdate1);
           
            Core_Trigger_Executions__c accountECBCheck = new Core_Trigger_Executions__c();
            accountECBCheck.name = 'UpdateContactOnECBCheck';
            accountECBCheck.Core_Object__c = 'Descriptive Feature';
            accountECBCheck.Core_Trigger_Events__c = 'After insert,after update';
            accountECBCheck.Core_Active__c = TRUE;
            accountECBCheck.Core_Description__c = 'This is test description';
            accountECBCheck.Core_Class_Name__c = 'Core_IPS_Account_Trigger_Handler';  
            toggleList.add(accountECBCheck);   
            insert toggleList;
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
            //Test.startTest();
            insert ListOfContacts;
            System.assert(ListOfContacts[0].Id != null, 'Record not created');
            
            for(Account acnObj:ListOfAccounts){
                acnObj.Core_Export_Compliance_Block__c = true;
            }            
            update ListOfAccounts;
            
            //Test.stopTest();
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');            
        }
    }
}