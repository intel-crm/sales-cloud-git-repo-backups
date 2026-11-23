/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_KPIDeltaLoadHandler
Version     : 1.0 
Created Date: 25 JAN 2021
Function    : Utility methods to handle Delta Load
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             01/25/2021              Original Version

*****************************************************************************************************************************************************************************************************/

public without sharing class Core_KPIDeltaLoadHandler {
    
    public static map<Id,List<Core_Oppty_KPI_New__c>> mapOpptyKPI;
    public static map<Id,Set<Core_Oppty_KPI_New__c>> mapDeleteOpptyKPI;
    public static List<Core_Oppty_KPI_New__c> oppIdDeleteSet;
    public static map<id, String> mapoppidbatchtime;
    public static map<id, String> mapKPIoppidbatchId;
    public static List<Core_KPI_Staging__c> ksListStatus =new List<Core_KPI_Staging__c>();
    public static List<Core_KPI_Staging__c> ksDeleteListStatus =new List<Core_KPI_Staging__c>();
    public static Set<Id> allOpportunityIdSet = new Set<Id>();
    public static Set<Id> allOpportunityLineItemIdSet = new Set<Id>();
    public static List<Core_KPI_Staging__c> invalidKPIStaging = new List<Core_KPI_Staging__c>();
    public static List<id> validKPIStagingID = new List<id>();
    public static map<id, Core_KPI_Staging__c> mapValidKPIStaging = new map<id, Core_KPI_Staging__c>();
    public static String invalidKPIStagBatch = '';
    public static Boolean isRefreshKPIDel= false;
    /*
* Method name  : handleDeltaLoad
* Description  : 
* Return Type  : VOID
* Parameter    : List<Core_KPI_Staging__c> newList,boolean KPIFullLoadCheck
*/
    public static void handleDeltaLoad(List<Core_KPI_Staging__c> newList,boolean KPIDeltaLoadCheck) {
        KPIDeltaLoadCheck = false;
        List<Core_KPI_Staging__c> KPIAllFailure = new List<Core_KPI_Staging__c>();
        List<Core_KPI_Staging__c> isDeleteStaging = new List<Core_KPI_Staging__c>();
        map<String, Set<String>> mapBatchIdStatus = new map<String, Set<String>>();
        Map < ID, Map < String, String > > oppWithBatchId = new Map < ID, Map < String, String > > ();
        List<Core_Opportunity_KPI_Batch_Detail__c> KPIBatchDtls = new List<Core_Opportunity_KPI_Batch_Detail__c>();
        List<Core_Opportunity_KPI_Batch_Detail__c> updatedOppKPiBatchList = new List<Core_Opportunity_KPI_Batch_Detail__c>();
        Map<String, String> latestOppKPIMap = new Map<String, String>();

        Map<Id, Core_KPI_Staging__c> newListMap = new Map<Id, Core_KPI_Staging__c>(newList);
		Set<Id> errorIdsRemove = new Set<Id>();
        try{
            List<Core_Oppty_KPI_New__c> oppKPIList = new List<Core_Oppty_KPI_New__c>();
            List<Core_KPI_Staging__c> ksNewList = new List<Core_KPI_Staging__c>();            
            Set<Id> oppIdSet =  new Set<Id>();
            Set<Id> oppIdNoDeleteSetId =  new Set<Id>();
            Set<Id> allOpportunityId = new Set<Id>();
            Set<Id> allOpportunityLineId = new Set<Id>();            
            oppIdDeleteSet =  new List<Core_Oppty_KPI_New__c>();
            List<Core_Oppty_KPI_New__c> oppIdDeleteList =  new List<Core_Oppty_KPI_New__c>();
            Set<Core_Oppty_KPI_New__c> oppIdKPIDeleteList =  new Set<Core_Oppty_KPI_New__c>();
            for(Core_KPI_Staging__c staging : newList){
                allOpportunityId.add(staging.Core_Opportunity_ID_Txt__c);
                allOpportunityLineId.add(staging.Core_Opportunity_Product_Txt__c);
                if(!staging.Core_Begin_Of_File__c && !staging.Core_End_Of_File__c){
                    oppIdSet.add(staging.Core_Opportunity_ID_Txt__c);
                    ksNewList.add(staging);
                    if(staging.Core_Is_Delete__c == false){
                        oppIdNoDeleteSetId.add(staging.Core_Opportunity_ID_Txt__c);
                    }
                    if (oppWithBatchId.get(staging.Core_Opportunity_ID_Txt__c) == null && staging.Core_Opportunity_Stage_Txt__c != null) {
                        oppWithBatchId.put(staging.Core_Opportunity_ID_Txt__c, new map < String, String > { String.valueOf(staging.Core_Opportunity_Stage_Txt__c) => String.valueOf(staging.Core_Batch_ID__c) });
                    }
                }
                if(staging.Core_Is_Delete__c == true && !staging.Core_Begin_Of_File__c){
                    isDeleteStaging.add(staging);
                }
                
            }
            //reduce query SOQL
            List<Core_Oppty_KPI_New__c> existingOppKPIDelete = [select id,Core_Batch_Time__c,Core_KPI_Opportunity__c, Core_Opportunity_KPI_Batch_ID__c from Core_Oppty_KPI_New__c 
                                                          where Core_KPI_Opportunity__c =:oppIdNoDeleteSetId and Core_IsActive__c =true];
                                                          
            List<Core_Oppty_KPI_New__c> existingOppKPI = [select id,Core_Batch_Time__c,Core_KPI_Opportunity__c, Core_Opportunity_KPI_Batch_ID__c from Core_Oppty_KPI_New__c 
                                                          where Core_KPI_Opportunity__c IN :oppIdSet and Core_IsActive__c =true];
            
            List<Opportunity> allOpportunityList = [SELECT Id,StageName FROM Opportunity WHERE Id IN :allOpportunityId];
            List<OpportunityLineItem> allOpportunityLineItemList = [SELECT Id FROM OpportunityLineItem WHERE Id IN :allOpportunityLineId];
            for (Core_Opportunity_KPI_Batch_Detail__c batch: [SELECT ID,Core_Opportunity_ID_Txt__c,Core_Opportunity_Stage_Txt__c,Core_Opportunity_KPI_Batch_ID_Txt__c FROM Core_Opportunity_KPI_Batch_Detail__c WHERE Core_Opportunity_ID_Txt__c IN :allOpportunityId
                                                              ORDER BY Core_Opportunity_ID_Txt__c
                                                             ]) {
                                                                 String kpiBtch = batch.Core_Opportunity_ID_Txt__c + '~' + batch.Core_Opportunity_Stage_Txt__c;
                                                                 if (latestOppKPIMap.get(kpiBtch) == null) {
                                                                     latestOppKPIMap.put(kpiBtch, batch.Core_Opportunity_KPI_Batch_ID_Txt__c);
                                                                 }
                                                             }
            for(Opportunity opp: allOpportunityList){
                allOpportunityIdSet.add(opp.Id);
                if (oppWithBatchId.get(opp.Id) != null) {
                    //String latestKPI = opp.Id + '~' + opp.StageName;
                    if(oppWithBatchId.get(opp.Id).containsKey('Design Win') && latestOppKPIMap.get(opp.Id + '~Design Win') == null){
                        Core_Opportunity_KPI_Batch_Detail__c kpiBatch = new Core_Opportunity_KPI_Batch_Detail__c();
                        kpiBatch.Core_Opportunity_ID_Txt__c = opp.Id;
                        kpiBatch.Core_Opportunity_Stage_Txt__c = 'Design Win';
                        kpiBatch.Core_Opportunity_KPI_Batch_ID_Txt__c = oppWithBatchId.get(opp.Id).get('Design Win');
                        KPIBatchDtls.add(kpiBatch);
                    }
                    if(oppWithBatchId.get(opp.Id).containsKey('Production Win') && latestOppKPIMap.get(opp.Id + '~Production Win') == null){
                        Core_Opportunity_KPI_Batch_Detail__c kpiBatch = new Core_Opportunity_KPI_Batch_Detail__c();
                        kpiBatch.Core_Opportunity_ID_Txt__c = opp.Id;
                        kpiBatch.Core_Opportunity_Stage_Txt__c = 'Production Win';
                        kpiBatch.Core_Opportunity_KPI_Batch_ID_Txt__c = oppWithBatchId.get(opp.Id).get('Production Win');
                        KPIBatchDtls.add(kpiBatch);
                    }
                }
            }
            for(OpportunityLineItem oppLineItem : allOpportunityLineItemList){
                allOpportunityLineItemIdSet.add(oppLineItem.Id);
            }
            //reduce the for loops
            mapOpptyKPI = new map<Id,List<Core_Oppty_KPI_New__c>>();
            mapDeleteOpptyKPI = new map<Id,Set<Core_Oppty_KPI_New__c>>();
            
            mapoppidbatchtime = new map<id, String>();
            mapKPIoppidbatchId = new map<id, String>();
            for(Core_Oppty_KPI_New__c opptyKPI: existingOppKPI){
                mapoppidbatchtime.put(opptyKPI.Core_KPI_Opportunity__c, string.valueOf(opptyKPI.Core_Batch_Time__c));
                mapKPIoppidbatchId.put(opptyKPI.Core_KPI_Opportunity__c, opptyKPI.Core_Opportunity_KPI_Batch_ID__c);
                if(oppIdSet.contains(opptyKPI.Core_KPI_Opportunity__c)){
                    if(mapOpptyKPI.containskey(opptyKPI.Core_KPI_Opportunity__c)){
                        List<Core_Oppty_KPI_New__c> listKPI = mapOpptyKPI.get(opptyKPI.Core_KPI_Opportunity__c);
                        listKPI.add(opptyKPI);
                        mapOpptyKPI.put(opptyKPI.Core_KPI_Opportunity__c, listKPI);
                    }
                    else{
                        mapOpptyKPI.put(opptyKPI.Core_KPI_Opportunity__c, new List<Core_Oppty_KPI_New__c>{opptyKPI});
                    }
                }  
            }
            oppKPICreate(ksNewList,mapoppidbatchtime,oppKPIList,mapDeleteOpptyKPI);            
            Core_KPI_Staging__c tempkpiStage;
           
            if(oppKPIList.size()>0 || oppIdDeleteSet.size()>0){
                integer i= 0 ;
                
                if(existingOppKPI.size()>0)
                {                       
                    //delete existingOppKPIDelete;
                    //TWC3123-118 Inactivate the old kpis
                    List<Core_Oppty_KPI_New__c> fList = new List<Core_Oppty_KPI_New__c>();
                    for(Core_Oppty_KPI_New__c kp : existingOppKPIDelete){
                        kp.Core_IsActive__c =false;
                        fList.add(kp);
                    }
                    database.update(fList);
                }
                Database.SaveResult[] srr = database.insert(oppKPIList,false);
                for (Database.SaveResult sr : srr) {
                    if (sr.isSuccess()) {
                        Core_KPI_Staging__c kobj = new Core_KPI_Staging__c();
                        kobj.id = validKPIStagingID[i];
                        kobj.Core_Status__c = 'Success';
                        ksListStatus.add(kobj);
                    }
                    else if (!sr.isSuccess()){
                        // DML operation failed
                        Core_KPI_Staging__c kobjFailed = new Core_KPI_Staging__c();
                        kobjFailed.id = validKPIStagingID[i];
                        kobjFailed.Core_Status__c = 'Failure';
                        kobjFailed.Core_KPI_Processing_Time__c = Datetime.now().addMinutes(integer.valueof(system.label.Core_New_KPI_Retry_Timer));
                        for(Database.Error err : sr.getErrors()) {
                            kobjFailed.Core_Error_Description__c = err.getMessage()+' --'+ err.getFields();
                        }
                        errorIdsRemove.add(mapValidKPIStaging.get(validKPIStagingID[i]).Core_Opportunity_ID_Txt__c);
                        ksListStatus.add(kobjFailed);
                    }
                    i++;
                }
                
                oppIdKPIDeleteList.addAll(oppIdDeleteSet);
                List<Core_Oppty_KPI_New__c> deleteKPIList = new List<Core_Oppty_KPI_New__c>();
                deleteKPIList.addAll(oppIdKPIDeleteList);
                //Database.DeleteResult[] drr = database.delete(deleteKPIList,false);
                //TWC3123-118 Inactivate the old kpis
                List<Core_Oppty_KPI_New__c> fList = new List<Core_Oppty_KPI_New__c>();
                for(Core_Oppty_KPI_New__c kp : deleteKPIList){
                    kp.Core_IsActive__c =false;
                        fList.add(kp);
                }
                if(fList.size()>0){
                Database.SaveResult[] srrDelete = database.update(fList,false);
                for(Integer j=0; j < isDeleteStaging.size(); j++) {
                    Database.SaveResult sr = srrDelete[j];
                    if (sr.isSuccess()) {
                        Core_KPI_Staging__c kobj = new Core_KPI_Staging__c();
                        kobj.id = isDeleteStaging[j].Id;
                        kobj.Core_Status__c = 'Success';
                        ksListStatus.add(kobj);
                    }
                    else{
                        Core_KPI_Staging__c kobjFailed = new Core_KPI_Staging__c();
                        kobjFailed.id = isDeleteStaging[j].Id;
                        kobjFailed.Core_Status__c = 'Failure';
                        kobjFailed.Core_KPI_Processing_Time__c = Datetime.now().addMinutes(integer.valueof(system.label.Core_New_KPI_Retry_Timer));
                        for(Database.Error err : sr.getErrors()) {
                            kobjFailed.Core_Error_Description__c = err.getMessage()+' --'+ err.getFields();
                        }
                        ksListStatus.add(kobjFailed);
                        errorIdsRemove.add(isDeleteStaging[j].Core_Opportunity_ID_Txt__c);
                    }
                    
                }
                }
                
                //update here
                if(ksListStatus.size()>0){
                    update ksListStatus;
                }
                //List<Core_KPI_Staging__c> KPIStagingList = [select id,Core_Batch_ID__c,Core_Status__c, Core_End_Of_File__c,Core_Begin_Of_File__c,Core_Retry_Counter__c from Core_KPI_Staging__c where id in:newList];
                //map<String, Set<String>> mapBatchIdStatus = new map<String, Set<String>>();
                /*for(Core_KPI_Staging__c kpiStag : newList){
                    if(kpiStag.Core_End_Of_File__c == false && kpiStag.Core_Begin_Of_File__c == false){
                        if(mapBatchIdStatus.containskey(kpiStag.Core_Batch_ID__c)){
                            Set<String> listStatus = mapBatchIdStatus.get(kpiStag.Core_Batch_ID__c);
                            listStatus.add(kpiStag.Core_Status__c);
                            mapBatchIdStatus.put(kpiStag.Core_Batch_ID__c, listStatus);
                        }
                        else{
                            mapBatchIdStatus.put(kpiStag.Core_Batch_ID__c, new Set<String>{kpiStag.Core_Status__c});
                        }
                    }    
                }
                
                if(newList.size()>0){
                    List<Core_KPI_Staging__c> updateEndOfFileStatus = new List<Core_KPI_Staging__c>();
                    for(Core_KPI_Staging__c sta : newList){
                        tempkpiStage = new Core_KPI_Staging__c();
                        tempkpiStage.Id = sta.Id;
                        if(sta.Core_End_Of_File__c == true){                               
                            if(mapBatchIdStatus.containskey(sta.Core_Batch_ID__c)){
                                if(mapBatchIdStatus.get(sta.Core_Batch_ID__c).contains('Failure')){
                                    tempkpiStage.Core_Status__c = 'Failure';
                                    updateEndOfFileStatus.add(tempkpiStage);
                                    
                                }
                                else{
                                    tempkpiStage.Core_Status__c = 'Success';
                                    updateEndOfFileStatus.add(tempkpiStage);
                                }
                            }
                        }
                        else if(sta.Core_Begin_Of_File__c == false && sta.Core_End_Of_File__c == false && sta.Core_Status__c == 'Failure'){
                            tempkpiStage.Core_Retry_Counter__c = sta.Core_Retry_Counter__c+1;
                            updateEndOfFileStatus.add(tempkpiStage);
                        }
                    }
                    update updateEndOfFileStatus;
                }*/
                
            }
                        
            // no matching staging record found
            
            else if(oppIdDeleteSet.size()==0){
                for(Core_KPI_Staging__c staging : newList){
                    if(mapOpptyKPI.get(staging.Core_Opportunity_ID_Txt__c)== null && staging.Core_Begin_Of_File__c == false){
                        Core_KPI_Staging__c kobj = new Core_KPI_Staging__c();
                        kobj.id = staging.Id;
                        kobj.Core_Status__c = 'Success';
                        ksDeleteListStatus.add(kobj);
                    }   
                    else if(mapOpptyKPI.get(staging.Core_Opportunity_ID_Txt__c)!= null && staging.Core_Batch_ID__c!= invalidKPIStagBatch ){
                        Core_KPI_Staging__c kobj = new Core_KPI_Staging__c();
                        kobj.id = staging.Id;
                        kobj.Core_Status__c = 'Failure';
                        kobj.Core_Old_Record__c = true;
                        kobj.Core_Invalid_Record__c = true;
                        kobj.Core_Error_Description__c = 'Batch ID/Batch time is less than existing records';
                        ksDeleteListStatus.add(kobj);
                        errorIdsRemove.add(staging.Core_Opportunity_ID_Txt__c);
                    }  
                    else if(mapOpptyKPI.get(staging.Core_Opportunity_ID_Txt__c)!= null && staging.Core_Batch_ID__c == invalidKPIStagBatch){
                        if(staging.Core_Begin_Of_File__c == true){
                            Core_KPI_Staging__c kobj = new Core_KPI_Staging__c();
                            kobj.id = staging.Id;
                            kobj.Core_Status__c = 'New';
                            ksDeleteListStatus.add(kobj);
                        }
                        else if(staging.Core_End_Of_File__c == true){
                            Core_KPI_Staging__c kobj = new Core_KPI_Staging__c();
                            kobj.id = staging.Id;
                            kobj.Core_Status__c = 'Success';
                            ksDeleteListStatus.add(kobj);
                        }
                   }                                                
                } 
                update ksDeleteListStatus;           
            }
            else{
                for(Core_KPI_Staging__c ks: newList){
                    if(mapOpptyKPI.get(ks.Core_Opportunity_ID_Txt__c)!= null){
                        tempkpiStage = new Core_KPI_Staging__c();
                        tempkpiStage.Id = ks.Id;
                        tempkpiStage.Core_Status__c = 'Failure';
                        tempkpiStage.Core_Old_Record__c = true;
                        tempkpiStage.Core_Invalid_Record__c = true;
                        tempkpiStage.Core_Error_Description__c = 'Batch ID/Batch time is less than existing records';
                        KPIAllFailure.add(tempkpiStage);
                        errorIdsRemove.add(ks.Core_Opportunity_ID_Txt__c);
                    }
                }
                update KPIAllFailure;
            }
            if(invalidKPIStaging.size()>0 || invalidKPIStaging!= null){
                List<Core_KPI_Staging__c> updateInvalidKPI = new List<Core_KPI_Staging__c>();
                for( Core_KPI_Staging__c kpi : invalidKPIStaging){
                    Core_KPI_Staging__c invalidKpiStage = new Core_KPI_Staging__c();
                    invalidKpiStage.Id = kpi.Id;
                    invalidKpiStage.Core_Status__c = 'Failure';
                    invalidKpiStage.Core_Old_Record__c = true;
                    invalidKpiStage.Core_Invalid_Record__c = true;
                    invalidKpiStage.Core_Error_Description__c = 'Invalid Opportunity Id/Opportunity Product Id';
                    updateInvalidKPI.add(invalidKpiStage);
                    errorIdsRemove.add(kpi.Core_Opportunity_ID_Txt__c);
                }
                update updateInvalidKPI;
            }
            List<Core_KPI_Staging__c> KPIStagingList = [select id,Core_Error_Description__c,Core_Batch_ID__c,Core_Status__c, Core_End_Of_File__c,Core_Begin_Of_File__c,Core_Retry_Counter__c from Core_KPI_Staging__c where id in:newListMap.keySet()];
            set<String> errormsgs = new set<string>();
            integer cnt=0;
            integer cntTotalFail=0;
            for(Core_KPI_Staging__c kpiStag : KPIStagingList){
                if(kpiStag.Core_End_Of_File__c == false && kpiStag.Core_Begin_Of_File__c == false){
                    if(mapBatchIdStatus.containskey(kpiStag.Core_Batch_ID__c)){
                        Set<String> listStatus = mapBatchIdStatus.get(kpiStag.Core_Batch_ID__c);
                        listStatus.add(kpiStag.Core_Status__c);
                        mapBatchIdStatus.put(kpiStag.Core_Batch_ID__c, listStatus);
                    }
                    else{
                        mapBatchIdStatus.put(kpiStag.Core_Batch_ID__c, new Set<String>{kpiStag.Core_Status__c});
                    }
                }
                if(kpiStag.Core_Status__c == 'Failure'){
                    if(kpiStag.Core_Error_Description__c.contains('Invalid Opportunity Id/Opportunity Product Id')){
                        cnt++;
                    }
                    cntTotalFail++;
                    errormsgs.add(kpiStag.Core_Error_Description__c);
                }
            }
            if(KPIStagingList.size()>0){
                List<Core_KPI_Staging__c> updateEndOfFileStatusList = new List<Core_KPI_Staging__c>();
                Set<Core_KPI_Staging__c> updateEndOfFileStatus = new Set<Core_KPI_Staging__c>();
                for(Core_KPI_Staging__c sta : KPIStagingList){
                    tempkpiStage = new Core_KPI_Staging__c();
                    tempkpiStage.Id = sta.Id;
                    if(sta.Core_End_Of_File__c == true){ 
                        if(mapBatchIdStatus.containskey(sta.Core_Batch_ID__c)){
                            if(cnt==cntTotalFail){
                                tempkpiStage.Core_Status__c = 'Success';
                                updateEndOfFileStatus.add(tempkpiStage);
                            }
                            else if(mapBatchIdStatus.get(sta.Core_Batch_ID__c).contains('Failure')){
                                tempkpiStage.Core_Status__c = 'Failure';
                                updateEndOfFileStatus.add(tempkpiStage);
                            }
                            else{
                                tempkpiStage.Core_Status__c = 'Success';
                                updateEndOfFileStatus.add(tempkpiStage);
                            }
                        }
                    }
                    else if(sta.Core_Begin_Of_File__c == false && sta.Core_End_Of_File__c == false && sta.Core_Status__c == 'Failure'){
                        tempkpiStage.Core_Retry_Counter__c = sta.Core_Retry_Counter__c+1;
                        updateEndOfFileStatus.add(tempkpiStage);
                    }
                }
                updateEndOfFileStatusList.addAll(updateEndOfFileStatus);
                update updateEndOfFileStatusList;
            }
            if(KPIBatchDtls.size()>0){
                for (Core_Opportunity_KPI_Batch_Detail__c parent : KPIBatchDtls) {
                    if (!errorIdsRemove.contains(parent.Core_Opportunity_ID_Txt__c)) {
                        updatedOppKPiBatchList.add(parent);
                    }
                }
                database.insert(updatedOppKPiBatchList,false);
            }
        }
        catch(exception e){
            List<Core_KPI_Staging__c> excepList = new List<Core_KPI_Staging__c>();
            if(ksListStatus.size()>0){
                for(Core_KPI_Staging__c KPIStage : ksListStatus){
                    if(KPIStage.Core_Status__c == 'Failure'){
                        Core_KPI_Staging__c excep = new Core_KPI_Staging__c();
                        excep.id=KPIStage.id;  
                        excepList.add(excep);
                    }
                }
            }    
            else{
                for(Core_KPI_Staging__c KPIStage : newList){
                    Core_KPI_Staging__c excep = new Core_KPI_Staging__c();
                    excep.id=KPIStage.id;
                    excep.Core_Status__c = 'Failure';
                    excep.Core_Error_Description__c= e.getMessage()+'-'+e.getStackTraceString();
                    excep.Core_Retry_Counter__c =  KPIStage.Core_Retry_Counter__c+1;    
                    excep.Core_KPI_Processing_Time__c =  Datetime.now().addMinutes(integer.valueof(system.label.Core_New_KPI_Retry_Timer));               
                    excepList.add(excep);                    
                }
            }
            update excepList;
        }
    }
    
    
    /*
* Method name  : oppKPICreate
* Description  : 
* Return Type  : VOID
* Parameter    : List<Core_KPI_Staging__c> newList,boolean KPIFullLoadCheck
*/
    public static void oppKPICreate(List<Core_KPI_Staging__c> ksNewList,Map<Id, String> mapoppidbatchtime ,List<Core_Oppty_KPI_New__c> oppKPIList,map<Id,Set<Core_Oppty_KPI_New__c>> mapDeleteOpptyKPI){
        for(Core_KPI_Staging__c ks: ksNewList){
            if(allOpportunityIdSet.contains(ks.Core_Opportunity_ID_Txt__c) && allOpportunityLineItemIdSet.contains(ks.Core_Opportunity_Product_Txt__c)){
                if(mapOpptyKPI.get(ks.Core_Opportunity_ID_Txt__c)!= null){
                    if(datetime.valueOfGmt(mapoppidbatchtime.get(ks.Core_Opportunity_ID_Txt__c)) < datetime.valueOfGmt(string.valueof(ks.Core_Batch_Time__c)) && (mapKPIoppidbatchId.get(ks.Core_Opportunity_ID_Txt__c) < ks.Core_Batch_ID__c)){
                        if(!ks.Core_Is_Delete__c){
                            Core_Oppty_KPI_New__c oppKPIObj = new Core_Oppty_KPI_New__c();
                            oppKPIObj.Core_KPI_Achieved__c = ks.Core_KPI_Achieved__c;
                            oppKPIObj.Core_KPI_Opportunity__c = ks.Core_Opportunity_ID_Txt__c;
                            oppKPIObj.Core_KPI_Record_Id__c = ks.Core_KPI_Record_ID__c;
                            oppKPIObj.Core_KPI_Threshold_Met__c = ks.Core_Threshold_Met__c;
                            oppKPIObj.Core_KPI_Threshold_Req__c = ks.core_kpi_threshold_req__c;
                            oppKPIObj.Core_Opp_KPI_Add_Date__c = ks.core_opp_kpi_add_date__c;
                            oppKPIObj.Core_Opp_KPI_Type__c = ks.Core_KPI_Type__c;
                            oppKPIObj.Core_Opportunity_Product_Id__c = ks.core_opp_kpi_product__c;
                            oppKPIObj.Core_Opp_KPI_Product__c = ks.core_opp_kpi_product__c;
                            oppKPIObj.Core_Batch_Time__c = ks.Core_Batch_Time__c;
                            oppKPIObj.name = ks.Core_KPI_Name__c;
                            oppKPIObj.Core_Opportunity_KPI_Batch_ID__c = ks.Core_Batch_ID__c;
                            oppKPIObj.Core_Refresh_Type__c = ks.Core_Refresh_Type__c;
                            oppKPIObj.Core_Opportunity_Product__c = ks.Core_Opportunity_Product_Txt__c;
                            oppKPIObj.Core_KPI_Total_Price__c= ks.Core_KPI_Total_Price__c;
                            oppKPIObj.Core_KPI_Quantity__c= ks.Core_KPI_Quantity__c;
                            oppKPIObj.Core_TIER__c = ks.Core_TIER__c;
                            oppKPIList.add(oppKPIObj);
                            validKPIStagingID.add(ks.id);
                            if (!mapValidKPIStaging.containsKey(ks.Id)) {
                                mapValidKPIStaging.put(ks.Id, ks);
                            }
                        }
                        if(ks.Core_Is_Delete__c){
                            if(mapOpptyKPI.get(ks.Core_Opportunity_ID_Txt__c)!= null){
                                if(mapOpptyKPI.get(ks.Core_Opportunity_ID_Txt__c).size()>0){
                                    List<Core_Oppty_KPI_New__c> oppKPI = mapOpptyKPI.get(ks.Core_Opportunity_ID_Txt__c);
                                    for(Core_Oppty_KPI_New__c oppty : mapOpptyKPI.get(ks.Core_Opportunity_ID_Txt__c)){
                                        oppIdDeleteSet.add(oppty);
                                    }
                                }
                            }
                        }
                    }
                }
                else{
                    isRefreshKPIDel = true;
                }
                
                Boolean checkSize = false;
                if(mapOpptyKPI.get(ks.Core_Opportunity_ID_Txt__c)!= null && mapOpptyKPI.get(ks.Core_Opportunity_ID_Txt__c).size()>0){
                    checkSize = true;
                }
                if(!checkSize && !ks.Core_Is_Delete__c){
                    Core_Oppty_KPI_New__c oppKPIObj = new Core_Oppty_KPI_New__c();
                    oppKPIObj.Core_KPI_Achieved__c = ks.Core_KPI_Achieved__c;
                    oppKPIObj.Core_KPI_Opportunity__c = ks.Core_Opportunity_ID_Txt__c;
                    oppKPIObj.Core_KPI_Record_Id__c = ks.Core_KPI_Record_ID__c;
                    oppKPIObj.Core_KPI_Threshold_Met__c = ks.Core_Threshold_Met__c;
                    oppKPIObj.Core_KPI_Threshold_Req__c = ks.core_kpi_threshold_req__c;
                    oppKPIObj.Core_Opp_KPI_Add_Date__c = ks.core_opp_kpi_add_date__c;
                    oppKPIObj.Core_Opp_KPI_Type__c = ks.Core_KPI_Type__c;
                    oppKPIObj.Core_Opportunity_Product_Id__c = ks.core_opp_kpi_product__c;
                    oppKPIObj.Core_Opp_KPI_Product__c = ks.core_opp_kpi_product__c;
                    oppKPIObj.Core_Batch_Time__c = ks.Core_Batch_Time__c;
                    oppKPIObj.name = ks.Core_KPI_Name__c;
                    oppKPIObj.Core_Opportunity_KPI_Batch_ID__c = ks.Core_Batch_ID__c;
                    oppKPIObj.Core_Refresh_Type__c = ks.Core_Refresh_Type__c;
                    oppKPIObj.Core_Opportunity_Product__c = ks.Core_Opportunity_Product_Txt__c;
                    oppKPIObj.Core_TIER__c = ks.Core_TIER__c;
                    oppKPIObj.Core_KPI_Total_Price__c= ks.Core_KPI_Total_Price__c;
                    oppKPIObj.Core_KPI_Quantity__c= ks.Core_KPI_Quantity__c;
                    oppKPIList.add(oppKPIObj);
                    validKPIStagingID.add(ks.id);
                    if (!mapValidKPIStaging.containsKey(ks.Id)) {
                        mapValidKPIStaging.put(ks.Id, ks);
                    }
                }                 
            }
            else{
                invalidKPIStaging.add(ks); 
                invalidKPIStagBatch = ks.Core_Batch_ID__c;   
            }
        }
    }
    /*
    * Method name  : seprateRefreshTypes
    * Description  : 
    * Return Type  : VOID
    * Parameter    : List<Core_KPI_Staging__c> newList, boolean KPIDeltaLoadCheck , boolean KPIFullLoadCheck
    */
    public static void seprateRefreshTypes(List<Core_KPI_Staging__c> newList, boolean KPIDeltaLoadCheck , boolean KPIFullLoadCheck ){
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        map<String, List<Core_KPI_Staging__c>> fullLoadMap = new map<String, List<Core_KPI_Staging__c>>();
        List<Core_KPI_Staging__c> deltaLoadList = new List<Core_KPI_Staging__c>();
        List<Core_KPI_Staging__c> fullLoadList = new List<Core_KPI_Staging__c>();
        List<Core_KPI_Staging__c> syncLoadList = new List<Core_KPI_Staging__c>();
        Set<String> batchId = new Set<String>();
        Boolean endOfFile = false;
        List<Core_KPI_FullRefresh_Check__c> csList = new List<Core_KPI_FullRefresh_Check__c>();
        for(Core_KPI_Staging__c stagerec: newList){
            if(stagerec.Core_Refresh_Type__c == 'incremental' ){
                deltaLoadList.add(stagerec);
            }
            if(stagerec.Core_Refresh_Type__c == 'full' && stagerec.Core_Status__c == 'New'){
                if(stagerec.Core_End_Of_File__c){
                    endOfFile = true;
                }
                if(stagerec.Core_Begin_Of_File__c){
                
               
                    Core_KPI_FullRefresh_Check__c csOrg = Core_KPI_FullRefresh_Check__c.getOrgDefaults();
                    Core_KPI_FullRefresh_Check__c csUser = Core_KPI_FullRefresh_Check__c.getInstance();
                    if(!csOrg.IsFullRefresh__c){
                         csOrg.IsFullRefresh__c = true;
                         csList.add(csOrg);
                    }
                    if(!csUser.IsFullRefresh__c){
                         csUser.IsFullRefresh__c = true;
                         csList.add(csUser);
                    }

                    
                }
                batchId.add(stagerec.Core_Batch_ID__c);
                fullLoadList.add(stagerec);               
                
            }
            //TWC3123-961 start
            if(stagerec.Core_Refresh_Type__c == 'sync' && stagerec.Core_Status__c == 'New'){
                if(stagerec.Core_End_Of_File__c){
                    endOfFile = true;
                }
                batchId.add(stagerec.Core_Batch_ID__c);
                syncLoadList.add(stagerec);               
                
            }
            //TWC3123-961 end
        }//end of For Loop.
        upsert csList;
        //TWC3123-691- adding changes to modify code to accomodate Opportunities having more than 100,200 KPIs.
        Set<String> DeltaLoadSyncBatchid = new Set<String>();
        Set<String> DeltaLoadAsyncBatchid = new Set<String>();
        if(deltaLoadList.size()>0 && mapFunctionalityNameTriggerExecution.containsKey('KPIDeltaLoad') && mapFunctionalityNameTriggerExecution.get('KPIDeltaLoad').Core_Active__c){
            for(Core_KPI_Staging__c dList : deltaLoadList){
                if(dList.Core_End_Of_File__c && dList.Core_Record_Count__c <= 100){
                    DeltaLoadSyncBatchid.add(dList.Core_Batch_ID__c);
                }
                else if (dList.Core_End_Of_File__c && dList.Core_Record_Count__c > 100){
                    DeltaLoadAsyncBatchid.add(dList.Core_Batch_ID__c);
                }
            }
            if(DeltaLoadSyncBatchid.size()>0){
                List<Core_KPI_Staging__c> newDeltaList = getRecords(DeltaLoadSyncBatchid);
                Core_KPIDeltaLoadHandler.handleDeltaLoad(newDeltaList,KPIDeltaLoadCheck);
            }
            if(DeltaLoadAsyncBatchid.size()>0){
                handleAsyncDeltaLoad(DeltaLoadAsyncBatchid,KPIDeltaLoadCheck);
            }
        }
        // end TWC3123-691
        if(fullLoadList.size()>0 && endOfFile && mapFunctionalityNameTriggerExecution.containsKey('KPIFullLoad') && mapFunctionalityNameTriggerExecution.get('KPIFullLoad').Core_Active__c){
            Core_KPIFullLoadHandler.handleFullLoad(fullLoadList,batchId, KPIFullLoadCheck );
        }
         //TWC3123-961 start
        if(syncLoadList.size()>0 && endOfFile && mapFunctionalityNameTriggerExecution.containsKey('KPISyncLoad') && mapFunctionalityNameTriggerExecution.get('KPISyncLoad').Core_Active__c){
            Core_KPISyncLoadHandler.handleSyncLoad(syncLoadList,batchId, KPIFullLoadCheck );
        }
         //TWC3123-961 end
    }
    
    /*
    * Method name  : handleAsyncDeltaLoad
    * Description  : this method is used when the KPI stage record count is more than 100. this we are doing to more CPU time while processing data.
    * Return Type  : VOID
    * Parameter    : Set<String> DeltaLoadAsyncBatchid,boolean KPIDeltaLoadCheck
    */
    @future
    public static void handleAsyncDeltaLoad(Set<String> DeltaLoadAsyncBatchid,boolean KPIDeltaLoadCheck) {
        List<Core_KPI_Staging__c> newDeltaList = getRecords(DeltaLoadAsyncBatchid);
        Core_KPIDeltaLoadHandler.handleDeltaLoad(newDeltaList,KPIDeltaLoadCheck);
    }
    
    /*
    * Method name  : getRecords
    * Description  : this method returns the records based on the batch id.
    * Return Type  : List<Core_KPI_Staging__c>
    * Parameter    : Set<String> DeltaLoadBatchid
    */
    public static List<Core_KPI_Staging__c> getRecords(Set<String> DeltaLoadBatchid){
        List<Core_KPI_Staging__c> DeltaList = [select id,Core_Batch_ID__c,Core_Batch_Time__c,Core_Begin_Of_File__c,Core_End_Of_File__c,
                                                Core_KPI_Achieved__c,core_opp_kpi_add_date__c,Core_KPI_Record_ID__c,core_kpi_threshold_req__c,
                                                Core_KPI_Total_Price__c,Core_KPI_Name__c,Core_KPI_Quantity__c,Core_KPI_Type__c,Core_Opportunity_Stage_Txt__c,
                                                Core_Opportunity_ID_Txt__c,Core_Is_Delete__c,Core_Retry_Counter__c ,Core_Opportunity_Product_Txt__c, Core_TIER__c, core_opp_kpi_product__c,Core_Refresh_Type__c,Core_Status__c,Core_Threshold_Met__c
                                                from Core_KPI_Staging__c where
                                                Core_Batch_ID__c IN: DeltaLoadBatchid];
        return DeltaList;
    }
}