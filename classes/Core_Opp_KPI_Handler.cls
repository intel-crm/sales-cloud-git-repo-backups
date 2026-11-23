/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Opp_KPI_Handler
Version     : 1.0 
Created Date: 14th Jan 2019
Function    : Trigger handler method for Opportunity KPI
Modification Log :
* Developer                   Date             Description
* ----------------------------------------------------------------------------                 
* Ashwin Dash                14 Jan 2019      US176263 : SMG 2019: DWG- Update DWG Logic for 2019 [Production Deployment WW04.3]
* Ashwin Dash				 10 Jun 2019	  US379922 : KPI defect fix migration to PROD (WW24.1)
*****************************************************************************************************************************************************************************************************/

public class Core_Opp_KPI_Handler {
    
    //START: US176263 : SMG 2019: DWG- Update DWG Logic for 2019 [Production Deployment WW04.3]  -- Ashwin
    /*
* Method name  : updDWGonInstUpdtKPI
* Description  : This Method is used to update the KPI Flags on DWG if the KPI Name is matched or KPI achieved on Oppty KPI. It runs whenever there is update or insert in the KPI.
* Return Type  : void
* Parameter    : (list<Core_Opportunity_KPI__c> newGoalList, Map<Id, Core_Opportunity_KPI__c> oldGoalMap).
*/ 
    public static boolean isKPIInsert = false;
    public static void updDWGonInstUpdtKPI(List<Core_Opportunity_KPI__c> newKPIList, Map<Id, Core_Opportunity_KPI__c> oldKPIMap, boolean isDelete){ 
        Set<Id> opptyIdSet = new Set<Id>();
        Map<Id, List<Core_Goal__c>> opptyDWGMap = new Map<Id, List<Core_Goal__c>>();
        //US379922 : KPI defect fix migration to PROD (WW24.1) - Created a map and Set to capture the count of KPI
		Map<Id, Map<String, Integer>> opptyKPICountMap = new Map<Id, Map<String, Integer>>();
		Set<Id> countDelKPIOpptyId = new Set<Id>();
        Set<Core_Goal__c> updateDWGforKPISet = new Set<Core_Goal__c>();
        Set<Core_Goal__c> interDWGKPISet = new Set<Core_Goal__c>();
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        
        if(!isdelete){
			for(Core_Opportunity_KPI__c kpi : newKPIList){
				opptyIdSet.add(kpi.Core_Opp_KPI_Opportunity__c);
			}
        }else{
            for(Core_Opportunity_KPI__c kpi : oldKPIMap.values()){
				opptyIdSet.add(kpi.Core_Opp_KPI_Opportunity__c);
				countDelKPIOpptyId.add(kpi.Core_Opp_KPI_Opportunity__c);				
			}
        }
        //START - US379922 : KPI defect fix migration to PROD (WW24.1) - populate the KPI count for each Opportunity 
		for(Core_Opportunity_KPI__c kpi : [SELECT id, Name, Core_Opp_KPI_Achieved__c, Core_Opp_KPI_Opportunity__c FROM Core_Opportunity_KPI__c WHERE Core_Opp_KPI_Opportunity__c IN :countDelKPIOpptyId]){
			if(opptyKPICountMap.get(kpi.Core_Opp_KPI_Opportunity__c) != null && !opptyKPICountMap.get(kpi.Core_Opp_KPI_Opportunity__c).isEmpty()){
				Map<String, Integer> tempKPIMap = new Map<String, Integer>();
				tempKPIMap = opptyKPICountMap.get(kpi.Core_Opp_KPI_Opportunity__c);
				if(tempKPIMap.get(kpi.Name) != null){
					tempKPIMap.put(kpi.Name, tempKPIMap.get(kpi.Name)+1);
					opptyKPICountMap.put(kpi.Core_Opp_KPI_Opportunity__c, tempKPIMap);
				}
			}else{
				opptyKPICountMap.put(kpi.Core_Opp_KPI_Opportunity__c, new Map<String, Integer>{kpi.Name => 0});
			}
		}
        //END - US379922 : KPI defect fix migration to PROD (WW24.1) - populate the KPI count for each Opportunity 
       
        for(Core_Goal__c dwg : [SELECT id, name, Core_Goal_BU_Focus_Area__c, Core_Goal_KPI_Achieved_Flag__c, Core_Goal_KPI_Match_Flag__c, Core_Opportunity__c FROM Core_Goal__c WHERE Core_Opportunity__c IN :opptyIdSet]){
            List<Core_Goal__c> tempList = new List<Core_Goal__c>();
            if(opptyDWGMap.get(dwg.Core_Opportunity__c) != null){
                tempList = opptyDWGMap.get(dwg.Core_Opportunity__c);
                tempList.add(dwg);
                opptyDWGMap.put(dwg.Core_Opportunity__c, tempList);
            }else{
                tempList.add(dwg);
                opptyDWGMap.put(dwg.Core_Opportunity__c, tempList);
            }
        }
        
        if(!isDelete){
            System.debug('***Entering Update**');
            for(Core_Opportunity_KPI__c kpi : newKPIList){
                if((oldKPIMap == null || oldKPIMap.isEmpty()) && opptyDWGMap.get(kpi.Core_Opp_KPI_Opportunity__c) != null){
                    for(Core_Goal__c dwg : opptyDWGMap.get(kpi.Core_Opp_KPI_Opportunity__c)){
                        System.debug('****Inside For Loop***');
                        if(dwg.Core_Goal_BU_Focus_Area__c == kpi.name){
                            dwg.Core_Goal_KPI_Match_Flag__c = true;
                            System.debug('***KPI - '+dwg.Core_Goal_KPI_Match_Flag__c);
                            if(kpi.Core_Opp_KPI_Achieved__c){
                                dwg.Core_Goal_KPI_Achieved_Flag__c = true;
                            }
                            updateDWGforKPISet.add(dwg);
                        }
                    }
                    isKPIInsert = true;
                }
				if(oldKPIMap != null && !oldKPIMap.isEmpty() && oldKPIMap.get(kpi.Id).Core_Opp_KPI_Achieved__c != kpi.Core_Opp_KPI_Achieved__c && oldKPIMap.get(kpi.Id).name == kpi.name && opptyDWGMap.get(kpi.Core_Opp_KPI_Opportunity__c) != null){
					System.debug('***Only KPI Achieved flag changed***');
                    for(Core_Goal__c dwg : opptyDWGMap.get(kpi.Core_Opp_KPI_Opportunity__c)){
                        if(dwg.Core_Goal_BU_Focus_Area__c == kpi.name){	
                            dwg.Core_Goal_KPI_Match_Flag__c = true;
                            if(kpi.Core_Opp_KPI_Achieved__c){
                                dwg.Core_Goal_KPI_Achieved_Flag__c = true;
                            }else{
                                dwg.Core_Goal_KPI_Achieved_Flag__c = false;
                            }
                            updateDWGforKPISet.add(dwg);
                        }
                    }
                }
				if(oldKPIMap != null && !oldKPIMap.isEmpty() && oldKPIMap.get(kpi.Id).name != kpi.name && opptyDWGMap.get(kpi.Core_Opp_KPI_Opportunity__c) != null){
					System.debug('***Only KPI Name changed***');
					for(Core_Goal__c dwg : opptyDWGMap.get(kpi.Core_Opp_KPI_Opportunity__c)){
						if(dwg.Core_Goal_BU_Focus_Area__c == oldKPIMap.get(kpi.Id).name){	
							dwg.Core_Goal_KPI_Match_Flag__c = false;
							dwg.Core_Goal_KPI_Achieved_Flag__c = false;
							updateDWGforKPISet.add(dwg);
						}
					}
					System.debug('***KPI Name Updated for OLD***'+updateDWGforKPISet);
					for(Core_Goal__c dwg : opptyDWGMap.get(kpi.Core_Opp_KPI_Opportunity__c)){
						if(dwg.Core_Goal_BU_Focus_Area__c == kpi.name){	
							dwg.Core_Goal_KPI_Match_Flag__c = true;
							if(kpi.Core_Opp_KPI_Achieved__c){
                                dwg.Core_Goal_KPI_Achieved_Flag__c = true;
                            }else{
                                dwg.Core_Goal_KPI_Achieved_Flag__c = false;
                            }
                            updateDWGforKPISet.add(dwg);
						}
					}
				}
            }
        }else{
            for(Core_Opportunity_KPI__c kpi : oldKPIMap.values()){
                //US379922 : KPI defect fix migration to PROD (WW24.1) - Checking the Count 
				Integer count = 0;
				count = opptyKPICountMap.get(kpi.Core_Opp_KPI_Opportunity__c).get(kpi.Name);
				if(count < 1){
					if(opptyDWGMap.get(kpi.Core_Opp_KPI_Opportunity__c) != null){
						for(Core_Goal__c dwg : opptyDWGMap.get(kpi.Core_Opp_KPI_Opportunity__c)){
							if(dwg.Core_Goal_BU_Focus_Area__c == kpi.name){
								dwg.Core_Goal_KPI_Match_Flag__c = false;
								if(kpi.Core_Opp_KPI_Achieved__c){
									dwg.Core_Goal_KPI_Achieved_Flag__c = false;
								}
								updateDWGforKPISet.add(dwg);
							}
							
						}
					}
				}
            }
        }           
        
        if(!updateDWGforKPISet.isEmpty()){
            List<Core_Goal__c> updateDWGforKPIList = new List<Core_Goal__c>();
            Map<Id, Core_Goal__c> mapDWGKPIList = new Map<Id, Core_Goal__c>();
            updateDWGforKPIList.addAll(updateDWGforKPISet);
            mapDWGKPIList.putAll(updateDWGforKPIList);
            Database.SaveResult[] srList = Database.update(mapDWGKPIList.values(), false);
            for(Database.SaveResult sr : srList) {
                if(!sr.isSuccess()){
                    String errorMsg = '';
                    for(Database.Error err : sr.getErrors()) {
                        errorMsg = errorMsg + err.getMessage();
                    }
					System.debug('***Error MSG - '+errorMsg);
                    captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'DWG_Update_Error', Core_Severity__c = 'High', Core_Origin__c='core_Opp_KPI_Handler', Core_When__c = System.now()));   
                }
            }
        }
        if(!captureQueryErr.isEmpty()){
            insert captureQueryErr;
        }
        
    }
    //END: US176263 : SMG 2019: DWG- Update DWG Logic for 2019 [Production Deployment WW04.3]  -- Ashwin    
    
    
}