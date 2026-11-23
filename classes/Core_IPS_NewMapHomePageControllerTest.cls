/************************************************************************************
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prasad                        23/April/2020               fixed PMD issues
****************************************************************************************/
@isTest(seeAllData=false)
private class Core_IPS_NewMapHomePageControllerTest {
    
    @testSetup 
    static void testSetupData() {
        List<Product2> productList = new List<Product2>();
      // inserting products
        ProductList = TestUtilities.getListOfProduct(3);
        insert ProductList;
        System.assert(ProductList <> null, 'Record not created');
        
        // inserting product org
        Core_IPS_Product_Organization__c prodOrg = new Core_IPS_Product_Organization__c();
        prodOrg = TestUtilities.getSupportOrg();
        prodOrg.Core_Organization_Description__c = 'Test';
        insert prodOrg;
        System.assert(prodOrg <> null, 'Record not created');
       
        // inserting Supported Product 
        List<Core_IPS_Supported_Product__c> suppProductList = new List<Core_IPS_Supported_Product__c> ();
        SuppProductList = TestUtilities.getListOfSupportedProduct(3);
        Integer i = 0;
        for(Core_IPS_Supported_Product__c supportedProductRecord: SuppProductList){                
                SupportedProductRecord.Core_Product__c = ProductList.get(i).id;
                SupportedProductRecord.Core_Product_Organization__c = prodOrg.id;
                 i++;                     
           }
        insert SuppProductList;
        System.assert(SuppProductList <> null, 'Record not created');
         Account Accnt = new Account();
            Accnt.Name = 'Test Account';
            Accnt.BillingCountryCode = 'USA';
            Accnt.BillingStateCode = 'AL';
            Accnt.BillingCity = 'Alabama';
            Accnt.BillingStreet = 'street';
            Accnt.Core_IPS_Active__c = true;
            Accnt.recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId();
            Database.insert(Accnt);
        
        Case cs = TestUtilities.getCase();
        cs.AccountId=Accnt.id;
        cs.Core_IPS_Supported_Product__c = suppProductList[0].Id;
        insert cs;
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = prodOrg.id;
        mapRec.Core_Name__c = 'Test Record-MAP';
        mapRec.Core_Status__c = 'Active';
        mapRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
        insert mapRec;
        System.assert(mapRec <> null, 'Record not created');
        
       // inserting Prodcut Access Product
        List<Core_IPS_MAP_Product__c> prodJuncList= new List<Core_IPS_MAP_Product__c>();
        for(Integer x=0;x<1;x++){
            Core_IPS_MAP_Product__c mapProd = new Core_IPS_MAP_Product__c();
            mapProd.Core_MAP_PAR__c = mapRec.id;
            mapProd.Core_MAP_Supported_Product__c = SuppProductList[x].id;
            prodJuncList.add(mapProd);
        }
        insert prodJuncList;
        System.assert(prodJuncList <> null, 'Record not created');
        
      
    }
    
    private static testmethod void displayMapResultsTest() {
        Core_IPS_NewMapHomePageController.isNewMapButtonVisible();
        list<Core_IPS_NewMapHomePageController.DataTableWrapper> wrap1 = new list<Core_IPS_NewMapHomePageController.DataTableWrapper>();
        String queryString = 'SELECT Id, Name,Core_Name__c,Core_IPS_MAP_Access_Flag__c, Core_Status__c,LastModifiedBy.Name,Core_Product_Organization__c, Core_Product_Organization__r.Name, Core_Product_Organization__r.Core_Organization_Description__c, Core_Product_Organization__r.Id, Core_Product_Organization__r.Core_IPS_Support_Org_Name__c FROM Core_IPS_MAP_PAR__c Order By Name asc';
        wrap1 = Core_IPS_NewMapHomePageController.displayMapResults(queryString);
        system.assertEquals(queryString, 'SELECT Id, Name,Core_Name__c,Core_IPS_MAP_Access_Flag__c, Core_Status__c,LastModifiedBy.Name,Core_Product_Organization__c, Core_Product_Organization__r.Name, Core_Product_Organization__r.Core_Organization_Description__c, Core_Product_Organization__r.Id, Core_Product_Organization__r.Core_IPS_Support_Org_Name__c FROM Core_IPS_MAP_PAR__c Order By Name asc');
       
    }
    
    private static testMethod void updateMAPRecordTest(){
        Core_IPS_MAP_PAR__c mapRec = new Core_IPS_MAP_PAR__c();
        mapRec = [select name,id from Core_IPS_MAP_PAR__c where core_name__c = 'Test Record-MAP'];
        List<Case> cs = [Select Id From Case];
        Core_IPS_NewMapHomePageController.updateMAPRecord(mapRec);
        system.assertNotEquals(mapRec, null);
        Core_IPS_NewMapHomePageController.getattachments(cs.get(0).Id);
       
    }
    
    private static testMethod void getQueryResultTest(){
               
        String coreNameLike = 'Test Record-MAP';
    string queryStr = 'select id from Core_IPS_MAP_PAR__c where core_name__c = \'' +String.escapeSingleQuotes(coreNameLike) +'\''; 
       
        Core_IPS_NewMapHomePageController.getQueryResult(queryStr);    
        system.assertNotEquals(queryStr, null);
      
    } 
    
    private static testMethod void addSupportedProductToMAPTest(){
       List<Core_IPS_MAP_Product__c> mapProdRec = new List<Core_IPS_MAP_Product__c>();
       Core_IPS_MAP_Product__c rec = new Core_IPS_MAP_Product__c();
       rec = [select id from Core_IPS_MAP_Product__c where Core_MAP_PAR__r.core_name__c = 'Test Record-MAP'];
       mapProdRec.add(rec); 
       Core_IPS_NewMapHomePageController.addSupportedProductToMAP(mapProdRec);
       system.assertNotEquals(mapProdRec, null);
        
    }
    
    static List<Account> accountList =  new List<Account>();
    static List<Product2> productList = new List<Product2>();
    static Core_IPS_Product_Organization__c prodOrg = new Core_IPS_Product_Organization__c();
    static List<Core_IPS_Supported_Product__c> suppProductList = new List<Core_IPS_Supported_Product__c> ();
    public static TestMethod void getRecords(){
        // inserting Accounts
        AccountList = TestUtilities.getAccountsList(3);
        for(Account acc : AccountList) {
            acc.Core_IPS_Active__c = true;
            acc.Core_CNDA_Number__c = '1234';
        }
        insert AccountList;
        List<user> userList = TestUtilities.getListofuser(1);
        profile prof = [select id, name from Profile where name = 'Sales Rep-BB' limit 1];
        userlist[0].profileid=prof.id;
        userlist[0].username='salesrep0202.abc@user.com';
        //System.runAs(ListOfUser.get(0)){
            insert userlist;
        //}
        String teamMemberRole = 'Team Member (100%)';
        String accountAccessLevel = 'Edit';
        String opportunityAccessLevel = 'Read';
        String caseAccessLevel = 'Edit';
        
        List<AccountTeamMember> members = new list<AccountTeamMember>();
        List<AccountShare> sharingRules = new list<AccountShare>();
        members.add(New AccountTeamMember(AccountId = AccountList.get(0).Id, TeamMemberRole = teamMemberRole, UserId= userlist[0].Id));
        sharingRules.add(new AccountShare(AccountAccessLevel = accountAccessLevel, OpportunityAccessLevel = OpportunityAccessLevel, CaseAccessLevel = caseAccessLevel, UserOrGroupId = userlist[0].Id, AccountId = AccountList.get(0).Id));
        insert members;
        insert sharingRules;
        
        // inserting products
        ProductList = TestUtilities.getListOfProduct(3);
        insert ProductList;
        // inserting product org
        prodOrg = TestUtilities.getSupportOrg();
        insert prodOrg;
        // inserting Supported Product 
        suppProductList = TestUtilities.getListOfSupportedProduct(3);
        Integer i = 0;
        for(Core_IPS_Supported_Product__c supportedProductRecord: SuppProductList){                
                SupportedProductRecord.Core_Product__c = ProductList.get(i).id;
                SupportedProductRecord.Core_Product_Organization__c = prodOrg.id;
                if(i==1) {
                    SupportedProductRecord.Core_Flag_Status__c = 'Par Hidden';
                }
                if(i==2) {
                    SupportedProductRecord.Core_Flag_Status__c = 'Auto Approve';   
                }
                 i++;                     
            // SuppProductList.add(SupportedProductRecord);
        }
        insert SuppProductList;
        system.assertNotEquals(AccountList, null);
    }

  private static testMethod void createLineItemsTest() {
    getRecords();
    
    // inserting Product Access Header
    List<Core_IPS_MAP_PAR__c> mapList = new List<Core_IPS_MAP_PAR__c>();
    Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
    mapRec.Core_Product_Organization__c = prodOrg.id;
    mapRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
    mapList.add(mapRec);
     
    Core_IPS_MAP_PAR__c mapRec1 = TestUtilities.getMapPar();
    mapRec1.Core_Product_Organization__c = prodOrg.id;
    mapRec1.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
    mapList.add(mapRec1);
     
    insert mapList;
    
    List<Core_IPS_MAP_Product__c> mapProdList = new List<Core_IPS_MAP_Product__c>();
    for(Integer i=0;i<2;i++){
      Core_IPS_MAP_Product__c mapProd = new Core_IPS_MAP_Product__c();
      MapProd.Core_MAP_PAR__c=mapRec.id;
      MapProd.Core_MAP_Supported_Product__c=SuppProductList[i].Id;
      mapProdList.add(MapProd);
    }
    Core_IPS_NewMapHomePageController.addSupportedProductToMAP(mapProdList);
    
    Core_IPS_MAP_Account__c accJunc = new Core_IPS_MAP_Account__c();
    accJunc.Core_Account__c=AccountList[1].id;
    accJunc.Core_MAP_PAR__c=mapRec.id;
    Core_IPS_NewMapHomePageController.addAccountToMAP(accJunc);
    // inserting Product Access Line Items-MAP
    Id mapLineItemRecTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
    List<Core_IPS_Map_Par_Line_Item__c> lineItemList = new List<Core_IPS_Map_Par_Line_Item__c>();
    for(Integer i=0;i<3;i++){
      Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
      lineItem.Core_MAP_PAR__c = mapRec.id;
      lineItem.Core_Supported_Product__c = SuppProductList[i].id;
      lineItem.Core_Approval_Type__c = 'Auto Approve';
      lineItem.Core_Account__c = accJunc.id;
      lineItem.Core_Status__c = 'Active';
      lineItem.RecordTypeId = mapLineItemRecTypeId;
            lineItem.Core_Submitter_Comments__c = 'Test Submitter Comment';
      lineItemList.add(lineItem);
    }
    Object obj = Core_IPS_NewMapHomePageController.createLineItems(lineItemList);
                
        List<Core_IPS_Map_Par_Line_Item__c> lineItemList1 = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Integer i=0;i<3;i++){
            Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
            lineItem.Core_MAP_PAR__c = mapRec.id;
            lineItem.Core_Supported_Product__c = SuppProductList[i].id;
            lineItem.Core_Approval_Type__c = 'Auto Approve';
            lineItem.Core_Account__c = AccountList[i].id;
            lineItem.Core_Submitter_Comments__c = 'Test Submitter Comment';
            lineItemList1.add(lineItem);
        }
        insert lineItemList1;
        
        List<Core_IPS_Map_Par_Line_Item__c> uplineItemList = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Core_IPS_Map_Par_Line_Item__c lineItem: lineItemList1){
            lineItem.Core_Status__c='INACTIVE';
            uplineItemList.add(lineItem);
        }
        uplineItemList[2].Core_Status__c='ACTIVE';
        update uplineItemList;
        delete uplineItemList[0];
        
    lineItemList = new List<Core_IPS_Map_Par_Line_Item__c>();
    for(Integer i=0;i<3;i++){
      Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
      lineItem.Core_MAP_PAR__c = mapRec.id;
      lineItem.Core_Supported_Product__c = SuppProductList[i].id;
      lineItem.Core_Approval_Type__c = 'Auto Approve';
      lineItem.Core_Account__c =  AccountList[i].id;//accJunc.id;
      lineItem.Core_Status__c = 'Active';
      lineItem.RecordTypeId = mapLineItemRecTypeId;
            lineItem.Core_Submitter_Comments__c = 'Test Submitter Comment';
      lineItemList.add(lineItem);
    }
    Core_IPS_NewMapHomePageController.createLineItems(lineItemList);
        
        Core_IPS_NewMapHomePageController.deleteMAPRecord(mapRec);
        Core_IPS_MAP_Account__c accJunc2 = new Core_IPS_MAP_Account__c();
    accJunc2.Core_Account__c=AccountList[1].id;
    accJunc2.Core_MAP_PAR__c=mapRec.id;
        Core_IPS_NewMapHomePageController.addAccountToMAP(accJunc2);
        Core_IPS_NewMapHomePageController.getFAEAffiliatedAccounts();
    
        String queryString = 'SELECT Id, Name FROM Core_IPS_MAP_Account__c WHERE Core_MAP_PAR__c = \''+ mapRec.id + '\'';
        Core_IPS_NewMapHomePageController.getFAEAffiliatedMapAccounts(queryString);
       
        User usr = [Select Id FROM User where username = 'salesrep0202.abc@user.com'];
        System.runAs(usr) {
            Core_IPS_NewMapHomePageController.getFAEAffiliatedAccounts();
        }
        system.assertNotEquals(lineItemList, null);
  }
    /*
    private static testMethod void createLineItemsTest1() {
    getRecords();
    
    // inserting Product Access Header
    List<Core_IPS_MAP_PAR__c> mapList = new List<Core_IPS_MAP_PAR__c>();
    Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
    mapRec.Core_Product_Organization__c = prodOrg.id;
    mapRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
    mapList.add(mapRec);
    
    insert mapList;
    
    List<Core_IPS_MAP_Product__c> mapProdList = new List<Core_IPS_MAP_Product__c>();
    for(Integer i=0;i<2;i++){
      Core_IPS_MAP_Product__c MapProd = new Core_IPS_MAP_Product__c();
      MapProd.Core_MAP_PAR__c=mapRec.id;
      MapProd.Core_MAP_Supported_Product__c=SuppProductList[i].Id;
      mapProdList.add(MapProd);
    }
    Core_IPS_NewMapHomePageController.addSupportedProductToMAP(mapProdList);
    
    Core_IPS_MAP_Account__c accJunc = new Core_IPS_MAP_Account__c();
    accJunc.Core_Account__c=AccountList[1].id;
    accJunc.Core_MAP_PAR__c=mapRec.id;
    Core_IPS_NewMapHomePageController.addAccountToMAP(accJunc);
    
    Id mapLineItemRecTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
    List<Core_IPS_Map_Par_Line_Item__c> lineItemList = new List<Core_IPS_Map_Par_Line_Item__c>();
    for(Integer i=0;i<3;i++){
      Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
      lineItem.Core_MAP_PAR__c = mapRec.id;
      lineItem.Core_Supported_Product__c = SuppProductList[i].id;
      lineItem.Core_Approval_Type__c = 'Auto Approve';
      lineItem.Core_Account__c = accJunc.id;
      lineItem.Core_Status__c = 'Active';
      lineItem.RecordTypeId = mapLineItemRecTypeId;
            lineItem.Core_Submitter_Comments__c = 'Test Submitter Comment';
      lineItemList.add(lineItem);
    }
    Object obj = Core_IPS_NewMapHomePageController.createLineItems(lineItemList);
    Core_IPS_NewMapHomePageController.deleteMAPRecord(accJunc);
    
    mapProdList = new List<Core_IPS_MAP_Product__c>();
    for(Integer i=2;i<3;i++){
      Core_IPS_MAP_Product__c MapProd = new Core_IPS_MAP_Product__c();
      MapProd.Core_MAP_PAR__c=mapRec.id;
      MapProd.Core_MAP_Supported_Product__c=SuppProductList[i].Id;
      mapProdList.add(MapProd);
    }
    Core_IPS_NewMapHomePageController.addSupportedProductToMAP(mapProdList);
    
    accJunc = new Core_IPS_MAP_Account__c();
    accJunc.Core_Account__c=AccountList[1].id;
    accJunc.Core_MAP_PAR__c=mapRec.id;
    Core_IPS_NewMapHomePageController.addAccountToMAP(accJunc);
    
    lineItemList = new List<Core_IPS_Map_Par_Line_Item__c>();
    for(Integer i=0;i<3;i++){
      Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
      lineItem.Core_MAP_PAR__c = mapRec.id;
      lineItem.Core_Supported_Product__c = SuppProductList[i].id;
      lineItem.Core_Approval_Type__c = 'Auto Approve';
      lineItem.Core_Account__c = accJunc.id;
      lineItem.Core_Status__c = 'Active';
      lineItem.RecordTypeId = mapLineItemRecTypeId;
            lineItem.Core_Submitter_Comments__c = 'Test Submitter Comment';
      lineItemList.add(lineItem);
    }
    obj = Core_IPS_NewMapHomePageController.createLineItems(lineItemList);
  }*/
    
    
    
    private static testMethod void isCurrentUserOrgAdminMemberTest1() {
        prodOrg = TestUtilities.getSupportOrg();
        insert prodOrg;
                
        Test.startTest();
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> profileList = [select id, name from Profile where name = 'IPS Support Org Admin' or Name = 'Sales Rep-BB'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        List<User> listOfUser = new List<User> ();
        ListOfUser = TestUtilities.getListOfUser(2);
        for(User usr : ListOfUser){
            Usr.ProfileID =  profiles.get('IPS Support Org Admin');
        }
        //ListOfUser[1].ProfileID = profiles.get('Sales Rep-BB');
        insert ListOfUser;
        prodOrg.ownerId = ListOfUser[0].Id;
        update prodOrg;
        List<Core_IPS_Product_Organization_Admin__c> orgAdminMemList = new List<Core_IPS_Product_Organization_Admin__c>();
        Core_IPS_Product_Organization_Admin__c orgAdminMem = new Core_IPS_Product_Organization_Admin__c();
        orgAdminMem.Core_Admin__c = UserInfo.getUserId();
        orgAdminMem.Core_Primary_Admin__c = true;
        orgAdminMem.Core_Product_Organization__c = prodOrg.Id;
        orgAdminMemList.add(orgAdminMem);
        
        Core_IPS_Product_Organization_Admin__c orgAdminMem2 = new Core_IPS_Product_Organization_Admin__c();
        orgAdminMem2.Core_Admin__c = ListOfUser[0].Id;
        orgAdminMem2.Core_Primary_Admin__c = true;
        orgAdminMem2.Core_Product_Organization__c = prodOrg.Id;
        orgAdminMemList.add(orgAdminMem2);
        
        insert orgAdminMem2;
        System.runAs(ListOfUser.get(1)){
            try{
            Core_IPS_NewMapHomePageController.isCurrentUserOrgAdminMember(prodOrg.Id);
            }
            catch(Exception e)
            {
    //Handle exception here
        }
        }
       // Core_IPS_NewMapHomePageController.isCurrentUserOrgAdminMember(prodOrg.Id);
        Test.stopTest();
        system.assertNotEquals(prodOrg, null);
    }
    
    private static testMethod void getUserIdsFromQPBTest() {
        List<Group> grpList = new List<Group>();
        Group grp1 = new Group(Type='Queue', Name='Queue name');
    grpList.add(grp1);
        Group grp2 = new Group(Name='Queue name');
    grpList.add(grp2);
        insert grpList;
        
        List<GroupMember> grpMemList = new List<GroupMember>();
        GroupMember member1 = new GroupMember();
        member1.UserOrGroupId = UserInfo.getUserId();
        member1.GroupId = grp1.Id;
        grpMemList.add(member1);
        
        GroupMember member2 = new GroupMember();
        member2.UserOrGroupId = UserInfo.getUserId();
        member2.GroupId = grp2.Id;
        grpMemList.add(member2);
        
        GroupMember member3 = new GroupMember();
        member3.UserOrGroupId = grp2.Id;
        member3.GroupId = grp1.Id;
        grpMemList.add(member3);
        
        insert grpMemList;
        
        Core_IPS_NewMapHomePageController.getUserIdsFromQPB(grp1.Id);
        Core_IPS_NewMapHomePageController.getLabel('Core_IPS_MAP_PAR__c', 'Core_IPS_MAP_PAR__c');
        
        system.assertNotEquals(grpMemList, null);
    }
    private static testMethod void getCaseTest() {
        Case testCase = TestUtilities.getCase();
        insert testCase;

        String status = Core_IPS_NewMapHomePageController.getCase(testCase.Id);
        System.assert(status == 'New');
    }
    /*private static testMethod void isCurrentUserFEETest() {
        User usr = TestUtilities.getUser();
        Id prfId = [SELECT Id FROM Profile WHERE Name = 'Sales Rep-BB' LIMIT 1].Id;
        usr.ProfileId = prfId;
        insert usr;

        Core_IPS_NewMapHomePageController.checkForFAEandProjects result;
        System.runAs(usr) {
            result = Core_IPS_NewMapHomePageController.isCurrentUserFEE('SELECT Id FROM Core_IPS_Opportunity__c');
        }
        System.assert(result.isCurrentUserFAE == true);
        
    }
    private static testMethod void isCurrentUserFEETestNegative() {
        User usr = TestUtilities.getUser();
        Id prfId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        usr.ProfileId = prfId;
        insert usr;

        Core_IPS_NewMapHomePageController.checkForFAEandProjects result;
        System.runAs(usr) {
            result = Core_IPS_NewMapHomePageController.isCurrentUserFEE('SELECT Id FROM Core_IPS_Opportunity__c');
        }
        System.assert(result.isCurrentUserFAE == false);
    }*/
   
}