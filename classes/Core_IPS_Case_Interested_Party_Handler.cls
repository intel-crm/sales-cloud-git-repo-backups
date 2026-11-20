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
        List<CaseTeamMember> cTMList = new List<CaseTeamMember>();
        List<Core_IPS_Case_Interested_Party__c> iPList = new List<Core_IPS_Case_Interested_Party__c>();
        CaseTeamRole cTRExt;
        CaseTeamRole cTRInt;
        CaseTeamRole cTRIntRead;
        try{
            //FLS checks added for below 3-Venugopal
            if(CaseTeamRole.SObjectType.getDescribe().isAccessible()){
            cTRExt = [select id from CaseTeamRole where name = 'IPS External Interested Party']; // HARDCODED values NEEDs to move to Labels 
            }
            if(CaseTeamRole.SObjectType.getDescribe().isAccessible()){
            cTRInt = [select id from CaseTeamRole where name = 'IPS Internal Interested Party']; // HARDCODED values NEEDs to move to Labels 
            }
            if(CaseTeamRole.SObjectType.getDescribe().isAccessible()){
            cTRIntRead = [select id from CaseTeamRole where Name =: Label.Core_IPS_ReadOnly_CaseTeam_Role];//Added Readonly CaseTeamRole  -- 4/18/2017 Manoj Kumar
            }
            MAP<ID,ID> mapofContactANDUser = new MAP<ID,ID>();
            
            //Added Account,CaseTeamRole,FAEs variables  -- 4/18/2017 Manoj Kumar
            Set<ID> accountID = new Set<ID>();
            Map<Id,Set<Id>> faesByAccount = new Map<Id,Set<Id>>();
            Set<String> salesRepProfIds = new Set<String>();
            Set<String> iPAgentProfileIds = new Set<String>();
            String cTRIntId = '';
            // End Manoj Kumar
            
            Set<ID> contactID = new Set<ID>();
            Set<ID> userID = new Set<ID>();
            List<User> UsrLst = new List<User>();
            List<User> conLst = new List<User>();
            MAP<Id,ID> useridRecMap =  new MAP<Id,ID>();
            List<String> caseIds = new List<String>();      
            List<String> MemberIds = new List<String>(); 
			List<Core_IPS_Project_Member__c> projectMemberList = new List<Core_IPS_Project_Member__c>();

            List<CaseTeamMember> CaseTeamLst = new List<CaseTeamMember>();
            for (Core_IPS_Case_Interested_Party__c IP: newList) {
                if(IP.Contact__c != null){
                    contactID.add(IP.Contact__c);
                }
                if(IP.User__c != null){
                    userID.add(IP.User__c);
                }
                if(IP.Case__c != null)
                caseIds.add(IP.Case__c);
                
            }
            
            //Added Case__r.AccountId in query to fetch IP's Case Account   -- 4/18/2017  Manoj Kumar
            //FLS check added-Venugopal
            if(Core_IPS_Case_Interested_Party__c.SObjectType.getDescribe().isAccessible()){
            // APEX GURU - SOQL FIX
            Map<Id, Core_IPS_Case_Interested_Party__c> newListMap = new Map<Id, Core_IPS_Case_Interested_Party__c>();
                if(newList!=null && newList.size()>0){
                   newListMap = new Map<Id, Core_IPS_Case_Interested_Party__c>(newList);
                 }
            // iPList = [Select id,Name,Case__c,Case__r.AccountId,User__c,User__r.ProfileId,Contact__c,Contact__r.Email,Contact__r.Core_Enterprise_Id__c,Agent_Name__c,Active__c,Type__c from Core_IPS_Case_Interested_Party__c where id IN: newList];
	       iPList = [Select id,Name,Case__c,Case__r.AccountId,User__c,User__r.ProfileId,Contact__c,Contact__r.Email,Contact__r.Core_Enterprise_Id__c,Agent_Name__c,Active__c,Type__c from Core_IPS_Case_Interested_Party__c where id IN: newListMap.keyset()];
            }
            
            iPAgentProfileIds.addall(Label.Interested_Parties_Internal_Agent_ProfileIds.split(','));
            salesRepProfIds.addall(label.Core_IPS_Sales_Rep_ProfileIds.split(','));
            
            for(Core_IPS_Case_Interested_Party__c iPRec: iPList) {
                //Adding IP's Case Accounts to accountId to fetch FAEs under that Account  -- 4/18/2017  Manoj Kumar
                if(iPRec.Case__r.AccountId != null)
                accountID.add(iPRec.Case__r.AccountId);
            } // END -- Manoj Kumar
            //FLS check added-Venugopal
            if(CaseTeamMember.SObjectType.getDescribe().isAccessible()){
            cTMList = [Select id,ParentId, MemberId,TeamRoleId from CaseTeamMember where ParentId IN:caseIds];
            }
            for(CaseTeamMember cTMRec: cTMList){
                MemberIds.add(cTMRec.MemberId);
            }
            
            if(contactID.size() > 0){
                conLst = [Select ID, ContactId from User where ContactId IN : contactID and (NOT(Id IN: MemberIds))];
            }
      
            if(conLst.size() > 0){
                for(User usr : conLst){
                    if(usr.ContactID != null)
                        mapofContactANDUser.put(usr.ContactID,usr.ID);
                }
            }
            
            if(userID.size() > 0){
                usrLst = [Select ID, ContactID from User where id IN : userID and (NOT(Id IN: MemberIds))];
            }
            
            if(usrLst.size() > 0){
                for(User usr : usrLst){
                    if(usr.ContactID == null)
                        useridRecMap.put(usr.id,usr.id);
                }
            }
            
            //Check for IP's Case accounts and fetch FAEs under that Account    -- 4/18/2017    Manoj Kumar
            if(accountID.size() > 0){
                faesByAccount = Core_IPS_Helper_Utility.getFAEsByAccount(accountID);
            } //END --  Manoj Kumar
            for (Core_IPS_Case_Interested_Party__c iP: iPList ) {
                
                if(iP.Contact__c != null){
                    iP.User__c = mapofContactANDUser.get(iP.Contact__c);
                }
                else{
                    iP.User__c = useridRecMap.get(iP.User__c);
                    // Check if iP's User is part of iP's Case Account Team and provide respective Case access      -- 4/18/2017    Manoj Kumar 
                    if(faesByAccount!=null && faesByAccount.size()>0){
                        for(Set<id> setID : faesByAccount.values()){
                            if(((setID.contains(iP.User__c) && salesRepProfIds.contains(iP.User__r.ProfileId)) || iPAgentProfileIds.contains(IP.User__r.ProfileId))&& cTRInt.Id != Null){
                                cTRIntId = cTRInt.Id;
                            }
                            else{
                                if(cTRIntRead.Id != Null)
                                cTRIntId = cTRIntRead.Id;
                            }
                        }//END  --  Manoj Kumar
                    }
                    else {
                        if(iP.Case__r.AccountId == null && cTRInt.Id != Null){
                            cTRIntId = cTRInt.Id;
                        }
                    }
                }
                CaseTeamMember caseTeam = new CaseTeamMember();
                caseTeam.parentId = iP.Case__c;
                caseTeam.MemberId = iP.User__c;

                if (iP.contact__c != null && cTRExt.Id != null) {
                    caseTeam.TeamRoleId = cTRExt.Id;
                }
                //Modified condition to check caseTeamRoleId based on iP's Case Account Team        -- 4/18/2017    Manoj Kumar     
                else if (iP.User__c != null && iP.contact__c == null && !String.isBlank(cTRIntId)) {
                    caseTeam.TeamRoleId = cTRIntId;
                }//END  --  Manoj Kumar

                if(caseTeam <> null && caseTeam.TeamRoleId <> null && caseTeam.MemberId <> null && caseTeam.parentId <> null)
                    CaseTeamLst.add(caseTeam);
                
            }
            
            
            // Niyaz -- 12/06/2025 --- added as part of vulnerability fix,
            if(Schema.sObjectType.CaseTeamMember.isCreateable() && CaseTeamLst.size()>0){ 
            Database.Insert(CaseTeamLst); 
            } 
        
            // start---- US1038333  ----25-06-2021----Farooq---- Interested party changes my Intel--
            if(!Test.isRunningTest() && iPList.size()>0)
            { 
                if(Core_Trigger_Executions__c.getValues('myIntelIntrestrestedPartiesHandler') != null){
                    if(Core_Trigger_Executions__c.getValues('myIntelIntrestrestedPartiesHandler').Core_Active__c){
                        projectMemberList = [select Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Core_Enterprise_Id__c, Core_IPS_Project__c from Core_IPS_Project_Member__c 
                                             where Core_IPS_Project__c IN (select Core_IPS_Project_Case__c from Case where ID IN: caseIds) and Core_IPS_Contact_IPS_Active__c = true];
                        System.enqueueJob(new Core_IPS_MyIntel_3_0(caseIds, 'Add', projectMemberList, iPList)); 
                    }
                }
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
            Set<String> concatCaseANDUser = new Set<String>();
            List<CaseTeamMember> caseTeamList = new List<CaseTeamMember>();
            Set<ID> caseIdSet = new Set<ID>();
            Set<ID> userIdSet = new Set<ID>();
            Set<ID> contactIdSet = new Set<ID>();
            
            List<CaseTeamMember> cTMToBeDeletedLst = new List<CaseTeamMember>();
            //Set<CaseTeamMember> cTMToBeDeletedSet = new Set<CaseTeamMember>();
            
            for(Core_IPS_Case_Interested_Party__c iP: oldList){
                concatCaseANDUser.add(String.ValueOf(iP.Case__c) + String.ValueOf(iP.User__c));
                caseIdSet.add(iP.Case__c);
                userIdSet.add(iP.User__c);
                contactIdSet.add(iP.Contact__c);
            }
            
            if(caseIdSet.size() > 0 && (userIdSet.size() > 0 || contactIdSet.size()>0)){
                //FLS check added-Venugopal
                if(CaseTeamMember.SObjectType.getDescribe().isAccessible()){
                caseTeamList = [Select ID, ParentId, MemberId from CaseTeamMember where ParentId IN:caseIdSet AND MemberId IN:userIdSet];
                }
                }
            
            for(CaseTeamMember cTM: caseTeamList){
                String parentIDStr = String.ValueOf(cTM.ParentId);
                String memberIdStr = String.ValueOf(cTM.MemberId);
                if(concatCaseANDUser.contains(parentIDStr+memberIdStr))
                {
                    cTMToBeDeletedLst.add(cTM);
                }
            }
            // Niyaz -- 12/06/2025 --- added as part of vulnerability fix,
            if (Schema.sObjectType.CaseTeamMember.isDeletable() && cTMToBeDeletedLst.size() > 0) {
            		delete cTMToBeDeletedLst;
       	    }
    		// Niyaz delete cTMToBeDeletedLst; 
	} 
	    catch (Exception ex){ 
	}
    }
    
    /*Deleting a CTM on IP Inactivation*/
    public static void deleteIPFromCaseTeamonInactivation(List<Core_IPS_Case_Interested_Party__c> newList){
        try{
            Set<String> concatCaseANDUser = new Set<String>();
            List<CaseTeamMember> caseTeamList = new List<CaseTeamMember>();
            Set<ID> caseIdSet = new Set<ID>();
            Set<ID> userIdSet = new Set<ID>();
            
            List<CaseTeamMember> cTMToBeDeletedLst = new List<CaseTeamMember>();
            //Set<CaseTeamMember> cTMToBeDeletedSet = new Set<CaseTeamMember>();
            List<Core_IPS_Case_Interested_Party__c> createCTMfromIPlistonUpdate = new List<Core_IPS_Case_Interested_Party__c>();
            for(Core_IPS_Case_Interested_Party__c iP: newList){
                concatCaseANDUser.add(String.ValueOf(iP.Case__c) + String.ValueOf(iP.User__c));
                caseIdSet.add(iP.Case__c);
                if(iP.Active__c == false){
                    userIdSet.add(iP.User__c);
                }
                else{
                    createCTMfromIPlistonUpdate.add(iP);
                }
            }
            
            if(caseIdSet.size() > 0 && userIdSet.size() > 0){
                //FLS check added-Venugopal
                if(CaseTeamMember.SObjectType.getDescribe().isAccessible()){
                caseTeamList = [Select ID, ParentId, MemberId from CaseTeamMember where ParentId IN:caseIdSet AND MemberId IN:userIdSet];
                }
                }
            
            //Creating a CTM on IP Re-Activation
            if(createCTMfromIPlistonUpdate.size()>0){
                Core_IPS_Case_IP_Dispatcher.DeleteCTM = true;
                Core_IPS_Case_Interested_Party_Handler.insertIPToCaseTeam(createCTMfromIPlistonUpdate); 
            }
            
            if(!Core_IPS_Case_IP_Dispatcher.DeleteCTM){
                for(CaseTeamMember CTM: caseTeamList){
                    String parentIDStr = String.ValueOf(CTM.ParentId);
                    String memberIdStr = String.ValueOf(CTM.MemberId);
                    if(concatCaseANDUser.contains(parentIDStr+memberIdStr))
                    {
                        cTMToBeDeletedLst.add(CTM);
                    }
                }
            }
            
            if(cTMToBeDeletedLst.size()>0)
            delete cTMToBeDeletedLst; 
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
        List<Core_IPS_Case_Interested_Party__c> iPList = new List<Core_IPS_Case_Interested_Party__c>();
        if(Core_Trigger_Executions__c.getValues('myIntelIntrestrestedPartiesHandler') != null){
            if(Core_Trigger_Executions__c.getValues('myIntelIntrestrestedPartiesHandler').Core_Active__c){
                try{
                    
                    List<ID> CaseIdList = new List<ID>();
                    List<Core_IPS_Project_Member__c> projectMemberList = new List<Core_IPS_Project_Member__c>();
                    //FLS check added-Venugopal
                    if(Core_IPS_Case_Interested_Party__c.SObjectType.getDescribe().isAccessible()){
                    iPList = [Select id,Name,Case__c,Case__r.AccountId,User__c,User__r.ProfileId,Contact__c,Contact__r.Email,Contact__r.Core_Enterprise_Id__c,Agent_Name__c,Active__c,Type__c from Core_IPS_Case_Interested_Party__c where id IN: oldList];
                    }
                    for(Core_IPS_Case_Interested_Party__c iP: oldList){
                        
                        CaseIdList.add(iP.Case__c);
                    }
                    // start----   ----25-06-2021----Farooq---- Interested party changes my Intel-- 
                    if(!Test.isRunningTest() && iPList.size()>0)
                    { 
                        projectMemberList = [select Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Core_Enterprise_Id__c, Core_IPS_Project__c from Core_IPS_Project_Member__c 
                                             where Core_IPS_Project__c IN (select Core_IPS_Project_Case__c from Case where ID IN: CaseIdList) and Core_IPS_Contact_IPS_Active__c = true];
                        System.enqueueJob(new Core_IPS_MyIntel_3_0(new List<Id>(CaseIdList), 'Remove', projectMemberList, iPList));
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