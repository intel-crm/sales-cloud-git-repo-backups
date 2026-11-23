/***************************************************************************************************************************************
Apex Class Name     : PRM_EntitlementUtility 
Version             : 1.0
Created Date        : July 2019
Function            : Handler for PRM_Contact_Entitlements_Insert_batch class to assign Contact Entitlements.

Modification Log    :
* Developer                     Date                          Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Utkarsh                   10-July-2019                   Added a new method assignContactEntitlements(List) to Update or Insert the ContactEntitlements whenever the PRM_Contact_Entitlements_Insert_batch class executes.
*************************************************************************************************************************************/

public without sharing class PRM_EntitlementUtility{
    
    Public static Map<Core_Contact_Entitlement__c,Id> ceMapToUpdate = new Map<Core_Contact_Entitlement__c,Id>();
    Public static Map<Id,Core_Contact_Entitlement__c> ceStatusMap = new Map<Id,Core_Contact_Entitlement__c>();
    Public static Map<Id,List<Core_Contact_Entitlement__c>> contactEntitelmentUpdateMap = new Map<Id,List<Core_Contact_Entitlement__c>>();
    Public static String origin  = 'PRM_EntitlementUtility';
    Public static String severity  = 'Critical';
    Public static String project  = 'IPA';
    Public static String errormessage  = 'Too many DML rows';
    Public static String updateReasonCSPFlow = System.Label.PRM_Entitlement_Source;
    Public static final String status_Success ='Success';
    Public static final String status_Failed ='Failed';
    Public static final String status_discarded ='Discarded';
    Public static final String status_Reason_UIOLI ='Contact Identity is Deleted as part of UIOLI';
    public static set<string> errorContIds=new set<String>(); 
    public static   string logentries;
    public static set<Id> accIdAssocSet=new set<Id>();
    public static set<Id> accIdRemoveSet=new set<Id>();

/************************************************************
Method:    assignContactEntitlements        
Return:    void
Purpose:   Assign New Entitelments to Contacts or Update Existing Entitelement
************************************************************/ 
    public static void assignContactEntitlements(List<PRM_Batch_Entitlement__c>lstBatchEntitlement){   
        //TWC729-4717 - getting instance of metadata
        Core_CustomMetadataObjectController customMetadata = new Core_CustomMetadataObjectController('PRM_Tracker_steps__mdt');
        Map<String,Object> entProcessMdt = customMetadata.getInstance('ENT_PROCESS');
        List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();
        //List<PRM_Tracker__c> retriveTrackerList = new List<PRM_Tracker__c>();
        //TWC729-4717 - initializing acm List for successful and unsuccessful upsert 
        map<Id, Core_Contact_Entitlement__c> conEntitlementUpsert = new  map<Id, Core_Contact_Entitlement__c>();
        list<PRM_Value_Exchange_Recommendation__c> opidRecList = new list<PRM_Value_Exchange_Recommendation__c>(); //TWC729-6800 EOL activities
        
        map<Id, Id> contAccountMap = new map<Id, Id>();
        
        set<Id> ceIdSet = new set<Id>();
        set<Id> intelAccIdSet = new set<Id>();
        //set<Id> opidRecIds = new set<Id>();
        // added as part of TWC729-5300
        Map<Id,String> entOpidMap = new Map<Id,String>();
        Id opidRecommendationRecordType = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_OPID).getRecordTypeId(); //OPID Recommendation
      //  Map<Id, PRM_Tracker__c> listOfAvailableMilestoneRecords = new Map<Id, PRM_Tracker__c>();
        Map<string, PRM_Tracker__c> listOfAvailableMilestoneRecords = new Map<string, PRM_Tracker__c>();
        List<PRM_Tracker__c> tList=new List<PRM_Tracker__c>();
        
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> finalCEList = new List<Core_Contact_Entitlement__c>();
        /*List<Core_Contact_Entitlement__c> contactEntitlement = new List<Core_Contact_Entitlement__c>();
        Map<Id,String> mapConToName = new Map<Id,String>();
        Map<Id,String> conToEntMap = new Map<Id,String>();
        Map<Id,Id> mapConToId = new Map<Id,Id>();*/
        List<Id> conId = new List<Id>();
        List<Id> entId = new List<Id>();    
        set<string> contRecordIds=new set<String>();
        Set<Id> accIdsEntitlementRemoved = new Set<Id>();
        Map<Id,Id> accOPIDmap = new Map<Id,Id>();
        Map<Id,String> entAgsMap = new Map<Id,String>();
        boolean updateCheck = true;
        boolean isExecuted = false;
     list<PRM_Tracker__c> updateLstTracker=new list<PRM_Tracker__c>();
        list<string> ceLst=new list<string> ();
    list<string> entitlementlist=new list<string> ();
          map<Id, list<string>> trackeMapAccCE=new map<Id, list<string>>();
          map<Id, PRM_Tracker__c> accTrackerMap=new map<Id, PRM_Tracker__c>();
          list<Id> listOfAccidForTrackerRecord=new list<Id>();
        string LogEntry;
        try{
            //Maping records for contact entitlements.
            // added PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c as part of TWC729-5300
            //ATHR Fix - TWC729-9556 - SJ
            for(PRM_VXEnttlmntMatrix__c ent :[Select id, PRM_Entitlement_Id__c,PRM_IsActive_Ind__c,
                                              PRM_Approval_Type_Nm__c,PRM_IPA_Partner_Role_Nm__c,PRM_AGS_Role__c,
                                              PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c/*,RecordType.Name,PRM_Partner_Benefit_Id__c,PRM_Contact_Relationship_Id__c,PRM_Entitlement_Id__r.Name*/ from PRM_VXEnttlmntMatrix__c 
                                              where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType 
                                              AND PRM_IsActive_Ind__c = True 
                                              AND PRM_IPA_Partner_Role_Nm__c != null /*AND PRM_Channel_Program_Level_Id__r.name<>'Member'*/])
            {
                entAgsMap.put(ent.PRM_Entitlement_Id__c,ent.PRM_AGS_Role__c);       
                entOpidMap.put(ent.PRM_Entitlement_Id__c,ent.PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c);                                           
            }
            for(PRM_Batch_Entitlement__c be :lstBatchEntitlement){
                if(String.isNotBlank(be.PRM_Contact_Id__r.Account.Core_IPA_One_Partner_Id__c)){
                    accOPIDmap.put(be.PRM_Contact_Id__r.AccountId , be.PRM_Contact_Id__r.Account.Core_IPA_One_Partner_Id__c);
                }
                conId.add(be.PRM_Contact_Id__c);
                entId.add(be.PRM_Entitlement_Id__c);
                contRecordIds.add(be.PRM_Contact_Id__c);
                contAccountMap.put(be.PRM_Contact_Id__c,be.PRM_Contact_Id__r.AccountId);
            }

            //Get all Existing Active Entitelments 
            if(conId.size()>0 && entId.size()>0){           
                getExistingEntitelments(conId,entId);
            }
            
            for(PRM_Batch_Entitlement__c be :lstBatchEntitlement){
                if(String.isNotBlank(be.PRM_Contact_Id__r.Core_Login_Status__c) || String.isNotBlank(be.PRM_Contact_Id__r.PRM_Wechat_Union_Id__c)){
                    if(be.PRM_Contact_Id__r.Core_Login_Status__c=='Active' || (be.PRM_Contact_Id__r.Core_Login_Status__c==System.Label.IPA_Downgrade_to_B2C && be.PRM_IsRemove_Ind__c != true) || String.isNotBlank(be.PRM_Contact_Id__r.PRM_Wechat_Union_Id__c)){                
                        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
                        ce.Core_Contact_Id__c = be.PRM_Contact_Id__c;
                        ce.Core_Entitlement_Id__c = be.PRM_Entitlement_Id__c;   
                        ce.Core_From_Source__c =((entAgsMap != null && !entAgsMap.IsEmpty()) && entAgsMap.containsKey(be.PRM_Entitlement_Id__c) && ( entAgsMap.get(be.PRM_Entitlement_Id__c) == '' || entAgsMap.get(be.PRM_Entitlement_Id__c) == null)) ?true:false;          
                        ce.Core_DontNotify__c = true;
                        ce.Core_Data_Loaded__c = true;
                        if(Test.isRunningTest()){ ce.Core_Engagement_Tier__c = 'Test Tier'; }                  
                        
                        //Checking If Contact Entitelment Rceord already exists 
                        if(ceMapToUpdate.containsKey(ce)){
                            ce.Id = ceMapToUpdate.get(ce); 
                            Core_Contact_Entitlement__c contEnt = ceStatusMap.get(ce.Id);
                            if(be.PRM_IsRemove_Ind__c){
                                accIdsEntitlementRemoved.add(be.PRM_Contact_Id__r.AccountId);
                                ce.Core_Selected__c = false; //Updating Entitlements if Batch entitlements records are created from trigger.
                                if((entAgsMap != null && !entAgsMap.IsEmpty()) && (entAgsMap.get(ce.Core_Entitlement_Id__c) != '' && entAgsMap.get(ce.Core_Entitlement_Id__c) != null)) { ce.Core_Status__c = 'Pending'; }
                                if(!finalCEList.contains(ce)){ finalCEList.add(ce);}
                            }
                            else{
                                if(contEnt.Core_Source__c == '' && contEnt.Core_Source__c == null){
                                    ce.Core_Source__c = updateReasonCSPFlow;  //Added for US539488:to Identify origin of Entitlement
                                    updateCheck = true;
                                }
                                if(!contEnt.Core_Selected__c){
                                    ce.Core_Selected__c = true;  //Updating Entitlements if Batch entitlements records are created from Batch class.
                                    if((entAgsMap != null && !entAgsMap.IsEmpty()) && (entAgsMap.get(ce.Core_Entitlement_Id__c) != '' && entAgsMap.get(ce.Core_Entitlement_Id__c) != null)){ce.Core_Status__c = 'Pending'; }
                                    updateCheck = true;
                                }
                                if(updateCheck && !finalCEList.contains(ce)){finalCEList.add(ce);}
                            }
                        }
                        else{ 
                            ce.Core_Selected__c = true; //Inserting Entitlements if Batch entitlements records are created from Batch class.
                            ce.Core_Source__c = updateReasonCSPFlow;
                            if((entAgsMap != null && !entAgsMap.IsEmpty()) && (entAgsMap.get(ce.Core_Entitlement_Id__c) != '' && entAgsMap.get(ce.Core_Entitlement_Id__c) != null)){ce.Core_Status__c = 'Pending'; }
                            if(!finalCEList.contains(ce)){finalCEList.add(ce);}
                        }               
                    }else{
                        be.PRM_Status_Nm__c =status_discarded;
                        be.PRM_Status_Reason_Txt__c=status_Reason_UIOLI;
                    }
                }
            }
            
            if(finalCEList.size() < Limits.getLimitDMLRows()){
                if(finalCEList != null && !finalCEList.IsEmpty()){
                    Database.UpsertResult[] conEntList = Database.upsert(finalCEList, false); // Upserting Contact Entitlements.
                    integer index = 0;
                    for (Database.UpsertResult sr : conEntList){                    
                        if(!sr.isSuccess()){ // Checking If any record got errored out while upserting.
                            List<String> errorMessages = new List<String>();
                            for(Database.Error err : sr.getErrors()){
                                errorMessages.add(err.getMessage());
                            } 
                            //createLogEntry(errorMessages, index,finalCEList, mapConToName, conToEntMap, mapConToId, lstBatchEntitlement);
                            createLogEntry(errorMessages, index, finalCEList, lstBatchEntitlement);
                        }
                        else{
                            ceIdSet.add(sr.getId());
                            lstBatchEntitlement[index].PRM_Status_Nm__c = status_Success; // Updating Batch Entitlemet record status to success if any record get errored out.
                            lstBatchEntitlement[index].PRM_Status_Reason_Txt__c = 'PRM_EntitlementUtility : Entitlement insertion/removal succeeded';//TWC729-8089 : Adding reason text : NJ
                        }
                        
                        
                        index ++;
                    }
                    
                    for(Core_Contact_Entitlement__c ce : finalCEList){
                        if(ce.Core_Contact_Id__c != null && contAccountMap.containsKey(ce.Core_Contact_Id__c) ){
                            if(ceIdSet.contains(ce.Id)){
                                //TWC729-4717 - updating set for successful upsert
                                conEntitlementUpsert.put(contAccountMap.get(ce.Core_Contact_Id__c), ce);
                            }
                            // added as part of TWC729-5300
                            if(entOpidMap.containsKey(ce.Core_Entitlement_Id__c) && entOpidMap.get(ce.Core_Entitlement_Id__c) == System.Label.PRM_Partner_Account_Group_Record_Type){ //Core_Partner_Account_Group
                                intelAccIdSet.add(contAccountMap.get(ce.Core_Contact_Id__c));
                            }                            
                        }
                    }
                    Map<Id,Id> oldOpidMap = new Map<Id,Id>();
                    if (!accIdsEntitlementRemoved.isEmpty()) {
                       for (Core_Account_Group_Member__c cag: [Select Id,Core_Partner_Account_Id__c,Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c WHERE Core_Intel_Account_Id__c IN:accIdsEntitlementRemoved AND Core_Inactive_Ind__c = FALSE ]) {
                            oldOpidMap.put(cag.Core_Intel_Account_Id__c , cag.Core_Partner_Account_Id__c);
                        }
                    }
                    //Set<Id> entitlementAddIds = new Set<Id>();
                    //Set<Id> entitlementRemoveIds = new Set<Id>();
           for(PRM_Tracker__c tr:[select id , Name,  PRM_Completed__c, PRM_Location_Account__c,  PRM_Milestone_Display_Name__c, PRM_Milestone__c, PRM_OPID_Recommendation__c, PRM_OPID__c, PRM_Type__c, PRM_OPID_account_name__c, PRM_Integration_Outbound_Message__c, PRM_LOC_account_name__c, 
          prm_skip_tracker__c, prm_entitlement_id__c  from PRM_Tracker__c where 
          prm_skip_tracker__c=true]){
                        ceLst.addAll(tr.prm_entitlement_id__c.split(';'));
                         trackeMapAccCE.put(tr.PRM_Location_Account__c,ceLst);
             accTrackerMap.put(tr.PRM_Location_Account__c,tr);
                         // map.put(accid, list<entitlement id>)
                         //    map.put(accid, trackerrecord)
                              }
            for (Id accId: conEntitlementUpsert.keySet()) {
            if(trackeMapAccCE!=null && trackeMapAccCE.containsKey(accId)){
                             entitlementlist = trackeMapAccCE.get(accId);
               } 
                            Core_Contact_Entitlement__c ce= conEntitlementUpsert.get(accid);
                                if(entitlementlist!=null && !entitlementlist.contains(ce.Core_Entitlement_Id__c)){
                                           listOfAccidForTrackerRecord.add(accid);    
                                }
                            
                            if(!listOfAccidForTrackerRecord.contains(accId)){
              if(accTrackerMap!=null && accTrackerMap.containsKey(accid)){
                             PRM_Tracker__c   trackerToUpdate = accTrackerMap.get(accid);
                                trackerToUpdate.prm_skip_tracker__c = false;
                                updateLstTracker.add(trackerToUpdate);
                }
                            }      
                        }      
                    for (Id accId: listOfAccidForTrackerRecord) {
                        if(accOPIDmap.containsKey(accId) && conEntitlementUpsert.get(accId).Core_Selected__c==true && !accIdAssocSet.contains(accId)){
                            trackerList.add(PRM_IPA_Utility.createTrackerInstance('OPID Updates','ENT_UPD_OPID_ASSOC',null,accId,accOPIDmap.get(accId),accOPIDmap.get(accId),'','',true,'','','Entitlements updated'));
                            accIdAssocSet.add(accId);
                        }
                        else if(oldOpidMap.containsKey(accId) && conEntitlementUpsert.get(accId).Core_Selected__c==false && !accIdRemoveSet.contains(accId)){
                            trackerList.add(PRM_IPA_Utility.createTrackerInstance('OPID Updates','ENT_UPD_OPID_REM',null,accId,oldOpidMap.get(accId),oldOpidMap.get(accId),'','',true,'','','Entitlements updated'));
                            accIdRemoveSet.add(accId);
                        }
                    }
                    isExecuted=true;
                    update lstBatchEntitlement;
                }else if(!isExecuted){
                    update lstBatchEntitlement;
                }
            }
            else{ string log=Core_Log_Entry.logEntryWithDetails(origin, project,'Message', severity,errormessage,'','' ,'',''); 
                if(log!=null )
                LogEntry=LogEntry!=null ?LogEntry+';'+log: log;
            }
        }
        catch(Exception ex){ 
            string log1=Core_Log_Entry.logEntryWithException(origin, project,'Exception', severity,errormessage,'','' ,'','',ex);
            if(log1!=null )
                LogEntry=LogEntry!=null ?LogEntry+';'+log1: log1;
                //PRM_Contact_Entitlements_Insert_batch.logentires=PRM_Contact_Entitlements_Insert_batch.logentires!=null?PRM_Contact_Entitlements_Insert_batch.logentires+';'+LogEntry:LogEntry;
                getlogentries.logentries=LogEntry;
                
        
        }

    }
    
/************************************************************
Method:    getExistingEntitelments        
Return:    void
Purpose:   Get Existing Active Entitelments related to Contacts and Entitelments  
************************************************************/ 
    public static void getExistingEntitelments(List<Id> conId,List<Id>entId){      
        for(Core_Contact_Entitlement__c ce :[Select Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Selected__c,Core_Status__c,Core_Data_Loaded__c,Core_DontNotify__c,Core_Type__c,Core_Source__c,Core_From_Source__c From Core_Contact_Entitlement__c Where Core_Contact_Id__c IN :conId AND Core_Entitlement_Id__c IN :entId]){
            Core_Contact_Entitlement__c newCe = new Core_Contact_Entitlement__c();
            newCe.Core_Contact_Id__c = ce.Core_Contact_Id__c;
            newCe.Core_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
            newCe.Core_Data_Loaded__c = true;
            newCe.Core_DontNotify__c = true;
            newCe.Core_From_Source__c = ce.Core_From_Source__c;
            if(Test.isRunningTest()){
                newCe.Core_Engagement_Tier__c = 'Test Tier';
            }     
            ceStatusMap.put(ce.Id,ce);
      ceMapToUpdate.put(newCe, ce.Id);                

        }       
    }
    
/************************************************************
Method:    updateBatchEntitelmentStatus        
Return:    List<PRM_Batch_Entitlement__c>
Purpose:   Update Batch Entitelment Record status to In-Progress  
************************************************************/ 
    public static List<PRM_Batch_Entitlement__c> updateBatchEntitelmentStatus(List<PRM_Batch_Entitlement__c> beList){
        List<PRM_Batch_Entitlement__c> batchEntList = new List<PRM_Batch_Entitlement__c>();
        set<string> conrecordids=new set<string>();
        string logentries;
        for(PRM_Batch_Entitlement__c be :beList){
            be.PRM_Status_Nm__c ='In Progress';
            be.PRM_Status_Reason_Txt__c ='PRM_EntitlementUtility : Batch Entitlement picked for processing';//TWC729-8089 : Adding reason text : NJ
            conrecordids.add(be.PRM_Contact_Id__c);
            batchEntList.add(be);
        }
        try{
            Database.update (batchEntList,false);}catch(Exception ex){string logE=Core_Log_Entry.logEntryWithException(origin, project,'Exception', severity,errormessage,'','' ,'','',ex);   logentries=logentries!=null?logentries+';'+logE:logentries;     if(conrecordids.size()>0 && System.Label.PRM_Tracker_Enabled=='true')  System.enqueueJob(new PRM_RegistrationTrackerUtility.UpdateTrackerSteps (null,conrecordids,logentries,'PRM_EntitlementUtility','Admin'));     }
        return batchEntList;
    }

    public static void createLogEntry(List<String> srList, integer index, List<Core_Contact_Entitlement__c> finalCEList, List<PRM_Batch_Entitlement__c> lstBatchEntitlement) {//
        for(String errmsg : srList){
            Id sId;
            String sObjectType = '';
            sId =finalCEList[index].Id;
            if(sId != null){
                sObjectType =  sId.getSObjectType().getDescribe().getName();}
            String tags = '';
            String accName =  '';
            //accName =mapConToName.get(finalCEList[index].Core_Contact_Id__c) == null?'':mapConToName.get(finalCEList[index].Core_Contact_Id__c);
            String benName =  '';
            //benName =conToEntMap.get(finalCEList[index].Core_Contact_Id__c) == null?'':conToEntMap.get(finalCEList[index].Core_Contact_Id__c);
            String accId =  '';
            //accId = mapConToId.get(finalCEList[index].Core_Contact_Id__c) == null ?'':mapConToId.get(finalCEList[index].Core_Contact_Id__c);
            // tag format used - <Account Name> ; <Benefit Name> ; <Account ID>
            tags = accName + ';' + benName + ';' + accId;
            string logentry=Core_Log_Entry.logEntryWithDetails(origin, project,'Message', severity, errmsg , '', sId, sObjectType, tags);
            PRM_EntitlementUtility.logentries=PRM_EntitlementUtility.logentries!=null?PRM_EntitlementUtility.logentries+';'+logentry:logentry;
            lstBatchEntitlement[index].PRM_Status_Nm__c = status_Failed; // Updating Batch Entitlemet record status to failed if any record get errored out.
            lstBatchEntitlement[index].PRM_Status_Reason_Txt__c = 'PRM_EntitlementUtility : Failed:'+errmsg;//TWC729-8089 : Adding reason text : NJ
        } 
    }
}