public without sharing class ACM_BU_DeleteDuplicateChnlMembership {
    Public static Map<Id, PRM_AccountChannelMembership__c> acctChnlMemList;
    public static void getChildChnlMembership(List<Account> oldAccList) {
        /*system.debug('oldAccountChannelMem'+oldAccountChannelMem);
        system.debug('newAccountChannelMem'+newAccountChannelMem);
        Set<Id> newAccounId = new Set<Id>();
        Set<Id> newPartnerProgram = new Set<Id>();
        List<PRM_AccountChannelMembership__c> newChnlMemList =  new List<PRM_AccountChannelMembership__c>();
        List<PRM_AccountChannelMembership__c> oldChnlMemList =  new List<PRM_AccountChannelMembership__c>();
        for (PRM_AccountChannelMembership__c newChnMem : newAccountChannelMem.values()) {
            system.debug(oldAccountChannelMem.get(newChnMem.Id).PRM_Account_Id__c);
            system.debug(newChnMem.PRM_Account_Id__c);

            if (oldAccountChannelMem.get(newChnMem.Id).PRM_Account_Id__c != newChnMem.PRM_Account_Id__c) {
                system.debug(newAccountChannelMem.get(newChnMem.Id).PRM_Account_Id__c);
                newAccounId.add(newChnMem.PRM_Account_Id__c);
                newPartnerProgram.add(newChnMem.PRM_Channel_Program_Id__c);
                newChnlMemList.add(newChnMem);
            }
        }
        oldChnlMemList = [select id from PRM_AccountChannelMembership__c where PRM_Account_Id__c =:newAccounId and  PRM_Channel_Program_Id__c =:newPartnerProgram];
        if(!oldChnlMemList.isEmpty()){
            delete newChnlMemList;
        }*/
        acctChnlMemList =  new  Map<Id, PRM_AccountChannelMembership__c>();
        Set<Id> oldAccountIds = new Set<Id>();
        for(Account a : oldAccList){
            oldAccountIds.add(a.id);
         
        }
        for (PRM_AccountChannelMembership__c actChnlMem : [Select id,PRM_Channel_Program_Id__c,PRM_Account_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c =: oldAccountIds]){
            acctChnlMemList.put(actChnlMem.id,actChnlMem);
        }

    }
    public static void delteDupChnlMembership(List<Account> newAccList) {
    Set<Id> MergedAccountId = new Set<Id>();
    List<PRM_AccountChannelMembership__c> deleteChnlMemList = new List<PRM_AccountChannelMembership__c>();
        for(Account a : newAccList){
            if(a.MasterRecordId != null){
                MergedAccountId.add(a.MasterRecordId);
            }
        }
        for (PRM_AccountChannelMembership__c actChnlMem : [Select id,PRM_Channel_Program_Id__c,PRM_Account_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c =: MergedAccountId]){
            if(acctChnlMemList.containsKey(actChnlMem.id) && acctChnlMemList.get(actChnlMem.id).PRM_Channel_Program_Id__c == actChnlMem.PRM_Channel_Program_Id__c && 
            acctChnlMemList.get(actChnlMem.id).PRM_Account_Id__c != actChnlMem.PRM_Account_Id__c){
                deleteChnlMemList.add(actChnlMem);
            }
            
        }
       
        if(!deleteChnlMemList.isEmpty()){
            delete deleteChnlMemList;
        }
    }

}