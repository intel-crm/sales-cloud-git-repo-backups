@isTest(SeeAllData=false)
public class PMP_PIMServiceCallout_Test { 
    
    
    @isTest(SeeAllData=false)
    static void testPublishProductPositive(){
        
        PMP_Product_API_Key__c apiKey=new PMP_Product_API_Key__c();
        apiKey.Name='API_Key';
        apiKey.PMP_API_KEY__c='efm9JpXElhgutg8t8HuHTYWc4tVvcvWk';
        insert apiKey;
        //insert new PMP_Product_API_Key__c(PMP_API_KEY__c = 'efm9JpXElhgutg8t8HuHTYWc4tVvcvWk');
        
        //Create account 
        Account testAccount = new Account();
        testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
        testAccount.Name = 'Test Account 19-Jun-19';       
        testAccount.Core_Account_Country__c='India';
        testAccount.Core_Sales_Groups__c='US Sales Group';
        testAccount.Core_Account_Type__c='ODM';
        testAccount.BillingStreet='Bangalore Central';
        testAccount.BillingCity='Bangalore';
        testAccount.BillingCountry='IND';
        testAccount.BillingState='KA';
        testAccount.BillingPostalCode='560029';
        testAccount.Industry='Agriculture';
        insert testAccount;
        
        PMP_Company__c testCompany = PMP_TestDataUtility.createCompanyInformation('TestCompany1', testAccount.Id, true);
        
        //Inserting partner record 
        PMP_Partner_Offering__c partnerOffering=new PMP_Partner_Offering__c();
        partnerOffering.Name=String.valueOf(DateTime.now());
        partnerOffering.PMP_Partner_Offering_Nm__c = partnerOffering.Name;
        partnerOffering.PMP_Partner_Offering_Visibility_Nm__c='Public Content';
        partnerOffering.PMP_Partner_Offering_Dsc__c=String.valueOf(DateTime.now());
        partnerOffering.PMP_Company_Id__c=testCompany.Id;//'a3z0n0000003sHGAAY';
        partnerOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Published';
        insert partnerOffering;
        system.debug('partnerOffering:'+partnerOffering.Id);
        
        
        Core_Log_Failed_Callout_Entry__c failedCalloutEntry=new Core_Log_Failed_Callout_Entry__c();
        failedCalloutEntry.Core_Status__c='Investigating';
        failedCalloutEntry.Core_sObjectId__c=partnerOffering.Id;
        insert failedCalloutEntry;
            
        Test.setMock(HttpCalloutMock.class, new PMP_TestHttpCalloutMock());
        //PMP_PIMServiceCallout.publishProduct('{\"test\":\"string\"}','POST',partnerOffering.Id,'', 'English');
        List<String> jsonStrings=new List<String>();
        jsonStrings.add('{\"test\":\"string\"}');
        
        List<String> methods=new List<String>();
        methods.add('POST');        
        
        List<Id> offeringIds=new List<Id>();
        offeringIds.add(partnerOffering.Id);
        
        List<String> pimProductIds=new List<String> ();
        pimProductIds.add('');
        List<String> languageCodes=new List<String>();
        languageCodes.add('en_US');
        
        List<String> localeNames=new List<String>();
        localeNames.add('English');
        Test.startTest();
        PMP_PIMServiceCallout.isFuturepublishProduct(jsonStrings,methods,offeringIds, pimProductIds,languageCodes, localeNames,false, false);
        Test.stopTest();
    }
    @isTest(SeeAllData=false)
    static void testPublishProductPutMethodPositive(){
        PMP_Product_API_Key__c apiKey=new PMP_Product_API_Key__c();
        apiKey.Name='API_Key';
        apiKey.PMP_API_KEY__c='efm9JpXElhgutg8t8HuHTYWc4tVvcvWk';
        insert apiKey;
        //Create account
        Account testAccount = new Account();
        testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
        testAccount.Name = 'Test Account 19-Jun-19';       
        testAccount.Core_Account_Country__c='India';
        testAccount.Core_Sales_Groups__c='US Sales Group';
        testAccount.Core_Account_Type__c='ODM';
        testAccount.BillingStreet='Bangalore Central';
        testAccount.BillingCity='Bangalore';
        testAccount.BillingCountry='IND';
        testAccount.BillingState='KA';
        testAccount.BillingPostalCode='560029';
        testAccount.Industry='Agriculture';
        insert testAccount;
        
        PMP_Company__c testCompany = PMP_TestDataUtility.createCompanyInformation('TestCompany1', testAccount.Id, true);

        Test.setMock(HttpCalloutMock.class, new PMP_TestHttpCalloutMock());
        
        //Inserting partner record
        PMP_Partner_Offering__c partnerOffering=new PMP_Partner_Offering__c();
        partnerOffering.Name=String.valueOf(DateTime.now());
        partnerOffering.PMP_Partner_Offering_Nm__c = partnerOffering.Name;
        partnerOffering.PMP_Partner_Offering_Visibility_Nm__c='Public Content';
        partnerOffering.PMP_Partner_Offering_Dsc__c=String.valueOf(DateTime.now());
        partnerOffering.PMP_Company_Id__c=testCompany.Id;//'a3z0n0000003sHGAAY';
        partnerOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Published';
        partnerOffering.PMP_Partner_Offering_Sync_Status_Nm__c='In Sync';
        partnerOffering.PMP_Partner_Offering_Id__c='NPP12345678';
        insert partnerOffering;
        
        //PMP_Partner_Offering__c offering status=[select PMP_Partner_Offering_Id__c, Id from PMP_Partner_Offering__c where Id=:partnerOffering.Id];
        
        //PMP_PIMServiceCallout.publishProduct('{\"test\":\"string\"}','PUT',partnerOffering.Id,partnerOffering.PMP_Partner_Offering_Id__c,'English');
        //need to UNCOMMENT ONCE RETRY is implemented
        //PMP_PIMServiceCallout.isFuturepublishProduct('{\"test\":\"string\"}','PUT',partnerOffering.Id,partnerOffering.PMP_Partner_Offering_Id__c,'English',True);
        //PMP_PIMServiceCallout.isFuturepublishProduct('{\"test\":\"string\"}','PUT',partnerOffering.Id,partnerOffering.PMP_Partner_Offering_Id__c,'English',False);
        //
        //PMP_PIMServiceCallout.publishProduct('{\"test\":\"string\"}','POST',partnerOffering.Id,'', 'English');
        List<String> jsonStrings=new List<String>();
        jsonStrings.add('{\"test\":\"string\"}');
        
        List<String> methods=new List<String>();
        methods.add('PUT');        
        
        List<Id> offeringIds=new List<Id>();
        offeringIds.add(partnerOffering.Id);
        
        List<String> pimProductIds=new List<String> ();
        pimProductIds.add('NPP12345678');
        List<String> languageCodes=new List<String>();
        languageCodes.add('en_US');
        
        List<String> localeNames=new List<String>();
        localeNames.add('English');
        
        PMP_PIMServiceCallout.isFuturepublishProduct(jsonStrings,methods,offeringIds, pimProductIds,languageCodes, localeNames,false, false);
    }

    
    
     @isTest(SeeAllData=false)
    static void testPublishProductPutMethodFail_t(){
        PMP_Product_API_Key__c apiKey=new PMP_Product_API_Key__c();
        apiKey.Name='API_Key';
        apiKey.PMP_API_KEY__c='efm9JpXElhgutg8t8HuHTYWc4tVvcvWk';
        insert apiKey;
        //Create account
        Account testAccount = new Account();
        testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
        testAccount.Name = 'Test Account 19-Jun-19';       
        testAccount.Core_Account_Country__c='India';
        testAccount.Core_Sales_Groups__c='US Sales Group';
        testAccount.Core_Account_Type__c='ODM';
        testAccount.BillingStreet='Bangalore Central';
        testAccount.BillingCity='Bangalore';
        testAccount.BillingCountry='IND';
        testAccount.BillingState='KA';
        testAccount.BillingPostalCode='560029';
        testAccount.Industry='Agriculture';
        insert testAccount;
        
        PMP_Company__c testCompany = PMP_TestDataUtility.createCompanyInformation('TestCompany1', testAccount.Id, true);

        Test.setMock(HttpCalloutMock.class, new PMP_TestHttpCalloutMockFail());
        
        //Inserting partner record
        PMP_Partner_Offering__c partnerOffering=new PMP_Partner_Offering__c();
        partnerOffering.Name=String.valueOf(DateTime.now());
        partnerOffering.PMP_Partner_Offering_Nm__c = partnerOffering.Name;
        partnerOffering.PMP_Partner_Offering_Visibility_Nm__c='Public Content';
        partnerOffering.PMP_Partner_Offering_Dsc__c=String.valueOf(DateTime.now());
        partnerOffering.PMP_Company_Id__c=testCompany.Id;//'a3z0n0000003sHGAAY';
        partnerOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Published';
        partnerOffering.PMP_Partner_Offering_Sync_Status_Nm__c='In Sync';
        partnerOffering.PMP_Partner_Offering_Id__c='NPP12345678';
        insert partnerOffering;
        
        //PMP_Partner_Offering__c offering status=[select PMP_Partner_Offering_Id__c, Id from PMP_Partner_Offering__c where Id=:partnerOffering.Id];
        
        //PMP_PIMServiceCallout.publishProduct('{\"test\":\"string\"}','PUT',partnerOffering.Id,partnerOffering.PMP_Partner_Offering_Id__c,'English');
        //PMP_PIMServiceCallout.isFuturepublishProduct('{\"test\":\"string\"}','PUT',partnerOffering.Id,partnerOffering.PMP_Partner_Offering_Id__c,'English',True);
        //PMP_PIMServiceCallout.isFuturepublishProduct('{\"test\":\"string\"}','PUT',partnerOffering.Id,partnerOffering.PMP_Partner_Offering_Id__c,'English',False);
        //
        //
        //PMP_PIMServiceCallout.publishProduct('{\"test\":\"string\"}','POST',partnerOffering.Id,'', 'English');
        List<String> jsonStrings=new List<String>();
        jsonStrings.add('{\"test\":\"string\"}');
        
        List<String> methods=new List<String>();
        methods.add('PUT');        
        
        List<Id> offeringIds=new List<Id>();
        offeringIds.add(partnerOffering.Id);
        
        List<String> pimProductIds=new List<String> ();
        pimProductIds.add('NPP12345678');
        List<String> languageCodes=new List<String>();
        languageCodes.add('en_US');
        
        List<String> localeNames=new List<String>();
        localeNames.add('English');
        
        PMP_PIMServiceCallout.isFuturepublishProduct(jsonStrings,methods,offeringIds, pimProductIds,languageCodes, localeNames,true, true);
        PMP_PIMServiceCallout.isFuturepublishProduct(jsonStrings,methods,offeringIds, pimProductIds,languageCodes, localeNames,false,false);
    }
    
    
    
    
}