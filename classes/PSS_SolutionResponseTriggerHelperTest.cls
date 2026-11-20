/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_SolutionResponseTriggerHelperTest {
/*@isTest
    public static void solutionResponseTest(){
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
        UserRole role = [Select id from UserRole where DeveloperName = 'Admin' limit 1]; 
        adminUser.userRoleId = role.id;
        update adminUser;
        
        System.runAs(adminUser){
        ArdiraSurvey__Survey__c survey=new ArdiraSurvey__Survey__c();
        survey.ArdiraSurvey__CNav_Pagination__c='Section';
        survey.Name='Solution Survey';
        survey.ArdiraSurvey__Status__c='Closed';
        insert survey;
        PMP_TestDataUtility.createDocument();
        Account acc = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        Contact con = PMP_TestDataUtility.createContact(acc.Id, true);
    
        Profile profileName= [Select Id from profile where Name='Partner']; 
        User newUser=PMP_TestDataUtility.createTestUser(profileName);
        newUser.ContactId = con.Id;
        insert newUser;
      
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account accOPID = PMP_TestDataUtility.createAccount('TestPAgAccount1',devRecordTypeId , true);

        ArdiraSurvey__Survey_Result__c result=new ArdiraSurvey__Survey_Result__c();
        result.ArdiraSurvey__Survey__c=survey.id;
        result.PSS_Partner_Account_Id__c=acc.id;
        result.ArdiraSurvey__Assigned_To_User__c=newUser.id;
        result.PSS_Partner_Solution_Lifecycle_Status_Nm__c='Admin Review';
        result.PSS_Comma_Separated_Intel_Products_Txt__c='Intel,Intel';
        result.PSS_Strategic_Attributes_Nm__c = 'Vision;Workload Consolidation';
        result.PSS_Intel_Admin_Id__c=newUser.id;
        insert result;
        
        ArdiraSurvey__Survey_Result__c result2=new ArdiraSurvey__Survey_Result__c();
        result2.ArdiraSurvey__Survey__c=survey.id;
        result2.PSS_Partner_Account_Id__c=acc.id;
        result2.ArdiraSurvey__Assigned_To_User__c=newUser.id;
        result2.PSS_Partner_Solution_Lifecycle_Status_Nm__c='Approved';
        result2.PSS_Comma_Separated_Intel_Products_Txt__c='Intel,Intel';
        result2.PSS_Strategic_Attributes_Nm__c = 'Vision;Workload Consolidation';
        result2.PSS_Intel_Admin_Id__c=newUser.id;
        insert result2;
        
        ArdiraSurvey__Survey_Result__c result3=new ArdiraSurvey__Survey_Result__c();
        result3.ArdiraSurvey__Survey__c=survey.id;
        result3.PSS_Partner_Account_Id__c=acc.id;
        result3.ArdiraSurvey__Assigned_To_User__c=newUser.id;
        result3.PSS_Partner_Solution_Lifecycle_Status_Nm__c='On Hold';
        result3.PSS_Comma_Separated_Intel_Products_Txt__c='Intel,Intel';
        result3.PSS_Strategic_Attributes_Nm__c = 'Vision;Workload Consolidation';
        result3.PSS_Intel_Admin_Id__c=newUser.id;
        insert result3;
        
        ArdiraSurvey__Survey_Result__c result4=new ArdiraSurvey__Survey_Result__c();
        result4.ArdiraSurvey__Survey__c=survey.id;
        result4.PSS_Partner_Account_Id__c=acc.id;
        result4.ArdiraSurvey__Assigned_To_User__c=newUser.id;
        result4.PSS_Partner_Solution_Lifecycle_Status_Nm__c='Review Scheduled';
        result4.PSS_Comma_Separated_Intel_Products_Txt__c='Intel,Intel';
        result4.PSS_Strategic_Attributes_Nm__c = 'Vision;Workload Consolidation';
        result4.PSS_Intel_Admin_Id__c=newUser.id;
        insert result4;
        
        ArdiraSurvey__Survey_Result__c result5=new ArdiraSurvey__Survey_Result__c();
        result5.ArdiraSurvey__Survey__c=survey.id;
        result5.PSS_Partner_Account_Id__c=acc.id;
        result5.ArdiraSurvey__Assigned_To_User__c=newUser.id;
        result5.PSS_Partner_Solution_Lifecycle_Status_Nm__c='Update Required';
        result5.PSS_Comma_Separated_Intel_Products_Txt__c='Intel,Intel';
        result5.PSS_Strategic_Attributes_Nm__c = 'Vision;Workload Consolidation';
        result5.PSS_Intel_Admin_Id__c=newUser.id;
        result5.ArdiraSurvey__Assigned_To_Contact__c = con.Id;
        insert result5;
        
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c();
        agm.Core_Intel_Account_Id__c=acc.id;
        agm.Core_Partner_Account_Id__c=accOPID.id;
        insert agm;
        
        AccountTeamMember atm =new AccountTeamMember();
        atm.UserId = newUser.id;
        atm.AccountId =acc.id;
        insert atm;
       system.assertEquals('Review Scheduled', result4.PSS_Partner_Solution_Lifecycle_Status_Nm__c);
            
        List<ArdiraSurvey__Survey_Workflow_Stage__c> workStageList = New List<ArdiraSurvey__Survey_Workflow_Stage__c>();
        ArdiraSurvey__Survey_Workflow_Stage__c workStage1 = New ArdiraSurvey__Survey_Workflow_Stage__c();
        workStage1.ArdiraSurvey__Survey__c = survey.Id;
        workStage1.ArdiraSurvey__Rank__c = 1;
        workStage1.Name = PSS_StaticConstants.DATA_COLLECTION;
        workStageList.add(workStage1);
        
        ArdiraSurvey__Survey_Workflow_Stage__c workStage2 = New ArdiraSurvey__Survey_Workflow_Stage__c();
        workStage2.ArdiraSurvey__Survey__c = survey.Id;
        workStage2.ArdiraSurvey__Rank__c = 2;
        workStage2.Name = PSS_StaticConstants.REVIEW;
        workStageList.add(workStage2);
        
        insert workStageList;
        
        List<ArdiraSurvey__Question__c> questionList =New List<ArdiraSurvey__Question__c>();
        ArdiraSurvey__Question__c question1 = New ArdiraSurvey__Question__c();
        question1.PSS_Question_Unique_Key_Txt__c = 'IOTG_IntelProduct';
        question1.ArdiraSurvey__Survey__c = survey.Id;
        questionList.add(question1);
        
        ArdiraSurvey__Question__c question2 = New ArdiraSurvey__Question__c();
        question2.PSS_Question_Unique_Key_Txt__c = 'IOTG_ProjectedQuantity';
        question2.ArdiraSurvey__Survey__c = survey.Id;
        questionList.add(question2);
        
        ArdiraSurvey__Question__c question3 = New ArdiraSurvey__Question__c();
        question3.PSS_Question_Unique_Key_Txt__c = 'IOTG_Virtual_Layer';
        question3.ArdiraSurvey__Survey__c = survey.Id;
        questionList.add(question3);
        
        ArdiraSurvey__Question__c question4 = New ArdiraSurvey__Question__c();
        question4.PSS_Question_Unique_Key_Txt__c = 'DCG_IntelProduct';
        question4.ArdiraSurvey__Survey__c = survey.Id;
        questionList.add(question4);
        
        insert questionList;
        
        List<ArdiraSurvey__Question_Result__c> questionResultList =New List<ArdiraSurvey__Question_Result__c>();
        ArdiraSurvey__Question_Result__c questResult1 = New ArdiraSurvey__Question_Result__c();
        questResult1.ArdiraSurvey__Repeat_Position__c = '001';
        questResult1.ArdiraSurvey__Answer_Text__c ='Intel® Xeon SP Bronze';
        questResult1.ArdiraSurvey__Question__c = question1.Id;
        questResult1.ArdiraSurvey__Survey__c = survey.Id;
        questResult1.ArdiraSurvey__Survey_Result__c = result.Id;
        questionResultList.add(questResult1);
        
        ArdiraSurvey__Question_Result__c questionResult2 = New ArdiraSurvey__Question_Result__c();
        questionResult2.ArdiraSurvey__Repeat_Position__c = '001';
        questionResult2.ArdiraSurvey__Answer_Number__c = 1000;
        questionResult2.ArdiraSurvey__Survey__c = survey.Id;
        questionResult2.ArdiraSurvey__Survey_Result__c = result.Id;
        questionResult2.ArdiraSurvey__Question__c = question2.Id;
        questionResultList.add(questionResult2);
        
        ArdiraSurvey__Question_Result__c questionResult3 = New ArdiraSurvey__Question_Result__c();
        questionResult3.ArdiraSurvey__Repeat_Position__c = '002';
        questionResult3.ArdiraSurvey__Answer_Text__c ='Yes';
        questionResult3.ArdiraSurvey__Question__c = question3.Id;
        questionResult3.ArdiraSurvey__Survey__c = survey.Id;
        questionResult3.ArdiraSurvey__Survey_Result__c = result.Id;
        questionResultList.add(questionResult3);
        
        ArdiraSurvey__Question_Result__c questionResult4 = New ArdiraSurvey__Question_Result__c();
        questionResult4.ArdiraSurvey__Repeat_Position__c = '001';
        questionResult4.ArdiraSurvey__Answer_Text__c ='Yes,No';
        questionResult4.ArdiraSurvey__Question__c = question4.Id;
        questionResult4.ArdiraSurvey__Survey__c = survey.Id;
        questionResult4.ArdiraSurvey__Survey_Result__c = result.Id;
        questionResultList.add(questionResult4);
        
        insert questionResultList;
        
        PSS_Intel_Products__c intelProduct1 = New PSS_Intel_Products__c();
        intelProduct1.PSS_ASP__c = 1000;
        intelProduct1.Name = 'Intel® Xeon SP Bronze';
        intelProduct1.PSS_Product_Type_Txt__c = 'CPU';
        insert intelProduct1;
        
      
        List<ArdiraSurvey__Survey_Result__c> listAdd=new List<ArdiraSurvey__Survey_Result__c>();
        listadd.add(result);
        listadd.add(result2);
        listadd.add(result3);
        listadd.add(result4);
        listadd.add(result5);
        Set<Id> surveyIds = New Set<Id>();
        surveyIds.add(survey.Id);
        
        map<Id,ArdiraSurvey__Survey_Result__c> oldMap = new map<Id,ArdiraSurvey__Survey_Result__c>();
        oldMap.put(result.id, result);
        oldMap.put(result2.id, result2);
        oldMap.put(result3.id, result3);
        oldMap.put(result4.id, result4);
        oldMap.put(result5.id, result5);
        
        List<ArdiraSurvey__Survey_Result__c> updateListAdd=new List<ArdiraSurvey__Survey_Result__c>();
        result.PSS_Intel_Admin_Id__c = adminUser.Id;//added dynamic value
        updateListAdd.add(result);
        updateListAdd.add(result2);
        updateListAdd.add(result3);
        updateListAdd.add(result4);
        updateListAdd.add(result5);
        
        Test.startTest();
        PSS_SolutionResponseTriggerHelper.populateIntelProducts(listadd, oldMap);
        PSS_SolutionResponseTriggerHelper.createSharingRecords(listadd);
		PSS_SolutionResponseTriggerHelper.populateArdiraStatusAndStage(listadd,surveyIds);
        PSS_SolutionResponseTriggerHelper.populateSolutionFieldsFromQuestionResult(listadd);
        PSS_SolutionResponseTriggerHelper.populateApprovedDate(listadd,oldMap);
        PSS_SolutionResponseTriggerHelper.populateSearchableFields(updateListAdd,oldMap); 
        PSS_SolutionResponseTriggerHelper.populateSearchableFields(listadd,oldMap); 
        Test.stopTest();
        
        system.assertEquals(surveyIds.size(), 1,'equal');
        result.PSS_Partner_Solution_Lifecycle_Status_Nm__c='Update Required';
        update result;
        }
    }*/
}