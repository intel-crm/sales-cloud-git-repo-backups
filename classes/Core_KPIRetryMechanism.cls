/**************************************************************************************
Apex Class Name:  Core_KPIRetryMechanism
Version     : 1.0 
Created Date: 12 JUNE 2020
Function    : Subscribe to the Platform Event.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             06/12/2020              Original Version

*************************************************************************************/
public without sharing class Core_KPIRetryMechanism {
    
    /*************
    * Method name  : retryFailedStagingKPIs
    * Description  : This method reads the attachment body and passes it to the XMLParserHandler.
    * Return Type  : VOID
    * Parameter    : recordid
    *************/
    
    @InvocableMethod
    public static void retryFailedStagingKPIs(List<id> recordId) {
        map<Id,List<Core_Oppty_KPI_New__c>> mapOpptyKPI = new map<Id,List<Core_Oppty_KPI_New__c>>();
        List<Core_KPI_Staging__c> ksFailedList = new List<Core_KPI_Staging__c>();
        List<Core_KPI_Staging__c> ksListStatus  = new List<Core_KPI_Staging__c>();
        Map < ID, Map < String, String > > oppWithBatchId = new Map < ID, Map < String, String > > ();
        List<Core_Opportunity_KPI_Batch_Detail__c> KPIBatchDtls = new List<Core_Opportunity_KPI_Batch_Detail__c>();
        List<Core_Opportunity_KPI_Batch_Detail__c> updatedOppKPiBatchList = new List<Core_Opportunity_KPI_Batch_Detail__c>();
        Map<String, String> latestOppKPIMap = new Map<String, String>();
		Set<Id> errorIdsRemove = new Set<Id>();
        try{
             ksFailedList = [select id,Core_Opportunity_ID_Txt__c, Core_Opportunity_Product_Txt__c, Core_Is_Delete__c, Core_TIER__c, Core_KPI_Total_Price__c, Core_KPI_Quantity__c,
                                         Core_KPI_Achieved__c,Core_KPI_Record_ID__c,Core_Threshold_Met__c,core_kpi_threshold_req__c, Core_Invalid_Record__c,
                                         Core_Batch_Time__c,Core_Refresh_Type__c,Core_Begin_Of_File__c,Core_End_Of_File__c, Core_KPI_Name__c,Core_Opportunity_Stage_Txt__c,
                                         core_opp_kpi_add_date__c,Core_KPI_Type__c,core_opp_kpi_product__c,Core_Batch_ID__c,Core_status__c, Core_Retry_Counter__c
                                         from Core_KPI_Staging__c
                                         where id in:recordId AND Core_Status__c = 'Failure' AND Core_Retry_Counter__c <3 AND Core_Begin_Of_File__c = false AND Core_End_Of_File__c = false AND Core_Invalid_Record__c = false];
             List<Core_KPI_Staging__c> KPIAllFailure = new List<Core_KPI_Staging__c>();
             List<Core_Oppty_KPI_New__c> oppKPIList = new List<Core_Oppty_KPI_New__c>();
			 List<Core_Oppty_KPI_New__c> oppKPISet = new List<Core_Oppty_KPI_New__c>();
             Set<String> setBatchId = new Set<String>();
             Set<Id> oppIdSet =  new Set<Id>();
            for(Core_KPI_Staging__c stag : ksFailedList){
                oppIdSet.add(stag.Core_Opportunity_ID_Txt__c);
                if (oppWithBatchId.get(stag.Core_Opportunity_ID_Txt__c) == null && stag.Core_Opportunity_Stage_Txt__c != null) {
                    oppWithBatchId.put(stag.Core_Opportunity_ID_Txt__c, new map < String, String > { String.valueOf(stag.Core_Opportunity_Stage_Txt__c) => String.valueOf(stag.Core_Batch_ID__c) });
                }
            }
            List<Core_Oppty_KPI_New__c> existingOppKPI = [select id,Core_Batch_Time__c,Core_IsActive__c, Core_KPI_Opportunity__c, Core_Opportunity_KPI_Batch_ID__c from Core_Oppty_KPI_New__c where Core_KPI_Opportunity__c IN :oppIdSet and Core_IsActive__c =true];
            List<Opportunity> allOpportunityList = [SELECT Id,StageName FROM Opportunity WHERE Id IN :oppIdSet];
            for (Core_Opportunity_KPI_Batch_Detail__c batch: [SELECT ID,Core_Opportunity_ID_Txt__c,Core_Opportunity_Stage_Txt__c,Core_Opportunity_KPI_Batch_ID_Txt__c FROM Core_Opportunity_KPI_Batch_Detail__c WHERE Core_Opportunity_ID_Txt__c IN :oppIdSet
                                                              ORDER BY Core_Opportunity_ID_Txt__c
                                                             ]) {
                                                                 String kpiBtch = batch.Core_Opportunity_ID_Txt__c + '~' + batch.Core_Opportunity_Stage_Txt__c;
                                                                 if (latestOppKPIMap.get(kpiBtch) == null) {
                                                                     latestOppKPIMap.put(kpiBtch, batch.Core_Opportunity_KPI_Batch_ID_Txt__c);
                                                                 }
                                                             }
            for(Opportunity opp: allOpportunityList){
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
            for(Core_Oppty_KPI_New__c opptyKPI: existingOppKPI){
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
            for(Core_KPI_Staging__c ks: ksFailedList){
                setBatchId.add(ks.Core_Batch_ID__c); 
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
                    oppKPIObj.Core_TIER__c = ks.Core_TIER__c;
                    oppKPIObj.Core_KPI_Total_Price__c= ks.Core_KPI_Total_Price__c;
                    oppKPIObj.Core_KPI_Quantity__c= ks.Core_KPI_Quantity__c;
                    oppKPISet.add(oppKPIObj);
                    //oppKPIList.add(oppKPIObj);
                }
                if(ks.Core_Is_Delete__c){
                    if(mapOpptyKPI.get(ks.Core_Opportunity_ID_Txt__c)!= null){
                        if(mapOpptyKPI.get(ks.Core_Opportunity_ID_Txt__c).size()>0){
                            List<Core_Oppty_KPI_New__c> oppKPI = mapOpptyKPI.get(ks.Core_Opportunity_ID_Txt__c);
                            for(Core_Oppty_KPI_New__c oppty : mapOpptyKPI.get(ks.Core_Opportunity_ID_Txt__c)){
                                oppty.Core_IsActive__c =false;
                                oppKPISet.add(oppty);
                                //oppKPIList.add(oppty);
                            } 
                        }
                    }   
                }
            }       
     
             if(oppKPISet.size()>0){   
                 oppKPIList.addAll(oppKPISet);
                 Database.UpsertResult[] srr = database.upsert(oppKPIList,false);                  
                 for(Integer i=0; i < ksFailedList.size(); i++) {
                      Database.UpsertResult ur = srr[i];
                      if (ur.isSuccess()) {
                          Core_KPI_Staging__c kobj = new Core_KPI_Staging__c();
                          kobj.id = ksFailedList[i].id;
                          kobj.Core_Status__c = 'Success';
                          ksListStatus.add(kobj);
                      }
                      else{
                          Core_KPI_Staging__c kobjFailed = new Core_KPI_Staging__c();
                          kobjFailed.id = ksFailedList[i].id;
                          kobjFailed.Core_Status__c = 'Failure';
                          kobjFailed.Core_KPI_Processing_Time__c = Datetime.now().addMinutes(integer.valueof(system.label.Core_New_KPI_Retry_Timer));
                          for(Database.Error err : ur.getErrors()) {
                              kobjFailed.Core_Error_Description__c = err.getMessage();
                          }      
                          ksListStatus.add(kobjFailed);
                          errorIdsRemove.add(ksFailedList[i].Core_Opportunity_ID_Txt__c);
                      }
                 
                 }   
                
                update ksListStatus;
                
                List<Core_KPI_Staging__c> KPIStagingList = [select id,Core_Batch_ID__c,Core_Status__c, Core_End_Of_File__c,Core_Retry_Counter__c from Core_KPI_Staging__c where (id in:ksFailedList OR Core_End_Of_File__c = true) AND Core_Batch_ID__c in:setBatchId LIMIT 49999];
                
                 map<String, Set<String>> mapBatchIdStatus = new map<String, Set<String>>();
                 for(Core_KPI_Staging__c kpiStag : KPIStagingList){
                     if(kpiStag.Core_End_Of_File__c == false){
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
                                
                if(KPIStagingList !=null){
                    List<Core_KPI_Staging__c> updateEndOfFileStatus = new List<Core_KPI_Staging__c>();
                    for(Core_KPI_Staging__c sta : KPIStagingList){
                        if(sta.Core_End_Of_File__c == true){
                            if(mapBatchIdStatus.get(sta.Core_Batch_ID__c)!= null){
                                if(mapBatchIdStatus.get(sta.Core_Batch_ID__c).contains('Failure')){
                                    sta.Core_Status__c = 'Failure';
                                    //sta.Core_KPI_Processing_Time__c =  Datetime.now().addMinutes(integer.valueof(system.label.Core_New_KPI_Retry_Timer));
                                    updateEndOfFileStatus.add(sta);
                                
                                }
                                else{
                                    sta.Core_Status__c = 'Success';
                                    updateEndOfFileStatus.add(sta);
                                }
                            }
                        }
                        else if(sta.Core_End_Of_File__c == false && sta.Core_Status__c == 'Failure'){
                             sta.Core_Retry_Counter__c = sta.Core_Retry_Counter__c+1;
                             updateEndOfFileStatus.add(sta);
                         }
                    }
                    update updateEndOfFileStatus;
                }
             
             }
             else{
                for(Core_KPI_Staging__c ks: [select id,Core_Status__c from Core_KPI_Staging__c where id in: ksFailedList]){
                    ks.Core_Status__c = 'Failure';
                        ks.Core_Old_Record__c = true;
                        ks.Core_Invalid_Record__c = true;
                        ks.Core_Error_Description__c = 'Batch ID/Batch time is less than existing records';
                        KPIAllFailure.add(ks);
                }
                update KPIAllFailure;
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
                for(Core_KPI_Staging__c KPIStage : ksFailedList){
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
    
    }