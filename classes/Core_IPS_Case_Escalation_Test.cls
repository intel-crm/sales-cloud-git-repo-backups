/***************************************************************************************************
Class Name:  Core_IPS_Case_Escalation_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 25 Jan 2016
Function    : This class contains test coverage for Core_IPS_Case_Escalation class
Input Parameters: None 
Output Parameters: None
Description:   This class contains unit test scenarios for Core_IPS_Case_Escalation class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                 Created
****************************************************************************************************/
@isTest
public class Core_IPS_Case_Escalation_Test {
    //Instance variables that are commonly used in multiple test methods
    static List<User> ListOfUser = new List<User> ();
    static Group grp = new Group();
    static Group queue = new Group();
    /***************************************************************************************************
Method Name:  getRecords()
Method Type: void
Version     : 1.0 
Created Date: 25 Jan 2016
Description:  Common Test data used for all test methods
Scenario Type:  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty       25/01/2016              Created
****************************************************************************************************/
    static void getRecords (){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('Sales Rep-BB');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(3);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(1).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(2).ProfileID =  profiles.get('Sales Rep-BB');
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        ListOfUser.get(1).UserRoleID =  role.Id;
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        System.assertEquals(ListOfUser.get(1).profileid, profiles.get('System Administrator'));
        System.assertEquals(ListOfUser.get(2).profileid, profiles.get('Sales Rep-BB'));
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
            //Create Group
            queue = TestUtilities.getQueue();
            insert queue;
            QueueSobject testQueue = TestUtilities.getMappingQueue();
            testQueue.QueueId = queue.Id;
            testQueue.SobjectType = 'Case';            
            insert testQueue;
            //Create Group Members
            List<GroupMember> ListQu = new List<GroupMember>();
            for(User usr:ListOfUser){
                GroupMember GM = new GroupMember();
                GM.GroupId = queue.Id;
                GM.UserOrGroupId = usr.Id;
                ListQu.add(GM);
            }
            //insert Group Memebers
            insert ListQu;
        }
    }
    /***************************************************************************************************
Method Name:  changeOwnerwithCoreIPSEscalateProfileList_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 25 Jan 2015
Description:  Testing with Core_IPS_Escalate_Profile_List record
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/
    static testmethod void changeOwnerwithCoreIPSEscalateProfileList_Test(){
        getrecords();
        List<Case> ListOfCases = new List<Case>();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        //System.runAs(ListOfUser.get(1)){
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Case' and isActive=true];
        // Create Accounts
        Account ListOfAccounts = TestUtilities.getAccount();
        System.runAs(ListOfUser.get(2)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts.Id != null, 'Record not created');
        Contact ListOfContacts;
        ListOfContacts = TestUtilities.getContact();
        ListOfContacts.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        ListOfContacts.Accountid = ListOfAccounts.Id;
        ListOfContacts.Core_IPS_Active__c = false;            
        System.runAs(ListOfUser.get(1)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts.Id != null, 'Record not created');
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        System.runAs(ListOfUser.get(1)){
            insert ListOfSupportOrg;
        }
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
        System.runAs(ListOfUser.get(1)){
            insert ListOfProducts;
        }
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
        System.runAs(ListOfUser.get(1)){
            insert ListOfSupportedProduct;
        }
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
        System.runAs(ListOfUser.get(1)){
            insert ListOfFlatProductHierarchy;
        }
        System.assert(ListOfFlatProductHierarchy[0].id != null,'Record not created');
        counter = 0;
        //Create Support admin
        Core_IPS_Product_Organization_Admin__c suppadmin = TestUtilities.getSupportOrgAdmin();
        suppadmin.Core_Admin__c=ListOfUser.get(2).id;
        suppadmin.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        System.runAs(ListOfUser.get(1)){
            insert suppadmin;
        }
        Core_IPS_Product_Organization_Admin__c suppadmin1 = TestUtilities.getSupportOrgAdmin();
        suppadmin1.Core_Admin__c=ListOfUser.get(2).id;
        suppadmin1.Core_Primary_Admin__c = true;
        suppadmin1.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
        System.runAs(ListOfUser.get(1)){
            insert suppadmin1;
        }
        // Create Case
        ListOfCases = TestUtilities.getListOfCases(10);
        for(Case CaseRec : ListOfCases){
            for(RecordType rt: rtypes){
                if(rt.Name=='IPS Case Create'){
                    CaseRec.ContactId = ListOfContacts.id;
                    CaseRec.accountId = ListOfAccounts.Id;
                    CaseRec.RecordTypeId = rt.Id;
                    CaseRec.OwnerId = queue.Id;                         
                    if(counter < 5){
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id; 
                        CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(0).id;
                    }else{
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id; 
                        CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(0).id;
                    }
                    counter++;
                }
            }
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
        System.runAs(ListOfUser.get(2)){
            insert QueueXBizHours;
        }
        System.runAs(ListOfUser.get(2)){
            insert ListOfCases;                
        }
        List<CaseShare> csList = new List<CaseShare>();
        for(Case csObj:ListOfCases){
            CaseShare cs = new CaseShare();
            cs.CaseId=csObj.Id;
            cs.CaseAccessLevel = 'Edit';
            cs.UserOrGroupId = ListOfUser.get(2).Id;
            cs.RowCause = 'Manual';
            csList.add(cs);
        }
        System.runAs(ListOfUser.get(1)){
            insert csList;
        }
        System.assert(ListOfCases[0].Id != null, 'Record not created');
        Test.startTest();
        ApexPages.StandardController Controller = new ApexPages.StandardController(ListOfCases.get(0));
        PageReference pageRef = Page.Core_IPS_Case_Escalation;
        pageRef.getParameters().put('id', ListOfCases.get(0).id);
		String nextPage;
        Test.setCurrentPage(pageRef); 
        Core_IPS_Case_Escalation pagExt = new Core_IPS_Case_Escalation(Controller);
        System.runAs(ListOfUser.get(2)){            
            nextPage=pagExt.changeOwner().getUrl();
        }
        System.assertEquals('/'+ListOfCases.get(0).id,nextPage);
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  changeOwnerPrimaryAdmin_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 28 Jan 2015
Description:  Testing with Core_IPS_Escalate_Profile_List record
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              28/01/2016                Created
****************************************************************************************************/
    static testmethod void changeOwnerPrimaryAdmin_Test(){
        getrecords();
        List<Case> ListOfCases = new List<Case>();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        //System.runAs(ListOfUser.get(1)){
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Case' and isActive=true];
        // Create Accounts
        Account ListOfAccounts = TestUtilities.getAccount();
        System.runAs(ListOfUser.get(2)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts.Id != null, 'Record not created');
        Contact ListOfContacts;
        ListOfContacts = TestUtilities.getContact();
        ListOfContacts.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        ListOfContacts.Accountid = ListOfAccounts.Id;
        ListOfContacts.Core_IPS_Active__c = false;            
        System.runAs(ListOfUser.get(1)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts.Id != null, 'Record not created');
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        System.runAs(ListOfUser.get(1)){
            insert ListOfSupportOrg;
        }
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
        System.runAs(ListOfUser.get(1)){
            insert ListOfProducts;
        }
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
        System.runAs(ListOfUser.get(1)){
            insert ListOfSupportedProduct;
        }
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
        System.runAs(ListOfUser.get(1)){
            insert ListOfFlatProductHierarchy;
        }
        System.assert(ListOfFlatProductHierarchy[0].id != null,'Record not created');
        counter = 0;
        //Create Support admin
        Core_IPS_Product_Organization_Admin__c suppadmin = TestUtilities.getSupportOrgAdmin();
        suppadmin.Core_Admin__c=ListOfUser.get(2).id;
        suppadmin.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        suppadmin.Core_Primary_Admin__c = true;
        System.runAs(ListOfUser.get(1)){
            insert suppadmin;
        }
        Core_IPS_Product_Organization_Admin__c suppadmin1 = TestUtilities.getSupportOrgAdmin();
        suppadmin1.Core_Admin__c=ListOfUser.get(2).id;
        suppadmin1.Core_Primary_Admin__c = true;
        suppadmin1.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
        System.runAs(ListOfUser.get(1)){
            insert suppadmin1;
        }
        // Create Case
        ListOfCases = TestUtilities.getListOfCases(10);
        for(Case CaseRec : ListOfCases){
            for(RecordType rt: rtypes){
                if(rt.Name=='IPS Case Create'){
                    CaseRec.ContactId = ListOfContacts.id;
                    CaseRec.accountId = ListOfAccounts.Id;
                    CaseRec.RecordTypeId = rt.Id;
                    CaseRec.OwnerId = queue.Id;                         
                    if(counter < 5){
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id; 
                        CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(0).id;
                    }else{
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id; 
                        CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(0).id;
                    }
                    counter++;
                }
            }
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
        System.runAs(ListOfUser.get(2)){
            insert QueueXBizHours;
        }
        System.runAs(ListOfUser.get(2)){
            insert ListOfCases;                
        }
        List<CaseShare> csList = new List<CaseShare>();
        for(Case csObj:ListOfCases){
            CaseShare cs = new CaseShare();
            cs.CaseId=csObj.Id;
            cs.CaseAccessLevel = 'Edit';
            cs.UserOrGroupId = ListOfUser.get(2).Id;
            cs.RowCause = 'Manual';
            csList.add(cs);
        }
        System.runAs(ListOfUser.get(1)){
            insert csList;
        }
        System.assert(ListOfCases[0].Id != null, 'Record not created');
        Test.startTest();
		String nextPage;
        ApexPages.StandardController Controller = new ApexPages.StandardController(ListOfCases.get(0));
        PageReference pageRef = Page.Core_IPS_Case_Escalation;
        pageRef.getParameters().put('id', ListOfCases.get(0).id);
        Test.setCurrentPage(pageRef); 
        Core_IPS_Case_Escalation pagExt = new Core_IPS_Case_Escalation(Controller);
        System.runAs(ListOfUser.get(2)){            
            nextPage=pagExt.changeOwner().getUrl();
        }
        System.assertEquals('/'+ListOfCases.get(0).id,nextPage);
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  changeOwnerwithUserAlreadyOwner_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 25 Jan 2015
Description:  Testing with Core_IPS_Escalate_Profile_List record for Owner is already an Agent
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              25/01/2016                Created
****************************************************************************************************/
    static testmethod void changeOwnerwithUserAlreadyOwner_Test(){
        getrecords();
        List<Case> ListOfCases = new List<Case>();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        //System.runAs(ListOfUser.get(1)){
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Case' and isActive=true];
        // Create Accounts
        Account ListOfAccounts = TestUtilities.getAccount();
        System.runAs(ListOfUser.get(2)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts.Id != null, 'Record not created');
        Contact ListOfContacts;
        ListOfContacts = TestUtilities.getContact();
        ListOfContacts.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        ListOfContacts.Accountid = ListOfAccounts.Id;
        ListOfContacts.Core_IPS_Active__c = false;            
        System.runAs(ListOfUser.get(1)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts.Id != null, 'Record not created');
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        System.runAs(ListOfUser.get(1)){
            insert ListOfSupportOrg;
        }
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
        System.runAs(ListOfUser.get(1)){
            insert ListOfProducts;
        }
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
        System.runAs(ListOfUser.get(1)){
            insert ListOfSupportedProduct;
        }
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
        System.runAs(ListOfUser.get(1)){
            insert ListOfFlatProductHierarchy;
        }
        System.assert(ListOfFlatProductHierarchy[0].id != null,'Record not created');
        counter = 0;
        //Create Support admin
        Core_IPS_Product_Organization_Admin__c suppadmin = TestUtilities.getSupportOrgAdmin();
        suppadmin.Core_Admin__c=ListOfUser.get(2).id;
        suppadmin.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        System.runAs(ListOfUser.get(1)){
            insert suppadmin;
        }
        Core_IPS_Product_Organization_Admin__c suppadmin1 = TestUtilities.getSupportOrgAdmin();
        suppadmin1.Core_Admin__c=ListOfUser.get(2).id;
        suppadmin1.Core_Primary_Admin__c = true;
        suppadmin1.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
        System.runAs(ListOfUser.get(1)){
            insert suppadmin1;
        }
        // Create Case
        ListOfCases = TestUtilities.getListOfCases(10);
        for(Case CaseRec : ListOfCases){
            for(RecordType rt: rtypes){
                if(rt.Name=='IPS Case Create'){
                    CaseRec.ContactId = ListOfContacts.id;
                    CaseRec.accountId = ListOfAccounts.Id;
                    CaseRec.RecordTypeId = rt.Id;
                    CaseRec.OwnerId = ListOfUser.get(1).Id;                         
                    if(counter < 5){
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id; 
                        CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(0).id;
                    }else{
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id; 
                        CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(0).id;
                    }
                    counter++;
                }
            }
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
        System.runAs(ListOfUser.get(2)){
            insert QueueXBizHours;
        }
        System.runAs(ListOfUser.get(1)){
            insert ListOfCases;                
        }
        List<CaseShare> csList = new List<CaseShare>();
        for(Case csObj:ListOfCases){
            CaseShare cs = new CaseShare();
            cs.CaseId=csObj.Id;
            cs.CaseAccessLevel = 'Edit';
            cs.UserOrGroupId = ListOfUser.get(2).Id;
            cs.RowCause = 'Manual';
            csList.add(cs);
        }
        System.runAs(ListOfUser.get(1)){
            insert csList;
        }
        System.assert(ListOfCases[0].Id != null, 'Record not created');
        Test.startTest();
        String nextPage;
        ApexPages.StandardController Controller = new ApexPages.StandardController(ListOfCases.get(0));
        PageReference pageRef = Page.Core_IPS_Case_Escalation;
        pageRef.getParameters().put('id', ListOfCases.get(0).id);
        Test.setCurrentPage(pageRef); 
        pageReference PageRef2;
        System.runAs(ListOfUser.get(2)){  
            Core_IPS_Case_Escalation pagExt = new Core_IPS_Case_Escalation(Controller);
            PageRef2 = pagExt.changeOwner();
        }
        System.assert(PageRef2 == null, 'Owner is already an Agent');
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  changeOwnerInvalidProfile_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 28 Jan 2015
Description:  Testing with Invalid Profile
Scenario Type:  Negative
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              28/01/2016                Created
****************************************************************************************************/
    static testmethod void changeOwnerInvalidProfile_Test(){
        
        getrecords();
        List<Case> ListOfCases = new List<Case>();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        //System.runAs(ListOfUser.get(1)){
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Case' and isActive=true];
        // Create Accounts
        Account ListOfAccounts = TestUtilities.getAccount();
        System.runAs(ListOfUser.get(2)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts.Id != null, 'Record not created');
        Contact ListOfContacts;
        ListOfContacts = TestUtilities.getContact();
        ListOfContacts.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        ListOfContacts.Accountid = ListOfAccounts.Id;
        ListOfContacts.Core_IPS_Active__c = false;            
        System.runAs(ListOfUser.get(1)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts.Id != null, 'Record not created');
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        System.runAs(ListOfUser.get(1)){
            insert ListOfSupportOrg;
        }
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
        System.runAs(ListOfUser.get(1)){
            insert ListOfProducts;
        }
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
        System.runAs(ListOfUser.get(1)){
            insert ListOfSupportedProduct;
        }
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
        System.runAs(ListOfUser.get(1)){
            insert ListOfFlatProductHierarchy;
        }
        System.assert(ListOfFlatProductHierarchy[0].id != null,'Record not created');
        counter = 0;
        //Create Support admin
        Core_IPS_Product_Organization_Admin__c suppadmin = TestUtilities.getSupportOrgAdmin();
        suppadmin.Core_Admin__c=ListOfUser.get(2).id;
        suppadmin.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        suppadmin.Core_Primary_Admin__c = true;
        System.runAs(ListOfUser.get(1)){
            insert suppadmin;
        }
        Core_IPS_Product_Organization_Admin__c suppadmin1 = TestUtilities.getSupportOrgAdmin();
        suppadmin1.Core_Admin__c=ListOfUser.get(2).id;
        suppadmin1.Core_Primary_Admin__c = true;
        suppadmin1.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
        System.runAs(ListOfUser.get(1)){
            insert suppadmin1;
        }
        // Create Case
        ListOfCases = TestUtilities.getListOfCases(10);
        for(Case CaseRec : ListOfCases){
            for(RecordType rt: rtypes){
                if(rt.Name=='IPS Case Create'){
                    CaseRec.ContactId = ListOfContacts.id;
                    CaseRec.accountId = ListOfAccounts.Id;
                    CaseRec.RecordTypeId = rt.Id;
                    CaseRec.OwnerId = queue.id;                         
                    if(counter < 5){
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id; 
                        CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(0).id;
                    }else{
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id; 
                        CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(0).id;
                    }
                    counter++;
                }
            }
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
        System.runAs(ListOfUser.get(2)){
            insert QueueXBizHours;
        }
        System.runAs(ListOfUser.get(2)){
            insert ListOfCases;                
        }
        List<CaseShare> csList = new List<CaseShare>();
        for(Case csObj:ListOfCases){
            CaseShare cs = new CaseShare();
            cs.CaseId=csObj.Id;
            cs.CaseAccessLevel = 'Edit';
            cs.UserOrGroupId = ListOfUser.get(2).Id;
            cs.RowCause = 'Manual';
            csList.add(cs);
        }
        System.runAs(ListOfUser.get(2)){
            insert csList;
        }
        System.assert(ListOfCases[0].Id != null, 'Record not created');
        Test.startTest();
        ApexPages.StandardController Controller = new ApexPages.StandardController(ListOfCases.get(0));
        PageReference pageRef = Page.Core_IPS_Case_Escalation;
        pageRef.getParameters().put('id', ListOfCases.get(0).id);
        Test.setCurrentPage(pageRef); 
        pageReference PageRef2;
        System.runAs(ListOfUser.get(1)){  
            Core_IPS_Case_Escalation pagExt = new Core_IPS_Case_Escalation(Controller);
            PageRef2 = pagExt.changeOwner();
        }
        System.assert(PageRef2 == null, 'User not authorized');
        Test.stopTest();
    }
    /***************************************************************************************************
Method Name:  CancelAction_Test
Method Type: Test Method
Version     : 1.0 
Created Date: 28 Jan 2015
Description:  Testing with Cancel action
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              28/01/2016                Created
****************************************************************************************************/
    static testmethod void CancelAction_Test(){
        
        getrecords();
        List<Case> ListOfCases = new List<Case>();
        // Get intelSupportOwner Id (User Id)
        Id intelSupportOwner = ListOfUser.get(0).id;
        //System.runAs(ListOfUser.get(1)){
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Case' and isActive=true];
        // Create Accounts
        Account ListOfAccounts = TestUtilities.getAccount();
        System.runAs(ListOfUser.get(2)){
            insert ListOfAccounts;
        }
        System.assert(ListOfAccounts.Id != null, 'Record not created');
        Contact ListOfContacts;
        ListOfContacts = TestUtilities.getContact();
        ListOfContacts.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        ListOfContacts.Accountid = ListOfAccounts.Id;
        ListOfContacts.Core_IPS_Active__c = false;            
        System.runAs(ListOfUser.get(1)){
            insert ListOfContacts;
        }
        System.assert(ListOfContacts.Id != null, 'Record not created');
        // Create Support Org
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
        System.runAs(ListOfUser.get(1)){
            insert ListOfSupportOrg;
        }
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
        System.runAs(ListOfUser.get(1)){
            insert ListOfProducts;
        }
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
        System.runAs(ListOfUser.get(1)){
            insert ListOfSupportedProduct;
        }
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
        System.runAs(ListOfUser.get(1)){
            insert ListOfFlatProductHierarchy;
        }
        System.assert(ListOfFlatProductHierarchy[0].id != null,'Record not created');
        counter = 0;
        //Create Support admin
        Core_IPS_Product_Organization_Admin__c suppadmin = TestUtilities.getSupportOrgAdmin();
        suppadmin.Core_Admin__c=ListOfUser.get(2).id;
        suppadmin.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
        suppadmin.Core_Primary_Admin__c = true;
        System.runAs(ListOfUser.get(1)){
            insert suppadmin;
        }
        Core_IPS_Product_Organization_Admin__c suppadmin1 = TestUtilities.getSupportOrgAdmin();
        suppadmin1.Core_Admin__c=ListOfUser.get(2).id;
        suppadmin1.Core_Primary_Admin__c = true;
        suppadmin1.Core_Product_Organization__c = ListOfSupportOrg.get(1).id;
        System.runAs(ListOfUser.get(1)){
            insert suppadmin1;
        }
        // Create Case
        ListOfCases = TestUtilities.getListOfCases(10);
        for(Case CaseRec : ListOfCases){
            for(RecordType rt: rtypes){
                if(rt.Name=='IPS Case Create'){
                    CaseRec.ContactId = ListOfContacts.id;
                    CaseRec.accountId = ListOfAccounts.Id;
                    CaseRec.RecordTypeId = rt.Id;
                    CaseRec.OwnerId = queue.id;                         
                    if(counter < 5){
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id; 
                        CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(0).id;
                    }else{
                        CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(1).id; 
                        CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(0).id;
                    }
                    counter++;
                }
            }
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
        System.runAs(ListOfUser.get(2)){
            insert QueueXBizHours;
        }
        System.runAs(ListOfUser.get(2)){
            insert ListOfCases;                
        }
        List<CaseShare> csList = new List<CaseShare>();
        for(Case csObj:ListOfCases){
            CaseShare cs = new CaseShare();
            cs.CaseId=csObj.Id;
            cs.CaseAccessLevel = 'Edit';
            cs.UserOrGroupId = ListOfUser.get(2).Id;
            cs.RowCause = 'Manual';
            csList.add(cs);
        }
        System.runAs(ListOfUser.get(2)){
            insert csList;
        }
        System.assert(ListOfCases[0].Id != null, 'Record not created');
        Test.startTest();
		String nextPage;
        ApexPages.StandardController Controller = new ApexPages.StandardController(ListOfCases.get(0));
        PageReference pageRef = Page.Core_IPS_Case_Escalation;
        pageRef.getParameters().put('id', ListOfCases.get(0).id);
        Test.setCurrentPage(pageRef); 
        Core_IPS_Case_Escalation pagExt = new Core_IPS_Case_Escalation(Controller);
        System.runAs(ListOfUser.get(2)){            
            nextPage=pagExt.CancelAction().getUrl();
        }
        System.assertEquals('/'+ListOfCases.get(0).id,nextPage);
        Test.stopTest();
    }
}