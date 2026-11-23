/**************************************************************************************
Apex Class Name:  Core_SolutionMilestoneHandler
Version     : 1.0 
Created Date: 28 OCT 2015
Function    : Utility methods to handle Solution Milestone functions
    Modification Log
* Developer                   Date           Description
* ----------------------------------------------------------------------------
* Ajay Doddangadi           20/Sep/2017      Updated Code to put an entry in commissions table only when milestone commissionable is Yes.
* Ashwin Dash               01/Aug/2017      DE28898: Update lookup field value to associated Opportunity ID. 
* Sampath Bokam             04/03/2017       Updated addCommissionableTransactions() to remove Design Product Category from Integration 
* Sampath Bokam             11/09/2016       Modified code to put an entry in commissions table only for Milestone owner, and not team members
* David Wong                29/3/2016        Modified Commissionable Transaction
* David Wong                10/28/2015       Original version
*************************************************************************************/
public class Core_SolutionMilestoneHandler{

    // Make sure we only execute functionality once
    public static Boolean alreadyAddedCommissionableTransactions = false;

    // Milestone Owner Role, Contribution percentage
    public static String milestoneOwnerRole = 'Milestone Owner (100%)';
    public static Integer milestoneOwnerRoleContribution = 100;

    /*
* Method name  : addCommissionableTransactions
* Description  : Adds new Commissionable Transaction entries for each Opportunity Team Member associated with
*                an newly approved, qualifying Solution Milestone.  For Solution Milestones that go from  
*                approved to not approved, inserts new Commissionable Transaction entries corresponding to the 
*                previous approved entries, whose status is marked as not approved.
* Return Type  : VOID
* Parameters   : Trigger.Old, Trigger.oldMap, Trigger.New, Trigger.newMap, Trigger.isInsert, Trigger.isUpdate
*/

   /* public static void addCommissionableTransactions(List<Core_Solution_Milestone__c> oldMilestoneList, Map<Id,Core_Solution_Milestone__c> oldMilestoneMap,
                                                     List<Core_Solution_Milestone__c> newMilestoneList, Map<Id,Core_Solution_Milestone__c> newMilestoneMap,
                                                     Boolean isInsert, Boolean isUpdate)
    {
        if(!alreadyAddedCommissionableTransactions) {

            alreadyAddedCommissionableTransactions = true;

            List<Core_Commissionable_Transaction__c> newTxns = new List<Core_Commissionable_Transaction__c>();

            // Set of all new approved milestones that are changing to "approved"
            Set<Core_Solution_Milestone__c> approvedMilestones = new Set<Core_Solution_Milestone__c>();
            // Map of all rejected milestones
            Map<ID,Core_Solution_Milestone__c> rejectedMilestones = new Map<ID,Core_Solution_Milestone__c>();
            Set<ID> userIDs = new Set<ID>();

            for (Core_Solution_Milestone__c milestone : newMilestoneList) {
                // If (this is an insert trigger and status is approved) OR
                //  If (this is an update trigger, new status is approved and prior status was not approved)
                if (
                    (milestone.Core_Milestone_Commissionable__c.equalsIgnoreCase(Core_Static_Variables.YES) && isInsert && (milestone.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Milestone_Approved_Status)) ||
                    (milestone.Core_Milestone_Commissionable__c.equalsIgnoreCase(Core_Static_Variables.YES) &&(isUpdate && (milestone.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Milestone_Approved_Status)) //TODO: make "approved" a custom label
                     && !((oldMilestoneMap.get(milestone.Id).Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Milestone_Approved_Status)))) {

                         //Verify that this milestone is a commissionable milestone found in the custom setting
                         List<Core_Commissionable_Transaction_Type__c> txnTypes = Core_Commissionable_Transaction_Type__c.getAll().values(); 
                         for(Core_Commissionable_Transaction_Type__c txnType : txnTypes) {
                             if(txnType.Core_Milestone__c == milestone.Core_Milestone__c) {
                                 //Add this milestone to set of all newly approved, commissionable milestones
                                 approvedMilestones.add(milestone); 
                                 userIDs.add(milestone.Core_Owner__c);
                             }
                         } 
                     }

                //Else if this is an update trigger, new status is not approved, and prior status was approved
                else if (isUpdate 
                         && !((milestone.Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Milestone_Approved_Status)) 
                         && ((oldMilestoneMap.get(milestone.Id).Core_Status__c).equalsIgnoreCase(Label.Core_Commissionable_Transaction_Milestone_Approved_Status)) ) {
                             //Add this milestone to map of rejected milestones 
                             rejectedMilestones.put(milestone.ID, milestone);          
                         }                          
            }

            //Get a list of commissionableTxns associated with every rejected milestone
            List<Core_Commissionable_Transaction__c> txnList = [
                SELECT Core_Account_ID__c,Core_Account_Name__c,Core_Approved_Total_Price__c,Core_Claim_Date__c,
                Core_Employee_ID__c,Core_Employee_Name__c,Core_Last_Approved_Date__c,
                Core_Milestone_Area__c,Core_Milestone_Focus__c,Core_Milestone_ID__c,Core_Milestone__c,Core_Opportunity_Name__c,
                Core_Opportunity_Team_Member_Role__c,Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,
                Core_Product2_ID__c,Core_Product_Type__c,Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,
                Core_Transaction_Type__c,Core_WWID__c 
                FROM Core_Commissionable_Transaction__c
                WHERE Core_Source_ID__c in :rejectedMilestones.keySet()
            ];

            Map<ID,DateTime> rejectedMilestoneMostRecentTimestamp = new Map<ID,DateTime>();
            List<Core_Commissionable_Transaction__c> rejectedTransactions = new List<Core_Commissionable_Transaction__c>();

            for (ID rejectedMilestoneID : rejectedMilestones.keySet()) {
                //Find the most recent timestamp in the list of transactions for this milestone
                DateTime mostRecentTimestamp = DateTime.newInstanceGMT(2000, 1, 1, 12, 0, 0);
                for (Core_Commissionable_Transaction__c ct : txnList) {
                    if (ct.Core_Source_ID__c == rejectedMilestoneID && ct.Core_Transaction_Timestamp__c > mostRecentTimestamp)
                        mostRecentTimestamp = ct.Core_Transaction_Timestamp__c;
                }                
                //Iterate again through the list of transactions to get all transactions matching this milestone and timestamp, 
                // and add to list of rejected transactions
                for (Core_Commissionable_Transaction__c ct : txnList) {
                    if (ct.Core_Source_ID__c == rejectedMilestoneID && ct.Core_Transaction_Timestamp__c == mostRecentTimestamp)
                        rejectedTransactions.add(ct);
                }
            }

            //Iterate through the set, replacing the Transaction Timestamp with current time, and set status to current status.
            //(If no match was found, do nothing)
            for (Core_Commissionable_Transaction__c rejectedTransaction : rejectedTransactions) {
                rejectedTransaction.Core_Transaction_Timestamp__c = System.now();
                rejectedTransaction.Core_Status__c = rejectedMilestones.get(rejectedTransaction.Core_Source_ID__c).Core_Status__c;
                rejectedTransaction.Id = null;
                //Add the modified transaction to newTxn
                newTxns.add(rejectedTransaction);
            }

            //Iterate through set of milestones changing to "approved", generate a set of Opportunity IDs
            Set<ID> opportunityIDs = new Set<ID>();
            for (Core_Solution_Milestone__c approvedMilestone : approvedMilestones) {
                opportunityIDs.add(approvedMilestone.Core_Opportunity__c);
            }

            //Generate an Opportunity map based on the set, keyed by Opportunity ID (Name, Type)
            Map<ID, Opportunity> opportunities = new Map<ID, Opportunity>();    
            Set<ID> accountIDs = new Set<ID>();
            for (Opportunity op : [SELECT o.ID, o.Name, o.Core_Opportunity_Type__c, o.AccountId FROM Opportunity o WHERE o.ID in :opportunityIDs]) {
                opportunities.put(op.ID, op);
                accountIDs.add(op.AccountId);
            }       

            //Generate an Account map (CIM ID, Name)
            Map<ID, Account> accounts = new Map<ID, Account>();
            for (Account account: [SELECT a.ID,  a.Name FROM Account a WHERE a.ID in :accountIDs] )
                accounts.put(account.ID, account);    

            //Generate a User map (Name, WWID)
            Map<ID, User> users = new Map<ID, User>();
            for (User user: [SELECT u.ID, u.Name, u.Core_WWID__c, u.Core_Employee_Type_Code__c FROM User u WHERE u.ID in :userIDs] )
                users.put(user.ID, user);

            Core_Commissionable_Transaction__c opTxn;

            //Iterate through the approvedMilestones set
            for (Core_Solution_Milestone__c approvedMilestone : approvedMilestones) {  
                if (approvedMilestone.Core_Opportunity__c!= null &&
                    users.get(approvedMilestone.Core_Owner__c).Core_Employee_Type_Code__c == 'EMP') {
                        opTxn = new Core_Commissionable_Transaction__c();

                        //Use maps to collate transaction attributes above the user level        
                        opTxn.Core_Source_ID__c = approvedMilestone.Id;
                        opTxn.Core_Transaction_Timestamp__c = System.now();
                        opTxn.Core_Account_ID__c = opportunities.get(approvedMilestone.Core_Opportunity__c).AccountId;
                        opTxn.Core_Account_Name__c = accounts.get(opportunities.get(approvedMilestone.Core_Opportunity__c).AccountId).Name;
                       // opTxn.Core_CIM_ID__c = accounts.get(opportunities.get(approvedMilestone.Core_Opportunity__c).AccountId).Core_CIM_ID__c;
                        opTxn.Core_Claim_Date__c = approvedMilestone.Core_Milestone_Claim_Date__c;
                        if(approvedMilestone.Core_Milestone_Approved_Date__c == null)
                        {
                            //in production, we always expect this code to run -- when a milestone is newly approved, the milestone approved date usually gets populated after this
                            opTxn.Core_Last_Approved_Date__c = System.now().date();
                        }
                        else
                        {
                            //in case of manual data updates, this code may need to run instead
                            opTxn.Core_Last_Approved_Date__c = approvedMilestone.Core_Milestone_Approved_Date__c;
                        }
                        opTxn.Core_Milestone_ID__c = approvedMilestone.Id;
                        opTxn.Core_Milestone__c = approvedMilestone.Core_Milestone__c;
                        opTxn.Core_Milestone_Area__c = approvedMilestone.Core_Milestone_Focus_Area__c;
                        opTxn.Core_Milestone_Focus__c = approvedMilestone.Core_Milestone_Focus__c;
                        //This will always be approved
                        opTxn.Core_Status__c = Label.Core_Commissionable_Transaction_Approved_Status;
                        opTxn.Core_Opportunity__c = approvedMilestone.Core_Opportunity__c;
                        opTxn.Core_Opportunity_Name__c = opportunities.get(approvedMilestone.Core_Opportunity__c).Name;
                        opTxn.Core_Opportunity_Type__c = opportunities.get(approvedMilestone.Core_Opportunity__c).Core_Opportunity_Type__c;

                        // Set the role and percentage contribution
                        opTxn.Core_Opportunity_Team_Member_Role__c = milestoneOwnerRole;
                        opTxn.Core_Percent_Contribution__c = milestoneOwnerRoleContribution;

                        //Get Transaction Type via custom setting
                        List<Core_Commissionable_Transaction_Type__c> txnTypes = Core_Commissionable_Transaction_Type__c.getAll().values(); 
                        for(Core_Commissionable_Transaction_Type__c txnType : txnTypes) {
                            if(txnType.Core_Milestone__c == approvedMilestone.Core_Milestone__c)
                                opTxn.Core_Transaction_Type__c = txnType.Core_Commissionable_Transaction_Type__c;
                        }

                        opTxn.Core_Employee_ID__c = approvedMilestone.Core_Owner__c;
                        opTxn.Core_Employee_Name__c = users.get(approvedMilestone.Core_Owner__c).Name;
                        opTxn.Core_WWID__c = users.get(approvedMilestone.Core_Owner__c).Core_WWID__c;

                        newTxns.add(opTxn);
                    }
            }

            insert newTxns;
        }
    }*/
    
    //START - DE28898: Update lookup field value to associated Opportunity ID. -- Ashwin
    /*
    * Method name  : udpdateLookupField
    * Description  : Update the new field Core_Milestone_Oppty__c with the existing Opporutnity ID 
    * Return Type  : VOID
    * Parameters   : Trigger.New
    */
    public static void udpdateLookupField(List<Core_Solution_Milestone__c> oldMilestoneList){
        for(Core_Solution_Milestone__c mile : oldMilestoneList){
            mile.Core_Milestone_Oppty__c = mile.Core_Opportunity__c;
        }
    }
    //END - DE28898: Update lookup field value to associated Opportunity ID. -- Ashwin
}