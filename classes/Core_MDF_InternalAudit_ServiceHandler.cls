public class Core_MDF_InternalAudit_ServiceHandler {
    public static void validateAuditDates(List<Core_MDF_InternalAudit__c> newListTobeProcessed, Map<Id,Core_MDF_InternalAudit__c> internalAuditOldMap) {
        /*List<Core_MDF_InternalAudit__c> internalAuditToBeStamped = new List<Core_MDF_InternalAudit__c>();

try{            
// Check whether the audit now is updated from the new and old list && true
for(Core_MDF_InternalAudit__c newInternalAudit : newListTobeProcessed){                
if(newInternalAudit.Core_MDF_Audit_Now__c    != internalAuditOldMap.get(newInternalAudit.Id).Core_MDF_Audit_Now__c){
if(newInternalAudit.Core_MDF_Audit_Now__c){
internalAuditToBeStamped.add(newInternalAudit);
}
}                
}            
// stamp dates 
if(internalAuditToBeStamped!=null && internalAuditToBeStamped.size()>0){            
for(Core_MDF_InternalAudit__c rec : internalAuditToBeStamped){
rec.Audit_Start_Date__c = date.valueOf(system.now());
rec.Audit_End_Date__c = date.valueOf(system.now()).addDays(42);
}
update internalAuditToBeStamped;
}
}catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}   */     
    }
    
    public static void populateCloseDate(List<Core_MDF_InternalAudit__c> newListTobeProcessed, Map<Id,Core_MDF_InternalAudit__c> internalAuditOldMap) {
        List<Core_MDF_InternalAudit__c> internalAuditToBeStamped = new List<Core_MDF_InternalAudit__c>();
        
        for(Core_MDF_InternalAudit__c newInternalAudit : newListTobeProcessed){                
            if(newInternalAudit.Status__c != internalAuditOldMap.get(newInternalAudit.Id).Status__c){
                if(newInternalAudit.Status__c == 'Reviewed_AND_Closed'){
                    internalAuditToBeStamped.add(newInternalAudit);
                }
            }                
        }
        if(internalAuditToBeStamped!=null && internalAuditToBeStamped.size()>0){            
            for(Core_MDF_InternalAudit__c rec : internalAuditToBeStamped){
                rec.Audit_Close_Date__c  = date.valueOf(system.now());
            }
        }
    }
    
    public static void setupAuditorbeforeInsert(List<Core_MDF_InternalAudit__c> newListTobeProcessed) {
        
        Map<Id,List<Id>> accountIdToProgramIdMap = new Map<Id,List<Id>>();
        Map<String,Map<Id,List<Id>>> intAccIdProgIdToMapOfAccIdToUsrShrIdMap = new Map<String,Map<Id,List<Id>>>();
        Map<Id,List<Id>> AccountIdToUserIdMap = new Map<Id,List<Id>>();
        Map<String,Core_MDF_InternalAudit__c> uniqueIdToInternalAuditMap = new Map<String,Core_MDF_InternalAudit__c>();
        
        for(Core_MDF_InternalAudit__c rec : newListTobeProcessed){
            if(accountIdToProgramIdMap.containsKey(rec.Account__c)){
                accountIdToProgramIdMap.get(rec.Account__c).add(rec.Channel_Program__c);
            }
            else{
                accountIdToProgramIdMap.put(rec.Account__c, new List<Id>{rec.Channel_Program__c});
            }
            uniqueIdToInternalAuditMap.put(rec.Account__c+'_'+rec.Channel_Program__c, rec);
        }
        
        for(AccountShare a : [select accountid, account.Core_MDF_CoMarketing_Ultimate_Account__c, account.Core_MDF_Channel_Program__c, UserOrGroupId from accountshare where account.Core_MDF_CoMarketing_Ultimate_Account__c in: accountIdToProgramIdMap.keySet() and UserOrGroupId in (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Core_MDF_CCP_External_User_Admin')]){
            if(accountIdToProgramIdMap.get(a.account.Core_MDF_CoMarketing_Ultimate_Account__c).contains(a.account.Core_MDF_Channel_Program__c)){
                if(intAccIdProgIdToMapOfAccIdToUsrShrIdMap.containsKey(a.account.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+a.account.Core_MDF_Channel_Program__c)){
                    Map<Id,List<Id>> subDetails= intAccIdProgIdToMapOfAccIdToUsrShrIdMap.get(a.account.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+a.account.Core_MDF_Channel_Program__c);
                    
                    if(subDetails.containsKey(a.accountId)){
                        subDetails.get(a.accountId).add(a.UserOrGroupId);
                    }
                    else{
                        subDetails.put(a.accountId, new List<Id>{a.UserOrGroupId});
                    }
                    
                    intAccIdProgIdToMapOfAccIdToUsrShrIdMap.get(a.account.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+a.account.Core_MDF_Channel_Program__c).putAll(subDetails);
                }
                else{
                    Map<Id,List<Id>> subDetails = new Map<Id,List<Id>>();
                    subDetails.put(a.accountId, new List<Id>{a.UserOrGroupId});
                    intAccIdProgIdToMapOfAccIdToUsrShrIdMap.put(a.account.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+a.account.Core_MDF_Channel_Program__c, subDetails);
                }
            }
        }
        
        //List of Internal Audit Share Records with Eligible User Admins
        List<Core_MDF_InternalAudit__Share> internalAuditShareRecords = new List<Core_MDF_InternalAudit__Share>();
        
        for(String interAuditRec : intAccIdProgIdToMapOfAccIdToUsrShrIdMap.keySet()){
            Map<Id,List<Id>> subDetails = intAccIdProgIdToMapOfAccIdToUsrShrIdMap.get(interAuditRec);
            List<Id> userIdList = new List<Id>();
            Integer totalNodes = subDetails.size();
            
            for(Id accId : subDetails.keySet()){
                userIdList.addAll(subDetails.get(accId));
            }
            
            Map<Id,Integer> countMap = new Map<Id,Integer>();
            
            for(Id key : userIdList)
            {
                if(!countMap.containsKey(key)){
                    countMap.put(key,0);
                }
                Integer currentInt = countMap.get(key) + 1;
                countMap.put(key,currentInt);
            }
            
            Integer maxCount = 0;
            Id finalUserId;
            Set<Id> userAdminIds = new Set<Id>();
            
            for(Id userId : countMap.keySet()){
                if(countMap.get(userId) > maxCount){
                    maxCount = countMap.get(userId);
                    finalUserId = userId;
                }
            }
            system.debug('finalUserId::'+finalUserId);
            for(Id userId : countMap.keySet()){
                if(countMap.get(userId) == maxCount){
                    Core_MDF_InternalAudit__Share intAudShare = new Core_MDF_InternalAudit__Share();
                    intAudShare.UserOrGroupId = userId;
                    intAudShare.ParentId = uniqueIdToInternalAuditMap.get(interAuditRec).Id;
                    intAudShare.RowCause = 'Manual';
                    intAudShare.AccessLevel = 'Edit';
                    internalAuditShareRecords.add(intAudShare);
                    userAdminIds.add(userId);
                }
            }
            //sendMailToUserAdmins(userAdminIds,userAdminIds.size(),uniqueIdToInternalAuditMap.get(interAuditRec).Id);//not in before insert
            system.debug('userAdminIds::'+userAdminIds);
            system.debug('internalAuditShareRecords::'+internalAuditShareRecords);
            /*
To share only with eligible user admins and sending notification only to eligible admins, 
use totalNodes = maxCount in if condition.
If want to assign approve only when he/she acknowledges, then comment below if condition.
*/
            //if(finalUserId != null){
            //uniqueIdToInternalAuditMap.get(interAuditRec).Approver__c = finalUserId;
            uniqueIdToInternalAuditMap.get(interAuditRec).Core_MDF_No_of_User_Admin__c = userAdminIds.size();
            system.debug('userAdminIdssizVD'+userAdminIds.size());
            system.debug('uniqueIdToInternalAuditMapCore_MDF_No_of_User_Admin__cVD'+uniqueIdToInternalAuditMap.get(interAuditRec).Core_MDF_No_of_User_Admin__c);
            //}
        }
        // Share internal audit records with user admins
        //database.insert(internalAuditShareRecords);//comment this in before insert
        
        /* For Mass Email
Messaging.MassEmailMessage email = new Messaging.MassEmailMessage(); 
email.setTargetObjectIds(conIds);
email.setTemplateId('00Xi0000000J9hx');
email.setSubject('note');
Messaging.SendEmail(New Messaging.MassEmailMessage[] {email});
*/
    }
    /*public static void changeOwner(List<Core_MDF_InternalAudit__c> newListTobeProcessed){

for(Core_MDF_InternalAudit__c rec : [Select id,]){

}

}*/
    public static void setupAuditor(List<Core_MDF_InternalAudit__c> newListTobeProcessed) {
        
        Map<Id,List<Id>> accountIdToProgramIdMap = new Map<Id,List<Id>>();
        Map<String,Map<Id,List<Id>>> intAccIdProgIdToMapOfAccIdToUsrShrIdMap = new Map<String,Map<Id,List<Id>>>();
        Map<Id,List<Id>> AccountIdToUserIdMap = new Map<Id,List<Id>>();
        Map<String,Core_MDF_InternalAudit__c> uniqueIdToInternalAuditMap = new Map<String,Core_MDF_InternalAudit__c>();
        
        for(Core_MDF_InternalAudit__c rec : newListTobeProcessed){
            if(accountIdToProgramIdMap.containsKey(rec.Account__c)){
                accountIdToProgramIdMap.get(rec.Account__c).add(rec.Channel_Program__c);
            }
            else{
                accountIdToProgramIdMap.put(rec.Account__c, new List<Id>{rec.Channel_Program__c});
            }
            uniqueIdToInternalAuditMap.put(rec.Account__c+'_'+rec.Channel_Program__c, rec);
        }
        
        for(AccountShare a : [select accountid, account.Core_MDF_CoMarketing_Ultimate_Account__c, account.Core_MDF_Channel_Program__c, UserOrGroupId from accountshare where account.Core_MDF_CoMarketing_Ultimate_Account__c in: accountIdToProgramIdMap.keySet() and UserOrGroupId in (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Core_MDF_CCP_External_User_Admin')]){
            if(accountIdToProgramIdMap.get(a.account.Core_MDF_CoMarketing_Ultimate_Account__c).contains(a.account.Core_MDF_Channel_Program__c)){
                if(intAccIdProgIdToMapOfAccIdToUsrShrIdMap.containsKey(a.account.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+a.account.Core_MDF_Channel_Program__c)){
                    Map<Id,List<Id>> subDetails= intAccIdProgIdToMapOfAccIdToUsrShrIdMap.get(a.account.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+a.account.Core_MDF_Channel_Program__c);
                    
                    if(subDetails.containsKey(a.accountId)){
                        subDetails.get(a.accountId).add(a.UserOrGroupId);
                    }
                    else{
                        subDetails.put(a.accountId, new List<Id>{a.UserOrGroupId});
                    }
                    
                    intAccIdProgIdToMapOfAccIdToUsrShrIdMap.get(a.account.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+a.account.Core_MDF_Channel_Program__c).putAll(subDetails);
                }
                else{
                    Map<Id,List<Id>> subDetails = new Map<Id,List<Id>>();
                    subDetails.put(a.accountId, new List<Id>{a.UserOrGroupId});
                    intAccIdProgIdToMapOfAccIdToUsrShrIdMap.put(a.account.Core_MDF_CoMarketing_Ultimate_Account__c+'_'+a.account.Core_MDF_Channel_Program__c, subDetails);
                }
            }
        }
        
        //List of Internal Audit Share Records with Eligible User Admins
        List<Core_MDF_InternalAudit__Share> internalAuditShareRecords = new List<Core_MDF_InternalAudit__Share>();
        
        for(String interAuditRec : intAccIdProgIdToMapOfAccIdToUsrShrIdMap.keySet()){
            Map<Id,List<Id>> subDetails = intAccIdProgIdToMapOfAccIdToUsrShrIdMap.get(interAuditRec);
            List<Id> userIdList = new List<Id>();
            Integer totalNodes = subDetails.size();
            
            for(Id accId : subDetails.keySet()){
                userIdList.addAll(subDetails.get(accId));
            }
            
            Map<Id,Integer> countMap = new Map<Id,Integer>();
            
            for(Id key : userIdList)
            {
                if(!countMap.containsKey(key)){
                    countMap.put(key,0);
                }
                Integer currentInt = countMap.get(key) + 1;
                countMap.put(key,currentInt);
            }
            
            Integer maxCount = 0;
            Id finalUserId;
            Set<Id> userAdminIds = new Set<Id>();
            
            for(Id userId : countMap.keySet()){
                if(countMap.get(userId) > maxCount){
                    maxCount = countMap.get(userId);
                    finalUserId = userId;
                }
            }
            system.debug('finalUserId::'+finalUserId);
            for(Id userId : countMap.keySet()){
                if(countMap.get(userId) == maxCount){
                    Core_MDF_InternalAudit__Share intAudShare = new Core_MDF_InternalAudit__Share();
                    intAudShare.UserOrGroupId = userId;
                    intAudShare.ParentId = uniqueIdToInternalAuditMap.get(interAuditRec).Id;
                    intAudShare.RowCause = 'Manual';
                    intAudShare.AccessLevel = 'Edit';
                    internalAuditShareRecords.add(intAudShare);
                    userAdminIds.add(userId);
                }
            }
            system.debug('userAdminIdsVD'+userAdminIds);
            system.debug('userAdminIds34VD'+uniqueIdToInternalAuditMap.get(interAuditRec).Id);
            //sendMailToUserAdmins(userAdminIds,uniqueIdToInternalAuditMap.get(interAuditRec).Id);
            system.debug('userAdminIds::'+userAdminIds);
            system.debug('internalAuditShareRecords::'+internalAuditShareRecords);
            /*
To share only with eligible user admins and sending notification only to eligible admins, 
use totalNodes = maxCount in if condition.
If want to assign approve only when he/she acknowledges, then comment below if condition.
*/
            /*if(finalUserId != null){
uniqueIdToInternalAuditMap.get(interAuditRec).Approver__c = finalUserId;
}*/
        }
        // Share internal audit records with user admins
        database.insert(internalAuditShareRecords);//comment this in before insert
        
        /* For Mass Email
Messaging.MassEmailMessage email = new Messaging.MassEmailMessage(); 
email.setTargetObjectIds(conIds);
email.setTemplateId('00Xi0000000J9hx');
email.setSubject('note');
Messaging.SendEmail(New Messaging.MassEmailMessage[] {email});
*/
    }
    
    public static void sendMailToUserAdmins(Set<Id> userAdminIdSet,Id internalAuditRecord) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();           
        
        List<Id> userAdminIdList = new List<Id>();
        userAdminIdList.addAll(userAdminIdSet);
        system.debug('VuserAdminIdList'+userAdminIdList);
        Id templateId = [SELECT Id, DeveloperName FROM EmailTemplate where DeveloperName ='Test_V'].Id;
        system.debug('VtemplateId'+templateId);
        String recordId = String.valueOf(internalAuditRecord).substring(0, 15);
        system.debug('VrecordId'+recordId);
        for (integer i=0; i<userAdminIdList.size(); i++) {
            system.debug('HiIMaHere');
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(userAdminIdList[i]);
            email.setWhatId(recordId);
            email.setTemplateId(templateId);
            email.setSaveAsActivity(false);
            email.setOrgWideEmailAddressId('0D21J0000008U6X');
            emailsToSend.add(email);
            
        }
        system.debug('emailsToSend'+emailsToSend);
        Messaging.sendEmail(emailsToSend);
        
    }
    
    /*public static void sendMail(Set<Id> userAdminIdSet,Id internalAuditRecord) {

}*/
    public static Void createNewRecord(List<Core_MDF_InternalAudit__c> newListTobeProcessed,Map<Id,Core_MDF_InternalAudit__c> internalAuditMap){
        List<Core_MDF_InternalAudit__c> intenalAuditListRec = new List<Core_MDF_InternalAudit__c>();
        system.debug('In Create New Recor Method');
        
        for(Core_MDF_InternalAudit__c newInternalAudit :newListTobeProcessed){
            system.debug('newInternalAudit'+newInternalAudit+'%%'+newInternalAudit.Status__c+'%%'+internalAuditMap.get(newInternalAudit.Id).Status__c);
            if((newInternalAudit.Status__c!=internalAuditMap.get(newInternalAudit.Id).Status__c) && newInternalAudit.Status__c=='Reviewed_AND_Closed'){
                Core_MDF_InternalAudit__c newInternalAuditRecord = new Core_MDF_InternalAudit__c();
                newInternalAuditRecord.Account__c=newInternalAudit.Account__c;
                newInternalAuditRecord.Channel_Program__c = newInternalAudit.Channel_Program__c;
                //newInternalAuditRecord.Name=newInternalAudit.Name;
                newInternalAuditRecord.Audit_Start_Date__c=newInternalAudit.Audit_Start_Date__c.addDays(365);
                newInternalAuditRecord.Audit_End_Date__c=newInternalAudit.Audit_End_Date__c.addDays(365);
                newInternalAuditRecord.OwnerId=newInternalAudit.OwnerId;
                intenalAuditListRec.add(newInternalAuditRecord); 
                system.debug('intenalAuditListRec'+intenalAuditListRec);
                
            }
        }
        database.insert(intenalAuditListRec);        
    }
    
    // Invocable method from flow to get all pnums associated to incoming accounts
    @InvocableMethod(label='Get all Pnums' description='Returns pnums with incoming accounts')
    public static List<List<Core_MDF_Partner_Node_User_Mapping__c>> passAllPnums(List<List<Account>> accList) {
        system.debug('accList::'+accList);
        system.debug('accList.size()::'+accList.size());
        Set<ID> accId = new Set<Id>();
        for(List<Account> recList : accList){
            for(account rec : recList){
                accId.add(rec.Id);
            }
        }
        List<List<Core_MDF_Partner_Node_User_Mapping__c>> pnumListOfList = new List<List<Core_MDF_Partner_Node_User_Mapping__c>>();
        List <Core_MDF_Partner_Node_User_Mapping__c> accUserList = [select Id, Core_MDF_Account__c, Core_MDF_User__c from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_Account__c IN : accId AND Core_MDF_User__r.Contact.Core_Audience_List__c INCLUDES ('CCF User Administrator', 'DCF User Administrator', 'Retail User Administrator', 'SPCF User Administrator', 'CCF Boost User Administrator')];
        Map<Id,List<Core_MDF_Partner_Node_User_Mapping__c>> accIdToAccUserMap = new Map<Id,List<Core_MDF_Partner_Node_User_Mapping__c>>();
        for(Core_MDF_Partner_Node_User_Mapping__c rec : accUserList){
            if(accIdToAccUserMap.containsKey(rec.Core_MDF_Account__c)){
                accIdToAccUserMap.get(rec.Core_MDF_Account__c).add(rec);
            }else{
                accIdToAccUserMap.put(rec.Core_MDF_Account__c, new List<Core_MDF_Partner_Node_User_Mapping__c>{rec});
            }
        }
        system.debug('accIdToAccUserMap::'+accIdToAccUserMap);
        for(List<Account> recList : accList){
            List <Core_MDF_Partner_Node_User_Mapping__c> accUserTempList = new List <Core_MDF_Partner_Node_User_Mapping__c>();
            for(account rec : recList){
                if(accIdToAccUserMap.containsKey(rec.Id)){
                    system.debug('accIdToAccUserMap.get(rec.Id)::'+accIdToAccUserMap.get(rec.Id));
                    accUserTempList.addAll(accIdToAccUserMap.get(rec.Id));
                    //pnumListOfList[count].addAll(accIdToAccUserMap.get(rec.Id));
                }
            }
            pnumListOfList.add(accUserTempList);
        }
        return pnumListOfList;
    }
}