@isTest
public class PRM_ER_CIMAccountSearchInfo_Test {
		
    	static testMethod void callConstructors_codecoverage()
        {
        Address address = new Address('Magarpatta','Hadapsar','Pune','IND','Maharashtra','02039399');
      	Account acc = new Account();
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        acc.name ='Test';
        acc.RecordTypeId = intelaccountRT;
        acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_CNDA_Number__c ='63524108';
        insert acc;
      
		Datetime dt =date.valueOf('2021-10-08 11:11:11');    	
        PRM_ER_AccountSearch.AccountLegalAgreement legalAgreement = new PRM_ER_AccountSearch.AccountLegalAgreement(dt);
       	PartnerRoleInfo role = new PartnerRoleInfo('Abcd', '2', 'open', dt);
    	Test.startTest();         

        PRM_ER_CIMAccountSearchInfo obj_cimAccSrch_rdc = new PRM_ER_CIMAccountSearchInfo 
            (acc.name, address, acc.Id, '22213672');
        Test.stopTest();           
            
            
            
        }
    
   
     
}