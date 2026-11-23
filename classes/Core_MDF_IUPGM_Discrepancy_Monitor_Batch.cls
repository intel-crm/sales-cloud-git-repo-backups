/***************************************************************************************************************************************************************** 
Class Name:         Core_MDF_IUPGM_Discrepancy_Monitor_Batch
@parameters:        N/A
Description:        Batch to check all IUPGM active records having correct PGMs, Groups and Group Members. If any discrepancy found generate a CSV with those data.  
Added By:           Ayush   08-03-2023
Modified By:        Date:           Changes:
Ayush               04-12-2024      Adding all the discrepancy data to csvDataList and using same list in finish method to print data in CSV file.
*****************************************************************************************************************************************************************/
global with sharing class Core_MDF_IUPGM_Discrepancy_Monitor_Batch implements Database.Batchable<sObject>,Database.Stateful,Core_MDF_BatchSchedulerInterface {
    
    Public String csvHeader = 'Category, IUPGM Id, Account Id, Account Name, Program Name, Role, User Id, Region, All Budget Type Access, Budget Type, PGM Id, Group Id, Group Name';
    Public Id recordTrackingId;
    Public Integer count = 0;
    Public List<String> csvDataList = new List<String>{csvHeader};
        Public List<ContentVersion> contentVersionListToBeInserted = new List<ContentVersion>();
    Public final Integer MAX_RECORDS = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IUPGMDataMonitorMaxFileSize'));
    String fieldFilterName;
    String fieldFilterValue;
    Set<String> keySet = new Set<String>();
    global Core_MDF_IUPGM_Discrepancy_Monitor_Batch(){}
    
    public static object generateInstance(String jsonText, String classSignature){
        object des_Obj;
        map<String,object> parmValueMap = (Map<String, Object>)JSON.deserializeUntyped(jsonText);
        if(classSignature == 'Core_MDF_IUPGM_Discrepancy_Monitor_Batch(String fieldFilterName, String fieldFilterValue)'){
            String filterName = String.valueOf(parmValueMap.get('fieldFilterName'));
            string filterValue = String.valueOf(parmValueMap.get('fieldFilterValue'));
            des_Obj = new Core_MDF_IUPGM_Discrepancy_Monitor_Batch(filterName,filterValue);
        }
        return des_Obj;
    }
    
    global Core_MDF_IUPGM_Discrepancy_Monitor_Batch(String fieldFilterName, String fieldFilterValue){
        this.fieldFilterName = fieldFilterName;
        this.fieldFilterValue = fieldFilterValue;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Core_MDF_Account_id__c, Core_MDF_Account_id__r.Name, Core_MDF_Program_nm__c, Core_MDF_Channel_Program_id__c, '+
            'Core_MDF_Role_nm__c, Core_MDF_Region_Sub_Region_nm__c, Core_MDF_Region_cd__c, Core_MDF_Budget_Type_nm__c, '+
            'Core_MDF_All_Budget_Type_Access_Ind__c, Core_MDF_GeoSubGeo_Budget_Type_nm__c, Core_MDF_User_id__c '+
            'FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c '+ 
            'WHERE Core_MDF_Account_id__r.RecordType.DeveloperName != \'Core_MDF_Co_Marketing\' '+
            'AND Core_MDF_All_Accounts_cd__c = \'No\' '+
            'AND Core_MDF_Active_Ind__c = TRUE '+
            'AND Core_MDF_is_User_Active_ind__c = TRUE';
        
        if(fieldFilterName != null && fieldFilterName != '' && fieldFilterValue != null && fieldFilterValue != ''){
            query += ' AND '+ fieldFilterName + '='+ fieldFilterValue;
        }
        
        query += ' ORDER BY LastModifiedDate';
        
       
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmObjList){
        try{
        if(csvDataList.size() <= MAX_RECORDS){ // To restrict records more than 50K (If already 50K data reached don't even go inside)
            Set<Id> accountIdSet = new Set<Id>();                               
            Set<Id> programIdSet = new Set<Id>();
            Set<String> regionSet = new Set<String>();
            Set<String> budgetTypeSet = new Set<String>();
            Map<String,Id> accProgGeoGrpIdSetMap = new Map<String,Id>();
            Map<String,Set<Id>> accProgGeoUserIdSetMap = new Map<String,Set<Id>>();
            // Highlight: Unused Local Variable - 14285
            // Map<Id,Set<Id>> groupIdToUserIdSetMap = new Map<Id,Set<Id>>();
            Set<String> groupIdUserIdSet = new Set<String>();
            Map<String,Map<Id,List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>>> iupgmKeyToUserIdToRecordMap = new Map<String,Map<Id,List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>>>(); //
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> missingPGMList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> missingGroupList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> missingGrpMemberList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            Map<String, List<contentWrapper>> missingCategoryToWrapperMap = new Map<String, List<contentWrapper>>();
            Map<String, Core_MDF_Partner_Group_Mapping__c> keyToPGMRecordMap = new Map<String, Core_MDF_Partner_Group_Mapping__c>();
            List<contentWrapper> contentWrapperLst = new List<contentWrapper>();
            
            // Highlight: Unused Local Variable - 14285
            // String accProgGeoBudTypeKey = '';
            Set<Id> userIdSet = new Set<Id>();
            Set<Id> groupIdSet = new Set<Id>();
            // Highlight: Unused Local Variable - 14285
            // Map<Id,Group> groupIdToGroupMap = new Map<Id,Group>();
            
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmObjList){
                Set<String> geoSubGeoSet =  new Set<String>();
                String accProgGeoKey = '';
                accountIdSet.add(iupgm.Core_MDF_Account_id__c);                               
                programIdSet.add(iupgm.Core_MDF_Channel_Program_id__c);
                
                if(iupgm.Core_MDF_Region_Sub_Region_nm__c != null){
                    List<String> geoList = iupgm.Core_MDF_Region_Sub_Region_nm__c.split(';');
                    geoSubGeoSet.addAll(new Set<String>(geoList));
                }
                
                if(iupgm.Core_MDF_Region_cd__c != null){
                    List<String> regionList = iupgm.Core_MDF_Region_cd__c.split(';'); 
                    regionSet.addAll(new Set<String>(regionList));
                }
                
                if(iupgm.Core_MDF_Budget_Type_nm__c != null){ // budget type exists
                    // Nested IF reduction: guard for blank/null to avoid deep nesting and unsafe splits - US - TWC702-14285
                    if (String.isBlank(iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c)) {
                        // no-op: behavior matches previous null-check (skip inner processing)
                        continue; //US - TWC702-14285
                    } 
                        for(String geoBudgetTypeStr : iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';')){
                            String geo = geoBudgetTypeStr.split('->')[0] ;                             
                            String budgetType = geoBudgetTypeStr.split('->')[1] ;
                            budgetTypeSet.add(budgetType);
                            accProgGeoKey = iupgm.Core_MDF_Account_id__c + ';' + iupgm.Core_MDF_Program_nm__c + ';' + geo + ';' + budgetType; // 001g0000024cdfQQZ;Intel Partner Alliance;APJ;ProposalI
                            
                            if(!accProgGeoUserIdSetMap.containsKey(accProgGeoKey)){         
                                accProgGeoUserIdSetMap.put(accProgGeoKey, new Set<Id>());                           
                            }
                            accProgGeoUserIdSetMap.get(accProgGeoKey).add(iupgm.Core_MDF_User_id__c); //{001g0000024cdfQQZ;Intel Partner Alliance;APJ;ProposalI:{UserId1, UserId2}}
                            
                            if(iupgmKeyToUserIdToRecordMap.containsKey(accProgGeoKey)){
                                if(iupgmKeyToUserIdToRecordMap.get(accProgGeoKey).containsKey(iupgm.Core_MDF_User_id__c)){
                                    iupgmKeyToUserIdToRecordMap.get(accProgGeoKey).get(iupgm.Core_MDF_User_id__c).add(iupgm);
                                }else{
                                    iupgmKeyToUserIdToRecordMap.get(accProgGeoKey).put(iupgm.Core_MDF_User_id__c,new list<Core_MDF_Int_Users_Partner_Geo_Mapping__c>{iupgm});
                                }
                            }
                            else{
                                Map<Id,List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>> userIdToIUPGMListMap = new Map<Id,List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>>();
                                userIdToIUPGMListMap.put(iupgm.Core_MDF_User_id__c,new list<Core_MDF_Int_Users_Partner_Geo_Mapping__c>{iupgm});
                                iupgmKeyToUserIdToRecordMap.put(accProgGeoKey, userIdToIUPGMListMap); // {001g0000024cdfQQZ;Intel Partner Alliance;APJ;ProposalI:{UserID:{IUPGM1, IUPGM2}}}
                            }
                        }
                    
                }
                else{ // without budget type keys
                    for(String geo : geoSubGeoSet){
                        accProgGeoKey = iupgm.Core_MDF_Account_id__c + ';' + iupgm.Core_MDF_Program_nm__c + ';' + geo;  // 001g0000024cdfQQZ;Intel Partner Alliance;APJ
                        if(!accProgGeoUserIdSetMap.containsKey(accProgGeoKey)){         
                            accProgGeoUserIdSetMap.put(accProgGeoKey, new Set<Id>());                           
                        }
                        accProgGeoUserIdSetMap.get(accProgGeoKey).add(iupgm.Core_MDF_User_id__c); //{001g0000024cdfQQZ;Intel Partner Alliance;APJ:{UserId1, UserId2}}
                        
                        if(iupgmKeyToUserIdToRecordMap.containsKey(accProgGeoKey)){
                            if(iupgmKeyToUserIdToRecordMap.get(accProgGeoKey).containsKey(iupgm.Core_MDF_User_id__c)){
                                iupgmKeyToUserIdToRecordMap.get(accProgGeoKey).get(iupgm.Core_MDF_User_id__c).add(iupgm);
                            }else{
                                iupgmKeyToUserIdToRecordMap.get(accProgGeoKey).put(iupgm.Core_MDF_User_id__c,new list<Core_MDF_Int_Users_Partner_Geo_Mapping__c>{iupgm});
                            }
                        }else{
                            Map<Id,List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>> userIdToIUPGMListMap = new Map<Id,List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>>();
                            userIdToIUPGMListMap.put(iupgm.Core_MDF_User_id__c,new list<Core_MDF_Int_Users_Partner_Geo_Mapping__c>{iupgm});
                            iupgmKeyToUserIdToRecordMap.put(accProgGeoKey, userIdToIUPGMListMap); // {001g0000024cdfQQZ;Intel Partner Alliance;APJ:{UserID:{IUPGM1, IUPGM2}}}
                        }
                    }
                }
                
                if(iupgm.Core_MDF_User_id__c != null){
                    userIdSet.add(iupgm.Core_MDF_User_id__c); // adding users to the set for Group Member Query
                }
            }
            
            if(!accountIdSet.isEmpty() && !programIdSet.isEmpty() && !regionSet.isEmpty()){
                
                for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Id, Core_MDF_Account__c, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Group_Name__c,                               
                                                             Core_MDF_Group_id__c, Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c, Core_MDF_BudgetType_nm__c, Core_MDF_Inactive_Ind__c                                
                                                             FROM Core_MDF_Partner_Group_Mapping__c
                                                             WHERE Core_MDF_Channel_Program__c IN : programIdSet
                                                             AND Core_MDF_Account__c IN: accountIdSet 
                                                             AND Core_MDF_Region_cd__c IN : regionSet
                                                             AND Core_MDF_Type_Of_Access__c = 'Internal'
                                                             AND Core_MDF_Inactive_Ind__c = FALSE]){
                                                                 // Highlight: Unused Local Variable - 14285
                                                                 // String accProgGeoBudTypePGMKey = '';
                                                                 String accProgGeoPGMKey = '';
                                                                 if(pgm.Core_MDF_BudgetType_nm__c != NULL){
                                                                     // Early-continue guard to reduce nesting and avoid empty-if - US - TWC702-14285
                                                                     if(!budgetTypeSet.contains(pgm.Core_MDF_BudgetType_nm__c)) {
                                                                         continue; //US - TWC702-14285
                                                                     }
                                                                     accProgGeoPGMKey = pgm.Core_MDF_Account__c + ';' +pgm.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c + ';' + pgm.Core_MDF_Region_cd__c +'-'+ pgm.Core_MDF_Sub_Region_cd__c + ';' + pgm.Core_MDF_BudgetType_nm__c;                               
                                                                     //if sub region is null, then -null has to be removed 
                                                                     if(accProgGeoPGMKey.contains('-null')){                               
                                                                         accProgGeoPGMKey = accProgGeoPGMKey.remove('-null');
                                                                     }
                                                                     if(pgm.Core_MDF_Group_id__c != null){
                                                                         accProgGeoGrpIdSetMap.put(accProgGeoPGMKey, pgm.Core_MDF_Group_id__c);// {001g0000024cdfQQZ;Intel Partner Alliance;APJ;ProposalI:{GroupId1}, 001g0000024cdfQQZ;Intel Partner Alliance;EMEA,ProposalI:{GroupId2}}
                                                                     }
                                                                     if(accProgGeoPGMKey != null && accProgGeoPGMKey != '' && pgm != null && !keyToPGMRecordMap.containsKey(accProgGeoPGMKey)){ 
                                                                         keyToPGMRecordMap.put(accProgGeoPGMKey, pgm);
                                                                     }  
                                                                 }
                                                                 else{          
                                                                     accProgGeoPGMKey = pgm.Core_MDF_Account__c + ';' + pgm.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c + ';' + pgm.Core_MDF_Region_cd__c +'-'+ pgm.Core_MDF_Sub_Region_cd__c;                             
                                                                     //if sub region is null, then -null has to be removed from the end                                                                      
                                                                     if(accProgGeoPGMKey.endsWith('-null')){                               
                                                                         accProgGeoPGMKey = accProgGeoPGMKey.removeEnd('-null');
                                                                     }
                                                                     
                                                                     if(pgm.Core_MDF_Group_id__c != null){
                                                                         accProgGeoGrpIdSetMap.put(accProgGeoPGMKey, pgm.Core_MDF_Group_id__c); // {001g0000024cdfQQZ;Intel Partner Alliance;APJ:{GroupId1}, 001g0000024cdfQQZ;Intel Partner Alliance;EMEA:{GroupId2}}
                                                                     }
                                                                     if(accProgGeoPGMKey != null && accProgGeoPGMKey != '' && pgm != null && !keyToPGMRecordMap.containsKey(accProgGeoPGMKey)){ 
                                                                         keyToPGMRecordMap.put(accProgGeoPGMKey, pgm);
                                                                     }
                                                                 }
                                                                 
                                                                 if(pgm.Core_MDF_Group_id__c != null){
                                                                     groupIdSet.add(pgm.Core_MDF_Group_id__c);
                                                                 }
                                                             }
            }
            
            if(!groupIdSet.isEmpty() && !userIdSet.isEmpty()){                                        
                for(GroupMember gm : [SELECT Id, GroupId, UserOrGroupId, Group.DeveloperName 
                                      FROM GroupMember 
                                      WHERE GroupId IN: groupIdSet 
                                      AND UserOrGroupId IN: userIdSet
                                      AND Group.type = 'Regular' 
                                      AND (Group.DeveloperName like 'Core_MDF%' or Group.DeveloperName like 'MDF%' )]){
                                      groupIdUserIdSet.add(gm.GroupId+ ';' +gm.UserOrGroupId);
                                      }
            }
            ////US - TWC702-14285
            for(String accProgGeoKey : accProgGeoUserIdSetMap.keySet()){
                // Simplified nested IF structure using guard clauses for the specific statement requested - //US - TWC702-14285
                if(!accProgGeoGrpIdSetMap.containsKey(accProgGeoKey)&& iupgmKeyToUserIdToRecordMap.containsKey(accProgGeoKey)
                 && iupgmKeyToUserIdToRecordMap.get(accProgGeoKey) != null){ //Sheet for Missing PGM 
                   // if(iupgmKeyToUserIdToRecordMap.containsKey(accProgGeoKey) && iupgmKeyToUserIdToRecordMap.get(accProgGeoKey) != null){
                        missingPGMList.addAll(iupgmKeyToUserIdToRecordMap.get(accProgGeoKey).values()[0]);
                    //}
                    continue; //US - TWC702-14285
                }
                
                // PGM Exists - now flattened to avoid the nested if statement
                Id groupId = accProgGeoGrpIdSetMap.get(accProgGeoKey);
                if(groupId != null){ // Group Id Exists - replaced the nested if with direct check
                    for(Id userId : accProgGeoUserIdSetMap.get(accProgGeoKey)){
                        String groupIdUserId = groupId + ';' + userId;
                        if(!groupIdUserIdSet.contains(groupIdUserId)&& iupgmKeyToUserIdToRecordMap.get(accProgGeoKey).containsKey(userId)){ // sheet for missing group member
                            //if(iupgmKeyToUserIdToRecordMap.get(accProgGeoKey).containsKey(userId)){
                                missingGrpMemberList.addAll(iupgmKeyToUserIdToRecordMap.get(accProgGeoKey).get(userId));
                                keySet.add(accProgGeoKey);
                           // }
                        }
                    }
                }
                else{ // sheet where PGM present Group Not present
                    if(iupgmKeyToUserIdToRecordMap.containsKey(accProgGeoKey)){
                        missingGroupList.addAll(iupgmKeyToUserIdToRecordMap.get(accProgGeoKey).values()[0]);
                        keySet.add(accProgGeoKey);
                    }
                }
            }
            
            if(!missingGrpMemberList.isEmpty() && keyToPGMRecordMap != null){
                contentWrapperLst = createContentWrapper(missingGrpMemberList, keyToPGMRecordMap, keySet); // calling createContentWrapper method with parameters of Missing Group Member
                missingCategoryToWrapperMap.put('Missing Group Member', contentWrapperLst); //Forming Map of Category to WrapperList
            }
            if(!missingGroupList.isEmpty() && keyToPGMRecordMap != null){
                contentWrapperLst = createContentWrapper(missingGroupList, keyToPGMRecordMap, keySet); // calling createContentWrapper method with parameters of Missing Group
                missingCategoryToWrapperMap.put('Missing Group', contentWrapperLst); //Forming Map of Category to WrapperList
            } 
            if(!missingPGMList.isEmpty() ){
                contentWrapperLst = createContentWrapper(missingPGMList, null, null); // calling createContentWrapper method with parameters of Missing PGM
                missingCategoryToWrapperMap.put('Missing PGM', contentWrapperLst); //Forming Map of Category to WrapperList
            }
            
            // logic to form CSV with wrapper as input
            if(missingCategoryToWrapperMap.keySet() != null){
                for(String category : missingCategoryToWrapperMap.keySet()){ // iterating on map to get the category
                    for(contentWrapper wrapperRec : missingCategoryToWrapperMap.get(category)){ //iterating on map to get the wrapper records
                        if(csvDataList.size() <= MAX_RECORDS){ // To restrict records more than 50K (If Inside Execute)
                            if(wrapperRec.accountName != null){
                                wrapperRec.accountName = '"' + wrapperRec.accountName.replace('"', '') + '"';
                            }
                            
                            String csvRow = category + ',' + wrapperRec.IUPGMId + ',' + wrapperRec.accountId + ',' + wrapperRec.accountName + ',' + wrapperRec.program + ',' + wrapperRec.role + ',' + wrapperRec.userId + ',' + wrapperRec.region; 
                            csvRow += (wrapperRec.allBudgetTypeAccess != null) ? ',' + wrapperRec.allBudgetTypeAccess : ',' + '-';
                            csvRow += string.isNotBlank(wrapperRec.budgetType) ? ',' + wrapperRec.budgetType : ',' + '-';
                            csvRow += string.isNotBlank(wrapperRec.PGMId) ? ',' + wrapperRec.PGMId : ',' + '-'; 
                            csvRow += string.isNotBlank(wrapperRec.groupId) ? ',' + wrapperRec.groupId : ',' + '-';
                            csvRow += string.isNotBlank(wrapperRec.groupName) ? ',' + wrapperRec.groupName : ',' + '-';
			    
                            if(csvDataList != null && !csvDataList.contains(csvRow)){
                                csvDataList.add(csvRow);
                                ++count;
                            }
                        }
                    }
                }
            }
        }
    }catch(Exception e){
        Core_MDF_CCP_UtilityClass.logError(e);
    }
    }
    
    /*-----------------------------------------------------------------------------------
Method Name         : createContentVersion
@Input Parameters   : List of csv records.
Description         : This method creates file based on progam. 
------------------------------------------------------------------------------------*/
    
    
    public ContentVersion createContentVersion(List<String> csvDataList){
        ContentVersion cv = new ContentVersion();
        cv.Title = 'IUPGM Discrepancy';
        String base64 = EncodingUtil.base64Encode(Blob.valueOf(String.join(csvDataList,'\n')));
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.PathOnClient = 'IUPGM Discrepancy' + '.csv';
        return cv;
    }
    
    // this method will be called in finish
    public void saveAttachment(List<ContentVersion> contentVersionListToBeInserted){
        
        List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
        
        if(recordTrackingId != null){
            for(ContentDocument contentDoc : [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :contentVersionListToBeInserted]){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentDoc.Id; 
                cdl.LinkedEntityId = recordTrackingId;
                cdl.ShareType = 'V'; // V stands for "Viewer Access". You can also use E for "Edit Access"
                cdl.Visibility = 'InternalUsers';// set the visibility of the file. Other options are InternalUsers or SharedUsers
                contentDocLinkList.add(cdl);
            }
            insert contentDocLinkList;
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
        try{
        if(recordTrackingId == null){
            Core_MDF_Record_Tracking__c rt = new Core_MDF_Record_Tracking__c();
            rt.Core_MDF_Scope_nm__c = 'IUPGM Discrepancy Monitor'; 
            Database.SaveResult insertedRecord = Database.insert(rt);
            
            if(insertedRecord != null && insertedRecord.isSuccess()){
                recordTrackingId = insertedRecord.getId();
            }  
        }
        
        if(csvDataList != null && !csvDataList.isEmpty()){
            contentVersionListToBeInserted.add(createContentVersion(csvDataList));
            Database.insert(contentVersionListToBeInserted);
            saveAttachment(contentVersionListToBeInserted);
        }
        
        if(csvDataList != null && !csvDataList.isEmpty() && csvDataList.size() > 1){ //ignoring the header
            List<String> userIdsList = new List<String>();
            List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
            String templateName =  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IUPGMDiscrepancyEmailTemp'); 
            String iupgmGroupName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IUPGMDiscrepancyRecipients'); 
            List<EmailTemplate> templateList = [SELECT Id, HtmlValue, Subject 
                                                FROM EmailTemplate 
                                                WHERE DeveloperName = :templateName LIMIT 1];
            
            if(iupgmGroupName != null){                          
                for(GroupMember grpMember : [SELECT Id, GroupId, UserOrGroupId, Group.DeveloperName 
                                             FROM GroupMember 
                                             WHERE Group.DeveloperName =:iupgmGroupName]){
                                                 userIdsList.add(grpMember.UserOrGroupId);
                                             }
            }
            
            if(!templateList.isEmpty() && recordTrackingId != null)                            
                for( User usr : [SELECT Id FROM user WHERE Id in: userIdsList]){
                    Messaging.SingleEmailMessage sendEmail =new Messaging.SingleEmailMessage();
                    sendEmail.setWhatId(recordTrackingId);
                    sendEmail.setTemplateId(templateList[0].id);
                    sendEmail.setTargetObjectId(usr.id);
                    sendEmail.setSaveAsActivity(false);
                    sendEmail.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
                    emailsToBeSent.add(sendEmail);
                }
            
            if(!emailsToBeSent.isEmpty()){
                Core_MDF_GenericClassToSendMail.sendEmails(emailsToBeSent);
            }
        }
    }catch(Exception e){
        Core_MDF_CCP_UtilityClass.logError(e);
    }
    }
    
    //creation of wrapper for IUPGM and PGM Fields
    public static List<contentWrapper> createContentWrapper (List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList, Map<String, Core_MDF_Partner_Group_Mapping__c> keyToPGMRecordMap, Set<String> keySet){
        List<contentWrapper> contentWrapperList = new List<contentWrapper>();
        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmRecord : iupgmList){
            Set<String> geoSubGeoSet =  new Set<String>();
            if(keyToPGMRecordMap == null){
                contentWrapper contentWraperRec = new contentWrapper();
                contentWraperRec.IUPGMId = iupgmRecord.Id;
                contentWraperRec.accountId = iupgmRecord.Core_MDF_Account_id__c;
                contentWraperRec.accountName = iupgmRecord.Core_MDF_Account_id__r.Name;
                contentWraperRec.program = iupgmRecord.Core_MDF_Program_nm__c;
                contentWraperRec.role = iupgmRecord.Core_MDF_Role_nm__c;
                contentWraperRec.region = iupgmRecord.Core_MDF_Region_Sub_Region_nm__c;
                contentWraperRec.budgetType = iupgmRecord.Core_MDF_Budget_Type_nm__c;
                contentWraperRec.userId = iupgmRecord.Core_MDF_User_id__c;
                contentWraperRec.allBudgetTypeAccess = iupgmRecord.Core_MDF_All_Budget_Type_Access_Ind__c;
                
                contentWrapperList.add(contentWraperRec);
            }
            else{
                String accProgGeoKey = '';
                if(iupgmRecord.Core_MDF_Region_Sub_Region_nm__c != null){
                    List<String> geoList = iupgmRecord.Core_MDF_Region_Sub_Region_nm__c.split(';');
                    geoSubGeoSet.addAll(new Set<String>(geoList));
                }
                //US - TWC702-14285
                if(iupgmRecord.Core_MDF_Budget_Type_nm__c != null){ // budget type exists
                    // Guard clause to avoid nested IF and improve readability
                    if(iupgmRecord.Core_MDF_GeoSubGeo_Budget_Type_nm__c == null) {
                        // Skip processing if no geo budget type data
                        continue; //US - TWC702-14285
                    }
                    
                    for(String geoBudgetTypeStr : iupgmRecord.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';')){
                        String geo = geoBudgetTypeStr.split('->')[0] ;                             
                        String budgetType = geoBudgetTypeStr.split('->')[1] ;
                        accProgGeoKey = iupgmRecord.Core_MDF_Account_id__c + ';' + iupgmRecord.Core_MDF_Program_nm__c + ';' + geo + ';' + budgetType; // 001g0000024cdfQQZ;Intel Partner Alliance;APJ;ProposalI
                        
                        if(keyToPGMRecordMap != null && keyToPGMRecordMap.containsKey(accProgGeoKey) && keySet.contains(accProgGeoKey)){ // if PGM is not null then only populate PGM fields
                            contentWrapper contentWraperRec = new contentWrapper();
                            
                            contentWraperRec.IUPGMId = iupgmRecord.Id;
                            contentWraperRec.accountId = iupgmRecord.Core_MDF_Account_id__c;
                            contentWraperRec.accountName = iupgmRecord.Core_MDF_Account_id__r.Name;
                            contentWraperRec.program = iupgmRecord.Core_MDF_Program_nm__c;
                            contentWraperRec.role = iupgmRecord.Core_MDF_Role_nm__c;
                            contentWraperRec.region = iupgmRecord.Core_MDF_Region_Sub_Region_nm__c;
                            contentWraperRec.budgetType = iupgmRecord.Core_MDF_Budget_Type_nm__c;
                            contentWraperRec.userId = iupgmRecord.Core_MDF_User_id__c;
                            contentWraperRec.allBudgetTypeAccess = iupgmRecord.Core_MDF_All_Budget_Type_Access_Ind__c;
                            contentWraperRec.PGMId = keyToPGMRecordMap.get(accProgGeoKey).Id;
                            contentWraperRec.groupId = keyToPGMRecordMap.get(accProgGeoKey).Core_MDF_Group_Id__c;
                            contentWraperRec.groupName = keyToPGMRecordMap.get(accProgGeoKey).Core_MDF_Group_Name__c;
                            contentWrapperList.add(contentWraperRec);
                        }
                    }
                }
                else{ // without budget type keys
                    for(String geo : geoSubGeoSet){
                        accProgGeoKey = iupgmRecord.Core_MDF_Account_id__c + ';' + iupgmRecord.Core_MDF_Program_nm__c + ';' + geo;  // 001g0000024cdfQQZ;Intel Partner Alliance;APJ

                        if(keyToPGMRecordMap != null && keyToPGMRecordMap.containsKey(accProgGeoKey) && keySet.contains(accProgGeoKey)){ // if PGM is not null then only populate PGM fields
                            contentWrapper contentWraperRec = new contentWrapper();
                            
                            contentWraperRec.IUPGMId = iupgmRecord.Id;
                            contentWraperRec.accountId = iupgmRecord.Core_MDF_Account_id__c;
                            contentWraperRec.accountName = iupgmRecord.Core_MDF_Account_id__r.Name;
                            contentWraperRec.program = iupgmRecord.Core_MDF_Program_nm__c;
                            contentWraperRec.role = iupgmRecord.Core_MDF_Role_nm__c;
                            contentWraperRec.region = iupgmRecord.Core_MDF_Region_Sub_Region_nm__c;
                            contentWraperRec.budgetType = iupgmRecord.Core_MDF_Budget_Type_nm__c;
                            contentWraperRec.userId = iupgmRecord.Core_MDF_User_id__c;
                            contentWraperRec.allBudgetTypeAccess = iupgmRecord.Core_MDF_All_Budget_Type_Access_Ind__c;
                            contentWraperRec.PGMId = keyToPGMRecordMap.get(accProgGeoKey).Id;
                            contentWraperRec.groupId = keyToPGMRecordMap.get(accProgGeoKey).Core_MDF_Group_Id__c;
                            contentWraperRec.groupName = keyToPGMRecordMap.get(accProgGeoKey).Core_MDF_Group_Name__c;
                            contentWrapperList.add(contentWraperRec);
                        }
                    }
                }
            }
        }     
        return contentWrapperList;
    }
    
    // Wrapper for IUPGM and PGM fields
    public class contentWrapper{
        Id IUPGMId;
        Id accountId;
        String accountName;
        String program;
        String role;
        String region;
        String budgetType;
        Id userId;
        Boolean allBudgetTypeAccess;
        Id PGMId;
        Id groupId;
        String groupName;
    }
}