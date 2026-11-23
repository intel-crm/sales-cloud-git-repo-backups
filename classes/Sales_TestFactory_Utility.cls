/*********************************************************************************************************************
Class Name    : Sales_TestFactory_Utility
Version       : 1.0
Created Date  : Jan 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Jasmine Narula           11-Jan-2021              Test Setup data to be used for test classes 
* *********************************************************************************************************************/
@isTest
public without sharing class Sales_TestFactory_Utility {
/*
    Public static PermissionSet permissionRec;
    public static Map<String, Account> intelAccMap = new Map<String, Account>();
    Static{
    }
    public static Account createAccount(){
        Account acc = new Account();
        acc.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);  
        acc.Name = 'TstAccIntel'+Integer.valueOf(Math.random()*1000);
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = 'Education';
        acc.Core_Sub_Industry__c = 'Student';
        acc.BillingCity = 'Swans Island City ';
        acc.BillingState='ME';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = '1234  Victoria Court ABCHE';
        acc.BillingPostalCode='04685';
        acc.Type='Distributor';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        acc.Core_IPA_Partner_Role__c='FPGA Designer';
        acc.Core_Sales_Groups__c = 'PRC Sales Group';       
        insert acc;
        return acc;
    }
    public static Account createDifferentAccounts(String AccName, String BillingCity, String Street, String CoreAccountType, String Acctype){
        Account acc = new Account();
        acc.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);  
        acc.Name = AccName;
        acc.Core_Account_Type__c = CoreAccountType;
        acc.Industry = 'Education';
        acc.Core_Sub_Industry__c = 'Student';
        acc.BillingCity = BillingCity;
        acc.BillingState='ME';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = Street;
        acc.BillingPostalCode='04685';
        acc.Type = Acctype;
        acc.Core_Sales_Groups__c = 'PRC Sales Group';       
        insert acc;
        return acc;
    }
    public static Account createIntelSoldAccount(){
        Account acc2 = new Account();
        acc2.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);  
        acc2.Name = 'SoldToAcc'+Integer.valueOf(Math.random()*1000);
        acc2.Core_Account_Type__c = 'Distributor';
        acc2.Industry = 'Education';
        acc2.Core_Sub_Industry__c = 'Student';
        acc2.BillingCity = 'HOLLINWOOD CITY ';
        acc2.BillingState='ENG';
        acc2.BillingCountry = 'GBR';
        acc2.BillingStreet = '4039  Dye Street ABCD';
        acc2.BillingPostalCode='ABCS SY13 6ZF';
        acc2.Type='Distributor';
        acc2.Core_Sales_Groups__c = 'PRC Sales Group';       
        intelAccMap.put('IntelSoldAccount', acc2);
        return acc2;
    }   
    public static Account createIntelShipAccount(){
        Account acc3 = new Account();
        acc3.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);  
        acc3.Name = 'ShiptoAcc'+Integer.valueOf(Math.random()*1000);
        acc3.Core_Account_Type__c = 'Academia & research institutions';
        acc3.Industry = 'Education';
        acc3.Core_Sub_Industry__c = 'Student';
        acc3.BillingCity = 'Phra Nakhon City';
        acc3.BillingState='18';
        acc3.BillingCountry = 'THA';
        acc3.BillingStreet = '7699  Sarah Drive Street';
        acc3.BillingPostalCode='10200';
        acc3.Type='EMS';
        acc3.Core_Sales_Groups__c = 'PRC Sales Group'; 
        intelAccMap.put('IntelShipAccount', acc3);      
        return acc3;
    }    
    public static Account createEndCustAccount(){
        Account ac = new Account();
        ac.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);      
        ac.Name = 'EndCusAcc'+Integer.valueOf(Math.random()*1000);
        ac.Core_Account_Type__c = 'End User';
        ac.Industry = 'Banking';
        ac.BillingCity = 'Texas';
        ac.BillingCountry = 'USA';
        ac.BillingStreet = 'G-210createSoldToAccount'; 
        ac.Type='End User';
        ac.Core_PSG_Account__c=true; 
        ac.Core_Sales_Groups__c = 'PRC Sales Group';       
        insert ac;
        return ac;
    }
    public static User createUserWithProfile1() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name='IT Admin'];
        String uniqueUserName = 'userNameIntial' + String.valueof((Integer)(Math.random()*100)) + '@intel.com';
        UserRole admin = [SELECT Id from UserRole where Name = 'Admin' limit 1];
        User user = new User(FirstName='test',LastName='test Last', ProfileId = profileId.Id , Email=uniqueUserName,
                             LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',LanguageLocaleKey='en_US',
                             Alias= (String.valueOf(datetime.now()).substring(0,8)), UserRoleId = admin.Id,
                             UserName=uniqueUserName, EmailEncodingKey='UTF-8'	);
        return user;
    }
    public static Account createEndCustAccount1(){
        Account ac1 = new Account();
        ac1.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);      
        ac1.Name = 'EndCusAcc'+Integer.valueOf(Math.random()*1000);
        ac1.Core_Account_Type__c = 'End User';
        ac1.Industry = 'Banking';
        ac1.BillingCity = 'Texas';
        ac1.BillingCountry = 'USA';
        ac1.BillingStreet = 'G-210createSoldToAccount'; 
        ac1.Type='End User';
        ac1.Core_PSG_Account__c=true; 
        ac1.Core_Sales_Groups__c = 'PRC Sales Group'; 
        ac1.Core_Partner_Alliance_Program__c='PSG Demand Creation - PSG';
        insert ac1;
        Account ac = new Account();
        Account parentAcc = new Account();
        parentAcc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
        parentAcc.Name = 'EndCusAcc'+Integer.valueOf(Math.random()*1000);
        parentAcc.Core_Direct_Account_Type_Nm__c='End Customer Parent';
        parentAcc.Core_Is_Pricing_Parent_ChkBox__c = true; 
        parentAcc.Core_Direct_Account_Active_Ind__c =true;
        parentAcc.Core_PSG_Account__c=true; 
        parentAcc.Type='End User';
        parentAcc.ParentId=ac1.id;
        parentAcc.Core_Partner_Alliance_Program__c='PSG Demand Creation - PSG';
        insert parentAcc;
        ac.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);      
        ac.Name = 'EndCusAcc'+Integer.valueOf(Math.random()*1000);
        ac.Core_Direct_Pricing_Parent_Id__c = parentAcc.id;    
        ac.Core_Account_Type__c = 'End Customer';     
        ac.Industry = 'Government';
        ac.Core_Sub_Industry__c = 'Economic Programs and Services';
        ac.BillingCity = 'Texas';
        ac.BillingCountry = 'USA';
        ac.BillingStreet = 'G-210createSoldToAccount'; 
        ac.Type='End User';
        ac.Core_PSG_Account__c=true; 
        ac.Core_Sales_Groups__c = 'PRC Sales Group';       
        insert ac;
        return ac;
    }
    public static Account createSoldToAccount(){        
        Account ac2 = new Account();
        ac2.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
        ac2.Name = 'CREATESoldtoAcc'+Integer.valueOf(Math.random()*1000);
        ac2.ParentId = intelAccMap?.get('IntelSoldAccount')?.id;
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
        ac2.Core_Direct_Distributor_Channel_Nm__c='01';
        ac2.Core_Geo__c='ASMO';
        return ac2;
    }
    public static Account createShipToAccount(){
        Account ac3 = new Account();
        ac3.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
        ac3.Name = 'ShiptoAcc2'+Integer.valueOf(Math.random()*1000);
        ac3.ParentId = intelAccMap?.get('IntelShipAccount')?.id;
        ac3.Core_Direct_Account_Active_Ind__c=true;
        ac3.Core_Account_Type__c = 'Distributor';
        ac3.BillingCity = 'Delhi';
        ac3.BillingCountry = 'IND';
        ac3.BillingStreet = '178 , Ground Floor'; 
        ac3.BillingPostalCode='400003';
        ac3.BillingState='DL';
        ac3.Core_Direct_Account_Type_Nm__c='Ship To';
        ac3.Core_Direct_Shipping_Condition_Nm__c = '1Q';
        ac3.Core_Direct_Incoterm_Dsc__c = 'CIF';
        ac3.Type='End User';
        ac3.Core_PSG_Account__c=true;
        ac3.Core_Sales_Groups__c = 'PRC Sales Group'; 
        return ac3;
    }
    public static Account createEndCustomerAccount(){
        Account accObj = createEndCustAccount();
        Account ac4 = new Account();
        ac4.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
        ac4.Name = 'EndCusA'+Integer.valueOf(Math.random()*1000);
        ac4.ParentId = accObj.Id;
        ac4.Core_Account_Type__c = 'Distributor';
        ac4.BillingPostalCode='440009';
        ac4.BillingState='DL';
        ac4.BillingCity = 'Delhi';
        ac4.BillingCountry = 'IND';
        ac4.BillingStreet = '7678  Rebecca Street'; 
        ac4.Core_Direct_Account_Type_Nm__c='End Customer';
        ac4.Type='End User';
        ac4.Core_PSG_Account__c=true;
        ac4.Core_Sales_Groups__c = 'PRC Sales Group';       
        insert ac4;
        return ac4;
    }
    public static Contact createContact(Id accId){
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = 'FirstName'+Integer.valueOf(Math.random()*1000);
        con.LastName = 'LastName';
        con.Email = 'FirstName'+Integer.valueOf(Math.random()*1000)+'@intel.com';
        con.AccountId = accId;
        con.Core_Primary_Contact__c = true;
        con.MailingCountry='India';
        insert con;
        return con;
    }
    public static PriceBook2 createPriceBook(String name){
        PriceBook2 p = new PriceBook2(
            name = 'name',
            isActive=true
        );
        insert p;
        return p;
    }
    public static List<Sales_License_Generator__c> createLiceneseGenerator(){
        List<Sales_License_Generator__c> licenseGen = new List<Sales_License_Generator__c>();
        Sales_License_Generator__c lGen = new  Sales_License_Generator__c();
        lGen.Name='Gen1';
        lGen.Sales_License_Vendor__c='Mentor Graphics';
        lGen.Sales_License_Generator_txt__c='genlic';
        lGen.Sales_License_Feature_Lyn_Syntx_txt__c='Gen';
        licenseGen.add(lGen);
        insert licenseGen;
        return licenseGen;
    }
    public static List<Sales_License_Group__c> createLiceneseGroup(Id gen){
        List<Sales_License_Group__c> licenseGroupList=new List<Sales_License_Group__c>();
        Sales_License_Group__c licGroup= new Sales_License_Group__c();
        licGroup.Name = 'Partner'+String.valueOf(Integer.valueOf(Math.random()*100));  
        licGroup.Sales_License_Generator__c=gen;
        licGroup.Sales_License_Parameter_txt__c='test'+String.valueOf(Integer.valueOf(Math.random()*100));			
        licGroup.Sales_License_Description_dsc__c='test'+String.valueOf(Integer.valueOf(Math.random()*100));			
        licenseGroupList.add(licGroup);
        insert licenseGroupList;
        return licenseGroupList;
    }
    public static Core_Product_Ext_Attribute__c createProductExtAttribute(String toolType, Id lcGroupid){
        Core_Product_Ext_Attribute__c l1 = new Core_Product_Ext_Attribute__c();
        l1.Core_SW_Lic_Enforcement_Method_Nm__c = 'File';
        l1.Core_Prod_Tool_Type_Nm__c = toolType;
        l1.Core_SW_Lic_Type_Nm__c = 'FIXED' ; 
        l1.Core_SW_Prod_Max_Rehost_Cnt__c = 1;
        l1.Core_SW_Prod_Web_Dsc__c='Test';
        l1.Core_SW_Lic_File_Data_Encryption_Std_Cd__c = '1DES' ;
        l1.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c = true;
        l1.Core_SW_Lic_Group_Id__c = lcGroupid;
        l1.Core_SW_Lic_Generator_Parameter_Txt__c = 'testing';
        l1.Core_SW_Prod_Expiration_Duration_Nbr__c = 45;
        insert l1;
        return l1;
    }
    public static Product2 createDifferentProducts(Id licenseId, String classVal, String pName){
        Product2 p1 = new Product2();
        p1.Name = ' Test '+pName+ ' Product';
        p1.Description='Test Product Entry 1';
        p1.productCode = 'ABC';
        p1.isActive = true;
        p1.Core_Item_Orderable_Ind__c=true;
        p1.Core_Item_Quotable_Ind__c=true;
        p1.Core_Sales_Visible_Flag__c = true;
        p1.SBQQ__SubscriptionTerm__c = 12;
        p1.Core_Item_Class_Nm__c=classVal;
        p1.Core_Item_Sub_Component_Category_Nm__c='A';
        p1.Core_Product_Ext_Attribute_Id__c=licenseId;
        insert p1;
        return p1;
    }
    public static Product2 createProductWithDifferentLicenseType(String licenceType,String devkitId){
        Core_Product_Ext_Attribute__c cp= new Core_Product_Ext_Attribute__c();
        cp.Core_SW_Lic_Enforcement_Method_Nm__c = 'File';
        cp.Core_Prod_Tool_Type_Nm__c ='BASE';
        cp.Core_SW_Lic_Type_Nm__c =licenceType;
        cp.Core_SW_Prod_Max_Rehost_Cnt__c = 88;
        cp.Core_SW_Lic_Generator_Parameter_Txt__c = 'hd';
        cp.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c = true;
        cp.Core_SW_Lic_File_Data_Encryption_Std_Cd__c = '1DES';
        cp.Core_SW_Lic_Renewal_Period_Nbr__c = 20;
        List<Sales_License_Generator__c> licGenList = createLiceneseGenerator();
        List<Sales_License_Group__c> licenseGroupList=createLiceneseGroup(licGenList[0].id);
        cp.Core_SW_Lic_Group_Id__c = licenseGroupList[0].Id;
        insert cp;
        Product2 p1 = new Product2();
        p1.Name = ' Test Product ';
        p1.Description='Test Product Entry 1';
        p1.Core_OPN__c='TESTFLOAT';
        p1.productCode = 'ABC';
        p1.isActive = true;
        p1.Core_Product_Ext_Attribute_Id__c  = cp.Id;
        p1.Core_Item_Class_Nm__c = devkitId;
        p1.Core_Item_Orderable_Ind__c = true;
        insert p1;
        return p1;
    }
    public static PricebookEntry createPriceBookEntry(Id prodId, Id priceBookId){
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = priceBookId;
        standardPrice.Product2Id = prodId;
        standardPrice.UnitPrice = 10000;
        standardPrice.price_disty_cost__c=18900;
        standardPrice.IsActive = true;
        insert standardPrice;
        return standardPrice;
    }
    public static Order createOrders(Id accId, Id pricebookId, String OrderType){
        List<Account> accList = new List<Account>();
        Account intelSoldto = Sales_TestFactory_Utility.createIntelSoldAccount();
        Account intelShipAcc = Sales_TestFactory_Utility.createIntelShipAccount();
        accList.add(intelSoldto);
        accList.add(intelShipAcc);
        insert accList;             
        List<Account> accList2 = new List<Account>();
        accList2.add(Sales_TestFactory_Utility.createSoldToAccount());
        accList2.add(Sales_TestFactory_Utility.createShipToAccount());
        insert accList2; 
        List<Core_Account_SoldTo_ShipTo_Rel__c> relation_Ship_Sold =  accountsoldToshipTo(accList2[0].Id, accList2[1].Id);
        Account accSoldTo = accList2[0];
        Order o = new Order();
        o.Type= OrderType;
        o.Name = 'Test Order ';
        o.Status = 'Draft';
        o.Sales_status__c = 'Draft Order';  
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 4;
        o.AccountId = accSoldTo.ParentId;
        o.Sales_Order_Reason__c='Stocking Order';
        o.Pricebook2Id =  pricebookId ;  
        o.Sales_PO_Number_Txt__c = '68790007'+String.valueof((Integer)(Math.random() * 1000000000));
        o.Sales_Header_Special_Instructions_Dsc__c = 'abc';
        Account accShipTo = accList2[1]; 
        o.Sales_Sold_To_Account__c=accSoldTo.Id;
        o.Sales_Ship_To_Account__c = accShipTo.Id;
        o.Sales_Shipping_Condition_Txt__c = '1Q';
        o.Sales_Incoterms_Txt__c = 'DAT';
        o.Sales_Payment_Terms__c = 'KB';
        o.Sales_Req_Ship_Date_Dt__c = system.today() + 5;
        o.Sales_SoldTo_Street_Dsc__c = '3695  Green Avenue';
        o.Sales_SoldTo_City_Txt__c = 'Oakland';
        o.Sales_SoldTo_State_Txt__c = 'California';
        o.Sales_SoldTo_Province_Txt__c = 'CA';
        o.Sales_SoldTo_Zip_Txt__c = '94621';
        o.Sales_SoldTo_Country_Txt__c = 'United States';
        o.Sales_ShipTo_Street_Dsc__c = '1893  Orchard Street';
        o.Sales_ShipTo_City_Txt__c = 'RODNEY';
        o.Sales_ShipTo_State_Txt__c = 'Michigan';
        o.Sales_ShipTo_Province_Txt__c = 'MI';
        o.Sales_ShipTo_Zip_Txt__c = '49342';
        o.Sales_ShipTo_Country_Txt__c = 'United States';
        insert o;  
        return o;
    } 
    public static List<Order> createListofOrders(Id accId, Id pricebookId, String OrderType){
        List<Order> ordList = new List<Order>();
        List<Account> accList = new List<Account>();
        Account intelSoldto = Sales_TestFactory_Utility.createIntelSoldAccount();
        Account intelShipAcc = Sales_TestFactory_Utility.createIntelShipAccount();
        accList.add(intelSoldto);
        accList.add(intelShipAcc);
        insert accList;             
        List<Account> accList2 = new List<Account>();
        accList2.add(Sales_TestFactory_Utility.createSoldToAccount());
        accList2.add(Sales_TestFactory_Utility.createShipToAccount());
        insert accList2; 
        List<Core_Account_SoldTo_ShipTo_Rel__c> relation_Ship_Sold =  accountsoldToshipTo(accList2[0].Id, accList2[1].Id);
        Account accSoldTo = accList2[0]; 
        Order o = new Order();
        o.Type= OrderType;
        o.Name = 'Test Order ';
        o.Status = 'Draft';
        o.Sales_status__c = 'Draft Order';  
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 4;
        o.AccountId = accSoldTo.ParentId;
        o.Sales_Order_Reason__c='Non Stocking Order';
        o.Pricebook2Id =  pricebookId ;  
        o.Sales_PO_Number_Txt__c = '687900077999898';
        o.Sales_Header_Special_Instructions_Dsc__c = 'abc';
        Account accShipTo = accList2[1];
        o.Sales_Sold_To_Account__c=accSoldTo.Id;
        o.Sales_Ship_To_Account__c = accShipTo.Id;
        o.Sales_Shipping_Condition_Txt__c = '1Q';
        o.Sales_Incoterms_Txt__c = 'FCA';
        o.Sales_Payment_Terms__c = 'KB';
        o.Sales_Req_Ship_Date_Dt__c = system.today() + 2;
        o.Sales_SoldTo_Street_Dsc__c = '3695  Green Avenue';
        o.Sales_SoldTo_City_Txt__c = 'Oakland';
        o.Sales_SoldTo_State_Txt__c = 'California';
        o.Sales_SoldTo_Province_Txt__c = 'CA';
        o.Sales_SoldTo_Zip_Txt__c = '94621';
        o.Sales_SoldTo_Country_Txt__c = 'United States';
        o.Sales_ShipTo_Street_Dsc__c = '1893  Orchard Street';
        o.Sales_ShipTo_City_Txt__c = 'RODNEY';
        o.Sales_ShipTo_State_Txt__c = 'Michigan';
        o.Sales_ShipTo_Province_Txt__c = 'MI';
        o.Sales_ShipTo_Zip_Txt__c = '49342';
        o.Sales_ShipTo_Country_Txt__c = 'United States';
        ordList.add(o);
        insert ordList;
        return ordList;
    } 
    public static Order createNonCommOrder(){
        List<Order> ordList = new List<Order>();
        List<Account> accList = new List<Account>();
        Account intelSoldto = Sales_TestFactory_Utility.createIntelSoldAccount();
        Account intelShipAcc = Sales_TestFactory_Utility.createIntelShipAccount();
        accList.add(intelSoldto);
        accList.add(intelShipAcc);
        insert accList;             
        List<Account> accList2 = new List<Account>();
        accList2.add(Sales_TestFactory_Utility.createSoldToAccount());
        accList2.add(Sales_TestFactory_Utility.createShipToAccount());
        insert accList2;
        List<Core_Account_SoldTo_ShipTo_Rel__c> relation_Ship_Sold =  accountsoldToshipTo(accList2[0].Id, accList2[1].Id);
        Account accSoldTo = accList2[0]; 
        Account accEndcust=Sales_TestFactory_Utility.createEndCustomerAccount();
        Order o = new Order();
        o.Type= 'Non Commercial Order';
        o.Name = 'Test Non Comm Order';
        o.Status = 'Draft';
        o.Sales_status__c = 'Draft Order';  
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 4;
        o.AccountId = accEndcust.ParentId;
        o.Sales_Order_Reason__c='Non Stocking Order';
        Id pricebookId = Test.getStandardPricebookId();
        o.Pricebook2Id =  pricebookId;  
        o.Sales_PO_Number_Txt__c = '687900077999898';
        o.Sales_Header_Special_Instructions_Dsc__c = 'abc';
        Account accShipTo = accList2[1];
        o.Sales_Sold_To_Account__c=accSoldTo.Id;
        o.Sales_Ship_To_Account__c = accShipTo.Id;
        o.Sales_Shipping_Condition_Txt__c = '1Q';
        o.Sales_Incoterms_Txt__c = 'FCA';
        o.Sales_Payment_Terms__c = 'KB';
        o.Sales_Req_Ship_Date_Dt__c = system.today() + 2;
        o.Sales_SoldTo_Street_Dsc__c = '3695  Green Avenue';
        o.Sales_SoldTo_City_Txt__c = 'Oakland';
        o.Sales_SoldTo_State_Txt__c = 'California';
        o.Sales_SoldTo_Province_Txt__c = 'CA';
        o.Sales_SoldTo_Zip_Txt__c = '94621';
        o.Sales_SoldTo_Country_Txt__c = 'United States';
        o.Sales_ShipTo_Street_Dsc__c = '1893  Orchard Street';
        o.Sales_ShipTo_City_Txt__c = 'RODNEY';
        o.Sales_ShipTo_State_Txt__c = 'Michigan';
        o.Sales_ShipTo_Province_Txt__c = 'MI';
        o.Sales_ShipTo_Zip_Txt__c = '49342';
        o.Sales_ShipTo_Country_Txt__c = 'United States';
        o.Sales_End_Customer_Account__c=accEndcust.Id;
        o.Sales_End_Customer_Street_Dsc__c='6689  Rebecca Street';
        o.Sales_End_Customer_City_Txt__c='New York';
        o.Sales_End_Customer_State_Txt__c='New York';
        o.Sales_End_Customer_Province_Txt__c='NY';
        o.Sales_End_Customer_Zip_Txt__c='142376';
        o.Sales_End_Customer_Country_Txt__c='USA';
        insert o;  
        return o;
    } 
    public static Order createOrderswithQUote(Id accId, Id pricebookId, Id qId){
        Account accSoldTo = Sales_TestFactory_Utility.createSoldToAccount();
        Account accShipTo = Sales_TestFactory_Utility.createShipToAccount();
        Order o = new Order();
        o.Sales_PO_Number_Txt__c = '687900077999898';
        o.Sales_Header_Special_Instructions_Dsc__c = 'abc';
        o.Sales_Ship_To_Account__c = accShipTo.Id;
        o.Name = 'Test Order ';
        o.Status = 'New';
        o.Sales_status__c = 'New';  
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 4;
        o.AccountId = accId;
        o.Sales_Sold_To_Account__c=accSoldTo.Id;
        o.Type='Licensed Tool Order';
        o.Sales_Order_Reason__c='Non Stocking Order';
        o.Pricebook2Id =  pricebookId ;  
        o.SBQQ__Quote__c=qId;
        insert o;  
        return o;
    }
    public static OrderItem createOrderProduct(Id ordId, Id prodId, Id pbEntryId){
        OrderItem i = new OrderItem();
        i.OrderId = ordId;
        i.Quantity = 24;
        i.UnitPrice = 240;
        i.Product2id = prodId;
        i.SBQQ__Status__c='Draft';
        i.PricebookEntryId=pbEntryId;
        insert i;
        return i;
    } 
    public static OrderItem createOrderProductAllFields(Id ordId, Id prodId, Id pbEntryId){
        OrderItem i = new OrderItem();
        i.OrderId = ordId;
        i.Quantity = 24;
        i.UnitPrice = 240;
        i.Product2id = prodId;
        i.PricebookEntryId=pbEntryId;
        i.SBQQ__Activated__c=true;
        i.SBQQ__Status__c='Draft';
        i.SBQQ__BillingFrequency__c='Monthly';
        i.SBQQ__BookingsIndicator__c='Include';
        i.Sales_Broken_Price_Amt__c=9;
        i.SBQQ__ChargeType__c='Usage';
        i.SBQQ__ContractAction__c='New';
        i.SBQQ__Contracted__c=true;
        i.SBQQ__ContractingMethod__c='Inherit';
        i.Sales_Customer_frght_collect_account__c='abc'; 
        insert i;
        return i;
    } 
    public static OrderItem updateOrderProduct(Id ordId, Id prodId, Id pbEntryId){
        OrderItem i = new OrderItem();
        i.OrderId = ordId;
        i.Quantity = 2;
        i.UnitPrice = 240;
        i.Product2id = prodId;
        i.PricebookEntryId=pbEntryId;
        insert i;
        i.Quantity = 4;
        update i;
        return i;
    } 
    public static List<Order> createOrderList(Id accId, Id pricebookId){
        Account accSoldTo = Sales_TestFactory_Utility.createSoldToAccount(); 
        List<Order> iList = new List<Order>();
        Order o = new Order();
        o.Name = 'Test Order ';
        o.Status = 'New';
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 4;
        o.AccountId = accId;
        o.Sales_Sold_To_Account__c = accSoldTo.id;
        o.Type='Licensed Tool Order';
        o.Sales_Order_Reason__c='Stocking Order';
        o.Pricebook2Id =  pricebookId ; 
        iList.add(o);
        insert iList; 
        return iList;
    } 
    public static List<OrderItem> createOrderProductList(Id ordId, Id prodId, Id pbEntryId){
        Order ord = [Select id,AccountId from order where id=:ordId];
        List<OrderItem> iList = new List<OrderItem>();
        OrderItem i = new OrderItem();
        i.OrderId = ordId;
        i.Quantity = 2;
        i.UnitPrice = 240;
        i.Product2id = prodId;
        i.PricebookEntryId=pbEntryId;
        Contact NewContact = createContact(ord.AccountId);
        i.Sales_Contact__c = NewContact.Id ;
        iList.add(i);
        insert iList;
        return iList;
    } 
    public static OrderItem createOrderProductWithQuoteline(Id ordId, Id prodId, Id pbEntryId,Id qline){
        OrderItem i = new OrderItem();
        i.OrderId = ordId;
        i.Quantity = 2;
        i.UnitPrice = 240;
        i.Product2id = prodId;
        i.PricebookEntryId=pbEntryId;
        i.SBQQ__QuoteLine__c = qline;
        insert i;
        return i;
    } 
    public static List<OrderItem> createOrderProductListWithQuoteline(Id ordId, Id prodId, Id pbEntryId,Id qline){
        List<OrderItem> iList = new List<OrderItem>();
        OrderItem i = new OrderItem();
        i.OrderId = ordId;
        i.Quantity = 2;
        i.UnitPrice = 240;
        i.Product2id = prodId;
        i.PricebookEntryId=pbEntryId;
        i.SBQQ__QuoteLine__c = qline;
        iList.add(i);
        insert iList;
        return iList;
    } 
    public static List<Contract> createContract(Id accId){
        List<Contract> conList = new List<Contract>();
        Contract con = new Contract(); 
        con.AccountId = accId;
        con.StartDate = System.today();
        con.ContractTerm = 1; 
        con.Status = 'Draft';
        conList.add(con);
        insert con;
        return conList;
    }
    public static Opportunity createOpportunity(Id accId){
        Opportunity o = new Opportunity();
        o.Accountid = accId;
        o.Name = 'test';
        o.StageName = 'Define';
        o.CloseDate = date.today();
        o.Type = 'New Client';
        o.NextStep = 'Test';
        o.LeadSource = 'Business Development';
        o.Pricebook2Id = Test.getStandardPricebookId();
        insert o;
        return o;
    }
    public static SBQQ__Quote__c createQuote(Id endCusId,Id oppId, Id pbId){
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.RecordTypeId= SBQQ__Quote__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PSG_Quote_New').getRecordTypeId();
        quote.core_cpq_active_cb__c = true;
        quote.SBQQ__Opportunity2__c = oppId;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__PriceBook__c = pbId;
        quote.core_cpq_quote_type_nm__c='Budgetary'; 
        quote.SBQQ__StartDate__c = date.today();
        quote.SBQQ__EndDate__c = date.today()+365;
        quote.SBQQ__SubscriptionTerm__c = 12;
        quote.SBQQ__Status__c = 'Approved';
        quote.SBQQ__Account__c=endCusId;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__ContractingMethod__c = 'Single Contract';
        insert quote;
        return quote;
    }
    public static SBQQ__QuoteLine__c createQuoteLine(Id quoteId, Id productId, Id pricebookEntryId){
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
        quoteLine.SBQQ__Product__c = productId;
        quoteLine.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
        quoteline.SBQQ__PricebookEntryId__c = pricebookEntryId;
        quoteLine.Pricing_Systems_qty__c = 10; 
        quoteline.SBQQ__Quantity__c = 10;
        quoteline.core_cpq_quote_line_type_txt__c = 'Qty Limited';
        quoteline.SBQQ__DefaultSubscriptionTerm__c= 12;
        quoteLine.Pricing_pm_approval_comments_nm__c = 'Test Comment';
        quoteLine.Pricing_CPUs_per_system_qty__c = 1;
        quoteLine.Pricing_Single_System_Price_Amt__c = 4;
        quoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
        quoteLine.Pricing_Req_Discounted_Unit_Price__c = 1;
        quoteLine.Pricing_Additional_OEM_Discount_Amt__c = 1;
        quoteLine.Pricing_Other_Competitor_Product_Nm__c = 'Test Tender Prod';
        quoteLine.Pricing_Market_Segment_Nm__c = 'Non Embedded';   
        quoteLine.SBQQ__Quote__c = quoteId;
        quoteLine.SBQQ__StartDate__c = date.today();
        quoteLine.SBQQ__EndDate__c = date.today()+365;
        quoteline.price_brokencost_amt__c = 67;
        quoteline.price_requested_resale_amt__c=55;
        quoteline.price_suggested_resale_amt__c=89;
        insert quoteLine;
        return quoteLine;
    }
    public static SBQQ__QuoteLine__c createNonCorpQuoteLine(Id quoteId, Id productId, Id pricebookEntryId){
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(); 
        quoteLine.SBQQ__Product__c = productId;
        quoteLine.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
        quoteline.SBQQ__PricebookEntryId__c = pricebookEntryId;
        quoteLine.Pricing_Systems_qty__c = 10; 
        quoteline.SBQQ__Quantity__c = 4;
        quoteline.core_cpq_quote_line_type_txt__c = 'AVP';
        quoteline.SBQQ__DefaultSubscriptionTerm__c= 12;
        quoteLine.Pricing_pm_approval_comments_nm__c = 'Test Comment';
        quoteLine.Pricing_CPUs_per_system_qty__c = 1;
        quoteLine.Pricing_Single_System_Price_Amt__c = 4;
        quoteLine.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
        quoteLine.Pricing_Req_Discounted_Unit_Price__c = 1;
        quoteLine.Pricing_Additional_OEM_Discount_Amt__c = 1;
        quoteLine.Pricing_Other_Competitor_Product_Nm__c = 'Test Tender Prod';
        quoteLine.Pricing_Market_Segment_Nm__c = 'Non Embedded';   
        quoteLine.SBQQ__Quote__c = quoteId;
        quoteline.price_brokencost_amt__c = 0;
        quoteline.price_requested_resale_amt__c=0;
        quoteline.price_suggested_resale_amt__c=0;
        insert quoteLine;
        return quoteLine;
    }
    public static List<Core_Product_Ext_Attribute__c> createLicense(Id grp){
        List<Core_Product_Ext_Attribute__c> extAttributeList = new List<Core_Product_Ext_Attribute__c>();
        Core_Product_Ext_Attribute__c l1 = new Core_Product_Ext_Attribute__c();
        l1.Core_Prod_Tool_Type_Nm__c='Base';
        l1.Core_SW_Lic_Type_Nm__c='FIXED';
        l1.Core_SW_Lic_Enforcement_Method_Nm__c='File';
        l1.Core_SW_Prod_Web_Dsc__c='Test';
        l1.Core_SW_Lic_Generator_Parameter_Txt__c   ='1';
        l1.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c=true;
        l1.Core_SW_Prod_Max_Rehost_Cnt__c=2;
        l1.Core_SW_Lic_File_Data_Encryption_Std_Cd__c='1DES';
        l1.Core_SW_Lic_Group_Id__c  = grp;
        extAttributeList.add(l1);
        insert extAttributeList;
        return extAttributeList;
    }
    public static Product2 createProductWithDEVKit(Id extAttribute){
        Product2 p = new Product2();
        p.Name = 'Test DEVKit Product';
        p.Core_Avail_for_New_Designs__c=true;
        p.Core_Item_Orderable_Ind__c=true;
        p.Core_Item_Quotable_Ind__c=true;
        p.IsActive=true;
        p.Description='Test Product Entry 1';
        p.productCode = 'ABC';
        p.isActive = true;
        p.Core_Item_Class_Nm__c ='BD';
        p.Core_Product_Ext_Attribute_Id__c = extAttribute;
        insert p;
        return p;   
    }
    public static Sales_License_Group__c createLicenseGroupPackage( String lgenpara){
        Sales_License_Group__c lgp = new Sales_License_Group__c();
        lgp.Name = 'lgp1';
        lgp.Sales_License_Generator__c = lgenpara ;
        insert lgp;
        return lgp; 
    }
    public static List<Sales_License_Control__c> createSalesLicenseControl(Id accId,Id productId){
        List<Sales_License_Control__c> salesLicenseList =new List<Sales_License_Control__c>(); 
        Sales_License_Control__c salesLicense = new Sales_License_Control__c();
        salesLicense.Sales_Account_Competitor__c =accId;
        salesLicense.Sales_License_Vendor_Nm__c='Mentor Graphics';
        salesLicense.Sales_Product__c=productId;
        salesLicense.Sales_InActive_Ind__c=false;
        salesLicenseList.add(salesLicense);
        salesLicense = new Sales_License_Control__c();
        salesLicense.Sales_Account_Competitor__c =accId;
        salesLicense.Sales_License_Vendor_Nm__c='Altera';
        salesLicense.Sales_Product__c=productId;
        salesLicense.Sales_InActive_Ind__c=false;
        salesLicenseList.add(salesLicense);
        insert salesLicenseList;
        return salesLicenseList;
    }
    public static Product2 createNEWProduct(){
        Product2 p = new Product2();
        p.Name = ' Test Corporate Product';
        p.Description='Test Product Entry 1';
        p.productCode = 'ABC';
        p.isActive = true;
        p.Core_Item_Orderable_Ind__c = true;
        p.SBQQ__SubscriptionPricing__c ='Fixed Price';
        p.SBQQ__SubscriptionType__c = 'One-time';
        insert p; 
        return p;
    }
    public static Product2 createBASEProduct(){
        Product2 p = new Product2();
        p.Name = ' Test BASE Product';
        p.Description='Test Product Entry 1';
        p.productCode = 'ABC';
        p.isActive = true;
        p.Core_Item_Orderable_Ind__c = true;
        p.SBQQ__SubscriptionPricing__c ='Fixed Price';
        p.SBQQ__SubscriptionType__c = 'One-time';
        p.Core_Item_Class_Nm__c=' ';
        insert p; 
        return p;
    }
    Public static List<Sales_License__c> createSalesLicense(Id orderId,Id ContractId){
        List<Sales_License__c> liclist = new List<Sales_License__c>();
        Sales_License__c licobj = new Sales_License__c();
        licobj.Sales_License_Order__c = orderId;
        licobj.Sales_License_Contract__c = ContractId;
        licobj.Sales_License_Start_Date_Dt__c = System.Today();
        licobj.Sales_License_Status__c = 'Licensed';
        liclist.add(licobj);
        insert liclist;
        return liclist;
    }
    Public static List<Sales_License_Order_Product__c> createSalesLicenseOrdProd(Id licenseId,Id ContractId,Id OrderProductId){
        List<Sales_License_Order_Product__c> licOrdProdList = new List<Sales_License_Order_Product__c>();
        Sales_License_Order_Product__c licOrdProd = new Sales_License_Order_Product__c();
        licOrdProd.Sales_License__c = licenseId;
        licOrdProd.Sales_License_ContractId__c = ContractId;
        licOrdProd.Sales_Order_Product__c = OrderProductId;
        licOrdProd.Sales_License_Expiration_Date_Dt__c = System.Today()+10;
        licOrdProd.Sales_Quantity__c = 1;
        licOrdProdList.add(licOrdProd);
        insert licOrdProdList;
        return licOrdProdList;
    }
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
        return acc;
    }
    public static Account createInsertDiffPSGDownstreamAccounts(String CoreAccountType, String Acctype){
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
    public static SBQQ__Quote__c createQuote(Id distributorId, Id endCusId,Id oppId, Id pbId){
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.RecordTypeId= SBQQ__Quote__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PSG_Quote_New').getRecordTypeId();
        quote.core_cpq_active_cb__c = true;
        quote.SBQQ__Opportunity2__c = oppId;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__PriceBook__c = pbId;
        quote.core_cpq_business_unit_nm__c = 'Military';
        quote.SBQQ__Type__c = 'Quote';
        quote.core_cpq_quote_type_nm__c='Design Win';
        quote.SBQQ__StartDate__c = date.today()+10;
        quote.SBQQ__SubscriptionTerm__c = 12;
        quote.SBQQ__Status__c = 'Approved';
        quote.core_cpq_end_customer_nm__c=endCusId;
        quote.SBQQ__Account__c=distributorId;
        insert quote;
        return quote;
    }
    public static Core_Product_Ext_Attribute__c createProdExtAtt_withFoundationProd(String toolType, Id lcGroupid, Id foundationProdId ){
        Core_Product_Ext_Attribute__c l1 = new Core_Product_Ext_Attribute__c();
        l1.Core_SW_Lic_Enforcement_Method_Nm__c = 'File';
        l1.Core_Prod_Tool_Type_Nm__c = toolType;
        l1.Core_Foundation_Product_Id__c=foundationProdId;
        l1.Core_SW_Lic_Type_Nm__c = 'FIXED' ; 
        l1.Core_SW_Prod_Max_Rehost_Cnt__c = 1;
        l1.Core_SW_Prod_Web_Dsc__c='Test';
        l1.Core_SW_Lic_File_Data_Encryption_Std_Cd__c = '1DES' ;
        l1.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c = true;
        l1.Core_SW_Lic_Group_Id__c = lcGroupid;
        l1.Core_SW_Lic_Generator_Parameter_Txt__c = 'testing';
        insert l1;
        return l1;
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
    public static List<Order> createListofOrderswithQUote(Id accId, Id pricebookId, Id qId){
        Account accSoldTo = Sales_TestFactory_Utility.createSoldToAccount();
        Account accShipTo = Sales_TestFactory_Utility.createShipToAccount();
        List<Order> orList = new List<Order>();
        Order o = new Order();
        o.Sales_PO_Number_Txt__c = '687900077999898';
        o.Sales_Header_Special_Instructions_Dsc__c = 'abc';
        o.Sales_Ship_To_Account__c = accShipTo.Id;
        o.Name = 'Test Order ';
        o.Status = 'New';
        o.Sales_status__c = 'New'; 
        o.EffectiveDate = system.today();
        o.EndDate = system.today() + 4;
        o.AccountId = accId;
        o.Sales_Sold_To_Account__c=accSoldTo.Id;
        o.Type='Licensed Tool Order';
        o.Sales_Order_Reason__c='Non Stocking Order';
        o.Pricebook2Id = pricebookId ;
        o.SBQQ__Quote__c=qId;
        orList.add(o);
        insert orList;
        return orList;
    }
    public static List<OrderItem> createOrderProductList1(Id ordId, Id prodId, Id pbEntryId,Id conId){
        List<OrderItem> iList = new List<OrderItem>();
        OrderItem i = new OrderItem();
        i.OrderId = ordId;
        i.Quantity = 2;
        i.UnitPrice = 240;
        i.Product2id = prodId;
        i.PricebookEntryId=pbEntryId;
        i.Sales_Contact__c = conId;
        iList.add(i);
        insert iList;
        return iList;
    } 
    public static List<Core_Account_SoldTo_ShipTo_Rel__c> accountsoldToshipTo(Id SoldTo, Id ShipTo)
    {
        List<Core_Account_SoldTo_ShipTo_Rel__c> soldToshipTo= new List<Core_Account_SoldTo_ShipTo_Rel__c>();
        Core_Account_SoldTo_ShipTo_Rel__c s=new Core_Account_SoldTo_ShipTo_Rel__c();
        s.Core_Sold_To_Account__c=SoldTo;
        s.Core_Ship_To_Account__c=ShipTo;
        soldToshipTo.add(s);
        insert soldToshipTo;
        return soldToshipTo;
    }
*/
}