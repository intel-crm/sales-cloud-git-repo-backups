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
            
            /*for(Account acnObj:ListOfAccounts){
                acnObj.Core_Export_Compliance_Block__c = true;
            }            
            update ListOfAccounts;*/
            
            //Test.stopTest();
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');            
        }
    }
    /***************************************************************************************************
Method Name : CIMUpdateTest
Method Type: Test Method
Version     : 1.0 
Created Date: 06 Jan 2018
Description:  Whenever CIM Id is Stamped
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Javid Sayeed            06/01/2022                 Created
****************************************************************************************************/
    static testmethod void CIMUpdateTest(){
        getRecords();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;     
        System.runAs(ListOfUser.get(1)){ 
            List<Core_Trigger_Executions__c> toggleList = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c OpportunityFactsUpdate = new Core_Trigger_Executions__c();
            OpportunityFactsUpdate.name = 'CIMIDStampCheck';
            OpportunityFactsUpdate.Core_Object__c = 'Descriptive Feature';
            OpportunityFactsUpdate.Core_Trigger_Events__c = 'After Update';
            OpportunityFactsUpdate.Core_Active__c = TRUE;
            OpportunityFactsUpdate.Core_Description__c = 'This is test description';
            OpportunityFactsUpdate.Core_Class_Name__c = 'Test Class';
            toggleList.add(OpportunityFactsUpdate);
            Insert toggleList;
            
            // Create Accounts
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            List<Account> NewAccountList = new List<Account> () ;
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
             
            for(Account acnObj:ListOfAccounts){
                acnObj.Core_CIM_ID__c = '12324';
                acnObj.Core_Intel_Partner_Alliance_PartnerGroup__c = true ;
                NewAccountList.add(acnObj);
            }            
            update NewAccountList;
            System.assert(NewAccountList[0].Core_CIM_ID__c != null, 'CIM not created');         
      
        }
    }
    
      @isTest
    public static void testabc(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'iuser', Email='standarduser@example.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='standarduser@intel.com');
        insert u ;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User u1 = new User(Alias = 'standt', Email='standarduser@intel.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p1.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@intel.com');
        insert u1 ;
        
        Id recordTypeIdOPIDAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_ParentAccRecordType).getRecordTypeId();
        Id recordTypeIdMAP = Schema.SObjectType.Core_IPS_MAP_PAR__c.getRecordTypeInfosByName().get('PAR').getRecordTypeId();
        Id accountRecordTypeIntel =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        List<Account> accList = new List<Account>();
        List<Account> accList1 = new List<Account>();
        List<Account> accList2 = new List<Account>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        Map<Id,Account> accMap1 = new Map<Id,Account>();
        Map<Id,Account> accMap2 = new Map<Id,Account>();
        Map<Id,Account> accMap3 = new Map<Id,Account>();
        Map<Id,Account> accMap4 = new Map<Id,Account>();
        
        Account newAccount3 = new Account();//Account
        newAccount3.RecordTypeId = recordTypeIdOPIDAcc;
        newAccount3.Name='Test 4';
        newAccount3.BillingCity='City';
        newAccount3.BillingStreet='Street';
        newAccount3.BillingCountry='India';
        newAccount3.BillingPostalCode='Postal code';
        newAccount3.Core_IPA_Partner_Role__c = 'Solution Integrator';
        newAccount3.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount3.Core_IPA_Badge_Tier__c = 'Partner';//'Gold';
        newAccount3.Core_IPA_Partner_Segment__c = 'Client Computing';
        insert newAccount3;
        
        Account newAccount34 = new Account();//Account
        newAccount34.RecordTypeId = recordTypeIdOPIDAcc;
        newAccount34.Name='Test 34';
        newAccount34.BillingCity='pune';
        newAccount34.BillingStreet='Street';
        newAccount34.BillingCountry='India';
        newAccount34.BillingPostalCode='767613';
        newAccount34.Core_IPA_Partner_Role__c = 'Solution Integrator';
        newAccount34.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount34.Core_IPA_Partner_Segment__c = 'Data Center';
        newAccount34.Core_IPA_Badge_Tier__c = 'Partner'; //'Member';
        insert newAccount34;
        accList1.add(newAccount34);
    accMap2.put(newAccount34.id,newAccount3);        
        
        Account accIntel1 = PRM_TestUtility.getAccount();
        accIntel1.RecordTypeId = accountRecordTypeIntel;
        accIntel1.AccountNumber = '4357659738';
        accIntel1.Name='TestUser1';
        accIntel1.BillingCity='Pune';
        accIntel1.BillingCountryCode='IND';
        accIntel1.BillingStreet='Joshi Marg';
        accIntel1.BillingPostalCode='6546787';
        accIntel1.BillingStateCode='KA';
        accIntel1.Core_CIM_ID__c='2345987';
        accIntel1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel1.Industry = 'Construction';
        accIntel1.Core_IPS_Active__c = false;
        accIntel1.Core_IPA_One_Partner_Id__c = newAccount3.Id;
        accIntel1.OwnerId = u.Id;
        accIntel1.Core_IPA_Badge_Tier__c = 'Partner'; //'Gold';
        accIntel1.Core_IPA_Partner_Segment__c = 'Data Center';
        accIntel1.Core_IPS_Active__c = true;
        accIntel1.Core_CNDA_Number__c = '567436';
        insert accIntel1;
        
        Account accIntel2 = PRM_TestUtility.getAccount();
        accIntel2.RecordTypeId = accountRecordTypeIntel;
        accIntel2.AccountNumber = '67825241155';
        accIntel2.Name='TestUser2';
        accIntel2.BillingCity='Mumbai';
        accIntel2.BillingCountryCode='IND';
        accIntel2.BillingStreet='Joshi Marg';
        accIntel2.BillingPostalCode='411015';
        accIntel2.BillingStateCode='KA';
        accIntel2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel2.Industry = 'Construction';
        accIntel2.Core_IPS_Active__c = false;
        accIntel2.Core_IPA_One_Partner_Id__c = newAccount3.Id;
        accIntel2.OwnerId = u1.Id;
        accIntel2.Core_IPA_Badge_Tier__c = 'Partner'; //'Member';
        accIntel2.Core_IPA_Partner_Segment__c = 'Client Computing';
        accIntel2.Core_Deactivated__c = false;
        insert accIntel2;
        
        Account accIntel3 = PRM_TestUtility.getAccount();
        accIntel3.RecordTypeId = accountRecordTypeIntel;
        accIntel3.AccountNumber = '4357659738';
        accIntel3.Name='TestUser3';
        accIntel3.BillingCity='Nagpur';
        accIntel3.BillingCountryCode='IND';
        accIntel3.BillingStreet='Joshi Marg';
        accIntel3.BillingPostalCode='5410091';
        accIntel3.BillingStateCode='KA';
        accIntel3.Core_CIM_ID__c='7676811';
        accIntel3.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel3.Industry = 'Construction';
        accIntel3.Core_IPS_Active__c = false;
        accIntel3.Core_IPA_One_Partner_Id__c = newAccount3.Id;
        accIntel3.OwnerId = u.Id;
        accIntel3.Core_IPA_Badge_Tier__c = 'Partner';//'Gold';
        accIntel3.Core_IPA_Partner_Segment__c = 'Data Center';
        accIntel3.Core_Deactivated__c = true;
        accIntel3.Core_Deactivation_Reason__c = 'Duplicate Account';
        insert accIntel3;
        
        Account acc = new Account();//Account 
        acc.RecordTypeId = recordTypeIdOPIDAcc;
        acc.Name='Amazon';
        acc.Core_PAG_Grouping_Method__c ='GLBL';
        insert acc;
        
        Account acc1 = new Account();//Account 
        acc1.RecordTypeId = recordTypeIdOPIDAcc;
        acc1.Name='Amazon Test';
        acc1.Core_PAG_Grouping_Method__c ='CTRY';
        insert acc1;
        accList2.add(acc);
        accMap4.put(acc.Id, acc1);        
        
        Core_IPS_MAP_PAR__c imp = new Core_IPS_MAP_PAR__c();
        imp.Core_isPARRequest__c = true;
        imp.RecordTypeId = recordTypeIdMAP;
        insert imp;
        
        Core_IPS_MAP_Account__c ima = new Core_IPS_MAP_Account__c();
        ima.Core_Account__c = accIntel1.id;
        ima.Core_MAP_PAR__c = imp.id;
        insert ima;
        
        Core_IPS_Project__c ipc = new Core_IPS_Project__c();
        ipc.name = 'Test Project';
        ipc.Core_IPS_Enable_ISTasInterested_Parties__c = false;
        ipc.Core_IPS_EnableMemberasInterestedParties__c = true;
        ipc.Core_IPS_Private__c = false;
        ipc.Core_IPS_Remove_Notification_Details__c = false;
        ipc.Core_Status__c = 'Draft';
        insert ipc;
        
        Core_IPS_Account__c ia = new Core_IPS_Account__c();
        ia.Core_Account__c = accIntel1.id;
        ia.Core_IPS_Project__c = ipc.id;
        ia.Core_Status__c = 'Active';
        insert ia;        
        
        Asset a = new Asset();
        a.Name = 'Ice Lake';
        a.AccountId = accIntel1.id;
        a.Core_IPS_Project__c = ipc.id;
        insert a;
                
        ChannelProgram cpIPATest = new ChannelProgram();
        cpIPATest.Name='Intel Partner Alliance';
        cpIPATest.PRM_programCode__c='IPA';
        insert cpIPATest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Prestige';
        cplTest.ProgramId=cpIPATest.Id;
        insert cplTest;
        
        PRM_AccountChannelMembership__c acctChnlMem = new PRM_AccountChannelMembership__c(); 
        acctChnlMem.PRM_Account_Id__c=accIntel1.Id;
        acctChnlMem.PRM_Channel_Program_Id__c=cpIPATest.Id;
        acctChnlMem.PRM_Channel_Program_Level_Id__c=cplTest.Id;
        acctChnlMem.PRM_Status_Nm__c = 'Approved';
        acctChnlMem.PRM_Status_Reason_Txt__c='Test';
        acctChnlMem.PRM_Partner_Role__c='Builder';//'Seller';
        insert acctChnlMem;
        
        accMap.put(accIntel1.id, accIntel2);
        accMap1.put(accIntel1.id, accIntel3);
        accIntel1.Core_IPS_Active__c = true;
        accIntel1.Core_IPA_Badge_Tier__c = 'Partner'; //'Member';
        accIntel1.Core_CIM_ID__c = '19891888';
        update accIntel1;
        accList.add(accIntel1);
        accMap3.put(accIntel1.id, accIntel1);

        Test.startTest();
         try{
            Core_IPS_Account_Trigger_Handler.assignEntitlementToIPSAccount(accMap3, accList);
        }catch(exception ex){
        }
        try{
            Core_IPS_Account_Trigger_Handler.assignEntitlementToIPSAccount(accMap, accList);
        }catch(exception ex){
        }
        Core_IPS_Account_Trigger_Handler.revokeAccess(accList,accMap);
        Core_IPS_Account_Trigger_Handler.grantAccess(accList,accMap);
        Core_IPS_Account_Trigger_Handler.restrictManageExternalAccount(accList,accMap);
        Core_IPS_Account_Trigger_Handler.restrictManageExternalAccount(accList,accMap);
        //Core_IPS_Account_Trigger_Handler.UpdateContactOnECBCheck(accList,accMap);
        Core_IPS_Account_Trigger_Handler.CIMIdStamped(accList,accMap);
        Core_IPS_Account_Trigger_Handler.createTrackerMilestonesForBadgeTierUpdate(accList,accMap);
        Core_IPS_Account_Trigger_Handler.createTrackerMilestonesForBadgeTierUpdate(accList,accMap1);
        Core_IPS_Account_Trigger_Handler.createTrackerMilestonesForBadgeTierUpdate(accList1,null);
        Core_IPS_Account_Trigger_Handler.createTrackerMilestonesForBadgeTierUpdate(accList1,accMap2);
        Core_IPS_Account_Trigger_Handler.createTrackerMilestonesForBadgeTierUpdate(accList2,accMap4);
        Test.stopTest();
    }
    
    
    
}