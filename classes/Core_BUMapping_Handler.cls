/******************************************************************************************************************************************
Class Name:  Core_BUMapping_Handler
Version     : 1.0 
Created Date: 20 August 2022
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mula Yeshwanth             20/08/2022              Original Version
*****************************************************************************************************************************************/
public class Core_BUMapping_Handler {		
/*   Public static void createBUOwnerRecord(List<Core_BU_Mapping_Table__c> BuMappingIds)
{
	Try	{
		List<Core_BU_Owner_Table__c> buOwnerlist = new List<Core_BU_Owner_Table__c>();
		set<String> newBUlst = new set<String>();
		
		 for( Core_BU_Mapping_Table__c Bu : BuMappingIds){
                 newBUlst.add(Bu.Core_BU_Shortname__c);	
         }
		 if(newBUlst.size() >0){
				List<Core_BU_Owner_Table__c> BuOwnlist = [SELECT Id, Name, Core_BU_Shortname__c FROM Core_BU_Owner_Table__c WHERE Core_BU_Shortname__c =: newBUlst];
		 		
		for(String st :newBUlst)
		{
                  if(BuOwnlist.size()==0)
				{
					Core_BU_Owner_Table__c BUOwner = new Core_BU_Owner_Table__c();					
					BUOwner.Core_BU_Shortname__c = st; buOwnerlist.add(BUOwner);
				}
				else{
					Continue;
				}
        }}
		insert buOwnerlist;
	}
	Catch (Exception e)	{
		System.debug('Error--'+e.getMessage());
	}

}
   */ 
}