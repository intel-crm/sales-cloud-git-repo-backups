/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_GoalHandler
Version     : 1.0 
Created Date: 02 OCT 2017
Function    : Utility methods to handle Goal functions
Modification Log :
* Developer                   Date             Description
* ----------------------------------------------------------------------------                 
* David S Wong               02 OCT 2017      Commented out code previously existed; added some new handling related to commissions.
* Ashwin Dash                25 OCT 2017      US83097 - Added method to Update the accepted date 
* Ashwin Dash                10 APR 2018      US101134 : DWG: Ensure Delegate Approvers Have Access to Deal Win Goals
* Ashwin Dash                14 JUN 2018      US108336 - Added method to update OpportunityIdentified field while inserting or updating\
* Ashwin Dash                19 JUL 2018      US103737 : DWG: Remove Old Relationship/Report Types - OOC WW29.4
* Ashwin Dash                14 Jan 2019      US176263 : SMG 2019: DWG- Update DWG Logic for 2019 [Production Deployment WW04.3]
*****************************************************************************************************************************************************************************************************/


public class Core_GoalHandler {
    // Make sure we only execute Commissionable Transactions functionality once
    public static Boolean alreadyAddedCommissionableTransactions = false;
    public static final string Core_ACCEPTED = 'Accepted';
    public static final String Core_SUBMITTED = 'Submitted';
    public static final String Core_APPROVED = 'Approved';
    public static boolean recurrsiveCheck = false;
    public static boolean kpiRecurrCheck = false;
    public static boolean KpiRecCheck = false;
    public static boolean restrictPicklistCheck = false;
    public static Map<String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public static EmailTemplate emailNoLongerAchievedTemplate = [Select Id from EmailTemplate where developername = 'DWG_No_Longer_Achieved_Need_to_be_Recalled'];
    public static EmailTemplate emailKPIAchievedTemplate = [Select Id from EmailTemplate where developername = 'DWG_Ready_to_Submit_Notification'];
    
    
    //START: US176263 : SMG 2019: DWG- Update DWG Logic for 2019 [Production Deployment WW04.3]  -- Ashwin
    /*
* Method name  : UpdateGoalOnKPIChange
* Description  : This Method is used to update the KPI Flags on DWG if the KPI Name is matched or KPI achieved on Oppty KPI .
* Return Type  : void
* Parameter    : (list<Core_Goal__c> newGoalList, Map<Id, Core_Goal__c> oldGoalMap).
*/ 

    
    public static void UpdateGoalOnKPIChange(List<Core_Goal__c> dwgList, Map<Id,Core_Goal__c> oldGoalMap){
        List<Core_Goal__c> finalDwgList = new List<Core_Goal__c>();
        for(Core_Goal__c dwg : dwgList){
            if((dwg.Core_Goal_BU_Focus_Area__c <> null && dwg.Core_Goal_BU_Focus_Area__c <> oldGoalMap.get(dwg.Id).Core_Goal_BU_Focus_Area__c) || (dwg.Core_Validate_KPI_Flag__c && !oldGoalMap.get(dwg.Id).Core_Validate_KPI_Flag__c) ||
               (dwg.Core_Opportunity__c <> oldGoalMap.get(dwg.Id).Core_Opportunity__c)){
                   system.debug('!!!!!!!!!!! '+dwg.Id);
                   finalDwgList.add(dwg);
               }
        }
        if(!finalDwgList.isEmpty()){
            system.debug('@@@@@@@@@@@@@@@@ '+finalDwgList);
            validateKPIAchievedFlag(finalDwgList);
        }
    }
    
    public static void validateKPIAchievedFlag(List<Core_Goal__c> dwgList){
        Set<String> oppId = new Set<String>();
        for(Core_Goal__c dwg : dwgList){
            if(dwg.Core_Opportunity__c <> null){
                oppId.add(dwg.Core_Opportunity__c);
            }
        }
        system.debug('########### '+oppId);
        List<Core_Oppty_KPI_New__c> oppKpiList = new List<Core_Oppty_KPI_New__c>();
        if(oppId.isEmpty()){
            for(Core_Goal__c dwg : dwgList){
                dwg.Core_Goal_KPI_Match_Flag__c = false;
                dwg.Core_Goal_KPI_Achieved_Flag__c = false;
                dwg.Core_Validate_KPI_Flag__c = false;
            }
        }else{
            oppKpiList = [select Id, Name, Core_KPI_Achieved__c, Core_KPI_Opportunity__c from Core_Oppty_KPI_New__c where Core_KPI_Opportunity__c IN: oppId AND Core_IsActive__c = true];
            if(oppKpiList.isEmpty()){
                for(Core_Goal__c dwg : dwgList){
                    dwg.Core_Goal_KPI_Match_Flag__c = false;
                    dwg.Core_Goal_KPI_Achieved_Flag__c = false;
                    dwg.Core_Validate_KPI_Flag__c = false;
                }
            }else{
                system.debug('$$$$$$$$$$$$$$$$$ '+oppKpiList);
                Map<String,List<Core_Oppty_KPI_New__c>> oppKpiMap = new Map<String,List<Core_Oppty_KPI_New__c>>();
                List<Core_Oppty_KPI_New__c> tempList = new List<Core_Oppty_KPI_New__c>();
                for(Core_Oppty_KPI_New__c oppKpi : oppKpiList){
                    if(oppKpiMap.containskey(oppKpi.Core_KPI_Opportunity__c)){
                        tempList = oppKpiMap.get(oppKpi.Core_KPI_Opportunity__c);
                    }else{
                        tempList = new List<Core_Oppty_KPI_New__c>();
                    }
                    tempList.add(oppKpi);
                    oppKpiMap.put(oppKpi.Core_KPI_Opportunity__c,tempList);
                }
                Integer kpiCount;
                Integer kpiAchievedCount;
                for(Core_Goal__c dwg : dwgList){
                    system.debug('%%%%%%%%%%%%%%%% '+dwg);
                    kpiCount = kpiAchievedCount = 0;
                    if(oppKpiMap.containskey(dwg.Core_Opportunity__c)){
                        for(Core_Oppty_KPI_New__c oppKpi : oppKpiMap.get(dwg.Core_Opportunity__c)){
                            if(oppKpi.Name.equalsIgnoreCase(dwg.Core_Goal_BU_Focus_Area__c)){
                                kpiCount = kpiCount + 1;
                                if(oppKpi.Core_KPI_Achieved__c){
                                    kpiAchievedCount = kpiAchievedCount + 1;
                                }
                            }
                        }
                    }
                    if(kpiCount > 0){
                        dwg.Core_Goal_KPI_Match_Flag__c = true;
                        if(kpiCount == kpiAchievedCount){
                            dwg.Core_Goal_KPI_Achieved_Flag__c = true;
                        }else{
                            dwg.Core_Goal_KPI_Achieved_Flag__c = false;
                        }
                    }else{
                        dwg.Core_Goal_KPI_Match_Flag__c = false;
                        dwg.Core_Goal_KPI_Achieved_Flag__c = false;
                    }
                    dwg.Core_Validate_KPI_Flag__c = false;
                }
                system.debug('^^^^^^^^^^^^^^^^^^^^ '+dwgList);
            }
        }
    }
    
    
    
    //START: US108336- Added method to update OpportunityIdentified -- Ashwin
    /*
* Method name  : updateOpptyIdentified
* Description  : This Method is used to update the Opportunity Identified field to true if the Opporutnity has been added .
* Return Type  : void
* Parameter    : (list<Core_Goal__c> newGoalList, Map<Id, Core_Goal__c> oldGoalMap).
*/ 
    public static void updateOpptyIdentified(List<Core_Goal__c> newGoalList, Map<Id, Core_Goal__c> oldGoalMap){             
        for(Core_Goal__c dwg : newGoalList){
            if(dwg.Core_Opportunity__c != null){
                dwg.Core_Goal_Opportunity_Identified__c = true;
            }else{
                dwg.Core_Goal_Opportunity_Identified__c = false;
            }
            if(mapFunctionalityNameTriggerExecution.containsKey('beforeDWGUpdateStatusCheck') && mapFunctionalityNameTriggerExecution.get('beforeDWGUpdateStatusCheck').Core_Active__c){
                if(oldGoalMap != null && !oldGoalMap.isEmpty()){
                    if(oldGoalMap.get(dwg.Id).Core_Opportunity__c != dwg.Core_Opportunity__c && (dwg.Core_Goal_Status__c == 'Submitted' || dwg.Core_Goal_Status__c == 'Approved')){
                        dwg.addError('Opportunity cannot be changed when Deal Win Goal Record is Submitted or Approved');
                    }
                }
            }
        }
        
    }
    //END: US108336 - Added method to update OpportunityIdentified -- Ashwin
    
    public static void restrictBadPicklistValues(String objName, String pickListName, List<sObject>sObjList, Map<Id, sObject>sObjectOldMap){
        Core_Opp_Bypass_Validation_Rule__c bypassValidation = Core_Opp_Bypass_Validation_Rule__c.getInstance();
        if(!bypassValidation.Bypass__c){
            Map<String, Schema.SObjectType> GlobalMap = Schema.getGlobalDescribe();
            Schema.DescribeSObjectResult sObj = GlobalMap.get(objName).getDescribe();
            Schema.DescribeFieldResult descField = sObj.Fields.getMap().get(pickListName).getDescribe();        
            List<Schema.PicklistEntry> PList = descField.getPicklistValues();
            Set<String> pickSet = new Set<String>();
            for(Schema.PicklistEntry pi : PList){
                pickSet.add(pi.getValue());
            }
            //Specific to Goal Object
            if(objName == 'Core_Goal__c'){
                for(Core_Goal__c so : (List<Core_Goal__c>)sObjList){
                    Core_Goal__c oldGoal = (Core_Goal__c)sObjectOldMap.get(so.Id);
                    if(!pickSet.contains(so.Core_Goal_BU_Focus_Area__c) )//&& (((so.Core_Goal_Status__c == 'Accepted' || so.Core_Goal_Status__c == 'Submitted' || so.Core_Goal_Status__c == 'Draft') && oldGoal.Core_Goal_Status__c != 'Submitted' && oldGoal.Core_Goal_Status__c != 'Approved')
                    {
                        so.Core_Goal_BU_Focus_Area__c.addError(System.Label.DWG_KPI_PicklistError);
                    }                
                }
            }
        }
    }
    
     /*
* Method name  : updateGoalRevenueKPI
* Description  : This Method is used to update KPI Revenue on DWG based on the KPI Name. .
* Return Type  : void
* Parameter    : (list<Core_Goal__c> newGoalList, Map<Id, Core_Goal__c> oldGoalMap).
*/     
    
    public static void updateGoalRevenueKPI(List<Core_Goal__c> newGoalList,Map<Id, Core_Goal__c> oldGoalMap){
        Set<Id> opptyIdKPIIdSet = new Set<Id>();
        Map<Id, List<Core_Oppty_KPI_New__c>> opptyKPIMap = new Map<Id, List<Core_Oppty_KPI_New__c>>();
        for(Core_Goal__c dwg : newGoalList){
            if(dwg.Core_Opportunity__c <> null){
                opptyIdKPIIdSet.add(dwg.Core_Opportunity__c);
            }
        }
        
        for(Core_Oppty_KPI_New__c oppKPI : [SELECT id, name,Core_Opp_KPI_Type__c,Core_KPI_Total_Price__c, Core_KPI_Achieved__c, Core_KPI_Threshold_Met__c, Core_KPI_Opportunity__c FROM Core_Oppty_KPI_New__c WHERE Core_KPI_Opportunity__c IN :opptyIdKPIIdSet AND Core_IsActive__c = true]){
            List<Core_Oppty_KPI_New__c> tempList = new List<Core_Oppty_KPI_New__c>();
            if(opptyKPIMap.get(oppKPI.Core_KPI_Opportunity__c) != null){
                tempList = opptyKPIMap.get(oppKPI.Core_KPI_Opportunity__c);
                tempList.add(oppKPI);
                opptyKPIMap.put(oppKPI.Core_KPI_Opportunity__c, tempList);
            }else{
                tempList.add(oppKPI);
                opptyKPIMap.put(oppKPI.Core_KPI_Opportunity__c, tempList);
            }
        }
        
        
        for(Core_Goal__c dwg : newGoalList){
            Decimal FinalKPIRevenue=0;
            if(oldGoalMap == null || oldGoalMap.isEmpty()){
                System.debug('***Insert DWG**');
                if(dwg.Core_Opportunity__c != null && opptyKPIMap.get(dwg.Core_Opportunity__c) != null){
                    for(Core_Oppty_KPI_New__c kpi : opptyKPIMap.get(dwg.Core_Opportunity__c)){                        
                        if(dwg.Core_Goal_BU_Focus_Area__c == kpi.name && Kpi.Core_Opp_KPI_Type__c=='Salesforce Pipeline $' && Kpi.Core_KPI_Total_Price__c !=null){
                            FinalKPIRevenue =FinalKPIRevenue+Kpi.Core_KPI_Total_Price__c;
                            
                        }
                        
                    }
                    
                    if(FinalKPIRevenue !=0){
                        dwg.Core_KPI_Revenue__c=FinalKPIRevenue;
                    }else{
                        dwg.Core_KPI_Revenue__c=0;
                    }
                    dwg.Core_KPI_Revenue_Update__c=false;
                    
                }
            }else if(oldGoalMap != null &&  !oldGoalMap.isEmpty() && dwg.Core_Goal_BU_Focus_Area__c <> null && (dwg.Core_Goal_BU_Focus_Area__c <> oldGoalMap.get(dwg.Id).Core_Goal_BU_Focus_Area__c || dwg.Core_Opportunity__c <> oldGoalMap.get(dwg.Id).Core_Opportunity__c || dwg.Core_KPI_Revenue_Update__c <> oldGoalMap.get(dwg.Id).Core_KPI_Revenue_Update__c)){
                
                System.debug('***Update  DWG Revenue**');
                if(dwg.Core_Opportunity__c != null && opptyKPIMap.get(dwg.Core_Opportunity__c) != null){
                    for(Core_Oppty_KPI_New__c kpi : opptyKPIMap.get(dwg.Core_Opportunity__c)){                        
                        if(dwg.Core_Goal_BU_Focus_Area__c == kpi.name && Kpi.Core_Opp_KPI_Type__c=='Salesforce Pipeline $' && Kpi.Core_KPI_Total_Price__c !=null){
                            FinalKPIRevenue =FinalKPIRevenue+Kpi.Core_KPI_Total_Price__c;
                            system.debug('FinalKPI'+FinalKPIRevenue);
                        }
                    }
                }
                if(FinalKPIRevenue !=0){
                    dwg.Core_KPI_Revenue__c=FinalKPIRevenue;
                }else{
                    dwg.Core_KPI_Revenue__c=0;
                }
                dwg.Core_KPI_Revenue_Update__c=false;
            }
        }
    }
    
    
    //US83097 - Added method to update Accepted Date -- Ashwin
    /*
* Method name  : updateaGoalonApproval
* Description  : This Method is used to update opportunities at approval and other fields post approval action  .
* Return Type  : void
* Parameter    : (list<Core_Goal__c> newGoalList, Map<Id, Core_Goal__c> oldGoalMap).
*/ 
    public static void updateGoalonApproval(List<Core_Goal__c> newGoalList, Map<Id, Core_Goal__c> oldGoalMap){
       //US: 586414 : DWG :[Problem record : PRB000094420 ] "KPI Name" picklist changes
        if(!restrictPicklistCheck && mapFunctionalityNameTriggerExecution != null && !mapFunctionalityNameTriggerExecution.isEmpty() && mapFunctionalityNameTriggerExecution.containsKey('restrictInactivePicklist') && mapFunctionalityNameTriggerExecution.get('restrictInactivePicklist').Core_Active__c){
            
            for(Core_Goal__c cg : newGoalList){
                if(cg.Core_Goal_Status__c <> oldGoalMap.get(cg.id).Core_Goal_Status__c && !oldGoalMap.get(cg.id).Core_Goal_Status__c.equalsIgnoreCase('Approved') && !cg.Core_Goal_Status__c.equalsIgnoreCase('Accepted')){
                    restrictBadPicklistValues('Core_Goal__c', 'Core_Goal_BU_Focus_Area__c', newGoalList, oldGoalMap);
                }else if(cg.Core_Goal_Status__c == oldGoalMap.get(cg.id).Core_Goal_Status__c){
                    restrictBadPicklistValues('Core_Goal__c', 'Core_Goal_BU_Focus_Area__c', newGoalList, oldGoalMap);
                }
            }
            restrictPicklistCheck = true;
        }
      	//DWG EOL Temporary fix - switch to be added | Permanent fix - code to be re-configured
        //US103737 : DWG: Remove Old Relationship/Report Types - OOC WW29.4 -- Ashwin
        Map<Id,Core_Goal__c> coreGoalMap = new Map<Id, Core_Goal__c>([SELECT id, Core_Goal_Status__c, Core_Goal_Opportunities_at_Approval__c, Core_Goal_Owner__r.ManagerId, Core_Goal_Owner__r.Manager.DelegatedApproverId FROM Core_Goal__c WHERE Id IN :oldGoalMap.keySet()]);
        //, (SELECT id,Core_DWG_Opportunity__r.OwnerId FROM Opportunities1__r)
        
        //START - US101134 : Created maps for storing the sharing of opportunities or DWG with approvers -- Ashwin
        Set<Id> DWGOpptyIdSet = new Set<Id>();
        Set<Id> dwgIdSet = new Set<Id>();
        Set<Id> mngrDelegatedApproverSet = new Set<Id>();
        if(coreGoalMap != null && !coreGoalMap.isEmpty()){
            for(Core_Goal__c dwg : coreGoalMap.values()){
                if(dwg.Core_Goal_Owner__r.ManagerId != null){
                    mngrDelegatedApproverSet.add(dwg.Core_Goal_Owner__r.ManagerId);
                    if(dwg.Core_Goal_Owner__r.Manager.DelegatedApproverId != null){
                        mngrDelegatedApproverSet.add(dwg.Core_Goal_Owner__r.Manager.DelegatedApproverId);
                    }
                }
                dwgIdSet.add(dwg.Id);
                //START - US103737 : DWG: Remove Old Relationship/Report Types - OOC WW29.4 -- Ashwin
                /*if(coreGoalMap.get(dwg.Id).Opportunities1__r != null || !(coreGoalMap.get(dwg.Id).Opportunities1__r).isempty()){
for(DWG_Opportunity__c opp : coreGoalMap.get(dwg.Id).Opportunities1__r){
DWGOpptyIdSet.add(opp.Core_DWG_Opportunity__c);
}
}*/
                //END - US103737 : DWG: Remove Old Relationship/Report Types - OOC WW29.4 -- Ashwin
            }
        }
        List<Core_Goal__Share> goalShareList = new List<Core_Goal__Share>();
        List<OpportunityShare> opptyShareList = new List<OpportunityShare>();
        List<OpportunityShare> existingOpptyShareList = new List<OpportunityShare>();
        Map<Id, Set<Id>> opptyVsMgrMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> dwgVsMgrMap = new Map<Id, Set<Id>>();
        //START - US103737 : DWG: Remove Old Relationship/Report Types - OOC WW29.4 -- Ashwin
        /*existingOpptyShareList = [SELECT id, OpportunityId, RowCause, OpportunityAccessLevel, UserOrGroupId FROM OpportunityShare WHERE OpportunityId IN :DWGOpptyIdSet AND UserOrGroupId IN :mngrDelegatedApproverSet];
if(!existingOpptyShareList.isEmpty()){
for(OpportunityShare opptyShare : existingOpptyShareList){
Set<Id> tempSet = new Set<Id>();
if(opptyVsMgrMap.get(opptyShare.OpportunityId) != null){
tempSet=opptyVsMgrMap.get(opptyShare.OpportunityId);
tempSet.add(opptyShare.UserOrGroupId);
opptyVsMgrMap.put(opptyShare.OpportunityId, tempSet);
}else{
tempSet.add(opptyShare.UserOrGroupId);
opptyVsMgrMap.put(opptyShare.OpportunityId, tempSet);
}
}
}*/
        //END - US103737 : DWG: Remove Old Relationship/Report Types - OOC WW29.4 -- Ashwin
        List<Core_Goal__Share> existingGoalShareList = new List<Core_Goal__Share>();
        existingGoalShareList = [SELECT id, AccessLevel, RowCause, UserOrGroupId, ParentId FROM Core_Goal__Share WHERE ParentID IN :dwgIdSet AND UserOrGroupId IN :mngrDelegatedApproverSet];
        if(!existingGoalShareList.isEmpty()){
            for(Core_Goal__Share dwgShare : existingGoalShareList){
                Set<Id> tempSet = new Set<Id>();
                if(dwgVsMgrMap.get(dwgShare.ParentId) != null){
                    tempSet=dwgVsMgrMap.get(dwgShare.ParentId);
                    tempSet.add(dwgShare.UserOrGroupId);
                    dwgVsMgrMap.put(dwgShare.ParentId, tempSet);
                }else{
                    tempSet.add(dwgShare.UserOrGroupId);
                    dwgVsMgrMap.put(dwgShare.ParentId, tempSet);
                }
            }
        }
        
        system.debug('goalShareMap====>'+dwgVsMgrMap);
        system.debug('opptyShareMap===>'+opptyVsMgrMap);
        //END - US101134 : Created maps for storing the sharing of opportunities or DWG with approvers -- Ashwin
        for(Core_Goal__c dwg : newGoalList){
            if(coreGoalMap != null && !coreGoalMap.isEmpty()){
                if((dwg.Core_Goal_Status__c != oldGoalMap.get(dwg.Id).Core_Goal_Status__c) && (dwg.Core_Goal_Status__c == Core_APPROVED) && (oldGoalMap.get(dwg.Id).Core_Goal_Status__c != Core_APPROVED) && !recurrsiveCheck){                   
                    //START - US103737 : DWG: Remove Old Relationship/Report Types - OOC WW29.4 -- Ashwin
                    /*for(DWG_Opportunity__c opp : coreGoalMap.get(dwg.Id).Opportunities1__r){
if(String.isNotBlank(opp.Core_DWG_Opportunity__c)){
if(dwg.Core_Goal_Opportunities_at_Approval__c != null){
dwg.Core_Goal_Opportunities_at_Approval__c = dwg.Core_Goal_Opportunities_at_Approval__c+','+opp.Core_DWG_Opportunity__c;
}else{
dwg.Core_Goal_Opportunities_at_Approval__c = opp.Core_DWG_Opportunity__c;
}
}
}*/
                    //END - US103737 : DWG: Remove Old Relationship/Report Types - OOC WW29.4 -- Ashwin
                    recurrsiveCheck = true;
                }
                
                if((dwg.Core_Goal_Status__c != oldGoalMap.get(dwg.Id).Core_Goal_Status__c) && (((oldGoalMap.get(dwg.Id).Core_Goal_Status__c != Core_ACCEPTED) && (dwg.Core_Goal_Status__c == Core_ACCEPTED)) || ((dwg.Core_Goal_Status__c == Core_SUBMITTED) && (oldGoalMap.get(dwg.Id).Core_Goal_Status__c != Core_SUBMITTED))) && !recurrsiveCheck){    
                    dwg.Core_Goal_Opportunities_at_Approval__c = '';
                    dwg.Core_Goal_Approver__c = CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.ManagerId;
                    recurrsiveCheck = true;
                    //START - US101134 : Creating sharing rules for Opportunity and DWG records which are submitted -- Ashwin
                    if((dwg.Core_Goal_Status__c == Core_SUBMITTED) && (oldGoalMap.get(dwg.Id).Core_Goal_Status__c != Core_SUBMITTED)){
                        //START - US103737 : DWG: Remove Old Relationship/Report Types - OOC WW29.4 -- Ashwin
                        /*for(DWG_Opportunity__c opp : coreGoalMap.get(dwg.Id).Opportunities1__r){
if(opp.Core_DWG_Opportunity__r.OwnerId != CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.ManagerId){
if((CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.ManagerId != null) && opptyVsMgrMap.get(opp.Core_DWG_Opportunity__c) != null && !opptyVsMgrMap.get(opp.Core_DWG_Opportunity__c).contains(CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.ManagerId)){
opptyShareList.add(new OpportunityShare(UserOrGroupId=CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.ManagerId, OpportunityId=opp.Core_DWG_Opportunity__c, RowCause='Manual', OpportunityAccessLevel = 'Read'));
}
if((CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.Manager.DelegatedApproverId != null) && opptyVsMgrMap.get(opp.Core_DWG_Opportunity__c) != null && !opptyVsMgrMap.get(opp.Core_DWG_Opportunity__c).contains(CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.Manager.DelegatedApproverId)){
opptyShareList.add(new OpportunityShare(UserOrGroupId=CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.Manager.DelegatedApproverId, OpportunityId=opp.Core_DWG_Opportunity__c, RowCause='Manual', OpportunityAccessLevel = 'Read'));
}
}
}*/
                        //END - US103737 : DWG: Remove Old Relationship/Report Types - OOC WW29.4 -- Ashwin
                        if((CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.ManagerId != null) && dwg.OwnerId != CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.ManagerId && ((dwgVsMgrMap.get(dwg.Id) != null && !dwgVsMgrMap.get(dwg.Id).contains(CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.ManagerId)) || dwgVsMgrMap.isEmpty())){
                            goalShareList.add(new Core_Goal__Share(UserOrGroupId = CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.ManagerId,ParentId = dwg.Id, RowCause='Core_Deal_Win_Goal__c', AccessLevel = 'Edit'));
                        }
                        if((CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.Manager.DelegatedApproverId != null) && dwg.OwnerId != CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.Manager.DelegatedApproverId && ((dwgVsMgrMap.get(dwg.Id) != null && !dwgVsMgrMap.get(dwg.Id).contains(CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.Manager.DelegatedApproverId)) || dwgVsMgrMap.isEmpty())){
                            goalShareList.add(new Core_Goal__Share(UserOrGroupId = CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.Manager.DelegatedApproverId,ParentId = dwg.Id, RowCause='Core_Deal_Win_Goal__c', AccessLevel = 'Edit'));
                        }
                    }
                    //END - US101134 : Creating sharing rules for Opportunity and DWG records which are submitted -- Ashwin
                }               
            }           
        }
        system.debug('goalShareList====>'+goalShareList);
        system.debug('opptyShareList===>'+opptyShareList);
        if(!goalShareList.isEmpty()){
            try{
                insert goalShareList;
            }Catch(Exception e){
                for(Core_Goal__c dwg : newGoalList){
                    //US101134 : Added error message -- Ashwin
                    dwg.addError('Not able to submit for approval'+e.getMessage());
                }
            }
        }
        //START - US103737 : DWG: Remove Old Relationship/Report Types - OOC WW29.4 -- Ashwin
        /*if(!opptyShareList.isEmpty()){
try{
insert opptyShareList;
}Catch(Exception e){
for(Core_Goal__c dwg : newGoalList){
//US101134 : Added error message -- Ashwin
dwg.addError('Not able to submit for approval'+e.getMessage());
}
}
}*/
        //END - US103737 : DWG: Remove Old Relationship/Report Types - OOC WW29.4 -- Ashwin
    }
    
    
    /*
* Method name  : addCommissionableTransactions
* Description  : Adds new Commissionable Transaction entries for each an newly approved Goal moving to the
*                Approved state.  For Goals going from approved to not approved, inserts new Commissionable
*                Transaction entries corresponding to the previous approved entries, whose status is indicated
*                as not approved.
* Return Type  : VOID
* Parameters   : Trigger.Old, Trigger.oldMap, Trigger.New, Trigger.newMap, Trigger.isInsert, Trigger.isUpdate
*/
    
    /*public static void addCommissionableTransactions(List<Core_Goal__c> oldGoalList, Map<Id,Core_Goal__c> oldGoalMap,
                                                     List<Core_Goal__c> newGoalList, Map<Id,Core_Goal__c> newGoalMap,
                                                     Boolean isInsert, Boolean isUpdate)
    {
        System.debug('>>>>Entering ACT... continue? ' + alreadyAddedCommissionableTransactions);
        
        //Adding Share records for the newly created commissionable transactions (defect raised Credit data not visible to Sales Rep)-- Ashwin
        List<OpportunityShare> commissionShareList = new List<OpportunityShare>();
        if(!alreadyAddedCommissionableTransactions) {
            
            List<Core_Commissionable_Transaction__c> newTxns = new List<Core_Commissionable_Transaction__c>();
            
            //Set of all new approved goals that are changing to Win
            Set<Core_Goal__c> approvedGoals = new Set<Core_Goal__c>();
            // Map of all rejected goals
            Map<ID,Core_Goal__c> rejectedGoals = new Map<ID,Core_Goal__c>();
            
            for (Core_Goal__c g : newGoalList) {                
                System.debug('>>>>New StageName ' + g.Core_Goal_Status__c);
                System.debug('>>>>Old StageName ' + oldGoalMap.get(g.Id).Core_Goal_Status__c);
                
                // If this is an update trigger, new stage is Win and (prior status was not Win, Production Win, Production Lost, or Production Cancelled)
                if 
                    (g.Core_Goal_Status__c != null &&
                     (
                         (isUpdate && (g.Core_Goal_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Goal_Approved_Status)) 
                         && 
                         !(
                             (oldGoalMap.get(g.Id).Core_Goal_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Goal_Approved_Status) 
                         )
                     )
                    ) 
                {                    
                    //Add this opportunity product to set of all newly approved, commissionable opportunity products
                    System.debug('>>>> Adding approved Goals; new stage name: ' + g.Core_Goal_Status__c);
                    approvedGoals.add(g);                       
                    alreadyAddedCommissionableTransactions = true;
                }
                
                //Else if this is an update trigger, new status is not approved, and prior status was approved
                else if 
                    (
                        isUpdate 
                        && 
                        (g.Core_Goal_Status__c != null &&(
                            !(
                                (g.Core_Goal_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Goal_Approved_Status) 
                            ) 
                            && 
                            (
                                (oldGoalMap.get(g.Id).Core_Goal_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Goal_Approved_Status) 
                            ) 
                        )
                        )
                    )
                {
                    //Add this opportunity product to map of rejected opportunity products
                    System.debug('>>>> Adding rejected Goals ' );
                    rejectedGoals.put(g.ID, g);             
                    alreadyAddedCommissionableTransactions = true;
                }                        
            }
            system.debug('approvedGoals!!!!!!!!!!!!!! '+approvedGoals);
            system.debug('rejectedGoals@@@@@@@@@@@@@@@@ '+rejectedGoals);
            //Handle rejections ---------------------------------------------
            //Get a list of commissionableTxns associated with every rejected Goal 
            List<Core_Commissionable_Transaction__c> txnList = [
                SELECT Core_Account_ID__c,Core_Account_Name__c,Core_Approved_Total_Price__c,Core_CIM_ID__c,Core_Claim_Date__c,
                Core_Employee_ID__c,Core_Employee_Name__c,Core_Goal__c,Core_Last_Approved_Date__c,
                Core_Milestone_Area__c,Core_Milestone_Focus__c,Core_Milestone_ID__c,Core_Milestone__c,Core_Opportunity_Name__c,
                Core_Opportunity_Team_Member_Role__c,Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,
                Core_Product2_ID__c,Core_Product_Type__c,Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,
                Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
                FROM Core_Commissionable_Transaction__c
                WHERE Core_Source_ID__c in :rejectedGoals.keySet()
            ];
            system.debug('txnList---'+txnList);
            Map<ID,DateTime> rejectedGoalMostRecentTimestamp = new Map<ID,DateTime>();
            List<Core_Commissionable_Transaction__c> rejectedTransactions = new List<Core_Commissionable_Transaction__c>();
            
            for (ID rejectedGoal : rejectedGoals.keySet()) {
                //Find the most recent timestamp in the list of transactions for this Goal
                DateTime mostRecentTimestamp = DateTime.newInstanceGMT(2000, 1, 1, 12, 0, 0);
                for (Core_Commissionable_Transaction__c ct : txnList) {
                    if (ct.Core_Source_ID__c == rejectedGoal && ct.Core_Transaction_Timestamp__c > mostRecentTimestamp)
                        mostRecentTimestamp = ct.Core_Transaction_Timestamp__c;
                }                
                //Iterate again through the list of transactions to get all transactions matching this Goal and timestamp, 
                // and add to list of rejected transactions
                for (Core_Commissionable_Transaction__c ct : txnList) {
                    if (ct.Core_Source_ID__c == rejectedGoal && ct.Core_Transaction_Timestamp__c == mostRecentTimestamp)
                        rejectedTransactions.add(ct);
                }
            }
            Set<Id> rejectedGoalIdSet = new Set<Id>();
            //Iterate through the set, replacing the Transaction Timestamp with current time, and set status to specified rejected status (or current status).
            //(If no match was found, do nothing)
            for (Core_Commissionable_Transaction__c rejectedTransaction : rejectedTransactions) {
                rejectedTransaction.Core_Transaction_Timestamp__c = System.now();
                if (Label.Core_Commissionable_Transaction_Goal_Rejected_Status != 'Actual Goal Stage Value')
                    rejectedTransaction.Core_Status__c = Label.Core_Commissionable_Transaction_Goal_Rejected_Status;
                else
                    rejectedTransaction.Core_Status__c = rejectedGoals.get(rejectedTransaction.Core_Source_ID__c).Core_Goal_Status__c;
                rejectedTransaction.Id = null;
                //Add the modified transaction to newTxn
                rejectedGoalIdSet.add(rejectedTransaction.Core_Source_ID__c);
                newTxns.add(rejectedTransaction);
            }
            
            //Handle approvals ---------------------------------------------
            
            //Iterate through set of Goals changing to "approved", generate a set of Owner IDs
            Set<ID> goalIDs = new Set<ID>();
            Set<ID> goalOwners = new Set<ID>();
            Map<Id, Id> goalIdvsApproverIdMap = new Map<Id, Id>();
            Set<String> oppIdSet = new Set<String>();
            for (Core_Goal__c approvedGoal : approvedGoals) {
                system.debug('Approved Goal at # 533---'+approvedGoal);
                goalIDs.add(approvedGoal.ID);
                goalOwners.add(approvedGoal.OwnerId);
                goalIdvsApproverIdMap.put(approvedGoal.Id, approvedGoal.Core_Goal_Approver__c);
                oppIdSet.add(approvedGoal.Core_Opportunity__c);
                System.debug('oppIdSet' + oppIdSet);
            }
            
            Map<String,String> kpiNameKpiTypeMap = new Map<String,String>();
            if(!oppIdSet.isEmpty()){
                List<Core_Oppty_KPI_New__c> oppKpiList = [select Id, Name, Core_Opp_KPI_Type__c, Core_KPI_Opportunity__c from Core_Oppty_KPI_New__c where Core_KPI_Opportunity__c IN: oppIdSet AND Core_IsActive__c = true];
                for(Core_Oppty_KPI_New__c oppKpi : oppKpiList){
                    kpiNameKpiTypeMap.put(oppKpi.Name,oppKpi.Core_Opp_KPI_Type__c);
                    system.debug('kpiNameKpiTypeMap---'+kpiNameKpiTypeMap);
                }
            }
            
            if(newTxns != null && !newTxns.isEmpty()){
                List<Core_Goal__c> goalApproverList = [SELECT id, Core_Goal_Approver__c FROM Core_Goal__c WHERE id IN : rejectedGoalIdSet];
                for (Core_Goal__c appGoal : goalApproverList) {
                    goalIdvsApproverIdMap.put(appGoal.Id, appGoal.Core_Goal_Approver__c);
                    system.debug('goalIdvsApproverIdMap---'+goalIdvsApproverIdMap);
                }
            }
            
            //Generate user data associated with the Goal Owner (Name, WWID)
            Map<ID, User> users = new Map<ID, User>();
            for (User user: [SELECT u.ID, u.Name, u.Core_WWID__c, u.Core_Employee_Type_Code__c FROM User u WHERE u.ID in :goalOwners] )
                users.put(user.ID, user);
            system.debug('users----'+users);
            Core_Commissionable_Transaction__c txn;
            Core_Commissionable_Transaction__c gTxn;
            List<Core_Opp_KPI_History__c> oppKpiHisList = new List<Core_Opp_KPI_History__c>(); //US862235: KTBR: Preventive solution for Deal Revenue Sent as Count
            
            //Iterate through the approvedGoal set
            for (Core_Goal__c approvedGoal : approvedGoals) { 
                Core_Opp_KPI_History__c oppKpiHistory = new Core_Opp_KPI_History__c(); //US862235: KTBR: Preventive solution for Deal Revenue Sent as Count
                gTxn = new Core_Commissionable_Transaction__c();
                
                //Use maps to collate transaction attributes above the user level        
                gTxn.Core_Source_ID__c = approvedGoal.Id;
                gTxn.Core_Goal__c = approvedGoal.Id;
                //Insert a string to the Milestone field to facilitate iPaaS inserting a quantity of 1.0 enroute to Callidus
                gTxn.Core_Milestone__c = approvedGoal.Core_Goal_Name__c;
                gTxn.Core_Milestone_Focus__c = approvedGoal.Core_Goal_Category__c;
                gTxn.Core_Milestone_Area__c = approvedGoal.Core_Goal_BU_Focus_Area__c;
                gTxn.Core_Transaction_Timestamp__c = System.now();   
                system.debug('gTxn at #579--'+gTxn);
                if(approvedGoal.Core_Goal_Claim_Date__c != null)
                    gTxn.Core_Claim_Date__c = approvedGoal.Core_Goal_Claim_Date__c;
                
                if(approvedGoal.Core_Goal_Approved_Date__c == null)
                {
                    //when a goal is newly approved, the approved date may get populated after this handler runs
                    gTxn.Core_Last_Approved_Date__c = System.now().date();
                }                
                else
                {
                    //in case of manual data updates, this code may need to run instead
                    gTxn.Core_Last_Approved_Date__c = date.newinstance(approvedGoal.Core_Goal_Approved_Date__c.year(), approvedGoal.Core_Goal_Approved_Date__c.month(), approvedGoal.Core_Goal_Approved_Date__c.day());
                }
                //CTs have a master-detail relationship with Opportunity, so inserting a placeholder opportunity
                gTxn.Core_Opportunity__c = Label.Core_Commissionable_Transaction_Goal_Placeholder_Opportunity;
                
                //This will always be approved
                gTxn.Core_Status__c = Label.Core_Commissionable_Transaction_Approved_Status;
                
                //Get Transaction Type via custom setting
                if(kpiNameKpiTypeMap.containskey(approvedGoal.Core_Goal_BU_Focus_Area__c) && kpiNameKpiTypeMap.get(approvedGoal.Core_Goal_BU_Focus_Area__c) == 'Salesforce Pipeline $'){
                    gTxn.Core_Transaction_Type__c = Core_Commissionable_Transaction_Type__c.getInstance('Revenue KPI Goal').Core_Commissionable_Transaction_Type__c;
                    system.debug('gTxv at # 602---'+gTxn.Core_Transaction_Type__c);
                }else{
                    gTxn.Core_Transaction_Type__c = Core_Commissionable_Transaction_Type__c.getInstance('Any Goal Except Revenue KPI').Core_Commissionable_Transaction_Type__c;
                    system.debug('gTxv at # 605---'+gTxn.Core_Transaction_Type__c);
                    //US862235: KTBR: Preventive solution for Deal Revenue Sent as Count
                    //insert opp KPI History record-->Core_Opp_KPI_History__c
                    oppKpiHistory.Core_Opp_KPI_Opportunity_Name__c = approvedGoal.Core_Opportunity__c;
                    oppKpiHistory.Core_KPI_Name__c = approvedGoal.Core_Goal_BU_Focus_Area__c;
                    oppKpiHistory.Core_Opp_KPI_Type__c = kpiNameKpiTypeMap.get(approvedGoal.Core_Goal_BU_Focus_Area__c);
                    oppKpiHisList.add(oppKpiHistory);  
                    system.debug('oppKpiHisList at #612-------'+oppKpiHisList);
                }
                system.debug('gTxn_Core_Transaction_Type__c at # 612--'+gTxn.Core_Transaction_Type__c);
                system.debug('oppKpiHisList at #615-------'+oppKpiHisList);
                //Get Percent Contribution via custom setting
                gTxn.Core_Percent_Contribution__c = Core_Commissions_Percent_Contribution__c.getInstance('Goal Owner').Core_Percent_Contribution__c;
                
                gTxn.Core_WWID__c = users.get(approvedGoal.OwnerId).Core_WWID__c;
                gTxn.Core_Employee_ID__c = approvedGoal.OwnerId;
                gTxn.Core_Employee_Name__c = users.get(approvedGoal.OwnerId).Name;
                system.debug('approvedGoal at #623---'+approvedGoal);
                
                
                if(approvedGoal.Core_KPI_Revenue__c <> null && approvedGoal.Core_KPI_Revenue__c > 0){
                    gTxn.Core_Approved_Total_Price__c = approvedGoal.Core_KPI_Revenue__c;
                }else{
                    gTxn.Core_Approved_Total_Price__c = 0;
                   } 
                system.debug('approvedGoal at #623---'+gTxn);
                system.debug('approvedGoal at #624---'+gTxn.Core_Approved_Total_Price__c);
               
                 
                // Add to commissions only if the goal owner is Employee 
                if (users.get(approvedGoal.OwnerId).Core_Employee_Type_Code__c == 'EMP') 
                    newTxns.add(gTxn); 
                system.debug('############# '+gTxn);
            }
            system.debug('$$$$$$$$$$$$$$$$ '+newTxns);
        try{
            insert newTxns;
            insert oppKpiHisList;
        }catch(Exception e){
            system.debug('^^^^^^^^^^^^^^^ '+e.getStackTraceString());
            system.debug('&&&&&&&&&&&&&&& '+e.getLineNumber());
        }
            
            for(Core_Commissionable_Transaction__c cTxns : newTxns){
                commissionShareList.add(new OpportunityShare(UserOrGroupId=cTxns.Core_Employee_ID__c, OpportunityId=Label.Core_Commissionable_Transaction_Goal_Placeholder_Opportunity, RowCause='Manual', OpportunityAccessLevel = 'Read'));
                if(goalIdvsApproverIdMap.get(cTxns.Core_Source_ID__c) != null){
                    system.debug('goalIdvsApproverIdMap---'+goalIdvsApproverIdMap);
                    commissionShareList.add(new OpportunityShare(UserOrGroupId=goalIdvsApproverIdMap.get(cTxns.Core_Source_ID__c), OpportunityId=Label.Core_Commissionable_Transaction_Goal_Placeholder_Opportunity, RowCause='Manual', OpportunityAccessLevel = 'Read'));
                }
            }
            
            try{
                system.debug('commissionShareList%%%%%%%%%%%%% '+commissionShareList);
                insert commissionShareList;
            }Catch(Exception e){
                system.debug('exception at 661 --'+e.getMessage()+' '+e.getLineNumber());
                //system.debug('exception line at 662--'+e.getLineNumber()); 
                for(Core_Goal__c dwg : newGoalList){
                    
                    dwg.addError('ERROR: Could not insert the sharing of Commissionable Transaction for Approver - '+e.getMessage());
                }
            }
            
        }
    }*/
    
    //Commented due to new commission logic  moved to Opp trigger
    public static void createCommissionableTransactions(List<Core_Goal__c> newList, Map<Id, Core_Goal__c> oldMap){
        if(!alreadyAddedCommissionableTransactions){
            alreadyAddedCommissionableTransactions = true;
            List<Core_Commissionable_Transaction__c> commissionList = new List<Core_Commissionable_Transaction__c>();
            Core_Commissionable_Transaction__c tempCommission;
            List<Core_Goal__c> approvedGoalList = new List<Core_Goal__c>();
            Map<Id, Core_Goal__c> recalledGoalMap = new Map<Id, Core_Goal__c>();
            Set<String> goalOwnerIds = new Set<String>();
            Map<String, String> goalIdApproverIdMap = new Map<String, String>();
            for(Core_Goal__c goal : newList){
                if(goal.Core_Goal_Status__c == 'Approved' && oldMap.get(goal.Id).Core_Goal_Status__c <> 'Approved'){
                    approvedGoalList.add(goal);
                    goalOwnerIds.add(goal.OwnerId);
                    goalIdApproverIdMap.put(goal.Id, goal.Core_Goal_Approver__c);
                }else if(goal.Core_Goal_Status__c <> 'Approved' && oldMap.get(goal.Id).Core_Goal_Status__c == 'Approved'){
                    recalledGoalMap.put(goal.Id, goal);
                    goalIdApproverIdMap.put(goal.Id, goal.Core_Goal_Approver__c);
                }
            }
            
            if(!approvedGoalList.isEmpty()){
                Map<Id, User> goalOwnersMap = new Map<Id, User>([SELECT Id, Name, Core_WWID__c, Core_Employee_Type_Code__c FROM User WHERE Id IN: goalOwnerIds]);
                for(Core_Goal__c approvedGoal : approvedGoalList){
                    if(goalOwnersMap.containsKey(approvedGoal.OwnerId)){
                        system.debug('approvedGoal '+approvedGoal.Core_Goal_BU_Focus_Area__c);
                        tempCommission = new Core_Commissionable_Transaction__c();
                        tempCommission.Core_Source_ID__c = approvedGoal.Id;
                        tempCommission.Core_Goal__c = approvedGoal.Id;
                        tempCommission.Core_Milestone__c = approvedGoal.Core_Goal_Name__c;
                        tempCommission.Core_Milestone_Focus__c = approvedGoal.Core_Goal_Category__c;
                        tempCommission.Core_Milestone_Area__c = approvedGoal.Core_Goal_BU_Focus_Area__c;
                        tempCommission.Core_Transaction_Timestamp__c = System.now();
                        
                        if(approvedGoal.Core_Goal_Claim_Date__c != null){
                            tempCommission.Core_Claim_Date__c = approvedGoal.Core_Goal_Claim_Date__c;
                        }
                        
                        if(approvedGoal.Core_Goal_Approved_Date__c == null){
                            //when a goal is newly approved, the approved date may get populated after this handler runs
                            tempCommission.Core_Last_Approved_Date__c = System.now().date();
                        }else{
                            //in case of manual data updates, this code may need to run instead
                            tempCommission.Core_Last_Approved_Date__c = date.newinstance(approvedGoal.Core_Goal_Approved_Date__c.year(), approvedGoal.Core_Goal_Approved_Date__c.month(), approvedGoal.Core_Goal_Approved_Date__c.day());
                        }
                        
                        tempCommission.Core_Opportunity__c = Label.Core_Commissionable_Transaction_Goal_Placeholder_Opportunity;
                        //This will always be approved
                        tempCommission.Core_Status__c = Label.Core_Commissionable_Transaction_Approved_Status;
                        
                        if(approvedGoal.Core_Goal_BU_Focus_Area__c.contains('$')){
                            tempCommission.Core_Transaction_Type__c = Core_Commissionable_Transaction_Type__c.getInstance('Revenue KPI Goal').Core_Commissionable_Transaction_Type__c;
                        }else{
                            tempCommission.Core_Transaction_Type__c = Core_Commissionable_Transaction_Type__c.getInstance('Any Goal Except Revenue KPI').Core_Commissionable_Transaction_Type__c;
                        }
                        
                        tempCommission.Core_Percent_Contribution__c = Core_Commissions_Percent_Contribution__c.getInstance('Goal Owner').Core_Percent_Contribution__c;
                        tempCommission.Core_WWID__c = goalOwnersMap.get(approvedGoal.OwnerId).Core_WWID__c;
                        tempCommission.Core_Employee_ID__c = approvedGoal.OwnerId;
                        tempCommission.Core_Employee_Name__c = goalOwnersMap.get(approvedGoal.OwnerId).Name;
                        
                        if(approvedGoal.Core_KPI_Revenue__c <> null && approvedGoal.Core_KPI_Revenue__c > 0){
                            tempCommission.Core_Approved_Total_Price__c = approvedGoal.Core_KPI_Revenue__c;
                        }else{
                            tempCommission.Core_Approved_Total_Price__c = 0;
                        }
                        
                        if(goalOwnersMap.get(approvedGoal.OwnerId).Core_Employee_Type_Code__c == 'EMP'){
                            commissionList.add(tempCommission);
                        }
                    }
                }
                system.debug('commissionList '+commissionList.size());
            }
            
            if(!recalledGoalMap.isEmpty()){
                List<Core_Commissionable_Transaction__c> transList = [
                    SELECT Core_Account_ID__c,Core_Account_Name__c,Core_Approved_Total_Price__c,Core_CIM_ID__c,Core_Claim_Date__c, Core_Employee_ID__c,Core_Employee_Name__c,Core_Goal__c,Core_Last_Approved_Date__c,
                    Core_Milestone_Area__c,Core_Milestone_Focus__c,Core_Milestone_ID__c,Core_Milestone__c,Core_Opportunity_Name__c, Core_Opportunity_Team_Member_Role__c,Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,
                    Core_Product2_ID__c,Core_Product_Type__c,Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c, Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
                    FROM Core_Commissionable_Transaction__c WHERE Core_Source_ID__c IN: recalledGoalMap.keySet() order by createdDate desc];
                
                if(!transList.isEmpty() && transList[0].Core_Status__c.equalsIgnoreCase(Label.Core_Commissionable_Transaction_Approved_Status)){
                    for(Integer i = 0; i<transList.size(); i++){
                        if(transList[i].Core_Status__c.equalsIgnoreCase(Label.Core_Commissionable_Transaction_Approved_Status)){
                            tempCommission = new Core_Commissionable_Transaction__c();
                            tempCommission = transList[i].clone();
                            if (Label.Core_Commissionable_Transaction_Goal_Rejected_Status != 'Actual Goal Stage Value'){
                                tempCommission.Core_Status__c = Label.Core_Commissionable_Transaction_Goal_Rejected_Status;
                            }else{
                                tempCommission.Core_Status__c = recalledGoalMap.get(transList[i].Core_Source_ID__c).Core_Goal_Status__c;
                            }
                            tempCommission.Core_Transaction_Timestamp__c = System.now();
                            commissionList.add(tempCommission);
                        }else{
                            i = transList.size();
                        }
                    }
                }
            }
            
            if(!commissionList.isEmpty()){
                try{
                    system.debug('commissionList before insert '+commissionList.size());
                    insert commissionList;
                    List<OpportunityShare> oppShareList = new List<OpportunityShare>();
                    for(Core_Commissionable_Transaction__c cTxns : commissionList){
                        if(goalIdApproverIdMap.containsKey(cTxns.Core_Source_ID__c)){
                            oppShareList.add(new OpportunityShare(UserOrGroupId=goalIdApproverIdMap.get(cTxns.Core_Source_ID__c), OpportunityId=Label.Core_Commissionable_Transaction_Goal_Placeholder_Opportunity, RowCause='Manual', OpportunityAccessLevel = 'Read'));
                        }
                    }
                    
                    system.debug('oppShareList%%%%%%%%%%%%% '+oppShareList);
                    insert oppShareList;
                }Catch(Exception e){
                    system.debug('exception '+e.getMessage()+' '+e.getLineNumber());
                    for(Core_Goal__c dwg : newList){
                        dwg.addError('ERROR: Could not insert the sharing of Commissionable Transaction for Approver - '+e.getMessage());
                    }
                }
            }
        }
    }
    
    /*
    * Method name  : removeSplCharacterinDWGName
    * Description  : removes the special characters in the DWG Name.
    * Return Type  : VOID
    * Parameters   : Trigger.oldMap, Trigger.New, Trigger.isInsert, Trigger.isUpdate
    */
        
    public static void removeSplCharacterinDWGName(Map<Id,Core_Goal__c> oldGoalMap, List<Core_Goal__c> newGoalList, Boolean isInsert, Boolean isUpdate){  
        for(Core_Goal__c goal : newGoalList){
            String tabString = '    ';
            //Tab Space and More Spaces are removed if the DWG name is having tab and more spaces in it while updating
            if(isUpdate){
                if(goal.Name!= oldGoalMap.get(goal.Id).Name){
                    String goalName = goal.Name.replaceAll('\\t+', ';');
                    goal.Name = goalName.replaceAll( ';', ' ');                  
                    if(goal.Name.contains(' ')){
                        String goalNameSpc = goal.Name.replaceAll( '\\s+', ';');
                        goal.Name = goalNameSpc.replaceAll( ';', ' ');
                    } 
                }              
            } 
            //Tab Space and More Spaces are removed if the DWG name is having tab and more spaces in it while inserting
            else if(isInsert){
                String goalName = goal.Name.replaceAll('\\t+', ';');
                goal.Name = goalName.replaceAll( ';', ' ');  
                if(goal.Name.contains(' ')){
                    String goalNameSpc = goal.Name.replaceAll( '\\s+', ';');
                    goal.Name = goalNameSpc.replaceAll( ';', ' ');
                }    
            }  
        }                                                 
    }
    
    /*
    * Method name  : sendNotificationonChangeofMatchOppKPI
    * Description  : sends mail if their is change in the value of Match Opportunity KPI field value.
    * Return Type  : VOID
    * Parameters   : Trigger.New
    */    
    /*public static void sendNotificationonChangeofMatchOppKPI(List<Core_Goal__c> newGoalList, Map<Id, Core_Goal__c> oldGoalMap){
        List<Core_Goal__c> finalDWGList = new List<Core_Goal__c>();
        Date lastYearDate = Date.newInstance(2021,12,31);
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail;
        String finalEmailTemplateId;
        for(Core_Goal__c goal : newGoalList){
            if(goal.Core_MatchOppKPI_2ndPrev_Backend__c <> null && goal.Core_MatchOppKPI_Backend__c <> null && goal.Core_MatchOppKPI_Backend__c <> oldGoalMap.get(goal.Id).Core_MatchOppKPI_Backend__c){
                boolean isNotify = false;
                System.debug('Hey I am inside '+goal.Core_MatchOppKPI_Backend__c +'     '+oldGoalMap.get(goal.Id).Core_MatchOppKPI_Backend__c);
                List<String> userIdList = new List<String>();
                userIdList.add(goal.OwnerId);
                if(goal.Core_MatchOppKPI_Backend__c == 'KPI Achieved' && goal.Core_MatchOppKPI_2ndPrev_Backend__c <> 'KPI Achieved'){
                    finalEmailTemplateId = emailKPIAchievedTemplate.Id;
                    isNotify = true;
                }
                else if(goal.Core_MatchOppKPI_Backend__c == 'KPI Not Achieved' && goal.Core_MatchOppKPI_2ndPrev_Backend__c == 'KPI Achieved' && goal.Core_Goal_Claim_Date__c > lastYearDate){
                    finalEmailTemplateId = emailNoLongerAchievedTemplate.Id;
                    if(goal.Core_Goal_Status__c == 'Approved'){
                        userIdList.add(goal.Core_Goal_Approver__c);
                    }
                    isNotify = true;
                }
                if(isNotify){
                    for(String u :userIdList){
                        mail = Messaging.renderStoredEmailTemplate(finalEmailTemplateId, u, goal.Id);
                        mail.setTargetObjectId(u);
                        mail.setSaveAsActivity(false);
                        mail.setOrgWideEmailAddressId(System.Label.Core_SetFromEmailAddress);
                        mailList.add(mail);
                    }
                }
                
                finalDWGList.add(goal);
            }
        }
        if(!mailList.isEmpty()){
            Messaging.sendEmail(mailList);
        }
        
        for(Core_Goal__c goal : finalDWGList){
            goal.Core_MatchOppKPI_Prev_Backend__c = null;
            goal.Core_MatchOppKPI_2ndPrev_Backend__c = null;
        }
    }*/

}