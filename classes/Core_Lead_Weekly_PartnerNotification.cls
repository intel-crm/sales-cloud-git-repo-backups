/**************************************************************************************
Apex Class Name: Core_Lead_Weekly_PartnerNotification
Version : 1.0 
Created Date: 06 Dec 2016
Function: Schedulable class that will send weekly email summary notifications to partner users
This summary contains the outstanding leads assigned which are in open state.

Modification Log :
Developer                Date                   Description
----------------------------------------------------------------------------                 
Aran Wongsaprome          12/06/2016              Initial Version
*************************************************************************************/

global class Core_Lead_Weekly_PartnerNotification implements schedulable
{
	// Main method that gets called by the scheduler and is required
	global void execute(SchedulableContext sc)
	{
		DispositionReminder();
	}

	static final Integer FIRSTBUCKET  = 5;
	static final Integer SECONDBUCKET = 20;
	static final Integer THIRDBUCKET  = 30;
	static final Integer MAXAGEFORLEAD = 37;

	// The data model structure
	public class DispositionReminderData {
		public List<Lead> Leads { get; set; }
		public Map<String, Integer> map_OwnerToBucketCount { get; set; }
		public Map<Id, String> map_OwnerToPartner { get; set; }
		public Set<Id> set_Owners { get; set; }
		public Map<Id, List<String>> map_OwnersToEmail { get; set; }
		public Map<Id, Id> map_OwnersToTarget { get; set; }
		public Boolean isDebugging { get; set; }
		public Id Template { get; set; }
		public Id OrgEmailId { get; set; }
		public List<String> BCCAddresses { get; set; }
	}

	// Load the open lead from the database for partners who are not opted out from
	// recieving the weekly notifications.
	public Integer ReadOpenLeads(DispositionReminderData Data) {
		Set<String> OptedInPartners = new Set<String>();
		for(Core_Partner_Queue_Mapping__c P : [
			SELECT Core_Partner_Name__c FROM Core_Partner_Queue_Mapping__c 
			WHERE Core_Disposition_Reminder_Email_Opt_In__c = true AND Core_Active__c = true
		])
			OptedInPartners.add(P.Core_Partner_Name__c);
	
		// Get a list of Open Partner leads
		Data.Leads = [
			SELECT Id, Name, OwnerId, Core_Partner_Name__c, Core_Age_of_Lead__c FROM Lead 
			WHERE Core_Lead_State__c = 'Open'
				AND RecordTypeId = :System.Label.Core_Partner_Lead_Record_Id
				AND Core_Partner_Name__c IN :OptedInPartners
				AND Core_Age_of_Lead__c > :FIRSTBUCKET AND Core_Age_of_Lead__c <= :MAXAGEFORLEAD
		];
		Integer TotalRead = Data.Leads.size();
		System.debug('### ReadOpenLeads() 1 ### Total Lead Count: ' + TotalRead);
		for (Lead l : Data.Leads)
			System.debug('### ReadOpenLeads() 2 ### Lead Details: ' + l);
		return TotalRead;
	}
	
	// Count leads by owner and age, placing the data into the model.
	public void AggregateByOwnerAndAge(DispositionReminderData Data) {
		Data.map_OwnerToBucketCount = new Map<String, Integer>();
		Integer LeadCount; 
		String Bucket;
		for (Lead l :Data.Leads)
		{
			// Track by owner and bucket subtotal
			if(l.Core_Age_of_Lead__c > THIRDBUCKET) Bucket = 'third';
			else if(l.Core_Age_of_Lead__c > SECONDBUCKET) Bucket = 'second';
			else Bucket = 'first';
			LeadCount = Data.map_OwnerToBucketCount.get(l.OwnerId + Bucket);
			if (LeadCount == null) // First lead of the Queue
				Data.map_OwnerToBucketCount.put(l.OwnerId + Bucket, 1);  
			else 
				Data.map_OwnerToBucketCount.put(l.OwnerId + Bucket, LeadCount + 1);
		}
		for (String OwnerBucket : Data.map_OwnerToBucketCount.keyset())
			system.debug('### AggregateByOwnerAndAge() 1 ### Lead Count By Bucket: ' + OwnerBucket + ' - ' + Data.map_OwnerToBucketCount.get(OwnerBucket));
	}
	
	// From the lead data, derive the list of partners and a unique list of owners.
	public Integer ReadOwnerAndPartnerData(DispositionReminderData Data) {
		Data.map_OwnerToPartner = new Map<Id, String>();
		for (Lead l : Data.Leads)
			Data.map_OwnerToPartner.put(l.OwnerId, l.Core_Partner_Name__c);
		
		Data.set_Owners = Data.map_OwnerToPartner.keySet();

		for (String Owner : Data.set_Owners)
			system.debug('### ReadOwnerAndPartnerData() 1 ### Partner Name By Owner: ' + Owner + ' - ' + Data.map_OwnerToPartner.get(Owner));
		
		return Data.set_Owners.size();
	}

	// With the given list of users, find the one matching the given id.
	public String FindEmailForUserId(List<User> Users, id Who) {
		for (User U : Users) if(U.id == Who) return U.Email;
		return null;
	}
	
	// Load the list of users within each owner queue, along with the email addresses of
	// these users. Place this into the data model.
	public void ReadEmailData(DispositionReminderData Data) {
		List<GroupMember> Members = [ // all members of all the queues that would receive emails
			SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId = :Data.set_Owners ORDER BY GroupId
		];
		Set<Id> UserIds = new Set<Id>();
		for (GroupMember M : Members) {
			UserIds.add(M.UserOrGroupId);
			System.debug('### ReadEmailData() 1 ### Queue Member: ' + M.Groupid + ' - ' + M.UserOrGroupId);
		}
		List<User> Users = [ SELECT Id, Email FROM User WHERE Id = :UserIds AND IsActive = true ];
		for (User U : Users)
			System.debug('### ReadEmailData() 2 ### User: ' + U.Id + ' - ' + U.Email);
		
		// Collect the emails for each owner group into lists of email address
		Data.map_OwnersToEmail = new Map<id, List<String>>();
		Data.map_OwnersToTarget = new Map<Id, Id>();
		for(Id O : Data.set_Owners) Data.map_OwnersToEmail.put(O, new List<String>());
		id LastOwner;
		List<String> Emails;
		String Address;
		for (GroupMember M : Members) {
			if(M.GroupID != LastOwner) {
				LastOwner = M.GroupID;
				Emails = Data.map_OwnersToEmail.get(LastOwner);
				Data.map_OwnersToTarget.put(M.GroupID, M.UserOrGroupId);
			}
			Address = FindEmailForUserId(Users, M.UserOrGroupId);
			if(Address != null) Emails.add(Address);
		}
	}
	
	// Load the shared configuration data from labels and email template object. Place this
	// into the data model for use in generating emails.
	public void ReadCommonEmailData(DispositionReminderData Data) {
		Data.isDebugging = Boolean.ValueOf(System.Label.Core_Partner_DispositionReminder_Debug_Mode);
		System.debug('### ReadCommonEmailData() 1 ### Debug Mode: ' + Data.isDebugging);
		
		OrgWideEmailAddress OWA = [ 
			SELECT Id FROM OrgWideEmailAddress 
			WHERE Address = :System.Label.Core_Partner_DispositionReminder_From_Address 
		];
		Data.OrgEmailId = OWA.id;
		System.debug('### ReadCommonEmailData() 2 ### OrgWideEmailAddress: ' + Data.OrgEmailId);
		
		Data.Template = Data.isDebugging 
			? System.Label.Core_Partner_DispositionReminder_EmailTemplate_Id_Debug
			: System.Label.Core_Partner_DispositionReminder_EmailTemplate_Id;
		System.debug('### ReadCommonEmailData() 3 ### Email Template: ' + Data.Template);
		
		String BCC = System.Label.Core_Partner_DispositionReminder_Bcc_Address;
		Data.BCCAddresses = BCC.contains('@') ? BCC.split(',') : null;
		System.debug('### ReadCommonEmailData() 4 ### BCC: ' + (Data.BCCAddresses == null ? 'null' : String.join(Data.BCCAddresses, ',')));
	}
	
	// Replace the template place holders with the correct values for debugging. Return the 
	// rendered template as a string.
	public String RenderEmailBodyDebug(DispositionReminderData Data, Id Owner, String Body) {
		Body = Body.replace('(Lead.QueueId)', String.valueof(Owner));
		
		String Partner = Data.map_OwnerToPartner.Get(Owner);
		Body = Body.replace('(Lead.PartnerName)', Partner == null ? 'null' : Partner);
		
		Body = Body.replace('(Lead.Recipients)', String.join(Data.map_OwnersToEmail.get(Owner), ', '));
		return Body;
	}
	
	// Replace the template place holders with the correct values. Return the rendered template as a string.
	public String RenderEmailBody(DispositionReminderData Data, Id Owner, String Body) {
		String LF = Body.contains('<body') ? '<br>' : '\n';
		Integer first = Data.map_OwnerToBucketCount.Get(Owner + 'first');
		Body = Body.replace('(Lead.FirstBucket)', first == null ? ''
			: String.valueOf(first) + ' leads are more than ' + String.valueOf(FIRSTBUCKET) + ' days past due' + LF);
		Integer second = Data.map_OwnerToBucketCount.Get(Owner + 'second'); 
		Body = Body.replace('(Lead.SecondBucket)', second == null ? '' 
			: String.valueOf(second) + ' leads are more than ' + String.valueOf(SECONDBUCKET) + ' days past due' + LF);
		Integer third = Data.map_OwnerToBucketCount.Get(Owner + 'third');
		Body = Body.replace('(Lead.ThirdBucket)', third == null ? '' 
			: String.valueOf(third) + ' leads are more than ' + String.valueOf(THIRDBUCKET) + ' days past due' + LF);
		return Data.isDebugging ? RenderEmailBodyDebug(Data, Owner, Body) : Body;
	}

	// Using the data model, generate the email for the given owner queue.
	public Messaging.SingleEmailMessage GenerateEmail(DispositionReminderData Data, Id Owner) {
		String[] Recipients = Data.map_OwnersToEmail.get(Owner);
		System.debug('### GenerateEmail() 1 ### Queue id: ' + Owner);
		System.debug('### GenerateEmail() 1 ### Queue Partner Name: ' + Data.map_OwnerToPartner.Get(Owner));	
		System.debug('### GenerateEmail() 1 ### Leads in first bucket: ' + Data.map_OwnerToBucketCount.Get(Owner + 'first'));
		System.debug('### GenerateEmail() 1 ### Leads in second bucket: ' + Data.map_OwnerToBucketCount.Get(Owner + 'second'));
		System.debug('### GenerateEmail() 1 ### Leads in third bucket: ' + Data.map_OwnerToBucketCount.Get(Owner + 'third'));
		System.debug('### GenerateEmail() 1 ### Recipients: ' + (Recipients.isEmpty() ? 'None' : String.join(Recipients, ', ')));
		if(Recipients.isEmpty()) return null;
		Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(Data.Template, null, null);
		mail.OrgWideEmailAddressId = Data.OrgEmailId;
		if (Data.isDebugging) { // Ignore the actual emails and use test emails if we are running in the debug mode
			Recipients = System.Label.Core_Partner_DispositionReminder_To_Address_Debug.split(',');
			System.debug('### GenerateEmail() 2 ### Debug reset recipient: ' + String.join(Recipients, ', '));
		}
		else // Set the target object to a user in the queue, so the apex email count does not use the org limits
			mail.SetTargetObjectId(Data.map_OwnersToTarget.get(Owner)); 
		mail.setToAddresses(Recipients);
		if (Data.BCCAddresses != null && !Data.BCCAddresses.isEmpty())
			mail.setBccAddresses(Data.BCCAddresses);
		mail.setHtmlBody(RenderEmailBody(Data, Owner, mail.HtmlBody));
		mail.setPlainTextBody(RenderEmailBody(Data, Owner, mail.PlainTextBody));
		mail.setSaveAsActivity(false);		
		return mail;
	}

	// Generate and send the emails based on the accumulated data.
	public List<Messaging.SingleEmailMessage> SendEmails(DispositionReminderData Data) {
		List<Messaging.SingleEmailMessage> Emails = new List<Messaging.SingleEmailMessage>();
		Messaging.SingleEmailMessage Current;
		for (Id Owner : Data.set_Owners) {
			Current = GenerateEmail(Data, Owner);
			if(Current != null)
				Emails.add(Current);
		}
		System.debug('### SendEmails() 1 ### Total Emails: ' + Emails.size());
		for (Messaging.SendEmailResult R : Messaging.sendEmail(Emails))
			if (R.success)
				System.debug('### SendEmails() 2 ### The email was sent successfully.'); 
			else
				System.debug('### SendEmails() 2 ### The email failed to send: ' + R.errors[0].message);
		return Emails;
	}

	// The main entry point for generating the disposition reminder emails. Gather data from the system.
	// Then loop, sending one email to each owner queue.
	public List<Messaging.SingleEmailMessage> DispositionReminder() {
		DispositionReminderData Data = new DispositionReminderData();
		if (ReadOpenLeads(Data) == 0) return null;
		AggregateByOwnerAndAge(Data);
		if (ReadOwnerAndPartnerData(Data) == 0) return null;
		ReadEmailData(Data);
		ReadCommonEmailData(Data);
		return SendEmails(Data);
	}
}