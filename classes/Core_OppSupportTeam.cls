/**
 * @description       : 
 * @author            : Rajesh Gajul
 * @group             : 
 * @last modified on  : 08-22-2024
 * @last modified by  : Rajesh Gajul
**/
public without sharing class Core_OppSupportTeam { //TWC3123-5359 Added without sharing keyword to fix code scan issue
    //changing user ID in Opportunity support team
    public static Map<Id,List<Id>> supprequestDetails = new Map<Id,List<Id>>();
    public static void updateSupportToOpprotunityTeam(Map<Id,Core_Opportunity_Support_Team__c> triggerOldMap, List<Core_Opportunity_Support_Team__c> triggerNew,boolean isdeleteOpperation){
        Map<Id,set<Id>> userOppSupMapToDelete = new Map<Id , set<Id>>();
        Map<Id,set<Id>> userOppSupMapToAdd = new Map<Id , set<Id>>();
        //Map<Id,List<Id>> supprequestDetails = new Map<Id,List<Id>>();
        try {   
            for (Core_Opportunity_Support_Team__c opp_suppTeam : triggerNew) {
                set<Id> tempUserIdDelete = new set<Id>();
                set<Id> tempUserIdAdd = new set<Id>();
                List<Id> supTeamId = new List<Id>();
                // if(opp_suppTeam.Core_Opportunity_Support_Team_Member__c != triggerOldMap.get(opp_suppTeam.id).Core_Opportunity_Support_Team_Member__c)
                //   	opp_suppTeam.core_Status__c  = 'Pending';

                if(opp_suppTeam.Core_Opportunity_Support__r.Core_Sales_Stages__c=='Design Win'){
                }
                
                if(isdeleteOpperation || (triggerOldMap != null &&  opp_suppTeam.Core_Opportunity_Support_Team_Member__c != triggerOldMap.get(opp_suppTeam.id).Core_Opportunity_Support_Team_Member__c)){                
                    // add a user to map to remove from Opportunity team sharing using trigger.Old map 
                    if(userOppSupMapToDelete.containsKey(opp_suppTeam.Core_Opportunity_Support__c)){
                        tempUserIdDelete =   userOppSupMapToDelete.get(opp_suppTeam.Core_Opportunity_Support__c);
                        tempUserIdDelete.add(triggerOldMap.get(opp_suppTeam.id).Core_Opportunity_Support_Team_Member__c);                    
                    } 
                    else
                        tempUserIdDelete.add(triggerOldMap.get(opp_suppTeam.id).Core_Opportunity_Support_Team_Member__c);                 
                    
                    userOppSupMapToDelete.put(opp_suppTeam.Core_Opportunity_Support__c,tempUserIdDelete);                
                }
                //add a user to map to add in Opportunity team sharing using trigger.new
                //check if it's delete opertion (trigger.new will be empty for deletion option)
                if(!isdeleteOpperation && opp_suppTeam.core_Status__c == 'Accepted'){
                    if(userOppSupMapToAdd.containsKey(opp_suppTeam.Core_Opportunity_Support__c) ){
                        tempUserIdAdd =   userOppSupMapToAdd.get(opp_suppTeam.Core_Opportunity_Support__c);
                        tempUserIdAdd.add(opp_suppTeam.Core_Opportunity_Support_Team_Member__c); 
                        supTeamId = supprequestDetails.get(opp_suppTeam.Core_Opportunity_Support__c);
                        supTeamId.add(opp_suppTeam.id);
                    } 
                    else{
                        tempUserIdAdd.add(opp_suppTeam.Core_Opportunity_Support_Team_Member__c); 
                        supTeamId.add(opp_suppTeam.id);
                    }
                    supprequestDetails.put(opp_suppTeam.Core_Opportunity_Support__c,supTeamId);
                    userOppSupMapToAdd.put(opp_suppTeam.Core_Opportunity_Support__c,tempUserIdAdd);
                }           
            }
            if(!userOppSupMapToDelete.isEmpty() || !userOppSupMapToAdd.isEmpty())
                updateUserInOppteam(userOppSupMapToDelete,userOppSupMapToAdd);
        } catch (Exception e) {
            Core_Exceptions__c excep = new Core_Exceptions__c(Core_Exception__c = 'Failure : ########### - '+e.getStackTraceString()+' Cause'+e.getMessage(),Core_Class_Name__c ='Core_OppSupportTeam',Core_Method_Name__c ='updateSupportToOpprotunityTeam',Core_IPS_Object_Name__c = 'OpportunityTeamMember');
            insert excep;
        } 
    }
    
    public static void updateUserInOppteam(Map<Id,set<Id>> userOppSupMapToDelete,Map<Id,set<Id>> userOppSupMapToAdd ){
        String orgInstance = URL.getOrgDomainUrl().toExternalForm();
        Map<String,datetime> OppUsermap = new Map<String,datetime>();
        Set<Id> userIdToRemove = new set<Id>();
        Set<Id> OppID = new set<Id>();
        Set<Id> userIdToAdd = new set<Id>();
        Set<Id> OppIDUpdate = new set<Id>();
        List<String> userInOtherSupport = new List<String>();
        //List of user to add Opportunity team
        List<OpportunityTeamMember> oppToShare = new List<OpportunityTeamMember>(); 
        Map<string,OpportunityTeamMember> checkUserInOppTeam = new  Map<string,OpportunityTeamMember>();
        Map<string,string> checkDescrOfTeamMember = new  Map<string,string>();
        //List of User to remove from Opportunity team
        List<OpportunityTeamMember> memberToDelete = new List<OpportunityTeamMember>();
        
        for(Core_Opportunity_Support__c opp_supp : [select id,Opportunity__c,Core_Approved_Date__c from Core_Opportunity_Support__c 
                                                    where (id IN: userOppSupMapToDelete.keySet() OR id IN: userOppSupMapToAdd.keySet())  
                                                    AND (Core_Status__c = 'Approved' OR Core_Status__c = 'Pending' 
                                                         OR Core_Status__c = 'Closed : Support Provided' OR Core_Status__c = 'Closed : Support Not Provided' )]){
            if(userOppSupMapToDelete.containsKey(opp_supp.id)){
                string userTeamDesc = orgInstance + '/' + opp_supp.id;
                userIdToRemove.addAll(userOppSupMapToDelete.get(opp_supp.id));
                OppID.add(opp_supp.Opportunity__c);
                for(id userId :userOppSupMapToDelete.get(opp_supp.id)){
                    OppUsermap.put(opp_supp.Opportunity__c+'_'+userId ,opp_supp.Core_Approved_Date__c);
                    checkDescrOfTeamMember.put(opp_supp.Opportunity__c+'_'+userId ,userTeamDesc);
                } 
            }
            if(userOppSupMapToAdd.containsKey(opp_supp.id)){
                //only add active user
                for(id userId :userOppSupMapToAdd.get(opp_supp.id)){
                    OppIDUpdate.add(opp_supp.Opportunity__c);
                    userIdToAdd.add(userId);
                    OpportunityTeamMember oppteam = new OpportunityTeamMember();               
                    oppteam.OpportunityId = opp_supp.Opportunity__c;
                    oppteam.OpportunityAccessLevel = 'Edit';
                    oppteam.TeamMemberRole = 'Team Member (100%)';
                    oppteam.UserId = userId;
                    oppteam.Core_Description_of_Contribution__c = orgInstance + '/' + opp_supp.id;
                    oppToShare.add(oppteam);
                    checkUserInOppTeam.put(userId+'_'+opp_supp.Opportunity__c ,oppteam );
                }  
            }
            
        }
        for(Core_Opportunity_Support_Team__c userInOtherTeam : [select id ,Core_Opportunity_Support_Team_Member__c,Core_Opportunity_Support__r.Opportunity__c from Core_Opportunity_Support_Team__c
                                                                where Core_Opportunity_Support__r.Opportunity__c IN: OppID and Core_Opportunity_Support__c NOT IN:userOppSupMapToDelete.keySet() ])
        {            
            userInOtherSupport.add( userInOtherTeam.Core_Opportunity_Support__r.Opportunity__c+'_'+userInOtherTeam.Core_Opportunity_Support_Team_Member__c);
        }
		Set<Id> finalUserList =  new Set<Id>();
        finalUserList.addAll(userIdToRemove);
        finalUserList.addAll(userIdToAdd);
		set<Id> finalOppList = new Set<Id>();   
        finalOppList.addAll(OppID);
        finalOppList.addAll(OppIDUpdate);
        for(OpportunityTeamMember OppTeam : [select id ,UserId,OpportunityId ,Core_Description_of_Contribution__c,Core_Date_Added__c from OpportunityTeamMember where UserId IN:finalUserList  and OpportunityId IN:finalOppList]){// type cast to date
            if(!checkUserInOppTeam.containsKey(OppTeam.UserId+'_'+OppTeam.OpportunityId) 
               && !userInOtherSupport.contains(OppTeam.OpportunityId+'_'+OppTeam.UserId) 
               && OppUsermap.containsKey(OppTeam.OpportunityId+'_'+OppTeam.UserId) 
               && OppTeam.Core_Date_Added__c.date() >= OppUsermap.get(OppTeam.OpportunityId+'_'+OppTeam.UserId).date()
               && checkDescrOfTeamMember.containsKey(OppTeam.OpportunityId+'_'+OppTeam.UserId)
               &&(OppTeam.Core_Description_of_Contribution__c == checkDescrOfTeamMember.get(OppTeam.OpportunityId+'_'+OppTeam.UserId)) )
               {
                  memberToDelete.add(OppTeam);   }
           
            if(checkUserInOppTeam.containsKey(OppTeam.UserId+'_'+OppTeam.OpportunityId)){
                OpportunityTeamMember oppteamExist = checkUserInOppTeam.get(OppTeam.UserId+'_'+OppTeam.OpportunityId);
                oppteamExist.Core_Description_of_Contribution__c = oppteamExist.Core_Description_of_Contribution__c + '\n'+OppTeam.Core_Description_of_Contribution__c;
                oppteamExist.id = OppTeam.id;
                checkUserInOppTeam.put(OppTeam.UserId+'_'+OppTeam.OpportunityId ,oppteamExist );
            }
            
        }
        
        
        if(memberToDelete.size() > 0)
            delete memberToDelete;           
        
       
        //if(oppToShare.size() > 0)
          //  insert oppToShare;
        
        if(checkUserInOppTeam.size() > 0)
            upsert checkUserInOppTeam.values();
        if(supprequestDetails.size() > 0)
            Core_EmailNotification.userAcceptReq(supprequestDetails);
    }
    
    public static void checkDuplicateOppSupTeamMem(List<Core_Opportunity_Support_Team__c> triggerNew,Map<Id,Core_Opportunity_Support_Team__c> triggerOldMap){
        try{ 
            Set<Id> supportIds = new Set<Id>();
            Set<Id> userIds = new Set<Id>();
            List<String> oppSupUserKey = new List<String>();
            //Set<Id> checkAnyAccpRequest = new Set<Id>();
            for (Core_Opportunity_Support_Team__c team : triggerNew) {  
                
                
                if(Trigger.IsInsert || ((Trigger.IsUpdate && team.Core_Opportunity_Support_Team_Member__c != triggerOldMap.get(team.id).Core_Opportunity_Support_Team_Member__c) )){
                    supportIds.add(team.Core_Opportunity_Support__c);
                    userIds.add(team.Core_Opportunity_Support_Team_Member__c);
                    team.Core_Reassign_counter__c = ( team.Core_Reassign_counter__c == null ? 0 : team.Core_Reassign_counter__c + 1 );
                }
            }
            for( Core_Opportunity_Support_Team__c createuniqueKey : [ SELECT Core_Status__c, Core_Opportunity_Support_Team_Member__c, Core_Opportunity_Support__c FROM Core_Opportunity_Support_Team__c
                                                                     WHERE Core_Opportunity_Support__c IN :supportIds ]) // AND Core_Opportunity_Support_Team_Member__c IN :userIds
            {
               
                
                oppSupUserKey.add(createuniqueKey.Core_Opportunity_Support__c+'_'+createuniqueKey.Core_Opportunity_Support_Team_Member__c);     
            }
            for (Core_Opportunity_Support_Team__c team : triggerNew) {      
                if (oppSupUserKey.contains(team.Core_Opportunity_Support__c+'_'+team.Core_Opportunity_Support_Team_Member__c) ) {
                    team.addError(Core_CRM_Utility.getCRMLabel('OppSup_checkDuplicateUser'));
                }
            }
        }
        catch (Exception e) {
            PMP_Utility.logError(e, 'Core_OppSupportTeam.checkDuplicateOppSupTeamMem');
        }
        
        
    }
    public static void updateOppSupteamStatus(List<Core_Opportunity_Support_Team__c> triggerNew,Map<Id,Core_Opportunity_Support_Team__c> triggerOldMap){
        List<Id> OppSupportRequest = new List<Id>();
        Map<Id,string> OppSupportStatus = new Map<Id,string>();
        Map<Id,string> OppSupportType = new Map<Id,string>();
        List<Id> approvedRecords = new List<Id>();
        List<Core_Opportunity_Support__c> oppSuppReqList = new List<Core_Opportunity_Support__c>();
        //Get the Opportunity support requset id
        for (Core_Opportunity_Support_Team__c team : triggerNew)
            OppSupportRequest.add(team.Core_Opportunity_Support__c);
        
        //Update the map with support request ID and status of support request
        for(Core_Opportunity_Support__c opp_supp : [select id,Opportunity__c,Core_Status__c,RecordType.DeveloperName from Core_Opportunity_Support__c 
                                                    where id IN: OppSupportRequest]){
                                                        OppSupportStatus.put(opp_supp.id,opp_supp.Core_Status__c);
                                                        OppSupportType.put(opp_supp.id,opp_supp.RecordType.DeveloperName);
                                                    }
        
        //check record got Approved or not 
        for(ProcessInstance approvedList :[SELECT Id, TargetObjectId, Status  FROM ProcessInstance WHERE TargetObjectId IN :OppSupportRequest AND Status = 'Approved' order by CreatedDate desc] )
            approvedRecords.add(approvedList.TargetObjectId);
        
        //change the status of Opportunity support team status to Not submitted or Pending based on support request status
        for (Core_Opportunity_Support_Team__c team : triggerNew) {
            if(Trigger.IsInsert){
              if(OppSupportStatus.containsKey(team.Core_Opportunity_Support__c) && (OppSupportStatus.get(team.Core_Opportunity_Support__c) == 'Closed : Support Not Provided' || OppSupportStatus.get(team.Core_Opportunity_Support__c) == 'Closed : Support Provided')){
                    team.addError(Core_CRM_Utility.getCRMLabel('OppSup_CloseStateError'));
              }
                if(OppSupportStatus.containsKey(team.Core_Opportunity_Support__c) && (OppSupportStatus.get(team.Core_Opportunity_Support__c) == 'Pending' ||  approvedRecords.contains(team.Core_Opportunity_Support__c) )) {
                    team.Core_Status__c  = 'Accepted';  
                    team.Core_Approval_Comment__c = 'Auto Approved';                
                }                
                else 
                    team.Core_Status__c  = 'New';
                
            }
            
           if((Trigger.IsUpdate && team.Core_Opportunity_Support_Team_Member__c != triggerOldMap.get(team.id).Core_Opportunity_Support_Team_Member__c) )
            {	
                if(OppSupportStatus.containsKey(team.Core_Opportunity_Support__c) && (OppSupportStatus.get(team.Core_Opportunity_Support__c) == 'Closed : Support Not Provided' || OppSupportStatus.get(team.Core_Opportunity_Support__c) == 'Closed : Support Provided')){
                    team.addError(Core_CRM_Utility.getCRMLabel('OppSup_CloseStateError'));
                }
                else{
                   
                    if(!approvedRecords.contains(team.Core_Opportunity_Support__c)){
                        team.Core_Status__c  = 'New';
                        team.Core_Approval_Comment__c = '';
                    }
                    else {
                        team.Core_Status__c  = 'Accepted';
                        team.Core_Approval_Comment__c = 'Auto Approved';
                    }
                }
            }               
        }
       
        if(oppSuppReqList.size() > 0)
            update oppSuppReqList;
    }
    //Logic to capture Opportunity Support Team Member Name on opportunity Support on insert,update and delete - TWC3123-4778
    public static void captureOppSupportTeamMemberName(List<Core_Opportunity_Support_Team__c> triggerNew){
        List<Id> OppSupportId = new List<Id>();
        for (Core_Opportunity_Support_Team__c team : triggerNew){
            OppSupportId.add(team.Core_Opportunity_Support__c);
        }
        Map<Id, Core_Opportunity_Support__c> oppSupportList = new Map<Id, Core_Opportunity_Support__c>();
        Map<Id, Core_Opportunity_Support_Team__c> oppSuppTeamList = new Map<Id, Core_Opportunity_Support_Team__c>( [SELECT Id, Core_Opportunity_Support__c, Core_Opportunity_Support__r.Core_Opportunity_Support_Team_Member__c , Core_Opportunity_Support_Team_Member__r.Name from Core_Opportunity_Support_Team__c WHERE Core_Opportunity_Support__c IN: OppSupportId]);
       
        for(Core_Opportunity_Support_Team__c oppSuppTeam : oppSuppTeamList.values()){
            String temp = '';
            if(oppSupportList.containskey(oppSuppTeam.Core_Opportunity_Support__c)){
                 temp = oppSupportList.get(oppSuppTeam.Core_Opportunity_Support__c).Core_Opportunity_Support_Team_Member__c;
                 temp = temp+', '+oppSuppTeam.Core_Opportunity_Support_Team_Member__r.Name;
                 
                oppSupportList.get(oppSuppTeam.Core_Opportunity_Support__c).Core_Opportunity_Support_Team_Member__c = temp;
                
             }
             else{
                 temp = oppSuppTeam.Core_Opportunity_Support_Team_Member__r.Name;
                 oppSupportList.put(oppSuppTeam.Core_Opportunity_Support__c, new Core_Opportunity_Support__c(Id=oppSuppTeam.Core_Opportunity_Support__c,Core_Opportunity_Support_Team_Member__c = temp));
                 
                 
             }            
        }
        update oppSupportList.values();       
    }

    public static void deleteSupportToOpprotunityTeam(List<Core_Opportunity_Support_Team__c> triggerold){
        map<Id,Core_Opportunity_Support_Team__c> OppSupportMap = new map<Id,Core_Opportunity_Support_Team__c>();
        for (Core_Opportunity_Support_Team__c ost : triggerold) {
            OppSupportMap.put(ost.Core_Opportunity_Support__c,ost);
        }
        if (OppSupportMap != null) {
            List<Core_Opportunity_Support__c> OppSuppListStage = [SELECT Id, Core_Sales_Stages__c FROM Core_Opportunity_Support__c WHERE Id IN :OppSupportMap.keyset()];
            for (Core_Opportunity_Support__c osls : OppSuppListStage) {
                if( osls.Core_Sales_Stages__c == 'Design Win' || osls.Core_Sales_Stages__c == 'Production Win'||
                    osls.Core_Sales_Stages__c == 'Lost' || osls.Core_Sales_Stages__c == 'Cancelled'||
                    osls.Core_Sales_Stages__c == 'Production Lost' || osls.Core_Sales_Stages__c == 'Production Cancelled'){
                       OppSupportMap.get(osls.Id).addError('Once Opportunity is Closed, Support Request cannot be deleted'); 
                }
            }
        }
    }

}