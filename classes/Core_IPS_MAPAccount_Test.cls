@isTest
public class Core_IPS_MAPAccount_Test{
        
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Void Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Common Test data used in multiple test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        11/04/2015                Created
    ****************************************************************************************************/
    static List<Account> AccountList =  new List<Account>();
    static List<Product2> ProductList = new List<Product2>();
    static Core_IPS_Product_Organization__c prodOrg = new Core_IPS_Product_Organization__c();
    static List<User> ListOfUser = new List<User> ();
    // static Core_IPS_Supported_Product__c supProd = new Core_IPS_Supported_Product__c();
    static List<Core_IPS_Supported_Product__c> SuppProductList = new List<Core_IPS_Supported_Product__c> ();
    public static TestMethod void getRecords(){
        // inserting Accounts
        AccountList = TestUtilities.getAccountsList(2);
        insert AccountList;
        System.assert(AccountList <> null, 'Record not created');
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
            // SuppProductList.add(SupportedProductRecord);
        }
        system.debug('test ### '+SuppProductList);
        insert SuppProductList;
        System.assert(SuppProductList <> null, 'Record not created');
    }
        
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Void Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Common Test data used in multiple test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        11/04/2015                Created
    ****************************************************************************************************/
    public static TestMethod void testActivateLineItems(){

        getRecords();    

        // inserting Product Access Header
        Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = prodOrg.id;
        mapRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
        insert mapRec;
        System.assert(mapRec <> null, 'Record not created');
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c parRec = TestUtilities.getMapPar();
        parRec.Core_Product_Organization__c = prodOrg.id;
        parRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId(); //'012210000004IHZ';
        insert parRec;
        System.assert(parRec <> null, 'Record not created');
        
        // inserting Product Access Line Items-MAP
        List<Core_IPS_Map_Par_Line_Item__c> lineItemList = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Integer i=0;i<2;i++){
            Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
            lineItem.Core_MAP_PAR__c = mapRec.id;
            lineItem.Core_Supported_Product__c = SuppProductList[0].id;
            lineItem.Core_Approval_Type__c = 'Auto Approve';
            lineItem.Core_Account__c = AccountList[i].id;
            lineItemList.add(lineItem);
        }
        insert lineItemList;
        System.assert(lineItemList <> null, 'Record not created');
        
        // inserting Product Access Line Items-PAR
        List<Core_IPS_Map_Par_Line_Item__c> lineItemListPAR = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Integer i=0;i<2;i++){
            Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
            lineItem.Core_MAP_PAR__c = parRec.id;
            lineItem.Core_Supported_Product__c = SuppProductList[0].id;
            lineItem.Core_Approval_Type__c = 'Auto Approve';
            lineItem.Core_Account__c = AccountList[i].id;
            lineItemListPAR.add(lineItem);
        }
        insert lineItemListPAR;
        System.assert(lineItemListPAR <> null, 'Record not created');
        
        // updating Line Item status to Inactive
        List<Core_IPS_Map_Par_Line_Item__c> uplineItemList = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Core_IPS_Map_Par_Line_Item__c lineItem: lineItemList){
            lineItem.Core_Status__c='INACTIVE';
            uplineItemList.add(lineItem);
        }
        update uplineItemList;
        System.assert(uplineItemList <> null, 'Record not updated');
        
        // updating Line Item status to Inactive
        List<Core_IPS_Map_Par_Line_Item__c> uplineItemListPAR = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Core_IPS_Map_Par_Line_Item__c lineItemPAR: lineItemListPAR){
            lineItemPAR.Core_Status__c='INACTIVE';
            uplineItemListPAR.add(lineItemPAR);
        }
        update uplineItemListPAR;
        System.assert(uplineItemListPAR <> null, 'Record not updated');
            
        // inserting Prodcut Access Product
        List<Core_IPS_MAP_Product__c> prodJuncList= new List<Core_IPS_MAP_Product__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Product__c mapProd = new Core_IPS_MAP_Product__c();
            mapProd.Core_MAP_PAR__c = mapRec.id;
            mapProd.Core_MAP_Supported_Product__c = SuppProductList[i].id;
            prodJuncList.add(mapProd);
        }
        insert prodJuncList;
        System.assert(prodJuncList <> null, 'Record not created');
        
        // inserting Prodcut Access Product-PAR
        List<Core_IPS_MAP_Product__c> prodJuncPARList= new List<Core_IPS_MAP_Product__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Product__c mapProdPAR = new Core_IPS_MAP_Product__c();
            mapProdPAR.Core_MAP_PAR__c = parRec.id;
            mapProdPAR.Core_MAP_Supported_Product__c = SuppProductList[i].id;
            prodJuncPARList.add(mapProdPAR);
        }
        insert prodJuncPARList;
        System.assert(prodJuncPARList <> null, 'Record not created');
        
        // inserting Prodcut Access Accounts
        List<Core_IPS_MAP_Account__c> accJuncList = new List<Core_IPS_MAP_Account__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Account__c accJunc = new Core_IPS_MAP_Account__c();
            accJunc.Core_Account__c=AccountList[i].id;
            accJunc.Core_MAP_PAR__c=mapRec.id;
            accJuncList.add(accJunc);
        }
        
        // inserting Prodcut Access Accounts-PAR
        List<Core_IPS_MAP_Account__c> accJuncPARList = new List<Core_IPS_MAP_Account__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Account__c accJuncPAR = new Core_IPS_MAP_Account__c();
            accJuncPAR.Core_Account__c=AccountList[i].id;
            accJuncPAR.Core_MAP_PAR__c=parRec.id;
            accJuncPARList.add(accJuncPAR);
        }
            
        Test.startTest();           
            insert accJuncList;
            System.assert(accJuncList <> null, 'Record not created');
            insert accJuncPARList;
            System.assert(accJuncPARList <> null, 'Record not created');
        Test.stopTest();
    }
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Void Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Common Test data used in multiple test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        11/04/2015                Created
    ****************************************************************************************************/
     public static TestMethod void accJuncCreateLineItems(){
        // Always make sure the accounts for line item and junc object assignments are not the same
        getRecords();
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = prodOrg.id;
        mapRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
        insert mapRec;
        System.assert(mapRec <> null, 'Record not created');
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c parRec = TestUtilities.getMapPar();
        parRec.Core_Product_Organization__c = prodOrg.id;
        parRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId(); //'012210000004IHZ';
        insert parRec;
        System.assert(parRec <> null, 'Record not created');
        
        // inserting Product Access Line Items-MAP
        List<Core_IPS_Map_Par_Line_Item__c> lineItemList = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
            lineItem.Core_MAP_PAR__c = mapRec.id;
            lineItem.Core_Supported_Product__c = SuppProductList[0].id;
            lineItem.Core_Approval_Type__c = 'Auto Approve';
            lineItem.Core_Account__c = AccountList[1].id;
            lineItemList.add(lineItem);
        }
        insert lineItemList;
        System.assert(lineItemList <> null, 'Record not created');
        
        // inserting Product Access Line Items-PAR
        List<Core_IPS_Map_Par_Line_Item__c> lineItemListPAR = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_Map_Par_Line_Item__c lineItem = new Core_IPS_Map_Par_Line_Item__c();
            lineItem.Core_MAP_PAR__c = parRec.id;
            lineItem.Core_Supported_Product__c = SuppProductList[0].id;
            lineItem.Core_Approval_Type__c = 'Auto Approve';
            lineItem.Core_Account__c = AccountList[1].id;
            lineItemListPAR.add(lineItem);
        }
        insert lineItemListPAR;
        System.assert(lineItemListPAR <> null, 'Record not created');
        
        // updating Line Item status to Inactive
        List<Core_IPS_Map_Par_Line_Item__c> uplineItemList = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Core_IPS_Map_Par_Line_Item__c lineItem: lineItemList){
            lineItem.Core_Status__c='INACTIVE';
            uplineItemList.add(lineItem);
        }
        update uplineItemList;
        System.assert(uplineItemList <> null, 'Record not updated');
        
        // updating Line Item status to Inactive
        List<Core_IPS_Map_Par_Line_Item__c> uplineItemListPAR = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Core_IPS_Map_Par_Line_Item__c lineItemPAR: lineItemListPAR){
            lineItemPAR.Core_Status__c='INACTIVE';
            uplineItemListPAR.add(lineItemPAR);
        }
        update uplineItemListPAR;
        System.assert(uplineItemListPAR <> null, 'Record not updated');
        
        // inserting Prodcut Access Product
        List<Core_IPS_MAP_Product__c> prodJuncList= new List<Core_IPS_MAP_Product__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Product__c mapProd = new Core_IPS_MAP_Product__c();
            mapProd.Core_MAP_PAR__c = mapRec.id;
            mapProd.Core_MAP_Supported_Product__c = SuppProductList[i].id;
            prodJuncList.add(mapProd);
        }
        insert prodJuncList;
        System.assert(prodJuncList <> null, 'Record not created');
        
        // inserting Prodcut Access Product-PAR
        List<Core_IPS_MAP_Product__c> prodJuncPARList= new List<Core_IPS_MAP_Product__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Product__c mapProdPAR = new Core_IPS_MAP_Product__c();
            mapProdPAR.Core_MAP_PAR__c = parRec.id;
            mapProdPAR.Core_MAP_Supported_Product__c = SuppProductList[i].id;
            prodJuncPARList.add(mapProdPAR);
        }
        insert prodJuncPARList;
        System.assert(prodJuncPARList <> null, 'Record not created');
        
        // inserting Prodcut Access Accounts (different from line item)
        List<Core_IPS_MAP_Account__c> accJuncList = new List<Core_IPS_MAP_Account__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Account__c accJunc = new Core_IPS_MAP_Account__c();
            accJunc.Core_Account__c=AccountList[0].id;
            accJunc.Core_MAP_PAR__c=mapRec.id;
            accJuncList.add(accJunc);
        }

        // inserting Prodcut Access Accounts (different from line item)-PAR
        List<Core_IPS_MAP_Account__c> accJuncPARList = new List<Core_IPS_MAP_Account__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Account__c accJuncPAR = new Core_IPS_MAP_Account__c();
            accJuncPAR.Core_Account__c=AccountList[0].id;
            accJuncPAR.Core_MAP_PAR__c=parRec.id;
            accJuncPARList.add(accJuncPAR);
        }
            
        Test.startTest();           
            insert accJuncList;
            System.assert(accJuncList <> null, 'Record not created');
            insert accJuncPARList;
            System.assert(accJuncPARList <> null, 'Record not created');
        Test.stopTest();
    }
    
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Void Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Common Test data used in multiple test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        11/04/2015                Created
    ****************************************************************************************************/
    public static TestMethod void accJuncDeleteLineItems(){
        getRecords();
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = prodOrg.id;
        mapRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
        insert mapRec;
        System.assert(mapRec <> null, 'Record not created');
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c parRec = TestUtilities.getMapPar();
        parRec.Core_Product_Organization__c = prodOrg.id;
        parRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId(); //'012210000004IHZ';
        insert parRec;
        System.assert(parRec <> null, 'Record not created');

        // inserting Prodcut Access Product
        List<Core_IPS_MAP_Product__c> prodJuncList= new List<Core_IPS_MAP_Product__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Product__c mapProd = new Core_IPS_MAP_Product__c();
            mapProd.Core_MAP_PAR__c = mapRec.id;
            mapProd.Core_MAP_Supported_Product__c = SuppProductList[i].id;
            prodJuncList.add(mapProd);
        }
        insert prodJuncList;
        System.assert(prodJuncList <> null, 'Record not created');
        
        // inserting Prodcut Access Product-PAR
        List<Core_IPS_MAP_Product__c> prodJuncPARList= new List<Core_IPS_MAP_Product__c>();
        for(Integer i=0;i<1;i++){
            Core_IPS_MAP_Product__c mapProdPAR = new Core_IPS_MAP_Product__c();
            mapProdPAR.Core_MAP_PAR__c = parRec.id;
            mapProdPAR.Core_MAP_Supported_Product__c = SuppProductList[i].id;
            prodJuncPARList.add(mapProdPAR);
        }
        insert prodJuncPARList;
        System.assert(prodJuncPARList <> null, 'Record not created');
        
        // inserting Prodcut Access Accounts 
        List<Core_IPS_MAP_Account__c> accJuncList = new List<Core_IPS_MAP_Account__c>();
        for(Integer i=0;i<2;i++){
            Core_IPS_MAP_Account__c accJunc = new Core_IPS_MAP_Account__c();
            accJunc.Core_Account__c=AccountList[i].id;
            accJunc.Core_MAP_PAR__c=mapRec.id;
            accJuncList.add(accJunc);
        }
        
        // inserting Prodcut Access Accounts -PAR
        List<Core_IPS_MAP_Account__c> accJuncPARList = new List<Core_IPS_MAP_Account__c>();
        for(Integer i=0;i<2;i++){
            Core_IPS_MAP_Account__c accJuncPAR = new Core_IPS_MAP_Account__c();
            accJuncPAR.Core_Account__c=AccountList[i].id;
            accJuncPAR.Core_MAP_PAR__c=parRec.id;
            accJuncPARList.add(accJuncPAR);
        }
        
        Test.startTest();
            insert accJuncList;
            System.assert(accJuncList <> null, 'Record not created');
            delete accJuncList;
            System.assert(accJuncList <> null, 'Record not deleted');
            insert accJuncPARList;
            System.assert(accJuncPARList <> null, 'Record not created');
            delete accJuncPARList;
            System.assert(accJuncPARList <> null, 'Record not deleted');
        Test.stopTest();
    }
    
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Void Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Common Test data used in multiple test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        11/04/2015                Created
    ****************************************************************************************************/
    public static TestMethod void accJuncDuplicateTest(){
        // inserting accoutn one
        Account acc = TestUtilities.getAccountRecord();
        insert acc;
        System.assert(acc <> null, 'Record not created');
        // inserting Product Org one
        Core_IPS_Product_Organization__c prodOrg_Del = TestUtilities.getSupportOrg();
        insert prodOrg_Del;
        System.assert(prodOrg_Del <> null, 'Record not created');
        // inserting Product Access Header one
        Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = prodOrg_Del.id;
        mapRec.Recordtypeid  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
        insert mapRec;
        System.assert(mapRec <> null, 'Record not created');
        // creating Product Access Account Junction one
        Core_IPS_MAP_Account__c MapAcc = new Core_IPS_MAP_Account__c();
        MapAcc.Core_Account__c=acc.id;
        MapAcc.Core_MAP_PAR__c=mapRec.id;
              
        Test.startTest();
            //Inserting MapAccount Junction for before Insert
            insert MapAcc;
            System.assert(MapAcc <> null, 'Record not created');            
            // Inserting another account
            Account acc1 = TestUtilities.getAccountRecord();
            acc1.Name='Testaccount2';
            acc1.BillingCity='Bezawada';
            insert acc1;
            // inserting prodcut org two
            Core_IPS_Product_Organization__c prodOrg1 = TestUtilities.getSupportOrg();
            insert prodOrg1;
            System.assert(prodOrg1 <> null, 'Record not created');
            // insertig Product Access Header two
            Core_IPS_MAP_PAR__c mapRec1 = TestUtilities.getMapPar();
            mapRec1.Core_Product_Organization__c = prodOrg1.id;
            mapRec1.Recordtypeid  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
            insert mapRec1;
            System.assert(mapRec1 <> null, 'Record not created');
            // inserting Product Access Account Junction two
            Core_IPS_MAP_Account__c MapAcc1 = new Core_IPS_MAP_Account__c();
            MapAcc1.Core_Account__c=acc.id;
            MapAcc1.Core_MAP_PAR__c=mapRec.id;
            try{
            insert MapAcc1;
            System.assert(MapAcc1 <> null, 'Record not created');
            }
            catch(exception e){} 
        Test.stopTest();
        
    }
    
    
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Void Method
    Version     : 1.0 
    Created Date: 03 Nov 2015
    Description:  Common Test data used in multiple test methods
    Scenario Type:  
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        11/04/2015                Created
    ****************************************************************************************************/
    public static TestMethod void getFAEsbyMap(){

    // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
    // Create Users
        ListOfUser = TestUtilities.getListOfUser(1);
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
    // Profile Query
        Profile SalesRepBbProfile = [select Id, name from Profile where name = 'Sales Rep-BB'];
    // Create User
        List<User> ListOfUsr = TestUtilities.getListOfUser(1);
        for(User Usr : ListOfUsr){
            Usr.UserName = 'getFAEsByProject@intel.com';
            Usr.ProfileID = SalesRepBbProfile.id;
        }
        insert ListOfUsr;
        System.debug('user test'+ListOfUsr);
        System.Assert(ListOfUsr[0].Id != null, 'Record not created');
        
    // Custom Setting - Ips Lables        
        List<Core_IPS_Labels__c> ListofIpsLables = TestUtilities.getIPSLabel();
        System.runAs(ListOfUser[0]){
            insert ListofIpsLables;
        }
        System.Assert(ListofIpsLables[0].Id != null, 'Records not created');
    // Create Accounts
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        System.runAs(Listofuser[0]){
        insert ListOfAccounts;
        }        
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        for(Account Acc : ListOfAccounts){
            Acc.Ownerid = ListOfUsr.get(0).id;
        }
        System.runAs(Listofuser[0]){
        update ListOfAccounts;
        }
        System.assertEquals(ListOfAccounts[0].Ownerid, ListOfUsr.get(0).id);
        
    // Create accountshare records
        List<AccountShare> ListOfAccountShare = [select UserOrGroupId,rowcause,CaseAccessLevel,AccountId from AccountShare where AccountId =:ListOfAccounts ];
        System.debug('set 4'+ListOfAccountShare);
        User ProflName = [select id, profile.name from user where id =: ListOfAccountShare[0].userOrGroupId];
        system.debug('prfl0'+ProflName);
        for(AccountShare Share : ListOfAccountShare){
            Share.CaseAccessLevel = 'Edit';
        }       
    // inserting products
        ProductList = TestUtilities.getListOfProduct(3);
         System.runAs(Listofuser[0]){
        insert ProductList;
        }
        System.assert(ProductList <> null, 'Record not created');        
    // inserting product org
        prodOrg = TestUtilities.getSupportOrg();
        System.runAs(Listofuser[0]){
        insert prodOrg;}
        System.assert(prodOrg <> null, 'Record not created');
        
    // inserting Supported Product 
        SuppProductList = TestUtilities.getListOfSupportedProduct(3);       
        Integer i = 0;
        for(Core_IPS_Supported_Product__c SupportedProductRecord: SuppProductList){                
                SupportedProductRecord.Core_Product__c = ProductList.get(i).id;
                SupportedProductRecord.Core_Product_Organization__c = prodOrg.id;
                 i++;                     
            // SuppProductList.add(SupportedProductRecord);
        }
        System.runAs(Listofuser[0]){
        insert SuppProductList;}
        System.assert(SuppProductList <> null, 'Record not created');        
    // inserting Product Access Header
        Core_IPS_MAP_PAR__c parRec = TestUtilities.getMapPar();
        parRec.Core_Product_Organization__c = prodOrg.id;
        parRec.RecordTypeId  = schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId(); //'012210000004IHZ';
        System.runAs(Listofuser[0]){
        insert parRec;}
        System.assert(parRec <> null, 'Record not created');
        // inserting Prodcut Access Product-PAR
        List<Core_IPS_MAP_Product__c> prodJuncPARList= new List<Core_IPS_MAP_Product__c>();
        for(i=0;i<1;i++){
            Core_IPS_MAP_Product__c mapProdPAR = new Core_IPS_MAP_Product__c();
            mapProdPAR.Core_MAP_PAR__c = parRec.id;
            mapProdPAR.Core_MAP_Supported_Product__c = SuppProductList[i].id;
            prodJuncPARList.add(mapProdPAR);
        }
        System.runAs(Listofuser[0]){
        insert prodJuncPARList;}
        System.assert(prodJuncPARList <> null, 'Record not created'); 
        // inserting Prodcut Access Accounts-PAR
        List<Core_IPS_MAP_Account__c> accJuncPARList = new List<Core_IPS_MAP_Account__c>();
        Core_IPS_MAP_Account__c accJuncPAR = new Core_IPS_MAP_Account__c();
        for(i=0;i<1;i++){
            // Core_IPS_MAP_Account__c accJuncPAR = new Core_IPS_MAP_Account__c();
            accJuncPAR.Core_Account__c=ListOfAccounts[0].id;
            accJuncPAR.Core_MAP_PAR__c=parRec.id;
            accJuncPARList.add(accJuncPAR);
        }
        System.runAs(Listofuser[0]){ 
        update ListOfAccountShare;
        insert accJuncPARList;
        }
        System.assertEquals(ListOfAccountShare[0].CaseAccessLevel, 'Edit');
        System.assert(accJuncPARList <> null, 'Record not created');
        
        Set<Id> AccountSet =  new Set<Id>();
        for(Core_IPS_MAP_Account__c Acc: accJuncPARList){
            AccountSet.add(Acc.Core_Account__c);
        }
        System.runAs(Listofuser[0]){
        Map<Id,Set<Id>> AccountsByMap = Core_IPS_MAPAccount_Handler.getAccountsByMap(accJuncPARList);
        Map<Id,Set<Id>> faesByAccount = Core_IPS_Helper_Utility.getFAEsByAccount(AccountSet);
            
        Test.startTest();
            Map<Id,Set<Id>> FAEsbyMAP = Core_IPS_MAPAccount_Handler.getFAEsbyMAP(AccountsByMap,faesByAccount);
            System.assert(!(FAEsbyMAP.isempty()), 'FAEsbyMAP method does not return the records');
        Test.stopTest();
        
        }
    
    }
}