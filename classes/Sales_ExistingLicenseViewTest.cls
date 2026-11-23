/*********************************************************************************************************************
Class Name    : Sales_ExistingLicenseViewTest
Version       : 1.0
Created Date  : March 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma          4-April-2021             Test class for Controller class of License View Component. 
* *********************************************************************************************************************/
@isTest
public with sharing class Sales_ExistingLicenseViewTest {    
    public static Account createDiffPSGDownstreamAccounts(String CoreAccountType, String Acctype){
        Account acc = new Account();
        acc.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);  
        acc.Core_PSG_Account__c=true;   
        acc.Name = 'AccName - '+String.valueof((Math.random() * 1000));
        acc.Core_Account_Type__c = CoreAccountType;
        acc.Industry = 'Education';
        acc.Core_Sub_Industry__c = 'Student';
        acc.BillingCity = 'New york';
        acc.BillingState='ME';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = 'New U';
        acc.BillingPostalCode='04685';
        acc.Type = Acctype;
        acc.Core_Sales_Groups__c = 'PRC Sales Group';       
        insert acc;
        return acc;
    }
    public static SBQQ__ProductOption__c createoption(Id configSKUProdId, Id optionalSKUProdId){
        SBQQ__ProductOption__c prodoption = new SBQQ__ProductOption__c();
        prodoption.SBQQ__Number__c = 5;
        prodoption.SBQQ__ConfiguredSKU__c = configSKUProdId;
        prodoption.SBQQ__OptionalSKU__c = optionalSKUProdId ;
        prodoption.SBQQ__Bundled__c = true;
        prodoption.SBQQ__Type__c ='Accessory';
        insert prodoption;
        return prodoption;
    }
    @testSetup static void testData(){
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        List<Sales_License_Generator__c> licGenerator = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> liceneGroupRec= Sales_TestFactory_Utility.createLiceneseGroup(licGenerator[0].Id);
        Core_Product_Ext_Attribute__c l = new Core_Product_Ext_Attribute__c();
        l.Core_SW_Lic_Enforcement_Method_Nm__c = 'File';
        l.Core_Prod_Tool_Type_Nm__c = 'BASE';
        l.Core_SW_Lic_Type_Nm__c = 'FIXED' ; 
        l.Core_SW_Prod_Max_Rehost_Cnt__c = 1;
        l.Core_SW_Lic_File_Data_Encryption_Std_Cd__c = '1DES' ;
        l.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c = true;
        l.Core_SW_Lic_Group_Id__c = liceneGroupRec[0].Id;
        l.Core_SW_Lic_Generator_Parameter_Txt__c = 'testing';
        insert l;
        Contact c = new Contact();
        c.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        c.FirstName = 'FirstName';
        c.LastName = 'LastName';
        c.Email = 'FirstName@intel.com';
        c.AccountId = accObj.Id;
        c.Core_Primary_Contact__c = true;
        c.MailingCountry = 'India';
        insert c;
        List<Product2> prodList = new List<Product2>();
        Product2 p1 =new Product2();
        p1.Name = ' Test Product ';
        p1.Description='Test Product Entry 1';
        p1.productCode = 'ABC';
        p1.isActive = true;
        p1.Core_Item_Class_Nm__c='SV';
        p1.Core_Item_Orderable_Ind__c=true;
        p1.Core_Product_Ext_Attribute_Id__c = l.Id;
        prodList.add(p1);
        Product2 p2 =new Product2();
        p2.Name = ' Test Product 2';
        p2.Description='Test Product Entry 2';
        p2.productCode = 'ABC2';
        p2.isActive = true;
        p2.Core_Item_Class_Nm__c='SV2';
        p2.Core_Product_Ext_Attribute_Id__c = l.Id;
        prodList.add(p2);
        insert prodList;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookentry =Sales_TestFactory_Utility.createPriceBookEntry(p1.Id,pricebookId);
        List<SBQQ__ProductOption__c> prodOptionList = new List<SBQQ__ProductOption__c>();
        SBQQ__ProductOption__c prodOption1 = new SBQQ__ProductOption__c();
        prodOption1.SBQQ__Type__c='Related Product';
        prodOption1.SBQQ__ConfiguredSKU__c = p1.Id;
        prodOption1.SBQQ__Number__c=1;
        prodOption1.SBQQ__Bundled__c=true;
        prodOption1.SBQQ__OptionalSKU__c=p2.Id;
        prodOptionList.add(prodOption1);
        SBQQ__ProductOption__c prodOption2 = new SBQQ__ProductOption__c();
        prodOption2.SBQQ__Type__c='Component';
        prodOption2.SBQQ__ConfiguredSKU__c = p1.Id;
        prodOption2.SBQQ__Number__c=1;
        prodOption2.SBQQ__Bundled__c=true;
        prodOption1.SBQQ__OptionalSKU__c=p2.Id;
        prodOptionList.add(prodOption2);
        insert prodOptionList;
        insert new PRM_Execution_Controls__c(SetupOwnerId=UserInfo.getOrganizationId(), Skip_ValidationRule_Order_Status__c=true);
        Account accObjIntelSold = new Account();
        accObjIntelSold.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);  
        accObjIntelSold.Name = 'SoldToAcc'+Integer.valueOf(Math.random()*1000);
        accObjIntelSold.Core_Account_Type__c = 'Distributor';
        accObjIntelSold.Industry = 'Education';
        accObjIntelSold.Core_Sub_Industry__c = 'Student';
        accObjIntelSold.BillingCity = 'HOLLINWOOD CITY ';
        accObjIntelSold.BillingState='ENG';
        accObjIntelSold.BillingCountry = 'GBR';
        accObjIntelSold.BillingStreet = '4039  Dye Street ABCD';
        accObjIntelSold.BillingPostalCode='ABCS SY13 6ZF';
        accObjIntelSold.Type='Distributor';
        accObjIntelSold.Core_Sales_Groups__c = 'APJ Partner Holding'; 
        Account accObjIntelShip = new Account();
        accObjIntelShip.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);  
        accObjIntelShip.Name = 'ShiptoAcc'+Integer.valueOf(Math.random()*1000);
        accObjIntelShip.Core_Account_Type__c = 'Academia & research institutions';
        accObjIntelShip.Industry = 'Education';
        accObjIntelShip.Core_Sub_Industry__c = 'Student';
        accObjIntelShip.BillingCity = 'Phra Nakhon City';
        accObjIntelShip.BillingState='18';
        accObjIntelShip.BillingCountry = 'THA';
        accObjIntelShip.BillingStreet = '7699  Sarah Drive Street';
        accObjIntelShip.BillingPostalCode='10200';
        accObjIntelShip.Type='EMS';
        accObjIntelShip.Core_Sales_Groups__c = 'APJ Partner Holding';
        List<Account> intelAccountList = new List<Account>();
        intelAccountList.add(accObjIntelSold);
        intelAccountList.add(accObjIntelShip);
        insert intelAccountList;
        List<Account> testAccountList = new List<Account>();
        Account ac2 = new Account();
        ac2.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
        ac2.Name = 'CREATESoldtoAcc'+Integer.valueOf(Math.random()*1000);
        ac2.ParentId = intelAccountList[0].id;
        ac2.Core_Direct_Account_Active_Ind__c=true;
        ac2.Core_Account_Type__c = 'Distributor';
        ac2.BillingCity = 'Billing City Test Nasr Billing City CD';
        ac2.BillingState = 'MT';
        ac2.BillingCountry = 'EGY';
        ac2.BillingStreet = 'CYASt. No. 16, Free ZoneXYZ '; 
        ac2.Core_Direct_Account_Type_Nm__c='Sold To';
        ac2.Type='End User';
        ac2.Core_Direct_Payment_Term_Nm__c = 'U';
        ac2.Core_PSG_Account__c=true;
        ac2.Core_Sales_Groups__c = 'PRC Sales Group';    
        ac2.Core_Direct_Sales_Organization_Nm__c='AM03';
        ac2.Core_Direct_Distributor_Channel_Nm__c='04';
        ac2.Core_Geo__c='ASMO';
        testAccountList.add(ac2);
        Account ac3 = new Account();
        ac3.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
        ac3.Name = 'ShiptoAcc2'+Integer.valueOf(Math.random()*1000);
        ac3.ParentId = intelAccountList[1].Id;
        ac3.Core_Direct_Account_Active_Ind__c=true;
        ac3.Core_Account_Type__c = 'Distributor';
        ac3.BillingCity = 'Delhi';
        ac3.BillingCountry = 'IND';
        ac3.BillingStreet = '178 , Ground Floor'; 
        ac3.BillingPostalCode='400003';
        ac3.BillingState='DL';
        ac3.Core_Direct_Account_Type_Nm__c='Ship To';
        ac3.Core_Direct_Shipping_Condition_Nm__c = '1Q';
        ac3.Core_Direct_Shipping_Instruction_Txt__c	 = 'Shipping';
        ac3.Core_Direct_Incoterm_Dsc__c = 'CIF';
        ac3.Type='End User';
        ac3.Core_PSG_Account__c=true;
        ac3.Core_Sales_Groups__c = 'PRC Sales Group';       
        testAccountList.add(ac3);
        insert testAccountList;
        Sales_TestFactory_Utility.accountsoldToshipTo(testAccountList[0].Id,testAccountList[1].Id);
        Order orderRec = new Order();
        orderRec.Type= 'Licensed Tool Order';
        orderRec.Name = 'Test Order ';
        orderRec.Status = 'Draft';
        orderRec.Sales_status__c = 'Draft Order';  
        orderRec.EffectiveDate = system.today();
        orderRec.EndDate = system.today() + 4;
        orderRec.AccountId = intelAccountList[0].id;
        orderRec.Sales_Order_Reason__c='Stocking Order';
        orderRec.Pricebook2Id =  pricebookId ;  
        orderRec.Sales_PO_Number_Txt__c = '687900077999898';
        orderRec.Sales_Header_Special_Instructions_Dsc__c = 'abc';
        orderRec.Sales_Sold_To_Account__c=testAccountList[0].Id;
        orderRec.Sales_Ship_To_Account__c = testAccountList[1].Id;
        orderRec.Sales_Shipping_Condition_Txt__c = '1Q';
        orderRec.Sales_Incoterms_Txt__c = 'DAT';
        orderRec.Sales_Shipping_Instructions_Dsc__c = 'xyz';
        orderRec.Sales_Payment_Terms__c = 'KB';
        orderRec.Sales_Req_Ship_Date_Dt__c = system.today() + 2;
        orderRec.Sales_SoldTo_Street_Dsc__c = '3695  Green Avenue';
        orderRec.Sales_SoldTo_City_Txt__c = 'Oakland';
        orderRec.Sales_SoldTo_State_Txt__c = 'California';
        orderRec.Sales_SoldTo_Province_Txt__c = 'CA';
        orderRec.Sales_SoldTo_Zip_Txt__c = '94621';
        orderRec.Sales_SoldTo_Country_Txt__c = 'United States';
        orderRec.Sales_ShipTo_Street_Dsc__c = '1893  Orchard Street';
        orderRec.Sales_ShipTo_City_Txt__c = 'RODNEY';
        orderRec.Sales_ShipTo_State_Txt__c = 'Michigan';
        orderRec.Sales_ShipTo_Province_Txt__c = 'MI';
        orderRec.Sales_ShipTo_Zip_Txt__c = '49342';
        orderRec.Sales_ShipTo_Country_Txt__c = 'United States';
        insert orderRec;
        Test.startTest();
        List<OrderItem> orderProduct =Sales_TestFactory_Utility.createOrderProductList(orderRec.Id,p1.Id,pricebookentry.Id);
        List<Sales_License__c> licList = new List<Sales_License__c>();
        Sales_License__c licRecord = new Sales_License__c();
        licRecord.Sales_License_Order_Product__c = orderProduct[0].Id;
        licRecord.Sales_License_Order__c = orderRec.Id;
        licRecord.Sales_License_Product__c = p1.Id;
        licRecord.Sales_License_Status__c = 'Licensed';
        licRecord.Sales_License_Avbl_Qty_Nbr__c = 2;
        licList.add(licRecord);
        Sales_License__c licRecordNeg = new Sales_License__c();
        licRecordNeg.Sales_License_Order_Product__c = orderProduct[0].Id;
        licRecordNeg.Sales_License_Order__c = orderRec.Id;
        licRecordNeg.Sales_License_Product__c = p1.Id;
        licRecordNeg.Sales_License_Status__c = 'Licensed';
        licRecordNeg.Sales_License_Avbl_Qty_Nbr__c = -2;
        licList.add(licRecordNeg);
        insert licList;
        List<Contract> conList = new List<Contract>();
        Contract con = new Contract(); 
        con.AccountId = accObj.Id;
        con.StartDate = System.today();
        con.ContractTerm = 1; 
        con.Status = 'Draft';
        con.SBQQ__Order__c=orderRec.id;
        conList.add(con);
        insert conList;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity o = new Opportunity();
        o.Accountid = accObj.Id;
        o.Name = 'test';
        o.StageName = 'Qualify';
        o.CloseDate = date.today();
        o.Type = 'New Client';
        o.NextStep = 'Test';
        o.LeadSource = 'Business Development';
        oppList.add(o);
        insert oppList;
        Test.stopTest();
    }
    @isTest
    public static void getLicenseListFoundationProductTest(){
        Test.startTest();
        Set<Id> tempFoundIdSet=new Set<Id>();
        Sales_License_Generator__c licGen = [Select Id from Sales_License_Generator__c limit 1];  
        Sales_License_Group__c lcGrp = [Select Id from Sales_License_Group__c limit 1];
        Product2 p = [Select Id,Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c from Product2 where Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c = 'BASE' Limit 1];
        Contact c = [Select Id from Contact where FirstName = 'FirstName' Limit 1];
        Core_Product_Ext_Attribute__c extAttribute = new Core_Product_Ext_Attribute__c();
        extAttribute.Core_SW_Lic_Enforcement_Method_Nm__c = 'File';
        extAttribute.Core_Prod_Tool_Type_Nm__c = 'Base';
        extAttribute.Core_Foundation_Product_Id__c=p.Id;
        extAttribute.Core_SW_Lic_Type_Nm__c = 'FIXED' ; 
        extAttribute.Core_SW_Prod_Max_Rehost_Cnt__c = 1;
        extAttribute.Core_SW_Prod_Web_Dsc__c='Test';
        extAttribute.Core_SW_Lic_File_Data_Encryption_Std_Cd__c = '1DES' ;
        extAttribute.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c = true;
        extAttribute.Core_SW_Lic_Group_Id__c = lcGrp.Id;
        extAttribute.Core_SW_Lic_Generator_Parameter_Txt__c = 'testing';
        insert extAttribute;
        Product2 prd =new Product2();
        prd.Name = 'Test Foundation Product';
        prd.Description='Test Foundation Product Entry 2';
        prd.productCode = 'ABC2878';
        prd.isActive = true;
        prd.Core_Item_Orderable_Ind__c = true;
        prd.Core_Item_Class_Nm__c='SV';
        prd.Core_Product_Ext_Attribute_Id__c = extAttribute.Id;
        insert prd;
        SBQQ__ProductOption__c prodoption = new SBQQ__ProductOption__c();
        prodoption.SBQQ__Number__c = 5;
        prodoption.SBQQ__ConfiguredSKU__c = p.Id;
        prodoption.SBQQ__OptionalSKU__c = prd.Id ;
        prodoption.SBQQ__Bundled__c = true;
        prodoption.SBQQ__Type__c ='Accessory';
        insert prodoption;
        List<id> CurrentRecId=new List<id>();
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookentry =Sales_TestFactory_Utility.createPriceBookEntry(prd.Id,pricebookId);
        Order ord = [Select Id from Order Limit 1];
        OrderItem oi = new OrderItem();
        oi.OrderId = ord.Id;
        oi.Quantity = 2;
        oi.UnitPrice = 240;
        oi.Product2id = prd.Id;
        oi.Sales_Contact__c = c.id;
        oi.PricebookEntryId=PricebookEntry.Id;
        insert oi;
        Id contact=oi.Sales_Contact__c;
        Sales_License__c lcRecord = new Sales_License__c();
        lcRecord.Sales_License_Order_Product__c = oi.Id;
        lcRecord.Sales_License_Order__c = ord.Id;
        lcRecord.Sales_License_Product__c = prd.Id;
        lcRecord.Sales_License_Status__c = 'Licensed';
        lcRecord.Sales_License_Avbl_Qty_Nbr__c = 2;
        lcRecord.Sales_License_Primary_Admin_Contact__c=c.id;
        lcRecord.Sales_License_Lic_User_Contact_ID__c=contact;
        lcRecord.Sales_License_Type__c='Original';
        lcRecord.Sales_Parent_License__c=null;
        lcRecord.Sales_License_Expiration_Date_Dt__c=System.today()+10;
        insert lcRecord;
        Sales_ExistingLicenseViewCtrl.getLicenseListForAdmin(oi.Id);
        prodoption.SBQQ__ConfiguredSKU__c=prd.Id;
        update prodoption;
        tempFoundIdSet.add(prodoption.SBQQ__ConfiguredSKU__c);
        Sales_ExistingLicenseViewCtrl.getLicenseListForAdmin(oi.Id);
        Test.stopTest();
    }
    @isTest
    public static void getLicenseListForAdminTest(){
        String orderItemId = [Select Id from OrderItem Limit 1].Id;
        String orderId = [Select Id from Order Limit 1].Id;
        String conId = [Select Id,SBQQ__Order__c from Contract Limit 1].Id;
        String sl=[Select Id from Sales_License__c Limit 1].id;
        String key = ' where Sales_License__r.Sales_License_Lic_User_Contact_ID__c=:conId';
        Test.startTest();
        List<id> CurrentRecId=new List<id>();
        CurrentRecId.add(sl);
        Sales_ExistingLicenseViewCtrl.getLicenseListForAdmin(orderItemId);
        Sales_ExistingLicenseViewCtrl.getLicenseListForAdmin(orderId);
        Contract con = [Select Id,SBQQ__Order__c from Contract Limit 1];
        Sales_ExistingLicenseViewCtrl.getLicenseListForAdmin(conId);
        Test.stopTest();
    }
    @isTest
    public static void getcheckLicenseListForAdminTest(){
        Test.startTest();
        Product2 p = [Select Id from Product2 where Core_Item_Class_Nm__c = 'SV' Limit 1];
        OrderItem oi=[Select Id,Sales_Contact__c from OrderItem Limit 1];
        Order orderId = [Select Id from Order Limit 1];
        Sales_License__c sl=[Select Id from Sales_License__c Limit 1];
        Contract c = [Select id from Contract Limit 1];
        Sales_License__c licRecord = new Sales_License__c();
        licRecord.Sales_License_Order_Product__c = oi.Id;
        licRecord.Sales_License_Order__c = orderId.Id;
        licRecord.Sales_License_Product__c = p.Id;
        licRecord.Sales_Parent_License__c = sl.Id;
        licRecord.Sales_License_Status__c = 'Licensed';
        licRecord.Sales_License_Avbl_Qty_Nbr__c = 2;
        licRecord.Sales_License_Maintenance_Exp_Dt__c = System.today()+10;
        insert licRecord;      
        Sales_License_Order_Product__c licOrdProd = new Sales_License_Order_Product__c();
        licOrdProd.Sales_License__c = licRecord.Id;
        licOrdProd.Sales_License_ContractId__c = c.Id;
        licOrdProd.Sales_Order_Product__c = oi.Id;
        licOrdProd.Sales_License_Expiration_Date_Dt__c = System.Today()+10;
        licOrdProd.Sales_Quantity__c = 1;
        insert licOrdProd;
        Sales_License_Order_Product__c slop=[Select Id,Sales_License__r.Sales_Parent_License__c from Sales_License_Order_Product__c where Id=:licOrdProd.Id Limit 1];
        slop.Sales_License__r.Sales_Parent_License__c=licOrdProd.Id;
        update slop;
        Id con = [Select Id from Contact where FirstName='FirstName' limit 1].Id;
        oi.Sales_Contact__c=con;
        update oi;
        List<id> CurrentRecId=new List<id>();
        Sales_ExistingLicenseViewCtrl.getLicenseListForAdmin(oi.Id);
        licRecord.Sales_License_Type__c='Original';
        licRecord.Sales_Parent_License__c=null;
        licRecord.Sales_License_Primary_Admin_Contact__c=con;
        update licRecord;
        Sales_ExistingLicenseViewCtrl.getLicenseListForAdmin(oi.Id);
        Test.stopTest();
    }
    @isTest
    public static void getExistingLicenseListTestNonCpr(){
        String orderItemId = [Select Id from OrderItem Limit 1].Id;
        Sales_ExistingLicenseViewCtrl.licenseWrapperClass licWrapper = new Sales_ExistingLicenseViewCtrl.licenseWrapperClass();
        Test.startTest();
        licWrapper = Sales_ExistingLicenseViewCtrl.getExistingLicenseList(orderItemId,'Original');
        Test.stopTest();
        System.assertEquals(0, licWrapper.licenseList.size());
    }
    @isTest
    public static void getOptionProductsTest(){
        String prodId = [Select Id from Product2 Limit 1].Id;
        String orderItemId = [Select Id from OrderItem Limit 1].Id;
        String licId = [Select Id from Sales_License__c where Sales_License_Avbl_Qty_Nbr__c>0 Limit 1].Id;
        Sales_ExistingLicenseViewCtrl.licenseWrapperClass licWrapper = new Sales_ExistingLicenseViewCtrl.licenseWrapperClass();
        Test.startTest();
        licWrapper = Sales_ExistingLicenseViewCtrl.getOptionProducts(licId,prodId,orderItemId,'FLOAT');
        Sales_ExistingLicenseViewCtrl.getOptionProducts(licId,prodId,'','FLOAT');
        Test.stopTest();
        System.assertEquals(1,licWrapper.productOptionReturnList.size());
    }
    @isTest
    public static void createOptionLicenseTest(){
        List<Id> optionProductIdList = new List<Id>();
        String prodId = [Select Id from Product2 Limit 1].Id;
        String licId = [Select Id from Sales_License__c where Sales_License_Avbl_Qty_Nbr__c>0 Limit 1].Id;
        String orderItemId = [Select Id from OrderItem Limit 1].Id;
        String renewalLicId =[Select Id from Sales_License__c Limit 1].Id;
        Sales_ExistingLicenseViewCtrl.licenseWrapperClass licWrapper = new Sales_ExistingLicenseViewCtrl.licenseWrapperClass();
        Test.startTest();
        licWrapper = Sales_ExistingLicenseViewCtrl.getOptionProducts(licId,prodId,orderItemId,'FLOAT');
        for(SBQQ__ProductOption__c prodOption:licWrapper.productOptionReturnList){
            optionProductIdList.add(prodOption.Id);
        }
        Sales_ExistingLicenseViewCtrl.createOptionLicense(licId,optionProductIdList,renewalLicId);
        Test.stopTest();
    }
    @isTest
    public static void processDistributionActionTest(){
        List<Sales_License__c> licRecordList = [Select Id,Sales_License_Avbl_Qty_Nbr__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Status__c,Sales_License_Contract__c,Sales_License_Expiration_Date_Dt__c,Sales_License_Quantity__c from Sales_License__c];
        String orderItemId = [Select Id from OrderItem Limit 1].Id;
        Test.startTest();
        Sales_ExistingLicenseViewCtrl.processDistributionAction(2,orderItemId,licRecordList,licRecordList[0].Id);
        Test.stopTest();
    }
    @isTest
    public static void processDistributionActionTestNegQuantity(){
        List<Sales_License__c> licRecordList = [Select Id,Sales_License_Avbl_Qty_Nbr__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Status__c,Sales_License_Contract__c,Sales_License_Expiration_Date_Dt__c,Sales_License_Quantity__c from Sales_License__c where Sales_License_Avbl_Qty_Nbr__c<0];
        String orderItemId = [Select Id from OrderItem Limit 1].Id;
        Test.startTest();
        Sales_ExistingLicenseViewCtrl.processDistributionAction(2,orderItemId,licRecordList,licRecordList[0].Id);
        Test.stopTest();
    }
    @isTest
    public static void createLicensedForRenewalFixedTest(){
        List<Sales_License__c> licRecordList = [Select Id,Sales_License_Avbl_Qty_Nbr__c,Sales_License_Status__c,Sales_License_Contract__c,Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Quantity__c from Sales_License__c];
        Id orderItemId = [Select Id from OrderItem Limit 1].Id;
        Test.startTest();
        Test.stopTest();
    }
}