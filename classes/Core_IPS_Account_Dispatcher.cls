public class Core_IPS_Account_Dispatcher{
    public static void beforeMethod(List<Core_IPS_Account__c> oldList, List<Core_IPS_Account__c> newList, 
                            Map<Id,Core_IPS_Account__c> oldMap,Map<Id,Core_IPS_Account__c> newMap){
        if(trigger.isInsert){
		Core_IPS_Account_Handler.checkDuplicateAccount(newList);
        }
        if(trigger.isUpdate){
         
        }
        if(trigger.isDelete){
            Core_IPS_Account_Handler.PreventDelete(oldList);    
            Core_IPS_Account_Handler.DeleteProjMembers(oldList);
        }
    }  
    
    public static void afterMethod(List<Core_IPS_Account__c> oldList, List<Core_IPS_Account__c> newList, 
                            Map<Id,Core_IPS_Account__c> oldMap,Map<Id,Core_IPS_Account__c> newMap){
        if(trigger.isInsert){
            Core_IPS_Account_Handler.preventMPNDAforNonNDAAccount(newList);
            Core_IPS_Account_Handler.preventNonNDAAccountAddonMPNDAProj(newList);     //added by Aayushi 15/06/2018 DE39928
            Core_IPS_Account_Handler.addIPSUsersToProjectMembers(newList);
            // Use to share new Account FAE added to IPSProject
            Core_IPS_Account_Handler.addAccountFAEtoProject(newList);
        }
        if(trigger.isUpdate){
            Core_IPS_Account_Handler.ActivateOrDeactivateProjectMembers(newList, oldMap);
            Core_IPS_Account_Handler.addProjectMembersOnchangeOfAccount(newList, oldMap);
        }
        if(trigger.isDelete){
        }
    }
}