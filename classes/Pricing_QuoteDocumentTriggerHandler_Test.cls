/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-26-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_QuoteDocumentTriggerHandler_Test {
    @testSetup
    static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(adminUserList[0]) {
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Quote_Document_Trigger_Handler_Test');
            
            List<User> accExeUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            
            Test.startTest();
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accExeUserList[0].Email);
            List<SBQQ__QuoteLine__c> quoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 1);                   
            for(SBQQ__QuoteLine__c quoteLine : quoteLines){
                Pricing_Test_Utility.createPerformanceMetrics(quoteLine.Id);
            }
            
            Core_Trigger_Executions__c triggerEntry2 = new Core_Trigger_Executions__c();
            triggerEntry2.name = 'pricingSendOutboundMessagesIQR';
            triggerEntry2.Core_Object__c = 'Descriptive Feature';
            triggerEntry2.Core_Trigger_Events__c = 'After insert';
            triggerEntry2.Core_Active__c = TRUE;
            triggerEntry2.Core_Description__c = 'This is test description';
            triggerEntry2.Core_Class_Name__c = 'Test Class';
            insert triggerEntry2;
            
            Document document;            
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'my_document';
            document.IsPublic = true;
            document.Name = Label.Pricing_IQR_Intel_Logo;
            document.FolderId = userinfo.getuserid();
            insert document;
            Test.stopTest();
            
            SBQQ__QuoteTemplate__c quoteTemplates = new SBQQ__QuoteTemplate__c();
            quoteTemplates.Name = 'IQR Quote Template';
            quoteTemplates.SBQQ__DeploymentStatus__c = 'Deployed';
            quoteTemplates.SBQQ__PageWidth__c = 1.000;
            quoteTemplates.SBQQ__PageHeight__c = 1.000;
            quoteTemplates.SBQQ__TopMargin__c = 1.000;
            quoteTemplates.SBQQ__BottomMargin__c = 1.000;
            quoteTemplates.SBQQ__LeftMargin__c = 1.000;
            quoteTemplates.SBQQ__RightMargin__c = 1.000;
            insert quoteTemplates;         
            
        }                
    } 
    
    @isTest
    private static void testQuoteDocumentSendEmail(){
        test.startTest();
        Contact c = [SELECT Id from Contact LIMIT 1];
        Map<id,SBQQ__Quote__c> quotesMap = new Map<Id,SBQQ__Quote__c>([SELECT id FROM SBQQ__Quote__c Limit 1]);
        List<SBQQ__QuoteLine__c> quoteLies = new List<SBQQ__QuoteLine__c>();
        
        for(SBQQ__QuoteLine__c qli : [SELECT id,Pricing_Status_Nm__c, Pricing_Primary_Contact_Nm__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :quotesMap.keySet()]){
            qli.Pricing_Status_Nm__c = 'Approved';
            qli.Pricing_Primary_Contact_Nm__c = c.Id;
            quoteLies.add(qli);
        }
        if(quoteLies.size() > 0){
            update quoteLies;
        }   
        Blob bodyBlob = Blob.valueOf('This is a test File');
        ContentVersion cv1 = new ContentVersion(Title='SampleFile',PathOnClient='Sample.pdf', VersionData=bodyBlob, Origin='H');
        insert cv1;
        List<ContentVersion> cv2 = [SELECT id,Title,ContentDocumentId FROM ContentVersion WHERE id=:cv1.Id LIMIT 1];
        List<SBQQ__QuoteDocument__c> sr = new List<SBQQ__QuoteDocument__c>();
        for (SBQQ__Quote__c q: quotesMap.values()){
            
            sr.add (new SBQQ__QuoteDocument__c(
                SBQQ__Quote__c = q.Id,
                SBQQ__Template__c = 'Standard Quote',
                SBQQ__DocumentId__c= cv2[0].ContentDocumentId
            ));  
            
        }
        insert sr;
        List<SBQQ__QuoteDocument__c> sr1 = [SELECT id FROM SBQQ__QuoteDocument__c];
        system.assert(sr1.size() > 0);
        
        test.stopTest();
    }
    
}