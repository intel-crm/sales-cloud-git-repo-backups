@isTest
public class Core_Notes_Attachments_Ctrl_Test {

    static List<User> createTestUserInGeo(Integer numUsers, Id profileId, String geo) {
        List<User> testUsers = new List<User>();
        for (Integer i=0; i<numUsers; i++) {
            User testUser = new User();
            testUser.Firstname = 'test';
            testUser.LastName = 'user ' + geo + i;
            testUser.UserName = 'testuser.' + geo + i + '@intel.com.crm';
            testUser.Email = 'testuser.' + geo + i + '@intel.com';
            testUser.Alias = geo + i;
            testUser.CommunityNickName = 'test.' + geo + i;
            testUser.ProfileId = profileId;
            testUser.LANGUAGELOCALEKEY = 'en_US';
            testUser.LOCALESIDKEY = 'en_US';
            testUser.TIMEZONESIDKEY = 'America/Los_Angeles';
            testUser.EMAILENCODINGKEY = 'ISO-8859-1';
            testUser.Core_User_Geo__c = geo;
            testUsers.add(testUser);
        }
        return testUsers;
    }
    
    @testSetup 
    static void setup(){
        Id profileId = [select Id from Profile where Name = 'Standard User'][0].Id;
        insert createTestUserInGeo(1, profileId, 'EMEA');
        
        Account acc = new Account();
        acc.name = 'Test Account';
        acc.BillingCountryCode = 'USA';
        acc.BIllingStateCode = 'AL';
        acc.BillingCity = 'Alabama';
        acc.BillingStreet = 'test';
        acc.Core_Sales_Groups__c='CCG Sales Group';
        insert acc;
        
        Note nt = new Note();
        nt.Title = 'note title';
        nt.Body = 'note description';
        nt.ParentId = acc.Id;
        insert nt;
        
        Attachment att = new Attachment();
        att.IsPrivate = false;
        att.Name = 'testAttachment.txt';
        att.Body = Blob.valueOf('attachment description');
        att.ParentId = acc.Id;
        insert att;
        
        ContentNote contNote = new ContentNote();
        contNote.Title = 'content title';
        contNote.Content = Blob.valueOf('content description');
        insert contNote;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contNote.Id;
        cdl.LinkedEntityId = acc.Id;
        cdl.Visibility = 'AllUsers';
        insert cdl;
        
        ContentVersion file = new ContentVersion();
        file.Title = 'fileTitle';
        file.VersionData = Blob.valueOf('file description');
        file.PathOnClient = 'fileTitle.pdf';
        file.Core_Is_Public__c = false;
        insert file;
        file = [select ContentDocumentId, Title, VersionData from ContentVersion where Id =: file.Id];
        cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = file.ContentDocumentId;
        cdl.LinkedEntityId = acc.Id;
        cdl.Visibility = 'AllUsers';
        insert cdl;
    }
    
    static testMethod void testNotesAttachments1(){
        Account acc = [select Id, Name from Account];
        List<Note> ntList = [select Id from Note];
        List<ContentNote> contNoteList = [select Id from ContentNote];
        Core_Notes_Attachments_Ctrl.fetchAccountDetails(acc.Id);
        Core_Notes_Attachments_Ctrl.getAllNotesAttachments(acc.Id);
        Core_Notes_Attachments_Ctrl.createUpdateNote(ntList[0].Id, 'test title', 'test desc', 'Note', acc.Id);
        Core_Notes_Attachments_Ctrl.createUpdateNote('', 'test title', 'test desc', 'Enhanced Note', acc.Id);
        Core_Notes_Attachments_Ctrl.createUpdateNote(contNoteList[0].Id, 'test title', 'test desc', 'Enhanced Note', acc.Id);
        Core_Notes_Attachments_Ctrl.getImageName('file', 'test.mp3');
        Core_Notes_Attachments_Ctrl.getImageName('file', 'test.csv');
        Core_Notes_Attachments_Ctrl.getImageName('file', 'test.xlsx');
        Core_Notes_Attachments_Ctrl.getImageName('file', 'test.jpg');
        Core_Notes_Attachments_Ctrl.getImageName('file', 'test.ppt');
        Core_Notes_Attachments_Ctrl.getImageName('file', 'test.vsd');
        Core_Notes_Attachments_Ctrl.getImageName('file', 'test.doc');
        Core_Notes_Attachments_Ctrl.getImageName('file', 'test.xml');
        Core_Notes_Attachments_Ctrl.getImageName('file', 'test.mp4');
        Core_Notes_Attachments_Ctrl.getImageName('file', 'test.zip');
        Core_Notes_Attachments_Ctrl.getImageName('file', 'test.unknown');
    }
    
    static testMethod void testNotesAttachments2(){
        Account acc = [select Id, Name from Account];
        Core_Notes_Attachments_Access_Profiles__c profAccess = new Core_Notes_Attachments_Access_Profiles__c();
        profAccess.SetupOwnerId = UserInfo.getUserId();
        profAccess.Core_is_Access__c = true;
        insert profAccess;
        Core_Notes_Attachments_Ctrl.getAllNotesAttachments(acc.Id);
    }
    
    static testMethod void testNotesAttachments3(){
        Account acc = [select Id, Name from Account];
        Core_Notes_Attachments_Access_Profiles__c profAccess = new Core_Notes_Attachments_Access_Profiles__c();
        profAccess.SetupOwnerId = UserInfo.getProfileId();
        profAccess.Core_is_Access__c = true;
        insert profAccess;
        Core_Notes_Attachments_Ctrl.getAllNotesAttachments(acc.Id);
    }
    
    static testMethod void testNotesAttachments4(){
        Account acc = [select Id, Name, OwnerId from Account];
        List<User> userList = [select Id, Name from User];
        acc.OwnerId = userList[0].Id;
        update acc;
        Core_Notes_Attachments_Ctrl.getAllNotesAttachments(acc.Id);
    }
    
    static testMethod void testNotesAttachments5(){
        Account acc = [select Id, Name, OwnerId from Account];
        List<User> userList = [select Id, Name from User];
        acc.OwnerId = userList[0].Id;
        update acc;
        AccountTeamMember accTeam = new AccountTeamMember();
        accTeam.AccountId = acc.Id;
        accTeam.UserId = UserInfo.getUserId();
        insert accTeam;
        Core_Notes_Attachments_Ctrl.getAllNotesAttachments(acc.Id);
    }
    
    static testMethod void testNotesAttachments6(){
        List<UserRole> usRoleList = [select Id, Name from UserRole where parentRoleId =: UserInfo.getUserRoleId()];
        List<User> userList = [select Id, Name, UserRoleId from User];
        userList[0].UserRoleId = usRoleList[0].Id;
        Account acc = [select Id, Name, OwnerId from Account];
        acc.OwnerId = userList[0].Id;
        update acc;
        Core_Notes_Attachments_Ctrl.getAllNotesAttachments(acc.Id);
    }
    
    static testMethod void testNotesAttachments7(){
        List<Note> ntList = [select Id from Note];
        List<ContentNote> contNoteList = [select Id from ContentNote];
        List<Attachment> attList = [select Id from Attachment];
        List<ContentVersion> fileList = [select Id, ContentDocumentId from ContentVersion];
        Core_Notes_Attachments_Ctrl.updateAccessLevel(attList[0].Id, 'Attachment', 'Public');
        Core_Notes_Attachments_Ctrl.updateAccessLevel(attList[0].Id, 'Attachment', 'Private');
        Core_Notes_Attachments_Ctrl.updateAccessLevel(fileList[0].ContentDocumentId, 'File', 'Public');
        Core_Notes_Attachments_Ctrl.updateAccessLevel(fileList[0].ContentDocumentId, 'File', 'Private');
        Core_Notes_Attachments_Ctrl.delNote(ntList[0].Id);
        Core_Notes_Attachments_Ctrl.delAttachment(attList[0].Id);
        Core_Notes_Attachments_Ctrl.delEnhancedNote(contNoteList[0].Id);
        Core_Notes_Attachments_Ctrl.delFile(fileList[0].Id);
    }
}