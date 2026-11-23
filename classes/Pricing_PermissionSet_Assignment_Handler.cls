public without sharing class Pricing_PermissionSet_Assignment_Handler extends TriggerHandler{
    
    public override void afterInsert() {
        Set<String> userIds = new Set<String>();
        Set<String> deletedUserIds = new Set<String>();
        for(Pricing_PermissionSet_Assignment_Event__e evt : (List<Pricing_PermissionSet_Assignment_Event__e>)Trigger.New){
            if(!String.isEmpty(evt.Pricing_User_Ids__c) && evt.Pricing_Action__c=='insert'){
                userIds.addAll(evt.Pricing_User_Ids__c.split(','));
            }
            if(!String.isEmpty(evt.Pricing_User_Ids__c) && evt.Pricing_Action__c=='delete'){
                deletedUserIds.addAll(evt.Pricing_User_Ids__c.split(','));
            }            
        }
        
        // Inserted Users in PSA 
        if(userIds.size()>0){
            Set<Id> accountIds = New Set<Id>();
            List<AccountTeamMember> accoTeamMemList = New List<AccountTeamMember>();
            accoTeamMemList= [SELECT Id, UserId, AccountId FROM AccountTeamMember where UserId in : userIds];
            if(accoTeamMemList.size()>0){
                for(AccountTeamMember atm: accoTeamMemList){
                    accountIds.add(atm.AccountId); 
                }
                Map<Id,Set<Id>> accountToGroupIdMapInter = new  Map<Id,Set<Id>>();
                if(accountIds.size()>0){
                    for(Core_MDF_Partner_Group_Mapping__c partnerGroup : [select Id,Core_MDF_Account__c,Core_MDF_Channel_Program_Name_Txt__c,Core_MDF_Channel_Program__c,Core_MDF_AccountIdGroupName__c,Core_MDF_Group_Id__c,Core_MDF_Type_of_Access__c from Core_MDF_Partner_Group_Mapping__c where
                                                                          Core_MDF_Channel_Program_Name_Txt__c =: Label.Pricing_Tender_PGM_Channel and   Core_MDF_Account__c in : accountIds and Core_MDF_Group_Id__c!=null and Core_MDF_Type_of_Access__c=: Label.Pricing_Tender_PGM_Type]){
                                                                              if(!accountToGroupIdMapInter.containsKey(partnerGroup.Core_MDF_Account__c)){
                                                                                  accountToGroupIdMapInter.put(partnerGroup.Core_MDF_Account__c,new Set<Id>{partnerGroup.Core_MDF_Group_Id__c});
                                                                              }
                                                                              else {
                                                                                  accountToGroupIdMapInter.get(partnerGroup.Core_MDF_Account__c).add(partnerGroup.Core_MDF_Group_Id__c);
                                                                              }                                                                          
                                                                          } 
                }
                Database.executeBatch(new Pricing_BatchQuoteShare_ATM(accoTeamMemList, false, accountToGroupIdMapInter));
            }
        }
        
        // Deleted Users from PSA
        if(deletedUserIds.size()>0){
            Set<Id> accountIds = New Set<Id>();
            List<AccountTeamMember> accoTeamMemList = New List<AccountTeamMember>();
            accoTeamMemList= [SELECT Id, UserId, AccountId FROM AccountTeamMember where UserId in : deletedUserIds];
            if(accoTeamMemList.size()>0){
                for(AccountTeamMember atm: accoTeamMemList){
                    accountIds.add(atm.AccountId); 
                }
                Map<Id,Set<Id>> accountToGroupIdMapInter = new  Map<Id,Set<Id>>();
                if(accountIds.size()>0){
                    for(Core_MDF_Partner_Group_Mapping__c partnerGroup : [select Id,Core_MDF_Account__c,Core_MDF_Channel_Program_Name_Txt__c,Core_MDF_Channel_Program__c,Core_MDF_AccountIdGroupName__c,Core_MDF_Group_Id__c,Core_MDF_Type_of_Access__c from Core_MDF_Partner_Group_Mapping__c where
                                                                          Core_MDF_Channel_Program_Name_Txt__c =: Label.Pricing_Tender_PGM_Channel and   Core_MDF_Account__c in : accountIds and Core_MDF_Group_Id__c!=null and Core_MDF_Type_of_Access__c=: Label.Pricing_Tender_PGM_Type]){
                                                                              if(!accountToGroupIdMapInter.containsKey(partnerGroup.Core_MDF_Account__c)){
                                                                                  accountToGroupIdMapInter.put(partnerGroup.Core_MDF_Account__c,new Set<Id>{partnerGroup.Core_MDF_Group_Id__c});
                                                                              }
                                                                              else {
                                                                                  accountToGroupIdMapInter.get(partnerGroup.Core_MDF_Account__c).add(partnerGroup.Core_MDF_Group_Id__c);
                                                                              }                                                                          
                                                                          } 
                }
                Database.executeBatch(new Pricing_BatchQuoteShare_ATM(accoTeamMemList, True, accountToGroupIdMapInter));
            }            
        }                
    }
    
}