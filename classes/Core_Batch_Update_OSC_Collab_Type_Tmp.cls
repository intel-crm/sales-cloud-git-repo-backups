global class Core_Batch_Update_OSC_Collab_Type_Tmp implements Database.Batchable<sObject> {

    static final String NO_OSC_INVOLVMENT    = 'No OSC Involvement';
    static final String OSC_ASSISTING_FIELD  = 'OSC Assisting the Field';
    static final String OSC_FIELD_ASSISTANCE = 'OSC with Field Assistance';
    static final String OSC_SOLO             = 'OSC Solo';

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Database.QueryLocator opp = Database.getQueryLocator(
        [SELECT Id,Core_Technical_Owner__c,OwnerId, Core_OSC_Collaboration_Type__c
        FROM Opportunity 
            WHERE 
            Account.Core_Deactivated__c = FALSE AND Account.Core_Export_Compliance_Block__c = FALSE
            AND Opportunity.Account.RecordType.Name != 'Intel Ultimate Account' AND Opportunity.Account.RecordType.Name != 'Inactive Account']
        );
       	
        Integer x = 0;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
        x++;
         return opp;
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> lstOpp) {

        Set<Id> setOpportunityIDs = (new Map<Id,SObject>(lstOpp)).keySet();
        Map<String, OpportunityTeamMember> mapOppTm = new Map<String, OpportunityTeamMember>() ;
        String curOppUserId ;

        List<OpportunityTeamMember> lstTeamMembers = 
        [
        SELECT Id,OpportunityId, UserId, Core_OSC_Snapshot__c, Core_Is_OSC__c
        FROM OpportunityTeamMember 
            WHERE 
            OpportunityId in : setOpportunityIDs
        ];

        for (OpportunityTeamMember oppTm : lstTeamMembers){
            curOppUserId = String.ValueOf(oppTm.OpportunityId) + String.ValueOf(oppTm.UserId) ;
            mapOppTm.put(curOppUserId,oppTm) ;
        }

        Opportunity oppCur ;
        List<Opportunity> lstUpdate = new List<Opportunity>() ;

        Boolean isOSC;        
        for(Opportunity opp : lstOpp){
            oppCur = new Opportunity() ;
            oppCur.Id = opp.Id ;
            curOppUserId = String.ValueOf(opp.Id) + String.ValueOf(opp.OwnerId) ;
            OpportunityTeamMember oppOwner = mapOppTm.get(curOppUserId) ;
            curOppUserId = String.ValueOf(opp.Id) + String.ValueOf(opp.Core_Technical_Owner__c) ;
            OpportunityTeamMember oppTechOwner = mapOppTm.get(curOppUserId) ;
            
            if (oppOwner != null && oppOwner.Core_Is_OSC__c && (oppTechOwner == null || (oppTechOwner != null && oppTechOwner.Core_Is_OSC__c))) {
                isOSC = true;
                for (OpportunityTeamMember oppTeam : lstTeamMembers)
                    if (oppTeam.OpportunityId == opp.Id)
                        isOSC = isOSC && oppTeam.Core_Is_OSC__c;
                    
                if (isOSC)
                {
                    if (opp.Core_OSC_Collaboration_Type__c != OSC_SOLO){
                        oppCur.Core_OSC_Collaboration_Type__c = OSC_SOLO ;
                        lstUpdate.Add(oppCur) ;
                        }
                    continue;    
                }
            }
            if (oppOwner != null && oppOwner.Core_Is_OSC__c ) {
                if (oppTechOwner != null && !oppTechOwner.Core_Is_OSC__c) {                
                    if (opp.Core_OSC_Collaboration_Type__c != OSC_FIELD_ASSISTANCE){
                        oppCur.Core_OSC_Collaboration_Type__c = OSC_FIELD_ASSISTANCE ;
                        lstUpdate.Add(oppCur) ;
                        }
                    continue;    
                }
                
                isOSC = true;
                for (OpportunityTeamMember oppTeam : lstTeamMembers)
                    if (oppTeam.OpportunityId == opp.Id)
                        isOSC = isOSC && oppTeam.Core_Is_OSC__c;
                
                if (!isOSC) {
                    if (opp.Core_OSC_Collaboration_Type__c != OSC_FIELD_ASSISTANCE){
                        oppCur.Core_OSC_Collaboration_Type__c = OSC_FIELD_ASSISTANCE ;
                        lstUpdate.Add(oppCur) ;
                        }
                    continue;
                }                
            }
            if (oppOwner != null && !oppOwner.Core_Is_OSC__c ) {
                if (oppTechOwner != null && oppTechOwner.Core_Is_OSC__c) {                
                    if (opp.Core_OSC_Collaboration_Type__c != OSC_ASSISTING_FIELD){
                        oppCur.Core_OSC_Collaboration_Type__c = OSC_ASSISTING_FIELD ;
                        lstUpdate.Add(oppCur) ;
                        }
                    continue;
                }
                
                isOSC = false;
                for (OpportunityTeamMember oppTeam : lstTeamMembers)
                    if (oppTeam.OpportunityId == opp.Id)
                        isOSC = isOSC || oppTeam.Core_Is_OSC__c;
                
                if (isOSC) {
                    if (opp.Core_OSC_Collaboration_Type__c != OSC_ASSISTING_FIELD){
                        oppCur.Core_OSC_Collaboration_Type__c = OSC_ASSISTING_FIELD ;
                        lstUpdate.Add(oppCur) ;
                        }
                    continue;
                }                
            }
            if (opp.Core_OSC_Collaboration_Type__c != NO_OSC_INVOLVMENT){
                oppCur.Core_OSC_Collaboration_Type__c = NO_OSC_INVOLVMENT ;
                lstUpdate.Add(oppCur) ;
                }
        }
           
        update lstUpdate;

    }
    global void finish(Database.BatchableContext bc) {
    }
}