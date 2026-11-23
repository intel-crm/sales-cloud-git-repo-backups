public without sharing class Account360_SharingUtility {
    
    public static String readAccessLevel = '';
    
    public static List<sObject> createShareRecordList(List<RecordManualShareClass> recordManualSharelst){
        Map<String,Schema.SObjectType> acc360ObjMap = new Map<String,Schema.SObjectType>();
        List<String> objectsForAccount360Sharing = System.Label.Objects_for_Account360_sharing.split(',');
        for(String acc360Obj : objectsForAccount360Sharing){
            String acc360Objshare = acc360Obj.removeEndIgnoreCase(Label.Core_MDF_c_Label) + Label.Core_MDF_Share_Label;
            Schema.SObjectType objToken = Schema.getGlobalDescribe().get(acc360Objshare);
            acc360ObjMap.put(acc360Obj, objToken);
        }
        List<sObject> dynObjectList = new List<sObject>();
        Boolean hasUserId = false;
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
        try{
            for( RecordManualShareClass recordManualShare : recordManualSharelst){
                if(recordManualShare != NULL){
                    Schema.SObjectType objToken = acc360ObjMap.get(recordManualShare.typeName);
                    if(objToken != NULL)
                    {
                        List<Id> objectIdList = new List<Id>();
                        objectIdList.addAll(recordManualShare.objectIdUserGroupIdListMap.keySet());
                        for(Id objectId : recordManualShare.objectIdUserGroupIdListMap.keySet())
                        {
                            //Then, fetch all the User Ids with which the object record needs to be shared with.
                            for(String userGroupId : recordManualShare.objectIdUserGroupIdListMap.get(objectId))
                            {
                                //Dynamically instantiate the Object Share record.
                                sObject dynObject = objToken.newSObject();
                                if (dynObject != NULL && userGroupId != NULL &&
                                    recordManualShare.OwnerId != userGroupId)
                                {
                                    dynObject.put(Label.Core_MDF_ParentId_Label, objectId); //ParentId
                                    if(String.isNotBlank(recordManualShare.accessLevelStr)){
                                        dynObject.put(Label.Core_MDF_AccessLevel_Label, recordManualShare.accessLevelStr);
                                    }
                                    dynObject.put(Label.Core_MDF_UserOrGroupId_Label, userGroupId); //Add the UserOrGroupId field
                                    dynObject.put('RowCause', recordManualShare.rowCauseStr); //Add the RowCause field
                                    dynObjectList.add(dynObject); //Add it to the List
                                }
                            }
                        }                                
                    }
                }
            }
            if(dynObjectList.size() > 0)
            {
                List<Database.SaveResult> saveResultList = Database.insert(dynObjectList); //insert the record
                if(saveResultList != NULL){
                    return dynObjectList; //return the list of Share records
                }
            }
        }catch(Exception e){  
            logEntries.add(new Core_Log_Entry__c(Core_Message__c ='Error',Core_Details__c = e.getMessage(), Core_Origin__c='Account360_SharingUtility.createShareRecordList', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
            if(!logEntries.isEmpty() && !logSwitch.isEmpty()){
                if(logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c){ 
                    insert logEntries;
                }
            }
        }
        return dynObjectList;
        
    }
    
    
    public class RecordManualShareClass{
        String typeName;
        Map<Id,List<Id>> objectIdUserGroupIdListMap = new Map<Id,List<Id>>();
        String accessLevelStr;
        String rowCauseStr;
        Id ownerId;
        public RecordManualShareClass(String typeNameStr, Map<Id,List<Id>> UserIdListMap, String aLevelStr, Id ownerId){
            this.typeName = typeNameStr;
            this.objectIdUserGroupIdListMap = UserIdListMap;
            this.accessLevelStr = aLevelStr;
            this.rowCauseStr = 'Manual';
            this.ownerId = ownerId;
        }
    }
    
    public static void account360_Apex_Sharing(Map<Id,List<sObject>> acctRecordListMap)
    {
        Map<Id,List<Id>> acctIdUserIdListMap = new Map<Id,List<Id>>();
        Set<Id> acctToGetOwnerIds = new Set<Id>();
        List<RecordManualShareClass> recordShareList = new List<RecordManualShareClass>();
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
        try{
            for(AccountTeamMember atm : [Select UserId, User.Name, AccountId, Account.OwnerId from AccountTeamMember where AccountId IN :acctRecordListMap.keySet() and User.IsActive = true])
            {
                if(acctIdUserIdListMap.containsKey(atm.AccountId)){
                    acctIdUserIdListMap.get(atm.AccountId).add(atm.UserId);
                }else{
                    acctIdUserIdListMap.put(atm.AccountId, new List<Id>{atm.UserId,atm.Account.OwnerId});
                }
            }
            for(Id acctId : acctRecordListMap.keySet())
            {
                if(!acctIdUserIdListMap.keySet().contains(acctId))
                {
                    acctToGetOwnerIds.add(acctId);
                }
            }
            if(acctToGetOwnerIds.size() > 0)
            {
                for(Account acct : [Select Id, OwnerId from Account where Id IN :acctToGetOwnerIds])
                {
                    acctIdUserIdListMap.put(acct.Id,new List<Id>{acct.OwnerId});
                }
            }
            if(acctIdUserIdListMap.size()>0 && acctRecordListMap.values().size()>0)
            {
                for(Id acc : acctRecordListMap.keySet())
                {
                    for(sObject rec : acctRecordListMap.get(acc))
                    {
                        Map<Id,List<Id>> userIdListMap = new Map<Id,List<Id>>();
                        userIdListMap.put(rec.Id, acctIdUserIdListMap.get(acc));
                        String objName = rec.Id.getSObjectType().getDescribe().getName();
                        RecordManualShareClass recordManualShare = new RecordManualShareClass(objName,userIdListMap,'Edit', (Id)rec.get('OwnerId')); 
                        recordShareList.add(recordManualShare);
                    }
                }
                createShareRecordList(recordShareList);
            }
        }catch(Exception e){ 
            logEntries.add(new Core_Log_Entry__c(Core_Message__c ='Error',Core_Details__c = e.getMessage(), Core_Origin__c='Account360_SharingUtility.account360_Apex_Sharing', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
            if(!logEntries.isEmpty() && !logSwitch.isEmpty()){
                if(logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c){ 
                    insert logEntries;
                }
            }
        }
    }
    
    
    @InvocableMethod
    public static void invokeAccount360Sharing(List<AccountTeamMember> accTeamMember)
    {
        Map<Id,List<Id>> acctIdUserIdListMap = new Map<Id,List<Id>>();
        if(accTeamMember != null && accTeamMember.size() > 0)
        {
            for(AccountTeamMember rec : accTeamMember)
            {
                if(acctIdUserIdListMap.containsKey(rec.AccountId)){
                    acctIdUserIdListMap.get(rec.AccountId).add(rec.UserId);
                }else{
                    acctIdUserIdListMap.put(rec.AccountId, new List<Id>{rec.UserId});
                } 
                
            }
        	performAccount360Sharing(acctIdUserIdListMap);
        }
    }
    
    public static void performAccount360Sharing(Map<Id,List<Id>> acctIdUserIdListMap)
    {
        List<String> objectsForAccount360Sharing = System.Label.Objects_for_Account360_sharing.split(',');
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
        List<RecordManualShareClass> recordShareList = new List<RecordManualShareClass>();
        try{
            if(objectsForAccount360Sharing.contains('Account_Plan__c'))
            {
                for(Account_Plan__c rec : [Select ID, Account__c,OwnerId from Account_Plan__c where Account__c IN : acctIdUserIdListMap.keySet()])
                {
                    Map<Id,List<Id>> userIdListMap = new Map<Id,List<Id>>();
                    userIdListMap.put(rec.Id, acctIdUserIdListMap.get(rec.Account__c));
                    String objName = rec.Id.getSObjectType().getDescribe().getName();
                    RecordManualShareClass recordManualShare = new RecordManualShareClass(objName,userIdListMap,'Edit', rec.OwnerId); 
                    recordShareList.add(recordManualShare);
                }
            }
            if(objectsForAccount360Sharing.contains('Executive_Meeting_Brief__c'))
            {
                for(Executive_Meeting_Brief__c rec : [Select ID, Account__c,OwnerId from Executive_Meeting_Brief__c where Account__c IN : acctIdUserIdListMap.keySet()])
                {
                    Map<Id,List<Id>> userIdListMap = new Map<Id,List<Id>>();
                    userIdListMap.put(rec.Id, acctIdUserIdListMap.get(rec.Account__c));
                    String objName = rec.Id.getSObjectType().getDescribe().getName();
                    RecordManualShareClass recordManualShare = new RecordManualShareClass(objName,userIdListMap,'Edit',rec.OwnerId); 
                    recordShareList.add(recordManualShare);
                }
            }
            if(objectsForAccount360Sharing.contains('Account_Status__c'))
            {
                for(Account_Status__c rec : [Select ID, Account__c,OwnerId from Account_Status__c where Account__c IN : acctIdUserIdListMap.keySet()])
                {
                    Map<Id,List<Id>> userIdListMap = new Map<Id,List<Id>>();
                    userIdListMap.put(rec.Id, acctIdUserIdListMap.get(rec.Account__c));
                    String objName = rec.Id.getSObjectType().getDescribe().getName();
                    RecordManualShareClass recordManualShare = new RecordManualShareClass(objName,userIdListMap,'Edit',rec.OwnerId); 
                    recordShareList.add(recordManualShare);
                }
            }
            if(objectsForAccount360Sharing.contains('Account_Revenue__c'))
            {
                for(Account_Revenue__c rec : [Select ID,Account__c,OwnerId from Account_Revenue__c where Account__c IN : acctIdUserIdListMap.keySet()])
                {
                    Map<Id,List<Id>> userIdListMap = new Map<Id,List<Id>>();
                    userIdListMap.put(rec.Id, acctIdUserIdListMap.get(rec.Account__c));
                    String objName = rec.Id.getSObjectType().getDescribe().getName();
                    RecordManualShareClass recordManualShare = new RecordManualShareClass(objName,userIdListMap,'Edit',rec.OwnerId); 
                    recordShareList.add(recordManualShare);
                }
            }
            //TWC4767-4408 CRM: Sharing and security model for New Standard Account Plans
            if(objectsForAccount360Sharing.contains('AccountPlan'))
            {
                for(AccountPlan rec : [Select ID,AccountId,OwnerId from AccountPlan where AccountId IN : acctIdUserIdListMap.keySet()])
                {
                    Map<Id,List<Id>> userIdListMap = new Map<Id,List<Id>>();
                    userIdListMap.put(rec.Id, acctIdUserIdListMap.get(rec.AccountId));
                    String objName = rec.Id.getSObjectType().getDescribe().getName();
                    RecordManualShareClass recordManualShare = new RecordManualShareClass(objName,userIdListMap,'Edit',rec.OwnerId); 
                    recordShareList.add(recordManualShare);
                }
            }
            createShareRecordList(recordShareList);
        }
        catch(Exception e){   
            logEntries.add(new Core_Log_Entry__c(Core_Message__c ='Error',Core_Details__c = e.getMessage(), Core_Origin__c='Account360_SharingUtility.invokeAccount360Sharing', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
            if(!logEntries.isEmpty() && !logSwitch.isEmpty()){
                if(logSwitch.get('Core_LogEntry_Check') != null && logSwitch.get('Core_LogEntry_Check').Is_Selected__c){ 
                    insert logEntries;
                }
            }
        }
    }

}