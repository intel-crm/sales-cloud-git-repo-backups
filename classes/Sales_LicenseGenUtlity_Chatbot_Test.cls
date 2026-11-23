/*********************************************************************************************************************
Version       : 1.0
Created Date  : June 2021

Modification Log :
* Developers                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Jasmine Narula / Shivam Vishwakarma / Nilesh Mithapelli        
*							24-June-2021             Chatbot related Apex Classes - Common test class
* ---------------------------------------------------------------------------------------------------------*/

@isTest
public class Sales_LicenseGenUtlity_Chatbot_Test {
    
    /*@isTest static void checkRetrieveLicense(){
        test.startTest();
        Sales_LicenseGenerationUtlity_Chatbot.retriveLicenseDetailsOnSearch('2U Passive');
        test.stopTest();
    }*/
    
    /*@isTest static void checkhostReassigment(){
        
        Sales_Host__c hostObj = new Sales_Host__c();
        hostObj.Sales_Computer_Name_Txt__c='My Intel COmputer';
        hostObj.Sales_Computer_Type__c='NIC ID';
        hostObj.Sales_isActiveHost__c= true;
        hostObj.Sales_License_Type__c='FIXED';
        hostObj.Name='AAAABBBBEEFF';
        insert hostObj;
        test.startTest();
        //Sales_LicenseGenerationUtlity_Chatbot.hostReassigment('EAEFF368FCF4C6294C09BABE123C7A12',hostObj.id);
        test.stopTest();
    }
     public class LicenseInput {
        @InvocableVariable
        public String Sales_Activation_Code;
        @InvocableVariable
        public Id Sales_ContactId;
    }
    
    @isTest static void checkgetLicenseDetailsMethod(){
        List<LicenseInput> ipList = new List<LicenseInput>();
        LicenseInput ip = new LicenseInput();
        ip.Sales_Activation_Code = 'EAEFF368FCF4C6294C09BABE123C7A12';
        ipList.add(ip);
        //Sales_LicenseGenerationUtlity_Chatbot.getLicenseDetails(ipList);
    }
    
    
    
    
    /******************************
* Developer Name : Shivam Vishwakarma
* Test method: DetermineHostLicType_Test - Test method for Apex Class -> Sales_DetermineHostLicType_Bot
* ****************************/
    
    /*@isTest
    public static void DetermineHostLicType_Test(){
        String errMsg = '';
        //Test Setup
        Sales_DetermineHostLicType_Bot.LicenseToolTypeInput licenseTypeInput = new Sales_DetermineHostLicType_Bot.LicenseToolTypeInput();
        Sales_DetermineHostLicType_Bot.LicenseToolTypeInput licenseTypeInput2 = new Sales_DetermineHostLicType_Bot.LicenseToolTypeInput();
        Sales_DetermineHostLicType_Bot.LicenseToolTypeInput licenseTypeInput3 = new Sales_DetermineHostLicType_Bot.LicenseToolTypeInput();
        List<Sales_DetermineHostLicType_Bot.Result> result = new List<Sales_DetermineHostLicType_Bot.Result>();
        licenseTypeInput.License_Type_OnLicense = 'FIXED';
        licenseTypeInput2.License_Type_OnLicense = 'FLOAT';
        licenseTypeInput3.hostobj = createHostRecord('Computer1','FIXED','NIC ID',null,null,null,null);
        Test.startTest();
        try{
            result = Sales_DetermineHostLicType_Bot.determineHostLicType(new List<Sales_DetermineHostLicType_Bot.LicenseToolTypeInput>{licenseTypeInput});
            result = Sales_DetermineHostLicType_Bot.determineHostLicType(new List<Sales_DetermineHostLicType_Bot.LicenseToolTypeInput>{licenseTypeInput2});
            result = Sales_DetermineHostLicType_Bot.determineHostLicType(new List<Sales_DetermineHostLicType_Bot.LicenseToolTypeInput>{licenseTypeInput3});
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    
    /******************************
* Developer Name : Shivam Vishwakarma
* Test method: LicenseFileGeneration_Test - Test method for Apex Class -> Sales_LicenseFileGeneration_Chatbot
* ****************************/
    
    /*@isTest
    public static void LicenseFileGeneration_Test(){
        String errMsg = '';
        //Test Setup            	
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
        Sales_Host__c hostObj = createHostRecord('Computer1','FIXED','NIC ID',null,null,null,null);
        Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
        Pricebookentry pbEntry = new Pricebookentry();
        pbEntry.UnitPrice = 240;
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        Order ord = Sales_TestFactory_Utility.createOrders(partnerAccount.Id, Test.getStandardPricebookId(), 'Sample Order');     
        String actCode = Sales_LicenseTriggerUtility.mdFiveHashAsLicenseActivationCode();
        Sales_License__c lic = new Sales_License__c();
        lic.Sales_License_Activation_Code__c = actCode;
        lic.Sales_License_Host_Node_Id__c = hostObj.Id;
        lic.Sales_License_Order__c = ord.Id;
        lic.Sales_License_Product__c = prod1.Id;
        lic.Sales_License_Account__c = partnerAccount.Id;
        lic.Sales_License_Primary_Admin_Contact__c = partnerContact.Id;
        insert lic;
        
        Test.startTest();    
        //Mock Web service callout
        Test.setMock(HttpCalloutMock.class, new CalloutMock());
        //Test Data for Class to test
        Sales_LicenseFileGeneration_Chatbot.LicenseFileGenInput Input = new Sales_LicenseFileGeneration_Chatbot.LicenseFileGenInput();
        Input.ActivationCode_OR_HostId  = actCode;
        Input.InputType = 'ActivationCode';  
        Sales_LicenseFileGeneration_Chatbot.LicenseFileGenInput Input2 = new Sales_LicenseFileGeneration_Chatbot.LicenseFileGenInput();
        Input2.HostData  = hostObj;
        Input2.InputType = 'HostId'; 
        List<Sales_LicenseFileGeneration_Chatbot.LicenseFileGenOutput> result = new List<Sales_LicenseFileGeneration_Chatbot.LicenseFileGenOutput>();
        
        try{
            result = Sales_LicenseFileGeneration_Chatbot.generateLicenseFile(new List<Sales_LicenseFileGeneration_Chatbot.LicenseFileGenInput>{Input});
            result = Sales_LicenseFileGeneration_Chatbot.generateLicenseFile(new List<Sales_LicenseFileGeneration_Chatbot.LicenseFileGenInput>{Input2});
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        Test.stopTest();
        //System.assertEquals(errMsg,'');
    }
    
    /******************************
* Developer Name : Shivam Vishwakarma
* Test method: fetchActivationCode_Test - Test method for Apex Class -> Sales_fetchActivationCode_Bot
* ****************************/
    
    /*@isTest
    public static void fetchActivationCode_Test(){
        String errMsg = '';
        //Test Setup            	
        Product2 prod1 = Sales_TestFactory_Utility.createProductWithDifferentLicenseType('Float',null);
        Pricebookentry pbEntry = new Pricebookentry();
        pbEntry.UnitPrice = 240;
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
            
        String actCode = Sales_LicenseTriggerUtility.mdFiveHashAsLicenseActivationCode();
        Sales_License__c lic = new Sales_License__c();
        lic.Sales_License_Activation_Code__c = actCode;
        lic.Sales_License_Product__c = prod1.Id;      
        insert lic;
        
        Test.startTest();            
        //Test Data for Class to test
        Sales_fetchActivationCode_Bot.LicenseInput Input = new Sales_fetchActivationCode_Bot.LicenseInput();
		Input.licenseObject = lic;
        List<Sales_fetchActivationCode_Bot.LicenseOutput> result = new List<Sales_fetchActivationCode_Bot.LicenseOutput>();   
        try{
            result = Sales_fetchActivationCode_Bot.getHostDetails(new List<Sales_fetchActivationCode_Bot.LicenseInput>{Input});
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(errMsg,'');
    }
    






    
    
    /******************************
* UTILITY METHODS TO SETUP TEST DATA
* Test Utility Methods added :
* 1. createHostRecord - To create an Host Record based on Inputs provided by User. - Developer Name : Shivam Vishwakarma
* 2. createAccount_PartnerandNonpartner_PSGDownstream - To create an Account Record based on Inputs provided by User. - Developer Name : Shivam Vishwakarma
* 3. createContactWithDetails - To create an Contact Record based on Inputs provided by User. - Developer Name : Shivam Vishwakarma
* 4. CalloutMock.class -> respond - To mock respone from Web Service Callout - License File Generation. - Developer Name : Shivam Vishwakarma
* ****************************/
    
    /*public static Sales_Host__c createHostRecord(String compName, String LicType, String compType, Id primAdmContactId, String compServ1, String redServ1, String redServ2){
        Sales_Host__c h = new Sales_Host__c();
        if(compType=='HOST ID')
            h.Name='AAA18AAA';		//Randomly populating Primary Computer Id.
        else if(compType=='NIC ID')
            h.Name='AAAAAA36BBBB';		//Randomly populating Primary Computer Id.
        h.Sales_isActiveHost__c = true;
        h.Sales_Computer_Name_Txt__c = compName;
        h.Sales_Computer_Type__c = compType;
        h.Sales_License_Type__c = LicType;
        h.Sales_Contact__c = primAdmContactId;
        h.Sales_Companion_Server1_Txt__c = compServ1;
        h.Sales_Redundant_Server1_Txt__c = redServ1;
        h.Sales_Redundant_Server2_Txt__c = redServ2;
        insert h;
        return h;
    }   
    
    public static Account createAccount_PartnerandNonpartner_PSGDownstream(String CoreAccountType, String Acctype){
        Account acc = new Account();
        acc.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);  
        acc.Core_PSG_Account__c=true;   // PSG Downstream true
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
        acc.Core_Sales_Groups__c = 'CCG Sales Group';       
        insert acc;
        return acc;
    }
    
    public static Contact createContactWithDetails(Id accId, String fName, String lName, String emailId){
        Contact con = new Contact();
        con.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        con.FirstName = fName;
        con.LastName = lName;
        con.Email = emailId;
        con.AccountId = accId;
        con.Core_Primary_Contact__c = true;
        insert con;
        return con;
    }
    
    public class CalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"Status" : "Success","Comment" : "License File processed successfully for given Batch Id."}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }*/
    
}