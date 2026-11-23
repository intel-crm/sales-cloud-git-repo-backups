@isTest
public class PRM_IPA_Integration_Scheduler_Test {
	@testSetup
	private static void createData(){
		String partnerAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
		List<Account> lstAccts = new List<Account>();

		Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor' /*,Core_Sales_Groups__c= 'PRC Sales Group'*/,
		                                      Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='USA',BillingStreet='abc chowk delhi',BillingState='FL',
		                                      ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True,OwnerId=UserInfo.getUserId());
		lstAccts.add(partnerAccount1);
		Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)' /*,Core_Sales_Groups__c= 'PRC Sales Group'*/ ,
		                                    Industry='Agriculture', BillingCity='delhi',BillingCountry='USA',BillingStreet='cbc chowk delhi',
		                                    ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True);
		lstAccts.add(intelAccount1);
		Database.insert(lstAccts);

		partnerAccount1.Core_PMP_Membership_Change_Ind__c = false;
		Database.update(partnerAccount1);
		List<Account> updatedAcct= new List<Account>();
		for(Account acc:[SELECT ID,NAME,Core_Account_Type__c,Core_IPA_Partner_Role__c FROM ACCOUNT]) {
			
			 acc.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
            acc.Core_IPA_Partner_Role__c = 'Service Provider';
			acc.Core_CIM_ID__c='12345';
			acc.PRM_IPA_Integration_Status__c = 'Pending';
			updatedAcct.add(acc);
		}
		//Get Contact Record Type
		Id intelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
		Contact cnt = new Contact(FirstName='Test',LastName='Contact1',Email='testcontact1@mailinator.com',AccountId=partnerAccount1.Id,RecordTypeId=intelContRecTypeId,
		                          MailingCity='delhi',MailingState='FL',MailingCountry='USA',MailingPostalCode='123456',PRM_IPA_Integration_Status__c='Pending');
        
		insert cnt;

		Test.startTest();
		Database.Update(updatedAcct);
		Test.stopTest();
	}

	@isTest
	private static void validateAccountPayloadBatch() {
		PRM_IPA_Integration_Scheduler asch = new PRM_IPA_Integration_Scheduler();
		string sch = '0 5 * * * ?';
		string jobId = system.schedule('IPA Account Payload Test', sch, asch);

		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression,'Corn expression is correct');
        System.assertEquals(0, ct.TimesTriggered,'Batch is not triggered');
        
        PRM_Batch_IPA_Account_Integration b = new PRM_Batch_IPA_Account_Integration();
        Database.executeBatch(b,Integer.ValueOf(Label.IPA_Int_Batch_Size));
	}
    
    @isTest
	private static void validateContactPayloadBatch() {
		PRM_IPA_Integration_Scheduler asch = new PRM_IPA_Integration_Scheduler();
		string sch = '0 5 * * * ?';
		string jobId = system.schedule('IPA Contact Payload Test', sch, asch);

		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression,'Corn expression is correct');
        System.assertEquals(0, ct.TimesTriggered,'Batch is not triggered');
        
        PRM_Batch_IPA_Contact_Integration c = new PRM_Batch_IPA_Contact_Integration();
        Database.executeBatch(c,Integer.ValueOf(Label.IPA_Int_Batch_Size));
        
      
         Database.executeBatch(c,250);
	}
}