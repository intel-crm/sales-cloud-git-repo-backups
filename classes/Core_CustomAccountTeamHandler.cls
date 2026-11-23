/******************************************************************************************************************************************
Class Name  : Core_CustomAccountTeamHandler
Version     : 1.0 
Created Date: 18 MAR 2016
Function    : 
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------    
* Dave Hood                 03/18/2015              Original version
*****************************************************************************************************************************************/

public class Core_CustomAccountTeamHandler {

    public static void manageSharing(List<Core_Account_Team__c> newList) {
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        if(mapFunctionalityNameTriggerExecution.containsKey('shareAccountMeetingBrief') &&
           mapFunctionalityNameTriggerExecution.get('shareAccountMeetingBrief').Core_Active__c) {
               
               System.debug('##### newList: ' + newList);
           
               // Get the following from the list of account team members passed in: User IDs, Account IDs
               // For those Account IDs, get the list of Account Meeting Briefs associated with them
               // Insert sharing records for those users, for those Account Meeting Briefs
               
               Map<Id,Set<Id>> accountIdUserIdMap = new Map<Id,Set<Id>>();
               for (Core_Account_Team__c teamMember : newList) {
                   Set<Id> userIds = new Set<Id>();
                   if (accountIdUserIdMap.containsKey(teamMember.Core_Account__c))
                       userIds = accountIdUserIdMap.get(teamMember.Core_Account__c);
                   userIds.add(teamMember.Core_Team_Member__c);
                   accountIdUserIdMap.put(teamMember.Core_Account__c, userIds);
               }
               List<Account_Meeting_Brief__c> acctMeetingBriefs=new  List<Account_Meeting_Brief__c>();
               //FLS check added-Venugopal
               if(Account_Meeting_Brief__c.SObjectType.getDescribe().isAccessible()){
                    acctMeetingBriefs = [select Id, Account__c from Account_Meeting_Brief__c
                                                                       where Account__c in :accountIdUserIdMap.keySet()];
                   System.debug('##### acctMeetingBriefs: ' + acctMeetingBriefs);
               } 
               List<Account_Meeting_Brief__Share> briefShares = new List<Account_Meeting_Brief__Share>();
               
               for (Account_Meeting_Brief__c brief : acctMeetingBriefs) {
                   for (Id userId : accountIdUserIdMap.get(brief.Account__c)) {
                       briefShares.add(new Account_Meeting_Brief__Share(ParentId=brief.Id, UserOrGroupId=userId, AccessLevel='Edit',RowCause = Schema.Account_Meeting_Brief__Share.RowCause.Account_Team_Member__c));
                   }
               }
               
               if (briefShares.size() > 0) {
                   try {
                       System.debug('##### inserting briefShares: ' + briefShares);
                       insert briefShares;
                   }
                   catch (Exception e) {
                       System.debug('##### Exception: ' + e.getMessage());
                       Core_Exceptions__c excep=new Core_Exceptions__c();
                
                       excep.Core_Class_Name__c='Core_CustomAccountTeamHandler';
                       
                       excep.Core_Exception__c=e.getMessage()+' '+e.getStackTraceString();
                       
                       excep.Core_Login_User_Id__c=userInfo.getUserId();
                       insert excep;
                   }
               }
           }
        
    }
    
    public static void revokeAccessForDelete(List<Core_Account_Team__c> oldList) {
        List<Account_Meeting_Brief__c> acctMeetingBriefs=new List<Account_Meeting_Brief__c>();
        system.debug('inside delete access method');
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        if(mapFunctionalityNameTriggerExecution.containsKey('shareAccountMeetingBrief') &&
           mapFunctionalityNameTriggerExecution.get('shareAccountMeetingBrief').Core_Active__c) {
               
               System.debug('##### oldList: ' + oldList);
               // Get the following from the list of account team members passed in: User IDs, Account IDs
               // For those Account IDs, get the list of Account Meeting Briefs associated with them
               // From that list, get the Account Meeting Brief Share records for the users in question
               // Delete sharing records for those users, for those Account Meeting Briefs
               
               Map<Id,Set<Id>> accountIdUserIdMap = new Map<Id,Set<Id>>();
               for (Core_Account_Team__c teamMember : oldList) {
                   Set<Id> userIds = new Set<Id>();
                   if (accountIdUserIdMap.containsKey(teamMember.Core_Account__c))
                       userIds = accountIdUserIdMap.get(teamMember.Core_Account__c);
                   userIds.add(teamMember.Core_Team_Member__c);
                   accountIdUserIdMap.put(teamMember.Core_Account__c, userIds);
               }
               
               Set<Id> accountIds = accountIdUserIdMap.keySet();
               //FLS check added-Venugopal
               if(Account_Meeting_Brief__c.SObjectType.getDescribe().isAccessible()){
                   acctMeetingBriefs = [select Id, Account__c from Account_Meeting_Brief__c
                                                                   where Account__c in :accountIds];
               System.debug('##### acctMeetingBriefs: ' + acctMeetingBriefs);
               }
               
               Set<Id> acctMeetingBriefIds = new Set<Id>();
               List<Account_Meeting_Brief__Share> allBriefShares=new List<Account_Meeting_Brief__Share>();
               for (Account_Meeting_Brief__c brief : acctMeetingBriefs)
                   acctMeetingBriefIds.add(brief.Id);
               //FLS check added-Venugopal
               if(Account_Meeting_Brief__Share.SObjectType.getDescribe().isAccessible()){
                  allBriefShares = [select Id, Parent.Account__c, UserOrGroupId
                                                                    from Account_Meeting_Brief__Share where ParentId in :acctMeetingBriefIds and RowCause =: Schema.Account_Meeting_Brief__Share.RowCause.Account_Team_Member__c];
               } 
               List<Account_Meeting_Brief__Share> briefSharesToDelete = new List<Account_Meeting_Brief__Share>();
               
               for (Account_Meeting_Brief__Share share : allBriefShares) {
                   Id accountId = share.Parent.Account__c;
                   Id userId = share.UserOrGroupId;
                   if (accountIds.contains(accountId) && accountIdUserIdMap.containsKey(accountId) &&
                       accountIdUserIdMap.get(accountId).contains(userId)) {
                       briefSharesToDelete.add(share);
                   }
               }
               
               if (briefSharesToDelete.size() > 0) {
                   try {
                       System.debug('##### deleting briefSharesToDelete: ' + briefSharesToDelete);
                       if (Schema.sObjectType.Account_Meeting_Brief__Share.isDeletable()) {
                       delete briefSharesToDelete;
                   }
                   }
                   catch (Exception e) {
                       System.debug('##### Exception: ' + e.getMessage());
                       Core_Exceptions__c excep=new Core_Exceptions__c();
                
                       excep.Core_Class_Name__c='Core_CustomAccountTeamHandler';                       
                       excep.Core_Exception__c=e.getMessage()+' '+e.getStackTraceString();                                                                        
                       excep.Core_Login_User_Id__c=userInfo.getUserId();
                       insert excep;
                   }
               }
           
           }
        
    }
    
    /*
    * Method name  : Insert_logexception
    * Description  : This Method used to create failed records in Exception object.
    * Parameter    : (List<Account>,ExceptionMsg).
    */ 
    Public static void Insert_logexception(list<Account> acc,String ExceptionMsg){
        if(ExceptionMsg != null){
            list<Core_Exceptions__c> exceplist=new list<Core_Exceptions__c>();
            for(Account a: acc){
                Core_Exceptions__c excep=new Core_Exceptions__c();
               
                    excep.Core_Class_Name__c='Core_IPS_AccountTeamUpdate_Scheduler';
                    excep.Core_Method_Name__c='execute';
                    excep.Core_Record_Id__c=a.Id; 
               
                /*if(system.isBatch()){
                    excep.Core_Class_Name__c='Core_IPS_AccountTeamUpdate_Scheduler';
                    excep.Core_Method_Name__c='execute';
                    excep.Core_Record_Id__c=a.Id;
                }*/
                excep.Core_Exception__c=ExceptionMsg;
                excep.Core_IPS_Object_Name__c='Account';                                                   
                excep.Core_Login_User_Id__c=userInfo.getUserId();
                exceplist.add(excep);
            } //End of for loop//
            if(exceplist != null && !(exceplist.isEmpty())){
               Database.insert(exceplist);
            }             
        }
    }
    
}