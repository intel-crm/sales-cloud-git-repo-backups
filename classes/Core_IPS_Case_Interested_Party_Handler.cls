/**************************************************************************************************
Apex Class Name:  Core_IPS_Case_Interested_Party_Handler
Version     : 1.0 
Created Date: 11 05 2015
Function    : Core_IPS_Case_Interested_Party_Handler Class for Core_IPS_Case_Interested_Party Trigger. This class defines all the methods
              which are used for adding,updating,deleting CaseTeamMembers when ever Interested Parties are added on Case.
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------                 
* Manoj Kumar                         04/18/2017              insertIPToCaseTeam() method updated to Provide Case Access based on Case Account Team
                                                              as per Implentation of US61151. Added Try & Catch blocks to handle exceptions

*****************************************************************************************************/

public class Core_IPS_Case_Interested_Party_Handler{
    
    /*Creating a CTM on IP Insertion*/
    public static void insertIPToCaseTeam(List<Core_IPS_Case_Interested_Party__c> newList){
        try{
            CaseTeamRole CTRExt = [select id from CaseTeamRole where name = 'IPS External Interested Party']; // HARDCODED values NEEDs to move to Labels 
            CaseTeamRole CTRInt = [select id from CaseTeamRole where name = 'IPS Internal Interested Party']; // HARDCODED values NEEDs to move to Labels 
            CaseTeamRole CTRIntRead = [select id from CaseTeamRole where Name =: Label.Core_IPS_ReadOnly_CaseTeam_Role];//Added Readonly CaseTeamRole  -- 4/18/2017 Manoj Kumar
            system.debug('coming in insert');
            MAP<ID,ID> MapofContactANDUser = new MAP<ID,ID>();
            
            //Added Account,CaseTeamRole,FAEs variables  -- 4/18/2017 Manoj Kumar
            Set<ID> AccountID = new Set<ID>();
            Map<Id,Set<Id>> faesByAccount = new Map<Id,Set<Id>>();
            Set<String> SalesRepProfIds = new Set<String>();
            Set<String> IPAgentProfileIds = new Set<String>();
            String CTRIntId = '';
            // End Manoj Kumar
            
            Set<ID> ContactID = new Set<ID>();
            Set<ID> UserID = new Set<ID>();
            List<User> UsrLst = new List<User>();
            List<User> ConLst = new List<User>();
            MAP<Id,ID> UseridRecMap =  new MAP<Id,ID>();
            List<String> CaseIds = new List<String>();      
            List<String> MemberIds = new List<String>(); 
            List<CaseTeamMember> CaseTeamLst = new List<CaseTeamMember>();
            for (Core_IPS_Case_Interested_Party__c IP: newList) {
                if(IP.Contact__c != null){
                    ContactID.add(IP.Contact__c);
                }
                if(IP.User__c != null){
                    UserID.add(IP.User__c);
                }
                if(IP.Case__c != null)
                CaseIds.add(IP.Case__c);
            }
            
            //Added Case__r.AccountId in query to fetch IP's Case Account   -- 4/18/2017  Manoj Kumar
            List<Core_IPS_Case_Interested_Party__c> IPList = [Select id,Name,Case__c,Case__r.AccountId,User__c,User__r.ProfileId,Contact__c,Agent_Name__c,Active__c,Type__c from Core_IPS_Case_Interested_Party__c where id IN: newList];
            
            IPAgentProfileIds.addall(Label.Interested_Parties_Internal_Agent_ProfileIds.split(','));
            SalesRepProfIds.addall(label.Core_IPS_Sales_Rep_ProfileIds.split(','));
            
            for(Core_IPS_Case_Interested_Party__c IPRec: IPList) {
                //Adding IP's Case Accounts to AccountId to fetch FAEs under that Account  -- 4/18/2017  Manoj Kumar
                if(IPRec.Case__r.AccountId != null)
                AccountID.add(IPRec.Case__r.AccountId);
            } // END -- Manoj Kumar
            
            List<CaseTeamMember> CTMList = [Select id,ParentId, MemberId,TeamRoleId from CaseTeamMember where ParentId IN:CaseIds];
            for(CaseTeamMember CTMRec: CTMList){
                MemberIds.add(CTMRec.MemberId);
                system.debug('MemberIds ***'+MemberIds);
            }
            
            if(ContactID.size() > 0){
                ConLst = [Select ID, ContactID from User where contactId IN : ContactID and (NOT(Id IN: MemberIds))];
                System.debug('User List ***'+ConLst);
            }
      
            if(ConLst.size() > 0){
                for(User usr : ConLst){
                    if(usr.ContactID != null)
                        MapofContactANDUser.put(usr.ContactID,usr.ID);
                }
            }
            
            if(UserID.size() > 0){
                UsrLst = [Select ID, ContactID from User where id IN : UserID and (NOT(Id IN: MemberIds))];
                System.debug('User List ***'+UsrLst);
            }
            
            if(UsrLst.size() > 0){
                for(User usr : UsrLst){
                    if(usr.ContactID == null)
                        UseridRecMap.put(usr.id,usr.id);
                }
            }
            
            //Check for IP's Case accounts and fetch FAEs under that Account    -- 4/18/2017    Manoj Kumar
            system.debug('-- AccountID --'+AccountID.size());
            if(AccountID.size() > 0){
                faesByAccount = Core_IPS_Helper_Utility.getFAEsByAccount(AccountID);
            } //END --  Manoj Kumar
            system.debug('-- faesByAccount --'+faesByAccount.size());
            for (Core_IPS_Case_Interested_Party__c IP: IPList ) {
                
                if(IP.Contact__c != null){
                    IP.User__c = MapofContactANDUser.get(IP.Contact__c);
                }
                else{
                    IP.User__c = UseridRecMap.get(IP.User__c);
                    
                    System.debug('-- Inside Internal IP --');
                    // Check if IP's User is part of IP's Case Account Team and provide respective Case access      -- 4/18/2017    Manoj Kumar 
                    if(faesByAccount!=null && faesByAccount.size()>0){
                        for(Set<id> SetID : faesByAccount.values()){
                            if(((SetID.contains(IP.User__c) && SalesRepProfIds.contains(IP.User__r.ProfileId)) || IPAgentProfileIds.contains(IP.User__r.ProfileId))&& CTRInt.Id != Null){
                                System.debug('-- Inside Read/Write Internal IP --');
                                CTRIntId = CTRInt.Id;
                            }
                            else{
                                System.debug('-- Inside ReadOnly Internal IP --');
                                if(CTRIntRead.Id != Null)
                                CTRIntId = CTRIntRead.Id;
                            }
                        }//END  --  Manoj Kumar
                    }
                    else {
                        System.debug('-- Inside Read/Write Internal IP for No Assigned Contact case--');
                        if(IP.Case__r.AccountId == null && CTRInt.Id != Null){
                            CTRIntId = CTRInt.Id;
                        }
                    }
                }
                System.debug('-- CTRIntId --'+CTRIntId);
                CaseTeamMember CaseTeam = new CaseTeamMember();
                CaseTeam.parentId = IP.Case__c;
                CaseTeam.MemberId = IP.User__c;

                if (IP.contact__c != null && CTRExt.Id != null) {
                    CaseTeam.TeamRoleId = CTRExt.Id;
                }
                //Modified condition to check CaseTeamRoleId based on IP's Case Account Team        -- 4/18/2017    Manoj Kumar     
                else if (IP.User__c != null && IP.contact__c == null && !String.isBlank(CTRIntId)) {
                    CaseTeam.TeamRoleId = CTRIntId;
                }//END  --  Manoj Kumar
                System.debug('== CaseTeam=='+CaseTeam+'=== CaseTeam.MemberId =='+CaseTeam.MemberId+'==CaseTeam.parentId=='+CaseTeam.parentId+'-- CaseTeam.TeamRoleId --'+CaseTeam.TeamRoleId);

                if(CaseTeam <> null && CaseTeam.TeamRoleId <> null && CaseTeam.MemberId <> null && CaseTeam.parentId <> null)
                    CaseTeamLst.add(CaseTeam);
                
                system.debug('CaseTeamLst***'+CaseTeamLst);
            }
            
            if(CaseTeamLst.size()>0) 
            Database.Insert(CaseTeamLst); } catch (Exception ex){ System.debug('-- Exception Occcured :'+ex.getmessage()); }
    }
    
    /*Deleting a CTM on IP Deletion*/
    public static void deleteIPFromCaseTeam(List<Core_IPS_Case_Interested_Party__c> oldList){
        try{
            Set<String> ConcatCaseANDUser = new Set<String>();
            List<CaseTeamMember> CaseTeamList = new List<CaseTeamMember>();
            Set<ID> CaseIdSet = new Set<ID>();
            Set<ID> UserIdSet = new Set<ID>();
            Set<ID> ContactIdSet = new Set<ID>();
            
            List<CaseTeamMember> CTMToBeDeletedLst = new List<CaseTeamMember>();
            //Set<CaseTeamMember> CTMToBeDeletedSet = new Set<CaseTeamMember>();
            
            for(Core_IPS_Case_Interested_Party__c IP: oldList){
                ConcatCaseANDUser.add(String.ValueOf(IP.Case__c) + String.ValueOf(IP.User__c));
                CaseIdSet.add(IP.Case__c);
                UserIdSet.add(IP.User__c);
                ContactIdSet.add(IP.Contact__c);
                System.debug('UserIdSet***'+UserIdSet);
                System.debug('ContactIdSet***'+ContactIdSet);
            }
            
            if(CaseIdSet.size() > 0 && (UserIdSet.size() > 0 || ContactIdSet.size()>0)){
                CaseTeamList = [Select ID, ParentId, MemberId from CaseTeamMember where ParentId IN:CaseIdSet AND MemberId IN:UserIdSet];
            }
            
            for(CaseTeamMember CTM: CaseTeamList){
                String ParentIDStr = String.ValueOf(CTM.ParentId);
                String MemberIdStr = String.ValueOf(CTM.MemberId);
                if(ConcatCaseANDUser.contains(ParentIDStr+MemberIdStr))
                {
                    CTMToBeDeletedLst.add(CTM);
                }
            }
            delete CTMToBeDeletedLst; } catch (Exception ex){ System.debug('-- Exception Occcured :'+ex.getmessage()); }
    }
    
    /*Deleting a CTM on IP Inactivation*/
    public static void deleteIPFromCaseTeamonInactivation(List<Core_IPS_Case_Interested_Party__c> newList){
        try{
            Set<String> ConcatCaseANDUser = new Set<String>();
            List<CaseTeamMember> CaseTeamList = new List<CaseTeamMember>();
            Set<ID> CaseIdSet = new Set<ID>();
            Set<ID> UserIdSet = new Set<ID>();
            
            List<CaseTeamMember> CTMToBeDeletedLst = new List<CaseTeamMember>();
            //Set<CaseTeamMember> CTMToBeDeletedSet = new Set<CaseTeamMember>();
            List<Core_IPS_Case_Interested_Party__c> CreateCTMfromIPlistonUpdate = new List<Core_IPS_Case_Interested_Party__c>();
            for(Core_IPS_Case_Interested_Party__c IP: newList){
                ConcatCaseANDUser.add(String.ValueOf(IP.Case__c) + String.ValueOf(IP.User__c));
                system.debug('case and user'+ConcatCaseANDUser);
                CaseIdSet.add(IP.Case__c);
                if(IP.Active__c == false){
                    UserIdSet.add(IP.User__c);
                }
                else{
                    CreateCTMfromIPlistonUpdate.add(IP);
                }
            }
            
            if(CaseIdSet.size() > 0 && UserIdSet.size() > 0){
                CaseTeamList = [Select ID, ParentId, MemberId from CaseTeamMember where ParentId IN:CaseIdSet AND MemberId IN:UserIdSet];
            }
            
            //Creating a CTM on IP Re-Activation
            if(CreateCTMfromIPlistonUpdate.size()>0){
                Core_IPS_Case_IP_Dispatcher.DeleteCTM = true;
                system.debug('coming here to delte');
                Core_IPS_Case_Interested_Party_Handler.insertIPToCaseTeam(CreateCTMfromIPlistonUpdate); 
            }
            
            if(!Core_IPS_Case_IP_Dispatcher.DeleteCTM){
                for(CaseTeamMember CTM: CaseTeamList){
                    String ParentIDStr = String.ValueOf(CTM.ParentId);
                    String MemberIdStr = String.ValueOf(CTM.MemberId);
                    if(ConcatCaseANDUser.contains(ParentIDStr+MemberIdStr))
                    {
                        CTMToBeDeletedLst.add(CTM);
                        system.debug('ctm to be deleted'+CTMToBeDeletedLst);
                    }
                }
            }
            
            if(CTMToBeDeletedLst.size()>0)
            delete CTMToBeDeletedLst; } catch (Exception ex){ System.debug('-- Exception Occcured :'+ex.getmessage()); }
    }
    
}