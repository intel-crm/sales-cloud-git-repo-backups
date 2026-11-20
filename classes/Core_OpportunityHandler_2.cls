public without sharing class Core_OpportunityHandler_2{
    
    public static Boolean isNonCloneFunction = true;
    //TWC4767-931 : Technical Owner team member creation 
    //NP : Add Technical Owner (Internal only) as Opportunity Team Member if not already, during Opp submission for aprroval and before approval
    public static void checkOppStatus(List<Opportunity> newOppList){
        List<Opportunity> checkForTOTM = new List<Opportunity>();
        Set<id> userList = new Set<id>();
        Map<id,User> userRec = new Map<id,User>();
        try{
            for(Opportunity opp: newOppList){
                if(opp.Core_Approval_Status__c == 'Submitted' || opp.Core_Approval_Status__c == 'Approved'){
                    userList.add(opp.Core_Technical_Owner__c);
                }                
            }
            if(!userList.isEmpty() && userList != null){
                userRec = new Map<id,User>([select id from User where id in: userList and UserType != 'PowerPartner']);
            }
            
            
            for(Opportunity opp: newOppList){
                if(opp.Core_Technical_Owner__c != null && userRec.containsKey(Id.valueOf(opp.Core_Technical_Owner__c)) 
                   && (opp.Core_Approval_Status__c == 'Submitted' || opp.Core_Approval_Status__c == 'Approved')) {
                       checkForTOTM.add(opp);
                   }
            }
            if(checkForTOTM.size()>0) {
                TOAdditionToOTM(checkForTOTM);
            }
        }
        catch(Exception ex) { 
            PMP_Utility.logError(ex, 'Core_OpportunityHandler_2.checkOppStatus');
        }
    }
    
    public static void TOAdditionToOTM (List<Opportunity> newOppList) {
        Map<id,id> oppToTOMap = new Map<id,id>();
        Map<id,list<id>> oppToTMMap = new Map<id,List<id>>();
        List<OpportunityTeamMember> oTMList = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> oTMInsertList = new List<OpportunityTeamMember>();
        List<id> teamMembersList;
        
        try{
            for(Opportunity opp: newOppList){
                if(opp.Core_Technical_Owner__c != null){
                    oppToTOMap.put(opp.id,opp.Core_Technical_Owner__c); 
                } 
            }
            
            oTMList = [select id, UserId, OpportunityId from OpportunityTeamMember where OpportunityId in : oppToTOMap.keyset()];
            
            if(oTMList.size()>0) {
                for(OpportunityTeamMember oTM : oTMList) {
                    if(!oppToTMMap.containsKey(oTM.OpportunityId)) { teamMembersList = new List<id>(); }
                    teamMembersList.add(oTM.UserId);
                    oppToTMMap.put(oTM.OpportunityId,teamMembersList);     
                }
                
                for(id opp: oppToTMMap.keyset()) {
                    List<id> teamMembers = oppToTMMap.get(opp);
                    if(!teamMembers.contains(oppToTOMap.get(opp))){
                        OpportunityTeamMember createOppTM = new OpportunityTeamMember();
                        createOppTM.OpportunityId = opp;
                        createOppTM.TeamMemberRole = 'Technical Owner (100%)';
                        createOppTM.userid = oppToTOMap.get(opp);
                        createOppTM.OpportunityAccessLevel = 'Edit';
                        oTMInsertList.add(createOppTM);   
                    }
                }
                
                if(oTMInsertList.size()>0) {
                    Database.SaveResult[] oppTeamMemberUpdate = Database.insert(oTMInsertList, false); 
                }    
            }       
        }
        catch(Exception ex) { 
            Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = ex.getMessage().abbreviate(254), Core_Origin__c = 'Opportunity Update - TO addition to Opp Team Member', Core_Severity__c = 'High', Core_When__c = System.Now(), Core_Project__c = 'Sales', Core_Details__c = 'Line number:'+ex.getLineNumber()+', Stack trace: '+ex.getStackTraceString());
            insert ExcepLog;
        } 
    }
    //This method will call the PRM_PartnerDealOpportunitySharingService class for partner deal opportunity sharing to OO
    public static void sharePRMDealOpptyToOpptyOwner(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap){
        
        List<Core_Log_Entry__c> captureLogsErr= new List<Core_Log_Entry__c>();
        Set<Id> opportunityIds = new Set<Id>();
        try{
            for (Opportunity opty : newOppList) {
                if (opty.Core_Opportunity_Owner__c != oldOppMap.get(opty.Id).Core_Opportunity_Owner__c) {
                    opportunityIds.add(opty.Id);
                }
                if (!opportunityIds.isEmpty()) {
                    PRM_PartnerDealOpportunitySharingService.updateOpportunityOwnerSharing(opportunityIds);
                }
            }
        }
        catch(exception e){
            captureLogsErr.add(new Core_Log_Entry__c(Core_Details__c = e.getMessage(), Core_Message__c = 'Core_OpportunityHandler_2.sharePRMDealOpptyToOpptyOwner', Core_Severity__c = 'Low', Core_Origin__c = 'core_OpportunityLineItemHandler', Core_When__c = System.now()));
        }
        finally{
            if(!captureLogsErr.isEmpty()){
                insert captureLogsErr;
            }
        }
        
    }
    
    public class InputData{
        @InvocableVariable
        public Id accOwnerId;
        @InvocableVariable
        public Id priorAccountOwnerId;
        @InvocableVariable
        public Id accId;
    }
    
    @InvocableMethod
    public static void invokeAccount360OpportunitySharingforOnwerChange(List<InputData> inputData)
    {
        
        Core_CRM_Labels__c updateSwitch = Core_CRM_Labels__c.getValues('CRM_OpportunityOwnerUpdateSwitch');
        if(updateSwitch!= Null && updateSwitch.Value__c.equalsIgnoreCase('true')){
            
            Id priorAccOwnerId;
            Id accountOwnerId;
            Id accountId;
            for(InputData inp : inputData){
                if(inp != null){
                    priorAccOwnerId = inp.priorAccountOwnerId;
                    accountOwnerId = inp.accOwnerId;
                    accountId = inp.accId;
                }
            }
            
            List<Opportunity> opportunities = [
                SELECT Id, AccountId, StageName, OwnerId, Account.OwnerId,IsClosed,Core_Technical_Owner__c,Core_Opportunity_Coverage_Nm__c,Core_Coverage_Type_Nm__c,RecordTypeId,Core_Design_Registration_Id__r.Core_Partner_Account_Id__r.OwnerId,Core_OpportunityTeamMembers__c,CRM_SW_Flag_Ind__c
                FROM Opportunity 
                WHERE AccountId =:accountId AND OwnerId =:accountOwnerId 
                AND StageName IN ('Qualify', 'Define', 'Design', 'Develop') AND IsClosed = false
            ];
            List<Opportunity> opportunitiesId = new List<Opportunity>();
            for (Opportunity opp : opportunities) {
                opportunitiesId.add(opp);
            }
            
            if(opportunitiesId.size() > 0 || opportunitiesId != null){
                
                Database.executeBatch(new CRM_OpportunityOwnerUpdate(opportunitiesId,priorAccOwnerId), 50);
            }
        }
    }
    
}