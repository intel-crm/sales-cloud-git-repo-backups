/*********************************************************************************************************************
Apex Class Name  : ER_RegistrationProfileResponse_Test
Version       : 1.0
Created Date  : 1 Feb 2022
Function      : 

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Gaurav Kurwade            1 Feb 2022              Test class for ER_RegistrationProfileResponse     
*************************************************************************************************************************/


@isTest
public class ER_RegistrationProfileResponse_Test {

    
    static testMethod void test_getProfileResponseValues(){
        PRM_Profile_Questions__c profileQues =  new PRM_Profile_Questions__c();
        profileQues.PRM_Question_Cd__c = 'CSPx2_ServicePlanTodayOrNext';
        profileQues.PRM_Question_Type_Nm__c = 'Textarea';
        insert profileQues;
        
        PRM_Profile_Answer__c profileAns = new PRM_Profile_Answer__c();
        profileAns.PRM_Answer_Cd__c = 'CSPx2_ServicePlanTodayOrNext_DBAAS';
        profileAns.PRM_Profile_Questions_Id__c = profileQues.Id;
        profileAns.PRM_Answer_Display_Txt__c = '';
        insert profileAns;
        
        
        List<PRM_Registration_Request__c> regList = new  List<PRM_Registration_Request__c>();  
        PRM_Registration_Request__c rr = PRM_TestUtility.getPRMRegistrationRequest();
        rr.PRM_Enterprise_ID__c = '300002199713';
        rr.PRM_Preferred_Language__c = 'ENG';
        rr.recordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        rr.PRM_Profile_Response__c='{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_DBAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_DBAAS}';
        insert rr;
        regList.add(rr);
            
        
        Test.startTest();
        // ER_RegistrationProfileResponse.getProfileResponseValues(regList, null);
        Test.stopTest();
        
		}
}