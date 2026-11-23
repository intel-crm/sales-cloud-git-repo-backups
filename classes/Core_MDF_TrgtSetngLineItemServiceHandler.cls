/********************************************************************************************************************************************** 
Class Name:         Core_MDF_TrgtSetngLineItemServiceHandler
@parameters:        newTargetSettingLineItemList,oldTargetSettingLineItemMap,isInsert
Description:        Service Handler class for Target Setting Line Items
Added By:           Ayush   02-22-2024
Modified By:        Date:           Changes:

**********************************************************************************************************************************************/
public without sharing class Core_MDF_TrgtSetngLineItemServiceHandler {
    
    /***************************************************************************************************** 
Method Name   :        shareRecords
@return       :        void
@parameters   :        newTargetSettingLineItemList,oldTargetSettingLineItemMap,isInsert
Description   :        Share Line Item Records to PGM and Metadata groups
Added By      :        Ayush   02-22-2024
Modified By   :        Date:           Changes: 

******************************************************************************************************/
    public static void shareRecords(List<Core_MDF_Target_Setting_Line_Item__c> newTargetSettingLineItemList, Map<Id,Core_MDF_Target_Setting_Line_Item__c> oldTargetSettingLineItemMap, Boolean isInsert){
        Map<Id,Id>accToUltimateAccMap = new Map<Id,Id>();
        Set<Id> virtualCorpAccSet = new Set<Id>();
        String region = '';
        String programName = '';
        List<Core_MDF_RecordGeoShare> recordGeoShareList = new List<Core_MDF_RecordGeoShare>(); 
        List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
        List<Core_MDF_Target_Setting_Line_Item__Share> lineItemSharetoBeDeleted = new List<Core_MDF_Target_Setting_Line_Item__Share>();
        Map<Id,Core_MDF_Target_Setting_Line_Item__c> updatedLineItemMap = new  Map<Id,Core_MDF_Target_Setting_Line_Item__c>();
        
        try{
            for(Core_MDF_Target_Setting_Line_Item__c lineItemRecord : newTargetSettingLineItemList){
                if(lineItemRecord.Core_MDF_Account__c != null){
                    virtualCorpAccSet.add(lineItemRecord.Core_MDF_Account__c);
                }
            }
            for(Account acc : [SELECT id, Name, Core_MDF_Parent_Fund_Account__c
                               FROM Account 
                               WHERE Id IN: virtualCorpAccSet AND Core_MDF_Parent_Fund_Account__r.RecordType.DeveloperName !=: Core_MDF_CCP_ConstantClass.ACCOUNT_RECORD_TYPE])
            {
                accToUltimateAccMap.put(acc.Id, acc.Core_MDF_Parent_Fund_Account__c);
            }
            for(Core_MDF_Target_Setting_Line_Item__c lineItemRecord : newTargetSettingLineItemList){
                // US - TWC702-14285: Flatten nested IFs (no logic change)
                if(!isInsert && (oldTargetSettingLineItemMap == null || oldTargetSettingLineItemMap.isEmpty())){
                    continue;
                }
                
                region = (String.isNotBlank(lineItemRecord.Core_MDF_Host_Region_Txt__c)) ? lineItemRecord.Core_MDF_Host_Region_Txt__c : lineItemRecord.Core_MDF_Region_Name_nm__c;
       
                if(oldTargetSettingLineItemMap != null && !oldTargetSettingLineItemMap.isEmpty() && lineItemRecord.Core_MDF_Region_Name_nm__c != oldTargetSettingLineItemMap.get(lineItemRecord.Id).Core_MDF_Region_Name_nm__c){
                    updatedLineItemMap.put(lineItemRecord.id,lineItemRecord);
                }
                
                programName = lineItemRecord.Core_MDF_ProgramName_Txt__c;
                // US - TWC702-14285: Flatten nested IFs (no logic change)
                if(region == null || programName == null) {
                     continue;
                }
                
                if(programName == Core_MDF_CCP_ConstantClass.IPA_PROGRAM){
                    recordGeoShareList.add(new Core_MDF_RecordGeoShare(lineItemRecord.Id,region, null, programName, lineItemRecord.Core_MDF_Budget_Type_nm__c));
                    
                    if(lineItemRecord.Core_MDF_Account__c != null && accToUltimateAccMap.containsKey(lineItemRecord.Core_MDF_Account__c)){
                        recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(lineItemRecord.id, region, null, programName, lineItemRecord.Core_MDF_Budget_Type_nm__c, accToUltimateAccMap.get(lineItemRecord.Core_MDF_Account__c)));
                    }
                }
                // US - TWC702-14285: Flatten nested IFs (no logic change)
                if(programName != Core_MDF_CCP_ConstantClass.IPA_PROGRAM && lineItemRecord.Core_MDF_Region_Name_nm__c != null){
                    for(string geo : lineItemRecord.Core_MDF_Region_Name_nm__c.split(';')){
                        recordGeoShareList.add(new Core_MDF_RecordGeoShare(lineItemRecord.Id,geo, null, programName));
                        
                        if(lineItemRecord.Core_MDF_Account__c != null && accToUltimateAccMap.containsKey(lineItemRecord.Core_MDF_Account__c)){ 
                            recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(lineItemRecord.id, geo, null, programName, null, accToUltimateAccMap.get(lineItemRecord.Core_MDF_Account__c)));
                        }
                    }
                }
            }
            
            if(oldTargetSettingLineItemMap != null && !oldTargetSettingLineItemMap.isEmpty() && updatedLineItemMap != null && !updatedLineItemMap.isEmpty()){ //only on region update scenarios
                for(Core_MDF_Target_Setting_Line_Item__Share lineItemShare : [SELECT Id, ParentId, UserOrGroupId
                                                                              FROM Core_MDF_Target_Setting_Line_Item__Share
                                                                              WHERE ParentId IN :updatedLineItemMap.keySet() AND 
                                                                              RowCause =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RowCause_Manual')]){
                                                                                  lineItemSharetoBeDeleted.add(lineItemShare);
                                                                              }
                if(lineItemSharetoBeDeleted != NULL && lineItemSharetoBeDeleted.size() > 0){
                    delete lineItemSharetoBeDeleted; // deleting manual share records 
                }
            }
            
            
            if(recordGeoShareList != NULL && recordGeoShareList.size() >0){ 
                Core_MDF_ShareRecordToGeoGroup.shareRecordToGeoGroup('Core_MDF_Target_Setting_Line_Item__c',recordGeoShareList);
            }
            if(recordPGMShareList != null && recordPGMShareList.size() >0){
                Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('Core_MDF_Target_Setting_Line_Item__c', recordPGMShareList);
            }
        }
        catch ( Exception e ){
            Core_MDF_CCP_UtilityClass.logError ( e );
        }
    }
    /***************************************************************************************************** 
Method Name   :        sumOfAmount
@return       :        void
@parameters   :        newTargetSettingLineItemList,oldTargetSettingLineItemMap,isInsert
Description   :        Update sum of all Target Setting Line Item records on Version Record
Added By      :        Ayush   02-22-2024
Modified By   :        Date:           Changes: 

******************************************************************************************************/
    public static void sumOfAmount(List<Core_MDF_Target_Setting_Line_Item__c> newTargetSettingLineItemList, Map<Id,Core_MDF_Target_Setting_Line_Item__c> oldTargetSettingLineItemMap, Boolean isInsert){
        Set<Id> versionIdSet = new Set<Id>();
        List<Core_MDF_Spending_Targets_Version__c> versionRecordList = new List<Core_MDF_Spending_Targets_Version__c>();
        Map<Id,Decimal> versionIdToAggregateLineItemsAmtMap = new Map<Id,Decimal>();
        try{
            for(Core_MDF_Target_Setting_Line_Item__c lineItemRecord : newTargetSettingLineItemList){
                if(isInsert || (oldTargetSettingLineItemMap != null && !oldTargetSettingLineItemMap.isEmpty() && lineItemRecord.Core_MDF_Amount__c != oldTargetSettingLineItemMap.get(lineItemRecord.Id).Core_MDF_Amount__c)){
                    versionIdSet.add(lineItemRecord.Core_MDF_Spending_Targets_Version__c);
                }
            }
            if(!versionIdSet.isEmpty() && versionIdSet != null){
                for(AggregateResult lineItemRec : [SELECT Core_MDF_Spending_Targets_Version__c Id ,sum(Core_MDF_Amount__c)amt
                                                   FROM Core_MDF_Target_Setting_Line_Item__c 
                                                   WHERE Core_MDF_Spending_Targets_Version__c IN: versionIdSet
                                                   GROUP BY Core_MDF_Spending_Targets_Version__c]){ 
                                                       ID versionId =(Id)lineItemRec.get('Id');
                                                       Decimal agregateLineItemAmount =(Decimal)lineItemRec.get('amt');
                                                       versionIdToAggregateLineItemsAmtMap.put(versionId,agregateLineItemAmount); //check on aggr quey if anythinfg is null it will fdefault ot 0
                                                   }
                for(Core_MDF_Spending_Targets_Version__c versionRecord : [SELECT Id, Core_MDF_Amount_amt__c 
                                                                          FROM Core_MDF_Spending_Targets_Version__c 
                                                                          WHERE Id IN: versionIdSet]){
                                                                              if(versionIdToAggregateLineItemsAmtMap != null && versionIdToAggregateLineItemsAmtMap.containsKey(versionRecord.Id)){
                                                                                  Core_MDF_Spending_Targets_Version__c versionObj = new Core_MDF_Spending_Targets_Version__c();
                                                                                  versionObj.Id = versionRecord.Id;
                                                                                  versionObj.Core_MDF_Amount_amt__c = versionIdToAggregateLineItemsAmtMap.get(versionRecord.Id) != null ? versionIdToAggregateLineItemsAmtMap.get(versionRecord.Id) : 0;
                                                                                  versionRecordList.add(versionObj);
                                                                              }
                                                                          }
            }
            if(!versionRecordList.isEmpty() && versionRecordList != null){
                Database.update(versionRecordList);
            }
        }
        catch ( Exception e ){
            Core_MDF_CCP_UtilityClass.logError ( e );
        }
    }
    
    /***************************************************************************************************** 
Method Name   :        validateUserRegion
@return       :        void
@parameters   :        newTargetSettingLineItemList,oldTargetSettingLineItemMap,isInsert
Description   :        validate user region while creating Target Setting Line Items on Spending Targets
Added By      :        Leela   06-09-2024
Modified By   :        Date:           Changes: 

******************************************************************************************************/
    Public Static Void validateUserRegion(List<Core_MDF_Target_Setting_Line_Item__c> newTargetSettingLineItemList, Map<Id,Core_MDF_Target_Setting_Line_Item__c> oldTargetSettingLineItemMap, Boolean isInsert){
        Map<String, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>> iupgmMap = new Map<String, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>>();       
        String TRGT_SETTNG_LINE_ITEM_REGION_VALIDATION_ERROR_MESSAGE = Core_MDF_CCP_ConstantClass.TRGT_SETTNG_LINE_ITEM_REGION_VALIDATION_ERROR_MESSAGE; 
        List<Core_MDF_Target_Setting_Line_Item__c> lineItemsList= new List<Core_MDF_Target_Setting_Line_Item__c>();
        Id lineItemIPARecTypeId = Schema.SObjectType.Core_MDF_Target_Setting_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        List<String> allGeosLst = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Exception_AllGeo').Split(',');
        try{
            for(Core_MDF_Target_Setting_Line_Item__c trgtSettingLineItemRec : newTargetSettingLineItemList){
                if(trgtSettingLineItemRec.RecordTypeId != lineItemIPARecTypeId && (oldTargetSettingLineItemMap == null ||
                  trgtSettingLineItemRec.Core_MDF_Country_Name_nm__c != oldTargetSettingLineItemMap.get(trgtSettingLineItemRec.Id).Core_MDF_Country_Name_nm__c))
                {
                    lineItemsList.add(trgtSettingLineItemRec);   
                }
            }
            if(!(FeatureManagement.checkPermission('Core_MDF_Budget_User_Target_Setting_Line_Item_Access')) && !lineItemsList.isEmpty()){
                // Query IUPGM records to get the regions for the creating users
                List<String> accountManagerPermissionSet = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Acc_Mgr_Trgt_Line_Item_Modify').split(',');
                for (Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Core_MDF_User_id__c,Core_MDF_Account_id__c,Core_MDF_Channel_Program_id__r.Name,Core_MDF_Region_Sub_Region_nm__c
                                                                        FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c WHERE Core_MDF_User_id__c =: UserInfo.getUserId() AND Core_MDF_Active_Ind__c= TRUE 
                                                                        AND Core_MDF_Role_nm__c IN : accountManagerPermissionSet]) { 
                                                                            //Verify if Account Manager has WW IUPGM access                                                          
                                                                            List<String> regionList = iupgm.Core_MDF_Region_Sub_Region_nm__c.split(';');
                                                                            // US - TWC702-14285: Flatten nested IFs (no logic change)
                                                                            // Early exit if no regions
                                                                            if(regionList.isEmpty()) {
                                                                                continue;            //Refactored: Using guard clauses to avoid deep nesting
                                                                            }
                                                                            
                                                                            for(String geo : regionList){  
                                                                                // Handle 'WW' case separately
                                                                                if(geo == 'WW'){
                                                                                    for(String strOnGeoLst : allGeosLst){
                                                                                        String iupgmKey = (String) iupgm.Core_MDF_Account_id__c+ (String) iupgm.Core_MDF_Channel_Program_id__r.Name+strOnGeoLst;
                                                                                        // Combine conditions to reduce nesting
                                                                                        if(iupgmMap != null && iupgmMap.containsKey(iupgmKey) && iupgmMap.get(iupgmKey) != null) {
                                                                                            iupgmMap.get(iupgmKey).add(iupgm);    
                                                                                        }
                                                                                        else {
                                                                                            iupgmMap.put(iupgmKey,new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>{iupgm});
                                                                                        }
                                                                                    }    
                                                                                }
                                                                                else{
                                                                                    String iupgmKey = (String) iupgm.Core_MDF_Account_id__c+ (String) iupgm.Core_MDF_Channel_Program_id__r.Name+geo;
                                                                                    // Combine conditions to reduce nesting
                                                                                    if(iupgmMap != null && iupgmMap.containsKey(iupgmKey) && iupgmMap.get(iupgmKey) != null) {
                                                                                        iupgmMap.get(iupgmKey).add(iupgm);    
                                                                                    }
                                                                                    else {
                                                                                        iupgmMap.put(iupgmKey,new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>{iupgm});
                                                                                    }
                                                                                }
                                                                            } 
                                                                        }
                // US - TWC702-14285: Flatten nested IFs (no logic change)
                // Early exit if no iupgm mappings exist
                if(iupgmMap.isEmpty()) {
                    for (Core_MDF_Target_Setting_Line_Item__c trgtSettingLineItemRec : lineItemsList) {
                        trgtSettingLineItemRec.addError(TRGT_SETTNG_LINE_ITEM_REGION_VALIDATION_ERROR_MESSAGE);
                    }
                    // Skip the rest of the validation logic - no continue needed here
                    // Just return early from this method since no further validation is needed
                    return;               //Refactored: Using guard clauses to avoid deep nesting
                }

                // US - TWC702-14285: Flatten nested IFs (no logic change)
                // Perform Region check for Target Setting Line Item record and throw validation error 
                for (Core_MDF_Target_Setting_Line_Item__c trgtSettingLineItemRec : lineItemsList) {
                    // Early exit if no regions to validate
                    if(trgtSettingLineItemRec.Core_MDF_Region_Name_nm__c == null) {
                        continue;           //Refactored: Using guard clauses to avoid deep nesting
                    }
                    
                    // US - TWC702-14285: Flatten nested IFs (no logic change)
                    // Check if the region/country combination is valid
                    Boolean isValidRegion = isInsert || (oldTargetSettingLineItemMap != null && !oldTargetSettingLineItemMap.isEmpty() && 
                        oldTargetSettingLineItemMap.get(trgtSettingLineItemRec.Id).Core_MDF_Country_Name_nm__c != null &&
                        trgtSettingLineItemRec.Core_MDF_Country_Name_nm__c != oldTargetSettingLineItemMap.get(trgtSettingLineItemRec.Id).Core_MDF_Country_Name_nm__c);
                    
                    // US - TWC702-14285: Flatten nested IFs (no logic change)
                    // If not valid, skip validation (this prevents unnecessary processing)
                    if(!isValidRegion) {
                        continue;          //Refactored: Using guard clauses to avoid deep nesting
                    }
                    
                    List<string> geoList = trgtSettingLineItemRec.Core_MDF_Region_Name_nm__c.split(';');
                    for(String geo : geoList){
                        String trgetSettingLineItemkey = trgtSettingLineItemRec.Core_MDF_Ultimate_Account_Id__c + (String) trgtSettingLineItemRec.Core_MDF_ProgramName_Txt__c+geo; 
                       
                        if(!iupgmMap.containskey(trgetSettingLineItemkey)){
                           trgtSettingLineItemRec.addError(TRGT_SETTNG_LINE_ITEM_REGION_VALIDATION_ERROR_MESSAGE);
                       }
                    }
                }
            }
        }catch ( Exception e ){
            Core_MDF_CCP_UtilityClass.logError ( e );
        }
    }  
    /***************************************************************************************************** 
Method Name   :        validateCountrySelection
@return       :        void
@parameters   :        newTargetSettingLineItemList
Description   :        validate the country selection
Added By      :        Aswin   07-09-2024
Modified By   :        Date:           Changes: 

******************************************************************************************************/
    Public Static Void validateCountrySelection(List<Core_MDF_Target_Setting_Line_Item__c> newTargetSettingLineItemList){

        Id lineItemIPARecTypeId = Schema.SObjectType.Core_MDF_Target_Setting_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();

        String TRGT_SETTNG_LINE_ITEM_MULTI_COUNTRY_VALIDATION_ERROR_MESSAGE = Core_MDF_CCP_ConstantClass.TRGT_SETTNG_LINE_ITEM_MULTI_COUNTRY_VALIDATION_ERROR_MESSAGE; 

        for (Core_MDF_Target_Setting_Line_Item__c trgtSettingLineItemRec : newTargetSettingLineItemList) {
            if(trgtSettingLineItemRec.RecordTypeId != lineItemIPARecTypeId){
                List<string> countryList = trgtSettingLineItemRec.Core_MDF_Country_Name_nm__c.split(';');
                if((countryList.contains(Core_MDF_CCP_ConstantClass.Trgt_Setting_Line_Item_All_Other_EMEA)
                    || countryList.contains(Core_MDF_CCP_ConstantClass.Trgt_Setting_Line_Item_All_Other_ASMO)
                    || countryList.contains(Core_MDF_CCP_ConstantClass.Trgt_Setting_Line_Item_All_Other_APJ)) && countryList.size()>1){
                    trgtSettingLineItemRec.addError(TRGT_SETTNG_LINE_ITEM_MULTI_COUNTRY_VALIDATION_ERROR_MESSAGE);
                }
            }
        }
    }
    
/********************************************************************************************************************************************** 
Class Name:         Core_MDF_TrgtSetngLineItemServiceHandler
@parameters:        newTargetSettingLineItemList,oldTargetSettingLineItemMap
Description:        validate duplicate target setting line item records present in the system.
Added By:           Akanksha   03-07-2024
Modified By:        Date:           Changes:

**********************************************************************************************************************************************/

    public static void validateDuplicateTargetSetngLineItemRcrds(List<Core_MDF_Target_Setting_Line_Item__c> newTargetSettingLineItemList, Map<Id,Core_MDF_Target_Setting_Line_Item__c> oldTargetSettingLineItemMap){
	

        List<Core_MDF_Target_Setting_Line_Item__c> trgtStngLineItemLst = new List<Core_MDF_Target_Setting_Line_Item__c>();
        Map<String, Core_MDF_Target_Setting_Line_Item__c> mapOfTargtSetngLnItemWithoutDuplicates = new Map<String, Core_MDF_Target_Setting_Line_Item__c>();
        String TRGT_SETTNG_LINE_ITEM_DUPLICATE_RECORD_ERROR_MESSAGE = Core_MDF_CCP_ConstantClass.TRGT_SETTNG_LINE_ITEM_DUPLICATE_RECORD_ERROR_MESSAGE; 
        Id lineItemIPARecTypeId = Schema.SObjectType.Core_MDF_Target_Setting_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();

        Set<String> existingProgramNameSet = new Set<String>();
        Set<String> spndgTrgtRcrdNameSet = new Set<String>();
        Set<String> spndgTrgtVrsnNameSet = new Set<String>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<String> prioritySet = new Set<String>();
        Set<String> bucketNameSet = new Set<String>();
        Set<String> countryNameSet = new Set<String>();
        Set<String> campaignNameSet = new Set<String>();
        Set<String> budgetTypeNameSet = new Set<String>();
    
        Map<String, List<Core_MDF_Target_Setting_Line_Item__c>> mapOfKeyForOldTrgtStngRcrds = new Map<String, List<Core_MDF_Target_Setting_Line_Item__c>>();
        List<Core_MDF_Target_Setting_Line_Item__c> existingLstTrgtStngLineItems = new List<Core_MDF_Target_Setting_Line_Item__c>();

        try{

        if(oldTargetSettingLineItemMap == null){
            trgtStngLineItemLst.addAll(newTargetSettingLineItemList);
        }else{
            for(Core_MDF_Target_Setting_Line_Item__c itrTrgtStngLnItmRcrd : newTargetSettingLineItemList){
                if(itrTrgtStngLnItmRcrd.Core_MDF_Spending_Targets_Record_Name__c != oldTargetSettingLineItemMap.get(itrTrgtStngLnItmRcrd.Id).Core_MDF_Spending_Targets_Record_Name__c ||
                itrTrgtStngLnItmRcrd.Core_MDF_Spending_Targets_Record_Name__c != oldTargetSettingLineItemMap.get(itrTrgtStngLnItmRcrd.Id).Core_MDF_Spending_Targets_Record_Name__c ||
                itrTrgtStngLnItmRcrd.Core_MDF_Spending_Version_Record_Name__c != oldTargetSettingLineItemMap.get(itrTrgtStngLnItmRcrd.Id).Core_MDF_Spending_Version_Record_Name__c ||
                itrTrgtStngLnItmRcrd.Core_MDF_Account__c != oldTargetSettingLineItemMap.get(itrTrgtStngLnItmRcrd.Id).Core_MDF_Account__c ||
                itrTrgtStngLnItmRcrd.Core_MDF_Priority_nm__c != oldTargetSettingLineItemMap.get(itrTrgtStngLnItmRcrd.Id).Core_MDF_Priority_nm__c ||
                itrTrgtStngLnItmRcrd.Core_MDF_Bucket_nm__c != oldTargetSettingLineItemMap.get(itrTrgtStngLnItmRcrd.Id).Core_MDF_Bucket_nm__c ||
                itrTrgtStngLnItmRcrd.Core_MDF_Country_Name_nm__c != oldTargetSettingLineItemMap.get(itrTrgtStngLnItmRcrd.Id).Core_MDF_Country_Name_nm__c ||
                itrTrgtStngLnItmRcrd.Core_MDF_Campaign_Name__c != oldTargetSettingLineItemMap.get(itrTrgtStngLnItmRcrd.Id).Core_MDF_Campaign_Name__c ||
                itrTrgtStngLnItmRcrd.Core_MDF_Budget_Type_nm__c != oldTargetSettingLineItemMap.get(itrTrgtStngLnItmRcrd.Id).Core_MDF_Budget_Type_nm__c){
                
                    trgtStngLineItemLst.add(itrTrgtStngLnItmRcrd);
                }
            }
        }
        if(!trgtStngLineItemLst.isEmpty()){
            //rename itrTrgtStngLnItmRcrd this to itrTrgtStngLnItmRcrdLnItem
            for(Core_MDF_Target_Setting_Line_Item__c itrTrgtStngLnItmRcrd : trgtStngLineItemLst){
                if(itrTrgtStngLnItmRcrd.RecordTypeId != lineItemIPARecTypeId){
                    existingProgramNameSet.add(itrTrgtStngLnItmRcrd.Core_MDF_ProgramName_Txt__c);
                    spndgTrgtRcrdNameSet.add(itrTrgtStngLnItmRcrd.Core_MDF_Spending_Targets_Record_Name__c);
                    spndgTrgtVrsnNameSet.add(itrTrgtStngLnItmRcrd.Core_MDF_Spending_Version_Record_Name__c);
                    accountIdSet.add(itrTrgtStngLnItmRcrd.Core_MDF_Account__c);
                    prioritySet.add(itrTrgtStngLnItmRcrd.Core_MDF_Priority_nm__c);
                    bucketNameSet.add(itrTrgtStngLnItmRcrd.Core_MDF_Bucket_nm__c);
                    countryNameSet.add(itrTrgtStngLnItmRcrd.Core_MDF_Country_Name_nm__c);
                    campaignNameSet.add(itrTrgtStngLnItmRcrd.Core_MDF_Campaign_Name__c);
                    budgetTypeNameSet.add(itrTrgtStngLnItmRcrd.Core_MDF_Budget_Type_nm__c);
                }
            }
            if(!(existingProgramNameSet.isEmpty() && spndgTrgtRcrdNameSet.isEmpty() && spndgTrgtVrsnNameSet.isEmpty() && accountIdSet.isEmpty() && prioritySet.isEmpty() &&
                bucketNameSet.isEmpty() && countryNameSet.isEmpty() && campaignNameSet.isEmpty() && budgetTypeNameSet.isEmpty())){
                
                existingLstTrgtStngLineItems = [SELECT Id, Core_MDF_Account__c,Core_MDF_Priority_nm__c,Core_MDF_Bucket_nm__c,Core_MDF_Country_Name_nm__c,Core_MDF_Campaign_Name__c,
                                            Core_MDF_Budget_Type_nm__c,Core_MDF_ProgramName_Txt__c,Core_MDF_Spending_Version_Record_Name__c, Core_MDF_Spending_Targets_Record_Name__c 
                                            FROM Core_MDF_Target_Setting_Line_Item__c WHERE
                                            Core_MDF_ProgramName_Txt__c IN : existingProgramNameSet AND
                                            Core_MDF_Spending_Targets_Record_Name__c IN : spndgTrgtRcrdNameSet AND
                                            Core_MDF_Spending_Version_Record_Name__c IN : spndgTrgtVrsnNameSet AND
                                            Core_MDF_Account__c IN : accountIdSet AND
                                            Core_MDF_Priority_nm__c IN : prioritySet AND
                                            Core_MDF_Bucket_nm__c IN : bucketNameSet AND
                                            Core_MDF_Country_Name_nm__c IN : countryNameSet AND
                                            Core_MDF_Campaign_Name__c IN : campaignNameSet AND
                                            Core_MDF_Budget_Type_nm__c IN : budgetTypeNameSet 
                                            ];	
            }
            if(!existingLstTrgtStngLineItems.isEmpty() && existingLstTrgtStngLineItems.size() > 0){
                mapOfKeyForOldTrgtStngRcrds = Core_MDF_TrgtSetngLineItemServiceHandler.fetchMapWithKeyAndListOfTrgtSetngLineItemRcrds(existingLstTrgtStngLineItems);
            }
            String KeyForDuplicateCheck = '';
            for(Core_MDF_Target_Setting_Line_Item__c itrOnNewTrgtStngLnItm : newTargetSettingLineItemList){
                // US - TWC702-14285: Flatten nested IFs (no logic change)
                // Early exit for IPA records
                if(itrOnNewTrgtStngLnItm.RecordTypeId == lineItemIPARecTypeId){
                    continue;         //Refactored: Using guard clauses to avoid deep nesting
                }
                
                // Build key for duplicate checking
                KeyForDuplicateCheck = itrOnNewTrgtStngLnItm.Core_MDF_Account__c + '_' +
                                        itrOnNewTrgtStngLnItm.Core_MDF_Priority_nm__c + '_' + 
                                        itrOnNewTrgtStngLnItm.Core_MDF_Bucket_nm__c + '_' +
                                        itrOnNewTrgtStngLnItm.Core_MDF_Country_Name_nm__c + '_' +
                                        itrOnNewTrgtStngLnItm.Core_MDF_Campaign_Name__c + '_' +
                                        itrOnNewTrgtStngLnItm.Core_MDF_Budget_Type_nm__c + '_' +
                                        itrOnNewTrgtStngLnItm.Core_MDF_Spending_Version_Record_Name__c + '_' +
                                        itrOnNewTrgtStngLnItm.Core_MDF_Spending_Targets_Record_Name__c;
                // US - TWC702-14285: Flatten nested IFs (no logic change)
                // Early exit if key is empty
                if(String.isEmpty(KeyForDuplicateCheck)){
                    continue;         //Refactored: Using guard clauses to avoid deep nesting
                }
                
                       if(mapOfKeyForOldTrgtStngRcrds.containsKey(KeyForDuplicateCheck)){
                            itrOnNewTrgtStngLnItm.addError(TRGT_SETTNG_LINE_ITEM_DUPLICATE_RECORD_ERROR_MESSAGE);
                        }else{
                            //check for duplicates in the incoming list of Target Setting Line Item Records.
                            if(!mapOfTargtSetngLnItemWithoutDuplicates.containsKey(KeyForDuplicateCheck)){
                                mapOfTargtSetngLnItemWithoutDuplicates.put(KeyForDuplicateCheck, itrOnNewTrgtStngLnItm);
                            }else{
                                itrOnNewTrgtStngLnItm.addError(TRGT_SETTNG_LINE_ITEM_DUPLICATE_RECORD_ERROR_MESSAGE);
                            }
                        }
            }
        }   
    }catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e);}  

    }
/********************************************************************************************************************************************** 
Class Name:         Core_MDF_TrgtSetngLineItemServiceHandler
@parameters:        TargetSettingLineItem List
Description:        Method return a Map of key and list of Target setting line item record. The key consist of the values againt which duplicates are checked in the system
Added By:           Akanksha   03-07-2024
Modified By:        Date:           Changes:

**********************************************************************************************************************************************/
    public static Map<String, List<Core_MDF_Target_Setting_Line_Item__c>> fetchMapWithKeyAndListOfTrgtSetngLineItemRcrds(List<Core_MDF_Target_Setting_Line_Item__c> lstTrgtStngRrds){
        
        String keyForTrgtStngRcrds = '';
        Map<String, List<Core_MDF_Target_Setting_Line_Item__c>> mapOfKeyAndTargtSetngLineItemRcrds = new Map<String, List<Core_MDF_Target_Setting_Line_Item__c>>();
        try{
            // US - TWC702-14285: Flatten nested IFs (no logic change)
            // Early exit if list is empty
            if(lstTrgtStngRrds.isEmpty()){
                return mapOfKeyAndTargtSetngLineItemRcrds;         //Refactored: Using guard clauses to avoid deep nesting
            }
            
            for(Core_MDF_Target_Setting_Line_Item__c itrTrgtStngLnItmRcrd : lstTrgtStngRrds){
                //key for validating duplicates.
                keyForTrgtStngRcrds = itrTrgtStngLnItmRcrd.Core_MDF_Account__c + '_' +
                                        itrTrgtStngLnItmRcrd.Core_MDF_Priority_nm__c + '_' + 
                                        itrTrgtStngLnItmRcrd.Core_MDF_Bucket_nm__c + '_' +
                                        itrTrgtStngLnItmRcrd.Core_MDF_Country_Name_nm__c + '_' +
                                        itrTrgtStngLnItmRcrd.Core_MDF_Campaign_Name__c + '_' +
                                        itrTrgtStngLnItmRcrd.Core_MDF_Budget_Type_nm__c + '_' +
                                        itrTrgtStngLnItmRcrd.Core_MDF_Spending_Version_Record_Name__c + '_' +
                                        itrTrgtStngLnItmRcrd.Core_MDF_Spending_Targets_Record_Name__c;
                // US - TWC702-14285: Flatten nested IFs (no logic change)
                // Early exit if key is empty
                if(String.isEmpty(keyForTrgtStngRcrds)){
                    continue;            //Refactored: Using guard clauses to avoid deep nesting
                }
                
                // US - TWC702-14285: Flatten nested IFs (no logic change)
                // Add to map or append to existing list
                if(mapOfKeyAndTargtSetngLineItemRcrds.containsKey(keyForTrgtStngRcrds)){
                    mapOfKeyAndTargtSetngLineItemRcrds.get(keyForTrgtStngRcrds).add(itrTrgtStngLnItmRcrd); // added to existing list
          }else{
                    mapOfKeyAndTargtSetngLineItemRcrds.put(keyForTrgtStngRcrds,new List<Core_MDF_Target_Setting_Line_Item__c>{itrTrgtStngLnItmRcrd});   // created new list
                }
            }	
        }catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e);}
         return mapOfKeyAndTargtSetngLineItemRcrds;  
     
    }
}