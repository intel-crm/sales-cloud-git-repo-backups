/****************************************************************************************************
*Class Name:  Core_IPS_Outbound_Message_Dispatcher
*Modification Log :
* Developer                   Date                        Description
* ----------------------------------------------------------------------------          
* Farooq                    25/02/2020                  Created(UserStory US925875)
****************************************************************************************************/
public class Core_IPS_Outbound_Message_Dispatcher {
	public static void beforeMethod(List<Core_IPS_BES_Outbound_Message__c> oldList, List<Core_IPS_BES_Outbound_Message__c> newList, 
                            Map<Id,Core_IPS_BES_Outbound_Message__c> oldMap,Map<Id,Core_IPS_BES_Outbound_Message__c> newMap){
                                
    }
    public static void afterMethod(List<Core_IPS_BES_Outbound_Message__c> oldList, List<Core_IPS_BES_Outbound_Message__c> newList, 
                            Map<Id,Core_IPS_BES_Outbound_Message__c> oldMap,Map<Id,Core_IPS_BES_Outbound_Message__c> newMap){
                                
    	if(trigger.isInsert){
            
         }
         if(trigger.isUpdate){
                 Core_IPS_Outbound_Message_Handler.updateCaseStatus(oldList, newList, oldMap, newMap);                
    	}
    }
}