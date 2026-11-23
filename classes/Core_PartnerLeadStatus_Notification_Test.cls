@isTest
public class Core_PartnerLeadStatus_Notification_Test {
    static testmethod void CorePartnerLeadNotificationTestMethod(){
        List<User> userList = new List<User>();
        Profile p = [select Id,name from Profile where name =:'System Administrator' limit 1];
        User u = new user(Alias = 'user14', Email= 'firstNameDisty1@intel.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.id,IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles', UserName = 'FirstNameDisty1@Intel.com',Core_Leads_Generated_Current_Year__c =0,Core_Leads_Accepted_Current_Year__c=1,
                          Core_Leads_Contacted_Current_Year__c=2,Core_Leads_Qualified_Current_Year__c=3,
                          Core_Leads_Rejected_Current_Year__c=4);
        insert u;
        userList.add(u);
        //Core_PartnerLead_status_Notification.sendEmailToUser(userList);
    }
}