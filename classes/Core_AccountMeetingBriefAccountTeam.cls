/******************************************************************************************************************************************
Class Name  : Core_AccountMeetingBriefAccountTeam
Version     : 1.0 
Created Date: 18 MAR 2016
Function    : Used to add the Account Owner + Account Team to the sharing on Account Meeting Brief custom object
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Dave Hood                 03/18/2016              Original version
*****************************************************************************************************************************************/
public class Core_AccountMeetingBriefAccountTeam {

    public static void addAccountOwnerAndTeam(List<Account_Meeting_Brief__c> oldList, List<Account_Meeting_Brief__c> newList,
                                              Map<Id,Account_Meeting_Brief__c> oldMap, Map<Id,Account_Meeting_Brief__c> newMap)
    {
        // Ensure no re-entry
        if (!Core_AccountMeetingBriefHandler.accountTeamMembersAdded) {
            Core_AccountMeetingBriefHandler.accountTeamMembersAdded = true;
            
            // Check to see if the trigger functionality is turned on
            if (!Core_AccountMeetingBriefHandler.mapFunctionalityNameTriggerExecution.isEmpty()) {
                if (Core_AccountMeetingBriefHandler.mapFunctionalityNameTriggerExecution.containsKey('addAccountTeamToMeetingBrief') && 
                    Core_AccountMeetingBriefHandler.mapFunctionalityNameTriggerExecution.get('addAccountTeamToMeetingBrief').Core_Active__c)
                {
                    // Iterate through the list of Account Meeting Briefs being added, and get the Account Owner + Account Teams for each
                    // For all of those Account Meeting Briefs + Users, add sharing records
                    
                    Set<Id> accountIds = new Set<Id>();
                    for (Account_Meeting_Brief__c brief : newList)
                        accountIds.add(brief.Account__c);
                    
                    List<Account> accounts = [select Id, OwnerId from Account where Id in :accountIds];
                    List<AccountTeamMember> accountTeamMembers = [select Id, AccountId, UserId from AccountTeamMember where AccountId in :accountIds];
                    
                    //Map<Id,Id> accountIdToOwnerMap = new Map<Id,Id>();
                    Map<Id,List<Id>> accountIdToUserMap = new Map<Id,List<Id>>();
                    
                    for (Account acct : accounts)
                        accountIdToUserMap.put(acct.Id, new List<Id>{acct.OwnerId});
                    
                    for (AccountTeamMember member : accountTeamMembers) {
                        // This should always be true: accountIdToUserMap.containsKey(member.AccountId), since we just built it with account owners
                        List<Id> memberIds = accountIdToUserMap.get(member.AccountId);
                        memberIds.add(member.UserId);
                        accountIdToUserMap.put(member.AccountId, memberIds);
                    }
                    System.debug('##### accountIdToUserMap: ' + accountIdToUserMap);
                    
                    for (Account_Meeting_Brief__c brief : newList) {
                        for (Id userId : accountIdToUserMap.get(brief.Account__c)) {
                            
                            // The current user will already have 'All' rights to the Account Meeting Brief, so if we try to insert 'Edit' it'll fail
                            if (userId != UserInfo.getUserId()) {
                                
                                Account_Meeting_Brief__Share share = new Account_Meeting_Brief__Share(ParentId = brief.Id,
                                                                                                      UserOrGroupId = userId,
                                                                                                      AccessLevel = 'Edit',
                                                                                                      RowCause = Schema.Account_Meeting_Brief__Share.RowCause.Account_Team_Member__c);
                                System.debug('##### share: ' + share);
                                Core_AccountMeetingBriefHandler.objectsToInsert.add(share);
                            }
                        }
                    }
                }
            }
        }
    }

}