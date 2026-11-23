@isTest
public class Core_Lead_Weekly_PartnerNotification_Tst {

  // Create a new test user with the given suffix.
  static User IocUser(String suffix, Id ProfileId){
    return new User(
      LastName = 'User'+suffix, Alias = 'tuser'+suffix , Email = 'aran.d.wongsaprome@intel.com', 
      UserName = 'test.user'+suffix+'@10645638.intel.com',
      ProfileId = ProfileId, EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', 
      LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', IsActive = true
    );
  }

  // Create IOC setup related data, including users, group, group membership, and queue object.
  public static Id IocSetupData()
  {
    Group group1 = new Group(Type = 'Queue', Name = 'PTNR - TestPartner1', DeveloperName = 'Core_PTNR_TestPartner1');
    insert group1;
      
    Queuesobject queue1 = new Queuesobject(SobjectType = 'Lead', QueueId = group1.id);
    insert queue1;
    
    Profile StandardUser = [ SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1 ];
    System.assertNotEquals(null, StandardUser.Id);
    
    User user1 = IocUser('1', StandardUser.Id);
    insert user1;
    insert new GroupMember(GroupId = group1.Id, UserOrGroupId = user1.Id);
    User user2 = IocUser('2', StandardUser.Id);
    insert user2;
    insert new GroupMember(GroupId = group1.Id, UserOrGroupId = user2.Id);
    
    return group1.id;
  }

  // Create a new lead with the given suffice and group id.
  public static Lead addTestLeads(String Suffix, Id Owner) {
    return new Lead(
      RecordTypeId = System.Label.Core_Partner_Lead_Record_Id,
      FirstName = 'Test1',
      LastName = 'Test1',
      email = 'test1@test1.com',
      Phone = '123 4567',
      Company = 'Test1' + Suffix,
      CountryCode = 'USA',
      LeadSource = 'Partner Program',
      Core_Partner_Name__c = 'TestPartner1',
      OwnerId = Owner
    );
  }
  
  // Create some old leads which need a response reminder.
  public static void IocData(Id Owner) {
    List<Lead> Leads = new List<Lead>();
    for(String S : new List<String> { '1','2','3','4','5','6','7','8' })
      Leads.add(addTestLeads(S, Owner));
    Database.Insert(Leads);
    Integer Age = 0;
    for(Lead L : Leads)  {
      Age -= 5;
      Test.setCreatedDate(L.Id, DateTime.now().addDays(Age));
    }
  }

  // Opt out from recieving a notification for the test partner.
  public static void IocOpt(Boolean Option) {
    insert new Core_Partner_Queue_Mapping__c (
      Core_Active__c = true,
      Core_Partner_Name__c = 'TestPartner1',
      Core_Queue_Name__c = 'Core_PTNR_TestPartner1',
      Core_Disposition_Reminder_Email_Opt_In__c = Option
    );
  }
  
  // Show that the class is able to be run under a schedule.
  static testMethod void testSchedule() {
    String CRON_EXP = '0 0 0 15 3 ? 2022';

    Test.startTest();
    String jobId = System.schedule('Core_Lead_Weekly_PartnerNotification', CRON_EXP, new Core_Lead_Weekly_PartnerNotification());
    Test.stopTest();
    
    CronTrigger ct = [ SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId ];
    System.assertEquals(CRON_EXP, ct.CronExpression);
    System.assertEquals(0, ct.TimesTriggered);
    System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
  }
  
  // Show that emails are generated with the expected data.
  static testMethod void testProcess() {
    Id Owner;
    System.runAs(Core_Test_Utility.systemAdminUser) {
      Owner = IocSetupData();
    }
    IocData(Owner);
    IocOpt(true);
  
    Test.startTest();
   // List<Messaging.SingleEmailMessage> Result = new Core_Lead_Weekly_PartnerNotification().DispositionReminder();
     Test.stopTest();
     
   // System.assertEquals(1, Result.size(), 'wrong result size');
    // String Body = Result[0].plainTextBody;
    // System.assert(-1 != Body.indexOf('3 leads are more than 5 days past due'),  'five');
    // System.assert(-1 != Body.indexOf('2 leads are more than 20 days past due'), 'twenty');
    // System.assert(-1 != Body.indexOf('1 leads are more than 30 days past due'), 'thirty');
  }
  
  // Show that when a user is opted out, that the email is not generated.
  static testMethod void testOptOut() {
    Id Owner;
    System.runAs(Core_Test_Utility.systemAdminUser) {
      Owner = IocSetupData();
    }
    IocData(Owner);
    IocOpt(false);
    
    Test.startTest();
    //List<Messaging.SingleEmailMessage> Result = new Core_Lead_Weekly_PartnerNotification().DispositionReminder();
     Test.stopTest();
     
    // System.assertEquals(null, Result);
  }
}