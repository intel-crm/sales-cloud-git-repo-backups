@isTest
public class Core_Platform_Event_Producer_Test {
    
    @isTest static void insertAccount(){
        test.startTest();
        
        Core_Attributes_List__mdt m = new Core_Attributes_List__mdt();
        m.QualifiedApiName='Account';
        m.Core_Attribute_List__c='Id, BillingCity, BillingCountry, BillingCountryCode, BillingPostalCode, BillingState, BillingStateCode, BillingStreet, Core_Account_Legal_Name__c, Core_CIM_ID__c, Core_Deactivated__c,Core_Deactivation_Reason__c, Core_Sales_Group__c, Core_Sales_Segment__c, Fax, Name, Phone, RecordTypeId, Type';
        
        
        Account acc = new Account();
        acc.name='Test';
        //acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_Account_Legal_Name__c='asas';
        acc.Core_Sales_Segment__c='aa';
        acc.Core_Sales_Group__c='Global Accounts';
        acc.Fax='aaa';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Phone='121212';
        acc.Industry = '';
        insert acc;
        
        
        Account acc1 = new Account();
        acc1.name='Test1';
        acc1.id=acc.id;
        update acc1;

       test.stopTest();
     }
}