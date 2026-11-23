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
            Set<Id> offeringIdCacheClear = new Set<Id>();
            List<PMP_company__c> pubCompList = new List<PMP_company__c>();
            List<PMP_Partner_Offering__c> pubOfferings = new List<PMP_Partner_Offering__c>();
            Boolean countCheck = false;
         // Start :: part of Account registration process 101 Soql issue for optimatization added the check on 16/04/2021.
			for(PMP_Company__c comp : newCompanyList){
				
				if(comp.PMP_Is_Enabled_Lead_Gen_Nm__c != oldCompMap.get(comp.id).PMP_Is_Enabled_Lead_Gen_Nm__c || comp.PMP_Is_Lead_Gen_Limited_Nm__c != oldCompMap.get(comp.id).PMP_Is_Lead_Gen_Limited_Nm__c || comp.PMP_Company_Lead_Gen_Language_Nm__c != oldCompMap.get(comp.id).PMP_Company_Lead_Gen_Language_Nm__c){
					countCheck = true;
				}
			}
        // END :: part of Account registration process 101 Soql issue for optimatization added the below on 16/04/2021.  
        if(countCheck){
            if(Schema.sObjectType.PMP_Company__c.isAccessible())
            {
                pubCompList = [SELECT Id,PMP_Is_Working_Copy_Ind__c
                 ,PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Company_Lead_Gen_Language_Nm__c,
                 PMP_Is_Lead_Gen_Limited_Nm__c,
                 PMP_Working_Copy_Id__c FROM PMP_Company__c WHERE PMP_Working_Copy_Id__c in :newCompMap.keySet()]; 
            }
               
           
             Set<Id> pubComId = (new Map<Id,PMP_Company__c>(pubCompList)).keySet();

            //get all the offerings attached to the partner records
           if(Schema.sObjectType.PMP_Partner_Offering__c.isAccessible())
           { 
              pubOfferings = [Select Id from PMP_Partner_Offering__c 
              where PMP_Partner_Offering_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Published and 
              PMP_Company_Id__c in: pubComId];
           }


            for (PMP_company__c pubComp: pubCompList)
            {
                workPubMap.put(pubComp.PMP_Working_Copy_Id__c , pubComp);   
            }
            for (PMP_Company__c workComp: newCompanyList)
            {
                
                if(workComp!=null && workComp.PMP_Is_Working_Copy_Ind__c == true){
                    if (workComp.PMP_Is_Enabled_Lead_Gen_Nm__c != null)
                    {
                       workPubMap.get(workComp.Id).PMP_Is_Enabled_Lead_Gen_Nm__c = workComp.PMP_Is_Enabled_Lead_Gen_Nm__c;
                    }
                    if (workComp.PMP_Is_Lead_Gen_Limited_Nm__c != null)
                    {
                        workPubMap.get(workComp.Id).PMP_Is_Lead_Gen_Limited_Nm__c = workComp.PMP_Is_Lead_Gen_Limited_Nm__c;
                    }  
                    if (workComp.PMP_Company_Lead_Gen_Language_Nm__c != null)
                    {
                        workPubMap.get(workComp.Id).PMP_Company_Lead_Gen_Language_Nm__c = workComp.PMP_Company_Lead_Gen_Language_Nm__c;
                    }   
                    else
                    {
                        workPubMap.get(workComp.Id).PMP_Company_Lead_Gen_Language_Nm__c = '';
                    }   
                }	
            }
        
        
        	update workPubMap.values();
            //system.debug('Lead Gen Updated in PC');
            //system.debug('Clearing platform Cache for offerings attached to this partner: Initiated');
           /* if(!pubOfferings.isEmpty())
            {
                offeringIdCacheClear = ( new Map<Id,PMP_Partner_Offering__c>(pubOfferings)).keySet();
               if(!offeringIdCacheClear.isEmpty())
                 {
                    PMP_OfferingTriggerHelper.clearPlatformCache(offeringIdCacheClear);
                 }
            }*/
        }
    }
}