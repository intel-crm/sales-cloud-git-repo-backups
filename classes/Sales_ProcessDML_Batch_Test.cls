@isTest
public class Sales_ProcessDML_Batch_Test {
    @isTest
    static void testQueueableJob() {
        List<sObject> insertrecords = new List<sObject>();
        Account accAPJ = new Account();
        accAPJ.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);      
        accAPJ.Name = 'Test Account'+math.random();
        accAPJ.Core_Account_Type__c = 'Distributor;End Customer';
        accAPJ.Industry = 'Banking';
        accAPJ.BillingCity = 'Texas';
        accAPJ.BillingCountry = 'USA';
        accAPJ.BillingStreet = 'G-2101'; 
        accAPJ.Core_Sales_Groups__c = 'APJ India Sales Group'; 
        accAPJ.Core_Geo__c = 'APJ';
        accAPJ.Core_Sub_Geo__c = 'IJKK';
        accAPJ.Core_PSG_Account__c = true;
        accAPJ.Core_Account_Tier__c ='PSG-Tier 4';
        Account acc = PSG_Test_Utility.createAccount();
        Contact con = PSG_Test_Utility.createContact(acc.Id);
        con.Email = 'FirstNameacc123@intel.com';
        acc.name = 'Test account';
        List<sObject> updaterecords = new List<sObject>{con,acc,accAPJ};
        String className = 'Sales_ProcessDML_Batch';
        String methodName = 'execute';
        String errorLogMsg = 'Error occurred during processing';
        Test.startTest();
        Database.executeBatch(new Sales_ProcessDML_Batch(updaterecords,className,methodName,errorLogMsg),100);
        Test.stopTest();

    }

}