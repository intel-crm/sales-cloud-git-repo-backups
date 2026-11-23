/******************************************************************************************************************************
Apex Class Name:  PRM_Email_Log_Utility_Test
Version     : 1.0 
Created Date: 01 JUN 2021
Function    : Test Class for Email_Log_Utility 

Modification Log :
* Developer                     Date                    Description
* ----------------------------------------------------------------------------------------------------------------------------
* GopiKrishna Vankadari       01/06/2021               Test Class for Email_Log_Utility 

*******************************************************************************************************************************/
@isTest()
public class PRM_Email_Log_Utility_Test {     
    static testMethod void insertEmailLog(){   
        Test.startTest();
        Core_Platform_Event_Attempts__c attempts2 =new Core_Platform_Event_Attempts__c();
        attempts2.Core_Batch_Size__c =1;
        attempts2.Core_Number_Of_Attempts__c =2;
        attempts2.Core_IPA_Support_Email_Address__c ='abc@intel.com, cder@123.com';
        insert attempts2;
        
        PRM_EmailLog__c emaillog = new PRM_EmailLog__c();
        emaillog.PRM_Subject__c='Congratulations on Your New Intel® Cloud Insider Status';
        emaillog.PRM_ToEmailID__c='ebert123@mailinator.com';
        emaillog.PRM_EmailContent__c='htmlbody';
        emaillog.Email_Template_Name__c='SCRRENGENRLREV';
        emaillog.Language__c='ENG';
        emaillog.PRM_Read__c=false;
        insert emaillog;
        System.assertEquals(null,emaillog.PRM_EnterpriseId__c);
        
        //Update the EmailLog Record
        emaillog.PRM_Read__c =true;
        update emaillog;
        
        
        
        Test.stopTest();
    }
    
    @isTest
    private static void publishPlatformEvent(){
        Test.startTest();
        Core_Platform_Event_Attempts__c attempts2 =new Core_Platform_Event_Attempts__c();
        attempts2.Core_Batch_Size__c =1;
        attempts2.Core_Number_Of_Attempts__c =2;
        attempts2.Core_IPA_Support_Email_Address__c ='abc@intel.com, cder@123.com';
        insert attempts2;
        List<PRM_EmailLog__c> emailLogList = new List<PRM_EmailLog__c>();
        PRM_EmailLog__c emaillog = new PRM_EmailLog__c();
        emaillog.PRM_Subject__c='Congratulations on Your New Intel® Cloud Insider Status';
        emaillog.PRM_ToEmailID__c='ebert123@mailinator.com';
        emaillog.PRM_EmailContent__c='htmlbody';
        emaillog.Email_Template_Name__c='SCRRENGENRLREV';
        emaillog.Language__c='ENG';
        emaillog.PRM_Read__c=false;
        emailLogList.add(emaillog);
        
        List<Core_Platform_Event_Log__c> platformEventLogList = new List<Core_Platform_Event_Log__c>();
        Core_Platform_Event_Log__c platformEventLog = new Core_Platform_Event_Log__c();
        platformEventLog.Core_Object_API_Name__c = 'PRM_EmailLog__c';
        platformEventLog.Core_Message__c = 'EmailLogId';
        platformEventLog.Core_IsActive__c = True;
        platformEventLog.Core_Number_Of_Attempts__c = 0;
        platformEventLogList.add(platformEventLog);
        insert platformEventLogList;
        
        List<Id> platformEventLogListId = new List<Id>();
        Id eventId;
        eventId = [SELECT Id from Core_Platform_Event_Log__c].Id;
        platformEventLogListId.add(eventId); 
        
        List<Integer> attemptList = new List<Integer>(); 
        attemptList.add(1);
        
        PRM_Email_Log_Utility.publish_Platform_EventWrapper obj = new PRM_Email_Log_Utility.publish_Platform_EventWrapper();
        obj.republishList = emailLogList;
        obj.isRepublish = True;
        obj.platFormEventLogidList = platformEventLogListId;
        obj.attemptList = attemptList;
        PRM_Email_Log_Utility.publish_Platform_Event(obj); //Athr fixes
        //PRM_Email_Log_Utility.publish_Platform_Event(emailLogList,True,platformEventLogListId,attemptList);
        
        Test.stopTest();
    }
}