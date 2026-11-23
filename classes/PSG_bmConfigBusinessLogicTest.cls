/****************************************************************************************************
Apex Class Name : PSG_bmConfigBusinessLogicTest
Version         : 1.0 
Created Date    : 01/05/2021
Function        : Test class for PSG_bmConfigBusinessLogic.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hema                     01/05/2021               Created
*****************************************************************************************************/
@isTest
public class PSG_bmConfigBusinessLogicTest{
    @isTest
    static void negativebmTestMethod(){
        Account acc = new Account();
        acc = PSG_Test_Utility.createDirectAccount();
        List<User> bmUserList = PSG_Test_Utility.createBMUser();
        core_cpq_bm_assignment_config__c apprvRec2 = new core_cpq_bm_assignment_config__c(core_cpq_end_customer_parent__c = null,
                                                                                          core_cpq_business_unit_nm__c = 'CEAD',
                                                                                          core_cpq_account_tier_nm__c = 'PSG-Tier 2',
                                                                                          core_cpq_asmo_txt__c = bmUserList[0].Id,
                                                                                          core_cpq_emea_txt__c = bmUserList[0].Id,
                                                                                          core_cpq_apj_prc_txt__c = bmUserList[0].Id,
                                                                                          core_cpq_japan_txt__c = bmUserList[0].Id
                                                                                         );
        insert apprvRec2;
        System.assert(apprvRec2!=null, 'Cretaed');
        core_cpq_bm_assignment_config__c bmApprvList1 = new core_cpq_bm_assignment_config__c(core_cpq_end_customer_parent__c = null,
                                                                                             core_cpq_business_unit_nm__c = 'CEAD',
                                                                                             core_cpq_account_tier_nm__c = 'PSG-Tier 2',
                                                                                             core_cpq_asmo_txt__c = bmUserList[0].Id,
                                                                                             core_cpq_emea_txt__c = bmUserList[0].Id,
                                                                                             core_cpq_apj_prc_txt__c = bmUserList[0].Id,
                                                                                             core_cpq_japan_txt__c = bmUserList[0].Id);
        Test.startTest();
        try{
            insert bmApprvList1;
        }catch(Exception e){} 
        apprvRec2.core_cpq_end_customer_parent__c=acc.Id;
        update apprvRec2;
        bmApprvList1.core_cpq_end_customer_parent__c=acc.Id;
        try{
            insert bmApprvList1;
        }catch(Exception e){} 
        bmApprvList1.core_cpq_account_tier_nm__c='PSG-Tier 4';
        bmApprvList1.core_cpq_business_unit_nm__c='All';
        try{
            insert bmApprvList1;
        }catch(Exception e){}
        Test.stopTest();
    }
}