/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Batch_OpportunityKPIInsert
Version     : 1.0 
Created Date: 25 JAN 2021
Function    : Batch to create new KPIs from Azure
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             01/25/2021              Original Version

*****************************************************************************************************************************************************************************************************/
global class Core_Batch_OpportunityKPIInsert implements Database.Batchable<sObject>,Database.stateful{

    @testVisible
   private static Boolean throwException1 = false;
   @testVisible
   private static boolean throwException2 = false;
    
    List<Core_KPI_Staging__c> NewFullRecBatch = new List<Core_KPI_Staging__c>();
    String batchIDbatch;
    String refreshTypebatch;
    List<Core_KPI_Staging__c> KPIAllFailure = new List<Core_KPI_Staging__c>();
    Integer BatchRecCount=0;
    Integer totalRecords = 0;
    //06-Dec Start
    Integer invalidCount = 0;
    //06-Dec end
    Set<Id> allOpportunityIdSet = new Set<Id>();
    Set<Id> allOpportunityLineItemIdSet = new Set<Id>();
    List<Core_KPI_Staging__c> invalidKPIStaging = new List<Core_KPI_Staging__c>();
    List<Core_KPI_Staging__c> invalidKPIStagingFinal = new List<Core_KPI_Staging__c>();
    List<Core_KPI_Staging__c> isDeleteKPIRecords = new List<Core_KPI_Staging__c>(); //Sync Refresh
    global Core_Batch_OpportunityKPIInsert(String batchID, String refreshType){
        
        batchIDbatch = batchID;
        refreshTypebatch = refreshType;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
         totalRecords = [select count() from Core_KPI_Staging__c where Core_Batch_ID__c=: batchIDbatch and Core_Refresh_Type__c =:refreshTypebatch and Core_Is_Delete__c = false]; // added Core_Is_Delete__c for sync.
         //system.debug('totalrec-->'+totalRecords);                     
        String query = 'select id,Core_Is_Delete__c,Core_Error_Description__c,Core_Retry_Counter__c,Core_Opportunity_Product__c,Core_TIER__c,Core_Batch_ID__c,Core_Batch_Time__c,Core_Begin_Of_File__c,Core_End_Of_File__c,Core_KPI_Achieved__c,core_opp_kpi_add_date__c,Core_KPI_Record_ID__c,core_kpi_threshold_req__c,Core_KPI_Total_Price__c,Core_KPI_Name__c,Core_KPI_Quantity__c,Core_KPI_Type__c,Core_Opportunity_Product_Txt__c,Core_Opportunity_Stage_Txt__c, Core_Opportunity_ID_Txt__c,core_opp_kpi_product__c,Core_Refresh_Type__c,Core_Status__c,Core_Threshold_Met__c from Core_KPI_Staging__c where Core_Batch_ID__c=: batchIDbatch and Core_Refresh_Type__c =:refreshTypebatch';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Core_KPI_Staging__c> newRec){
        
        List<Core_Oppty_KPI_New__c> oppKPIList = new List<Core_Oppty_KPI_New__c>();
        List<Core_KPI_Staging__c> ksList = new List<Core_KPI_Staging__c>(); 
        List<Core_KPI_Staging__c> ksListStatus = new List<Core_KPI_Staging__c>();
        List<Core_KPI_Staging__c> ksListStatusFailure = new List<Core_KPI_Staging__c>();
        Map < ID, Map < String, String > > oppWithBatchId = new Map < ID, Map < String, String > > ();
        List<Core_Opportunity_KPI_Batch_Detail__c> KPIBatchDtls = new List<Core_Opportunity_KPI_Batch_Detail__c>();
        List<Core_Opportunity_KPI_Batch_Detail__c> updatedOppKPiBatchList = new List<Core_Opportunity_KPI_Batch_Detail__c>();
        Map<String, String> latestOppKPIMap = new Map<String, String>();
		Set<Id> errorIdsRemove = new Set<Id>();
        Set<Id> setKsId = new Set<Id>();
        Set<Id> allOpportunityId = new Set<Id>();
        Set<Id> allOpportunityLineId = new Set<Id>();
        try{

            if(Test.isRunningTest()){
                if(throwException1){
                    throw new DMLException('Test DMLException'); 
                }
            }
            
            
        for(Core_KPI_Staging__c staging : newRec){
            allOpportunityId.add(staging.Core_Opportunity_ID_Txt__c);
            allOpportunityLineId.add(staging.Core_Opportunity_Product_Txt__c);
            if (oppWithBatchId.get(staging.Core_Opportunity_ID_Txt__c) == null && staging.Core_Opportunity_Stage_Txt__c != null) {
                oppWithBatchId.put(staging.Core_Opportunity_ID_Txt__c, new map < String, String > { String.valueOf(staging.Core_Opportunity_Stage_Txt__c) => String.valueOf(staging.Core_Batch_ID__c) });
            }
        }
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
                String latestKPI = opp.Id + '~' + opp.StageName;
                if(opp.StageName == 'Design Win' && oppWithBatchId.get(opp.Id).containsKey('Design Win') && latestOppKPIMap.get(latestKPI) == null){
                    Core_Opportunity_KPI_Batch_Detail__c kpiBatch = new Core_Opportunity_KPI_Batch_Detail__c();
                    kpiBatch.Core_Opportunity_ID_Txt__c = opp.Id;
                    kpiBatch.Core_Opportunity_Stage_Txt__c = opp.StageName;
                    kpiBatch.Core_Opportunity_KPI_Batch_ID_Txt__c = oppWithBatchId.get(opp.Id).get('Design Win');
                    KPIBatchDtls.add(kpiBatch);
                }
                if(opp.StageName == 'Production Win' && oppWithBatchId.get(opp.Id).containsKey('Production Win') && latestOppKPIMap.get(latestKPI) == null){
                    Core_Opportunity_KPI_Batch_Detail__c kpiBatch = new Core_Opportunity_KPI_Batch_Detail__c();
                    kpiBatch.Core_Opportunity_ID_Txt__c = opp.Id;
                    kpiBatch.Core_Opportunity_Stage_Txt__c = opp.StageName;
                    kpiBatch.Core_Opportunity_KPI_Batch_ID_Txt__c = oppWithBatchId.get(opp.Id).get('Production Win');
                    KPIBatchDtls.add(kpiBatch);
                }
            }
        }
        for(OpportunityLineItem oppLineItem : allOpportunityLineItemList){
            allOpportunityLineItemIdSet.add(oppLineItem.Id);
        }
        
        for(Core_KPI_Staging__c ks: newRec){
            setKsId.add(ks.Id);
                if(ks.Core_Begin_Of_File__c || ks.Core_End_Of_File__c || ks.Core_Is_Delete__c){ //added Core_Is_Delete__c for sync
                    if(ks.Core_Is_Delete__c){
                        isDeleteKPIRecords.add(ks);
                    }
                    continue;
                }
                else{
                    if(allOpportunityIdSet.contains(ks.Core_Opportunity_ID_Txt__c) && allOpportunityLineItemIdSet.contains(ks.Core_Opportunity_Product_Txt__c)){
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
                        oppKPIObj.Name = ks.Core_KPI_Name__c;
                        oppKPIObj.Core_Opportunity_KPI_Batch_ID__c = ks.Core_Batch_ID__c;
                        oppKPIObj.Core_Refresh_Type__c = ks.Core_Refresh_Type__c;
                        oppKPIObj.Core_KPI_Total_Price__c= ks.Core_KPI_Total_Price__c;
                        oppKPIObj.Core_KPI_Quantity__c= ks.Core_KPI_Quantity__c;
                        oppKPIObj.Core_TIER__c = ks.Core_TIER__c;
                        oppKPIObj.Core_Opportunity_Product__c = ks.Core_Opportunity_Product_Txt__c;
                        oppKPIList.add(oppKPIObj);
                        ksList.add(ks);
                   } 
                   else{
                       invalidKPIStaging.add(ks);
                   }
                }
            }
            
             if(invalidKPIStaging.size()>0 || invalidKPIStaging!= null){
                List<Core_KPI_Staging__c> updateInvalidKPI = new List<Core_KPI_Staging__c>();
                 for( Core_KPI_Staging__c kpi : invalidKPIStaging){
                     Core_KPI_Staging__c invalidKpiStage = new Core_KPI_Staging__c();
                     invalidKpiStage.Id = kpi.Id;
                     invalidKpiStage.Core_Status__c = 'Failure';
                     invalidKpiStage.Core_Old_Record__c = true;
                     invalidKpiStage.Core_Invalid_Record__c = true;
                     invalidCount++;
                     invalidKpiStage.Core_Error_Description__c = 'Invalid Opportunity Id/Opportunity Product Id';
                     updateInvalidKPI.add(invalidKpiStage);
                     errorIdsRemove.add(kpi.Core_Opportunity_ID_Txt__c);
                 }
                invalidKPIStagingFinal.addAll(updateInvalidKPI);
                update updateInvalidKPI;
            }
            if(oppKPIList.size()>0){
                //integer count = 0;
                integer i=0;
                
                Database.SaveResult[] srr = database.insert(oppKPIList,false);
                
               
                for (Database.SaveResult sr : srr) {
                
                    if (sr.isSuccess()) {
                        ++BatchRecCount;
                        Core_KPI_Staging__c kobj = new Core_KPI_Staging__c();
                        
                        kobj.id = ksList[i].id;
                        
                        //kobj.id = mapOppKpIStag.get(sr.getId());
                        kobj.Core_Status__c = 'Success';
                        ksListStatus.add(kobj);
                    }
                    else if (!sr.isSuccess()){
                        // DML operation failed
                        Core_KPI_Staging__c kobjFailed = new Core_KPI_Staging__c();
                        kobjFailed.id = ksList[i].id;
                        //kobjFailed.id = mapOppKpIStag.get(sr.getId());
                        kobjFailed.Core_Status__c = 'Failure';
                        kobjFailed.Core_KPI_Processing_Time__c = Datetime.now().addMinutes(integer.valueof(system.label.Core_New_KPI_Retry_Timer));
                        for(Database.Error err : sr.getErrors()) {
                            kobjFailed.Core_Error_Description__c = err.getMessage()+' --'+ err.getFields();
                        }
                        ksListStatus.add(kobjFailed);
                        ksListStatusFailure.add(kobjFailed);
                        errorIdsRemove.add(ksList[i].Core_Opportunity_ID_Txt__c);
                    }
                    i++;
                }
                //system.debug('kslistupdate--'+ksListStatus); 
                //update ksListStatus;
                
                if(Test.isRunningTest() && throwException2){//TWC3123-5299 added throwException2 in the same line to avoid nested if
                    throw new DmlException('Test Exception');
                }
                
            }
            //22-07-2021
            invalidKPIStagingFinal.addAll(ksListStatusFailure);
            update ksListStatus;
            Map<Id, Core_KPI_Staging__c> ksListStatusMap = new Map<Id, Core_KPI_Staging__c>(ksListStatus);
            List<Core_KPI_Staging__c> stageListFailUpdate = [select id,Core_Status__c,Core_Retry_Counter__c from Core_KPI_Staging__c where id in:ksListStatusMap.keySet()];

            List<Core_KPI_Staging__c> updateEndOfFileStatus = new List<Core_KPI_Staging__c>();
            if(stageListFailUpdate .size()>0){
                for(Core_KPI_Staging__c s:stageListFailUpdate ){
                    if(s.Core_Status__c == 'Failure'){
                        s.Core_Retry_Counter__c = s.Core_Retry_Counter__c+1;
                        updateEndOfFileStatus .add(s);
                    }
                }
                update updateEndOfFileStatus ;
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
                        excep.Core_Error_Description__c=  e.getMessage()+'-'+e.getStackTraceString();
                        //excep.Core_Retry_Counter__c =  KPIStage.Core_Retry_Counter__c+1;                  
                        excepList.add(excep);
                    }
                }
            }
            else{
                for(Core_KPI_Staging__c KPIStage : newRec){
                    //if(KPIStage.Core_Status__c == 'Failure'){
                        Core_KPI_Staging__c excep = new Core_KPI_Staging__c();
                        excep.id=KPIStage.id;
                        excep.Core_Status__c = 'Failure';
                        excep.Core_Error_Description__c= e.getMessage()+'-'+e.getStackTraceString();
                        excep.Core_Retry_Counter__c =  KPIStage.Core_Retry_Counter__c+1;    
                        excep.Core_KPI_Processing_Time__c =  Datetime.now().addMinutes(integer.valueof(system.label.Core_New_KPI_Retry_Timer));               
                        excepList.add(excep);
                    //}
                }
            }
            //system.debug('errorlist-->'+excepList);
            update excepList;
        }
    }
    global void finish(Database.BatchableContext batchcontext){
        List<Core_KPI_Staging__c> ksStatus = [select id,Core_Status__c from Core_KPI_Staging__c where Core_Batch_ID__c =: batchIDbatch and (Core_End_Of_File__c = true or Core_Begin_Of_File__c = true)];
        //22-07-2021
        /*Integer cnt=0;
        if(invalidKPIStagingFinal.size()>0){
            for(Core_KPI_Staging__c kpist: invalidKPIStagingFinal){
                kpist.Core_Error_Description__c.contains('Invalid Opportunity Id/Opportunity Product Id');
                cnt++;
            }
        }*/
        /*system.debug('invalidCount'+invalidCount);
        system.debug('invalidKPIStagingFinal'+invalidKPIStagingFinal.size());*/
        //Sync Refresh Start.
        List<Core_KPI_Staging__c> deleteList = new List<Core_KPI_Staging__c>();
        if(isDeleteKPIRecords.size()>0){
            for(Core_KPI_Staging__c deleteKPI : isDeleteKPIRecords){
                Core_KPI_Staging__c kpiObj = new Core_KPI_Staging__c();
                kpiObj.id = deleteKPI.id;
                kpiObj.Core_Status__c = 'Success';
                deleteList.add(kpiObj);
            }
        }
        update deleteList;
        //Sync Refresh End.
        if(ksStatus.size()>0){
            for(Core_KPI_Staging__c k : ksStatus){
                if(totalRecords == BatchRecCount+2){
                    k.Core_Status__c = 'Success';
                }
                //22-07-2021
                else if(invalidCount==invalidKPIStagingFinal.size()){
                    k.Core_Status__c = 'Success';
                }
                //
                else{
                    k.Core_Status__c = 'Failure';
                }
                
            }
        }
        update ksStatus; 
		
        /*Core_Batch_OpportunityKPIFinalProcess b=new Core_Batch_OpportunityKPIFinalProcess();
        database.executebatch(b,10);*/

        // Changes made to update the Full Refresh check back
        List<Core_KPI_FullRefresh_Check__c> csList = new List<Core_KPI_FullRefresh_Check__c>();
        Core_KPI_FullRefresh_Check__c csUser = Core_KPI_FullRefresh_Check__c.getInstance();
        Core_KPI_FullRefresh_Check__c csOrg = Core_KPI_FullRefresh_Check__c.getOrgDefaults();
        csOrg.IsFullRefresh__c = false;
        csUser.IsFullRefresh__c = false;
        csList.add(csOrg);
        csList.add(csUser);
        if(!Test.isRunningTest()){
            update csList; 
        } 
        
       
        /* List<Core_KPI_FullRefresh_Check__c> FrList = new List<Core_KPI_FullRefresh_Check__c>();
        for(Core_KPI_FullRefresh_Check__c fr: [SELECT id, Name FROM Core_KPI_FullRefresh_Check__c]){
            fr.IsFullRefresh__c = false;
            FrList.add(fr);
        }
        update FrList;*/
    }
}