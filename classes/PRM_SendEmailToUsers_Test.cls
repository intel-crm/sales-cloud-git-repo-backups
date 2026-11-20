@isTest
public class PRM_SendEmailToUsers_Test {
    @isTest
    static void testSendData() {
        
        EmailTemplate template1 = new EmailTemplate(DeveloperName='dev_name', Body='body', Subject='subject'); //Description = 'there is rec success', Encoding = 'there is rec fail');
       // insert template1;

        EmailTemplate validEmailTemplate2 = new EmailTemplate();
        validEmailTemplate2.Subject= 'bulksbuject';
        validEmailTemplate2.isActive = true;
        validEmailTemplate2.Name = 'name';
        validEmailTemplate2.Body = 'test email body';
        validEmailTemplate2.DeveloperName = 'SolutionShared_Submitter';
        validEmailTemplate2.TemplateType = 'text';
        validEmailTemplate2.FolderId = UserInfo.getUserId();
        insert validEmailTemplate2;

        User usr = [Select id from User where Id = :UserInfo.getUserId()];

 

        System.RunAs(usr)
   
        {
   
           Test.startTest();

        string bulkRecStringForExcelSuccess = 'Record Success ContactEmail, LastName, FirstName, status \n';
        
        PRM_SendEmailToUsers.sendData(validEmailTemplate2.DeveloperName,bulkRecStringForExcelSuccess,'', template1.Body, template1.Subject);
        
        string bulkRecStringForExcelFail = 'Record Fail ContactEmail, LastName, FirstName, status \n';
        
        PRM_SendEmailToUsers.sendData(validEmailTemplate2.DeveloperName,'',bulkRecStringForExcelFail,template1.Body, template1.Subject);
            test.stopTest();
    }
        
    }
    
}