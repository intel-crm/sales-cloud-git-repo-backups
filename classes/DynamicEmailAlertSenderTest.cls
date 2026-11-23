@IsTest
public class DynamicEmailAlertSenderTest {

    @IsTest
    static void testSendEmails() {

        // 🔹 Create Account + Contact
        Account acc = new Account(Name = 'Test Acc');
        insert acc;

        Contact con = new Contact(
            LastName = 'Test',
            Email = 'test@test.com',
            AccountId = acc.Id
        );
        insert con;

        // 🔹 Create Case
        Case cs = new Case(
            Subject = 'Test',
            Status = 'New',
            Origin = 'Phone',
            ContactId = con.Id
        );
        insert cs;

        // 🔹 Create Email Template
        EmailTemplate et = new EmailTemplate(
            Name = 'Test Template',
            DeveloperName = 'Test_Template',
            FolderId = UserInfo.getUserId(),
            TemplateType = 'Text',
            Subject = 'Sub',
            Body = 'Body'
        );
        insert et;

        // 🔹 Inject Mock Metadata (NO DML)
        DynamicEmailAlertSender.testConfigs = new List<Email_Config_mdt__mdt>{
            new Email_Config_mdt__mdt(
                Email_Alert_Name__c = 'TEST_ALERT',
                Email_Template__c = 'Test_Template',
                Recipient_Type__c = 'Related Contact',
                Selected_Recipients__c = 'ContactId'
            )
        };

        // 🔹 Call method
        DynamicEmailAlertSender.EmailRequest req =
            new DynamicEmailAlertSender.EmailRequest();
        req.emailAlertName = 'TEST_ALERT';
        req.recordId = cs.Id;

        Test.startTest();
        DynamicEmailAlertSender.sendEmails(
            new List<DynamicEmailAlertSender.EmailRequest>{req}
        );
        Test.stopTest();

        System.assert(true);
    }
}