public without sharing class CRM_VBS_SOARTeamSyncHandler {
    @InvocableMethod(label='Sync SOAR team to Opp' description='Copy SOAR Team to Opportunity Team')
    public static void syncTeams(List<Id> updatedSOARs) {
        // Maps to hold the SOAR Teams and Opportunity Teams for comparison
        Map<Id, List<CRM_VBS_SOAR_Team__c>> soarTeamMap = new Map<Id, List<CRM_VBS_SOAR_Team__c>>();
        Map<Id, List<OpportunityTeamMember>> oppTeamMap = new Map<Id, List<OpportunityTeamMember>>();
        try{
            
            // Query SOAR Teams related to the updated SOAR records
            List<CRM_VBS_SOAR_Team__c> soarTeams = [SELECT Id, CRM_VBS_Team_member__c, CRM_VBS_Team_Role__c,CRM_VBS_Description_of_Contribution__c, CRM_VBS_SOAR__r.CRM_VBS_SOAR_Opportunity__c FROM CRM_VBS_SOAR_Team__c WHERE CRM_VBS_SOAR__c IN :updatedSOARs AND CRM_VBS_Team_member__r.IsActive = true];
            // Organize SOAR Teams by related Opportunity Id
            for (CRM_VBS_SOAR_Team__c team : soarTeams) {
                if (!soarTeamMap.containsKey(team.CRM_VBS_SOAR__r.CRM_VBS_SOAR_Opportunity__c)) {
                    soarTeamMap.put(team.CRM_VBS_SOAR__r.CRM_VBS_SOAR_Opportunity__c, new List<CRM_VBS_SOAR_Team__c>()); 
                }
                soarTeamMap.get(team.CRM_VBS_SOAR__r.CRM_VBS_SOAR_Opportunity__c).add(team);
            }
            
            // Query Opportunity Teams related to the Opportunities of updated SOAR records
            List<OpportunityTeamMember> oppTeams = [SELECT Id,User.IsActive, TeamMemberRole,UserId,Core_Description_of_Contribution__c,  OpportunityId FROM OpportunityTeamMember WHERE OpportunityId IN :soarTeamMap.keySet()];
            // Organize Opportunity Teams by Opportunity Id
            for (OpportunityTeamMember member : oppTeams) {
                if (!oppTeamMap.containsKey(member.OpportunityId)) {
                    oppTeamMap.put(member.OpportunityId, new List<OpportunityTeamMember>());
                }
                oppTeamMap.get(member.OpportunityId).add(member);
            }
            
            // Lists to hold records to be inserted or deleted
            List<OpportunityTeamMember> oppTeamMembersToInsertUpdate = new List<OpportunityTeamMember>();
            List<OpportunityTeamMember> oppTeamMembersToDelete = new List<OpportunityTeamMember>();
            
            // Iterate over the SOAR Teams and perform the necessary operations
            for (Id oppId : soarTeamMap.keySet()) {
                Map<Id, OpportunityTeamMember> oppTeamMemberMap = new Map<Id, OpportunityTeamMember>();
                for (OpportunityTeamMember oppMember : oppTeamMap.get(oppId)) {
                    oppTeamMemberMap.put(oppMember.UserId, oppMember);
                }
                
                for (CRM_VBS_SOAR_Team__c soarMember : soarTeamMap.get(oppId)) {
                    system.debug('---test--'+soarMember);
                    
                    OpportunityTeamMember correspondingOppMember = oppTeamMemberMap.get(soarMember.CRM_VBS_Team_member__c);
                    system.debug('correspondingOppMember'+correspondingOppMember);
                     if (correspondingOppMember != null && correspondingOppMember.User.IsActive &&  (correspondingOppMember.Core_Description_of_Contribution__c != soarMember.CRM_VBS_Description_of_Contribution__c || correspondingOppMember.TeamMemberRole != soarMember.CRM_VBS_Team_Role__c )) 
                     {
                         correspondingOppMember.Core_Description_of_Contribution__c = soarMember.CRM_VBS_Description_of_Contribution__c +'\n'+ (correspondingOppMember.Core_Description_of_Contribution__c != null ? correspondingOppMember.Core_Description_of_Contribution__c : ''); 
                         correspondingOppMember.TeamMemberRole = soarMember.CRM_VBS_Team_Role__c;
                        // Update the record in the database
                        oppTeamMembersToInsertUpdate.add(correspondingOppMember);
                        
                    }
                   
                    // If the user is present in the SOAR team but not in the Opportunity team, create a new record
                    if (correspondingOppMember == null) {
                        OpportunityTeamMember newMember = new OpportunityTeamMember(
                            OpportunityId = oppId,
                            UserId = soarMember.CRM_VBS_Team_member__c,
                            TeamMemberRole = soarMember.CRM_VBS_Team_Role__c,
                            Core_Description_of_Contribution__c = 'Team Member added as part of SOAR process \n'+ (soarMember.CRM_VBS_Description_of_Contribution__c != null ? soarMember.CRM_VBS_Description_of_Contribution__c : '')
                        );
                        oppTeamMembersToInsertUpdate.add(newMember);
                    }
                }
                
                
            }
            
            // Perform DML operations
            if (!oppTeamMembersToInsertUpdate.isEmpty()) {
                upsert oppTeamMembersToInsertUpdate;
            }
            
        }catch (Exception e) {
            system.debug('--error--'+e.getMessage());
            Core_Exceptions__c excep = new Core_Exceptions__c(Core_Exception__c = 'Failure : ########### - '+e.getStackTraceString()+' Cause'+e.getMessage(),Core_Class_Name__c ='CRM_VBS_SOARTeamSyncHandler',Core_Method_Name__c ='syncTeams');
           
            insert excep; 
            
        }
    }
}