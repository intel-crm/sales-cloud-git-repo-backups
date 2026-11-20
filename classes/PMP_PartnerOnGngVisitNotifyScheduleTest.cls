/****************************************************************************************************************************************
* Class Name        : PMP_PartnerOnGngVisitNotifyScheduleTest
* Created Date      : 24-07-2020
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Abhishek         24-07-2020         test class for PMP_PartnerOnGoingVisitNotifyScheduler .
*****************************************************************************************************************************************/
@isTest
public class PMP_PartnerOnGngVisitNotifyScheduleTest {
  
    static testMethod void PMP_PartnerOnGngVisitNotifyScheduleTest(){
        
        
        //insert the apex email record that will match the batch query criteria.
        Core_Apex_EmailNotification__c record1 = New Core_Apex_EmailNotification__c(Name='Partner_OnGoing_Visit', Core_Date_Reference_Txt__c = 'PMP_Company_Status_Update_Dt__c',
                                                Core_Allowed_Permission_Nm__c='PMP_External_Partner_Admin,PMP_External_Marketing_Specialist',
                                                Core_NumberOfDays_Nbr__c = 2, Core_Email_Template_Nm__c = 'PMP_Company_Under_Review_Template_for_Admin',
                                                Core_IsActive_Ind__c = true,Core_IsRecurring_Ind__c = false, Core_Query_String_Txt__c = 'PMP_Is_Published_Ind__c= false',
                                                Core_Object_Nm__c = 'PMP_Company__c');
        
        insert record1;
		// system.debug('record1'+record1.id);    
        Test.StartTest();
        String jobID = System.schedule('Schedule', '0 46 * * * ?' , new PMP_PartnerOnGoingVisitNotifyScheduler());
        Test.stopTest();
        system.assertNotEquals(record1.id, null);
    }
}