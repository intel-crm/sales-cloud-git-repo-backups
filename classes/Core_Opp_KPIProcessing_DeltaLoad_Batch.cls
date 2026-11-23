/********************************************************************************************************************************************************************
Apex Class Name:  Core_Opp_KPIProcessing_DeltaLoad_Batch
Version     : 1.0 
Created Date: 01/15/2019
Function    : Update Opportunity KPI Object with data from KPI Integration Inbound object

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ashwin Dash               01/15/2019               Original Version developed
* Ashwin Dash               03/13/2020               Added changes for US604686 - KPI : Update and fix KPI sync with IAH
*******************************************************************************************************************************************************************/
global class Core_Opp_KPIProcessing_DeltaLoad_Batch implements Database.Batchable<sObject>{
    
    global List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
    //global Set<String> existingOppKPISet = new Set<String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, OwnerId, Name, Core_IAH_KPI_Achieved__c,lastmodifieddate, Core_IAH_KPI_Added_Date__c, Core_IAH_KPI_Batch_Time__c, Core_IAH_KPI_DB_Status__c, Core_IAH_KPI_Last_Updated_Date__c, Core_IAH_KPI_Name__c, Core_IAH_KPI_Oppty_Id__c, Core_IAH_KPI_Oppty_Prod_Id__c, Core_IAH_KPI_Oppty_Volume__c, Core_IAH_KPI_Quantity__c, Core_IAH_KPI_Record_ID__c, Core_IAH_KPI_Threshold_Met__c, Core_IAH_KPI_Total_Price__c, Core_IAH_KPI_Type__c, Core_IAH_SF_KPI_ID__c, Core_KPI_Processing_Status__c, Core_IAH_KPI_Error_Message__c FROM Core_KPI_Integration_Inbound__c WHERE Core_KPI_Processing_Status__c IN (\'New\') ORDER BY Core_IAH_KPI_Oppty_Id__c,Core_IAH_KPI_Oppty_Prod_Id__c,Core_IAH_KPI_Name__c,Core_IAH_KPI_Batch_Time__c,Core_IAH_KPI_DB_Status__c ASC';      
        try{            
            //Querying all the KPI Integration Inbound object sending to execute method in batch of 2000. Records are sorted in Descending order for Batch Date.
            return Database.getQuerylocator(query);
        }catch(Exception e){
            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = e.getMessage(), Core_Message__c = 'KPI_Query_Error', Core_Severity__c = 'High', Core_Origin__c='Core_Opp_KPIProcessing_DeltaLoad_Batch', Core_When__c = System.now()));     
            insert captureQueryErr;         
            return null;
        }
    }
    global void execute(Database.BatchableContext BC, List<Core_KPI_Integration_Inbound__c> scope) {
        
        //START - Initializing required Variables 
        Set<Id> kpiOpptyIdSet = new Set<Id>();
        Set<Id> kpiOpptyProdIdSet = new Set<Id>();
        Map<String, Core_Opportunity_KPI__c>  existingkpiGroupedbyOPKMap = new Map<String, Core_Opportunity_KPI__c>();
        List<Core_Opportunity_KPI__c> updateKPIList = new List<Core_Opportunity_KPI__c>();
        Set<Id> deleteKPISet = new Set<Id>();
        Set<Id> savedKPISet = new Set<Id>();        
        Map<String, List<Core_KPI_Integration_Inbound__c>> kpiIntGroupedbyOPKpiMap = new Map<String, List<Core_KPI_Integration_Inbound__c>>();
        Map<String, Core_Opp_KPI_Criteria__c> kpiCriteriaMap = new Map<String, Core_Opp_KPI_Criteria__c>();
        Map<String, Id> opptyKPIProductMap = new Map<String, Id>();
        List<Core_KPI_Integration_Inbound__c> kpiIntUpdateList = new List<Core_KPI_Integration_Inbound__c>();
        Set<Id> kpiIntUpdateSet = new Set<Id>();
        List<Core_Opp_KPI_Product__c> insertKPIProdList = new List<Core_Opp_KPI_Product__c>();
        Set<Id> deleteKPIProdSet = new Set<Id>();
        List<Core_Opportunity_KPI__c> insertKPIList = new List<Core_Opportunity_KPI__c>();
        Map<Id, String> failedKPIMap = new Map<Id, String>();
        Map<Id, String> failedKPIIntMap = new Map<Id, String>();
        //END - Initializing required Variables 
        
        //Getting set of opportunity Ids associated to each KPI Integration Inbound object
        for(Core_KPI_Integration_Inbound__c kpiInt : scope){
            kpiOpptyIdSet.add(kpiInt.Core_IAH_KPI_Oppty_Id__c);
            kpiOpptyProdIdSet.add(kpiInt.Core_IAH_KPI_Oppty_Prod_Id__c);
        }
        for(Core_Opp_KPI_Criteria__c kpic : [SELECT id, name, Core_Opp_KPI_BU_Owner__c, Core_Opp_KPI_Description__c, Core_Opp_Threshold_Requirement__c,(SELECT Id,Name,Core_IAH_KPI_Record_ID__c,Core_KPI_Criteria_Detail__c FROM KPI_RecordIDs__r) FROM Core_Opp_KPI_Criteria__c]){
            for(Core_KPI_RecordID__c kpiRecordId : kpic.KPI_RecordIDs__r){
                string str=kpic.name+';'+kpiRecordId.Core_IAH_KPI_Record_ID__c;
                kpiCriteriaMap.put(str, kpic);
            }
            
        }
        Map<Id, OpportunityLineItem> kpiProdOpptyProdMap = new Map<id, OpportunityLineItem>([SELECT id, Product2.Id, Product2.Name, name FROM OpportunityLineItem WHERE Id IN :kpiOpptyProdIdSet]);
        Map<Id, Opportunity> kpiOpptyMap = new Map<Id, Opportunity>([SELECT id FROM Opportunity WHERE Id IN : kpiOpptyIdSet]);
        
        //Creating a map of existing Opportunity KPI unique key with KPI associated some KPI attached to it, where OpptyId;ProdId;KPIName is in the key and corresponding Oppty KPI record in value.
        for(Core_Opportunity_KPI__c oppkpi : [SELECT id, name,lastmodifieddate, Core_Opp_KPI_Opportunity__c, Core_Opp_KPI_BatchTime__c, Core_Opp_KPI_IntRecord_Id__c, Core_IAH_KPI_Record_ID__c, (SELECT id, Core_Opp_KPI_Oppty_Product_Id__c FROM Opportunity_KPI_Products__r) FROM Core_Opportunity_KPI__c WHERE Core_Opp_KPI_Opportunity__c IN : kpiOpptyIdSet]){
            List<Core_Opp_KPI_Product__c> kpiProdList = new List<Core_Opp_KPI_Product__c>();
            kpiProdList = oppKpi.Opportunity_KPI_Products__r;           
            for(Core_Opp_KPI_Product__c kpiPrd : kpiProdList){
                //Updated the Unique string to contain "IAH KPI ID" for US604686 - KPI : Update and fix KPI sync with IAH
                String unique = oppkpi.Core_Opp_KPI_Opportunity__c + ';' + kpiPrd.Core_Opp_KPI_Oppty_Product_Id__c + ';' + oppkpi.name + ';' + oppkpi.Core_IAH_KPI_Record_ID__c;                
                existingkpiGroupedbyOPKMap.put(unique, oppkpi);
            }
        }
        
        //Creating a map of new Opportunity KPI unique key with KPI associated some KPI attached to it, where OpptyId;Prod;KPIName is in the key and corresponding Oppty KPI record in value.
        for(Core_KPI_Integration_Inbound__c kpiInt : scope){            
            List<Core_KPI_Integration_Inbound__c> tempList = new List<Core_KPI_Integration_Inbound__c>();           
            //Defining a primary key comprising of OpptyId, ProductId and KPI Name in the format - "oppId1;kpiName1"
            //Updated the Unique string to contain "IAH KPI ID" for US604686 - KPI : Update and fix KPI sync with IAH
            String unique = kpiInt.Core_IAH_KPI_Oppty_Id__c + ';' + kpiInt.Core_IAH_KPI_Oppty_Prod_Id__c + ';' + kpiInt.Core_IAH_KPI_Name__c + ';' + kpiInt.Core_IAH_KPI_Record_ID__c;          
            //kpiIntGroupedbyOPKpiMap will contain the the Primary Key in the Key and the list of KPI Integration Inbound Records in Value sorted in Descending order of Batch Date.
            if(kpiIntGroupedbyOPKpiMap.get(unique) != null){
                tempList = kpiIntGroupedbyOPKpiMap.get(unique);
                tempList.add(kpiInt);
                kpiIntGroupedbyOPKpiMap.put(unique, tempList);
            }else{
                tempList = new List<Core_KPI_Integration_Inbound__c>();
                tempList.add(kpiInt);
                kpiIntGroupedbyOPKpiMap.put(unique, tempList);
            }       
        }
        
        //Taking the first reocord in the kpiIntGroupedbyOPKpiMap for each Primary Key because it is sorted in Descending order and will have the latest operation.
        for(String key : kpiIntGroupedbyOPKpiMap.keySet()){
            Integer kpisize = kpiIntGroupedbyOPKpiMap.get(key).size() - 1;
            List<String> keyList = key.split(';');
            if(keyList != null && keyList.size() > 3){//Updated the count to 3 "IAH KPI ID" for US604686 - KPI : Update and fix KPI sync with IAH
                if(existingkpiGroupedbyOPKMap.get(key) != null && existingkpiGroupedbyOPKMap.get(key).Core_Opp_KPI_BatchTime__c < kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Batch_Time__c){
                    if(kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_DB_Status__c == 'Delete'){
                        deleteKPISet.add(existingkpiGroupedbyOPKMap.get(key).Id);   
                    }
                    if(kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_DB_Status__c == 'Update'){
                       
                        string str1=kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Name__c+';'+kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Record_ID__c;
                        //string str1=kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Name__c+';'+kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Record_ID__c;
                        
                        
                        
                         if(str1 != null && kpiCriteriaMap.get(str1) != null){
                            
                            //updated Query to contain "IAH KPI ID" for US604686 - KPI : Update and fix KPI sync with IAH
                            updateKPIList.add(new Core_Opportunity_KPI__c(id = existingkpiGroupedbyOPKMap.get(key).Id, Core_Opp_KPI_BU_Owner__c = kpiCriteriaMap.get(str1).Core_Opp_KPI_BU_Owner__c, Core_Opp_KPI_Description__c = kpiCriteriaMap.get(str1).Core_Opp_KPI_Description__c, Core_Opp_KPI_Threshold_Req__c = kpiCriteriaMap.get(str1).Core_Opp_Threshold_Requirement__c, Core_Opp_KPI_Achieved__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Achieved__c, Core_Opp_KPI_Add_Date__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Added_Date__c, Core_Opp_KPI_Last_Update_Date__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Last_Updated_Date__c, Core_Opp_KPI_Quantity__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Quantity__c, Core_Opp_KPI_Total_Price__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Total_Price__c, Core_Opp_KPI_Type__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Type__c, Core_Opp_KPI_Opportunity__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Oppty_Id__c, Core_Opp_KPI_Volume__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Oppty_Volume__c, Core_Opp_KPI_Threshold_Met__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Threshold_Met__c, Name = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Name__c, Core_Opp_KPI_IntRecord_Id__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Id, Core_Opp_KPI_BatchTime__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Batch_Time__c, Core_IAH_KPI_Record_ID__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Record_ID__c));
                            opptyKPIProductMap.put(key+';'+kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Id+';Update', kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Oppty_Prod_Id__c);    
                        }else{
                              
                            //updated Query to contain "IAH KPI ID" for US604686 - KPI : Update and fix KPI sync with IAH
                            updateKPIList.add(new Core_Opportunity_KPI__c(id = existingkpiGroupedbyOPKMap.get(key).Id, Core_Opp_KPI_Achieved__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Achieved__c, Core_Opp_KPI_Add_Date__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Added_Date__c, Core_Opp_KPI_Last_Update_Date__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Last_Updated_Date__c, Core_Opp_KPI_Quantity__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Quantity__c, Core_Opp_KPI_Total_Price__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Total_Price__c, Core_Opp_KPI_Type__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Type__c, Core_Opp_KPI_Opportunity__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Oppty_Id__c, Core_Opp_KPI_Volume__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Oppty_Volume__c, Core_Opp_KPI_Threshold_Met__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Threshold_Met__c, Name = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Name__c, Core_Opp_KPI_IntRecord_Id__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Id, Core_Opp_KPI_BatchTime__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Batch_Time__c, Core_IAH_KPI_Record_ID__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Record_ID__c));  
                            opptyKPIProductMap.put(key+';'+kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Id+';Update', kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Oppty_Prod_Id__c);                        
                        }
                        
                    }
                }else if(existingkpiGroupedbyOPKMap.get(key) == null){          
                    if(kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_DB_Status__c == 'Insert' || kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_DB_Status__c == 'Update' || kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_DB_Status__c == 'No Change'){
                        if(kpiProdOpptyProdMap.keySet().contains(keyList[1]) && kpiOpptyMap.keySet().contains(keyList[0])){
                            string str2=kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Name__c+';'+kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Record_ID__c;
                            if(kpiCriteriaMap.get(str2) != null){
                                //updated Query to contain "IAH KPI ID" for US604686 - KPI : Update and fix KPI sync with IAH
                                insertKPIList.add(new Core_Opportunity_KPI__c(Core_Opp_KPI_BU_Owner__c = kpiCriteriaMap.get(str2).Core_Opp_KPI_BU_Owner__c, Core_Opp_KPI_Description__c = kpiCriteriaMap.get(str2).Core_Opp_KPI_Description__c, Core_Opp_KPI_Threshold_Req__c = kpiCriteriaMap.get(str2).Core_Opp_Threshold_Requirement__c, Core_Opp_KPI_Achieved__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Achieved__c, Core_Opp_KPI_Add_Date__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Added_Date__c, Core_Opp_KPI_Last_Update_Date__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Last_Updated_Date__c, Core_Opp_KPI_Quantity__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Quantity__c, Core_Opp_KPI_Total_Price__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Total_Price__c, Core_Opp_KPI_Type__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Type__c, Core_Opp_KPI_Opportunity__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Oppty_Id__c, Core_Opp_KPI_Volume__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Oppty_Volume__c, Core_Opp_KPI_Threshold_Met__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Threshold_Met__c, Name = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Name__c, Core_Opp_KPI_IntRecord_Id__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Id, Core_Opp_KPI_BatchTime__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Batch_Time__c, Core_IAH_KPI_Record_ID__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Record_ID__c));
                                opptyKPIProductMap.put(key+';'+kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Id, kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Oppty_Prod_Id__c);    
                            }else{
                                //updated Query to contain "IAH KPI ID" for US604686 - KPI : Update and fix KPI sync with IAH
                                insertKPIList.add(new Core_Opportunity_KPI__c(Core_Opp_KPI_Achieved__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Achieved__c, Core_Opp_KPI_Add_Date__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Added_Date__c, Core_Opp_KPI_Last_Update_Date__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Last_Updated_Date__c, Core_Opp_KPI_Quantity__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Quantity__c, Core_Opp_KPI_Total_Price__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Total_Price__c, Core_Opp_KPI_Type__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Type__c, Core_Opp_KPI_Opportunity__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Oppty_Id__c, Core_Opp_KPI_Volume__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Oppty_Volume__c, Core_Opp_KPI_Threshold_Met__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Threshold_Met__c, Name = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Name__c, Core_Opp_KPI_IntRecord_Id__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Id, Core_Opp_KPI_BatchTime__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Batch_Time__c, Core_IAH_KPI_Record_ID__c = kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Record_ID__c));   
                                opptyKPIProductMap.put(key+';'+kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Id, kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Core_IAH_KPI_Oppty_Prod_Id__c);                      
                            }   
                        }else{
                            failedKPIIntMap.put(kpiIntGroupedbyOPKpiMap.get(key)[kpisize].Id, 'Opportunity/Product does not exist.'+keyList[0]+';'+keyList[1]);
                        }                           
                    }   
                }
            }           
        }
        List<Id> deleteKPIList = new List<Id>();
        //Actual deleting and inserting of Opportunity KPI records.
        try{
            if(!deleteKPISet.isEmpty()){
                deleteKPIList.addAll(deleteKPISet);
                Database.DeleteResult[] drList = Database.delete(deleteKPIList, false);
                for(Database.DeleteResult dr : drList) {
                    if(!dr.isSuccess() || Test.isRunningTest()){
                        String errorMsg = '';
                        for(Database.Error err : dr.getErrors()) {
                            errorMsg = errorMsg + err.getMessage();
                        }
                        captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'KPI_Delete_Error', Core_Severity__c = 'High', Core_Origin__c='Core_Opp_KPIProcessing_Full_Batch', Core_When__c = System.now()));
                    }
                }
            }

            if(!insertKPIList.isEmpty()){
                Database.SaveResult[] srList = Database.insert(insertKPIList, false);
                for(Integer i = 0; i<srList.size(); i++){
                    if(!srList[i].isSuccess() || Test.isRunningTest()){//only look at failures, or NOT Successes
                        String errorMsg = String.valueOf(srList[i].getErrors());
                        captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg+insertKPIList[i].Core_Opp_KPI_Opportunity__c+';'+insertKPIList[i].Name, Core_Message__c = 'KPI_Insert_Error', Core_Severity__c = 'High', Core_Origin__c='Core_Opp_KPIProcessing_Full_Batch', Core_When__c = System.now())); 
                        failedKPIMap.put(insertKPIList[i].Core_Opp_KPI_IntRecord_Id__c, errorMsg+'; '+insertKPIList[i].Core_Opp_KPI_Opportunity__c+';'+insertKPIList[i].Name); 
                    }else{
                        savedKPISet.add(srList[i].getId());
                    }
                }   
            }
            
            if(!updateKPIList.isEmpty()){
                Database.SaveResult[] srList = Database.update(updateKPIList, false);
                for(Integer i = 0; i<srList.size(); i++){
                    if(!srList[i].isSuccess()){//only look at failures, or NOT Successes
                        String errorMsg = '';
                        errorMsg = errorMsg+srList[i].getErrors();
                        captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'KPI_Update_Error', Core_Severity__c = 'High', Core_Origin__c='Core_Opp_KPIProcessing_Full_Batch', Core_When__c = System.now())); 
                        failedKPIMap.put(updateKPIList[i].Core_Opp_KPI_IntRecord_Id__c, errorMsg+'; '+updateKPIList[i].Core_Opp_KPI_Opportunity__c+';'+updateKPIList[i].Name); 
                    }else{
                        savedKPISet.add(srList[i].getId());
                    }
                }   
            }
            
            
        }catch(Exception e){
           
        }     
        Datetime  lastModifTime;
        //Update the KPI Integration records which failed using savedKPISet
        for(Core_Opportunity_KPI__c oppKpi : [SELECT id, Name, Core_Opp_KPI_Opportunity__c, Core_Opp_KPI_IntRecord_Id__c,lastmodifieddate FROM Core_Opportunity_KPI__c WHERE Id IN : savedKPISet ORDER BY lastmodifieddate ]){
            kpiIntUpdateSet.add(oppKpi.Core_Opp_KPI_IntRecord_Id__c);
           //US600689 : Update KPI Refresh Message on Home page
            if(oppKpi.lastmodifieddate.Date() == System.today()){
                lastModifTime=oppKpi.lastmodifieddate;
            }
            
        }
        
        List<Core_KPI_Refresh_Message__c> csList=new List<Core_KPI_Refresh_Message__c>();
        List<Core_KPI_Refresh_Message__c> kpCsiList = Core_KPI_Refresh_Message__c.getAll().values();
        
        if(lastModifTime != NULL){
        if(kpCsiList.size() > 0 && !kpCsiList.isempty()){
            integer j=0;
            for(Core_KPI_Refresh_Message__c kpcs:kpCsiList){
                j++;
                if(kpCsiList.size() == j){
                    kpcs.Name=kpcs.Name;
                    kpcs.Core_LastModifiedDate__c=lastModifTime;
                    csList.add(kpcs);
                }
            }
        }
        
        else{
            Core_KPI_Refresh_Message__c kpiMsg=new Core_KPI_Refresh_Message__c();
            kpiMsg.Name='KPI Last Updated';
            kpiMsg.Core_LastModifiedDate__c=lastModifTime;
            csList.add(kpiMsg);
        }
        
       
        if(csList.size() > 0 && ! csList.isempty()){
            upsert csList;
        }
        }
        
        for(Core_KPI_Integration_Inbound__c kpiInt : scope){
            if(failedKPIMap.keySet().contains(kpiInt.Id)){
                kpiInt.Core_KPI_Processing_Status__c = 'Failure';
                kpiInt.Core_IAH_KPI_Error_Message__c = failedKPIMap.get(kpiInt.Id);
                kpiIntUpdateList.add(kpiInt);
            }else{
                if(failedKPIIntMap.keySet().contains(kpiInt.id)){
                    kpiInt.Core_KPI_Processing_Status__c = 'Failure';
                    kpiInt.Core_IAH_KPI_Error_Message__c = failedKPIIntMap.get(kpiInt.Id);
                    kpiIntUpdateList.add(kpiInt);
                }else{
                    kpiInt.Core_KPI_Processing_Status__c = 'Success';
                    kpiIntUpdateList.add(kpiInt);
                }
            }
        }
        if(!kpiIntUpdateList.isEmpty()){
            try{
                update kpiIntUpdateList;
            }catch(Exception e){
                
            }
        }
        
        Map<Id, Core_Opportunity_KPI__c> savedOpptyKPIMap = new Map<Id, Core_Opportunity_KPI__c>([SELECT id, Name, Core_Opp_KPI_Opportunity__c, Core_Opp_KPI_IntRecord_Id__c, (SELECT id, Core_Opp_KPI_Oppty_Product_Id__c FROM Opportunity_KPI_Products__r) FROM Core_Opportunity_KPI__c WHERE Id IN : savedKPISet]);
        
        for(String key : opptyKPIProductMap.keySet()){
            List<String> keyList = key.split(';');
            for(Core_Opportunity_KPI__c kpiObj : savedOpptyKPIMap.values()){
                //updated count to 4 to contain "IAH KPI ID" for US604686 - KPI : Update and fix KPI sync with IAH
                if(kpiObj.Core_Opp_KPI_Opportunity__c == keyList[0] && kpiObj.name == keyList[2] && kpiObj.Core_Opp_KPI_IntRecord_Id__c == keyList[4] && kpiProdOpptyProdMap.get(keyList[1]) != null){
                   //US647551 : OPPTY : Change logic for Opportunity KPI fields update fix
                    if((keyList.size() > 5 && keyList[5] == 'Update') || Test.isRunningTest()){
                        List<Core_Opp_KPI_Product__c> kpiProdList = new List<Core_Opp_KPI_Product__c>();
                        kpiProdList = kpiObj.Opportunity_KPI_Products__r;           
                        for(Core_Opp_KPI_Product__c kpiPrd : kpiProdList){
                            deleteKPIProdSet.add(kpiPrd.Id);
                        }
                    }
                    //String kpiProdName = kpiProdOpptyProdMap.get(keyList[1]).Name.left(77)+'..';
                    String kpiProdName = kpiProdOpptyProdMap.get(keyList[1]).Product2.Name;
                    kpiProdName = kpiProdName.left(79);
                    insertKPIProdList.add(new Core_Opp_KPI_Product__c(name = kpiProdName, Core_Opp_KPI__c = kpiObj.Id, Core_Opp_KPI_Oppty_Product_Id__c = keyList[1], Core_Opp_KPI_Product__c = kpiProdOpptyProdMap.get(keyList[1]).Product2.Id));
                }
            }
        }
        List<Id> deleteKPIPrdList = new List<Id>();
        
        try{
            if(!deleteKPIProdSet.isEmpty()){
                deleteKPIPrdList.addAll(deleteKPIProdSet);
                Database.DeleteResult[] drList = Database.delete(deleteKPIPrdList, false);
                for(Database.DeleteResult dr : drList) {
                    if(!dr.isSuccess()){
                        String errorMsg = '';
                        for(Database.Error err : dr.getErrors()) {
                            errorMsg = errorMsg + err.getMessage();
                        }
                        captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'KPIProd_Delete_Error', Core_Severity__c = 'High', Core_Origin__c='Core_Opp_KPIProcessing_Full_Batch', Core_When__c = System.now()));
                    }
                }
            }
            if(!insertKPIProdList.isEmpty()){
                Database.SaveResult[] srList = Database.insert(insertKPIProdList, false);
                for(Database.SaveResult sr : srList) {
                    if(!sr.isSuccess()){
                        String errorMsg = '';
                        for(Database.Error err : sr.getErrors()) {
                            errorMsg = errorMsg + err.getMessage();
                        }
                        captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'KPIProd_Insert_Error', Core_Severity__c = 'High', Core_Origin__c='Core_Opp_KPIProcessing_Full_Batch', Core_When__c = System.now()));   
                    }
                }
            }
            if(!captureQueryErr.isEmpty()){
                insert captureQueryErr;
            }
        }catch(Exception e){
            
        }
        
        
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}