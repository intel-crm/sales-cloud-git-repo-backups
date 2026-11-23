/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_OppApproval
Function    : Methods to handle logic around opportunity approvals - determining approvers, and what to do
            at product line item level upon submission/approval/rejection
Modification Log :
Developer        Date          Description
----------------------------------------------------------------------------        
Dave Hood        R1            Original version
Dave Hood        04/25/2015    Added filter on territory model queries, to only pull from the active model
Dave Hood        04/25/2015    Added Apex managed sharing (read/write access) for opportunity approvers
Dave Hood        05/17/2016    Added DML to bypass validation rules when updating line items back to Pending
Aran Wongsaprome 02/16/2017    Support new Stages and product statuses
Aran Wongsaprome 03/20/2017    On approval only approve products in submitted status
Ashwin Dash      07/28/2017    Adding log entries to capture the issues related to US56607 | INC004899140
Ashwin Dash      10/20/2017    US83099 - DDR: Update Approval Workflow for Disti Oppty - Added code to check if Oppty has DDR
*****************************************************************************************************************************************************************************************************/
public class Core_OppApproval {
    
    // This method is called from a before update trigger, and does the following:
    //  - If Opportunity Approval Status was changed to "Submitted", it
    //  looks up the proper Approver and updates it on the Opportunity
    public static void determineApprovers(Map<Id,Opportunity> triggerOldMap, List<Opportunity> triggerNew) {
        
        // These will hold our lists of Opportunities & Accounts where we need to find an Approver
        List<Opportunity> opportunitiesToGetApprover = new List<Opportunity>();
        List<Id> opportunityIdsToGetApprover = new List<Id>();
        Set<Id> accountIdsToGetApprover = new Set<Id>();
        boolean managerIdBlank = false; //US83099 - DDR: Update Approval Workflow for Disti Oppty - Added boolean check - Ashwin
        
        // Iterate through the Opportunities being updated, to see which ones we need to act on
        for (Opportunity opp : triggerNew) {
                    
            // Check to see if the Approval Status is changing to Submitted
            if ((triggerOldMap.get(opp.Id).Core_Approval_Status__c != opp.Core_Approval_Status__c) &&
                (opp.Core_Approval_Status__c == 'Submitted')) {
                    
                    // Add to the lists where we need to find the Approver
                    opportunitiesToGetApprover.add(opp);
                    opportunityIdsToGetApprover.add(opp.Id);
                    accountIdsToGetApprover.add(opp.AccountId);
            }
        }
        
        // Opportunity Approver update, if necessary
        if ((opportunitiesToGetApprover != null) && (opportunitiesToGetApprover.size() > 0)) {
            
            // This will be used to build up a sharing list, to ensure everybody we're adding as approvers
            // have access to the opportunities
            List<OpportunityShare> oppShares = new List<OpportunityShare>();
            
            // First build up maps of accounts to the territories they're in, and then for each
            // territory, the approvers that are in it
            Map<Id,List<Id>> accountTerritoryMap = new Map<Id,List<Id>>();
            Set<Id> territoriesToGetApprover = new Set<Id>();
            Map<Id,List<Id>> territoryApproverMap = new Map<Id,List<Id>>();
            
            List<ObjectTerritory2Association> accountTerritories = [
                select ObjectId, Territory2Id 
                from ObjectTerritory2Association
                where ObjectId in :accountIdsToGetApprover
                    and Territory2.Territory2Model.State = 'Active'
            ];
            for (ObjectTerritory2Association acctTerr : accountTerritories) {
                if (accountTerritoryMap.containsKey(acctTerr.ObjectId))
                    accountTerritoryMap.get(acctTerr.ObjectId).add(acctTerr.Territory2Id);
                else
                    accountTerritoryMap.put(acctTerr.ObjectId, new List<Id> {acctTerr.Territory2Id});
                
                territoriesToGetApprover.add(acctTerr.Territory2Id);
            }
            
            List<UserTerritory2Association> territoryApprovers = [
                select Territory2Id, UserId from UserTerritory2Association
                where Territory2Id in :territoriesToGetApprover
                and RoleInTerritory2 = 'Opportunity Approver'
                and User.IsActive = true
                and Territory2.Territory2Model.State = 'Active'
            ];
            for (UserTerritory2Association terrAppr : territoryApprovers) {
                if (territoryApproverMap.containsKey(terrAppr.Territory2Id))
                    territoryApproverMap.get(terrAppr.Territory2Id).add(terrAppr.UserId);
                else
                    territoryApproverMap.put(terrAppr.Territory2Id, new List<Id> {terrAppr.UserId});
            }
            
            // In case we can't find any approvers based on territory, get the opportunity owner's
            // manager and active/inactive status, along with technical owner's manager and status
            Map<Id,Opportunity> oppManagerMap = new Map<Id,Opportunity>([
                select Id, Owner.ManagerId, Owner.Manager.IsActive, Core_Technical_Owner__r.ManagerId, 
                    Core_Technical_Owner__r.Manager.IsActive
                from Opportunity 
                where Id in :opportunityIdsToGetApprover
            ]);
            
            //US83099 - DDR: Update Approval Workflow for Disti Oppty - Added code to check if Oppty has DDR
            Map<Id, Opportunity> getDDROpptyManagerIdMap = new Map<Id, Opportunity>([SELECT id, Core_Approver_1__c,Core_Approver_2__c,Core_Approver_3__c,Core_Approver_4__c,Core_Approver_5__c, Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.Owner.ManagerId FROM Opportunity WHERE Core_Design_Registration_Id__c != '' AND id IN :opportunityIdsToGetApprover]);
            
            for (Opportunity opp : opportunitiesToGetApprover) {
                    
                // Blank out any existing approvers
                opp.Core_Approver_1__c = null;
                opp.Core_Approver_2__c = null;
                opp.Core_Approver_3__c = null;
                opp.Core_Approver_4__c = null;
                opp.Core_Approver_5__c = null;
                
                //US83099 - DDR: Update Approval Workflow for Disti Oppty - Added code to check if Oppty has DDR
                if(opp.Core_Design_Registration_Id__c != null && String.valueOf(opp.Core_Design_Registration_Id__c) != ''){
                    if(getDDROpptyManagerIdMap.get(opp.Id) != null){
                        opp.Core_Approver_1__c = getDDROpptyManagerIdMap.get(opp.Id).Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.Owner.ManagerId;
                        opp.Core_Approver_2__c = getDDROpptyManagerIdMap.get(opp.Id).Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.Owner.ManagerId;
                        opp.Core_Approver_3__c = getDDROpptyManagerIdMap.get(opp.Id).Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.Owner.ManagerId;
                        opp.Core_Approver_4__c = getDDROpptyManagerIdMap.get(opp.Id).Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.Owner.ManagerId;
                        opp.Core_Approver_5__c = getDDROpptyManagerIdMap.get(opp.Id).Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.Owner.ManagerId;
                        if(getDDROpptyManagerIdMap.get(opp.Id).Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.Owner.ManagerId != opp.OwnerId)
                                oppShares.add(new OpportunityShare(UserOrGroupId=getDDROpptyManagerIdMap.get(opp.Id).Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.Owner.ManagerId, OpportunityId=opp.Id, OpportunityAccessLevel='Edit'));
                            
                        if(getDDROpptyManagerIdMap.get(opp.Id).Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.Owner.ManagerId == null || String.valueOf(getDDROpptyManagerIdMap.get(opp.Id).Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.Owner.ManagerId) == ''){
                            managerIdBlank = true;
                        }
                    }
                }else{                
                    Set<Id> approverIds = new Set<Id>();
                    List<Id> territoryIds = accountTerritoryMap.get(opp.AccountId);
                    
                    if (territoryIds != null) {
                        for (Id terrId : territoryIds)
                            if (territoryApproverMap.containsKey(terrId))
                                approverIds.addAll(territoryApproverMap.get(terrId));
                    }
                    
                    // If we found at least one Opportunity Approver, then assign up to 5 possible approvers depending on how many
                    // we found.  We need to assign a value to all 5 approver fields, even if it's the same, to prevent the
                    // approval process from generating an error.
                    if ((approverIds != null) && (approverIds.size() > 0)) {
                        
                        Integer numApprovers = approverIds.size();
                        if (numApprovers > 5) numApprovers = 5;
                        
                        List<Id> approverIdList = new List<Id>(approverIds);
                        List<Id> upToFiveApprovers = new List<Id>();
                        for (Integer i=0; i<numApprovers; i++)
                            upToFiveApprovers.add(approverIdList[i]);
                        
                        if (numApprovers == 1) {
                            opp.Core_Approver_1__c = upToFiveApprovers[0];
                            opp.Core_Approver_2__c = upToFiveApprovers[0];
                            opp.Core_Approver_3__c = upToFiveApprovers[0];
                            opp.Core_Approver_4__c = upToFiveApprovers[0];
                            opp.Core_Approver_5__c = upToFiveApprovers[0];
                        }
                        else if (numApprovers == 2) {
                            opp.Core_Approver_1__c = upToFiveApprovers[0];
                            opp.Core_Approver_2__c = upToFiveApprovers[1];
                            opp.Core_Approver_3__c = upToFiveApprovers[0];
                            opp.Core_Approver_4__c = upToFiveApprovers[0];
                            opp.Core_Approver_5__c = upToFiveApprovers[0];
                        }
                        else if (numApprovers == 3) {
                            opp.Core_Approver_1__c = upToFiveApprovers[0];
                            opp.Core_Approver_2__c = upToFiveApprovers[1];
                            opp.Core_Approver_3__c = upToFiveApprovers[2];
                            opp.Core_Approver_4__c = upToFiveApprovers[0];
                            opp.Core_Approver_5__c = upToFiveApprovers[0];
                        }
                        else if (numApprovers == 4) {
                            opp.Core_Approver_1__c = upToFiveApprovers[0];
                            opp.Core_Approver_2__c = upToFiveApprovers[1];
                            opp.Core_Approver_3__c = upToFiveApprovers[2];
                            opp.Core_Approver_4__c = upToFiveApprovers[3];
                            opp.Core_Approver_5__c = upToFiveApprovers[0];
                        }
                        else if (numApprovers == 5) {
                            opp.Core_Approver_1__c = upToFiveApprovers[0];
                            opp.Core_Approver_2__c = upToFiveApprovers[1];
                            opp.Core_Approver_3__c = upToFiveApprovers[2];
                            opp.Core_Approver_4__c = upToFiveApprovers[3];
                            opp.Core_Approver_5__c = upToFiveApprovers[4];
                        }
                        // Add opportunity read/write access to all approvers if needed
                        for (Id approverId : upToFiveApprovers) {
                            // Check to see if the approver is also the owner (shouldn't happen, but the insert will generate an exception if so)
                            if (approverId != opp.OwnerId)
                                oppShares.add(new OpportunityShare(
                                    UserOrGroupId=approverId, OpportunityId=opp.Id, OpportunityAccessLevel='Edit'
                                ));
                        }
                    }
                    // If we didn't find an approver based on territory, base it on management
                    else {
                        Opportunity oppManagers = oppManagerMap.get(opp.Id);
                        
                        // Set the "default approver" we'll use to fill out the 5 approver fields (which all need a value in them,
                        // even if it's redundant, to prevent the approval process from throwing an error).  Use the opportunity owner's
                        // manager, if he/she is active.  Otherwise use the technical owner's manager, if active.  If neither, an
                        // error will be thrown, which is what we want.
                        Id defaultApprover;
                        if ((oppManagers.Owner.Manager.IsActive != null) && (oppManagers.Owner.Manager.IsActive))
                            defaultApprover = oppManagers.Owner.ManagerId;
                        else if ((oppManagers.Core_Technical_Owner__r.Manager.IsActive != null) &&
                            (oppManagers.Core_Technical_Owner__r.Manager.IsActive))
                            defaultApprover = oppManagers.Core_Technical_Owner__r.ManagerId;
                        
                        // To simplify the logic, first we'll assign all 5 to our "default approver"
                        opp.Core_Approver_1__c = defaultApprover;
                        opp.Core_Approver_2__c = defaultApprover;
                        opp.Core_Approver_3__c = defaultApprover;
                        opp.Core_Approver_4__c = defaultApprover;
                        opp.Core_Approver_5__c = defaultApprover;
                        
                        // Add opportunity read/write access to the approver if needed, and check to see if the approver is also the
                        // owner (shouldn't happen, but the insert will generate an exception if so)
                        if (defaultApprover != opp.OwnerId)
                            oppShares.add(new OpportunityShare(
                                UserOrGroupId=defaultApprover, OpportunityId=opp.Id, OpportunityAccessLevel='Edit'
                            ));
                        
                        // Now, if that default approver was the user's manager, see if we can assign an approver based on the
                        // technical owner's manager.  (If the default approver was already the tech owner's manager, don't do
                        // anything, since that means the owner didn't have an active manager.)
                        if ((oppManagers.Owner.ManagerId != null) &&
                            (defaultApprover == oppManagers.Owner.ManagerId) &&
                            (oppManagers.Core_Technical_Owner__r.ManagerId != null) &&
                            (oppManagers.Core_Technical_Owner__r.Manager.IsActive != null) &&
                            (oppManagers.Core_Technical_Owner__r.Manager.IsActive)) {
                                opp.Core_Approver_2__c = oppManagers.Core_Technical_Owner__r.ManagerId;
                                
                                if (opp.Core_Approver_2__c != opp.OwnerId)
                                    oppShares.add(new OpportunityShare(UserOrGroupId=opp.Core_Approver_2__c, OpportunityId=opp.Id, OpportunityAccessLevel='Edit'));
                            }
                    }
                }   
            }
            //US83099 - DDR: Update Approval Workflow for Disti Oppty - Added code to check if Oppty has DDR
            if(managerIdBlank){
                for(Opportunity oppty : triggerNew){
                    oppty.addError('The Design Registration Partner account does not has a manager');
                }
            }
            /*
            for (OpportunityShare oppShare : oppShares)
                System.debug('##### OpportunityShare: ' + oppShare);
            */
            // Insert the OpportunityShare records but without doing "all or none" - the insert can theoretically
            // fail in scenarios that really should never happen, like the opportunity owner is also a territory
            // approver, or his/her own manager, etc.
            Database.SaveResult[] dsr = Database.insert(oppShares, false);
        }
    }

    /* The business logic to determine what product state results from update to opportunity stagey
     * Handles Stage changes to "Production Win", "Production Cancelled", or "Production Lost"
     * Handles Approval Status changes to "Submitted", "Approved", "Rejected", or "Recalled"
     */
    private static void determineProductStatus(Opportunity OldOpp, Opportunity Opp, OpportunityLineItem Product, List<OpportunityLineItem> UpdateProducts, Set<Id> UpdateOpps, List<Core_Log_Entry__c> logEntries) {
        if(OldOpp.StageName != Opp.StageName) {
            if(Opp.StageName == 'Production Win' && Product.Core_Status__c == 'Win Approved') {
                System.debug('Update product ' + Product.Id + ' status ' + Product.Core_Status__c + ' to ' + Opp.StageName);
                Product.Core_Status__c = Opp.StageName; 
                UpdateProducts.add(Product);
            }
            if(Opp.StageName == 'Production Cancelled') {
                if(Product.Core_Status__c == 'Win Approved' || Product.Core_Status__c == 'Production Win') {
                    System.debug('Update product ' + Product.Id + ' status ' + Product.Core_Status__c + ' to ' + Opp.StageName);
                    Product.Core_Loss_Cancel_Reason__c = 'Opportunity Cancelled';
                    Product.Core_Status__c = Opp.StageName;
                    UpdateProducts.add(Product);
                }
                if(Product.Core_Status__c == 'Pending' || Product.Core_Status__c == 'On Hold') {
                    System.debug('Update product ' + Product.Id + ' status ' + Product.Core_Status__c + ' to Cancelled');
                    Product.Core_Loss_Cancel_Reason__c = 'Opportunity Cancelled';
                    Product.Core_Status__c = 'Cancelled';
                    UpdateProducts.add(Product);
                }
            }
            if(Opp.StageName == 'Production Lost') {
                if(Product.Core_Status__c == 'Win Approved' || Product.Core_Status__c == 'Production Win') {
                    System.debug('Update product ' + Product.Id + ' status ' + Product.Core_Status__c + ' to ' + Opp.StageName);
                    Product.Core_Loss_Cancel_Reason__c = 'Opportunity Lost';
                    Product.Core_Status__c = Opp.StageName;
                    UpdateProducts.add(Product);
                }
                if(Product.Core_Status__c == 'Pending' || Product.Core_Status__c == 'On Hold') {
                    System.debug('Update product ' + Product.Id + ' status ' + Product.Core_Status__c + ' to Lost');
                    Product.Core_Loss_Cancel_Reason__c = 'Opportunity Lost';
                    Product.Core_Status__c = 'Lost';
                    UpdateProducts.add(Product);
                }
            }
        }
        //Added logEntries to capture the new status of the products and which product has been changed -- Ashwin
        if(OldOpp.Core_Approval_Status__c != Opp.Core_Approval_Status__c && (Product.Core_Status__c == 'Pending' || Product.Core_Status__c == 'Win Submitted')) {
            if(Opp.Core_Approval_Status__c == 'Submitted') {
                System.debug('Update product ' + Product.Id + ' status ' + Product.Core_Status__c + ' to Win Submitted');
                Product.Core_Status__c = 'Win Submitted';
                UpdateProducts.add(Product);
                logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Stage-'+Opp.StageName+' Product Status -'+Product.Core_Status__c, Core_Origin__c ='Core_OppApproval.updateProductLineItems', Core_Severity__c='High',Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve',Core_sObjectId__c=Product.id));
            }
            if(Opp.Core_Approval_Status__c == 'Approved' && Product.Core_Status__c == 'Win Submitted') {
                System.debug('Update product ' + Product.Id + ' status ' + Product.Core_Status__c + ' to Win Approved');
                Product.Core_Status__c = 'Win Approved';
                UpdateProducts.add(Product);
                logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Stage-'+Opp.StageName+' Product Status -'+Product.Core_Status__c, Core_Origin__c ='Core_OppApproval.updateProductLineItems', Core_Severity__c='High',Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve',Core_sObjectId__c=Product.id));
            }
            if(Opp.Core_Approval_Status__c == 'Rejected' || Opp.Core_Approval_Status__c == 'Recalled') {
                System.debug('Update product ' + Product.Id + ' status ' + Product.Core_Status__c + ' to Pending');
                Product.Core_Status__c = 'Pending';
                UpdateProducts.add(Product);
                System.debug('Update opportunity ' + Opp.Id + ' Core_Bypass_Field_Validation__c = true');
                UpdateOpps.add(Opp.Id);
                logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Stage-'+Opp.StageName+' Product Status -'+Product.Core_Status__c, Core_Origin__c ='Core_OppApproval.updateProductLineItems', Core_Severity__c='High',Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve',Core_sObjectId__c=Product.id));
            }
        }
    }
    
    // This method is called from an Opportunity after update trigger. It updates the 
    // child products based on the logic in the above method.
    public static void updateProductLineItems(Map<Id,Opportunity> triggerOldMap, List<Opportunity> triggerNew) {
        // Get all of the IDs for the Opportunities being updated to find related products
        //START - Adding Log Entry and Try Catch block -- Ashwin
        
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>(); 
        try{
        
            Set<Id> oppIds = new Set<Id>();
            for (Opportunity opp : triggerNew) oppIds.add(opp.Id);
            // Get all of the Opportunity Products that we *might* update, where Status is Pending or Win Submitted
            List<OpportunityLineItem> oppProdList = [
                SELECT Id, OpportunityId, Core_Status__c FROM OpportunityLineItem
                WHERE OpportunityId IN :oppIds
                    AND Core_Status__c IN ('Pending', 'On Hold', 'Win Submitted', 'Win Approved', 'Production Win')
            ];
            // Determine what updates are needed based on the old opp, new opp, and related product
            List<OpportunityLineItem> UpdateProducts = new List<OpportunityLineItem>(); 
            Set<Id> UpdateOpps = new Set<Id>();
            //Adding brackets for proper identification of for loop -- Ashwin
            for (Opportunity O : triggerNew){ 
                logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Stage-'+O.StageName+' Approval-'+O.Core_Approval_Status__c, Core_Origin__c ='Core_OppApproval.updateProductLineItems', Core_Severity__c='High',Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve',Core_sObjectId__c=O.id));
                for (OpportunityLineItem P : oppProdList){
                    if(O.Id == P.OpportunityId){                        
                        determineProductStatus(triggerOldMap.get(O.Id), O, P, UpdateProducts, UpdateOpps, logEntries);
                    }
                }
            }
            if(!UpdateOpps.isEmpty()) {
                List<Opportunity> Opps = [ SELECT Id, Core_Bypass_Field_Validation__c FROM Opportunity WHERE Id in :UpdateOpps ];
                for(Opportunity O : Opps) O.Core_Bypass_Field_Validation__c = true;
                update Opps;
                System.debug('Updates to opportunities complete');
            }
            // Make the updates that were determined
            if(!UpdateProducts.isEmpty()) {
                update UpdateProducts;
                System.debug('Updates to products complete');
            }
            
        }catch(Exception e){
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c='Core_OppApproval.updateProductLineItems', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
        }finally{
            if(!logEntries.isEmpty()){
                insert logEntries;
            }
        }
        //END - Adding Log Entry and Try Catch block -- Ashwin
    }
}