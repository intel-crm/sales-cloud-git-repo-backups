/*********************************************************************************************************************
Modification Log : 
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
*Tanya Rajesh           01/01/2023                  TriggerHandler for ACM Object
*                                                 
*********************************************************************************************************************/
public with sharing class PRM_ACMTriggerHandlerNew extends TriggerHandler{
    public static List<String> configPartnerRoles = Label.PRM_AGSIdentityCreation_PartnerRoles.split(',');
    //public static ChannelProgram cp = [Select Id, Name From ChannelProgram Where Name =:System.Label.PRM_Intel_Partner_Alliance LIMIT 1];
    public static  boolean firstRunAfterInsert = true;
    public static  boolean firstRunBeforeInsert = true;
    public static  boolean firstRunBeforeUpdate = true;
    public static  boolean firstRunAfterUpdate = true;
    public static  boolean isOpidrecommendationexecuted = true;
    public static boolean ACMUtilityfirstRun = true;
    public static boolean secondRun = true;
    public static boolean firstRun = true;
    public static boolean iPAFirstRun = true;
    public static boolean mPFirstRun = true;
    public static Set<Id> badgeTierUpdatedAccounts = new Set<Id>();
    public static boolean rtaRun = false;
    @TestVisible static Boolean executeTrigger = true;
    public static final String LOG_ENTRY_ORIGIN   = 'PRM_ACMTriggerHandlerNew';
    public static final String LOG_ENTRY_PROJECT  = 'IPA Registrations';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_ACMTriggerHandlerNew';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    //public static boolean ipaRefresh = Boolean.valueOf(label.prm_iparefresh);
    public static Id intelAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    public static String logEntryMsgString;
    public override void beforeInsert(){
        try{
            if(executeTrigger && isActive('Account_Channel_Membership_Switch') && firstRunBeforeInsert && Trigger.isInsert){     
                logEntryMsgString+='\nEntered beforeInsert of PRM_ACMTriggerHandlerNew, Trigger.new: '+Trigger.new;                  
                        List<PRM_AccountChannelMembership__c> acmNewList = new List<PRM_AccountChannelMembership__c>();
                        List<PRM_AccountChannelMembership__c> acmOldList = new List<PRM_AccountChannelMembership__c>();
                        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
                        Map<id, PRM_AccountChannelMembership__c> acmOldMap = new Map<id, PRM_AccountChannelMembership__c>();
                        Map<id, PRM_AccountChannelMembership__c> acmRecMapTriggerRecs = new Map<id, PRM_AccountChannelMembership__c>();
                        List<PRM_AccountChannelMembership__c> acmListUpsertOPIDACM = new List<PRM_AccountChannelMembership__c>();
                        Map<Id,Id> childParentMap = new Map<Id,Id>();
                        Set<Id> acmAccId = new Set<Id>();
                        Set<String> acmPartnerRole = new Set<String>();
                        List<Account> accList = new List<Account>();
                        Set<Id> parentACMAccId = new Set<Id>();
                        set<string> allACMAccid=new set<string>();
                        
                        List<String> uniqstr = new List<String>();
                        List<Id> idslist = new List<Id>();
                        
                        //Trigger.New and Trigger.Old putting in lists and maps
                        acmOldList = Trigger.old;
                        acmNewList = Trigger.new;
                        acmOldMap = (Map<id, PRM_AccountChannelMembership__c>)Trigger.oldMap;
                        /*if(!acmOldList.isEmpty() && acmOldList != null){
    for(PRM_AccountChannelMembership__c acmRecOld : acmOldList){
    acmOldMap.put(acmRecOld.id, acmRecOld); 
    }
    }*/
                        
                        if(!acmNewList.isEmpty()){
                            for(PRM_AccountChannelMembership__c acmRecNew : acmNewList){
                                if(acmOldMap == null || acmOldMap.get(acmRecNew.id) == null || 
                                (acmOldMap.containsKey(acmRecNew.id) && acmRecNew.PRM_Status_Nm__c != acmOldMap.get(acmRecNew.id).PRM_Status_Nm__c) || 
                                (acmOldMap.containsKey(acmRecNew.id) && acmRecNew.PRM_Status_Nm__c != acmOldMap.get(acmRecNew.id).PRM_Status_Nm__c))
                                {
                                    acmRecNew.PRM_Status_Change_Dt__c = System.now();
                                }  // Updation of statusChangeDateTime
                                PRM_AccountChannelMembership__c acmOld ; 
                                if(acmOldMap!=null && !acmOldMap.isEmpty()) {
                                    acmOld = (PRM_AccountChannelMembership__c) acmOldMap.get(acmRecNew.id) ;
                                }
                                //Precondition of Upsert OPID ACM ---- Start
                                if(((acmOld == null) || (acmOld != null && acmOld.PRM_Status_Nm__c != acmRecNew.PRM_Status_Nm__c)) 
                                && (acmRecNew.PRM_Status_Nm__c == System.Label.PRM_Status)
                                ){
                                    acmAccId.add(acmRecNew.PRM_Account_Id__c);
                                    acmRecMapTriggerRecs.put(acmRecNew.id, acmRecNew);
                                    acmPartnerRole.add(acmRecNew.PRM_Partner_Role__c);
                                }
                            }
                        }
                        
                        if(acmAccId!=null && !acmAccId.IsEmpty()){
                            for(Account acc:[SELECT id,
                                            Core_IPA_Partner_Segment__c, 
                                            Core_IPA_One_Partner_Id__c
                                            FROM account 
                                            WHERE id in :acmAccId]
                            ){
                                accList.add(acc);
                            }
                        }
                        if(acmAccId!=null && !acmAccId.IsEmpty()){ // Fetching parent account id.
                            for(Core_Account_Group_Member__c agm :[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Intel_Account_Id__c IN :acmAccId AND Core_Inactive_Ind__c = false]){ 
                                parentACMAccId.add(agm.Core_Partner_Account_Id__c);
                                childParentMap.put(agm.Core_Intel_Account_Id__c,agm.Core_Partner_Account_Id__c);
                            }
                        }
                        if(!parentACMAccId.IsEmpty()){
                            for(Core_Account_Group_Member__c cag :[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Partner_Account_Id__c IN :parentACMAccId AND Core_Inactive_Ind__c = false]){ 
                                childParentMap.put(cag.Core_Intel_Account_Id__c,cag.Core_Partner_Account_Id__c);
                                allACMAccid.add(cag.Core_Intel_Account_Id__c);
                            }
                        }
                        
                        //Precondition of Upsert OPID ACM ---- End
                        
                        
                        //Precondition for Duplicate Record Check ---- Start
                        if(acmNewList != null && !acmNewList.IsEmpty()){
                            for(PRM_AccountChannelMembership__c acm: acmNewList){
                                uniqstr.add(acm.PRM_Account_Channel_Program_Key__c);
                                idsList.add(acm.id);
                            }
                        }
                        //Precondition for Duplicate Record Check ---- End
                        
                        //All Common Queries ---- Start
                        if((uniqstr != null && !uniqstr.isEmpty())  
                        || (allACMAccid.isEmpty() || !parentACMAccId.isEmpty())
                        ){
                            for(PRM_AccountChannelMembership__c acmRec : [SELECT Id,
                                                                            Name,
                                                                            PRM_Partner_Role__c, 
                                                                            PRM_Account_Id__c,
                                                                            PRM_Account_Id__r.Core_IPA_Partner_Segment__c, 
                                                                            PRM_Account_Id__r.Name,
                                                                            PRM_Channel_Program_Id__c,
                                                                            PRM_Channel_Program_Level_Id__r.Name,
                                                                            PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c,
                                                                            PRM_Account_Channel_Program_Key__c 
                                                                            FROM PRM_AccountChannelMembership__c 
                                                                            WHERE PRM_Account_Channel_Program_Key__c IN: uniqstr
                                                                            OR((PRM_Account_Id__c IN :allACMAccid OR PRM_Account_Id__c IN:parentACMAccId)  
                                                                            AND (PRM_Partner_Role__c IN :acmPartnerRole))])
                            {
                                if(uniqstr.contains(acmRec.PRM_Account_Channel_Program_Key__c)){
                                    acmList.add(acmRec);
                                }
                                if((allACMAccid.contains(acmRec.PRM_Account_Id__c) || parentACMAccId.contains(acmRec.PRM_Account_Id__c))
                                    && (acmPartnerRole.contains(acmRec.PRM_Partner_Role__c))
                                    ){
                                        acmListUpsertOPIDACM.add(acmRec);
                                    }
                            } 
                        }
                        //All Common Queries ---- End
                        
                        firstRunBeforeInsert = false;                    
                        duplicateRecordCheck(acmNewList, acmOldList, acmList);
                        UpsertOPIDACM(acmNewList, acmOldMap, acmListUpsertOPIDACM, acmRecMapTriggerRecs, childParentMap,parentACMAccId);           
            }
        }catch(Exception ex){
            logEntryMsgString='\n errors:'+ex;
        }finally{
            createLogEntry(logEntryMsgString);
        }
    }
    public override void beforeUpdate() {
        try{
        if(isActive('Account_Channel_Membership_Switch_Update') && firstRunBeforeUpdate){//Retrieved from Custom labels            
            if(Trigger.isUpdate){
                logEntryMsgString+='\n Entered before Update of PRM_ACMTriggerHandlerNew, Trigger.new: '+Trigger.new;
                List<PRM_AccountChannelMembership__c> acmNewList = new List<PRM_AccountChannelMembership__c>();
                List<PRM_AccountChannelMembership__c> acmOldList = new List<PRM_AccountChannelMembership__c>();
                List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
                Map<id, PRM_AccountChannelMembership__c> acmOldMap = new Map<id, PRM_AccountChannelMembership__c>();
                List<PRM_AccountChannelMembership__c> acmListUpsertOPIDACM = new List<PRM_AccountChannelMembership__c>();
                Map<id, PRM_AccountChannelMembership__c> acmRecMapTriggerRecs = new Map<id, PRM_AccountChannelMembership__c>();
                Map<Id,Id> childParentMap = new Map<Id,Id>();
                Set<Id> acmAccId = new Set<Id>();
                Set<Id> parentACMAccId = new Set<Id>();
                
                
                Set<String> acmPartnerRole = new Set<String>();
                List<Account> accList = new List<Account>();
                
                List<String> uniqstr = new List<String>();
                List<Id> idslist = new List<Id>();
                Set<Id>acmAccountIdSet = new Set<Id>();//set for suppress email
                acmOldList = Trigger.old;
                acmNewList = Trigger.new;
                acmOldMap = (Map<id, PRM_AccountChannelMembership__c>)Trigger.oldMap;
                
                //Trigger.New and Trigger.Old putting in lists and maps
                /*if(!acmOldList.isEmpty()){
for(PRM_AccountChannelMembership__c acmRecOld : acmOldList){
acmOldMap.put(acmRecOld.id, acmRecOld); 
}
}*/
                
                if(!acmNewList.isEmpty()){
                    for(PRM_AccountChannelMembership__c acmRecNew : acmNewList){
                        if(acmOldMap == null || acmOldMap.get(acmRecNew.id) == null || 
                           (acmOldMap.containsKey(acmRecNew.id) && acmRecNew.PRM_Status_Nm__c != acmOldMap.get(acmRecNew.id).PRM_Status_Nm__c) || 
                           (acmOldMap.containsKey(acmRecNew.id) && acmRecNew.PRM_Status_Nm__c != acmOldMap.get(acmRecNew.id).PRM_Status_Nm__c))
                        {
                            acmRecNew.PRM_Status_Change_Dt__c = System.now();
                        }  // Updation of statusChangeDateTime
                        
                        if(acmRecNew.PRM_Suppress_Email__c == true){
                            acmAccountIdSet.add(acmRecNew.PRM_Account_Id__c);
                        }
                        //Updating Suppress Email
                        PRM_AccountChannelMembership__c acmOld ; 
                        if(acmOldMap!=null && !acmOldMap.isEmpty()) {
                            acmOld = (PRM_AccountChannelMembership__c) acmOldMap.get(acmRecNew.id) ;
                        }
                        if(acmOld != null && (acmOld.PRM_Status_Nm__c == 'Approved' 
                                              &&(acmRecNew.PRM_Status_Nm__c == 'Pending'||acmRecNew.PRM_Status_Nm__c == 'Inactive')) 
                           && acmOld.PRM_Suppress_Email__c==true
                          ){
                              acmRecNew.PRM_Suppress_Email__c =false;
                          }
                        
                        //Precondition of Upsert OPID ACM ---- Start
                        if(((acmOld == null) || (acmOld != null && acmOld.PRM_Status_Nm__c != acmRecNew.PRM_Status_Nm__c)) 
                           && (acmRecNew.PRM_Status_Nm__c == System.Label.PRM_Status)
                          ){
                              acmRecMapTriggerRecs.put(acmRecNew.id, acmRecNew);
                              acmAccId.add(acmRecNew.PRM_Account_Id__c);
                              acmPartnerRole.add(acmRecNew.PRM_Partner_Role__c);
                          }
                    }
                }
                
                if(acmAccId!=null && !acmAccId.IsEmpty()){
                    for(Account acc:[SELECT id,
                                     Core_IPA_Partner_Segment__c, 
                                     Core_IPA_One_Partner_Id__c 
                                     FROM account 
                                     WHERE id in :acmAccId]
                       ){
                           accList.add(acc);                           
                       }
                }
                if(acmAccId!=null && !acmAccId.IsEmpty()){ // Fetching parent account id.
                    for(Core_Account_Group_Member__c agm :[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Intel_Account_Id__c IN :acmAccId AND Core_Inactive_Ind__c = false]){ 
                        parentACMAccId.add(agm.Core_Partner_Account_Id__c);
                        childParentMap.put(agm.Core_Intel_Account_Id__c,agm.Core_Partner_Account_Id__c);
                    }
                }
                Set<string> allACMAccid=new Set<string>();
                Set<Id>intelAccountIds = new Set<Id>();//for suppress email
                if(!parentACMAccId.IsEmpty() && parentACMAccId.size()>0){
                    for(Core_Account_Group_Member__c cag :
                        [SELECT Id,
                         Name,
                         Core_Partner_Account_Id__c, 
                         Core_Intel_Account_Id__c,
                         Core_Inactive_Ind__c 
                         FROM Core_Account_Group_Member__c
                         WHERE (Core_Partner_Account_Id__c IN :parentACMAccId AND Core_Inactive_Ind__c = false)
                         OR (Core_Partner_Account_Id__c IN :acmAccountIdSet)
                        ]){
                            allACMAccid.add(cag.Core_Intel_Account_Id__c);
                            childParentMap.put(cag.Core_Intel_Account_Id__c,cag.Core_Partner_Account_Id__c);
                            if(acmAccountIdSet.size()>0 && !acmAccountIdSet.isEmpty()){
                                intelAccountIds.add(cag.Core_Intel_Account_Id__c); //For Suppress Email Method
                            } 
                        }
                }
                
                //Precondition of Upsert OPID ACM ---- End
                
                
                //Precondition for Duplicate Record Check ---- Start
                if(acmNewList != null && !acmNewList.IsEmpty()){
                    for(PRM_AccountChannelMembership__c acm: acmNewList){
                        uniqstr.add(acm.PRM_Account_Channel_Program_Key__c);
                        idsList.add(acm.id);
                    }
                }
                //Precondition for Duplicate Record Check ---- End
                
                //All Common Queries ---- Start
                if(uniqstr != null && !uniqstr.isEmpty()){
                    For(PRM_AccountChannelMembership__c acmRec : [SELECT Id,
                                                                  Name,
                                                                  PRM_Partner_Role__c, 
                                                                  PRM_Account_Id__c,
                                                                  PRM_Account_Id__r.Core_IPA_Partner_Segment__c, 
                                                                  PRM_Account_Id__r.Name,
                                                                  PRM_Channel_Program_Id__c,
                                                                  PRM_Channel_Program_Level_Id__r.Name,
                                                                  PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c,
                                                                  PRM_Account_Channel_Program_Key__c 
                                                                  FROM PRM_AccountChannelMembership__c 
                                                                  WHERE PRM_Account_Channel_Program_Key__c IN: uniqstr
                                                                  OR(
                                                                      (PRM_Account_Id__c IN :allACMAccid OR PRM_Account_Id__c IN:parentACMAccId)  
                                                                      AND (PRM_Partner_Role__c IN :acmPartnerRole)
                                                                  )
                                                                 ]){
                                                                     if(uniqstr.contains(acmRec.PRM_Account_Channel_Program_Key__c)){
                                                                         acmList.add(acmRec);
                                                                     }
                                                                     if((allACMAccid.contains(acmRec.PRM_Account_Id__c) || parentACMAccId.contains(acmRec.PRM_Account_Id__c)) 
                                                                        && (acmPartnerRole.contains(acmRec.PRM_Partner_Role__c))
                                                                       ){
                                                                           acmListUpsertOPIDACM.add(acmRec);
                                                                       }
                                                                 } 
                }
                //All Common Queries ---- End 
                
                firstRunBeforeUpdate = false; 
                suppressEmail(acmNewList, intelAccountIds);
                duplicateRecordCheck(acmNewList, acmOldList, acmList);
                UpsertOPIDACM(acmNewList, acmOldMap, acmListUpsertOPIDACM, acmRecMapTriggerRecs, childParentMap,parentACMAccId); 

            }
        }
    }catch(Exception ex){
        logEntryMsgString+='\nErros: '+ex.getMessage();
    }finally{
        createLogEntry(logEntryMsgString);
    }
        
    }
    public override void afterInsert() {
        if(executeTrigger){   
            afterUpdateAndInsert(Trigger.new,(Map<Id,PRM_AccountChannelMembership__c>) Trigger.oldMap);      
        }
    }
    
    public override void afterUpdate() {
        afterUpdateAndInsert(Trigger.new,(Map<Id,PRM_AccountChannelMembership__c>) Trigger.oldMap);      
    }
    
    /* **********************************************************************************************************************************************
METHODS
************************************************************************************************************************************************* */
    
    public static void afterUpdateAndInsert(List<PRM_AccountChannelMembership__c> acmNewList, Map<Id,PRM_AccountChannelMembership__c> acmOldMap){
        logEntryMsgString+='\n Entered afterUpdateAndInsert of PRM_ACMTriggerHandlerNew, Trigger.new: '+Trigger.new;
        Id opidAccRecordType =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        Id[] intelAndOPIDAccRecTypes = new Id[]{opidAccRecordType};
            set<Id> acctIds = new set<Id>();
        set<Id> accountIdAfterOperationOnACM = new set<Id>();
        set<Id> accountIdsMPI = new set<Id>();
        List<Account> accountsToBeUpdated = new List<Account>();
        List<Account> accountList = new List<Account>();
        List<Account> accountListMPI = new List<Account>();
        List<Id> acmid = new List<Id>();
        List<Account> accListAfterOp = new List<Account>();
        List<Id> opidAccountList = new List<Id>();
        List<PRM_AccountChannelMembership__c> initialACMListUpdatelocAccountACM = new List<PRM_AccountChannelMembership__c>();
        List<Core_Account_Group_Member__c> listCAGUpdateOpOnACM = new List<Core_Account_Group_Member__c>();
        Map<id, PRM_AccountChannelMembership__c> acmRecMapTriggerRecs = new Map<id, PRM_AccountChannelMembership__c>();
        List<PRM_AccountChannelMembership__c> acmListUpsertOPIDACM = new List<PRM_AccountChannelMembership__c>();
        Map<Id,Id> childParentMap = new Map<Id,Id>();
        Set<Id> acmAccId = new Set<Id>();
        Set<String> acmPartnerRole = new Set<String>();
        List<Account> accList = new List<Account>();
        Set<Id> parentACMAccId = new Set<Id>();
        set<string> allACMAccid=new set<string>();

        //   UCD Changes - start - TWC729-6744 .
        Map<String,Core_Account_Group_Member__c> parentCagRec = new Map<String,Core_Account_Group_Member__c>();
    Map<String,account> ucdNonGlblAccMap = new Map<String,account>();
        Map<String,list<account>> globalIdMap = new Map<String,list<account>>();
        Id UcdintelAccRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();  
        set<string> parentUcdSet = new set<string>();
        //   UCD Changes - end - TWC729-6744 .
        
        /* OPID Recommendation ceclarations starts*/
        /*Id recordTypeOPID= Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_OPID).getRecordTypeId(); //TWC729-6800 EOL activities
        List<PRM_AccountChannelMembership__c> AcmRecordCheckForOPID = new List<PRM_AccountChannelMembership__c>();
        List<PRM_AccountChannelMembership__c> AcmWithoutOPIDList = new List<PRM_AccountChannelMembership__c>();            
        Set<Id> AcmWithOPIDCheckSet = new Set<Id>();*/
        Set<Id> AcmWithOPIDSet = new Set<Id>();
        //Set<Id> AccountSetWithCIM = new Set<Id>();
        Map<Id,PRM_AccountChannelMembership__c> AcmWithOPIDCheckMap = new Map<Id,PRM_AccountChannelMembership__c>(); 
        Map<Id,PRM_AccountChannelMembership__c> AcmWithoutOPIDMap = new Map<Id,PRM_AccountChannelMembership__c>();  
        Set<Id> AcmWithoutOPIDSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        //List<Core_Account_Group_Member__c> AcmWithOPID = new List<Core_Account_Group_Member__c>();
        Map<String,String> mapOFTierAndBusinessEvent = new Map<String,String>();
        list<Core_OnePartner_Inbound_Message__c> listOfInboundOnePartner =  new list<Core_OnePartner_Inbound_Message__c> () ;   //UCD- TWC729-6744

        
        
        /* OPID Recommendation ends */    
        
        for(PRM_AccountChannelMembership__c acm : acmNewList) {
            acctIds.add(acm.PRM_Account_Id__c);
            accountIdsMPI.add(acm.PRM_Account_Id__c);
            acmid.add(acm.Id);
            if(acmOldMap!=null && acmOldMap.get(acm.Id).PRM_Partner_Role__c!=acm.PRM_Partner_Role__c){
                accountIdAfterOperationOnACM.add(acm.PRM_Account_Id__c);// storing account ids
            }
            
            PRM_AccountChannelMembership__c acmOld ; 
            if(acmOldMap!=null && !acmOldMap.isEmpty()) {
                acmOld = (PRM_AccountChannelMembership__c) acmOldMap.get(acm.id) ;
            }
            //Precondition of Upsert OPID ACM ---- Start
            if(((acmOld == null) || (acmOld != null && acmOld.PRM_Status_Nm__c != acm.PRM_Status_Nm__c)) 
               && (acm.PRM_Status_Nm__c == System.Label.PRM_Status)
              ){
                  acmAccId.add(acm.PRM_Account_Id__c);
                  acmRecMapTriggerRecs.put(acm.id, acm);
                  acmPartnerRole.add(acm.PRM_Partner_Role__c);
              }
            if((acmOldMap == null && acm.PRM_Status_Nm__c == 'Approved') || (acmOld != null && acmOld.PRM_Status_Nm__c != acm.PRM_Status_Nm__c &&  acm.PRM_Status_Nm__c == 'Approved' ))
            {
                AcmWithOPIDCheckMap.put(acm.PRM_Account_Id__c,acm);
                accountIdSet.add(acm.PRM_Account_Id__c);
            }
            
            //Map Of Tier and Business Event
            /*if(!ipaRefresh || Test.isRunningTest()){
            if(acm.PRM_Tier_Name_txt__c=='Gold' 
               && acmOldMap!=null && acmOldMap.containsKey(acm.Id) 
               && acmOldMap.get(acm.Id).PRM_Tier_Name_txt__c=='Member'){
                   mapOFTierAndBusinessEvent.put(acm.PRM_Tier_Name_txt__c, 'OPID_Upgrade_Gold');
               }
            else if(acm.PRM_Tier_Name_txt__c=='Titanium' 
                    && acmOldMap!=null && acmOldMap.containsKey(acm.Id) 
                    && acmOldMap.get(acm.Id).PRM_Tier_Name_txt__c=='Gold'){
                        mapOFTierAndBusinessEvent.put(acm.PRM_Tier_Name_txt__c, 'OPID_Upgrade_Titanium');
                    }
            else if(acm.PRM_Tier_Name_txt__c=='Titanium' 
                    && acmOldMap!=null && acmOldMap.containsKey(acm.Id) 
                    && acmOldMap.get(acm.Id).PRM_Tier_Name_txt__c=='Member'){
                        mapOFTierAndBusinessEvent.put(acm.PRM_Tier_Name_txt__c, 'OPID_Upgrade_Titanium');
                    }
        }*/ // IPA Switch Removal
           //else{
                 if(acm.PRM_Tier_Name_txt__c=='Prestige' 
                    && acmOldMap!=null && acmOldMap.containsKey(acm.Id) 
                    && acmOldMap.get(acm.Id).PRM_Tier_Name_txt__c=='Partner'){
                        mapOFTierAndBusinessEvent.put(acm.PRM_Tier_Name_txt__c, 'OPID_Upgrade_Prestige');
                }
           // }

        }
        
        if(acmAccId!=null && !acmAccId.IsEmpty()){
    List<Account> acntList = new List<Account>();
    if(AcmWithOPIDCheckMap!=null && !AcmWithOPIDCheckMap.isEmpty()){//NJ Soql issue
        logEntryMsgString+='\n AcmWithOPIDCheckMap: '+AcmWithOPIDCheckMap;
        acntList.addAll([SELECT id,Core_Intel_Partner_Alliance_PartnerGroup__c, 
                             Core_CIM_ID__c,
                             Core_CIM_ID_Old__c,  
                            //UCD-Start - TWC729-6744
                            Core_Business_Party_Id__c,
                            Core_Parent_Business_Party_Id__c,
                            Core_Unified_Global_Customer_BP_Id__c,
                            Core_Customer_Aggregation_Type__c,
                            Core_Unified_Global_Customer_Name__c,
                            Name,
                            (select id from Partner_Account_Group_Members1__r where Core_Inactive_Ind__c = false   limit 1 ),
                            //UCD-End - TWC729-6744
                             Core_CIM_Gold_Status__c,
                             Core_IPA_Partner_Segment__c, 
                             Core_IPA_One_Partner_Id__c 
                             FROM account 
                             WHERE /*id in :acmAccId
                             OR(*/ id In :AcmWithOPIDCheckMap.keyset() and Core_Business_Party_Id__c != null   and Core_IPA_One_Partner_Id__c = null and RecordTypeId =: UcdintelAccRecType ]);   //UCD- TWC729-6744 - Change in OR condition   
    }
    //}       
            for(Account acc: acntList){
        //   UCD Changes - start - TWC729-6744 .
                // UCD-Start - TWC729-6744
                if(acc.Partner_Account_Group_Members1__r.size() == 0 ) {
                    ucdNonGlblAccMap.put(acc.Core_Business_Party_Id__c,acc);
                    parentUcdSet.add(acc.Core_Parent_Business_Party_Id__c);
                }
            //}
                //UCD-End - TWC729-6744
                // UCD- Start - TWC729-6744
               }
        }
        
        if(acmid != null && !acmid.IsEmpty()){ //fetching parent account id.
            for(PRM_AccountChannelMembership__c acm:  [SELECT Id,
                                                       Name, 
                                                       PRM_Account_Id__c, 
                                                       PRM_Channel_Program_Level_Id__c,
                                                       PRM_Channel_Program_Level_Id__r.Name, 
                                                       PRM_Account_Id__r.RecordTypeId,
                                                       PRM_Status_Nm__c,
                                                       PRM_Partner_Role__c 
                                                       FROM PRM_AccountChannelMembership__c 
                                                       where Id IN :acmid])
            {
                if(acmId.contains(acm.id)){
                    initialACMListUpdatelocAccountACM.add(acm);
                    if(intelAndOPIDAccRecTypes.contains(acm.PRM_Account_Id__r.RecordTypeId)){
                        opidAccountList.add(acm.PRM_Account_Id__c);
                    }
                }
            }
        }
        if(acmAccId!=null && !acmAccId.IsEmpty()){ // Fetching parent account id.
            for(Core_Account_Group_Member__c agm :[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Intel_Account_Id__c IN :acmAccId AND Core_Inactive_Ind__c = false]){ 
                parentACMAccId.add(agm.Core_Partner_Account_Id__c);
                childParentMap.put(agm.Core_Intel_Account_Id__c,agm.Core_Partner_Account_Id__c);
            }
        }
        if((accountIdsMPI!=null && !accountIdsMPI.isEmpty() && accountIdsMPI.size()>0)|| 
        (opidAccountList != null && !opidAccountList.IsEmpty()) || 
        (parentACMAccId!=null && !parentACMAccId.isEmpty()) ||
        /*(AccountSetWithCIM!=null && !AccountSetWithCIM.isEmpty()) ||*/
        (parentUcdSet!=null && !parentUcdSet.isEmpty())){
               for(Core_Account_Group_Member__c agm :[SELECT Id,
                                                      Name,
                                                      Core_Partner_Account_Id__c, 
                                                      Core_Intel_Account_Id__c,
                                                      Core_Business_Party_Id__c,                        // TWC729-6744 UCD Change
                                                      Core_Partner_Account_Id__r.Core_OnePartnerID__c,  // TWC729-6744 UCD Change
                                                      Core_Partner_Account_Id__r.Name,                  // TWC729-6744 UCD Change
                                                      Core_Inactive_Ind__c 
                                                      FROM Core_Account_Group_Member__c 
                                                      WHERE ((Core_Intel_Account_Id__c IN :accountIdsMPI OR Core_Partner_Account_Id__c IN :accountIdsMPI) AND Core_Inactive_Ind__c = false)
                                                      OR(Core_Partner_Account_Id__c in :opidAccountList AND Core_Inactive_Ind__c = false)
                                                      OR(Core_Partner_Account_Id__c IN :parentACMAccId AND Core_Inactive_Ind__c = false)
                                                     /* OR(Core_Intel_Account_Id__c in :AccountSetWithCIM and Core_Inactive_Ind__c = false)*/
                                                      OR(Core_Business_Party_Id__c in :parentUcdSet and Core_Inactive_Ind__c = false)])  // TWC729-6744 UCD Change
               {   if(accountIdsMPI.contains(agm.Core_Intel_Account_Id__c) || accountIdsMPI.contains(agm.Core_Partner_Account_Id__c)){
                   accountIdsMPI.add(agm.Core_Partner_Account_Id__c);
                   accountIdsMPI.add(agm.Core_Intel_Account_Id__c);
               } 
                
                if(opidAccountList.contains(agm.Core_Partner_Account_Id__c)){
                    listCAGUpdateOpOnACM.add(agm);
                }
                if(parentACMAccId.contains(agm.Core_Partner_Account_Id__c)){
                    childParentMap.put(agm.Core_Intel_Account_Id__c,agm.Core_Partner_Account_Id__c);
                    allACMAccid.add(agm.Core_Intel_Account_Id__c);
                }
                // TWC729-6744 - Start - UCD Change
                logEntryMsgString+='\n parentUcdSet: '+parentUcdSet;
                if(parentUcdSet.contains(agm.Core_Business_Party_Id__c)){ // UCD change
                    parentCagRec.put(agm.Core_Business_Party_Id__c,agm);
                    //AcmWithOPIDSet.add(agm.Core_Intel_Account_Id__c);
                 }//}
                // TWC729-6744 - End - UCD Change

               } 
           }
        //OPID Recommendation
        //Extracting all the accounts which was no association with OPID

       

        
        if(allACMAccid.isEmpty() || !parentACMAccId.isEmpty())
        {
            for(PRM_AccountChannelMembership__c acmRec : [SELECT Id,
                                                          Name,
                                                          PRM_Partner_Role__c, 
                                                          PRM_Account_Id__c,
                                                          PRM_Account_Id__r.Core_IPA_Partner_Segment__c, 
                                                          PRM_Account_Id__r.Name,
                                                          PRM_Channel_Program_Level_Id__c,
                                                          PRM_Channel_Program_Id__c,
                                                          PRM_Channel_Program_Level_Id__r.Name,
                                                          PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c,
                                                          PRM_Account_Channel_Program_Key__c,
                                                          CreatedDate 
                                                          FROM PRM_AccountChannelMembership__c 
                                                          WHERE((PRM_Account_Id__c IN :allACMAccid OR PRM_Account_Id__c IN:parentACMAccId)  
                                                                AND (PRM_Partner_Role__c IN :acmPartnerRole))
                                                          OR(PRM_Account_Id__c  In :AcmWithoutOPIDSet and PRM_Status_Nm__c = 'Approved')
                                                          ORDER BY CreatedDate asc])
            {
                if((allACMAccid.contains(acmRec.PRM_Account_Id__c) || parentACMAccId.contains(acmRec.PRM_Account_Id__c))
                   && (acmPartnerRole.contains(acmRec.PRM_Partner_Role__c))
                  ){
                      acmListUpsertOPIDACM.add(acmRec);
                  }
              

            } 
        }
        
        List<PMP_OPID_MPI_Rel__c> junctionObjectsRelatedToAccounts = PMP_Utility.getJunctionAccountToMpiByAccountId(accountIdsMPI);
        Set<Id> allMpiIdRelatedToAccounts = PMP_Utility.getAllMpiIds(junctionObjectsRelatedToAccounts);
        List<PMP_OPID_MPI_Rel__c> junctionObjectsRelatedToMpi = PMP_Utility.getJunctionAccountToMpiByCompanyId(allMpiIdRelatedToAccounts);
        Map<Id,Set<Id>> mapMpiToListAccountActive = PMP_Utility.getMapMpiToListAccountActive(junctionObjectsRelatedToMpi);//MPI Object
        for(Id mpi : mapMpiToListAccountActive.keySet()){
            accountIdsMPI.addAll(mapMpiToListAccountActive.get(mpi));
        }
        
        
        if(acctIds.size() > 0) {
            for(Account acc: [SELECT id,
                              Name,
                              PRM_IPA_Integration_Status__c,
                              Core_IPA_Badge_Tier__c,
                              Core_Account_Type__c,
                              Core_IPA_Partner_Segment__c,
                              Core_IPA_Partner_Speciality__c,
                              RecordTypeId,
                              Core_IPA_Partner_Role__c,
                              Core_User_Defined_Website__c,
                              (SELECT PRM_Channel_Program_Id__r.Name,
                               PRM_Account_Id__c,
                               PRM_Account_Id__r.Core_Account_Type__c,
                               PRM_Channel_Program_Id__r.PRM_programCode__c,
                               PRM_Channel_Program_Level_Id__r.Name,
                               PRM_Partner_Role__c,
                               PRM_Status_Nm__c
                               FROM Channel_Memberships1__r)
                              FROM Account WHERE Id IN: acctIds OR Id IN: accountIdsMPI OR Id IN: accountIdAfterOperationOnACM])
            {
                if(acctIds.size()>0){
                    accountList.add(Acc);
                }
                if(accountIdsMPI.size()>0 ){
                    accountListMPI.add(acc);
                }
                if(accountIdAfterOperationOnACM.contains(acc.Id)){
                    accListAfterOp.add(acc);
                }
            }
        }
        
        if(isActive('ACM_Update_ERPM_Integration_Trigger') && firstRun && (Trigger.isUpdate || Trigger.isInsert)) {
            //ContactERPMIntegrationStatusHandler.parseInputList((List<PRM_AccountChannelMembership__c>)Trigger.new);
            if(accountList.size() > 0) {
                for(Account acct : accountList) {
                    List<PRM_AccountChannelMembership__c> acctACMs= new List<PRM_AccountChannelMembership__c>();
                    for(PRM_AccountChannelMembership__c acm : acct.Channel_Memberships1__r){
                        if(configPartnerRoles.contains(acm.PRM_Partner_Role__c) && acm.PRM_Status_Nm__c != 'Pending'){
                            acctACMs.add(acm);
                        }
                    }
                    if(acctACMs.size() > 0 && acct.PRM_IPA_Integration_Status__c != 'Pending') {
                        acct.PRM_IPA_Integration_Status__c = 'Pending';
                        accountsToBeUpdated.add(acct);
                    }
                }
                if(accountsToBeUpdated.size() > 0) {
                    logEntryMsgString+='\n accountsToBeUpdated: '+accountsToBeUpdated;
                    update accountsToBeUpdated;
                }
            }
            firstRun = false;
        }
        
        if(isActive('ACM_After_Insert')){
            if(trigger.IsInsert && firstRunAfterInsert){
                firstRunAfterInsert = false;
                UpsertOPIDACM(acmNewList, acmOldMap, acmListUpsertOPIDACM, acmRecMapTriggerRecs, childParentMap,parentACMAccId); 
                AfterOperationsOnACM(Trigger.new, (Map<Id,PRM_AccountChannelMembership__c>) Trigger.oldMap, initialACMListUpdatelocAccountACM, accListAfterOp);
            }
        } 
        Set<String> noIpaAccountIds = new Set<String>();
        boolean createInbnd_Recmndn = false;
        if(isActive('ACM_After_Update') && ACMUtilityfirstRun && Trigger.isUpdate && (ACMUtilityfirstRun || secondRun)){
            if(ACMUtilityfirstRun == false){
                secondrun=false;
            } 
            PRM_ACM_Utility.firstRun = false;
            if(secondrun == true){                    
                        CreateInboundRecord(parentCagRec,ucdNonGlblAccMap,listOfInboundOnePartner,AcmWithOPIDCheckMap,noIpaAccountIds); // TWC729-6744 .- UCD
                        createInbnd_Recmndn = true;                
                
            }
            UpsertOPIDACM(acmNewList, acmOldMap, acmListUpsertOPIDACM, acmRecMapTriggerRecs, childParentMap,parentACMAccId);  
            UpdateLocationAccACM(initialACMListUpdatelocAccountACM, listCAGUpdateOpOnACM, mapOFTierAndBusinessEvent); 
            System.debug('@@JK method call');
            AfterOperationsOnACM(Trigger.new, (Map<Id,PRM_AccountChannelMembership__c>) Trigger.oldMap, initialACMListUpdatelocAccountACM, accListAfterOp);
        }
        if((isActive('ACM_OPID_Recommendation') && isOpidrecommendationexecuted==true && (Trigger.isUpdate || Trigger.isInsert)) ){
                isOpidrecommendationexecuted=false;
                if(createInbnd_Recmndn == false){
                    CreateInboundRecord(parentCagRec,ucdNonGlblAccMap,listOfInboundOnePartner,AcmWithOPIDCheckMap,noIpaAccountIds); // TWC729-6744 .- UCD                
            }
        } 
        if(isActive('PMP_Company_Tier_Switch_Update') && mPFirstRun && (Trigger.isUpdate || Trigger.isInsert)){
            updateTierOnMPI(allMpiIdRelatedToAccounts, mapMpiToListAccountActive, accountListMPI);  
            mPFirstRun =false;
        }
        if(Trigger.isUpdate){
            createTrackerMilestonesForMembershipUpdate((List<PRM_AccountChannelMembership__c>)trigger.new,(Map<Id,PRM_AccountChannelMembership__c>) trigger.oldMap);
        }  
        createLogEntry(logEntryMsgString);
    }
    //   UCD Changes - start - TWC729-6744 .
    public static string fetchOpidNumber(){
        Integer tempOpidNumber;
        String onePartnerNum = '';
        try{
            logEntryMsgString+='\n***fetchOpidNumber***';
            OPID_Number__c opidMax = OPID_Number__c.getValues('OPID Number');
            if(opidMax!=null){
                string opidNum = opidMax.Max_OPID_Number__c;
                tempOpidNumber = integer.valueOf(opidNum)+1;
                onePartnerNum = String.valueOf(tempOpidNumber);
                opidMax.Max_OPID_Number__c = onePartnerNum;
                update opidMax;
                logEntryMsgString+='\n***onePartnerNum: '+onePartnerNum;
            }
        }catch(Exception ex){
            logEntryMsgString+= ex.getMessage();
        }
        return onePartnerNum;
    }
    public static void updateOpidNumber(List<Core_OnePartner_Inbound_Message__c> listOfInboundOnePartner){
        try{
            logEntryMsgString+='***updateOpidNumber***';
            boolean isMaxOpidNum = false;
            OPID_Number__c opidMax = OPID_Number__c.getValues('OPID Number');
            if(opidMax!=null){
                Integer opidNum = Integer.valueOf(opidMax.Max_OPID_Number__c);
                for(Core_OnePartner_Inbound_Message__c inboundRec : listOfInboundOnePartner){ 
                    Integer maxOpidNumber = Integer.valueOf(inboundRec.Core_OnePartnerID__c);
                        if(maxOpidNumber>opidNum){ 
                            opidNum = maxOpidNumber;
                            isMaxOpidNum = true;
                        }     
                }
                if(isMaxOpidNum){
                    opidMax.Max_OPID_Number__c = String.valueOf(opidNum);                    
                    update opidMax;
                }
            }
        }catch(Exception ex){
            logEntryMsgString+='\n Errors: '+ex.getMessage();
        }
    }
    //   UCD Changes - End - TWC729-6744 .
    
    //This method is used to restrict user from adding the duplicate Account Channel Membership record for the same account.
    public static void duplicateRecordCheck(List<PRM_AccountChannelMembership__c > acmNewList, List<PRM_AccountChannelMembership__c > acmOldList, List<PRM_AccountChannelMembership__c> acmList)
    {   
        logEntryMsgString+='\nEntered duplicateRecordCheck,acmNewList: '+acmNewList;
        Map<String,Id> uniqueMap = new Map<String,Id>();
        Map<String,Id> uniqueUpdateMap = new Map<String,Id>();
        //List<PRM_AccountChannelMembership__c> initialACMList = new List<PRM_AccountChannelMembership__c>();
        List<String> uniqstr = new List<String>();
        List<Id> idslist = new List<Id>();
        //Throwing error message if CP, CPL and partner role combination already exists in an ACM record.
        if(!acmNewList.isEmpty() && acmNewList != null){
            for(PRM_AccountChannelMembership__c acm : acmNewList){
                uniqstr.add(acm.PRM_Account_Channel_Program_Key__c);
                idsList.add(acm.id);
            }
        }
        
        if(acmOldList == null){
            if(acmList != null && !acmList.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm :acmList){
                    uniqueMap.put(acm.PRM_Account_Channel_Program_Key__c, acm.Id);
                }
            }
            if(acmNewList != null && !acmNewList.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm: acmNewList){    
                    if(uniqueMap.containsKey(acm.PRM_Account_Channel_Program_Key__c)){
                        acm.addError(System.Label.PRM_ACM_Error_Message);
                    }            
                }
            }
        }else{
            if(acmList != null && !acmList.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm :acmList){
                    if((uniqstr != null && !uniqstr.IsEmpty()) && (idsList != null && !idsList.IsEmpty()) && (!idsList.contains(acm.Id)) && (uniqstr.contains(acm.PRM_Account_Channel_Program_Key__c))){
                        uniqueUpdateMap.put(acm.PRM_Account_Channel_Program_Key__c,acm.Id);
                    }
                    
                }
            }
            if(acmNewList != null && !acmNewList.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm: acmNewList){    
                    if(uniqueUpdateMap.containsKey(acm.PRM_Account_Channel_Program_Key__c)){
                        acm.addError(System.Label.PRM_ACM_Error_Message);
                    }            
                }
            }
        } 
    }
    //METHOD End here
    
    /* **********************************************************************************************************************************************
* Method Name  : UpsertOPIDACM    
* Description  : This method includes all the logic to rollup membership on OPID when new ACM is created on loaction account.
************************************************************************************************************************************************* */
    public static void UpsertOPIDACM(List<PRM_AccountChannelMembership__c > acmNewList,Map<Id,PRM_AccountChannelMembership__c> oldMap, List<PRM_AccountChannelMembership__c> acmListUpsertOPIDACM, Map<Id,PRM_AccountChannelMembership__c>  acmRecMap, Map<Id,Id> childParentMap,Set<Id> parentACMAccId){
        logEntryMsgString+='\n Entered UpsertOPIDACM';
        boolean upsertOPIDACM = false;
        Set<String> acmPartnerRole = new Set<String>();
        Set<Id> acmAccId = new Set<Id>();
        Map<Id,PRM_AccountChannelMembership__c> parentACMMap = new Map<Id,PRM_AccountChannelMembership__c>();
        Map<Id,PRM_AccountChannelMembership__c> acmMap = new Map<Id,PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c parentAcm = new PRM_AccountChannelMembership__c();
        PRM_AccountChannelMembership__c locationAcm = new PRM_AccountChannelMembership__c();
        List<PRM_AccountChannelMembership__c> upsertACMList = new List<PRM_AccountChannelMembership__c>();
        set<PRM_AccountChannelMembership__c> processACMID = new set<PRM_AccountChannelMembership__c>();
        //List<Core_Account_Group_Member__c> initialPAGMRecordList = new List<Core_Account_Group_Member__c>();
        Map<string,integer> OPIDTierRollUpMap=new Map<string,integer>();
        set<Id> acrIds=new set<id>();
        set<string> partnerRoleSet=new set<string>();
        
        for(PRM_AccountChannelMembership__c acm :acmNewList){
            PRM_AccountChannelMembership__c oldACM;
            if(oldMap != null && oldMap.size() > 0){
                oldACM = (PRM_AccountChannelMembership__c) oldMap.get(acm.Id);
            }
            if(((oldACM == null) || (oldACM != null && oldACM.PRM_Status_Nm__c != acm.PRM_Status_Nm__c)) && (acm.PRM_Status_Nm__c == System.Label.PRM_Status)){
                upsertOPIDACM=true;
                processACMID.add(acm);
                acrIds.add(acm.Id);
            }
        }
        
        if(upsertOPIDACM){
            if(processACMID != null && !processACMID.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm :processACMID){ // Fetching location ACM details.
                    acmAccId.add(acm.PRM_Account_Id__c);
                    acmPartnerRole.add(acm.PRM_Partner_Role__c);
                    acmMap.put(acm.PRM_Account_Id__c,acm);
                    acmRecMap.put(acm.id, acm);
                }
            }
                      
            for(PRM_AccountChannelMembership__c acm : acmListUpsertOPIDACM){
                if(acmRecMap.containsKey(acm.id)){
                    acm = acmRecMap.get(acm.id);
                }
                if(childParentMap.containsKey(acm.PRM_Account_Id__c) && acm.PRM_Status_Nm__c == 'Approved'){
                    if(partnerRoleSet.contains(acm.PRM_Partner_Role__c)){
                        if(childParentMap.containsKey(acm.PRM_Account_Id__c)){ //true
                            if(OPIDTierRollUpMap.containsKey(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c)){
                                OPIDTierRollUpMap.put(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c,OPIDTierRollUpMap.get(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c)+1);
                            }else{
                                OPIDTierRollUpMap.put(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c,1);
                            } 
                        }
                    }
                    else if(acm.PRM_Partner_Role__c != null){
                        partnerRoleSet.add(acm.PRM_Partner_Role__c);
                        OPIDTierRollUpMap.put(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c,1);
                    }
    }
                if(parentACMAccId.contains(acm.PRM_Account_Id__c)){
                    parentACMMap.put(acm.PRM_Account_Id__c, acm); 
                }
            }
            if(Trigger.isBefore && Trigger.isInsert){
                for(PRM_AccountChannelMembership__c acm :acmNewList){
                    if(OPIDTierRollUpMap.containsKey(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c)){
                        OPIDTierRollUpMap.put(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c,OPIDTierRollUpMap.get(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c)+1);
                    }else{
                        OPIDTierRollUpMap.put(childParentMap.get(acm.PRM_Account_Id__c)+acm.PRM_Partner_Role__c,1);
                    }
                }
            }
            
             Set<Id> acmIdSet = new Set<Id>();
            if(acmAccId != null && !acmAccId.IsEmpty()){ 
                for(Id accid :acmAccId){
                    parentAcm = parentACMMap.get(childParentMap.get(accid));
                    locationAcm = acmMap.get(accid);
                    if(parentAcm != null){ // Update back location account ACM.
                        if(Trigger.isAfter){
                            if(parentAcm.PRM_Channel_Program_Level_Id__c != locationAcm.PRM_Channel_Program_Level_Id__c && OPIDTierRollUpMap!=null && OPIDTierRollUpMap.containskey(parentAcm.PRM_Account_Id__c+locationAcm.PRM_Partner_Role__c) && OPIDTierRollUpMap.get(parentAcm.PRM_Account_Id__c+locationAcm.PRM_Partner_Role__c)==1){
                                parentAcm.PRM_Channel_Program_Level_Id__c = locationAcm.PRM_Channel_Program_Level_Id__c;
                                parentAcm.PRM_Status_Nm__c = System.Label.PRM_Status;
                                parentAcm.PRM_Status_Reason_Txt__c = 'Approved as part of Rollup from Location';//TWC729-8089 : Adding reason text : NJ
                                upsertACMList.add(parentAcm);
                            }
                            if(parentAcm.PRM_Status_Nm__c != System.Label.PRM_Status){
                                parentAcm.PRM_Status_Nm__c = System.Label.PRM_Status;
                                parentAcm.PRM_Status_Reason_Txt__c ='Approved as part of Rollup from Location' ;//TWC729-8089 : Adding reason text : NJ
                                upsertACMList.add(parentAcm);
                            }
                        }
                        if(Trigger.isBefore){
                            if(parentAcm.PRM_Channel_Program_Level_Id__c != locationAcm.PRM_Channel_Program_Level_Id__c){
                                if((OPIDTierRollUpMap!=null && OPIDTierRollUpMap.containskey(parentAcm.PRM_Account_Id__c+locationAcm.PRM_Partner_Role__c) && 
                                    (OPIDTierRollUpMap.get(parentAcm.PRM_Account_Id__c+locationAcm.PRM_Partner_Role__c)==1)) || 
                                   OPIDTierRollUpMap == null || OPIDTierRollUpMap.isEmpty()){
                                       parentAcm.PRM_Channel_Program_Level_Id__c = locationAcm.PRM_Channel_Program_Level_Id__c;
                                       parentAcm.PRM_Status_Nm__c = System.Label.PRM_Status;
                                       parentAcm.PRM_Status_Reason_Txt__c ='Approved as part of Rollup from Location' ;//TWC729-8089 : Adding reason text : NJ
                                       upsertACMList.add(parentAcm);
                                   }
                                else {
                                    locationAcm.PRM_Channel_Program_Level_Id__c = parentAcm.PRM_Channel_Program_Level_Id__c;
                                }
                            }
                            //upsertACMList.add(locationAcm);
                            if(parentAcm.PRM_Status_Nm__c != System.Label.PRM_Status){
                                parentAcm.PRM_Status_Nm__c = System.Label.PRM_Status;
                                parentAcm.PRM_Status_Reason_Txt__c = 'Approved as part of Rollup from Location' ;//TWC729-8089 : Adding reason text : NJ
                                upsertACMList.add(parentAcm);
                            }
                        }
                        
                    }
                    else{ // insert ACM on OPID.
                        if(Trigger.isAfter){
                            PRM_AccountChannelMembership__c insertAcm = new PRM_AccountChannelMembership__c();
                            insertAcm.PRM_Account_Id__c = childParentMap.get(accid);
                            insertAcm.PRM_Channel_Program_Id__c =LabelConfiguration__mdt.getInstance('ChannelProgramIds').Value__c;
                            if(locationAcm != null){
                                insertAcm.PRM_Channel_Program_Level_Id__c = locationAcm.PRM_Channel_Program_Level_Id__c;
                                insertAcm.PRM_Partner_Role__c = locationAcm.PRM_Partner_Role__c;
                            }
                            insertAcm.PRM_Status_Nm__c = System.Label.PRM_Status;
                            insertAcm.PRM_Status_Reason_Txt__c = 'ACM Created as part of Rollup from Location' ;//TWC729-8089 : Adding reason text : NJ
                            if(!Test.isRunningTest() && insertAcm.PRM_Account_Id__c != null){
                                upsertACMList.add(insertAcm);
                            }
                        }
                    }
                }
            }
            Database.UpsertResult[] saveResLst; 
            if(upsertACMList != null && !upsertACMList.IsEmpty())
            {
                PRM_ACM_TriggerHandler.firstRun = true;
                logEntryMsgString+='\n upsertACMList:'+upsertACMList;
                saveResLst = PRM_DMLUtility.doupsert(upsertACMList, 'PRM_AccountChannelMembership__c', 'PRM_ACMTriggerHandlerNew.UpsertOPIDACM'); // what if we do it in future context or queable context?
            }
            if (saveResLst != null) {
              
            for (Database.UpsertResult sr : saveResLst) {
                if (sr.isSuccess()) {      
                    acmIdSet.add(sr.getId());     
                }
                else{
                    for (Database.Error err : sr.getErrors()) {
                                logEntryMsgString+= 'Message: ' + err.getMessage() + '\n'
                                                + 'Fields: ' + err.Fields.toString() + '\n'
                                                + 'StatusCode: ' + err.getStatusCode() + '\n';
                            }
                }
            }
            map<Id, PRM_AccountChannelMembership__c> acmMapAfterUpsert = new  map<Id, PRM_AccountChannelMembership__c>();
            if(upsertACMList != null && !upsertACMList.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm : upsertACMList){
                    if(acmIdSet.contains(acm.Id)){
                        acmMapAfterUpsert.put(acm.PRM_Account_Id__c , acm);
                    }
                }
            }
             /*if(acmMapAfterUpsert != null && !acmMapAfterUpsert.isempty() && (!ipaRefresh || test.isRunningTest())){
                PRM_OPIDPAGRecordOperation.assignBenefitsOnRollUp(acmMapAfterUpsert);
            }*/ // IPA Switch Removal 
            }
        }
    }
    
    //Suppress Email Method
    public static void suppressEmail(List<PRM_AccountChannelMembership__c> acmList, Set<Id> intelAccountIds){
        logEntryMsgString+='\n Entered suppressEmail,acmList: '+acmList;
        //Map<Id,String> conIdConEmailMap = new Map<Id,String>();
        List<PRM_Email_Handler__c> emailHandlerRecordsToInsert= new List<PRM_Email_Handler__c>();
        String acmPartnerrolestring ='';
        //Set<Id>contactId = new Set<Id>();
        
        for(PRM_AccountChannelMembership__c acm : acmList){
            if(acm.PRM_Suppress_Email__c == true){                    
                acmPartnerrolestring = (acmPartnerrolestring != null) ? (acmPartnerrolestring + ';' + acm.PRM_Partner_Role__c) : acm.PRM_Partner_Role__c;
                acmPartnerrolestring = acmPartnerrolestring.removeEnd(';');
            }
        }
        
        if((intelAccountIds != null && !intelAccountIds.IsEmpty()) && (acmPartnerrolestring != null)){
            for(PRM_Account_Contact_Relationship__c accCon : [Select PRM_Account_Id__c,PRM_Contact_Id__c, PRM_Contact_Id__r.email,PRM_Partner_Role__c,PRM_Contact_Id__r.Core_IPA_PartnerRole__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :intelAccountIds and PRM_Relationship_Id__r.name=:System.Label.PRM_Primary_Contact AND PRM_InActive_Ind__c = false AND PRM_Status_Nm__c =:System.Label.PRM_ACR_Status]){
                if(accCon.PRM_Contact_Id__r.Core_IPA_PartnerRole__c != null && acmPartnerrolestring.containsAny(accCon.PRM_Contact_Id__r.Core_IPA_PartnerRole__c)){
                    //contactId.add(accCon.PRM_Contact_Id__c);
                    PRM_Email_Handler__c emailHandler = new PRM_Email_Handler__c();
                    emailHandler.PRM_Contact__c =accCon.PRM_Contact_Id__c;                
                    emailHandler.PRM_Event__c = 'Upgrade Request';
                    emailHandler.PRM_Email_Handler_Status__c = 'Requested For Suppression';
                    emailHandler.PRM_Suppress_Email__c = true;
                    emailHandlerRecordsToInsert.add(emailHandler);
                }                
            }
        }
        if(emailHandlerRecordsToInsert!=null && !emailHandlerRecordsToInsert.isEmpty()){
            logEntryMsgString+='\n emailHandlerRecordsToInsert: '+emailHandlerRecordsToInsert;
            insert emailHandlerRecordsToInsert;
        }
    }
    
    //New mthod
    public static void updateTierOnMPI(Set<Id> allMpiIdRelatedToAccounts, Map<Id,Set<Id>> mapMpiToListAccountActive, List<Account> accountList){
        String INVALID_TIER = 'UNDETERMND';
        Id intelacc_rectypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        // If No MPI related to accounts, return
        if(allMpiIdRelatedToAccounts.isEmpty()){
            return;
        }
        List<PMP_Company__c> partners ;
        logEntryMsgString+='\n Entered updateTierOnMPI, allMpiIdRelatedToAccounts: '+allMpiIdRelatedToAccounts;
        if(Schema.sObjectType.PMP_Company__c.isAccessible()){
            partners=[SELECT id,Name,PMP_Published_Copy_Id__r.PMP_Account_Program_Membership__c,PMP_IPA_Badge_Tier_Txt__c, PMP_Account_Program_Membership__c,PMP_Partner_Program_nm__c,PMP_Account_Website__c from PMP_Company__c where Id IN :mapMpiToListAccountActive.keyset()];
        }
        
        
        //ENd : OPID to MPI tier defect fix DE109646 : QA/PROD: MPI record is not getting updated when updated ACM tier/ Benefit/ New partner role addition.
        
        Map<Id,String> mapAccountToCoreAccountType = new Map<Id,String>();  
        
        Map<Id,String> mapAccountToPartnerSegment = new Map<Id,String>();
        Map<Id,String> mapAccountToSpeciality = new Map<Id,String>();
        Map<Id,Account> mapAccount = new Map<Id,Account>();                  
        
        Map<Id,List<PRM_AccountChannelMembership__c>> mapAccountToListChannelMemberships = new Map<Id,List<PRM_AccountChannelMembership__c>>();
        for(Account acc: accountList){
            mapAccount.put(acc.Id,acc);
            mapAccountToCoreAccountType.put(acc.Id,acc.Core_Account_Type__c);
            mapAccountToPartnerSegment.put(acc.Id,acc.Core_IPA_Partner_Segment__c);
            mapAccountToSpeciality.put(acc.Id,acc.Core_IPA_Partner_Speciality__c);
            List<PRM_AccountChannelMembership__c> listChannelMemberships = new List<PRM_AccountChannelMembership__c>();
            for( PRM_AccountChannelMembership__c eng : acc.Channel_Memberships1__r){
                if(eng.PRM_Status_Nm__c == 'Approved'){
                    listChannelMemberships.add(eng);
                }
            }
            mapAccountToListChannelMemberships.put(acc.Id,listChannelMemberships);
        }
        
        
        
        
        Schema.DescribeFieldResult fieldResultSpeciality = PMP_Company__c.PMP_Account_Specialty__c.getDescribe();
        List<Schema.PicklistEntry> pleSpeciality = fieldResultSpeciality.getPicklistValues();
        Set<String> picklistValuesSpeciality = new Set<String>();
        for( Schema.PicklistEntry f : pleSpeciality)
        {
            picklistValuesSpeciality.add(f.getValue());
        }
        Schema.DescribeFieldResult fieldResultSegment = PMP_Company__c.PMP_Partner_Segment_Nm__c.getDescribe();
        List<Schema.PicklistEntry> pleSegment = fieldResultSegment.getPicklistValues();
        Set<String> picklistValuesSegment = new Set<String>();
        for( Schema.PicklistEntry f : pleSegment)
        {
            picklistValuesSegment.add(f.getValue());
        }
        
        
        
        for(PMP_Company__c company : partners){
            company.PMP_Account_Program_Membership__c = null;
            company.PMP_Partner_Program_nm__c = null;
            company.PMP_IPA_Badge_Tier_Txt__c = null;
            
            // If Intel account update website info and company name to account name also
            if(mapMpiToListAccountActive.get(company.id).size()==1){
                List<Id> intelAccountIds = new List<Id>();
                intelAccountIds.addAll(mapMpiToListAccountActive.get(company.id));
                if(mapAccount != null && !mapAccount.isEmpty() && mapAccount.containsKey(intelAccountIds[0])){
                    Account intelAcc = mapAccount.get(intelAccountIds[0]);
                    if(intelAcc.RecordTypeId == intelacc_rectypeid){
                        if(company.Name!=intelAcc.Name){
                            Integer maxSize = 80;
                            if(intelAcc.Name.length() > maxSize ){
                                company.Name = intelAcc.Name.substring(0, maxSize);
                            }else{
                                company.Name = intelAcc.Name;
                            }
                        }
                        
                        if(company.PMP_Account_Website__c!=intelAcc.Core_User_Defined_Website__c){
                            company.PMP_Account_Website__c = intelAcc.Core_User_Defined_Website__c;
                        }
                        
                    }
                }
            }
            company.PMP_Biz_Org_Type_Value_Txt__c = PMP_AccountBenefitPartnerUtility.getBizOrgType(mapMpiToListAccountActive.get(company.id),mapAccountToCoreAccountType);
            
            company.PMP_Partner_Segment_Nm__c = PMP_AccountBenefitPartnerUtility.rollUpMultiPicklist(mapMpiToListAccountActive.get(company.id),mapAccountToPartnerSegment,picklistValuesSegment);
            company.PMP_Account_Specialty__c =  PMP_AccountBenefitPartnerUtility.rollUpMultiPicklist(mapMpiToListAccountActive.get(company.id),mapAccountToSpeciality,picklistValuesSpeciality);
            
            List<PRM_AccountChannelMembership__c> listAllAccountChannelMembershipsRelatedToMpi = new List<PRM_AccountChannelMembership__c>();
            for(Id accountId:mapMpiToListAccountActive.get(company.id)){
                if(mapAccountToListChannelMemberships != null && !mapAccountToListChannelMemberships.isEmpty() && mapAccountToListChannelMemberships.containsKey(accountId)){
                    listAllAccountChannelMembershipsRelatedToMpi.addAll(mapAccountToListChannelMemberships.get(accountId));
                }
            }
            
            String programMembership='';
            String partnerProgram='';
            String ipaBadgeTier= PMP_AccountBenefitPartnerUtility.calculateIpaBadgeTier(listAllAccountChannelMembershipsRelatedToMpi);
            for(PRM_AccountChannelMembership__c eng : listAllAccountChannelMembershipsRelatedToMpi){
                if( eng.PRM_Channel_Program_Level_Id__r.Name != INVALID_TIER ){
                    // String progMembership = eng.PRM_Partner_Role__c + ' - ' + eng.PRM_Channel_Program_Level_Id__r.Name; 
                    // String progMembership = eng.PRM_Partner_Role__c == 'Distributor'? eng.PRM_Partner_Role__c + ' - ' + eng.PRM_Account_Id__r.Core_Account_Type__c:eng.PRM_Partner_Role__c + ' - ' + eng.PRM_Channel_Program_Level_Id__r.Name;
                   
                    String progMembership = PMP_AccountBenefitPartnerUtility.getProgramMembership(eng);   

                    programMembership= PMP_AccountBenefitPartnerUtility.formatAndPopulateMultiPicklistForProgramMembership(programMembership,progMembership);
                    partnerProgram = PMP_AccountBenefitPartnerUtility.formatAndPopulateMultiPicklist(partnerProgram,eng.PRM_Partner_Role__c);
                }
                else{
                    partnerProgram = PMP_AccountBenefitPartnerUtility.formatAndPopulateMultiPicklist(partnerProgram,eng.PRM_Partner_Role__c);
                }     
            }
            company.PMP_Account_Program_Membership__c=programMembership;
            company.PMP_Partner_Program_nm__c= partnerProgram;
            company.PMP_IPA_Badge_Tier_Txt__c = ipaBadgeTier;
            
        }
        
        
        if(Schema.sObjectType.PMP_Company__c.isUpdateable() && !partners.isempty()){
            
            //The below static constant added by Krishna Ch for 101 SOQL issue.
            Map<String,Core_Trigger_Executions__c> companyTriggerFlagMap = Core_Trigger_Executions__c.getAll();
            if(companyTriggerFlagMap.containsKey('Sync_Published_Copy') && 
               !companyTriggerFlagMap.get('Sync_Published_Copy').Core_Active__c){ 
                   PMP_StaticConstants_Partner.isCompanyAfterUpdateTriggerActive = False;
               }
            logEntryMsgString+='\n partners: '+partners;
            update partners;
            
        }
        
    }
    
    public Static  void UpdateLocationAccACM(List<PRM_AccountChannelMembership__c> initialACMList, List<Core_Account_Group_Member__c> cagRecs, Map<String,String> mapOFTierAndBusinessEvent){
        
        List<Id> opidAccountList = new List<Id>();
        List<PRM_AccountChannelMembership__c> upsertACMList = new List<PRM_AccountChannelMembership__c>();
        Map<Id,PRM_AccountChannelMembership__c> mapLocationAccIdACM = new Map<Id,PRM_AccountChannelMembership__c>();
        Map<Id,String> opidAccPartnerRole = new Map<Id,String>();
        Map<Id,String> opidAccPartnerTier = new Map<Id,String>();
        Map<Id,String> mapLocationAccPartnerTier = new Map<Id,String>();
        Map<Id,PRM_AccountChannelMembership__c> opidAccPartnerACMMap = new Map<Id,PRM_AccountChannelMembership__c>();
        Map<Id,Id> mapLocationAccOpid = new Map<Id,Id>();
        Set<Id> locationAccList = new Set<Id>();
        boolean opidAccount = false;
        boolean isLocAccUpgraded = false;
        List<PRM_Value_Exchange_Recommendation__c> updatedVxRecList = new List<PRM_Value_Exchange_Recommendation__c>(); //UCD Changes - TWC729-6744 .
        List<Id> updatedACMList = new List<Id>();
        Set<Id> activeLocationACMAccid = new Set<Id>();
        Id opidAccRecordType =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        Id[] intelAndOPIDAccRecTypes = new Id[]{opidAccRecordType};
            
            if(Trigger.isAfter){    
                if(initialACMList != null && !initialACMList.IsEmpty()){
                    logEntryMsgString+='\n Entered UpdateLocationAccACM, initialACMList: '+initialACMList;
                    for(PRM_AccountChannelMembership__c acm :initialACMList){
                        if(intelAndOPIDAccRecTypes.contains(acm.PRM_Account_Id__r.RecordTypeId)){
                            opidAccountList.add(acm.PRM_Account_Id__c);
                            opidAccPartnerRole.put(acm.PRM_Account_Id__c, acm.PRM_Partner_Role__c);
                            opidAccPartnerTier.put(acm.PRM_Account_Id__c, acm.PRM_Channel_Program_Level_Id__r.Name);
                            opidAccPartnerACMMap.put(acm.PRM_Account_Id__c, acm);
                            opidAccount = true;
                        }
                    }
                }
                if(opidAccount){
                    if(opidAccountList != null && !opidAccountList.IsEmpty()){ //Fetching location account id.
                        for(Core_Account_Group_Member__c agm : cagRecs){
                            locationAccList.add(agm.Core_Intel_Account_Id__c);
                            mapLocationAccOpid.put(agm.Core_Intel_Account_Id__c,agm.Core_Partner_Account_Id__c);
                        }
                    }
                    if((locationAccList != null && !locationAccList.IsEmpty()) && (mapLocationAccOpid != null && !mapLocationAccOpid.IsEmpty()) && (opidAccPartnerRole != null && !opidAccPartnerRole.IsEmpty())){
                        for(PRM_AccountChannelMembership__c acm :[Select Id,Name, PRM_Account_Id__c,PRM_Partner_Role__c, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name, PRM_Account_Id__r.RecordTypeId from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN :locationAccList AND PRM_Status_Nm__c =:System.Label.PRM_Status]){
                            mapLocationAccPartnerTier.put(acm.PRM_Account_Id__c,acm.PRM_Channel_Program_Level_Id__r.Name);
                            if(acm.PRM_Partner_Role__c == opidAccPartnerRole.get(mapLocationAccOpid.get(acm.PRM_Account_Id__c))){
                                mapLocationAccIdACM.put(acm.PRM_Account_Id__c,acm);
                                activeLocationACMAccid.add(acm.PRM_Account_Id__c);
                            }
                        }
                    }
                    if((locationAccList != null && !locationAccList.IsEmpty()) && (opidAccPartnerACMMap != null && !opidAccPartnerACMMap.IsEmpty())){
                        for(Id accid :locationAccList){ //updating child ACM
                            if(mapLocationAccIdACM.get(accid) != null){
                                PRM_AccountChannelMembership__c updateacm = new PRM_AccountChannelMembership__c();
                                updateacm = mapLocationAccIdACM.get(accid);
                                if(updateacm != null){
                                    PRM_AccountChannelMembership__c parentACM = opidAccPartnerACMMap.get(mapLocationAccOpid.get(accid));
                                    String parentAccChannelPrg = parentACM.PRM_Channel_Program_Level_Id__r.name;
                                    String locationAccChannelPrg = updateacm.PRM_Channel_Program_Level_Id__r.name;
                                    if(locationAccChannelPrg != parentAccChannelPrg){
                                        updateacm.PRM_Channel_Program_Level_Id__c = parentACM.PRM_Channel_Program_Level_Id__c;
                                        String statusMessage = PRM_OPIDProcessUtility.acmUpdateStatusMessage(locationAccChannelPrg,parentAccChannelPrg);
                                        updateacm.PRM_Status_Reason_Txt__c =  statusMessage;   
                                        upsertACMList.add(updateacm);
                                        isLocAccUpgraded = true;
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                try{
                    Database.UpsertResult[] acmErrorHandle = null;
                    Id finalACMId;
                    
                    if(upsertACMList != null && !upsertACMList.IsEmpty()){
                        PRM_ACM_TriggerHandler.firstRun = true;
                        logEntryMsgString+='\nUpdateLocationAccACM  upsertACMList: '+upsertACMList;
                        acmErrorHandle = Database.upsert(upsertACMList,false);
                        Map<String,String> acmMapError = PRM_OPIDProcessUtility.getErrorMessageForACMupsert(upsertACMList, acmErrorHandle);
                        PRM_OPIDProcessUtility.updateErrorDetailsAtInboundTable(acmMapError);
                        for(Database.UpsertResult sr : acmErrorHandle){
                            if(sr.isSuccess()){
                                finalACMId = sr.getId();
                                updatedACMList.add(finalACMId);
                                System.debug('@@JK updatedACMList'+updatedACMList);
                            }else{
                                 for (Database.Error err : sr.getErrors()) {
                                    logEntryMsgString+= 'Message: ' + err.getMessage() + '\n'
                                                + 'Fields: ' + err.Fields.toString() + '\n'
                                                + 'StatusCode: ' + err.getStatusCode() + '\n';
                                }
                            }
                        }
                    }
                    
                }catch(Exception ex){logEntryMsgString+='\n Errors: '+ex.getMessage();            
                                    }
                
                /* Start - Send upgrade email to primary contact*/
                Set<String> updatedACMpartnerRole = new Set<String>();
                Set<String> acmPartnerTierList = new Set<String>();
                Set<Id> updatedACMAccountId = new Set<Id>();
                Map<Id,String> intelaccPartnerRoleMap = new Map<Id,String>();
                //Map<String,String> mapOFTierAndBusinessEvent = new Map<String,String>();
                List<PRM_EmailQueue__c> emqList= new List<PRM_EmailQueue__c>();
                List<PRM_Tracker__c> trackers = new List<PRM_Tracker__c>();
                
                if(updatedACMList != null && !updatedACMList.IsEmpty()){
                    for(PRM_AccountChannelMembership__c acm :[Select Id,Name, PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Tier_Name_txt__c, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name, PRM_Account_Id__r.RecordTypeId from PRM_AccountChannelMembership__c where Id IN :updatedACMList AND PRM_Status_Nm__c =:System.Label.PRM_Status]){
                        updatedACMpartnerRole.add(acm.PRM_Partner_Role__c);
                        updatedACMAccountId.add(acm.PRM_Account_Id__c);
                        acmPartnerTierList.add(acm.PRM_Channel_Program_Level_Id__r.Name);
                        intelaccPartnerRoleMap.put(acm.PRM_Account_Id__c,acm.PRM_Channel_Program_Level_Id__r.name);
                    }
                }
                
                /*if((acmPartnerTierList != null && !acmPartnerTierList.IsEmpty()) && (updatedACMpartnerRole != null && !updatedACMpartnerRole.IsEmpty())){
for(PRM_EmailConfiguration__mdt emailConfigList :[Select Id,PRM_BusinessEvent__c,PRM_PartnerRole__c,PRM_Entitlement_List__c,PRM_Priority__c,PRM_Tier__c from PRM_EmailConfiguration__mdt where PRM_Tier__c IN :acmPartnerTierList and PRM_PartnerRole__c IN :updatedACMpartnerRole])
{
mapOFTierAndBusinessEvent.put(emailConfigList.PRM_Tier__c, emailConfigList.PRM_BusinessEvent__c);
}
}*/
                
                if((updatedACMAccountId != null && !updatedACMAccountId.IsEmpty()) && (updatedACMpartnerRole != null && !updatedACMpartnerRole.IsEmpty())){
                    Map<Id,PRM_Email_Handler__c> emailSuppressionMap =PRM_Email_Handler_Utility.returnContactSupressionMap(updatedACMAccountId,'Upgrade Request');                
                    List<PRM_Email_Handler__c> emailHandlersToUpdate = new List<PRM_Email_Handler__c>();
                    Boolean suppressEmail=false;
                    for(PRM_Account_Contact_Relationship__c accCon : [Select PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,PRM_Contact_Id__c, PRM_Contact_Id__r.email,Name,PRM_Partner_Role__c,PRM_Contact_Id__r.Core_Preferred_Language__c,PRM_Contact_Id__r.FirstName,PRM_Contact_Id__r.LastName,PRM_Contact_Id__r.Name,PRM_Contact_Id__r.Core_Do_Not_Contact__c,PRM_Contact_Id__r.Core_IPA_PartnerRole__c,PRM_Relationship_Id__r.Name From PRM_Account_Contact_Relationship__c Where PRM_Account_Id__c IN :updatedACMAccountId and PRM_Contact_Id__r.Core_Do_Not_Contact__c = false AND PRM_InActive_Ind__c = false  AND PRM_Status_Nm__c =:System.Label.PRM_ACR_Status AND PRM_Contact_Id__r.Core_IPA_PartnerRole__c != null]){
                        //Boolean suppressEmail = PRM_Email_Handler_Utility.checkForEmailSupression(accCon.PRM_Contact_Id__r.email,'Upgrade Request');                   
                        if(accCon.PRM_Relationship_Id__r.Name == System.Label.PRM_Primary_Contact || accCon.PRM_Relationship_Id__r.name == System.Label.PRM_Admin_Delegate){ // US760255 - UTKARSH - Added partner admin delegate as a recepient of upgrade emails.
                            if(!mapOFTierAndBusinessEvent.isEmpty() && updatedACMpartnerRole.contains(accCon.PRM_Contact_Id__r.Core_IPA_PartnerRole__c)){                                
                                contact c=new contact();
                                c.id=accCon.PRM_Contact_Id__c;
                                c.Email=accCon.PRM_Contact_Id__r.email;
                                PRM_EmailQueue__c emqu = new PRM_EmailQueue__c();
                                emqu.PRM_Business_Event__c = intelaccPartnerRoleMap!=null ?
                                    mapOFTierAndBusinessEvent.get(intelaccPartnerRoleMap.get(accCon.PRM_Account_Id__c))
                                    :mapOFTierAndBusinessEvent.get(accCon.PRM_Account_Id__r.Core_IPA_Badge_Tier__c);
                                emqu.PRM_Email_Content__c = '';
                                emqu.PRM_Contact__c = c.Id;
                                emqu.PRM_Status__c = System.Label.PRM_Pending;
                                emqu.PRM_Tier__c = intelaccPartnerRoleMap!=null ? intelaccPartnerRoleMap.get(accCon.PRM_Account_Id__c) : accCon.PRM_Account_Id__r.Core_IPA_Badge_Tier__c;
                                emqu.PRM_PartnerRole__c = accCon.PRM_Contact_Id__r.Core_IPA_PartnerRole__c;
                                emqu.PRM_Priority__c = 1;   
                                if(emailSuppressionMap.containsKey(accCon.PRM_Contact_Id__c)){
                                    suppressEmail=true; // Setting SuppressEmail Indicator 
                                    emailSuppressionMap.get(accCon.PRM_Contact_Id__c).PRM_Email_Handler_Status__c='Completed';
                                    emailSuppressionMap.get(accCon.PRM_Contact_Id__c).PRM_Email_Suppressed_Time__c=datetime.now();
                                    emailHandlersToUpdate.add(emailSuppressionMap.get(accCon.PRM_Contact_Id__c));
                                }
                                if(!emqList.contains(emqu)&& suppressEmail==false){                                 
                                    emqList.add(emqu);
                                    if (String.isNotBlank(accCon.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c)){
                                        trackers.add(PRM_IPA_Utility.createTrackerInstance('OPID Updates',
                                                                                           'UPGRADE_EMAIL',
                                                                                           null,
                                                                                           accCon.PRM_Account_Id__c,
                                                                                           accCon.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,
                                                                                           accCon.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,
                                                                                           '',
                                                                                           '',
                                                                                           true,
                                                                                           '',
                                                                                           ''
                                                                                          ));
                                    }
                                }
                            }
                        }                    
                        suppressEmail=false;//Reset SuppressEmail Indicator
                    }
                    //Update EmailHandler Details 
                    if(!emailHandlersToUpdate.isEmpty() && emailHandlersToUpdate!=null){
                        logEntryMsgString+='\n emailHandlersToUpdate: '+emailHandlersToUpdate;
                        PRM_Email_Handler_Utility.updateEmailHandlerDetails(emailHandlersToUpdate);
                    }
                }
                /* END - Send upgrade email to primary contact*/
                    
                try{  
                    if(emqList != null && !emqList.IsEmpty() && !system.isBatch()){
                        logEntryMsgString+='\n emqList: '+emqList;
                        insert emqList;
                        PRM_RegistrationApprovalEmail.sendWelcomeEmail(emqList);
                    }
                    if (!trackers.isEmpty()) {
                        insert trackers;
                    }
                }catch(Exception ex){logEntryMsgString+='\n Errors: '+ex.getmessage();    
                                    }
                /* END - Update status of VX record*/
            }
    }
    
    public static void AfterOperationsOnACM(List<PRM_AccountChannelMembership__c> acmList,Map<Id,PRM_AccountChannelMembership__c>oldMap, List<PRM_AccountChannelMembership__c> acmListQuery,List<Account> accList){
        logEntryMsgString+='\n Entered AfterOperationsOnACM';
        Set<Id> opidAndIntelAccRecList = new Set<Id>();
        List<Id> acmIdList = new List<Id>();
        Map<String,String> accandHighestTierMap = new Map<String,String>();
        List<Account> toUpdateAccList = new List<Account>();
        //Set<String> intelAndOPIDAccRecTypes = new Set<String>{System.Label.PRM_Intel_Account,System.Label.PRM_Partner_Account_Group_Record_Type};
        Id opidAccRecordType =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
        Id intelAccRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();  
        Id[] intelAndOPIDAccRecTypes = new Id[]{opidAccRecordType,intelAccRecType};
            Map<String,Integer> tierAndRankMap = new Map<String,Integer>{System.Label.PRM_Member => 1, System.Label.PRM_Tier_Gold => 2, System.Label.PRM_Tier_Titanium => 3};
                List<Id> acmAccountIDList = new List<Id>();
        Set<Id> accSet = new Set<Id>();
        List<Account> updateAcc = new List<Account>();
        Map<Id, Account> acctounsToUpdateMap = new Map<Id, Account>();
        List<Id> initialACMIdList = new List<Id>();
        List<PRM_AccountChannelMembership__c> initialACMRecordList = new List<PRM_AccountChannelMembership__c>();
        //List<Core_Account_Group_Member__c> initialPAGMRecordList = new List<Core_Account_Group_Member__c>();
        List<PRM_AccountChannelMembership__c> accACMsList;
        List<PRM_AccountChannelMembership__c> resaccACMsList;
        List<Id> inactivatedACMsAccIdList = new List<Id>();
        Map<Id, List<PRM_AccountChannelMembership__c>> mapOfAccACMsList = new Map<Id,List<PRM_AccountChannelMembership__c>>(); 
        Map<Id, List<PRM_AccountChannelMembership__c>> resmapOfAccACMsList = new Map<Id,List<PRM_AccountChannelMembership__c>>(); 
        Map<Id,String> mapOfAccIdBadgeTier = new Map<Id,String>();
        Map<Id,String> resmapOfAccIdBadgeTier = new Map<Id,String>();
        Map<String, Decimal> mapOfBadgeNameTier = new Map<String, Decimal>();
        Map<String, Decimal> resmapOfBadgeNameTier = new Map<String, Decimal>();
        String highestTier = '';
        String accountBadgeTier = '';
        String reshighestTier = '';
        List<Account> accsToUpdate = new List<Account>();
        List<Account> resaccsToUpdate = new List<Account>();
        //List<Account> initialAccList = new List<Account>();
        List<Id> initialACCId = new List<Id>();
        Set<String> accountIds = new Set<String>();
        Set<String> contactIds = new Set<String>();
        Set<String> channelPrograms = new Set<String>();
        Set<String> cpLevels= new Set<String>();
        Set<Id> automaticBenefits = new Set<Id>();
        Set<String> partnerRole = new Set<String>(); 
        List<PRM_ContactSubscriptionAssociation__c> csaList = new List<PRM_ContactSubscriptionAssociation__c>();
        List<PRM_AccountBenefitAssociation__c> updateABAList = new List<PRM_AccountBenefitAssociation__c>();
        //List<Id> updateAccid = new List<Id>();
        boolean inactiveIPAAccount = false;
        boolean activeIPAAccount = false;
        boolean updateBatchTierRollup = false;
        boolean updateBatchTierRolldown = false;
        boolean inactiveABAandSubs = false;
        //boolean upsertOPIDACM = false;
        Set<Id> acmActiveAccountIDset = new Set<Id>(); //added by Teja Munagala 
        Set<Id> acmActiveIDset = new Set<Id>(); //added by Teja Munagala
        /*List<Account> accountIPAActive = new List<Account>();
        Map<Id,Account>accountIPAActiveset = new Map<Id,Account>();
        set<PRM_AccountChannelMembership__c> processACMID = new set<PRM_AccountChannelMembership__c>();*/
        Set<String>activeACMPartnerRole = new Set<String>();
        Set<Id>activeACMPartnerRoleBenefits = new Set<Id>();
        Set<String> cpl = new Set<String>{'Member','Gold','Titanium'};
            Set<Id> existingABA = new Set<Id>();
        Map<String, String> mapRoleandTier = new Map<String, String>();
        String benefittier;
        Map<Id,String> mapAcmPartnerRole = new Map<Id,String>();
        List<PRM_Account_Specialty_Association__c> updateChildASA = new List<PRM_Account_Specialty_Association__c>();
        List<PRM_IPA_Affiliation__c> updateChildAIA = new List<PRM_IPA_Affiliation__c>();
        List<Account> updateLocationAcc = new List<Account>();
        Set<Id> accPartnerSegment = new Set<Id>();
        /*Variables used for add logic in condition 4 */
        boolean inactivateOPIDACM = false;
        Set<Id> inactiveACMId = new Set<Id>();
        Set<Id> inactiveACMAccId = new Set<Id>();
        Set<String> inactiveACMPartnerrole = new Set<String>();
        Set<Id> parentAccId = new Set<Id>();
        Set<Id> childAccId = new Set<Id>();
        Map<Id,Id> mapLocationAccOpid = new Map<Id,Id>();
        Map<id,list<PRM_AccountChannelMembership__c>> mapOpidLoc = new Map<id,list<PRM_AccountChannelMembership__c>> () ; //TWC729-5005
        Map<id,set<string>> mapOpidEligBenefits = new Map<id,set<string>> () ; //TWC729-5005
        Map<string,set<string>> mapPartnerTierBenefits = new Map<string,set<string>> () ; //TWC729-5005
        //set<string> allEligBenefits = new set<string>() ; //TWC729-5005
        Set<Id> activeParentAccIdSet = new Set<Id>();
        List<PRM_AccountChannelMembership__c> updateOPIDACM = new List<PRM_AccountChannelMembership__c>();
        List<PRM_Account_Contact_Relationship__c> inactiveACRIdList = new List<PRM_Account_Contact_Relationship__c>();
        Map<Id, Map<String, String>> accountIdOldNewPartnerROleMap = new Map<Id, Map<String, String>>();
        //List<PRM_Account_Contact_Relationship__c> activeACRIdList = new List<PRM_Account_Contact_Relationship__c>();
        List<PRM_AccountChannelMembership__c> acmAccountList = new List<PRM_AccountChannelMembership__c>();
        List<Id> accountACMList = new List<Id>();
        //Set<Id> acrAccId = new Set<Id>();
        Set<String> activeACMPR = new Set<String>();
        Map<id, Account> mapAccountsToUpdate = new Map<id, Account>();
        List<Id> acrIdsToInactivate = new List<id>();
        //List<PRM_Account_Contact_Relationship__c> inactiveAllACRIdList;
        /*Variables used for add logic in condition 4  - END*/
        /*Start - Filtering based on conditions*/
        Set<String> actIdPartnerRole = new set<String>();
        Set<id> accountId = new Set<id>();
        //Set<Id>conPartRoleRemoveSet = new Set<Id>();
        List<Contact>contactsToUpdateList = new List<Contact>();
         Map<Id,String> actIdNewRole = new Map<Id,String>();
        if(Trigger.isAfter){
            PRM_AccountChannelMembership__c oldACM;
            for(PRM_AccountChannelMembership__c acm:acmList){
                if(oldMap!=null){
                    if(accountIdOldNewPartnerROleMap.size()>0 && accountIdOldNewPartnerROleMap.containskey(acm.PRM_Account_Id__c) && accountIdOldNewPartnerROleMap.get(acm.PRM_Account_Id__c)!=null ){                   
                        accountIdOldNewPartnerROleMap.get(acm.PRM_Account_Id__c).put(acm.PRM_Partner_Role__c,oldMap.get(acm.Id).PRM_Partner_Role__c);
                    }else{
                        accountIdOldNewPartnerROleMap.put(acm.PRM_Account_Id__c,new Map<String, String>{acm.PRM_Partner_Role__c=>oldMap.get(acm.Id).PRM_Partner_Role__c});
                    }
                }
                if(oldMap!=null && oldMap.get(acm.Id).PRM_Partner_Role__c!=acm.PRM_Partner_Role__c){
                    accountId.add(acm.PRM_Account_Id__c);// storing account ids
                    actIdPartnerRole.add(acm.PRM_Account_Id__c+'-'+acm.PRM_Partner_Role__c);
                     actIdNewRole.put(acm.PRM_Account_Id__c,acm.PRM_Partner_Role__c);
                }
                //------------------
                initialACMIdList.add(acm.Id);
                //PRM_AccountChannelMembership__c oldACM;
                if(oldMap != null && oldMap.size() > 0){
                    oldACM = (PRM_AccountChannelMembership__c) oldMap.get(acm.Id);
                }
                //condition - 1 - Update Badge tier when manual or OPID upgrade take place rollup.
                if((oldMap == null) || ((oldMap != null && oldMap.size() > 0) && ((acm.PRM_Channel_Program_Level_Id__c != oldACM.PRM_Channel_Program_Level_Id__c) || ((oldACM.PRM_Status_Nm__c != System.Label.PRM_Status) && (acm.PRM_Status_Nm__c == System.Label.PRM_Status))))){
                    acmIdList.add(acm.Id);
                    updateBatchTierRollup = true;
                }
                //condition - 2 - Update Badge tier when manual or OPID upgrade take place rolldown.
                if(acm.PRM_Status_Nm__c == System.label.PRM_Status_Inactive && oldMap != null && oldMap.containsKey(acm.Id) && oldMap.get(acm.id).PRM_Status_Nm__c != acm.PRM_Status_Nm__c){
                    inactivatedACMsAccIdList.add(acm.PRM_Account_Id__c);
                    updateBatchTierRolldown = true;                 
                }
                //condition - 3 - Inactivate IPA Account.
                if(oldACM != null && (oldACM.PRM_Status_Nm__c != acm.PRM_Status_Nm__c && acm.PRM_Status_Nm__c != System.Label.PRM_Status)){
                    inactiveIPAAccount = true;
                    acmAccountIDList.add(acm.PRM_Account_Id__c);
                }
                //condition - 4 - Inactivate ABA records on account and inactive subscriptions.
                if(oldACM != null && (oldACM.PRM_Status_Nm__c != acm.PRM_Status_Nm__c && acm.PRM_Status_Nm__c == System.label.PRM_Status_Inactive)){
                    inactiveABAandSubs = true;
                    inactiveACMId.add(acm.Id);
                    accountIds.add(acm.PRM_Account_Id__c);
                    channelPrograms.add(acm.PRM_Channel_Program_Id__c);
                    cpLevels.add(acm.PRM_Channel_Program_Level_Id__c);
                    partnerRole.add(acm.PRM_Partner_Role__c);
                }
                //condition  - 5 - Activate IPA Account. added by Teja Munagala
                if((oldACM == null && acm.PRM_Status_Nm__c == System.Label.PRM_Status )  || (oldACM != null && (oldACM.PRM_Status_Nm__c != acm.PRM_Status_Nm__c && acm.PRM_Status_Nm__c == System.Label.PRM_Status))){
                    activeIPAAccount=true;
                    acmActiveAccountIDset.add(acm.PRM_Account_Id__c);
                    activeACMPR.add(acm.PRM_Partner_Role__c);
                    acmActiveIDset.add(acm.id);
                }
            }
            /*END - Filtering based on conditions*/
            //added by dinesh
            // get the account details
            Map<Id, List<String>> actIdBizTypes = new Map<Id, List<String>>();
            Map<Id, List<String>> actIdPartnerRoles = new Map<Id, List<String>>();
            Map<id,account> accountDetailsMap = new Map<Id,Account>();
            if(accountId!=null && !accountId.isEmpty()){
                for(Account accRecord : acclist){
                    List<String> bizTypes = new List<String>();
                    List<String> roles = new List<String>();
                    if(!String.isEmpty(accRecord.Core_Account_Type__c)){
                        bizTypes = accRecord.Core_Account_Type__c.split(';');
                    }
                    
                    if(!String.isEmpty(accRecord.Core_IPA_Partner_Role__c)){
                        roles = accRecord.Core_IPA_Partner_Role__c.split(';');
                    }
                    
                    actIdBizTypes.put(accRecord.id, bizTypes);
                    actIdPartnerRoles.put(accRecord.id, roles);
                    accountDetailsMap.put(accRecord.id,accRecord);
                }
                //Added by Chaithaly aspartof IPARefresh to update partnerroles in contact if ACM Role is updated
                 if(accountIdOldNewPartnerROleMap != null){
                for(PRM_Account_Contact_Relationship__c acr : [Select Id,PRM_Account_Id__c,PRM_Contact_Id__c,PRM_Contact_Id__r.Core_IPA_PartnerRole__c, PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :accountId and PRM_InActive_Ind__c = false]){
                    String newRole = actIdNewRole.get(acr.PRM_Account_Id__c);
                    String oldRole = accountIdOldNewPartnerROleMap.get(acr.PRM_Account_Id__c).get(newRole);
                   if(acr.PRM_Contact_Id__r.Core_IPA_PartnerRole__c == oldRole && acr.PRM_Contact_Id__r.Core_IPA_PartnerRole__c != newRole){
                                                Contact con = new Contact();
                                                con.id = acr.PRM_Contact_Id__c;
                                                con.Core_IPA_PartnerRole__c = newRole;
                                                if(!contactsToUpdateList.contains(con)){
                                                    contactsToUpdateList.add(con);
                                                }
                    }

                }
                }
            }
            // get the metedata default mapping
            Map<String, String> defaultPartnerRoleBizType = new Map<String, String>();
            
            for(PRM_PartnerRoleTypeMappings__mdt mdt : [Select Id,Label,PRM_Partner_Role__c,PRM_Biz_Org_Type__c from PRM_PartnerRoleTypeMappings__mdt where Grouping_Method__c != null]){               
                defaultPartnerRoleBizType.put(mdt.PRM_Partner_Role__c,mdt.PRM_Biz_Org_Type__c);
            }
            // update account with new values
            
            Map<id, Account> accountsToBeUpdated =  new Map<Id, Account>();
            Map<Id, Account> allInitialAccMap = new Map<Id, Account>();
            
            //if(actIdPartnerRole!=null && !actIdPartnerRole.isEmpty()){
            for(String record :  actIdPartnerRole){
                String accId = record.split('-')[0];
                String newRole = record.split('-')[1];
                String bizType = defaultPartnerRoleBizType.get(newRole);
                
                if(accountDetailsMap.size()>0 && accountDetailsMap.containsKey(accId)){ 
                    Account a = accountDetailsMap.get(accId);                            
                       // if(!ipaRefresh || Test.isRunningTest()) a.Core_Account_Type__c=(actIdBizTypes!=null && actIdBizTypes.containsKey(accId) && actIdBizTypes.get(accId).contains(bizType))?a.Core_Account_Type__c:a.Core_Account_Type__c+';'+bizType; // IPA Switch Removal
                       a.Core_Account_Type__c=a.Core_Account_Type__c+';'+bizType;
                    if(actIdPartnerRoles.size()>0 ){
                        if(actIdPartnerRoles.containsKey(accId) && actIdPartnerRoles.get(accId).contains(newRole)){                                    
                            a.Core_IPA_Partner_Role__c = a.Core_IPA_Partner_Role__c;
                        }
                        else if(actIdPartnerRoles.containsKey(accId) && accountIdOldNewPartnerROleMap.size()>0 && actIdPartnerRoles.get(accId).contains(accountIdOldNewPartnerROleMap.get(accId).get(newRole))){
                            a.Core_IPA_Partner_Role__c = string.valueOf(a.Core_IPA_Partner_Role__c).replace(accountIdOldNewPartnerROleMap.get(accId).get(newRole), newRole);
                        }else{
                            a.Core_IPA_Partner_Role__c = newRole;//a.Core_IPA_Partner_Role__c+';'+
                        }
                        
                    }else{
                        a.Core_IPA_Partner_Role__c = a.Core_IPA_Partner_Role__c+';'+newRole;
                    }
                    accountsToBeUpdated.put(a.Id, a);
                    
                }
            }
            //}
            
            
            logEntryMsgString+='\nAfterOperationsOnACM accountsToBeUpdated:'+accountsToBeUpdated;
            Database.SaveResult [] srList = Database.update(accountsToBeUpdated.values(), false);
            for(Database.SaveResult sr: srList){
                if(!sr.isSuccess()){
                    for (Database.Error err : sr.getErrors()) {
                                logEntryMsgString+= 'Message: ' + err.getMessage() + '\n'
                                                + 'Fields: ' + err.Fields.toString() + '\n'
                                                + 'StatusCode: ' + err.getStatusCode() + '\n';
                            }
                }
            }
            
            
            Map<id, Account> accountMap = new Map<Id, Account>();
            Map<Id, List<String>> mapOfInactiveAccPartnerRole = new Map<Id, List<String>>();
            //---- End 
            /*Start - Required query on objects to use later in the method*/
            if(initialACMIdList != null && !initialACMIdList.IsEmpty()){                                        
                initialACMRecordList = [Select Id,Name,PRM_Account_Id__r.Core_IPA_Partner_Segment__c,PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, PRM_Account_Id__r.Core_IPA_Badge_Tier__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c, PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,PRM_Account_Id__r.recordType.DeveloperName From PRM_AccountChannelMembership__c Where Id IN :initialACMIdList];
                for(PRM_AccountChannelMembership__c acm :initialACMRecordList){
                    initialACCId.add(acm.PRM_Account_Id__c);
                    
                    if(inactivatedACMsAccIdList.contains(acm.PRM_Account_Id__c)){
                        /*if(!accountMap.containsKey(acm.PRM_Account_Id__c) && !ipaRefresh){
                            Account acc = new Account();
                            acc.id = acm.PRM_Account_Id__c;                            
                           // if(!ipaRefresh || Test.isRunningTest())acc.Core_IPA_Partner_Segment__c = acm.PRM_Account_Id__r.Core_IPA_Partner_Segment__c;
                            accountMap.put(acc.id, acc);
                        }*/ // IPA Switch Removal
                        
                        if(mapOfInactiveAccPartnerRole.containsKey(acm.PRM_Account_Id__c)){
                            mapOfInactiveAccPartnerRole.get(acm.PRM_Account_Id__c).add(acm.PRM_Partner_Role__c);
                        }else{                          
                            List<String> roleList = new List<String>();
                            roleList.add(acm.PRM_Partner_Role__c);
                            mapOfInactiveAccPartnerRole.put(acm.PRM_Account_Id__c, roleList);
                        }
                        
                    }
                    
                    if(!allInitialAccMap.containsKey(acm.PRM_Account_Id__c)){
                        Account acc = new Account();    
                        acc.id = acm.PRM_Account_Id__c;
                        acc.Core_IPA_Badge_Tier__c = acm.PRM_Account_Id__r.Core_IPA_Badge_Tier__c;
                        acc.PRM_IPA_Badge_Tier_Date__c = System.now();
                        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c;                        
                        //if(!ipaRefresh || Test.isRunningTest())acc.Core_IPA_Partner_Segment__c = acm.PRM_Account_Id__r.Core_IPA_Partner_Segment__c;
                        allInitialAccMap.put(acc.id, acc);
                    }
                }
            }
            /*(updateBatchTierRollup || updateBatchTierRolldown){

initialPAGMRecordList = [Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c From Core_Account_Group_Member__c];
}*/

            List<ChannelProgramLevel> oldCPL = new List<ChannelProgramLevel>();
            Map<Id, String> tierIdNames = new Map<Id, String>();
            for(ChannelProgramLevel record : [SELECT Id, Name FROM ChannelProgramLevel WHERE Program.PRM_programCode__c = 'IPA']) {
                tierIdNames.put(record.Id, record.Name);
                if(oldACM!=null && record.id == oldACM.PRM_Channel_Program_Level_Id__c){
                    oldCPL.add(record);
                }
            }
            /*END - Required query on objects to use later in the method*/
            /*Start - condition-1, Developer - Bharath*/
            if(updateBatchTierRollup){
                if(initialACMRecordList != null && !initialACMRecordList.IsEmpty()){
                    List<Id> accIdsForRollDown = new List<Id>();
                    for(PRM_AccountChannelMembership__c acm :initialACMRecordList){
                        if(acmIdList!= null && !acmIdList.IsEmpty()){
                            if(acmIdList.contains(acm.Id) && intelAndOPIDAccRecTypes.contains(acm.PRM_Account_Id__r.RecordTypeId) && acm.PRM_Status_Nm__c == System.Label.PRM_Status){
                                opidAndIntelAccRecList.add(acm.PRM_Account_Id__c);
                                if((oldCPL != null && oldCPL.size() > 0) && tierAndRankMap.get(acm.PRM_Channel_Program_Level_Id__r.Name) < tierAndRankMap.get(oldCPL[0].Name) && oldACM.PRM_Status_Nm__c == acm.PRM_Status_Nm__c){
                                    accIdsForRollDown.add(acm.PRM_Account_Id__c);
                                }
                            }
                        }
                    }
                     /*if(!accIdsForRollDown.isEmpty() && !rtaRun && (!ipaRefresh || test.isRunningTest())){
                        assignBenefitsOnRollDown(accIdsForRollDown,tierIdNames);
                    } */ // IPA Switch Removal
                }
                if(opidAndIntelAccRecList!=null && !opidAndIntelAccRecList.IsEmpty()){// Fetch location account from opid account when upgrade teakes place
                    //for(Core_Account_Group_Member__c agm :initialPAGMRecordList){
                    for(Core_Account_Group_Member__c agm :[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where (Core_Partner_Account_Id__c IN :opidAndIntelAccRecList or Core_Intel_Account_Id__c IN :opidAndIntelAccRecList) AND Core_Inactive_Ind__c = false]){
                        // if(opidAndIntelAccRecList.contains(agm.Core_Partner_Account_Id__c)){ 
                        opidAndIntelAccRecList.add(agm.Core_Intel_Account_Id__c);
                        opidAndIntelAccRecList.add(agm.Core_Partner_Account_Id__c);
                        /*}else if(opidAndIntelAccRecList.contains(agm.Core_Intel_Account_Id__c)){
opidAndIntelAccRecList.add(agm.Core_Partner_Account_Id__c);    
} */
                    }
                }
                /*
                if(opidAndIntelAccRecList!=null && !opidAndIntelAccRecList.IsEmpty()){ // Fetch opid from location account when opid get activated 
                    //for(Core_Account_Group_Member__c agm :initialPAGMRecordList){
                    for(Core_Account_Group_Member__c agm :[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Intel_Account_Id__c IN :opidAndIntelAccRecList AND Core_Inactive_Ind__c = false]){
                        //if(opidAndIntelAccRecList.contains(agm.Core_Partner_Account_Id__c)){
                        opidAndIntelAccRecList.add(agm.Core_Partner_Account_Id__c);
                        //}
                    }
                } 
                */
                if(opidAndIntelAccRecList!=null && !opidAndIntelAccRecList.IsEmpty()){
                    List<PRM_AccountChannelMembership__c> opidAcmRecList = [SELECT Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Badge_Tier__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN :opidAndIntelAccRecList and PRM_Account_Id__r.RecordTypeId IN:intelAndOPIDAccRecTypes and PRM_Status_Nm__c = :System.Label.PRM_Status];
                    if(opidAcmRecList!=null && !opidAcmRecList.IsEmpty()){
                        for(PRM_AccountChannelMembership__c acm:opidAcmRecList){ 
                            if(accandHighestTierMap.containsKey(acm.PRM_Account_Id__c)){
                                Integer currentRank = tierAndRankMap.get(accandHighestTierMap.get(acm.PRM_Account_Id__c));
                                if(currentRank < tierAndRankMap.get(acm.PRM_Channel_Program_Level_Id__r.Name)){accandHighestTierMap.put(acm.PRM_Account_Id__c,acm.PRM_Channel_Program_Level_Id__r.Name);
                                                                                                              }
                            }else{
                                if(!accandHighestTierMap.containsKey(acm.PRM_Account_Id__c)){
                                    accandHighestTierMap.put(acm.PRM_Account_Id__c,acm.PRM_Channel_Program_Level_Id__r.Name);
                                }
                            }
                        }
                    }
                }
                //IPA Refresh 2.0 - TWC729-8102  
                Map<Id,Core_Account_Group_Member__c> mapIntelAccCAG = new Map<Id,Core_Account_Group_Member__c>();
                for(Core_Account_Group_Member__c cag:[SELECT id,Core_Partner_Account_Id__c,Core_Intel_Account_Id__c,Primary_Account__c,Core_Inactive_Ind__c,UCD_Hierarchy__c,Core_Intel_Account_Id__r.Core_Unified_Global_Customer_Name__c FROM Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__c IN: opidAndIntelAccRecList AND Core_Inactive_Ind__c = FALSE AND UCD_Hierarchy__c =: System.label.PRM_Global_Customer]){
                    mapIntelAccCAG.put(cag.Core_Partner_Account_Id__c,cag);
                }  
                //IPA Refresh 2.0 - TWC729-8102  -- end
                
                if(opidAndIntelAccRecList!=null && !opidAndIntelAccRecList.IsEmpty()){                   
                    List<Account> allOPIDaccs = [Select Id,Name,Core_IPA_Badge_Tier__c,RecordTypeId from Account where Id IN:opidAndIntelAccRecList and RecordTypeId IN:intelAndOPIDAccRecTypes];
                    for(Account acc : allOPIDaccs){
                        // for(Account acc: accMap.values()){
                        if(accandHighestTierMap!=null && !accandHighestTierMap.IsEmpty() && !badgeTierUpdatedAccounts.contains(acc.id) && acc.Core_IPA_Badge_Tier__c !=accandHighestTierMap.get(acc.Id) && accandHighestTierMap.containsKey(acc.Id)){
                                Account accToUpdate = acctounsToUpdateMap.containsKey(acc.id)? acctounsToUpdateMap.get(acc.id): new Account();
                                
                                accToUpdate.Core_IPA_Badge_Tier__c = accandHighestTierMap.get(acc.Id);
                                accToUpdate.PRM_IPA_Badge_Tier_Date__c = System.now();
                                accToUpdate.id = acc.id;

                                //IPA Refresh 2.0 - TWC729-8102
                                accToUpdate.Core_Deactivated__c = FALSE;
                                if(mapIntelAccCAG.containsKey(acc.id)){
                                    accToUpdate.UCD_Primary_Account__c = mapIntelAccCAG.get(acc.id).Core_Intel_Account_Id__c;
                                    accToUpdate.Name = mapIntelAccCAG.get(acc.id).Core_Intel_Account_Id__r.Core_Unified_Global_Customer_Name__c+' - Global';
                                    accToUpdate.Core_PAG_Grouping_Method__c = 'GLBL';
                                }
                                //IPA Refresh 2.0 - TWC729-8102  -- end

                                toUpdateAccList.add(accToUpdate);
                                acctounsToUpdateMap.put(accToUpdate.id, accToUpdate);
                            badgeTierUpdatedAccounts.add(acc.id);
                        }
                    }
                }
                if(toUpdateAccList != null && !toUpdateAccList.IsEmpty()){
                 /*   if(!System.isBatch()){
                        Schema.SObjectType acc = Schema.Account.getSObjectType();
                        System.enqueueJob(new ContactERPMIntegrationStatusHandler(toUpdateAccList,acc));
                    }
                    else */if(System.isBatch()){
                        logEntryMsgString+='\n toUpdateAccList: '+toUpdateAccList;
                        update toUpdateAccList;
                                             }  
                }
            }
            /*END -condition-1*/
            /*Start - condition-2, Developer - SABA*/
            
            
            if(trigger.Isupdate && updateBatchTierRolldown){
                if(inactivatedACMsAccIdList!=null && !inactivatedACMsAccIdList.IsEmpty()){
                    for(Core_Account_Group_Member__c agm :[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Intel_Account_Id__c IN :inactivatedACMsAccIdList AND Core_Inactive_Ind__c = false]){
                        inactivatedACMsAccIdList.add(agm.Core_Partner_Account_Id__c);
                    }
                }
                if(inactivatedACMsAccIdList != null && !inactivatedACMsAccIdList.IsEmpty()){
                    acmAccountList = [Select Id, PRM_Account_Id__c,PRM_Account_Id__r.RecordType.Name, PRM_Account_Id__r.Core_IPA_Partner_Segment__c,PRM_Account_Id__r.Core_IPA_Badge_Tier__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Status_Nm__c,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN:inactivatedACMsAccIdList and PRM_Status_Nm__c = :System.label.PRM_Status];
                    for(PRM_AccountChannelMembership__c acm: acmAccountList ){
                        if(mapOfInactiveAccPartnerRole.containsKey(acm.PRM_Account_Id__c)){
                            mapOfInactiveAccPartnerRole.get(acm.PRM_Account_Id__c).add(acm.PRM_Partner_Role__c);
                        }else{                          
                            List<String> roleList = new List<String>();
                            roleList.add(acm.PRM_Partner_Role__c);
                            mapOfInactiveAccPartnerRole.put(acm.PRM_Account_Id__c, roleList);
                        }
                        
                        mapOfAccIdBadgeTier.put(acm.PRM_Account_Id__c, acm.PRM_Account_Id__r.Core_IPA_Badge_Tier__c);
                        if(mapOfAccACMsList.containsKey(acm.PRM_Account_Id__c)){
                            accACMsList = mapOfAccACMsList.get(acm.PRM_Account_Id__c);
                        }else{
                            accACMsList = new List<PRM_AccountChannelMembership__c>();
                        }
                        accACMsList.add(acm);
                        mapOfAccACMsList.put(acm.PRM_Account_Id__c,accACMsList);
                        
                        if(acm.PRM_Account_Id__r.RecordType.Name == 'Partner Account Group' && accountIds.contains(acm.PRM_Account_Id__c)){
                          if(mapOpidLoc.containsKey(acm.PRM_Account_Id__c)){
                                // This Map will have parent , list of cag.
                                List<PRM_AccountChannelMembership__c> acmRecords = mapOpidLoc.get(acm.PRM_Account_Id__c);
                                acmRecords.add(acm);
                                mapOpidLoc.put(acm.PRM_Account_Id__c, acmRecords);
                            }
                            else{
                                mapOpidLoc.put(acm.PRM_Account_Id__c,new List<PRM_AccountChannelMembership__c>{acm}) ;
                            }       
                        }
                    }
                }
                if(updateBatchTierRolldown){
                  for(String bageMapping :LabelConfiguration__mdt.getInstance('ChannelProgramLevelRanking').Value__c.split(';')){ 
                      List<String> progTier = bageMapping.split(':');
                      mapOfBadgeNameTier.put(progTier[0],Integer.valueOf(progTier[1]));        
                    }
                }
                if(inactivatedACMsAccIdList != null && !inactivatedACMsAccIdList.IsEmpty()){
                    for(Id accId: inactivatedACMsAccIdList){
                        if(!mapOfAccACMsList.containskey(accId)){
                            Account accToUpdate = acctounsToUpdateMap.containsKey(accId)? acctounsToUpdateMap.get(accId): new Account();
                            accToUpdate.Core_IPA_Badge_Tier__c = '';
                            accToUpdate.PRM_IPA_Badge_Tier_Date__c = null;
                            System.debug('JB-- tier and date is balnk of acc(line1723): '+accToUpdate);
                                       // if(!ipaRefresh || Test.isRunningTest())accToUpdate.Core_IPA_Partner_Segment__c = '';
                            accToUpdate.Id = accId;
                            acctounsToUpdateMap.put(accToUpdate.id, accToUpdate);  
                            if(!accsToUpdate.contains(accToUpdate)){
                                accsToUpdate.add(accToUpdate);
                            }
                        }                    
                    }
                }
                if(mapOfAccACMsList != null && !mapOfAccACMsList.IsEmpty()){
                    for(Id accId: mapOfAccACMsList.keyset()){
                        accACMsList = mapOfAccACMsList.get(accId);
                        accountBadgeTier = mapOfAccIdBadgeTier.get(accId);
                        if(accACMsList == null || accACMsList.isEmpty()){ Account accToUpdate = acctounsToUpdateMap.containsKey(accId)? acctounsToUpdateMap.get(accId): new Account();                                                                      
                                                                         accToUpdate.Core_IPA_Badge_Tier__c = '';
                                                                         accToUpdate.PRM_IPA_Badge_Tier_Date__c = null;
                                                                         accToUpdate.id = accId;
                                                                         acctounsToUpdateMap.put(accToUpdate.id, accToUpdate);                                                                        
                                                                         if(!accsToUpdate.contains(accToUpdate)){accsToUpdate.add(accToUpdate);
                                                                                                        } 
                                                                        }
                        highestTier = null;
                        for(PRM_AccountChannelMembership__c acm: accACMsList){
                            if(String.isBlank(highestTier)){
                                highestTier = acm.PRM_Channel_Program_Level_Id__r.Name;
                            }else if(mapOfBadgeNameTier.get(highestTier) > mapOfBadgeNameTier.get(acm.PRM_Channel_Program_Level_Id__r.Name)){highestTier = acm.PRM_Channel_Program_Level_Id__r.Name;                                      
                                                                                                                                            }
                        }
                        if(accountBadgeTier != highestTier){                            
                            Account accToUpdate = acctounsToUpdateMap.containsKey(accId)? acctounsToUpdateMap.get(accId): new Account();Account acc = new Account();
                            accToUpdate.Core_IPA_Badge_Tier__c = highestTier;
                            accToUpdate.PRM_IPA_Badge_Tier_Date__c = System.now();
                            accToUpdate.Id = accId;
                            acctounsToUpdateMap.put(accToUpdate.id, accToUpdate);
                            if(!accsToUpdate.contains(accToUpdate)){accsToUpdate.add(accToUpdate);
                                                           }    
                        }
                    }
                }
                
                
                if(accsToUpdate != null && !accsToUpdate.IsEmpty()){                    
                   /* if(!System.isBatch()){                        
                        acctounsToUpdateMap.putAll(accsToUpdate);
                    }
                    else */if(System.isBatch()){
                        logEntryMsgString+='\n accsToUpdate: '+accsToUpdate;
                        update accsToUpdate;
                                             }
                }
            }
            /*END -condition-2*/
            /*Start - condition-3, Developer - UTKARSH*/
            if(trigger.Isupdate && inactiveIPAAccount){
                if(acmAccountIDList!=null && !acmAccountIDList.IsEmpty()){
                    //Commenting below code for fixing SOQL issue TWC729-4591, used existing ACM query above to get ACM values
                    // for(PRM_AccountChannelMembership__c acm :[SELECT Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN :acmAccountIDList and PRM_Status_Nm__c =:System.Label.PRM_Status and PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c=TRUE]){
                    for(PRM_AccountChannelMembership__c  acm : acmAccountList){
                        if(acmAccountIDList.contains(acm.PRM_Account_Id__c) && acm.PRM_Status_Nm__c ==System.Label.PRM_Status)
                        {
                            accountACMList.add(acm.PRM_Account_Id__c);
                        }
                    }
                    
                    for(PRM_AccountChannelMembership__c acm: initialACMRecordList){  
                        if(acmAccountIDList.contains(acm.PRM_Account_Id__c) && acm.PRM_Status_Nm__c ==System.Label.PRM_Status && acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c==TRUE){
                            accSet.add(acm.PRM_Account_Id__c);
                        }
                    }
                }
                if(initialACCId!=null && !initialACCId.IsEmpty()){
                    //Commenting below code for fixing SOQL issue TWC729-4591, used existing ACM query above to get Account values
                    //for(Account acc :[Select Id,Name,Core_Intel_Partner_Alliance_PartnerGroup__c,RecordType.DeveloperName,RecordTypeId From Account Where Id IN :initialACCId]){
                    for(Account acc: allInitialAccMap.values()){
                        if(acmAccountIDList!=null && !acmAccountIDList.IsEmpty() && acmAccountIDList.contains(acc.Id) && ((accountACMList==null || accountACMList.IsEmpty()) || !accountACMList.contains(acc.Id)) && ((accSet==null || accSet.IsEmpty()) || !accSet.contains(acc.Id))){
                            if(acctounsToUpdateMap.containsKey(acc.Id)){
                                acctounsToUpdateMap.get(acc.Id).Core_Intel_Partner_Alliance_PartnerGroup__c = false;
                                allInitialAccMap.get(acc.Id).Core_Intel_Partner_Alliance_PartnerGroup__c = false;
                            } else{acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
                                    updateAcc.add(acc);
                                }
                        }
                    }
                }
                if(updateAcc != null && !updateAcc.IsEmpty()){acctounsToUpdateMap.putAll(updateAcc);
                                                             }  
            }
            //DE97259: update account
          /*  if(acctounsToUpdateMap != null && !acctounsToUpdateMap.IsEmpty()){                    
                if(!System.isBatch()){
                    Schema.SObjectType acc = Schema.Account.getSObjectType();
                    System.enqueueJob(new ContactERPMIntegrationStatusHandler(acctounsToUpdateMap.values(),acc));
                }
            }*/
            
            /*END -condition-3*/
            /*Start - condition-4, Developer - UTKARSH*/
            if(trigger.Isupdate && inactiveABAandSubs){ 
                for(PRM_AccountChannelMembership__c acm: initialACMRecordList){
                    if(inactiveACMId.contains(acm.id)){      
                        mapAcmPartnerRole.put(acm.PRM_Account_Id__c,acm.PRM_Partner_Role__c);
                        //if(acm.PRM_Channel_Program_Level_Id__r.Name == System.Label.PRM_Channel_Program_Level){
                        inactivateOPIDACM = true;
                        inactiveACMAccId.add(acm.PRM_Account_Id__c);
                        inactiveACMPartnerrole.add(acm.PRM_Partner_Role__c);                        
                        //}
                    }
                }   
                //Set<Id> updateOPIDACMIDList=new Set<Id>();               
                Set<Id> locationAccount = new Set<Id>();             
                if(inactivateOPIDACM){
                    if(inactiveACMAccId != null && !inactiveACMAccId.IsEmpty()){ //Fetching parent account id.
                        for(Core_Account_Group_Member__c agm : [Select Id,Name,Core_Partner_Account_Id__c, Core_Partner_Account_Id__r.Core_IPA_Partner_Segment__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where (Core_Intel_Account_Id__c IN :inactiveACMAccId or Core_Partner_Account_Id__c IN:inactiveACMAccId) AND Core_Inactive_Ind__c = false]){
                            parentAccId.add(agm.Core_Partner_Account_Id__c);
                            locationAccount.add(agm.Core_Intel_Account_Id__c);
                            Account opidAcc = new Account();
                            opidAcc.id = agm.Core_Partner_Account_Id__c;                            
                                               // if(!ipaRefresh || Test.isRunningTest())opidAcc.Core_IPA_Partner_Segment__c = agm.Core_Partner_Account_Id__r.Core_IPA_Partner_Segment__c;
                            accountMap.put(opidAcc.id, opidAcc);
                        }
                    } 
                    if(parentAccId != null && !parentAccId.IsEmpty()){ //Fetching other child accounts id from the parent accounts.
                        for(Core_Account_Group_Member__c agm : [Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c,Core_Inactive_Ind__c From Core_Account_Group_Member__c Where Core_Partner_Account_Id__c IN :parentAccId AND Core_Inactive_Ind__c = false]){
                            childAccId.add(agm.Core_Intel_Account_Id__c);
                            mapLocationAccOpid.put(agm.Core_Intel_Account_Id__c,agm.Core_Partner_Account_Id__c);
                        }
                    }
                    if((childAccId != null && !childAccId.IsEmpty()) && (inactiveACMPartnerrole != null && !inactiveACMPartnerrole.IsEmpty())){ //Fetching parent account id if its child account has same ACM configuration present.
                        for(PRM_AccountChannelMembership__c acm :[Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c From PRM_AccountChannelMembership__c Where PRM_Account_Id__c IN :childAccId AND PRM_Partner_Role__c IN :inactiveACMPartnerrole AND PRM_Status_Nm__c =:System.Label.PRM_Status]){activeParentAccIdSet.add(mapLocationAccOpid.get(acm.PRM_Account_Id__c));
                                                                                                                                                                                                                                                                                                                                                                                                                                            }
                    }                    
                    // checking - if the sibling account does not have matching partner role then we could conclude this is the last ACM with this partner role for this OPID. Inacitvate the ACM at OPID. But try to avoid the recursion
                    if(parentAccId != null && !parentAccId.IsEmpty()){ //Inactivating ACM from parent account
                        for(PRM_AccountChannelMembership__c acm :[Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c From PRM_AccountChannelMembership__c Where  (PRM_Account_Id__c IN :parentAccId or PRM_Account_Id__c IN :locationAccount)  AND PRM_Status_Nm__c =:System.Label.PRM_Status]){
                            if(mapOfInactiveAccPartnerRole.containsKey(acm.PRM_Account_Id__c)){
                                mapOfInactiveAccPartnerRole.get(acm.PRM_Account_Id__c).add(acm.PRM_Partner_Role__c);
                            }else{
                                List<String> roleList = new List<String>();
                                roleList.add(acm.PRM_Partner_Role__c);
                                mapOfInactiveAccPartnerRole.put(acm.PRM_Account_Id__c, roleList);
                            }
                            if(((activeParentAccIdSet == null || activeParentAccIdSet.IsEmpty()) || !activeParentAccIdSet.contains(acm.PRM_Account_Id__c)) || ((locationAccount.contains(acm.PRM_Account_Id__c) && inactiveACMPartnerrole.contains(acm.PRM_Partner_Role__c)))){
                                if(inactiveACMPartnerrole.contains(acm.PRM_Partner_Role__c)){
                                    acm.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
                                    acm.PRM_Status_Reason_Txt__c = 'Inactivating ACM as no child has ACM with this partner role' ;//TWC729-8089 : Adding reason text : NJ
                                    updateOPIDACM.add(acm);
                                    inactiveACMAccId.add(acm.PRM_Account_Id__c);
                                }else{
                                    //TWC729-5005
                                    if(mapOpidLoc.keyset().contains(acm.PRM_Account_Id__c)){
                                        // This Map will have parent , list of cag.
                                        List<PRM_AccountChannelMembership__c> acmRecords = mapOpidLoc.get(acm.PRM_Account_Id__c);
                                        acmRecords.add(acm);
                                        mapOpidLoc.put(acm.PRM_Account_Id__c, acmRecords);
                                    }
                                    else{
                                        mapOpidLoc.put(acm.PRM_Account_Id__c,new List<PRM_AccountChannelMembership__c>{acm}) ;
                                    } 
                                    //TWC729-5005
                                }
                            }
                        }
                    }
                }
                //roll up OPID Account Partner Segment on inactivating Location Account ACM
                Map<String, List<String>> mapOfPartnerSegmentRole = getPartnerSegmentPartnerRoleMapping();
                Map<Id,Account> rolledUpAccountMap = new Map<Id,Account>();
                for(Id accId: inactiveACMAccId){
                    if(mapOfInactiveAccPartnerRole.containsKey(accId) && accountMap.containsKey(accId)){
                        Account acc = accountMap.get(accId);                                                       
                        List<String> partnerSegmentList = new List<String>();
                        if(String.IsNotBlank(acc.Core_IPA_Partner_Segment__c))
                            partnerSegmentList.addAll(acc.Core_IPA_Partner_Segment__c.split(';'));  
                        acc.Core_IPA_Partner_Segment__c = '';   
                        /*for(String partnerSeg: partnerSegmentList){
                                                if(mapOfPartnerSegmentRole.containsKey(partnerSeg) && mapOfPartnerSegmentRole.get(partnerSeg).Size() == 1 && !inactiveACMPartnerrole.contains(mapOfPartnerSegmentRole.get(partnerSeg)[0]) && !ipaRefresh){
                                acc.Core_IPA_Partner_Segment__c = acc.Core_IPA_Partner_Segment__c + ';' + partnerSeg;
                            }else
                                if(mapOfPartnerSegmentRole.containsKey(partnerSeg) && mapOfPartnerSegmentRole.get(partnerSeg).Size() > 1){                              
                                    for(String role: mapOfPartnerSegmentRole.get(partnerSeg)){
                                                        if(mapOfInactiveAccPartnerRole.get(accId).contains(role) && !inactiveACMPartnerrole.contains(role) && !ipaRefresh){
                                            acc.Core_IPA_Partner_Segment__c = String.isNotBlank(acc.Core_Account_Type__c) ? acc.Core_IPA_Partner_Segment__c + ';' + partnerSeg : partnerSeg;
                                    }
                                }        
                                }        
                        }*/ // IPA switch removal
                        
                        rolledUpAccountMap.put(acc.id, acc);   
                    }
                }
                //Added below Code as a Part of TWC729-1602 KIIT: Agate: Clear contact Partner role on membership inactivation - Vijay AGATE
                if(childAccId.size () > 0){
                    for(PRM_Account_Contact_Relationship__c acr : [Select Id,PRM_Account_Id__c,PRM_Contact_Id__c,PRM_Contact_Id__r.Core_IPA_PartnerRole__c, PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :childAccId]){
                        if((inactiveACMPartnerrole.contains(acr.PRM_Partner_Role__c) &&(inactiveACMAccId.contains(acr.PRM_Account_Id__c)) || (inactiveACMPartnerrole.contains(acr.PRM_Partner_Role__c) && acr.PRM_InActive_Ind__c == true)) && acr.PRM_Contact_Id__r.Core_IPA_PartnerRole__c != null) {
                            //conPartRoleRemoveSet.add(acr.PRM_Contact_Id__c);
                            Contact con = new Contact();
                            con.id = acr.PRM_Contact_Id__c;
                            con.Core_IPA_PartnerRole__c = ''; 
                            if(!contactsToUpdateList.contains(con)){
                                contactsToUpdateList.add(con);  
                            }
                        }
                    }  
                }else If(inactiveACMAccId.size() > 0){
                    for(PRM_Account_Contact_Relationship__c acr : [Select Id,PRM_Account_Id__c,PRM_Contact_Id__c,PRM_Contact_Id__r.Core_IPA_PartnerRole__c,PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :inactiveACMAccId]){
                        if((inactiveACMPartnerrole.contains(acr.PRM_Partner_Role__c) &&(inactiveACMAccId.contains(acr.PRM_Account_Id__c)) || (inactiveACMPartnerrole.contains(acr.PRM_Partner_Role__c) && acr.PRM_InActive_Ind__c == true)) && acr.PRM_Contact_Id__r.Core_IPA_PartnerRole__c != null) {
                            //conPartRoleRemoveSet.add(acr.PRM_Contact_Id__c);
                            Contact con = new Contact();
                            con.id = acr.PRM_Contact_Id__c;
                            con.Core_IPA_PartnerRole__c = ''; 
                            if(!contactsToUpdateList.contains(con)){
                                contactsToUpdateList.add(con);  
                            }
                        }
                    }  
                }
                
                /*US759862 - END*/
                /*US775822 -UTKARSH - Inactive ASA on location account when ACM become inactive*/
                /*if(accountIds != null && !accountIds.IsEmpty() && !PRM_ACMUpdateUtility.isRTAInitiated && (!ipaRefresh  || test.isrunningtest())){ //Inactivating ASA from Child account  //IPA2.0-TWC727-2861
                    for(PRM_Account_Specialty_Association__c asa :[Select Id,Name,PRM_Account_Id__c,PRM_Specialty_Id__c,PRM_Specialty_Id__r.Name,PRM_InActive_Ind__c,PRM_Partner_Role__c From PRM_Account_Specialty_Association__c Where PRM_Account_Id__c IN :accountIds]){
                        if(asa.PRM_Partner_Role__c == mapAcmPartnerRole.get(asa.PRM_Account_Id__c) && asa.PRM_InActive_Ind__c == false){asa.PRM_InActive_Ind__c = true;
                                                                                                                                        updateChildASA.add(asa);
                                                                                                                                       }
                    }
                }*/ // IPA Switch Removal
                /*US775822 - END*/

                //TWC729-7521 -NJ -Inactivate AIA on location account when ACM is inactivated
                if(accountIds != null && !accountIds.IsEmpty() && !PRM_ACMUpdateUtility.isRTAInitiated){ //Inactivating ASA from Child account
                    List<PRM_IPA_Affiliation__c> aiaList = [select id,PRM_Builder_Strategy__c, PRM_Account__c, PRM_Account__r.RecordTypeId,PRM_Active__c,PRM_Notes__c from PRM_IPA_Affiliation__c where PRM_Account__c in:accountIds and PRM_Active__c = true and PRM_Account__r.RecordTypeId=:intelAccRecType];
                    for(PRM_IPA_Affiliation__c aia :aiaList){
                        aia.PRM_Active__c = false;
                        aia.PRM_Notes__c = 'Inactivation as account has become Non IPA';//TWC729-8089 : Adding reason text : NJ
                        updateChildAIA.add(aia);
                    }
                }
                //TWC729-7521 - End


                if((accountIds != null && !accountIds.IsEmpty())){ //Fetching ABA records.
                    //Commenting below code for fixing SOQL issue TWC729-4591, used existing ACM query above to get ACM values
                    //for(PRM_AccountChannelMembership__c acm :[Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Account_Id__r.RecordTypeId,PRM_Status_Nm__c From PRM_AccountChannelMembership__c Where PRM_Account_Id__c IN :accountIds AND PRM_Status_Nm__c =:System.Label.PRM_Status]){
                    for(PRM_AccountChannelMembership__c acm: initialACMRecordList){ 
                        if(accountIds.contains(acm.PRM_Account_Id__c) && acm.PRM_Status_Nm__c ==System.Label.PRM_Status){
                            accPartnerSegment.add(acm.PRM_Account_Id__c);
                            activeACMPartnerRole.add(acm.PRM_Partner_Role__c);
                            mapRoleandTier.put(acm.PRM_Partner_Role__c,acm.PRM_Channel_Program_Level_Id__r.Name);
                        }
                    }
                }
                /*if(!ipaRefresh || test.isRunningTest()){
                if((cpLevels != null && !cpLevels.IsEmpty()) && (channelPrograms != null && !channelPrograms.IsEmpty())){ //Fetching benefit matrix records.
                    for(PRM_VXBnftMatrix__c bm :[Select Id,PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,PRM_Partner_Role_Nm__c,PRM_Channel_Program_Level_Id__r.Name From PRM_VXBnftMatrix__c Where PRM_Channel_Program_Id__c IN :channelPrograms and PRM_Partner_Role_Nm__c != null and PRM_Channel_Program_Level_Id__r.Name != null ]){
                        if(activeACMPartnerRole != null && activeACMPartnerRole.contains(bm.PRM_Partner_Role_Nm__c)){
                            benefittier =  mapRoleandTier.get(bm.PRM_Partner_Role_Nm__c);
                            if(bm.PRM_Channel_Program_Level_Id__r.Name == benefittier){
                                activeACMPartnerRoleBenefits.add(bm.PRM_Partner_Benefit_Id__c);
                            }
                        }
                        //TWC729-5005below map will have benefits based on role and tier combination
                        if(mapPartnerTierBenefits.ContainsKey(bm.PRM_Partner_Role_Nm__c.toUpperCase()+'_'+bm.PRM_Channel_Program_Level_Id__r.Name.toUpperCase())){
                            // This Map will have parent , list of cag.
                            set<string> bnftIds = mapPartnerTierBenefits.get(bm.PRM_Partner_Role_Nm__c.toUpperCase()+'_'+bm.PRM_Channel_Program_Level_Id__r.Name.toUpperCase());
                            bnftIds.add(bm.PRM_Partner_Benefit_Id__c);
                            mapPartnerTierBenefits.put(bm.PRM_Partner_Role_Nm__c.toUpperCase()+'_'+bm.PRM_Channel_Program_Level_Id__r.Name.toUpperCase(), bnftIds);
                        }
                        else{
                            mapPartnerTierBenefits.put(bm.PRM_Partner_Role_Nm__c.toUpperCase()+'_'+bm.PRM_Channel_Program_Level_Id__r.Name.toUpperCase(),new set<string>{bm.PRM_Partner_Benefit_Id__c}) ;
                        }  //TWC729-5005                                     
                    }                     
                    
                    // the below map will make sure that higher tier has all the benefits of lower tier
                    
                    for( string roleTier :    mapPartnerTierBenefits.keySet()){
                        String role = roleTier.split('_')[0];
                        String tier = roleTier.split('_')[1];
                        if(tier == 'MEMBER' ){
                            
                            
                            if(mapPartnerTierBenefits.containsKey(role+'_'+'GOLD')){
                                mapPartnerTierBenefits.get(role+'_'+'GOLD').addall(mapPartnerTierBenefits.get(roleTier));
                            }
                            if(mapPartnerTierBenefits.containsKey(role+'_'+'TITANIUM')){
                                mapPartnerTierBenefits.get(role+'_'+'TITANIUM').addall(mapPartnerTierBenefits.get(roleTier));
                            }
                        }
                        if(tier == 'GOLD' && mapPartnerTierBenefits.containsKey(role+'_'+'TITANIUM')){
                            mapPartnerTierBenefits.get(role+'_'+'TITANIUM').addall(mapPartnerTierBenefits.get(roleTier));
                        }
                        
                    }  
                }
                //TWC729-5005
                //Iterating over OPID to get all the eligible benefits for the OPID even though one of it's acm is inactive
                for(id opidId : mapOpidLoc.keyset()){
                    for(PRM_AccountChannelMembership__c acmList1 : mapOpidLoc.get(opidId)){
                        
                        if(mapOpidEligBenefits.keyset().contains(acmList1.PRM_Account_Id__c)){
                            // This Map will have parent , list of cag.
                            set<string> bnftIds = mapOpidEligBenefits.get(acmList1.PRM_Account_Id__c);
                            bnftIds.addall(mapPartnerTierBenefits.get(acmList1.PRM_Partner_Role__c.toUpperCase()+'_'+acmList1.PRM_Channel_Program_Level_Id__r.Name.toUpperCase()));
                            mapOpidEligBenefits.put(acmList1.PRM_Account_Id__c, bnftIds);
                        }
                        else{
                            mapOpidEligBenefits.put(acmList1.PRM_Account_Id__c,mapPartnerTierBenefits.get(acmList1.PRM_Partner_Role__c.toUpperCase()+'_'+acmList1.PRM_Channel_Program_Level_Id__r.Name.toUpperCase() )) ;
                        }  //TWC729-5005   
                        
                    }
                }
                //TWC729-5005
                if((accountIds != null && !accountIds.IsEmpty()) && (activeACMPartnerRoleBenefits != null && !activeACMPartnerRoleBenefits.IsEmpty())){ //Fetching ABA records.
                    for(PRM_AccountBenefitAssociation__c aba : [Select Id,Name,PRM_Account_Id__c,PRM_Partner_Benefit_Id__c,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c From PRM_AccountBenefitAssociation__c Where PRM_Account_Id__c IN :accountIds AND PRM_Partner_Benefit_Id__c IN :activeACMPartnerRoleBenefits]){existingABA.add(aba.PRM_Partner_Benefit_Id__c);
                                                                                                                                                                                                                                                                                                                  }
                }
                if((partnerRole != null && !partnerRole.IsEmpty()) && (channelPrograms != null && !channelPrograms.IsEmpty())){ //Fetching benefit matrix records.
                    for(PRM_VXBnftMatrix__c bm :[Select Id,PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c From PRM_VXBnftMatrix__c Where PRM_Channel_Program_Level_Id__r.Name IN :cpl AND PRM_Channel_Program_Id__c IN :channelPrograms AND PRM_Partner_Role_Nm__c IN :partnerRole]){
                        if(!existingABA.contains(bm.PRM_Partner_Benefit_Id__c)){
                            automaticBenefits.add(bm.PRM_Partner_Benefit_Id__c);
                        }
                    }
                }
                if((accountIds != null && !accountIds.IsEmpty()) && (automaticBenefits != null && !automaticBenefits.IsEmpty())){ //Fetching ABA records.
                    for(PRM_AccountBenefitAssociation__c aba : [Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Segment__c,PRM_Account_Id__r.RecordType.Name  ,PRM_Account_Id__r.Core_IPA_Badge_Tier__c,PRM_Partner_Benefit_Id__c,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c,PRM_Source__c From PRM_AccountBenefitAssociation__c Where (PRM_Account_Id__c IN :accountIds or PRM_Account_Id__c IN :inactiveACMAccId) AND PRM_Partner_Benefit_Id__c IN :automaticBenefits]){ //TWC729-5005                                                                    
                        
                        if(aba.PRM_Source__c != System.Label.PRM_ProgramLevel || (aba.PRM_Source__c == System.Label.PRM_ProgramLevel && aba.PRM_Status_Nm__c == 'Active') ){ // TWC729-5005 - Condition will only Inactivate those benefits that are already active. DML would be saved if not required. 
                            
                            Boolean isNotEligible = (aba.PRM_Account_Id__r.RecordType.Name != 'Partner Account Group' || mapOpidEligBenefits.isEmpty() || (aba.PRM_Account_Id__r.RecordType.Name == 'Partner Account Group' && mapOpidEligBenefits.containskey(aba.PRM_Account_Id__c) && !mapOpidEligBenefits.get(aba.PRM_Account_Id__c).contains(aba.PRM_Partner_Benefit_Id__c) ) );
                            if((aba.PRM_Source__c == System.Label.PRM_ProgramLevel || aba.PRM_Source__c == System.Label.PRM_Source_Specialty) && isNotEligible ){ //TWC729-5005
                                aba.PRM_Source__c='';
                                aba.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
                                aba.PRM_Status_Reason_Txt__c = System.Label.PRM_ABA_Status_Reason;
                                // making values null
                                // aba.PRM_Account_Id__r.Core_IPA_Partner_Segment__c='';
                                // aba.PRM_Account_Id__r.Core_IPA_Badge_Tier__c='';
                            }else if(isNotEligible){aba.PRM_Source__c= System.Label.PRM_Source_Specialty;
                                 }
                            //aba.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
                            //aba.PRM_Status_Reason_Txt__c = System.Label.PRM_ABA_Status_Reason;
                            updateABAList.add(aba);
                        } // TWC729-5005
                    }
                }
                }*/ // IPA Switch Removal
                if(accountIds != null && !accountIds.IsEmpty()){
                    for(PRM_Account_Contact_Relationship__c acrList : [Select id, name, PRM_Account_Id__c, PRM_Contact_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c,PRM_Status_Reason_Txt__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c IN :accountIds AND PRM_Partner_Role__c IN :partnerRole]){
                        contactIds.add(acrList.PRM_Contact_Id__c);
                        /*US808806 -UTKARSH - inactivate ACR when ACM become inactive*/
                        if(acrList.PRM_InActive_Ind__c == false){
                            acrList.PRM_InActive_Ind__c = true;
                            acrList.PRM_Status_Reason_Txt__c = System.Label.PRM_ACR_Status_Reason;
                            inactiveACRIdList.add(acrList);
                            acrIdsToInactivate.add(acrList.id);
                        }
                        /*US808806 - END*/
                    }
                }
                //Deactivating CSA records.
                if(contactIds != null && !contactIds.IsEmpty()){
                    for(PRM_ContactSubscriptionAssociation__c csa : [Select id , name, PRM_Contact_Id__c, PRM_Status_Nm__c,PRM_Status_Reason_Txt__c from PRM_ContactSubscriptionAssociation__c where PRM_Contact_Id__c IN :contactIds]){
                        csa.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
                        csa.PRM_Status_Reason_Txt__c = 'Contact Subscription inactivated as part of membership inactivation.';//TWC729-8089 : Adding reason text : NJ
                        csaList.add(csa);
                    }
                }
                /*US775822 -UTKARSH - Update partner segment on location account when ACM become inactive*/
                if(accountIds != null && !accountIds.IsEmpty()){
                    //Commenting below code for fixing SOQL issue TWC729-4591, used existing ACM query above to get Account values
                    //for(Account acc : [Select Id , Core_IPA_Partner_Segment__c from Account where Id IN :accountIds]){
                    for(Id accId: accountIds){
                        Account acc = allInitialAccMap.get(accId);
                        if(acc != null && !accPartnerSegment.contains(acc.Id) && acc.Core_IPA_Partner_Segment__c != null){
                            //acrAccId.add(acc.Id);
                                                        //if(!ipaRefresh || Test.isRunningTest())acc.Core_IPA_Partner_Segment__c = ''; // IPA Switch Removal
                            if(!rolledUpAccountMap.containsKey(acc.id)) updateLocationAcc.add(acc);
                        }
                    }
                }
                updateLocationAcc.addAll(rolledUpAccountMap.values());
                if(updateLocationAcc != null && !updateLocationAcc.IsEmpty()){if(!System.isBatch()){Schema.SObjectType acc = Schema.Account.getSObjectType();
                                                                                                    //System.enqueueJob(new ContactERPMIntegrationStatusHandler(updateLocationAcc,acc));
                                                                                                    System.enqueueJob(new PRM_RegReqProcessingQueueable(updateLocationAcc,null,false,'Update_Account',null,true));//TWC729-7729
                                                                                                   }
                                                                              else if(System.isBatch()){update updateLocationAcc;
                                                                                                       }
                                                                              
                                                                             }
                /*US775822 - END*/
            }
            /*END -condition-4*/
            /*Start - condition-5, Developer - TEJA*/
            if((trigger.Isupdate || trigger.IsInsert) && (activeIPAAccount==TRUE)){
                if(acmActiveAccountIDset!=null && !acmActiveAccountIDset.IsEmpty()){
                    Map<String, Integer> mapProgramToPriority = new Map<String, Integer>{
                        'Titanium' => 3,
                            'Gold' => 2,
                            'Member' => 1
                            };
                   
                                for(PRM_AccountChannelMembership__c acm :[SELECT Id,PRM_Account_Id__c,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Status_Nm__c,PRM_Partner_Role__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN :acmActiveAccountIDset AND PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = FALSE]){                                   
                                    Account accToUpdate = acctounsToUpdateMap.containsKey(acm.PRM_Account_Id__c)? acctounsToUpdateMap.get(acm.PRM_Account_Id__c): new Account();Account acc = new Account();
                                    accToUpdate.id=acm.PRM_Account_Id__c;
                                    accToUpdate.Core_IPA_Badge_Tier__c = acm.PRM_Channel_Program_Level_Id__r.Name;
                                    accToUpdate.PRM_IPA_Badge_Tier_Date__c = System.now();
                                    accToUpdate.Core_Intel_Partner_Alliance_PartnerGroup__c=TRUE;

                                    if(mapAccountsToUpdate.containsKey(accToUpdate.id) && 
                                       mapProgramToPriority.get(accToUpdate.Core_IPA_Badge_Tier__c) > mapProgramToPriority.get(mapAccountsToUpdate.get(accToUpdate.id).Core_IPA_Badge_Tier__c ))
                                    {
                                        mapAccountsToUpdate.put(accToUpdate.id, accToUpdate);
                                    }
                                    else{
                                        mapAccountsToUpdate.put(accToUpdate.id, accToUpdate);
                                    }
                                }


                
            }

                
                if(mapAccountsToUpdate != null && !mapAccountsToUpdate.IsEmpty()){
                    if(!System.isBatch()){
                        acctounsToUpdateMap.putAll(mapAccountsToUpdate);
                       // Schema.SObjectType acc = Schema.Account.getSObjectType();
                       // System.enqueueJob(new ContactERPMIntegrationStatusHandler(mapAccountsToUpdate.values(),acc));
                    }
                    else if(System.isBatch()){
                        logEntryMsgString+='\n mapAccountsToUpdate: '+mapAccountsToUpdate;
                        update mapAccountsToUpdate.values();
                    }
                    
                }            
            } 
            PRM_accBenefitAssociationUtility.mapPartnerTierBenefitsABA= mapPartnerTierBenefits;
            try{
                Database.SaveResult[] result;
                if((updateABAList != null && !updateABAList.IsEmpty()) && !System.isBatch()){
                    //To skip the MP benefit validation
                    PRM_accBenefitAssociationUtility.skipvalidationforMPBenefits = true;
                    logEntryMsgString+='\n updateABAList: '+updateABAList;
                    update updateABAList;
                }
                if(csaList != null && !csaList.IsEmpty()){
                    logEntryMsgString+='\n csaList: '+csaList;
                    update csaList;
                                                         }
                if(inactiveACRIdList != null && !inactiveACRIdList.IsEmpty()){
                    if(!System.isBatch() && !System.isQueueable() && !System.isFuture()){
                        logEntryMsgString+='\n future method inactivateACRList being called with parameter,acrIdsToInactivate: '+acrIdsToInactivate;
                       inactivateACRList(acrIdsToInactivate);    
                    }else{
                        logEntryMsgString+='\n inactiveACRIdList: '+inactiveACRIdList;
                      update inactiveACRIdList;   
                    }
                }
                /*if(activeACRIdList != null && !activeACRIdList.IsEmpty()){update activeACRIdList;
}
if(inactiveAllACRIdList != null && !inactiveAllACRIdList.IsEmpty()){update inactiveAllACRIdList;
}*/
                if(updateOPIDACM != null && !updateOPIDACM.IsEmpty()){
                    PRM_ACM_TriggerHandler.firstRun = true;
                    logEntryMsgString+='\n updateOPIDACM: '+updateOPIDACM;
                    result= Database.update(updateOPIDACM,false);
                    set<string> setOfOpidACM = new set<string>(); 
                    string resACMId;
                    Set<Id> resAccSet = new Set<Id>();
                    if(result != null && !result.isEmpty()){
                        for(Database.SaveResult sr : result){
                            if(sr.isSuccess()){
                                resACMId = sr.getId();
                                if(resACMId != null && resACMId !=''){
                                    setOfOpidACM.add(resACMId);  
                                }
                            }else{
                                for (Database.Error err : sr.getErrors()) {
                                logEntryMsgString+= 'Message: ' + err.getMessage() + '\n'
                                                + 'Fields: ' + err.Fields.toString() + '\n'
                                                + 'StatusCode: ' + err.getStatusCode() + '\n';
                            }
                            }
                        }  
                    }
                    for(PRM_AccountChannelMembership__c acm :[Select Id,PRM_Account_Id__c,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c from PRM_AccountChannelMembership__c where Id IN: setOfOpidACM]){
                        resAccSet.add(acm.PRM_Account_Id__c);
                    }    
                    if(resAccSet != null && !resAccSet.IsEmpty()){
                        for(PRM_AccountChannelMembership__c acm: [Select Id, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Badge_Tier__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN:resAccSet and PRM_Status_Nm__c = :System.label.PRM_Status]){
                            resmapOfAccIdBadgeTier.put(acm.PRM_Account_Id__c, acm.PRM_Account_Id__r.Core_IPA_Badge_Tier__c);
                            if(resmapOfAccACMsList.containsKey(acm.PRM_Account_Id__c)){resaccACMsList = resmapOfAccACMsList.get(acm.PRM_Account_Id__c);
                                                                                      }else{resaccACMsList = new List<PRM_AccountChannelMembership__c>();
                                                                                           }
                            resaccACMsList.add(acm);
                            resmapOfAccACMsList.put(acm.PRM_Account_Id__c,resaccACMsList);
                        }
                    }
    if(updateBatchTierRolldown){
                  for(String bageMapping :LabelConfiguration__mdt.getInstance('ChannelProgramLevelRanking').Value__c.split(';')){ 
                      List<String> progTier = bageMapping.split(':');
                      resmapOfBadgeNameTier.put(progTier[0],Integer.valueOf(progTier[1]));        
                        }
                    }
                    if(resAccSet != null && !resAccSet.IsEmpty()){
                        for(Id accId: resAccSet){
                            if(!resmapOfAccACMsList.containskey(accId)){
                                Account accToUpdate = acctounsToUpdateMap.containsKey(accId)? acctounsToUpdateMap.get(accId): new Account();
                                accToUpdate.Core_IPA_Badge_Tier__c = '';
                                accToUpdate.PRM_IPA_Badge_Tier_Date__c = null;
                                accToUpdate.Id = accId;
                                if(!resaccsToUpdate.contains(accToUpdate)){resaccsToUpdate.add(accToUpdate);
                                                                  }
                            }                    
                        }
                    }
                    if(resmapOfAccACMsList != null && !resmapOfAccACMsList.IsEmpty()){
                        for(Id accId: resmapOfAccACMsList.keyset()){resaccACMsList = resmapOfAccACMsList.get(accId);
                                                                    reshighestTier = resmapOfAccIdBadgeTier.get(accId);
                                                                    if(resaccACMsList == null || resaccACMsList.isEmpty()){Account accToUpdate = acctounsToUpdateMap.containsKey(accId)? acctounsToUpdateMap.get(accId): new Account();
                                                                                                                           accToUpdate.Core_IPA_Badge_Tier__c = '';
                                                                                                                           accToUpdate.PRM_IPA_Badge_Tier_Date__c = null;
                                                                                                                           accToUpdate.Id = accId;
                                                                                                                           if(!resaccsToUpdate.contains(accToUpdate)){resaccsToUpdate.add(accToUpdate);
                                                                                                                                                             } 
                                                                                                                          }
                                                                    for(PRM_AccountChannelMembership__c acm: resaccACMsList){if(resmapOfBadgeNameTier.get(reshighestTier) > resmapOfBadgeNameTier.get(acm.PRM_Channel_Program_Level_Id__r.Name)){Account accToUpdate = acctounsToUpdateMap.containsKey(accId)? acctounsToUpdateMap.get(accId): new Account();
                                                                                                                                                                                                                                                 accToUpdate.Core_IPA_Badge_Tier__c = acm.PRM_Channel_Program_Level_Id__r.Name;
                                                                                                                                                                                                                                                 accToUpdate.PRM_IPA_Badge_Tier_Date__c = System.now();
                                                                                                                                                                                                                                                 accToUpdate.Id = acm.PRM_Account_Id__c;
                                                                                                                                                                                                                                                 if(!resaccsToUpdate.contains(accToUpdate)){resaccsToUpdate.add(accToUpdate);
                                                                                                                                                                                                                                                                                   }                            
                                                                                                                                                                                                                                                }
                                                                                                                            }
                                                                   }
                    }
                    if(resaccsToUpdate != null && !resaccsToUpdate.IsEmpty()){
                        if(!System.isBatch()){
                            acctounsToUpdateMap.putall(resaccsToUpdate);
                            //Schema.SObjectType acc = Schema.Account.getSObjectType();
                            //System.enqueueJob(new ContactERPMIntegrationStatusHandler(resaccsToUpdate,acc));
                        }
                        else if(System.isBatch()){
                            logEntryMsgString+='\n resaccsToUpdate: '+resaccsToUpdate;
                            update resaccsToUpdate;
                                                 }
                    }
                }
                
                if(acctounsToUpdateMap != null && !acctounsToUpdateMap.IsEmpty()){                    
                    if(!System.isBatch()){
                        Schema.SObjectType acc = Schema.Account.getSObjectType();
                        logEntryMsgString+='\n ContactERPMIntegrationStatusHandler enqueued below, acctounsToUpdateMap: '+acctounsToUpdateMap;
                        System.enqueueJob(new ContactERPMIntegrationStatusHandler(acctounsToUpdateMap.values(),acc));
                    }
                }

            
                if(updateChildASA != null && !updateChildASA.IsEmpty()){
                    logEntryMsgString+='\n updateChildASA: '+updateChildASA;
                    update updateChildASA;      
                                                                       }
                
                //TWC729-7521 -NJ -Inactivate AIA on location account when ACM is inactivated
                if(updateChildAIA != null && !updateChildAIA.IsEmpty()){
                     logEntryMsgString+='\n updateChildAIA: '+updateChildAIA;
                     update updateChildAIA;      
                                                                       }           
                

                if(contactsToUpdateList.size() > 0){
                    if(!System.isBatch()){
                        Schema.SObjectType con = Schema.Contact.getSObjectType();
                        logEntryMsgString+='\n ContactERPMIntegrationStatusHandler enqueued below, contactsToUpdateList: '+contactsToUpdateList;
                        System.enqueueJob(new ContactERPMIntegrationStatusHandler(contactsToUpdateList,con));  
                    }                                    
                }
            }catch(Exception e){logEntryMsgString+='\n Errors: '+e.getMessage();            
                               }finally{
                                createLogEntry(logEntryMsgString);
                               }
        }
    }
    
    /***************************************************************************************************************
     * @param1 : Map<String,Core_Account_Group_Member__c> parentCagRec - holds the Unified ID and CAG record of the parent of the Account
     * @param2 : Map<string,account> ucdNonGlblAccMap - holds the Unified ID and Account
     * @param3 : List<Core_OnePartner_Inbound_Message__c> listOfInboundOnePartner - holds the inbound records to be created
     * @param4 : Map<Id,PRM_AccountChannelMembership__c> AcmWithOPIDCheckMap - If the account is IPA, then this map has the acocunt id and acm. It will be blank for Non-ipa acocunts
    *****************************************************************************************************************/

    public static void CreateInboundRecord(Map<String,Core_Account_Group_Member__c> parentCagRec,Map<string,account> ucdNonGlblAccMap, List<Core_OnePartner_Inbound_Message__c> listOfInboundOnePartner ,Map<Id,PRM_AccountChannelMembership__c> AcmWithOPIDCheckMap,Set<String> noIpaAccountIds){
        //Id recordTypeOPID= Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_OPID).getRecordTypeId(); //TWC729-6800 EOL activities
        List<PRM_AccountChannelMembership__c> AcmListToProcess = new List<PRM_AccountChannelMembership__c>();
        List<PRM_AccountChannelMembership__c> AcmListWithNoApproved = new List<PRM_AccountChannelMembership__c>();      
        //List<PRM_Value_Exchange_Recommendation__c> finalListOfOPIDRecmnd = new List<PRM_Value_Exchange_Recommendation__c>(); //TWC729-6800 EOL activities
        //List<PRM_Value_Exchange_Recommendation__c> vxr = new List<PRM_Value_Exchange_Recommendation__c>(); //TWC729-6800 EOL activities
        Map<String,String> MetadataMap = new Map<String,String>();      
    
        //UCD Change- Start
        Map<String,list<account>> globalIdMap = new Map<String,list<account>>();
        set<String> globalIdSet = new set<String>();
        Map<String,account> primaryNodeMap = new Map<String,account>();
        Map<String,Core_OnePartner_Inbound_Message__c> ucdIdInbMap = new Map<String,Core_OnePartner_Inbound_Message__c>();
        Map<String,Account> allAcc = new Map<String,Account>();
        //Id OpidRecordTypeId = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByDeveloperName().get('PRM_OPID_Recommendation').getRecordTypeId();   //TWC729-6800 EOL activities     
        // UCD Change- End

        
        try{
            logEntryMsgString+='*****CreateInboundRecord*****';
        //  logEntryMsgString+='\naccountIdSet :'+accountIdSet;
          /*
            vxr = [SELECT id,
                   PRM_Account_Id__c,
                   RecordTypeId
                   FROM PRM_Value_Exchange_Recommendation__c 
                   WHERE PRM_Account_Id__c IN:accountIdSet AND RecordTypeId=:recordTypeOPID AND PRM_Recommendation_Status_Nm__c != 'OPID Created'];
            */
          //if(vxr == null || vxr.IsEmpty()){     
               //Iterating all the accounts which are not Global and not associated to OPID. If parentCagRec is empty, it means none of the account in trigger.new is associated with any OPID. If it is not empty, some might be associated and some might not be.
               if(!ucdNonGlblAccMap.isEmpty()){
                logEntryMsgString+='\n ucdNonGlblAccMap:'+ucdNonGlblAccMap;
                for(account ucdRec : ucdNonGlblAccMap.values()){
                    if(!parentCagRec.IsEmpty() && ucdRec.Core_Parent_Business_Party_Id__c!=null && parentCagRec.containskey(ucdRec.Core_Parent_Business_Party_Id__c) ){
                        // Scenario1 
                        Integer opidNumber = integer.valueOf(parentCagRec.get(ucdRec.Core_Parent_Business_Party_Id__c).Core_Partner_Account_Id__r.Core_OnePartnerID__c);
                        String opidaccountName = parentCagRec.get(ucdRec.Core_Parent_Business_Party_Id__c).Core_Partner_Account_Id__r.Name;
                        Core_OnePartner_Inbound_Message__c  inboundOnePartner = createInbound(opidNumber,opidaccountName,ucdRec);
                        listOfInboundOnePartner.add(inboundOnePartner);
                    }else if(AcmWithOPIDCheckMap.containsKey(ucdRec.id) || noIpaAccountIds.contains(ucdRec.Core_Unified_Global_Customer_BP_Id__c)){
                        globalIdSet.add(ucdRec.Core_Unified_Global_Customer_BP_Id__c);
                        
                    }
                }
            }
            
            
            // Fetch all the child account in the UCD hierarchy related to the Global Account.
            if(!globalIdSet.isEmpty()){
                logEntryMsgString+='\n globalIdSet:'+globalIdSet;
                for(Account accRec : [SELECT id,Name,Core_Intel_Partner_Alliance_PartnerGroup__c, Core_Business_Party_Id__c,Core_Parent_Business_Party_Id__c,
                                        (SELECT id FROM Partner_Account_Group_Members1__r WHERE Core_Inactive_Ind__c = false LIMIT 1 ),
                                        Core_Unified_Global_Customer_BP_Id__c,Core_Customer_Aggregation_Type__c,Core_Unified_Global_Customer_Name__c  FROM Account 
                                      WHERE Core_Unified_Global_Customer_BP_Id__c IN :globalIdSet AND Core_Business_Party_Id__c != null and RecordTypeId=:intelAccountRTId]){
                    allAcc.put(accRec.id,accRec);
                        if(globalIdMap.containsKey(accRec.Core_Unified_Global_Customer_BP_Id__c)){
                            List<account> accRecParent = globalIdMap.get(accRec.Core_Unified_Global_Customer_BP_Id__c);
                            accRecParent.add(accRec);
                            globalIdMap.put(accRec.Core_Unified_Global_Customer_BP_Id__c,accRecParent);                                    
                        }else{
                            globalIdMap.put(accRec.Core_Unified_Global_Customer_BP_Id__c,new List<account>{accRec});
                    }
                }
            }
            if(!allAcc.isEmpty()){
                List<Core_OnePartner_Inbound_Message__c> activeInbnd = [SELECT id,Core_SalesCloud_AccountID__c,Core_Status__c,Core_Status_Effective_End_Date_Time__c,Core_OnePartnerID__c,Core_OnePartner_Account_Name__c,Core_PAG_Grouping_Method__c
                                                                        FROM Core_OnePartner_Inbound_Message__c WHERE Core_Status__c='NEW' AND Core_SalesCloud_AccountID__c IN: allAcc.keyset() AND (Core_Status_Effective_End_Date_Time__c=null OR Core_Effective_End_Date_Time__c=null)];
                if(!activeInbnd.isEmpty()){
                    for(Core_OnePartner_Inbound_Message__c inbMsg:activeInbnd){
                        if(allAcc.containsKey(inbMsg.Core_SalesCloud_AccountID__c)){
                            ucdIdInbMap.put(allAcc.get(inbMsg.Core_SalesCloud_AccountID__c).Core_Business_Party_Id__c,inbMsg);
                        }
                    }
                }
            }  
 
            //scenario 2
            if(!globalIdMap.isEmpty()){
                logEntryMsgString+='\n globalIdMap:'+globalIdMap;
                for(string globalId : globalIdMap.keySet()){
                    Integer ucd_OnePartnerID =integer.valueOf(fetchOpidNumber()); // one Id for all the childs. This will bind them together
                    if(noIpaAccountIds.contains(globalId)){
                        for(account globalAccountRec :  globalIdMap.get(globalId)){
                            if(!ucdIdInbMap.containsKey(globalAccountRec.Core_Business_Party_Id__c) && ucdIdInbMap.containsKey(globalAccountRec.Core_Parent_Business_Party_Id__c)){
                                Integer opidNumber =  integer.valueof(ucdIdInbMap.get(globalAccountRec.Core_Parent_Business_Party_Id__c).Core_OnePartnerID__c);
                                String opidaccountName = ucdIdInbMap.get(globalAccountRec.Core_Parent_Business_Party_Id__c).Core_OnePartner_Account_Name__c;
                                Core_OnePartner_Inbound_Message__c  inboundOnePartner = createInbound(opidNumber,opidaccountName,globalAccountRec);
                                listOfInboundOnePartner.add(inboundOnePartner);   
                            }
                        }
                    }
                    else{
                        for(account globalAccountRec :  globalIdMap.get(globalId)){
                            if(globalAccountRec.Partner_Account_Group_Members1__r.size()==0){
                                if(!ucdIdInbMap.containsKey(globalAccountRec.Core_Business_Party_Id__c) && !ucdIdInbMap.containsKey(globalAccountRec.Core_Parent_Business_Party_Id__c)){
                                    // Scenario2
                                    String opidaccountName = globalAccountRec.Core_Unified_Global_Customer_Name__c+' - Global';
                                    Core_OnePartner_Inbound_Message__c  inboundOnePartner = createInbound(ucd_OnePartnerID,opidaccountName,globalAccountRec);
                                    listOfInboundOnePartner.add(inboundOnePartner);   
                                }else if(!ucdIdInbMap.containsKey(globalAccountRec.Core_Business_Party_Id__c) && ucdIdInbMap.containsKey(globalAccountRec.Core_Parent_Business_Party_Id__c)){
                                    Integer opidNumber =  integer.valueof(ucdIdInbMap.get(globalAccountRec.Core_Parent_Business_Party_Id__c).Core_OnePartnerID__c);
                                    String opidaccountName = ucdIdInbMap.get(globalAccountRec.Core_Parent_Business_Party_Id__c).Core_OnePartner_Account_Name__c;
                                    Core_OnePartner_Inbound_Message__c  inboundOnePartner = createInbound(opidNumber,opidaccountName,globalAccountRec);
                                    listOfInboundOnePartner.add(inboundOnePartner);   
                                }
                                
                            } 
                        }
                    }
                }
            }
            
        
            // Insert the list of Inbound records.
            if(!listOfInboundOnePartner.IsEmpty()){
                //insert listOfInboundOnePartner;  
                //TWC729-6801 OPID Tracker Start
                logEntryMsgString+='\n listOfInboundOnePartner:'+listOfInboundOnePartner;
                updateOpidNumber(listOfInboundOnePartner);
                Database.SaveResult[] saveResultList = Database.insert(listOfInboundOnePartner, false);
                List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();
                Map<id,Core_OnePartner_Inbound_Message__c> inboundRecMap = new Map<id,Core_OnePartner_Inbound_Message__c>(listOfInboundOnePartner);
                
                for(Database.SaveResult result: saveResultList){//loop start
                    if(result.isSuccess()){
                        Id sId = result.getId();
                        if(sId!=null && inboundRecMap.keySet().contains(sId) ){
                            PRM_Tracker__c tracker = new PRM_Tracker__c();
                            tracker.PRM_Type__c = 'OPID Updates';
                            tracker.PRM_Milestone__c = 'INBND_CRTD';
                            tracker.PRM_Location_Account__c = inboundRecMap.get(sId).Core_SalesCloud_AccountID__c;
                            tracker.PRM_Milestone_Display_Name__c = 'OPID Request Created';
                            tracker.PRM_Completed__c = true;
                            trackerList.add(tracker);    
                        }
                    }
                    else if (!result.isSuccess()){
                        for (Database.Error err : result.getErrors()) {
                            logEntryMsgString+= 'Message: ' + err.getMessage() + '\n'
                                            + 'Fields: ' + err.Fields.toString() + '\n'
                                            + 'StatusCode: ' + err.getStatusCode() + '\n';
                        }
                    }
                }//loop ends here..
                if (!trackerList.isEmpty()) {
                    //insert trackerList;
                    List<Database.SaveResult> insertTrackerResult = new List<Database.SaveResult>();
                    insertTrackerResult = Database.insert(trackerList,false); //TWC729-6988 Exception Handling
                    for(Database.SaveResult result: saveResultList){//loop start
                        if (!result.isSuccess()){
                            for (Database.Error err : result.getErrors()) {
                                logEntryMsgString+= 'Message: ' + err.getMessage() + '\n'
                                                + 'Fields: ' + err.Fields.toString() + '\n'
                                                + 'StatusCode: ' + err.getStatusCode() + '\n';
                            }
                        }
                    }//loop end
                }
                //TWC729-6801 OPID Tracker End 
            }
        }catch(Exception ex){
            //PRM_ErrorUtilityClass.logError(ex);
            logEntryMsgString+= ex.getMessage();
        }
    } 
    public static Core_OnePartner_Inbound_Message__c createInbound(Integer onePartnerId,String opidAccountName, Account acc){
        Core_OnePartner_Inbound_Message__c  inboundOnePartner = new Core_OnePartner_Inbound_Message__c  () ;
        inboundOnePartner.Core_OnePartnerID__c  = onePartnerId;
        inboundOnePartner.Core_OnePartner_Account_Name__c = opidAccountName;
        inboundOnePartner.Core_SalesCloud_AccountID__c = acc.id ;
        inboundOnePartner.Core_Status__c = 'NEW';
        inboundOnePartner.Primary_Account__c =  acc.Core_Customer_Aggregation_Type__c == 'UNFD_GLBL_CUST' ? true : false ;
        inboundOnePartner.Core_PAG_Grouping_Method__c = 'GLBL' ; // Need to create a metadata and get the corresponding valid picklist value xxxxx
        inboundOnePartner.Core_CIM_ID__c  = Decimal.valueof(acc.Core_Business_Party_Id__c);  // Change the CIM name to UCD Id
        inboundOnePartner.Core_Effective_Start_Date_Time__c = System.now();
        inboundOnePartner.Comments__c = 'Association to 1PID on creation';
        return inboundOnePartner;
        

    }

    
    
    public static void createTrackerMilestonesForMembershipUpdate(List<PRM_AccountChannelMembership__c> acms, Map<Id,PRM_AccountChannelMembership__c> oldAcmMap) {
        List<PRM_Tracker__c> trackers = new List<PRM_Tracker__c>();
        Core_CustomMetadataObjectController customMetadata = new Core_CustomMetadataObjectController('PRM_Tracker_steps__mdt');
        for (PRM_AccountChannelMembership__c acm: acms) {
           if(acm.PRM_Channel_Program_Level_Id__c != oldAcmMap.get(acm.Id).PRM_Channel_Program_Level_Id__c ||
            acm.PRM_Partner_Role__c != oldAcmMap.get(acm.Id).PRM_Partner_Role__c) {
                    
                    trackers.add(PRM_IPA_Utility.createTrackerInstance('OPID Updates',
                                                                       'MEM_UPDATED_LOC',
                                                                       null,
                                                                       acm.PRM_Account_Id__c,
                                                                       acm.PRM_Onepartner_Id__c,
                                                                       acm.PRM_Onepartner_Id__c,
                                                                       acm.PRM_Partner_Role__c,
                                                                       acm.PRM_Tier_Name_txt__c,
                                                                       true,
                                                                       '',
                                                                       '',
                                                                       String.valueOf(customMetadata.getInstance('MEM_UPDATED_LOC').get('PRM_Milestone_Display_Name__c'))
                                                                      ));
                }
            
            if ((acm.PRM_Channel_Program_Level_Id__c != oldAcmMap.get(acm.Id).PRM_Channel_Program_Level_Id__c ||
            acm.PRM_Partner_Role__c != oldAcmMap.get(acm.Id).PRM_Partner_Role__c) &&
            acm.PRM_Account_RT__c == 'Core_Partner_Account_Group') {
                    
                    trackers.add(PRM_IPA_Utility.createTrackerInstance('OPID Updates 1PID',
                                                                       'MEM_UPDATED_1PID',
                                                                       null,
                                                                       null,
                                                                       acm.PRM_Account_Id__c,
                                                                       acm.PRM_Account_Id__c,
                                                                       acm.PRM_Partner_Role__c,
                                                                       acm.PRM_Tier_Name_txt__c,
                                                                       true,
                                                                       '',
                                                                       '',
                                                                       String.valueOf(customMetadata.getInstance('MEM_UPDATED_1PID').get('PRM_Milestone_Display_Name__c'))
                                                                      ));
                }
        }
        
        if (!trackers.isEmpty()) {
            insert trackers;
        }
    }
    private static Map<String, List<String>> getPartnerSegmentPartnerRoleMapping(){
        Map<String, List<String>> mapOfPartnerSegmentRole =  new Map<String, List<String>>();
        for(PRM_PartnerRoleTypeMappings__mdt segRoleTypeRec: [Select id, PRM_Partner_Role__c, PRM_Partner_Segment__c from PRM_PartnerRoleTypeMappings__mdt where PRM_Partner_Segment__c != null]){
            if(mapOfPartnerSegmentRole.containsKey(segRoleTypeRec.PRM_Partner_Segment__c))
                mapOfPartnerSegmentRole.get(segRoleTypeRec.PRM_Partner_Segment__c).add(segRoleTypeRec.PRM_Partner_Role__c);
            else{
                List<String> roleList = new List<String>();
                roleList.add(segRoleTypeRec.PRM_Partner_Role__c);
                mapOfPartnerSegmentRole.put(segRoleTypeRec.PRM_Partner_Segment__c, roleList);
            }
        }
        return mapOfPartnerSegmentRole;    
    }     
    
    @future
    public static void inactivateACRList(List<Id> acrList){
        if(acrList != null && !acrList.isEmpty()){
            List<PRM_Account_Contact_Relationship__c> inactiveACRIdList = new List<PRM_Account_Contact_Relationship__c>();
          for(PRM_Account_Contact_Relationship__c acr : [Select id, name, PRM_Account_Id__c, PRM_Contact_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c,PRM_Status_Reason_Txt__c from PRM_Account_Contact_Relationship__c where Id IN: acrList]){                
                /*US808806 -UTKARSH - inactivate ACR when ACM become inactive*/
                if(acr.PRM_InActive_Ind__c == false){
                    acr.PRM_InActive_Ind__c = true;
                    acr.PRM_Status_Reason_Txt__c = System.Label.PRM_ACR_Status_Reason;
                    inactiveACRIdList.add(acr);
                }    
          }
            
            update inactiveACRIdList;
      }
    }
    //Method runs when IPA refresh is false
  public static void assignBenefitsOnRollDown(List<id> accIdList,Map<Id, String> tierIdNames) {
        Map<Id, String> actIdRoleTierMap = new Map<Id, String>(); 
        Map<Id, String> accChMemMap = new Map<Id, String>();
        Map<Id,List<PRM_AccountChannelMembership__c>> acmMap = new Map<Id,List<PRM_AccountChannelMembership__c>>();
        for(PRM_AccountChannelMembership__c acm : [Select id,Name,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Level_Id__c,PRM_Account_Id__r.recordType.DeveloperName,PRM_Channel_Program_Level_Id__r.Name,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c in: accIdList and PRM_Status_Nm__c =: 'Approved']){
            if(acmMap.containsKey(acm.PRM_Account_Id__c)){
                acmMap.get(acm.PRM_Account_Id__c).add(acm);
            }
            else{
                acmMap.put(acm.PRM_Account_Id__c,new List<PRM_AccountChannelMembership__c>{acm});
            }
        }
        if(!acmMap.isEmpty()){
        //fetching other acms of the accounts 
            Map<String,Integer> tierAndRankMap = new Map<String,Integer>{System.Label.PRM_Member => 1, System.Label.PRM_Tier_Gold => 2, System.Label.PRM_Tier_Titanium => 3}; 
            List<PRM_AccountBenefitAssociation__c> abaToUpsertList = new List<PRM_AccountBenefitAssociation__c>();
            Set<Id> existingABASet = new Set<Id>();
            Set<Id> EligibleABASet = new Set<Id>();
            Map<String, List<PRM_VXBnftMatrix__c>> autoPartnerRolVxBftMat = new Map<String, List<PRM_VXBnftMatrix__c>>();
            Map<String, List<PRM_VXBnftMatrix__c>> manualPartnerRolVxBftMat = new Map<String, List<PRM_VXBnftMatrix__c>>();
            for(PRM_VXBnftMatrix__c vebm : [Select id, PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name, PRM_Channel_Program_Level_Id__c,PRM_Covered_Account_Ind__c, PRM_Approval_Type_Nm__c, PRM_Partner_Benefit_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Role_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c from PRM_VXBnftMatrix__c where (PRM_Approval_Type_Nm__c =:Label.PRM_ApprovalType or PRM_Approval_Type_Nm__c = 'manual') AND PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_IsActive_Ind__c = True]){
                if(vebm.PRM_Approval_Type_Nm__c ==Label.PRM_ApprovalType){
                    if(autoPartnerRolVxBftMat.size()>0 && autoPartnerRolVxBftMat.containsKey(vebm.PRM_Partner_Role_Nm__c+'-'+vebm.PRM_Channel_Program_Level_Id__r.Name)){
                    autoPartnerRolVxBftMat.get(vebm.PRM_Partner_Role_Nm__c+'-'+vebm.PRM_Channel_Program_Level_Id__r.Name).add(vebm);
                    }else{
                        autoPartnerRolVxBftMat.put(vebm.PRM_Partner_Role_Nm__c+'-'+vebm.PRM_Channel_Program_Level_Id__r.Name, new List<PRM_VXBnftMatrix__c>{vebm});
                    }
                }
                else{
                    if(manualPartnerRolVxBftMat.size()>0 && manualPartnerRolVxBftMat.containsKey(vebm.PRM_Partner_Role_Nm__c+'-'+vebm.PRM_Channel_Program_Level_Id__r.Name)){
                        manualPartnerRolVxBftMat.get(vebm.PRM_Partner_Role_Nm__c+'-'+vebm.PRM_Channel_Program_Level_Id__r.Name).add(vebm);
                    }else{
                        manualPartnerRolVxBftMat.put(vebm.PRM_Partner_Role_Nm__c+'-'+vebm.PRM_Channel_Program_Level_Id__r.Name, new List<PRM_VXBnftMatrix__c>{vebm});
                    }
                }      
            }
            //fetching the existing aba on opid and storing in a map.
            Map<String,PRM_AccountBenefitAssociation__c> existingABAMap = new Map<String,PRM_AccountBenefitAssociation__c>();
            for(PRM_AccountBenefitAssociation__c abaRec : [select id,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c,PRM_Account_Id__r.RecordType.DeveloperName,PRM_Account_Id__c, PRM_Partner_Benefit_Id__c,PRM_Source__c,PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c  from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c in: accIdList]){
                existingABAMap.put(abaRec.PRM_Partner_Benefit_Id__c+'-'+abaRec.PRM_Account_Id__c, abaRec);
                existingABASet.add(abaRec.id);
            }
            //assigning auto-assign benefits
            if((autoPartnerRolVxBftMat != null && !autoPartnerRolVxBftMat.isEmpty()) || (manualPartnerRolVxBftMat != null && !manualPartnerRolVxBftMat.isEmpty())){
                for(Id accId: acmMap.keyset()){
                    if(acmMap.get(accId).size() == 1){
                        PRM_AccountChannelMembership__c accChMem = acmMap.get(accId)[0];
                        Integer currentRank = tierAndRankMap.get(accChMem.PRM_Channel_Program_Level_Id__r.Name);
                        List<String> keys = new List<String>{accChMem.PRM_Partner_Role__c+'-'+accChMem.PRM_Channel_Program_Level_Id__r.Name};
                        if(currentRank == 2){
                            keys.add(accChMem.PRM_Partner_Role__c+'-'+System.Label.PRM_Member);
                        }
                        
                        for(String key : keys){
                            if(autoPartnerRolVxBftMat.containskey(key)){
                                for(PRM_VXBnftMatrix__c vebm : autoPartnerRolVxBftMat.get(key)){
                                    if(!existingABAMap.containskey(vebm.PRM_Partner_Benefit_Id__c+'-'+accChMem.PRM_Account_Id__c)){
                                        if(vebm.PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c == accChMem.PRM_Account_Id__r.recordType.DeveloperName){
                                        PRM_AccountBenefitAssociation__c aba  = new PRM_AccountBenefitAssociation__c();
                                        aba.PRM_Account_Id__c = accChMem.PRM_Account_Id__c;
                                        aba.PRM_Partner_Benefit_Id__c = vebm.PRM_Partner_Benefit_Id__c;
                                        aba.PRM_Status_Nm__c = 'Active';
                                        aba.PRM_Source__c ='Tier';
                                        abaToUpsertList.add(aba);
                                        }
                                    }
                                    else{
                                        if(existingABAMap.get(vebm.PRM_Partner_Benefit_Id__c+'-'+accChMem.PRM_Account_Id__c).PRM_Status_Nm__c == 'Inactive'){
                                            if(vebm.PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c == accChMem.PRM_Account_Id__r.recordType.DeveloperName){    
                                                PRM_AccountBenefitAssociation__c aba  = existingABAMap.get(vebm.PRM_Partner_Benefit_Id__c+'-'+accChMem.PRM_Account_Id__c);
                                                aba.PRM_Status_Nm__c = 'Active';
                                                abaToUpsertList.add(aba);
                                                EligibleABASet.add(aba.id);
                                                }
                                        }
                                        else{//it is already existing ABA with Active status.
                                            EligibleABASet.add(existingABAMap.get(vebm.PRM_Partner_Benefit_Id__c+'-'+accChMem.PRM_Account_Id__c).Id);
                                        }
                                    }
                                }
                            }
                            if(manualPartnerRolVxBftMat.containskey(key)){
                                for(PRM_VXBnftMatrix__c vebm : manualPartnerRolVxBftMat.get(key)){
                                    if(existingABAMap.containskey(vebm.PRM_Partner_Benefit_Id__c+'-'+accChMem.PRM_Account_Id__c)){
                                        EligibleABASet.add(existingABAMap.get(vebm.PRM_Partner_Benefit_Id__c+'-'+accChMem.PRM_Account_Id__c).Id);
                                    }}
                            }
                        }
                        existingABASet.removeAll(EligibleABASet);
                        if(accChMem.PRM_Account_Id__r.RecordType.DeveloperName == Label.PRM_Intel_Account){
                            accChMemMap.put(accChMem.PRM_Account_Id__c,accChMem.PRM_Partner_Role__c);
                            actIdRoleTierMap.put(accChMem.PRM_Account_Id__c,accChMem.PRM_Partner_Role__c+'-'+accChMem.PRM_Channel_Program_Level_Id__c);
                            if(accChMem.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c != null &&!actIdRoleTierMap.containskey(accChMem.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c)){
                              actIdRoleTierMap.put(accChMem.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,accChMem.PRM_Partner_Role__c+'-'+accChMem.PRM_Channel_Program_Level_Id__c);
                            }
                        }
                    }
                }
                for(PRM_AccountBenefitAssociation__c aba : existingABAMap.values()){
                    if(existingABASet.contains(aba.id)){
                        aba.PRM_Status_Nm__c = 'Inactive';
                        aba.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
                        abaToUpsertList.add(aba);
                    }
                }
                if(abaToUpsertList != null && !abaToUpsertList.isempty()){
                    //Database.UpsertResult[] urList = 
                    Database.upsert(abaToUpsertList, false);
                    //upsert abaToUpsertList;
                }
            }
            if(!accChMemMap.isEmpty() && !actIdRoleTierMap.IsEmpty() && !tierIdNames.isEmpty()){
                 if(System.isBatch() || System.isQueueable() || System.isFuture()) {
                     UpdateEntitlementOnRollDown(accChMemMap,actIdRoleTierMap,tierIdNames);
                 }
                else{
                    UpdateEntOnRollDown(accChMemMap,actIdRoleTierMap,tierIdNames);
                }
            } 
        }
    }
    @future
    public static void UpdateEntOnRollDown(Map<Id, String> accChMem, Map<Id, String> actIdRoleTierMap,Map<Id, String> tierIdNames){
        UpdateEntitlementOnRollDown(accChMem,actIdRoleTierMap,tierIdNames);
    }

    public static void UpdateEntitlementOnRollDown(Map<Id, String> accChMem, Map<Id, String> actIdRoleTierMap,Map<Id, String> tierIdNames){
        if(accChMem != null && !accChMem.isEmpty()){
            Map<Id, Set<Id>> actIdCtIdMap = new Map<Id, Set<Id>>();
            Map<Id,List<String>> newPartnerRoleMap = new Map<Id, List<String>>();
            Map<Id, String> contactIdRelName = new Map<id, String>(); 
             for(PRM_Account_Contact_Relationship__c acrRec : [select id,PRM_Relationship_Id__r.name,PRM_Account_Id__r.Core_IPA_Partner_Segment__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c, PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, PRM_Contact_Id__c, PRM_Contact_Id__r.Core_IPA_PartnerRole__c , PRM_Partner_Role__c,PRM_Account_Id__c,PRM_Contact_Id__r.Core_IPA_Contact_Segment__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in: accChMem.keySet() and PRM_Account_Id__r.RecordType.DeveloperName =: Label.PRM_Intel_Account and PRM_InActive_Ind__c=false and PRM_Status_Nm__c='Complete' and  PRM_Partner_Role__c in: accChMem.values()]){
                    if(accChMem.get(acrRec.PRM_Account_Id__c) == acrRec.PRM_Partner_Role__c)
                    {
                        if(actIdCtIdMap!=null && !actIdCtIdMap.isEmpty() &&actIdCtIdMap.containsKey(acrRec.PRM_Account_Id__c)){
                          actIdCtIdMap.get(acrRec.PRM_Account_Id__c).add(acrRec.PRM_Contact_Id__c);
                        }else{
                            actIdCtIdMap.put(acrRec.PRM_Account_Id__c, new Set<id>{acrRec.PRM_Contact_Id__c});
                        }
                    
                      if(contactIdRelName!=null && !contactIdRelName.isEMpty() && contactIdRelName.containsKey(acrRec.PRM_Contact_Id__c)){
                            String str = contactIdRelName.get(acrRec.PRM_Contact_Id__c);
                            str+=acrRec.PRM_Relationship_Id__r.name;
                            contactIdRelName.put(acrRec.PRM_Contact_Id__c, str);
                        }else{
                            contactIdRelName.put(acrRec.PRM_Contact_Id__c, acrRec.PRM_Relationship_Id__r.name + '-');
                        }
                    }
                 }
                 if(contactIdRelName!= null && !contactIdRelName.isEmpty()){
                    PRM_EntitlementResponseWrapper entWrap = new PRM_EntitlementResponseWrapper();
                    entWrap.actIdCtIdMap = actIdCtIdMap;
                    entWrap.actIdRoleTierMap = actIdRoleTierMap;
                    entWrap.tierIdNames = tierIdNames;
                    entWrap.newPartnerRoleMap = newPartnerRoleMap;
                    entWrap.contactIdRelName = contactIdRelName;
                    PRM_ACMUpdateAssignEntitlment auae = new PRM_ACMUpdateAssignEntitlment();
                    List<Core_Contact_Entitlement__c> entitlementsTOUpsert = auae.AssignEntitlements(entWrap);
                    List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
                    if(entitlementsTOUpsert!= null && !entitlementsTOUpsert.isEmpty()){
                        for(Core_Contact_Entitlement__c ce : entitlementsTOUpsert){
                            ce.Core_Status__c = 'Complete';
                            ceList.add(ce);
                        }
                    }
                    if(!ceList.isEmpty() && ceList != null){
                      //Database.UpsertResult[] urList = 
                      Database.upsert(ceList, false);
                    }
                 }
        }
    }
    public static void createLogEntry(String logEntryMsgString){
        string jobInitiatedDateTime = System.Now().format('MM/dd/YYYY HH:MM:SS','PST');
        if(logEntryMsgString!=''){// this block will create Log Entry records on the basis of length of logEntryMsg and Field limit.
            PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
            Integer fieldLength=Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
            logEntryUtility.addLogEntry(logEntryMsgString,fieldLength);
            for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
               Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'Job started at: '+ jobInitiatedDateTime +' PST' ,logEntryUtility.logEntryList[i] , '', '', '');
            }//loop ends here..
        }
    }
}