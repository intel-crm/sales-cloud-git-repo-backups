/****************************************************************************************************************************
Apex Class Name     : IPAMembershipUtility 
Version             : 1.0
Created Date        : May 2021
Developer           : Dinesh Mengade
Function 			: checkIfAlreadyExists - restrict user to add membership record if any pending membership
approved membership/ACM is there
****************************************************************************************************************************/

public with sharing class IPAMembershipUtility {
    public static void checkIfMultipleACMExists(List<PRM_IPA_Membership__c> newList){
        set<id> accountId = new Set<id>();
        Map<id, PRM_IPA_Membership__c> ipaMembership= new Map<Id,PRM_IPA_Membership__c>();
        
        for(PRM_IPA_Membership__c ipamem : newList){
            accountId.add(ipamem.PRM_Account_Id__c);
            ipaMembership.put(ipamem.PRM_Account_Id__c, ipamem);
        }
        //for(AggregateResult ar : [select count(id) noOfRecord, PRM_Account_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c in :accountId and PRM_Status_Nm__c<>'Inactive' group by PRM_Account_Id__c]){
        //TWC729-7584 - ApexGuru
        for(AggregateResult ar : [select count(id) noOfRecord, PRM_Account_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c in :accountId and PRM_Status_Nm__c IN ('Pending','Approved') group by PRM_Account_Id__c]){     
            if(Integer.valueOf(ar.get('noOfRecord'))>1){
                ipaMembership.get(STring.valueOf(ar.get('PRM_Account_Id__c'))).addError(Label.PRM_Restrict_change_request_to_single_Partner_Role);
            }
        }
    }
    
    public static void checkIfAlreadyExists(List<PRM_IPA_Membership__c> newList){
        //new request - partnerRole, PRM_Channel_Program_Level__c, PRM_AccountChannelMembership__c
        set<id> actId = new Set<Id>();
        //List<String> status = Label.PRM_Reject_rej_request_if_status_is_one_of_this.split(';');
        map<String, PRM_IPA_Membership__c> newMemkeyRecord= new Map<String, PRM_IPA_Membership__c>();
        map<String, PRM_IPA_Membership__c> newMemPartnerPendingRecord= new Map<String, PRM_IPA_Membership__c>();
        Map<Id, List<PRM_IPA_Membership__c>> memMap = new Map<id, List<PRM_IPA_Membership__c>>();
        //map<Id,Integer> pendingMembershipmap = new Map<id, Integer>();
        
        try{
            for( PRM_IPA_Membership__c MembershipRecord : newList){
                actId.add(MembershipRecord.PRM_Account_Id__c);
                newMemkeyRecord.put(MembershipRecord.PRM_Partner_Role__c+MembershipRecord.PRM_Partner_Tier__c,MembershipRecord);// required to check acm at parent sibling level
                newMemPartnerPendingRecord.put(MembershipRecord.PRM_Partner_Role__c,MembershipRecord);
                if(memMap!=null && !memMap.isEmpty() && memMap.containsKey(MembershipRecord.PRM_Account_Channel_Membership__c)){
                    memMap.get(MembershipRecord.PRM_Account_Channel_Membership__c).add(MembershipRecord);
                    
                    
                }else{
                    memMap.put(MembershipRecord.PRM_Account_Channel_Membership__c, new List<PRM_IPA_Membership__c>{MembershipRecord});
                }
                
            }		        
            
            for(PRM_AccountChannelMembership__c acmRecord : [select id, PRM_Account_Id__c, PRM_Partner_Role__c,PRM_Channel_Program_Level_Id__c, PRM_Status_Nm__c, (select id, PRM_Partner_Tier__c, PRM_Partner_Role__c,PRM_Status__c from PRM_IPA_Membership__r )  from PRM_AccountChannelMembership__c where PRM_Account_Id__c in :actId and PRM_Status_Nm__c!='inactive']){
                String key = acmRecord.PRM_Partner_Role__c+acmRecord.PRM_Channel_Program_Level_Id__c;
                if(newMemkeyRecord.containsKey(key)){
                    newMemkeyRecord.get(key).addError(System.Label.PRM_Membership_exist_at_Account_Level);
                }else{
                    for(PRM_IPA_Membership__c childRecord : acmRecord.PRM_IPA_Membership__r){
                        if(childRecord.PRM_Status__c==label.PRM_ACM_Change_Request_Label || childRecord.PRM_Status__c==label.PRM_Status_Pending	 || childRecord.PRM_Status__c==label.Core_MDF_Status_Submitted	 || childRecord.PRM_Status__c==label.Core_MDF_Status_Approved){
                            if(memMap!=null && !memMap.isEmpty() && memMap.containsKey(acmRecord.id)){
                                memMap.get(acmRecord.id)[0].addError('There is already incomplete request in queue');
                            }
                        }
                        String key2 = childRecord.PRM_Partner_Role__c+childRecord.PRM_Partner_Tier__c;
                        if(newMemkeyRecord.containsKey(key2) && ((childRecord.PRM_Status__c!=label.Core_MDF_Complete && childRecord.PRM_Status__c!=label.Core_MDF_Status_Rejected && childRecord.PRM_Status__c!=label.Core_MDF_Status_Submitted))){
                            newMemkeyRecord.get(key2).addError(System.Label.PRM_Child_membership_record_already_exits);
                        }else if(newMemPartnerPendingRecord!=null && newMemPartnerPendingRecord.containsKey(childRecord.PRM_Partner_Role__c) && (newMemPartnerPendingRecord.get(childRecord.PRM_Partner_Role__c).PRM_Status__c==label.PRM_Status_Pending && (childRecord.PRM_Status__c!=label.Core_MDF_Complete && childRecord.PRM_Status__c!=label.Core_MDF_Status_Rejected))){
                            newMemPartnerPendingRecord.get(childRecord.PRM_Partner_Role__c).addError(System.Label.PRM_Already_Pending_Membership);
                        }   
                    }                    
                }
            }
            
        }catch(Exception ex){
            
            PRM_ErrorUtilityClass.logErrorInLogObject(ex.getMessage(),'PRM_IPA_Membership__c');
        }
    }
}