@isTest
public class Core_IPS_Accept_Part_Support_Contr_Test{
   static Account testAccount=null;
   static Contact testContact=null;
    public static void testDataSetup(){
        testAccount=TestUtilities.getAccount();
        insert testAccount;
        System.assert(testAccount.Id != null, 'Record not created');

         
        testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123456@testing.com.testsetup',
                                 AccountId=testAccount.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',MailingCountry = 'India');
        insert testContact;
        System.assert(testContact.Id != null, 'Record not created');

    }
    public static testmethod void getAssignment(){
        // Query Profiles
        User logedInUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( logedInUser ) {
            testDataSetup();
        }
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'partner'];
        
        User userTest = new User(alias = 'test123', email='test123@inteltest.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',ProfileId=ProfileList[0].id,
        IsActive =true,
        ContactId = testContact.Id, username='tester@inteltest.com');
        
        insert userTest;
        PermissionSet ps = [select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set'];
        PermissionSet ps1 = [select id,label from PermissionSet where Label = 'IPS Permission Set'];
        insert new PermissionSetAssignment(AssigneeId = userTest.id, PermissionSetId = ps.Id );
        insert new PermissionSetAssignment(AssigneeId = userTest.id, PermissionSetId = ps1.Id );
        
        System.runAs(userTest){
        
        Case caseRecord=  TestUtilities.getCase(); 
        System.assertNotEquals(null, testAccount.id);
        caseRecord.AccountId=testAccount.id;
        caseRecord.contactid=testContact.id;
        
        insert caseRecord;
        System.assert(caseRecord.Id != null, 'Record not created');

        ApexPages.StandardController sc = new ApexPages.StandardController(caseRecord);
        Core_IPS_Accept_Part_Support_Controller controller =new Core_IPS_Accept_Part_Support_Controller(sc);
        controller.updateOwner();
        controller.goback();
        }
    }
     public static testmethod void withoutAssignment(){
            User logedInUser = [ select Id from User where Id = :UserInfo.getUserId() ];
            System.runAs ( logedInUser ) {
                testDataSetup();
            }
            Case caseRecord=  TestUtilities.getCase(); 
            caseRecord.AccountId=testAccount.id;
            caseRecord.contactid=testContact.id;
         
            insert caseRecord;
            System.assert(caseRecord.Id != null, 'Record not created');

            ApexPages.StandardController sc = new ApexPages.StandardController(caseRecord);
            Core_IPS_Accept_Part_Support_Controller controller =new Core_IPS_Accept_Part_Support_Controller(sc);
            controller.updateOwner();
            controller.goback();
    }
    
}