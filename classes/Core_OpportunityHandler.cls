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
*Jerin                      12/16/2022              Adding the New Deal and Design RecordTypeId --Jerin
* Pratik Padwal             03/06/2023              TWC3123-3783- added loss cancel details field in opps line item update code.
* Areefa Banu               26/05/2023              Remove CoE_Engagement_Needed__c and CoE_Status__c code because going forward will provide support in Opportunity Support Request Side
*****************************************************************************************************************************************************************************************************/
public without sharing class Core_OpportunityHandler{ //TWC3123-5359 Added without sharing keyword to fix code scan issue
    
    //Ensures that the trigger is running only once during the after update 
    public static boolean bTechnicalOwnerUpdate = true;
    public static String DESIGN_WIN = 'Design Win';
    public static String DESIGN = 'Design';//Added by Hira
    public static String PRODUCTION_WIN = 'Production Win';//Added by Hira
    public static Boolean kpiBatchCleanupQueued = false;
    public static Set<Id> uniqueOpptyIdsSet = new Set<Id>();   //DE28766: Adding a new Set to check the recurssion of Trigger execution - Ashwin 
    public static final Set<String> Core_Status = new Set<String>{'Lost','Cancelled','Deleted','On Hold','Production Lost','Production Cancelled'};
        public static boolean isExistingOpp = true;
    public static boolean TerritoryUpdateCheck = true;
    public static boolean KPIJSONCheckInsert = true;
    public static Boolean createOppJSONUpdateRecCheck = false;//added by Monisha for recursive check
    public static Boolean UpdateActivityLineItemsRecCheck = false;//added by Monisha for recursive check
    public static Boolean updateInactiveVendorOnUpdateCheck = false;//added by Monisha for recursive check
    public static Boolean oppUniqueValidationRecursion = false;
    public static boolean checkTOonTM = true;

    //public static boolean KPIJSONCheckUpdate = true;
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
        Set<Id> OppIDwithOLI = new Set<Id>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        Map<Id,Opportunity> oppCanclMap = new Map<Id,Opportunity>();
        List<OpportunityLineItem> opplineitemlst = [SELECT Id,OpportunityId, SBQQ__QuoteLine__r.Pricing_Status_Nm__c
                                              FROM OpportunityLineItem
                                              WHERE OpportunityId =:mapNewsObject.values()
                                              AND SBQQ__QuoteLine__r.Pricing_Status_Nm__c IN ('Pending Further Intel Review')//Pending Intel Field Review
                                              AND Opportunity.Core_Opportunity_Coverage_Nm__c=:'Partner-Led Opportunity'
                                              AND Opportunity.Core_Coverage_Type_Nm__c=:'Deal Registration' 
                                              ];
        for (OpportunityLineItem oli : opplineitemlst )
        {           
            OppIDwithOLI.add(oli.OpportunityId);      
        }
        
        for (Opportunity opp : oppsUpdated) {
            String errMsg = 'Stage cannot be set to Lost/Cancelled when Quote Line is in Review';
            if ((((opp.StageName == 'Lost') && (mapOldsObject.get(opp.Id).StageName != 'Lost'))||((opp.StageName == 'Cancelled') && (mapOldsObject.get(opp.Id).StageName != 'Cancelled')))&& OppIDwithOLI.contains(opp.id))
            {               
                opp.addError(errMsg);            
            }
            if ((opp.StageName == 'Lost') && (mapOldsObject.get(opp.Id).StageName != 'Lost')&& !OppIDwithOLI.contains(opp.id)) 
            {               oppIdsLost.add(opp.Id);            
                            oppMap.put(opp.Id, opp);            
            }
            else if ((opp.StageName == 'Cancelled') && (mapOldsObject.get(opp.Id).StageName != 'Cancelled') && !OppIDwithOLI.contains(opp.id) ) 
            {                
                oppIdsCancelled.add(opp.Id);
                oppCanclMap.put(opp.Id, opp);
            }
            else if ((opp.StageName == DESIGN_WIN) && (mapOldsObject.get(opp.Id).StageName != DESIGN_WIN)) {
                oppIdsDesignWin.add(opp.Id);
            }
        }
        
        if (oppIdsLost.size() > 0) {
            List<OpportunityLineItem> oppItemsLost = oppLostCancelledLineItems(oppIdsLost, 'Lost', 'Opportunity Lost',oppMap);
            if (oppItemsLost.size() > 0)
                update oppItemsLost;
            oppSupportRequest(oppIdsLost);
           // if (oppSupportLost.size() > 0)
           //     update oppSupportLost;

        }
        
        if (oppIdsCancelled.size() > 0) {
            List<OpportunityLineItem> oppItemsCancelled = oppLostCancelledLineItems(oppIdsCancelled, 'Cancelled', 'Opportunity Cancelled',oppCanclMap);
            if (oppItemsCancelled.size() > 0)
                update oppItemsCancelled;
            oppSupportRequest(oppIdsCancelled);
         //   if (oppSupportCancelled.size() > 0)
          //      update oppSupportCancelled;
        }
        
    }

    
    private static List<OpportunityLineItem> oppLostCancelledLineItems(Set<Id> oppIds, String status, String reason,Map<Id,Opportunity> opptyMap)
    {   //TWC3123-3783 - Added loss/cancel details field in query.
        List<OpportunityLineItem> oppItems = [SELECT Id, OpportunityId, Core_Status__c, Core_Loss_Cancel_Reason__c, Core_Loss_Cancel_Details__c
                                              FROM OpportunityLineItem
                                              WHERE OpportunityId in :oppIds 
                                              AND Core_Status__c IN ('Pending', 'On Hold')];
        
        for (OpportunityLineItem li : oppItems) {
            li.Core_Status__c = status;
            li.Core_Loss_Cancel_Reason__c = opptyMap.get(li.OpportunityId).Core_Loss_Cancel_Reason__c;
            li.Core_Loss_Cancel_Details__c = opptyMap.get(li.OpportunityId).Core_Loss_Cancel_Details__c;//TWC3123-3783 - Added loss/cancel details field to update.
        }
        
        return oppItems;
    }
    
    private static void oppSupportRequest(Set<Id> oppIds)
    {   
        List<Core_Opportunity_Support__c> oppsuppItems = [SELECT Id,Core_Status__c FROM Core_Opportunity_Support__c 
                                                          WHERE Opportunity__r.id in :oppIds and Core_Status__c in ('Pending','Submitted')];
        
        for (Core_Opportunity_Support__c suppReq : oppsuppItems) {
            suppReq.Core_Status__c = 'Cancelled';
        }
        if(oppsuppItems.size()>0)
        update oppsuppItems;
    }
    
    //Description  : Checks the opp facts & delete them
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
    
    //Description  : Add/Update Opportunity Team Members related to opportunity record based on Technical Owner
    public static void opportunityTechnicalOwnerUpdate(Map < Id, Opportunity > mapOldsObject, Map < Id, Opportunity > mapNewsObject , Boolean isUpdate) {
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
        
        // Map to store opportunity owner Id and opportunity
        Map < Id, List<Opportunity>> mapOpportunityOwnerOpportunity = new Map <Id, List<Opportunity>> (); //TWC3123-7010
        
        // Adding all the opportunities 
        List<Opportunity> lstOwnerOpportunities = new List<Opportunity>(); //TWC3123-7010
        
        // List to store the opportunities for which opportunity team members needs to be created
        List < Opportunity > lstOpportunities = new List < Opportunity > ();
        
        // List to store opportunity splits for opportunity
        List < OpportunitySplit > lstOpportunitySplits = new List < OpportunitySplit > ();
        
        // List to store opportunity splits opportunity owner
        List < OpportunitySplit > lstOpportunityOwnerSplits = new List <OpportunitySplit >();
        
        // Map to store splitOwnerId and Opportunity Split Record
        Map < Id, List < OpportunitySplit >> mapSplitOwnerIdOpportunitySplit = new Map < Id, List < OpportunitySplit >> ();
        
        Map <Id, List <OpportunitySplit >> mapSplitOppOwnerIdOpportunitySplit = new Map < Id, List < OpportunitySplit >> (); //TWC3123-7010
        
        // List to store opportunity splits which needs to be deleted
        List < OpportunitySplit > lstDeletedOpportunitySplits = new List < OpportunitySplit > ();
        
        List < OpportunitySplit > lstDeletedOpportunitySplits1 = new List < OpportunitySplit > (); //TWC3123-7010
        
        // Map to store User Id and list of Opportunity team member records
        Map < Id, List < OpportunityTeamMember >> mapUserIdOpportunityTeamMember = new Map < Id, List < OpportunityTeamMember >> ();
        
        // List to store Opportunity team members to be deleted
        List < OpportunityTeamMember > lstDeleteOpportunityTeamMembers = new List < OpportunityTeamMember > ();
        Set<Id> setDeleteOpptyTeamMembers = new Set<Id>();  // Added to pass set of ids to future method for deleting the team members - Ashwin
        
        // List to store Opportunity share records to be inserted
        List<OpportunityShare> lstOpportunityShare = new List<OpportunityShare>();
        List<OpportunityShare> lstOpportunityShareDup = new List<OpportunityShare>(); //Created for capturing the actual oppty share records to be updated - Ashwin
        
        // Team Constants
        String sOpportunityOwner100 = System.Label.Core_Opportunity_Owner;    // String to store 'Opportunity Owner (100%)' value             
        String sTeamMember          = System.Label.Core_Team_Member;          // String to store 'Team Member' value             
        String sTechnicalOwner      = System.Label.Core_Technical_Owner;      // String to store 'Technical Owner' value 
        String sOpportunityOwner    = 'Opportunity Owner';  //Added by Aashna
        
        
        // Adding all the opportunities for which opportunity team members needs to created for update
        List<Opportunity> lstUpdatedOpportunities = new List<Opportunity>();
        
        SET<ID> setUpdatedOpportunities = new SET<ID>();
        set<id> setOwnerOpportunities = new set<id>(); //TWC3123-7010
        Set<id> opptechnicalOwnerId = new Set<id>();
        set<id> opportunityOwnerId = new set<id>(); //TWC3123-7010
        
        
        //List to store Team Member Records
        List<OpportunityTeamMember> OppTeamMember = [SELECT Id, OpportunityId, TeamMemberRole, UserId, User.IsActive, Core_Description_of_Contribution__c , Core_Production_Win_Member_Role__c,Opportunity.RecordTypeId
                                                     FROM OpportunityTeamMember 
                                                     WHERE OpportunityId IN :mapNewsObject.keyset()];
        
        //Map to store Oppty Team Member's user Id and OpportunityId
        Map<Id, Id> mapTeamMemberIdOpportunityId = new Map<Id, Id>();
        
        Id designRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        

        //------TWC3123-5177---------------end--------------------------------------------------------------------
        
        //US87446 - Cleanup Log Entries - Check to toggle creation of log entries for Sales Evolve - Ashwin
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();      
        
        //DE28766: Adding try catch block- Ashwin
        try{
            // Checking if its an update or insert
            if (!mapOldsObject.isEmpty()) {
                //------TWC3123-5177---------------Start--------------------------------------------------------------------
                //Map to store DDR Opportunity's partner account owner ID 
                Map<Id, Opportunity> getDDRpartnerAccOwnerIdMap = new Map<Id, Opportunity>([SELECT id, Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerId 
                                                                                            FROM Opportunity 
                                                                                            WHERE Opportunity.Core_Opportunity_Coverage_Nm__c='Partner-Led Opportunity' AND 
                                                                                            Core_Design_Registration_Id__c != '' AND id IN :mapNewsObject.keyset()]);
                
                for(OpportunityTeamMember OTM : OppTeamMember){
                    if(getDDRpartnerAccOwnerIdMap.containsKey(OTM.OpportunityId))
                        mapTeamMemberIdOpportunityId.put(OTM.UserId, OTM.OpportunityId);
                }
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
                    
                    //TWC3123-7010 -------- start
					if (mapOldsObject.get(opp.Id).OwnerId != opp.OwnerId) {
                        setOwnerOpportunities.add(opp.Id);
                        lstOwnerOpportunities.add(opp);
                        if(mapOpportunityOwnerOpportunity.containsKey(mapOldsObject.get(opp.Id).OwnerId)) {
                            mapOpportunityOwnerOpportunity.get(mapOldsObject.get(opp.Id).OwnerId).add(opp);
                        }
                        else{
                            mapOpportunityOwnerOpportunity.put(mapOldsObject.get(opp.Id).OwnerId,new List<Opportunity> {opp});
                        }
                        opportunityOwnerId.add(opp.OwnerId);
                    }
                    //TWC3123-7010 -------- End
                    //TWC3123-4957
                    String lstElements =  opp.Core_OpportunityTeamMembers__c != null ? opp.Core_OpportunityTeamMembers__c : '';
                    String[] lstElementsTab = lstElements.split('\\,'); 
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
                            if(opp.recordtypeId == designRecordTypeId){
                            otm.Core_Production_Win_Member_Role__c = sTechnicalOwner;
                            }
                            //TWC3123-4957--defaulting-previous-description-of-contribution------------START--------------------------
                            
                            for(Integer j = 0; j<lstElementsTab.size(); j++)
                            {   
                                if(lstElementsTab[j].contains(otm.userId))
                                {
                                    otm.Core_Description_of_Contribution__c = String.valueOf(lstElementsTab[j].split('\\_')[1].trim());
                                    if(j == lstElementsTab.size()-1){
                                        otm.Core_Description_of_Contribution__c = otm.Core_Description_of_Contribution__c.removeEnd(')');
                                    }
                                }
                            }
                            //TWC3123-4957--------------------------------END----------------------------------------------------------
                            lstOpportunityTeamMember.add(otm);
                        }
                    }
                    /* TWC3123-5177--------------start---------------------------------------------------------------------------------------------
                    * Added for inserting partner account owner whenever  DDR opportunity's oppty owner is getting updated 
                    */ 
                    If(opp.OwnerId!= null && mapOldsObject.get(opp.Id).OwnerId != opp.OwnerId && opp.Core_Opportunity_Coverage_Nm__c=='Partner-Led Opportunity')
                    {
                        OpportunityTeamMember createOppTeamMember = new OpportunityTeamMember();
                        createOppTeamMember.TeamMemberRole = sTeamMember;
                        createOppTeamMember.OpportunityId = opp.id;
                        //If partner account owner is not present in DDR opportunity team, then only insert
                        if(!mapTeamMemberIdOpportunityId.containskey(getDDRpartnerAccOwnerIdMap.get(opp.Id).Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerId))      
                        {
                            createOppTeamMember.userid = getDDRpartnerAccOwnerIdMap.get(opp.Id).Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerId;
                            
                            //TWC3123-4957--defaulting-previous-description-of-contribution------------START-------------------------
                            for(Integer j = 0; j<lstElementsTab.size(); j++)
                            {   
                                if(lstElementsTab[j].contains(createOppTeamMember.userId))
                                {
                                    createOppTeamMember.Core_Description_of_Contribution__c = String.valueOf(lstElementsTab[j].split('\\_')[1].trim());
                                    if(j == lstElementsTab.size()-1){
                                        createOppTeamMember.Core_Description_of_Contribution__c = createOppTeamMember.Core_Description_of_Contribution__c.removeEnd(')');
                                    }
                                }
                            } 
                            //TWC3123-4957--------------------------------END----------------------------------------------------------
                            lstOpportunityTeamMember.add(createOppTeamMember);
                        }
                    }
                    //TWC3123-5177--------------end-------------------------------------------------------------------------------------------------
                }
                
                // Checking whether technical owner map is empty
                if (!mapTechnicalOwnerOpportunity.isEmpty()) {
                    
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
                                    //TWC3123-4861
                                    logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = err.getMessage(), Core_Origin__c='Core_OpportunityHandler.opportunityTechnicalOwnerUpdate', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve', Core_sObjectId__c = sr.getId()));
                                }
                            }
                            iDatabaseUpdateIndex++;
                        }
                    }
                    
                    if (!mapTechnicalOwnerOpportunity.isEmpty()) {
                        //Removed Query as we have 1 query on OTM above in method line #227 List<OpportunityTeamMember> OppTeamMember
                        /*lstUpdateOpportunityTeamMember = [SELECT ID, UserId, OpportunityId,TeamMemberRole FROM OpportunityTeamMember
WHERE UserId = : mapTechnicalOwnerOpportunity.KeySet() AND TeamMemberRole = :sTechnicalOwner AND OpportunityId IN :setUpdatedOpportunities
];*/
                        
                        //Fetching the list of opportunity team members related to technical owner for role Technical Owner
                        for(OpportunityTeamMember otm: OppTeamMember){
                            If(otm.TeamMemberRole == sTechnicalOwner && setUpdatedOpportunities.contains(otm.OpportunityId) && mapTechnicalOwnerOpportunity.containsKey(otm.UserId))
                            {
                                lstUpdateOpportunityTeamMember.add(otm);
                            }
                        }
                        
                        //DE28766 - Fixed the Technical Owner Issue - Ashwin
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
                                                   
                                               }
                                        }
                                    }
                                    
                                }
                            }
                            
                            // Deleting the list of opportunity team members
                            
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
                        if(opp.recordtypeId == designRecordTypeId){
                        otm.Core_Production_Win_Member_Role__c = sTechnicalOwner;
                        }
                        lstOpportunityTeamMember.add(otm);
                        
                        opptechnicalOwnerId.add(opp.Core_Technical_Owner__c);
                    }
                }       
            }
            
            //TWC3123-7010 -------- start
            if (!mapOpportunityOwnerOpportunity.isEmpty()) {
                    
                    // Fetching Opportunity splits for the opportunity
                    lstOpportunityOwnerSplits = [SELECT OpportunityId, SplitOwnerId from OpportunitySplit Where OpportunityId IN: setOwnerOpportunities];
                    
                    // Checking whether opportunity splits list is empty
                    if (!lstOpportunityOwnerSplits.isEmpty()) {
                        
                        // Iterating over the list of opportunity splits and creating a map for split owner and opportunity split
                        for (OpportunitySplit opportunitySplitInstance: lstOpportunityOwnerSplits) {
                            if (mapSplitOppOwnerIdOpportunitySplit.containsKey(opportunitySplitInstance.splitOwnerId))
                                mapSplitOppOwnerIdOpportunitySplit.get(opportunitySplitInstance.splitOwnerId).add(opportunitySplitInstance);
                            else
                                mapSplitOppOwnerIdOpportunitySplit.put(opportunitySplitInstance.splitOwnerId, new List < OpportunitySplit > {
                                    opportunitySplitInstance
                                        });
                        }
                    }
                
                if (!mapSplitOppOwnerIdOpportunitySplit.isEmpty()) {
                        // Iterating over Opportunity Owners and checking if Opportunity owner is having opportunity split 
                        for (Id OppOwnerId: mapOpportunityOwnerOpportunity.keyset()) {
                            
                            if (mapSplitOppOwnerIdOpportunitySplit.containsKey(OppOwnerId)) {
                                List < OpportunitySplit > lstOpportunity = mapSplitOppOwnerIdOpportunitySplit.get(OppOwnerId); //7010 list
                                List<Opportunity> lstUpdatedOpportunity1 =  mapOpportunityOwnerOpportunity.get(OppOwnerId);
                                
                                for (OpportunitySplit opportunitySplitInstance: lstOpportunity) {
                                    for(Opportunity opportunityInstance : lstUpdatedOpportunity1)
                                    {
                                        if(opportunityInstance.Id == opportunitySplitInstance.opportunityId && 
                                           opportunitySplitInstance.splitOwnerId != opportunityInstance.OwnerId)
                                            lstDeletedOpportunitySplits1.add(opportunitySplitInstance);
                                    }
                                }
                            }
                        }
                    }
                
                    // Checking and deleting opportunity splits w.r.t. Opportunity Owner
                    if (!lstDeletedOpportunitySplits1.isEmpty()) {
                        Database.DeleteResult[] lstOppSplitsDeletedResults1 = Database.delete(lstDeletedOpportunitySplits1, false);
                        Integer iDatabaseUpdateIndex1 = 0;                       
                        for (Database.DeleteResult sr : lstOppSplitsDeletedResults1) {                           
                            if (!sr.isSuccess()) {
                                for(Database.Error err : sr.getErrors()) {
                                    mapNewsObject.get(lstDeletedOpportunitySplits1.get(iDatabaseUpdateIndex1).OpportunityId).addError(err.getMessage());
                                    //DE28766: Adding log entries - Ashwin
                                    //TWC3123-4861
                                    //logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = err.getMessage(), Core_Origin__c='Core_OpportunityHandler.opportunityTechnicalOwnerUpdate', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve', Core_sObjectId__c = sr.getId()));
                                }
                            }
                            iDatabaseUpdateIndex1++;
                        }
                    }                
            }   
            //TWC3123-7010 --------- End    
                
            // Inserting list of opportunity team members   
            if(!lstOpportunityTeamMember.isEmpty())
            {
                Database.SaveResult[] srList = Database.insert(lstOpportunityTeamMember, false);
                Integer iDatabaseUpdateIndex = 0; 
                
                // lstOpportunityShare = [Select UserOrGroupId, OpportunityId, OpportunityAccessLevel,
                //                        Id From OpportunityShare where OpportunityId IN: mapNewsObject.keySet() and UserOrGroupId In :opptechnicalOwnerId];
                // Capturing the logs for error records
                for (Database.SaveResult sr : srList) 
                {        
                    if (!sr.isSuccess()) 
                    {         
                        for(Database.Error err : sr.getErrors()) 
                        {
                            mapNewsObject.get(lstOpportunityTeamMember.get(iDatabaseUpdateIndex).OpportunityId).addError(err.getMessage());
                            //DE28766: Adding log entries - Ashwin
                            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = err.getMessage(), Core_Origin__c='Core_OpportunityHandler.opportunityTechnicalOwnerUpdate', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve', Core_sObjectId__c = sr.getId()));
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
            
            //Removed Query as we have same query above in method line #227 List<OpportunityTeamMember> OppTeamMember
            /*List<OpportunityTeamMember> otmList = [SELECT Id, OpportunityId, TeamMemberRole, UserId, User.IsActive,Core_Description_of_Contribution__c
FROM OpportunityTeamMember
WHERE OpportunityId IN :mapNewsObject.keySet()];*/
            
            
            List<OpportunityTeamMember> otmUpdates = new List<OpportunityTeamMember>();
            
            for (OpportunityTeamMember otm : OppTeamMember)
            {
                // 02/16/16 DH: check added to ensure action is only taken on active team members (otherwise we'll get a hard error)
                // 03/10/2025 --  added isUpdate check to make sure during Update trigger this code wont run unless owners are changed
                if ((otm.User.IsActive && !isUpdate ) ||  ( otm.User.IsActive && isUpdate && ((mapOldsObject.get(otm.OpportunityId).Core_Technical_Owner__c != mapNewsObject.get(otm.OpportunityId).Core_Technical_Owner__c)
                                || (mapOldsObject.get(otm.OpportunityId).OwnerId != mapNewsObject.get(otm.OpportunityId).OwnerId) )) ) {
                    if (mapNewsObject.get(otm.OpportunityId).OwnerId == otm.UserId) {
                        otm.TeamMemberRole = sOpportunityOwner100;
                        if(otm.Opportunity.RecordTypeId == designRecordTypeId){
                        otm.Core_Production_Win_Member_Role__c = sOpportunityOwner100;
                        }
                        //otm.Core_Description_of_Contribution__c = otm.TeamMemberRole;//TWC3123-4906 Logic already covered in Core_Oppty_TeamMember_DescUpdate flow
                        otmUpdates.add(otm);
                    }  
                    else if (mapNewsObject.get(otm.OpportunityId).Core_Technical_Owner__c == otm.UserId) {
                        otm.TeamMemberRole = sTechnicalOwner;
                        if(otm.Opportunity.RecordTypeId == designRecordTypeId){
                        otm.Core_Production_Win_Member_Role__c = sTechnicalOwner;
                        }
                        otmUpdates.add(otm);
                    }   
                    else {
                        if ((otm.TeamMemberRole == sOpportunityOwner100 || otm.TeamMemberRole == sOpportunityOwner || otm.TeamMemberRole == sTechnicalOwner)
                            && ((mapOldsObject.get(otm.OpportunityId).Core_Technical_Owner__c != mapNewsObject.get(otm.OpportunityId).Core_Technical_Owner__c)
                                || (mapOldsObject.get(otm.OpportunityId).OwnerId != mapNewsObject.get(otm.OpportunityId).OwnerId) )
                            && (mapOldsObject.get(otm.OpportunityId).OwnerId == otm.UserId 
                                ||mapOldsObject.get(otm.OpportunityId).Core_Technical_Owner__c == otm.UserId  ))
                        {
                            otm.TeamMemberRole = sTeamMember;
                            otm.Core_Description_of_Contribution__c = '';//Blank out Core_Description_of_Contribution__c for old Opp Owner
                            if(otm.Opportunity.RecordTypeId == designRecordTypeId){
                            otm.Core_Production_Win_Member_Role__c = sTeamMember;
                            
                            }
                            otmUpdates.add(otm);
                        }
                    }                
                    //otmUpdates.add(otm);
                }
            }
            
            if (!otmUpdates.isEmpty()) {
                // update otmUpdates; 
                Database.SaveResult[] srListUpdates = Database.update(otmUpdates, false);
            } 
            
            //START - DE28766: Populating the recurssive check map with all processed oppty ids and adding try catch block - Ashwin            
            for(Id opptyIds : mapNewsObject.keySet()){
                uniqueOpptyIdsSet.add(opptyIds);
            }
            
        }catch(Exception e){
            //DE28766: Adding log entries - Ashwin
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = e.getMessage(), Core_Origin__c='Core_OpportunityHandler.opportunityTechnicalOwnerUpdate', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));          
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
    //Description : Future method to delete Opportunity Team Members
    
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
                        logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = err.getMessage(), Core_Origin__c='Core_OpportunityHandler', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve', Core_sObjectId__c = sr.getId()));
                    }
                }else if(sr.isSuccess()){
                    logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Successfully deleted', Core_Origin__c='Core_OpportunityHandler.deleteOpptyTeamMembersFutureMethod', Core_Severity__c='info', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve', Core_sObjectId__c = sr.getId()+(String.valueOf(delOpptyMembersMap.get(sr.getId()).OpportunityId)).left(15))); //changed Core_Severity__c from High to info as part of TWC4767-4319
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
    
    //Description  : Updates the Amount, Volume of all the records in 'Marketing Activity Opportuntiy' object connected to the Opportunities
    
    public static void UpdateActivityLineItems(List <Opportunity> lstOpportunities) {
        if(!UpdateActivityLineItemsRecCheck){
            
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
            UpdateActivityLineItemsRecCheck = true;
        }
    }
    
    //Description  : Updates Business Units and Specialists, Geographic World Wide, Named/Stategic Accounts on  Opportuntiy' based on territory associated to account.
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
            
            Id dealRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
            Id designRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
            // Adding the New Deal and Design RecordTypeId --Jerin
            for(Opportunity opp : lstOpportunities){
                // opportyunity record type check is added for New Opportunity record type.
                if((opp.recordtypeId == dealRecordTypeId || opp.recordtypeId == designRecordTypeId) 
                   && !(opp.StageName == 'Lost' || opp.StageName == 'Cancelled' || opp.StageName == 'Design Win' 
                        || opp.StageName == 'Production Win' || opp.StageName == 'Production Lost' || opp.StageName == 'Production Cancelled')){
                            // isUpdate is added to differentiate insert and update call. 
                            if(!isUpdate)
                                opptyAccountIdList.add(opp.AccountId);
                            else  
                                opptyAccountIdList.add(opp.AccountId);
                        }       
            }
            
            if(TerritoryUpdateCheck){
                TerritoryUpdateCheck =false;
                for(Account a : [Select id, Recordtype.developerName  from account where Id In : opptyAccountIdList]){
                    if(a.Recordtype.developerName  == 'Mastered_Account'){
                        intelAccountIdList.add(a.Id);
                    }
                }
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
            // Adding the New Deal and Design RecordTypeId --Jerin
            if(accountIdTerritorymap.size() >0){
                for(Opportunity opp : lstOpportunities){
                    if((opp.recordtypeId == dealRecordTypeId || opp.recordtypeId == designRecordTypeId)
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
        PMP_Utility.logError(ex, 'Core_OpportunityHandler.UpdateTerritoryInfoOnOppty');
            
        }
    }
    
    //Description  : This Method used to lock the fields after opportunity is approved
    public static void ValidateLockFields(List <Opportunity> lstOpportunities,map<Id,Opportunity> oldMap) {
        Id designRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        String ErrorMsg = Label.Core_LockFields_ErrorMsg;
        for(Opportunity opp : lstOpportunities){
            if(opp.Core_Approval_Status__c == 'Approved' && oldMap.get(opp.Id).Core_Approval_Status__c == 'Approved'){
                List<String> Fields_API_List = System.Label.Core_Locked_Fields_API_Name.split(',');
                
                
                for (String str : Fields_API_List) {
                    if(opp.get(str) != oldMap.get(opp.Id).get(str)){
                        opp.addError(ErrorMsg);
                    }
                }
            }
            
            if((opp.StageName == 'Design Win' && oldMap.get(opp.Id).StageName == 'Design Win')||
               (opp.StageName == 'Production Win' && oldMap.get(opp.Id).StageName == 'Production Win')||
               (opp.StageName == 'Lost' && oldMap.get(opp.Id).StageName == 'Lost')||
               (opp.StageName == 'Cancelled' && oldMap.get(opp.Id).StageName == 'Cancelled')||
               (opp.StageName == 'Production Lost' && oldMap.get(opp.Id).StageName == 'Production Lost')||
               (opp.StageName == 'Production Cancelled' && oldMap.get(opp.Id).StageName == 'Production Cancelled')||
               (opp.StageName == 'Group Cancelled' && oldMap.get(opp.Id).StageName == 'Group Cancelled')||
               (opp.StageName == 'Group Closed' && oldMap.get(opp.Id).StageName == 'Group Closed')){
                   
                   List<String> Fields_API_List = System.Label.Core_CoE_Status_Locked.split(',');
                   
                   
                   for (String str : Fields_API_List) {
                       if(opp.get(str) != oldMap.get(opp.Id).get(str)){
                           opp.addError(ErrorMsg);
                       }
                   }
               }
            String field_api = Core_CRM_Utility.getCRMLabel('field_api_name');
            
            if(opp.StageName == 'Production Win' && opp.RecordTypeId == designRecordTypeId && opp.get(field_api) != oldMap.get(opp.Id).get(field_api) ){ opp.addError(ErrorMsg);   }
            
        }
    }
    
    //US83104 - Added changes when opportunity Decision Date/ FCSD changes the Forecast should be re-calculated. - Ashwin
    //Description  : This Method used to create records for Forecast on updation of an Opportunity decision date or first customer ship date, basically doing the recalculation.
    
    public static void updateForecastRecs(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        Set<Id> opptyId = new Set<Id>();
        Set<Id> oliIdSet = new Set<Id>();
        Set<Id> oliStatusIdSet = new Set<Id>();
        String oppDealRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
        String oppDesignRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        List<Core_Opp_FC_Prod_Schedule__c> validForecastList1 = new List<Core_Opp_FC_Prod_Schedule__c>();
        
        for(Opportunity opp : newList){
            if(opp.Core_Opportunity_Type__c != null && opp.RecordTypeId==oppDealRecordTypeId){
                if((opp.CloseDate != oldMap.get(opp.Id).CloseDate) || (opp.Core_Opportunity_Type__c != oldMap.get(opp.Id).Core_Opportunity_Type__c)){
                    opptyId.add(opp.Id);
                }
            }/*else if(opp.Core_Opportunity_Type__c != null && opp.RecordTypeId==oppDesignRecordTypeId){
if((opp.Core_First_Customer_Ship_Date__c != oldMap.get(opp.Id).Core_First_Customer_Ship_Date__c) || (opp.Core_Opportunity_Type__c != oldMap.get(opp.Id).Core_Opportunity_Type__c)){

opptyId.add(opp.Id);
}*/
            // }
        }
        if(!opptyId.isEmpty()){
            List<Core_Opp_FC_Prod_Schedule__c> validForecastList = [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, Core_FC_Vendor__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c IN :opptyId];
            
            if(!validForecastList.isEmpty()){
                delete validForecastList;
                //List<OpportunityLineItem> opptyOLIList = [SELECT id, Core_Vendor__c, Product2Id, OpportunityId, Core_Status__c, Quantity FROM OpportunityLineItem WHERE id IN :oliStatusIdSet];
                List<OpportunityLineItem> opptyOLIList = [SELECT id, Core_Vendor__c, Product2Id, OpportunityId, Core_Status__c, Quantity FROM OpportunityLineItem WHERE OpportunityId IN :opptyId];
                if(!opptyOLIList.isEmpty()){
                    Core_OpportunityLineItemHandler.insertForecastRecords(opptyOLIList,new List<Core_Opp_FC_Prod_Schedule__c>(),true);
                }
            }           
        }
    }
    
    //US314046-Block selection of existing opportunity while converting a lead
    //Description  : This Method used to block selecting existing Opportunity on Lead Conversion.
    
    /*public static void BlockExistingOppOnLeadConversion(List<Opportunity> OppList,map<Id,Opportunity> oldMap){
        String BlockOppOnConvertMesg = Label.Core_BlockOpp_OnConvert;
        for(Opportunity opp : OppList){
            if(opp.Core_Lead_Id__c <> null && opp.Core_Lead_Id__c <> oldMap.get(opp.Id).Core_Lead_Id__c){
                opp.addError(BlockOppOnConvertMesg);
            }
        }
        
    }*/
    
    
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
            for( Schema.PicklistEntry f : pleSA) {
                lstSetSA.add(f.getValue());
            }  
            for(Opportunity opp:finalOppList) {
                if(!lstSetSA.contains(opp.Core_Solution_Area__c)) {
                    opp.addError(Label.Core_Solution_Area_Inactive_Lov_Msg); 
                }
            }
        }     
        
    }
    
    //US317032 -This Method used to Restrict the Solution Detail based on Active Lov's
    //Description  : This Method used to Restrict the Solution Detail based on Active Lov's.
    
    public static void validateAllActiveLOV(List<Opportunity> opportunityList, Map<Id, Opportunity> oldOppMap, boolean Insertflag){
        
        Set<String> activeSolutionDetLOV = new Set<String> ();
        Set<String> solutionDetailSet;
        List<String> solutionDetailLOV;
        String strSolDet;
        
        activeSolutionDetLOV = Core_Utility.getPicklistValuesSet('Opportunity' , 'Core_Solution_Detail__c');
        for(Opportunity opp : opportunityList) {
            solutionDetailSet = new Set<String> (); 
            solutionDetailLOV = new List<String>();
            strSolDet= opp.Core_Solution_Detail__c;
            if((strSolDet != null && Insertflag) || (strSolDet != null && oldOppMap.get(opp.Id).Core_Solution_Detail__c <> strSolDet && !Insertflag)) {                
                if(String.isNotBlank(strSolDet)) {
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
    //Description  : This Method used to combine the Solution Detail IOTG and Solution Detail DCG/CCG.
    
    public static void SolutionDetailCombine(List<Opportunity> opportunityList,Map<Id,Opportunity> oldOppMap) {
        List<Opportunity> OppSolutionDetailList= new List<Opportunity>();
        for(Opportunity Opp : opportunityList) {
            if(oldOppMap == null || oldOppMap.isEmpty()) { OppSolutionDetailList.add(Opp); } 
            else if(oldOppMap != null && !oldOppMap.isEmpty() && (Opp.Core_Solution_Detail_DCG_CCG__c <> oldOppMap.get(Opp.Id).Core_Solution_Detail_DCG_CCG__c || Opp.Core_Solution_Detail_IOTG__c <> oldOppMap.get(Opp.Id).Core_Solution_Detail_IOTG__c )) { OppSolutionDetailList.add(Opp); }   
        }
        if(OppSolutionDetailList.size() > 0) { CombineSolutionDetailIOTG_DCG_CCG(OppSolutionDetailList); }    
    }
    
    //US510857-Implementation of :  Fix for Solution Detail LOV Limits
    //Description  : This Method used to combine the Solution Detail IOTG and Solution Detail DCG/CCG.
    
    public static void CombineSolutionDetailIOTG_DCG_CCG(List<Opportunity> opportunityList) { 
        for(Opportunity Opp : opportunityList) {
            if(Opp.Core_Solution_Detail_DCG_CCG__c !=null && Opp.Core_Solution_Detail_IOTG__c !=null) {
                opp.Core_Combined_Solution_Detail__c=Opp.Core_Solution_Detail_DCG_CCG__c+';'+Opp.Core_Solution_Detail_IOTG__c;
            }else if(Opp.Core_Solution_Detail_DCG_CCG__c ==null && Opp.Core_Solution_Detail_IOTG__c !=null) {
                opp.Core_Combined_Solution_Detail__c=Opp.Core_Solution_Detail_IOTG__c;
                
            }else if(Opp.Core_Solution_Detail_DCG_CCG__c !=null && Opp.Core_Solution_Detail_IOTG__c ==null) {
                opp.Core_Combined_Solution_Detail__c=Opp.Core_Solution_Detail_DCG_CCG__c;
                
            }else if(Opp.Core_Solution_Detail_DCG_CCG__c ==null && Opp.Core_Solution_Detail_IOTG__c ==null) {
                opp.Core_Combined_Solution_Detail__c=' ';
            }
        }
    }
    
    //Description  : This Method used to update opportunity risk reason when the product risk reason changes.
    public static void createOppJSONInsert(List<Opportunity> opportunityList) { //US661969
        List<String> oppId = new List<String>();
        for(Opportunity Opp: opportunityList) {
            //Areefa: Exclude PCC Deal Reg
           if(!(Opp.Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity' && 
            Opp.Core_Coverage_Type_Nm__c == 'Deal Registration')){
                oppId.add(Opp.id);
            }
        }
        if(oppId.size()>0){
            if(!System.isBatch()) {
                if(KPIJSONCheckInsert){ 
                KPIJSONCheckInsert = false;
                oppKPIJSON(oppId);
               }
            }
        }
    }
    
    //Description  : This Method used to update opportunity risk reason when the product risk reason changes.
    public static void createOppJSONUpdate(List<Opportunity> opportunityList, Map<Id, Opportunity> oldOppMap) { //US661969
        boolean ucdSwitch = Core_CRM_Utility.isUCDSwitchOn(); //TWC4767-3431 - implementation of UCD and CIM logic switch 
        
        List<Id> OppIdlist = new List<Id>();
        for(Opportunity opp:opportunityList){
             OppIdlist.add(opp.id);
        }
        if(!createOppJSONUpdateRecCheck){
            List<String> oppId = new List<String>();
            Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
            List<OpportunityLineItem> OppItemList = [SELECT Core_product2_division__c,Core_BU_Product_Segment__c,Core_BU_Short_Name__c,Core_Division__c,Core_Product_Application__c,Core_Product_Segment__c,Core_Product_Type__c,Id,OpportunityId 
                                                     FROM OpportunityLineItem 
                                                     where OpportunityId IN: OppIdlist 
                                                     and Core_Status__c!=:Label.Core_LineItem_Status];
            Map<id,List<OpportunityLineItem>> mapOppLineItem = new Map<id,List<OpportunityLineItem>>();
            if(OppItemList.size()>0) {
                for(OpportunityLineItem oppLineRec : OppItemList) {
                    if(mapOppLineItem.containsKey(oppLineRec.OpportunityId)) { mapOppLineItem.get(oppLineRec.OpportunityId).add(oppLineRec); } 
                    else { mapOppLineItem.put(oppLineRec.OpportunityId,new List<OpportunityLineItem>{oppLineRec}); }
                }
            }
            //TWC3123-610 change end
            
            for(Opportunity Opp: opportunityList){  
                //NK- Fixed BU Mapping PROD IssueCore_IPS_Opportunity_PAR_Handler
                //TWC3123-610 chnage start
				//TWC4767-3431 - implementation of UCD and CIM logic switch
                boolean checkDiffEitherInUCDNameOrPrimeName = (ucdswitch == true) ? (Opp.accountId <> oldOppMap.get(Opp.Id).accountId) : (Opp.Core_Opp_Prime_Account_Name__c<> oldOppMap.get(Opp.Id).Core_Opp_Prime_Account_Name__c);
                if(Opp.core_product_segment__c <> oldOppMap.get(Opp.Id).core_product_segment__c || Opp.Core_Product_Application__c <> oldOppMap.get(Opp.Id).Core_Product_Application__c)
                {
                    if (mapFunctionalityNameTriggerExecution.containsKey('set_BUShortName') && mapFunctionalityNameTriggerExecution.get('set_BUShortName').Core_Active__c){
                        Core_OppLineItem_Batch_Helper.WrapperHelper wrap = Core_OppLineItem_Batch_Helper.prepareBuMappingTable();
                        Core_BU_Mapping_Table__c finalBuMap;
                        List<OpportunityLineItem> failedList= new List<OpportunityLineItem>();
                        if(!wrap.extKeyWithBuMap.isEmpty() && !mapOppLineItem.isEmpty()) {
                            for(OpportunityLineItem oppLineItem : mapOppLineItem.get(opp.id)) {
                                finalBuMap = Core_OppLineItem_Batch_Helper.buShortNmUpdateLogic(oppLineItem, wrap);
                                if(finalBuMap == null){failedList.add(oppLineItem);}
                                else{oppLineItem.Core_BU_Mapping_record__c = finalBuMap.Id;}
                            }
                            
                            try{
                                Database.update(OppItemList);
                                oppId.add(Opp.id);
                            }
                            catch(Exception ex) {Core_OpportunityLineItemHandler.Insert_logexception(OppItemList,ex.getmessage());}
                        }
                    }
                }
                //TWC3123-610 change end  
                //Areefa: Exclude PCC Deal Reg             
                else if((Opp.Core_Solution_Detail_IOTG__c <> oldOppMap.get(Opp.Id).Core_Solution_Detail_IOTG__c || 
                        Opp.core_solution_type__c <> oldOppMap.get(Opp.Id).core_solution_type__c || 
                        Opp.core_solution_detail_dcg_ccg__c <> oldOppMap.get(Opp.Id).core_solution_detail_dcg_ccg__c || 
                        Opp.core_solution_area__c <> oldOppMap.get(Opp.Id).core_solution_area__c || 
                        //TWC3123-610 change start
                        //Opp.core_product_segment__c <> oldOppMap.get(Opp.Id).core_product_segment__c ||
                        //Opp.Core_Product_Application__c <> oldOppMap.get(Opp.Id).Core_Product_Application__c ||
                        //TWC3123-610 change end
                        //Opp.Core_Opp_Prime_Account_Name__c <> oldOppMap.get(Opp.Id).Core_Opp_Prime_Account_Name__c || 
                        checkDiffEitherInUCDNameOrPrimeName || //TWC4767-3431
                        Opp.core_opportunity_type__c <> oldOppMap.get(Opp.Id).core_opportunity_type__c ||
                        //Opp.core_opportunity_products__c <> oldOppMap.get(Opp.Id).core_opportunity_products__c ||
                        Opp.core_exclude_from_KPIs__c <> oldOppMap.get(Opp.Id).core_exclude_from_KPIs__c ||
                        Opp.Core_Consumption_Market__c <> oldOppMap.get(Opp.Id).Core_Consumption_Market__c ||
                        Opp.core_commissionable__c <> oldOppMap.get(Opp.Id).core_commissionable__c ||
                        Opp.core_athena_candidate__c <> oldOppMap.get(Opp.Id).core_athena_candidate__c ||
                        Opp.core_architecture_conversion__c <> oldOppMap.get(Opp.Id).core_architecture_conversion__c ||
                        Opp.CloseDate <> oldOppMap.get(Opp.Id).CloseDate ||
                        Opp.Opportunity_Focus__c <> oldOppMap.get(Opp.Id).Opportunity_Focus__c || //TWC3123-6044
                        Opp.Core_First_Customer_Ship_Date__c <> oldOppMap.get(Opp.Id).Core_First_Customer_Ship_Date__c) &&
                       !(Opp.Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity' &&  Opp.Core_Coverage_Type_Nm__c == 'Deal Registration')){
                            oppId.add(Opp.id);
                        }
                
            }
            if(oppId.size()>0) {
                if(!System.isBatch()) {
                    if(KPIJSONCheckInsert) 
                    { 
                    KPIJSONCheckInsert = false;
                    oppKPIJSON(oppId);
                     }
                }
            }
            createOppJSONUpdateRecCheck=true;
        }
    } 
    
    /*Opportunity Solution Area - 17/10/22 Start*/ 
    
    public static void createJSONSolutionArea(List<Opportunity_Solution_Area__c> oppSolutionArea){
        List<String> oppId = new List<String>();
        List<String> oppIdForKPI = new List<String>();
        //Areefa: Exclude PCC Deal Reg
        for(Opportunity_Solution_Area__c OppSA: oppSolutionArea){           
            oppId.add(OppSA.Core_Opportunity__c);              
        }
        if(oppId.size()>0) {
            for (Opportunity allOppKPI: [SELECT ID FROM Opportunity WHERE Id IN :oppId and (Core_Opportunity_Coverage_Nm__c!='Partner-Led Opportunity' or
                                              Core_Coverage_Type_Nm__c !='Deal Registration')
                                             ]) {
                                                 oppIdForKPI.add(allOppKPI.Id);
                                             }
            if(!System.isBatch() && oppIdForKPI.Size() > 0) {
                if(KPIJSONCheckInsert)
                 { KPIJSONCheckInsert = false;
                  oppKPIJSON(oppIdForKPI); }
            }
        }
    }
    
    public static void updateJSONSolutionArea(List<Core_Solution_Areas__c> newSolutionArea, Map<Id, Core_Solution_Areas__c> oldSolutionArea){
        List<String> oppId = new List<String>();
        Set<Id> saIds = new Set<Id>();
        List<Opportunity_Solution_Area__c> getOppSA= new List<Opportunity_Solution_Area__c>();
        try{
            if(newSolutionArea.size()>0)  {
                for(Core_Solution_Areas__c OppSA: newSolutionArea) {
                    if(OppSA.Core_Industry_Use_Case__c != oldSolutionArea.get(OppSA.Id).Core_Industry_Use_Case__c || OppSA.Core_Application_Workload__c != oldSolutionArea.get(OppSA.Id).Core_Application_Workload__c || OppSA.Core_Technology_Enabled__c != oldSolutionArea.get(OppSA.Id).Core_Technology_Enabled__c || OppSA.Core_Version__c != oldSolutionArea.get(OppSA.Id).Core_Version__c){
                        saIds.add(OppSA.Id);
                    }            
                }
            }
            if(saIds.size()>0){ 
                getOppSA = [Select Id, Core_Opportunity__c, Core_Solution_Areas__c from Opportunity_Solution_Area__c 
                            where Core_Solution_Areas__c =:saIds and (Core_Opportunity__r.Core_Opportunity_Coverage_Nm__c != 'Partner-Led Opportunity' or Core_Opportunity__r.Core_Coverage_Type_Nm__c != 'Deal Registration')]; 
                if(getOppSA.size()>0){
                    for(Opportunity_Solution_Area__c oSolArea : getOppSA) { oppId.add(oSolArea.Core_Opportunity__c); }
                } 
            }
            if(oppId.size()>0) {
                if(!System.isBatch()) {
                    if(KPIJSONCheckInsert)
                    { KPIJSONCheckInsert = false;
                     oppKPIJSON(oppId); }
                }
            }
        }
        Catch(Exception ex){
        PMP_Utility.logError(ex, 'Core_OpportunityHandler.updateJSONSolutionArea'); }
    }
    
    //Description  : This Method used to create the JSON.
    
    public static void oppKPIJSON(List<String> rid) {        
        Core_OpportunityJSON updateJob = new Core_OpportunityJSON(rid);
        ID jobID=System.enqueueJob(updateJob);
    }
    
    //Description  : This Method is used to delete the associated new KPI object record on DELETE of Opportunity. 
    
    public static void deleteNewKPI(List<Opportunity> oldOppList) {
        List<Core_Oppty_KPI_New__c> newKpiList = [select Id, Core_KPI_Opportunity__c from Core_Oppty_KPI_New__c where Core_KPI_Opportunity__c IN: oldOppList];
        if(!newKpiList.isEmpty()){ delete newKpiList;}
    }
    
    //Description  : Validate Uniqueness of Opportunity Name. #TWC3123-2827
    
    public static void validateUniqueOppUpdate(List<Opportunity> oppList, map<Id,Opportunity> oldMap) {
        Core_Opp_Bypass_Validation_Rule__c mapBypassValidation = Core_Opp_Bypass_Validation_Rule__c.getInstance(); //Bypassing for all System/Integration Users
        List<String> oppName = new List<String>();
        List<Opportunity> existingOppList = new List<Opportunity>();
        
        if(!oppUniqueValidationRecursion) {oppUniqueValidationRecursion = true;}
        else {return;}
        
        try {   
            for(Opportunity opp: oppList) { oppName.add(opp.Name); }
            if(Test.isRunningTest()){ throw new System.DMLException();}  
            existingOppList = [Select Id, Name from Opportunity Where Name =: oppName AND Id !=: oldMap.keySet()];
            if(existingOppList.size()>0 && mapBypassValidation.Bypass__c == false ){ 
                for(Opportunity opp: oppList){   
                    if(opp.Name != oldMap.get(opp.Id).Name){ opp.addError(Label.Core_UniqueOppo_Validation);}
                }
            }
        }
        Catch(Exception ex) {
            for(Opportunity opp: oppList){opp.addError(Label.Core_UniqueOppo_Validation);}
        }
    }
    public static void validateUniqueOppInsert(List<Opportunity> oppList){
        Core_Opp_Bypass_Validation_Rule__c mapBypassValidation = Core_Opp_Bypass_Validation_Rule__c.getInstance(); //Bypassing for all System/Integration Users
        List<String> oppName = new List<String>();
        List<Opportunity> existingOppList = new List<Opportunity>();
        try {   
            for(Opportunity opp: oppList){ oppName.add(opp.Name);}
            existingOppList = [Select Id, Name from Opportunity Where Name =: oppName];
            if(existingOppList.size()>0 && mapBypassValidation.Bypass__c == false) { 
                for(Opportunity opp: oppList) {opp.addError(Label.Core_UniqueOppo_Validation);}           
            }
            if(Test.isRunningTest()){throw new System.DMLException();}  
        }
        Catch(Exception ex) {
            for(Opportunity opp: oppList){opp.addError(Label.Core_UniqueOppo_Validation);}
        }
    }
    //Description  : When updating the stage, it checks for the exit criteria fields of the current stage before moving to the next stage. #TWC3123-3502
    public static void restrictBlankFieldUpdates(List<Opportunity> NewOppList,map<Id,Opportunity> oldOppMap,List<Opportunity> OldOppList,Boolean isUpdate) {
        Set<String> OppStages = new Set<String> {'Define','Develop','Design','Design Win','Production Win'};   
            String errorMsgToDisplay='';  
        String FieldLabel='';
        Boolean nextLineFlag=false;          
        Id designRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        Id dealRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
        Set<Id> OppIdstoGet = new Set<Id>();
        for (Opportunity OppRecs : NewOppList){
            OppIdstoGet.add(OppRecs.Id);
        }
       
        Set<Id> OppOcrSet = new Set<Id>();
        for(OpportunityContactRole OppOcr : [select opportunityid from OpportunityContactRole where opportunityid IN :OppIdstoGet and role='Business Decision Maker']){
            OppOcrSet.add(OppOcr.opportunityid);
        }
        // Cache Schema describes once to avoid schema method calls within loops
        Schema.DescribeSObjectResult oppDescribe = Opportunity.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> oppFieldMap = oppDescribe.fields.getMap();
        for(Opportunity OppRec : NewOppList )
        {
            String strfieldLabels='';
            List<String> fieldsToDisplay=new List<String>();
            //PCC Deal Reg 
            if(!(OppRec.Core_Opportunity_Coverage_Nm__c=='Partner-Led Opportunity' && OppRec.Core_Coverage_Type_Nm__c =='Deal Registration')){
                if(!isUpdate) {
                    if(OppRec.StageName=='Define' && OppRec.Core_IsClone__c == False) {
                        fieldsToDisplay= OppRec.RecordTypeId==designRecordTypeId ? System.Label.Core_Design_Define_Validation.split(',') : System.Label.Core_Deal_Define_Validation.split(',');
                        if(!fieldsToDisplay.isEmpty()){
                            for(String fields:fieldsToDisplay){
                                if(String.isEmpty((String)oppRec.get(fields))){
                                    FieldLabel = oppFieldMap.containsKey(fields) ? oppFieldMap.get(fields).getDescribe().getLabel() : fields;
                                    strfieldLabels+=' '+FieldLabel+',';
                                }
                            }
                        }
                    }
                } 
                else {
                    switch on OppRec.StageName {
                        when 'Define' {
                            fieldsToDisplay= OppRec.RecordTypeId==designRecordTypeId ? System.Label.Core_Design_Define_Validation.split(',') : System.Label.Core_Deal_Define_Validation.split(',');}
                        when 'Develop' {
                            fieldsToDisplay=OppRec.RecordTypeId==designRecordTypeId ? System.Label.Core_Design_Develop_Validation.split(',') : System.Label.Core_Deal_Develop_Validation.split(',');}
                        when 'Design' {
                            fieldsToDisplay=OppRec.RecordTypeId==designRecordTypeId ?
                                OppRec.Core_Opportunity_Coverage_Nm__c==Core_CRM_Utility.getCRMLabel('Core_OpportunitySellerProgram')?
                                System.Label.Core_Design_Design_Validation.split(','):Core_CRM_Utility.getCRMLabel('Core_PartnerDesign_Design_Validation').split(',')
                                    : System.Label.Core_Deal_Design_Validation.split(',');
                            if(String.isEmpty(OppRec.Core_Competitive_Architecture__c) && String.isEmpty(OppRec.Core_Design_Registration_Id__c) && OppRec.RecordTypeId==designRecordTypeId) {
                                fieldstoDisplay.add('Core_Competitive_Architecture__c');} 
                        }
                        /* TWC3123-4257 -Making Description & StatusUpdate mandetory at Design Win,Production win Stages */
                        when 'Design Win' {
                            fieldsToDisplay= System.Label.Core_Opp_Description_StatusUpdate_Fields.split(',');}
                        when 'Production Win' {
                            fieldsToDisplay= System.Label.Core_Opp_Description_StatusUpdate_Fields.split(',');}
                    }
                    if(OppRec.StageName=='Production Win' || OppRec.StageName=='Design Win') {
                        Opportunity OldOppRec = oldOppMap.get(OppRec.Id);
                        if(!fieldsToDisplay.isEmpty()){
                            for(String fields:fieldsToDisplay){
                                if(String.isEmpty((String)oppRec.get(fields)) && oppRec.get(fields) != OldOppRec.get(fields)) {
                                    FieldLabel = oppFieldMap.containsKey(fields) ? oppFieldMap.get(fields).getDescribe().getLabel() : fields;
                                    strfieldLabels+=' '+FieldLabel+',';
                                }
                            }
                        }
                    }
                    
                    //on status change checking the blank fields
                    if(OppRec.StageName != oldOppMap.get(OppRec.Id).StageName) {
                        if(!fieldsToDisplay.isEmpty()) {
                            for(String fields:fieldsToDisplay) {
                                if(String.isEmpty((String)oppRec.get(fields))){
                                    FieldLabel = oppFieldMap.containsKey(fields) ? oppFieldMap.get(fields).getDescribe().getLabel() : fields;
                                    strfieldLabels+=' '+FieldLabel+',';
                                }
                            }
                        }
                        
                        if((OppRec.RecordTypeId==designRecordTypeId && String.isEmpty(OppRec.Core_Design_Registration_Id__c) && OppRec.Core_Contact_Roles_Count__c < 1 && (OppRec.StageName=='Develop'|| OppRec.StageName=='Design')) || 
                           (OppRec.RecordTypeId==dealRecordTypeId && OppRec.Core_Contact_Roles_Count__c < 1 && (OppRec.StageName=='Develop' || OppRec.StageName=='Design'))){
                               strfieldLabels+=System.Label.Core_Contact_Role_Error_Message;  
                               nextLineFlag=true;
                           }  
                        
                                              
                        
                        // TWC4767-2117 : seperated out ProductCount and WriteInProductCount. Bypass WriteInProductCount for VBS
                        if(OppRec.StageName=='Design' && OppRec.Core_Product_Count__c <1){
                            strfieldLabels+=System.Label.Core_Opp_Product_Count; // Must include at least one (1) Product
                            nextLineFlag=true;
                        }
                        if(OppRec.StageName=='Design' && OppRec.Core_Write_In_Product_Count__c >0 && OppRec.Core_VBS_Potential__c==False){
                            strfieldLabels+=System.Label.Core_Oppo_Approval_Write_in_Product_count; //Write in Product count is greater than 0
                            nextLineFlag=true;
                        } 
                            
                            //Added by Ealisha:TWC4767-1284-SalesCRM End User Sales Motion Stage Gate changes
                            if(OppRec.RecordTypeId==dealRecordTypeId &&
                               OppRec.Core_Opportunity_Coverage_Nm__c=='Intel-Led Opportunity' && 
                               ((OppRec.Core_Opportunity_Type__c == 'Deal: Sell-to'||OppRec.Core_Opportunity_Type__c == 'Deal: Sell-through') && 
                                (OppRec.StageName=='Develop' || OppRec.StageName=='Design'))) {
                                    /*List<OpportunityContactRole> ocr = new List<OpportunityContactRole>();
                                    ocr = [select id from OpportunityContactRole where opportunityid =:OppRec.Id and role='Business Decision Maker'];*/
                                    if((OppRec.Core_Write_In_Product_Count__c > 0)&& OppRec.Core_VBS_Potential__c==False && !strfieldLabels.contains(System.Label.Core_Oppo_Approval_Write_in_Product_count)){ //|| OppRec.Core_Product_Count__c <1
                                        strfieldLabels+=System.Label.Core_Oppo_Approval_Write_in_Product_count;
                                        nextLineFlag=true;
                                    }
                                    if(OppRec.Core_Product_Count__c <1 && !strfieldLabels.contains(System.Label.Core_Opp_Product_Count)){
                                        strfieldLabels+=System.Label.Core_Opp_Product_Count;
                                        nextLineFlag=true;
                                    }
                                    if(!(OppOcrSet.contains(OppRec.Id))) {
                                        strfieldLabels+=System.Label.Core_Opp_Deal_SellTo_Error_Message;
                                        nextLineFlag=true;
                                    }
                                }
                       // }
                    }
                    
                    //Ealisha
                    if(OppRec.RecordTypeId==dealRecordTypeId && OppRec.Core_Opportunity_Coverage_Nm__c=='Intel-Led Opportunity' && OppRec.Core_Opportunity_Type__c != oldOppMap.get(OppRec.Id).Core_Opportunity_Type__c && 
                       OppRec.Core_Opportunity_Type__c != 'Deal: Sell-to' && OppRec.Core_Opportunity_Type__c != 'Deal: Sell-through'){
                           OppRec.Opportunity_Focus__c='';
                           OppRec.FAD_Start_Date__c=null;
                           OppRec.FAD_End_Date__c=null;
                           OppRec.RFP_Open_Date__c=null;
                           OppRec.RFP_Close_Date__c=null;
                           OppRec.POC_Start_Date__c=null;
                           OppRec.POC_End_Date__c=null;
                           OppRec.Desired_End_State__c='';
                           OppRec.Technology_and_Readiness_Gaps__c='';
                           OppRec.Business_Need__c='';
                           OppRec.Technical_Need__c='';
                           OppRec.Competitor_Threat_Mitigation__c='';  
                       }
                }
                if(!String.isBlank(strfieldLabels)){
                    strfieldLabels=strfieldLabels.removeEnd(',');
                    
                    //if more than one field is blank, than we are appending 'and' before the last field
                    if(strfieldLabels.contains(',')){
                        Integer indexofComma=strfieldLabels.lastIndexOf(',');
                        strfieldLabels=strfieldLabels.substring(0,indexofComma)+' and '+strfieldLabels.substring(indexofComma+1);
                        if(!(OppRec.StageName=='Production Win' || OppRec.StageName=='Design Win')){
                            errorMsgToDisplay=System.Label.Core_Stage_Exit_Validation_Message+strfieldLabels;}
                        else{
                            errorMsgToDisplay=System.Label.Core_Following_Fields_MustBe_Completed_ErrorMessage+strfieldLabels;}
                    }
                    else if(!strfieldLabels.contains(',') && !String.isBlank(strfieldLabels) && nextLineFlag==false){
                        if(!(OppRec.StageName=='Production Win' || OppRec.StageName=='Design Win')){
                            errorMsgToDisplay=strfieldLabels+' '+System.Label.Core_Stage_Exit_Validation_Message_Single_Field;}
                        else{
                            errorMsgToDisplay=strfieldLabels+' '+System.Label.Core_Single_Field_Cannot_Be_Blank_ErrorMessage;}
                    }
                    else if(!strfieldLabels.contains(',') && !String.isBlank(strfieldLabels) && nextLineFlag==true)
                    {errorMsgToDisplay=System.Label.Core_Stage_Exit_Validation_Message+' '+strfieldLabels;}
                    
                    OppRec.addError(errorMsgToDisplay);
                }                
            }
        }
    }
    //Description  : retrigger 6QPS Auto calculation On Reverasal(Flow - Core_Opportunity_Approval_Reversal) TWC3123-3794
    
    @InvocableMethod( label='Retrigger 6QPS Calculation')    
    public static void retrigger6QPS(List<Opportunity> newOppList) {
        List<Id> oppIdList = new List<Id>();
        for(Opportunity opp : newOppList){            
            oppIdList.add(opp.Id);        
        }
        if(oppIdList.size()>0) {
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
            List<Core_Opp_FC_Prod_Schedule__c> fcRecs = new List<Core_Opp_FC_Prod_Schedule__c>();
            Map<Id,List<Core_Opp_FC_Prod_Schedule__c>> oppFcMap = new Map<Id,List<Core_Opp_FC_Prod_Schedule__c>>();
            for(Core_Opp_FC_Prod_Schedule__c fc : [Select Id, Core_Opp_FC_Approval_Status__c, Core_Opp_FC_Opportunity__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c IN: oppIdList]){
                if(oppFcMap.containskey(fc.Core_Opp_FC_Opportunity__c)){
                    List<Core_Opp_FC_Prod_Schedule__c> fcRec = oppFcMap.get(fc.Core_Opp_FC_Opportunity__c);
                    fcRec.add(fc);
                    oppFcMap.put(fc.Core_Opp_FC_Opportunity__c,fcRec);
                }
                else { oppFcMap.put(fc.Core_Opp_FC_Opportunity__c, new List<Core_Opp_FC_Prod_Schedule__c>{fc}); }
            }
            for(Id id : oppFcMap.keyset() ){
                List<Core_Opp_FC_Prod_Schedule__c> fcRec = oppFcMap.get(id);
                for(Core_Opp_FC_Prod_Schedule__c fc : fcRec){
                    if(fc.Core_Opp_FC_Approval_Status__c == 'Approved' || fc.Core_Opp_FC_Approval_Status__c == 'Submitted')
                    {     oppFcMap.remove(id); 
                          break;  
                     }  
                     }
            }
            fcRecs = [Select id FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c IN: oppFcMap.keyset()];
            oliList = [Select ID,OpportunityId,Product2Id,Core_Vendor__c,Core_Status__c,Quantity,Core_PW_Quantity__c,Core_PW_Sales_Price__c from OpportunityLineItem where OpportunityId IN: oppFcMap.keyset()];
            if(fcRecs.size()>0){
                delete fcRecs;
                Core_OpportunityLineItemHandler.insertForecastRecords(oliList,new List<Core_Opp_FC_Prod_Schedule__c>(),true);
            }        }
    }
    
    //Description  : Checks if the IOGM Opportunity is true and share the Opportunity with FED CRM System User.
    public static void FedCRMOpportunityShare(List<Opportunity> OppList, Map<Id,Opportunity> OldMap,Boolean isInsert, Boolean isUpdate) {        
        Set<Id> fedCRMOppid = new Set<Id>();
        Set<Id> fedCRMOppidDel = new Set<Id>();
        Id groupId = null;
        // Get the oppty list which have account sales Group changed
        for(Opportunity opp:OppList){
            if((isInsert && opp.Core_Sales_Groups__c=='Americas US Sales Group')||(isUpdate && !OppList.IsEmpty() && !OldMap.IsEmpty() && opp.Core_Sales_Groups__c=='Americas US Sales Group' && (OldMap.get(opp.id).Core_Sales_Groups__c!=opp.Core_Sales_Groups__c || OldMap.get(opp.id).OwnerId !=opp.OwnerId))){
                fedCRMOppid.add(opp.id);           
            }
            if(isUpdate && !OppList.IsEmpty() && !OldMap.IsEmpty() && OldMap.get(opp.id).Core_Sales_Groups__c=='Americas US Sales Group' && OldMap.get(opp.id).Core_Sales_Groups__c!=opp.Core_Sales_Groups__c ){
                fedCRMOppidDel.add(opp.id);
            }
        }
        if(fedCRMOppidDel.size() > 0 || fedCRMOppid.size() > 0){
            //Get the FED CRM Group id
            groupId = [SELECT id FROM Group where DeveloperName  =: 'Core_Fed_CRM_Group'][0].Id;
        }
        if(fedCRMOppidDel.size() >0){
            List<OpportunityShare> fedCRMShare = [SELECT Id FROM OpportunityShare WHERE Opportunity.id IN: fedCRMOppidDel and UserOrGroupId =:groupId];
            Database.DeleteResult[] deleteResults = Database.delete( fedCRMShare, true );  
        }
        //Share the Opportunities in Oppty Share
        List<OpportunityShare> sharesToInsert  = new List<OpportunityShare>();
        OpportunityShare oppRoleShr;
        //Iterating through New Opportunity
        if(fedCRMOppid.size()>0){            
            for(Id key : fedCRMOppid){
                oppRoleShr = new OpportunityShare();
                oppRoleShr.OpportunityId = key; 
                oppRoleShr.UserOrGroupId = groupId;
                oppRoleShr.OpportunityAccessLevel = 'Read'; 
                oppRoleShr.RowCause = 'Manual';  
                sharesToInsert.add(oppRoleShr);
            }
            Database.SaveResult[] lsr = Database.insert(sharesToInsert,false);
        }
    }
    //Description  : This method checks the technical owner change on opportunity and shares it with the respective Portal Roles and delete previous.
    public static void OpportunityShare(List<Opportunity> OppList, Map<Id,Opportunity> OldMap) {
        Set<Id> newtechOwnerIDs = new Set<Id>();
        Set<Id> OldtechOwnerIDs = new Set<Id>();
        Set<id> NewRoleSet=new Set<id>();
        Set<id> OldRoleSet=new Set<id>();
        Map<Id,String> tOwnerMap = new Map<Id,String>();
        Map<Id,Id> NewTechOwnerMap=new Map<Id,Id>();
        Map<Id,Id> OldTechOwnerMap=new Map<Id,Id>();
        Map<id, id> roleAndGroupMap = new Map<id, id>();
        Map<id,id> OppNTRoleMap = new Map<id,id>();
        Map<id,id> OppOTRoleMap = new Map<id,id>();
        List<User> usList = new List<User>();
        List<Group> roleGroup = new List<Group>();
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        
        
        
        for(Opportunity opp:OppList) {
            if(!OppList.IsEmpty() && !OldMap.IsEmpty()){
                if(((opp.Core_Technical_Owner__c!= null && OldMap.get(opp.Id).Core_Technical_Owner__c != opp.Core_Technical_Owner__c)
                    ||(opp.OwnerId!= null && OldMap.get(opp.Id).OwnerId != opp.OwnerId)) 
                   && opp.Core_Opportunity_Coverage_Nm__c=='Partner-Led Opportunity'){
                       newtechOwnerIDs.add(opp.Core_Technical_Owner__c); 
                       OldtechOwnerIDs.add(OldMap.get(opp.Id).Core_Technical_Owner__c);
                   }                
            }
        }
        
        if(newtechOwnerIDs != null && !newtechOwnerIDs.isEmpty()) {
            usList = [select Id, Name, Profile.Name, UserRoleId from User where Profile.Name like '%Partner%' and UserRoleId<>null AND 
                      (Id IN :newtechOwnerIDs OR Id IN :OldtechOwnerIDs)]; 
        }
        
        for(Opportunity opp:OppList) { 
            //checking technical owner change on ddr created opportunity and Opportunity Owner Change
            if(((opp.Core_Technical_Owner__c!= null && OldMap.get(opp.Id).Core_Technical_Owner__c != opp.Core_Technical_Owner__c)
                ||(opp.OwnerId!= null && OldMap.get(opp.Id).OwnerId != opp.OwnerId)) 
               && opp.Core_Opportunity_Coverage_Nm__c=='Partner-Led Opportunity'){
                   Id newtOwnerID = opp.Core_Technical_Owner__c;          
                   Id OldtOwnerID =  OldMap.get(opp.Id).Core_Technical_Owner__c;
                   
                   for(User user: usList) { 
                       if(newtOwnerID==user.Id) {
                           if(!NewTechOwnerMap.containsKey(user.Id)){
                               NewTechOwnerMap.put(user.Id,user.UserRoleId);
                               OppNTRoleMap.put(opp.id, user.UserRoleId); 
                           } else{ OppNTRoleMap.put(opp.id, user.UserRoleId); }
                       }
                       if(OldtOwnerID==user.Id) {
                           if(!OldTechOwnerMap.containsKey(user.Id)){
                               OldTechOwnerMap.put(user.Id, user.UserRoleId);
                               OppOTRoleMap.put(opp.id, user.UserRoleId);
                           }
                           else{ OppOTRoleMap.put(opp.id, user.UserRoleId); }
                       }
                   }
                   //If (User role Id of old and new technical owner is different) or (Oppty Owner get changed and user role id of-old & new technical owner is same) then only share the opportunity record 
                   if((OppNTRoleMap.get(opp.Id) <> OppOTRoleMap.get(opp.Id))||((opp.OwnerId!= null && OldMap.get(opp.Id).OwnerId != opp.OwnerId) && (OppNTRoleMap.get(opp.Id) == OppOTRoleMap.get(opp.Id)))){
                       tOwnerMap.put(opp.id,OppNTRoleMap.get(opp.Id));//map of oppty id and new technical owner's UserRoleId 
                       NewRoleSet.add(OppNTRoleMap.get(opp.Id));
                       if(OppNTRoleMap.get(opp.Id) <> OppOTRoleMap.get(opp.Id)){
                           OldRoleSet.add(OppOTRoleMap.get(opp.Id)); 
                       }
                   }
               }
        }
        
        if(!NewRoleSet.isEmpty() || !OldRoleSet.isEmpty()){
            //Querying NewRole and OldRole groups and putting user's userRoleID(group's relatedId) as key into map and groups id as its value           
            roleGroup = [SELECT Id, RelatedId, Type FROM Group WHERE (RelatedId IN: NewRoleSet OR RelatedId IN: OldRoleSet) and type = 'role'];
            for(group grp: roleGroup){
                if(!roleAndGroupMap.containskey(grp.RelatedId)){
                    roleAndGroupMap.put(grp.RelatedId, grp.id);
                }                
            }
        }
        
        List<OpportunityShare> sharesToInsert  = new List<OpportunityShare>();
        OpportunityShare oppRoleShr;
        String switchLog = Core_CRM_Utility.getCRMLabel('handlerLogSwitch'); 
        
        //Iterating through New Opportunity
        if(tOwnerMap.size()>0){           
            for(Id key : tOwnerMap.keyset()){
                oppRoleShr = new OpportunityShare(); // Instantiate the sharing objects     
                oppRoleShr.OpportunityId = key; // Set the ID of record being shared
                oppRoleShr.UserOrGroupId = roleAndGroupMap.get(tOwnerMap.get(key)); // Set the ID of user or group being granted access
                oppRoleShr.OpportunityAccessLevel = 'edit'; // Set the access level
                oppRoleShr.RowCause = 'Manual'; // Set the Apex sharing 
                sharesToInsert.add(oppRoleShr);
            }
            if(!sharesToInsert.isEmpty()) { 
                Database.SaveResult[] insertedResults = Database.insert(sharesToInsert,false);
                
                String str = JSON.serialize(sharesToInsert);
                
                for (Database.SaveResult sr : insertedResults) {
                    if (!sr.isSuccess() && switchLog.equalsIgnoreCase('true') ) {                            
                        for(Database.Error err : sr.getErrors()) {
                            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error During Insertion',Core_Details__c =  str+'--'+ err.getMessage()  , Core_Origin__c='Core_OpportunityHandler.OpportunityShare', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM', Core_sObjectId__c = sr.getId())); 
                        }
                    }
                }
                
                
            }            
        }
        
        List<OpportunityShare> sharesToDelete= new List<OpportunityShare>();
        if(!OldRoleSet.isEmpty()){
            // Querying Old Tech owner's sharing record where opptyId should be in coming OppList and UserOrGroupId in old technical owner's group set.
            List<OpportunityShare> shareRecords = [SELECT Id,OpportunityId,UserOrGroupId  FROM OpportunityShare WHERE OpportunityId IN :OldMap.keyset() AND UserOrGroupId IN : roleAndGroupMap.values()];
            
            for(OpportunityShare os :shareRecords){
                id gid = roleAndGroupMap.get(OldTechOwnerMap.get(OldMap.get(os.OpportunityId).Core_Technical_Owner__c));
                if(gid==os.UserOrGroupId && OppNTRoleMap.get(os.OpportunityId) <> OppOTRoleMap.get(os.OpportunityId)){
                    sharesToDelete.add(os);                   
                }
            }
            
            // Delete the Old Share record
            if(!sharesToDelete.isEmpty()){ 
                Database.DeleteResult[] deletedResults =  Database.Delete(sharesToDelete, false);
                
                String str = JSON.serialize(sharesToDelete);
                
                for (Database.DeleteResult sr : deletedResults) {
                    if (!sr.isSuccess() && switchLog.equalsIgnoreCase('true') ) {                            
                        for(Database.Error err : sr.getErrors()) {
                            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error During Deletion',Core_Details__c =  str+'--'+err.getMessage(), Core_Origin__c='Core_OpportunityHandler.OpportunityShare', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM', Core_sObjectId__c = sr.getId())); 
        }    
    }
                }
            }
        }
        
        
        if(logEntries.size()>0){
            
            Insert logEntries;
        }
        
        
    }
    // As a part of TWC3123-6470
    //Description  : This method checks the technical owner change on opportunity and shares it with the respective Portal Roles and delete previous.
    
    public static void OpportunityKPIfieldRefresh(List<Opportunity> OppList, Map<Id,Opportunity> OldMap)
    { 
        for(Opportunity opp:OppList){
            if(opp.StageName != OldMap.get(opp.Id).StageName && opp.StageName != PRODUCTION_WIN){
                opp.Core_ProductionWin_KPI_Txt__c=null;
            }  
        }
    }
    //Description  : This method stores the Description Of Contribution of Technical owner and Partner account owner into field whenever Opportunity Owner changed.
    public static void storeOppTeamMemDescription(map<Id, Opportunity> oldMap, map<Id, Opportunity> newMap) {
        set<Id> updatedOppSet = new set<Id>();
        map<Id, list<String>> mapOppIdUserDesc = new map<Id, list<String>>();
        try{
            for (Opportunity opp : newMap.values()) {
                if (oldMap.get(opp.id).OwnerId != opp.OwnerId) {
                    updatedOppSet.add(opp.id);
                }   
            }
            if(oldMap != null && newMap != null && updatedOppSet.size()>0) {
                list<String> lstUserDesc = new list<String>();
                for(OpportunityTeamMember otm : [SELECT UserId, OpportunityId, User.Name, TeamMemberRole, core_description_of_contribution__c, Opportunity.Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.ownerid
                                                 FROM OpportunityTeamMember WHERE OpportunityId =: updatedOppSet ORDER BY OpportunityId]) {   
                                                     if(otm.UserId == otm.Opportunity.Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.ownerid || otm.TeamMemberRole==System.Label.Core_Technical_Owner) {
                                                         String userIdDesc = String.valueOf(otm.UserId) + '_'+ String.valueOf(otm.core_description_of_contribution__c);
                                                         if(mapOppIdUserDesc.containskey(otm.OpportunityId)) { mapOppIdUserDesc.get(otm.OpportunityId).add(userIdDesc);}
                                                         else {
                                                             lstUserDesc = new list<String>();
                                                             lstUserDesc.add(userIdDesc);
                                                             mapOppIdUserDesc.put(otm.OpportunityId, lstUserDesc); 
                                                         }
                                                     }
                                                     
                                                 }                 
                if(!mapOppIdUserDesc.isEmpty()) {
                    for (Opportunity Opp : newMap.values()) {
                        if(oldMap.get(Opp.id).OwnerId != Opp.OwnerId) {
                            Opp.Core_OpportunityTeamMembers__c = String.valueOf(mapOppIdUserDesc.get(Opp.Id));
                        }    
                    }
                }
            }
        } catch(Exception ex) {
        PMP_Utility.logError(ex, 'Core_OpportunityHandler.storeOppTeamMemDescription'); 
    }
    }
    
    //Description-Added as part of TWC3123-5419 for point-> Any update to DW opportunity in stage DW including the submission - > update the pw qty, sales price from DW field for blank values)
    public static void updatePWFieldsonProduct(List<Opportunity> NewOppList) {
        Set<Id> oppIds=new Set<Id>();
        List<OpportunityLineItem> oliToUpdate=new List<OpportunityLineItem>();
        Id designRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        for(Opportunity opp:NewOppList){
            if((opp.StageName== DESIGN_WIN && opp.RecordTypeId==designRecordTypeId)
               || (opp.StageName== DESIGN_WIN && opp.RecordTypeId==designRecordTypeId && opp.Core_PW_Approval_Status__c == 'Recalled'  )){
                   // added additional check on Production win products so that existing data will get updated durong reversal scenario
                   oppIds.add(opp.Id);                   
               }
        }
        
        if(!oppIds.isEmpty()){
            List<OpportunityLineItem> oliList=[select Id,Quantity,Core_PW_Quantity__c,UnitPrice,Core_PW_Sales_Price__c 
                                               from OpportunityLineItem 
                                               where ((Core_PW_Sales_Price__c=null and UnitPrice <> null) OR Core_PW_Quantity__c=null) AND (Core_Status__c='Win Approved' or Core_Status__c='Production Win') AND OpportunityId IN :oppIds];
            if(!oliList.isEmpty()){
                for(OpportunityLineItem oli:oliList){
                    OpportunityLineItem oliRec=new OpportunityLineItem();
                    oliRec.Id=oli.Id;
                    if(oli.Core_PW_Quantity__c==null){
                        oliRec.Core_PW_Quantity__c=oli.Quantity;
                    }
                    if(oli.Core_PW_Sales_Price__c == null){
                        oliRec.Core_PW_Sales_Price__c=oli.UnitPrice;                                 
                    }
                    oliToUpdate.add(oliRec);
                }
                
                if(!oliToUpdate.isEmpty()){
                     update oliToUpdate;
                }
            }
        }
    } 
    
    
    // PCC Deal -Sync opportunity OO and TO with Quote Sales Rep and Primary Contact. TWC4767-1683
public static void syncOwner_Opportunity_Quote(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap) {
  List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
  try {
    set<Id> OptyIds = new set<Id>();
    for (Opportunity opty : newOppList) {
      if (opty.Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity' && opty.Core_Coverage_Type_Nm__c == 'Deal Registration' && opty.Core_Opportunity_Owner__c<> oldOppMap.get(opty.Id).Core_Opportunity_Owner__c || opty.Core_Technical_Owner__c<> oldOppMap.get(opty.Id).Core_Technical_Owner__c) {
        OptyIds.add(opty.Id);
      }
    }
    if (!OptyIds.IsEmpty() && OptyIds.size() > 0) {
      List<Opportunity> optydata = [ select Id, OwnerId, Owner.Email, Core_Technical_Owner__r.ContactId, Core_Technical_Owner__c, Core_Opportunity_Owner__c, SBQQ__PrimaryQuote__c, Core_Opportunity_Coverage_Nm__c, Core_Coverage_Type_Nm__c from Opportunity WHERE Id IN : OptyIds ];
      Map<Id, Opportunity> oppIdToOpptyRecordMap = new Map<Id, Opportunity>(optydata);

      if (!oppIdToOpptyRecordMap.IsEmpty() && oppIdToOpptyRecordMap.size() > 0) {
        Pricing_FinancialIncentive_BusinessLogic.updateOpportunityOwnerName(oppIdToOpptyRecordMap);
      }
    }

  } catch (exception e) {
    captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = e.getMessage(), Core_Message__c = 'syncOwner_Opportunity_Quote', Core_Severity__c = 'Low', Core_Origin__c = 'core_OpportunityLineItemHandler', Core_When__c = System.now()));

  } finally {
    if (!captureQueryErr.IsEmpty()) {
      insert captureQueryErr;
    }
  }
}
    
    
    //Lock Opportunity update if Quote's QL is in PFIR status - TWC3123-5659 - Devashish
    public static void checkPCCOpptyLock(List<Opportunity> newOppList, Map<Id,Opportunity> oldOppMap){
        List<Opportunity> PCCOpptyList = new List<Opportunity>();
         String OppfieldString = System.Label.Core_PCC_OpptyLock;

        Schema.DescribeSObjectResult oppDescribe = Opportunity.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = oppDescribe.fields.getMap();
        Boolean oppfieldbypass = false; //field to bypass opp lock for certain fields
        for(Opportunity opp: newOppList){
                  if(opp.Core_Opportunity_Coverage_Nm__c =='Partner-Led Opportunity' && opp.Core_Coverage_Type_Nm__c =='Deal Registration')
                { 
                for(String fieldName : fieldMap.keySet()) {
               
                 if (opp.get(fieldName) != oldOppMap.get(opp.Id).get(fieldName) && !OppfieldString.containsIgnoreCase(fieldName)) {
                        oppfieldbypass = true;
                        break;
                    }
             
                }
                if(oppfieldbypass == true){
                   
                    PCCOpptyList.add(opp);
                }
            }        
        }
        if(PCCOpptyList.size()>0){
            Boolean lock = Core_CRM_Utility.lockOpportunity(PCCOpptyList);
            if(lock)
            {
                for(Opportunity opp:PCCOpptyList)
                {
                    opp.adderror(System.Label.Core_LockPCCOppty);
                }
            }
        } 
    }    
    
    // IQR Tender-Oppty Integration-If an opportunity is listed on the quote and the opportunity status is either Won or Lost for Intel-Led Opportunity-- TWC4767-1873
    public static void syncStatus_Opportunity_IQRQuote(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap) {
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        try {
            set<Id> OpportunityIds=new set<Id>();      
            for (Opportunity opty : newOppList) {
                if (opty.StageName <> oldOppMap.get(opty.Id).StageName && (opty.StageName == 'Design Win' || opty.StageName == 'Cancelled' || opty.StageName == 'Lost') && opty.Core_Opportunity_Coverage_Nm__c == 'Intel-Led Opportunity'){                  
                    OpportunityIds.add(opty.Id);                    
                }
            }
            
            if (!OpportunityIds.IsEmpty() && OpportunityIds.size() > 0) {
                callQuoteApproveNotify(OpportunityIds);
            }
        } catch (exception e) {
            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = e.getMessage(),Core_Message__c = 'syncStatus_Opportunity_IQRQuote',Core_Severity__c = 'Low',Core_Origin__c = 'Core_OpportunityHandler',Core_When__c = System.now()));
            insert captureQueryErr;
        }
    }
    
    
    public static void callQuoteApproveNotify(set<id> oppIds){
        List<SBQQ__Quote__c> results = [select Id from  SBQQ__Quote__c where Pricing_Quote_Program_Nm__c ='Tender'  and SBQQ__Opportunity2__r.Id IN : oppIds];
        Set<Id> resultIds = (new Map<Id,SBQQ__Quote__c>(results)).keySet();
        if(resultIds.size() > 0){
            QuoteBusinessLogic.qlApproveAENotifyForOppWonLost(resultIds);
        }
    }
   
    // Stage reversals during approval recall happen after the trigger recursion guard stops calling this handler,
    // so cleanup is deferred to a Queueable that evaluates the final committed stage.
    public static void OpportunityKPIBatchUpdate(List<Opportunity> OppList, Map<Id,Opportunity> OldMap){ 
        Set<Id> oppIds = new Set<Id>();
        Set<String> trackedStages = new Set<String>{DESIGN_WIN, PRODUCTION_WIN};
        for(Opportunity opp : OppList){
            Opportunity oldOpp = OldMap != null ? OldMap.get(opp.Id) : null;
            if(trackedStages.contains(opp.StageName) || (oldOpp != null && trackedStages.contains(oldOpp.StageName))){
                oppIds.add(opp.Id);
            }
        }
        if(oppIds.isEmpty() || kpiBatchCleanupQueued){
            return;
        }
        kpiBatchCleanupQueued = true;
        if(System.isFuture() || System.isQueueable() || System.isBatch() || Limits.getQueueableJobs() >= Limits.getLimitQueueableJobs()){
            cleanupKPIBatch(oppIds);
        } else {
            System.enqueueJob(new KPIBatchCleanupJob(oppIds));
        }
    }

    public without sharing class KPIBatchCleanupJob implements Queueable {
        private Set<Id> oppIds;
        public KPIBatchCleanupJob(Set<Id> oppIds){
            this.oppIds = oppIds;
        }
        public void execute(QueueableContext ctx){
            Core_OpportunityHandler.cleanupKPIBatch(oppIds);
        }
    }

    public static void cleanupKPIBatch(Set<Id> oppIds){
        try{
            if(oppIds == null || oppIds.isEmpty()){
                return;
            }
            // Keyed by both 18- and 15-char Id text since Core_Opportunity_ID_Txt__c may hold either.
            Map<String, Set<String>> staleStagesByOppId = new Map<String, Set<String>>();
            Set<String> allStaleStages = new Set<String>();
            for(Opportunity opp : [SELECT Id, StageName FROM Opportunity WHERE Id IN :oppIds]){
                Set<String> staleStages;
                if(opp.StageName == DESIGN){
                    staleStages = new Set<String>{DESIGN_WIN, PRODUCTION_WIN};
                } else if(opp.StageName == DESIGN_WIN){
                    staleStages = new Set<String>{PRODUCTION_WIN};
                } else {
                    continue;
                }
                String idText = String.valueOf(opp.Id);
                staleStagesByOppId.put(idText, staleStages);
                staleStagesByOppId.put(idText.left(15), staleStages);
                allStaleStages.addAll(staleStages);
            }
            if(staleStagesByOppId.isEmpty()){
                return;
            }
            Set<String> oppIdTexts = staleStagesByOppId.keySet();
            List<Core_Opportunity_KPI_Batch_Detail__c> toDelete = new List<Core_Opportunity_KPI_Batch_Detail__c>();
            for(Core_Opportunity_KPI_Batch_Detail__c kpi : [SELECT Id, Core_Opportunity_ID_Txt__c, Core_Opportunity_Stage_Txt__c
                                                            FROM Core_Opportunity_KPI_Batch_Detail__c
                                                            WHERE Core_Opportunity_ID_Txt__c IN :oppIdTexts
                                                            AND Core_Opportunity_Stage_Txt__c IN :allStaleStages]){
                Set<String> staleStages = staleStagesByOppId.get(kpi.Core_Opportunity_ID_Txt__c);
                if(staleStages != null && staleStages.contains(kpi.Core_Opportunity_Stage_Txt__c)){
                    toDelete.add(kpi);
                }
            }
            if(toDelete.isEmpty()){
                return;
            }
            List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
            for(Database.DeleteResult sr : Database.delete(toDelete, false)){
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()){
                        logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error', Core_Details__c = err.getMessage(), Core_Origin__c = 'Core_OpportunityHandler.cleanupKPIBatch', Core_Severity__c = 'High', Core_When__c = System.now(), Core_Project__c = 'Sales Evolve', Core_sObjectId__c = sr.getId()));
                    }
                }
            }
            Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getAll();
            if(!logEntries.isEmpty() && logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c){
                insert logEntries;
            }
        } catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OpportunityHandler.cleanupKPIBatch');
        }
    }
    
    //Description : Detects Opportunities where CRM_Audit_Status__c changed and triggers Approved
    //commission generation for them. Every audit status change produces a new Approved
    //Core_Commissionable_Transaction__c record, even if Approved records already exist.
    public static void generateCommissionOnAuditStatusChange(List<Opportunity> newOppList, Map<Id,Opportunity> oldOppMap) {
        Set<Id> auditStatusChangedOppIds = new Set<Id>();
        for (Opportunity opp : newOppList) {
            Opportunity oldOpp = oldOppMap != null ? oldOppMap.get(opp.Id) : null;
            if (oldOpp != null && opp.CRM_Audit_Status__c != oldOpp.CRM_Audit_Status__c) {
                auditStatusChangedOppIds.add(opp.Id);
            }
        }
        if (!auditStatusChangedOppIds.isEmpty()) {
            Core_CommissionableTransactions.generateApprovedCommissionOnAuditStatusChange(auditStatusChangedOppIds);
        }
    } 
}