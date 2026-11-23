/******************************************************************************************************************************************
Class Name:  core_BuMappingTable
Version     : 1.0 
Created Date: 20 August 2022
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mula Yeshwanth             20/08/2022              Original Version
*****************************************************************************************************************************************/

trigger core_BuMappingTable on Core_BU_Mapping_Table__c (after  insert) {
     
	/* map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
	
 if(!mapFunctionalityNameTriggerExecution.isEmpty()) {	
			if(trigger.isAfter)
			{
				 
                if(mapFunctionalityNameTriggerExecution.containsKey('BuMappingTable') && 
                   mapFunctionalityNameTriggerExecution.get('BuMappingTable').Core_Active__c) 
				   {
					
                if(Trigger.isInsert){
                if(mapFunctionalityNameTriggerExecution.containsKey('BuMappingTable') && mapFunctionalityNameTriggerExecution.get('BuMappingTable').Core_Active__c) {
            		Core_BUMapping_Handler.createBUOwnerRecord(trigger.New);
						}
					}
			}
	}
}*/
}


/*trigger core_BuMappingTable on Core_BU_Mapping_Table__c (after  insert) {
    
    if(trigger.isAfter)
    {
        if (trigger.isInsert) {
            Core_BUMapping_Handler.createBUOwnerRecord(trigger.New);
        }
    }

}
*/