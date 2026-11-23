/****************************************************************************************************************************************
* Class Name  : PMP_ParentSpecificationUpdate 
* Version     : 1.0 
* Created Date: 13-11-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Sangeetha Ganta     13/11/2018                    Created for extending Trigger framework to process specification business 
*                                                             logic methods.
* Infosys - Sangeetha Ganta      12/27/2018                    User Story - US247116
* Infosys - Sangeetha Ganta     02/26/2019                    US247100. Update the Parent Specification based on Active Flag values.
*****************************************************************************************************************************************/

public with sharing class PMP_ParentSpecificationUpdate {
    
    public static void updateParentSpec(List<PMP_Specification__c> specs){
      
        //Variable Declaration
        Map<String,Id> OfferingSpecIdMap = new Map<String,Id>();
        List<PMP_Specification__c> uploadOffSpec = new List<PMP_Specification__c>();
        Set<Id> offspecIds = new Set<Id>();
        
        for(PMP_Specification__c offspec : specs)
        {
            offspecIds.add(offspec.id);
        }
        
        
            for(PMP_Specification__c osc: [Select Id,PMP_Partner_Product_Specification_Id__c,PMP_Partner_Product_Specification_Key__c from PMP_Specification__c where PMP_Partner_Product_Specification_Id__c != null])
            {
            
              OfferingSpecIdMap.put(osc.PMP_Partner_Product_Specification_Key__c,osc.Id); 
            }
            
             for(PMP_Specification__c ospec: [Select Id,PMP_Active_Ind__c,PMP_Parent_Specification_Id__c,PMP_Partner_Product_Specification_Id__c ,PMP_Product_Parent_Specification_Id__c,PMP_Partner_Product_Specification_Key__c from PMP_Specification__c where id in :offspecIds])
            {
              if(ospec.PMP_Product_Parent_Specification_Id__c != null)
              {
                  if(ospec.PMP_Active_Ind__c == true)
                  {
                      String Key = ((ospec.PMP_Product_Parent_Specification_Id__c).deleteWhitespace()).toLowerCase();
                      if(OfferingSpecIdMap.get(key) != null)
                      {
                             ospec.PMP_Parent_Specification_Id__c = OfferingSpecIdMap.get(key);
                        }
                  }
                  else
                  {
                      ospec.PMP_Parent_Specification_Id__c = null;
                  }
                
              }     
                uploadOffSpec.add(ospec);
            }
            
            if(uploadOffSpec.size()>0)
            {
                try
                {
                    if(Schema.sObjectType.PMP_Specification__c.isUpdateable()) {
                        //update uploadOffSpec;
                        Database.SaveResult[] uploadOSlist = Database.update(uploadOffSpec, false);
						PMP_Utility.logDmlErrors((Object[]) uploadOSlist, 'PMP_ParentSpecificationUpdate-updateParentSpec');

                    }
                }
                catch(Exception exp)
                {
                   //System.debug('Error occured from class Core_PMP_ParentSpecificationUpdate due to '+exp.getMessage());  
                }
                
            }
     	        
  }
    
}