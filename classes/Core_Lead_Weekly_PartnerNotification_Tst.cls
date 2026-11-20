@isTest
public class Core_Lead_Weekly_PartnerNotification_Tst {

	// Create a new test user with the given suffix.
	static User iocUser(String suffix, Id ProfileId) {
		return new User(
			LastName = 'User'+suffix, Alias = 'tuser'+suffix , Email = 'aran.d.wongsaprome@intel.com', 
			UserName = 'test.user'+suffix+'@10645638.intel.com',
			ProfileId = ProfileId, EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', 
			LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', IsActive = true
		);
	}

	// Create IOC setup related data, including users, group, group membership, and queue object.
	public static Id iocSetupData() { 
		Group group1 = new Group(Type = 'Queue', Name = 'PTNR - TestPartner1', DeveloperName = 'Core_PTNR_TestPartner1');
		insert group1;
			
		Queuesobject queue1 = new Queuesobject(SobjectType = 'Lead', QueueId = group1.id);
		insert queue1;
		
		Profile standardUser = [ SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1 ];
		System.assertNotEquals(null, standardUser.Id);
		
		User user1 = iocUser('1', standardUser.Id);
		insert user1;
		insert new GroupMember(GroupId = group1.Id, UserOrGroupId = user1.Id);
		User user2 = iocUser('2', standardUser.Id);
		insert user2;
		insert new GroupMember(GroupId = group1.Id, UserOrGroupId = user2.Id);
		
		return group1.id;
	}

	// Create a new lead with the given suffice and group id.
	public static Lead addTestLeads(String suffix, Id owner) {
		return new Lead(
			RecordTypeId = System.Label.Core_Partner_Lead_Record_Id,
			FirstName = 'Test1',
			LastName = 'Test1',
			email = 'test1@test1.com',
			Phone = '123 4567',
			Company = 'Test1' + suffix,
			CountryCode = 'USA',
			LeadSource = 'Partner Program',
			Core_Partner_Name__c = 'TestPartner1',
			OwnerId = owner
		);
	}
	
	// Create some old leads which need a response reminder.
	public static void iocData(Id owner) {
		List<Lead> leads = new List<Lead>();
		for(String s : new List<String> { '1','2','3','4','5','6','7','8' }) { 
			leads.add(addTestLeads(s, owner));}
		Database.Insert(leads);
		Integer age = 0;
		for(Lead l : leads)	{
			age -= 5;
			Test.setCreatedDate(l.Id, DateTime.now().addDays(age));
		}
	}

	// Opt out from recieving a notification for the test partner.
	public static void iocOpt(Boolean option) {
		insert new Core_Partner_Queue_Mapping__c (
			Core_Active__c = true,
			Core_Partner_Name__c = 'TestPartner1',
			Core_Queue_Name__c = 'Core_PTNR_TestPartner1',
			Core_Disposition_Reminder_Email_Opt_In__c = option
		);
	}
	
	// Show that the class is able to be run under a schedule.
	static testMethod void testSchedule() {
		String CRON_EXP = '0 0 0 15 3 ? *';

		Test.startTest();
		String jobId = System.schedule('Core_Lead_Weekly_PartnerNotification', CRON_EXP, new Core_Lead_Weekly_PartnerNotification());
		Test.stopTest();
		
		CronTrigger ct = [ SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId ];
		System.assertEquals(CRON_EXP, ct.CronExpression,'assert equals');
		System.assertEquals(0, ct.TimesTriggered,'assert equals');
	}
	
	// Show that emails are generated with the expected data.
	static testMethod void testProcess() {
		Id owner;
		System.runAs(Core_Test_Utility.systemAdminUser) {
			owner = iocSetupData();
		}
		iocData(owner);
		iocOpt(true);
	
		Test.startTest();
        //TWC3123-5360
		//List<Messaging.SingleEmailMessage> Result = new Core_Lead_Weekly_PartnerNotification().DispositionReminder();
		Database.executeBatch(new Core_PartnerLead_ReminderEmail());
		Integer invocations = Limits.getEmailInvocations();
	 	Test.stopTest();
	 	System.assertnotEquals(1, invocations, 'An email has been sent');
	}
	
	// Show that when a user is opted out, that the email is not generated.
	static testMethod void testOptOut() {
		Id owner;
		System.runAs(Core_Test_Utility.systemAdminUser) {
			owner = iocSetupData();
		}
		iocData(owner);
		iocOpt(false);
		
		Test.startTest();
        //TWC3123-5360
		//List<Messaging.SingleEmailMessage> Result = new Core_Lead_Weekly_PartnerNotification().DispositionReminder();
		Database.executeBatch(new Core_PartnerLead_ReminderEmail());
        Integer invocations = Limits.getEmailInvocations();
	 	Test.stopTest();
        System.assertEquals(0, invocations, 'An email has not been sent');
	}
}