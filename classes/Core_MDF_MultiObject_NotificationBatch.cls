/**************************************************************************************
Apex Class Name:  Core_MDF_MultiObject_NotificationBatch
Version     : 1.0 
Created Date: 01/09/2025
Function    : Notification if there is no Active Approvers
Modification Log :
* Developer                   Date                   Description
*************************************************************************************/

global class Core_MDF_MultiObject_NotificationBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    public Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery currentQuery;
    private Integer currentIndex;
    
    public Set<String> csvDataList = new Set<String>{'Id,Name,Program'}; 
        public Id recordTrackingId;
    
    public Core_MDF_MultiObject_NotificationBatch() {
        this.recordTrackingId = null;
        Integer index=0;
        List<Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery> queries = Core_MDF_MultiObjectBatchHandler.prepareQueries();
        if (index < queries.size()) {
            currentQuery = queries[index];
            currentIndex = index;
        }
        
    }
    public Core_MDF_MultiObject_NotificationBatch(Integer index, Id recordTrackingId) {
        this.recordTrackingId = recordTrackingId;
        List<Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery> queries = Core_MDF_MultiObjectBatchHandler.prepareQueries();
        if (index < queries.size()) {
            currentQuery = queries[index];
            currentIndex = index;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String fields = String.join(currentQuery.fields, ', ');
        String query = 'SELECT ' + fields + ' FROM ' + currentQuery.objectName + ' ' + currentQuery.queryCondition;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) { 
        
        Map<SObject, String> mapOfUniqueIdVsSobject = new Map<SObject, String>();
        Map<SObject, String> mapOfSobjectVAllAccsuniqueKey = new Map<SObject, String>();
        Set<Id> setOfUltimateAccIds = new Set<Id>();
        Set<String> listOfIupgmUniqueKey = new Set<String>();
        Set<String> setOfQueueApiname = new Set<String>();
        Map<Id,String> mapOfAccIdsVsuniqueKey = new Map<Id,String>();
        Set<Id> setOfPnumAccIds= new Set<Id>();
        Set<Id> setOfAccIds= new Set<Id>();
        Set<Id> setOfPrdIdForManger = new Set<Id>(); 
        Set<String> setOfPublicGrpNm = new Set<String>();
        
        
        if (currentQuery.objectName == 'PartnerMarketingBudget') {
            processPartnerMarketingBudget(scope, currentQuery,mapOfUniqueIdVsSobject,mapOfSobjectVAllAccsuniqueKey,setOfUltimateAccIds,setOfQueueApiname,listOfIupgmUniqueKey);
        }
        else if (currentQuery.objectName == 'PartnerFundRequest') {
            processPartnerFundRequest(scope, currentQuery,mapOfUniqueIdVsSobject,mapOfSobjectVAllAccsuniqueKey,setOfUltimateAccIds,setOfQueueApiname,listOfIupgmUniqueKey,setOfAccIds,setOfPrdIdForManger,setOfPublicGrpNm);
        }
        else if (currentQuery.objectName == 'Campaign') {
            processCampaign(scope, currentQuery,mapOfUniqueIdVsSobject,mapOfSobjectVAllAccsuniqueKey,setOfUltimateAccIds,setOfQueueApiname,listOfIupgmUniqueKey,setOfAccIds);
        }
        
        if(!setOfQueueApiname.isEmpty()){  
            Set<String> setOfQueueName = Core_MDF_MultiObjectBatchHandler.getQueuesWithActiveUsers(setOfQueueApiname);    
            if (!setOfQueueName.isEmpty()) {
                listOfIupgmUniqueKey.addAll(setOfQueueName);
            }
            
        }
        if(!setOfAccIds.isEmpty()){
            for (Core_MDF_Partner_Node_User_Mapping__c pnum : [ SELECT Core_MDF_Account__c FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Account__c IN :setOfAccIds
                                                               AND Core_MDF_User__r.IsActive = true
                                                               AND Core_MDF_Active_Ind__c = true]) {
                                                                   setOfPnumAccIds.add(pnum.Core_MDF_Account__c);
                                                               }
        }
        if(!setOfPublicGrpNm.isEmpty()){
            Set<String> setOfPublicName = Core_MDF_MultiObjectBatchHandler.getPublicGroupsWithActiveUsers(setOfPublicGrpNm);    
            if (!setOfPublicGrpNm.isEmpty()) {
                listOfIupgmUniqueKey.addAll(setOfPublicName);
            }
            
        }
        
        // Step 3: Identify invalid records
        if(!mapOfUniqueIdVsSobject.isEmpty()){
            for (SObject sobj : mapOfUniqueIdVsSobject.keySet()) {
                if(currentQuery.objectName == 'Campaign'){
                    Campaign cmp = (Campaign) sobj;
                    String uniqueKey = mapOfUniqueIdVsSobject.containsKey(sobj) ? mapOfUniqueIdVsSobject.get(sobj) : null;
                    String uniqueKeyForAll = mapOfSobjectVAllAccsuniqueKey.containsKey(sobj) ? mapOfSobjectVAllAccsuniqueKey.get(sobj) : null;
                    Id pnumAccIds = (cmp.Core_MDF_Approval_Stage_nm__c == Core_MDF_CCP_ConstantClass.PFR_CUSTOMER_ACCEPTANCE) ? cmp.Core_MDF_Account__c: null;
                    
                    if (!listOfIupgmUniqueKey.contains(uniqueKey) && !listOfIupgmUniqueKey.contains(uniqueKeyForAll) && !setOfPnumAccIds.contains(pnumAccIds)) {
                        Core_MDF_SFReportWrapper wrap = new Core_MDF_SFReportWrapper(sobj, currentQuery.objectName);
                        csvDataList.add(wrap.toCsvRow());
                    }
                }
                else if(currentQuery.objectName == 'PartnerMarketingBudget'){
                    String uniqueKey = mapOfUniqueIdVsSobject.containsKey(sobj) ? mapOfUniqueIdVsSobject.get(sobj) : null;
                    String uniqueKeyForAll = mapOfSobjectVAllAccsuniqueKey.containsKey(sobj) ? mapOfSobjectVAllAccsuniqueKey.get(sobj) : null;
                    
                    if (!listOfIupgmUniqueKey.contains(uniqueKey) && !listOfIupgmUniqueKey.contains(uniqueKeyForAll)) {
                        Core_MDF_SFReportWrapper wrap = new Core_MDF_SFReportWrapper(sobj, currentQuery.objectName);
                        csvDataList.add(wrap.toCsvRow());
                    }
                    
                }
                else if(currentQuery.objectName == 'PartnerFundRequest'){
                    PartnerFundRequest pfr = (PartnerFundRequest) sobj;
                    
                    String uniqueKey = mapOfUniqueIdVsSobject.containsKey(sobj) ? mapOfUniqueIdVsSobject.get(sobj) : null;
                    String uniqueKeyForAll = mapOfSobjectVAllAccsuniqueKey.containsKey(sobj) ? mapOfSobjectVAllAccsuniqueKey.get(sobj) : null;
                    Id pnumAccIds = (Core_MDF_CCP_ConstantClass.APPROVAL_STAGE_FOR_EXTERNAL_USER.Contains(pfr.Core_MDF_Approval_Stage__c)) ? pfr.ChannelPartnerId: null; 
                    Id prfIdForRmfLevelManager = (Core_MDF_CCP_ConstantClass.FIRST_SECOND_LEVEL_MGR.Contains(pfr.Core_MDF_Approval_Stage__c)) ? pfr.Id : null;
                    
                    if (!listOfIupgmUniqueKey.contains(uniqueKey) && !listOfIupgmUniqueKey.contains(uniqueKeyForAll) && !setOfPnumAccIds.contains(pnumAccIds) && !setOfPrdIdForManger.contains(prfIdForRmfLevelManager)) {
                        
                        Core_MDF_SFReportWrapper wrap = new Core_MDF_SFReportWrapper(sobj, currentQuery.objectName);
                        csvDataList.add(wrap.toCsvRow());
                    }
                }
            } 
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        if (recordTrackingId == null) {
            Core_MDF_Record_Tracking__c rt = new Core_MDF_Record_Tracking__c();
            rt.Core_MDF_Scope_nm__c = 'Missing Approver Roles Configuration';
            insert rt;
            recordTrackingId = rt.Id;
        }
        
        if (csvDataList.size() > 1) {
            ContentVersion cv = createContentVersion(csvDataList);
            insert cv;
            saveAttachment(new List<ContentVersion>{cv});
        }
        
        List<Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery> queries = Core_MDF_MultiObjectBatchHandler.prepareQueries();
        Integer nextIndex = currentIndex + 1;
        if (nextIndex < queries.size()) {
            Integer batchSize = Core_MDF_CustomLabelConfig.getIntegerValues('Core_MDF_Missing_approver_NotifyLogBatch');
            Database.executeBatch(new Core_MDF_MultiObject_NotificationBatch(nextIndex, recordTrackingId), batchSize); // Add batch size in the custom label confi meta data
        } else {
            sendNotificationEmails();
        }
    }
    
    private void saveAttachment(List<ContentVersion> cvs) {
        if (recordTrackingId == null) return;
        
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (ContentDocument cd : [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :cvs]) {
            links.add(new ContentDocumentLink(
                ContentDocumentId = cd.Id,
                LinkedEntityId = recordTrackingId,
                ShareType = 'V',
                Visibility = 'InternalUsers'
            ));
        }
        insert links;
    }
    
    private ContentVersion createContentVersion(Set<String> data) {
        String objectName = currentQuery != null ? currentQuery.objectName : 'UnknownObject';
        ContentVersion cv = new ContentVersion();
        cv.Title = objectName + ': Missing Approver Roles Configuration';
        cv.VersionData = Blob.valueOf(String.join(data, '\n'));
        cv.PathOnClient = objectName + ': Missing Approver Roles Configuration.csv';
        
        return cv;
    }
    
    private void sendNotificationEmails() {
        String groupName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Missing_Approver_Roles_Configur'); 
        String templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_No_Approver_Email_Notifier');
        
        List<EmailTemplate> templates = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];
        if (templates.isEmpty() || recordTrackingId == null) return;
        
        List<String> userIds = new List<String>();
        for (GroupMember gm : [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = :groupName]) {
            userIds.add(gm.UserOrGroupId);
        }
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (User usr : [SELECT Id FROM User WHERE Id IN :userIds]) {
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setWhatId(recordTrackingId);
            msg.setTemplateId(templates[0].Id);
            msg.setTargetObjectId(usr.Id);
            msg.setSaveAsActivity(false);
            msg.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
            emails.add(msg);
        }
        
        if (!emails.isEmpty()) {
            Core_MDF_GenericClassToSendMail.sendEmails(emails);
        }
    }
    
    // Report Wrapper
    public class Core_MDF_SFReportWrapper {
        public String RecordId;
        public String Title;
        public String ProgramName;
        public String AccountName;
        public String ApprovalStage;
        
        public Core_MDF_SFReportWrapper(SObject sobj, String objectName) {
            this.RecordId = (String)sobj.get('Id');
            if (objectName == 'PartnerMarketingBudget') {
                this.Title = (String)sobj.get('Title'); 
                this.ProgramName = (String)sobj.get('Core_MDF_Program_Nm__c');
            }
            else if (objectName == 'Campaign') {
                this.Title = (String)sobj.get('Name');
                this.ProgramName = (String)sobj.get('Core_MDF_Program__c');
            }
            else if (objectName == 'PartnerFundRequest') {
                this.Title = (String)sobj.get('Title');
                this.ProgramName = (String)sobj.get('Core_MDF_Program__c');
            }
        }
        
        public String toCsvRow() {
            return RecordId + ',' + Title + ',' + ProgramName;
        }
    }
    
    /***************************************************************************************************
Method Name:  processPartnerMarketingBudget
Version     : 1.0 
Created Date: 01/09/2025
Function    : 
Input Parameters: The list of SObjects (PartnerMarketingBudget,processCampaign,processPartnerFundRequest) in the current batch scope.
Output Parameters: Populates maps (mapOfUniqueIdVsSobject, mapOfSobjectVAllAccsuniqueKey) with calculated keys.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rishabh                   01/09/2025             Created
* Rishabh                    01/09/2025             Modified
****************************************************************************************************/
    public static void processPartnerMarketingBudget(List<SObject> scope,Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery currentQuery,Map<SObject, String> mapOfUniqueIdVsSobject,
                                                     Map<SObject, String> mapOfSobjectVAllAccsuniqueKey,Set<Id> setOfUltimateAccIds,Set<String> setOfQueueApiname,Set<String> listOfIupgmUniqueKey){
                                                         set<string> setOfPrgmId = new set<string>();
                                                         set<string> setOfrole = new set<string>();
                                                         
                                                         
                                                         for(SObject sobj : scope){                                    
                                                             PartnerMarketingBudget pmb = (PartnerMarketingBudget) sobj;
                                                             if (pmb.Core_MDF_Program_Nm__c != null && pmb.Core_MDF_Budget_Type__c != null && pmb.Core_MDF_Ultimate_Account_Id__c!=null) { // add null check Core_MDF_Ultimate_Account_Id__c
                                                                 
                                                                 // Case 1: Role based on ApprovalStage
                                                                 if (!currentQuery.mapOfApprovalStageToRole.isEmpty() && currentQuery.mapOfApprovalStageToRole.containsKey(pmb.Core_MDF_Program_Nm__c)) {
                                                                     if(Core_MDF_CCP_ConstantClass.Budget_Type_For_IPA_EEF_COGTM.Contains(pmb.Core_MDF_Budget_Type__c)){
                                                                         // Unique key for campaign record
                                                                         String uniqueKey = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                             pmb.Core_MDF_Ultimate_Account_Id__c,
                                                                                 pmb.Core_MDF_Program__c,
                                                                                 currentQuery.mapOfApprovalStageToRole.get(pmb.Core_MDF_Program_Nm__c)
                                                                                 });
                                                                         
                                                                         // Unique Key for "All Accounts"
                                                                         String uniqueKeyForAllAcc = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                             pmb.Core_MDF_Program__c,
                                                                                 currentQuery.mapOfApprovalStageToRole.get(pmb.Core_MDF_Program_Nm__c)
                                                                                 });
                                                                         
                                                                         mapOfUniqueIdVsSobject.put(pmb, uniqueKey);
                                                                         setOfUltimateAccIds.add(pmb.Core_MDF_Ultimate_Account_Id__c);
                                                                         mapOfSobjectVAllAccsuniqueKey.put(pmb,uniqueKeyForAllAcc);
                                                                         setOfrole.add(currentQuery.mapOfApprovalStageToRole.get(pmb.Core_MDF_Program_Nm__c));
                                                                         setOfPrgmId.add(pmb.Core_MDF_Program__c);
                                                                     }
                                                                 }
                                                                 
                                                                 // Case 2: BudgetType based
                                                                 else if (!currentQuery.mapOfProgramToBudgetTypeToQueue.isEmpty() && currentQuery.mapOfProgramToBudgetTypeToQueue.containsKey(pmb.Core_MDF_Program_Nm__c) && 
                                                                          currentQuery.mapOfProgramToBudgetTypeToQueue.get(pmb.Core_MDF_Program_Nm__c).containsKey(pmb.Core_MDF_Budget_Type__c)) {   // Null check
                                                                              
                                                                              if (Core_MDF_CCP_ConstantClass.MDF_BUDGETTYPES.Contains(pmb.Core_MDF_Budget_Type__c)) {
                                                                                  
                                                                                  String uniqueKey = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                                      pmb.Core_MDF_Ultimate_Account_Id__c,
                                                                                          pmb.Core_MDF_Program__c,
                                                                                          currentQuery.mapOfProgramToBudgetTypeToQueue.get(pmb.Core_MDF_Program_Nm__c).get(pmb.Core_MDF_Budget_Type__c)
                                                                                          });
                                                                                  mapOfUniqueIdVsSobject.put(pmb, uniqueKey);
                                                                                  setOfUltimateAccIds.add(pmb.Core_MDF_Ultimate_Account_Id__c);
                                                                                  setOfrole.add(currentQuery.mapOfProgramToBudgetTypeToQueue.get(pmb.Core_MDF_Program_Nm__c).get(pmb.Core_MDF_Budget_Type__c));
                                                                                  setOfPrgmId.add(pmb.Core_MDF_Program__c);
                                                                              } 
                                                                              else {
                                                                                  setOfQueueApiname.add(currentQuery.mapOfProgramToBudgetTypeToQueue.get(pmb.Core_MDF_Program_Nm__c).get(pmb.Core_MDF_Budget_Type__c));
                                                                                  mapOfUniqueIdVsSobject.put(pmb, currentQuery.mapOfProgramToBudgetTypeToQueue.get(pmb.Core_MDF_Program_Nm__c).get(pmb.Core_MDF_Budget_Type__c));
                                                                              }
                                                                          }
                                                                 
                                                                 // Case 3: Geo-based
                                                                 else if (!currentQuery.mapOfProgramToGeoBasedToRole.isEmpty() && currentQuery.mapOfProgramToGeoBasedToRole.containsKey(pmb.Core_MDF_Program_Nm__c)) {
                                                                     String geo = pmb.Core_MDF_Budget_Partner__r.Core_Geo__c;
                                                                     if (currentQuery.mapOfProgramToGeoBasedToRole.get(pmb.Core_MDF_Program_Nm__c).containsKey(geo)) {
                                                                         setOfQueueApiname.add(currentQuery.mapOfProgramToGeoBasedToRole.get(pmb.Core_MDF_Program_Nm__c).get(geo));
                                                                         mapOfUniqueIdVsSobject.put(pmb, currentQuery.mapOfProgramToGeoBasedToRole.get(pmb.Core_MDF_Program_Nm__c).get(geo));
                                                                     }
                                                                     else if (geo == Core_MDF_CCP_ConstantClass.ASMO_Region) { 
                                                                         setOfQueueApiname.add(currentQuery.mapOfProgramToGeoBasedToRole.get(pmb.Core_MDF_Program_Nm__c).get(geo + '-' + pmb.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c));
                                                                         mapOfUniqueIdVsSobject.put(pmb, currentQuery.mapOfProgramToGeoBasedToRole.get(pmb.Core_MDF_Program_Nm__c).get(geo + '-' + pmb.Core_MDF_Budget_Partner__r.Core_Sub_Geo__c));
                                                                     }
                                                                 }
                                                             }
                                                         }
                                                         
                                                         if(!setOfUltimateAccIds.isEmpty()){
                                                             for (Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Id, Core_MDF_Account_id__c, Core_MDF_Program_nm__c, Core_MDF_Role_nm__c,Core_MDF_Region_cd__c,Core_MDF_Budget_Type_nm__c,
                                                                                                                     Core_MDF_Active_Ind__c, Core_MDF_Channel_Program_id__c,Core_MDF_All_Accounts_cd__c,Core_MDF_Activity_Classification_nm__c,Core_MDF_All_Budget_Type_Access_Ind__c
                                                                                                                     FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                                                                     WHERE (Core_MDF_Account_id__c IN :setOfUltimateAccIds OR Core_MDF_All_Accounts_cd__c='Yes')
                                                                                                                     AND Core_MDF_Channel_Program_id__c IN :setOfPrgmId
                                                                                                                     AND Core_MDF_Role_nm__c IN :setOfrole
                                                                                                                     AND Core_MDF_Active_Ind__c = true]) {	
                                                                                                                         // Store all the program in the set
                                                                                                                         if (iupgm.Core_MDF_Channel_Program_id__c != null && iupgm.Core_MDF_Role_nm__c != null) {
                                                                                                                             String programNm = iupgm.Core_MDF_Program_nm__c;
                                                                                                                             Boolean allAccFlag = (iupgm.Core_MDF_All_Accounts_cd__c == 'Yes');
                                                                                                                             String uniqueKey = '';
                                                                                                                             
                                                                                                                             // Intel Partner Alliance (special case: must have Account Plan)
                                                                                                                             if (programNm == Core_MDF_CCP_ConstantClass.IPA_PROGRAM) {
                                                                                                                                 List<String> budgetList = (iupgm.Core_MDF_All_Budget_Type_Access_Ind__c == true)
                                                                                                                                     ? new List<String>{Core_MDF_CCP_ConstantClass.IPA_BUDGET_TYPE}
                                                                                                                                 : (String.isNotBlank(iupgm.Core_MDF_Budget_Type_nm__c)
                                                                                                                                    ? iupgm.Core_MDF_Budget_Type_nm__c.split(';')
                                                                                                                                    : new List<String>());
                                                                                                                                 
                                                                                                                                 if (budgetList.contains(Core_MDF_CCP_ConstantClass.IPA_BUDGET_TYPE)) {
                                                                                                                                     uniqueKey = allAccFlag
                                                                                                                                         ? iupgm.Core_MDF_Channel_Program_id__c + '|' + iupgm.Core_MDF_Role_nm__c
                                                                                                                                         : iupgm.Core_MDF_Account_id__c + '|' + iupgm.Core_MDF_Channel_Program_id__c + '|' + iupgm.Core_MDF_Role_nm__c;
                                                                                                                                 }
                                                                                                                             } 
                                                                                                                             // All other supported programs
                                                                                                                             else if (Core_MDF_CCP_ConstantClass.Prog_For_CCF_DCF_EEF_COGTM_FOR_IUPGM.contains(programNm)) {
                                                                                                                                 uniqueKey = allAccFlag
                                                                                                                                     ? iupgm.Core_MDF_Channel_Program_id__c + '|' + iupgm.Core_MDF_Role_nm__c
                                                                                                                                     : iupgm.Core_MDF_Account_id__c + '|' + iupgm.Core_MDF_Channel_Program_id__c + '|' + iupgm.Core_MDF_Role_nm__c;
                                                                                                                             }
                                                                                                                             
                                                                                                                             // Add to the set if valid
                                                                                                                             if (String.isNotBlank(uniqueKey)) {
                                                                                                                                 listOfIupgmUniqueKey.add(uniqueKey);
                                                                                                                             }
                                                                                                                         }
                                                                                                                         
                                                                                                                     }
                                                             
                                                             
                                                         }
                                                         
                                                         
                                                         
                                                     }
    /***************************************************************************************************
Method Name:  processCampaign
Version     : 1.0 
Created Date: 01/09/2025
Function    : 
Input Parameters: The list of SObjects (processCampaign) in the current batch scope.
Output Parameters: Populates maps (mapOfUniqueIdVsSobject, mapOfSobjectVAllAccsuniqueKey) with calculated keys.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rishabh                   01/09/2025             Created
* Rishabh                    01/09/2025             Modified
****************************************************************************************************/
    public static void processCampaign(List<SObject> scope,Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery currentQuery,Map<SObject, String> mapOfUniqueIdVsSobject,
                                       Map<SObject, String> mapOfSobjectVAllAccsuniqueKey,Set<Id> setOfUltimateAccIds,Set<String> setOfQueueApiname,Set<String> listOfIupgmUniqueKey,Set<Id> setOfAccIds){
                                           set<Id> setOfPrgmId = new set<Id>();
                                           set<string> setOfrole = new set<string>();
                                           
                                           for (SObject sobj : scope) {
                                               
                                               Campaign cmp = (Campaign) sobj;
                                               if(cmp.Core_MDF_Ultimate_Account_txt__c!=null && cmp.Core_MDF_Opal_Budget_Type_Txt__c!=null && cmp.Core_MDF_Channel_Program__c!=null){
                                                   if (!currentQuery.mapOfProgramToApprovalStageToRolesList.isEmpty() && currentQuery.mapOfProgramToApprovalStageToRolesList.containsKey(cmp.Core_MDF_Program__c) 
                                                       && cmp.Core_MDF_Account__r.Core_Geo__c!=null && currentQuery.mapOfProgramToApprovalStageToRolesList.get(cmp.Core_MDF_Program__c).containsKey(cmp.Core_MDF_Approval_Stage_nm__c)) { // add contains check for approval stage
                                                           List<String> roleList = currentQuery.mapOfProgramToApprovalStageToRolesList.get(cmp.Core_MDF_Program__c).get(cmp.Core_MDF_Approval_Stage_nm__c); 
                                                           String roleName = (roleList != null && !roleList.isEmpty()) ? roleList[0] : null;
                                                           
                                                           String activityClassification;
                                                           String uniqueKey;
                                                           String uniqueKeyForAllAcc;
                                                           
                                                           if(Core_MDF_CCP_ConstantClass.stageToClassificationMap.containsKey(cmp.Core_MDF_Approval_Stage_nm__c)){
                                                               activityClassification = Core_MDF_CCP_ConstantClass.stageToClassificationMap.get(cmp.Core_MDF_Approval_Stage_nm__c);
                                                           }
                                                           
                                                           if(cmp.Core_MDF_Approval_Stage_nm__c == Core_MDF_CCP_ConstantClass.PFR_PRICE_REVIEWER){
                                                               uniqueKey = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                   cmp.Core_MDF_Ultimate_Account_txt__c,
                                                                       cmp.Core_MDF_Channel_Program__c,
                                                                       roleName,
                                                                       cmp.Core_MDF_Account__r.Core_Geo__c
                                                                       });
                                                               uniqueKeyForAllAcc = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                   cmp.Core_MDF_Channel_Program__c,
                                                                       roleName,
                                                                       cmp.Core_MDF_Account__r.Core_Geo__c
                                                                       });
                                                           }
                                                           else{
                                                               // Unique key for campaign record
                                                               uniqueKey = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                   cmp.Core_MDF_Ultimate_Account_txt__c,
                                                                       cmp.Core_MDF_Channel_Program__c,
                                                                       roleName,
                                                                       cmp.Core_MDF_Opal_Budget_Type_Txt__c,
                                                                       cmp.Core_MDF_Account__r.Core_Geo__c, // check host region for cogtm
                                                                       activityClassification
                                                                       });
                                                               // Unique Key for "All Accounts"
                                                               uniqueKeyForAllAcc = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                   cmp.Core_MDF_Channel_Program__c,
                                                                       roleName,
                                                                       cmp.Core_MDF_Opal_Budget_Type_Txt__c,
                                                                       cmp.Core_MDF_Account__r.Core_Geo__c,
                                                                       activityClassification
                                                                       });
                                                           }
                                                           mapOfUniqueIdVsSobject.put(cmp, uniqueKey);
                                                           mapOfSobjectVAllAccsuniqueKey.put(cmp, uniqueKeyForAllAcc);
                                                           setOfPrgmId.add(cmp.Core_MDF_Channel_Program__c);
                                                           setOfrole.add(roleName);
                                                           setOfUltimateAccIds.add(cmp.Core_MDF_Ultimate_Account_txt__c);
                                                       }
                                                   else if(!currentQuery.mapOfProgramToBudgetTypeToQueue.isEmpty() && currentQuery.mapOfProgramToBudgetTypeToQueue.containsKey(cmp.Core_MDF_Program__c)
                                                           && currentQuery.mapOfProgramToBudgetTypeToQueue.get(cmp.Core_MDF_Program__c).containsKey(cmp.Core_MDF_Approval_Stage_nm__c)){
                                                               
                                                               String roleValue = currentQuery.mapOfProgramToBudgetTypeToQueue.get(cmp.Core_MDF_Program__c).get(cmp.Core_MDF_Approval_Stage_nm__c);
                                                               String roleName = roleValue != null ? roleValue : null;
                                                               // Unique key for campaign record
                                                               String uniqueKey = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                   cmp.Core_MDF_Ultimate_Account_txt__c,
                                                                       cmp.Core_MDF_Channel_Program__c,
                                                                       roleName,
                                                                       cmp.Core_MDF_Opal_Budget_Type_Txt__c
                                                                       });
                                                               
                                                               // Unique Key for "All Accounts"
                                                               String uniqueKeyForAllAcc = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                   cmp.Core_MDF_Channel_Program__c,
                                                                       roleName,
                                                                       cmp.Core_MDF_Opal_Budget_Type_Txt__c
                                                                       });
                                                               mapOfUniqueIdVsSobject.put(cmp, uniqueKey);
                                                               mapOfSobjectVAllAccsuniqueKey.put(cmp, uniqueKeyForAllAcc);
                                                               setOfPrgmId.add(cmp.Core_MDF_Channel_Program__c);
                                                               setOfrole.add(roleName);
                                                               setOfUltimateAccIds.add(cmp.Core_MDF_Ultimate_Account_txt__c);
                                                               
                                                           }
                                                   else if (!currentQuery.mapOfPnumApprovalStageToRole.isEmpty() && currentQuery.mapOfPnumApprovalStageToRole.containsKey(cmp.Core_MDF_Approval_Stage_nm__c)) {
                                                       mapOfUniqueIdVsSobject.put(cmp, currentQuery.mapOfPnumApprovalStageToRole.get(cmp.Core_MDF_Approval_Stage_nm__c));
                                                       setOfAccIds.add(cmp.Core_MDF_Account__c); // Node Account
                                                   }
                                               }
                                           }
                                           if(!setOfUltimateAccIds.isEmpty()){
                                               for (Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [
                                                   SELECT Id, Core_MDF_Account_id__c, Core_MDF_Program_nm__c, Core_MDF_Role_nm__c,
                                                   Core_MDF_Region_cd__c, Core_MDF_Budget_Type_nm__c, Core_MDF_Active_Ind__c,
                                                   Core_MDF_Channel_Program_id__c, Core_MDF_All_Accounts_cd__c, 
                                                   Core_MDF_Activity_Classification_nm__c, Core_MDF_All_Budget_Type_Access_Ind__c
                                                   FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                   WHERE (Core_MDF_Account_id__c IN :setOfUltimateAccIds OR Core_MDF_All_Accounts_cd__c = 'Yes')
                                                   AND Core_MDF_Channel_Program_id__c IN :setOfPrgmId
                                                   AND Core_MDF_Role_nm__c IN :setOfrole
                                                   AND Core_MDF_Active_Ind__c = true
                                               ]) {
                                                   
                                                   String baseKey = (iupgm.Core_MDF_All_Accounts_cd__c == 'Yes') 
                                                       ? iupgm.Core_MDF_Channel_Program_id__c + '|' + iupgm.Core_MDF_Role_nm__c
                                                       : iupgm.Core_MDF_Account_id__c + '|' + iupgm.Core_MDF_Channel_Program_id__c + '|' + iupgm.Core_MDF_Role_nm__c;
                                                   
                                                   List<String> geoList= new List<String>();
                                                   List<String> budgetList = (iupgm.Core_MDF_All_Budget_Type_Access_Ind__c == true)
                                                       ? (iupgm.Core_MDF_Program_nm__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM
                                                          ? new List<String>{ Core_MDF_CCP_ConstantClass.PR_MDF_BUDGET_TYPE, Core_MDF_CCP_ConstantClass.IPA_PROPOSAL_MDF_BUDGET_TYPE }
                                                          : (iupgm.Core_MDF_Program_nm__c == Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM
                                                             ? new List<String>{Core_MDF_CCP_ConstantClass.CO_GTM_BUDGET_TYPE}
                                                             : (iupgm.Core_MDF_Budget_Type_nm__c != null
                                                                ? iupgm.Core_MDF_Budget_Type_nm__c.split(';')
                                                                : new List<String>()
                                                               )
                                                            )
                                                         )
                                                       : (iupgm.Core_MDF_Budget_Type_nm__c != null
                                                          ? iupgm.Core_MDF_Budget_Type_nm__c.split(';')
                                                          : new List<String>()
                                                         );
                                                             
                                                             
                                                             // Geo values
                                                             if(iupgm.Core_MDF_Program_nm__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM){
                                                                 geoList = (iupgm.Core_MDF_Region_cd__c != null && iupgm.Core_MDF_Region_cd__c.contains(Core_MDF_CCP_ConstantClass.GEO_WW))
                                                                     ? Core_MDF_CCP_ConstantClass.ALL_REGION
                                                                     : (iupgm.Core_MDF_Region_cd__c != null ? iupgm.Core_MDF_Region_cd__c.split(';') : new List<String>());
                                                                         }
                                                   // Classification values
                                                   
                                                   List<String> classificationList = 
                                                       (iupgm.Core_MDF_Role_nm__c == Core_MDF_CCP_ConstantClass.L2_Iupgm_Role && iupgm.Core_MDF_Activity_Classification_nm__c != null)
                                                       ? iupgm.Core_MDF_Activity_Classification_nm__c.split(';')
                                                       : new List<String>();
                                                   
                                                   // Build combos
                                                   List<List<String>> inputFields = new List<List<String>>{ budgetList, geoList, classificationList };
                                                       Set<String> combos = Core_MDF_MultiObjectBatchHandler.getRoleRegionCombinations(inputFields);
                                                   for (String cs : combos) {
                                                       if (String.isNotBlank(cs)) {
                                                           listOfIupgmUniqueKey.add(baseKey + '|' + cs);
                                                       }
                                                   }
                                               }
                                           }
                                           
                                       }
    /***************************************************************************************************
Method Name:  processPartnerFundRequest
Version     : 1.0 
Created Date: 01/09/2025
Function    : 
Input Parameters: The list of SObjects (processPartnerFundRequest) in the current batch scope.
Output Parameters: Populates maps (mapOfUniqueIdVsSobject, mapOfSobjectVAllAccsuniqueKey) with calculated keys.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rishabh                   01/09/2025             Created
* Rishabh                    01/09/2025             Modified
****************************************************************************************************/
    public static void processPartnerFundRequest(List<SObject> scope,Core_MDF_MultiObjectBatchHandler.Core_MDF_ObjectQuery currentQuery,Map<SObject, String> mapOfUniqueIdVsSobject,
                                                 Map<SObject, String> mapOfSobjectVAllAccsuniqueKey,Set<Id> setOfUltimateAccIds,Set<String> setOfQueueApiname,Set<String> listOfIupgmUniqueKey,Set<Id> setOfAccIds,set<Id> setOfPrdIdForManger,Set<String> setOfPublicGrpNm){
                                                     set<string> setOfPrgmId = new set<string>();
                                                     set<string> setOfrole = new set<string>();
                                                     
                                                     for (SObject sobj : scope) {
                                                         PartnerFundRequest pfr = (PartnerFundRequest) sobj;
                                                         
                                                         if(pfr.Core_MDF_Approval_Stage__c!=NULL && pfr.Campaign.Core_MDF_Channel_Program__c!=NULL && pfr.Core_MDF_Budget_Type_nm__c!=Null){
                                                             String approvalStageKey = pfr.Core_MDF_Approval_Stage__c + ' - ' + pfr.Core_MDF_Budget_Type_nm__c;
                                                             if (!currentQuery.mapOfProgramToApprovalStageToRolesList.isEmpty() && currentQuery.mapOfProgramToApprovalStageToRolesList.containsKey(pfr.Core_MDF_Program__c)
                                                                 && currentQuery.mapOfProgramToApprovalStageToRolesList.get(pfr.Core_MDF_Program__c).containsKey(approvalStageKey)) {
                                                                     
                                                                     List<String> roleList = currentQuery.mapOfProgramToApprovalStageToRolesList.get(pfr.Core_MDF_Program__c).get(approvalStageKey);
                                                                     String roleName = (roleList != null && !roleList.isEmpty()) ? roleList[0] : null;
                                                                     String activityClassification;
                                                                     
                                                                     if(Core_MDF_CCP_ConstantClass.stageToClassificationMap.containsKey(pfr.Core_MDF_Approval_Stage__c)){
                                                                         activityClassification = Core_MDF_CCP_ConstantClass.stageToClassificationMap.get(pfr.Core_MDF_Approval_Stage__c);
                                                                     }
                                                                     
                                                                     String uniqueKey;
                                                                     String uniqueKeyForAllAcc;
                                                                     if(pfr.Core_MDF_Approval_Stage__c== Core_MDF_CCP_ConstantClass.PFR_PRICE_REVIEWER){
                                                                         uniqueKey = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                             pfr.Core_MDF_Ultimate_Account_Id__c,
                                                                                 pfr.ChannelPartner.Core_MDF_Channel_Program__c,
                                                                                 roleName,
                                                                                 pfr.Core_MDF_Region_nm__c
                                                                                 });
                                                                         uniqueKeyForAllAcc = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                             pfr.ChannelPartner.Core_MDF_Channel_Program__c,
                                                                                 roleName,
                                                                                 pfr.Core_MDF_Region_nm__c
                                                                                 });
                                                                     }else{
                                                                         // Unique key for campaign record
                                                                         uniqueKey = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                             pfr.Core_MDF_Ultimate_Account_Id__c,
                                                                                 pfr.Campaign.Core_MDF_Channel_Program__c,
                                                                                 roleName,
                                                                                 pfr.Core_MDF_Budget_Type_nm__c,
                                                                                 pfr.Core_MDF_Region_nm__c,
                                                                                 activityClassification                      // In case of EEF we ignore classification
                                                                                 });
                                                                         // Unique Key for "All Accounts Yes"
                                                                         uniqueKeyForAllAcc = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                             pfr.Campaign.Core_MDF_Channel_Program__c,
                                                                                 roleName,
                                                                                 pfr.Core_MDF_Budget_Type_nm__c,
                                                                                 pfr.Core_MDF_Region_nm__c,
                                                                                 activityClassification
                                                                                 });
                                                                     }
                                                                     
                                                                     mapOfSobjectVAllAccsuniqueKey.put(pfr, uniqueKeyForAllAcc);
                                                                     mapOfUniqueIdVsSobject.put(pfr, uniqueKey);
                                                                     setOfUltimateAccIds.add(pfr.Core_MDF_Ultimate_Account_Id__c);
                                                                     setOfrole.add(roleName);
                                                                     setOfPrgmId.add(pfr.Campaign.Core_MDF_Channel_Program__c);
                                                                 }
                                                             else if(!currentQuery.mapOfProgramToBudgetTypeToQueue.isEmpty() && currentQuery.mapOfProgramToBudgetTypeToQueue.containsKey(pfr.Core_MDF_Program__c) &&
                                                                     currentQuery.mapOfProgramToBudgetTypeToQueue.get(pfr.Core_MDF_Program__c) != null && currentQuery.mapOfProgramToBudgetTypeToQueue.get(pfr.Core_MDF_Program__c).containsKey(approvalStageKey)){
                                                                         
                                                                         String roleValue = currentQuery.mapOfProgramToBudgetTypeToQueue.get(pfr.Core_MDF_Program__c).get(approvalStageKey);
                                                                         String roleName = (roleValue != null) ? roleValue : null;
                                                                         String uniqueKey;
                                                                         String uniqueKeyForAllAcc;
                                                                         
                                                                         if(pfr.Core_MDF_Approval_Stage__c== Core_MDF_CCP_ConstantClass.PFR_PRICE_REVIEWER){
                                                                             
                                                                             uniqueKey = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                                 pfr.Core_MDF_Ultimate_Account_Id__c,
                                                                                     pfr.ChannelPartner.Core_MDF_Channel_Program__c,
                                                                                     roleName,
                                                                                     pfr.Core_MDF_Region_nm__c
                                                                                     });
                                                                             
                                                                             uniqueKeyForAllAcc = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                                 pfr.ChannelPartner.Core_MDF_Channel_Program__c,
                                                                                     roleName,
                                                                                     pfr.Core_MDF_Region_nm__c
                                                                                     });
                                                                         }else{
                                                                             
                                                                             uniqueKey = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                                 pfr.Core_MDF_Ultimate_Account_Id__c,
                                                                                     pfr.Campaign.Core_MDF_Channel_Program__c,
                                                                                     roleName,
                                                                                     pfr.Core_MDF_Region_nm__c
                                                                                     });
                                                                         }
                                                                         
                                                                         mapOfUniqueIdVsSobject.put(pfr, uniqueKey);
                                                                         mapOfSobjectVAllAccsuniqueKey.put(pfr, uniqueKeyForAllAcc);
                                                                         setOfUltimateAccIds.add(pfr.Core_MDF_Ultimate_Account_Id__c);
                                                                         setOfrole.add(roleName);
                                                                         setOfPrgmId.add(pfr.Campaign.Core_MDF_Channel_Program__c);
                                                                         
                                                                     }
                                                             else if(!currentQuery.mapOfProgramToGeoBasedToRole.isEmpty() && currentQuery.mapOfProgramToGeoBasedToRole.containsKey(pfr.Core_MDF_Program__c)
                                                                     && currentQuery.mapOfProgramToGeoBasedToRole.get(pfr.Core_MDF_Program__c).containsKey(approvalStageKey)){
                                                                         
                                                                         String roleValue = currentQuery.mapOfProgramToGeoBasedToRole.get(pfr.Core_MDF_Program__c).get(approvalStageKey);
                                                                         String roleName = (roleValue != null) ? roleValue : null;
                                                                         String uniqueKey;
                                                                         String RegionNm;
                                                                         String uniqueKeyForAllAcc;
                                                                         RegionNm = (pfr.Core_MDF_Region_nm__c == Core_MDF_CCP_ConstantClass.ASMO_Region && String.isNotBlank(pfr.Core_MDF_Sub_Region_nm__c))
                                                                             ? pfr.Core_MDF_Region_nm__c + ' - ' + pfr.Core_MDF_Sub_Region_nm__c
                                                                             : pfr.Core_MDF_Region_nm__c;
                                                                         
                                                                         
                                                                         if(pfr.Core_MDF_Approver_1__c!=Null && (Core_MDF_CCP_ConstantClass.FIRST_SECOND_LEVEL_MGR.Contains(pfr.Core_MDF_Approval_Stage__c))){
                                                                             setOfPrdIdForManger.add(pfr.Id);
                                                                             mapOfUniqueIdVsSobject.put(pfr, pfr.Core_MDF_Approval_Stage__c);
                                                                         }else{
                                                                             if(pfr.Core_MDF_Approval_Stage__c== Core_MDF_CCP_ConstantClass.PFR_PRICE_REVIEWER){
                                                                                 uniqueKey = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                                     pfr.Core_MDF_Ultimate_Account_Id__c,
                                                                                         pfr.ChannelPartner.Core_MDF_Channel_Program__c,
                                                                                         roleName,
                                                                                         RegionNm
                                                                                         });
                                                                                 uniqueKeyForAllAcc = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                                     pfr.ChannelPartner.Core_MDF_Channel_Program__c,
                                                                                         roleName,
                                                                                         RegionNm
                                                                                         });
                                                                             }else{
                                                                                 uniqueKey = Core_MDF_MultiObjectBatchHandler.buildUniqueKey(new List<String>{
                                                                                     pfr.Campaign.Core_MDF_Channel_Program__c,
                                                                                         roleName,
                                                                                         RegionNm
                                                                                         });
                                                                             }
                                                                             mapOfUniqueIdVsSobject.put(pfr, uniqueKey);
                                                                             setOfUltimateAccIds.add(pfr.Core_MDF_Ultimate_Account_Id__c);
                                                                             mapOfSobjectVAllAccsuniqueKey.put(pfr, uniqueKeyForAllAcc);
                                                                             setOfrole.add(roleName);
                                                                             setOfPrgmId.add(pfr.Campaign.Core_MDF_Channel_Program__c);
                                                                             
                                                                         }
                                                                     }
                                                             else if (!currentQuery.mapOfPnumApprovalStageToRole.isEmpty() && currentQuery.mapOfPnumApprovalStageToRole.containsKey(pfr.Core_MDF_Approval_Stage__c)) {
                                                                 setOfAccIds.add(pfr.ChannelPartnerId);
                                                                 mapOfUniqueIdVsSobject.put(pfr, currentQuery.mapOfPnumApprovalStageToRole.get(pfr.Core_MDF_Approval_Stage__c));
                                                             }
                                                             else if (!currentQuery.mapOfPrgmTOBudgetTypeTOPublicGrp.isEmpty() && currentQuery.mapOfPrgmTOBudgetTypeTOPublicGrp.containsKey(pfr.Core_MDF_Program__c) 
                                                                      && currentQuery.mapOfPrgmTOBudgetTypeTOPublicGrp.get(pfr.Core_MDF_Program__c).containsKey(approvalStageKey)) {
                                                                          
                                                                          String pubGrpValue = currentQuery.mapOfPrgmTOBudgetTypeTOPublicGrp.get(pfr.Core_MDF_Program__c).get(approvalStageKey);
                                                                          String pubGrpName = pubGrpValue != null ? pubGrpValue : null;
                                                                          setOfPublicGrpNm.add(pubGrpName);
                                                                          mapOfUniqueIdVsSobject.put(pfr, pubGrpName);
                                                                      }
                                                         }
                                                         
                                                     }
                                                     if(!setOfUltimateAccIds.isEmpty()){
                                                         for (Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [
                                                             SELECT Id, Core_MDF_Account_id__c, Core_MDF_Program_nm__c, Core_MDF_Role_nm__c,
                                                             Core_MDF_Region_cd__c, Core_MDF_Budget_Type_nm__c, Core_MDF_Active_Ind__c,
                                                             Core_MDF_Channel_Program_id__c, Core_MDF_All_Accounts_cd__c, 
                                                             Core_MDF_Activity_Classification_nm__c, Core_MDF_All_Budget_Type_Access_Ind__c
                                                             FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                             WHERE (Core_MDF_Account_id__c IN :setOfUltimateAccIds OR Core_MDF_All_Accounts_cd__c = 'Yes')
                                                             AND Core_MDF_Channel_Program_id__c IN :setOfPrgmId
                                                             AND Core_MDF_Role_nm__c IN :setOfrole
                                                             AND Core_MDF_Active_Ind__c = true
                                                         ]) {
                                                             List<String> budgetList = new List<String>();
                                                             String baseKey = (iupgm.Core_MDF_All_Accounts_cd__c == 'Yes') 
                                                                 ? iupgm.Core_MDF_Channel_Program_id__c + '|' + iupgm.Core_MDF_Role_nm__c
                                                                 : iupgm.Core_MDF_Account_id__c + '|' + iupgm.Core_MDF_Channel_Program_id__c + '|' + iupgm.Core_MDF_Role_nm__c;
                                                             
                                                             // Geo values
                                                             List<String> geoList;
                                                             if (iupgm.Core_MDF_Region_cd__c != null && iupgm.Core_MDF_Region_cd__c.contains(Core_MDF_CCP_ConstantClass.GEO_WW)) {
                                                                 geoList = (iupgm.Core_MDF_Program_nm__c != Core_MDF_CCP_ConstantClass.RMF_PROGRAM)
                                                                     ? Core_MDF_CCP_ConstantClass.ALL_REGION
                                                                     :	Core_MDF_CCP_ConstantClass.ALL_REGION_FOR_RMF;
                                                             } else {
                                                                 geoList = (iupgm.Core_MDF_Region_cd__c != null) 
                                                                     ? iupgm.Core_MDF_Region_cd__c.split(';') 
                                                                     : new List<String>();
                                                             }
                                                             
                                                             
                                                             // Classification values
                                                             List<String> classificationList = 
                                                                 (iupgm.Core_MDF_Role_nm__c == Core_MDF_CCP_ConstantClass.L2_Iupgm_Role && iupgm.Core_MDF_Activity_Classification_nm__c != null)
                                                                 ? iupgm.Core_MDF_Activity_Classification_nm__c.split(';')
                                                                 : new List<String>();
                                                             
                                                             // Budget values
                                                             if(iupgm.Core_MDF_Role_nm__c != Core_MDF_CCP_ConstantClass.PFR_PRICE_REVIEWER){
                                                                 budgetList =
                                                                     (iupgm.Core_MDF_All_Budget_Type_Access_Ind__c == true && iupgm.Core_MDF_Program_nm__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM)
                                                                     ? new List<String>{ Core_MDF_CCP_ConstantClass.IPA_BUDGET_TYPE }
                                                                 : (iupgm.Core_MDF_All_Budget_Type_Access_Ind__c == true && iupgm.Core_MDF_Program_nm__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM)
                                                                     ? new List<String>{ Core_MDF_CCP_ConstantClass.EEF_BUDGET_TYPE }
                                                                 : (iupgm.Core_MDF_Budget_Type_nm__c != null
                                                                    ? iupgm.Core_MDF_Budget_Type_nm__c.split(';')
                                                                    : new List<String>());
                                                             }
                                                             
                                                             // Build combos
                                                             List<List<String>> inputFields = new List<List<String>>{ budgetList, geoList, classificationList };
                                                                 Set<String> combos = Core_MDF_MultiObjectBatchHandler.getRoleRegionCombinations(inputFields);
                                                             
                                                             for (String cs : combos) {
                                                                 if (String.isNotBlank(cs)) {
                                                                     listOfIupgmUniqueKey.add(baseKey + '|' + cs);
                                                                 }
                                                             }
                                                         }
                                                     }
                                                     
                                                 }
}