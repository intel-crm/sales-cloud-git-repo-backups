/****************************************************************************************************************************************
* Class Name  : PSS_SolutionResponse_TriggerHandler_Test 
* Version     : 1.0 
* Created Date: 06/17/2021
* Modification Log :
*
* Developer                                 Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Onyx                                06/17/2021           Test class for the class PSS_SolutionResponse_TriggerHandler
*****************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_SolutionResponse_TriggerHandler_Test {
    /*@testSetup static void setup() {
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator'  AND isActive=true Limit 1];
        UserRole role = [Select id from UserRole where DeveloperName = 'Admin' limit 1]; 
        adminUser.userRoleId = role.id;
        update adminUser;
        
        System.runAs(adminUser){
        //trigger switch custom setting
        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c();
        cs.Name = 'PSS_solution_trigger';
        cs.Core_Active__c = true;
        cs.Core_Class_Name__c='PSS_SolutionResponse_TriggerHandler';
        cs.Core_Description__c='PSS_SolutionResponse_TriggerHandler';
        cs.Core_Object__c='ArdiraSurvey__Survey_Result__c';
        cs.Core_Trigger_Events__c='After Insert, After Update, Before Delete, Before Update';
        insert cs;
        
        //Inerting Document used in mail Header
        PMP_TestDataUtility.createDocument();
        
        Account acc = PMP_TestDataUtility.createAccount('testAccount', PMP_TestDataUtility.intel_Account_Record_Type, true );
        Contact con = PMP_TestDataUtility.createContact(acc.Id, true);
        
        
        User poeUser;
        Profile prf2=[SELECT Id  FROM Profile WHERE name='Partner' limit 1];
            //UserRole ur = [Select Id,PortalType, PortalAccountId From UserRole where PortalAccountId=:intelAccount.Id limit 1];
            poeUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                               EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = prf2.Id,
                               TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',
                               FirstName='Test'                       
                              );
            poeUser.ContactId=con.Id;
            insert poeUser;
        
        //create impact path scoring criteria record
        PSS_Impact_Path_Scoring_Criteria__c impPathScore= new PSS_Impact_Path_Scoring_Criteria__c();
        impPathScore.Name='Intel Tech/ASP Profile';
        impPathScore.PSS_Weightage__c=20;
        impPathScore.PSS_Survey_Result_Field_Name__c='PSS_Solution_ASP_Profile_Value__c';
        insert impPathScore;
        
        //Inserting Survey
        ArdiraSurvey__Survey__c survey = New ArdiraSurvey__Survey__c();
        survey.Name = 'Test Survey';
        survey.ArdiraSurvey__CNav_Pagination__c = 'Section';
        survey.ArdiraSurvey__Status__c = 'Open';
        insert survey ;
        
        List<ArdiraSurvey__Survey_Result__c> surveyResultList = New List<ArdiraSurvey__Survey_Result__c>();
        //Create Solution with Draft Status
        ArdiraSurvey__Survey_Result__c surResult = PSS_TestDataUtility.createSolution();
        surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Draft';
        surResult.PSS_Proposal_Name_Txt__c='Test Proposal Draft';
        surResult.ArdiraSurvey__Survey__c = survey.id;
        surResult.ArdiraSurvey__Assigned_To_Contact__c = con.Id;
        surveyResultList.add(surResult);
        
        //Create Solution with On Admin Review status
        ArdiraSurvey__Survey_Result__c surResult1 = PSS_TestDataUtility.createSolution();
        surResult1.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Admin Review';
        surResult1.PSS_Proposal_Name_Txt__c='Test Proposal Admin Review';
        surResult1.ArdiraSurvey__Survey__c = survey.id;
        surveyResultList.add(surResult1);
        
        //Create Solution with On Hold Status
        ArdiraSurvey__Survey_Result__c surResult2 = PSS_TestDataUtility.createSolution();
        surResult2.PSS_Proposal_Name_Txt__c='Test-Proposal-On-Hold';
        surResult2.PSS_Partner_Solution_Lifecycle_Status_Nm__c='On Hold';
        surResult2.PSS_Follow_up_Date_Dt__c= System.today()+1;
        surResult2.ArdiraSurvey__Survey__c = survey.id;
        surResult2.PSS_Total_Minutes_On_Hold__c=12;
        surveyResultList.add(surResult2);
        
        //Create Solution with Update Required Status
        ArdiraSurvey__Survey_Result__c surResult3 = PSS_TestDataUtility.createSolution();
        surResult3.PSS_Proposal_Name_Txt__c='Test-Proposal-Update-Required';
        surResult3.PSS_Partner_Solution_Lifecycle_Status_Nm__c='Update Required';
        surResult3.ArdiraSurvey__Survey__c = survey.id;
        surResult3.PSS_Follow_up_Date_Dt__c= System.today()+1;
        surResult3.PSS_Total_Minutes_Update_Required__c=12;
        surveyResultList.add(surResult3);
        
        insert surveyResultList;
        }
    }
    
    @isTest
    public static void testHandlerForAdminReview(){

        test.startTest();
        ArdiraSurvey__Survey_Result__c surResult=[select id, name,PSS_Partner_Solution_Lifecycle_Status_Nm__c 
                                                  from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c='Test Proposal Draft'];
        surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c='Admin Review';
        update surResult;
          
        System.assertEquals('Admin Review', surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c, 'Status changed to Admin Review');
        test.stopTest();
    }
    
    @isTest
    public static void testHandlerForOnHold(){

        test.startTest();
        ArdiraSurvey__Survey_Result__c surResult=[select id, name,PSS_Partner_Solution_Lifecycle_Status_Nm__c 
                                                 from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c='Test Proposal Admin Review'];
        surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c='On Hold';
        surResult.PSS_Follow_up_Date_Dt__c= System.today()+1;
        surResult.PSS_Total_Minutes_On_Hold__c=12;
        update surResult;
          
        System.assertEquals('On Hold', surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c, 'Status changed to On Hold');
        test.stopTest();
    }
    @isTest
    public static void testHandlerForUpdateRequired(){

        test.startTest();
        ArdiraSurvey__Survey_Result__c surResult=[select id, name,PSS_Partner_Solution_Lifecycle_Status_Nm__c 
                                                  from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c='Test Proposal Admin Review'];
        surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Update Required';
        surResult.PSS_Total_Minutes_Update_Required__c=12;
        update surResult;
        
        System.assertEquals('Update Required', surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c, 'Status changed to Update Required');
        test.stopTest();  

    }
    @isTest
    public static void testHandlerForApproved(){
 
        test.startTest();
        ArdiraSurvey__Survey_Result__c surResult=[select id, name,PSS_Partner_Solution_Lifecycle_Status_Nm__c 
                                                  from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c='Test Proposal Admin Review'];
        surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Approved';
        update surResult;
       
        System.assertEquals('Approved', surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c, 'Status changed to Approved');
        test.stopTest();  
    }
    
    @isTest
    public static void testHandlerForOnHoldtoApproved(){
 
        test.startTest();
        ArdiraSurvey__Survey_Result__c surResult=[select id, name,PSS_Partner_Solution_Lifecycle_Status_Nm__c 
                                                  from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c='Test-Proposal-On-Hold'];
        surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Approved';
        update surResult;
       
        System.assertEquals('Approved', surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c, 'Status changed to Approved');
        test.stopTest();  
    }
    
    @isTest
    public static void testHandlerForUpdateRequiredtoAdminReview(){
 
        test.startTest();
        ArdiraSurvey__Survey_Result__c surResult=[select id, name,PSS_Partner_Solution_Lifecycle_Status_Nm__c 
                                                  from ArdiraSurvey__Survey_Result__c where PSS_Proposal_Name_Txt__c='Test-Proposal-Update-Required'];
        surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Admin Review';
        update surResult;
       
        System.assertEquals('Admin Review', surResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c, 'Test-Proposal-Update-Required');
        test.stopTest();  
    }*/
    
}