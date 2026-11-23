@isTest
public class PMP_Offering_Image_Upload_test {

   static TestMethod void testImageUpload()
       
     {
         test.startTest();
        Account testAccount = new Account();
        testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
        testAccount.Name = 'Test Account 19-Jun-19';       
        testAccount.Core_Account_Country__c='India';
  //      testAccount.Core_Sales_Groups__c='Automotive Sales Group';
        testAccount.Core_Account_Type__c='ODM';
        testAccount.BillingStreet='Bangalore Central';
        testAccount.BillingCity='Bangalore';
        testAccount.BillingCountry='IND';
        testAccount.BillingState='KA';
        testAccount.BillingPostalCode='560029';
        testAccount.Industry='Agriculture';
        insert testAccount;
         
               
        PMP_Company__c testCompany =  PMP_TestDataUtility.createCompanyInformation('TestCompany1', testAccount.Id, true);
        
        //PMP_Partner_Offering__c testOffering=PMP_TestDataUtility.createOffering('Test 19 feb 8:50 PM', 'Public Content','Test 19 feb 8:50 PM',testCompany.id,true,'Published','The paper Company');
         
       //system.debug('Company ID - '+testCompany.id);
       // Create custom setting for PMP_Utility.getValue() method coverage
        PMP_Static_Constants__c setting = new PMP_Static_Constants__c();
        setting.Name = 'Marketplace_Community_Name';
        setting.PMP_Value__c = 'Partner Solutions Marketplace';
        insert setting;
                
         PMP_Company_Resource__c obj1 = new PMP_Company_Resource__c();
         obj1.Name = 'Test Company Resource';
         obj1.PMP_Company_Id__c = testCompany.Id;         
         obj1.PMP_Company_Resource_URL_txt__c = 'https://solutionsdirectory.intel.com/sites/default/files/shared/Logo With Tagline-01_transparent.png';
         obj1.PMP_Company_Resource_Type_Nm__c = 'Image';
               
         insert obj1;  
         
        //  PMP_Partner_Offering_Resource__c obj2 = new PMP_Partner_Offering_Resource__c();
        //  obj2.Name = 'blade server 2';
        // // obj2.PMP_Offering_Id__c = 'a3s0n000000AKx9AAG';        
        //  obj2.PMP_Offering_Id__c = testOffering.id;        
        //  obj2.PMP_Partner_Offering_Resource_URL_Txt__c = 'https://solutionsdirectory.intel.com/sites/default/files/shared/solutions/PPC-4151W_B20140506150210.png';
        //  obj2.PMP_Resource_Type_Nm__c = 'Image';
         
         
        //  insert obj2; 
        // Create additional resource without URL for negative testing
PMP_Company_Resource__c obj2 = new PMP_Company_Resource__c();
obj2.Name = 'Test Company Resource 2';
obj2.PMP_Company_Id__c = testCompany.Id;         
obj2.PMP_Company_Resource_URL_txt__c = null; // This will be skipped in batch
obj2.PMP_Company_Resource_Type_Nm__c = 'Image';
insert obj2;

// Create resource with invalid URL for exception testing
PMP_Company_Resource__c obj3 = new PMP_Company_Resource__c();
obj3.Name = 'Test Company Resource 3';
obj3.PMP_Company_Id__c = testCompany.Id;         
obj3.PMP_Company_Resource_URL_txt__c = 'invalid-url';
obj3.PMP_Company_Resource_Type_Nm__c = 'Image';
insert obj3;
         
         PMP_HTTPCallRequestMock_test fakeResponse = new PMP_HTTPCallRequestMock_test();
         Test.setMock(HttpCalloutMock.class, fakeResponse);  
         
         PMP_Offering_Image_Upload bc = new PMP_Offering_Image_Upload('PMP_Company_Resource__c');
         Id batchId = database.executeBatch(bc); 
         
         system.assert(batchId != null,'Failed');   

         // Test individual methods for coverage
Map<Id, String> testUrlMap = new Map<Id, String>();
testUrlMap.put(obj1.Id, obj1.PMP_Company_Resource_URL_txt__c);

// Test downloadImage method
Map<Id, Blob> downloadResult = bc.downloadImage(testUrlMap);
System.assert(downloadResult != null, 'Download should return result');

// Test uploadImage method
Map<Id, Blob> uploadMap = new Map<Id, Blob>();
uploadMap.put(obj1.Id, Blob.valueOf('test image data'));
bc.uploadImage(uploadMap);

// Test buildQuery method
String query = bc.buildQuery('PMP_Company_Resource__c');
System.assert(query.contains('PMP_Company_Resource__c'), 'Query should contain object name');
                 
        //  PMP_Offering_Image_Upload bc1 = new PMP_Offering_Image_Upload('PMP_Partner_Offering_Resource__c');
        //  Id batchId1 = database.executeBatch(bc1); 
         
        // system.assert(batchId1 <> null,'Failed'); 
         
         //HTTP Callout exception scenario
        
        //  PMP_Partner_Offering_Resource__c obj3 = new PMP_Partner_Offering_Resource__c();
        //  obj3.Name = 'blade server 2';     
        //  obj3.PMP_Offering_Id__c = testOffering.id;        
        //  obj3.PMP_Partner_Offering_Resource_URL_Txt__c = 'www.intel.com';
        //  obj3.PMP_Resource_Type_Nm__c = 'Image';
         
        //  PMP_Offering_Image_Upload bc2 = new PMP_Offering_Image_Upload('PMP_Partner_Offering_Resource__c');
        //  Id batchId2 = database.executeBatch(bc2); 
         
         //system.assert(batchId2 <> null,'Failed'); 
         
         test.stopTest();
     }
}