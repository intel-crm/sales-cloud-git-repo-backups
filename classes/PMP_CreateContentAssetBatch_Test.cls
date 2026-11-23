@isTest
public class PMP_CreateContentAssetBatch_Test {
    @isTest
    public static void testCreateContentAsset(){
        //Creating Test Data
        Account testAccount = new Account(Name = 'Sample Account' ,Core_Account_Type__c='Other',
                                          BillingCity='Bangalore', BillingCountry='IND', BillingStreet = 'TestStreet');
        insert testAccount;
        Id accntId = testAccount.Id;
        
        PMP_Company__c testCompany = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',PMP_Account_Id__c=accntId);
        testCompany.PMP_Is_Published_Ind__c=true;
        insert testCompany;
        Id cmpnyId = testCompany.Id;
        
        PMP_Company_Resource__c testResource = new PMP_Company_Resource__c(Name='sampleResource1',PMP_Company_Id__c=cmpnyId,PMP_Company_Resource_Type_Nm__c='Image');
        insert testResource;
        
        PMP_Company_Resource__c testResource2 = new PMP_Company_Resource__c(Name='sampleResource2',PMP_Company_Id__c=cmpnyId,PMP_Company_Resource_Type_Nm__c='Thumbnail Image');
        insert testResource2;
            
      
        //Starting test with test Data created
        Test.startTest();
        
        PMP_CreateContentAssetBatch obj = new PMP_CreateContentAssetBatch();
        ID batchprocessid= Database.executebatch(obj,20);
        
        Test.stopTest();
    }
}