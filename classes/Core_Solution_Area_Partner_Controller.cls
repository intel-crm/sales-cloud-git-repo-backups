/******************************************************************************************************************************************
Class Name:  Core_Solution_Area_Partner_Controller
Version     : 1.0 
Created Date: 20 JUN 2023
Function    : Apex Class to update concatenated partner data for Solution area 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Shijas KM            20/06/2023             Original Version
*****************************************************************************************************************************************/

public without sharing class Core_Solution_Area_Partner_Controller {
    
    
    
     public static void UpsertPartnerValuesToSolution(List<Core_Solution_Area_Partner__c> solutionPartners){
        
         system.debug('Inside addPartnerValuesToSolution');         
         try
         {
            Set<ID> solnIds= new Set<ID>();
             if (solutionPartners!= null && solutionPartners.size()>0)
             {
            for(Core_Solution_Area_Partner__c solutionPartner: solutionPartners){
                solnIds.add(solutionPartner.Core_Solution_Area__c);                
            }
            if (solnIds!= null && solnIds.size()>0)
            {
              UpsertPartnerData(solnIds);
             }
             }
             else
             {
                 System.debug('addPartnerValuesToSolution::: is empty');
             }
             
         }Catch(Exception ex){
         	System.debug('addPartnerValuesToSolution:::'+ex);
        }
     }
    
     public static void updatePartnerValuesToSolution(List<Core_Solution_Area_Partner__c> newsolutionAreaPartners, Map<Id, Core_Solution_Area_Partner__c> oldsolutionAreaPartner){
         system.debug('Inside updatePartnerValuesToSolution');
         
         try
         {           
            Set<ID> solnIds= new Set<ID>();
            for(Core_Solution_Area_Partner__c solutionPartner: newsolutionAreaPartners){
                if(solutionPartner.Core_Solution_Partner__c != oldsolutionAreaPartner.get(solutionPartner.Id).Core_Solution_Partner__c)
                {
                     solnIds.add(solutionPartner.Core_Solution_Area__c);   
                }                            
            }
            if (solnIds!= null && solnIds.size()>0)
            {
                UpsertPartnerData(solnIds);
            }
         }Catch(Exception ex){
         	System.debug('updatePartnerValuesToSolution:::'+ex);
        } 
     }
   
    @future
     private static void UpsertPartnerData(Set<ID> solnIds) {
        
		try{
			System.debug('solnIds.size---'+solnIds.size());
			String PartnerName;
			Id Solution_ID;
         	List<Core_Solution_Areas__c> SolnArea = new List<Core_Solution_Areas__c>();
           
            Map<Id,set<String>> SA_PartnersIds= new Map<Id,set<String>>();

         if(solnIds != null && solnIds.size()>0){
            for(Core_Solution_Area_Partner__c solnId: [Select  Core_Solution_Area__c,Core_Solution_Partner__r.name from Core_Solution_Area_Partner__c  where Core_Solution_Area__c= :solnIds]){
                set<String> csPartnername = new set<String>();
                if(SA_PartnersIds.containsKey(solnId.Core_Solution_Area__c) ){
                    csPartnername =SA_PartnersIds.get(solnId.Core_Solution_Area__c);
					csPartnername.add(solnId.Core_Solution_Partner__r.name);
				    SA_PartnersIds.put(solnId.Core_Solution_Area__c,csPartnername); 
                   // SA_PartnersIds.put(solnId.Core_Solution_Area__c, SA_PartnersIds.get(solnId.Core_Solution_Area__c).add(solnId.Core_Solution_Partner__c));
				}
				else{
                    csPartnername.add(solnId.Core_Solution_Partner__r.name);
				    SA_PartnersIds.put(solnId.Core_Solution_Area__c, csPartnername); 
                    

				}
            }

                    for(ID solnId: solnIds){
                      	PartnerName= '';
                        Solution_ID= solnId;
                        PartnerName= string.join( SA_PartnersIds.get(solnId),';');

                          
                    }
			  
			  if (String.IsNotBlank (PartnerName))
                       {
                           Core_Solution_Areas__c soln= new Core_Solution_Areas__c();
                           soln.Id= Solution_ID;
                           soln.Core_Concatenated_Solution_Partners__c = PartnerName;                       
                           SolnArea.add(soln);
                           
                       }
        }
             update SolnArea;
			  //System.debug('update SolnArea---' + SolnArea.size());
		}
        Catch(Exception ex){
         	System.debug('deletePartnerValuesFromSolution:::'+ex);
        }  

    }

}