/*****************************************************************************************************
Class        :   Core_MDF_IUPGM_Dummyclass
*****************************************************************************************************/
public without sharing class Core_MDF_IUPGM_Dummyclass {
     @AuraEnabled
    Public static void getRecordsToApprove() {
        system.debug('inside-->');//Hi
    }
}