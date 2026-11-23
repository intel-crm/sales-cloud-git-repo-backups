public without sharing class Core_MDF_Target_Setting_ServiceHandler {
    
    public static final string pfrPrefixKey = Core_MDF_Target_Setting__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix();
    public static id versionId;
    
    /*****************************************************************************************************
Method Name :   validateRecords
Description :   Method to check all the validations on Target Setting object 
Called on   :   Before Insert
******************************************************************************************************/    
    public static void validateRecords(List<Core_MDF_Target_Setting__c> newTargetSettingList, Map<Id,Core_MDF_Target_Setting__c> oldTargetSettingMap, Boolean isInsert){
        try{
            validateOverlapingTargetSetting(newTargetSettingList, oldTargetSettingMap, isInsert);
        }
        catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);  
            throw e; 
        }
    }
    
    /*****************************************************************************************************
Method Name :   validateRecordsOnUpdate
Description :   Method to check all the validations on Target Setting object 
Called on   :   Before Update
******************************************************************************************************/    
    public static void validateRecordsOnUpdate(List<Core_MDF_Target_Setting__c> newTargetSettingList, Map<Id,Core_MDF_Target_Setting__c> oldTargetSettingMap, Boolean isInsert){
        try{
            validateOvrlapingTgtSetngOnUpdate(newTargetSettingList, oldTargetSettingMap, isInsert); 
        }
        catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);  
            throw e;
        }
    }
    
    /*******************************************************************************************************************************
Method Name :   createTargetSettingLineItems
Description :   This method is used to create Target Setting Line Item records for both Top Accounts and Other Accounts 
Called on   :   After Insert
********************************************************************************************************************************/    
    public static void createTargetSettingLineItems(List<Core_MDF_Target_Setting__c> targetSettingList, Map<Id,Core_MDF_Target_Setting__c> oldTargetSettingMap, Boolean isInsert){
        
        List<Core_MDF_Target_Setting_Line_Item__c> lineItemsList= new List<Core_MDF_Target_Setting_Line_Item__c>();
        List<Core_MDF_Target_Setting_LineItem_Config__c> LineItemConfigList = new List<Core_MDF_Target_Setting_LineItem_Config__c>();
        List<String> TopAccEnabledBudgetTypes = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_TrgtStngTopAccEnabledBdgtTypes').split(';');
        // Highlight: Unused Local Variable - 14285
        // Map<Id, String> accIdToGeoMap = new Map<Id,String>();
        Map<String, List<Core_MDF_Target_Setting_LineItem_Config__c>> programToLineItemListMap = new Map<String, List<Core_MDF_Target_Setting_LineItem_Config__c>>();
        Map<String, List<Account>> programToAccListMap = new Map<String, List<Account>>();
        Set<String> programIdSet = new Set<String>();
        Map<String,String> idToProgramMap = new Map<String,String>();
        Id lineItemIPARecTypeId = Schema.SObjectType.Core_MDF_Target_Setting_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        
        try{
            for(Core_MDF_Target_Setting__c targetSettingRecord : targetSettingList){
                programIdSet.add(targetSettingRecord.Core_MDF_Program_Name__c);
            }
            
            for (ChannelProgram cp : [SELECT Id, Name                               
                                      FROM ChannelProgram                               
                                      WHERE Id IN: programIdSet]){                               
                                          idToProgramMap.put(cp.Id,cp.Name);                             
                                      } 

            if(idToProgramMap.values().contains(Core_MDF_CCP_ConstantClass.IPA_PROGRAM)){
            
                //quering on account to get Top Accounts for a particular progam which is selected on Targetr Setting record 
                for(Account acc : [SELECT id, Name, Core_MDF_Channel_Program__r.Name, Core_Geo__c 
                                FROM Account 
                                WHERE Core_MDF_Is_Top_Account_Ind__c = true 
                                And Core_MDF_Channel_Program__c IN :programIdSet])
                {
                    //Map which contains all top accounts for a particular program
                    if(!programToAccListMap.containsKey(acc.Core_MDF_Channel_Program__r.Name)){
                        programToAccListMap.put(acc.Core_MDF_Channel_Program__r.Name, new List<Account>());
                    }
                    programToAccListMap.get(acc.Core_MDF_Channel_Program__r.Name).add(acc);
                }
                
                //Query for custom setting records 
                LineItemConfigList = [SELECT Id, Name, Core_MDF_Program_txt__c, Core_MDF_Budget_Type_txt__c, Core_MDF_Region_txt__c,Core_MDF_Focus_Area_txt__c, Core_MDF_Sub_Region_txt__c 
                                    FROM Core_MDF_Target_Setting_LineItem_Config__c 
                                    WHERE Core_MDF_Is_Active_Ind__c = true 
                                    And Core_MDF_Program_txt__c IN :idToProgramMap.values()];
                
                for(Core_MDF_Target_Setting_LineItem_Config__c LineItemconfig: LineItemConfigList){
                    if(!programToLineItemListMap.containsKey(LineItemconfig.Core_MDF_Program_txt__c)){
                        programToLineItemListMap.put(LineItemconfig.Core_MDF_Program_txt__c, new List<Core_MDF_Target_Setting_LineItem_Config__c>());
                    }
                    programToLineItemListMap.get(LineItemconfig.Core_MDF_Program_txt__c).add(LineItemconfig);
                }
                if(!targetSettingList.isEmpty()){
                    for(Core_MDF_Target_Setting__c targetSetting : targetSettingList){
                       // if(idToProgramMap.containsKey(targetSetting.Core_MDF_Program_Name__c) && programToLineItemListMap.containsKey(idToProgramMap.get(targetSetting.Core_MDF_Program_Name__c)) && programToLineItemListMap.get(idToProgramMap.get(targetSetting.Core_MDF_Program_Name__c)) != null){
                      
                        
                            if (!idToProgramMap.containsKey(targetSetting.Core_MDF_Program_Name__c) ||
                                !programToLineItemListMap.containsKey(idToProgramMap.get(targetSetting.Core_MDF_Program_Name__c)) ||
                                programToLineItemListMap.get(idToProgramMap.get(targetSetting.Core_MDF_Program_Name__c)) == null) {
                                continue; //US - TWC702-14285
                            }

                            for(Core_MDF_Target_Setting_LineItem_Config__c configRecord : programToLineItemListMap.get(idToProgramMap.get(targetSetting.Core_MDF_Program_Name__c))){
                                //Add top accounts for those budget types which are configured in TopAccEnabledBudgetTypes metadata rec
                                //US - TWC702-14285 - Added the below commented if conditions 
                                if(TopAccEnabledBudgetTypes.contains(configRecord.Core_MDF_Budget_Type_txt__c) 
                                && programToAccListMap.containsKey(configRecord.Core_MDF_Program_txt__c) 
                                && programToAccListMap.get(configRecord.Core_MDF_Program_txt__c) != null){
                                   // if(programToAccListMap.containsKey(configRecord.Core_MDF_Program_txt__c) && programToAccListMap.get(configRecord.Core_MDF_Program_txt__c) != null){ //US - TWC702-14285 - Original code commented
                                        for(Account acc : programToAccListMap.get(configRecord.Core_MDF_Program_txt__c)){
                                            //pickup records from custom setting which matches the host region of account 
                                            if(acc.Core_Geo__c == configRecord.Core_MDF_Region_txt__c){
                                                Core_MDF_Target_Setting_Line_Item__c topAccountLineItems = new Core_MDF_Target_Setting_Line_Item__c();
                                                topAccountLineItems.Core_MDF_Account__c = acc.id;
                                                topAccountLineItems.Core_MDF_All_Accounts_nm__c = 'No';
                                                topAccountLineItems.Core_MDF_Budget_Type_nm__c = configRecord.Core_MDF_Budget_Type_txt__c;
                                                topAccountLineItems.Core_MDF_Focus_Area_nm__c = configRecord.Core_MDF_Focus_Area_txt__c;
                                                topAccountLineItems.Core_MDF_Region_Name_nm__c = acc.Core_Geo__c;
                                                topAccountLineItems.Core_MDF_Amount__c = 0;
                                                //topAccountLineItems.Core_MDF_Target_Setting__c = targetSetting.id;
                                                topAccountLineItems.Core_MDF_Spending_Targets_Version__c = versionId;
                                                topAccountLineItems.RecordTypeId = lineItemIPARecTypeId;
                                                lineItemsList.add(topAccountLineItems);
                                            }
                                        }
                                   
                                }
                                // to add All Other Account's records in Target Setting Line Item
                                Core_MDF_Target_Setting_Line_Item__c otherAccountLineItems = new Core_MDF_Target_Setting_Line_Item__c();
                                otherAccountLineItems.Core_MDF_Budget_Type_nm__c = configRecord.Core_MDF_Budget_Type_txt__c;
                                otherAccountLineItems.Core_MDF_Focus_Area_nm__c = configRecord.Core_MDF_Focus_Area_txt__c;
                                otherAccountLineItems.Core_MDF_Region_Name_nm__c = configRecord.Core_MDF_Region_txt__c;
                                otherAccountLineItems.Core_MDF_Amount__c = 0;
                                //otherAccountLineItems.Core_MDF_Target_Setting__c = targetSetting.id;
                                otherAccountLineItems.Core_MDF_Spending_Targets_Version__c = versionId;
                                otherAccountLineItems.Core_MDF_All_Accounts_nm__c = 'Yes';
                                otherAccountLineItems.RecordTypeId = lineItemIPARecTypeId;
                                lineItemsList.add(otherAccountLineItems);
                            }
                        
                    }
                }
                if(!lineItemsList.isEmpty()){
                    insert lineItemsList;
                }
            }
        }
        catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);  
            throw e; 
        } 
    }
    
    /*******************************************************************************************************************************
Method Name :   validateOverlapingTargetSetting
Description :   This method is used to validate overlaping Target Setting Records with existing records and also in case of 
bulk insert/update compares the records which is present in the incoming file 

Called on   :   Before Insert, Before Update
********************************************************************************************************************************/    
    public static void validateOverlapingTargetSetting(List<Core_MDF_Target_Setting__c> newTargetSettingList, Map<Id,Core_MDF_Target_Setting__c> oldTargetSettingMap, Boolean isInsert){
        // flag to bypass overlapping validation
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_BypassTargetStngOvrlapVal')){
            Set<String> programSet = new Set<String>();
            Integer recordIdCount = 1;
            Map<String,Core_MDF_Target_Setting__c> idToTargetSetRecMap = new Map<String,Core_MDF_Target_Setting__c>();
            // Highlight: Unused Local Variable - 14285
            // Set<String> executedRecId = new Set<String>();
            Map<String,Core_MDF_Target_Setting__c> draftTargetSettingMap = new Map<String,Core_MDF_Target_Setting__c>();
            set<String> duplicateRecIdSet = new set<String>();
            Map<String,Core_MDF_Target_Setting__c> subDraftTargetSetMap = new Map<String,Core_MDF_Target_Setting__c>();
            List<Core_MDF_Target_Setting__c> targetSettingList = new List<Core_MDF_Target_Setting__c>();
            
            for(Core_MDF_Target_Setting__c tsRec : newTargetSettingList){
                if(isInsert){
                    String randomNumber = getFakeId( tsRec.getSObjectType(),recordIdCount);
                    tsRec.id = randomNumber;
                    recordIdCount++;
                }
                idToTargetSetRecMap.put(tsRec.id,tsRec);
                programSet.add(tsRec.Core_MDF_Program_Name__c);
            }
            
            List<Core_MDF_Target_Setting__c> existingTargetSettingList = [SELECT id, Core_MDF_Start_Date__c, Core_MDF_End_Date__c, Core_MDF_Program_Name__c 
                                                                          FROM Core_MDF_Target_Setting__c 
                                                                          WHERE Core_MDF_Program_Name__c IN :programSet
                                                                          LIMIT 50000];
            
            
            // Flatten nested IF: use guard clause + continue to avoid else nesting - //US - TWC702-14285
             if(existingTargetSettingList == null || existingTargetSettingList.isEmpty()){
                targetSettingList = idToTargetSetRecMap.Values();
                
            }else{
                
				for(Core_MDF_Target_Setting__c newRec : idToTargetSetRecMap.Values()){
                    for(Core_MDF_Target_Setting__c existingRec: existingTargetSettingList){
                        // Flatten nested IF: use guard clause + continue to avoid else nesting - //US - TWC702-14285
                        if(validateOverlapingRecs(newRec,existingRec)){
                            newRec.addError(Label.Core_MDF_Target_Setting_Overlap_Error);
                            continue; //US - TWC702-14285
                        }
                            targetSettingList.add(newRec);
                        
                    }
                }
            }
            
            
            
            //US - TWC702-14285 - Begin 
            if(targetSettingList != null && !targetSettingList.isEmpty()){ 
                    for(Core_MDF_Target_Setting__c newRec : targetSettingList){
                        if(draftTargetSettingMap.isEmpty()){
                            draftTargetSettingMap.put(newRec.Id,newRec);
                        }
                        if(!subDraftTargetSetMap.isEmpty()){
                            for(string recId: subDraftTargetSetMap.keySet()){
                                if(!draftTargetSettingMap.containsKey(recId)){
                                    draftTargetSettingMap.put(recId,subDraftTargetSetMap.get(recId));
                                }
                            }
                        }

                        if(draftTargetSettingMap.containsKey(newRec.Id)){
                            continue;
                        }

                        for(Core_MDF_Target_Setting__c draftRec: draftTargetSettingMap.Values()){
                            if(duplicateRecIdSet.contains(newRec.Id)){
                                continue;
                            }

                            if(validateOverlapingRecs(newRec,draftRec)){
                                duplicateRecIdSet.add(newRec.Id);
                                if(subDraftTargetSetMap.containsKey(newRec.Id)){
                                    subDraftTargetSetMap.remove(newRec.Id);
                                }
                                newRec.addError(Label.Core_MDF_Target_Setting_Overlap_Error);
                                continue;
                            }
                            subDraftTargetSetMap.put(newRec.Id,newRec);
                        }
                    }
            } 
            //US - TWC702-14285 - End


            for(Core_MDF_Target_Setting__c targetSettingRecord : newTargetSettingList){
                if(isInsert){
                    targetSettingRecord.id = null;
                }
            }
            
        }
    }
    
    
/*******************************************************************************************************************************
Method Name :   validateOvrlapingTgtSetngOnUpdate
Description :   This method is used to validate overlaping Target Setting Records with existing records and also in case of 
bulk insert/update compares the records which is present in the incoming file
Called on   :   Before Update
********************************************************************************************************************************/    
    public static void validateOvrlapingTgtSetngOnUpdate(List<Core_MDF_Target_Setting__c> newTargetSettingList, Map<Id,Core_MDF_Target_Setting__c> oldTargetSettingMap, Boolean isInsert){
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_BypassTargetStngOvrlapVal')){
            List<Core_MDF_Target_Setting__c> targetSettingDupChkList = new List<Core_MDF_Target_Setting__c>();
            
            try{
                for(Core_MDF_Target_Setting__c newTargetSettingRecord : newTargetSettingList){
                    // if start date and end date is changed then add the records to a list and check for overlapping validation 
                    if(newTargetSettingRecord.Core_MDF_Start_Date__c != oldTargetSettingMap.get(newTargetSettingRecord.Id).Core_MDF_Start_Date__c
                       || newTargetSettingRecord.Core_MDF_End_Date__c != oldTargetSettingMap.get(newTargetSettingRecord.Id).Core_MDF_End_Date__c){
                           targetSettingDupChkList.add(newTargetSettingRecord);
                       }
                }
                if(!targetSettingDupChkList.isEmpty()){
                    validateOverlapingTargetSetting(targetSettingDupChkList,null,false);
                }
            }
            catch(Exception e) {
                Core_MDF_CCP_UtilityClass.logError(e);  
                throw e; 
            }
        }
    }
    
    /*******************************************************************************************************************************
Method Name :   populateBackendFields
Description :   This method is used to populate the backend fields

Called on   :   Before Insert
********************************************************************************************************************************/    
    public static void populateBackendFields(List<Core_MDF_Target_Setting__c> newTargetSettingList, Map<Id,Core_MDF_Target_Setting__c> oldTargetSettingMap, Boolean isInsert){
        
        reportAndDashboardFldUpdate(newTargetSettingList,oldTargetSettingMap,isInsert);
        
    }
    
    /*******************************************************************************************************************************
Method Name :   getFakeId
Description :   This method is used to generate fake ids for records                
Called on   :   Before Insert
********************************************************************************************************************************/    
    public static String getFakeId(Schema.SObjectType sot, Integer s_num){
        String result = String.valueOf(s_num++);
        return  pfrPrefixKey + '0'.repeat(12-result.length()) + result;
    }
    
    /*******************************************************************************************************************************
Method Name :   validateOverlapingRecs
Description :   This method contains the logic to validate overlaping Target Setting Records

Called on   :   Before Insert, Before Update
********************************************************************************************************************************/    
    public static Boolean validateOverlapingRecs(Core_MDF_Target_Setting__c newTargetSettingRecord, Core_MDF_Target_Setting__c existingTargetSettingRecord){
        Boolean isError = false;
        if(newTargetSettingRecord.Core_MDF_Program_Name__c == existingTargetSettingRecord.Core_MDF_Program_Name__c
           && existingTargetSettingRecord.Id != newTargetSettingRecord.Id
           && ((newTargetSettingRecord.Core_MDF_Start_Date__c == existingTargetSettingRecord.Core_MDF_Start_Date__c && newTargetSettingRecord.Core_MDF_End_Date__c == existingTargetSettingRecord.Core_MDF_End_Date__c) 
               || newTargetSettingRecord.Core_MDF_Start_Date__c == existingTargetSettingRecord.Core_MDF_End_Date__c || newTargetSettingRecord.Core_MDF_End_Date__c == existingTargetSettingRecord.Core_MDF_Start_Date__c 
               || (newTargetSettingRecord.Core_MDF_Start_Date__c > existingTargetSettingRecord.Core_MDF_Start_Date__c && newTargetSettingRecord.Core_MDF_End_Date__c < existingTargetSettingRecord.Core_MDF_End_Date__c)
               || (newTargetSettingRecord.Core_MDF_Start_Date__c > existingTargetSettingRecord.Core_MDF_Start_Date__c && newTargetSettingRecord.Core_MDF_Start_Date__c < existingTargetSettingRecord.Core_MDF_End_Date__c 
                   && newTargetSettingRecord.Core_MDF_End_Date__c > existingTargetSettingRecord.Core_MDF_End_Date__c)
               || (newTargetSettingRecord.Core_MDF_Start_Date__c == existingTargetSettingRecord.Core_MDF_Start_Date__c && ((newTargetSettingRecord.Core_MDF_End_Date__c > existingTargetSettingRecord.Core_MDF_Start_Date__c 
                                                                                                                            && newTargetSettingRecord.Core_MDF_End_Date__c < existingTargetSettingRecord.Core_MDF_End_Date__c) 
                                                                                                                           || newTargetSettingRecord.Core_MDF_End_Date__c > existingTargetSettingRecord.Core_MDF_End_Date__c))
               || (newTargetSettingRecord.Core_MDF_End_Date__c == existingTargetSettingRecord.Core_MDF_End_Date__c && ((newTargetSettingRecord.Core_MDF_Start_Date__c > existingTargetSettingRecord.Core_MDF_Start_Date__c 
                                                                                                                        && newTargetSettingRecord.Core_MDF_Start_Date__c < existingTargetSettingRecord.Core_MDF_End_Date__c) 
                                                                                                                       || newTargetSettingRecord.Core_MDF_Start_Date__c < existingTargetSettingRecord.Core_MDF_Start_Date__c))
               || (newTargetSettingRecord.Core_MDF_Start_Date__c < existingTargetSettingRecord.Core_MDF_Start_Date__c && ((newTargetSettingRecord.Core_MDF_End_Date__c > existingTargetSettingRecord.Core_MDF_Start_Date__c 
                                                                                                                           && newTargetSettingRecord.Core_MDF_End_Date__c < existingTargetSettingRecord.Core_MDF_End_Date__c) 
                                                                                                                          || newTargetSettingRecord.Core_MDF_End_Date__c > existingTargetSettingRecord.Core_MDF_End_Date__c)))){
                                                                                                                              isError = true;
                                                                                                                          }
        return isError;
    }
    
    /*******************************************************************************************************************************
Method Name :   reportAndDashboardFldUpdate
Description :   This method is used to populate the backend fields for Report Id and Dashboard Id

Called on   :   Before Insert
********************************************************************************************************************************/    
    public static void reportAndDashboardFldUpdate(List<Core_MDF_Target_Setting__c> newTargetSettingList, Map<Id,Core_MDF_Target_Setting__c> oldTargetSettingMap, Boolean isInsert){
        string dashBoardId = '';
        String listViewRecordId = '';
        String targetSettingReportJSON = '';
        List<String> targetSettingDashboard = new  List<String>();
        List<String> lineItemListView = new List<String>();

        Map<string,string> fieldNameToReportNameMap = new Map<string,string>();
        Map<string,string> reportNameToIdMap = new Map<string,string>();
        Set<String> programIdSet = new Set<String>();
        Map<String,String> idToProgramMap = new Map<String,String>();
        // Highlight: Unused Local Variable - 14285
        // Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('Core_MDF_Target_Setting__c').getDescribe().Fields.getMap();
        try{

            for(Core_MDF_Target_Setting__c targetSettingRecord : newTargetSettingList){
                programIdSet.add(targetSettingRecord.Core_MDF_Program_Name__c);
            }

            for (ChannelProgram cp : [SELECT Id, Name                               
                                      FROM ChannelProgram                               
                                      WHERE Id IN: programIdSet]){                               
                                          idToProgramMap.put(cp.Id,cp.Name);                             
                                      }

            for(Core_MDF_Target_Setting__c targetSettingRec : newTargetSettingList){
            
                if(idToProgramMap!= null && idToProgramMap.get(targetSettingRec.Core_MDF_Program_Name__c) == Core_MDF_CCP_ConstantClass.IPA_PROGRAM){
                    targetSettingReportJSON = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Target_Setting_Reports');
                    targetSettingDashboard = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Target_Setting_Dashboards').split(';');
                } 
                else if(idToProgramMap!= null && idToProgramMap.get(targetSettingRec.Core_MDF_Program_Name__c) == Core_MDF_CCP_ConstantClass.CCF_PROGRAM){
                    targetSettingReportJSON = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Target_Setting_CCF_Reports');
                    targetSettingDashboard = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Target_Setting_CCF_Dashboards').split(';');
                    lineItemListView = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_TrgtSetngLineItemCCFListViews').split(';');
                }
                else if(idToProgramMap!= null && idToProgramMap.get(targetSettingRec.Core_MDF_Program_Name__c) == Core_MDF_CCP_ConstantClass.DCF_PROGRAM){
                    targetSettingReportJSON = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Target_Setting_DCF_Reports');
                    targetSettingDashboard = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Target_Setting_DCF_Dashboards').split(';');
                    lineItemListView = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_TrgtSetngLineItemDCFListViews').split(';');
                }                              
            }
            List<fieldWrapper> fieldWrapperList = (List<fieldWrapper>) JSON.deserialize(targetSettingReportJSON,List<fieldWrapper>.class); 
            
            for(fieldWrapper wrap: fieldWrapperList){
                fieldNameToReportNameMap.put(wrap.fieldName,wrap.reportName);
            }
            
            
            if(!fieldNameToReportNameMap.isEmpty()){
                for(Report report : [SELECT Id, Name, DeveloperName 
                                     FROM Report
                                     WHERE DeveloperName IN :fieldNameToReportNameMap.Values()]){
                                         reportNameToIdMap.put(report.DeveloperName,report.Id);
                                     }
            }

            if(!targetSettingDashboard.isEmpty()){
                for (Dashboard rec: [SELECT id, Title, DeveloperName 
                                    FROM Dashboard
                                    WHERE Title IN :targetSettingDashboard LIMIT 1]){
                                        dashBoardId = rec.Id;
                                    }
            }

            if(!lineItemListView.isEmpty()){
                for(ListView listViewRec : [SELECT SobjectType,Id, DeveloperName 
                                            FROM ListView 
                                            WHERE SobjectType = 'Core_MDF_Target_Setting_Line_Item__c' and DeveloperName IN : lineItemListView]){
                                                listViewRecordId = listViewRec.Id;
                                            }
            }                     
            
            for(Core_MDF_Target_Setting__c targetSettingRec : newTargetSettingList){
                
                
                for(String fieldAPIName : fieldNameToReportNameMap.keySet()){
                    String reportId = (fieldNameToReportNameMap.containsKey(fieldAPIName) && 
                                       reportNameToIdMap.containsKey(fieldNameToReportNameMap.get(fieldAPIName))) ?  
                        reportNameToIdMap.get(fieldNameToReportNameMap.get(fieldAPIName)) : '';
                    
                    targetSettingRec.put(fieldAPIName,reportId);                
                }
                
                targetSettingRec.Core_MDF_Target_Setting_Dashboard_Id__c = dashBoardId;
                targetSettingRec.Core_MDF_List_View_Id__c = listViewRecordId;
            }
        }
        catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);  
            throw e; 
        }
    }     
    
    public static void createSpendingTargetsVersion(List<Core_MDF_Target_Setting__c> targetSettingList, Map<Id,Core_MDF_Target_Setting__c> oldTargetSettingMap, Boolean isInsert){
        Core_MDF_Spending_Targets_Version__c version = new 	Core_MDF_Spending_Targets_Version__c();
        Integer VersionNumber = 1;
        for(Core_MDF_Target_Setting__c targetSettingRecord : targetSettingList){
            version.Core_MDF_Spending_Targets__c = targetSettingRecord.Id;
            version.Core_MDF_Version_nbr__c = VersionNumber;
            version.Core_MDF_Is_Active_Ind__c = TRUE;
        }
        insert version;

        versionId = version.Id;
    }
    
    Public class fieldWrapper{
        public string fieldName;
        public string reportName;
    }
}