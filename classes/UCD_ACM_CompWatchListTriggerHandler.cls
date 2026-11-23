public without sharing class UCD_ACM_CompWatchListTriggerHandler {
    private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();
    public static void triggerPlatformEventOnInsert(System.TriggerOperation operation,List<Core_Account_Compliance_Watch_List__c> complianceWatchLists,Map<Id,Core_Account_Compliance_Watch_List__c> complianceWatchListById){
        Set<Id> accountIds = new Set<Id>();
        try{
            For(Core_Account_Compliance_Watch_List__c complianceWatchList :complianceWatchLists){
                if(operation == System.TriggerOperation.AFTER_INSERT){
                    accountIds.add(complianceWatchList.Core_Account_Id__c);
                }else if(operation == System.TriggerOperation.AFTER_UPDATE && ((complianceWatchList.Core_Account_Id__c != complianceWatchListById.get(complianceWatchList.Id).Core_Account_Id__c) ||
                                                                               (complianceWatchList.Core_Trusted_Source__c != complianceWatchListById.get(complianceWatchList.Id).Core_Trusted_Source__c) || 
                                                                               (complianceWatchList.Core_Effective_End_Date__c != complianceWatchListById.get(complianceWatchList.Id).Core_Effective_End_Date__c) ||
                                                                               (complianceWatchList.Core_Effective_Start_Date__c != complianceWatchListById.get(complianceWatchList.Id).Core_Effective_Start_Date__c) ||
                                                                               (complianceWatchList.Core_Type__c != complianceWatchListById.get(complianceWatchList.Id).Core_Type__c))){
                                                                                   accountIds.add(complianceWatchList.Core_Account_Id__c);
                                                                               }
            }
            if(accountIds.size() > 0){
                //UCD_ACM_AccountService.publishAccountChangeEvent(accountIds);
                accountServiceInstance.updateACMIntegrationMessage(accountIds);
            }
        }catch(Exception ex){
            UCD_ACM_Logger.error('UCD_ACM_CompWatchListTriggerHandler','triggerPlatformEventOnInsert','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString()+' UserName: '+UserInfo.getUserName(),'AccountIds: '+accountIds.toString());
            UCD_ACM_Logger.setLogDetails();
        }
    }
    
        public static void updateCompWatchListOnAcc(List<Core_Account_Compliance_Watch_List__c> compWatchList){

        Map<Id,List<Core_Account_Compliance_Watch_List__c>> compWatchWithAccId = new Map<Id,List<Core_Account_Compliance_Watch_List__c>>();

        Set<Id> accountIds = new Set<Id>();

        List<Account> accountsList = new List<Account>();

        String concatenateString;

        for(Core_Account_Compliance_Watch_List__c comp : compWatchList){

            if(comp.Core_Account_Id__c!= null)

            {

                accountIds.add(comp.Core_Account_Id__c); // get account id from Core_Account_Compliance_Watch_List__cs

            }

        }

        // get all Core_Account_Compliance_Watch_List__cs related to account ids

        if(accountIds.size() > 0){
			List<Core_Account_Compliance_Watch_List__c> acctIdComp = [SELECT Id,Core_Account_Id__c,Core_Type__c 

                                FROM Core_Account_Compliance_Watch_List__c 

                                WHERE Core_Account_Id__c IN: accountIds];

            for(Core_Account_Compliance_Watch_List__c comp : acctIdComp)

            {

                if(!compWatchWithAccId.containsKey(comp.Core_Account_Id__c))

                {

                    compWatchWithAccId.put(comp.Core_Account_Id__c,new List<Core_Account_Compliance_Watch_List__c>());

                }

                compWatchWithAccId.get(comp.Core_Account_Id__c).add(comp);

            }

        }

        // get account records

        if(accountIds.size() > 0){
            
			List<Account> acctIdsLatest = [SELECT Id,complaince_watchlist_test__c 

                                FROM Account WHERE Id IN: accountIds];
            for(Account acct : acctIdsLatest)

            {

                concatenateString = '';

                // populate all Core_Account_Compliance_Watch_List__c name on parent record field

                if(compWatchWithAccId.containsKey(acct.Id) && compWatchWithAccId.get(acct.Id).size() > 0)

                {
                        List<Schema.PicklistEntry> values = Core_Account_Compliance_Watch_List__c.Core_Type__c.getDescribe().getPicklistValues();
                        Map<String,String> TypesApiToLabelMap = new Map<String,String>();
                        For(Schema.PicklistEntry sp : values){
                            //Map to hold Picklist API as Key and Picklist Label as Value
                           TypesApiToLabelMap.put(sp.getValue(),sp.getLabel());
                         }

                    for(Core_Account_Compliance_Watch_List__c comp : compWatchWithAccId.get(acct.Id))

                    {
                       if(!concatenateString.contains(comp.Core_Type__c))

                        {
                            concatenateString = concatenateString + TypesApiToLabelMap.get(comp.Core_Type__c) + ', ';
                            System.debug('concatenateString'+concatenateString);

                        }

                    }

                    concatenateString = concatenateString.removeEnd(',');

                    acct.complaince_watchlist_test__c = concatenateString;

                }else{

                    acct.complaince_watchlist_test__c = null;

                }   

                accountsList.add(acct);

            }

        }

        try{

            if(accountsList.size() > 0){

                UPDATE accountsList;

            }

        }catch(Exception ex){

            System.debug('exception^^' + ex.getMessage());

        }

    }


}