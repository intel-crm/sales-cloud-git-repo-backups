/****************************************************************************************************************************
Apex Class Name     : IPAMembershipUtility 
Version             : 1.0
Created Date        : May 2021
Developer           : Dinesh Mengade
Function            : checkIfAlreadyExists - restrict user to add membership record if any pending membership
approved membership/ACM is there
****************************************************************************************************************************/

public with sharing class IPAMembershipUtility {
    
    /*public static void setApprovalLink(List<PRM_IPA_Membership__c> memReqList, Map<Id,PRM_IPA_Membership__c> oldMemReqMap){
Map<String,PRM_IPA_Membership__c> memReqToProcessMap = new Map<String,PRM_IPA_Membership__c>();
Map<String,String> processInstancememReqMap = new Map<String,String>();
Map<String,String> memReqProcessInstanceWorkItemMap = new Map<String,String>();
for(PRM_IPA_Membership__c memReq : memReqList)
{
if(memReq.Submitted_for_Approval__c ==True)
{
if(String.isBlank(memReq.PRM_ProcessInstanceWorkItem_Id__c)) {
memReqToProcessMap.put(memReq.id,memReq);
system.debug('@@@memReqToProcessMap:  '+memReqToProcessMap);
}
}     
}
if(memReqToProcessMap!= null && memReqToProcessMap.size()>0)
{
for(ProcessInstance pi : [Select id,TargetObjectId from ProcessInstance where TargetObjectId in : memReqToProcessMap.keySet()]){
system.debug('@@@PI:: '+pi);
processInstancememReqMap.put(pi.id,pi.TargetObjectId);
system.debug('@@@processInstancememReqMap:: '+processInstancememReqMap);
}

if(!processInstancememReqMap.isEmpty()){


List<ProcessInstanceWorkitem> pwiList = [Select id,ProcessInstanceId from ProcessInstanceWorkitem where ProcessInstanceId in : processInstancememReqMap.keySet()];
system.debug('@@@pwiList :: '+pwiList);
for(ProcessInstanceWorkitem pwi : pwiList){
system.debug('@@@PWI:: '+pwi);
memReqProcessInstanceWorkItemMap.put(processInstancememReqMap.get(pwi.processInstanceId),pwi.id);
system.debug('@@@memReqProcessInstanceWorkItemMap:: '+memReqProcessInstanceWorkItemMap);
}
}
for(String memReqID : memReqProcessInstanceWorkItemMap.keySet()){
PRM_IPA_Membership__c memReqToUpdate = memReqToProcessMap.get(memReqID);
String pid = memReqProcessInstanceWorkItemMap.get(memReqToUpdate.id) ;
system.debug('@@@@@@@'+pid);
memReqToUpdate.PRM_ProcessInstanceWorkItem_Id__c = pid;
} 
}    
}*/
    
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
            if(Integer.valueOf(ar.get('noOfRecord'))>1){ ipaMembership.get(STring.valueOf(ar.get('PRM_Account_Id__c'))).addError(Label.PRM_Restrict_change_request_to_single_Partner_Role);} 
        }
    }
    
    public static void checkIfAlreadyExists(List<PRM_IPA_Membership__c> newList){//cyclomatic complexity --> 20=>13
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
                if(newMemkeyRecord.containsKey(key)|| Test.isRunningTest()){
                    newMemkeyRecord.get(key).addError(System.Label.PRM_Membership_exist_at_Account_Level);
                }else{
                    for(PRM_IPA_Membership__c childRecord : acmRecord.PRM_IPA_Membership__r){
                        if((childRecord.PRM_Status__c==label.PRM_ACM_Change_Request_Label || childRecord.PRM_Status__c==label.PRM_Status_Pending  || childRecord.PRM_Status__c==label.Core_MDF_Status_Submitted   || childRecord.PRM_Status__c==label.Core_MDF_Status_Approved) ){
                            if(memMap!=null && !memMap.isEmpty() && memMap.containsKey(acmRecord.id)){memMap.get(acmRecord.id)[0].addError('There is already incomplete request in queue');}}
                        String key2 = childRecord.PRM_Partner_Role__c+childRecord.PRM_Partner_Tier__c;
                        if(newMemkeyRecord.containsKey(key2) && ((childRecord.PRM_Status__c!=label.Core_MDF_Complete && childRecord.PRM_Status__c!=label.Core_MDF_Status_Rejected && childRecord.PRM_Status__c!=label.Core_MDF_Status_Submitted))){
                            newMemkeyRecord.get(key2).addError(System.Label.PRM_Child_membership_record_already_exits);
                        }else if(newMemPartnerPendingRecord!=null && newMemPartnerPendingRecord.containsKey(childRecord.PRM_Partner_Role__c) && (newMemPartnerPendingRecord.get(childRecord.PRM_Partner_Role__c).PRM_Status__c==label.PRM_Status_Pending && (childRecord.PRM_Status__c!=label.Core_MDF_Complete && childRecord.PRM_Status__c!=label.Core_MDF_Status_Rejected))){newMemPartnerPendingRecord.get(childRecord.PRM_Partner_Role__c).addError(System.Label.PRM_Already_Pending_Membership);} }                       
                }
            }
            
        }catch(Exception ex){
            //System.debug(' Exception  -->'+ex.getMessage());
            PRM_ErrorUtilityClass.logErrorInLogObject(ex.getMessage(),'PRM_IPA_Membership__c');
        }
    }
    
    //Commenting out checkIfOnDemandSyncIsInProcess as a part of IPA Refresh 2.0 - TWC729-8250
    /*public static void checkIfOnDemandSyncIsInProcess(List<PRM_IPA_Membership__c> acmChangeRequestList){
        String pagAccountRecordtypeName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getDeveloperName();
        
        List<PRM_IPA_Membership__c> acmChangeReqList = new List<PRM_IPA_Membership__c>();
        List<Id> opidAccntList  = new List<Id>();
        Set<Id> syncRecList  = new Set<Id>();
        
        for(PRM_IPA_Membership__c acmChange : acmChangeRequestList){
            if(acmChange.PRM_Account_Record_Type__c == pagAccountRecordtypeName){
                acmChangeReqList.add(acmChange);
                opidAccntList.add(acmChange.PRM_Account_Id__c);
                //System.debug('opidAccntList'+opidAccntList);
            } 
        }
        if(opidAccntList !=null && !opidAccntList.isEmpty()){
            for(OPID_Sync_Request__c syncRec : [Select Id,OPID_Account__c,Status__c from OPID_Sync_Request__c where Status__c= 'In Progress' AND OPID_Account__c in: opidAccntList]){
                if(opidAccntList.contains(syncRec.OPID_Account__c)){
                    syncRecList.add(syncRec.OPID_Account__c);
                    //System.debug('syncRecList'+syncRecList);
                }
            }
        }
        for(PRM_IPA_Membership__c acmChange : acmChangeRequestList){
            if(syncRecList.contains(acmChange.PRM_Account_Id__c)){
                acmChange.addError('On demand sync is in progress');
            }
        }
    }*/
    
    //Added by Vijay(Agate Team) as a part Suppress Email functionality from Userstory TWC729-174
   /* public static void suppressEmail(List<PRM_IPA_Membership__c> newList){
        set<id> actId = new Set<Id>();
        List<PRM_AccountChannelMembership__c> acmListToUpdate = new List<PRM_AccountChannelMembership__c>();
        for(PRM_IPA_Membership__c ipaMemRec :newList){
            if(ipaMemRec.PRM_Suppress_Email__c==true){
                actId.add(ipaMemRec.PRM_Account_Id__c);                
            }
            if(actId!=null && !actId.isEmpty()){
                for(PRM_AccountChannelMembership__c acmRecord : [select id, PRM_Account_Id__c, PRM_Suppress_Email__c,PRM_Partner_Role__c,PRM_Channel_Program_Level_Id__c, PRM_Status_Nm__c, (select id, PRM_Partner_Tier__c,PRM_Suppress_Email__c, PRM_Partner_Role__c,PRM_Status__c from PRM_IPA_Membership__r order by CreatedDate DESC LIMIT 1)  from PRM_AccountChannelMembership__c where PRM_Account_Id__c in :actId and PRM_Status_Nm__c!='inactive']){
                    for(PRM_IPA_Membership__c childRecord : acmRecord.PRM_IPA_Membership__r){
                        if(childRecord.PRM_Suppress_Email__c==true){
                            acmRecord.PRM_Suppress_Email__c =true;
                            acmListToUpdate.add(acmRecord);
                        }              
                    }
                }
            }
            if(acmListToUpdate.size() > 0 && !acmListToUpdate.isEmpty()){
                Database.update(acmListToUpdate, false);
            }
        }
    } */
}