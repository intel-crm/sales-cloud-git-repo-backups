/***************************************************************************************************************************************************************************************************
Function    : Trigger handler method for Opportunity KPI
*****************************************************************************************************************************************************************************************************/

public without sharing class Core_Opp_KPI_Handler {//TWC3123-5338 Added without sharing keyword to fix code scan issue
    
   
    /*
* Method name  : updateDWGOnInstUpdtDelOppKPI
* Description  : This Method is used to update the KPI Flags on DWG if the KPI Name is matched or KPI achieved on Oppty KPI. It runs whenever there is update or insert in the KPI.
* Return Type  : void
* Parameter    : (list<Core_Opportunity_KPI__c> newGoalList, Map<Id, Core_Opportunity_KPI__c> oldGoalMap,String triggerPoint).
*/ 
    public static boolean isKPIInsert = false;
    public static List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
    public static Set<String> oppIdSet = new Set<String>();
     public static void updateDWGOnInstUpdtDelOppKPI(List<Core_Opportunity_KPI__c> newKPIList, Map<Id, Core_Opportunity_KPI__c> oldKPIMap, String triggerPoint){
        
        if(triggerPoint.equalsIgnoreCase('delete')){
            KPI_Delete(oldKPIMap);
        }
        else if(triggerPoint.equalsIgnoreCase('insert') || triggerPoint.equalsIgnoreCase('update')){
            KPI_Upsert(newKPIList,oldKPIMap,triggerPoint);
        }   
            
        updateDWG_KPI(newKPIList,oldKPIMap,triggerPoint);
        
       
    }
    
    Private static void KPI_Delete( Map<Id, Core_Opportunity_KPI__c> oldKPIMap ){
        for(Core_Opportunity_KPI__c oppKpi : oldKPIMap.values()){
                if(oppKpi.Core_Opp_KPI_Opportunity__c <> null){
                    oppIdSet.add(oppKpi.Core_Opp_KPI_Opportunity__c);
                }
            }
    
    }
    
    Private static void KPI_Upsert( List<Core_Opportunity_KPI__c> newKPIList, Map<Id, Core_Opportunity_KPI__c> oldKPIMap, String triggerPoint){
    for(Core_Opportunity_KPI__c oppKpi : newKPIList){
                if(triggerPoint.equalsIgnoreCase('insert') && oppKpi.Core_Opp_KPI_Opportunity__c <> null){
                    oppIdSet.add(oppKpi.Core_Opp_KPI_Opportunity__c);
                }
              
                    if( triggerPoint.equalsIgnoreCase('update') && (oppKpi.Core_Opp_KPI_Opportunity__c <> null && oppKpi.Core_Opp_KPI_Opportunity__c <> oldKPIMap.get(oppKpi.Id).Core_Opp_KPI_Opportunity__c) || (oppKpi.Core_Opp_KPI_Opportunity__c <> null && oppKpi.Core_Opp_KPI_Achieved__c <> oldKPIMap.get(oppKpi.Id).Core_Opp_KPI_Achieved__c || oppKpi.Name <> oldKPIMap.get(oppKpi.Id).Name)){
                        oppIdSet.add(oppKpi.Core_Opp_KPI_Opportunity__c);
                    }
           if(triggerPoint.equalsIgnoreCase('update') && (oppKpi.Core_Opp_KPI_Opportunity__c <> null && oppKpi.Core_Opp_KPI_Opportunity__c <> oldKPIMap.get(oppKpi.Id).Core_Opp_KPI_Opportunity__c)){
                        oppIdSet.add(oldKPIMap.get(oppKpi.id).Core_Opp_KPI_Opportunity__c);
                        
                    }
                    if( triggerPoint.equalsIgnoreCase('update') && (oppKpi.Core_Opp_KPI_Opportunity__c <> null && oppKpi.Core_Opp_KPI_Opportunity__c <> oldKPIMap.get(oppKpi.Id).Core_Opp_KPI_Opportunity__c) || (oppKpi.Core_Opp_KPI_Total_Price__c <> oldKPIMap.get(oppKpi.Id).Core_Opp_KPI_Total_Price__c || oppKpi.Core_Opp_KPI_Type__c <> oldKPIMap.get(oppKpi.Id).Core_Opp_KPI_Type__c)){
                        oppIdSet.add(oppKpi.Core_Opp_KPI_Opportunity__c);
                    }
               
            }
            }
            
    Private static void updateDWG_KPI(List<Core_Opportunity_KPI__c> newKPIList, Map<Id, Core_Opportunity_KPI__c> oldKPIMap, String triggerPoint){
        if(!oppIdSet.isEmpty()){
            Map<String,Core_Goal__c> finalDWGMap = new Map<String,Core_Goal__c>();
            List<Core_Goal__c> dwgList = [select Id, Core_Goal_BU_Focus_Area__c, Core_Opportunity__c, Core_Validate_KPI_Flag__c from Core_Goal__c where Core_Opportunity__c IN: oppIdSet WITH SECURITY_ENFORCED];
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
                List<Core_Opportunity_KPI__c> tempKPIList = new List<Core_Opportunity_KPI__c>();
                if(triggerPoint.equalsIgnoreCase('delete')){
                    tempKPIList = oldKPIMap.values();
                }else if(triggerPoint.equalsIgnoreCase('update')){
                    tempKPIList.addAll(newKPIList);
                    tempKPIList.addAll(oldKPIMap.values());
                }else{
                    tempKPIList = newKPIList;
                }
                for(Core_Opportunity_KPI__c oppKpi : tempKPIList){
                    if(oppDWGMap.get(oppKpi.Core_Opp_KPI_Opportunity__c) != null){
                        for(Core_Goal__c dwg : oppDWGMap.get(oppKpi.Core_Opp_KPI_Opportunity__c)){
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
                    
                    captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'DWG_Update_Error', Core_Severity__c = 'High', Core_Origin__c='core_Opp_KPI_Handler', Core_When__c = System.now()));   
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