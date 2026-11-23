/****************************************************************************************************
*Class Name:  Core_IPS_Project_Dispatcher
*Modification Log :
* Developer                   Date                        Description
* ----------------------------------------------------------------------------          
* Sugandha                    10/05/2018                  Modified(UserStory US104746 Iteration 11)
* Gourav                     15/11/2018         			Created - US113672
****************************************************************************************************/
public class Core_IPS_Project_Dispatcher{

    public static void beforeMethod(List<Core_IPS_Project__c> oldList, List<Core_IPS_Project__c> newList, 
                            Map<Id,Core_IPS_Project__c> oldMap,Map<Id,Core_IPS_Project__c> newMap){
         if(trigger.isInsert){
             //Commented by Sugandha for US104746
             //Core_IPS_Project_Handler.DuplicateRecordprevention(newList);
         }
         if(trigger.isUpdate){
         /*added by Aayushi 11-03-2017 US80374*/ 
         Core_IPS_Project_Handler.activateProject(oldMap,newList,newMap);
         }
         if(trigger.isDelete){
             Core_IPS_Project_Handler.PreventDelete(oldList);
         }
    }  
    
    public static void afterMethod(List<Core_IPS_Project__c> oldList, List<Core_IPS_Project__c> newList, 
                            Map<Id,Core_IPS_Project__c> oldMap,Map<Id,Core_IPS_Project__c> newMap){
         if(trigger.isInsert){
             Core_IPS_Project_Handler.ManagePublicGroups(newList); //Creation of project public group
             Core_IPS_Project_Handler.internalProjectGroup(newList); //Create Internal Project group US102838
             //Gourav: Add Internal Proj Owner to IST - US113672
             Core_IPS_Project_Handler.addInternalProjOwnerToIST(newList,oldMap); 
                 
         }
         if(trigger.isUpdate){
             Core_IPS_Project_Handler.externalProjectAccessControl(oldMap,newList); //Used for sharing and Unsharing project to Public Group.
             Core_IPS_Project_Handler.recalculateSharing(oldMap,newList);
             
             Core_IPS_Project_Handler.activateProject(oldMap,newList,newMap);
             Core_IPS_Project_Handler.preventMPNDAforNonNDAAccount(newList);
             //Rakesh -US107411 -calling a new method(insertRecordInterestedParties) from here
            Core_IPS_Project_Handler.insertRecordInterestedParties(newList,oldMap);
            Core_IPS_Project_Handler.updatePrivateProjectSharing(newList,oldMap);				//added by Aayushi US113701
            //Gourav: Add Internal Proj Owner to IST - US113672 
            Core_IPS_Project_Handler.addInternalProjOwnerToIST(newList,oldMap); 
            //US250915
			Core_IPS_Project_Handler.addDefaultCaseOwnerToIST(newList,oldMap);
             
           
         }
         if(trigger.isDelete){
         }
    }
}