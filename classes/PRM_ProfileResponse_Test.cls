/*********************************************************************************************************************
Class Name    : PRM_profileResponse_Test
Version       : 1.0
Created Date  : June 2019
Function      : Test Class for 'PRM_ProfileResponse'

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Rahul Kainth              14 June,2019            Test Class for 'PRM_ProfileResponse'

*********************************************************************************************************************/
@isTest
public class PRM_ProfileResponse_Test {
    @testSetup
    /*Test data creation*/
    static void setupDataCreation(){  
        
        PRM_Registration_Request__c rr = PRM_TestUtility.getPRMRegistrationRequest();
        rr.PRM_Profile_Response__c='{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_DBAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_DBAAS}{QuestionCode : CSPx2_ServicePlanTodayOrNext | ResponseCode : CSPx2_ServicePlanTodayOrNext_ConAAS | ResponseValue : CSPx2_ServicePlanTodayOrNext_ConAAS}';
        insert rr;
        
        Account acc = PRM_TestUtility.getAccount();
        acc.BillingCity='Bengaluru';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        insert acc;
        
        Contact con = PRM_TestUtility.getContact();
        con.FirstName='Samuel';
        con.LastName='Johnson';
        con.Email='samuel@outlook.com';
        con.AccountId=acc.Id;
        insert con;
        
        PRM_Profile_Questions__c profileQues =  new PRM_Profile_Questions__c();
        profileQues.PRM_Question_Cd__c = 'CSPx2_ServicePlanTodayOrNext';
        insert profileQues;
        
        PRM_Profile_Answer__c profileAns = new PRM_Profile_Answer__c();
        profileAns.PRM_Answer_Cd__c = 'CSPx2_ServicePlanTodayOrNext_DBAAS';
        profileAns.PRM_Profile_Questions_Id__c = profileQues.Id;
        insert profileAns;
        
        PRM_Profile_Responses__c response = new PRM_Profile_Responses__c();
        response.PRM_Account_Id__c = acc.Id;
        response.PRM_Profile_Questions_Id__c = profileQues.Id;
        response.PRM_Profile_Answer_Id__c = profileAns.Id;
        insert response;
    }
    static testMethod void testProfileResponse(){
        List<PRM_Registration_Request__c> regList = new List<PRM_Registration_Request__c>();
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        
        PRM_Registration_Request__c regReq = [Select Id,PRM_First_Name__c,PRM_Profile_Response__c from PRM_Registration_Request__c];
        Account act = [Select Id from Account];
        Contact cont = [Select Id from Contact];
        regList.add(regReq);
        accList.add(act);
        conList.add(cont);
        
        PRM_profileResponse.createResponse(regList, accList, conList,false);
        System.assertEquals(regReq.PRM_First_Name__c, 'Test Request','Value does not match');      
        
    }
    
}