@isTest
public class Core_Product_Access_Line_Item_Test {
    
    
    
    public static TestMethod void testDuplicateAssetPrev(){
        
        Account acc = TestUtilities.getAccountRecord();
        insert acc;

        Product2 prod = TestUtilities.getProduct();
        insert prod;
        
        Core_IPS_Product_Organization__c prodOrg = TestUtilities.getSupportOrg();
        insert prodOrg;
        
        Core_IPS_Supported_Product__c supProd = TestUtilities.getSupportedProduct();
        supProd.Core_Product__c = prod.id;
        supProd.Core_Product_Organization__c = prodOrg.id;
        insert supProd;
        
        List<Asset> lstAssets = new List<Asset>();
        Asset asst = TestUtilities.getAsset();
        asst.AccountId = acc.id;
        asst.Product2Id = prod.id;
        asst.Core_Supported_Product__c = supProd.id;
        asst.Core_Product_Organization__c = prodOrg.id;
        insert Asst;
        
        Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = prodOrg.id;
        mapRec.Recordtypeid  =  schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
        insert mapRec;
        
        Core_IPS_Map_Par_Line_Item__c lItem = new Core_IPS_Map_Par_Line_Item__c();
        lItem.Core_MAP_PAR__c = mapRec.id;
        lItem.Core_Account__c = acc.id;
        lItem.Core_Supported_Product__c = supProd.id;
        litem.Core_Approval_Type__c = 'Auto Approve';
        
        Test.startTest();
        //Inserting Line Item for after Insert
        insert lItem;
        Core_Asset_Dispatcher.Assetfieldupdated = false;
        //Updating Line Item for afer Update
        update lItem;
        //Retrieving the Line Item
        List<Core_IPS_Map_Par_Line_Item__c > newLItem = [Select id,Core_Status__c from Core_IPS_Map_Par_Line_Item__c where id =:lItem.id];
        //update newLItem ;
        //Testing that the trigger set the status to Active
        System.AssertEquals(newLItem[0].Core_Status__c,'ACTIVE', 'Status is active');
        Test.stopTest();
        
    }
    public static TestMethod void testDuplicateobsolateAssetprev(){
        
        Account acc = TestUtilities.getAccountRecord();
        insert acc;

        Product2 prod = TestUtilities.getProduct();
        insert prod;
        
        Core_IPS_Product_Organization__c prodOrg = TestUtilities.getSupportOrg();
        insert prodOrg;
        
        Core_IPS_Supported_Product__c supProd = TestUtilities.getSupportedProduct();
        supProd.Core_Product__c = prod.id;
        supProd.Core_Product_Organization__c = prodOrg.id;
        insert supProd;
        
        Asset obsoleteasst = TestUtilities.getAsset();
        obsoleteasst.AccountId = acc.id;
        obsoleteasst.Product2Id = prod.id;
        obsoleteasst.Core_Supported_Product__c = supProd.id;
        obsoleteasst.Core_Product_Organization__c = prodOrg.id;
        obsoleteasst.Status='Inactive';
        insert obsoleteasst;
        
        Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = prodOrg.id;
        mapRec.Recordtypeid  =  schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
        insert mapRec;
        
        Core_IPS_Map_Par_Line_Item__c lItem = new Core_IPS_Map_Par_Line_Item__c();
        lItem.Core_MAP_PAR__c = mapRec.id;
        lItem.Core_Account__c = acc.id;
        /*lItem.Core_Product__c = prod.id;*/
        lItem.Core_Supported_Product__c = supProd.id;
        litem.Core_Approval_Type__c = 'Auto Approve';
        
        Test.startTest();
        //Inserting Line Item for after Insert
        insert lItem;
        Core_Asset_Dispatcher.Assetfieldupdated = false;
        //Updating Line Item for afer Update
        update lItem;
        //Retrieving the Line Item
        List<Core_IPS_Map_Par_Line_Item__c > newLItem = [Select id,Core_Status__c from Core_IPS_Map_Par_Line_Item__c where id =:lItem.id];
        //update newLItem ;
        //Testing that the trigger set the status to Active
        System.AssertEquals(newLItem[0].Core_Status__c,'ACTIVE', 'Status is Active');
        Test.stopTest();
        
    }
    
    public static TestMethod void submittingPARforApproval(){
        
        Account acc = TestUtilities.getAccountRecord();
        insert acc;

        Product2 prod = TestUtilities.getProduct();
        insert prod;
        
        Core_IPS_Product_Organization__c prodOrg = TestUtilities.getSupportOrg();
        insert prodOrg;
        
        Core_IPS_Supported_Product__c supProd = TestUtilities.getSupportedProduct();
        supProd.Core_Product__c = prod.id;
        supProd.Core_Product_Organization__c = prodOrg.id;
        insert supProd;
        
        Asset asst = TestUtilities.getAsset();
        asst.AccountId = acc.id;
        asst.Product2Id = prod.id;
        asst.Core_Supported_Product__c = supProd.id;
        asst.Core_Product_Organization__c = prodOrg.id;
        insert asst;
        
        Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = prodOrg.id;
        mapRec.Recordtypeid  =  schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId(); //'012210000004IHY';
        insert mapRec;
        
        Core_IPS_Map_Par_Line_Item__c lItem = new Core_IPS_Map_Par_Line_Item__c();
        lItem.Core_MAP_PAR__c = mapRec.id;
        lItem.Core_Account__c = acc.id;
        /*lItem.Core_Product__c = prod.id;*/
        lItem.Core_isPARRequest__c=true;
        lItem.Core_Supported_Product__c = supProd.id;
        lItem.Core_Status__c = 'PENDING';
        litem.Core_Approval_Type__c = 'Approval Required';
        litem.Recordtypeid  =  schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId(); //'012210000004IHY';
        Test.startTest();
        
        //Inserting Line Item for after Insert
        insert lItem;
        //Updating Line Item for afer Update
        //Retrieving the Line Item
        List<Core_IPS_Map_Par_Line_Item__c > newLItem = [Select id,Core_Status__c from Core_IPS_Map_Par_Line_Item__c where id =:lItem.id];
        //Testing that the trigger set the status to Active
        System.AssertEquals(newLItem[0].Core_Status__c,'PENDING', 'Status is PENDING');
        Test.stopTest();
        
    }
    
    public static TestMethod void assetInsertlItemInsert(){
        
        // inserting Accounts
        List<Account> accountList =  new List<Account>();
        accountList = TestUtilities.getAccountsList(2);
        insert accountList;
        System.assert(accountList <> null, 'Record not created');

        // inserting products
        List<Product2> productList = new List<Product2>();
        productList = TestUtilities.getListOfProduct(3);
        insert productList;
        System.assert(productList <> null, 'Record not created');
        
        // inserting Product Orgs
        List<Core_IPS_Product_Organization__c> prodOrgList = new List<Core_IPS_Product_Organization__c>();
        prodOrgList = TestUtilities.getListOfSupportOrg(3);
        insert prodOrgList;
        
        // inserting Supported Product 
        List<Core_IPS_Supported_Product__c> suppProductList = new List<Core_IPS_Supported_Product__c> ();
        suppProductList = TestUtilities.getListOfSupportedProduct(3);
        Integer i = 0;
        for(Core_IPS_Supported_Product__c supportedProductRecord: suppProductList){                
                supportedProductRecord.Core_Product__c = productList.get(i).id;
                supportedProductRecord.Core_Product_Organization__c = prodOrgList.get(i).id;
                 i++;                     
        }
        insert suppProductList;
        System.assert(suppProductList <> null, 'Record not created');
        
        // // inserting asset 1
        // Asset asst = TestUtilities.getAsset();
        // asst.AccountId = accountList[0].id;
        // asst.Product2Id = productList[0].id;
        // asst.Core_Supported_Product__c = suppProductList[0].id;
        // asst.Core_Product_Organization__c = prodOrgList[0].id;
        // insert asst;
        
        // inserting asset 2
        Asset asst1 = TestUtilities.getAsset();
        asst1.AccountId = accountList[1].id;
        asst1.Product2Id = productList[1].id;
        asst1.Core_Supported_Product__c = suppProductList[1].id;
        asst1.Core_Product_Organization__c = prodOrgList[1].id;
        insert asst1;
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = prodOrgList[0].id;
        mapRec.RecordTypeId  =  schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
        insert mapRec;
        System.assert(mapRec <> null, 'Record not created');
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c parRec = TestUtilities.getMapPar();
        parRec.Core_Product_Organization__c = prodOrgList[0].id;
        parRec.RecordTypeId  =  schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId(); //'012210000004IHZ';
        insert parRec;
        System.assert(parRec <> null, 'Record not created');

        
        
        // inserting Prodcut Acces Line Item- MAP
        Core_IPS_Map_Par_Line_Item__c lItem = new Core_IPS_Map_Par_Line_Item__c();
        lItem.Core_MAP_PAR__c = mapRec.id;
        lItem.Core_Account__c = accountList[0].id;
        // lItem.Core_isPARRequest__c=true;
        lItem.Core_Supported_Product__c = suppProductList[0].id;
        lItem.RecordTypeId= schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IKA';
        insert lItem;
         Core_Asset_Dispatcher.Assetfieldupdated = false;
        //Updating Line Item for afer Update
        update lItem;
        
        
        // inserting Prodcut Acces Line Item- PAR
        Core_IPS_Map_Par_Line_Item__c lItemPAR = new Core_IPS_Map_Par_Line_Item__c();
        lItemPAR.Core_MAP_PAR__c = parRec.id;
        lItemPAR.RecordTypeId= schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId();
        lItemPAR.Core_Account__c = accountList[0].id;
        lItemPAR.Core_isPARRequest__c= false;
        lItemPAR.Core_Supported_Product__c = suppProductList[0].id;
        lItemPAR.Core_Approval_Type__c = 'Approval Required';
        insert lItemPAR;
        
        // inserting Prodcut Acces Line Item- PAR auto approve
        Core_IPS_Map_Par_Line_Item__c lItemPARAA = new Core_IPS_Map_Par_Line_Item__c();
        lItemPARAA.Core_MAP_PAR__c = parRec.id;
        lItemPARAA.Core_Account__c = accountList[0].id;
        lItemPARAA.Core_isPARRequest__c= true;
        lItemPARAA.Core_Supported_Product__c = suppProductList[0].id;
        lItemPARAA.Core_Approval_Type__c = 'Auto Approve';
        insert lItemPARAA;
        
        
        
    }

    public static TestMethod void assetInsertlItemUpdate(){
        
        // inserting Accounts
        List<Account> accountList =  new List<Account>();
        accountList = TestUtilities.getAccountsList(2);
        insert accountList;
        System.assert(accountList <> null, 'Record not created');

        // inserting products
        List<Product2> productList = new List<Product2>();
        productList = TestUtilities.getListOfProduct(3);
        insert productList;
        System.assert(productList <> null, 'Record not created');
        
        // inserting Product Orgs
        List<Core_IPS_Product_Organization__c> prodOrgList = new List<Core_IPS_Product_Organization__c>();
        prodOrgList = TestUtilities.getListOfSupportOrg(3);
        insert prodOrgList;
        
        // inserting Supported Product 
        List<Core_IPS_Supported_Product__c> suppProductList = new List<Core_IPS_Supported_Product__c> ();
        suppProductList = TestUtilities.getListOfSupportedProduct(3);
        Integer i = 0;
        for(Core_IPS_Supported_Product__c supportedProductRecord: suppProductList){                
                supportedProductRecord.Core_Product__c = productList.get(i).id;
                supportedProductRecord.Core_Product_Organization__c = prodOrgList.get(i).id;
                 i++;                     
        }
        insert suppProductList;
        System.assert(suppProductList <> null, 'Record not created');
        
        // // inserting asset 1
        // Asset asst = TestUtilities.getAsset();
        // asst.AccountId = accountList[0].id;
        // asst.Product2Id = productList[0].id;
        // asst.Core_Supported_Product__c = suppProductList[0].id;
        // asst.Core_Product_Organization__c = prodOrgList[0].id;
        // insert asst;
        
        // inserting asset 2
        Asset asst1 = TestUtilities.getAsset();
        asst1.AccountId = accountList[1].id;
        asst1.Product2Id = productList[1].id;
        asst1.Core_Supported_Product__c = suppProductList[1].id;
        asst1.Core_Product_Organization__c = prodOrgList[1].id;
        insert asst1;
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = prodOrgList[0].id;
        mapRec.RecordTypeId  =  schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IHY';
        insert mapRec;
        System.assert(mapRec <> null, 'Record not created');
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c parRec = TestUtilities.getMapPar();
        parRec.Core_Product_Organization__c = prodOrgList[0].id;
        parRec.RecordTypeId  =  schema.sobjecttype.Core_IPS_MAP_PAR__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId(); //'012210000004IHZ';
        insert parRec;
        System.assert(parRec <> null, 'Record not created');

        
        
        // inserting Prodcut Acces Line Item- MAP
        Core_IPS_Map_Par_Line_Item__c lItem = new Core_IPS_Map_Par_Line_Item__c();
        lItem.Core_MAP_PAR__c = mapRec.id;
        lItem.Core_Account__c = accountList[0].id;
        // lItem.Core_isPARRequest__c=true;
        lItem.Core_Supported_Product__c = suppProductList[0].id;
        lItem.RecordTypeId= schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); //'012210000004IKA';
        insert lItem;
         Core_Asset_Dispatcher.Assetfieldupdated = false;
        //Updating Line Item for afer Update
        Core_IPS_Map_Par_Line_Item__c qUpdateNewLitem = [Select id,Core_Status__c from Core_IPS_Map_Par_Line_Item__c where id =:lItem.id];
        qUpdateNewLitem.Core_Status__c = 'INACTIVE';
        update qUpdateNewLitem;

        
        
        
    }
/***************************************************************************************************
Method Name:  assetInsertlItemInsertMigrationUser
Method Type: Test Method
Version     : 1.0 
Created Date: 2 Feb 2016
Description:  Testing Product Access Line Item with Migration User
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              02/02/2016                Created
****************************************************************************************************/
    public static TestMethod void assetInsertlItemInsertMigrationUser(){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('IPS Data Migration');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        List<User> listOfUser = new List<User> ();
        listOfUser = TestUtilities.getListOfUser(1);
        listOfUser.get(0).ProfileID =  profiles.get('IPS Data Migration');
        insert listOfUser;
        System.assertEquals(listOfUser.get(0).profileid, profiles.get('IPS Data Migration'), 'Profile is IPS Data Migration');
        System.runAs(listOfUser.get(0)){
            // inserting Accounts
            List<Account> accountList =  new List<Account>();
            accountList = TestUtilities.getAccountsList(2);
            insert accountList;
            System.assert(accountList <> null, 'Record not created');
            // inserting products
            List<Product2> productList = new List<Product2>();
            productList = TestUtilities.getListOfProduct(3);
            insert productList;
            System.assert(productList <> null, 'Record not created');
            // inserting Product Orgs
            List<Core_IPS_Product_Organization__c> prodOrgList = new List<Core_IPS_Product_Organization__c>();
            prodOrgList = TestUtilities.getListOfSupportOrg(3);
            insert prodOrgList;
            // inserting Supported Product 
            List<Core_IPS_Supported_Product__c> suppProductList = new List<Core_IPS_Supported_Product__c> ();
            suppProductList = TestUtilities.getListOfSupportedProduct(3);
            Integer i = 0;
            for(Core_IPS_Supported_Product__c supportedProductRecord: suppProductList){                
                supportedProductRecord.Core_Product__c = productList.get(i).id;
                supportedProductRecord.Core_Product_Organization__c = prodOrgList.get(i).id;
                i++;                     
            }
            insert suppProductList;
            System.assert(suppProductList <> null, 'Record not created');
            // // inserting asset 1
            Asset asst1 = TestUtilities.getAsset();
            asst1.AccountId = accountList[1].id;
            asst1.Product2Id = productList[1].id;
            asst1.Core_Supported_Product__c = suppProductList[1].id;
            asst1.Core_Product_Organization__c = prodOrgList[1].id;
            insert asst1;
            
            // inserting Product Access Header
            Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
            mapRec.Core_Product_Organization__c = prodOrgList[0].id;
            mapRec.RecordTypeId  = [select id,name,Sobjecttype  from recordtype where name = 'MAP' and SobjectType='Core_IPS_MAP_PAR__c'].id;
            insert mapRec;
            System.assert(mapRec <> null, 'Record not created');
            // inserting Product Access Header
            Core_IPS_MAP_PAR__c parRec = TestUtilities.getMapPar();
            parRec.Core_Product_Organization__c = prodOrgList[0].id;
            parRec.RecordTypeId  = [select id,name,Sobjecttype  from recordtype where name = 'PAR' and SobjectType='Core_IPS_MAP_PAR__c'].id;
            insert parRec;
            System.assert(parRec <> null, 'Record not created');
            // inserting Prodcut Acces Line Item- MAP
            Core_IPS_Map_Par_Line_Item__c lItem = new Core_IPS_Map_Par_Line_Item__c();
            lItem.Core_MAP_PAR__c = mapRec.id;
            lItem.Core_Account__c = accountList[0].id;
            // lItem.Core_isPARRequest__c=true;
            lItem.Core_Supported_Product__c = suppProductList[0].id;
            lItem.RecordTypeId= [select id,name,Sobjecttype  from recordtype where name = 'MAP' and SobjectType='Core_IPS_Map_Par_Line_Item__c'].id;
            insert lItem;
            Core_Asset_Dispatcher.Assetfieldupdated = false;
            //Updating Line Item for afer Update
            update lItem;
            // inserting Prodcut Acces Line Item- PAR
            Core_IPS_Map_Par_Line_Item__c lItemPAR = new Core_IPS_Map_Par_Line_Item__c();
            lItemPAR.Core_MAP_PAR__c = parRec.id;
            lItemPAR.RecordTypeId= schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId();
            lItemPAR.Core_Account__c = accountList[0].id;
            lItemPAR.Core_isPARRequest__c= false;
            lItemPAR.Core_Supported_Product__c = suppProductList[0].id;
            lItemPAR.Core_Approval_Type__c = 'Approval Required';
            insert lItemPAR;
            // inserting Prodcut Acces Line Item- PAR auto approve
            Core_IPS_Map_Par_Line_Item__c lItemPARAA = new Core_IPS_Map_Par_Line_Item__c();
            lItemPARAA.Core_MAP_PAR__c = parRec.id;
            lItemPARAA.Core_Account__c = accountList[0].id;
            lItemPARAA.Core_isPARRequest__c= true;
            lItemPARAA.Core_Supported_Product__c = suppProductList[0].id;
            lItemPARAA.Core_Approval_Type__c = 'Auto Approve';
            insert lItemPARAA;
        }   
    }
/***************************************************************************************************
Method Name:  assetInsertlItemInsertMigrationUserCoreEOIS
Method Type: Test Method
Version     : 1.0 
Created Date: 2 Feb 2016
Description:  Testing Product Access Line Item with Migration User
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              02/02/2016                Created
****************************************************************************************************/
    public static TestMethod void assetInsertlItemInsertMigrationUserCoreEOIS(){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('IPS Data Migration');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        List<User> listOfUser = new List<User> ();
        listOfUser = TestUtilities.getListOfUser(1);
        listOfUser.get(0).ProfileID =  profiles.get('IPS Data Migration');
        insert listOfUser;
        System.assertEquals(listOfUser.get(0).profileid, profiles.get('IPS Data Migration'), 'Profile is IPS Data Migration');
        System.runAs(listOfUser.get(0)){
            // inserting Accounts
            List<Account> accountList =  new List<Account>();
            accountList = TestUtilities.getAccountsList(2);
            insert accountList;
            System.assert(accountList <> null, 'Record not created');
            // inserting products
            List<Product2> productList = new List<Product2>();
            productList = TestUtilities.getListOfProduct(3);
            insert productList;
            System.assert(productList <> null, 'Record not created');
            // inserting Product Orgs
            List<Core_IPS_Product_Organization__c> prodOrgList = new List<Core_IPS_Product_Organization__c>();
            prodOrgList = TestUtilities.getListOfSupportOrg(3);
            insert prodOrgList;
            // inserting Supported Product 
            List<Core_IPS_Supported_Product__c> suppProductList = new List<Core_IPS_Supported_Product__c> ();
            suppProductList = TestUtilities.getListOfSupportedProduct(3);
            Integer i = 0;
            for(Core_IPS_Supported_Product__c supportedProductRecord: suppProductList){                
                supportedProductRecord.Core_Product__c = productList.get(i).id;
                supportedProductRecord.Core_Product_Organization__c = prodOrgList.get(i).id;
                //give false by rajeswari on July 13 for increase code coverage: FIELD_FILTER_VALIDATION_EXCEPTION at Core_MAP_Supported_Product__c    
                supportedProductRecord.Core_EOIS__c = false;
              
                i++;                     
            }
            insert suppProductList;
            System.assert(suppProductList <> null, 'Record not created');
            // // inserting asset 1
            // Asset asst = TestUtilities.getAsset();
            // asst.AccountId = accountList[0].id;
            // asst.Product2Id = productList[0].id;
            // asst.Core_Supported_Product__c = suppProductList[0].id;
            // asst.Core_Product_Organization__c = prodOrgList[0].id;
            // insert asst;
            // inserting asset 2
            Asset asst1 = TestUtilities.getAsset();
            asst1.AccountId = accountList[1].id;
            asst1.Product2Id = productList[1].id;
            asst1.Core_Supported_Product__c = suppProductList[1].id;
            asst1.Core_Product_Organization__c = prodOrgList[1].id;
            insert asst1;
            
            // inserting Product Access Header
            Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
            mapRec.Core_Product_Organization__c = prodOrgList[0].id;
            mapRec.RecordTypeId  = [select id,name,Sobjecttype  from recordtype where name = 'MAP' and SobjectType='Core_IPS_MAP_PAR__c'].id;
            insert mapRec;
            System.assert(mapRec <> null, 'Record not created');
            // inserting Product Access Header
            Core_IPS_MAP_PAR__c parRec = TestUtilities.getMapPar();
            parRec.Core_Product_Organization__c = prodOrgList[0].id;
            parRec.RecordTypeId  = [select id,name,Sobjecttype  from recordtype where name = 'PAR' and SobjectType='Core_IPS_MAP_PAR__c'].id;
            insert parRec;
            System.assert(parRec <> null, 'Record not created');
            // inserting Prodcut Acces Line Item- MAP
            Core_IPS_Map_Par_Line_Item__c lItem = new Core_IPS_Map_Par_Line_Item__c();
            lItem.Core_MAP_PAR__c = mapRec.id;
            lItem.Core_Account__c = accountList[0].id;
            // lItem.Core_isPARRequest__c=true;
            lItem.Core_Supported_Product__c = suppProductList[0].id;
            lItem.RecordTypeId= [select id,name,Sobjecttype  from recordtype where name = 'MAP' and SobjectType='Core_IPS_Map_Par_Line_Item__c'].id;
            insert lItem;
            Core_Asset_Dispatcher.Assetfieldupdated = false;
            //Updating Line Item for afer Update
            update lItem;
            // inserting Prodcut Acces Line Item- PAR
            Core_IPS_Map_Par_Line_Item__c lItemPAR = new Core_IPS_Map_Par_Line_Item__c();
            lItemPAR.Core_MAP_PAR__c = parRec.id;
            lItemPAR.RecordTypeId= schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId();
            lItemPAR.Core_Account__c = accountList[0].id;
            lItemPAR.Core_isPARRequest__c= false;
            lItemPAR.Core_Supported_Product__c = suppProductList[0].id;
            lItemPAR.Core_Approval_Type__c = 'Approval Required';
            insert lItemPAR;
            // inserting Prodcut Acces Line Item- PAR auto approve
            Core_IPS_Map_Par_Line_Item__c lItemPARAA = new Core_IPS_Map_Par_Line_Item__c();
            lItemPARAA.Core_MAP_PAR__c = parRec.id;
            lItemPARAA.Core_Account__c = accountList[0].id;
            lItemPARAA.Core_isPARRequest__c= true;
            lItemPARAA.Core_Supported_Product__c = suppProductList[0].id;
            lItemPARAA.Core_Approval_Type__c = 'Auto Approve';
            insert lItemPARAA;
        }   
    }
/***************************************************************************************************
Method Name:  SubmittingPARforApprovaldontAddFalse
Method Type: Test Method
Version     : 1.0 
Created Date: 2 Feb 2016
Description:  Testing Product Access Line Item - Submitting PAR for Approval and dont Add flag to False
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              02/02/2016                Created
****************************************************************************************************/
    public static TestMethod void submittingPARforApprovaldontAddFalse(){
        
            // inserting Accounts
            List<Account> accountList =  new List<Account>();
            accountList = TestUtilities.getAccountsList(2);
            insert accountList;
            System.assert(accountList <> null, 'Record not created');

        Product2 prod = TestUtilities.getProduct();
        insert prod;
        
        Core_IPS_Product_Organization__c prodOrg = TestUtilities.getSupportOrg();
        insert prodOrg;
        
        Core_IPS_Supported_Product__c supProd = TestUtilities.getSupportedProduct();
        supProd.Core_Product__c = prod.id;
        supProd.Core_Product_Organization__c = prodOrg.id;
        insert supProd;
        
        Asset asst = TestUtilities.getAsset();
        asst.AccountId = accountList.get(0).id;
        asst.Product2Id = prod.id;
        asst.Core_Supported_Product__c = supProd.id;
        asst.Core_Product_Organization__c = prodOrg.id;
        insert asst;
        
        Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = prodOrg.id;
        mapRec.Recordtypeid  = [select id,name,Sobjecttype  from recordtype where name = 'MAP' and SobjectType='Core_IPS_MAP_PAR__c'].id;
        insert mapRec;
        
        Core_IPS_Map_Par_Line_Item__c lItem = new Core_IPS_Map_Par_Line_Item__c();
        lItem.Core_MAP_PAR__c = mapRec.id;
        lItem.Core_Account__c = accountList.get(1).id;
        /*lItem.Core_Product__c = prod.id;*/
        lItem.Core_isPARRequest__c=true;
        lItem.Core_Supported_Product__c = supProd.id;
        litem.Core_Approval_Type__c = 'Approval Required';
        litem.RecordTypeId = [select id,name,Sobjecttype  from recordtype where name = 'PAR' and SobjectType='Core_IPS_Map_Par_Line_Item__c'].id;
        litem.Core_Status__c = 'PENDING';
      //012210000004IHZAA2
        
        Test.startTest();
        
        //Inserting Line Item for after Insert
        insert lItem;
        //Updating Line Item for afer Update
        //Retrieving the Line Item
        List<Core_IPS_Map_Par_Line_Item__c > newLItem = [Select id,Core_Status__c from Core_IPS_Map_Par_Line_Item__c where id =:lItem.id];
        //Testing that the trigger set the status to Active
        System.AssertEquals(newLItem[0].Core_Status__c,'PENDING', 'Status is PENDING');
        Test.stopTest();
        
    }
/***************************************************************************************************
Method Name:  assetInsertlItemUpdateActive
Method Type: Test Method
Version     : 1.0 
Created Date: 2 Feb 2016
Description:  Testing Product Access Line Item - asset insert Item update and product line item active
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Deepak Jetty              02/02/2016                Created
****************************************************************************************************/
    public static TestMethod void assetInsertlItemUpdateActive(){
        
        // inserting Accounts
        List<Account> accountList =  new List<Account>();
        accountList = TestUtilities.getAccountsList(2);
        insert accountList;
        System.assert(accountList <> null, 'Record not created');

        // inserting products
        List<Product2> productList = new List<Product2>();
        productList = TestUtilities.getListOfProduct(3);
        insert productList;
        System.assert(productList <> null, 'Record not created');
        
        // inserting Product Orgs
        List<Core_IPS_Product_Organization__c> prodOrgList = new List<Core_IPS_Product_Organization__c>();
        prodOrgList = TestUtilities.getListOfSupportOrg(3);
        insert prodOrgList;
        
        // inserting Supported Product 
        List<Core_IPS_Supported_Product__c> suppProductList = new List<Core_IPS_Supported_Product__c> ();
        suppProductList = TestUtilities.getListOfSupportedProduct(3);
        Integer i = 0;
        for(Core_IPS_Supported_Product__c supportedProductRecord: suppProductList){                
                supportedProductRecord.Core_Product__c = productList.get(i).id;
                supportedProductRecord.Core_Product_Organization__c = prodOrgList.get(i).id;
                 i++;                     
        }
        insert suppProductList;
        System.assert(suppProductList <> null, 'Record not created');
        // inserting asset 2
        Asset asst1 = TestUtilities.getAsset();
        asst1.AccountId = accountList[1].id;
        asst1.Product2Id = productList[1].id;
        asst1.Core_Supported_Product__c = suppProductList[1].id;
        asst1.Core_Product_Organization__c = prodOrgList[1].id;
        insert asst1;
        
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c mapRec = TestUtilities.getMapPar();
        mapRec.Core_Product_Organization__c = prodOrgList[0].id;
        mapRec.RecordTypeId  = [select id,name,Sobjecttype  from recordtype where name = 'MAP' and SobjectType='Core_IPS_MAP_PAR__c'].id;
        insert mapRec;
        System.assert(mapRec <> null, 'Record not created');
        // inserting Product Access Header
        Core_IPS_MAP_PAR__c parRec = TestUtilities.getMapPar();
        parRec.Core_Product_Organization__c = prodOrgList[0].id;
        parRec.RecordTypeId  = [select id,name,Sobjecttype  from recordtype where name = 'PAR' and SobjectType='Core_IPS_MAP_PAR__c'].id;
        insert parRec;
        System.assert(parRec <> null, 'Record not created');
        // inserting Prodcut Acces Line Item- MAP
        Core_IPS_Map_Par_Line_Item__c lItem = new Core_IPS_Map_Par_Line_Item__c();
        lItem.Core_MAP_PAR__c = mapRec.id;
        lItem.Core_Account__c = accountList[0].id;
        // lItem.Core_isPARRequest__c=true;
        lItem.Core_Status__c = 'PENDING';
        lItem.Core_Supported_Product__c = suppProductList[0].id;
        litem.Core_Approval_Type__c = 'Approval Required';
        //litem.Core_isPARRequest__c = false;
        //lItem.RecordTypeId= [select id,name,Sobjecttype  from recordtype where name = 'MAP' and SobjectType='Core_IPS_Map_Par_Line_Item__c'].id;
        litem.RecordTypeId= schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
        Test.startTest();
        insert lItem;
        System.assert(lItem <> null, 'Record not created');
         Core_Asset_Dispatcher.Assetfieldupdated = false;
        //Updating Line Item for afer Update
        Core_IPS_Map_Par_Line_Item__c qUpdateNewLitem = [Select id,Core_Status__c,Core_isPARRequest__c,Core_Supported_Product__c from Core_IPS_Map_Par_Line_Item__c where id =:lItem.id];
        qUpdateNewLitem.Core_Supported_Product__c = suppProductList[2].id;
        qUpdateNewLitem.Core_isPARRequest__c = false;
        qUpdateNewLitem.Core_Status__c = 'ACTIVE';
        update qUpdateNewLitem;
        System.assert(qUpdateNewLitem.Core_Status__c == 'ACTIVE', 'Record not updated');
        Test.stopTest();
    }
    
}