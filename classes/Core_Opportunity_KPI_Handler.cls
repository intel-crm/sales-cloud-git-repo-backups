/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Opportunity_KPI_Handler
Version     : 1.0 
Created Date: 28 May 2020
Function    : Trigger handler method for Opportunity KPI
Modification Log :
* Developer                   Date             Description
* ----------------------------------------------------------------------------                 
* Mahesh                    28 May 2020         new Opportunity KPI Object trigger handler, old class Core_Opp_KPI_Handler
*****************************************************************************************************************************************************************************************************/

public without sharing class Core_Opportunity_KPI_Handler { //TWC3123-5376: code scan fix

    
   
    /*
* Method name  : updateDWGOnInstUpdtDelOppKPI
* Description  : This Method is used to update the KPI Flags on DWG if the KPI Name is matched or KPI achieved on Oppty KPI. It runs whenever there is update or insert in the KPI.
* Return Type  : void
* Parameter    : (list<Core_Oppty_KPI_New__c> newGoalList, Map<Id, Core_Oppty_KPI_New__c> oldGoalMap,String triggerPoint).
*/ 
    public static boolean isKPIInsert = false;
     public static void updateDWGOnInstUpdtDelOpportunityKPI(List<Core_Oppty_KPI_New__c> newKPIList, Map<Id, Core_Oppty_KPI_New__c> oldKPIMap, String triggerPoint) {
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        Set<String> oppIdSet = new Set<String>();
        if(triggerPoint.equalsIgnoreCase('delete')){
            for(Core_Oppty_KPI_New__c oppKpi : oldKPIMap.values()){
                if(oppKpi.Core_KPI_Opportunity__c <> null){
                    oppIdSet.add(oppKpi.Core_KPI_Opportunity__c);
                }
            }
        }else{
            for(Core_Oppty_KPI_New__c oppKpi : newKPIList){
                if(triggerPoint.equalsIgnoreCase('insert') && oppKpi.Core_KPI_Opportunity__c <> null){
                    oppIdSet.add(oppKpi.Core_KPI_Opportunity__c);
                }
                if(triggerPoint.equalsIgnoreCase('update')){
                    if((oppKpi.Core_KPI_Opportunity__c <> null && oppKpi.Core_KPI_Opportunity__c <> oldKPIMap.get(oppKpi.Id).Core_KPI_Opportunity__c) || (oppKpi.Core_KPI_Opportunity__c <> null && oppKpi.Core_KPI_Achieved__c <> oldKPIMap.get(oppKpi.Id).Core_KPI_Achieved__c || oppKpi.Name <> oldKPIMap.get(oppKpi.Id).Name)){
                        oppIdSet.add(oppKpi.Core_KPI_Opportunity__c);
                    }
                     if((oppKpi.Core_KPI_Opportunity__c <> null && oppKpi.Core_KPI_Opportunity__c <> oldKPIMap.get(oppKpi.Id).Core_KPI_Opportunity__c)){
                        oppIdSet.add(oldKPIMap.get(oppKpi.id).Core_KPI_Opportunity__c);
                       
                    }
                    if((oppKpi.Core_KPI_Opportunity__c <> null && oppKpi.Core_KPI_Opportunity__c <> oldKPIMap.get(oppKpi.Id).Core_KPI_Opportunity__c) || (oppKpi.Core_KPI_Total_Price__c <> oldKPIMap.get(oppKpi.Id).Core_KPI_Total_Price__c || oppKpi.Core_Opp_KPI_Type__c <> oldKPIMap.get(oppKpi.Id).Core_Opp_KPI_Type__c)){
                        oppIdSet.add(oppKpi.Core_KPI_Opportunity__c);
                    }
                    if(oppKpi.Core_KPI_Opportunity__c <> null && oppKpi.Core_IsActive__c <> oldKPIMap.get(oppKpi.Id).Core_IsActive__c){
                        oppIdSet.add(oppKpi.Core_KPI_Opportunity__c);
                    }
                }
            }
        }
       
        if(!oppIdSet.isEmpty()){
            Map<String,Core_Goal__c> finalDWGMap = new Map<String,Core_Goal__c>();
            List<Core_Goal__c> dwgList = [select Id, Core_Goal_BU_Focus_Area__c, Core_Opportunity__c, Core_Validate_KPI_Flag__c from Core_Goal__c where Core_Opportunity__c IN: oppIdSet];
            if(!dwgList.isEmpty()){
                Map<String,List<Core_Goal__c>> oppDWGMap = new Map<String,List<Core_Goal__c>>();
                List<Core_Goal__c> tempList = new List<Core_Goal__c>();
                for(Core_Goal__c dwg : dwgList){
                    if(oppDWGMap.containskey(dwg.Core_Opportunity__c)){
                        tempList = oppDWGMap.get(dwg.Core_Opportunity__c);
                    }else{
                        tempList = new List<Core_Goal__c>();
                    }
                    tempList.add(dwg);
                    oppDWGMap.put(dwg.Core_Opportunity__c,tempList);
                }
                List<Core_Oppty_KPI_New__c> tempKPIList = new List<Core_Oppty_KPI_New__c>();
                if(triggerPoint.equalsIgnoreCase('delete')){
                    tempKPIList = oldKPIMap.values();
                }else if(triggerPoint.equalsIgnoreCase('update')){
                    tempKPIList.addAll(newKPIList);
                    tempKPIList.addAll(oldKPIMap.values());
                }else{
                    tempKPIList = newKPIList;
                }
                for(Core_Oppty_KPI_New__c oppKpi : tempKPIList){
                    if(oppDWGMap.get(oppKpi.Core_KPI_Opportunity__c) != null){
                        for(Core_Goal__c dwg : oppDWGMap.get(oppKpi.Core_KPI_Opportunity__c)){
                            if(dwg.Core_Goal_BU_Focus_Area__c.equalsIgnoreCase(oppKpi.Name) && !finalDWGMap.containsKey(dwg.Id)){
                              
                                Core_Goal__c tempDWG = new Core_Goal__c();
                                tempDWG.Id = dwg.Id;
                                tempDWG.Core_Validate_KPI_Flag__c = true;
                                tempDWG.Core_KPI_Revenue_Update__c =true;
                                finalDWGMap.put(tempDWG.Id, tempDWG);
                            }
                        }
                    }
                }
            
                        
        if(!finalDWGMap.isEmpty()){
         
            Database.SaveResult[] srList = Database.update(finalDWGMap.values(), false);
            for(Database.SaveResult sr : srList) {
                if(!sr.isSuccess()){
                    String errorMsg = '';
                    for(Database.Error err : sr.getErrors()) {
                        errorMsg = errorMsg + err.getMessage();
                    }
                  
                    captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'DWG_Update_Error', Core_Severity__c = 'High', Core_Origin__c='core_Opportunity_KPI_Handler', Core_When__c = System.now()));   
                }
            }
        }
        if(!captureQueryErr.isEmpty()){
            insert captureQueryErr;
        }
                
            }
        }
    }
    
    
}