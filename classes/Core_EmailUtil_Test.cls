/***************************************************************************************************
* Apex Class Name: Core_EmailUtil_Test 
* Version     : 1.0 
* Created Date: 18th Nov 2015
* Function    : Test class for Core_EmailUtil
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     11/18/2015              Created
****************************************************************************************************/
@isTest public class Core_EmailUtil_Test {
    
    private static User SystUserRunAs; 
    private static EmailTemplate EmailTempl;
    private static OrgWideEmailAddress OrgWideEmailObj;
    
/***************************************************************************************************
* Method Name: Core_EmailUtil_Test
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 18th Nov 2015
* Description:  Email sent
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/18/2015              Created
****************************************************************************************************/         
    private static testMethod void should_store_email_results() {
        //Setup test data
        setup_test_data();
        //Start Test
        Test.startTest();
        System.runAs(SystUserRunAs) {        
            // Given an email util that hasn't sent emails
            System.assertEquals(null, Core_EmailUtil.last_sendEmail_result);
            // When you send an email
            Core_EmailUtil.to(new String[]{'test@spam.com'}).sendEmail(false);
            //Stop Test
            Test.stopTest();                
            // Then the email util should store the send result.
            System.assertNotEquals(null, Core_EmailUtil.last_sendEmail_result);
            System.assertEquals(1, Core_EmailUtil.last_sendEmail_result.size());
            for (Messaging.SendEmailResult ser : Core_EmailUtil.last_sendEmail_result)
                System.assertEquals(true, ser.isSuccess());
        }
    }
    
/***************************************************************************************************
* Method Name: Core_EmailUtil_Test
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 18th Nov 2015
* Description:  Email sent with AllorNone = True 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/18/2015              Created
****************************************************************************************************/         
    private static testMethod void should_store_email_results_allnone() {
        //Setup test data
        setup_test_data();
        //Start Test
        Test.startTest();
        System.runAs(SystUserRunAs) {
            // Given an email util that hasn't sent emails
            System.assertEquals(null, Core_EmailUtil.last_sendEmail_result);      
            // When you send an email
            Core_EmailUtil.to(new String[]{'test@spam.com'}).sendEmail(true);
        }
        //Stop Test
        Test.stopTest();                        
        // Then the email util should store the send result.
        System.assertNotEquals(null, Core_EmailUtil.last_sendEmail_result);
        System.assertEquals(1, Core_EmailUtil.last_sendEmail_result.size());
        for (Messaging.SendEmailResult ser : Core_EmailUtil.last_sendEmail_result)
            System.assertEquals(true, ser.isSuccess());
    } 
/***************************************************************************************************
* Method Name: Core_EmailUtil_Test
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 18th Nov 2015
* Description:  Email with Template 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/18/2015              Created
****************************************************************************************************/         
    private static testMethod void should_work_with_templates() {
        //Setup test data
        setup_test_data();
        //Start Test
        Test.startTest();
        System.runAs(SystUserRunAs) {      
            // Given an email util that has not sent emails, and a template for emails
            System.assertEquals(null, Core_EmailUtil.last_sendEmail_result);            
            // When an email is constructed & sent to the current user with that template
            Core_EmailUtil.to(UserInfo.getUserId())
                .templateId(EmailTempl.Id)
                .sendEmail(false);
        }
        //Stop Test
        Test.stopTest();                        
        // Then it should be sent successfully
        System.assertEquals(1, Core_EmailUtil.last_sendEmail_result.size());
        for (Messaging.SendEmailResult ser : Core_EmailUtil.last_sendEmail_result){
            System.assertEquals(true, ser.isSuccess());
        }   
    }   

/***************************************************************************************************
* Method Name: Core_EmailUtil_Test
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 18th Nov 2015
* Description:  Email with Bulk collect processing 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/18/2015              Created
****************************************************************************************************/            
    private static testMethod void should_bulk_stash() {
        //Setup test data
        setup_test_data();
        //Start Test
        Test.startTest();
        System.runAs(SystUserRunAs) {
            // Given an EmailUtil that doesn't have emails to send.
            System.assertEquals(false, Core_EmailUtil.hasEmailsToSend());		
            // When you stash an email to send
            Core_EmailUtil.to(new String[]{'test@spam.com'})
                .stashForBulk();     
        }
        //Stop Test
        Test.stopTest();                        
		// Then EmailUtil should have emails to send
		System.assertEquals(true, Core_EmailUtil.hasEmailsToSend());        
    } 
/***************************************************************************************************
* Method Name: Core_EmailUtil_Test
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 18th Nov 2015
* Description:  Email with Bulk processing 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/18/2015              Created
****************************************************************************************************/                
    private static testMethod void should_bulk_send() {
        //Setup test data
        setup_test_data();
        //Start Test
        Test.startTest();
        System.runAs(SystUserRunAs) {
            // Given an EmailUtil that doesn't have emails to send.
            System.assertEquals(false, Core_EmailUtil.hasEmailsToSend());	
            // Given an Email util with  bulk email to send
            Core_EmailUtil.to(new String[]{'test1@spam.com'}).stashForBulk();
            Core_EmailUtil.to(new String[]{'test2@spam.com'}).stashForBulk();
            
            // When you send bulk
            Core_EmailUtil.sendBulkEmail(false);
        }     
        //Stop Test
        Test.stopTest();                        
        // Then two emails should be sent successfully
        system.assertEquals(2, Core_EmailUtil.last_sendEmail_result.size());
        for (Messaging.SendEmailResult ser : Core_EmailUtil.last_sendEmail_result)
            System.assertEquals(true, ser.isSuccess());
        
    }
/***************************************************************************************************
* Method Name: Core_EmailUtil_Test
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 18th Nov 2015
* Description:  Email with Empty Bulk processing 
* Scenario Type: Negative 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/18/2015              Created
****************************************************************************************************/                   
    private static testMethod void should_gracefully_handle_empty_bulk_send() {
        //Setup test data
        setup_test_data();
        //Start Test
        Test.startTest();
        System.runAs(SystUserRunAs) {
            // Given an emailutil with no emails to send
            System.assertEquals(false, Core_EmailUtil.hasEmailsToSend());
            try {
                // When you try and do a bulk send
                Core_EmailUtil.sendBulkEmail(false);
            } catch (Exception e) {
                // then it shouldn't fail horribly.
                System.assert(false);
            }            
        }    
        //Stop Test
        Test.stopTest();                                
    }
/***************************************************************************************************
* Method Name: Core_EmailUtil_Test
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 18th Nov 2015
* Description:  Email with all setters 
* Scenario Type: Negative 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/18/2015              Created
****************************************************************************************************/                   
    private static testMethod void setters_should_not_throw_exceptions() {
        //Setup test data
        setup_test_data();  
        //Start Test
        Test.startTest();
        System.runAs(SystUserRunAs) {
            // Given an emailutil with no emails to send
            System.assertEquals(false, Core_EmailUtil.hasEmailsToSend());        
            try {
                // When using all the setters
                Core_EmailUtil.to(new String[]{'test@spam.com'})
                    .saveAsActivity(false)
                    .senderDisplayName('test sender')
                    .subject('test email')
                    .htmlBody('this is html')
                    .useSignature(false)
                    .replyTo('test@spam.com')
                    .plainTextBody('this is plaintext')
                    .fileAttachments(null)
                    .orgWideEmailAddressId(OrgWideEmailObj.Id);
            } catch (Exception e) {
                // Then it should not throw an exception.
                system.assert(false);
            }
        }
        //Stop Test
        Test.stopTest();                                
    }   
/***************************************************************************************************
* Method Name: Core_EmailUtil_Test
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 18th Nov 2015
* Description:  Test data Creation 
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      11/18/2015              Created
****************************************************************************************************/                
    private static void setup_test_data(){
        Id RoleId;
        //System Admin Profile
        Profile SysAdmPrf = [SELECT Id FROM Profile WHERE Name = : System.label.Core_System_Admin_Profile_Name];
        //Get an Existing System Admin User
        List<User> lstSysUsers = [select id, Name, UserRoleId from User where isActive = true and 
                                  ProfileId =:SysAdmPrf.Id and UserRoleId != null and 
                                  id !=:userinfo.getuserid() limit 1];
        if (lstSysUsers != null && lstSysUsers.size()> 0 ) {
            SystUserRunAs = lstSysUsers[0];  
            system.assert(SystUserRunAs.Id != null);
        } else {
            //Create a New Sys User with New Role
            UserRole TestRl = new UserRole(name = 'TEST ROLE');
            Database.insert(TestRl);
            system.assert(TestRl.Id != null);
            RoleId = TestRl.Id; 
            SystUserRunAs = TestUtilities.getUser();
            SystUserRunAs.userroleid = RoleId;
            SystUserRunAs.alias = 'sysrunas'; 
            SystUserRunAs.email = 'testsysusrrunas@intel.com';
            SystUserRunAs.profileid = SysAdmPrf.Id;
            SystUserRunAs.userName = 'testsysusrrunas@intel.com';
            Database.insert(SystUserRunAs); 
            system.assert(SystUserRunAs.Id != null);            
        }
        //Email Template
        EmailTempl = new EmailTemplate();
        EmailTempl.isActive = true;
        EmailTempl.Name = 'tstemltempl';
        EmailTempl.DeveloperName = 'Notifemltemptst';
        EmailTempl.TemplateType = 'text';
        EmailTempl.FolderId = UserInfo.getUserId();
        Database.insert(EmailTempl);
        system.assert(EmailTempl.Id != null);
        //OW Email id
        OrgWideEmailObj = new OrgWideEmailAddress();       
        OrgWideEmailObj = [select id, Address, DisplayName from OrgWideEmailAddress limit 1];
    }    
}