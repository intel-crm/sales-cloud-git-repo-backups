public without sharing class PMP_SearchCompanyLeadGenAction {
	
     /** 
* @description : To push storefront changes(Lead Gen) from working Partner to Published Partners 
* @developer : Prabuddh
* @return : void
* Method Parameters - trigger.new,trigger.old,trigger.newMap,trigger.oldMap
* Date : 08/Aug/2019
*/ 

    public static void updatePublishedCopy(Boolean triggerContext ,List<PMP_Company__c> newCompanyList, List<PMP_Company__c> oldCompanyList, Map<Id,PMP_Company__c> newCompMap, Map<Id,PMP_Company__c> oldCompMap){
    	
           
            Map<Id,PMP_Company__c> workPubMap = new Map<Id,PMP_Company__c>();
            
            
            List<PMP_company__c> pubCompList = new List<PMP_company__c>();
           
                pubCompList = [SELECT Id,PMP_Is_Working_Copy_Ind__c
                                                                ,PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Company_Lead_Gen_Language_Nm__c,
                                                                PMP_Is_Lead_Gen_Limited_Nm__c,
                                                               PMP_Working_Copy_Id__c FROM PMP_Company__c WHERE PMP_Working_Copy_Id__c in :newCompMap.keySet()];                
           
            
            
            for (PMP_company__c pubComp: pubCompList)
            {
                workPubMap.put(pubComp.PMP_Working_Copy_Id__c , pubComp);
                
            }
            for (PMP_Company__c workComp: newCompanyList)
            {
                
                if(workComp!=null && workComp.PMP_Is_Working_Copy_Ind__c == true){
                    if (workComp.PMP_Is_Enabled_Lead_Gen_Nm__c != null)
                        workPubMap.get(workComp.Id).PMP_Is_Enabled_Lead_Gen_Nm__c = workComp.PMP_Is_Enabled_Lead_Gen_Nm__c;
                    if (workComp.PMP_Is_Lead_Gen_Limited_Nm__c != null)
                        workPubMap.get(workComp.Id).PMP_Is_Lead_Gen_Limited_Nm__c = workComp.PMP_Is_Lead_Gen_Limited_Nm__c;
                    if (workComp.PMP_Company_Lead_Gen_Language_Nm__c != null)
                        workPubMap.get(workComp.Id).PMP_Company_Lead_Gen_Language_Nm__c = workComp.PMP_Company_Lead_Gen_Language_Nm__c;
                    else
                        workPubMap.get(workComp.Id).PMP_Company_Lead_Gen_Language_Nm__c = '';
                }	
            }
        
        
        	update workPubMap.values();
            system.debug('Lead Gen Updated in PC');
    
    }
}