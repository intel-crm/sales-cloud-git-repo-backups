@isTest
public class Core_IPS_Accept_Case_Controller_Test{
    static testmethod void partnerSupportTest(){
        Case Cs =  TestUtilities.getCase(); 
            Account testAccount=TestUtilities.getAccount();
            insert testAccount;
             
            Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test1234@testing.com.testsetup',
                                     AccountId=testAccount.id,Core_Personal_Email_Indicator__c = true,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',MailingCountry = 'India');
            insert testContact;
            System.assertNotEquals(null, testAccount.id);
            cs.AccountId=testAccount.id;
            cs.contactid=testContact.id;
            insert Cs;
        Core_IPS_Accept_Case_Controller controller= new Core_IPS_Accept_Case_Controller(new ApexPages.StandardController(Cs));
        controller.updateCaseOwner();
        controller.goBack();
        Cs=new Case();
        Core_IPS_Accept_Case_Controller controller2= new Core_IPS_Accept_Case_Controller(new ApexPages.StandardController(Cs));
        controller2.updateCaseOwner(); 
        
    }
}