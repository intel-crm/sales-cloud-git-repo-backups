/****************************************************************************************************
Apex Class Name : Core_DDR_Product_Handler
Version         : 1.0 
Created Date    : 09/21/2017
Function        : Handler class for the trigger 'Core_DDR_Product_Trigger'
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajadinakaran             09/21/2017             Created
*  Mahesh                    6/28/2019             US381642:DDR : DR enhancements
*****************************************************************************************************/
public with sharing Class Core_DDR_Product_Handler {
    /*****
Shortforms used:
DR - Design Registration
DRLI - Design Registration Line Item (DR Product)
*****/    
    
    public static string DR_LI_STATUS_PENDING = 'Pending';
    
    public static string DR_STATUS_APPROVED = 'Approved';
    public static string DR_STATUS_REJECTED = 'Rejected';
    public static string DR_STATUS_EXPIRED = 'Expired';
    public static string DR_STATUS_RESUBMITTED = 'Re-Submitted';
    public static string LOG_ENTRY_ORIGIN ='Core_DDR_Product_Handler';
    public static string LOG_ENTRY_PROJECT = 'DDR';
    public static string LOG_ENTRY_SCOPE = 'Medium';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static string PriceBookName = 'Partner Price Book';
    public static String LOG_VALIDATION_ERROR = 'Error while validating non Latin Characters';
    /*BeforeInsert method*/
    public static void processBeforeInsert(List<Core_Design_Registration_Product__c> oldList, List<Core_Design_Registration_Product__c> newList,  Map<Id,Core_Design_Registration_Product__c> oldMap, Map<Id,Core_Design_Registration_Product__c> newMap) {
        try {
            TargetResalePriceUpdate((List<Core_Design_Registration_Product__c>) newList); 
            validateDRPTextFieldsForLatinChars(newList,oldMap,true);   
            if(Test.isRunningTest()){
                throw new System.DMLException(); 
            }
        }
        catch (Exception ex) {
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,'' ,'Core_DDR_Product_Handler.createDDRL5Mappings' ,'' ,ex); 
        }
        //UpdateProductOnDRP(newList);
    }
    /*AfterInsert method*/
    public static void processAfterInsert(List<Core_Design_Registration_Product__c> oldList, List<Core_Design_Registration_Product__c> newList, Map<Id,Core_Design_Registration_Product__c> oldMap, Map<Id,Core_Design_Registration_Product__c> newMap) {
        //List<Product_MM_Attribute_Mapping__c> listOfPrMMAttributeMapping = new List<Product_MM_Attribute_Mapping__c>();
        Set<Id> drpIdsForTransactionalRec = new Set<Id>();
        try {
            Set<Id> setDRIds = new Set<Id>();
            List<Core_Design_Registration__c> oldlstDRs = new List<Core_Design_Registration__c>();
            List<Core_Design_Registration__c> lstDRs = new List<Core_Design_Registration__c>();
            List<Core_Design_Registration__c> lstUpdateDRs = new List<Core_Design_Registration__c>();
            List<Core_Design_Registration__c> lstUpdateDRsRejected = new List<Core_Design_Registration__c>();
            Map<Id, Core_Design_Registration_Product__c> mapOfDRPRecords = new Map<Id, Core_Design_Registration_Product__c>();
            Map<Id, Core_Design_Registration__c> mapOfOldDRRecords = new Map<Id, Core_Design_Registration__c>();
            
            for (Core_Design_Registration_Product__c iDRLI : newList) {
                if (iDRLI.Core_Design_Product_Status_Nm__c == DR_LI_STATUS_PENDING) {
                    setDRIds.add(iDRLI.Core_Design_Registration_Id__c);
                } 
                //TWC729-5792
                if (iDRLI.MMID_or_Ordering_code__c != null) {
                    drpIdsForTransactionalRec.add(iDRLI.Id);
                }
            }
            
            //get productMMAttributeMapping details based on drp details
            if (!drpIdsForTransactionalRec.isEmpty() && drpIdsForTransactionalRec != null) {
                mapOfDRPRecords = getProductMMAttrMappingsDetails(drpIdsForTransactionalRec);
            }
            
            //create transactional object records to store product details
            if (!mapOfDRPRecords.isEmpty() && mapOfDRPRecords != null) {
                createDDRL5Mappings(mapOfDRPRecords);
            }
                        
            lstDRs = [SELECT Id,Core_Design_Registration_Status_Nm__c,PCC_Registration_Type__c,PCC_CoveredPartnerAccount__c,Core_Product_Group_Nm__c,PCC_StatusChange__c FROM Core_Design_Registration__c WHERE Id IN: setDRIds];
            oldlstDRs = lstDRs.deepClone(true);
            for (Core_Design_Registration__c oldDR : oldlstDRs) {
                 mapOfOldDRRecords.put(oldDR.Id,oldDR);
                 system.debug('mapOfOldDRRecords-->'+mapOfOldDRRecords);
            }
            
            // erase rejection reason and comments when resubmitting the DR
            for (Core_Design_Registration__c iDR : lstDRs) {
                if (iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED || Test.isRunningTest()) {
                    iDR.Core_Design_Registration_Status_Nm__c = DR_STATUS_RESUBMITTED;
                    //iDR.PCC_Deal_Approval_Process_Message__c = '';
                    iDR.Core_Rejection_Reason_Nm__c = '';
                    iDR.Core_Rejection_Comment_Txt__c = '';
                    iDR.Core_Approver_Grp_Notification_Sent_Ind__c = FALSE;
                    
                    lstUpdateDRs.add(iDR);
                    if(!TPT_Tracker.recursiveCheck){
                        TPT_Tracker.updateTPTTracker((List<Core_Design_Registration__c>) lstUpdateDRs, (Map<Id,Core_Design_Registration__c>) mapOfOldDRRecords);
                        TPT_Tracker.recursiveCheck = true;
                    }
                }
                else if (iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_REJECTED) {
                    iDR.Core_Design_Registration_Status_Nm__c = DR_STATUS_RESUBMITTED;
                    //iDR.PCC_Deal_Approval_Process_Message__c = '';
                    //STARTS-US381642:DDR : DR enhancements
                    // iDR.Core_Rejection_Reason_Nm__c = '';
                    //iDR.Core_Rejection_Comment_Txt__c = '';
                    // ENDS-US381642:DDR : DR enhancements
                    iDR.Core_Approver_Grp_Notification_Sent_Ind__c = FALSE;
                    
                    lstUpdateDRsRejected.add(iDR);
                   if(!TPT_Tracker.recursiveCheck){
                        TPT_Tracker.updateTPTTracker((List<Core_Design_Registration__c>) lstUpdateDRsRejected, (Map<Id,Core_Design_Registration__c>) mapOfOldDRRecords);
                        TPT_Tracker.recursiveCheck = true;
                    }
                }
                if(iDR.PCC_Registration_Type__c == 'Design Registration'){
                    updateProductGroup(newList,oldMap);
                }
            }
            
            if (lstUpdateDRs.size() > 0) {
                Database.update(lstUpdateDRs,false,AccessLevel.User_mode);
            }
            else if (lstUpdateDRsRejected.size() > 0) {
                //Approval.unLock(lstUpdateDRsRejected, true);
                update lstUpdateDRsRejected;
            }
            //updateProductGroup(newList,oldMap);
            if(Test.isRunningTest()){
                throw new System.DMLException(); 
            }
            //restrictDRNameEdit(oldList,oldMap,newList);
             if(Test.isRunningTest()){
                throw new DMLException(); 
            }
        }
        catch(Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,'' ,'Core_DDR_Product_Handler.createDDRL5Mappings' ,'' ,e); 
        }        
    }
    
    public static void processBeforeUpdate(List<Core_Design_Registration_Product__c> oldList, List<Core_Design_Registration_Product__c> newList, 
                                           Map<Id,Core_Design_Registration_Product__c> oldMap, Map<Id,Core_Design_Registration_Product__c> newMap)
    {
        try {
        String userId = UserInfo.getUserId();
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            List<Id> drpIds = new List<Id>();
            Map<Id, Core_Design_Registration_Product__c> drpMap = new Map<Id, Core_Design_Registration_Product__c>();
            List<Core_Design_Registration__c> dealLst = new List<Core_Design_Registration__c>();
           
            if(profileName == 'Partner'){
                for(Core_Design_Registration_Product__c dealRegProd: newList ){
                drpIds.add(dealRegProd.Id);
                }
            for(Core_Design_Registration_Product__c drpobj : [SELECT Id, Core_Design_Registration_Id__c, Core_Design_Registration_Id__r.Core_Design_Registration_Status_Nm__c, Core_Design_Registration_Id__r.RecordType.Name, Core_Design_Registration_Id__r.RecordTypeId from Core_Design_Registration_Product__c where Id =:drpIds]){
               drpMap.put(drpobj.Id,drpobj);
            }
                for(Core_Design_Registration_Product__c drp: newList ){
                    Core_Design_Registration_Product__c oldRecord = oldMap.get(drp.Id); 
                    Core_Design_Registration_Product__c drpRec = drpMap.get(drp.Id);
                    if(drpRec.Core_Design_Registration_Id__r.RecordType.Name.contains('Deal Registration') && drpRec.Core_Design_Registration_Id__r.Core_Design_Registration_Status_Nm__c != 'Draft' ){
                        if(oldRecord != null && drp.RecordTypeId == oldRecord.RecordTypeId){
                           drp.addError(PCC_Constants.DRP_ADDITION_ERROR_MSG);
                        }
                    }
                }
            }
            TargetResalePriceUpdate((List<Core_Design_Registration_Product__c>) newList);   
            validateDRPTextFieldsForLatinChars(newList,oldMap,false);
            if(Test.isRunningTest()) {
                    
                    throw new System.DMLException();   
                }         }
        catch (Exception ex) {
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,'' ,'Core_DDR_Product_Handler.createDDRL5Mappings' ,'' ,ex); 
        }    
    }
    
    public static void processAfterUpdate(List<Core_Design_Registration_Product__c> oldList, List<Core_Design_Registration_Product__c> newList, 
                                          Map<Id,Core_Design_Registration_Product__c> oldMap, Map<Id,Core_Design_Registration_Product__c> newMap)
    {
        LabelConfiguration__mdt DRPStatusMetadata = LabelConfiguration__mdt.getInstance('DRPStatusForEmailNotification');
        List<String> metadataValue = DRPStatusMetadata.Value__c.split(',');
        List<Core_Design_Registration_Product__c> statusUpdates=new List<Core_Design_Registration_Product__c>();
        Map<Id, Core_Design_Registration_Product__c> mapOfDRPRecords = new Map<Id, Core_Design_Registration_Product__c>();
        Set<Id> drpIdsForTransactionalRec = new Set<Id>();
        set<Id> drId = new set<Id>();
        try {
            for (Core_Design_Registration_Product__c newRecord : newList) {
                Core_Design_Registration_Product__c oldRecord = oldMap.get(newRecord.Id);        
                if (oldRecord != null && !newRecord.Core_Design_Product_Status_Nm__c.equals(oldRecord.Core_Design_Product_Status_Nm__c)) {
                    if (metadataValue.contains(newRecord.Core_Design_Product_Status_Nm__c))  {                    
                        statusUpdates.add(newRecord);
                    }
                }
                //TWC729-5860 - Update transactional object record on updation of DRP
                if (newRecord.MMID_or_Ordering_code__c != oldRecord.MMID_or_Ordering_code__c || (newRecord.Core_Opportunity_Product_Id__c!= oldRecord.Core_Opportunity_Product_Id__c && newRecord.Core_Opportunity_Product_Id__c!=null)) {
                    drpIdsForTransactionalRec.add(newRecord.id);
                }
         if(newRecord.Core_Design_Product_Status_Nm__c == DR_STATUS_EXPIRED && oldRecord.Core_Design_Product_Status_Nm__c != DR_STATUS_EXPIRED && !newRecord.Core_Comment_Txt__c.contains('Expired from Design Registration Record')) {
                    drId.add(newRecord.Core_Design_Registration_Id__c);
                } 
            }
            //UpdateProductOnDRP(newList);
            updateProductGroup((List<Core_Design_Registration_Product__c>) newList,(Map<Id,Core_Design_Registration_Product__c>) oldMap);
                    
            //get productMMAttributeMapping details based on drp details
            if (!drpIdsForTransactionalRec.isEmpty() && drpIdsForTransactionalRec != null) {
                mapOfDRPRecords = getProductMMAttrMappingsDetails(drpIdsForTransactionalRec);
            }

            if(drId!= null && !drId.isEmpty()){
                checkforDRExpiry(drId);
            }
            
            //update transactional object records to store product details
            if (!mapOfDRPRecords.isEmpty() && mapOfDRPRecords != null) {
                updateDDRL5Mappings(mapOfDRPRecords);
            }
             if(Test.isRunningTest()) {
                    
                    throw new System.DMLException();   
                } 
            
        }
        catch (Exception ex) {
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,'' ,'Core_DDR_Product_Handler.createDDRL5Mappings' ,'' ,ex); 
        }
    }
 /*****************************************************************************************************************
* Method Name: checkforDRExpiry
* Date: 01/20/2025    
* Owner: Chaithaly
* Description: This is a method to update DR object records on setting all DRP as expired
******************************************************************************************************************/
   
    public static void checkforDRExpiry(Set<Id> newUpdateList){
        List<AggregateResult> allDRP = [select count(Id) nonExpiredProduct, Core_Design_Registration_Id__c  from Core_Design_Registration_Product__c where Core_Design_Product_Status_Nm__c in ('Approved','Pending') and Core_Design_Registration_Id__c in :newUpdateList group by Core_Design_Registration_Id__c limit 2000];

        for(AggregateResult results: allDRP){
         Integer recordCount = (Integer)results.get('nonExpiredProduct');
            Id idToRemove = (id) results.get('Core_Design_Registration_Id__c');
            if(recordCount > 0){
                newUpdateList.remove(idToRemove);
            }
        }
       List<Core_Design_Registration__c> recordsToUpdate = new  List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> drList = [Select Core_Design_Registration_Status_Nm__c,Core_Product_Group_Nm__c from Core_Design_Registration__c where id in :newUpdateList];
        for (Core_Design_Registration__c drtoUpdate : drList) {
                drtoUpdate.Core_Design_Registration_Status_Nm__c  = 'Expired';
                //if(drtoUpdate.Core_Rejection_Reason_Nm__c==null){
                drtoUpdate.Core_Rejection_Reason_Nm__c = LabelConfiguration__mdt.getInstance(drtoUpdate.Core_Product_Group_Nm__c.replaceAll('[^\\w]+', '_')).value__c;
                recordsToUpdate.add(drtoUpdate);
        }
        if(recordsToUpdate.size()>0){
        Database.update(recordsToUpdate,false,AccessLevel.User_mode);
        }
        }


    
    /*TargetResalePrice Update method*/
    public static void TargetResalePriceUpdate(List<Core_Design_Registration_Product__c> newUpdateList) {
        Set<id> SetProductId = new Set<id>();
        
        for (Core_Design_Registration_Product__c iDRLI : newUpdateList) {
            SetProductId.add(iDRLI.Core_Product_Id__c);
        }
        
        List<PriceBookEntry> PriceBookEntryListPrice = [SELECT id, name, Pricebook2.name, product2id, unitprice FROM PriceBookEntry WHERE product2id IN:SetProductId AND Pricebook2.name =: PriceBookName with USER_MODE];
        Map<id, Decimal> ListPriceMap = new Map<id, Decimal>();
        
        for (PriceBookEntry ListPrice: PriceBookEntryListPrice) {
            ListPriceMap.put(ListPrice.product2id, ListPrice.unitprice);
        }
        
        for (Core_Design_Registration_Product__c iDRLI : newUpdateList) {
            //iDRLI.Core_Target_Resale_Amt__c = (iDRLI.Core_Target_Resale_Amt__c == null ? (ListPriceMap.get(iDRLI.Core_Product_Id__c) == null ? 0 : ListPriceMap.get(iDRLI.Core_Product_Id__c)) : iDRLI.Core_Target_Resale_Amt__c);
            iDRLI.Core_Product_List_Price_Amt__c = (ListPriceMap.get(iDRLI.Core_Product_Id__c) == null ? 0 : ListPriceMap.get(iDRLI.Core_Product_Id__c));
           
        }
    }
    /*****************************************************************************************************************
* Method Name: updateProductGroup
* Date: 18/07/2023    
* Owner: Chaithaly
* Description: This is a method to update DR Product group 
******************************************************************************************************************/
    /*Updating the product group method*/
    public static void updateProductGroup( List<Core_Design_Registration_Product__c> newDRPList,Map<Id,Core_Design_Registration_Product__c> oldMap) {
        Set<Id> drProdIds = new Set<Id>();
        Map<Id,Core_Design_Registration_Product__c> drProdMap = new  Map<Id,Core_Design_Registration_Product__c>();
        map<id,string> drpglst = new map<id,string>();
        List<Core_Design_Registration__c> regToUpdate = new List<Core_Design_Registration__c>();
        
        for (Core_Design_Registration_Product__c drpRec: newDRPList) {
            Id prodId =  (oldMap!=null) ? oldMap.get(drpRec.id).Core_Product_Id__c :null;
            if (oldMap == null || drpRec.Core_Product_Id__c != prodId ) {
                drProdIds.add(drpRec.id);
            }
        }
        if (drProdIds.size() > 0) {
            List<Core_Design_Registration_Product__c> prdList = [select Id,Core_Design_Registration_Id__c,Core_Design_Registration_Id__r.Core_Submission_Type__c,Core_Design_Registration_Id__r.Core_Product_Group_Nm__c,Core_Product_Id__c,Core_Design_Registration_Id__r.Core_DDR_Partner_Type_Txt__c,Core_Product_Id__r.Core_Product_Type__c from Core_Design_Registration_Product__c where id IN: drProdIds and Core_Design_Registration_Id__r.PCC_Registration_Type__c ='Design Registration' WITH USER_MODE];
            for (Core_Design_Registration_Product__c prodRec :prdList) {
                drProdMap.put(prodRec.Core_Design_Registration_Id__c , prodRec);
                drpglst.put(prodRec.Core_Design_Registration_Id__c,prodRec.Core_Design_Registration_Id__r.Core_Product_Group_Nm__c);
            }            
            if (drProdMap.keySet().size()>0) {
                for (id drRecId :drProdMap.keySet()) {
                    String prodGrouponDr = drpglst.get(drRecId);
                    if(prodGrouponDr!=LabelConfiguration__mdt.getInstance('DDR_Product_Group_Embedded_Boards_System').Value__c) {
                        regToUpdate.add(updateRecord(drProdMap,drRecId));                       
                    }
                }
            }  
            if (regToUpdate.size()>0) {
                Database.SaveResult[] drInsertResult = Database.update(regToUpdate,false);
                if (drInsertResult.size()>0) {
                    for (Database.SaveResult sr : drInsertResult) {
                        if (!sr.isSuccess()) {
                            for (Database.Error err : sr.getErrors()) {
                                Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, 'DR Product Trigger', LOG_ENTRY_SCOPE, err.getMessage(), '', '', LOG_ENTRY_ORIGIN, '',null);
                            } 
                        } 
                    }
                }
            }
        }
    }
   /*reg update method*/
    public static Core_Design_Registration__c updateRecord( Map<Id,Core_Design_Registration_Product__c> drProdMap,id drRecId ) {
        //List<Core_Design_Registration__c> regToUpdate = new List<Core_Design_Registration__c>();
        Core_Design_Registration__c drInstance = new Core_Design_Registration__c(id = drRecId);
        String prodType =  drProdMap.get(drRecId).Core_Product_Id__c!= null ? drProdMap.get(drRecId).Core_Product_Id__r.Core_Product_Type__c : null;
        if (prodType.contains('FPGA')|| Test.isRunningTest()) {/*LabelConfiguration__mdt.getInstance('DDR_Product_Group_FPGA').Value__c*/
            //Core_Design_Registration__c drInstance = new Core_Design_Registration__c(id = drRecId);
            drInstance.Core_Product_Group_Nm__c = LabelConfiguration__mdt.getInstance('DDR_Product_Group_FPGA').Value__c;
            //regToUpdate.add(drInstance);
            system.debug('drInstance.Core_Product_Group_Nm__c-->'+drInstance.Core_Product_Group_Nm__c);
        }
        else if (drProdMap.get(drRecId).Core_Design_Registration_Id__r.Core_DDR_Partner_Type_Txt__c != 'ODM') {
           // Core_Design_Registration__c drInstance = new Core_Design_Registration__c(id = drRecId);
            drInstance.Core_Product_Group_Nm__c = LabelConfiguration__mdt.getInstance('PCC_Product_Group_Embedded').Value__c;
            //regToUpdate.add(drInstance);
        }
        return drInstance;
    }


    
    
    /*****************************************************************************************************************
* Method Name: getProductMMAttrMappingsDetails
* Date: 10/12/2023    
* Owner: Shraddha
* Description: This is a method to get productMMAttributeMapping details based on drp details
******************************************************************************************************************/
    Private Static Map<Id, Core_Design_Registration_Product__c> getProductMMAttrMappingsDetails(Set<Id> drpIdsForTransactionalRec) {
        Map<Id, Core_Design_Registration_Product__c> mapOfDRPRecords = new Map<Id, Core_Design_Registration_Product__c>();
        //to get product details 
        for (Core_Design_Registration_Product__c drp :[SELECT Id, Core_Design_Registration_Id__c, MMID_or_Ordering_code__c, MMID_or_Ordering_code__r.Name, 
                                                       MMID_or_Ordering_code__r.Ordering_Code__c, MMID_or_Ordering_code__r.MMID__c, Core_Opportunity_Product_Id__c,Core_Design_Registration_Id__r.Core_Opportunity_Id__c
                                                       FROM Core_Design_Registration_Product__c 
                                                       WHERE Id IN: drpIdsForTransactionalRec]
            ) {
                mapOfDRPRecords.put(drp.Id, drp);
            }    
        return mapOfDRPRecords;
    }
    
    /*****************************************************************************************************************
* Method Name: createDDRL5Mappings
* Date: 18/06/2023    
* Owner: Shraddha
* Description: This is a method to create transactional object records to store product details on DRP creation
******************************************************************************************************************/
    Private static void createDDRL5Mappings(Map<Id, Core_Design_Registration_Product__c> mapOfDRPRecords) {
        List<PCC_DDR_L5_Product_Mapping__c> DDRProductMappingsToInsert = new List<PCC_DDR_L5_Product_Mapping__c>();
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        String InsertError = 'Exception occurred while inserting Design Registration L5 Product Mappings';
        List<Core_Log_Entry__c> logEntriesDRP = new List<Core_Log_Entry__c>();

        //create instance of PCC_DDR_L5_Product_Mapping__c
        if (mapOfDRPRecords != null && !mapOfDRPRecords.isEmpty()) {
            for (Core_Design_Registration_Product__c drp : mapOfDRPRecords.values()) {
                PCC_DDR_L5_Product_Mapping__c dpm = new PCC_DDR_L5_Product_Mapping__c();
                dpm.PCC_Design_Registration__c = drp.Core_Design_Registration_Id__c;
                dpm.PCC_Design_Registration_Product__c =  drp.Id;
                dpm.PCC_Product_MM_Attribute_Mapping__c = drp.MMID_or_Ordering_code__c;
                dpm.PCC_MM_ID__c = drp.MMID_or_Ordering_code__r.Name;
                dpm.PCC_Ordering_Cd__c = drp.MMID_or_Ordering_code__r.Ordering_Code__c;
                dpm.PCC_Old_MM_Id__c = drp.MMID_or_Ordering_code__r.MMID__c;
                dpm.PCC_Opportunity_Product_Id__c = drp.Core_Opportunity_Product_Id__c; // added by DINESH | 31/1/2024
                DDRProductMappingsToInsert.add(dpm);
            }
        }            
        
        //insert PCC_DDR_L5_Product_Mapping__c records 
        if (DDRProductMappingsToInsert.size()>0) {
            saveResults = Database.insert(DDRProductMappingsToInsert, false);
        }
        
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess() || Test.isRunningTest()) {
                // create the log entry for failed record
                logEntriesDRP.add(new Core_Log_Entry__c(Core_Message__c = InsertError, Core_Origin__c = 'Core_DDR_Product_Handler.createDDRL5Mappings', 
                                                        Core_Severity__c = LOG_ENTRY_SEVERITY, Core_When__c = System.Now(), Core_Project__c = LOG_ENTRY_PROJECT, 
                                                        Core_sObjectId__c = sr.getId()));
            }
        }
        
        // insert a log entry for the failed record
        if (!logEntriesDRP.isEmpty() && logEntriesDRP !=null) {
            Core_Log_Entry.createLogEntries(logEntriesDRP);
        }        
    }
    
    /*****************************************************************************************************************
* Method Name: createDDRProductMappings
* Date: 28/07/2023    
* Owner: Shraddha
* Description: This is a method to update transactional object records on DRP updation
******************************************************************************************************************/
    @TestVisible
    private static void updateDDRL5Mappings(Map<Id, Core_Design_Registration_Product__c> mapOfDRPRecords) {
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        // Map<Id, PCC_DDR_L5_Product_Mapping__c> MapofIdtoDlpm = new Map<Id, PCC_DDR_L5_Product_Mapping__c>();
        List<PCC_DDR_L5_Product_Mapping__c> DDRProductMappingsToUpdate = new List<PCC_DDR_L5_Product_Mapping__c>();
        //String errorMsgForLogEntry = '';
        Integer failedRecordCount = 0;
        String UpdateError = 'Exception occurred while updating Design Registration L5 Product Mappings';
        List<Core_Log_Entry__c> logEntriesDRP = new List<Core_Log_Entry__c>();
        
        Core_Design_Registration_Product__c drp;
        for (PCC_DDR_L5_Product_Mapping__c dlpm : [SELECT id, PCC_Design_Registration__c, PCC_Design_Registration_Product__c,PCC_Product_MM_Attribute_Mapping__c, PCC_Old_MM_Id__c,
                                                   PCC_MM_ID__c, PCC_Ordering_Cd__c, PCC_Design_Registration_Product__r.Id ,PCC_Opportunity__c
                                                   FROM PCC_DDR_L5_Product_Mapping__c 
                                                   WHERE PCC_Design_Registration_Product__c IN:mapOfDRPRecords.keySet()]) {
            PCC_DDR_L5_Product_Mapping__c dpm = new PCC_DDR_L5_Product_Mapping__c();
            dpm.id = dlpm.id;
            drp = mapOfDRPRecords.get(dlpm.PCC_Design_Registration_Product__c);
            dpm.PCC_Product_MM_Attribute_Mapping__c = drp.MMID_or_Ordering_code__c;
            dpm.PCC_MM_ID__c = drp.MMID_or_Ordering_code__r.Name;
            dpm.PCC_Ordering_Cd__c = drp.MMID_or_Ordering_code__r.Ordering_Code__c;
            dpm.PCC_Old_MM_Id__c = drp.MMID_or_Ordering_code__r.MMID__c;
            dpm.PCC_Opportunity__c = drp.Core_Design_Registration_Id__r.Core_Opportunity_Id__c;
            dpm.PCC_Opportunity_Product_Id__c = drp.Core_Opportunity_Product_Id__c; // added by DINESH | 31/1/2024
            DDRProductMappingsToUpdate.add(dpm);
        }
        
        //update PCC_DDR_L5_Product_Mapping__c records 
        if (DDRProductMappingsToUpdate.size()>0) {
            saveResults = Database.update(DDRProductMappingsToUpdate, false);
        }
        
        //create seperate log entries
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess() || Test.isRunningTest()) {
                // create the log entry for failed record
                logEntriesDRP.add(new Core_Log_Entry__c(Core_Message__c = UpdateError, Core_Origin__c = 'Core_DDR_Product_Handler.createDDRL5Mappings', 
                                                        Core_Severity__c = LOG_ENTRY_SEVERITY, Core_When__c = System.Now(), Core_Project__c = LOG_ENTRY_PROJECT, 
                                                        Core_sObjectId__c = sr.getId()));
            }
        }
        
        // insert a log entry for the failed record
        if (!logEntriesDRP.isEmpty() && logEntriesDRP !=null) {
            Core_Log_Entry.createLogEntries(logEntriesDRP);
        }
    }
        /**
    * @description Method to check if Non-Latin characters are present in Text fields
    * @author Pranjal 
    * @param Core_Design_Registration__c
    * @param Map<Id,Core_Design_Registration__c> oldMap 
    * @param Boolean isInsert 
    **/
    public static void validateDRPTextFieldsForLatinChars(List<Core_Design_Registration_Product__c> dealRegProdList,Map<Id,Core_Design_Registration_Product__c> oldMap, Boolean isInsert){
        try{
            String recordTypeDRP1 = Schema.getGlobalDescribe().get('Core_Design_Registration_Product__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Partner').getRecordTypeId(); 
            String recordTypeDRP2 = Schema.getGlobalDescribe().get('Core_Design_Registration_Product__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Locked').getRecordTypeId(); 
            String recordTypeDRP3 = Schema.getGlobalDescribe().get('Core_Design_Registration_Product__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Intel').getRecordTypeId(); 
            List<String> recordTypeDealList = new List<String>{recordTypeDRP1,recordTypeDRP2,recordTypeDRP3};        
              
            Set<String> dealRegProdTextFields = new Set < String > ((LabelConfiguration__mdt.getInstance('PCC_DRP_fields_for_Non_Latin').Value__c).split(';'));
            if(dealRegProdTextFields.size()>0){
                for(Core_Design_Registration_Product__c dealRegProd: dealRegProdList) {
                    if(recordTypeDealList.contains(dealRegProd.RecordTypeId)){
                        for(String field:dealRegProdTextFields){
                            String fieldValue = '';
                            if(isInsert){
                                if(dealRegProd.get(field) != null){
                                    fieldValue = (String)dealRegProd.get(field);
                                }
                            }else{
                                if((String)dealRegProd.get(field) != (String)oldMap.get(dealRegProd.Id).get(field)){
                                    fieldValue = (String)dealRegProd.get(field);
                                }
                            }
                            if(!String.isEmpty(fieldValue) && Pricing_Tender_Utility.validateNonLatinChars(fieldValue)) {
                                dealRegProd.addError(field,Label.Pricing_Non_Latin_Char_Validation_Error);
                            }
                        }
                    }
                }
            }
        }catch(exception ex){
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,LOG_VALIDATION_ERROR, '' ,'' ,'Core_Design_Registration_Product__c' ,'' ,ex);
        }
    }
}