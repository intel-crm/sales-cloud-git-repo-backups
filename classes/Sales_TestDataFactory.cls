/*********************************************************************************************************************
Class Name    : Sales_TestDataFactory
Created By 	  : Srishty Sharma / Shivam Vishwakarma
Created Date  : July 2021
Function      : Test Data Setup Factory
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           16-July-2021              Test Setup data to be used for test classes
The test data is only for return no need of DML in case of no dependencies.
* Shivam Vishwakarma 	   16-July-2021				 Added Methods
* *********************************************************************************************************************/
@isTest
public without sharing class Sales_TestDataFactory {
    /*static Integer s_num = 1;
    Public static PermissionSet permissionRec;
    public static Map<String, Account> intelAccMap = new Map<String, Account>();
    Static{
    }
    /*********************************************************************************************************************
    * UTILITY METHODS SECTION -->
    * This Section of the Factory Contains all utility methods
    * ******************************************************************************************************************/
    /******************************
    *  Utility Method : getSObjectRecordTypeId
    * @param : 1.objectAPIName - Object API Name , 2.recordTypeName - Record Type DeveloperName
    * - To get the RecordType Id of any SObject based on Inputs provided by User. 
    * - Developer Name : Shivam Vishwakarma
    * ****************************/ 
    /*private static Id getSObjectRecordTypeId(String objectAPIName,String recordTypeName){
        Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = new Map<String,Schema.RecordTypeInfo>();
        sObject obj;
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectAPIName);
        if(objType != null){
            obj = objType.newsObject();  
            Schema.DescribeSObjectResult sObjDesc = obj.getSObjectType().getDescribe(); 
            if(sObjDesc != null){  
                recordTypeInfoMap = sObjDesc.getRecordTypeInfosByDeveloperName();  
            }
            if(recordTypeInfoMap.containsKey(recordTypeName)){
                return recordTypeInfoMap.get(recordTypeName).getRecordTypeId();
            }else{
                return null;
            }
        }        
        return null;
    }
    /******************************
    *  Utility Method : getFakeId
    * - To create fakeId - 15 digits
    * - Developer Name : Srishty Sharma
    * ****************************/  
    /*public static String getFakeId(Schema.SObjectType sObjectType){
        String result = String.valueOf(s_num++);
        return sObjectType.getDescribe().getKeyPrefix() + 
            '0'.repeat(12-result.length()) + result;
    }
    /******************************
    *  Utility Method : getFake18DigitId
    * - To create fake 18 Digits Salesforce Id for any SObject type 
    * - Developer Name : Shivam Vishwakarma
    * ****************************/  
    /*public static String getFake18DigitId(Schema.SObjectType sObjectType){
        String idSalesforce = getFakeId(sObjectType);
        String idCaseSuffix = '';
        String id18Digits= '';
        String caseSuffixDictionary = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ012345';
        for(Integer block = 0; block<3; block++){
            Integer flags = 0;
            for(Integer pos = 0; pos<5; pos++){
                String c = idSalesforce.substring(block*5+pos, block*5+pos+1);
                if((c.compareTo('A')>=0) && (c.compareTo('Z')<=0)){
                    flags += 1 << pos;
                }
            }
            idCaseSuffix = idCaseSuffix + caseSuffixDictionary.substring(flags, flags+1);
        }
        id18Digits = idSalesforce + idCaseSuffix;
        return id18Digits;
    }
    /*********************************************************************************************************************
    * TEST DATA SETUP METHODS SECTION -->
    * This Section of the Factory Contains all test data setup related methods
    * ******************************************************************************************************************/
    /******************************
    * Object : Account 
    * Test Utility Method : createAccount
    * @param : 1.Map of String ,Object-accountFieldValues 
    * - To get the account record instance based on Input field provided by User, in case of passing map as null will return default field value. 
    * - Developer Name : Srishty Sharma
    * ****************************/ 
    /*public static Account createAccount(Map<String,Object> accountFieldValues){
        Account acc = new Account();
        for(String accountField : accountFieldValues.keySet()){
            acc.put(accountField,accountFieldValues.get(accountField));
        }    
        return acc;
    }
    public static Account createDefaultAccount(){
        Map<String, Object> accFieldMap = populateDefaultAccountFields();
        return createAccount(accFieldMap);     
    }
    private static Map<String,Object> populateDefaultAccountFields(){
        return new Map<String, Object>{
            'RecordTypeId'									=>	getSObjectRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount),
                'Name'											=>	'TstAccIntel'+Integer.valueOf(Math.random()*1000),
                'Core_Account_Type__c'							=>	'Distributor',
                'Industry'										=>	'Education',
                'Core_Sub_Industry__c'							=>	'Student',
                'BillingCity'									=>	'Swans Island City ',
                'BillingState'									=>	'ME',
                'BillingCountry'								=>	'USA',
                'BillingStreet'									=>	'1234  Victoria Court ABCHE',
                'BillingPostalCode'								=>	'04685',
                'Type'											=>	'Distributor',
                'Core_Sales_Groups__c'							=>	'PRC Sales Group'
                };
                    }
    public static Account createSoldToAccount(){
        Map<String,Object> accountFieldValues = new Map<String,Object>();
        accountFieldValues.putAll(populateSoldToAccountFields());
        return createAccount(accountFieldValues);
    }
    private static Map<String,Object> populateSoldToAccountFields(){
        Map<String,Object> accountFieldValues = populateDefaultAccountFields();
        accountFieldValues.putAll(new Map<String, Object>{
            'RecordTypeId'							=>	getSObjectRecordTypeId('Account','Core_Direct_Account'),
                'Name'									=>	'CREATESoldtoAcc'+Integer.valueOf(Math.random()*1000),
                'Core_Direct_Account_Active_Ind__c'		=>	true,
                'Core_Direct_Account_Type_Nm__c'		=>	'Sold To',
                'Core_Direct_Payment_Term_Nm__c'		=>	'U',
                'Core_PSG_Account__c'					=>	true,
                'Core_Direct_Sales_Organization_Nm__c'	=>	'AM03',
                'Core_Direct_Distributor_Channel_Nm__c'	=>	'01',
                'Core_Geo__c'							=>	'ASMO'
                });
        return accountFieldValues;
    }
    public static Account createPartnerIntelShipToAccount(){
        Map<String,Object> accountFieldValues = new Map<String,Object>();
        accountFieldValues.putAll(populateParentIntelShipToAccountFields());
        return createAccount(accountFieldValues);
    }
    private static Map<String,Object> populateParentIntelShipToAccountFields(){
        Map<String,Object> accountFieldValues = populateDefaultAccountFields();
        accountFieldValues.putAll(new Map<String, Object>{
            'Name'									=>	'ShiptoAcc'+Integer.valueOf(Math.random()*1000),
                'Core_Account_Type__c'					=>	'Academia & research institutions',
                'Type'									=>	'EMS',
                'Core_Sales_Groups__c'					=>	'PRC Sales Group'
                });
        return accountFieldValues;
    }
    public static Account createShipToAccount(){
        Map<String,Object> accountFieldValues = new Map<String,Object>();
        accountFieldValues.putAll(populateShipToAccountFields());
        return createAccount(accountFieldValues);
    }
    private static Map<String,Object> populateShipToAccountFields(){
        Map<String,Object> accountFieldValues = populateDefaultAccountFields();
        accountFieldValues.putAll(new Map<String, Object>{
            'RecordTypeId'							=>	getSObjectRecordTypeId('Account','Core_Direct_Account'),
                'Name'									=>	'ShiptoAcc2'+Integer.valueOf(Math.random()*1000),
                'Core_Direct_Account_Active_Ind__c'		=>	true,
                'Core_Direct_Account_Type_Nm__c'		=>	'Ship To',
                'Core_Direct_Shipping_Condition_Nm__c'	=>	'1Q',
                'Core_Direct_Incoterm_Dsc__c'			=>	'CIF',
                'Type'									=>	'End User',
                'Core_PSG_Account__c'					=>	true
                });
        return accountFieldValues;
    }
    public static Account createParentEndCustomerAccount(){
        Map<String,Object> accountFieldValues = new Map<String,Object>();
        accountFieldValues.putAll(populateParentEndCustomerAccountFields());
        return createAccount(accountFieldValues);
    }
    private static Map<String,Object> populateParentEndCustomerAccountFields(){
        Map<String,Object> accountFieldValues = populateDefaultAccountFields();
        accountFieldValues.putAll(new Map<String, Object>{
            'Name'									=>	'EndCusAcc'+Integer.valueOf(Math.random()*1000),
                'Core_Account_Type__c'					=>	'End User',
                'Industry'								=>	'Banking',
                'Type'									=>	'End User',
                'Core_PSG_Account__c'					=>	true
                });
        return accountFieldValues; 
    }
    public static Account createEndCustomerAccount(){
        Map<String,Object> accountFieldValues = new Map<String,Object>();
        accountFieldValues.putAll(populateEndCustomerAccountFields());
        return createAccount(accountFieldValues);
    }
    private static Map<String,Object> populateEndCustomerAccountFields(){
        Map<String,Object> accountFieldValues = populateDefaultAccountFields();
        accountFieldValues.putAll(new Map<String, Object>{
            'RecordTypeId'							=>	getSObjectRecordTypeId('Account','Core_Direct_Account'),
                'Name'									=>	'EndCusA'+Integer.valueOf(Math.random()*1000),
                'Core_Direct_Account_Type_Nm__c'		=>	'End Customer',
                'Type'									=>	'End User',
                'Core_Direct_Account_Active_Ind__c'     => true,
                'Core_PSG_Account__c'					=>	true
                });
        return accountFieldValues; 
    }
    public static Account createDirectEndCustomerPricingParentAccount(){
        Map<String,Object> accountFieldValues = new Map<String,Object>();
        accountFieldValues.putAll(populateEndCustomerAccountFields());
        Account accEndPricing = createAccount(accountFieldValues);
        accEndPricing.Core_Direct_Account_Type_Nm__c = 'End Customer Parent';
        accEndPricing.Core_Is_Pricing_Parent_ChkBox__c = true;  
        return accEndPricing;
    }
    /******************************
    * Object : Contact
    * Test Utility Method : createContactRecord & overloaded version with no parameters
    * - To create an Contact Record based on Inputs provided by User. 
    * - Developer Name : Shivam Vishwakarma
    * ****************************/  
    /*public static Contact createContactRecord(Map<String,String> contactFieldValues){
        Contact con = new Contact();
        for(String contactField : contactFieldValues.keySet()){
            if(contactField == 'FirstName')
                con.FirstName = contactFieldValues.get(contactField);            
            if(contactField == 'LastName')
                con.LastName = contactFieldValues.get(contactField);   
            if(contactField == 'Email')
                con.Email = contactFieldValues.get(contactField);  
            if(contactField == 'AccountId')
                con.AccountId = contactFieldValues.get(contactField); 
            if(contactField == 'Core_Primary_Contact__c')
                con.Core_Primary_Contact__c = Boolean.valueOf(contactFieldValues.get(contactField)); 
            if(contactField == 'RecordTypeId')
                con.RecordTypeId = contactFieldValues.get(contactField); 
            if(contactField == 'PARAMETER_RECORDTYPEAPINAME'){
                con.RecordTypeId = getSObjectRecordTypeId('Contact',contactFieldValues.get(contactField));
                if(contactField == 'MailingCountry')
                    con.MailingCountry = contactFieldValues.get(contactField);   
            }       
        }
        if(!(contactFieldValues.containsKey('FirstName')))
            con.FirstName = 'TestContact';
        if(!(contactFieldValues.containsKey('LastName')))
            con.LastName = String.valueOf(Integer.valueOf(Math.random()*1000));
        if(!(contactFieldValues.containsKey('Email')))
            con.Email = String.valueOf((con.FirstName).trim() + (con.LastName).trim() + '@mailinator.com').toLowerCase();
        if(!(contactFieldValues.containsKey('Core_Primary_Contact__c')))
            con.Core_Primary_Contact__c = true;
        if( (!(contactFieldValues.containsKey('RecordTypeId'))) && (!(contactFieldValues.containsKey('PARAMETER_RECORDTYPEAPINAME'))) ) 
            con.RecordTypeId = getSObjectRecordTypeId('Contact','Core_Intel_Contact');
        if(!(contactFieldValues.containsKey('MailingCountry')))
            con.MailingCountry = 'India';
        if(!(contactFieldValues.containsKey('AccountId'))){							
            Account acc = createAccount(populateDefaultAccountFields());
            insert acc;
            con.AccountId = acc.Id ;
        }         
        return con;   
    }
    public static Contact createContactRecord(){
        return createContactRecord(new Map<String, String>());
    }
    /******************************
    * Object : User 
    * Test Utility Method : createUserWithProfileRecord  & overloaded version with no parameters
    * - To create an User Record, with a Specific Profile based on Inputs provided by User. 
    * - Developer Name : Shivam Vishwakarma
    * ****************************/ 
    /*public static User createUserWithProfileRecord(Map<String,String> userFieldValues){
        User u = new User();
        Boolean specificProfileCheck = false;
        Profile specificProfile;
        String getSpecificValues;
        for(String userField : userFieldValues.keySet()){
            if(userField == 'PARAMETER_PROFILENAME'){
                specificProfileCheck = true;
                getSpecificValues = userFieldValues.get(userField);
            }
        }
        if(specificProfileCheck){
            specificProfile = [SELECT Id FROM Profile WHERE Name=:getSpecificValues LIMIT 1];
        }
        for(String userField : userFieldValues.keySet()){
            if(userField == 'EmailEncodingKey')
                u.EmailEncodingKey = userFieldValues.get(userField);      
            if(userField == 'LanguageLocaleKey')
                u.LanguageLocaleKey = userFieldValues.get(userField);    
            if(userField == 'LocaleSidKey')
                u.LocaleSidKey = userFieldValues.get(userField);   
            if(userField == 'TimeZoneSidKey')
                u.TimeZoneSidKey = userFieldValues.get(userField);  
            if(userField == 'IsActive')
                u.IsActive = Boolean.valueOf(userFieldValues.get(userField));  
            if(userField == 'Alias')
                u.Alias = userFieldValues.get(userField);  
            if(userField == 'Email')
                u.Email = userFieldValues.get(userField);   
            if(userField == 'ContactId')
                u.ContactId = userFieldValues.get(userField); 
            if(userField == 'LastName')
                u.LastName = userFieldValues.get(userField);   
            if(userField == 'ProfileId')
                u.ProfileId = (Id)userFieldValues.get(userField);             
            if(userField == 'UserName')
                u.UserName = userFieldValues.get(userField); 
            if(userField == 'PARAMETER_PROFILENAME'){
                u.ProfileId = specificProfile.Id;
            }          
        }
        if(!(userFieldValues.containsKey('EmailEncodingKey')))
            u.EmailEncodingKey = 'UTF-8';
        if(!(userFieldValues.containsKey('LanguageLocaleKey')))
            u.LanguageLocaleKey = 'en_US';
        if(!(userFieldValues.containsKey('LocaleSidKey')))
            u.LocaleSidKey = 'en_US';
        if(!(userFieldValues.containsKey('TimeZoneSidKey')))
            u.TimeZoneSidKey = 'America/Los_Angeles';
        if(!(userFieldValues.containsKey('IsActive')))
            u.IsActive = true;
        if(!(userFieldValues.containsKey('LastName')))
            u.LastName = 'salestestuser';
        if(!(userFieldValues.containsKey('UserName')))
            u.UserName = u.LastName +String.valueof((Integer)(Math.random()*100)) + '@mailinator.com';    
        if(!(userFieldValues.containsKey('Email')))
            u.Email = u.UserName;
        if(!(userFieldValues.containsKey('Alias')))
            u.Alias = 'st'+String.valueof((Integer)(Math.random()*100));   
        if( (!(userFieldValues.containsKey('ProfileId'))) && (!(userFieldValues.containsKey('PARAMETER_PROFILENAME'))) )   
            u.ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id;   
        return u;   
    }
    public static User createUserWithProfileRecord(){
        return createUserWithProfileRecord(new Map<String,String>());
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
    /******************************
    * Object : Sales_Host__c - Host Information
    * Test Utility Method : createComputerRecord & overloaded version with no parameters
    * - To create an Host Record based on Inputs provided by User. 
    * - Developer Name : Shivam Vishwakarma
    * ****************************/       
    /*public static Sales_Host__c createComputerRecord(Map<String,Object> hostFieldValues){
        Sales_Host__c h = new Sales_Host__c();
        for(String hostField : hostFieldValues.keySet()){
            h.put(hostField,hostFieldValues.get(hostField));
        }
        return h;
    }
    public static Sales_Host__c createComputerRecord(Map<String,String> hostFieldValues){
        Sales_Host__c h = new Sales_Host__c();
        for(String hostField : hostFieldValues.keySet()){
            if(hostField == 'Name')
                h.Name = hostFieldValues.get(hostField);
            if(hostField == 'Sales_isActiveHost__c')
                h.Sales_isActiveHost__c = Boolean.valueOf(hostFieldValues.get(hostField));
            if(hostField == 'Sales_Computer_Name_Txt__c')
                h.Sales_Computer_Name_Txt__c = hostFieldValues.get(hostField);
            if(hostField == 'Sales_Computer_Type__c')
                h.Sales_Computer_Type__c = hostFieldValues.get(hostField);
            if(hostField == 'Sales_License_Type__c')
                h.Sales_License_Type__c = hostFieldValues.get(hostField);
            if(hostField == 'Sales_Contact__c')
                h.Sales_Contact__c = hostFieldValues.get(hostField);
            if(hostField == 'Sales_Companion_Server1_Txt__c')
                h.Sales_Companion_Server1_Txt__c = hostFieldValues.get(hostField);
            if(hostField == 'Sales_Companion_Server2_Txt__c')
                h.Sales_Companion_Server2_Txt__c = hostFieldValues.get(hostField);
            if(hostField == 'Sales_Redundant_Server1_Txt__c')
                h.Sales_Redundant_Server1_Txt__c = hostFieldValues.get(hostField);
            if(hostField == 'Sales_Redundant_Server2_Txt__c')
                h.Sales_Redundant_Server2_Txt__c = hostFieldValues.get(hostField);
            if(hostField == 'Temporary_NIC_ID__c')
                h.Temporary_NIC_ID__c = hostFieldValues.get(hostField);
            if(hostField == 'Sales_Host_Is_Created_From_Custom_Page__c')
                h.Sales_Host_Is_Created_From_Custom_Page__c = Boolean.valueOf(hostFieldValues.get(hostField));
        }
        if(!(hostFieldValues.containsKey('Name')))
            h.Name = 'ABCD1234EF36';		
        if(!(hostFieldValues.containsKey('Sales_License_Type__c')))
            h.Sales_License_Type__c = 'FIXED';
        if(!(hostFieldValues.containsKey('Sales_Computer_Type__c')))
            h.Sales_Computer_Type__c = 'NIC ID';       
        if(!(hostFieldValues.containsKey('Sales_Computer_Name_Txt__c')))
            h.Sales_Computer_Name_Txt__c = 'TestClass Computer';
        if(!(hostFieldValues.containsKey('Sales_isActiveHost__c')))
            h.Sales_isActiveHost__c = true;       
        if(!(hostFieldValues.containsKey('Sales_Host_Is_Created_From_Custom_Page__c')))
            h.Sales_Host_Is_Created_From_Custom_Page__c = true;       
        return h;   
    }
    public static Sales_Host__c createComputerRecord(){
        return createComputerRecord(new Map<String,String>());
    }
    /******************************
    * Object : Sales_License_Generator__c 
    * Test Utility Method : createLicenseGenerator
    * @param : 1.Map of String ,Object-licenseGeneratorFieldValues 
    * - To get the Sales_License_Generator__c record instance based on Input field provided by User, in case of passing map as null will return default field value. 
    * - Developer Name : Srishty Sharma
    * ****************************/ 
    /*public static Sales_License_Generator__c createLicenseGenerator(Map<String,Object> licenseGeneratorFieldValues){
        Sales_License_Generator__c licGenerator = new Sales_License_Generator__c();
        for(String licGeneratorField : licenseGeneratorFieldValues.keySet()){
            licGenerator.put(licGeneratorField,licenseGeneratorFieldValues.get(licGeneratorField));
        }    
        return licGenerator;
    }
    public static Sales_License_Generator__c createLicenseGenerator(){
        Map<String, Object> licGenratorFieldMap = new Map<String, Object>{
            'Name'											=>	'Gen'+Integer.valueOf(Math.random()*1000),
                'Sales_License_Vendor__c'						=>	'Mentor Graphics',
                'Sales_License_Generator_txt__c'				=>	'genlic',
                'Sales_License_Feature_Lyn_Syntx_txt__c'		=>	'Gen'
                };
                    return createLicenseGenerator(licGenratorFieldMap);     
    }
    /******************************
    * Object : Sales_License_Group__c 
    * Test Utility Method : createLicenseGroup
    * @param : 1.Map of String ,Object-licenseGroupFieldValues 
    * - To get the Sales_License_Group__c record instance based on Input field provided by User, in case of passing map as null will return default field value. 
    * - Developer Name : Srishty Sharma
    * ****************************/ 
    /*public static Sales_License_Group__c createLicenseGroup(Map<String,Object> licenseGroupFieldValues){
        Sales_License_Group__c licGroup = new Sales_License_Group__c();
        for(String licGroupField : licenseGroupFieldValues.keySet()){
            licGroup.put(licGroupField,licenseGroupFieldValues.get(licGroupField));
        }    
        return licGroup;
    }
    public static Sales_License_Group__c createLicenseGroup(){
        Map<String, Object> licenseGroupFieldValues = new Map<String, Object>{
            'Name'											=>	'Partner'+String.valueOf(Integer.valueOf(Math.random()*100)),
                'Sales_License_Parameter_txt__c'				=>	'test'+String.valueOf(Integer.valueOf(Math.random()*100)),
                'Sales_License_Description_dsc__c'				=>	'test'+String.valueOf(Integer.valueOf(Math.random()*100))
                };
                    return createLicenseGroup(licenseGroupFieldValues);     
    }
    /******************************
    * Object : Product2 
    * Test Utility Method : createProduct
    * @param : 1.Map of String ,Object-productFieldValues 
    * - To get the Product2 record instance based on Input field provided by User.
    * - Developer Name : Srishty Sharma
    * ****************************/ 
    /*public static Product2 createProduct(Map<String,Object> productFieldValues){
        Product2 product = new Product2();
        for(String productField : productFieldValues.keySet()){
            product.put(productField,productFieldValues.get(productField));
        }    
        return product;
    }
    public static Product2 createProduct(){
        Map<String, Object> productFieldValues = new Map<String, Object>{
            'Name'											=>	'Test Product'+String.valueOf(Integer.valueOf(Math.random()*100)),
                'Description'									=>	'Test Product Entry 1',
                'productCode'									=>	'ABC',
                'isActive'										=>	true,
                'Core_Sales_Visible_Flag__c'                    =>  true,                                   
                'Core_Item_Quotable_Ind__c'                     =>  true,                                   
                'Core_Item_Orderable_Ind__c'					=>	true,                                   
                'Core_Item_Shippable_Ind__c'                    =>  true,                                   
                'SBQQ__SubscriptionType__c'						=>	'One-time',
                'SBQQ__SubscriptionPricing__c'					=>	'Fixed Price',
                'Core_Product_Org__c'                          =>  'Sales'
                };
                    return createProduct(productFieldValues);     
    }
    /******************************
    * Object : Sales_License__c - License
    * Test Utility Method : createLicenseRecord  & overloaded version with no parameters
    * - To create an License Record based on Inputs provided by User. 
    * - Developer Name : Shivam Vishwakarma
    * ****************************/  
    /*public static Sales_License__c createLicenseRecord(Map<String,Object> licenseFieldValues){
        Sales_License__c lic = new Sales_License__c();
        for(String licenseField : licenseFieldValues.keySet()){
            lic.put(licenseField,licenseFieldValues.get(licenseField));
        }    
        return lic;
    }
    public static Sales_License__c createLicenseRecord(Map<String,String> licenseFieldValues){
        Sales_License__c lic = new Sales_License__c();
        for(String licenseField : licenseFieldValues.keySet()){
            if(licenseField == 'Sales_License_Activation_Code__c')
                lic.Sales_License_Activation_Code__c = licenseFieldValues.get(licenseField);
            if(licenseField == 'Sales_License_Host_Node_Id__c')
                lic.Sales_License_Host_Node_Id__c = (Id)licenseFieldValues.get(licenseField);
            if(licenseField == 'Sales_License_Order__c')
                lic.Sales_License_Order__c = (Id)licenseFieldValues.get(licenseField);
            if(licenseField == 'Sales_License_Product__c')
                lic.Sales_License_Product__c = (Id)licenseFieldValues.get(licenseField);
            if(licenseField == 'Sales_License_Order_Product__c'){
                lic.Sales_License_Order_Product__c  =(Id)licenseFieldValues.get(licenseField);
            }
            if(licenseField == 'Sales_License_Account__c')
                lic.Sales_License_Account__c = (Id)licenseFieldValues.get(licenseField);
            if(licenseField == 'Sales_License_Primary_Admin_Contact__c')
                lic.Sales_License_Primary_Admin_Contact__c = (Id)licenseFieldValues.get(licenseField);           
            if(licenseField == 'Sales_License_DelegateNames_Txt__c')
                lic.Sales_License_DelegateNames_Txt__c = licenseFieldValues.get(licenseField); 
            if(licenseField == 'Sales_License_Status__c')
                lic.Sales_License_Status__c = licenseFieldValues.get(licenseField);   
            if(licenseField == 'Sales_License_Type__c')
                lic.Sales_License_Type__c = licenseFieldValues.get(licenseField);                   
            if(licenseField == 'Sales_License_Avbl_Rehost_Nbr__c')
                lic.Sales_License_Avbl_Rehost_Nbr__c = Integer.valueOf(licenseFieldValues.get(licenseField));       
            if(licenseField == 'Sales_License_Quantity__c')
                lic.Sales_License_Quantity__c = Integer.valueOf(licenseFieldValues.get(licenseField));       
            if(licenseField == 'Sales_License_Avbl_Qty_Nbr__c')
                lic.Sales_License_Avbl_Qty_Nbr__c = Integer.valueOf(licenseFieldValues.get(licenseField));   
            if(licenseField == 'Sales_License_Available_Temp_Licenses__c')
                lic.Sales_License_Available_Temp_Licenses__c = Integer.valueOf(licenseFieldValues.get(licenseField)); 
            if(licenseField == 'Sales_License_Web_Display_Flag__c')
                lic.Sales_License_Web_Display_Flag__c = Boolean.valueOf(licenseFieldValues.get(licenseField));       
            if(licenseField == 'Sales_License_Start_Date_Dt__c')
                lic.Sales_License_Start_Date_Dt__c = Date.valueOf(licenseFieldValues.get(licenseField));  
            if(licenseField == 'Sales_License_Maintenance_Exp_Dt__c')
                lic.Sales_License_Maintenance_Exp_Dt__c = Date.valueOf(licenseFieldValues.get(licenseField)); 
            if(licenseField == 'Sales_License_Expiration_Date_Dt__c')
                lic.Sales_License_Expiration_Date_Dt__c = Date.valueOf(licenseFieldValues.get(licenseField));             
            if(licenseField == 'Sales_License_Contract__c')
                lic.Sales_License_Contract__c = (Id)licenseFieldValues.get(licenseField);                   
        }
        if(!(licenseFieldValues.containsKey('Sales_License_Activation_Code__c')))
            lic.Sales_License_Activation_Code__c = Sales_LicenseTriggerUtility.mdFiveHashAsLicenseActivationCode();
        if(!(licenseFieldValues.containsKey('Sales_License_Status__c')))
            lic.Sales_License_Status__c = 'Unlicensed';
        if(!(licenseFieldValues.containsKey('Sales_License_Type__c')))
            lic.Sales_License_Type__c = 'Original';
        if(!(licenseFieldValues.containsKey('Sales_License_Avbl_Rehost_Nbr__c')))
            lic.Sales_License_Avbl_Rehost_Nbr__c = 3;
        if(!(licenseFieldValues.containsKey('Sales_License_Quantity__c')))
            lic.Sales_License_Quantity__c = 3;
        if(!(licenseFieldValues.containsKey('Sales_License_Avbl_Qty_Nbr__c')))
            lic.Sales_License_Avbl_Qty_Nbr__c = 3;
        if(!(licenseFieldValues.containsKey('Sales_License_Web_Display_Flag__c')))
            lic.Sales_License_Web_Display_Flag__c = true;
        if(!(licenseFieldValues.containsKey('Sales_License_Start_Date_Dt__c')))
            lic.Sales_License_Start_Date_Dt__c = System.Today();
        if(!(licenseFieldValues.containsKey('Sales_License_Expiration_Date_Dt__c')))
            lic.Sales_License_Expiration_Date_Dt__c = date.today().addYears(2);
        if(!(licenseFieldValues.containsKey('Sales_License_Maintenance_Exp_Dt__c')))
            lic.Sales_License_Maintenance_Exp_Dt__c = date.today().addYears(3);
        return lic;   
    }
    public static Sales_License__c createLicenseRecord(){
        return createLicenseRecord(new Map<String,String>());
    }
    /******************************
    * Object : Sales_License_Order_Product__c - License Order Product
    * Test Utility Method : createLicenseOrderProductRecord  & overloaded version with no parameters
    * - To create an License Order Product Junction Record based on Inputs provided by User. 
    * - Developer Name : Shivam Vishwakarma
    * ****************************/  
    /*public static Sales_License_Order_Product__c createLicenseOrderProductRecord(Map<String,Object> licenseOPFieldValues){
        Sales_License_Order_Product__c licOP = new Sales_License_Order_Product__c();
        for(String licenseOPField : licenseOPFieldValues.keySet()){
            licOP.put(licenseOPField,licenseOPFieldValues.get(licenseOPField));
        }    
        return licOP;
    }
    public static Sales_License_Order_Product__c createLicenseOrderProductRecord(){
        return createLicenseOrderProductRecord(new Map<String,Object>());
    }
    /******************************
    * Object : Sales_License_Admin_Delegate__c - License Admin Delegate
    * Test Utility Method : createLicenseAdminDelegateRecord  
    * - To create an License Admin Delegate Record based on Inputs provided by User. 
    * - Developer Name : Shivam Vishwakarma
    * ****************************/  
    /*public static Sales_License_Admin_Delegate__c createLicenseAdminDelegateRecord(Map<String,Object> licAdmDlgFieldValues){
        Sales_License_Admin_Delegate__c licAdmDlg = new Sales_License_Admin_Delegate__c();
        for(String licAdmDlgField : licAdmDlgFieldValues.keySet()){
            licAdmDlg.put(licAdmDlgField,licAdmDlgFieldValues.get(licAdmDlgField));
        }    
        return licAdmDlg;
    }
    public static Sales_License_Admin_Delegate__c createLicenseAdminDelegateRecord(Map<String,String> licAdmDlgFieldValues){
        Sales_License_Admin_Delegate__c licAdmDlg = new Sales_License_Admin_Delegate__c();
        for(String licAdmDlgField : licAdmDlgFieldValues.keySet()){
            if(licAdmDlgField == 'Sales_License_PrimaryAdmin_Contact__c')
                licAdmDlg.Sales_License_PrimaryAdmin_Contact__c = (Id)licAdmDlgFieldValues.get(licAdmDlgField);     
            if(licAdmDlgField == 'Sales_License_DlgAdmin_Contact__c')
                licAdmDlg.Sales_License_DlgAdmin_Contact__c = (Id)licAdmDlgFieldValues.get(licAdmDlgField);           
            if(licAdmDlgField == 'Sales_License_isActive__c')
                licAdmDlg.Sales_License_isActive__c = Boolean.valueOf(licAdmDlgFieldValues.get(licAdmDlgField)); 
        }
        if(!(licAdmDlgFieldValues.containsKey('Sales_License_isActive__c')))
            licAdmDlg.Sales_License_isActive__c = true;
        return licAdmDlg;   
    }
    /******************************
    * Object : Core_Account_SoldTo_ShipTo_Rel__c - Account SoldTo ShipTo Relationships
    * Test Utility Method : accSoldToShipToRelationshipRecord  
    * - To create an Account SoldTo ShipTo Relationship based on Inputs provided by User. 
    * - Developer Name : Shivam Vishwakarma
    * ****************************/  
    /*public static Core_Account_SoldTo_ShipTo_Rel__c accSoldToShipToRelationshipRecord(Map<String,Object> accSoldShipRelFieldValues){
        Core_Account_SoldTo_ShipTo_Rel__c accSoldShipR = new Core_Account_SoldTo_ShipTo_Rel__c();
        for(String accSoldShipRelField : accSoldShipRelFieldValues.keySet()){
            accSoldShipR.put(accSoldShipRelField,accSoldShipRelFieldValues.get(accSoldShipRelField));
        }
        return accSoldShipR;   
    }
    public static Core_Account_SoldTo_ShipTo_Rel__c accSoldToShipToRelationshipRecord(Map<String,String> accSoldShipRelFieldValues){
        Core_Account_SoldTo_ShipTo_Rel__c accSoldShipR = new Core_Account_SoldTo_ShipTo_Rel__c();
        for(String accSoldShipRelField : accSoldShipRelFieldValues.keySet()){
            if(accSoldShipRelField == 'Core_Sold_To_Account__c')
                accSoldShipR.Core_Sold_To_Account__c = (Id)accSoldShipRelFieldValues.get(accSoldShipRelField);     
            if(accSoldShipRelField == 'Core_Ship_To_Account__c')
                accSoldShipR.Core_Ship_To_Account__c = (Id)accSoldShipRelFieldValues.get(accSoldShipRelField);           
            if(accSoldShipRelField == 'Core_Is_Deactivated_Ind__c')
                accSoldShipR.Core_Is_Deactivated_Ind__c = Boolean.valueOf(accSoldShipRelFieldValues.get(accSoldShipRelField)); 
        }
        return accSoldShipR;   
    }
    /******************************
    * Object : SBQQ__ProductOption__c 
    * Test Utility Method : createOptionProduct
    * @param : 1.Map of String ,Object-optionProductFieldValues 
    * - To get the SBQQ__ProductOption__c record instance based on Input field provided by User.
    * - Developer Name : Srishty Sharma
    * ****************************/ 
    /*public static SBQQ__ProductOption__c createOptionProduct(Map<String,Object> optionProductFieldValues){
        SBQQ__ProductOption__c optionProduct = new SBQQ__ProductOption__c();
        for(String optionProductField : optionProductFieldValues.keySet()){
            optionProduct.put(optionProductField,optionProductFieldValues.get(optionProductField));
        }    
        return optionProduct;
    }
    public static SBQQ__ProductOption__c createOptionProduct(){
        Map<String, Object> optionProductFieldValues = new Map<String, Object>{
            'SBQQ__Number__c'								=>	1,
                'SBQQ__Bundled__c'								=>	true,
                'SBQQ__Type__c'									=>	'Related Product'
                };
                    return createOptionProduct(optionProductFieldValues);     
    }
    /******************************
    * Object : Core_Product_Ext_Attribute__c 
    * Test Utility Method : createProductExternalAttributes
    * @param : 1.Map of String ,Object-extAttributesFieldValues 
    * - To get the Core_Product_Ext_Attribute__c record instance based on Input field provided by User.
    * - Developer Name : Srishty Sharma
    * ****************************/ 
    /*public static Core_Product_Ext_Attribute__c createProductExternalAttributes(Map<String,Object> extAttributesFieldValues){
        Core_Product_Ext_Attribute__c extAttribute = new Core_Product_Ext_Attribute__c();
        for(String extAttributeField : extAttributesFieldValues.keySet()){
            extAttribute.put(extAttributeField,extAttributesFieldValues.get(extAttributeField));
        }    
        return extAttribute;
    }
    public static Core_Product_Ext_Attribute__c createProductExternalAttributes(){
        Map<String, Object> extAttributeFieldValues = new Map<String, Object>{
            'Core_Prod_Tool_Type_Nm__c'								=>	'Base',
                'Core_SW_Lic_Type_Nm__c'								=>	'FIXED',
                'Core_SW_Lic_Enforcement_Method_Nm__c'					=>	'File',
                'Core_SW_Prod_Web_Dsc__c'								=>	'Test',
                'Core_SW_Lic_Generator_Parameter_Txt__c'				=>	'1',
                'Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c'			=>	true,
                'Core_SW_Prod_Max_Rehost_Cnt__c'						=>	1,
                'Core_SW_Lic_File_Data_Encryption_Std_Cd__c'			=>	'1DES'
                };
                    return createProductExternalAttributes(extAttributeFieldValues);     
    }
    /******************************
    * Object : PricebookEntry 
    * Test Utility Method : createPriceBookEntry
    * @param : 1.Map of String ,Object-priceBookEntryFieldValues 
    * - To get the PricebookEntry record instance based on Input field provided by User.
    * - Developer Name : Srishty Sharma
    * ****************************/ 
    /*private static PricebookEntry createPriceBookEntry(Map<String,Object> priceBookEntryFieldValues){
        PricebookEntry priceBookEntry = new PricebookEntry();
        for(String priceBookEntryField : priceBookEntryFieldValues.keySet()){
            priceBookEntry.put(priceBookEntryField,priceBookEntryFieldValues.get(priceBookEntryField));
        }    
        return priceBookEntry;
    }
    public static PricebookEntry createPriceBookEntry(){
        Map<String, Object> priceBookEntryFieldValues = new Map<String, Object>{
            'UnitPrice'					=>	10000,
                'price_disty_cost__c'		=>	18900,
                'IsActive'					=>	true
                };
                    return createPriceBookEntry(priceBookEntryFieldValues);     
    }
    /******************************
    * Object : Order 
    * Test Utility Method : createOrder
    * @param : 1.Map of String ,Object-orderFieldValues 
    * - To get the Order record instance based on Input field provided by User.
    * - Developer Name : Srishty Sharma
    * ****************************/ 
    /*private static Order createOrder(Map<String,Object> orderFieldValues){
        Order order = new Order();
        for(String orderField : orderFieldValues.keySet()){
            order.put(orderField,orderFieldValues.get(orderField));
        }    
        return order;
    }
    public static Order createOrder(){
        Map<String, Object> orderFieldValues = new Map<String, Object>{
            'Type'										=>	'Licensed Tool Order',
                'Name'										=>	'Test Order ',
                'Status'									=>	'Draft',
                'Sales_status__c'							=>	'Draft Order',
                'EffectiveDate'								=>	system.today(),
                'EndDate'									=>	system.today() + 4,
                'Sales_Order_Reason__c'						=>	'Stocking Order',
                'Sales_PO_Number_Txt__c'					=>	'68790007'+String.valueof((Integer)(Math.random() * 1000000000)),
                'Sales_Header_Special_Instructions_Dsc__c'	=>	'abc',
                'Sales_Shipping_Condition_Txt__c'			=>	'1Q',
                'Sales_Incoterms_Txt__c'					=>	'DAT',
                'Sales_Payment_Terms__c'					=>	'KB',
                'Sales_Req_Ship_Date_Dt__c'					=>	system.today() + 5,
                'Sales_SoldTo_Street_Dsc__c'				=>	'3695  Green Avenue',
                'Sales_SoldTo_City_Txt__c'					=> 	'Oakland',
                'Sales_SoldTo_State_Txt__c'					=> 	'California',
                'Sales_SoldTo_Province_Txt__c'				=> 	'CA',
                'Sales_SoldTo_Zip_Txt__c'					=> 	'94621',
                'Sales_SoldTo_Country_Txt__c'				=> 	'United States',
                'Sales_ShipTo_Street_Dsc__c'				=> 	'1893  Orchard Street',
                'Sales_ShipTo_City_Txt__c'					=> 	'RODNEY',
                'Sales_ShipTo_State_Txt__c'					=> 	'Michigan',
                'Sales_ShipTo_Province_Txt__c'				=> 	'MI',
                'Sales_ShipTo_Zip_Txt__c'					=> 	'49342',
                'Sales_ShipTo_Country_Txt__c'				=> 	'United States'
                };
                    return createOrder(orderFieldValues);     
    }
    /******************************
    * Object : OrderItem 
    * Test Utility Method : createOrderItem
    * @param : 1.Map of String ,Object-orderItemFieldValues 
    * - To get the OrderItem record instance based on Input field provided by User.
    * - Developer Name : Srishty Sharma
    * ****************************/ 
    /*public static OrderItem createOrderItem(Map<String,Object> orderItemFieldValues){
        OrderItem orderItem = new OrderItem();
        for(String orderItemField : orderItemFieldValues.keySet()){
            orderItem.put(orderItemField,orderItemFieldValues.get(orderItemField));
        }    
        return orderItem;
    }
    public static OrderItem createOrderItem(){
        Map<String, Object> orderItemFieldValues = new Map<String, Object>{
            'Quantity'										=>	2,
                'UnitPrice'										=>	240,
                'SBQQ__Status__c'								=>	'Draft'
                };
                    return createOrderItem(orderItemFieldValues);     
    }
    /******************************
    * Object : Sales_License_Control__c 
    * Test Utility Method : createSalesLicenseControl
    * @param : 1.Map of String ,Object-salesLicenseControlFieldValues 
    * - To get the Sales_License_Control__c record instance based on Input field provided by User.
    * - Developer Name : Srishty Sharma
    * ****************************/ 
    /*private static Sales_License_Control__c createSalesLicenseControl(Map<String,Object> salesLicenseControlFieldValues){
        Sales_License_Control__c salesLicenseControl = new Sales_License_Control__c();
        for(String salesLicenseControlField : salesLicenseControlFieldValues.keySet()){
            salesLicenseControl.put(salesLicenseControlField,salesLicenseControlFieldValues.get(salesLicenseControlField));
        }    
        return salesLicenseControl;
    }
    public static Sales_License_Control__c createSalesLicenseControl(){
        Map<String, Object> salesLicenseControlFieldValues = new Map<String, Object>{
            'Sales_InActive_Ind__c'							=>	false,
                'Sales_License_Vendor_Nm__c'					=>	'Mentor Graphics'
                };
                    return createSalesLicenseControl(salesLicenseControlFieldValues);     
    }
    /******************************
    * Object : Contract 
    * Test Utility Method : createContract
    * @param : 1.Map of String ,Object-contractFieldValues 
    * - To get the Contract record instance based on Input field provided by User.
    * - Developer Name : Srishty Sharma
    * ****************************/ 
    /*private static Contract createContract(Map<String,Object> contractFieldValues){
        Contract contract = new Contract();
        for(String contractField : contractFieldValues.keySet()){
            contract.put(contractField,contractFieldValues.get(contractField));
        }    
        return contract;
    }
    public static Contract createContract(){
        Map<String, Object> contractFieldValues = new Map<String, Object>{
            'StartDate'							=>	System.today(),
                'ContractTerm'					=>	1,
                'Status'					=> 'Draft'
                };
                    return createContract(contractFieldValues);     
    }
    /******************************
    * Object : Opportunity 
    * Test Utility Method : createOpportunityRecord
    * - To get the Opportunity record instance based on Input field provided by User. 
    * - Developer Name : Shivam Vishwakarma
    * ****************************/ 
    /*public static Opportunity createOpportunityRecord(Map<String,Object> oppFieldValues){
        Opportunity opp = new Opportunity();
        for(String oppField : oppFieldValues.keySet()){
            opp.put(oppField,oppFieldValues.get(oppField));
        }    
        return opp;
    }
    public static Opportunity createOpportunityRecord(){
        Map<String, Object> oppFieldMap = populateDefaultOpportunityFields();
        return createOpportunityRecord(oppFieldMap);    
    }
    private static Map<String,Object> populateDefaultOpportunityFields(){
        return new Map<String, Object>{
            'Name' => 'Test Opportunity',
                'StageName' => 'Define',
                'CloseDate' => date.today(),
                'Type' => 'New Client',
                'NextStep' => 'Test',
                'LeadSource' => 'Business Development',
                'Pricebook2Id' => System.Test.getStandardPricebookId()
                };
                    }
    /******************************
    * Object : SBQQ__Quote__c - Quote 
    * Test Utility Method : createQuoteRecord
    * - To get the quote record instance based on Input field provided by User. 
    * - Developer Name : Shivam Vishwakarma
    * ****************************/ 
    /*public static SBQQ__Quote__c createQuoteRecord(Map<String,Object> quoteFieldValues){
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        for(String quoteField : quoteFieldValues.keySet()){
            quote.put(quoteField,quoteFieldValues.get(quoteField));
        }    
        return quote;
    }
    public static SBQQ__Quote__c createQuoteRecord(){
        Map<String, Object> quoteFieldMap = populateDefaultQuoteFields();
        return createQuoteRecord(quoteFieldMap);     
    }
    private static Map<String,Object> populateDefaultQuoteFields(){
        return new Map<String, Object>{
            'RecordTypeId' => getSObjectRecordTypeId('SBQQ__Quote__c','PSG_Quote_Approved'),
                'core_cpq_active_cb__c' => true,
                'SBQQ__Primary__c' => true,
                'core_cpq_quote_type_nm__c' => 'Budgetary',
                'core_cpq_business_unit_nm__c' => 'Military',
                'SBQQ__StartDate__c' => date.today(),
                'SBQQ__EndDate__c' => date.today()+365,
                'SBQQ__SubscriptionTerm__c' => 12,
                'SBQQ__Status__c' => 'Approved',
                'core_cpq_status_txt__c' => 'Approved',
                'SBQQ__PriceBook__c' => Test.getStandardPricebookId(),
                'core_cpq_price_book_nm__c' => Test.getStandardPricebookId(),
                'SBQQ__PricebookId__c' => String.valueOf(Test.getStandardPricebookId()),
                'SBQQ__ContractingMethod__c' => 'Single Contract'
                };
                    }
    /******************************
    * Object : SBQQ__QuoteLine__c - QuoteLine 
    * Test Utility Method : createQuoteLineRecord
    * - To get the quoteline record instance based on Input field provided by User. 
    * - Developer Name : Shivam Vishwakarma
    * ****************************/ 
    /*public static SBQQ__QuoteLine__c createQuoteLineRecord(Map<String,Object> quotelineFieldValues){
        SBQQ__QuoteLine__c quoteline = new SBQQ__QuoteLine__c();
        for(String quotelineField : quotelineFieldValues.keySet()){
            quoteline.put(quotelineField,quotelineFieldValues.get(quotelineField));
        }    
        return quoteline;
    }
    public static SBQQ__QuoteLine__c createQuoteLineRecord(){
        Map<String, Object> quotelineFieldMap = populateDefaultQuoteLineFields();
        return createQuoteLineRecord(quotelineFieldMap);     
    }
    private static Map<String,Object> populateDefaultQuoteLineFields(){
        return new Map<String, Object>{        
            'SBQQ__Quantity__c' => 1,
                'price_brokencost_amt__c' => 54,
                'price_requested_resale_amt__c' => 45,
                'price_suggested_resale_amt__c' => 45,
                'SBQQ__DefaultSubscriptionTerm__c' => 12,
                'SBQQ__StartDate__c' => date.today(),
                'SBQQ__EndDate__c' => date.today()+365,
                'Pricing_OEM_System_Model_Nm__c' => 'Test OEM System Model',
                'Pricing_Systems_qty__c' => 10,
                'Pricing_CPUs_per_system_qty__c' => 1,
                'Pricing_Single_System_Price_Amt__c' => 4,
                'Pricing_OEM_Standard_Unit_Price_Amt__c' => 2,
                'Pricing_Req_Discounted_Unit_Price__c' => 1,
                'Pricing_Additional_OEM_Discount_Amt__c' => 1,
                'Pricing_Market_Segment_Nm__c' => 'Non Embedded',
                'Pricing_Other_Competitor_Product_Nm__c' => 'Test Tender Prod',
                'Pricing_pm_approval_comments_nm__c' => 'Test Comment'
                };
                    }   */
}