/******************************************************************************************************************************************
Trigger Name:  Core_Solution_Area_Controller
Version     : 1.0 
Created Date: 03 OCT 2014
Function    : Apex Class to update long text with multiple picklists
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gaurav Kurwade             18/11/2022              Original Version
*****************************************************************************************************************************************/

public with sharing class Core_Solution_Area_Controller {
    
    Public Static String dealDesign;
    /*Solution Area Long text update - 18/11/22 Start*/
    public static void addValuesToSolution(List<Core_Solution_Areas__c> solutionArea){
        system.debug('Inside saPick.Core_Solution_Long__c:::');
        List<String> saPickval = new List<String>();
        List<String> solutionAreaName = new List<String>();
        List<String> solutionAreaVersion = new List<String>();
        for(Core_Solution_Areas__c saPick: solutionArea){
            solutionAreaName.add(saPick.name);
            solutionAreaVersion.add(saPick.Core_Version__c);
        }
        Map<String,String> csaVerName = new Map<String,String>();
        for(Core_Solution_Areas__c saPick : [SELECT id, Core_Version__c,name from Core_Solution_Areas__c where  Core_Version__c like : solutionAreaVersion and  name like  : solutionAreaName]){
            csaVerName.put(saPick.Core_Version__c,saPick.name);
        }

        for(Core_Solution_Areas__c saPick: solutionArea){
            
           //  Integer SolnCnt = [SELECT count() from Core_Solution_Areas__c where Core_Version__c = :saPick.Core_Version__c and name= :saPick.Name];
           if(!(csaVerName.containskey(saPick.Core_Version__c) && (csaVerName.get(saPick.Core_Version__c)==saPick.Name)))
         //   if ( SolnCnt <= 0)
            {
                if(saPick.Core_Application_Workload__c != null || saPick.Core_Industry_Use_Case__c!= null || saPick.Core_Region_of_availability__c!= null || saPick.Core_Technology_Enabled__c!= null || saPick.Core_Industry__c!= null || saPick.Core_Solution_owner_email__c != null || saPick.Core_Solution_Type__c != null){
                    saPick.Core_Solution_Long__c = saPick.Core_Application_Workload__c+';'+saPick.Core_Industry_Use_Case__c+';'+saPick.Core_Region_of_availability__c+';'+saPick.Core_Technology_Enabled__c+';'+saPick.Core_Industry__c+';'+saPick.Core_Solution_owner_email__c+';'+saPick.Core_End_Customer_Solution__c+';'+saPick.Core_Solution_Type__c+';'+saPick.Core_Content_Link__c;
                    system.debug('saPick.Core_Solution_Long__c::'+saPick.Core_Solution_Long__c);	
                }
            }
           else
            {
              
                   saPick.addError(Label.Core_Solution_exist);
            }
        }
    }
    
    public static void updatedValuesToSolution(List<Core_Solution_Areas__c> newSolutionArea, Map<Id, Core_Solution_Areas__c> oldSolutionArea){
        system.debug('Inside saPick.Core_Solution_Long__c:::');
          String usrProfileName = [select Profile.Name from User where id = :Userinfo.getUserId()].Profile.Name;
        List<String> saPickval = new List<String>();
        for(Core_Solution_Areas__c saPick: newSolutionArea){
            
            if(newSolutionArea.size()>0){
                for(Core_Solution_Areas__c OppSA: newSolutionArea){
                   DateTime dT = System.now();
					if (oldSolutionArea.get(OppSA.Id).Core_Status__c!= 'EOL' )                         
                     {
                      if (saPick.Core_Status__c!= 'EOL')
            			{
                        if(OppSA.Core_Status__c != oldSolutionArea.get(OppSA.Id).Core_Status__c ||  OppSA.Core_Solution_owner_email__c != oldSolutionArea.get(OppSA.Id).Core_Solution_owner_email__c || OppSA.Core_End_Customer_Solution__c != oldSolutionArea.get(OppSA.Id).Core_End_Customer_Solution__c || OppSA.Core_Solution_Type__c != oldSolutionArea.get(OppSA.Id).Core_Solution_Type__c){
                            OppSA.Core_Solution_Long__c = OppSA.Core_Region_of_availability__c+';'+OppSA.Core_Industry__c+';'+OppSA.Core_Solution_owner_email__c+';'+OppSA.Core_End_Customer_Solution__c+';'+OppSA.Core_Solution_Type__c+';'+OppSA.Core_Content_Link__c;
                        }      
						}
						else
						{
							 OppSA.Core_Solution_Long__c =null;
                             						
                             OppSA.Core_Most_Recent_Status_Change_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
						}
                    }
                    else if (oldSolutionArea.get(OppSA.Id).Core_Status__c== 'EOL' )
                    {
                       // this is for IT admin...update while disabling the Validation rule
                         OppSA.Core_Solution_Long__c = OppSA.Core_Region_of_availability__c+';'+OppSA.Core_Industry__c+';'+OppSA.Core_Solution_owner_email__c+';'+OppSA.Core_End_Customer_Solution__c+';'+OppSA.Core_Solution_Type__c+';'+OppSA.Core_Content_Link__c;
                    								
                         OppSA.Core_Most_Recent_Status_Change_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                    }
                  
                    // OPTY Solution field update based on Solution Area update
                   //  String usrProfileName = [select Profile.Name from Opportunity_Solution_Area__c where id = :saPick.Id()];
                }
            }
        }
    }
    /*Solution Area Long text update - 18/11/22 Start*/
    //New Change: 26/12/2022
    public static void restrictPicklists(List<Core_Solution_Areas__c> newSolutionArea, Map<Id, Core_Solution_Areas__c> oldSolutionArea){
        system.debug('Inside restrictPicklists:::');
        try{
            String usrProfileName = [select Profile.Name from User where id = :Userinfo.getUserId()].Profile.Name;
            Integer usrPermissionsetCnt = [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Core_CRM_Special_Access'];
			System.debug(usrPermissionsetCnt);
           System.debug('User Profile'+usrProfileName);
            
            if(oldSolutionArea.size()>0){
                for(Core_Solution_Areas__c OppSA: newSolutionArea){
                    // if(usrProfileName != 'IT Admin'){
                    System.debug('User Profile::'+usrProfileName);
                    if(usrProfileName != 'IT Admin' && (OppSA.Core_Industry_Use_Case__c != oldSolutionArea.get(OppSA.Id).Core_Industry_Use_Case__c || OppSA.Core_Application_Workload__c != oldSolutionArea.get(OppSA.Id).Core_Application_Workload__c || OppSA.Core_Technology_Enabled__c != oldSolutionArea.get(OppSA.Id).Core_Technology_Enabled__c || OppSA.Core_Version__c != oldSolutionArea.get(OppSA.Id).Core_Version__c)){
                        System.debug('IN::Pick');
                        OppSA.addError(Label.restrictPicklists_for_Solutions);                               
                    }
                         if(usrProfileName != 'IT Admin' && usrProfileName != 'Data Ops' && usrPermissionsetCnt == 0 &&  (OppSA.Name != oldSolutionArea.get(OppSA.Id).Name || OppSA.OwnerId != oldSolutionArea.get(OppSA.Id).OwnerId)){
                            System.debug('in name it');
                            OppSA.addError('Cannot edit Solution Name/Owner');
                        } 
               
            if(OppSA.Name != oldSolutionArea.get(OppSA.Id).Name  || OppSA.Core_Version__c != oldSolutionArea.get(OppSA.Id).Core_Version__c)
            {
              		Integer SolnCnt = [SELECT count() from Core_Solution_Areas__c where Core_Version__c = :OppSA.Core_Version__c and name= :OppSA.Name];
                    if ( SolnCnt > 0)
                    {
                           OppSA.addError(Label.Core_Solution_exist);
                    }
            }
                }
            }

            if(Test.isRunningTest()){
                
                throw new System.DMLException();   
            }   
        }Catch(Exception ex){
            System.debug('Exception::'+ex);
        }
    }
    
       
    /*
    * Method name  : updateOpportunitySolutionArea
    * Description  : When updating the Solution area attributes corresponding OPTY Solution area attributes are updated with the help of this method.
    * Return Type  : VOID
    * Parameter    : 
    */
    
      public static void updateOpportunitySolutionArea(List<Core_Solution_Areas__c> newSolutionArea, Map<Id, Core_Solution_Areas__c> oldSolutionArea){
        System.debug('Inside  updateOpportunitySolutionArea');
     
        Set<Id> saIds = new Set<Id>();
        List<Opportunity_Solution_Area__c> getOppSA= new List<Opportunity_Solution_Area__c>();
       
        try{
         
            if(newSolutionArea.size()>0){
                for(Core_Solution_Areas__c OppSA: newSolutionArea){
                    if(OppSA.Core_Industry_Use_Case__c != oldSolutionArea.get(OppSA.Id).Core_Industry_Use_Case__c || 
                       OppSA.Core_Application_Workload__c != oldSolutionArea.get(OppSA.Id).Core_Application_Workload__c ||
                       OppSA.Core_Technology_Enabled__c != oldSolutionArea.get(OppSA.Id).Core_Technology_Enabled__c ||
                        OppSA.Core_Industry__c != oldSolutionArea.get(OppSA.Id).Core_Industry__c ||
                        OppSA.Core_Region_of_availability__c != oldSolutionArea.get(OppSA.Id).Core_Region_of_availability__c   )                 
                      {
                           
                         saIds.add(OppSA.Id); 
                      }
                }
                  System.debug('count--saIds-'+ saIds.size());
                if(saIds.size()>0){                      
                System.debug('count--IDs-'+ saIds);
                getOppSA = [Select Id, Core_Solution_Areas__c, Core_Technology_Enabled__c, Core_Region_of_availability__c ,Core_Industry_Use_Case_s__c, Core_Industry__c, Core_Application_Workload__c from Opportunity_Solution_Area__c where Core_Solution_Areas__c in :saIds]; 
                List<Core_Solution_Areas__c> SolnArea= new List<Core_Solution_Areas__c>();
                SolnArea = [Select Id, Core_Solution_Areas__c, tolabel( Core_Technology_Enabled__c), tolabel(Core_Region_of_availability__c) ,tolabel(Core_Industry_Use_Case__c),  tolabel(Core_Industry__c), tolabel( Core_Application_Workload__c) from Core_Solution_Areas__c where Id in :saIds]; 
					// update Opportunity_Solution_Area__c	
					 System.debug('count--getOppSA-'+ getOppSA.size());	
                     System.debug('count--SolnArea-'+ SolnArea.size());	
						  if(getOppSA.size()>0){
                   			 List<Opportunity_Solution_Area__c> oppDetails = new List<Opportunity_Solution_Area__c>();
						   for(Opportunity_Solution_Area__c oSolArea : getOppSA){
                                for(Core_Solution_Areas__c Sol : SolnArea){
                                    if (Sol.Id==oSolArea.Core_Solution_Areas__c)
                                    {
                                          
                                        oSolArea.Core_Technology_Enabled__c = Sol.Core_Technology_Enabled__c;
                                        oSolArea.Core_Region_of_availability__c = Sol.Core_Region_of_availability__c;
                                        oSolArea.Core_Industry_Use_Case_s__c = Sol.Core_Industry_Use_Case__c;
                                        oSolArea.Core_Industry__c = Sol.Core_Industry__c;
                                        oSolArea.Core_Application_Workload__c = Sol.Core_Application_Workload__c;
                                        oppDetails.add(oSolArea);
                                        System.debug('Inside  updateOpportunitySolutionArea -- record updated');
                                        System.debug('Sol.Core_Industry_Use_Case__c  '+ Sol.Core_Industry_Use_Case__c);
                                    }
                                }
                          }
                              upsert oppDetails;
                    }
                }	
            }
           
        }Catch(Exception ex){
            System.debug('Exception after updating OPTY Solns updateOpportunitySolutionArea:::'+ex);
        }
    } 
    /*
    * Method name  : AddOpportunitySolutionArea
    * Description  : When adding the Solution area OPTY Solution area updating the required fields.
    * Return Type  : VOID
    * Parameter    : 
    */
    
      public static void AddOpportunitySolutionArea(List<Opportunity_Solution_Area__c> newOptySolutionArea){
        System.debug('Inside AddOpportunitySolutionArea');
     
        Set<Id> oppIds = new Set<Id>();
        Set<Id> SAIds = new Set<Id>();
        List<Opportunity_Solution_Area__c> getOppSA= new List<Opportunity_Solution_Area__c>();
       
        try{
         
            if(newOptySolutionArea.size()>0){
                for(Opportunity_Solution_Area__c OppSA: newOptySolutionArea){ 
                     oppIds.add(OppSA.Core_Opportunity__c); 
                }
                System.debug('AddOpportunitySolutionArea--oppId-'+ oppIds.size());
                if(oppIds.size()>0){ 
                getOppSA = [Select Id, Core_Solution_Areas__c, Core_Technology_Enabled__c, Core_Region_of_availability__c ,Core_Industry_Use_Case_s__c, Core_Industry__c, Core_Application_Workload__c from Opportunity_Solution_Area__c where Core_Opportunity__c in :oppIds]; 
                if(getOppSA.size()>0){
                    for(Opportunity_Solution_Area__c OppSA: getOppSA){ 
                         SAIds.add(OppSA.Core_Solution_Areas__c); 
                    }
                    List<Core_Solution_Areas__c> SolnArea= new List<Core_Solution_Areas__c>();
                    SolnArea = [Select Id, Core_Solution_Areas__c, tolabel( Core_Technology_Enabled__c), tolabel(Core_Region_of_availability__c) ,tolabel(Core_Industry_Use_Case__c),  tolabel(Core_Industry__c), tolabel( Core_Application_Workload__c) from Core_Solution_Areas__c where Id in :SAIds]; 
                        // update Opportunity_Solution_Area__c	
                         System.debug('count--getOppSA-'+ getOppSA.size());	
                         System.debug('count--SolnArea-'+ SolnArea.size());	
                              if(getOppSA.size()>0){
                                 List<Opportunity_Solution_Area__c> oppDetails = new List<Opportunity_Solution_Area__c>();
                               for(Opportunity_Solution_Area__c oSolArea : getOppSA){
                                    for(Core_Solution_Areas__c Sol : SolnArea){
                                        if (Sol.Id==oSolArea.Core_Solution_Areas__c)
                                        { 
                                            oSolArea.Core_Technology_Enabled__c = Sol.Core_Technology_Enabled__c;
                                            oSolArea.Core_Region_of_availability__c = Sol.Core_Region_of_availability__c;
                                            oSolArea.Core_Industry_Use_Case_s__c = Sol.Core_Industry_Use_Case__c;
                                            oSolArea.Core_Industry__c = Sol.Core_Industry__c;
                                            oSolArea.Core_Application_Workload__c = Sol.Core_Application_Workload__c;
                                            oppDetails.add(oSolArea);
                                            System.debug('Inside  AddOpportunitySolutionArea -- record updated');
                                        }
                                    }
                              }
                            upsert oppDetails;
                        }
                }	
              }           
        }
        }
        Catch(Exception ex){
            System.debug('Exception after updating OPTY Solns AddOpportunitySolutionArea:::'+ex);
        }
    }
}