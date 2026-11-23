public without sharing class SalesApplyRenewLicGenPECtrl {
    
    public static void executeLicGeneration(List<Sales_Apply_Renew_Lic_Genration__e> eventList){
        set<id> hostIds=new set<id>();
        for(Sales_Apply_Renew_Lic_Genration__e evtList:eventList){
            if(evtList.Host_Ids__c!=null){
                system.debug('inside controller if');
            }
        }
    }
}