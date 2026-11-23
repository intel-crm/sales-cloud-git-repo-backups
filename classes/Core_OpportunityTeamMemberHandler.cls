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
public without sharing  class Core_OpportunityTeamMemberHandler {//TWC3123-5359 included without sharing //TWC3123-5759 Added without sharing keyword to fix code scan issue
    
    public static String fromEmailAddress = System.Label.Core_SetFromEmailAddress;//Organization-Wide Email Address
    static final String NO_OSC_INVOLVMENT    = 'No OSC Involvement';
    static final String OSC_ASSISTING_FIELD  = 'OSC Assisting the Field';
    static final String OSC_FIELD_ASSISTANCE = 'OSC with Field Assistance';
    static final String OSC_SOLO             = 'OSC Solo';
    
    public static boolean triggerUpdateGeoFlags=true;
    public static boolean triggerUpdateOSCType=true;
    public static boolean GetUserIdsFromGroupCheck=true; 
    public static boolean dcgSalesGroupLimitCheck=true;
    public static boolean userCheck=true;
    private class GeoFlags {
        Boolean bAPJ = false;
        Boolean bASMO = false;
        Boolean bEMEA = false;
        Boolean bPRC = false;
        Boolean bINDIA = false;
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
                                     Core_Opportunity_Team_Geo_EMEA__c, Core_Opportunity_Team_Geo_PRC__c,CRM_Opportunity_Team_Geo_INDIA__c
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
            else if(member.User.Core_User_Geo__c == 'INDIA')
                newGeoFlags.bINDIA = true;
            
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
            else if (mapOppsAndOldFlags.get(oppId).CRM_Opportunity_Team_Geo_INDIA__c != mapOppsAndNewGeoFlags.get(oppId).bINDIA)
                bUpdateOpp = true;
            
            if (bUpdateOpp)
                setOppIDsToUpdate.add(oppId);
        }
        
        List<Opportunity> lstOppsToUpdate = [select Id, Core_Opportunity_Team_Geo_APJ__c, Core_Opportunity_Team_Geo_ASMO__c,
                                             Core_Opportunity_Team_Geo_EMEA__c, Core_Opportunity_Team_Geo_PRC__c,CRM_Opportunity_Team_Geo_INDIA__c
                                             from Opportunity where Id in :setOppIDsToUpdate];
        for (Opportunity opp : lstOppsToUpdate) {
            opp.Core_Opportunity_Team_Geo_APJ__c = mapOppsAndNewGeoFlags.get(opp.Id).bAPJ;
            opp.Core_Opportunity_Team_Geo_ASMO__c = mapOppsAndNewGeoFlags.get(opp.Id).bASMO;
            opp.Core_Opportunity_Team_Geo_EMEA__c = mapOppsAndNewGeoFlags.get(opp.Id).bEMEA;
            opp.Core_Opportunity_Team_Geo_PRC__c = mapOppsAndNewGeoFlags.get(opp.Id).bPRC;
            opp.CRM_Opportunity_Team_Geo_INDIA__c = mapOppsAndNewGeoFlags.get(opp.Id).bINDIA;
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
        
        List<Opportunity> lstOpportunity = [SELECT Id, Owner.Core_Is_OSC__c, Core_Technical_Owner__r.Core_Is_OSC__c, Core_OSC_Collaboration_Type__c FROM Opportunity WHERE Id IN :setOpportunityIDs];
        
        //for the set of ID values, get the current list of team members and their IS OSC attribute
        List<OpportunityTeamMember> lstTeamMembers = [SELECT OpportunityId, UserId,User.ContactID,User.Email,Core_Is_OSC__c, TeamMemberRole
                                                      FROM OpportunityTeamMember 
                                                      WHERE OpportunityId IN :setOpportunityIDs];
        
        for (OpportunityTeamMember oppTeam : lstTeamMembers){
            // Add Team members in the map
            curOppUserId = String.ValueOf(oppTeam.OpportunityId) + String.ValueOf(oppTeam.UserId) ;
            mapOppTm.put(curOppUserId,oppTeam) ;
        }
        
        Boolean isOSC;        
        for(Opportunity opp : lstOpportunity) {
            
            // if Opportunity Owner, Technical Owner, and All Team Members have "Is OSC? = true", then OSC Solo
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
                
                if (isOSC) {
                    assignOSCCollaborationType(opp, OSC_SOLO, lstOppUpdates); 
                    continue;    
                }
            }
            
            // If Opportunity Owner has "Is OSC? = true", and Technical Owner or Any Team Member has "Is OSC? = false", 
            // then OSC with Field Assistance
            
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
    
    //Method added by Gaurav - Team Unicorn
    //Functionality: to check whether adding team member is having Opportunity access or not
    
    public static void check_OppObjAccessibility(List<OpportunityTeamMember> addedMember) {
        Set<Id> addedUserId = new Set<Id>();
        Set<id> allowedProfPSIds = new Set<id>();
        Map<Id,List<id>> userToProfPSIds = new Map<Id,List<id>>();
        List<id> profPSIds;
        
        try { 
            for(OpportunityTeamMember teamMember : addedMember) { addedUserId.add(teamMember.UserId); }
            
            if(!addedUserId.isEmpty()) {
                //TWC4767-894 PCC - Design Registration and Opportunity Integration testing
                //NP - Allowed Profiles/PS that have Opportunity access
                for(ObjectPermissions os: [SELECT Id, SObjectType, PermissionsRead, Parentid, Parent.name, Parent.Profile.name 
                                           FROM ObjectPermissions WHERE  SObjectType = 'Opportunity']){ allowedProfPSIds.add(os.Parentid); }
                
                //Get the accesses of the User Ids
                for(PermissionSetAssignment psa : [select id, PermissionSet.name, PermissionSet.Profile.name, PermissionSetId, AssigneeId 
                                                   FROM PermissionSetAssignment WHERE AssigneeId IN: addedUserId]){
                                                       if(!userToProfPSIds.containsKey(psa.AssigneeId)) { profPSIds = new List<id>(); }
                                                       profPSIds.add(psa.PermissionSetId);
                                                       userToProfPSIds.put(psa.AssigneeId,profPSIds);   
                                                   }
                
                
                for( OpportunityTeamMember oppTM : addedMember){
                    boolean hasAccess = false;
                    List<id> userProfPS = userToProfPSIds.get(oppTM.UserId);
                    for(id PPSId: userProfPS){
                        //Compare if the users have access to Opportunity
                        if(allowedProfPSIds.contains(PPSId)){
                            hasAccess = true;
                            break;
                        }
                    }
                    //Issue error if the User does not have Opportunity Access
                    if(!hasAccess) {
                        oppTM.UserId.addError(System.Label.Core_OppoAccessError);
                        oppTM.addError(System.Label.Core_OppoAccessError);
                    }
                }
            }  
        }
        catch(Exception ex) { PMP_Utility.logError(ex, 'Core_OpportunityTeamMemberHandler.check_OppObjAccessibility'); }  
    }
    
/**TWC3123-5273-------------------------------------------START---------------------------------
converting this flow->Core_OppTeamMember_Notify_Member_On_Addition into Trigger
*/
    public static void sendEmailtoNewTeamMember(Map<Id,OpportunityTeamMember> mapNewTeamMembers) {
        ID emailTemplate;
        try {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            //querying email template, which was already there in system
            emailTemplate = [Select Id, Name,Subject, HtmlValue, Body From EmailTemplate Where Name ='Opportunity Team Email Template'][0].id;
            //TWC3123-5552--Restrict Sending emails to External Users; addition into query
            Map<Id, OpportunityTeamMember> newMaps = new Map<Id, OpportunityTeamMember>([SELECT Id, OpportunityId, UserId, User.IsActive, Core_User_Type__c
                                                                                         FROM OpportunityTeamMember 
                                                                                         WHERE Id IN :mapNewTeamMembers.keyset() AND 
                                                                                         Core_User_Type__c = 'Internal User' AND 
                                                                                         User.IsActive = TRUE]);
            if(!newMaps.isEmpty()) {
                for(Id otmId : newMaps.KeySet()) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<Id> {newMaps.get(otmId).UserId});//user list to which we want to send email
                    mail.setTemplateId(emailTemplate);//classic template we are using 
                    mail.setTargetObjectId(newMaps.get(otmId).UserId);//its required to add this, when we are using some email template; otherwise its optional
                    mail.setTreatTargetObjectAsRecipient(false);//by making it false,recipient added in this 'setTargetObjectId' will not get email
                    mail.setWhatId(otmId);//opp Team Member Id field to merge with Template
                    mail.setSaveAsActivity(false); 
                    mail.setOrgWideEmailAddressId(fromEmailAddress);//reusing label--System.Label.Core_SetFromEmailAddress
                    mails.add(mail);
                }
            }
            
            if(!mails.isEmpty()) {
                Messaging.sendEmail(mails);
            }
        }
        catch(Exception ex) { PMP_Utility.logError(ex, 'Core_OpportunityTeamMemberHandler.sendEmailtoNewTeamMember'); }  
    }
    ///TWC3123-5273--------------------------------END-----------------------------------------------
    
    //TWC3123-5659 - Devashish
    public static void checkPCCLock(List<OpportunityTeamMember> otmList){
        Set<String> oppIds = new Set<String>();   
        for(OpportunityTeamMember otm:otmList){
                oppIds.add(otm.OpportunityId);
        }
        if(oppIds.size() > 0){
            List<Opportunity> OpptyList = [SELECT Id, name, SBQQ__PrimaryQuote__c, Core_Coverage_Type_Nm__c, Core_Opportunity_Coverage_Nm__c FROM Opportunity WHERE Id IN:oppIds AND Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity' AND Core_Coverage_Type_Nm__c ='Deal Registration']; 
            Boolean lock = Core_CRM_Utility.lockOpportunity(OpptyList);
            if(lock){
                for(OpportunityTeamMember otm:otmList){
                    otm.adderror(System.Label.Core_LockPCCOppty);
                }
            }
        }
    }
   
    
    //Call the Quote Method for PCC FI Team Member Sharing
    public static void shareOpptyTeamMembertoQuote(List<OpportunityTeamMember> updateTeamMembers){
        Set<Id> setPCCOppId = new Set<Id>();
        Set<Id> setOppId = new Set<Id>();
        Set<Id> setSWOppId = new Set<Id>();
        
        List<AsyncApexJob> lstJobs = [SELECT Id FROM  AsyncApexJob WHERE status ='Processing' AND ApexClass.Name = 'CRM_OpportunityOwnerUpdate'];
        
        if(updateTeamMembers != null && (lstJobs == null || lstJobs.IsEmpty() )){
            
            for (OpportunityTeamMember member : updateTeamMembers) {
                setOppId.add(member.OpportunityId);
            }
            
            Map<Id,Opportunity> opportunityMapData = new Map<Id, Opportunity>([Select id,Core_Opportunity_Coverage_Nm__c,Core_Coverage_Type_Nm__c,CRM_SW_Flag_Ind__c  from Opportunity where Id IN: setOppId ]);
            
            for (OpportunityTeamMember member : updateTeamMembers) {
                // WW7.4 2025- Added if condition below prior to calling Future method, to avoid System.LimitException: Too many future calls error
                if(opportunityMapData.get(member.OpportunityId).Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity' && opportunityMapData.get(member.OpportunityId).Core_Coverage_Type_Nm__c == 'Deal Registration'){
                    setPCCOppId.add(member.OpportunityId);
                }
                if(opportunityMapData.get(member.OpportunityId).CRM_SW_Flag_Ind__c == true){
                    setSWOppId.add(member.OpportunityId);
                }
            }
            
            
            if(setPCCOppId.size()>0 || setSWOppId.size()>0 ){
                callQuoteTeamMemberShare(setPCCOppId,setSWOppId);
            }
        }
    }   
    
    @future
    public static void callQuoteTeamMemberShare(set<Id> pccOppId , set<Id> swOppId){
        
        List<Id> setSWOppId = null ;
        
        /*  List<Opportunity> OpptyList = [SELECT Id,CRM_SW_Flag_Ind__c,Core_Opportunity_Coverage_Nm__c,Core_Coverage_Type_Nm__c FROM Opportunity WHERE Id IN:OppId]; 
for(Opportunity opp : OpptyList) {
if(opp.Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity' && opp.Core_Coverage_Type_Nm__c == 'Deal Registration'){
PCCOppId.add(opp.Id);
}
if(opp.CRM_SW_Flag_Ind__c){
SWOppId.add(opp.Id);
}
} */
        if(pccOppId.size()>0){
            Pricing_FinancialIncentive_BusinessLogic.createQuoteSharesForFI(pccOppId);
        }
        if(swOppId.size()>0){
            setSWOppId = new List<Id>(swOppId);
            Pricing_SW_QuoteBusinessLogic.createQuoteSharesForSW(setSWOppId);
        }
    }
}