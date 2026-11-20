@isTest
public class UCD_ACM_ContactOwnerChangeBatchTest {
    
     @TestSetup
    private static void setCommonData() {
        
     List<Core_Opp_Bypass_Validation_Rule__c> lstoppmetadta = [ select id, SetupOwnerId, Bypass__c from Core_Opp_Bypass_Validation_Rule__c where SetupOwnerId = : UserInfo.getUserId()] ;
              
        Account acc = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestDuplicateAccount','Intel Account','UNFD_GLBL_CUST');
        acc.Core_Data_Country_Nm__c = 'India';
        acc.Core_Data_Simplified_Account_Nm__c = 'TestDuplicateAccount';
        insert acc;

        
        
        Contact contact = new Contact(FirstName='testFirstName123', LastName='TestLastName', Email='test1234@testing.com.test',
                                          AccountId=acc.id,Core_Set_ERPM_Status_Bypass__c=true,Core_Personal_Email_Indicator__c = true,
                                          Core_Audience_List__c ='CCF User Administrator;CCF User');
        insert contact; 
        
        
        Core_Contact_Bypass_Validation_Rule__c contactVal = new Core_Contact_Bypass_Validation_Rule__c();
        contactVal.Bypass__c = false;
        contactVal.SetupOwnerId = UserInfo.getUserId();
        insert contactVal;
 	
       
    }
    
    @isTest
    private static void batchExecution(){
        Id batchJobId = Database.executeBatch(new UCD_ACM_ContactOwnerChangeBatch(), 200);

    }

}