public class PRM_IPADQFixBatch implements  Database.Batchable<sObject>,Database.stateful {
 	public String logEntryMsgString='';
    public static Boolean dQFixBatch = false;
    public Set<Account> accsToSetIpaFlag = new Set<Account>();
    public List<PRM_Account_Contact_Relationship__c> acrToInactivate = new List<PRM_Account_Contact_Relationship__c>();
    public set<Contact> contSet = new Set<Contact>();
    
    public List<PRM_IPA_DQ_Logs__c> dqLogList = new List<PRM_IPA_DQ_Logs__c>();
    
    public static Database.QueryLocator start(Database.BatchableContext context){
        DateTime lastSuccessfulRun;
        PRM_BatchCustomSetting__c batchCustomSetting;
        batchCustomSetting = [Select Id, Name, PRM_NoOfRecords__c, PRM_SchedulingHour__c,PRM_PartnerType__c,PRM_ChannelProgramLevel__c From PRM_BatchCustomSetting__c Where Name =:System.Label.PRM_BatchValues];
        Integer batchExecutionInterval = batchCustomSetting.PRM_SchedulingHour__c.intValue();
        DateTime batchExecutionHours = System.Now().addHours(- batchExecutionInterval);
        List<AsyncApexJob> lastBatchRun = [SELECT CompletedDate FROM AsyncApexJob WHERE ApexClass.Name = 'PRM_IPADQFixBatch' AND Status =:System.Label.PRM_AsyncStatus Order By CompletedDate DESC LIMIT 1];
        //The batch picks all ACM Records last modified post the last batch run
        String query='';
        if(lastBatchRun != NULL && !lastBatchRun.IsEmpty()){
            lastSuccessfulRun = (DateTime)lastBatchRun[0].CompletedDate;
            query='Select Id, PRM_Account_Id__c,PRM_Status_Nm__c,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,PRM_Tier_Name_txt__c,createddate,PRM_Partner_Role__c,PRM_Account_Id__r.Name,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,PRM_Account_Id__r.Core_Business_Party_Id__c,PRM_Account_Id__r.Core_Parent_Business_Party_Id__c,PRM_Account_Id__r.Core_Unified_Global_Customer_BP_Id__c,PRM_Account_Id__r.Core_Customer_Aggregation_Type__c,PRM_Account_Id__r.Core_Unified_Global_Customer_Name__c From PRM_AccountChannelMembership__c Where PRM_Account_Id__r.Recordtype.name=\'Intel Account\' and  PRM_Channel_Program_Id__r.Name =\'Intel Partner Alliance\' AND PRM_Channel_Program_Level_Id__r.PRM_inactind__c =false  AND (LastModifiedDate > :batchExecutionHours OR LastModifiedDate > :lastSuccessfulRun) AND lastmodifiedby.name!=\'IPA Data Migration User\'';
        }else{
            query='Select Id, PRM_Account_Id__c,PRM_Status_Nm__c,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,PRM_Tier_Name_txt__c,createddate,PRM_Partner_Role__c,PRM_Account_Id__r.Name,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,PRM_Account_Id__r.Core_Business_Party_Id__c,PRM_Account_Id__r.Core_Parent_Business_Party_Id__c,PRM_Account_Id__r.Core_Unified_Global_Customer_BP_Id__c,PRM_Account_Id__r.Core_Customer_Aggregation_Type__c,PRM_Account_Id__r.Core_Unified_Global_Customer_Name__c From PRM_AccountChannelMembership__c Where PRM_Account_Id__r.Recordtype.name=\'Intel Account\' and PRM_Channel_Program_Id__r.Name =\'Intel Partner Alliance\' AND PRM_Channel_Program_Level_Id__r.PRM_inactind__c =false AND LastModifiedDate > :batchExecutionHours AND lastmodifiedby.name!=\'IPA Data Migration User\'';
        }
        return database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<PRM_AccountChannelMembership__c> scope){
        logEntryMsgString+='Inside execute method, scope size: '+scope.size();
        Set<String> accountIds = new Set<String>();
        Set<String> triggeringAcmIds = new Set<String>();
        Map<String,List<PRM_AccountChannelMembership__c>> approvedAccAcmMap = new Map<String,List<PRM_AccountChannelMembership__c>>();
        Map<String,List<PRM_AccountChannelMembership__c>> pendingAccAcmMap = new Map<String,List<PRM_AccountChannelMembership__c>>();
        Map<String,List<PRM_Account_Contact_Relationship__c>> ipaAccAcrs = new Map<String,List<PRM_Account_Contact_Relationship__c>>();
        
        

        for(PRM_AccountChannelMembership__c acm: scope){
            if(acm.PRM_Status_Nm__c=='Approved'){
                if(!approvedAccAcmMap.containsKey(acm.PRM_Account_Id__c)){
                    approvedAccAcmMap.put(acm.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{acm});
                } else {
                    approvedAccAcmMap.get(acm.PRM_Account_Id__c).add(acm);
                }
            }else if( acm.PRM_Status_Nm__c =='Pending'){
                if(!pendingAccAcmMap.containsKey(acm.PRM_Account_Id__c)){
                    pendingAccAcmMap.put(acm.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{acm});
                } else {
                    pendingAccAcmMap.get(acm.PRM_Account_Id__c).add(acm);
                }
            }
            //Account Ids of all the ACMs retrieved
            accountIds.add(acm.PRM_Account_Id__c);
            triggeringAcmIds.add(acm.id);
        }
        if(accountIds!=null && !accountIds.isEmpty()){
            //get all the approved ACMs for that Account
            for(PRM_AccountChannelMembership__c acm : [Select Id, PRM_Account_Id__c,PRM_Status_Nm__c,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,PRM_Tier_Name_txt__c,createddate,PRM_Partner_Role__c,PRM_Account_Id__r.Name,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,PRM_Account_Id__r.Core_Business_Party_Id__c,PRM_Account_Id__r.Core_Parent_Business_Party_Id__c,PRM_Account_Id__r.Core_Unified_Global_Customer_BP_Id__c,PRM_Account_Id__r.Core_Customer_Aggregation_Type__c,PRM_Account_Id__r.Core_Unified_Global_Customer_Name__c From PRM_AccountChannelMembership__c where PRM_Account_Id__c in: accountIds and id not in: triggeringAcmIds and PRM_Channel_Program_Level_Id__r.PRM_inactind__c =false]){
                if(acm.PRM_Status_Nm__c=='Approved'){
                    if(!approvedAccAcmMap.containsKey(acm.PRM_Account_Id__c)){
                        approvedAccAcmMap.put(acm.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{acm});
                    } else {approvedAccAcmMap.get(acm.PRM_Account_Id__c).add(acm);
                    }
                }else if( acm.PRM_Status_Nm__c =='Pending'){
                    if(!pendingAccAcmMap.containsKey(acm.PRM_Account_Id__c)){pendingAccAcmMap.put(acm.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{acm});
                    } else {pendingAccAcmMap.get(acm.PRM_Account_Id__c).add(acm);
                    }
                }
            } 
            //query all ACR for the accounts whose ACM got retrieved
            for(PRM_Account_Contact_Relationship__c acr: [Select id,PRM_Status_Nm__c,PRM_InActive_Ind__c,PRM_Contact_Id__c,PRM_Contact_Id__r.Core_IPA_PartnerRole__c,PRM_Contact_Id__r.Core_Login_Status__c,
                                                        PRM_Contact_Id__r.Core_Enterprise_Id__c,PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Badge_Tier__c,PRM_Account_Id__r.PRM_IPA_Badge_Tier_Date__c,
                                                        PRM_Account_Id__r.Core_IPA_Partner_Role__c , PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c 
                                                        from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c  in: accountIds]){
                //acr is active Complete and account has approved acm 
                if(!acr.PRM_InActive_Ind__c && acr.PRM_Status_Nm__c=='Complete' && approvedAccAcmMap.containsKey(acr.PRM_Account_Id__c)){
                    //ipa account checkbox is not checked
                    List<PRM_AccountChannelMembership__c> acmList = approvedAccAcmMap.get(acr.PRM_Account_Id__c);
                    List<String> consolidatedRole= new List<String>();
                    String tier = null;
                    DateTime tierdate=null;
                    for(PRM_AccountChannelMembership__c acm:acmList ){
                        consolidatedRole.add(acm.PRM_Partner_Role__c);
                        if( tier==null){
                            tier=acm.PRM_Tier_Name_txt__c;
                            tierdate= acm.createddate;
                        }else if(tier=='Partner' && acm.PRM_Tier_Name_txt__c=='Prestige'){
                            tier = acm.PRM_Tier_Name_txt__c;tierdate = acm.createddate;
                        }else if(tier=='Prestige'){continue;
                        }
                    }
                    if(!acr.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c){
                        Account acc = new Account();
                        acc.id=acr.PRM_Account_Id__c;
                        acc.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
                        acc.Core_IPA_Badge_Tier__c=(acc.Core_IPA_Badge_Tier__c!=null && acc.Core_IPA_Badge_Tier__c==tier)?acc.Core_IPA_Badge_Tier__c:tier;
                        acc.PRM_IPA_Badge_Tier_Date__c= acc.PRM_IPA_Badge_Tier_Date__c!=null?acc.PRM_IPA_Badge_Tier_Date__c:tierdate;
                        acc.Core_IPA_Partner_Role__c=String.join(consolidatedRole,';');
                        //badge tier and other fields
                        accsToSetIpaFlag.add(acc);
                    }
                    //Contact is IPA but partner role is not stamped
                    if((acr.PRM_Contact_Id__r.Core_IPA_PartnerRole__c==null || !consolidatedRole.contains(acr.PRM_Contact_Id__r.Core_IPA_PartnerRole__c))
                        && acr.PRM_Contact_Id__r.Core_Login_Status__c =='Active' && acr.PRM_Contact_Id__r.Core_Enterprise_Id__c!=null){
                        Contact con= new Contact();
                        con.id= acr.PRM_Contact_Id__c;
                        con.Core_IPA_PartnerRole__c=consolidatedRole[0];
                        contSet.add(con);
                    }
                }
                //acr is inactive and account has no approved acm but ipa account checkbox is checked
                else if(!approvedAccAcmMap.containsKey(acr.PRM_Account_Id__c) && acr.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c){
                    Account acc = new Account();
                        acc.id=acr.PRM_Account_Id__c;
                        acc.Core_Intel_Partner_Alliance_PartnerGroup__c=false;
                        acc.Core_IPA_Badge_Tier__c=null;
                        acc.PRM_IPA_Badge_Tier_Date__c= null;
                        acc.Core_IPA_Partner_Role__c=null;
                        accsToSetIpaFlag.add(acc);
                }
                //acr is active Complete but the account has no approved acm
                if((approvedAccAcmMap==null || approvedAccAcmMap.isEmpty() || !approvedAccAcmMap.containsKey(acr.PRM_Account_Id__c))&& 
                (pendingAccAcmMap==null || pendingAccAcmMap.isEmpty() || !pendingAccAcmMap.containsKey(acr.PRM_Account_Id__c)) && !acr.PRM_InActive_Ind__c && acr.PRM_Status_Nm__c=='Complete'){
                    acr.PRM_InActive_Ind__c = true;
                    acr.PRM_Status_Reason_Txt__c ='Inactivated as Account has become Non IPA';
                    acrToInactivate.add(acr);
                }
                                                            
                
            }
        }

     
        
    }
    
    // Helper to notify when DML batch list exceeds threshold
    // Uses PRM_EmailUtility similar to opidAssociationEmail method
    public void sendWarningEmail(List<sObject> dmlList, String objectName){
        
        try{
            Map<String, Map<String, Object>> dqObjectsMap = getCustomMetadataRecords();
            // Get scenario description from custom metadata using helper method
            String scenarioDescription = '';
             // Get scenario description based on object name
            if(dqObjectsMap != null && !dqObjectsMap.isEmpty()){
                for(String metadataRec : dqObjectsMap.keySet()){
                    if(dqObjectsMap.get(metadataRec).get('Object__c') == objectName){
                        scenarioDescription = (String)dqObjectsMap.get(metadataRec).get('Scenario__c');
                        break;
                    }
                }
            }
            
            // Fallback to default message if no scenario found
            if(String.isEmpty(scenarioDescription)){
                scenarioDescription = 'Exception Unknown';
            }
            
            // Prepare placeholder map similar to opidAssociationEmail
            Map<String,String> placeholderMap = new Map<String,String>();
            placeholderMap.put('%ObjectName%', objectName);
            placeholderMap.put('%RecordCount%', String.valueOf(dmlList.size()));
            placeholderMap.put('%ScenarioDescription%', scenarioDescription != null ? scenarioDescription : 'Records will be updated as part of PRM_IPADQFixBatch processing.');
            placeholderMap.put('%ProcessDate%', String.valueOf(System.today()));
            
            // Call email utility from PRM_OPIDProcessUtility
            PRM_OPIDProcessUtility.callSendEmailUtil(placeholderMap, 'IPA_DQ_Email');

            PRM_IPA_DQ_Logs__c dqLog = new PRM_IPA_DQ_Logs__c();
            dqLog.PRM_Object_Name__c=objectName;
            dqLog.PRM_Message__c = scenarioDescription;
            dqLog.PRM_Apex_Class_Name__c = 'PRM_IPADQFixBatch';
            dqLogList.add(dqLog);

            
            logEntryMsgString += '\n[WarningEmailSent] Using PRM_EmailUtility for ' + objectName + ' with ' + dmlList.size() + ' records';
            
        } catch(Exception e){
            logEntryMsgString += '\n[WarningEmailSendFailed] ' + e.getMessage();
        }
    }
    
    public void finish(Database.BatchableContext context){
         List<Account> accountToUpdate = new List<Account>();
        List<Contact> contToUpdate= new List<Contact>();

        try{
        // Get threshold from custom metadata (Field_3__c of record with MasterLabel 'Threshold')
            Decimal threshold=0;
            Map<String, Map<String, Object>> dqObjectsMap = getCustomMetadataRecords();
            if(dqObjectsMap != null && !dqObjectsMap.isEmpty()){
                if(dqObjectsMap.containsKey('Threshold')){
                    threshold = Decimal.valueOf(String.valueOf(dqObjectsMap.get('Threshold').get('Threshold__c')));
                }
            }
            if(accsToSetIpaFlag!=null && !accsToSetIpaFlag.isEmpty()){
                logEntryMsgString+='\n accsToSetIpaFlag: '+accsToSetIpaFlag;
                accountToUpdate.addAll(accsToSetIpaFlag);
                if(accountToUpdate.size() < threshold){
                    List<Database.SaveResult> accresult = Database.Update(accountToUpdate,false);
                    handleResult(accresult, 'Account',accsToSetIpaFlag);
                }else{
                    sendWarningEmail(accountToUpdate,'Account');
                }
            }
            if(acrToInactivate!=null && !acrToInactivate.isEmpty()){
                logEntryMsgString+='\n acrToInactivate: '+acrToInactivate;
                System.debug('before update condition:'+acrToInactivate);
                if(acrToInactivate.size() < threshold){
                    List<Database.SaveResult> acrresult = Database.Update(acrToInactivate,false);
                    handleResult(acrresult, 'PRM_Account_Contact_Relationship__c',null);
                }else{
                    sendWarningEmail(acrToInactivate,'PRM_Account_Contact_Relationship__c');
                }

            }
            if(contSet!=null && !contSet.isEmpty()){
                logEntryMsgString+='\n contToUpdate: '+contToUpdate;
                contToUpdate.addAll(contSet);
                if(contToUpdate.size() < threshold){
                    List<Database.SaveResult> conresult = Database.Update(contToUpdate,false);
                    handleResult(conresult, 'Contact',null);
                }else{
                    sendWarningEmail(contToUpdate,'Contact');
                }
            }
            List<Database.SaveResult> dqResultList = Database.insert(dqLogList,false);
            for(Database.SaveResult dqResult: dqResultList){
                if(!dqResult.isSuccess()){
                    for (Database.Error err : dqResult.getErrors()) {
                        logEntryMsgString+= 'Message: ' + err.getMessage() + '\n'  + 'Fields: ' + err.Fields.toString() + '\n' + 'StatusCode: ' + err.getStatusCode() + '\n';
                    }
                }
            }
        }catch(Exception ex){
            logEntryMsgString+='\n errors:'+ex;
        }
        string jobInitiatedDateTime = System.Now().format('MM/dd/YYYY HH:MM:SS','PST');
        if(logEntryMsgString!=''){// this block will create Log Entry records on the basis of length of logEntryMsg and Field limit.
            PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
            Integer fieldLength=Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
            logEntryUtility.addLogEntry(logEntryMsgString,fieldLength);
            for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
                Core_Log_Entry.logEntryWithDetails('PRM_IPADQFixBatch', 'IPA', 'PRM_IPADQFixBatch', 'Medium','Job started at: '+ jobInitiatedDateTime +' PST' ,logEntryUtility.logEntryList[i] , '', '', '');
            }//loop ends here..
        }
    }
        //add log entries for batch run or not
        //failure email
        //log entry in flow
        //DQ log entry for each record
    public void handleResult(List<Database.SaveResult> result, String objectName,Set<Account> accsToSetIpaFlag ){
        PRM_IPA_DQ_Logs__c dqLog = new PRM_IPA_DQ_Logs__c();
        List<id> accountIds = new List<id>();
        List<id> acrIds = new List<id>();
        List<Id> contactId = new List<id>();
        String message='Time: '+System.today();
        for(Database.SaveResult sr: result){
            if(!sr.isSuccess()){
                for(Database.Error err: sr.getErrors()){
                    logEntryMsgString+= 'Message: ' + err.getMessage() + '\n' + 'Fields: ' + err.Fields.toString() + '\n' + 'StatusCode: ' + err.getStatusCode() + '\n';
                }
            }else{
                if(objectName=='Account'){
                    accountIds.add(sr.getId());
                }else if(objectName =='PRM_Account_Contact_Relationship__c'){
                    message+='\nFor a Non IPA Account, ACR got inactivated: '+sr.getId();
                }else if(objectName == 'Contact'){
                    message+='\nFor an IPA Contact, Contact Partner Role got fixed: '+sr.getId();
                }
            }
        }
        if(accsToSetIpaFlag!=null && !accsToSetIpaFlag.isEmpty()){
            for(Account acc: accsToSetIpaFlag){
                if(accountIds.contains(acc.id)){
                    if(acc.Core_Intel_Partner_Alliance_PartnerGroup__c){
                        message+='\nFor an IPA Account IPA Flag, badge tier, role got fixed on Account: '+acc.id;
                    }else{
                        message+='\nFor a Non IPA Account IPA Flag, badge tier, role got fixed on Account: '+acc.id;
                    }
                }
            }
        }
        dqLog.PRM_Object_Name__c=objectName;
        dqLog.PRM_Message__c = message;
        dqLog.PRM_Apex_Class_Name__c = 'PRM_IPADQFixBatch';
        dqLogList.add(dqLog);
    }
    public  Map<String, Map<String, Object>> getCustomMetadataRecords (){
        Map<String, Map<String, Object>> dqObjectsMap = new Map<String, Map<String, Object>>();
        Core_CustomMetadataObjectController customMetadataController = new Core_CustomMetadataObjectController('DQ_Objects_mdt');
        dqObjectsMap = customMetadataController.getAll();
        return dqObjectsMap;
    }
}