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
    public static Map<String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    
     //START: US176263 : SMG 2019: DWG- Update DWG Logic for 2019 [Production Deployment WW04.3]  -- Ashwin
    /*
    * Method name  : updateGoalforKPIChange
    * Description  : This Method is used to update the KPI Flags on DWG if the KPI Name is matched or KPI achieved on Oppty KPI .
    * Return Type  : void
    * Parameter    : (list<Core_Goal__c> newGoalList, Map<Id, Core_Goal__c> oldGoalMap).
    */ 
    public static void updateGoalforKPIChange(List<Core_Goal__c> newGoalList, Map<Id, Core_Goal__c> oldGoalMap){  
        Set<Id> opptyIdKPIIdSet = new Set<Id>();
        Map<Id, List<Core_Opportunity_KPI__c>> opptyKPIMap = new Map<Id, List<Core_Opportunity_KPI__c>>();
        
        //populating the set with related Opportunity Ids to query for the Oppty KPIs
        for(Core_Goal__c dwg : newGoalList){
            opptyIdKPIIdSet.add(dwg.Core_Opportunity__c);
        }
        if(!kpiRecurrCheck){            
			for(Core_Opportunity_KPI__c oppKPI : [SELECT id, name, Core_Opp_KPI_Achieved__c, Core_Opp_KPI_Threshold_Met__c, Core_Opp_KPI_Opportunity__c FROM Core_Opportunity_KPI__c WHERE Core_Opp_KPI_Opportunity__c IN :opptyIdKPIIdSet]){
				List<Core_Opportunity_KPI__c> tempList = new List<Core_Opportunity_KPI__c>();
				if(opptyKPIMap.get(oppKPI.Core_Opp_KPI_Opportunity__c) != null){
					tempList = opptyKPIMap.get(oppKPI.Core_Opp_KPI_Opportunity__c);
					tempList.add(oppKPI);
					opptyKPIMap.put(oppKPI.Core_Opp_KPI_Opportunity__c, tempList);
				}else{
					tempList.add(oppKPI);
					opptyKPIMap.put(oppKPI.Core_Opp_KPI_Opportunity__c, tempList);
				}
			}
			
			for(Core_Goal__c dwg : newGoalList){
				if(oldGoalMap == null || oldGoalMap.isEmpty()){
                    System.debug('***Insert DWG**');
					if(dwg.Core_Opportunity__c != null && opptyKPIMap.get(dwg.Core_Opportunity__c) != null){
						integer count = 0;
						for(Core_Opportunity_KPI__c kpi : opptyKPIMap.get(dwg.Core_Opportunity__c)){                        
							if(dwg.Core_Goal_BU_Focus_Area__c == kpi.name){
								dwg.Core_Goal_KPI_Match_Flag__c = true;
								count++;
							}
							if(dwg.Core_Goal_BU_Focus_Area__c == kpi.name && kpi.Core_Opp_KPI_Achieved__c){
								dwg.Core_Goal_KPI_Achieved_Flag__c = true;
								count++;
							}
							if(count>0){                            
								break;
							}
						}
					}
				}else if(dwg.Core_Opportunity__c != null && (oldGoalMap.get(dwg.Id).Core_Opportunity__c != dwg.Core_Opportunity__c || oldGoalMap.get(dwg.Id).Core_Goal_BU_Focus_Area__c != dwg.Core_Goal_BU_Focus_Area__c) && opptyKPIMap.get(dwg.Core_Opportunity__c) != null){
					System.debug('***Entering update of DWG For KPI***');
					for(Core_Opportunity_KPI__c kpi : opptyKPIMap.get(dwg.Core_Opportunity__c)){
                        integer count1 = 0;
						if(dwg.Core_Goal_BU_Focus_Area__c == kpi.name){
							dwg.Core_Goal_KPI_Match_Flag__c = true;
                            count1++;
						}else{
							dwg.Core_Goal_KPI_Match_Flag__c = false;
							dwg.Core_Goal_KPI_Achieved_Flag__c = false;
						}
						if(dwg.Core_Goal_BU_Focus_Area__c == kpi.name && kpi.Core_Opp_KPI_Achieved__c){
							dwg.Core_Goal_KPI_Achieved_Flag__c = true;
                            count1++;
						}
                        if(count1>0){                            
                            break;
                        }
                    }             
				}else if(opptyKPIMap.get(dwg.Core_Opportunity__c) == null && !Core_Opp_KPI_Handler.isKPIInsert){
                    dwg.Core_Goal_KPI_Match_Flag__c = false;
                    dwg.Core_Goal_KPI_Achieved_Flag__c = false;
                }   
			} 
            kpiRecurrCheck = true;
		}		
    }
    //END US176263 : SMG 2019: DWG- Update DWG Logic for 2019 [Production Deployment WW04.3]  -- Ashwin
    
    
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
                if(!pickSet.contains(so.Core_Goal_BU_Focus_Area__c) && (((so.Core_Goal_Status__c == 'Accepted' || so.Core_Goal_Status__c == 'Submitted' || so.Core_Goal_Status__c == 'Draft') && oldGoal.Core_Goal_Status__c != 'Submitted' && oldGoal.Core_Goal_Status__c != 'Approved'))
                  ){
                    so.Core_Goal_BU_Focus_Area__c.addError(System.Label.DWG_KPI_PicklistError);
                }                
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
        if(mapFunctionalityNameTriggerExecution != null && !mapFunctionalityNameTriggerExecution.isEmpty() && mapFunctionalityNameTriggerExecution.containsKey('restrictInactivePicklist') && mapFunctionalityNameTriggerExecution.get('restrictInactivePicklist').Core_Active__c){
            restrictBadPicklistValues('Core_Goal__c', 'Core_Goal_BU_Focus_Area__c', newGoalList, oldGoalMap);
        }
        
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
    
    public static void addCommissionableTransactions(List<Core_Goal__c> oldGoalList, Map<Id,Core_Goal__c> oldGoalMap,
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
            
            for (Core_Goal__c approvedGoal : approvedGoals) {
                goalIDs.add(approvedGoal.ID);
                goalOwners.add(approvedGoal.OwnerId);
                goalIdvsApproverIdMap.put(approvedGoal.Id, approvedGoal.Core_Goal_Approver__c);
                //System.debug('goalID:' + approvedGoal.ID);
            }
            if(newTxns != null && !newTxns.isEmpty()){
                List<Core_Goal__c> goalApproverList = [SELECT id, Core_Goal_Approver__c FROM Core_Goal__c WHERE id IN : rejectedGoalIdSet];
                for (Core_Goal__c appGoal : goalApproverList) {
                    goalIdvsApproverIdMap.put(appGoal.Id, appGoal.Core_Goal_Approver__c);
                }
            }
            
            //Generate user data associated with the Goal Owner (Name, WWID)
            Map<ID, User> users = new Map<ID, User>();
            for (User user: [SELECT u.ID, u.Name, u.Core_WWID__c, u.Core_Employee_Type_Code__c FROM User u WHERE u.ID in :goalOwners] )
                users.put(user.ID, user);
            
            Core_Commissionable_Transaction__c txn;
            Core_Commissionable_Transaction__c gTxn;
            
            //Iterate through the approvedGoal set
            for (Core_Goal__c approvedGoal : approvedGoals) {        
                gTxn = new Core_Commissionable_Transaction__c();
                
                //Use maps to collate transaction attributes above the user level        
                gTxn.Core_Source_ID__c = approvedGoal.Id;
                gTxn.Core_Goal__c = approvedGoal.Id;
                //Insert a string to the Milestone field to facilitate iPaaS inserting a quantity of 1.0 enroute to Callidus
                gTxn.Core_Milestone__c = approvedGoal.Core_Goal_Name__c;
                gTxn.Core_Milestone_Focus__c = approvedGoal.Core_Goal_Category__c;
                gTxn.Core_Milestone_Area__c = approvedGoal.Core_Goal_BU_Focus_Area__c;
                gTxn.Core_Transaction_Timestamp__c = System.now();               
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
                gTxn.Core_Transaction_Type__c = Core_Commissionable_Transaction_Type__c.getInstance('Any Goal').Core_Commissionable_Transaction_Type__c;
                
                //Get Percent Contribution via custom setting
                gTxn.Core_Percent_Contribution__c = Core_Commissions_Percent_Contribution__c.getInstance('Goal Owner').Core_Percent_Contribution__c;
                
                gTxn.Core_WWID__c = users.get(approvedGoal.OwnerId).Core_WWID__c;
                gTxn.Core_Employee_ID__c = approvedGoal.OwnerId;
                gTxn.Core_Employee_Name__c = users.get(approvedGoal.OwnerId).Name;
                
                // Add to commissions only if the goal owner is Employee 
                if (users.get(approvedGoal.OwnerId).Core_Employee_Type_Code__c == 'EMP') 
                    newTxns.add(gTxn);               
            }
            insert newTxns;
            for(Core_Commissionable_Transaction__c cTxns : newTxns){
                commissionShareList.add(new OpportunityShare(UserOrGroupId=cTxns.Core_Employee_ID__c, OpportunityId=Label.Core_Commissionable_Transaction_Goal_Placeholder_Opportunity, RowCause='Manual', OpportunityAccessLevel = 'Read'));
                if(goalIdvsApproverIdMap.get(cTxns.Core_Source_ID__c) != null){
                    commissionShareList.add(new OpportunityShare(UserOrGroupId=goalIdvsApproverIdMap.get(cTxns.Core_Source_ID__c), OpportunityId=Label.Core_Commissionable_Transaction_Goal_Placeholder_Opportunity, RowCause='Manual', OpportunityAccessLevel = 'Read'));
                }
            }
            
            try{
                insert commissionShareList;
            }Catch(Exception e){
                for(Core_Goal__c dwg : newGoalList){
                    dwg.addError('ERROR: Could not insert the sharing of Commissionable Transaction for Approver - '+e.getMessage());
                }
            }
            
        }
    }
}