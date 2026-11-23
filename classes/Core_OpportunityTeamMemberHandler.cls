/******************************************************************************************************************************************
Class Name  : Core_OpportunityTeamMemberHandler
Version     : 1.0 
Created Date: May 18, 2015
Function    : Class code for the trigger on OpportunityTeamMember
Modification Log :
* Developer         Date          Description
* ----------------------------------------------------------------------------                 
* Dave Hood         05/18/2015    Original version
* Shailaja Gandam   06/02/2015    added method to populate OSC collaboration type field 
* Dave Hood         03/10/2016    Added code to ignore Viewers + users with IT@Intel profile in team geo rollup
* Anand Sharma      06/06/2016    Added code to use OSC Snapshot values isntead of User.Core_Is_OSC__c flag
*****************************************************************************************************************************************/
public class Core_OpportunityTeamMemberHandler {

    static final String NO_OSC_INVOLVMENT    = 'No OSC Involvement';
    static final String OSC_ASSISTING_FIELD  = 'OSC Assisting the Field';
    static final String OSC_FIELD_ASSISTANCE = 'OSC with Field Assistance';
    static final String OSC_SOLO             = 'OSC Solo';
    
    public static boolean triggerUpdateGeoFlags=true;
    public static boolean triggerUpdateOSCType=true;
    
    private class GeoFlags {
        Boolean bAPJ = false;
        Boolean bASMO = false;
        Boolean bEMEA = false;
        Boolean bPRC = false;
    }
    
    public static void updateGeoFlags(List<OpportunityTeamMember> lstOldTeamMembers,
                                      Map<Id,OpportunityTeamMember> mapOldTeamMembers,
                                      List<OpportunityTeamMember> lstNewTeamMembers)
    {
        
        //Make Sure trigger does not run twice
        if(!triggerUpdateGeoFlags)
            return;
        
        //Set the trigger flag to false
        triggerUpdateGeoFlags = false;
        // Opportunity IDs that have team members changing        
        Set<Id> setOpportunityIDs = new Set<Id>();
        
        // Check to see if we're deleting team members
        if (lstNewTeamMembers == null) {            
            // Iterate through the old team members and add the opportunity ID values to a set,
            // since they're the opportunities where the flags may need to be changed
            for (OpportunityTeamMember member : lstOldTeamMembers) {
                setOpportunityIDs.add(member.OpportunityId);
            }
        }
        // Else it's an insert or an update
        else {            
            // Iterate through the new team members and add the opportunity ID values to a set,
            // since they're the opportunities where the flags may need to be changed
            for (OpportunityTeamMember member : lstNewTeamMembers) {
                setOpportunityIDs.add(member.OpportunityId);
            }
        }
        
        // Use that set to pull current geo flags where team members are changing
        Map<Id,Opportunity> mapOppsAndOldFlags =
            new Map<Id,Opportunity>([select Id, Core_Opportunity_Team_Geo_APJ__c, Core_Opportunity_Team_Geo_ASMO__c,
                                     Core_Opportunity_Team_Geo_EMEA__c, Core_Opportunity_Team_Geo_PRC__c
                                     from Opportunity where Id in :setOpportunityIDs]);
        
        // Also for that set of ID values, get the current list of team members and their geos, where Role != Viewer and Profile != IT@Intel
        List<OpportunityTeamMember> lstTeamMembersAndNewGeos = [select OpportunityId, UserId, User.Core_User_Geo__c
                                                                from OpportunityTeamMember where OpportunityId in :setOpportunityIDs
                                                                and (User.Profile.Name != :Label.Core_IT_Intel_Profile_Name) and
                                                                    (TeamMemberRole != :Label.Core_Opportunity_Team_Role_Viewer)];
        
        // Iterate through that list to create a map of IDs and what the geo flags should be
        Map<Id,GeoFlags> mapOppsAndNewGeoFlags = new Map<Id,GeoFlags>();
        
        for (OpportunityTeamMember member : lstTeamMembersAndNewGeos) {
            
            GeoFlags newGeoFlags;
            
            if (mapOppsAndNewGeoFlags.containsKey(member.OpportunityId)) {
                newGeoFlags = mapOppsAndNewGeoFlags.get(member.OpportunityId);                    
            }
            else {
                newGeoFlags = new GeoFlags();
            }                
            
            if (member.User.Core_User_Geo__c == 'APJ')
                newGeoFlags.bAPJ = true;
            else if (member.User.Core_User_Geo__c == 'ASMO')
                newGeoFlags.bASMO = true;
            else if (member.User.Core_User_Geo__c == 'EMEA')
                newGeoFlags.bEMEA = true;
            else if (member.User.Core_User_Geo__c == 'PRC')
                newGeoFlags.bPRC = true;
            
            mapOppsAndNewGeoFlags.put(member.OpportunityId, newGeoFlags);
        }
        
        // Iterate through that list to check to see where the values are different, to see what we need to update
        Set<Id> setOppIDsToUpdate = new Set<Id>();
        for (Id oppId : mapOppsAndNewGeoFlags.keySet()) {
            
            Boolean bUpdateOpp = false;
            if (mapOppsAndOldFlags.get(oppId).Core_Opportunity_Team_Geo_APJ__c != mapOppsAndNewGeoFlags.get(oppId).bAPJ)
                bUpdateOpp = true;
            else if (mapOppsAndOldFlags.get(oppId).Core_Opportunity_Team_Geo_ASMO__c != mapOppsAndNewGeoFlags.get(oppId).bASMO)
                bUpdateOpp = true;
            else if (mapOppsAndOldFlags.get(oppId).Core_Opportunity_Team_Geo_EMEA__c != mapOppsAndNewGeoFlags.get(oppId).bEMEA)
                bUpdateOpp = true;
            else if (mapOppsAndOldFlags.get(oppId).Core_Opportunity_Team_Geo_PRC__c != mapOppsAndNewGeoFlags.get(oppId).bPRC)
                bUpdateOpp = true;
            
            if (bUpdateOpp)
                setOppIDsToUpdate.add(oppId);
        }
        
        List<Opportunity> lstOppsToUpdate = [select Id, Core_Opportunity_Team_Geo_APJ__c, Core_Opportunity_Team_Geo_ASMO__c,
                                             Core_Opportunity_Team_Geo_EMEA__c, Core_Opportunity_Team_Geo_PRC__c
                                             from Opportunity where Id in :setOppIDsToUpdate];
        for (Opportunity opp : lstOppsToUpdate) {
            opp.Core_Opportunity_Team_Geo_APJ__c = mapOppsAndNewGeoFlags.get(opp.Id).bAPJ;
            opp.Core_Opportunity_Team_Geo_ASMO__c = mapOppsAndNewGeoFlags.get(opp.Id).bASMO;
            opp.Core_Opportunity_Team_Geo_EMEA__c = mapOppsAndNewGeoFlags.get(opp.Id).bEMEA;
            opp.Core_Opportunity_Team_Geo_PRC__c = mapOppsAndNewGeoFlags.get(opp.Id).bPRC;
        }
        update lstOppsToUpdate;
    }


    private static void assignOSCCollaborationType(Opportunity oppForUpdate, String collabType, List<Opportunity>oppUpdateList)
    {
        if (oppForUpdate.Core_OSC_Collaboration_Type__c != collabType) {                                    
            oppForUpdate.Core_OSC_Collaboration_Type__c = collabType;       
            oppUpdateList.add(oppForUpdate);
        }                                 
    }


    //method to populate OSC Collaboration type field required for reporting    
    public static void updateOSCType(List<OpportunityTeamMember> updateTeamMembers)
    {
        
         //Make Sure trigger does not run twice
        if(!triggerUpdateOSCType)
            return;
        
        //Set the trigger flag to false
        triggerUpdateOSCType = false;
        
        if (updateTeamMembers == NULL)
            return;

        Set<Id> setOpportunityIDs = new Set<Id>();
        // New maps to store Opp Team Member
        Map<String, OpportunityTeamMember> mapOppTm = new Map<String, OpportunityTeamMember>() ;
        
        String curOppUserId ;


        for (OpportunityTeamMember oppTeam : updateTeamMembers){
            setOpportunityIDs.add(oppTeam.OpportunityId);
        }
       
        List<Opportunity> lstOppUpdates = new List<Opportunity>();

        List<Opportunity> lstOpportunity = [SELECT Id, Owner.Core_Is_OSC__c, Core_Technical_Owner__r.Core_Is_OSC__c, Core_OSC_Collaboration_Type__c
                                            FROM Opportunity 
                                            WHERE Id IN :setOpportunityIDs];


        //for the set of ID values, get the current list of team members and their IS OSC attribute
        List<OpportunityTeamMember> lstTeamMembers = [SELECT OpportunityId, UserId,Core_Is_OSC__c, TeamMemberRole
                                                      FROM OpportunityTeamMember 
                                                      WHERE OpportunityId IN :setOpportunityIDs];

        for (OpportunityTeamMember oppTeam : lstTeamMembers){
            // Add Team members in the map
            curOppUserId = String.ValueOf(oppTeam.OpportunityId) + String.ValueOf(oppTeam.UserId) ;
            mapOppTm.put(curOppUserId,oppTeam) ;
        }
                                                                
        Boolean isOSC;        
        for(Opportunity opp : lstOpportunity){
        
                
            // if Opportunity Owner, Technical Owner, and All Team Members have "Is OSC? = true", then OSC Solo
            //

            // Get Opportunity Owner from the map
            curOppUserId = String.ValueOf(opp.Id) + String.ValueOf(opp.Owner.Id) ;
            OpportunityTeamMember oppOwner = mapOppTm.get(curOppUserId) ;
            
            
            // Get Technical Owner from the map
            curOppUserId = String.ValueOf(opp.Id) + String.ValueOf(opp.Core_Technical_Owner__c) ;
            OpportunityTeamMember oppTechOwner = mapOppTm.get(curOppUserId) ;
            
            if (oppOwner != null && oppOwner.Core_Is_OSC__c && (oppTechOwner == null || (oppTechOwner != null && oppTechOwner.Core_Is_OSC__c))) {
                isOSC = true;
                for (OpportunityTeamMember oppTeam : lstTeamMembers)
                    if (oppTeam.OpportunityId == opp.Id)
                        isOSC = isOSC && oppTeam.Core_Is_OSC__c;
                    
                if (isOSC)
                {
                    assignOSCCollaborationType(opp, OSC_SOLO, lstOppUpdates);
                    continue;    
                }
            }

            
            // If Opportunity Owner has "Is OSC? = true", and Technical Owner or Any Team Member has "Is OSC? = false", 
            // then OSC with Field Assistance
            //
              if (oppOwner != null && oppOwner.Core_Is_OSC__c ) {
                if (oppTechOwner != null && !oppTechOwner.Core_Is_OSC__c) {                
                    assignOSCCollaborationType(opp, OSC_FIELD_ASSISTANCE, lstOppUpdates);
                    continue;
                }
                
                isOSC = true;
                for (OpportunityTeamMember oppTeam : lstTeamMembers)
                    if (oppTeam.OpportunityId == opp.Id)
                        isOSC = isOSC && oppTeam.Core_Is_OSC__c;
                
                if (!isOSC) {
                    assignOSCCollaborationType(opp, OSC_FIELD_ASSISTANCE, lstOppUpdates);
                    continue;
                }                
            }


            // If Opportunity Owner has "Is OSC? = false", and Technical Owner or Any Team Member has "Is OSC? = true", 
            // then OSC Assisting the Field
            //
            if (oppOwner != null && !oppOwner.Core_Is_OSC__c ) {
                if (oppTechOwner != null && oppTechOwner.Core_Is_OSC__c) {                
                    assignOSCCollaborationType(opp, OSC_ASSISTING_FIELD, lstOppUpdates);
                    continue;
                }
                
                isOSC = false;
                for (OpportunityTeamMember oppTeam : lstTeamMembers)
                    if (oppTeam.OpportunityId == opp.Id)
                        isOSC = isOSC || oppTeam.Core_Is_OSC__c;
                
                if (isOSC) {
                    assignOSCCollaborationType(opp, OSC_ASSISTING_FIELD, lstOppUpdates);
                    continue;
                }                
            }

            // Else "No OSC Involvement"
            assignOSCCollaborationType(opp, NO_OSC_INVOLVMENT, lstOppUpdates);
        
        }

        if (lstOppUpdates.size() > 0)
            update lstOppUpdates;        
            
    } 
}