/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_OpportunityHandler
Version     : 1.0 
Created Date: 16 OCT 2014
Function    : Utility methods to handle Opportunity functions
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/16/2014              Original Version
* Harshith M L              11/20/2014              Updated with new method opportunityTechnicalOwnerUpdate and runOnce
* Dave Hood                 12/19/2014              Added Opportunity Geo population
* Srikant Joshi             1/14/2015               DEACTIVATED THE BLOCK OF CODE SINCE THE FUNCTIONALITY IS NOW REVERTED BACK
* Srikant Joshi             1/14/2015               Added the exception handling for the code 
* Srikant joshi             02/05/2015              Added the exception handling for the code
* Harshith M L              02/05/2015              Added the exception handling for the code
* Harshith M L              02/23/2015              Added code to retain Technical Owner ( if same as opportunity owner ) as 
*                                                   Opportunity Team Member if opportunity Owner changes - ( Line No 200-215)
* Brian Matthews            03/09/2015              Clone Cleanup
* Dave Hood                 03/24/2015              Opportunity Stage update (for Lost/Cancelled) and removal of dead Opportunity Geo code
* Venu Karumuru             07/13/2015              Added call to UpdateActivityLineItems to copy Amount, Volume data from Opportunity to Activities
* Brian Matthews            08/25/2015              Stage Update for Design Win
* Kalpana Choudhary         09/01/2015              To update territory information on Opportunity from corresponding account.
* Dave Hood                 02/16/2016              Fixed issue for INC003866872 where inactive team members were trying to be updated
* Aran Wongsaprome          03/02/2017              US20045 Add stages "Production Lost" and "Production Cancelled"
* Bokam Sampath             04/11/2017              Updated opportunityTechnicalOwnerUpdate() to remove the user from oppotunity team when the user is removed as technical owner
* Ashwin Dash               05/25/2017              US58135: OPPTY Defect: Ensure Access is Removed When Technical Owner is Removed From Opportunity | Updated opportunityTechnicalOwnerUpdate() and added functionality to delete opportunity teammembers in future method -- Ashwin
* Ashwin Dash               06/23/2017              DE28766: Technical Owner not getting added to Team Member | Intermittent issue | Adding correct recurssive check in opportunityTechnicalOwnerUpdate() and enabling logging of all the events properly.
* Ashwin Dash               10/01/2017              US83104 - Added changes when opportunity Decision Date/ FCSD changes the Forecast should be re-calculated.
* Ashwin Dash               01/12/2017              US87446 - Cleanup Log Entries - Check to toggle creation of log entries for Sales Evolve
* Mahesh                    3/25/2019               US314046-Block selection of existing opportunity while converting a lead
*****************************************************************************************************************************************************************************************************/
public class Core_OpportunityHandler{
    
    //Ensures that the trigger is running only once during the after update 
    public static boolean bTechnicalOwnerUpdate = true;
    public static String DESIGN_WIN             = 'Design Win';
    public static Set<Id> uniqueOpptyIdsSet = new Set<Id>();   //DE28766: Adding a new Set to check the recurssion of Trigger execution - Ashwin 
    public static final Set<String> Core_Status = new Set<String>{'Lost','Cancelled','Deleted','On Hold','Production Lost','Production Cancelled'};
        public static boolean isExistingOpp = true;
    public static boolean TerritoryUpdateCheck = true;
    /*
* Method name  : opportunityStageUpdate
* Description  : Updates Pending/On Hold line items to Lost/Cancelled if opportunity is Lost/Cancelled
* Return Type  : VOID
* Parameter    : Map<Id,Opportunity>,Map<Id,Opportunity>
*/
    
    public static void opportunityStageUpdate(Map < Id, Opportunity > mapOldsObject, Map < Id, Opportunity > mapNewsObject) {
        
        // 1. For all opportunities that were updated, see which ones had their stage changed, from non-Lost to Lost
        // 2. With that list, pull all line items in a Pending or On Hold status
        // 3. Update those items to Lost
        // Do the same thing for Cancelled
        
        List<Opportunity> oppsUpdated = mapNewsObject.values();
        Set<Id> oppIdsLost      = new Set<Id>();
        Set<Id> oppIdsCancelled = new Set<Id>();
        Set<Id> oppIdsDesignWin = new Set<Id>();
        
        for (Opportunity opp : oppsUpdated) {
            if ((opp.StageName == 'Lost') && (mapOldsObject.get(opp.Id).StageName != 'Lost')) {
                oppIdsLost.add(opp.Id);
            }
            else if ((opp.StageName == 'Cancelled') && (mapOldsObject.get(opp.Id).StageName != 'Cancelled')) {
                oppIdsCancelled.add(opp.Id);
            }
            else if ((opp.StageName == DESIGN_WIN) && (mapOldsObject.get(opp.Id).StageName != DESIGN_WIN)) {
                oppIdsDesignWin.add(opp.Id);
            }
        }
        
        System.debug('#17 oppIdsLost.size(): ' + oppIdsLost.size());
        if (oppIdsLost.size() > 0) {
            List<OpportunityLineItem> oppItemsLost = oppLostCancelledLineItems(oppIdsLost, 'Lost', 'Opportunity Lost');
            if (oppItemsLost.size() > 0)
                update oppItemsLost;
        }
        
        System.debug('#18 oppIdsCancelled.size(): ' + oppIdsCancelled.size());
        if (oppIdsCancelled.size() > 0) {
            List<OpportunityLineItem> oppItemsCancelled = oppLostCancelledLineItems(oppIdsCancelled, 'Cancelled', 'Opportunity Cancelled');
            if (oppItemsCancelled.size() > 0)
                update oppItemsCancelled;
        }
        
    }
    
    
    private static List<OpportunityLineItem> oppLostCancelledLineItems(Set<Id> oppIds, String status, String reason)
    {
        List<OpportunityLineItem> oppItems = [SELECT Id, OpportunityId, Core_Status__c, Core_Loss_Cancel_Reason__c 
                                              FROM OpportunityLineItem
                                              WHERE OpportunityId in :oppIds 
                                              AND Core_Status__c IN ('Pending', 'On Hold')];
        
        for (OpportunityLineItem li : oppItems) {
            li.Core_Status__c = status;
            li.Core_Loss_Cancel_Reason__c = reason;
        }
        
        return oppItems;
    }
    
    
    /*
* Method name  : opportunityOppFactDelete
* Description  : Checks the opp facts & delete them
* Return Type  : VOID
* Parameter    : List of ID
*/
    public static void opportunityOppFactDelete(List<Opportunity> listOpportunity) {
        // Get the list of the Opportunity facts
        List<ID> listOpportunityFact = new List<ID>{};
            for(Opportunity sObjOpp : listOpportunity){
                if(sObjOpp.Core_Opportunity_Facts_ID__c != NULL)
                    listOpportunityFact.add(sObjOpp.Core_Opportunity_Facts_ID__c);    
            }
        if(!listOpportunityFact.isEmpty()){
            Database.DeleteResult[] lstOppFactDeletedResults = Database.delete(listOpportunityFact, false);
            for (Database.DeleteResult sr : lstOppFactDeletedResults) {
                if (!sr.isSuccess()) {
                    Opportunity sobjCoreOppFeature =  new Opportunity(Id = sr.getId());
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        sobjCoreOppFeature.addError(err.getMessage());   
                    }
                }
            }
        }
    }    
    
    /*
* Method name  : opportunityTechnicalOwnerUpdate
* Description  : Add/Update Opportunity Team Members related to opportunity record based on Technical Owner
* Return Type  : VOID
* Parameter    : Map<Id,Opportunity>,Map<Id,Opportunity>
*/
    
    public static void opportunityTechnicalOwnerUpdate(Map < Id, Opportunity > mapOldsObject, Map < Id, Opportunity > mapNewsObject) {
        
        // Enforcing the functionality to run only once
        //DE28766: Commmenting out below recurssive check -- Ashwin
        /*if (!isTechnicalOwnerUpdated()) 
return;
*/
        //START - DE28766: Adding the new Recurssive check - Ashwin
        if(!uniqueOpptyIdsSet.isEmpty() && !Test.isRunningTest()){
            for(Id oppId : mapNewsObject.keySet()){
                if(uniqueOpptyIdsSet.contains(oppId)){
                    return;
                }
            }
        }       
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        //END - DE28766: Adding the new Recurssive check - Ashwin
        
        // List to store opportunity team members to be inserted
        List < OpportunityTeamMember > lstOpportunityTeamMember = new LIst < OpportunityTeamMember > ();
        
        // List to store opportunity team members which are present for an opportunity
        List < OpportunityTeamMember > lstUpdateOpportunityTeamMember = new List < OpportunityTeamMember > ();
        
        // Map to store technical owner Id and opportunity
        Map < Id, List<Opportunity>> mapTechnicalOwnerOpportunity = new Map < Id, List<Opportunity>> ();
        
        // List to store the opportunities for which opportunity team members needs to be created
        List < Opportunity > lstOpportunities = new List < Opportunity > ();
        
        // List to store opportunity splits for opportunity
        List < OpportunitySplit > lstOpportunitySplits = new List < OpportunitySplit > ();
        
        // Map to store splitOwnerId and Opportunity Split Record
        Map < Id, List < OpportunitySplit >> mapSplitOwnerIdOpportunitySplit = new Map < Id, List < OpportunitySplit >> ();
        
        // List to store opportunity splits which needs to be deleted
        List < OpportunitySplit > lstDeletedOpportunitySplits = new List < OpportunitySplit > ();
        
        // Map to store User Id and list of Opportunity team member records
        Map < Id, List < OpportunityTeamMember >> mapUserIdOpportunityTeamMember = new Map < Id, List < OpportunityTeamMember >> ();
        
        // List to store Opportunity team members to be deleted
        List < OpportunityTeamMember > lstDeleteOpportunityTeamMembers = new List < OpportunityTeamMember > ();
        Set<Id> setDeleteOpptyTeamMembers = new Set<Id>();  // Added to pass set of ids to future method for deleting the team members - Ashwin
        
        // List to store Opportunity share records to be inserted
        List<OpportunityShare> lstOpportunityShare = new List<OpportunityShare>();
        List<OpportunityShare> lstOpportunityShareDup = new List<OpportunityShare>(); //Created for capturing the actual oppty share records to be updated - Ashwin
        
        // Team Constants
        String sOpportunityOwner = System.Label.Core_Opportunity_Owner;    // String to store 'Opportunity Owner' value             
        String sTeamMember       = System.Label.Core_Team_Member;          // String to store 'Team Member' value             
        String sTechnicalOwner   = System.Label.Core_Technical_Owner;      // String to store 'Technical Owner' value 
        
        
        // Adding all the opportunities for which opportunity team members needs to created for update
        List<Opportunity> lstUpdatedOpportunities = new List<Opportunity>();
        
        SET<ID> setUpdatedOpportunities = new SET<ID>();
        Set<id> opptechnicalOwnerId = new Set<id>();
        
        //US87446 - Cleanup Log Entries - Check to toggle creation of log entries for Sales Evolve - Ashwin
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();      
        
        //DE28766: Adding try catch block- Ashwin
        try{
            // Checking if its an update or insert
            if (!mapOldsObject.isEmpty()) {
                
                // Iterating over the list of opportunity records and checking if there is any change for technical owner
                for (Opportunity opp: mapNewsObject.values()) {
                    
                    if (mapOldsObject.get(opp.Id).Core_Technical_Owner__c != opp.Core_Technical_Owner__c) {
                        setUpdatedOpportunities.add(opp.Id);
                        lstUpdatedOpportunities.add(opp);
                        
                        if(mapTechnicalOwnerOpportunity.containsKey(mapOldsObject.get(opp.Id).Core_Technical_Owner__c)) {
                            mapTechnicalOwnerOpportunity.get(mapOldsObject.get(opp.Id).Core_Technical_Owner__c).add(opp);
                        }
                        else{
                            mapTechnicalOwnerOpportunity.put(mapOldsObject.get(opp.Id).Core_Technical_Owner__c,new List<Opportunity> {opp});
                        }
                        opptechnicalOwnerId.add(opp.Core_Technical_Owner__c);
                    }
                    
                    // The Technical Owner is assigned AND
                    // 
                    // We have a New Owner & the Technical Owner is not the New Owner
                    // OR
                    // We have a New Technical Owner
                    //                  
                    if ((opp.Core_Technical_Owner__c != Null) && (opp.Core_Technical_Owner__c != opp.OwnerId))
                    {
                        if ((mapOldsObject.get(opp.Id).OwnerId != opp.OwnerId) ||  
                            (mapOldsObject.get(opp.Id).Core_Technical_Owner__c != opp.Core_Technical_Owner__c))
                        {
                            OpportunityTeamMember otm  = new OpportunityTeamMember();
                            otm.TeamMemberRole         = sTechnicalOwner;
                            otm.UserId                 = opp.Core_Technical_Owner__c;
                            otm.OpportunityId          = opp.Id;
                            otm.OpportunityAccessLevel = 'Edit';// Added edit access to opportunity for OpportunitTeamMember -- Ashwin
                            lstOpportunityTeamMember.add(otm);
                            /*                    
// Creating an Opportunity Share record and adding it to the list
OpportunityShare opportunityShareInstance = new OpportunityShare();
opportunityShareInstance.OpportunityAccessLevel = System.Label.Core_Edit_Permission;
//                      opportunityShareInstance.UserOrGroupId = mapOldsObject.get(opp.Id).Core_Technical_Owner__c;
opportunityShareInstance.UserOrGroupId = opp.Core_Technical_Owner__c;
opportunityShareInstance.OpportunityId = opp.Id;
lstOpportunityShare.add(opportunityShareInstance);                     
*/
                        }
                    }                                                
                }
                
                // Fetching Opportunity splits for the opportunity
                lstOpportunitySplits = [SELECT OpportunityId, SplitOwnerId from OpportunitySplit Where OpportunityId IN: setUpdatedOpportunities];
                
                // Checking whether opportunity splits list is empty
                if (!lstOpportunitySplits.isEmpty()) {
                    
                    // Iterating over the list of opportunity splits and creating a map for split owner and opportunity split
                    for (OpportunitySplit opportunitySplitInstance: lstOpportunitySplits) {
                        if (mapSplitOwnerIdOpportunitySplit.containsKey(opportunitySplitInstance.splitOwnerId))
                            mapSplitOwnerIdOpportunitySplit.get(opportunitySplitInstance.splitOwnerId).add(opportunitySplitInstance);
                        else
                            mapSplitOwnerIdOpportunitySplit.put(opportunitySplitInstance.splitOwnerId, new List < OpportunitySplit > {
                                opportunitySplitInstance
                                    });
                    }
                }
                
                // Checking whether technical owner map is empty
                if (!mapTechnicalOwnerOpportunity.isEmpty()) {
                    
                    // checking if there is opportunity split for opportunity 
                    if (!mapSplitOwnerIdOpportunitySplit.isEmpty()) {
                        
                        // Iterating over technical Owners and checking if technical owner is having opportunity split 
                        for (Id technicalOwnerId: mapTechnicalOwnerOpportunity.keyset()) {
                            if (mapSplitOwnerIdOpportunitySplit.containsKey(technicalOwnerId)) {
                                List < OpportunitySplit > lstSelectedOpportunity = mapSplitOwnerIdOpportunitySplit.get(technicalOwnerId);
                                List<Opportunity> lstUpdatedOpportunity =  mapTechnicalOwnerOpportunity.get(technicalOwnerId);
                                
                                for (OpportunitySplit opportunitySplitInstance: lstSelectedOpportunity) {
                                    for(Opportunity opportunityInstance : lstUpdatedOpportunity)
                                    {
                                        if(opportunityInstance.Id == opportunitySplitInstance.opportunityId && 
                                           opportunitySplitInstance.splitOwnerId != opportunityInstance.OwnerId)
                                            lstDeletedOpportunitySplits.add(opportunitySplitInstance);
                                    }
                                }
                            }
                        }
                    }
                    
                    // Checking and deleting opportunity splits w.r.t. technical owner
                    if (!lstDeletedOpportunitySplits.isEmpty()) {
                        
                        Database.DeleteResult[] lstOppSplitsDeletedResults = Database.delete(lstDeletedOpportunitySplits, false);
                        Integer iDatabaseUpdateIndex = 0;                       
                        for (Database.DeleteResult sr : lstOppSplitsDeletedResults) {                           
                            if (!sr.isSuccess()) {
                                for(Database.Error err : sr.getErrors()) {
                                    mapNewsObject.get(lstDeletedOpportunitySplits.get(iDatabaseUpdateIndex).OpportunityId).addError(err.getMessage());
                                    //DE28766: Adding log entries - Ashwin
                                    logEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c='Core_OpportunityHandler.opportunityTechnicalOwnerUpdate', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve', Core_sObjectId__c = sr.getId()));
                                }
                            }
                            iDatabaseUpdateIndex++;
                        }
                    }
                    System.debug('****Map of Tech Owner selected - '+mapTechnicalOwnerOpportunity);
                    if (!mapTechnicalOwnerOpportunity.isEmpty()) {
                        
                        // Fetching the list of opportunity team members related to technical owner for role Technical Owner
                        lstUpdateOpportunityTeamMember = [SELECT ID, UserId, OpportunityId,TeamMemberRole FROM OpportunityTeamMember
                                                          WHERE UserId = : mapTechnicalOwnerOpportunity.KeySet() AND TeamMemberRole = :sTechnicalOwner AND OpportunityId IN :setUpdatedOpportunities
                                                         ];
                        //DE28766 - Fixed the Technical Owner Issue - Ashwin
                        system.Debug('#lstUpdateOpportunityTeamMember = ' +lstUpdateOpportunityTeamMember.size() + ' ' +lstUpdateOpportunityTeamMember);
                        
                        // Iterating over the list of Opportunity team members and adding user and related opportunity team members to map
                        if (!lstUpdateOpportunityTeamMember.isEmpty()) {
                            for (OpportunityTeamMember OpportunityTeamMemberInstance: lstUpdateOpportunityTeamMember) {
                                if (mapUserIdOpportunityTeamMember.containsKey(OpportunityTeamMemberInstance.userId))
                                    mapUserIdOpportunityTeamMember.get(OpportunityTeamMemberInstance.userId).add(OpportunityTeamMemberInstance);
                                else
                                    mapUserIdOpportunityTeamMember.put(OpportunityTeamMemberInstance.userId, new List < OpportunityTeamMember > {
                                        OpportunityTeamMemberInstance
                                            });
                            }
                            
                            // Iterating over the list of techncial owner and adding opportunity team members to the list to be deleted
                            for (Id technicalOwnerId: mapTechnicalOwnerOpportunity.keyset()) {
                                if (mapUserIdOpportunityTeamMember.containsKey(technicalOwnerId)) {
                                    List < OpportunityTeamMember > lstSelectedOpportunityTeamMembers = mapUserIdOpportunityTeamMember.get(technicalOwnerId);
                                    List<Opportunity> lstUpdatedOpportunity =  mapTechnicalOwnerOpportunity.get(technicalOwnerId);
                                    
                                    for (OpportunityTeamMember OpportunityTeamMemberInstance: lstSelectedOpportunityTeamMembers) {
                                        for(Opportunity opportunityInstance : lstUpdatedOpportunity)
                                        {
                                            if(opportunityInstance.Id == OpportunityTeamMemberInstance.opportunityId && 
                                               OpportunityTeamMemberInstance.UserID != opportunityInstance.OwnerId){
                                                   lstDeleteOpportunityTeamMembers.add(OpportunityTeamMemberInstance);
                                                   setDeleteOpptyTeamMembers.add(OpportunityTeamMemberInstance.Id);   // Added to pass set of ids to future method for deleting the team members - Ashwin
                                                   System.debug('***Populating the set of OpptyTeamMember Ids'+setDeleteOpptyTeamMembers);
                                               }
                                        }
                                    }
                                    
                                }
                            }
                            
                            // Deleting the list of opportunity team members
                            //Calling the below delete functionality in future method -- Ashwin
                            /*if (!lstDeleteOpportunityTeamMembers.isEmpty()) {

Database.DeleteResult[] lstTeamMembersDeletedResults = Database.delete(lstDeleteOpportunityTeamMembers, false);
Integer iDatabaseUpdateIndex = 0;

for (Database.DeleteResult sr : lstTeamMembersDeletedResults) 
{                    
if (!sr.isSuccess()) 
{
for(Database.Error err : sr.getErrors()) 
{
mapNewsObject.get(lstDeleteOpportunityTeamMembers.get(iDatabaseUpdateIndex).OpportunityId).addError(err.getMessage());
}
}
iDatabaseUpdateIndex++;
}
}*/
                            deleteOpptyTeamMembersFutureMethod(setDeleteOpptyTeamMembers);
                        }
                        
                    }
                }           
            } else {
                // Adding all the opportunities for which opportunity team members needs to created for insert 
                lstUpdatedOpportunities.addAll(mapNewsObject.values());
                
                // Iterating over the list of opportunities to populate opportunity team members and opportunity share records to be inserted
                for (Opportunity opp: lstUpdatedOpportunities) {
                    if (opp.Core_Technical_Owner__c != Null && opp.Core_Technical_Owner__c != opp.OwnerId) {
                        OpportunityTeamMember otm  = new OpportunityTeamMember();
                        otm.TeamMemberRole         = sTechnicalOwner;
                        otm.UserId                 = opp.Core_Technical_Owner__c;
                        otm.OpportunityId          = opp.Id; //Add OpportunityAccessLevel here
                        otm.OpportunityAccessLevel = 'Edit';
                        lstOpportunityTeamMember.add(otm);
                        
                        opptechnicalOwnerId.add(opp.Core_Technical_Owner__c);
                        /*
// Creating an Opportunity Share record and adding it to the list
OpportunityShare opportunityShareInstance = new OpportunityShare();
opportunityShareInstance.OpportunityAccessLevel = System.Label.Core_Edit_Permission;
opportunityShareInstance.UserOrGroupId = opp.Core_Technical_Owner__c;
opportunityShareInstance.OpportunityId = opp.Id;
lstOpportunityShare.add(opportunityShareInstance);
*/
                    }
                }       
            }
            
            // Inserting list of opportunity team members    
            if(!lstOpportunityTeamMember.isEmpty())
            {
                Database.SaveResult[] srList = Database.insert(lstOpportunityTeamMember, false);
                system.debug('srList=>'+srList);// added by suresh palvadi: to check the OppTeamMember creation failing
                Integer iDatabaseUpdateIndex = 0; 
                
                System.debug('mapNewsObject :: '+mapNewsObject.keySet());
                lstOpportunityShare = [Select UserOrGroupId, OpportunityId, OpportunityAccessLevel,
                                       Id From OpportunityShare where OpportunityId IN: mapNewsObject.keySet() and UserOrGroupId In :opptechnicalOwnerId];
                System.debug('lstOpportunityShare :: '+lstOpportunityShare);
                // Capturing the logs for error records
                for (Database.SaveResult sr : srList) 
                {        
                    if (!sr.isSuccess()) 
                    {         
                        for(Database.Error err : sr.getErrors()) 
                        {
                            mapNewsObject.get(lstOpportunityTeamMember.get(iDatabaseUpdateIndex).OpportunityId).addError(err.getMessage());
                            //DE28766: Adding log entries - Ashwin
                            logEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c='Core_OpportunityHandler.opportunityTechnicalOwnerUpdate', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve', Core_sObjectId__c = sr.getId()));
                        }
                    }
                    else {
                        /*for(OpportunityShare oppShare : lstOpportunityShare) {
//Added the below check for read access already being present - Ashwin
if(oppShare.OpportunityAccessLevel != System.Label.Core_Edit_Permission){
oppShare.OpportunityAccessLevel = System.Label.Core_Edit_Permission;
lstOpportunityShareDup.add(oppShare);
}
} 
System.debug('Before update lstOpportunityShare :: '+lstOpportunityShare);
System.debug('Actual records which are being updated - '+lstOpportunityShareDup);
/*if(lstOpportunityShare.size() > 0 && ) {
update lstOpportunityShare;
}*/
                        /*if(!lstOpportunityShareDup.isEmpty()){
update lstOpportunityShareDup;
}
*/   
                        
                    }
                    iDatabaseUpdateIndex++;
                }
            } 
            
            /*
// Inserting list of Opportunity shares    
if(!lstOpportunityShare.isEmpty())
{

Database.SaveResult[] srList = Database.insert(lstOpportunityShare, false);
Integer iDatabaseUpdateIndex = 0; 
// Capturing the logs for error records
for (Database.SaveResult sr : srList) 
{

if (!sr.isSuccess()) 
{
for(Database.Error err : sr.getErrors()) 
{
mapNewsObject.get(lstOpportunityShare.get(iDatabaseUpdateIndex).OpportunityId).addError(err.getMessage());
}
}
iDatabaseUpdateIndex++;
}
}
*/            
            /**/
            
            system.Debug('####mapNewsObject.keySet().size() = ' + mapNewsObject.keySet().size() + ' ' + mapNewsObject.keySet());   
            
            List<OpportunityTeamMember> otmList = [SELECT Id, OpportunityId, TeamMemberRole, UserId, User.IsActive
                                                   FROM OpportunityTeamMember
                                                   WHERE OpportunityId IN :mapNewsObject.keySet()];
            
            system.Debug('####otmList.size() = ' + otmList.size());   
            
            List<OpportunityTeamMember> otmUpdates = new List<OpportunityTeamMember>();                    
            
            for (OpportunityTeamMember otm : otmList)
            {
                // 02/16/16 DH: check added to ensure action is only taken on active team members (otherwise we'll get a hard error)
                if (otm.User.IsActive) {
                    system.debug('ownerID ========>'+mapNewsObject.get(otm.OpportunityId).OwnerId);
                    system.debug('otm.UserId ======>'+otm.UserId);
                    if (mapNewsObject.get(otm.OpportunityId).OwnerId == otm.UserId) {
                        otm.TeamMemberRole = sOpportunityOwner;       
                    }  
                    else if (mapNewsObject.get(otm.OpportunityId).Core_Technical_Owner__c == otm.UserId) {
                        otm.TeamMemberRole = sTechnicalOwner;        
                    }   
                    else {
                        if (otm.TeamMemberRole == sOpportunityOwner || otm.TeamMemberRole == sTechnicalOwner)
                            otm.TeamMemberRole = sTeamMember;
                    }                
                    otmUpdates.add(otm);
                }
            }
            
            update otmUpdates; 
            
            //START - DE28766: Populating the recurssive check map with all processed oppty ids and adding try catch block - Ashwin            
            for(Id opptyIds : mapNewsObject.keySet()){
                uniqueOpptyIdsSet.add(opptyIds);
            }
            
        }catch(Exception e){
            //DE28766: Adding log entries - Ashwin
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c='Core_OpportunityHandler.opportunityTechnicalOwnerUpdate', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
        }finally{
            //US87446 - Cleanup Log Entries - Check to toggle creation of log entries for Sales Evolve - Ashwin
            if(!logEntries.isEmpty() && !logSwitch.isEmpty()){
                if(logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c){
                    insert logEntries;
                }
            }
        }
        //END - DE28766: Populating the recurssive check map with all processed oppty ids and adding try catch block- Ashwin
    }
    
    //START - US58135: OPPTY Defect: Ensure Access is Removed When Technical Owner is Removed From Opportunity | Performing the delete in future method -- Ashwin
    /*
* Method Name : deleteOpptyTeamMembersFutureMethod
* Description : Future method to delete Opportunity Team Members
* Return Type : void
* Parameter   : Set of Opportunity Team members id to be deleted
*/
    @future
    public static void deleteOpptyTeamMembersFutureMethod(Set<Id> setofOpptyTeamMembers){
        //US87446 - Cleanup Log Entries - Check to toggle creation of log entries for Sales Evolve - Ashwin
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();      
        // List to store Opportunity team members to be deleted
        List< OpportunityTeamMember > listDelOpptyMembers = [SELECT id, UserId, OpportunityId, Name, TeamMemberRole FROM OpportunityTeamMember WHERE Id IN :setofOpptyTeamMembers];
        Map<Id,OpportunityTeamMember> delOpptyMembersMap = new Map<Id, OpportunityTeamMember>([SELECT id, UserId, OpportunityId, Name, TeamMemberRole FROM OpportunityTeamMember WHERE Id IN :setofOpptyTeamMembers]);
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        
        if(!listDelOpptyMembers.isEmpty()){  
            Database.DeleteResult[] lstTeamMembersDeletedResults = Database.delete(listDelOpptyMembers, false);         
            for (Database.DeleteResult sr : lstTeamMembersDeletedResults){                    
                if (!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()){
                        //mapNewsObject.get(listDelOpptyMembers.get(iDatabaseUpdateIndex).OpportunityId).addError(err.getMessage());
                        logEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c='Core_OpportunityHandler', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve', Core_sObjectId__c = sr.getId()));
                    }
                }else if(sr.isSuccess()){
                    logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Successfully deleted', Core_Origin__c='Core_OpportunityHandler.deleteOpptyTeamMembersFutureMethod', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve', Core_sObjectId__c = sr.getId()+(String.valueOf(delOpptyMembersMap.get(sr.getId()).OpportunityId)).left(15)));
                }
            }           
        } 
        //US87446 - Cleanup Log Entries - Check to toggle creation of log entries for Sales Evolve - Ashwin
        if(!logEntries.isEmpty() && !logSwitch.isEmpty()){
            if(logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c){
                insert logEntries;
            }
        }
    }
    //END - US58135: OPPTY Defect: Ensure Access is Removed When Technical Owner is Removed From Opportunity | Performing the delete in future method -- Ashwin
    
    /*
* Method name  : isTechnicalOwnerUpdated
* Description  : Ensures that the trigger is running only once during the after update for "TechnicalOwnerUpdate"
* Return Type  : boolean
* Parameter    : NONE

public static boolean isTechnicalOwnerUpdated() {
// Set the bolean to TRUE once the trigger is RUN
if (bTechnicalOwnerUpdate) {
bTechnicalOwnerUpdate = false;
return true;
} else {
return bTechnicalOwnerUpdate;
}
}   
*/
    
    /*
* Method name  : UpdateActivityLineItems
* Description  : Updates the Amount, Volume of all the records in 'Marketing Activity Opportuntiy' object connected to the Opportunities
* Return Type  : void
* Parameter    : List <Opportunity>
*/
    public static void UpdateActivityLineItems(List <Opportunity> lstOpportunities) {
        
        
        // Don't issue SOQL unless there's something to process.
        if (lstOpportunities == NULL || lstOpportunities.size() == 0) 
            return;
        
        // Get the list of IDs of all the updated opportunities
        List<Id> lstOpportunityIds = new List<Id>();
        
        for (Opportunity opp :lstOpportunities) {
            lstOpportunityIds.Add(opp.Id);
        }
        
        
        
        // Get the list of all related marketing activites
        // This also gets the Amount, Volume data from Opportunities
        List<Core_Marketing_Activity_Opportunity__c> lstActivities = [SELECT Id, Core_Opportunity__r.Amount, Core_Opportunity__r.Core_Opportunity_U_Base__c, 
                                                                      Core_Opportunity_Amount__c, Core_Opportunity_Volume__c FROM Core_Marketing_Activity_Opportunity__c
                                                                      WHERE Core_Opportunity__c IN :lstOpportunityIds];
        
        
        
        
        // Update the Amount, Volume of all the related activites
        for (Core_Marketing_Activity_Opportunity__c activity :lstActivities) {
            activity.Core_Opportunity_Amount__c = activity.Core_Opportunity__r.Amount;
            activity.Core_Opportunity_Volume__c = activity.Core_Opportunity__r.Core_Opportunity_U_Base__c;
        }
        
        // Run the DML to update the Amount, Volume of all the related activites
        update lstActivities;
     }
    
    /*
* Method name  : UpdateTerritoryInfoOnOppty
* Description  : Updates Business Units and Specialists, Geographic World Wide, Named/Stategic Accounts on  Opportuntiy' based on territory associated to account.
* Return Type  : void
* Parameter    : List <Opportunity>,Map<Id,Opportunity>, boolean 
*/
    public static void UpdateTerritoryInfoOnOppty(List <Opportunity> lstOpportunities,map<Id,Opportunity> oldMap, boolean isUpdate) {
        list<Id> opptyAccountIdList = new list<Id>();
        list<Id> intelAccountIdList = new list<Id>();
        map<Id,ObjectTerritory2Association> BusinessTerriMap = new map<Id,ObjectTerritory2Association>();
        map<Id,ObjectTerritory2Association> GeographicTerriMap = new map<Id,ObjectTerritory2Association>();
        map<Id,ObjectTerritory2Association> NamedTerriMap = new map<Id,ObjectTerritory2Association>();
        String BusinessTerriType = null,GeographicTerriType = null,NamedTerriType = null;
        map<Id,List<ObjectTerritory2Association>> accountIdTerritorymap = new map<Id,List<ObjectTerritory2Association>>();
        list<ObjectTerritory2Association> territoryList = new list<ObjectTerritory2Association>();
        
        try{
            
            
                for(Opportunity opp : lstOpportunities){
                    // opportyunity record type check is added for New Opportunity record type.
                    if((opp.recordtypeId == label.Core_Opp_New_Opp_Record_Type_Id || opp.recordtypeId == label.Core_Opportunity_Record_Type_Id) 
                       && !(opp.StageName == 'Lost' || opp.StageName == 'Cancelled' || opp.StageName == 'Design Win' 
                            || opp.StageName == 'Production Win' || opp.StageName == 'Production Lost' || opp.StageName == 'Production Cancelled'))
                    {
                        // isUpdate is added to differentiate insert and update call. 
                        if(!isUpdate)
                            opptyAccountIdList.add(opp.AccountId);
                        else  
                            opptyAccountIdList.add(opp.AccountId);
                    }       
                }
                system.debug('***1' + opptyAccountIdList);
            if(TerritoryUpdateCheck){
               TerritoryUpdateCheck =false;
                for(Account a : [Select id, Recordtype.developerName  from account where Id In : opptyAccountIdList]){
                    if(a.Recordtype.developerName  == 'Mastered_Account'){
                        intelAccountIdList.add(a.Id);
                    }
                }
                system.debug('***1' + intelAccountIdList);
                // Territory data is queried.
                
                if(intelAccountIdList.size()>0){
                    for(ObjectTerritory2Association terr : [SELECT Territory2Id,Territory2.Name,ObjectId, Territory2.DeveloperName, Territory2.Territory2Type.MasterLabel FROM ObjectTerritory2Association where ObjectId In : intelAccountIdList ORDER BY Territory2.Name Desc]){
                        if(!accountIdTerritorymap.keySet().contains(terr.ObjectId)){
                            accountIdTerritorymap.put(terr.ObjectId,new List<ObjectTerritory2Association>());
                        }
                        accountIdTerritorymap.get(terr.ObjectId).add(terr); 
                    }
                }
            }
                // Opportunity fields are populated based on territory type.
                
                if(accountIdTerritorymap.size() >0){
                    for(Opportunity opp : lstOpportunities){
                        if((opp.recordtypeId == label.Core_Opp_New_Opp_Record_Type_Id || opp.recordtypeId == label.Core_Opportunity_Record_Type_Id)
                           && !(opp.StageName == 'Lost' || opp.StageName == 'Cancelled' || opp.StageName == 'Design Win'
                                || opp.StageName == 'Production Win' || opp.StageName == 'Production Lost' || opp.StageName == 'Production Cancelled'))
                        {
                            for(ObjectTerritory2Association territ : accountIdTerritorymap.get(opp.AccountId)){
                                if(territ.Territory2.Territory2Type.MasterLabel == 'Business Units and Specialists'){
                                    BusinessTerriType = BusinessTerriType + ' ;' + territ.Territory2.Name;
                                    BusinessTerriMap.put(territ.ObjectId,territ);
                                }   
                                else if(territ.Territory2.Territory2Type.MasterLabel == 'Geographic World Wide'){    
                                    GeographicTerriType = GeographicTerriType + ' ;' + territ.Territory2.Name;
                                    GeographicTerriMap.put(territ.ObjectId,territ);
                                }   
                                else if(territ.Territory2.Territory2Type.MasterLabel == 'Named / Strategic Accounts'){   
                                    NamedTerriType = NamedTerriType + ' ;' + territ.Territory2.Name;
                                    NamedTerriMap.put(territ.ObjectId,territ);
                                }   
                            }       
                            if(isUpdate){
                                system.debug('***test BusinessTerriType' + BusinessTerriType + opp.Core_Business_Unit_Territory__c);
                                system.debug('***test GeographicTerriType' + GeographicTerriType + opp.Core_Geographical_Territory__c);
                                system.debug('***test NamedTerriType' + NamedTerriType + opp.Core_Named_Strategic__c);
                                for(ObjectTerritory2Association territ : accountIdTerritorymap.get(opp.AccountId)){
                                    if(BusinessTerriMap.size() >0 && territ.Territory2.Territory2Type.MasterLabel == 'Business Units and Specialists'){
                                        if(opp.Core_Business_Unit_Territory__c == Null || !(BusinessTerriType.Contains(opp.Core_Business_Unit_Territory__c)) ){
                                            opp.Core_Business_Unit_Territory__c = BusinessTerriMap.get(opp.AccountId).Territory2.Name;
                                            opp.Core_Business_Unit_Territory_Name__c = BusinessTerriMap.get(opp.AccountId).Territory2.DeveloperName;
                                        }
                                    }
                                    else if(GeographicTerriMap.size() >0 && territ.Territory2.Territory2Type.MasterLabel == 'Geographic World Wide'){
                                        if(opp.Core_Geographical_Territory__c == null || !(GeographicTerriType.Contains(opp.Core_Geographical_Territory__c))){
                                            opp.Core_Geographical_Territory__c = GeographicTerriMap.get(opp.AccountId).Territory2.Name;
                                            opp.Core_Geographical_Territory_Name__c = GeographicTerriMap.get(opp.AccountId).Territory2.DeveloperName;
                                        }   
                                    }else if(NamedTerriMap.size() >0 && territ.Territory2.Territory2Type.MasterLabel == 'Named / Strategic Accounts'){
                                        if(opp.Core_Named_Strategic__c == null || !(NamedTerriType.Contains(opp.Core_Named_Strategic__c))){
                                            opp.Core_Named_Strategic__c  = NamedTerriMap.get(opp.AccountId).Territory2.Name;
                                            opp.Core_Named_Strategic_Territory_Name__c = NamedTerriMap.get(opp.AccountId).Territory2.DeveloperName;
                                        }   
                                    } 
                                }   
                            }else{
                                for(ObjectTerritory2Association territ : accountIdTerritorymap.get(opp.AccountId)){
                                    if(BusinessTerriMap.size()>0 && territ.Territory2.Territory2Type.MasterLabel == 'Business Units and Specialists'){
                                        opp.Core_Business_Unit_Territory__c = BusinessTerriMap.get(opp.AccountId).Territory2.Name;
                                        opp.Core_Business_Unit_Territory_Name__c = BusinessTerriMap.get(opp.AccountId).Territory2.DeveloperName;  
                                    }else if(GeographicTerriMap.size()>0 && territ.Territory2.Territory2Type.MasterLabel == 'Geographic World Wide'){
                                        opp.Core_Geographical_Territory__c = GeographicTerriMap.get(opp.AccountId).Territory2.Name;
                                        opp.Core_Geographical_Territory_Name__c = GeographicTerriMap.get(opp.AccountId).Territory2.DeveloperName;
                                    }else if(NamedTerriMap.size()>0 && territ.Territory2.Territory2Type.MasterLabel == 'Named / Strategic Accounts'){
                                        opp.Core_Named_Strategic__c  = NamedTerriMap.get(opp.AccountId).Territory2.Name;
                                        opp.Core_Named_Strategic_Territory_Name__c = NamedTerriMap.get(opp.AccountId).Territory2.DeveloperName;
                                    }
                                }   
                            }   
                        }
                    }
                }
                
            }
        
        catch(Exception ex){
            system.debug('Error in populating territory' + ex.getMessage());
        }
    }
    
    //US83104 - Added changes when opportunity Decision Date/ FCSD changes the Forecast should be re-calculated. - Ashwin
    /*
* Method name  : updateForecastRecs
* Description  : This Method used to create records for Forecast on updation of an Opportunity decision date or first customer ship date, basically doing the recalculation.
* Return Type  : void
* Parameter    : (list<OpportunityLineItem> opplineitem).
*/ 
    public static void updateForecastRecs(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        Set<Id> opptyId = new Set<Id>();
        Set<Id> oliIdSet = new Set<Id>();
        Set<Id> oliStatusIdSet = new Set<Id>();
        List<Core_Opp_FC_Prod_Schedule__c> validForecastList1 = new List<Core_Opp_FC_Prod_Schedule__c>();
        for(Opportunity opp : newList){
            if(opp.Core_Opportunity_Type__c != null && opp.Core_Opportunity_Type__c.containsIgnoreCase('Deal')){
                if((opp.CloseDate != oldMap.get(opp.Id).CloseDate) || (opp.Core_Opportunity_Type__c != oldMap.get(opp.Id).Core_Opportunity_Type__c)){
                    System.debug('***Decision Change - '+(opp.CloseDate != oldMap.get(opp.Id).CloseDate));
                    opptyId.add(opp.Id);
                }
            }else if(opp.Core_Opportunity_Type__c != null && opp.Core_Opportunity_Type__c.containsIgnoreCase('Design')){
                if((opp.Core_First_Customer_Ship_Date__c != oldMap.get(opp.Id).Core_First_Customer_Ship_Date__c) || (opp.Core_Opportunity_Type__c != oldMap.get(opp.Id).Core_Opportunity_Type__c)){
                    System.debug('***Decision Change - '+(opp.Core_First_Customer_Ship_Date__c != oldMap.get(opp.Id).Core_First_Customer_Ship_Date__c));
                    opptyId.add(opp.Id);
                }
            }
        }
        if(!opptyId.isEmpty()){
            List<Core_Opp_FC_Prod_Schedule__c> validForecastList = [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, Core_FC_Vendor__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c IN :opptyId];
            
            if(!validForecastList.isEmpty()){
                delete validForecastList;
                //List<OpportunityLineItem> opptyOLIList = [SELECT id, Core_Vendor__c, Product2Id, OpportunityId, Core_Status__c, Quantity FROM OpportunityLineItem WHERE id IN :oliStatusIdSet];
                List<OpportunityLineItem> opptyOLIList = [SELECT id, Core_Vendor__c, Product2Id, OpportunityId, Core_Status__c, Quantity FROM OpportunityLineItem WHERE OpportunityId IN :opptyId];
                if(!opptyOLIList.isEmpty()){
                    Core_OpportunityLineItemHandler.insertForecastRecords(opptyOLIList, true);
                }
            }           
        }
    }
    
    //US314046-Block selection of existing opportunity while converting a lead
    /*
* Method name  : BlockExistingOppOnLeadConversion
* Description  : This Method used to block selecting existing Opportunity on Lead Conversion.
* Return Type  : void
* Parameter    : List<Opportunity> OppList,map<Id,Opportunity> oldMap.
*/ 
    
    public static void BlockExistingOppOnLeadConversion(List<Opportunity> OppList,map<Id,Opportunity> oldMap){
        System.debug('*****Inside update');
        String BlockOppOnConvertMesg = Label.Core_BlockOpp_OnConvert;
        for(Opportunity opp : OppList){
            if(opp.Core_Lead_Id__c <> null && opp.Core_Lead_Id__c <> oldMap.get(opp.Id).Core_Lead_Id__c){
                System.debug('********Inside If Condition');
                opp.addError(BlockOppOnConvertMesg);
            }
        }
        
    }
    
    
  ////DE63809 : Not getting an error message when user tries to update an historical data with old Solution area field LOV's
    public static void validateSolutionAreaInActiveLOV(List<Opportunity> oppLst)
    {
        List<Opportunity> finalOppList = new List<Opportunity>();
        for(Opportunity opp:oppLst){
            //US596829 : Oppty : Update the validation rule of DE63809
            if(opp.Core_Solution_Area__c <> null && !opp.StageName.equalsIgnoreCase('Design Win') && !opp.StageName.equalsIgnoreCase('Lost') && !opp.StageName.equalsIgnoreCase('Cancelled') && !opp.StageName.equalsIgnoreCase('Production win') && !opp.StageName.equalsIgnoreCase('Production lost')){
                finalOppList.add(opp);
            }
        }
        if(!finalOppList.isEmpty()){
            Schema.DescribeFieldResult fieldSAResult = Opportunity.Core_Solution_Area__c.getDescribe();
            
            List<Schema.PicklistEntry> pleSA = fieldSAResult.getPicklistValues();
            
            set<String> lstSetSA = new set<String>();
            for( Schema.PicklistEntry f : pleSA)
            {
                lstSetSA.add(f.getValue());
            }  
            
            for(Opportunity opp:finalOppList)
            {
                if(!lstSetSA.contains(opp.Core_Solution_Area__c))
                {
                   opp.addError(Label.Core_Solution_Area_Inactive_Lov_Msg); 
                   System.debug('Invalid value of Solution Area as :'+String.valueOf(opp.Core_Solution_Area__c));
                }
            }
        }     
        
    }
   
    //US317032 -This Method used to Restrict the Solution Detail based on Active Lov's
    /*
* Method name  : validateAllActiveLOV
* Description  : This Method used to Restrict the Solution Detail based on Active Lov's.
* Return Type  : void
* Parameter    : List<Opportunity> OppList,map<Id,Opportunity> oldMap,boolean flag.
*/ 
    public static void validateAllActiveLOV(List<Opportunity> opportunityList, Map<Id, Opportunity> oldOppMap, boolean Insertflag){
        
        Set<String> activeSolutionDetLOV = new Set<String> ();
        Set<String> solutionDetailSet;
        List<String> solutionDetailLOV;
        String strSolDet;
        
        activeSolutionDetLOV = Core_Utility.getPicklistValuesSet('Opportunity' , 'Core_Solution_Detail__c');
        // system.debug('@@@@$$$  '+activeSolutionDetLOV);
        for(Opportunity opp : opportunityList){
            solutionDetailSet = new Set<String> (); 
            solutionDetailLOV = new List<String>();
            strSolDet= opp.Core_Solution_Detail__c;
            if((strSolDet != null && Insertflag) || (strSolDet != null && oldOppMap.get(opp.Id).Core_Solution_Detail__c <> strSolDet && !Insertflag)){                
                if(String.isNotBlank(strSolDet)){
                    //After split values can be stored in list
                    solutionDetailLOV = strSolDet.split(';');
                    if(solutionDetailLOV.size() > 0){
                        //Storing all the selected values in Set 
                        solutionDetailSet.addAll(solutionDetailLOV);
                        if(!activeSolutionDetLOV.containsAll(solutionDetailSet)){
                            opp.addError(Label.Core_Restrict_Solution_Detail_Lov, false);
                        }
                    }
                }                
            }
        }
        
    }
    
    //US510857-Implementation of :  Fix for Solution Detail LOV Limits
    /*
* Method name  : SolutionDetailCombine
* Description  : This Method used to combine the Solution Detail IOTG and Solution Detail DCG/CCG.
* Return Type  : void
* Parameter    : List<Opportunity> OppList,map<Id,Opportunity> oldMap.
*/ 
    public static void SolutionDetailCombine(List<Opportunity> opportunityList,Map<Id,Opportunity> oldOppMap){
        
        List<Opportunity> OppSolutionDetailList= new List<Opportunity>();
        
        for(Opportunity Opp : opportunityList){
            if(oldOppMap == null || oldOppMap.isEmpty()){
                system.debug('Opp Insert');
                OppSolutionDetailList.add(Opp);
            }else if(oldOppMap != null && !oldOppMap.isEmpty() && (Opp.Core_Solution_Detail_DCG_CCG__c <> oldOppMap.get(Opp.Id).Core_Solution_Detail_DCG_CCG__c || Opp.Core_Solution_Detail_IOTG__c <> oldOppMap.get(Opp.Id).Core_Solution_Detail_IOTG__c )){
                OppSolutionDetailList.add(Opp);
            }
            
        }
        if(OppSolutionDetailList.size() > 0){
            CombineSolutionDetailIOTG_DCG_CCG(OppSolutionDetailList);
        }    
    }
    
    //US510857-Implementation of :  Fix for Solution Detail LOV Limits
    /*
* Method name  : CombineSolutionDetailIOTG_DCG_CCG
* Description  : This Method used to combine the Solution Detail IOTG and Solution Detail DCG/CCG.
* Return Type  : void
* Parameter    : List<Opportunity> OppList.
*/   
    
    public static void CombineSolutionDetailIOTG_DCG_CCG(List<Opportunity> opportunityList){
        
        
        for(Opportunity Opp : opportunityList){
            if(Opp.Core_Solution_Detail_DCG_CCG__c !=null && Opp.Core_Solution_Detail_IOTG__c !=null){
                opp.Core_Combined_Solution_Detail__c=Opp.Core_Solution_Detail_DCG_CCG__c+';'+Opp.Core_Solution_Detail_IOTG__c;
            }else if(Opp.Core_Solution_Detail_DCG_CCG__c ==null && Opp.Core_Solution_Detail_IOTG__c !=null){
                opp.Core_Combined_Solution_Detail__c=Opp.Core_Solution_Detail_IOTG__c;
                
            }else if(Opp.Core_Solution_Detail_DCG_CCG__c !=null && Opp.Core_Solution_Detail_IOTG__c ==null){
                opp.Core_Combined_Solution_Detail__c=Opp.Core_Solution_Detail_DCG_CCG__c;
                
            }else if(Opp.Core_Solution_Detail_DCG_CCG__c ==null && Opp.Core_Solution_Detail_IOTG__c ==null){
                opp.Core_Combined_Solution_Detail__c=' ';
            }
        }
    }
}