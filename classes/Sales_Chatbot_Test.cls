/**********************************************************************************************************************
Test Class Name : Sales_Chatbot_Test
Version         : 1.0
Created Date    : July 2021
Created By      : Shivam Vishwakarma
Modification Log :
* Developer                 Date                    Description 
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        16-July-2021             Common test class for all Chatbot related Apex Classes 
* ---------------------------------------------------------------------------------------------------------*/
@isTest
public class Sales_Chatbot_Test {
    @isTest
    public static void Sales_NonIpsCaseCreationChatbotTest(){
        String errMsg = '';
        Sales_NonIpsCaseCreationChatbot.ContactInput Input1 = new Sales_NonIpsCaseCreationChatbot.ContactInput();
        List<List<Sales_NonIpsCaseCreationChatbot.pickListWrapper>> result;         
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert con1;
        Input1.scontId = con1.Id;              
        System.Test.startTest();
        try{
            result = Sales_NonIpsCaseCreationChatbot.fetchNonIPSCaseCreation(new List<Sales_NonIpsCaseCreationChatbot.ContactInput>{Input1});   
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    @isTest
    public static void Sales_DynamicUrlCreationTest(){
        String errMsg = '';
        Sales_DynamicUrlCreation.ChatbotInput Input  = new Sales_DynamicUrlCreation.ChatbotInput();
        List<Sales_DynamicUrlCreation.ChatbotOutput> result = new List<Sales_DynamicUrlCreation.ChatbotOutput>();
        Input.statusVariable='';
        System.Test.startTest();
        try{
            result = Sales_DynamicUrlCreation.generateUrl(new List<Sales_DynamicUrlCreation.ChatbotInput>{Input});
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    @isTest
    public static void Sales_IpsNonIpsCheckTest(){
        String errMsg = '';
        Sales_IpsNonIpsCheck.ComputerInput Input  = new Sales_IpsNonIpsCheck.ComputerInput();
        List<Sales_IpsNonIpsCheck.ComputerOutput> result = new List<Sales_IpsNonIpsCheck.ComputerOutput>();
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert con;
        Input.ContactId=con.Id;
        System.Test.startTest();
        try{
            result = Sales_IpsNonIpsCheck.createComputerDetails(new List<Sales_IpsNonIpsCheck.ComputerInput>{Input});
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /****************************** 
    * Developer Name : Shivam Vishwakarma
    * Test method: DetermineHostLicType_Test - Test method for Apex Class -> Sales_DetermineHostLicType_Bot
    * ****************************/
    @isTest
    public static void DetermineHostLicType_Test(){
        String errMsg = '';
        Sales_DetermineHostLicType_Bot.LicenseToolTypeInput licenseTypeInput = new Sales_DetermineHostLicType_Bot.LicenseToolTypeInput();
        Sales_DetermineHostLicType_Bot.LicenseToolTypeInput licenseTypeInput2 = new Sales_DetermineHostLicType_Bot.LicenseToolTypeInput();
        Sales_DetermineHostLicType_Bot.LicenseToolTypeInput licenseTypeInput3 = new Sales_DetermineHostLicType_Bot.LicenseToolTypeInput();
        List<Sales_DetermineHostLicType_Bot.Result> result = new List<Sales_DetermineHostLicType_Bot.Result>();
        licenseTypeInput.License_Type_OnLicense = 'FIXED';
        licenseTypeInput2.License_Type_OnLicense = 'FLOAT';
        Sales_Host__c h = Sales_TestDataFactory.createComputerRecord();
        insert h;
        licenseTypeInput3.hostobj = h;
        System.Test.startTest();
        try{
            result = Sales_DetermineHostLicType_Bot.determineHostLicType(new List<Sales_DetermineHostLicType_Bot.LicenseToolTypeInput>{licenseTypeInput});
            result = Sales_DetermineHostLicType_Bot.determineHostLicType(new List<Sales_DetermineHostLicType_Bot.LicenseToolTypeInput>{licenseTypeInput2});
            result = Sales_DetermineHostLicType_Bot.determineHostLicType(new List<Sales_DetermineHostLicType_Bot.LicenseToolTypeInput>{licenseTypeInput3});
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: LicenseFileGeneration_Test - Test method for Apex Class -> Sales_LicenseFileGeneration_Chatbot
    * ****************************/
    @isTest
    public static void LicenseFileGeneration_Test(){
        String errMsg = '';
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert con;
        Sales_Host__c hostObj = Sales_TestDataFactory.createComputerRecord();
        insert hostObj;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostObj.Id ,    'Sales_License_Product__c' => prod1.Id ,
                'Sales_License_Account__c' => acc.Id , 'Sales_License_Primary_Admin_Contact__c' => con.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });
        insert lic;
        System.Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new LicenseFileGenerationCalloutMock());
        Sales_LicenseFileGeneration_Chatbot.LicenseFileGenInput Input = new Sales_LicenseFileGeneration_Chatbot.LicenseFileGenInput();
        Input.ActivationCode_OR_HostId  = lic.Id;
        Input.InputType = 'ActivationCode';  
        Input.contactId = con.Id;
        Sales_LicenseFileGeneration_Chatbot.LicenseFileGenInput Input2 = new Sales_LicenseFileGeneration_Chatbot.LicenseFileGenInput();
        Input2.HostData  = hostObj;
        Input2.InputType = 'HostId'; 
        Input2.contactId = con.Id;
        List<Sales_LicenseFileGeneration_Chatbot.LicenseFileGenOutput> result = new List<Sales_LicenseFileGeneration_Chatbot.LicenseFileGenOutput>();
        try{
            result = Sales_LicenseFileGeneration_Chatbot.generateLicenseFile(new List<Sales_LicenseFileGeneration_Chatbot.LicenseFileGenInput>{Input});
            result = Sales_LicenseFileGeneration_Chatbot.generateLicenseFile(new List<Sales_LicenseFileGeneration_Chatbot.LicenseFileGenInput>{Input2});
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: fetchActivationCode_Test - Test method for Apex Class -> Sales_fetchActivationCode_Bot
    * ****************************/
    @isTest
    public static void fetchActivationCode_Test(){
        String errMsg = '';
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Map<String,String> licenseFieldValues = new Map<String,String>();     
        licenseFieldValues.put('Sales_License_Product__c', prod1.Id);      
        licenseFieldValues.put('Sales_License_Order__c',o.id);      
        licenseFieldValues.put('Sales_License_Order_Product__c',oi.id);      
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues);      
        insert lic;
        System.Test.startTest();            
        Sales_fetchActivationCode_Bot.LicenseInput Input = new Sales_fetchActivationCode_Bot.LicenseInput();
        Input.licenseObject = lic;
        List<Sales_fetchActivationCode_Bot.LicenseOutput> result = new List<Sales_fetchActivationCode_Bot.LicenseOutput>();   
        try{
            result = Sales_fetchActivationCode_Bot.getHostDetails(new List<Sales_fetchActivationCode_Bot.LicenseInput>{Input});
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: askHostReassignment_Bot_Test - Test method for Apex Class -> Sales_askHostReassignment_Bot
    * ****************************/
    @isTest
    public static void askHostReassignment_Bot_Test(){
        String errMsg = '';
        Sales_askHostReassignment_Bot.HostInput Input1 = new Sales_askHostReassignment_Bot.HostInput();
        Sales_askHostReassignment_Bot.HostInput Input2 = new Sales_askHostReassignment_Bot.HostInput();
        Sales_askHostReassignment_Bot.HostInput Input3 = new Sales_askHostReassignment_Bot.HostInput();
        List<Sales_askHostReassignment_Bot.HostOutput> result = new List<Sales_askHostReassignment_Bot.HostOutput>();     
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        insert new List<Core_Product_Ext_Attribute__c>{prodExt1};
            Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert new List<Product2>{prod1};
            Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord();
        insert hostRec1;
        Map<String,String> licenseFieldValues = new Map<String,String>();   
        licenseFieldValues.put('Sales_License_Host_Node_Id__c', hostRec1.Id);
        licenseFieldValues.put('Sales_License_Order__c', o.Id);
        licenseFieldValues.put('Sales_License_Order_Product__c', oi.Id);
        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues); 
        insert lic1;
        Input1.hostObject = hostRec1;
        try{
            Test.startTest();
            result = Sales_askHostReassignment_Bot.askForhostReassigment(new List<Sales_askHostReassignment_Bot.HostInput>{Input1});
            Test.stopTest();
        }catch(Exception e){
            errMsg = e.getMessage();
        }
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: FetchLicenses_Rehosting_Bot_Test - Test method for Apex Class -> Sales_FetchLicenses_Rehosting_Bot
    * ****************************/
    @isTest
    public static void FetchLicenses_Rehosting_Bot_Test(){
        String errMsg = '';
        Sales_FetchLicenses_Rehosting_Bot.HostInput Input1 = new Sales_FetchLicenses_Rehosting_Bot.HostInput();
        List<List<Sales_License__c>> result;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord();
        insert hostRec1;
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Map<String,String> licenseFieldValues = new Map<String,String>();   
        licenseFieldValues.put('Sales_License_Host_Node_Id__c', hostRec1.Id);
        licenseFieldValues.put('Sales_License_Product__c', prod1.Id);
        licenseFieldValues.put('Sales_License_Order__c',o.id);
        licenseFieldValues.put('Sales_License_Order_Product__c',oi.id);
        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues); 
        insert lic1;
        Input1.hostObject = hostRec1;
        System.Test.startTest();
        try{
            result = Sales_FetchLicenses_Rehosting_Bot.fetchLicesesbyRehost(new List<Sales_FetchLicenses_Rehosting_Bot.HostInput>{Input1});             
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: GetLicenseActivationForRehost_Bot_Test - Test method for Apex Class -> Sales_GetLicenseActivationForRehost_Bot
    * ****************************/
    @isTest
    public static void GetLicenseActivationForRehost_Bot_Test(){
        String errMsg = '';
        Sales_GetLicenseActivationForRehost_Bot.LicenseInput Input1 = new Sales_GetLicenseActivationForRehost_Bot.LicenseInput();
        List<Sales_GetLicenseActivationForRehost_Bot.LicenseOutput> result = new List<Sales_GetLicenseActivationForRehost_Bot.LicenseOutput>();   
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert con;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Map<String,String> licenseFieldValues = new Map<String,String>();   
        licenseFieldValues.put('Sales_License_Product__c', prod1.Id);
        licenseFieldValues.put('Sales_License_Primary_Admin_Contact__c', con.Id );
        licenseFieldValues.put('Sales_License_Order__c', o.id);
        licenseFieldValues.put('Sales_License_Order_Product__c', oi.Id );
        Sales_License__c l =  Sales_TestDataFactory.createLicenseRecord(licenseFieldValues); 
        insert l;
        Input1.licenseObject = l;                      
        System.Test.startTest();
        try{
            result = Sales_GetLicenseActivationForRehost_Bot.getHostDetails(new List<Sales_GetLicenseActivationForRehost_Bot.LicenseInput>{Input1});             
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
* Developer Name : Jeebika Bishoyi
* Test method: getHostDetails - Test method for Apex Class -> Sales_GetHostType_Bot
* ****************************/
    @isTest
    public static void Sales_GetHostType_Bot_Test(){
        String errMsg = '';
        Sales_GetHostType_Bot.HostinfoInput Input1 = new Sales_GetHostType_Bot.HostinfoInput();
        List<Sales_GetHostType_Bot.hostinformationOutput> result = new List<Sales_GetHostType_Bot.hostinformationOutput>();
        Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord();
        insert hostRec1;
        Input1.hostinformationObject=hostRec1;
        System.Test.startTest();
        try{
            result = Sales_GetHostType_Bot.getHostDetails(new List<Sales_GetHostType_Bot.HostinfoInput>{Input1});             
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
* Developer Name : Shivam Vishwakarma
* Test method: SearchLicenses_Rehosting_Bot_Test - Test method for Apex Class -> Sales_SearchLicenses_Rehosting_Bot
* ****************************/
    @isTest
    public static void SearchLicenses_Rehosting_Bot_Test(){
        String errMsg = '';
        Sales_SearchLicenses_Rehosting_Bot.HostInput Input1 = new Sales_SearchLicenses_Rehosting_Bot.HostInput();
        List<List<Sales_License__c>> result;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord();
        insert hostRec1;
        Map<String,String> licenseFieldValues = new Map<String,String>();   
        licenseFieldValues.put('Sales_License_Host_Node_Id__c', hostRec1.Id);
        licenseFieldValues.put('Sales_License_Order_Product__c',oi.id);
        licenseFieldValues.put('Sales_License_Order__c',o.id);
        licenseFieldValues.put('Sales_License_Product__c', prod1.Id);
        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues); 
        insert lic1;
        Input1.hostObject = hostRec1;
        Input1.sproductName = (prod1.Name).trim();
        System.Test.startTest();
        try{
            result = Sales_SearchLicenses_Rehosting_Bot.getLicenseDetails(new List<Sales_SearchLicenses_Rehosting_Bot.HostInput>{Input1});             
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
* Developer Name : Shivam Vishwakarma
* Test method: TemporaryLicense_NICID_Test - Test method for Apex Class -> Sales_TemporaryLicense_NICID
* ****************************/
    @isTest
    public static void TemporaryLicense_NICID_Test(){
        String errMsg = '';
        Sales_TemporaryLicense_NICID.NICIDInput Input1 = new Sales_TemporaryLicense_NICID.NICIDInput();
        List<Sales_TemporaryLicense_NICID.Result> result;
        Sales_Host__c hostRec = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{
            'Sales_License_Type__c' => 'FLOAT','Sales_Host_Is_Created_From_Custom_Page__c'=>'true'
                });  
        insert hostRec;
        Input1.HostData = hostRec;
        Input1.NICid = 'ABCD1234EF27';
        System.Test.startTest();
        try{
            result = Sales_TemporaryLicense_NICID.addTemporaryNICIdDetails(new List<Sales_TemporaryLicense_NICID.NICIDInput>{Input1});             
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: GetHostRecordDetails_Bot_Test - Test method for Apex Class -> Sales_GetHostRecordDetails_Bot
    * ****************************/
    @isTest
    public static void GetHostRecordDetails_Bot_Test(){
        String errMsg = '';
        Sales_GetHostRecordDetails_Bot.HostInput Input1 = new Sales_GetHostRecordDetails_Bot.HostInput();
        Sales_GetHostRecordDetails_Bot.HostInput Input2 = new Sales_GetHostRecordDetails_Bot.HostInput();
        Sales_GetHostRecordDetails_Bot.HostInput Input3 = new Sales_GetHostRecordDetails_Bot.HostInput();
        List<Sales_GetHostRecordDetails_Bot.HostOutput> result;         
        Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord(); 
        Sales_Host__c hostRec2 = Sales_TestDataFactory.createComputerRecord(); 
        Sales_Host__c hostRec3 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_License_Type__c' => 'FLOAT','Sales_Host_Is_Created_From_Custom_Page__c'=>'true'});
        insert new List<Sales_Host__c>{hostRec1,hostRec2,hostRec3};
            Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','NEUTRAL');
        Core_Product_Ext_Attribute__c prodExt2 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt2.put('Core_SW_Lic_Type_Nm__c','FIXED');
        Core_Product_Ext_Attribute__c prodExt3 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt3.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        insert new List<Core_Product_Ext_Attribute__c>{prodExt1,prodExt2,prodExt3};
            Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        Product2 prod2 = Sales_TestDataFactory.createProduct();
        prod2.put('Core_Product_Ext_Attribute_Id__c',prodExt2.Id);
        Product2 prod3 = Sales_TestDataFactory.createProduct();
        prod3.put('Core_Product_Ext_Attribute_Id__c',prodExt3.Id);
        insert new List<Product2>{prod1,prod2,prod3};
            Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec1.Id, 'Sales_License_Product__c' =>  prod1.Id ,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id  
                }); 
        Sales_License__c lic2 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec2.Id, 'Sales_License_Product__c' =>  prod2.Id ,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id  
                }); 
        Sales_License__c lic3 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec3.Id, 'Sales_License_Product__c' =>  prod3.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id   
                }); 
        insert new List<Sales_License__c>{lic1,lic2,lic3};
            Input1.hostObject = hostRec1;
        Input1.Host_LicenseType_New = 'FIXED';
        Input2.hostObject = hostRec2;
        Input2.Host_LicenseType_New = 'FIXED';
        Input3.hostObject = hostRec3;
        Input3.Host_LicenseType_New = 'FLOAT';
        System.Test.startTest();
        try{
            result = Sales_GetHostRecordDetails_Bot.getHostRecordDetails(new List<Sales_GetHostRecordDetails_Bot.HostInput>{Input1});           
            result = Sales_GetHostRecordDetails_Bot.getHostRecordDetails(new List<Sales_GetHostRecordDetails_Bot.HostInput>{Input2});           
            result = Sales_GetHostRecordDetails_Bot.getHostRecordDetails(new List<Sales_GetHostRecordDetails_Bot.HostInput>{Input3});           
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: UpdateHostRecords_Bot_Test - Test method for Apex Class -> Sales_UpdateHostRecords_Bot
    * ****************************/
    @isTest
    public static void UpdateHostRecords_Bot_Test(){
        String errMsg = '';
        Sales_UpdateHostRecords_Bot.ComputerInput Input1 = new Sales_UpdateHostRecords_Bot.ComputerInput();
        Sales_UpdateHostRecords_Bot.ComputerInput Input2 = new Sales_UpdateHostRecords_Bot.ComputerInput();
        Sales_UpdateHostRecords_Bot.ComputerInput Input3 = new Sales_UpdateHostRecords_Bot.ComputerInput();
        Sales_UpdateHostRecords_Bot.ComputerInput Input4 = new Sales_UpdateHostRecords_Bot.ComputerInput();
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        insert new List<Core_Product_Ext_Attribute__c>{prodExt1};
            Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert new List<Product2>{prod1};
            Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord(); 
        Sales_Host__c hostRec2 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Computer_Type__c' => 'GUARD ID', 'Name' => 'T000096327','Sales_Host_Is_Created_From_Custom_Page__c'=>'true'}); 
        Sales_Host__c hostRec3 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_License_Type__c' => 'FLOAT', 'Sales_Computer_Type__c' => 'HOST ID', 'Name' => '3492EFBD','Sales_Host_Is_Created_From_Custom_Page__c'=>'true'});
        Sales_Host__c hostRec4 = Sales_TestDataFactory.createComputerRecord(); 
        insert new List<Sales_Host__c>{hostRec1,hostRec2,hostRec3,hostRec4};
            Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
                'Sales_License_Host_Node_Id__c' => hostRec1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                    }); 
        Sales_License__c lic2 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec2.Id ,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                }); 
        Sales_License__c lic3 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec3.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                }); 
        Sales_License__c lic4 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec4.Id, 'Sales_License_Avbl_Rehost_Nbr__c' => '0','Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                }); 
        insert new List<Sales_License__c>{lic1,lic2,lic3,lic4};
            Input1.hostData = hostRec1;
        Input1.Sales_ComputerName_for_New_Computer = 'ABC1';
        Input1.ComputerType_for_NewComputer = 'NIC ID';
        Input1.Host_LicenseType = 'FIXED';
        Input1.NIC_ID_or_Guard_ID = 'BBB444000AAF';
        Input1.Companion_Server1_ID = 'BBB444888AAF';
        Input1.Companion_Server2_ID = 'BBB444222AAF';
        Input2.hostData = hostRec2;
        Input2.Sales_ComputerName_for_New_Computer = 'ABC2';
        Input2.ComputerType_for_NewComputer = 'GUARD ID';
        Input2.Host_LicenseType = 'FIXED';
        Input2.Guard_ID = 'T999936279';
        Input3.hostData = hostRec3;
        Input3.Sales_ComputerName_for_New_Computer = 'ABC3';
        Input3.ComputerType_for_NewComputer = 'HOST ID';
        Input3.Host_LicenseType = 'FLOAT';
        Input3.Host_ID_or_Guard_ID = '99936279';
        Input3.Redundant_Server1_ID ='BBB444000AAF';
        Input3.Redundant_Server2_ID ='BBB444000AAF';
        Input4.hostData = hostRec4;
        Input4.Sales_ComputerName_for_New_Computer = 'ABC4';
        Input4.ComputerType_for_NewComputer = 'NIC ID';
        Input4.Host_LicenseType = 'FIXED';
        Input4.NIC_ID_or_Guard_ID = 'BBB444537AAF';
        System.Test.startTest();
        try{
            Sales_UpdateHostRecords_Bot.createComputerDetails(new List<Sales_UpdateHostRecords_Bot.ComputerInput>{Input4}); 
            Sales_UpdateHostRecords_Bot.createComputerDetails(new List<Sales_UpdateHostRecords_Bot.ComputerInput>{Input1});           
            Sales_UpdateHostRecords_Bot.createComputerDetails(new List<Sales_UpdateHostRecords_Bot.ComputerInput>{Input2});           
            Sales_UpdateHostRecords_Bot.createComputerDetails(new List<Sales_UpdateHostRecords_Bot.ComputerInput>{Input3});    
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: GetCompanionLicenseDetails_Bot_Test - Test method for Apex Class -> Sales_GetCompanionLicenseDetails_Bot
    * ****************************/
    @isTest
    public static void GetCompanionLicenseDetails_Bot_Test(){
        String errMsg = '';
        Sales_GetCompanionLicenseDetails_Bot.ContactInput Input1 = new Sales_GetCompanionLicenseDetails_Bot.ContactInput();
        List<List<Sales_Host__c>> result;         
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostObj = Sales_TestDataFactory.createComputerRecord();
        insert hostObj;
        Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id}); 
        insert licAdmDlg;
        System.Test.startTest();
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{'Sales_License_Host_Node_Id__c'=>hostObj.Id , 'Sales_License_Primary_Admin_Contact__c'=>con2.Id, 'Sales_License_Product__c'=>prod1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id});                                                                                                           
        insert lic;
        Input1.scontactId = con2.Id;      
        try{
            result = Sales_GetCompanionLicenseDetails_Bot.getHostDetails(new List<Sales_GetCompanionLicenseDetails_Bot.ContactInput>{Input1});             
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: GetComputerDetailsForCompanion_bot_Test - Test method for Apex Class -> Sales_GetComputerDetailsForCompanion_bot
    * ****************************/
    @isTest
    public static void GetComputerDetailsForCompanion_bot_Test(){
        String errMsg = '';
        Sales_GetComputerDetailsForCompanion_bot.ComputerInputFixed Input1 = new Sales_GetComputerDetailsForCompanion_bot.ComputerInputFixed();
        List<List<Sales_Host__c>> result;         
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostObj = Sales_TestDataFactory.createComputerRecord();
        insert hostObj;
        Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id}); 
        insert licAdmDlg;
        System.Test.startTest();
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{'Sales_License_Host_Node_Id__c'=>hostObj.Id , 'Sales_License_Primary_Admin_Contact__c'=>con2.Id, 'Sales_License_Product__c'=>prod1.Id, 'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id});                                                                                                           
        insert lic; 
        Input1.scontactIdFixed = con2.Id;      
        Input1.scomputerNameFixed = (hostObj.Name).trim();
        try{
            result = Sales_GetComputerDetailsForCompanion_bot.getDetailsonSearchforCompanion(new List<Sales_GetComputerDetailsForCompanion_bot.ComputerInputFixed>{Input1});             
            String hostId = Sales_GetComputerDetailsForCompanion_bot.getLicenseHostId(lic.Id);
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: GetComputerDetails_Bot_Test - Test method for Apex Class -> Sales_GetComputerDetails_Bot
    * ****************************/
    @isTest
    public static void GetComputerDetails_Bot_Test(){
        String errMsg = '';
        Sales_GetComputerDetails_Bot.ComputerInput Input1 = new Sales_GetComputerDetails_Bot.ComputerInput();
        List<List<Sales_Host__c>> result;         
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostObj = Sales_TestDataFactory.createComputerRecord();
        insert hostObj;
        Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id}); 
        insert licAdmDlg;
        System.Test.startTest();
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{'Sales_License_Host_Node_Id__c'=>hostObj.Id , 'Sales_License_Primary_Admin_Contact__c'=>con2.Id, 'Sales_License_Product__c'=>prod1.Id, 'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id});                                                                                                           
        insert lic; 
        Input1.sContactId = con2.Id;      
        Input1.scomputerName = (hostObj.Name).trim();
        Input1.sActivationCode = lic.Id;
        try{
            result = Sales_GetComputerDetails_Bot.getComputerDetailsonSearch(new List<Sales_GetComputerDetails_Bot.ComputerInput>{Input1});   
            List<Sales_Host__c> hostlist = Sales_GetComputerDetails_Bot.retriveComputerDetails((hostObj.Name).trim());
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: GetComputerList_Rehosting_Bot_Test - Test method for Apex Class -> Sales_GetComputerList_Rehosting_Bot
    * ****************************/
    @isTest
    public static void GetComputerList_Rehosting_Bot_Test(){
        String errMsg = '';
        Sales_GetComputerList_Rehosting_Bot.ContactInput Input1 = new Sales_GetComputerList_Rehosting_Bot.ContactInput();
        List<List<Sales_Host__c>> result;         
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostObj = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Contact__c'=>con2.Id,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true'});
        insert hostObj;
        Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id}); 
        insert licAdmDlg;
        System.Test.startTest();
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{'Sales_License_Host_Node_Id__c'=>hostObj.Id , 'Sales_License_Primary_Admin_Contact__c'=>con2.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id});                                                                                                           
        insert lic; 
        Input1.scontactId = con2.Id;              
        try{
            result = Sales_GetComputerList_Rehosting_Bot.getHostDetails(new List<Sales_GetComputerList_Rehosting_Bot.ContactInput>{Input1});   
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: GetComputers_TemporaryLicenses_Bot_Test - Test method for Apex Class -> Sales_GetComputers_TemporaryLicenses_Bot
    * ****************************/
    @isTest
    public static void GetComputers_TemporaryLicenses_Bot_Test(){
        String errMsg = '';
        Sales_GetComputers_TemporaryLicenses_Bot.ContactInput Input1 = new Sales_GetComputers_TemporaryLicenses_Bot.ContactInput();
        List<List<Sales_Host__c>> result;         
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostObj = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Contact__c'=>con2.Id , 'Sales_License_Type__c'=>'FLOAT','Sales_Host_Is_Created_From_Custom_Page__c'=>'true'});
        insert hostObj;
        Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id}); 
        insert licAdmDlg;
        System.Test.startTest();
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{'Sales_License_Host_Node_Id__c'=>hostObj.Id , 'Sales_License_Primary_Admin_Contact__c'=>con2.Id, 'Sales_License_Product__c'=>prod1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id});                                                                                                           
        insert lic; 
        Input1.scontactId = con2.Id;              
        try{
            result = Sales_GetComputers_TemporaryLicenses_Bot.getActiveFloattypeHostDetails(new List<Sales_GetComputers_TemporaryLicenses_Bot.ContactInput>{Input1});   
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: SearchComputerDetailsRehost_Bot_Test - Test method for Apex Class -> Sales_SearchComputerDetailsRehost_Bot
    * ****************************/
    @isTest
    public static void SearchComputerDetailsRehost_Bot_Test(){
        String errMsg = '';
        Sales_SearchComputerDetailsRehost_Bot.ComputerInput Input1 = new Sales_SearchComputerDetailsRehost_Bot.ComputerInput();
        Sales_SearchComputerDetailsRehost_Bot.ComputerInput Input2 = new Sales_SearchComputerDetailsRehost_Bot.ComputerInput();
        Sales_SearchComputerDetailsRehost_Bot.ComputerInput Input3 = new Sales_SearchComputerDetailsRehost_Bot.ComputerInput();
        List<List<Sales_Host__c>> result;         
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id}); 
        insert licAdmDlg;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','NEUTRAL');
        Core_Product_Ext_Attribute__c prodExt2 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt2.put('Core_SW_Lic_Type_Nm__c','FIXED');
        Core_Product_Ext_Attribute__c prodExt3 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt3.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        insert new List<Core_Product_Ext_Attribute__c>{prodExt1,prodExt2,prodExt3};
            Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        Product2 prod2 = Sales_TestDataFactory.createProduct();
        prod2.put('Core_Product_Ext_Attribute_Id__c',prodExt2.Id);
        Product2 prod3 = Sales_TestDataFactory.createProduct();
        prod3.put('Core_Product_Ext_Attribute_Id__c',prodExt3.Id);
        insert new List<Product2>{prod1,prod2,prod3};    
            System.Test.startTest();
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Contact__c'=>con2.Id,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true'}); 
        Sales_Host__c hostRec2 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Contact__c'=>con2.Id,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true'}); 
        Sales_Host__c hostRec3 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_License_Type__c' => 'FLOAT', 'Sales_Contact__c'=>con2.Id,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true'});
        insert new List<Sales_Host__c>{hostRec1,hostRec2,hostRec3};
            Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
                'Sales_License_Host_Node_Id__c' => hostRec1.Id, 'Sales_License_Primary_Admin_Contact__c'=>con2.Id, 'Sales_License_Product__c'=>prod1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                    }); 
        Sales_License__c lic2 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec2.Id, 'Sales_License_Primary_Admin_Contact__c'=>con2.Id, 'Sales_License_Product__c'=>prod2.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                }); 
        Sales_License__c lic3 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec3.Id, 'Sales_License_Primary_Admin_Contact__c'=>con2.Id, 'Sales_License_Product__c'=>prod3.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });         
        insert new List<Sales_License__c>{lic1,lic2,lic3};       
            Input1.sContactId = con2.Id;  
        Input1.scomputerName = hostRec1.Sales_Computer_Name_Txt__c;
        Input1.sActivationCode = lic1.Sales_License_Activation_Code__c;
        Input1.licenseId = lic1.Id;
        Input2.sContactId = con2.Id;  
        Input2.scomputerName = hostRec2.Sales_Computer_Name_Txt__c;
        Input2.sActivationCode = lic2.Sales_License_Activation_Code__c;
        Input2.licenseId = lic2.Id;
        Input3.sContactId = con2.Id;  
        Input3.scomputerName = hostRec3.Sales_Computer_Name_Txt__c;
        Input3.sActivationCode = lic3.Sales_License_Activation_Code__c;
        Input3.licenseId = lic3.Id;
        try{
            result = Sales_SearchComputerDetailsRehost_Bot.getComputerDetailsonSearch(new List<Sales_SearchComputerDetailsRehost_Bot.ComputerInput>{Input1});   
            result = Sales_SearchComputerDetailsRehost_Bot.getComputerDetailsonSearch(new List<Sales_SearchComputerDetailsRehost_Bot.ComputerInput>{Input2});  
            result = Sales_SearchComputerDetailsRehost_Bot.getComputerDetailsonSearch(new List<Sales_SearchComputerDetailsRehost_Bot.ComputerInput>{Input3});  
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: SearchComputerList_Rehosting_Bot_Test - Test method for Apex Class -> Sales_SearchComputerList_Rehosting_Bot
    * ****************************/
    @isTest
    public static void SearchComputerList_Rehosting_Bot_Test(){
        String errMsg = '';
        Sales_SearchComputerList_Rehosting_Bot.ContactInput Input1 = new Sales_SearchComputerList_Rehosting_Bot.ContactInput();
        List<List<Sales_Host__c>> result;         
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        insert new List<Core_Product_Ext_Attribute__c>{prodExt1};
            Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert new List<Product2>{prod1};
            Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        System.Test.startTest();
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_Host__c hostObj = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Contact__c'=>con2.Id,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true'});
        insert hostObj;
        Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id}); 
        insert licAdmDlg;
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{'Sales_License_Host_Node_Id__c'=>hostObj.Id , 'Sales_License_Primary_Admin_Contact__c'=>con2.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id});                                                                                                           
        insert lic; 
        Input1.scontactId = con2.Id;   
        Input1.computername = (hostObj.Name).trim();
        try{
            result = Sales_SearchComputerList_Rehosting_Bot.getHostDetails(new List<Sales_SearchComputerList_Rehosting_Bot.ContactInput>{Input1});   
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: SearchComputers_Temporary_Bot_Test - Test method for Apex Class -> Sales_SearchComputers_Temporary_Bot
    * ****************************/
    @isTest
    public static void SearchComputers_Temporary_Bot_Test(){
        String errMsg = '';
        Sales_SearchComputers_Temporary_Bot.ContactInput Input1 = new Sales_SearchComputers_Temporary_Bot.ContactInput();
        List<List<Sales_Host__c>> result;         
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        insert new List<Core_Product_Ext_Attribute__c>{prodExt1};
            Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert new List<Product2>{prod1};
            Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_Host__c hostObj = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Contact__c'=>con2.Id, 'Sales_License_Type__c' => 'FLOAT','Sales_Host_Is_Created_From_Custom_Page__c'=>'true'});
        insert hostObj;
        System.Test.startTest();
        Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id}); 
        insert licAdmDlg;
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{'Sales_License_Host_Node_Id__c'=>hostObj.Id , 'Sales_License_Primary_Admin_Contact__c'=>con2.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id});                                                                                                           
        insert lic; 
        Input1.scontactId = con2.Id;   
        Input1.computername = (hostObj.Name).trim();
        try{
            result = Sales_SearchComputers_Temporary_Bot.getHostDetails(new List<Sales_SearchComputers_Temporary_Bot.ContactInput>{Input1});   
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: checkHostLicenseType_Bot_Test - Test method for Apex Class -> Sales_checkHostLicenseType_Bot
    * ****************************/
    @isTest
    public static void checkHostLicenseType_Bot_Test(){
        String errMsg = '';
        Sales_checkHostLicenseType_Bot.ComputerInput Input1 = new Sales_checkHostLicenseType_Bot.ComputerInput();
        Sales_checkHostLicenseType_Bot.ComputerInput Input2 = new Sales_checkHostLicenseType_Bot.ComputerInput();
        Sales_checkHostLicenseType_Bot.ComputerInput Input3 = new Sales_checkHostLicenseType_Bot.ComputerInput();        
        List<Sales_checkHostLicenseType_Bot.Result> result;         
        Core_Product_Ext_Attribute__c prodExt2 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt2.put('Core_SW_Lic_Type_Nm__c','FIXED');
        Core_Product_Ext_Attribute__c prodExt3 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt3.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        insert new List<Core_Product_Ext_Attribute__c>{prodExt2,prodExt3};
            Product2 prod2 = Sales_TestDataFactory.createProduct();
        prod2.put('Core_Product_Ext_Attribute_Id__c',prodExt2.Id);
        Product2 prod3 = Sales_TestDataFactory.createProduct();
        prod3.put('Core_Product_Ext_Attribute_Id__c',prodExt3.Id);
        insert new List<Product2>{prod2,prod3};   
            System.Test.startTest();
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod2.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod2.Id, standardPrice.Id);
        Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Companion_Server1_Txt__c'=>'ABB444888AAF', 'Sales_Companion_Server2_Txt__c'=>'CBB444888AAF','Sales_Host_Is_Created_From_Custom_Page__c'=>'true'}); 
        Sales_Host__c hostRec2 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{
            'Sales_License_Type__c' => 'FLOAT', 'Sales_Computer_Type__c' => 'HOST ID', 'Name' => '3492EFBD', 'Sales_Redundant_Server1_Txt__c'=>'ABB44487' , 'Sales_Redundant_Server2_Txt__c'=>'ABB44485','Sales_Host_Is_Created_From_Custom_Page__c'=>'true'
                });
        Sales_Host__c hostRec3 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Companion_Server1_Txt__c'=>'ABB444888AAF', 'Sales_Companion_Server2_Txt__c'=>'CBB444888AAF','Sales_Host_Is_Created_From_Custom_Page__c'=>'true'}); 
        insert new List<Sales_Host__c>{hostRec1,hostRec2,hostRec3};
            Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
                'Sales_License_Host_Node_Id__c' => hostRec1.Id, 'Sales_License_Product__c' => prod2.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                    }); 
        Sales_License__c lic2 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec2.Id , 'Sales_License_Product__c' => prod3.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                }); 
        Sales_License__c lic3 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec3.Id, 'Sales_License_Avbl_Rehost_Nbr__c' => '0', 'Sales_License_Product__c' => prod2.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                }); 
        insert new List<Sales_License__c>{lic1,lic2,lic3};
            Input1.hostData = hostRec1;        
        Input1.Companion_Server1_ID = 'BBB444888AAF';
        Input1.Companion_Server2_ID = 'BBB444222AAF';        
        Input2.hostData = hostRec2;        
        Input2.Redundant_Server1_ID ='BBB44400';
        Input2.Redundant_Server2_ID ='BBB44AAE';
        Input3.hostData = hostRec3;      
        Input3.Companion_Server1_ID = 'BBB444888AAF';
        Input3.Companion_Server2_ID = 'BBB444222AAF';        
        try{         
            result = Sales_checkHostLicenseType_Bot.createComputerDetails(new List<Sales_checkHostLicenseType_Bot.ComputerInput>{Input1});           
            result = Sales_checkHostLicenseType_Bot.createComputerDetails(new List<Sales_checkHostLicenseType_Bot.ComputerInput>{Input2});           
            result = Sales_checkHostLicenseType_Bot.createComputerDetails(new List<Sales_checkHostLicenseType_Bot.ComputerInput>{Input3});    
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: CreateCompanionHost_bot_Test - Test method for Apex Class -> Sales_CreateCompanionHost_bot
    * ****************************/
    @isTest
    public static void CreateCompanionHost_bot_Test(){
        String errMsg = '';
        Sales_CreateCompanionHost_bot.CompanionComputerInput Input1 = new Sales_CreateCompanionHost_bot.CompanionComputerInput();
        Sales_CreateCompanionHost_bot.CompanionComputerInput Input2 = new Sales_CreateCompanionHost_bot.CompanionComputerInput();       
        List<Sales_CreateCompanionHost_bot.Result> result;         
        Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Companion_Server1_Txt__c'=>'ABB444888AAF', 'Sales_Companion_Server2_Txt__c'=>'CBB444888AAF','Sales_Host_Is_Created_From_Custom_Page__c'=>'true'}); 
        Sales_Host__c hostRec2 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Companion_Server1_Txt__c'=>'ABB444888AAF', 'Sales_Companion_Server2_Txt__c'=>'CBB444888AAF','Sales_Host_Is_Created_From_Custom_Page__c'=>'true'}); 
        insert new List<Sales_Host__c>{hostRec1,hostRec2};
            Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        System.Test.startTest();
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec1.Id, 'Sales_License_Product__c' => prod1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                }); 
        Sales_License__c lic2 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec2.Id, 'Sales_License_Avbl_Rehost_Nbr__c' => '0',  'Sales_License_Product__c' => prod1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                }); 
        insert new List<Sales_License__c>{lic1,lic2};
            Input1.hostData = hostRec1;        
        Input1.Companion_Server1_ID = 'BBB444888AAF';
        Input1.Companion_Server2_ID = 'BBB444222AAF';        
        Input2.hostData = hostRec2;      
        Input2.Companion_Server1_ID = 'BBB444888AAF';
        Input2.Companion_Server2_ID = 'BBB444222AAF';        
        try{         
            result = Sales_CreateCompanionHost_bot.createComputerDetails(new List<Sales_CreateCompanionHost_bot.CompanionComputerInput>{Input1});           
            result = Sales_CreateCompanionHost_bot.createComputerDetails(new List<Sales_CreateCompanionHost_bot.CompanionComputerInput>{Input2});                       
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: FetchLicenseActivationCode_Test - Test method for Apex Class -> Sales_FetchLicenseActivationCode
    * ****************************/
    @isTest
    public static void FetchLicenseActivationCode_Test(){
        String errMsg = '';
        Sales_FetchLicenseActivationCode.LicenseActivationCodeInput Input = new Sales_FetchLicenseActivationCode.LicenseActivationCodeInput();                
        List<Sales_FetchLicenseActivationCode.Result> result;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{ 'Sales_License_Product__c' => prod1.Id ,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id}); 
        insert lic1;
        Input.LicenseData = lic1;
        System.Test.startTest();
        try{         
            result = Sales_FetchLicenseActivationCode.getActivationCode(new List<Sales_FetchLicenseActivationCode.LicenseActivationCodeInput>{Input});                      
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: HostReassign_R_Bot_Test - Test method for Apex Class -> Sales_HostReassign_R_Bot
    * ****************************/
    @isTest
    public static void HostReassign_R_Bot_Test(){
        String errMsg = '';
        Sales_HostReassign_R_Bot.ComputerInput Input1 = new Sales_HostReassign_R_Bot.ComputerInput();
        Sales_HostReassign_R_Bot.ComputerInput Input2 = new Sales_HostReassign_R_Bot.ComputerInput();     
        Sales_HostReassign_R_Bot.ComputerInput Input3 = new Sales_HostReassign_R_Bot.ComputerInput();     
        List<Sales_HostReassign_R_Bot.HostOutput> result;   
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        insert new List<Core_Product_Ext_Attribute__c>{prodExt1};
            Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert new List<Product2>{prod1};
            Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1};
            Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Companion_Server1_Txt__c'=>'ABB444888AAF', 'Sales_Companion_Server2_Txt__c'=>'CBB444888AAF', 'Sales_Contact__c'=>con1.Id,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true'}); 
        Sales_Host__c hostRec2 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Companion_Server1_Txt__c'=>'ABB444878AAF', 'Sales_Companion_Server2_Txt__c'=>'CBB444878AAF', 'Sales_Contact__c'=>con1.Id,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true'}); 
        insert new List<Sales_Host__c>{hostRec1,hostRec2};                      
            Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
                'Sales_License_Host_Node_Id__c' => hostRec1.Id, 'Sales_License_Primary_Admin_Contact__c'=>con1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                    }); 
        Sales_License__c lic2 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec2.Id, 'Sales_License_Primary_Admin_Contact__c'=>con1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                }); 
        Sales_License__c lic3 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec1.Id, 'Sales_License_Avbl_Rehost_Nbr__c' => '0', 'Sales_License_Primary_Admin_Contact__c'=>con1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                }); 
        Sales_License__c lic4 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec1.Id, 'Sales_License_Avbl_Rehost_Nbr__c' => '-1', 'Sales_License_Primary_Admin_Contact__c'=>con1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                }); 
        insert new List<Sales_License__c>{lic1,lic2,lic3,lic4};
            Input1.selecthostObject = hostRec2;        
        Input1.newhosttoassign = hostRec1;
        Input2.selecthostObject = hostRec2;        
        Input2.newhosttoassign = hostRec1;
        Input3.selecthostObject = hostRec2;        
        Input3.newhosttoassign = hostRec1;    
        System.Test.startTest();
        try{         
            result = Sales_HostReassign_R_Bot.createComputerDetails(new List<Sales_HostReassign_R_Bot.ComputerInput>{Input1});           
            result = Sales_HostReassign_R_Bot.createComputerDetails(new List<Sales_HostReassign_R_Bot.ComputerInput>{Input2});     
            result = Sales_HostReassign_R_Bot.createComputerDetails(new List<Sales_HostReassign_R_Bot.ComputerInput>{Input3}); 
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
    }
    /******************************
    * UTILITY METHODS TO SETUP TEST DATA
    * Test Utility Methods added :
    * 1. CalloutMock.class -> respond - To mock respone from Web Service Callout - License File Generation. - Developer Name : Shivam Vishwakarma
    * ****************************/       
    public class LicenseFileGenerationCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"Status" : "Success","Comment" : "License File processed successfully for given Batch Id."}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    /******************************
    * Developer Name : Srishty Sharma
    * Test method: determineHostLicTypeTest - Test method for Apex Class -> Sales_LicenseCheckForReassigning
    * ****************************/
    @isTest
    public static void determineHostLicTypeTest(){
        List<Sales_LicenseCheckForReassigning.LicenseToolTypeInput> licenseTypeInput =new List<Sales_LicenseCheckForReassigning.LicenseToolTypeInput>();
        Sales_LicenseCheckForReassigning.LicenseToolTypeInput licType=new Sales_LicenseCheckForReassigning.LicenseToolTypeInput();
        licType.License_Type_OnLicense='FIXED';
        licenseTypeInput.add(licType);
        Sales_LicenseCheckForReassigning.LicenseToolTypeInput licType1=new Sales_LicenseCheckForReassigning.LicenseToolTypeInput();
        licType1.License_Type_OnLicense='FLOAT';
        licenseTypeInput.add(licType1);
        Sales_LicenseCheckForReassigning.LicenseToolTypeInput licType2=new Sales_LicenseCheckForReassigning.LicenseToolTypeInput();
        licType2.License_Type_OnLicense='NEUTRAL';
        licenseTypeInput.add(licType2);
        List<Sales_LicenseCheckForReassigning.Result> resultList = new List<Sales_LicenseCheckForReassigning.Result>();
        System.Test.startTest();
        resultList=Sales_LicenseCheckForReassigning.determineHostLicType(licenseTypeInput);
        System.Test.stopTest();
        System.assert(resultList.size()>0);
    }  
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: CreateComputerDetailsForRehost_Bot_Test - Test method for Apex Class -> Sales_CreateComputerDetailsForRehost_Bot
    * ****************************/
    @isTest
    public static void CreateComputerDetailsForRehost_Bot_Test(){
        String errMsg = '';
        Sales_CreateComputerDetailsForRehost_Bot.ComputerInput Input1 = new Sales_CreateComputerDetailsForRehost_Bot.ComputerInput();      
        Sales_CreateComputerDetailsForRehost_Bot.ComputerInput Input2 = new Sales_CreateComputerDetailsForRehost_Bot.ComputerInput();   
        Sales_CreateComputerDetailsForRehost_Bot.ComputerInput Input3 = new Sales_CreateComputerDetailsForRehost_Bot.ComputerInput();   
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                    }); 
        insert licAdmDlg;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        Core_Product_Ext_Attribute__c prodExt2 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt2.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        insert new List<Core_Product_Ext_Attribute__c>{prodExt1,prodExt2};
            Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        Product2 prod2 = Sales_TestDataFactory.createProduct();
        prod2.put('Core_Product_Ext_Attribute_Id__c',prodExt2.Id);
        insert new List<Product2>{prod1,prod2};
            Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Contact__c'=>con2.Id,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true'}); 
        Sales_Host__c hostRec2 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{
            'Sales_Contact__c'=>con2.Id, 'Sales_License_Type__c' => 'FLOAT','Sales_Host_Is_Created_From_Custom_Page__c'=>'true'
                }); 
        Sales_Host__c hostRec3 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Contact__c'=>con2.Id}); 
        insert new List<Sales_Host__c>{hostRec1,hostRec2,hostRec3};
            System.Test.startTest();
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec1.Id, 'Sales_License_Primary_Admin_Contact__c'=>con2.Id, 'Sales_License_Product__c'=>prod1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });  
        Sales_License__c lic2 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec2.Id, 'Sales_License_Primary_Admin_Contact__c'=>con2.Id, 'Sales_License_Product__c'=>prod2.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });  
        Sales_License__c lic3 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec3.Id, 'Sales_License_Primary_Admin_Contact__c'=>con2.Id, 'Sales_License_Product__c'=>prod1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });  
        insert new List<Sales_License__c>{lic1,lic2,lic3};       
            Input1.Primary_Admin_Contact = con2.Id;  
        Input1.Sales_ComputerName_for_New_Computer = hostRec1.Sales_Computer_Name_Txt__c;
        Input1.Sales_Activation_Code = lic1.Sales_License_Activation_Code__c;
        Input1.ComputerType_for_NewComputer = 'GUARD ID' ;
        Input1.Host_LicenseType = 'FIXED';
        Input1.Guard_ID = 'T000033399';
        Input1.Companion_Server1_ID = 'T000033399';
        Input1.Companion_Server2_ID = 'T000033399';
        Input1.licenseId=lic1.Id;
        Input2.Primary_Admin_Contact = con2.Id;  
        Input2.Sales_ComputerName_for_New_Computer = hostRec2.Sales_Computer_Name_Txt__c;
        Input2.Sales_Activation_Code = lic2.Sales_License_Activation_Code__c;
        Input2.ComputerType_for_NewComputer = 'HOST ID' ;
        Input2.Host_LicenseType = 'FLOAT';
        Input2.Host_ID_or_Guard_ID = '33399999';
        Input2.Redundant_Server1_ID = 'T000033399';
        Input2.Redundant_Server2_ID = 'T000033399';
        Input2.licenseId=lic2.Id;
        Input3.Primary_Admin_Contact = con2.Id;  
        Input3.Sales_ComputerName_for_New_Computer = hostRec3.Sales_Computer_Name_Txt__c;
        Input3.Sales_Activation_Code = lic3.Sales_License_Activation_Code__c;
        Input3.ComputerType_for_NewComputer = 'NIC ID' ;
        Input3.Host_LicenseType = 'FIXED';
        Input3.NIC_ID_or_Guard_ID = '123456789999';
        Input3.Companion_Server1_ID = 'T000033399';
        Input3.Companion_Server2_ID = 'T000033399';
        Input3.licenseId=lic3.Id;
        try{
            Sales_CreateComputerDetailsForRehost_Bot.createComputerDetails(new List<Sales_CreateComputerDetailsForRehost_Bot.ComputerInput>{Input1}); 
            Sales_CreateComputerDetailsForRehost_Bot.createComputerDetails(new List<Sales_CreateComputerDetailsForRehost_Bot.ComputerInput>{Input2}); 
            Sales_CreateComputerDetailsForRehost_Bot.createComputerDetails(new List<Sales_CreateComputerDetailsForRehost_Bot.ComputerInput>{Input3}); 
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: CreateComputerDetails_Bot_Test - Test method for Apex Class -> Sales_CreateComputerDetails_Bot
    * ****************************/
    @isTest
    public static void CreateComputerDetails_Bot_Test(){
        Sales_CreateComputerDetails_Bot.ComputerInput Input1 = new Sales_CreateComputerDetails_Bot.ComputerInput();      
        Sales_CreateComputerDetails_Bot.ComputerInput Input2 = new Sales_CreateComputerDetails_Bot.ComputerInput();   
        Sales_CreateComputerDetails_Bot.ComputerInput Input3 = new Sales_CreateComputerDetails_Bot.ComputerInput();   
        User u4= createUserWithProfile();
        insert u4;
        Account acc ;
        Contact con1;
        Contact con2;
        Sales_License_Admin_Delegate__c licAdmDlg ;
        System.runAs(u4){ 
            Core_Contact_Bypass_Validation_Rule__c triggerExecList = new Core_Contact_Bypass_Validation_Rule__c();
            triggerExecList.Bypass__c = true;
            insert triggerExecList;
            acc = Sales_TestDataFactory.createDefaultAccount();
            insert acc;
            con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
            con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
            insert new List<Contact>{con1,con2};
                licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                    'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                        }); 
            insert licAdmDlg;
        }
        profile pr=[SELECT Id FROM Profile WHERE Name='System Administrator'];
        PermissionSetLicense pset = [select id from PermissionSetLicense where MasterLabel ='Salesforce CPQ License'];
        UserRole portalRole=[SELECT id, Name FROM userrole where name = 'Admin' limit 1];
        User u = new user();
        u.FirstName = 'testeww';
        u.LastName = 'userww';
        u.Email = 'xyztest24739www2638@intel.com';
        u.Username = 'xyztwwest@testabc.com';
        u.Alias = 'testwwu';
        u.CommunityNickname = 'test.user44';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = pr.id;
        u.LanguageLocaleKey = 'en_US';
        u.UserRoleId = portalRole.Id;   
        insert u;
        System.Test.startTest();
        User u2=createUser_WithSpecificProfile('partneraddhost','parte','Partner','shivamx.vishwakarma@intel.com', con2.Id, true);
        System.runAs(u){
            
            Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
            prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
            Core_Product_Ext_Attribute__c prodExt2 = Sales_TestDataFactory.createProductExternalAttributes();
            prodExt2.put('Core_SW_Lic_Type_Nm__c','FLOAT');
            insert new List<Core_Product_Ext_Attribute__c>{prodExt1,prodExt2};
                Product2 prod1 = Sales_TestDataFactory.createProduct();
            prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
            Product2 prod2 = Sales_TestDataFactory.createProduct();
            prod2.put('Core_Product_Ext_Attribute_Id__c',prodExt2.Id);
            insert new List<Product2>{prod1,prod2};
                System.runAs(u2){
                    TriggerHandler.bypass('Sales_OrderTriggerHandler');
                    TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
                    Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
                    PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
                    OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
                    Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Contact__c'=>con2.Id,'Sales_Computer_Name_Txt__c'=>'QAtestingforduplicate','Sales_Host_Is_Created_From_Custom_Page__c'=>'true'}); 
                    Sales_Host__c hostRec2 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Computer_Name_Txt__c'=>'retest1',
                        'Sales_Contact__c'=>con2.Id, 'Sales_License_Type__c' => 'FLOAT','Sales_Host_Is_Created_From_Custom_Page__c'=>'true'
                        }); 
                    Sales_Host__c hostRec3 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{'Sales_Computer_Name_Txt__c'=>'retest2','Sales_Contact__c'=>con2.Id,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true'}); 
                    TriggerHandler.bypass('Sales_HostTriggerHandler');
                    insert new List<Sales_Host__c>{hostRec1,hostRec2,hostRec3};
                        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
                            'Sales_License_Host_Node_Id__c' => hostRec1.Id, 'Sales_License_Primary_Admin_Contact__c'=>con2.Id, 'Sales_License_Product__c'=>prod1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                                });  
                    Sales_License__c lic2 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
                        'Sales_License_Host_Node_Id__c' => hostRec2.Id, 'Sales_License_Primary_Admin_Contact__c'=>con2.Id, 'Sales_License_Product__c'=>prod2.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                            });  
                    Sales_License__c lic3 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
                        'Sales_License_Host_Node_Id__c' => hostRec3.Id, 'Sales_License_Primary_Admin_Contact__c'=>con2.Id, 'Sales_License_Product__c'=>prod1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                            });  
                    TriggerHandler.bypass('Sales_LicenseTriggerHandler');
                    insert new List<Sales_License__c>{lic1,lic2,lic3};       
                        TriggerHandler.clearAllBypasses();
                    Input1.ContactId = con2.Id;  
                    Input1.Sales_ComputerName_for_New_Computer = hostRec1.Sales_Computer_Name_Txt__c;
                    Input1.LicenseId = lic1.Id;
                    Input1.ComputerType_for_NewComputer = 'GUARD ID' ;
                    Input1.Host_LicenseType = 'FIXED';
                    Input1.Guard_ID = 'T758826360';
                    Input1.Companion_Server1_ID = 'T758826360';
                    Input1.Companion_Server2_ID = 'T758826360';
                    Input2.ContactId = con2.Id;  
                    Input2.Sales_ComputerName_for_New_Computer = hostRec2.Sales_Computer_Name_Txt__c;
                    Input2.LicenseId = lic2.Id;
                    Input2.ComputerType_for_NewComputer = 'HOST ID' ;
                    Input2.Host_LicenseType = 'FLOAT';
                    Input2.Host_ID_or_Guard_ID = '00067897';
                    Input2.Redundant_Server1_ID = '00067897';
                    Input2.Redundant_Server2_ID = '00067897';
                    Input3.ContactId = con2.Id;  
                    Input3.Sales_ComputerName_for_New_Computer = hostRec3.Sales_Computer_Name_Txt__c;
                    Input3.LicenseId = lic3.Id;
                    Input3.ComputerType_for_NewComputer = 'NIC ID' ;
                    Input3.Host_LicenseType = 'FIXED';
                    Input3.NIC_ID_or_Guard_ID = '123456789998';
                    Input3.Companion_Server1_ID = '123456789998';
                    Input3.Companion_Server2_ID = '123456789998';
                    TriggerHandler.bypass('Sales_LicenseTriggerHandler');
                    TriggerHandler.bypass('Sales_HostTriggerHandler');
                    Sales_CreateComputerDetails_Bot.createComputerDetails(new List<Sales_CreateComputerDetails_Bot.ComputerInput>{Input1}); 
                    Sales_CreateComputerDetails_Bot.createComputerDetails(new List<Sales_CreateComputerDetails_Bot.ComputerInput>{Input2}); 
                    Sales_CreateComputerDetails_Bot.createComputerDetails(new List<Sales_CreateComputerDetails_Bot.ComputerInput>{Input3}); 
                    String fix = Sales_CreateComputerDetails_Bot.getHostLicenseType('FIXED');
                    String flo = Sales_CreateComputerDetails_Bot.getHostLicenseType('N-A');
                    String na = Sales_CreateComputerDetails_Bot.getHostLicenseType('FLOAT');
                    String neutral = Sales_CreateComputerDetails_Bot.getHostLicenseType('NEUTRAL');
                }
        }
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: CreateComputer_Rehost_Bot_Test - Test method for Apex Class -> Sales_CreateComputer_Rehost_Bot
    * ****************************/
    @isTest
    public static void CreateComputer_Rehost_Bot_Test(){
        String errMsg = '';
        Sales_CreateComputer_Rehost_Bot.ComputerInput Input1 = new Sales_CreateComputer_Rehost_Bot.ComputerInput();      
        Sales_CreateComputer_Rehost_Bot.ComputerInput Input3 = new Sales_CreateComputer_Rehost_Bot.ComputerInput();
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord();
        Sales_Host__c hostRec3 = Sales_TestDataFactory.createComputerRecord(); 
        insert new List<Sales_Host__c>{hostRec1,hostRec3};
            Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec1.Id,  'Sales_License_Product__c'=>prod1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });
        
        Sales_License__c lic3 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostRec3.Id,  'Sales_License_Product__c'=>prod1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });
        
        insert new List<Sales_License__c>{lic1,lic3};
        Input1.hostObject = hostRec1;
        Input1.Sales_ComputerName_for_New_Computer = hostRec1.Sales_Computer_Name_Txt__c;
        Input1.ComputerType_for_NewComputer = 'GUARD ID' ;
        Input1.Host_LicenseType = 'FIXED';
        Input1.Guard_ID = 'T000032398';
        Input1.NIC_ID_or_Guard_ID = '123456789989';
        Input1.Companion_Server1_ID = 'T000023399';
        Input1.Companion_Server2_ID = 'T000453399';               
        Input3.hostObject = hostRec3;
        Input3.Sales_ComputerName_for_New_Computer = hostRec3.Sales_Computer_Name_Txt__c;
        Input3.ComputerType_for_NewComputer = 'NIC ID' ;
        Input3.Host_LicenseType = 'FLOAT';
        Input3.Host_ID_or_Guard_ID = '234512345678';
        Input3.Companion_Server1_ID = 'T000233399';
        Input3.Companion_Server2_ID = 'T002333399';
      
        System.Test.startTest();
        try{
            Sales_CreateComputer_Rehost_Bot.createComputerDetails(new List<Sales_CreateComputer_Rehost_Bot.ComputerInput>{Input1});            
            Sales_CreateComputer_Rehost_Bot.createComputerDetails(new List<Sales_CreateComputer_Rehost_Bot.ComputerInput>{Input3});
       
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: Order_GetComputerDetails_Test - Test method for Apex Class -> Sales_Order_GetComputerDetails
    * ****************************/
    @isTest
    public static void Order_GetComputerDetails_Test(){
        String errMsg = '';
        Sales_Order_GetComputerDetails.OrderInput Input1 = new Sales_Order_GetComputerDetails.OrderInput();    
        Sales_Order_GetComputerDetails.OrderInput Input2 = new Sales_Order_GetComputerDetails.OrderInput();    
        List<Sales_Order_GetComputerDetails.OrderOutput> result;
        Sales_Host__c hostRec1 = Sales_TestDataFactory.createComputerRecord(); 
        insert hostRec1;
        Input1.Computer_Name = hostRec1.Sales_Computer_Name_Txt__c;
        Input2.Computer_Name = '';
        System.Test.startTest();
        try{
            result = Sales_Order_GetComputerDetails.getOrderStatus(new List<Sales_Order_GetComputerDetails.OrderInput>{Input1}); 
            result = Sales_Order_GetComputerDetails.getOrderStatus(new List<Sales_Order_GetComputerDetails.OrderInput>{Input2}); 
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: RenewSeats_Chatbot_Test - Test method for Apex Class -> Sales_RenewSeats_Chatbot
    * ****************************/
    @isTest
    public static void RenewSeats_Chatbot_Test(){
        String errMsg = '';
        Sales_RenewSeats_Chatbot.LicenseInput Input1 = new Sales_RenewSeats_Chatbot.LicenseInput();       
        List<Sales_RenewSeats_Chatbot.LicenseOutput> result;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        Core_Product_Ext_Attribute__c prodExt2 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt2.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        insert new List<Core_Product_Ext_Attribute__c>{prodExt1,prodExt2};
            Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        Product2 prod2 = Sales_TestDataFactory.createProduct();
        prod2.put('Core_Product_Ext_Attribute_Id__c',prodExt2.Id);
        insert new List<Product2>{prod1,prod2};
            Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id}); 
        Sales_License__c lic2 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id}); 
        insert new List<Sales_License__c>{lic1,lic2};
            Input1.Sales_renewLicId = lic1.Id;
        Input1.Sales_seatsToRenew = '25';   
        System.Test.startTest();
        try{
            result = Sales_RenewSeats_Chatbot.getLicenseForRenewal(new List<Sales_RenewSeats_Chatbot.LicenseInput>{Input1}); 
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: GetLicenseSearchProduct_Bot_Test - Test method for Apex Class -> Sales_GetLicenseSearchProduct_Bot
    * ****************************/
    @isTest
    public static void GetLicenseSearchProduct_Bot_Test(){
        String errMsg = '';
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = acc.Id;
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = acc.Id;
        insert new List<Account>{soldToAccount, shipToAccount};
            Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_GetLicenseSearchProduct_Bot.ProductInput Input1 = new Sales_GetLicenseSearchProduct_Bot.ProductInput();       
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        System.Test.startTest();
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Product__c' => prod1.Id ,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });
        insert lic1;        
        Input1.sproductName = (prod1.Name).trim();
        Input1.contactId = con1.Id;
        Sales_License_Admin_Delegate__c licAdmDlg1 = new Sales_License_Admin_Delegate__c();
        licAdmDlg1.Sales_License_DlgAdmin_Contact__c = con1.Id;
        insert licAdmDlg1;
        try{
            Sales_GetLicenseSearchProduct_Bot.getLicenseDetails(new List<Sales_GetLicenseSearchProduct_Bot.ProductInput>{Input1}); 
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: ApplyRenewal_Chatbot_Test - Test method for Apex Class -> Sales_ApplyRenewal_Chatbot
    * ****************************/
    @isTest
    public static void ApplyRenewal_Chatbot_Test(){
        String errMsg = '';
        Sales_ApplyRenewal_Chatbot.LicenseInput Input1 = new Sales_ApplyRenewal_Chatbot.LicenseInput();       
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                    }); 
        insert licAdmDlg;
        Core_Product_Ext_Attribute__c renewalProdExtbase = Sales_TestDataFactory.createProductExternalAttributes();  
        renewalProdExtbase.put('Core_Prod_Tool_Type_Nm__c','BASE');
        insert renewalProdExtbase;
        Product2 baseProd = Sales_TestDataFactory.createProduct();
        baseProd.put('Core_Product_Ext_Attribute_Id__c',renewalProdExtbase.Id);   
        insert baseProd;
        Core_Product_Ext_Attribute__c renewalProdExt = Sales_TestDataFactory.createProductExternalAttributes();    
        renewalProdExt.put('Core_Foundation_Product_Id__c',baseProd.Id);
        renewalProdExt.put('Core_Prod_Tool_Type_Nm__c','RENEWAL');
        insert renewalProdExt;
        Product2 renewalProd = Sales_TestDataFactory.createProduct();
        renewalProd.put('Core_Product_Ext_Attribute_Id__c',renewalProdExt.Id);   
        insert renewalProd;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        Core_Product_Ext_Attribute__c prodExt2 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt2.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        insert new List<Core_Product_Ext_Attribute__c>{prodExt1,prodExt2};
            Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        Product2 prod2 = Sales_TestDataFactory.createProduct();
        prod2.put('Core_Product_Ext_Attribute_Id__c',prodExt2.Id);
        insert new List<Product2>{prod1,prod2};
            System.Test.startTest();
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Product__c' => renewalProd.Id , 'Sales_License_Primary_Admin_Contact__c'=>con1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });
        insert lic1;
        Input1.Sales_ContactId = con1.Id;
        Input1.Sales_renewLicId = lic1.Id;
        try{
            Sales_ApplyRenewal_Chatbot.getRenewalLicense(new List<Sales_ApplyRenewal_Chatbot.LicenseInput>{Input1}); 
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: getComputerDetails_Test - Test method for Apex Class.MethodName -> Sales_LicenseGenerationUtlity_Chatbot.getComputerDetails
    * ****************************/
    @isTest
    public static void getComputerDetails_Test(){
        String errMsg = '';
        Sales_LicenseGenerationUtlity_Chatbot.LicenseInput Input1 = new Sales_LicenseGenerationUtlity_Chatbot.LicenseInput();
        List<Sales_LicenseGenerationUtlity_Chatbot.LicenseOutput> result;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Product__c' => prod1.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });
        Sales_License__c lic2 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Product__c' => prod1.Id ,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });
        lic2.Sales_License_Maintenance_Exp_Dt__c=null;
        lic2.Sales_License_Expiration_Date_Dt__c=null;
        insert lic1;   
        Input1.Sales_Activation_Code = lic1.Sales_License_Activation_Code__c;
        Input1.Sales_ContactId = null;
        System.Test.startTest();
        try{
            result = Sales_LicenseGenerationUtlity_Chatbot.getComputerDetails(new List<Sales_LicenseGenerationUtlity_Chatbot.LicenseInput>{Input1} , new Map<String,Sales_License__c>{lic1.Sales_License_Activation_Code__c => lic1});
            result = Sales_LicenseGenerationUtlity_Chatbot.getComputerDetails(new List<Sales_LicenseGenerationUtlity_Chatbot.LicenseInput>{Input1} , new Map<String,Sales_License__c>{lic2.Sales_License_Activation_Code__c => lic2});
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Shivam Vishwakarma
    * Test method: getLicenseDetails - Test method for Apex Class.MethodName -> Sales_LicenseGenerationUtlity_Chatbot.getLicenseDetails
    * ****************************/
    @isTest
    public static void getLicenseDetails_Test(){
        String errMsg = '';
        Sales_LicenseGenerationUtlity_Chatbot.LicenseInput Input1 = new Sales_LicenseGenerationUtlity_Chatbot.LicenseInput();
        Sales_LicenseGenerationUtlity_Chatbot.LicenseInput Input2 = new Sales_LicenseGenerationUtlity_Chatbot.LicenseInput();
        List<Sales_LicenseGenerationUtlity_Chatbot.LicenseOutput> result;
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = acc.Id;
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = acc.Id;
        insert new List<Account>{soldToAccount, shipToAccount};
            Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                    }); 
        insert licAdmDlg;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        prodExt1.put('Core_SW_Prod_Temporary_Lic_Allowed_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Rehostable_Ind__c',true);
        prodExt1.put('Core_SW_Prod_Max_Rehost_Cnt__c',3);       
        insert prodExt1 ; 
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostObj1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{ 'Sales_Contact__c'=>con2.Id,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true' });
        insert hostObj1;
        Core_Account_SoldTo_ShipTo_Rel__c soldShipRel = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,Object>{
            'Core_Sold_To_Account__c' => soldToAccount.Id , 'Core_Ship_To_Account__c' => shipToAccount.Id
                });
        insert soldShipRel; 
        Order o1 = Sales_TestDataFactory.createOrder();
        o1.Pricebook2Id = Test.getStandardPricebookId();
        o1.AccountId = acc.Id;
        o1.Sales_Sold_To_Account__c = soldToAccount.Id ;
        o1.Sales_Ship_To_Account__c = shipToAccount.Id;      
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        insert o1;
        TriggerHandler.clearAllBypasses();
        PriceBookEntry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        OrderItem op1 = Sales_TestDataFactory.createOrderItem();
        op1.OrderId = o1.Id;
        op1.Product2Id = prod1.Id;
        op1.PricebookEntryId = pbEntry.Id;
        op1.Sales_Contact__c = con2.Id;
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        insert op1;
        TriggerHandler.clearAllBypasses();
        System.Test.startTest();
        try{
            Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
                'Sales_License_Product__c' => prod1.Id , 'Sales_License_Host_Node_Id__c' => hostObj1.Id ,
                    'Sales_License_Primary_Admin_Contact__c'=>con1.Id, 'Sales_License_Lic_User_Contact_ID__c'=>con2.Id , 
                    'Sales_License_Order__c' => o1.Id , 'Sales_License_Order_Product__c' => op1.Id
                    });       
            Sales_License__c lic2 = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
                'Sales_License_Product__c' => prod1.Id , 'Sales_License_Order__c'=>o1.Id , 'Sales_License_Order_Product__c' => op1.Id
                    });       
            insert new List<Sales_License__c>{lic1,lic2};
                Input1.Sales_Activation_Code  = lic1.Sales_License_Activation_Code__c;
            Input1.Sales_ContactId = con2.Id;
            Input2.Sales_Activation_Code  = lic2.Sales_License_Activation_Code__c;
            Input2.Sales_ContactId = con2.Id;
            result = Sales_LicenseGenerationUtlity_Chatbot.getLicenseDetails(new List<Sales_LicenseGenerationUtlity_Chatbot.LicenseInput>{Input1});
            result = Sales_LicenseGenerationUtlity_Chatbot.getLicenseDetails(new List<Sales_LicenseGenerationUtlity_Chatbot.LicenseInput>{Input2});
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    /******************************
    * Developer Name : Jasmine Narula
    * Test method: Sales_RenewalLogic_Bot - Test method for Apex Class -> Sales_RenewalLogic_Bot
    * ****************************/
    @isTest
    public static void renewalLogicTest(){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = acc.Id;
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = acc.Id;
        insert new List<Account>{soldToAccount, shipToAccount};
            Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                    }); 
        insert licAdmDlg;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        prodExt1.put('Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c', true);
        prodExt1.put('Core_SW_Prod_Temporary_Lic_Allowed_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Rehostable_Ind__c',true);
        prodExt1.put('Core_SW_Prod_Max_Rehost_Cnt__c',3);       
        insert prodExt1;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostObj1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{ 'Sales_Contact__c'=>con2.Id ,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true'});
        insert hostObj1;
        Core_Account_SoldTo_ShipTo_Rel__c soldShipRel = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,Object>{
            'Core_Sold_To_Account__c' => soldToAccount.Id , 'Core_Ship_To_Account__c' => shipToAccount.Id
                });
        insert soldShipRel; 
        Order o1 = Sales_TestDataFactory.createOrder();
        o1.Pricebook2Id = Test.getStandardPricebookId();
        o1.AccountId = acc.Id;
        o1.Sales_Sold_To_Account__c = soldToAccount.Id ;
        o1.Sales_Ship_To_Account__c = shipToAccount.Id;      
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        insert o1;
        TriggerHandler.clearAllBypasses();
        PriceBookEntry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        OrderItem op1 = Sales_TestDataFactory.createOrderItem();
        op1.OrderId = o1.Id;
        op1.Product2Id = prod1.Id;
        op1.PricebookEntryId = pbEntry.Id;
        op1.Sales_Contact__c = con2.Id;
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        insert op1;
        TriggerHandler.clearAllBypasses();
        Map<String,String> licenseFieldValues = new Map<String,String>();     
        licenseFieldValues.put('Sales_License_Product__c', prod1.Id);  
        licenseFieldValues.put('Sales_License_Order_Product__c', op1.Id);
        licenseFieldValues.put('Sales_License_Order__c', o1.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues);      
        insert lic;
        Sales_License__c baselic = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues);  
        insert baselic;
        baselic.Sales_License_Order_Product__c = op1.Id;
        update baselic;
        Sales_License__c blic = [SELECT id,Sales_License_Order_Product__c FROM Sales_License__c WHERE Id=:baselic.Id];
        System.Test.startTest();            
        Sales_ApplyRenewal_Chatbot.licensewrapper wrapper = new Sales_ApplyRenewal_Chatbot.licensewrapper();
        wrapper.Id = baselic.Id;
        Sales_RenewalLogic_Bot.LicenseInput Input = new Sales_RenewalLogic_Bot.LicenseInput();
        Input.noOfSeatsToRenew = '5';
        Input.renewalLic = String.valueof(lic.Id);
        Input.baseLicObj = wrapper;
        Input.contactId=con2.Id;
        Sales_RenewalLogic_Bot.LicenseOutput result = new Sales_RenewalLogic_Bot.LicenseOutput();   
        Sales_RenewalLogic_Bot.getRenewalLicense(new List<Sales_RenewalLogic_Bot.LicenseInput>{Input});
        Sales_License_Order_Product__c op = new Sales_License_Order_Product__c();
        op.Sales_Renewable_license__c = lic.Id;
        List<Sales_License_Order_Product__c> NewLicenseData = new List<Sales_License_Order_Product__c>();
        NewLicenseData= [SELECT Id, Sales_License__c,Sales_Renewable_license__c,Sales_Renewable_license__r.Name from 
                         Sales_License_Order_Product__c where Sales_Renewable_license__c=:lic.Id order by CreatedDate desc LIMIT 1];
        Id newlicenseId=null;
        result.outputString = true;
        if(newlicenseId!=null)
            result.licenseId = newlicenseId;            
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Jasmine Narula
    * Test method: Sales_GetIdFromActivationCode_Bot - Test method for Apex Class -> Sales_GetIdFromActivationCode_Bot
    * ****************************/
    @isTest
    public static void getIdfromActivationCodeTest(){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = acc.Id;
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = acc.Id;
        insert new List<Account>{soldToAccount, shipToAccount};
            Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                    }); 
        insert licAdmDlg;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        prodExt1.put('Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c', true);
        prodExt1.put('Core_SW_Prod_Temporary_Lic_Allowed_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Rehostable_Ind__c',true);
        prodExt1.put('Core_SW_Prod_Max_Rehost_Cnt__c',3);       
        insert prodExt1;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostObj1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{ 'Sales_Contact__c'=>con2.Id ,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true'});
        insert hostObj1;
        Core_Account_SoldTo_ShipTo_Rel__c soldShipRel = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,Object>{
            'Core_Sold_To_Account__c' => soldToAccount.Id , 'Core_Ship_To_Account__c' => shipToAccount.Id
                });
        insert soldShipRel; 
        Order o1 = Sales_TestDataFactory.createOrder();
        o1.Pricebook2Id = Test.getStandardPricebookId();
        o1.AccountId = acc.Id;
        o1.Sales_Sold_To_Account__c = soldToAccount.Id ;
        o1.Sales_Ship_To_Account__c = shipToAccount.Id;      
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        insert o1;
        TriggerHandler.clearAllBypasses();
        PriceBookEntry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        OrderItem op1 = Sales_TestDataFactory.createOrderItem();
        op1.OrderId = o1.Id;
        op1.Product2Id = prod1.Id;
        op1.PricebookEntryId = pbEntry.Id;
        op1.Sales_Contact__c = con2.Id;
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        insert op1;
        TriggerHandler.clearAllBypasses();
        Map<String,String> licenseFieldValues = new Map<String,String>();     
        licenseFieldValues.put('Sales_License_Product__c', prod1.Id);  
        licenseFieldValues.put('Sales_License_Order_Product__c', op1.Id);
        licenseFieldValues.put('Sales_License_Order__c', o1.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues);      
        insert lic;
        Sales_License__c lic1 = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues);      
        insert lic1;
        System.Test.startTest();            
        Sales_GetComputerDetails.wrapperClass unlicensewrapper = new Sales_GetComputerDetails.wrapperClass();
        Sales_ShowRenewalLicense_Bot.licensewrapper wrapper = new Sales_ShowRenewalLicense_Bot.licensewrapper();
        wrapper.Id = lic.Id;
        unlicensewrapper.id = lic1.Id;
        Sales_GetIdFromActivationCode_Bot.LicenseInput Input = new Sales_GetIdFromActivationCode_Bot.LicenseInput();
        Input.licenseObject = wrapper;
        List<Sales_GetIdFromActivationCode_Bot.LicenseOutput> result = new List<Sales_GetIdFromActivationCode_Bot.LicenseOutput>();         
        Sales_GetIdFromActivationCode_Bot.getLicenseId(new List<Sales_GetIdFromActivationCode_Bot.LicenseInput>{Input});
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Jasmine Narula
    * Test method: Sales_GetIdFromActivationCode_Bot - Test method for Apex Class -> Sales_GetIdFromActivationCode_Bot
    * ****************************/
    @isTest
    public static void getIdfromActivationCodeTest1(){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = acc.Id;
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = acc.Id;
        insert new List<Account>{soldToAccount, shipToAccount};
            Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                    }); 
        insert licAdmDlg;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        prodExt1.put('Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c', true);
        prodExt1.put('Core_SW_Prod_Temporary_Lic_Allowed_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Rehostable_Ind__c',true);
        prodExt1.put('Core_SW_Prod_Max_Rehost_Cnt__c',3);       
        insert prodExt1;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostObj1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{ 'Sales_Contact__c'=>con2.Id ,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true'});
        insert hostObj1;
        Core_Account_SoldTo_ShipTo_Rel__c soldShipRel = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,Object>{
            'Core_Sold_To_Account__c' => soldToAccount.Id , 'Core_Ship_To_Account__c' => shipToAccount.Id
                });
        insert soldShipRel; 
        Order o1 = Sales_TestDataFactory.createOrder();
        o1.Pricebook2Id = Test.getStandardPricebookId();
        o1.AccountId = acc.Id;
        o1.Sales_Sold_To_Account__c = soldToAccount.Id ;
        o1.Sales_Ship_To_Account__c = shipToAccount.Id;      
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        insert o1;
        TriggerHandler.clearAllBypasses();
        PriceBookEntry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        OrderItem op1 = Sales_TestDataFactory.createOrderItem();
        op1.OrderId = o1.Id;
        op1.Product2Id = prod1.Id;
        op1.PricebookEntryId = pbEntry.Id;
        op1.Sales_Contact__c = con2.Id;
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        insert op1;
        TriggerHandler.clearAllBypasses();
        Map<String,String> licenseFieldValues = new Map<String,String>();     
        licenseFieldValues.put('Sales_License_Product__c', prod1.Id);  
        licenseFieldValues.put('Sales_License_Order_Product__c', op1.Id);
        licenseFieldValues.put('Sales_License_Order__c', o1.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues);      
        insert lic;
        System.Test.startTest();            
        Sales_GetComputerDetails.wrapperClass unlicensewrapper = new Sales_GetComputerDetails.wrapperClass();
        unlicensewrapper.id = lic.Id;
        Sales_GetIdFromActivationCode_Bot.LicenseInput Input = new Sales_GetIdFromActivationCode_Bot.LicenseInput();
        Input.licenseObject = null;
        Input.licenseObjectUnlicensed = unlicensewrapper;
        List<Sales_GetIdFromActivationCode_Bot.LicenseOutput> result = new List<Sales_GetIdFromActivationCode_Bot.LicenseOutput>();         
        Sales_GetIdFromActivationCode_Bot.getLicenseId(new List<Sales_GetIdFromActivationCode_Bot.LicenseInput>{Input});
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Jasmine Narula
    * Test method: Sales_ShowRenewalLicense_Bot - Test method for Apex Class -> Sales_ShowRenewalLicense_Bot
    * ****************************/
    @isTest
    public static void showRenewalLicense(){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = acc.Id;
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = acc.Id;
        insert new List<Account>{soldToAccount, shipToAccount};
            Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                    }); 
        insert licAdmDlg;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        prodExt1.put('Core_Prod_Tool_Type_Nm__c','RENEWAL');
        prodExt1.put('Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c', true);
        prodExt1.put('Core_SW_Prod_Temporary_Lic_Allowed_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Rehostable_Ind__c',true);
        prodExt1.put('Core_SW_Prod_Max_Rehost_Cnt__c',3);       
        insert prodExt1;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Core_Account_SoldTo_ShipTo_Rel__c soldShipRel = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,Object>{
            'Core_Sold_To_Account__c' => soldToAccount.Id , 'Core_Ship_To_Account__c' => shipToAccount.Id
                });
        insert soldShipRel; 
        Order o1 = Sales_TestDataFactory.createOrder();
        o1.Pricebook2Id = Test.getStandardPricebookId();
        o1.AccountId = acc.Id;
        o1.Sales_Sold_To_Account__c = soldToAccount.Id ;
        o1.Sales_Ship_To_Account__c = shipToAccount.Id;      
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        insert o1;
        TriggerHandler.clearAllBypasses();
        PriceBookEntry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        OrderItem op1 = Sales_TestDataFactory.createOrderItem();
        op1.OrderId = o1.Id;
        op1.Product2Id = prod1.Id;
        op1.PricebookEntryId = pbEntry.Id;
        op1.Sales_Contact__c = con1.Id;
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        insert op1;
        TriggerHandler.clearAllBypasses();
        Map<String,String> licenseFieldValues = new Map<String,String>();     
        licenseFieldValues.put('Sales_License_Product__c', prod1.Id);  
        licenseFieldValues.put('Sales_License_Order_Product__c', op1.Id);
        licenseFieldValues.put('Sales_License_Primary_Admin_Contact__c', con1.Id);
        licenseFieldValues.put('Sales_License_Order__c', o1.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues);      
        insert lic;
        System.Test.startTest();            
        Sales_ShowRenewalLicense_Bot.LicenseInput Input = new Sales_ShowRenewalLicense_Bot.LicenseInput();
        Input.sContactId = String.valueof(con2.Id);    
        Sales_ShowRenewalLicense_Bot.showRenewalLicenses(new List<Sales_ShowRenewalLicense_Bot.LicenseInput>{Input});
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Jasmine Narula
    * Test method: Sales_RenewSeats_Chatbot - Test method for Apex Class -> Sales_RenewSeats_Chatbot
    * ****************************/
    @isTest
    public static void renewSeatsTest(){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = acc.Id;
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = acc.Id;
        insert new List<Account>{soldToAccount, shipToAccount};
            Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                    }); 
        insert licAdmDlg;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        prodExt1.put('Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c', true);
        prodExt1.put('Core_SW_Prod_Temporary_Lic_Allowed_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Rehostable_Ind__c',true);
        prodExt1.put('Core_SW_Prod_Max_Rehost_Cnt__c',3);       
        insert prodExt1;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Product2 prod2 = Sales_TestDataFactory.createProduct();
        prod2.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        prod2.Core_Item_Orderable_Ind__c = true;
        insert prod2;
        Sales_Host__c hostObj1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{ 'Sales_Contact__c'=>con2.Id ,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true'});
        insert hostObj1;
        Core_Account_SoldTo_ShipTo_Rel__c soldShipRel = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,Object>{
            'Core_Sold_To_Account__c' => soldToAccount.Id , 'Core_Ship_To_Account__c' => shipToAccount.Id
                });
        insert soldShipRel; 
        Order o1 = Sales_TestDataFactory.createOrder();
        o1.Pricebook2Id = Test.getStandardPricebookId();
        o1.AccountId = acc.Id;
        o1.Sales_Sold_To_Account__c = soldToAccount.Id ;
        o1.Sales_Ship_To_Account__c = shipToAccount.Id;      
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        insert o1;
        TriggerHandler.clearAllBypasses();
        PriceBookEntry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        PriceBookEntry pbEntry1 = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry1.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry1.Product2Id = prod2.Id;
        insert pbEntry1;
        OrderItem op1 = Sales_TestDataFactory.createOrderItem();
        op1.OrderId = o1.Id;
        op1.Product2Id = prod1.Id;
        op1.PricebookEntryId = pbEntry.Id;
        op1.Sales_Contact__c = con2.Id;
        OrderItem op2 = Sales_TestDataFactory.createOrderItem();
        op2.OrderId = o1.Id;
        op2.Product2Id = prod2.Id;
        op2.PricebookEntryId = pbEntry1.Id;
        op2.Sales_Contact__c = con2.Id;
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        insert op1;
        TriggerHandler.clearAllBypasses();
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        insert op2;
        TriggerHandler.clearAllBypasses();
        Map<String,String> licenseFieldValues = new Map<String,String>();     
        licenseFieldValues.put('Sales_License_Product__c', prod1.Id);  
        licenseFieldValues.put('Sales_License_Order_Product__c', op1.Id);
        licenseFieldValues.put('Sales_License_Order__c', o1.Id);
        Map<String,String> licenseFieldValues2 = new Map<String,String>();
        licenseFieldValues2.put('Sales_License_Order_Product__c', op2.Id);      
        licenseFieldValues2.put('Sales_License_Product__c', prod2.Id);  
        licenseFieldValues2.put('Sales_License_Order__c', o1.Id);
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues);      
        insert lic;
        Sales_License__c baselic = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues2);      
        insert baselic;
        System.Test.startTest();            
        Sales_ApplyRenewal_Chatbot.licensewrapper wrapper = new Sales_ApplyRenewal_Chatbot.licensewrapper();
        wrapper.Id = baselic.Id;
        Sales_RenewSeats_Chatbot.LicenseInput Input = new Sales_RenewSeats_Chatbot.LicenseInput();
        Input.Sales_seatsToRenew = '5';
        Input.Sales_renewLicId = String.valueof(lic.Id);
        Input.Sales_baseLicId = wrapper;
        Sales_RenewSeats_Chatbot.getLicenseForRenewal(new List<Sales_RenewSeats_Chatbot.LicenseInput>{Input});
        System.Test.stopTest();
    } 
    /******************************
    * Developer Name : Jasmine Narula
    * Test method: Sales_ApplyRenewal_Chatbot - Test method for Apex Class -> Sales_ApplyRenewal_Chatbot
    * ****************************/
    @isTest
    public static void applyrenewSeatsTest(){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = acc.Id;
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = acc.Id;
        insert new List<Account>{soldToAccount, shipToAccount};
            Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                    }); 
        insert licAdmDlg;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        prodExt1.put('Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c', true);
        prodExt1.put('Core_SW_Prod_Temporary_Lic_Allowed_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Rehostable_Ind__c',true);
        prodExt1.put('Core_SW_Prod_Max_Rehost_Cnt__c',3);       
        insert prodExt1;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        System.Test.startTest();     
        Sales_Host__c hostObj1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{ 'Sales_Contact__c'=>con2.Id ,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true'});
        insert hostObj1;
        Core_Account_SoldTo_ShipTo_Rel__c soldShipRel = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,Object>{
            'Core_Sold_To_Account__c' => soldToAccount.Id , 'Core_Ship_To_Account__c' => shipToAccount.Id
                });
        insert soldShipRel; 
        Order o1 = Sales_TestDataFactory.createOrder();
        o1.Pricebook2Id = Test.getStandardPricebookId();
        o1.AccountId = acc.Id;
        o1.Sales_Sold_To_Account__c = soldToAccount.Id ;
        o1.Sales_Ship_To_Account__c = shipToAccount.Id;      
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        insert o1;
        TriggerHandler.clearAllBypasses();
        PriceBookEntry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        OrderItem op1 = Sales_TestDataFactory.createOrderItem();
        op1.OrderId = o1.Id;
        op1.Product2Id = prod1.Id;
        op1.PricebookEntryId = pbEntry.Id;
        op1.Sales_Contact__c = con2.Id;
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        insert op1;
        TriggerHandler.clearAllBypasses();
        Map<String,String> licenseFieldValues = new Map<String,String>();     
        licenseFieldValues.put('Sales_License_Product__c', prod1.Id);  
        licenseFieldValues.put('Sales_License_Order_Product__c', op1.Id);
        licenseFieldValues.put('Sales_License_Order__c',o1.id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues);      
        insert lic;
        Sales_ApplyRenewal_Chatbot.LicenseInput Input = new Sales_ApplyRenewal_Chatbot.LicenseInput();
        Input.Sales_ContactId = con2.Id;
        Input.Sales_renewLicId = String.valueof(lic.Id);  
        Sales_ApplyRenewal_Chatbot.getRenewalLicense(new List<Sales_ApplyRenewal_Chatbot.LicenseInput>{Input});
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Jasmine Narula
    * Test method: Sales_GetLicenseId_Bot - Test method for Apex Class -> Sales_GetLicenseId_Bot
    * ****************************/
    @isTest
    public static void getLcienseIds(){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = acc.Id;
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = acc.Id;
        insert new List<Account>{soldToAccount, shipToAccount};
            Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                    }); 
        insert licAdmDlg;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        prodExt1.put('Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c', true);
        prodExt1.put('Core_SW_Prod_Temporary_Lic_Allowed_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Rehostable_Ind__c',true);
        prodExt1.put('Core_SW_Prod_Max_Rehost_Cnt__c',3);       
        insert prodExt1;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostObj1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{ 'Sales_Contact__c'=>con2.Id,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true' });
        insert hostObj1;
        Core_Account_SoldTo_ShipTo_Rel__c soldShipRel = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,Object>{
            'Core_Sold_To_Account__c' => soldToAccount.Id , 'Core_Ship_To_Account__c' => shipToAccount.Id
                });
        insert soldShipRel; 
        Order o1 = Sales_TestDataFactory.createOrder();
        o1.Pricebook2Id = Test.getStandardPricebookId();
        o1.AccountId = acc.Id;
        o1.Sales_Sold_To_Account__c = soldToAccount.Id ;
        o1.Sales_Ship_To_Account__c = shipToAccount.Id;      
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        insert o1;
        TriggerHandler.clearAllBypasses();
        PriceBookEntry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        OrderItem op1 = Sales_TestDataFactory.createOrderItem();
        op1.OrderId = o1.Id;
        op1.Product2Id = prod1.Id;
        op1.PricebookEntryId = pbEntry.Id;
        op1.Sales_Contact__c = con2.Id;
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        insert op1;
        TriggerHandler.clearAllBypasses();
        Map<String,String> licenseFieldValues = new Map<String,String>();     
        licenseFieldValues.put('Sales_License_Product__c', prod1.Id);  
        licenseFieldValues.put('Sales_License_Order_Product__c', op1.Id);
        licenseFieldValues.put('Sales_License_Order__c', o1.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues);      
        insert lic;
        System.Test.startTest();            
        Sales_GetLicenseInfo_Bot.wrapperClass wrapper = new Sales_GetLicenseInfo_Bot.wrapperClass();
        wrapper.Id = lic.Id;
        Sales_GetLicenseId_Bot.LicenseInput Input = new Sales_GetLicenseId_Bot.LicenseInput();
        Input.licenseObject = wrapper;
        Sales_GetLicenseId_Bot.getLicenseId(new List<Sales_GetLicenseId_Bot.LicenseInput>{Input});
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Jasmine Narula
    * Test method: Sales_GetLicenseId_Bot - Test method for Apex Class -> Sales_GetLicenseId_Bot
    * ****************************/
    @isTest
    public static void getLicenseDEtails(){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = acc.Id;
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = acc.Id;
        insert new List<Account>{soldToAccount, shipToAccount};
            Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                    }); 
        insert licAdmDlg;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        prodExt1.put('Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c', true);
        prodExt1.put('Core_SW_Prod_Temporary_Lic_Allowed_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Rehostable_Ind__c',true);
        prodExt1.put('Core_SW_Prod_Max_Rehost_Cnt__c',3);       
        insert prodExt1;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostObj1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{ 'Sales_Contact__c'=>con2.Id,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true' });
        insert hostObj1;
        Core_Account_SoldTo_ShipTo_Rel__c soldShipRel = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,Object>{
            'Core_Sold_To_Account__c' => soldToAccount.Id , 'Core_Ship_To_Account__c' => shipToAccount.Id
                });
        insert soldShipRel; 
        Order o1 = Sales_TestDataFactory.createOrder();
        o1.Pricebook2Id = Test.getStandardPricebookId();
        o1.AccountId = acc.Id;
        o1.Sales_Sold_To_Account__c = soldToAccount.Id ;
        o1.Sales_Ship_To_Account__c = shipToAccount.Id;      
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        insert o1;
        TriggerHandler.clearAllBypasses();
        PriceBookEntry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        OrderItem op1 = Sales_TestDataFactory.createOrderItem();
        op1.OrderId = o1.Id;
        op1.Product2Id = prod1.Id;
        op1.PricebookEntryId = pbEntry.Id;
        op1.Sales_Contact__c = con2.Id;
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        insert op1;
        TriggerHandler.clearAllBypasses();
        Map<String,String> licenseFieldValues = new Map<String,String>();     
        licenseFieldValues.put('Sales_License_Product__c', prod1.Id);  
        licenseFieldValues.put('Sales_License_Order_Product__c', op1.Id);
        licenseFieldValues.put('Sales_License_Order__c', o1.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues);      
        insert lic;
        System.Test.startTest();            
        Sales_GetLicenseInfo_Bot.ContactInput Input = new Sales_GetLicenseInfo_Bot.ContactInput();
        Input.scontId = con2.Id;
        Input.activationCode = lic.Sales_License_Activation_Code__c;
        Sales_GetLicenseInfo_Bot.getLicenseDetails(new List<Sales_GetLicenseInfo_Bot.ContactInput>{Input});
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Jasmine Narula
    * Test method: Sales_GetLicenseInfo_Bot - Test method for Apex Class -> Sales_GetLicenseInfo_Bot
    * ****************************/
    @isTest
    public static void Sales_GetLicenseInfo_Bot(){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = acc.Id;
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = acc.Id;
        insert new List<Account>{soldToAccount, shipToAccount};
            Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                    }); 
        insert licAdmDlg;
        System.Test.startTest();            
        Sales_GetLicenseInfo_Bot.ContactInput Input = new Sales_GetLicenseInfo_Bot.ContactInput();
        Input.scontId = con2.Id;
        Sales_GetLicenseInfo_Bot.getLicenseDetails(new List<Sales_GetLicenseInfo_Bot.ContactInput>{Input});
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Jasmine Narula
    * Test method: Sales_GetComputerDetails - Test method for Apex Class -> Sales_GetComputerDetails
    * ****************************/
    @isTest
    public static void getComputerdetails(){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = acc.Id;
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = acc.Id;
        insert new List<Account>{soldToAccount, shipToAccount};
            Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                    }); 
        insert licAdmDlg;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        prodExt1.put('Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c', true);
        prodExt1.put('Core_SW_Prod_Temporary_Lic_Allowed_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Rehostable_Ind__c',true);
        prodExt1.put('Core_SW_Prod_Max_Rehost_Cnt__c',3);       
        insert prodExt1;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostObj1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{ 'Sales_Contact__c'=>con2.Id,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true' });
        insert hostObj1;
        Core_Account_SoldTo_ShipTo_Rel__c soldShipRel = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,Object>{
            'Core_Sold_To_Account__c' => soldToAccount.Id , 'Core_Ship_To_Account__c' => shipToAccount.Id
                });
        insert soldShipRel; 
        Order o1 = Sales_TestDataFactory.createOrder();
        o1.Pricebook2Id = Test.getStandardPricebookId();
        o1.AccountId = acc.Id;
        o1.Sales_Sold_To_Account__c = soldToAccount.Id ;
        o1.Sales_Ship_To_Account__c = shipToAccount.Id;      
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        insert o1;
        TriggerHandler.clearAllBypasses();
        PriceBookEntry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        OrderItem op1 = Sales_TestDataFactory.createOrderItem();
        op1.OrderId = o1.Id;
        op1.Product2Id = prod1.Id;
        op1.PricebookEntryId = pbEntry.Id;
        op1.Sales_Contact__c = con2.Id;
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        insert op1;
        TriggerHandler.clearAllBypasses();
        Map<String,String> licenseFieldValues = new Map<String,String>();     
        licenseFieldValues.put('Sales_License_Product__c', prod1.Id);  
        licenseFieldValues.put('Sales_License_Order_Product__c', op1.Id);
        licenseFieldValues.put('Sales_License_Order__c', o1.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues);      
        insert lic;
        System.Test.startTest();            
        Sales_GetComputerDetails.ContactInput Input = new Sales_GetComputerDetails.ContactInput();
        Input.scontId = con2.Id;
        Input.activationCode = lic.Sales_License_Activation_Code__c;  
        Sales_GetComputerDetails.getLicenseDetails(new List<Sales_GetComputerDetails.ContactInput>{Input});
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Jasmine Narula
    * Test method: Sales_SearchLicenseForRenewal  - Test method for Apex Class -> Sales_SearchLicenseForRenewal
    * ****************************/
    @isTest
    public static void searchLicenseforRenewal(){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = acc.Id;
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = acc.Id;
        insert new List<Account>{soldToAccount, shipToAccount};
            Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert con1;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        prodExt1.put('Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c', true);
        prodExt1.put('Core_SW_Prod_Temporary_Lic_Allowed_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Rehostable_Ind__c',true);
        prodExt1.put('Core_SW_Prod_Max_Rehost_Cnt__c',3);       
        insert prodExt1;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostObj1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{ 'Sales_Contact__c'=>con1.Id ,'Sales_Host_Is_Created_From_Custom_Page__c'=>'true'});
        insert hostObj1;
        Core_Account_SoldTo_ShipTo_Rel__c soldShipRel = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,Object>{
            'Core_Sold_To_Account__c' => soldToAccount.Id , 'Core_Ship_To_Account__c' => shipToAccount.Id
                });
        insert soldShipRel; 
        Order o1 = Sales_TestDataFactory.createOrder();
        o1.Pricebook2Id = Test.getStandardPricebookId();
        o1.AccountId = acc.Id;
        o1.Sales_Sold_To_Account__c = soldToAccount.Id ;
        o1.Sales_Ship_To_Account__c = shipToAccount.Id;      
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        insert o1;
        TriggerHandler.clearAllBypasses();
        PriceBookEntry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        OrderItem op1 = Sales_TestDataFactory.createOrderItem();
        op1.OrderId = o1.Id;
        op1.Product2Id = prod1.Id;
        op1.PricebookEntryId = pbEntry.Id;
        op1.Sales_Contact__c = con1.Id;
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        insert op1;
        TriggerHandler.clearAllBypasses();
        Map<String,String> licenseFieldValues = new Map<String,String>();     
        licenseFieldValues.put('Sales_License_Product__c', prod1.Id);  
        licenseFieldValues.put('Sales_License_Order_Product__c', op1.Id);
        licenseFieldValues.put('Sales_License_Order__c', o1.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues);      
        insert lic;
        System.Test.startTest();            
        Sales_SearchLicenseForRenewal.LicenseInput Input = new Sales_SearchLicenseForRenewal.LicenseInput();
        Input.Sales_ContactId = con1.Id;
        Input.Sales_renewLicId = lic.Id;
        Input.Sales_computerName = 'Intel';
        Sales_SearchLicenseForRenewal.getRenewalLicense(new List<Sales_SearchLicenseForRenewal.LicenseInput>{Input});
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Jasmine Narula
    * Test method: Sales_HostReassignment_Bot  - Test method for Apex Class -> Sales_HostReassignment_Bot
    * ****************************/
    @isTest
    public static void hostReassginment_Bot(){   
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert con;
        Map<String,String> hostFieldValues = new Map<String,String>();  
        hostFieldValues.put('Sales_Computer_Name_Txt__c', 'youthost');
        hostFieldValues.put('Name', '758826360123');
        hostFieldValues.put('Sales_Host_Is_Created_From_Custom_Page__c=true','true');
        Sales_Host__c hostObj = Sales_TestDataFactory.createComputerRecord(hostFieldValues);
        insert hostObj;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FLOAT');
        insert prodExt1 ;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{
            'Sales_License_Host_Node_Id__c' => hostObj.Id ,    'Sales_License_Product__c' => prod1.Id ,
                'Sales_License_Account__c' => acc.Id , 'Sales_License_Primary_Admin_Contact__c' => con.Id,'Sales_License_Order__c'=>o.id,'Sales_License_Order_Product__c'=>oi.id
                });
        insert lic;
        Sales_Host__c h = Sales_TestDataFactory.createComputerRecord();
        insert h;
        Sales_HostReassignment_Bot.HostInput Input = new Sales_HostReassignment_Bot.HostInput();
        Input.hostObject = h;
        Input.activationCode = lic.Id;
        System.Test.startTest();
        Sales_HostReassignment_Bot.hostReassigment(new List<Sales_HostReassignment_Bot.HostInput>{Input});
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Jasmine Narula
    * Test method: Sales_ShowComputers_Bot  - Test method for Apex Class -> Sales_ShowComputers_Bot
    * ****************************/
    @isTest
    public static void showFIXEDComputer(){   
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert con;
        Sales_ShowComputers_Bot.ComputerInput Input = new Sales_ShowComputers_Bot.ComputerInput();
        Input.sContactId = con.Id;
        Input.licenseType = 'FIXED';
        System.Test.startTest();
        Sales_ShowComputers_Bot.getComputerDetailsonSearch(new List<Sales_ShowComputers_Bot.ComputerInput>{Input});
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Jasmine Narula
    * Test method: Sales_ShowComputers_Bot  - Test method for Apex Class -> Sales_ShowComputers_Bot
    * ****************************/
    @isTest
    public static void showFLOATComputer(){   
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert con;
        Sales_ShowComputers_Bot.ComputerInput Input = new Sales_ShowComputers_Bot.ComputerInput();
        Input.sContactId = con.Id;
        Input.licenseType = 'FLOAT';
        System.Test.startTest();
        Sales_ShowComputers_Bot.getComputerDetailsonSearch(new List<Sales_ShowComputers_Bot.ComputerInput>{Input});
        System.Test.stopTest();
    }
    /******************************
    * Developer Name : Jasmine Narula
    * Test method: Sales_Bot_GetSnapInsPreChatData  - Test method for Apex Class -> Sales_Bot_GetSnapInsPreChatData
    * ****************************/
    @isTest
    public static void Sales_Bot_GetSnapInsPreChatDataTest(){   
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con=new Contact();
        con.FirstName='Test';
        con.LastName ='Test1';
        con.Email='abc@gmail.com';
        con.AccountId=acc.id;
        con.MailingCountry='USA';
        insert con;
        Map<String, User> emailUserIdMap = new Map<String, User>();  
        User us = new User();
        us.FirstName = 'test';
        us.LastName = 'user';
        us.Email = 'xyztest247392638@intel.com';
        us.Username = 'xyztest@testabc.com';
        us.Alias = 'testu';
        us.CommunityNickname = 'test.user';
        us.TimeZoneSidKey = 'America/Los_Angeles';
        us.LocaleSidKey = 'en_US';
        us.EmailEncodingKey = 'UTF-8';
        us.ProfileId = UserInfo.getProfileId();
        us.LanguageLocaleKey = 'en_US';
        
        
        insert us;
        emailUserIdMap.clear();
        Set<Id> contactIds = new Set<Id>();
        emailUserIdMap.put(con.Email, us);
        if(con!=null)
        {
            contactIds.add(con.Id);
        }
        Map<id,id> contactmap=new Map<id,id>();
        contactmap.put(con.id,us.id); 
        Map<String,Id> emailIdConIdMap =new Map<String,Id>();
        emailIdConIdMap.put(con.Email,con.Id);
        system.runAs(us){                      
            LiveChatVisitor visitor = new LiveChatVisitor();
            insert visitor;
            LiveChatTranscript transcriptRecord = new LiveChatTranscript();
            transcriptRecord.FirstName__c=con.FirstName;
            transcriptRecord.LastName__c=con.LastName;
            transcriptRecord.Username__c = us.Id;
            transcriptRecord.Email__c=con.Email;
            transcriptRecord.ContactId=con.Id;
            transcriptRecord.LiveChatVisitorId = visitor.Id;
            transcriptRecord.ChatKey = 'juoiuft';
            insert transcriptRecord;
            String chatKey1 = [SELECT ChatKey from LiveChatTranscript where id=:transcriptRecord.id LIMIT 1]?.ChatKey;
            List<Sales_Bot_GetSnapInsPreChatData.PrechatInput> listInput = new List<Sales_Bot_GetSnapInsPreChatData.PrechatInput>();
            Sales_Bot_GetSnapInsPreChatData.PrechatInput Input = new Sales_Bot_GetSnapInsPreChatData.PrechatInput();
            Input.sChatKey ='juoiuft';
            listInput.add(Input);
            Sales_Bot_GetSnapInsPreChatData.getSnapInsPrechatData(listInput);
            us.Country='USA';
            update us;
            Sales_Bot_GetSnapInsPreChatData.getSnapInsPrechatData(listInput);
           
        }
    }
    public static User createUserWithProfile() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name='IT Admin'];
        String uniqueUserName = 'userNameIntial' + String.valueof((Integer)(Math.random()*100)) + '@intel.com';
        UserRole admin = [SELECT Id from UserRole where Name = 'Admin' limit 1];
        User user = new User(FirstName='test',LastName='test Last', ProfileId = profileId.Id , Email=uniqueUserName,
                             LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',LanguageLocaleKey='en_US',
                             Alias= (String.valueOf(datetime.now()).substring(0,8)), UserRoleId = admin.Id,
                             UserName=uniqueUserName, EmailEncodingKey='UTF-8'   );
        return user;
    }
    public static User createUser_WithSpecificProfile(String userNameIntial, String userAlias, String profileName, String emailId, Id partnerContactId, Boolean activeCheck ){
        String uniqueUserName = userNameIntial + String.valueof((Integer)(Math.random()*100)) + '@testorg.com';   
        Profile specificProfile = [SELECT Id FROM Profile WHERE Name=:profileName];  
        User userTest;
        if(profileName == 'Partner'){
            userTest = new User(Alias=userAlias, Email=emailId, ContactId=partnerContactId, IsActive=activeCheck,
                                EmailEncodingKey='UTF-8', LastName=userNameIntial+'Test', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = specificProfile.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);
        }else{
            userTest = new User(Alias=userAlias, Email=emailId, IsActive=activeCheck,
                                EmailEncodingKey='UTF-8', LastName=userNameIntial+'Test', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = specificProfile.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);
        }
        return userTest;
    }
}