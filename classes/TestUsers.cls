@isTest
public class TestUsers {
    static testMethod void UpdateJobFunction_Test() {
        Test.stopTest();
                List<Contact> lstConToInsert = new List<Contact>();

        List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
        Account account = lstAccounts[0];
        insert account;
        List<Contact> lstContacts = Core_Test_Utility.createContacts(3);
        Contact contact = lstContacts[0];
        contact.AccountId = account.id;
        Contact contact1 = lstContacts[1];
        contact1.AccountId = account.id;
        Contact contact2 = lstContacts[2];
        contact2.AccountId = account.id;
        lstConToInsert.add(contact);
        lstConToInsert.add(contact1);
        lstConToInsert.add(contact2);
        insert lstConToInsert;

       user u = [select id from user where id='0052i000003Y99AAAS'];
         User user1 = new User();
        user1.alias = 'test123';
        user1.email='test123@noemail.com';
        user1.emailencodingkey='UTF-8';
        user1.lastname='Testing';
        user1.languagelocalekey='en_US';
        user1.localesidkey='en_US';
        user1.profileid = [select id from profile where name='Partner'].id;
        user1.country='United States';
        user1.IsActive =true;
        user1.ContactId = contact1.Id;
        user1.timezonesidkey='America/Los_Angeles';
        user1.username=Math.random()+'@'+UserInfo.getOrganizationid()+'.test';
        System.RunAs(u){
            //insert user;
            insert user1;
        }
        Test.stopTest();
        

        
    }
}