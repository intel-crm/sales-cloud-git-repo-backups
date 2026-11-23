/****************************************************************************************************
Apex Class Name : PSG_UserDelegationBusinessLogic
Version         : 1.0 
Created Date    : 01/05/2021
Function        : This class is used used as part of User Delegation trigger
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hema                     01/05/2021               Created
*****************************************************************************************************/
public with sharing class PSG_UserDelegationBusinessLogic {
    
    /************************************************************************************************************
    *Method Name : beforeInsertUpdateOperations
    *Created Date: 08/13/2021
    *Author: Hema
    *Description : Performs operations on before context of trigger.
    ************************************************************************************************************/
    public static void beforeInsertUpdateOperations(List<core_user_delegation__c> userDelegateList,Map<id,core_user_delegation__c> oldMap,Boolean isInsert){
        set<Id> userIdSet = new set<Id>();
        String CONST_SOS = Label.PSG_Quote_SOS_PermissionSet;
        string CONST_DELEGATETOOUSERTYPE = 'NOT FOUND';
        string CONST_DELEGATEFOROUSERTYPE = 'NOT FOUND';
        try{
            if(!userDelegateList.isEmpty()){
                if(isInsert){
                    for(core_user_delegation__c userDelegate : userDelegateList){
                        if(userDelegate.core_cpq_delegated_to__c != null){
                            userIdSet.add(userDelegate.core_cpq_delegated_to__c);
                        }
                        
                        if(userDelegate.core_cpq_delegated_For__c != null){
                            userIdSet.add(userDelegate.core_cpq_delegated_For__c);
                        }
                    }
                }else{
                    for(core_user_delegation__c userDelegate : userDelegateList){
                        
                        if(userDelegate.core_cpq_delegated_to__c != null && oldmap.get(userDelegate.Id).core_cpq_delegated_to__c != userDelegate.core_cpq_delegated_to__c){
                            userIdSet.add(userDelegate.core_cpq_delegated_to__c);
                            userIdSet.add(userDelegate.core_cpq_delegated_For__c);  
                        }
                        
                        if(userDelegate.core_cpq_delegated_For__c != null  && oldmap.get(userDelegate.Id).core_cpq_delegated_For__c != userDelegate.core_cpq_delegated_For__c){
                            userIdSet.add(userDelegate.core_cpq_delegated_For__c);
                            userIdSet.add(userDelegate.core_cpq_delegated_to__c);
                        }
                    }
                }
                
                Map<Id,String> matchDelegateUsersToRegionMap = new Map<Id,String>();
                for(PermissionSetAssignment psa : [SELECT Id,PermissionSet.Name,AssigneeId,Assignee.Contact.AccountId FROM PermissionSetAssignment
                                                   WHERE AssigneeId = :userIdSet  AND (PermissionSet.Name =:Label.PSG_Quote_SOS_PermissionSet OR 
                                                                                       PermissionSet.Name = : Label.PSG_Quote_BO_PermissionSet OR 
                                                                                       PermissionSet.Name = :Label.PSG_Quote_BM_PermissionSet)]){
                                                                                           String permissions = psa.permissionSet.Name;
                                                                                           if(matchDelegateUsersToRegionMap.containskey(psa.AssigneeId)){
                                                                                               permissions = permissions +','+ matchDelegateUsersToRegionMap.get(psa.AssigneeId);
                                                                                           }
                                                                                           matchDelegateUsersToRegionMap.put(psa.AssigneeId,permissions);                      
                                                                                       }
                
                for(core_user_delegation__c userDelegate : userDelegateList){
                    If(matchDelegateUsersToRegionMap.containsKey(userDelegate.core_cpq_delegated_For__c)){
                        CONST_DELEGATEFOROUSERTYPE = matchDelegateUsersToRegionMap.get(userDelegate.core_cpq_delegated_For__c);
                    }
                    If(matchDelegateUsersToRegionMap.containsKey(userDelegate.core_cpq_delegated_to__c)){
                        CONST_DELEGATETOOUSERTYPE = matchDelegateUsersToRegionMap.get(userDelegate.core_cpq_delegated_to__c);
                    }
                    if((CONST_DELEGATEFOROUSERTYPE.contains(CONST_SOS) && !CONST_DELEGATETOOUSERTYPE.contains(CONST_SOS)) || (!CONST_DELEGATEFOROUSERTYPE.contains(CONST_SOS) && CONST_DELEGATETOOUSERTYPE.contains(CONST_SOS))){
                        userDelegate.addError(Label.PSG_Delegate_User_Error);
                    }
                }
            }
        }catch(Exception e){
            PSG_Utility.logError(e);
        }
    }
    public static void createSharingForDelegates(List<core_user_delegation__c> scope,String action){
         Map<Id,Set<Id>> delegateUserMap = new Map<Id,Set<Id>>();
         Map<Id,Set<Id>> quoteToDelegateUserMap = new Map<Id,Set<Id>>();
         for(core_user_delegation__c userDelgation : scope){
             if(delegateUserMap.containsKey(userDelgation.core_cpq_delegated_For__c)){
                 Set<id> delegatedtoids=delegateUserMap.get(userDelgation.core_cpq_delegated_For__c);
                 delegatedtoids.add(userDelgation.core_cpq_delegated_to__c);
                 delegateUserMap.put(userDelgation.core_cpq_delegated_For__c,delegatedtoids);
             }
            else{
                 delegateUserMap.put(userDelgation.core_cpq_delegated_For__c,new set<Id>{userDelgation.core_cpq_delegated_to__c});
            }
         }
        for(SBQQ__Quote__c quote:[SELECT id,name,OwnerId from SBQQ__Quote__c WHERE OwnerId IN : delegateUserMap.keySet()]){
            if(delegateUserMap.containsKey(quote.OwnerId)){
                Set <Id> temp =delegateUserMap.get(quote.OwnerId);
                quoteToDelegateUserMap.put(quote.id,temp);
        	}
        }
        if(!quoteToDelegateUserMap.isEmpty()){
            if(action == 'grant'){
                shareQuotesForDelegates(quoteToDelegateUserMap);
            }
            if(action == 'revoke'){
                 unshareQuotesForDelegates(quoteToDelegateUserMap);
            }            
        }
        
    }
    public static void shareQuotesForDelegates(Map<Id,Set<Id>> quoteToDelegateUserMap){
        try{
            List<SBQQ__Quote__share> qouteownerSharelist = new List<SBQQ__Quote__share>();
			if(!quoteToDelegateUserMap.isEmpty()){
				for(Id quoteId:quoteToDelegateUserMap.keySet()){
					Set<Id> delgateUsers=quoteToDelegateUserMap.get(quoteId);
					for(Id userId:delgateUsers){
						qouteownerSharelist.add(new SBQQ__Quote__Share(ParentId = quoteId,
																	   UserOrGroupId = userId,
																	   AccessLevel = 'edit',
																	   RowCause = Schema.SBQQ__Quote__Share.RowCause.Manual));
					}
				}
			}
			if(!qouteownerSharelist.isEmpty()){
				insert qouteownerSharelist;
			}
		}
		catch (Exception ex){
			PSG_Utility.logError(ex);
		}
    }
    public static void unshareQuotesForDelegates(Map<Id,Set<Id>> quoteToDelegateUserMap){
        try{
            Set<Id> allusersids=new Set<Id>();
            List<SBQQ__Quote__Share> quotesharetodelete=new List<SBQQ__Quote__Share>();
            for(String key:quoteToDelegateUserMap.keySet()){
                allusersids.addAll(quoteToDelegateUserMap.get(key));
                
            }
            
            for(SBQQ__Quote__Share quoteshare:[SELECT id,UserOrGroupId,ParentId FROM SBQQ__Quote__Share WHERE (ParentId IN :quoteToDelegateUserMap.keySet()  OR  UserorGroupid IN: allusersids) AND RowCause ='Manual']){
                if(quoteToDelegateUserMap.containsKey(quoteshare.ParentId) && quoteToDelegateUserMap.get(quoteshare.ParentId).contains(quoteshare.UserOrGroupId)){
                    quotesharetodelete.add(quoteshare);
                }
            }
            if(!quotesharetodelete.isEmpty()){
                delete quotesharetodelete;
            }
        }
        catch(Exception ex){
            PSG_Utility.logError(ex);
        }
    }
        
    
}