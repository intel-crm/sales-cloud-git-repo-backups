/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_PartnerResponsePageCtrlTest {
/*@isTest
    public static void partnerRespoonsePageTest(){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account acc = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
        
        ArdiraSurvey__Survey__c survey=new ArdiraSurvey__Survey__c();
        survey.ArdiraSurvey__CNav_Pagination__c='Section';
        survey.Name='Solution Survey';
        survey.ArdiraSurvey__Status__c='Closed';
        insert survey;
        Profile profileName= [Select Id from profile where Name='System Administrator']; 
        User newUser=PMP_TestDataUtility.createTestUser(profileName); 
        insert newUser;
        ArdiraSurvey__Survey_Result__c result=new ArdiraSurvey__Survey_Result__c();
        result.ArdiraSurvey__Survey__c=survey.id;
        result.PSS_Partner_Account_Id__c=acc.id;
        result.ArdiraSurvey__Assigned_To_User__c=newUser.id;
        result.PSS_Partner_Solution_Lifecycle_Status_Nm__c='Draft';
        insert result;
        ArdiraSurvey__Question__c ques=new ArdiraSurvey__Question__c();
        ques.ArdiraSurvey__C_Date_Correct_Answer_When__c='Answered';
        ques.ArdiraSurvey__C_Polar_Correct_Answer_When__c='True';
        ques.ArdiraSurvey__C_Radio_Display__c='Vertical Radio';
        ques.ArdiraSurvey__C_Ranking_Correct_Answer_When__c='Correct Order';
        ques.ArdiraSurvey__C_Text_Correct_Answer_When__c='Answered';
        ques.ArdiraSurvey__C_Display_Image_Size__c='Small';
        ques.ArdiraSurvey__Question__c='Comments(include SKU if known)';
        ques.ArdiraSurvey__C_Alignment__c='Left';
        ques.ArdiraSurvey__C_Help_Text_Display__c='As Tooltip';
        ques.ArdiraSurvey__Date_Allowed_Dates__c='Any';
        ques.ArdiraSurvey__C_Multiple_Choice_Display__c='Checkbox';
        ques.ArdiraSurvey__C_Multiple_Choice_Scoring_option__c='Use Choice Score';
        ques.ArdiraSurvey__C_Polar_Yes_No_Display__c='YesNo';
        ques.ArdiraSurvey__C_Rating_Shape__c='Star';
        ques.ArdiraSurvey__Rating_Rating_Range__c='3';
        ques.ArdiraSurvey__Question_Plain_Text__c='Intel Product';
        insert ques;
      
        ArdiraSurvey__Question__c ques1=new ArdiraSurvey__Question__c();
        ques1.ArdiraSurvey__C_Date_Correct_Answer_When__c='Answered';
        ques1.ArdiraSurvey__C_Polar_Correct_Answer_When__c='True';
        ques1.ArdiraSurvey__C_Radio_Display__c='Vertical Radio';
        ques1.ArdiraSurvey__C_Ranking_Correct_Answer_When__c='Correct Order';
        ques1.ArdiraSurvey__C_Text_Correct_Answer_When__c='Answered';
        ques1.ArdiraSurvey__C_Display_Image_Size__c='Small';
        ques1.ArdiraSurvey__Question__c='Intel Product';
        ques1.ArdiraSurvey__C_Alignment__c='Left';
        ques1.ArdiraSurvey__C_Help_Text_Display__c='As Tooltip';
        ques1.ArdiraSurvey__Date_Allowed_Dates__c='Any';
        ques1.ArdiraSurvey__C_Multiple_Choice_Display__c='Checkbox';
        ques1.ArdiraSurvey__C_Multiple_Choice_Scoring_option__c='Use Choice Score';
        ques1.ArdiraSurvey__C_Polar_Yes_No_Display__c='YesNo';
        ques1.ArdiraSurvey__C_Rating_Shape__c='Star';
        ques1.ArdiraSurvey__Rating_Rating_Range__c='3';
        ques1.PSS_Question_Unique_Key_Txt__c='IOTG_IntelProduct';
        ques1.ArdiraSurvey__Question_Plain_Text__c='Intel Product';
        insert ques1;
         ArdiraSurvey__Question__c ques2=new ArdiraSurvey__Question__c();
        ques2.ArdiraSurvey__C_Date_Correct_Answer_When__c='Answered';
        ques2.ArdiraSurvey__C_Polar_Correct_Answer_When__c='True';
        ques2.ArdiraSurvey__C_Radio_Display__c='Vertical Radio';
        ques2.ArdiraSurvey__C_Ranking_Correct_Answer_When__c='Correct Order';
        ques2.ArdiraSurvey__C_Text_Correct_Answer_When__c='Answered';
        ques2.ArdiraSurvey__C_Display_Image_Size__c='Small';
        ques2.ArdiraSurvey__Question__c='Intel Product';
        ques2.ArdiraSurvey__C_Alignment__c='Left';
        ques2.ArdiraSurvey__C_Help_Text_Display__c='As Tooltip';
        ques2.ArdiraSurvey__Date_Allowed_Dates__c='Any';
        ques2.ArdiraSurvey__C_Multiple_Choice_Display__c='Checkbox';
        ques2.ArdiraSurvey__C_Multiple_Choice_Scoring_option__c='Use Choice Score';
        ques2.ArdiraSurvey__C_Polar_Yes_No_Display__c='YesNo';
        ques2.ArdiraSurvey__C_Rating_Shape__c='Star';
        ques2.ArdiraSurvey__Rating_Rating_Range__c='3';
        insert ques2;
        
         ArdiraSurvey__Question__c ques3 = New ArdiraSurvey__Question__c();
        ques3.PSS_Question_Unique_Key_Txt__c = 'IOTG_ProjectedQuantity';
        ques3.ArdiraSurvey__Survey__c = survey.Id;
        insert ques3;
        
        ArdiraSurvey__Question__c ques4 = New ArdiraSurvey__Question__c();
        ques4.PSS_Question_Unique_Key_Txt__c = 'IOTG_Comments';
        ques4.ArdiraSurvey__Survey__c = survey.Id;
        insert ques4;
        
        ArdiraSurvey__Question_Result__c questionResult=new ArdiraSurvey__Question_Result__c();
        questionResult.ArdiraSurvey__Survey_Result__c=result.id;
        questionResult.ArdiraSurvey__Question__c=ques.id;
        questionResult.ArdiraSurvey__Survey__c=survey.id;
        questionResult.ArdiraSurvey__Answer_Text__c='Testing Testing';
        questionResult.ArdiraSurvey__Answered__c=true;
        insert questionResult;
         ArdiraSurvey__Question_Result__c questionResult1=new ArdiraSurvey__Question_Result__c();
        questionResult1.ArdiraSurvey__Survey_Result__c=result.id;
        questionResult1.ArdiraSurvey__Question__c=ques1.id;
        questionResult1.ArdiraSurvey__Survey__c=survey.id;
        questionResult1.ArdiraSurvey__Answer_Text__c='Intel';
        questionResult1.ArdiraSurvey__Answered__c=true;
        insert questionResult1;
         ArdiraSurvey__Question_Result__c questionResult2=new ArdiraSurvey__Question_Result__c();
        questionResult2.ArdiraSurvey__Survey_Result__c=result.id;
        questionResult2.ArdiraSurvey__Question__c=ques2.id;
        questionResult2.ArdiraSurvey__Survey__c=survey.id;
        questionResult2.ArdiraSurvey__Answered__c=true;
        insert questionResult2;
        
        ArdiraSurvey__Question_Result__c questionResult3=new ArdiraSurvey__Question_Result__c();
        questionResult3.ArdiraSurvey__Survey_Result__c=result.id;
        questionResult3.ArdiraSurvey__Question__c=ques3.id;
        questionResult3.ArdiraSurvey__Survey__c=survey.id;
        questionResult3.ArdiraSurvey__Answered__c=true;
        insert questionResult3;
        
        ArdiraSurvey__Question_Result__c questionResult4=new ArdiraSurvey__Question_Result__c();
        questionResult4.ArdiraSurvey__Survey_Result__c=result.id;
        questionResult4.ArdiraSurvey__Question__c=ques4.id;
        questionResult4.ArdiraSurvey__Survey__c=survey.id;
        questionResult4.ArdiraSurvey__Answered__c=true;
        insert questionResult4;
        
        
         ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document1';
        cv.PathOnClient = 'TestDocument1.pdf';
        cv.VersionData = Blob.valueOf('Test Content1');
        insert cv;
       Map<Id,ContentVersion> sContentVersionIdListMap = New Map<Id,ContentVersion>([SELECT Id,ContentDocumentId from ContentVersion WHERE Id =:cv.id]);
        List<ContentDocumentLink> sContentLinks = new List<ContentDocumentLink>();
        ContentDocumentLink contentLink1 = new ContentDocumentLink();
        contentLink1.LinkedEntityId = questionResult2.Id;
        contentLink1.ContentDocumentId = sContentVersionIdListMap.get(cv.id).ContentDocumentId;
        contentLink1.ShareType = 'I';
        contentLink1.Visibility = 'AllUsers'; 
        insert contentLink1;
        Test.startTest();
        PSS_PartnerResponsePageCtrl.getPartnerResponses(result.id);
        PSS_PartnerResponsePageCtrl.submitAdminReview(result);
        boolean accessible = PSS_PartnerResponsePageCtrl.accessSolutionRecord(result.id);
        Test.stopTest();
        system.assertEquals(accessible, true, 'equal');
    }*/
}