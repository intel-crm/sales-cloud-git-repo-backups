/**************************************************************************************************
Apex Class Name :  Core_IPS_Project_Member_Dispatcher
Description     :  Dispatcher Class used in Project Member Trigger.
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------    
* Sugandha                              20/04/2018             Modified(User Story# US102846 Iteration# 10)
* Aayushi                               11/07/2018             Modified US109046
*****************************************************************************************************/
public class Core_IPS_Project_Member_Dispatcher{
    //added Boolean for DE32193
    public static Boolean ProjMemUpdatedfromProject=false;
    public static boolean ProvideAssetAccess = false;
    public static boolean preventDelete = true;
    public static void beforeMethod(List<Core_IPS_Project_Member__c> oldList, List<Core_IPS_Project_Member__c> newList, 
                            Map<Id,Core_IPS_Project_Member__c> oldMap,Map<Id,Core_IPS_Project_Member__c> newMap){
         if(trigger.isInsert){
            //Core_IPS_Project_Member_Handler.ManageGroupMember(newList);  //moving to after insert, amritesh
         
            //Code added as per DE18795
            Core_IPS_Project_Member_Handler.addNewProjectMember(newList);
         }
         if(trigger.isUpdate){
            // Core_IPS_Project_Member_Handler.preventInactivatingProjectMember(oldMap,newList);
            //added by sugandha for US102846
            Core_IPS_Project_Member_Handler.PreventInactivateProMem_FAE(newList);
             //Rakesh -US107411 -calling a new method(removeRelatedIpsOnStatusChangeForPM) from here
            Core_IPS_Project_Member_Handler.removeRelatedIpsOnStatusChangeForPM(newList,oldMap);
            //Code added as per DE18795 
            Core_IPS_Project_Member_Handler.addNewProjectMember(newList);
         }
         if(trigger.isDelete){
             if(preventDelete)
             Core_IPS_Project_Member_Handler.PreventDelete(oldList);
         }
    }  
    
    public static void afterMethod(List<Core_IPS_Project_Member__c> oldList, List<Core_IPS_Project_Member__c> newList, 
                            Map<Id,Core_IPS_Project_Member__c> oldMap,Map<Id,Core_IPS_Project_Member__c> newMap){
         if(trigger.isInsert){
             Core_IPS_Project_Member_Handler.ManageGroupMember(newList); //moved from before insert to here, amritesh 
             //Rakesh -US107411 -calling a new method(interestedParties_ProjectMembers) from here
             //modified DE32193
             Core_IPS_Project_Member_Handler.interestedParties_ProjectMembers(newList,null);
             
         }
         if(trigger.isUpdate){
             Core_IPS_Project_Member_Handler.preventInactivatingProjectMember(oldMap,newList);
             Core_IPS_Project_Member_Handler.RemoveorReaddProjMember(oldMap,oldList, newList);
             //Rakesh -US107411 -calling a new method(interestedParties_ProjectMembers) from here
             //modified DE32193
             if(!ProjMemUpdatedfromProject){
                 Core_IPS_Project_Member_Handler.interestedParties_ProjectMembers(newList,oldMap);}
             Core_IPS_Project_Member_Handler.RemovePSO(newList, oldMap);
         }
         if(trigger.isDelete){
             Core_IPS_Project_Member_Handler.removeProjectMemberFromGroup(oldList);
             Core_IPS_Project_Member_Handler.RemovePSO(oldList,null);
         }
    }
}