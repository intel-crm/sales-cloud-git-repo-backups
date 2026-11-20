/*********************************************************************************************************************
Class Name    : PRM_ScheduleBenefitBatch_Test
Version       : 1.0
Created Date  : Feb 2019
Function      : Test Class for 'PRM_ScheduleBenefitBatch'

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------
* Utkarsh                  Feb,2019              Test Class for 'PRM_ScheduleBenefitBatch'
*********************************************************************************************************************/
@isTest
public class PRM_ScheduleBenefitBatch_Test {
    static testMethod void scheduleBenefitBatchMethod(){
        Test.startTest();
            PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();//Custom Setting Benefit Mapping
            bm.Name='BatchFieldValues';
            bm.PRM_PartnerType__c='Cloud Service Provider (CSP)';
            bm.PRM_ChannelProgramLevel__c='Gold;Titanium';
            bm.PRM_SchedulingHour__c=6;
            bm.PRM_NoOfRecords__c=300;
            bm.PRM_NoOfBatchEntRecords__c=10;
            bm.PRM_PartnerRole__c ='Service Provider'; 
            insert bm;
            PRM_ScheduleBenefitBatch batchschedule = new PRM_ScheduleBenefitBatch();
            PRM_ScheduleEntitlementBatch entbatchschedule = new PRM_ScheduleEntitlementBatch();
            String cronExpression = '0 0 0/1 1/1 * ? *';
            system.schedule('Batch Test' , cronExpression , batchschedule);
            system.schedule('Batch Test 2' , cronExpression , entbatchschedule);
        Test.stopTest();
        System.assertEquals(bm.PRM_NoOfBatchEntRecords__c,10,'Value does not match'); 
    }
}