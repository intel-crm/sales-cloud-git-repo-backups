public with sharing class UCD_ACM_UnifiedDataController {
    private static UCD_ACM_ServiceContracts.IAccountService accountServiceInstance = UCD_ACM_AccountService.getInstance();

    @AuraEnabled(cacheable=true)
    public static accountWrap getUnifiedData(String accountId){
        system.debug('accountId--> '+accountId);
        Map<Id,String> complianceWatchListByAccountId = accountServiceInstance.getComplianceWatchListByAccountId(new Set<Id>{accountId});
        Map<Id,List<Business_Types__c>> mapOfBusinessTypesByAccountId = accountServiceInstance.getActiveBusinessTypeForAccount(new Set<Id>{accountId});
        System.debug('busines types map'+mapOfBusinessTypesByAccountId);
        accountWrap accWrap = new accountWrap();
        if(complianceWatchListByAccountId != null && complianceWatchListByAccountId.size() > 0 && complianceWatchListByAccountId.containsKey(accountId)){
            accWrap.complianceWatchList = complianceWatchListByAccountId.get(accountId);
        }
        if(mapOfBusinessTypesByAccountId != null && mapOfBusinessTypesByAccountId.size() > 0 && mapOfBusinessTypesByAccountId.containsKey(accountId)){
            //  accWrap.customerProcessEngg = customerAggTypeByAccountId.get(accountId);
            String businessType = '';
            
            for(Business_Types__c businessTypeObj : mapOfBusinessTypesByAccountId.get(accountId)){
               
                 //   if(businessTypeById != null && businessTypeById.containsKey(businessTypeObj.Id)){
                System.debug('businessTypeObj'+businessTypeObj); 
                if(businessType != null && businessType != ''){
                    businessType = businessType+', '+businessTypeObj.Name;
                }else{
                     businessType = businessTypeObj.Name;
                    }
                  //  }
                       
                       
                   
            }
            accWrap.customerProcessEngg = businessType;

        }
        system.debug('accWrap--> '+accWrap);
        return accWrap;
    }

    public class accountWrap{
        @AuraEnabled
        public string customerProcessEngg {get;set;}
        @AuraEnabled
        public string complianceWatchList {get;set;}
    }
}