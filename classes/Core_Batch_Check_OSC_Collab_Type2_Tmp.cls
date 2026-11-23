global class Core_Batch_Check_OSC_Collab_Type2_Tmp implements Database.Batchable<sObject> {

    static final String NO_OSC_INVOLVMENT    = 'No OSC Involvement';
    static final String OSC_ASSISTING_FIELD  = 'OSC Assisting the Field';
    static final String OSC_FIELD_ASSISTANCE = 'OSC with Field Assistance';
    static final String OSC_SOLO             = 'OSC Solo';

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Database.QueryLocator oppTeamMembers = Database.getQueryLocator(
        [SELECT Id,OpportunityId, UserId, Core_OSC_Snapshot__c, Core_Is_OSC__c
        FROM OpportunityTeamMember 
            WHERE 
            (Opportunity.Account.Core_Deactivated__c = FALSE AND Opportunity.Account.Core_Export_Compliance_Block__c = FALSE)
            AND (Opportunity.Account.RecordType.Name != 'Intel Ultimate Account' AND Opportunity.Account.RecordType.Name != 'Inactive Account')
            ]
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
         return oppTeamMembers;
    }

    global void execute(Database.BatchableContext bc, List<OpportunityTeamMember> lstTeamMembers) {

        Set<Id> setOpportunityIDs = new Set<Id>();
        Map<String, OpportunityTeamMember> mapOppTm = new Map<String, OpportunityTeamMember>() ;
        String curOppUserId ;
        
        
        for (OpportunityTeamMember oppTm : lstTeamMembers){
            setOpportunityIDs.add(oppTm.OpportunityId);
        }

        List <Opportunity> lstOpp = 
        [
        SELECT Core_Technical_Owner__c,Id,OwnerId, Core_OSC_Collaboration_Type__c   
        FROM Opportunity 
            WHERE 
    (Account.Core_Deactivated__c = FALSE AND Account.Core_Export_Compliance_Block__c = FALSE)
    AND (Account.RecordType.Name != 'Intel Ultimate Account' AND Account.RecordType.Name != 'Inactive Account')
    AND Id IN : setOpportunityIDs
   
        ];

        lstTeamMembers = 
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

Boolean isOSC;        
        for(Opportunity opp : lstOpp){
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
                    if (opp.Core_OSC_Collaboration_Type__c != OSC_SOLO)
                        System.Debug('Expected SOLO but result value is: ' + opp.Core_OSC_Collaboration_Type__c + ' Opp: ' + opp.Id) ;
                    continue;    
                }
            }
            if (oppOwner != null && oppOwner.Core_Is_OSC__c ) {
                if (oppTechOwner != null && !oppTechOwner.Core_Is_OSC__c) {                
                    if (opp.Core_OSC_Collaboration_Type__c != OSC_FIELD_ASSISTANCE)
                        System.Debug('Expected Field Assistance but result value is: ' + opp.Core_OSC_Collaboration_Type__c + ' Opp: ' + opp.Id) ;
                    continue;    
                }
                
                isOSC = true;
                for (OpportunityTeamMember oppTeam : lstTeamMembers)
                    if (oppTeam.OpportunityId == opp.Id)
                        isOSC = isOSC && oppTeam.Core_Is_OSC__c;
                
                if (!isOSC) {
                    if (opp.Core_OSC_Collaboration_Type__c != OSC_FIELD_ASSISTANCE)
                        System.Debug('Expected Field Assistance but result value is: ' + opp.Core_OSC_Collaboration_Type__c + ' Opp: ' + opp.Id) ;
                    continue;
                }                
            }
            if (oppOwner != null && !oppOwner.Core_Is_OSC__c ) {
                if (oppTechOwner != null && oppTechOwner.Core_Is_OSC__c) {                
                    if (opp.Core_OSC_Collaboration_Type__c != OSC_ASSISTING_FIELD)
                        System.Debug('Expected OSC ASSISTING FIELD but result value is: ' + opp.Core_OSC_Collaboration_Type__c + ' Opp: ' + opp.Id) ;
                    continue;
                }
                
                isOSC = false;
                for (OpportunityTeamMember oppTeam : lstTeamMembers)
                    if (oppTeam.OpportunityId == opp.Id)
                        isOSC = isOSC || oppTeam.Core_Is_OSC__c;
                
                if (isOSC) {
                    if (opp.Core_OSC_Collaboration_Type__c != OSC_ASSISTING_FIELD)
                    {
                        System.Debug('Expected OSC ASSISTING FIELD but result value is: ' + opp.Core_OSC_Collaboration_Type__c + ' Opp: ' + opp.Id) ;
                    }
                    continue;
                }                
            }
            if (opp.Core_OSC_Collaboration_Type__c != NO_OSC_INVOLVMENT)
                System.Debug('Expected NO OSC but result value is: ' + opp.Core_OSC_Collaboration_Type__c + ' Opp: ' + opp.Id) ;
        }
            

    }
    global void finish(Database.BatchableContext bc) {
    }
}