@isTest
public class Core_ContentDocumentTrigger_Test {
    @istest
    static void ContentDocumentDeletiontest() {
        List<Account> testAccount = Core_Test_Utility.createAccount(1);
        insert testAccount;
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Content',
            PathOnClient = 'TestPath',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert testContentVersion;
        ContentVersion testContentVersion1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:testContentVersion.Id];
        Account testAccount1 = [SELECT id FROM Account limit 1];
        
            ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = testContentVersion1.ContentDocumentId,
            LinkedEntityId = testAccount1.Id,
            ShareType = 'V'
        );
        insert testContentDocumentLink; 
        ContentDocument testContentDocument1 = [SELECT id FROM ContentDocument where id =:testContentVersion1.ContentDocumentId];
        
        delete testContentDocument1;       
    }      
    
}