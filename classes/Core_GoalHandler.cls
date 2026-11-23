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
*****************************************************************************************************************************************************************************************************/



public class Core_GoalHandler {
    // Make sure we only execute Commissionable Transactions functionality once
    public static Boolean alreadyAddedCommissionableTransactions = false;
    public static final string Core_ACCEPTED = 'Accepted';
    public static final String Core_SUBMITTED = 'Submitted';
    public static final String Core_APPROVED = 'Approved';
    public static boolean recurrsiveCheck = false;
    
    //US83097 - Added method to update Accepted Date -- Ashwin
    /*
    * Method name  : updateaGoalonApproval
    * Description  : This Method is used to update opportunities at approval and other fields post approval action  .
    * Return Type  : void
    * Parameter    : (list<Core_Goal__c> newGoalList, Map<Id, Core_Goal__c> oldGoalMap).
    */ 
    public static void updateGoalonApproval(List<Core_Goal__c> newGoalList, Map<Id, Core_Goal__c> oldGoalMap){
        Map<Id,Core_Goal__c> coreGoalMap = new Map<Id, Core_Goal__c>([SELECT id, Core_Goal_Status__c, Core_Goal_Opportunities_at_Approval__c, Core_Goal_Owner__r.ManagerId, (SELECT id, Name, OwnerId FROM Opportunities__r) FROM Core_Goal__c WHERE Id IN :oldGoalMap.keySet()]);
        List<Core_Goal__Share> goalShareList = new List<Core_Goal__Share>();
        List<OpportunityShare> opptyShareList = new List<OpportunityShare>();
        Set<Id> opptyIdSet = new Set<Id>();
        
        for(Core_Goal__c dwg : newGoalList){
            if(coreGoalMap != null && !coreGoalMap.isEmpty()){
                if((dwg.Core_Goal_Status__c != oldGoalMap.get(dwg.Id).Core_Goal_Status__c) && (dwg.Core_Goal_Status__c == Core_APPROVED) && (oldGoalMap.get(dwg.Id).Core_Goal_Status__c != Core_APPROVED) && !recurrsiveCheck){                   
                    for(Opportunity opp : coreGoalMap.get(dwg.Id).Opportunities__r){
                        System.debug('***Initial Opp at Approval***'+dwg.Core_Goal_Opportunities_at_Approval__c );
                        if(dwg.Core_Goal_Opportunities_at_Approval__c != null){
                            dwg.Core_Goal_Opportunities_at_Approval__c = dwg.Core_Goal_Opportunities_at_Approval__c+','+opp.Id;
                        }else{
                            dwg.Core_Goal_Opportunities_at_Approval__c = opp.Id;
                        }
                        if(opp.OwnerId != CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.ManagerId){
                            opptyShareList.add(new OpportunityShare(UserOrGroupId=CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.ManagerId, OpportunityId=opp.Id, RowCause='Manual', OpportunityAccessLevel = 'Read'));
                        }
                    }
                    System.debug('***Adding all Oppty for DWG***'+dwg.Core_Goal_Opportunities_at_Approval__c );
                    
                    goalShareList.add(new Core_Goal__Share(UserOrGroupId = CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.ManagerId,ParentId = dwg.Id, RowCause='Core_Deal_Win_Goal__c', AccessLevel = 'Edit'));
                    recurrsiveCheck = true;
                }
            }           
            if((dwg.Core_Goal_Status__c != oldGoalMap.get(dwg.Id).Core_Goal_Status__c) && (((oldGoalMap.get(dwg.Id).Core_Goal_Status__c != Core_ACCEPTED) && (dwg.Core_Goal_Status__c == Core_ACCEPTED)) || ((dwg.Core_Goal_Status__c == Core_SUBMITTED) && (oldGoalMap.get(dwg.Id).Core_Goal_Status__c != Core_SUBMITTED))) && !recurrsiveCheck){    
                dwg.Core_Goal_Opportunities_at_Approval__c = '';
                System.debug('***Setting approval to blank***');
                dwg.Core_Goal_Approver__c = CoreGoalMap.get(dwg.Id).Core_Goal_Owner__r.ManagerId;
                System.debug('***Approver Updated - '+dwg.Core_Goal_Approver__c);
                recurrsiveCheck = true;
            }           
        }
        
        if(!goalShareList.isEmpty()){
            try{
                insert goalShareList;
            }Catch(Exception e){
                for(Core_Goal__c dwg : newGoalList){
                    dwg.addError('Not able to submit for approval');
                }
            }
        }
        if(!opptyShareList.isEmpty()){
            try{
                insert opptyShareList;
            }Catch(Exception e){
                for(Core_Goal__c dwg : newGoalList){
                    dwg.addError('Not able to submit for approval');
                }
            }
        }
    }
    
    
    /*
    public static void UpdateOpportunityStage(map<Id, Opportunity> mapOld, map<Id, Opportunity> mapNew) {
        
        Set<Id> opportunities = new Set<Id>();
        
        for (Opportunity opportunity : mapNew.values()) {
            if(mapOld != null && mapOld.get(opportunity.Id).StageName != opportunity.StageName)
                opportunities.add(opportunity.Id);
        }
        
        if (opportunities.isEmpty())
            return;
        
        // Get related Goals
        List<Core_Goal__c> goalChildren = [SELECT (SELECT Id FROM Core_Goal__r) FROM Opportunity WHERE Id in :opportunities];
        
        for(Core_Goal__c goal : goalChildren) {
            goal.Core_Opportunity_Stage__c = mapNew.get(goal.Core_Opportunity__c).StageName;
        }
    }

    public static void PopulateOpportunityStage(List<Core_Goal__c> lstOldGoals, List<Core_Goal__c> lstNewGoals) {
        /*
        List<Core_Goal__c> goalsToPopulate = new List<Core_Goal__c>();
        
        for (Core_Goal__c goal : mapNew.values()) {
            if (mapOld == null || mapOld.get(goal.Id) == null)
                goalsToPopulate.add(goal);
            
            if(mapOld != null && mapOld.get(goal.Id).Core_Opportunity__c != goal.Core_Opportunity__c)
                goalsToPopulate.add(goal);
        }
        
        if (goalsToPopulate.size() == 0)
            return;
        
        
        
        List<Id> oppIds = new List<Id>();
        for (Core_Goal__c goal : lstNewGoals) {
            
            goal.Core_Opportunity__c = goal.Core_Opportunity__r.StageName;
            /*if (goal.Core_Opportunity__c != null)
                oppIds.add(goal.Core_Opportunity__c);
        }
        
        if (!oppIds.isEmpty()) {
            Map<ID, Opportunity> o = new Map<ID, Opportunity>([SELECT Id, StageName FROM Opportunity WHERE Id in :oppIds]);
            
            for (Core_Goal__c goal : lstNewGoals) {
                goal.Core_Opportunity_Stage__c = o.get(goal.Core_Opportunity__c).StageName;
            }
        }
    }*/
    
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