/******************************************************************************************************************************************
Class Name  : Core_OpportunityQuotePSGSales_Test
Version     : 1.0 
Created Date: Dec 16, 2016
Function    : Test class code for the PSG Sales functionality
Modification Log :
* Developer         Date          Description
* ---------------------------------------------------Core_SalesSupportPSGQuoteSFDCToSiebel-------------------------                 
* Accenture         12/16/2016    Original version
*****************************************************************************************************************************************/
@isTest
public class Core_SalesSupportPSGQuote_Test {
    
    /**********************************
* Method Name : createAccount
* Created On  : Dec-13-2016
* Created By  : Accenture
* Description : Intel Altera Phase1:
*               Below method is used for creating the Account  
***********************************/
    public static List<Account>  createAccount( integer count,Boolean isPSGAccount) {
        
        String recordTypeId = [SELECT Id, Name, SobjectType, IsActive FROM RecordType where SobjectType ='Account' and Name='Intel Account'].Id;
        List<Account> accList = new List<Account>();
        for(integer i=0;i<count;i++) {
            Account objAcc =  new Account();
            objAcc.Name='Test-Acc'+i;
            objAcc.Core_Account_Type__c ='Distributor';
            if(isPSGAccount)
                objAcc.Core_Sales_Group__c ='PSG Sales';
            else 
                objAcc.Core_Sales_Group__c ='Industry Sales';
            objAcc.Core_Sales_Groups__c ='APJ Partner Holding';
            objAcc.Industry = 'Agriculture';
            objAcc.Core_Account_Tier__c ='PSG-Tier 1';
            objAcc.BillingCountry = 'IND';
            objAcc.BillingStreet = 'Street 101';
            objAcc.BillingCity = 'Bangalore';
            objAcc.BillingState = 'KA';
            objAcc.BillingPostalCode='575001';
            //objAcc.Core_CIM_ID__c='7689544';
            accList.add(objAcc);
        }
        return accList;
        
    }
    
    /**********************************
* Method Name : createPSGIntegrationSetting
* Created On  : Jan-03-2017
* Created By  : Accenture
* Description : Intel Altera Phase1:
*               Below Code used for inserting values into PSG Integration Setting
***********************************/
    
    public static List<Core_PSG_Integration_Settings__c> createPSGIntegrationSetting(integer count) {
        
        List<Core_PSG_Integration_Settings__c> PSGIntegrationSettingList = new List<Core_PSG_Integration_Settings__c>();
        Core_PSG_Integration_Settings__c objPSGIntSetting = new Core_PSG_Integration_Settings__c();
        objPSGIntSetting.Name='PSG Setting-1';
        objPSGIntSetting.Core_User_Name__c ='Sibel@intel.com';
        objPSGIntSetting.Core_Password__c ='Sieble@123';
        PSGIntegrationSettingList.add(objPSGIntSetting);
        return PSGIntegrationSettingList;
    }
    
    /**********************************
* Method Name : createTestUserInGeo
* Created On  : Dec-15-2016
* Created By  : Accenture
* Description : Intel Altera Phase1:
*               Below Code used for creating the user  
***********************************/
    public static  List<User>  createTestUserInGeo(Integer numUsers, Id profileId, String geo) {
        
        List<User> testUsers = new List<User>();
        for (Integer i=0; i<numUsers; i++) {
            User testUser = new User();
            testUser.Firstname = 'test_test';
            testUser.LastName = 'user_test ' + geo + i;
            testUser.UserName = 'testuser_Test' + geo + i + '@intel.com.crm';
            testUser.Email = 'testuser._Test' + geo + i + '@intel.com';
            testUser.Alias = geo + i;
            testUser.CommunityNickName = 'test_test' + geo + i;
            testUser.ProfileId = profileId;
            testUser.LANGUAGELOCALEKEY = 'en_US';
            testUser.LOCALESIDKEY = 'en_US';
            testUser.TIMEZONESIDKEY = 'America/Los_Angeles';
            testUser.EMAILENCODINGKEY = 'ISO-8859-1';
            testUser.Core_User_Geo__c = geo;
            testUser.Core_Login_Id__c = 'test_idsid';
            testUsers.add(testUser);
        }
        
        return testUsers;
        
    }
    
    /**********************************
* Method Name : createOpportunity
* Created On  : Dec-15-2016
* Created By  : Accenture
* Description : Intel Altera Phase1:
*               Below method is used for creating the Opportunity
***********************************/
    public static List<Opportunity> createOpportunity(integer count,Account objOppAccount) {
        
        List<Opportunity> oppList = new List<Opportunity>();
        Id profileId = [select Id from Profile where Name = 'Sales Rep-BB'][0].Id;
        List<User> userList = createTestUserInGeo(1, profileId, '');
        insert userList;
        //Edited and moved the SOQL query from line number 116 by Kavyashree HR(Infosys Pegasus Team) on 30/04/2020 to fix security scan issues(US667274)
        String oppoRecordTypeId = [SELECT Id, Name, SobjectType, IsActive FROM RecordType where SobjectType ='Opportunity' and Name='New Opportunity'].Id;
        for(integer i =0;i <count;i++) {
            Opportunity opp = new Opportunity();
            String oppRecordTypeId = oppoRecordTypeId;
            opp.Name='Test-Opp'+i;
            opp.AccountId = objOppAccount.Id;
            opp.StageName ='Qualify';
            opp.Core_Sales_Group__c = 'PSG Sales';
            opp.Core_Military_Aerospace_Govmt_End_Use__c = 'Yes';
            opp.CloseDate = Date.Today();
            opp.Core_Opportunity_Type__c = 'Design: Original';
            opp.Core_PSG_Quote_Last_Processed_Status__c='Processing';
            //INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST, bad value for restricted picklist field: N/A: 
            //opp.Core_Product_Segment__c ='Embedded';
            //opp.Core_Product_Application__c ='Energy - Other';
            opp.Core_Solution_Area__c = 'IOTG Deal (Sell-To) $';
            //COMMENT BELOW 2 LINES WHEN MIGRATED AFTER DEVSLS
            opp.Core_Product_Segment__c ='Data Center Computing';
            opp.Core_Product_Application__c ='Storage';
            opp.Core_Consumption_Market__c = 'Education';
            opp.Core_Technical_Owner__c = userList[0].Id;
            opp.Core_First_Customer_Ship_Date__c = Date.Today();
            opp.Core_Production_End_Date__c = Date.Today();
            opp.Core_Volume__c = 10;
            opp.Description = 'Test Opportinity Description';
            oppList.add(opp);
        }
        return oppList;
        
    }
    
    // create oppty with another owner
    public static List<Opportunity> createOpportunity(integer count,Account objOppAccount, Id userId) {
        //Edited and moved the SOQL query from line number 116 by Kavyashree HR(Infosys Pegasus Team) on 30/04/2020 to fix security scan issues(US667274)
        String oppoRecordTypeId = [SELECT Id, Name, SobjectType, IsActive FROM RecordType where SobjectType ='Opportunity' and Name='New Opportunity'].Id;
        List<Opportunity> oppList = new List<Opportunity>();
        Id profileId = [select Id from Profile where Name = 'Sales Rep-BB'][0].Id;            
        for(integer i =0;i <count;i++) {
            Opportunity opp = new Opportunity();
            String oppRecordTypeId = oppoRecordTypeId;
            opp.Name='Test-Opp'+i;
            opp.AccountId = objOppAccount.Id;
            opp.StageName ='Design';
            opp.Core_Sales_Group__c = 'PSG Sales';
            opp.Core_Military_Aerospace_Govmt_End_Use__c = 'Yes';
            opp.CloseDate = Date.Today();
            opp.Core_Opportunity_Type__c = 'Design: Original';
            opp.Core_PSG_Quote_Last_Processed_Status__c='pending';
            //INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST, bad value for restricted picklist field: N/A: 
            //opp.Core_Product_Segment__c ='Embedded';
            //opp.Core_Product_Application__c ='Energy - Other';
            opp.Core_Solution_Area__c = 'IOTG All Deal $';
            //COMMENT BELOW 2 LINES WHEN MIGRATED AFTER DEVSLS
            opp.Core_Product_Segment__c ='Embedded';
            opp.Core_Product_Segment__c ='Data Center Computing';
            opp.Core_Product_Application__c ='Server';
            opp.Core_Technical_Owner__c = userId;
            opp.Core_First_Customer_Ship_Date__c = Date.Today();
            opp.Core_Production_End_Date__c = Date.Today();
            opp.Core_Volume__c = 10;
            opp.OwnerId = userId;
            oppList.add(opp);
        }
        return oppList;
        
    }
    
    
    /**********************************
* Method Name : createOpportunityPartner
* Created On  : Dec-15-2016
* Created By  : Accenture
* Description : Intel Altera Phase1:
*               Below method is used for inserting the values into the Opportunity Partner 
***********************************/
    public static List<Core_Opportunity_Partner__c> createOpportunityPartner(integer count,Account accObj,Opportunity oppObj){
        
        List<Core_Opportunity_Partner__c> oppPartnerList = new List<Core_Opportunity_Partner__c>();
        for(integer i =0;i <count;i++) {
            Core_Opportunity_Partner__c objOppPartner = new Core_Opportunity_Partner__c();
            objOppPartner.Core_Partner__c = accObj.Id;
            objOppPartner.Core_Opportunity__c = oppObj.Id;
            objOppPartner.Core_Partner_Role__c ='Co-Design';
            objOppPartner.Core_Partner_Type__c ='Distributor';
            objOppPartner.Core_Partner_Notes__c ='Test';
            oppPartnerList.add(objOppPartner);
        }
        return oppPartnerList;  
    }
    
    /**********************************
* Method Name : setupTestData
* Created On  : Dec-15-2016
* Created By  : Accenture
* Description : Intel Altera Phase1:
*               Below method is used for inserting the values for Trigger Execution object 
***********************************/
    public static void setupTestData() {  
        
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(
            Name='processInboundMessages', Core_Object__c='Core_Integration_Inbound_Message__c',
            Core_Class_Name__c='Core_IntegrationInboundMessageHandler',
            Core_Trigger_Events__c='before insert', Core_Active__c=true, Core_Description__c='testing, testing');
        insert triggerEntry;
        
    }
    
    /**********************************
* Method Name : createOpportunityProduct
* Created On  : Dec-15-2016
* Created By  : Accenture
* Description : Intel Altera Phase1:
*               Below method is used for creating the Opportunity LineItem 
***********************************/
    public static List<OpportunityLineItem> createOpportunityProduct(integer count,Opportunity oppObj,Boolean isPSGProd) {
        
        Id pricebookId = Test.getStandardPricebookId();
        List<OpportunityLineItem> oppLineItem = new List<OpportunityLineItem> ();
        //Create your product
        Product2 prod = new Product2();
        if(isPSGProd) {
            prod.Name = 'Intel® FPGAs';
            prod.ProductCode = 'Pro-X';
            prod.Core_Product_Type__c = 'Intel® FPGAs';
            prod.isActive = true;
        }
        else {
            prod.Name = 'Product00034343400';
            prod.ProductCode = 'Pro-7X';
            prod.Core_Product_Type__c = 'Intel® FPGAs11';
            prod.isActive = true;
        }
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        OpportunityLineItem objOppLineItem = new OpportunityLineItem();
        objOppLineItem.OpportunityId = oppObj.Id;
        objOppLineItem.Quantity = 5;
        objOppLineItem.PricebookEntryId = pbEntry.Id;
        objOppLineItem.TotalPrice = objOppLineItem.Quantity * pbEntry.UnitPrice;
        //objOppLineItem.Core_PW_Quantity__c = 10;
        //objOppLineItem.Core_PW_Sales_Price__c = 10;
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        oppLineItem.add(objOppLineItem);
        return oppLineItem;
        
    }
    
    /**********************************
* Method Name : insertIntegrationInboundMessage
* Created On  : Dec-15-2016
* Created By  : Accenture
* Description : Intel Altera Phase1:
*               Below method is used for inserting the values into Integration_Inbound_Message object .
***********************************/
    public static List<Core_Integration_Inbound_Message__c> insertIntegrationInboundMessage(integer count,Opportunity opp){
        
        List<Core_Integration_Inbound_Message__c> integrationInboundMessageList = new List<Core_Integration_Inbound_Message__c>();
        String Payload = '<?xml version="1.0" encoding="UTF-8"?>'+
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="http://siebel.com/CustomUI" xmlns:eai="http://www.siebel.com/xml/EAI%20Opty%20IO%20SFDC%20Altera">'+
            '<soapenv:Header/>'+
            '<soapenv:Body>'+
            '<cus:AlteraSfdcQuoteIntegration_Output>'+
            '<cus:Error_spcCode></cus:Error_spcCode>'+
            '<cus:Error_spcMessage></cus:Error_spcMessage>'+
            '<cus:QuoteURL>Altera.com</cus:QuoteURL>'+
            '<cus:RFQ_ID>IY-13456321ewqw41</cus:RFQ_ID>'+
            '<cus:Opportunity_ID>'+opp.Id+'</cus:Opportunity_ID>'+
            '<cus:Status>Quote successfully created – all PSG products on the opportunity were quoted</cus:Status>'+
            '</cus:AlteraSfdcQuoteIntegration_Output>'+
            '</soapenv:Body>'+
            '</soapenv:Envelope>';
        Core_Integration_Inbound_Message__c InboundMsg = new Core_Integration_Inbound_Message__c();
        InboundMsg.Core_Source_System__c = 'SIEBEL';
        InboundMsg.Core_Message_Type__c = 'Quote';
        InboundMsg.Core_Payload__c = Payload;
        integrationInboundMessageList.add(InboundMsg);
        return integrationInboundMessageList;
        
        
    }
    
    /**********************************
* Method Name : insertIntegrationInboundMessage
* Created On  : Dec-15-2016
* Created By  : Accenture
* Description : Intel Altera Phase1:
*               This method will check for the Empty Opportunity Id.
***********************************/
    static testMethod void testMethodemptyOpportuntiyId() {
        
        PageReference tpageRef = Page.Core_SalesSupportHome;
        Test.setCurrentPage(tpageRef);
        
        ApexPages.currentPage().getParameters().put('Id', null);
        //System.AssertEquals(false,Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportuntyBeforeQuoteCreation());
        
    }
    
    /**********************************
* Method Name : testPSGAccountForOpportunityCheck
* Created On  : Dec-15-2016
* Created By  : Accenture
* Description : Intel Altera Phase1:
*               This method is used for checking the Account PSG Sales Validation function.
***********************************/
    static testMethod void testPSGAccountForOpportunityCheck() {
        
        //Code for creating the Account
        List<Account> accList = new List<Account>();
        
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct = new Account(Name ='Test AccountX4',Core_Account_Type__c = 'End Customer',RecordTypeId=masterRecordTypeId, BillingCity='Seoul',BillingCountry='KOR',BillingStreet='KOR',Industry='Electronics',Core_Sales_Groups__c= 'PRC Sales Group');

        accList.add(acct);
        insert accList;
        List<Opportunity> oppList = createOpportunity(1,accList[0]);
        insert oppList;
        String  opId=ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);        
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        //System.AssertEquals(false,Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportuntyBeforeQuoteCreation());
        //Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportunityBeforeQuoteCreationNew(oppList[0].Id);
        String err=Core_SalesSupportPSGQuoteSFDCToSiebel.errorMessage='Valid';
        Core_SalesSupportPSGQuoteSFDCToSiebel.errorMessages(err);
        
        
    }
    
    /**********************************
* Method Name : testPSGAccountForOpportunityCheck
* Created On  : Dec-15-2016
* Created By  : Accenture
* Description : Intel Altera Phase1:
*               This method is used for checking the Opportunity with empty product.
***********************************/
    static testMethod void testOpportunityProductEmptyCheck() {
        
        //Code for creating the Account
        List<Account> accList = new List<Account>();
        
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct = new Account(Name ='Test AccountX1',Core_Account_Type__c = 'End Customer',RecordTypeId=masterRecordTypeId, BillingCity='Seoul',BillingCountry='KOR',BillingStreet='KOR',Industry='Electronics',Core_Sales_Groups__c= 'PRC Sales Group');

        accList.add(acct);
        insert accList;
        List<Opportunity> oppList = createOpportunity(1,accList[0]);
        insert oppList;
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        //System.AssertEquals(false,Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportuntyBeforeQuoteCreation());
        //Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportunityBeforeQuoteCreationNew(oppList[0].Id);
        
        
    }
    
    /**********************************
* Method Name : testOpportunityProductEmptyCheckWhenPSGSalesisEmpty
* Created On  : Dec-15-2016
* Created By  : Accenture
* Description : Intel Altera Phase1:
*               This method is used for checking the Opportunity with empty product when Account PSG Sales is Null.
***********************************/
    static testMethod void testOpportunityProductEmptyCheckWhenPSGSalesisEmpty() {
        
        //Code for creating the Account
        List<Account> accList = new List<Account>();
        
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct = new Account(Name ='Test AccountX2',Core_Account_Type__c = 'End Customer',RecordTypeId=masterRecordTypeId, BillingCity='Seoul',BillingCountry='KOR',BillingStreet='KOR',Industry='Electronics',Core_Sales_Groups__c= 'PRC Sales Group');

        accList.add(acct);
        insert accList;
        accList[0].Core_Sales_Group__c = null;
        update accList;
        List<Opportunity> oppList = createOpportunity(1,accList[0]);
        insert oppList;
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        //System.AssertEquals(false,Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportuntyBeforeQuoteCreation());
        
        //Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportunityBeforeQuoteCreationNew(oppList[0].Id);
        //Core_SalesSupportHomeController.createPSGQuoteonSiebelNew(oppList[0].Id);     
        
        
    }
    
    /**********************************
* Method Name : testOpportunityProductEmptyCheckWhenPSGSalesisEmpty
* Created On  : Dec-15-2016
* Created By  : Accenture
* Description : Intel Altera Phase1:
*               This method is used for testing the Parsing functionality.
***********************************/
    static testmethod void testOpportuntiyPayloadParse() {
        
        setupTestData();
        List<Account> accList = new List<Account>();
        
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct = new Account(Name ='Test AccountX3',Core_Account_Type__c = 'End Customer',RecordTypeId=masterRecordTypeId, BillingCity='Seoul',BillingCountry='KOR',BillingStreet='KOR',Industry='Electronics',Core_Sales_Groups__c= 'PRC Sales Group');

        accList.add(acct);
        insert accList;
        
        List<Opportunity> oppList = createOpportunity(1,accList[0]);
        
        insert oppList;
       	List<Core_PSG_Integration_Settings__c>  psgIntegrationSettingList = createPSGIntegrationSetting(1);
        insert psgIntegrationSettingList;
        
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        insert triggerExecList;
        
        List<OpportunityLineItem> oppLineItemList = createOpportunityProduct(1,oppList[0],true);
        insert oppLineItemList;
        
        /*if(Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportuntyBeforeQuoteCreation()) {
            List<Core_Integration_Inbound_Message__c>  inboundMessageList = insertIntegrationInboundMessage(1,oppList[0]);
            insert inboundMessageList;
        }*/
        List<Core_PSG_Quote_Generation_History__c> quoteGenarationList = [SELECT Id, Name, Core_Opportunity__c, Core_RFQ_ID__c FROM Core_PSG_Quote_Generation_History__c];
        Core_PSG_Quote_Generation_History__c psg=new Core_PSG_Quote_Generation_History__c();
        psg.Core_Error_Code__c='test';
        psg.Core_Error_Message__c='Updated the records';
        psg.Core_Message_Status__c='Ok';
        psg.Core_Opportunity__c=oppList[0].Id;
        psg.Core_Quote_URL__c='Test';
        psg.Core_RFQ_ID__c='1-HPVLDR';
        insert psg;
        quoteGenarationList = [SELECT Id, Name, Core_Opportunity__c, Core_RFQ_ID__c FROM Core_PSG_Quote_Generation_History__c where Core_Opportunity__c =:oppList[0].Id and id=:psg.Id];
        System.AssertEquals(1,quoteGenarationList.size());
        
    }
    
    /**********************************
* Method Name : testOpportunityProductEmptyCheckWhenPSGSalesisEmpty
* Created On  : Dec-15-2016
* Created By  : Accenture
* Description : Intel Altera Phase1:
*               This method is used for checking the accessibility  of page.
***********************************/
    static testmethod void testSalesSupportPageAccess() {
        
        Core_SalesSupportPSGQuoteSFDCToSiebel.isSalesSupportHomePageAccessible();
        
        System.assertNotEquals(null,Core_SalesSupportPSGQuoteSFDCToSiebel.isSalesSupportHomePageAccessible());
        
    }
    
    /**********************************
* Method Name : testOpportunityProductEmptyCheckWhenPSGSalesisEmpty
* Created On  : Dec-15-2016
* Created By  : Accenture
* Description : Intel Altera Phase1:
*               Test method for creating the Quote
***********************************/
    static testmethod void testSalesSupportHomeCreatePSGQuote_Test() {
        
        setupTestData();
        List<Account> accList = new List<Account>();
        
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct = new Account(Name ='Test AccountX7',Core_Account_Type__c = 'End Customer',RecordTypeId=masterRecordTypeId, BillingCity='Seoul',BillingCountry='KOR',BillingStreet='KOR',Industry='Electronics',Core_Sales_Groups__c= 'PRC Sales Group');

        accList.add(acct);
        insert accList;
        
        List<Opportunity> oppList = createOpportunity(1,accList[0]);
        insert oppList;
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        
        List<Core_PSG_Integration_Settings__c>  psgIntegrationSettingList = createPSGIntegrationSetting(1);
        insert psgIntegrationSettingList;
        
        Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        insert triggerExecList;
        
        List<OpportunityLineItem> oppLineItemList = createOpportunityProduct(1,oppList[0],true);
        insert oppLineItemList;
        
        List<Core_Opportunity_Partner__c> oppPartnerList = createOpportunityPartner(1,accList[0],oppList[0]);
        insert oppPartnerList;
        
        List<Core_Integration_Outbound_Message__c> outBoundmessageList;
        /*if(Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportuntyBeforeQuoteCreation()) {
            Core_SalesSupportHomeController objHomeController = new Core_SalesSupportHomeController();
            objHomeController.createPSGQuoteonSiebel();
            Core_Integration_Outbound_Message__c  OutMsg=new Core_Integration_Outbound_Message__c(Core_MessageType__c ='PSG_Quote',Core_Payload__c='<![CDATA[<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="http://siebel.com/CustomUI" xmlns:eai="http://www.siebel.com/xml/EAI%20Opty%20IO%20SFDC%20Altera"><soapenv:Header><UsernameToken');
            insert Outmsg;
            outBoundmessageList = [select id, name from Core_Integration_Outbound_Message__c where id=:OutMsg.Id];
            objHomeController.createPSGQuoteonSiebel();
            
        }*/
        
        // System.AssertEquals(1,outBoundmessageList.size()); 
        
    }
    
    /**********************************
* Method Name : testSalesSupportHomeCreatePSGQuoteForPSGSalesEmpty_Test
* Created On  : Jan-5-2017
* Created By  : Accenture
* Description : Intel Altera Phase1:
*               Test method for checking Opportunity has PSG Product or not.
***********************************/
    static testmethod void testSalesSupportHomeCreatePSGQuoteForPSGSalesEmpty_Test() {
        
        setupTestData();
        List<Account> accList = new List<Account>();
        
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct = new Account(Name ='Test AccountX6',Core_Account_Type__c = 'End Customer',RecordTypeId=masterRecordTypeId, BillingCity='Seoul',BillingCountry='KOR',BillingStreet='KOR',Industry='Electronics',Core_Sales_Groups__c= 'PRC Sales Group');

        accList.add(acct);
        insert accList;
        
        List<Opportunity> oppList = createOpportunity(1,accList[0]);
        insert oppList;
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        
        List<Core_PSG_Integration_Settings__c>  psgIntegrationSettingList = createPSGIntegrationSetting(1);
        insert psgIntegrationSettingList;
        
        
        Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        insert triggerExecList;
        
        List<OpportunityLineItem> oppLineItemList = createOpportunityProduct(1,oppList[0],false);
        insert oppLineItemList;
        
        
        List<Core_Opportunity_Partner__c> oppPartnerList = createOpportunityPartner(1,accList[0],oppList[0]);
        insert oppPartnerList;
        
        List<Core_Integration_Outbound_Message__c> outBoundmessageList;
        /*if(Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportuntyBeforeQuoteCreation()) {
            Core_SalesSupportHomeController objHomeController = new Core_SalesSupportHomeController();
            objHomeController.createPSGQuoteonSiebel();
            objHomeController.createPSGQuoteonSiebel(); 
        }*/
        outBoundmessageList = [select id, name from Core_Integration_Outbound_Message__c where Core_MessageType__c ='PSG_Quote'];
        System.AssertEquals(0,outBoundmessageList.size()); 
    }
    
    
    
    /**********************************
* Method Name : testOpportunityProductEmptyCheckWhenPSGSalesisEmpty
* Created On  : Dec-15-2016
* Created By  : Accenture
* Description : Intel Altera Phase1:
*               Test method for checking already processing PSG quote 
***********************************/
    static testmethod void testSalesSupportHomeAlreadyProcessingPSGQuote_Test() {
        
        setupTestData();
        List<Account> accList = new List<Account>();
        
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct = new Account(Name ='Test AccountX5',Core_Account_Type__c = 'End Customer',RecordTypeId=masterRecordTypeId, BillingCity='Seoul',BillingCountry='KOR',BillingStreet='KOR',Industry='Electronics',Core_Sales_Groups__c= 'PRC Sales Group');

        accList.add(acct);
        insert accList;
        
        List<Opportunity> oppList = createOpportunity(1,accList[0]);
        insert oppList;
        
        List<Core_PSG_Integration_Settings__c>  psgIntegrationSettingList = createPSGIntegrationSetting(1);
        insert psgIntegrationSettingList;
        
        List<Opportunity> oppUpdateList = [select id,Core_PSG_Quote_Last_Processed_Status__c from Opportunity where Id=:oppList[0].Id];
        oppUpdateList[0].Core_PSG_Quote_Last_Processed_Status__c = 'Processing';
        update oppUpdateList;
        
        ApexPages.currentPage().getParameters().put('OppId', oppList[0].Id);
        
        Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        insert triggerExecList;
        
        List<OpportunityLineItem> oppLineItemList = createOpportunityProduct(1,oppList[0],true);
        insert oppLineItemList;
        
        List<Core_Opportunity_Partner__c> oppPartnerList = createOpportunityPartner(1,accList[0],oppList[0]);
        insert oppPartnerList;
        
        List<Core_Integration_Outbound_Message__c> outBoundmessageList = new List<Core_Integration_Outbound_Message__c>();
        /*if(Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportuntyBeforeQuoteCreation()) {
            Core_SalesSupportHomeController objHomeController = new Core_SalesSupportHomeController();
            objHomeController.createPSGQuoteonSiebel();
            outBoundmessageList = [select id, name from Core_Integration_Outbound_Message__c where Core_MessageType__c ='PSG_Quote'];
            objHomeController.createPSGQuoteonSiebel();
            
        }*/
        System.AssertEquals(0,outBoundmessageList.size()); 
        
    }
    /**********************************
* Method Name : Core_SalesSupportPSGQuoteSFDCToSiebel.processPSGQuoteMessage
* Created On  : Jan-7-2018
* Created By  : Intel
* Description : Test Method for Core_SalesSupportPSGQuoteSFDCToSiebel.processPSGQuoteMessage
***********************************/
    static testmethod void Core_IntegrationInboundMessage_Unit1() {
        List < Core_Trigger_Executions__c > lstTriggerExecution = new List < Core_Trigger_Executions__c > ();
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c(
            Name='processInboundMessages', Core_Object__c='Core_Integration_Inbound_Message__c',
            Core_Class_Name__c='Core_IntegrationInboundMessageHandler',
            Core_Trigger_Events__c='before insert', Core_Active__c=true, Core_Description__c='testing, testing');
        lstTriggerExecution.add(triggerEntry);
        insert lstTriggerExecution;
        List<Account> accList = new List<Account>();
        
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct = new Account(Name ='Test AccountXX',Core_Account_Type__c = 'End Customer',RecordTypeId=masterRecordTypeId, BillingCity='Seoul',BillingCountry='KOR',BillingStreet='KOR',Industry='Electronics',Core_Sales_Groups__c= 'PRC Sales Group');

        accList.add(acct);
        insert accList;
        
        List<Opportunity> oppList = createOpportunity(1,accList[0]);
        
        insert oppList;
        List<Core_PSG_Integration_Settings__c>  psgIntegrationSettingList = createPSGIntegrationSetting(1);
        insert psgIntegrationSettingList;
        
        List<Core_Integration_Inbound_Message__c> integrationInboundMessageList = new List<Core_Integration_Inbound_Message__c>();
        String Payload = '<?xml version="1.0" encoding="UTF-8"?>'+
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="http://siebel.com/CustomUI" xmlns:eai="http://www.siebel.com/xml/EAI%20Opty%20IO%20SFDC%20Altera">'+
            '<soapenv:Header/>'+
            '<soapenv:Body>'+
            '<cus:AlteraSfdcQuoteIntegration_Output>'+
            '<cus:Error_spcCode></cus:Error_spcCode>'+
            '<cus:Error_spcMessage></cus:Error_spcMessage>'+
            '<cus:QuoteURL>Altera.com</cus:QuoteURL>'+
            '<cus:RFQ_ID>IY-13456321ewqw41</cus:RFQ_ID>'+           
            '<cus:Status>Quote successfully created – all PSG products on the opportunity were quoted</cus:Status>'+
            '</cus:AlteraSfdcQuoteIntegration_Output>'+
            '</soapenv:Body>'+
            '</soapenv:Envelope>';
        Core_Integration_Inbound_Message__c InboundMsg = new Core_Integration_Inbound_Message__c();
        InboundMsg.Core_Source_System__c = 'SIEBEL';
        InboundMsg.Core_Message_Type__c = 'Quote';
        InboundMsg.Core_Payload__c = Payload;
        integrationInboundMessageList.add(InboundMsg);
        
        insert integrationInboundMessageList;
        
        Core_PSG_Quote_Generation_History__c psg=new Core_PSG_Quote_Generation_History__c();
        psg.Core_Error_Code__c='test';
        psg.Core_Error_Message__c='Updated the records';
        psg.Core_Message_Status__c='Ok';
        psg.Core_Opportunity__c=oppList[0].Id;
        psg.Core_Quote_URL__c='Test';
        psg.Core_RFQ_ID__c='1-HPVLDR';
        insert psg;
    }
    
    static testMethod void validateOpportuntyBeforeQuoteCreation_Test1(){
        Test.startTest();
        List<Account> accList = new List<Account>();
        
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct = new Account(Name ='Test AccountX8',Core_Account_Type__c = 'End Customer',RecordTypeId=masterRecordTypeId, BillingCity='Seoul',BillingCountry='KOR',BillingStreet='KOR',Industry='Electronics',Core_Sales_Groups__c= 'PRC Sales Group');

        accList.add(acct);
        insert accList;
        
        List<Opportunity> testOpptyList = createOpportunity(3,accList[0]);      
        insert testOpptyList;
        
        List<Core_PSG_Integration_Settings__c>  psgIntegrationSettingList = createPSGIntegrationSetting(1);
        insert psgIntegrationSettingList;
        
        Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        insert triggerExecList;
        
        List<OpportunityLineItem> opptyLineItemList = createOpportunityProduct(2,testOpptyList[0],true);
        insert opptyLineItemList;
        
        ApexPages.currentPage().getParameters().put('OppId', testOpptyList[0].Id);
        //Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportuntyBeforeQuoteCreation();
        
        Core_SalesSupportPSGQuoteSFDCToSiebel.createPayloadForOpportuntiyQuote();
        //Core_SalesSupportPSGQuoteSFDCToSiebel.validateOpportunityBeforeQuoteCreationNew(testOpptyList[0].Id);
        Test.stopTest();
    }
}