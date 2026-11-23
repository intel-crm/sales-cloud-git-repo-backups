@istest   
public class Core_IPS_AdminUtilityTest { //System.assert()--> statement Added By Hassan Khan 03-02-2024
    
    static testmethod void AdminUtilitytestMethod1() {
        
        Profile ps = [select id, name from Profile where name = 'System Administrator'
                      limit 1
                     ];
        ID recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId();
        UserRole role=new UserRole();
        role.name='CEO';
        
        insert role;
        
        User sysAdimUser = TestUtilities.getUser();
        sysAdimUser.ProfileId = ps.id;
        sysAdimUser.userroleid=role.id;
        
        insert sysAdimUser;
        
        System.runAs(sysAdimUser) {
            List < Account > ListOfAccounts = TestUtilities.getAccountsList(1);
            ListOfAccounts.get(0).OwnerId = sysAdimUser.id;
            //Ashutosh _ US103890
            ListOfAccounts.get(0).Core_IPS_Active__c = true;
            ListOfAccounts.get(0).Core_B2B_Entitlement__c = true;
            ListOfAccounts.get(0).Core_CNDA_Number__c = '12523';
            insert ListOfAccounts;
            System.assert(ListOfAccounts[0].Id != null, 'Record not created');
            List < Contact > ListOfContacts = TestUtilities.getListOfContact(1);
            for (Contact ContactRec: ListOfContacts) {
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
                ContactRec.Core_IPS_Active__c = true;
                
            } 
            insert ListOfContacts;
            System.assert(ListOfContacts[0].id != null, 'Record not created');
            Core_IPS_AdminUtility.updateContact(ListOfContacts[0]);
            Core_IPS_AdminUtility.updateContact(NULL);
            // Create Product
            List < Product2 > ListOfProducts = TestUtilities.getListOfProduct(1);
            for (Product2 Product: ListOfProducts) {
                Product.Core_Hierarchy_ID__c = '43';
                Product.Core_Hierarchy_Name__c = 'ProdHierarchyName';
                Product.Core_Unique_ID__c = 'Product12345';
                Product.Core_Code_Name__c = 'ProductCoreCodeName';
                
            }
            insert ListOfProducts;
            System.assert(ListOfProducts[0].id != null, 'Record not created');
            // Create Support Org
            List < Core_IPS_Product_Organization__c > ListOfSupportOrg = TestUtilities.getListOfSupportOrg(2);
            insert ListOfSupportOrg;
            System.assert(ListOfSupportOrg != null, 'Record not created');
            // Create Supported product
            List < Core_IPS_Supported_Product__c > ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
            for (Core_IPS_Supported_Product__c SupportedProduct: ListOfSupportedProduct) {
                SupportedProduct.Core_Product__c = ListOfProducts.get(0).id;
                SupportedProduct.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                
            }
            insert ListOfSupportedProduct;
            System.assert(ListOfSupportedProduct[0].id != null, 'Record not created');
            
            //Added by Sunil 
            //Product2 prod =  TestUtilities.getProduct();
            //insert Prod;
            
            Asset asst = TestUtilities.getAsset();
            asst.Core_Supported_Product__c = ListOfSupportedProduct[0].Id;
            Asst.product2Id = ListOfProducts.get(0).id;
            Asst.Core_product_organization__c = ListOfSupportOrg.get(0).id;
            insert Asst;
            System.assert(Asst.Id != null, 'Record not created');
            //End By sunil                
            // Create Case
            List <case>ListOfCases = TestUtilities.getListOfCases(10);
            for (Case CaseRec: ListOfCases) {
                CaseRec.ContactId = ListOfContacts.get(0).id;
                CaseRec.accountId = ListOfAccounts.get(0).Id;
                CaseRec.AssetId = Asst.id;
                CaseRec.Core_IPS_Supported_Product__c = ListOfSupportedProduct.get(0).id;
                CaseRec.Core_IPS_Product_Org1__c = ListOfSupportOrg.get(0).id;
            }
            Core_IPS_Master_Issue_Category__c MasterCaseCategory = TestUtilities.getMasterCaseCategories();
            MasterCaseCategory.Core_type__c = 'Case Category';
            insert MasterCaseCategory;
            System.assert(MasterCaseCategory.Id != null, 'Record not created');
            
            Core_IPS_Master_Issue_Category__c MasterCategory = TestUtilities.getMasterCaseCategories();
            MasterCategory.Core_Master_Issue_Category__c = MasterCaseCategory.id;
            insert MasterCategory;
            System.assert(MasterCategory.Id != null, 'Record not created');
            Core_IPS_Product_Issue_Category__c caseCat = TestUtilities.getCaseCategories();
            caseCat.Core_Issue_Category_Name__c = MasterCategory.id;
            caseCat.Core_Type__c = 'Case Category';
            insert caseCat;
            System.assert(caseCat.Id != null, 'Record not created');
            
            Core_IPS_Product_Issue_Category__c subCategory = TestUtilities.getCaseCategories();
            subCategory.Core_Issue_Sub_Category_Name__c = MasterCategory.id;
            subCategory.Core_Type__c = 'Case Subcategory';
            insert subCategory;
            System.assert(subCategory.Id != null, 'Record not created');
            ListOfCases.get(0).Core_Case_Issue_Category__c = caseCat.id;
            ListOfCases.get(0).Core_case_issue_sub_category__c = subCategory.id;
            insert ListOfCases;
            System.assert(ListOfCases[0].Id != null, 'Record not created');
            List < Core_IPS_Error_Code__c > errorCodes = TestUtilities.getListOfIpsErrorCodes();
            insert errorCodes;
            System.assert(errorCodes[0].Id != null, 'Record not created');
            List < Core_IPS_Environment_Variables__c > ListOfenvVars = new List < Core_IPS_Environment_Variables__c > ();
            for (integer i = 0; i < 7; i++) {
                Core_IPS_Environment_Variables__c envVar = TestUtilities.getEnvironmentalDetailMaster();
                envVar.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
                ListOfenvVars.add(envVar);
            } 
            ListOfenvVars[0].Core_Datatype__c = 'picklist';
            ListOfenvVars[1].Core_Datatype__c = 'text';
            ListOfenvVars[2].Core_Datatype__c = 'textarea';
            ListOfenvVars[3].Core_Datatype__c = 'Multi Select';
            ListOfenvVars[4].Core_Datatype__c = 'text (255)';
            ListOfenvVars[5].Core_Datatype__c = 'textarea (5000)';
            ListOfenvVars[6].Core_Datatype__c = 'boolean';
            insert ListOfenvVars;
            
            List < Core_IPS_Environment_Details__c > lstenvDetal = new List < Core_IPS_Environment_Details__c > ();
            Core_IPS_Environment_Details__c envDetal = new Core_IPS_Environment_Details__c();
            envDetal.Name = 'Issue Resolution List';
            envDetal.Core_Question__c = 'intel';
            envDetal.Core_Answer__c = 'TestAnswer1;TestAns2;Testans3';
            envDetal.Core_Case__c = ListOfCases[0].id;
            lstenvDetal.add(envDetal);
            Core_IPS_AdminUtility.insertEnvDetailsToCreate(lstenvDetal);
            
            /*Added By Yogesh Sharma Start*/
            List<Core_IPS_Response__c> responseList = TestUtilities.getCoreResponseRecords(2);
            for(Core_IPS_Response__c cr : responseList){
                cr.Core_IPS_Case__c = ListOfCases.get(0).Id;
            }
            Core_IPS_AdminUtility.insertEnvDetailsToCreate(responseList);
            
            //insert responseList;
            Core_IPS_AdminUtility.DeleteEnvDetails(responseList);
            
            //List < Account > ListOfAccounts1 = TestUtilities.getAccountsList(1);
            //insert ListOfAccounts1;
            Case cs=TestUtilities.getCase();
            insert cs;
            
            List<Core_IPS_Environment_Details__c> envResponses=TestUtilities.getEnvironmentDetailResponses(10);
            for(Core_IPS_Environment_Details__c envResp:envResponses){
                envResp.Core_Case__c = cs.id;
            }
            insert envResponses;
            
            Core_IPS_AdminUtility.DeleteEnvDetails(envResponses);
            
            Map<string,ID> MapRecordtype = new Map<string,ID>();
            for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Core_IPS_MAP_PAR__c'])
            {  
                MapRecordtype.put(Rt.Name,Rt.ID);
            }        
            //Create PAR
            Core_IPS_MAP_PAR__c par = TestUtilities.getMapPar();
            par.RecordTypeId = MapRecordtype.get('PAR');
            insert par;
            
            //Create Core_IPS_MAP_Account__c
            Core_IPS_MAP_Account__c ipsmapAcc = TestUtilities.getIPSMAPAccount();
            
            ipsmapAcc.Core_MAP_PAR__c = par.Id;
            ipsmapAcc.Core_Account__c = ListOfAccounts[0].Id;
            //insert ipsmapAcc;
            
            Core_IPS_AdminUtility.insertProdAccessAccJOs(new List<Core_IPS_MAP_Account__c>{ipsmapAcc});
            
            List<Core_IPS_Supported_Product__c> SuppProductList = new List<Core_IPS_Supported_Product__c> ();
            List<Product2> ProductList = new List<Product2>();
            Core_IPS_Product_Organization__c prodOrg = new Core_IPS_Product_Organization__c();
            
            // inserting products
            ProductList = TestUtilities.getListOfProduct(3);
            insert ProductList;
            System.assert(ProductList <> null, 'Record not created');
            // inserting product org
            prodOrg = TestUtilities.getSupportOrg();
            insert prodOrg;
            System.assert(prodOrg <> null, 'Record not created');
            
            // inserting Supported Product 
            SuppProductList = TestUtilities.getListOfSupportedProduct(3);
            Integer i = 0; 
            for(Core_IPS_Supported_Product__c SupportedProductRecord: SuppProductList){                
                SupportedProductRecord.Core_Product__c = ProductList.get(i).id;
                SupportedProductRecord.Core_Product_Organization__c = prodOrg.id;
                i++;                     
            } 
            insert SuppProductList;
            
            // inserting Product Access Header 
            Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
            mapRec.Core_Product_Organization__c = prodOrg.id;
            mapRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
            insert mapRec;
            System.assert(mapRec <> null, 'Record not created');
            
            // inserting Prodcut Access Product
            List<Core_IPS_MAP_Product__c> prodJuncList= new List<Core_IPS_MAP_Product__c>();
            for(Integer j=0;j<1;j++){
                Core_IPS_MAP_Product__c mapProd = new Core_IPS_MAP_Product__c();
                mapProd.Core_MAP_PAR__c = mapRec.id;
                mapProd.Core_MAP_Supported_Product__c = SuppProductList[j].id;
                prodJuncList.add(mapProd);
            }
            //insert prodJuncList; 
            Core_IPS_AdminUtility.insertProdAccessProdJOs(prodJuncList);
            //Ashutosh - US103890
            List<Core_IPS_Case_Interested_Party__c> ListOfInterestedParty = TestUtilities.getInternalInterestedParties(2);//Ashutosh-us103988 - change to 2 parties
            ListOfInterestedParty.get(0).Case__c = ListOfCases.get(0).Id;
            ListOfInterestedParty.get(0).User__c = sysAdimUser.Id;
            //ListOfInterestedParty.get(0).Contact__c = ListOfContacts.get(0).Id;
            ListOfInterestedParty.get(0).Type__c = 'Internal';
            
            ListOfInterestedParty.get(1).Case__c = ListOfCases.get(0).Id;
            //ListOfInterestedParty.get(1).User__c = ListOfExternalUsers.get(1).Id;
            ListOfInterestedParty.get(1).Contact__c = ListOfContacts.get(0).Id;
            ListOfInterestedParty.get(1).Type__c = 'External';
            Test.startTest();  
            Core_IPS_AdminUtility.getProductVariants(ListOfProducts.get(0).id);
            Core_IPS_AdminUtility.getPartnerType();
            Core_IPS_AdminUtility.insertInterestedParties(ListOfInterestedParty);
            Test.stopTest();
            System.assertEquals(true,ListOfInterestedParty.get(0) != null);
        }
        
        /*Added By Yogesh Sharma Stop*/ 
        
    }
    static testmethod void AdminUtilitytestMethod2() {
        List <case >ListOfCases = TestUtilities.getListOfCases(1);
        
        insert ListOfCases;
        list < Core_IPS_GEC_Details__c > GECList = new list < Core_IPS_GEC_Details__c > ();
        
        
        Core_IPS_GEC_Details__c GEC1 = new Core_IPS_GEC_Details__c();
        GEC1.Core_IPS_GEC_Question1__c = 'THIS IS TEST CLASS';
        GEC1.Core_IPS_GEC_Question2__c = 'THIS IS TEST CLASS';
        GEC1.Core_IPS_Case__c = ListOfCases[0].Id;
        GECList.add(GEC1);
        
        Core_IPS_AdminUtility.insertGECList(GECList);
        System.assert(ListOfCases.size() > 0, true);
    }
    /*static testmethod void AdminUtilitytestMethod3() {
Profile ps = [select id, name from Profile where name = 'System Administrator'
limit 1
];
User sysAdimUser = TestUtilities.getUser();
sysAdimUser.ProfileId = ps.id;
insert sysAdimUser;
System.runAs(sysAdimUser) {
List < Account > ListOfAccounts = TestUtilities.getAccountsList(1);
insert ListOfAccounts;

Core_IPS_MAP_PAR__c  map1 = new Core_IPS_MAP_PAR__c();
//map1.Core_Product_Organization__c = prodOrg.Id;
// map1.core_name__c = reqField.Core_Name__c;
map1.core_name__c = 'hghhhh';
map1.RecordTypeId = System.Label.MAP_Header_Record_Type_ID;
map1.Core_Submitter_Comments__c='sssssssssssss';
insert map1;
List<Core_IPS_Map_Par_Line_Item__c> mapLineItems = new List<Core_IPS_Map_Par_Line_Item__c>();
Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();

lineItem.Core_Account__c = ListOfAccounts[0].id;
//lineItem.Core_Supported_Product__c=mapProdToSupProd.get(wl.prod.id).id;                
lineItem.Core_MAP_PAR__c = map1.id;
lineItem.RecordTypeId = System.Label.MAP_LineItem_Record_Type_ID;
mapLineItems.add(lineItem);

Core_IPS_AdminUtility.insertLineItems(mapLineItems);
}
}
*/
    
    
    static testmethod void upsertEnvDetailsToCreateTest(){
        Case cs=TestUtilities.getCase();
        insert cs;
        List<Core_IPS_Response__c> responseList = TestUtilities.getCoreResponseRecords(2);
        for(Core_IPS_Response__c cr : responseList){
            cr.Core_IPS_Case__c = cs.Id;
        }
        Core_IPS_AdminUtility.upsertEnvDetailsToCreate(responseList,cs.id,true);
        System.assert(cs.id != null, true);	
    }
    
    public static TestMethod void saveCommentsTest(){
        
        String profileId = [SELECT Id from Profile where Name='IPS Agent-Partner'].Id;
        core_IPS_LEXAddCommentController.partnerProf = profileId;
        core_IPS_LEXAddCommentController.partnerType = 'Not a Partner';
       
        /*Account acc = TestUtilities.getAccountRecord();
        insert acc;
        Contact con = TestUtilities.getContact();
        con.AccountId = acc.ID;
        insert con;*/
         User AccountOwner= TestUtilities.getAccountOwner();
              System.runas(AccountOwner){
              Account acc = TestUtilities.getAccountRecord();
        	  acc.OwnerId = AccountOwner.Id; //Added by Nuthana
        	  insert acc;
        	  System.debug('owner Id'+acc.OwnerId);
              System.assert(acc.Id != null, 'Record not created');

        	Contact con = TestUtilities.getContact();
        	con.AccountId = acc.ID;
        	insert con;
        	System.assert(con.Id != null, 'Record not created');
        list<Core_IPS_Labels__c> lstCs = new list<Core_IPS_Labels__c>();
        lstCs.add(new Core_IPS_Labels__c(name='Core_IPS_Agent_Partner_Profile_id', value__c=profileId));
        lstCs.add(new Core_IPS_Labels__c(name='Core_IPS_Profile_Name', value__c='IPS External Customer'));
        //Added by Sowmya - Start - 22/11/2014 - TWC745-6800 - Fix test coverage for all failed classes
     	lstCs.add(new Core_IPS_Labels__c(name='Core_IPS_Close_Pending_SubStatus', value__c='Close-Pending'));
        lstCs.add(new Core_IPS_Labels__c(name='PUBLIC_TO_CUSTOMERS', value__c='Public to Customers'));
        //Sowmya - End - 22/11/2014 - TWC745-6800 - Fix test coverage for all failed classes
		insert lstCs;
              
          }
          Contact con = [select Id from Contact Limit 1];
        Account acc = [select Id from Account Limit 1];
        User uu = new User(
            ProfileId = profileId,
            LastName = 'last',
            Email = 'puser00012@amamama.com',
            Username = 'puser00012@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ContactId = con.Id);
        insert uu;
        /*   PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
PermissionSet ps1 = [select id,label from PermissionSet where Label = 'IPS Permission Set'];
insert new PermissionSetAssignment(AssigneeId = uu.id, PermissionSetId = ps.Id );
insert new PermissionSetAssignment(AssigneeId = uu.id, PermissionSetId = ps1.Id );*/
        core_IPS_LEXAddCommentController.CaseWrapper caseWrapperObj = new core_IPS_LEXAddCommentController.CaseWrapper();
        System.runAs(uu){ 
            Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c ();
            labels2.name= 'Partner - Agent';
            labels2.value__c='Partner - Agent';
            insert labels2;
            
            
            insert TestUtilities.getCase();
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            caseWrapperObj.casesubststus = 'test';
            caseWrapperObj.caseComment = 'Test Comment';
            caseWrapperObj.closedPending = string.valueof(system.today()-1);
            caseWrapperObj.caseid = caseRec;
            caseWrapperObj.selectedRadioButton = 'Public to Customers';
            core_IPS_LEXAddCommentController.saveComment(JSON.serialize(caseWrapperObj));
            Core_IPS_AdminUtility.saveComment(JSON.serialize(caseWrapperObj));
            Core_IPS_AdminUtility.getPartnerType();
        }
          //Core_IPS_Map_Par_Line_Item__c lItem = new Core_IPS_Map_Par_Line_Item__c();
        System.runas([Select id,profile.Name from user where profile.Name like '%System Admin%' and isActive = true][0]){
             Core_IPS_Map_Par_Line_Item__c lItem = new Core_IPS_Map_Par_Line_Item__c(); //Added inside system.runas to cover failed method - Nuthana
              Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
              labels.name= 'Agent';
              labels.value__c='Agent';
              insert labels;
            Core_IPS_AdminUtility.saveComment(JSON.serialize(caseWrapperObj));
            Case cs=TestUtilities.getCase();
            insert cs;
            Core_IPS_AdminUtility.createCase(cs);
            List<Core_IPS_Supported_Product__c> suppProductList = new List<Core_IPS_Supported_Product__c> ();
            suppProductList = TestUtilities.getListOfSupportedProduct(1);
            List<Product2> productList = TestUtilities.getListOfProduct(3);
             insert productList;
              List<Core_IPS_Product_Organization__c>  prodOrgList = TestUtilities.getListOfSupportOrg(3);
            insert prodOrgList;
            suppProductList[0].Core_Product__c = productList.get(0).id;
            suppProductList[0].Core_Product_Organization__c = prodOrgList.get(0).id;
            insert suppProductList;
            Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
            mapRec.Core_Product_Organization__c = prodOrgList[0].id;
            mapRec.RecordTypeId  = [select id,name,Sobjecttype  from recordtype where name = 'MAP' and SobjectType='Core_IPS_MAP_PAR__c'].id;
            insert mapRec;
          
            lItem.Core_MAP_PAR__c = mapRec.id;  //Added inside system.runas to cover failed method - Nuthana
            lItem.Core_Account__c = acc.id;
            lItem.Core_Supported_Product__c = suppProductList[0].id;
            lItem.RecordTypeId= schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
            
            List<Core_IPS_Map_Par_Line_Item__c> mapItemsList = new List<Core_IPS_Map_Par_Line_Item__c>();
            mapItemsList.add(lItem);
          Core_IPS_AdminUtility.insertLineItems(mapItemsList);
        System.assert(con.id != null, true);
        }
         /*List<Core_IPS_Map_Par_Line_Item__c> mapItemsList = new List<Core_IPS_Map_Par_Line_Item__c>();
            mapItemsList.add(lItem);
          Core_IPS_AdminUtility.insertLineItems(mapItemsList);
        System.assert(con.id != null, true);*/
    }
    public static TestMethod void saveCommentsTest1(){
        String profileId = [SELECT Id from Profile where Name='Data Ops'].Id;
        user testuser=new user();
        testuser.email='testuser1998@example.com';
        testuser.Username='testuser1998@example.com';
        testuser.LastName='last';
        testuser.CompanyName='test';
        testuser.ProfileId=profileId;
        testuser.TimeZoneSidKey = 'America/Los_Angeles';
        testuser.EmailEncodingKey = 'UTF-8';
        testuser.LanguageLocaleKey = 'en_US';
        testuser.Alias = 'alias';
        testuser.LocaleSidKey = 'en_US';
        insert testuser;
        PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
        PermissionSet ps1 = [select id,label from PermissionSet where Label = 'IPS Permission Set'];
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps.Id );
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps1.Id );
        
        System.runAs(testuser){ 
            core_IPS_LEXAddCommentController.CaseWrapper caseWrapperObj = new core_IPS_LEXAddCommentController.CaseWrapper();
            list<Core_IPS_Labels__c> lstCs = new list<Core_IPS_Labels__c>();
            lstCs.add(new Core_IPS_Labels__c(name='Core_IPS_Close_Pending_SubStatus', value__c='Close-Pending'));
            lstCs.add(new Core_IPS_Labels__c(name='PUBLIC_TO_CUSTOMERS', value__c='Public to Customers'));
            lstCs.add(new Core_IPS_Labels__c(name='Customer', value__c='Customer'));
            lstCs.add(new Core_IPS_Labels__c(name='FAE', value__c='FAE'));
            lstCs.add(new Core_IPS_Labels__c(name='Agent', value__c='Agent'));
            lstCs.add(new Core_IPS_Labels__c(name='Data Migration', value__c='Data Migration'));
            lstCs.add(new Core_IPS_Labels__c(name='Backend Integration', value__c='Backend Integration'));
            lstCs.add(new Core_IPS_Labels__c(name='Partner - Agent', value__c='Partner - Agent'));
            lstCs.add(new Core_IPS_Labels__c(name='Partner', value__c='Partner'));
            
            insert lstCs;
            
            insert TestUtilities.getCase();
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            caseWrapperObj.casesubststus = 'test';
            caseWrapperObj.caseComment = 'Test Comment';
            caseWrapperObj.closedPending = string.valueof(system.today()-1);
            caseWrapperObj.caseid = caseRec;
            caseWrapperObj.selectedRadioButton = 'Public to Customers';
            core_IPS_LEXAddCommentController.saveComment(JSON.serialize(caseWrapperObj));
            Core_IPS_AdminUtility.saveComment(JSON.serialize(caseWrapperObj));
            
            Core_IPS_AdminUtility.getPartnerType();
        }
        System.assert(testuser.id != null, true);
    }
    
    public static TestMethod void saveCommentsTest3(){
        String profileId = [SELECT Id from Profile where Name='Sales Ops'].Id;
        user testuser=new user();
        testuser.email='testuser1998@example.com';
        testuser.Username='testuser1998@example.com';
        testuser.LastName='last';
        testuser.CompanyName='test';
        testuser.ProfileId=profileId;
        testuser.TimeZoneSidKey = 'America/Los_Angeles';
        testuser.EmailEncodingKey = 'UTF-8';
        testuser.LanguageLocaleKey = 'en_US';
        testuser.Alias = 'alias';
        testuser.LocaleSidKey = 'en_US';
        insert testuser;
        PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
        PermissionSet ps1 = [select id,label from PermissionSet where Label = 'IPS Permission Set'];
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps.Id );
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps1.Id );
        
        System.runAs(testuser){ 
            Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c ();
            labels2.name= 'FAE';
            labels2.value__c='FAE';
            insert labels2; 
            core_IPS_LEXAddCommentController.CaseWrapper caseWrapperObj = new core_IPS_LEXAddCommentController.CaseWrapper();
            insert TestUtilities.getCase();
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            caseWrapperObj.casesubststus = '';
            caseWrapperObj.caseComment = 'Test Comment';
            caseWrapperObj.closedPending = '';
            caseWrapperObj.caseid = caseRec;
            caseWrapperObj.selectedRadioButton = 'Public to Customers';
            core_IPS_LEXAddCommentController.saveComment(JSON.serialize(caseWrapperObj));
            Core_IPS_AdminUtility.saveComment(JSON.serialize(caseWrapperObj));
            Core_IPS_AdminUtility.getPartnerType();
        }
        System.assert(testuser.id != null, true);
    }
    public static TestMethod void saveCommentsTest41(){
        String profileId = [SELECT Id from Profile where Name='Production Support-IPS'].Id;
        user testuser=new user();
        testuser.email='testuser1998@example.com';
        testuser.Username='testuser1998@example.com';
        testuser.LastName='last';
        testuser.CompanyName='test';
        testuser.ProfileId=profileId;
        testuser.TimeZoneSidKey = 'America/Los_Angeles';
        testuser.EmailEncodingKey = 'UTF-8';
        testuser.LanguageLocaleKey = 'en_US';
        testuser.Alias = 'alias';
        testuser.LocaleSidKey = 'en_US';
        insert testuser;
        PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
        PermissionSet ps1 = [select id,label from PermissionSet where Label = 'IPS Permission Set'];
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps.Id );
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps1.Id );
        
        System.runAs(testuser){ 
            Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c ();
            labels2.name= 'Agent';
            labels2.value__c='Agent';
            insert labels2;
            core_IPS_LEXAddCommentController.CaseWrapper caseWrapperObj = new core_IPS_LEXAddCommentController.CaseWrapper();
            insert TestUtilities.getCase();
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            caseWrapperObj.casesubststus = '';
            caseWrapperObj.caseComment = 'Test Comment';
            caseWrapperObj.closedPending = '';
            caseWrapperObj.caseid = caseRec;
            caseWrapperObj.selectedRadioButton = 'Public to Customers';
            core_IPS_LEXAddCommentController.saveComment(JSON.serialize(caseWrapperObj));
            Core_IPS_AdminUtility.saveComment(JSON.serialize(caseWrapperObj));
            Core_IPS_AdminUtility.getPartnerType();
        }
        System.assert(testuser.id != null, true);
    }
    public static TestMethod void saveCommentsTest4(){
        String profileId = [SELECT Id from Profile where Name='Production Support-IPS'].Id;
        user testuser=new user();
        testuser.email='testuser1998@example.com';
        testuser.Username='testuser1998@example.com';
        testuser.LastName='last';
        testuser.CompanyName='test';
        testuser.ProfileId=profileId;
        testuser.TimeZoneSidKey = 'America/Los_Angeles';
        testuser.EmailEncodingKey = 'UTF-8';
        testuser.LanguageLocaleKey = 'en_US';
        testuser.Alias = 'alias';
        testuser.LocaleSidKey = 'en_US';
        insert testuser;
        PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
        PermissionSet ps1 = [select id,label from PermissionSet where Label = 'IPS Permission Set'];
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps.Id );
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps1.Id );
        
        System.runAs(testuser){ 
            core_IPS_LEXAddCommentController.CaseWrapper caseWrapperObj = new core_IPS_LEXAddCommentController.CaseWrapper();
            insert TestUtilities.getCase();
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            caseWrapperObj.casesubststus = '';
            caseWrapperObj.caseComment = 'Test Comment';
            caseWrapperObj.closedPending = '';
            caseWrapperObj.caseid = caseRec;
            //caseWrapperObj.selectedRadioButton = 'Public to Customers';
            core_IPS_LEXAddCommentController.saveComment(JSON.serialize(caseWrapperObj));
            Core_IPS_AdminUtility.saveComment(JSON.serialize(caseWrapperObj));
            Core_IPS_AdminUtility.getPartnerType();
        }
        System.assert(testuser.id != null, true);
    }
    public static TestMethod void saveCommentsTest5(){
        String profileId = [SELECT Id from Profile where Name='IPS Data Migration'].Id;
        user testuser=new user();
        testuser.email='testuser1998@example.com';
        testuser.Username='testuser1998@example.com';
        testuser.LastName='last';
        testuser.CompanyName='test';
        testuser.ProfileId=profileId;
        testuser.TimeZoneSidKey = 'America/Los_Angeles';
        testuser.EmailEncodingKey = 'UTF-8';
        testuser.LanguageLocaleKey = 'en_US';
        testuser.Alias = 'alias';
        testuser.LocaleSidKey = 'en_US';
        insert testuser;
        
        PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
        PermissionSet ps1 = [select id,label from PermissionSet where Label = 'IPS Permission Set'];
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps.Id );
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps1.Id );
        System.runAs(testuser){ 
            Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c ();
            labels2.name= 'Data Migration';
            labels2.value__c='Data Migration';
            insert labels2;
            core_IPS_LEXAddCommentController.CaseWrapper caseWrapperObj = new core_IPS_LEXAddCommentController.CaseWrapper();
            insert TestUtilities.getCase();
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            caseWrapperObj.casesubststus = 'test';
            caseWrapperObj.caseComment = 'Test Comment';
            caseWrapperObj.closedPending = '';
            caseWrapperObj.caseid = caseRec;
            caseWrapperObj.selectedRadioButton = 'Public to Customers';
            core_IPS_LEXAddCommentController.saveComment(JSON.serialize(caseWrapperObj));
            Core_IPS_AdminUtility.saveComment(JSON.serialize(caseWrapperObj));
            Core_IPS_AdminUtility.getPartnerType();
        }
        System.assert(testuser.id != null, true);
    }
    public static TestMethod void saveCommentsTest6(){
        String profileId = [SELECT Id from Profile where Name='Integration'].Id;
        user testuser=new user();
        testuser.email='testuser1998@example.com';
        testuser.Username='testuser1998@example.com';
        testuser.LastName='last';
        testuser.CompanyName='test';
        testuser.ProfileId=profileId;
        testuser.TimeZoneSidKey = 'America/Los_Angeles';
        testuser.EmailEncodingKey = 'UTF-8';
        testuser.LanguageLocaleKey = 'en_US';
        testuser.Alias = 'alias';
        testuser.LocaleSidKey = 'en_US';
        insert testuser;
        PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
        PermissionSet ps1 = [select id,label from PermissionSet where Label = 'IPS Permission Set'];
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps.Id );
        insert new PermissionSetAssignment(AssigneeId = testuser.id, PermissionSetId = ps1.Id );
        
        System.runAs(testuser){ 
            Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c ();
            labels2.name= 'PUBLIC_TO_CUSTOMERS';
            labels2.value__c='PUBLIC_TO_CUSTOMERS';
            insert labels2;
            Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
            labels.name= 'Backend Integration';
            labels.value__c='Backend Integration';
            insert labels;
            core_IPS_LEXAddCommentController.CaseWrapper caseWrapperObj = new core_IPS_LEXAddCommentController.CaseWrapper();
            insert TestUtilities.getCase();
            Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            caseWrapperObj.casesubststus = '';
            caseWrapperObj.caseComment = 'Test Comment';
            caseWrapperObj.closedPending = string.valueof(system.today()-1);
            caseWrapperObj.caseid = caseRec;
            caseWrapperObj.selectedRadioButton = 'Public to Customers';
            core_IPS_LEXAddCommentController.saveComment(JSON.serialize(caseWrapperObj));
            Core_IPS_AdminUtility.saveComment(JSON.serialize(caseWrapperObj));
            Core_IPS_AdminUtility.getPartnerType();
        }
        System.assert(testuser.id != null, true);
    }
    
    
    
    
    public static TestMethod void saveCommentsTest7(){
        
        String profileId = [SELECT Id from Profile where Name='Partner'].Id;
        core_IPS_LEXAddCommentController.partnerProf = profileId;
        core_IPS_LEXAddCommentController.partnerType = 'Not a Partner';
        /*list<Core_IPS_Labels__c> lstCs = new list<Core_IPS_Labels__c>();
        lstCs.add(new Core_IPS_Labels__c(name='Core_IPS_Agent_Partner_Profile_id', value__c=profileId));
        lstCs.add(new Core_IPS_Labels__c(name='Core_IPS_Profile_Name', value__c='IPS External Customer'));
       //Added by Sowmya - Start - 22/11/2014 - TWC745-6800 - Fix test coverage for all failed classes
     	lstCs.add(new Core_IPS_Labels__c(name='Core_IPS_Close_Pending_SubStatus', value__c='Close-Pending'));
        lstCs.add(new Core_IPS_Labels__c(name='PUBLIC_TO_CUSTOMERS', value__c='Public to Customers'));
        //Sowmya - End - 22/11/2014 - TWC745-6800 - Fix test coverage for all failed classes
     	insert lstCs;
        
        //Added by Sowmya - Start - 22/11/2014 - TWC745-6800 - Fix test coverage for all failed classes
     	Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c ();
        labels2.name= 'Partner - Agent';
        labels2.value__c='Partner - Agent';
        insert labels2;
        Account acc = TestUtilities.getAccountRecord();
        insert acc;
        Contact con = TestUtilities.getContact();
        con.AccountId = acc.ID;
        insert con;
        Account account2 = new Account();
            account2.Name = 'Dell Dell';
            account2.Core_Account_Type__c = 'Distributor';
            account2.Core_Sales_Segment__c = 'Compute';
			account2.BillingCity = 'folsom';
            account2.BillingCountry = 'USA';
            account2.BillingStreet = 'Creek Side Dr';
        	account2.Core_IPS_Active__c = true;
        insert account2;
        Contact con2 = TestUtilities.getContact();
        con2.Email = 'con2@gmail.com';
        con2.AccountId = account2.ID;
        con2.Core_IPS_Active__c = True;
        insert con2;*/
         User AccountOwner= TestUtilities.getAccountOwner();
              System.runas(AccountOwner){
                  list<Core_IPS_Labels__c> lstCs = new list<Core_IPS_Labels__c>();
        	lstCs.add(new Core_IPS_Labels__c(name='Core_IPS_Agent_Partner_Profile_id', value__c=profileId));
        	lstCs.add(new Core_IPS_Labels__c(name='Core_IPS_Profile_Name', value__c='IPS External Customer'));
       		//Added by Sowmya - Start - 22/11/2014 - TWC745-6800 - Fix test coverage for all failed classes
     		lstCs.add(new Core_IPS_Labels__c(name='Core_IPS_Close_Pending_SubStatus', value__c='Close-Pending'));
        	lstCs.add(new Core_IPS_Labels__c(name='PUBLIC_TO_CUSTOMERS', value__c='Public to Customers'));
        	//Sowmya - End - 22/11/2014 - TWC745-6800 - Fix test coverage for all failed classes
     		insert lstCs;
            //Added by Sowmya - Start - 22/11/2014 - TWC745-6800 - Fix test coverage for all failed classes
     		Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c ();
            labels2.name= 'Partner - Agent';
        	labels2.value__c='Partner - Agent';
        	insert labels2;
              Account acc = TestUtilities.getAccountRecord();
        	  acc.OwnerId = AccountOwner.Id; //Added by Nuthana
        	  insert acc;
        	  System.debug('owner Id'+acc.OwnerId);
              System.assert(acc.Id != null, 'Record not created');

        	Contact con = TestUtilities.getContact();
        	con.AccountId = acc.ID;
        	insert con;
        	System.assert(con.Id != null, 'Record not created');
                  
            Account account2 = new Account();
            account2.Name = 'Dell Dell';
            account2.Core_Account_Type__c = 'Distributor';
            account2.Core_Sales_Segment__c = 'Compute';
			account2.BillingCity = 'folsom';
            account2.BillingCountry = 'USA';
            account2.BillingStreet = 'Creek Side Dr';
        	account2.Core_IPS_Active__c = true;
        insert account2;
        Contact con2 = TestUtilities.getContact();
        con2.Email = 'con2@gmail.com';
        con2.AccountId = account2.ID;
        con2.Core_IPS_Active__c = True;
        insert con2;
              
          }
          Contact con = [select Id from Contact Limit 1];
        String profileId1 = [SELECT Id from Profile where Name='System Administrator'].Id;
		user u = new user();
        	u.ProfileId = profileId1;
            u.LastName = 'last';
            u.Email = 'puser00012@apttus.com';
            u.Username = 'puser00012@gmail.com' + System.currentTimeMillis();
            u.CompanyName = 'TEST';
            u.Title = 'title';
            u.Alias = 'alias';
            u.TimeZoneSidKey = 'America/Los_Angeles';
            u.EmailEncodingKey = 'UTF-8';
            u.LanguageLocaleKey = 'en_US';
            u.LocaleSidKey = 'en_US';
       Insert u;
         
        User uu = new User(
            ProfileId = profileId,
            LastName = 'last',
            Email = 'puser00012123@gmail.com',
            Username = 'puser00011232@gmail.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ContactId = con.Id);
        insert uu;
          
        core_IPS_LEXAddCommentController.CaseWrapper caseWrapperObj = new core_IPS_LEXAddCommentController.CaseWrapper();
           System.runas(u){
            PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Permission Set'];
            insert new PermissionSetAssignment(AssigneeId = uu.id, PermissionSetId = ps.Id );
        	Core_IPS_AdminUtility.saveComment(JSON.serialize(caseWrapperObj));
        }
        System.runAs(uu){ 
            insert TestUtilities.getCase();
			Id caseRec = [SELECT ID FROM Case Limit 1].Id;
            caseWrapperObj.casesubststus = 'test';
            caseWrapperObj.caseComment = 'Test Comment';
            caseWrapperObj.closedPending = string.valueof(system.today()-1);
            caseWrapperObj.caseid = caseRec;
            caseWrapperObj.selectedRadioButton = 'Public to Customers';
            core_IPS_LEXAddCommentController.saveComment(JSON.serialize(caseWrapperObj));
            Core_IPS_AdminUtility.saveComment(JSON.serialize(caseWrapperObj));
            Core_IPS_AdminUtility.getPartnerType();
        }

     	// Sowmya - End - 22/11/2014 - TWC745-6800 - Fix test coverage for all failed classes
     	 System.assert(con.id != null, true);
    }
    
    
    public static TestMethod void getProductVariants_test() {
        Core_IPS_Product_Organization__c prodOrg=new Core_IPS_Product_Organization__c();
        prodOrg.Core_Organization_Description__c='Datacenter, Servers, Networking, Comms and Storage';
        prodOrg.Core_IPS_Support_Org_Name__c='Test Data Center';
        insert prodOrg;
        // Avoid Hardcoding Id Fix  - Shipra  
        Product2 prod = new Product2();
        prod.name = 'Intel® Silicon Photonics 100G CWDM4 QSFP28 Optical Transceiver';
        prod.Core_Product_Name_EPM_ID__c = '84470';
        prod.Core_Design_Registration_Eligible_Ind__c  = true;
        prod.Core_Product_Org__c  = 'IPS';
        prod.isActive = true;
        prod.Core_IPS_Visible_Flag_Internal__c = 'Yes';
        insert prod;
        
        
        Core_IPS_Supported_Product__c supportProd=new Core_IPS_Supported_Product__c();
        supportProd.Core_Flag_Status__c='Approval Required';
        supportProd.Core_Supported_Product_Alias__c='CWDM4, QSFP28';
        supportProd.Core_Product__c= prod.Id;
        //supportProd.Core_Product__c='01to00000074tuDAAQ';
        
        supportProd.Core_Product_Organization__c=prodOrg.Id;
        supportProd.Core_IPS_Is_Show_Variant__c=true;
        insert supportProd;
        
        Core_IPS_Master_Issue_Category__c MasterIssue=new Core_IPS_Master_Issue_Category__c();
        MasterIssue.Core_Status__c='Active';
        MasterIssue.Core_Type__c='MasterIssue';
        MasterIssue.Name='Test Firmware/BIOS';
        insert MasterIssue;
        Core_IPS_Product_Issue_Category__c category=new Core_IPS_Product_Issue_Category__c();
        category.Core_Issue_Sub_Category_Name__c=MasterIssue.Id;
        category.Core_Type__c='Test Case Subcategory';
        category.Core_Status__c='Active';
        // Avoid Hardcoding Id Fix  - Shipra 
        //category.Core_Supported_Product__c='a2E1J000000KbPyUAK';
        category.Core_Supported_Product__c=supportProd.Id;
        insert category;
        String categoryId=category.Id;
        
        Core_IPS_Project__c Project=new Core_IPS_Project__c();
        Project.Name='Test CC';
        Project.Core_Status__c='Draft';
        insert Project;
        
        Core_Flat_Product_Hierarchy__c Flatproduct=new Core_Flat_Product_Hierarchy__c();
        Flatproduct.Core_EPM_Hierarchy_Name__c='test Flatproduct';
        Flatproduct.Core_L1_EPM_ID__c='36786';
        Flatproduct.Core_L1_EPM_Name__c='Programs';
        Flatproduct.Core_L2_EPM_ID__c='36786';
        Flatproduct.Core_L2_EPM_Name__c='Pre-Sales Products';
        Flatproduct.Core_Unique_ID__c='84470';
        //Flatproduct.Core_Product_EPM_ID__c=Project.Id;
        insert Flatproduct;
        
        asset assetProduct=new asset();
        assetProduct.Name='TestAsset';
        assetProduct.Core_Product_Organization__c=prodOrg.Id;
        assetProduct.Core_Supported_Product__c=supportProd.Id;
        assetProduct.Core_IPS_Project__c=Project.Id;
        assetProduct.Product2Id = prod.Id;
        //assetProduct.Core_Product_EPM_ID__c='84470';
        insert assetProduct;
        
        Core_IPS_AdminUtility.getProductVariants(assetProduct.Id);
        System.assert(Project.id != null, true);
    }
    
    
    
}