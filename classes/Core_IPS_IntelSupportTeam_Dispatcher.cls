/**************************************************************************************************
Apex Class Name :  Core_IPS_IntelSupportTeam_Dispatcher
Description     :  Dispatcher Class used in Intel Support Team Trigger.
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------    
* Aayushi                              20/04/2018             Created for US102838
* Amritesh							   09/05/2018			  Added RemoveISO - US137508
*****************************************************************************************************/

public class Core_IPS_IntelSupportTeam_Dispatcher {
    //added Boolean for DE32193
    public static Boolean ISTUpdatedfromProject=false;
    public static void beforeMethod(List<Core_IPS_Intel_Support_Team__c> oldList, List<Core_IPS_Intel_Support_Team__c> newList, 
                                    Map<Id,Core_IPS_Intel_Support_Team__c> oldMap,Map<Id,Core_IPS_Intel_Support_Team__c> newMap)
    {
        if(trigger.isInsert){
          Core_IPS_IntelSupportTeam_Handler.setAddToCaseIP(newList); 
        }
        if(trigger.isUpdate){
            //added by Rakesh for US107411
            Core_IPS_IntelSupportTeam_Handler.removeRelatedIpsOnStatusChangeForIST(newList,oldMap);
        }
        if(trigger.isDelete){
            
        }
    }  
    
    public static void afterMethod(List<Core_IPS_Intel_Support_Team__c> oldList, List<Core_IPS_Intel_Support_Team__c> newList, 
                                   Map<Id,Core_IPS_Intel_Support_Team__c> oldMap,Map<Id,Core_IPS_Intel_Support_Team__c> newMap)
    {
        if(trigger.isInsert){
            Core_IPS_IntelSupportTeam_Handler.insertInternalGroupMember(newList);
            //Rakesh -US107411 -calling a new method(interestedParties_IntelSupportTeam) from here
            Core_IPS_IntelSupportTeam_Handler.interestedParties_IntelSupportTeam(newList);
            
        }
        if(trigger.isUpdate){
            Core_IPS_IntelSupportTeam_Handler.manageGroupMembers(newList,oldMap);   
            //Rakesh -US107411 -calling a new method(create_InterestedParty_using_checkBox) from here
			//added If for DE32193
            if(!ISTUpdatedfromProject){
            Core_IPS_IntelSupportTeam_Handler.create_InterestedParty_using_checkBox(newList,oldMap);}
            Core_IPS_IntelSupportTeam_Handler.RemoveISO(newList, OldMap); //added by amritesh for US137508
        }
        if(trigger.isDelete){
            Core_IPS_IntelSupportTeam_Handler.removeGroupMembers(oldList);   
            Core_IPS_IntelSupportTeam_Handler.RemoveISO(oldList, OldMap); //added by amritesh for US137508
        }
    }
}