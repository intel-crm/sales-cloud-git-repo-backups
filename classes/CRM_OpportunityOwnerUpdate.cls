/********************************************************************************************************************************************************************
Apex Class Name: CRM_OpportunityOwnerUpdate
Version: 1.0
Created Date: 18/03/2025
Function: Batch class to update Portalrole Sharing and Opportunity Team Member Update based on AccountOwner Update

Modification Log :
* Developer Date Description
* ----------------------------------------------------------------------------
* Paraste Swati 18/03/2025 Original Version developed
*******************************************************************************************************************************************************************/
global without sharing class CRM_OpportunityOwnerUpdate implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    private List<Opportunity> opportunitiesId;
    private Id priorAccOwnerId;
    private Set<Id> setPCCOppId = new Set<Id>();
    private Set<Id> setSWOppId = new Set<Id>();
    
    public CRM_OpportunityOwnerUpdate(List<Opportunity> oppLst,Id priorAccountOwnerId) {
        this.opportunitiesId = oppLst;
        this.priorAccOwnerId = priorAccountOwnerId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
         String opportunities = 'SELECT Id, AccountId, StageName,CRM_SW_Flag_Ind__c,Core_Coverage_Type_Nm__c, OwnerId, Account.OwnerId,IsClosed,Core_Technical_Owner__c,Core_Opportunity_Coverage_Nm__c,RecordTypeId,Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerId,Core_OpportunityTeamMembers__c FROM Opportunity WHERE Id IN :opportunitiesId';
         return Database.getQueryLocator(opportunities);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        if(opportunitiesId.size() > 0 || opportunitiesId != null){
            
            OpportunityShare(opportunitiesId);
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(opportunitiesId);
            opportunityTechnicalOwnerUpdate(oppMap,priorAccOwnerId);
            
            List<OpportunityTeamMember> updateTeamMembers = [Select id,OpportunityId from OpportunityTeamMember where OpportunityId IN: opportunitiesId];
            if(!updateTeamMembers.isEmpty()){
                for (OpportunityTeamMember member : updateTeamMembers) {
                    if(oppMap.get(member.OpportunityId).Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity' && oppMap.get(member.OpportunityId).Core_Coverage_Type_Nm__c == 'Deal Registration'){
                        setPCCOppId.add(member.OpportunityId);
                    }
                    if(oppMap.get(member.OpportunityId).CRM_SW_Flag_Ind__c == true){
                        setSWOppId.add(member.OpportunityId);
                    }
                }
                
                if(setPCCOppId.size()>0 || setSWOppId.size()>0 ){
                    callQuoteTeamMemberShare(setPCCOppId,setSWOppId);
                }
            }
        }
    }  
    
    
    private static void OpportunityShare(List<Opportunity> OppList) {
        Set<Id> newtechOwnerIDs = new Set<Id>();
        Set<id> NewRoleSet=new Set<id>();
        Map<Id,String> tOwnerMap = new Map<Id,String>();
        Map<Id,Id> NewTechOwnerMap=new Map<Id,Id>();
        Map<id, id> roleAndGroupMap = new Map<id, id>();
        Map<id,id> OppNTRoleMap = new Map<id,id>();
        List<User> usList = new List<User>();
        List<Group> roleGroup = new List<Group>();
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        
        for(Opportunity opp:OppList) {
            if(!OppList.IsEmpty()){
                if((opp.Core_Technical_Owner__c!= null || opp.OwnerId!= null) && opp.Core_Opportunity_Coverage_Nm__c=='Partner-Led Opportunity'){
                    newtechOwnerIDs.add(opp.Core_Technical_Owner__c); 
                }                
            }
        }
        
        if(newtechOwnerIDs != null && !newtechOwnerIDs.isEmpty()) {usList = [select Id, Name, Profile.Name, UserRoleId from User where Profile.Name like '%Partner%' and UserRoleId<>null AND 
                                                                             (Id IN :newtechOwnerIDs)];  
                                                                  }
        
        for(Opportunity opp:OppList) { 
            //checking technical owner change on ddr created opportunity and Opportunity Owner Change
            if((opp.Core_Technical_Owner__c!= null || opp.OwnerId!= null) && opp.Core_Opportunity_Coverage_Nm__c=='Partner-Led Opportunity'){
                Id newtOwnerID = opp.Core_Technical_Owner__c;          
                for(User user: usList) { 
                    if(newtOwnerID==user.Id) {
                        if(!NewTechOwnerMap.containsKey(user.Id)){
                            NewTechOwnerMap.put(user.Id,user.UserRoleId);
                            OppNTRoleMap.put(opp.id, user.UserRoleId); 
                        } else{ OppNTRoleMap.put(opp.id, user.UserRoleId); }
                    }
                }
                //If (User role Id of technical owner is different) or (Oppty Owner get changed and user role id of-old & new technical owner is same) then only share the opportunity record 
                if((OppNTRoleMap.get(opp.Id))!= null||(opp.OwnerId!= null && OppNTRoleMap.get(opp.Id)!= null)){
                    tOwnerMap.put(opp.id,OppNTRoleMap.get(opp.Id));//map of oppty id and new technical owner's UserRoleId 
                    NewRoleSet.add(OppNTRoleMap.get(opp.Id));
                }
            }
        }
        
        if(!NewRoleSet.isEmpty()){
            //Querying NewRole groups and putting user's userRoleID(group's relatedId) as key into map and groups id as its value           
            roleGroup = [SELECT Id, RelatedId, Type FROM Group WHERE (RelatedId IN: NewRoleSet) and type = 'role'];
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
                            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error During Insertion',Core_Details__c =  str+'--'+ err.getMessage()  , Core_Origin__c='CRM_OpportunityOwnerUpdate.OpportunityShare', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM', Core_sObjectId__c = sr.getId())); 
                        }
                    }
                }
                
            }            
        }
        
        if(logEntries.size()>0)
        {
            Insert logEntries;
         }
        
    }
    
    private static void opportunityTechnicalOwnerUpdate(Map < Id, Opportunity > mapNewsObject, Id priorOppOwnerId) {
        Set<Id> uniqueOpptyIdsSet = new Set<Id>();
        //Start - Adding the new Recurssive check
        if(!uniqueOpptyIdsSet.isEmpty() && !Test.isRunningTest()){
            for(Id oppId : mapNewsObject.keySet()){
                if(uniqueOpptyIdsSet.contains(oppId)){
                    return;
                }
            }
        }
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        //END - Adding the new Recurssive check 
        
        // List to store opportunity team members to be inserted
        List < OpportunityTeamMember > lstOpportunityTeamMember = new LIst < OpportunityTeamMember > ();
        
        // Map to store opportunity owner Id and opportunity
        Map < Id, List<Opportunity>> mapOpportunityOwnerOpportunity = new Map <Id, List<Opportunity>> (); 
        
        // Adding all the opportunities 
        List<Opportunity> lstOwnerOpportunities = new List<Opportunity>(); 
        
        // Team Constants
        String sTeamMember          = System.Label.Core_Team_Member;          // String to store 'Team Member' value             
        String sTechnicalOwner      = System.Label.Core_Technical_Owner;      // String to store 'Technical Owner' value 
        String sOpportunityOwner100 = System.Label.Core_Opportunity_Owner;    // String to store 'Opportunity Owner (100%)' value             
        // Adding all the opportunities for which opportunity team members needs to created for update
        List<Opportunity> lstUpdatedOpportunities = new List<Opportunity>();
        
        
        
        //Map to store Oppty Team Member's user Id and OpportunityId
        Map<Id, Id> mapTeamMemberIdOpportunityId = new Map<Id, Id>();
        
        Id designRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        
        // Cleanup Log Entries - Check to toggle creation of log entries for Sales Evolve 
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();      
        
        //Adding try catch block
        try{
            // Checking if its an update or insert
            if (priorOppOwnerId != null) {
                
            
                //Map to store DDR Opportunity's partner account owner ID 
                Map<Id, Opportunity> getDDRpartnerAccOwnerIdMap = new Map<Id, Opportunity>([SELECT id, Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerId 
                                                                                            FROM Opportunity 
                                                                                            WHERE Opportunity.Core_Opportunity_Coverage_Nm__c='Partner-Led Opportunity' AND 
                                                                                            Core_Design_Registration_Id__c != '' AND id IN :mapNewsObject.keyset()]);
                
                // Iterating over the list of opportunity records and checking if there is any change for Opportunity owner
                for (Opportunity opp: mapNewsObject.values()) {
                    
                    String lstElements =  opp.Core_OpportunityTeamMembers__c != null ? opp.Core_OpportunityTeamMembers__c : '';
                    String[] lstElementsTab = lstElements.split('\\,'); 
                    // The Technical Owner is assigned AND
                    // 
                    // We have a New Owner & the Technical Owner is not the New Owner
                    // OR
                    // We have a New Technical Owner
                    // Adding Opportunity Team member for Technical Owner                 
                    if ((opp.Core_Technical_Owner__c != Null) && (opp.Core_Technical_Owner__c != opp.OwnerId))
                    { 
                        if ((priorOppOwnerId != opp.OwnerId) ||  (opp.Core_Technical_Owner__c != null))
                        {
                            OpportunityTeamMember otm  = new OpportunityTeamMember();
                            otm.TeamMemberRole         = sTechnicalOwner;
                            otm.UserId                 = opp.Core_Technical_Owner__c;
                            otm.OpportunityId          = opp.Id;
                            otm.OpportunityAccessLevel = 'Edit';// Added edit access to opportunity for OpportunitTeamMember
                            if(opp.recordtypeId == designRecordTypeId){
                                otm.Core_Production_Win_Member_Role__c = sTechnicalOwner;
                            }
                            //--defaulting-previous-description-of-contribution
                            
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
                            lstOpportunityTeamMember.add(otm);
                        }
                    }
                    // Added for inserting partner account owner whenever  DDR opportunity's oppty owner is getting updated 
                    If(opp.OwnerId!= null && priorOppOwnerId != opp.OwnerId && opp.Core_Opportunity_Coverage_Nm__c=='Partner-Led Opportunity')
                    {
                        OpportunityTeamMember createOppTeamMember = new OpportunityTeamMember();
                        createOppTeamMember.TeamMemberRole = sTeamMember;
                        createOppTeamMember.OpportunityId = opp.id;
                        //If partner account owner is not present in DDR opportunity team, then only insert
                        if(!mapTeamMemberIdOpportunityId.containskey(getDDRpartnerAccOwnerIdMap.get(opp.Id).Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerId))      
                        {
                            createOppTeamMember.userid = getDDRpartnerAccOwnerIdMap.get(opp.Id).Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerId;
                            
                            //defaulting-previous-description-of-contribution
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
                            lstOpportunityTeamMember.add(createOppTeamMember);
                        }
                    }
                }
            } 
            
            // Inserting list of opportunity team members   
            if(!lstOpportunityTeamMember.isEmpty())
            {
                Database.SaveResult[] srList = Database.insert(lstOpportunityTeamMember, false);
                Integer iDatabaseUpdateIndex = 0; 
                // Capturing the logs for error records
                for(OpportunityTeamMember oppT:lstOpportunityTeamMember){
                }
                for (Database.SaveResult sr : srList) 
                {        
                    if (!sr.isSuccess()) 
                    {         
                        for(Database.Error err : sr.getErrors()) 
                        {
                            mapNewsObject.get(lstOpportunityTeamMember.get(iDatabaseUpdateIndex).OpportunityId).addError(err.getMessage());
                            //Adding log entries 
                            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = err.getMessage(), Core_Origin__c='CRM_OpportunityOwnerUpdate.opportunityTechnicalOwnerUpdate', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve', Core_sObjectId__c = sr.getId()));
                        }
                    }
                    
                    iDatabaseUpdateIndex++;
                }
            } 
            
               //List to store Team Member Records
            List<OpportunityTeamMember> OppTeamMember = [SELECT Id, OpportunityId, TeamMemberRole, UserId, User.IsActive, Core_Description_of_Contribution__c , Core_Production_Win_Member_Role__c,Opportunity.RecordTypeId
                                                         FROM OpportunityTeamMember 
                                                         WHERE OpportunityId IN :mapNewsObject.keyset()];
            
            
            List<OpportunityTeamMember> otmUpdates = new List<OpportunityTeamMember>();
            
            if(OppTeamMember != null){
            for (OpportunityTeamMember otm : OppTeamMember)
            {
                
                if (mapNewsObject.get(otm.OpportunityId).OwnerId == otm.UserId) {
                    otm.TeamMemberRole = sOpportunityOwner100;
                    if(otm.Opportunity.RecordTypeId == designRecordTypeId){
                        otm.Core_Production_Win_Member_Role__c = sOpportunityOwner100;
                    }
                    otmUpdates.add(otm);
                }
            }
            }
            
            if (!otmUpdates.isEmpty()) {
                 
                Database.SaveResult[] srListUpdates = Database.update(otmUpdates, false);
            } 
            
            
            
            
            
            //START - Populating the recurssive check map with all processed oppty ids and adding try catch block             
            for(Id opptyIds : mapNewsObject.keySet()){
                uniqueOpptyIdsSet.add(opptyIds);
            }
            
        }catch(Exception e){
            //Adding log entries
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = e.getMessage(), Core_Origin__c='CRM_OpportunityOwnerUpdate.opportunityTechnicalOwnerUpdate', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));          
        }finally{
            //Cleanup Log Entries - Check to toggle creation of log entries for Sales Evolve
           if(!logEntries.isEmpty() && !logSwitch.isEmpty()){
                if(logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c){
                    insert logEntries;
                }
            }
        }
        //END - Populating the recurssive check map with all processed oppty ids and adding try catch block
        
    }
    
    private static void callQuoteTeamMemberShare(set<Id> pccOppId , set<Id> swOppId){
         List<Id> setSWOppId = null ;
        
         if(pccOppId.size()>0){
            Pricing_FinancialIncentive_BusinessLogic.createQuoteSharesForFI(pccOppId);
        }
        if(swOppId.size()>0){
            setSWOppId = new List<Id>(swOppId);
            Pricing_SW_QuoteBusinessLogic.createQuoteSharesForSW(setSWOppId);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}