@isTest
public class PSG_FeedbackControllerTest {
    
    @testSetup 
    static void setup(){
        Account acc1 = PSG_Test_Utility.createAccount();
        Contact con1 = PSG_Test_Utility.createContactWithEmail(acc1.Id,'PSGFeedbackUserInternal@example.com');
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u2 = new User(Alias = 'newUser', Email='PSGFeedbackUserInternal@example.com',
                           EmailEncodingKey='UTF-8', LastName='Testing_Internal', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p2.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='PSGFeedbackUserInternal@example.com');
        insert u2;
        //Create quote for both Users
        List<SBQQ__Quote__c> quote1 = PSG_Test_Utility.createQuote(acc1.Id,con1.Id,1);
        // Create a test instance of PSG_Feedback_Setting__c
        PSG_Feedback_Setting__c settingForEmoji = new PSG_Feedback_Setting__c(
            core_cpq_enabled__c = true,
            core_cpq_start_date__c = Date.today(),
            core_cpq_end_date__c = Date.today() + 30,
            core_cpq_emoji_form__c = true,
            core_cpq_feedback_interval__c = -5,
            core_cpq_skipped_interval__c = -1
        );
        insert settingForEmoji;
    }
    
    static testmethod void testFeedbackWrapper(){
        PSG_FeedbackController.FeedbackWrapper wrapper = new PSG_FeedbackController.FeedbackWrapper(false,false,false);
        System.assertEquals(false, wrapper.isFormVisible);
        System.assertEquals(false, wrapper.isEmoji);
        System.assertEquals(false, wrapper.isStar);
    }
    
    static testmethod void testGetFormDetails(){
        //Declaring Feedback Wrapper class with default value false for all variable.
        PSG_FeedbackController.FeedbackWrapper wrapper = new PSG_FeedbackController.FeedbackWrapper(false,false,false);
        //Calling Feedback Controller getFormDetails for the first time login user.
        wrapper = PSG_FeedbackController.getFormDetails();
        
        //Verifing the returned values.
        System.assertEquals(true, wrapper.isFormVisible, 'Form should be visible');
        System.assertEquals(true, wrapper.isEmoji, 'Emoji form should be enabled');
        System.assertEquals(false, wrapper.isStar, 'Star form should be disable');
        
        //Creating record for skipped feedback with Type as 'Skipped'
        Sales_Feedback__c skippedFeedback = new Sales_Feedback__c(
            Type__c = 'Skipped'
        );
        insert skippedFeedback;
        //Calling again the getformDetails for 2nd condition check.
        wrapper = PSG_FeedbackController.getFormDetails();
        
        //Verifing the returned values.
        System.assertEquals(true, wrapper.isFormVisible, 'Form should be visible');
        System.assertEquals(true, wrapper.isEmoji, 'Emoji form should be enabled');
        System.assertEquals(false, wrapper.isStar, 'Star form should be disable');
        
        //Creating record for new feedback after interval
        //Adding Rating and Comments.
        skippedFeedback.Type__c = 'Feedback';
        skippedFeedback.Rating__c ='Satisfied';
        update skippedFeedback;
        //Verifing the returned values.
        wrapper = PSG_FeedbackController.getFormDetails();
        System.assertEquals(true, wrapper.isFormVisible, 'Form should be visible');
        System.assertEquals(true, wrapper.isEmoji, 'Emoji form should be enabled');
        System.assertEquals(false, wrapper.isStar, 'Star form should be disable');
    }
    
    static testmethod void testGetFormDetails_notActive(){
        PSG_Feedback_Setting__c newSetting = [SELECT Id,core_cpq_enabled__c from PSG_Feedback_Setting__c];
        newSetting.core_cpq_enabled__c = false;
        update newSetting;
        PSG_FeedbackController.FeedbackWrapper wrapper = new PSG_FeedbackController.FeedbackWrapper(false,false,false);
        wrapper = PSG_FeedbackController.getFormDetails();
        System.assertEquals(false, wrapper.isFormVisible, 'Form should not be visible');
        System.assertEquals(true, wrapper.isEmoji, 'Emoji form should not be enabled');
        System.assertEquals(false, wrapper.isStar, 'Star form should not be disable');
    }
    
    static testmethod void testSubmitFeedbackExternal(){
        // Create a Disty user
        Account acc = PSG_Test_Utility.createAccount();
        Profile p = [SELECT Id,Name,UserType FROM Profile WHERE Name='IT Admin' LIMIT 1];
        Contact con=new Contact(FirstName='Feedback',LastName ='User',
                                Email='PSGFeedbackUserExternal@gmail.com',AccountId=acc.id);
        insert con;
        User u = new User(Alias = 'standt', Email='PSGFeedbackUserExternal@example.com',
                          EmailEncodingKey='UTF-8', LastName='Testing_External', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,CommunityNickname = 'PSG Feeback User',
                          TimeZoneSidKey='America/Los_Angeles', UserName='PSGFeedbackUserExternal@example.com');
        insert u;
        System.runAs(u){
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name ='CPQ_Managed_License_User' OR Name='PSG_External_Disty' LIMIT 1];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
            List<PermissionSetAssignment> psaa = [SELECT Id, PermissionSetId, PermissionSetGroupId, AssigneeId, SystemModstamp, ExpirationDate, IsActive  from PermissionSetAssignment where AssigneeId=:u.Id];
            //Calling the feedback Submit for the first time record creation.
            //As Type = 'Feedback'
            PSG_FeedbackController.feedbackSubmit('Satisfied', 'This is test comment', 'Feedback');
            //Verifing the result.
            List<Sales_Feedback__c> result = [SELECT Feedback_Text__c,Type__c,User__c from Sales_Feedback__c];
            System.assertEquals(1, result.size());
            System.assertEquals('Feedback', result[0].Type__c);
            
            //Calling the feedback submit for new feedback record after crossing the interval days.
            PSG_FeedbackController.feedbackSubmit('Satisfied', '2nd Feedback', 'Feedback');
            result = [SELECT Feedback_Text__c,Type__c,User__c from Sales_Feedback__c];
            //Verifing the results.
            System.assertEquals(2, result.size());
            System.assertEquals('2nd Feedback', result[1].Feedback_Text__c);
        }
    }
    
    static testmethod void testSubmitFeedbackInternal(){
        User u2 = [SELECT Id from User where LastName='Testing_Internal'];
        System.runAs(u2){
            //Calling the feedback Submit for the first time record creation.
            //As Type = 'Feedback'
            PSG_FeedbackController.feedbackSubmit('Satisfied', 'This is test comment', 'Feedback');
            
            //Verifing the result.
            List<Sales_Feedback__c> result = [SELECT Feedback_Text__c,Type__c,User__c from Sales_Feedback__c];
            System.assertEquals(1, result.size());
            System.assertEquals('Feedback', result[0].Type__c);
            
            //Calling the feedback submit for new feedback record after crossing the interval days.
            PSG_FeedbackController.feedbackSubmit('Satisfied', '2nd Feedback', 'Feedback');
            result = [SELECT Feedback_Text__c,Type__c, User__c from Sales_Feedback__c];
            //Verifing the results.
            System.assertEquals(2, result.size());
            System.assertEquals('2nd Feedback', result[1].Feedback_Text__c);
        }
    }
    
    static testmethod void testSubmitFeedback_skipped(){
        User u2 = [SELECT Id from User where LastName='Testing_Internal'];
        System.runAs(u2){
            Sales_Feedback__c newRecord = new Sales_Feedback__c(
                Type__c = 'Skipped'
            );
            insert newRecord;
            //Calling the feedback submit for skipped record.
            PSG_FeedbackController.feedbackSubmit('', '', 'Skipped');
            List<Sales_Feedback__c> result = [SELECT Feedback_Text__c,Type__c from Sales_Feedback__c];
            //Verifing the results.
            System.assertEquals(1, result.size());
            System.assertEquals('Skipped', result[0].Type__c);
        }
    }
}