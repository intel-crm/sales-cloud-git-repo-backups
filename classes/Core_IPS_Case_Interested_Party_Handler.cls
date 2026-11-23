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

public without sharing class Core_IPS_Case_Interested_Party_Handler{

/*Creating a CTM on IP Insertion*/
public static void insertIPToCaseTeam(List<Core_IPS_Case_Interested_Party__c> newList){
    List<CaseTeamMember> CTMList = new List<CaseTeamMember>();
    List<Core_IPS_Case_Interested_Party__c> IPList = new List<Core_IPS_Case_Interested_Party__c>();
    Id CTRExt;
    Id CTRInt;
    Id CTRIntRead;
    list<CaseTeamRole> CaseTeamList = new list<CaseTeamRole>();
    map<String ,Id> caseteamMap = new map<string,Id>();
    try{
        CaseTeamList = [select id ,name from CaseTeamRole where name IN ('IPS Internal Interested Party Read Only','IPS External Interested Party','IPS Internal Interested Party') ];
        for(CaseTeamRole cstRec : CaseTeamList){
            caseteamMap.put(cstRec.Name,cstRec.Id);
        }
        CTRExt = caseteamMap.get('IPS External Interested Party');
        CTRInt = caseteamMap.get('IPS Internal Interested Party');
        CTRIntRead = caseteamMap.get('IPS Internal Interested Party Read Only');
        //FLS checks added for below 3-Venugopal
        /*if(CaseTeamRole.SObjectType.getDescribe().isAccessible()){
        CTRExt = [select id from CaseTeamRole where name = 'IPS External Interested Party']; // HARDCODED values NEEDs to move to Labels 
        }
        if(CaseTeamRole.SObjectType.getDescribe().isAccessible()){
        CTRInt = [select id from CaseTeamRole where name = 'IPS Internal Interested Party']; // HARDCODED values NEEDs to move to Labels 
        }
        if(CaseTeamRole.SObjectType.getDescribe().isAccessible()){
        CTRIntRead = [select id from CaseTeamRole where Name =: Label.Core_IPS_ReadOnly_CaseTeam_Role];//Added Readonly CaseTeamRole  -- 4/18/2017 Manoj Kumar
        }*/
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
        List<Core_IPS_Project_Member__c> projectMemberList = new List<Core_IPS_Project_Member__c>();

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
        //FLS check added-Venugopal
        if(Core_IPS_Case_Interested_Party__c.SObjectType.getDescribe().isAccessible()){
        //  Added by Chiru - 20-08-24 - APEX GURU - SOQL FIX
        Map<Id, Core_IPS_Case_Interested_Party__c> newListMap = new Map<Id, Core_IPS_Case_Interested_Party__c>();
            if(newList!=null && newList.size()>0){
                newListMap = new Map<Id, Core_IPS_Case_Interested_Party__c>(newList);
                }
        IPList = [Select id,Name,Case__c,Case__r.AccountId,User__c,User__r.ProfileId,Contact__c,Contact__r.Email,Contact__r.Core_Enterprise_Id__c,Agent_Name__c,Active__c,Type__c from Core_IPS_Case_Interested_Party__c where id IN: newListMap.keyset()];
        }
        
        IPAgentProfileIds.addall(Label.Interested_Parties_Internal_Agent_ProfileIds.split(','));
        SalesRepProfIds.addall(label.Core_IPS_Sales_Rep_ProfileIds.split(','));
        
        for(Core_IPS_Case_Interested_Party__c IPRec: IPList) {
            //Adding IP's Case Accounts to AccountId to fetch FAEs under that Account  -- 4/18/2017  Manoj Kumar
            if(IPRec.Case__r.AccountId != null)
            AccountID.add(IPRec.Case__r.AccountId);
        } // END -- Manoj Kumar
        //FLS check added-Venugopal
        if(CaseTeamMember.SObjectType.getDescribe().isAccessible()){
        CTMList = [Select id,ParentId, MemberId,TeamRoleId from CaseTeamMember where ParentId IN:CaseIds];
        }
        for(CaseTeamMember CTMRec: CTMList){
            MemberIds.add(CTMRec.MemberId);
        }
        
        if(ContactID.size() > 0){
            ConLst = [Select ID, ContactID from User where contactId IN : ContactID and (NOT(Id IN: MemberIds))];
        }
    
        if(ConLst.size() > 0){
            for(User usr : ConLst){
                if(usr.ContactID != null)
                    MapofContactANDUser.put(usr.ContactID,usr.ID);
            }
        }
        
        if(UserID.size() > 0){
            UsrLst = [Select ID, ContactID from User where id IN : UserID and (NOT(Id IN: MemberIds))];
        }
        
        if(UsrLst.size() > 0){
            for(User usr : UsrLst){
                if(usr.ContactID == null)
                    UseridRecMap.put(usr.id,usr.id);
            }
        }
        
        //Check for IP's Case accounts and fetch FAEs under that Account    -- 4/18/2017    Manoj Kumar
        if(AccountID.size() > 0){
            faesByAccount = Core_IPS_Helper_Utility.getFAEsByAccount(AccountID);
        } //END --  Manoj Kumar
        for (Core_IPS_Case_Interested_Party__c IP: IPList ) {
            
            if(IP.Contact__c != null){
                IP.User__c = MapofContactANDUser.get(IP.Contact__c);
            }
            else{
                IP.User__c = UseridRecMap.get(IP.User__c);
                // Check if IP's User is part of IP's Case Account Team and provide respective Case access      -- 4/18/2017    Manoj Kumar 
                if(faesByAccount!=null && faesByAccount.size()>0){
                    for(Set<id> SetID : faesByAccount.values()){
                        if(((SetID.contains(IP.User__c) && SalesRepProfIds.contains(IP.User__r.ProfileId)) || IPAgentProfileIds.contains(IP.User__r.ProfileId))&& CTRInt != Null){
                            CTRIntId = CTRInt;
                        }
                        else{
                            if(CTRIntRead != Null)
                            CTRIntId = CTRIntRead;
                        }
                    }//END  --  Manoj Kumar
                }
                else {
                    if(IP.Case__r.AccountId == null && CTRInt != Null){
                        CTRIntId = CTRInt;
                    }
                }
            }
            CaseTeamMember CaseTeam = new CaseTeamMember();
            CaseTeam.parentId = IP.Case__c;
            CaseTeam.MemberId = IP.User__c;
            
            if (IP.contact__c != null && CTRExt != null) {
                CaseTeam.TeamRoleId = CTRExt;
            }
            //Modified condition to check CaseTeamRoleId based on IP's Case Account Team        -- 4/18/2017    Manoj Kumar     
            else if (IP.User__c != null && IP.contact__c == null && !String.isBlank(CTRIntId)) {
                CaseTeam.TeamRoleId = CTRIntId;
            }//END  --  Manoj Kumar

            if(CaseTeam <> null && CaseTeam.TeamRoleId <> null && CaseTeam.MemberId <> null && CaseTeam.parentId <> null)
                CaseTeamLst.add(CaseTeam);
            
        }
        
        // Niyaz -- 12/06/2025 --- added as part of vulnerability fix,
        if(Schema.sObjectType.CaseTeamMember.isCreateable() && CaseTeamLst.size()>0){ 
            Database.Insert(CaseTeamLst); 
        } 
        
        // start---- US1038333  ----25-06-2021----Farooq---- Interested party changes my Intel--
        // Avoid Deeply Nested IF Statements as part of ATHR Critical - Rakshitha
        if(!Test.isRunningTest() && IPList.size()>0 && Core_Trigger_Executions__c.getValues('myIntelIntrestrestedPartiesHandler') != null && Core_Trigger_Executions__c.getValues('myIntelIntrestrestedPartiesHandler').Core_Active__c)
        { 
            //if(Core_Trigger_Executions__c.getValues('myIntelIntrestrestedPartiesHandler') != null){
                // if(Core_Trigger_Executions__c.getValues('myIntelIntrestrestedPartiesHandler').Core_Active__c){
                    projectMemberList = [select Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Core_Enterprise_Id__c, Core_IPS_Project__c from Core_IPS_Project_Member__c 
                                            where Core_IPS_Project__c IN (select Core_IPS_Project_Case__c from Case where ID IN: CaseIds) and Core_IPS_Contact_IPS_Active__c = true];
                    System.debug(projectMemberList);
                    System.enqueueJob(new Core_IPS_MyIntel_3_0(CaseIds, 'Add', projectMemberList, IPList)); 
                //}
            //}
        }
        // end---- US1038333  ----25-06-2021----Farooq---- Interested party changes my Intel--
    
    } catch (Exception ex){ 
        String strDetails= 'Exception occured. while inserting records'+ex.getStackTraceString();
        Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'warn','IPS MyIntel Integration issue',strDetails,null,'Intrested Parties',null);
    }
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
        }
        
        if(CaseIdSet.size() > 0 && (UserIdSet.size() > 0 || ContactIdSet.size()>0)){
            //FLS check added-Venugopal
            if(CaseTeamMember.SObjectType.getDescribe().isAccessible()){
            CaseTeamList = [Select ID, ParentId, MemberId from CaseTeamMember where ParentId IN:CaseIdSet AND MemberId IN:UserIdSet];
            }
            }
        
        for(CaseTeamMember CTM: CaseTeamList){
            String ParentIDStr = String.ValueOf(CTM.ParentId);
            String MemberIdStr = String.ValueOf(CTM.MemberId);
            if(ConcatCaseANDUser.contains(ParentIDStr+MemberIdStr))
            {
                CTMToBeDeletedLst.add(CTM);
            }
        }
        // Niyaz -- 12/06/2025 --- added as part of vulnerability fix,
        if (Schema.sObjectType.CaseTeamMember.isDeletable() && CTMToBeDeletedLst.size() > 0) {
            delete CTMToBeDeletedLst;
        }
    // Niyaz delete CTMToBeDeletedLst; 
    } 
    catch (Exception ex){ 
    }
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
            CaseIdSet.add(IP.Case__c);
            if(IP.Active__c == false){
                UserIdSet.add(IP.User__c);
            }
            else{
                CreateCTMfromIPlistonUpdate.add(IP);
            }
        }
        
        if(CaseIdSet.size() > 0 && UserIdSet.size() > 0){
            //FLS check added-Venugopal
            if(CaseTeamMember.SObjectType.getDescribe().isAccessible()){
            CaseTeamList = [Select ID, ParentId, MemberId from CaseTeamMember where ParentId IN:CaseIdSet AND MemberId IN:UserIdSet];
            }
            }
        
        //Creating a CTM on IP Re-Activation
        if(CreateCTMfromIPlistonUpdate.size()>0){
            Core_IPS_Case_IP_Dispatcher.DeleteCTM = true;
            Core_IPS_Case_Interested_Party_Handler.insertIPToCaseTeam(CreateCTMfromIPlistonUpdate); 
        }
        
        if(!Core_IPS_Case_IP_Dispatcher.DeleteCTM){
            for(CaseTeamMember CTM: CaseTeamList){
                String ParentIDStr = String.ValueOf(CTM.ParentId);
                String MemberIdStr = String.ValueOf(CTM.MemberId);
                if(ConcatCaseANDUser.contains(ParentIDStr+MemberIdStr))
                {
                    CTMToBeDeletedLst.add(CTM);
                }
            }
        }
        
        if(CTMToBeDeletedLst.size()>0)
        delete CTMToBeDeletedLst; 
    } 
    catch (Exception ex){ 
    }
}
/*Deleting a CTM on IP Inactivation*/
/*********************************************
* Name : sendIntrestedParties 
* Author : Farooq Ahmed
* Date Created : 25/06/2021
* Description : This method is used to send intrestedParties to MyIntel on delete to myIntel
* Test Class : Core_IPS_MyIntel_3_0_Test
*   
************************************************/
/* public static void sendIntrestedParties(List<Core_IPS_Case_Interested_Party__c> oldList){
    List<Core_IPS_Case_Interested_Party__c> IPList = new List<Core_IPS_Case_Interested_Party__c>();
    if(Core_Trigger_Executions__c.getValues('myIntelIntrestrestedPartiesHandler') != null){
        if(Core_Trigger_Executions__c.getValues('myIntelIntrestrestedPartiesHandler').Core_Active__c){
            try{
                
                List<ID> CaseIdList = new List<ID>();
                List<Core_IPS_Project_Member__c> projectMemberList = new List<Core_IPS_Project_Member__c>();
                //FLS check added-Venugopal
                if(Core_IPS_Case_Interested_Party__c.SObjectType.getDescribe().isAccessible()){
                IPList = [Select id,Name,Case__c,Case__r.AccountId,User__c,User__r.ProfileId,Contact__c,Contact__r.Email,Contact__r.Core_Enterprise_Id__c,Agent_Name__c,Active__c,Type__c from Core_IPS_Case_Interested_Party__c where id IN: oldList];
                }
                for(Core_IPS_Case_Interested_Party__c IP: oldList){
                    
                    CaseIdList.add(IP.Case__c);
                }
                // start----   ----25-06-2021----Farooq---- Interested party changes my Intel-- 
                if(!Test.isRunningTest() && IPList.size()>0)
                { 
                    projectMemberList = [select Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Core_Enterprise_Id__c, Core_IPS_Project__c from Core_IPS_Project_Member__c 
                                            where Core_IPS_Project__c IN (select Core_IPS_Project_Case__c from Case where ID IN: CaseIdList) and Core_IPS_Contact_IPS_Active__c = true];
                    System.enqueueJob(new Core_IPS_MyIntel_3_0(new List<Id>(CaseIdList), 'Remove', projectMemberList, IPList));
                }
                
            }catch(Exception e){
                String strDetails= 'Exception occured. while inserting records'+e.getStackTraceString();
                Core_Log_Entry.logEntryWithDetails('SFDC','IPS',null,'warn','IPS MyIntel Integration issue',strDetails,null,'Intrested Parties',null);
            }
            // end----   ----25-06-2021----Farooq----Interested party changes my Intel--
            
            
        }
    }
}*/

}