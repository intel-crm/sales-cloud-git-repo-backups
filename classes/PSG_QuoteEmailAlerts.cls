/****************************************************************************************************
Apex Class Name : PSG_QuoteEmailAlerts
Version         : 1.0 
Created Date    : 02/21/2022
Function        : This class is to be used for all Quote email alerts.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Drushti Chauhan             02/21/2022             Created
*****************************************************************************************************/
public without sharing class PSG_QuoteEmailAlerts {
    @InvocableMethod(label='Quote email alerts' category='SBQQ__Quote__c')
    public static void getQuotes(List<ID> quoteId){
        Map<Id,Set<String>> userTodelegatedUserMap=getAllDelegatedUsers();
        List<Messaging.SingleEmailMessage> mails=new List<Messaging.SingleEmailMessage>();
        List<SBQQ__Quote__c> getactivequotes = [Select id,core_cpq_requestor_nm__r.Email,OwnerId,owner.email from SBQQ__Quote__c where id in :quoteId];
        EmailTemplate activetempId = [SELECT Id, HTMLValue,Subject, Body, Name FROM EmailTemplate WHERE DeveloperName = 'PSG_Quote_active_notify'];
        OrgWideEmailAddress orgWideEmailAdd = [Select Id,Address,DisplayName from OrgWideEmailAddress where address='wsm-postmaster@intel.com' Limit 1];
        for(SBQQ__Quote__c quote: getactivequotes){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setTemplateId(activetempId.Id);
            mail1.setTargetObjectId(quote.ownerId);
            mail1.setWhatId(quote.Id);
            mail1.setSaveAsActivity(false);
            Set<String> toAddresses = new Set<String>();
            if(quote?.core_cpq_requestor_nm__r?.Email != null){
                toAddresses.add(quote.core_cpq_requestor_nm__r.Email);
            }	
            if(quote?.owner?.Email != null){
               toAddresses.add(quote.owner.Email); 
            }	
            if(userTodelegatedUserMap.containsKey(quote.ownerId)){
              toAddresses.addAll(userTodelegatedUserMap.get(quote.ownerId));  
            }    
            mail1.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
            mail1.setToAddresses(new List<String>(toAddresses));
            mails.add(mail1);
        }
        if(!mails.isEmpty()){
            Messaging.sendEmail(mails);
         }
    }
    
    public static Map<Id,Set<String>> getAllDelegatedUsers(){
        Map<Id,Set<String>> userTodelegatedUserMap=new Map<Id,Set<String>>();
        for(core_user_delegation__c userdeleg : [Select id,core_cpq_delegated_For__c,core_cpq_delegated_to__c,core_cpq_delegated_to__r.email,Start_Date__c,End_Date__c from core_user_delegation__c where Start_Date__c <= Today and End_Date__c >= Today and core_cpq_delegated_to__c <> null]){
            if(userTodelegatedUserMap.containsKey(userdeleg.core_cpq_delegated_For__c)){
                userTodelegatedUserMap.get(userdeleg.core_cpq_delegated_For__c).add(userdeleg.core_cpq_delegated_to__r?.email);
            }else{
                userTodelegatedUserMap.put(userdeleg.core_cpq_delegated_For__c,new Set<String>{userdeleg.core_cpq_delegated_to__r?.email});
            }
        }
        return userTodelegatedUserMap;
    }
}