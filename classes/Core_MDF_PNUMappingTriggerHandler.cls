/****************************************************************************************************************************************
* Class Name  : Core_MDF_PNUMappingTriggerHandler 
* Version     : 1.0 
* Created Date: 7-23-2018
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - SB       7/23/2018          Created for extending Trigger framework to process 
										  Partner Node User Mapping business logic methods.
* Accenture - KK       12/13/2019		  Modified based on Batch Design
*****************************************************************************************************************************************/
public class Core_MDF_PNUMappingTriggerHandler extends TriggerHandler{
    
	public override void beforeUpdate() {
        //To stop Recursion, if coming from batch
        Boolean flagRecursion = Core_MDF_PNUMappingServiceHandler.isAccountUserUpdated((Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.oldMap, (Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.newMap);
        if(flagRecursion){
            //To check if duplicate entries available
            Core_MDF_PNUMappingServiceHandler.checkPNUMDuplicateRecords((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.new,(Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.oldMap);
            
            //To check if Flex Queue has available limit
            Core_MDF_PNUMappingServiceHandler.isApexJobLimitAvailable((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.new);
			
            //To clear Error Message Field from Account User
            Core_MDF_PNUMappingServiceHandler.clearErrorField((Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.newMap);
        }        	
    }
    
    public override void beforeInsert() {
        //To check if duplicate entries available
        Core_MDF_PNUMappingServiceHandler.checkPNUMDuplicateRecords((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.new,(Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.oldMap);
        
        //To check if Flex Queue has available limit
        Core_MDF_PNUMappingServiceHandler.isApexJobLimitAvailable((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.new);
    }

    public override void afterInsert(){
        //To create share records
        Core_MDF_PNUMappingServiceHandler.createObjectShareRecords((Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.newMap);
    	
        //Sharing of Account User
        Core_MDF_ManualSharing.sharingAccountUser((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.new);// Accenture - Krishna Kulkarni Date - 04-30-2019
    }
    
    public override void afterUpdate(){
        	//To check Recursion, if coming from batch block it.
            Boolean flagRecursion = Core_MDF_PNUMappingServiceHandler.isAccountUserUpdated((Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.oldMap, (Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.newMap);
        	if(flagRecursion){
                //Deleting share records & then Creating for new mapping
                Core_MDF_PNUMappingServiceHandler.deleteObjectShareRecords((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.old, (Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.newMap, true);
				
                //Creating account share records, as it is synchronous
            	Core_MDF_PNUMappingServiceHandler.createAccountShareRecords((Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.newMap);
            
            	//Resharing of Account User after Owner Change
            	Core_MDF_ManualSharing.recalculateSharePnumWhenOwnerChange((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.NEW,(Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.oldMap); // Accenture - Krishna Kulkarni Date - 04-30-2019    
            } 
    }
    
    public override void afterDelete(){
        //To delete Share Records
        Core_MDF_PNUMappingServiceHandler.deleteObjectShareRecords((List<Core_MDF_Partner_Node_User_Mapping__c>) Trigger.old, (Map<Id,Core_MDF_Partner_Node_User_Mapping__c>) Trigger.newMap, false);
    }
}