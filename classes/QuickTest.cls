@isTest public class QuickTest {
    
    static testMethod void createPortalUser(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Alias = 'batman',
            Email = 'jason.liveston@asdf.com',
            Username = 'jason.liveston@asdf.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);
        
        //User u1 = [Select ID From User Where Id =: portalAccountOwner1.Id];
        
        System.runAs ( portalAccountOwner1 ) {
            //Create account
            Account portalAccount1 = new Account(
                Name = 'TestAccount',
                OwnerId = portalAccountOwner1.Id
            );
            Database.insert(portalAccount1);
            
            //Create contact
            Contact contact1 = new Contact(
                FirstName = 'Test',
                Lastname = 'McTesty',
                AccountId = portalAccount1.Id,
                Email = '123test@example.com'
            );
            Database.insert(contact1);
            
            //Create user
            Profile portalProfile = [SELECT Id FROM Profile Limit 1];
            User user1 = new User(
                Username = '123test12345@example.com',
                ContactId = contact1.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test123',
                Email = 'test12345@example.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            Database.insert(user1);
            System.debug(' '+[Select Id, Name, ContactId, Contact.Name, AccountId, Account.Name from User where contactId = :contact1.Id ]);
        }
        
        
    }
}