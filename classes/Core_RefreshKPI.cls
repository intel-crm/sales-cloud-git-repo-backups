public without sharing class Core_RefreshKPI {
    List<opportunity> opplist = new List<opportunity>();
    Public Boolean ShowpageStartMsg{get;set;}
    Public Boolean ShowpageProgressMsg{get;set;}
    public Core_RefreshKPI(ApexPages.StandardSetController controller) {
        ShowpageStartMsg = false;
        ShowpageProgressMsg =false;
    }
    public void autoRun() {  
       
        String id = ApexPages.currentPage().getParameters().get('id');
        Opportunity opp = new opportunity();
        opp.id = id;
        opplist.add(opp);
        List<core_kpi_staging__c> KsList= [select id from core_kpi_staging__c where Core_Opportunity_ID_Txt__c=: ApexPages.currentPage().getParameters().get('id') and (Core_Batch_ID__c = '0' or Core_Status__c = 'New') and createddate = today order by createddate desc limit 1];
        if(KsList.isEmpty()){
            Core_OpportunityHandler.createOppJSONInsert(opplist);
            core_kpi_staging__c obj = new core_kpi_staging__c();
            obj.Core_Opportunity_ID_Txt__c = id;
            obj.Core_Batch_ID__c = '0';
            ShowpageStartMsg =true;
            insert obj;
        }
        else {
            ShowpageProgressMsg =true;
        } 
    }  
    // Code we will invoke when user clicks on back button.
    public PageReference back() {
       return new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
    }
    
    /***************************************************************************************************** 
    Method Name: displayMessage
    @return  :  Void
    Created By: Sanket Mahajan                   
    Date: 03 June, 2021                  
    ******************************************************************************************************/
    @AuraEnabled
    public static wrkpi checkKPIRefreshProcessing(String rId){
        wrkpi wr = new wrkpi();
        String msg = '';

        String lastSuccessBatch = '' ;
        Set<String> failedBatches = new Set<String>();
        boolean currentBatchSuccess = true ;
        String dateFormat = 'MM/dd/yyyy hh:mm a';
                
        core_kpi_staging__c dummyStagingRecord ;
        Map<String,List<core_kpi_staging__c>> mapBatchToStagingRecords = new Map<String,List<core_kpi_staging__c>>();
        for(core_kpi_staging__c stgKPI : [select id, Core_Status__c , Core_Refresh_Type__c, Core_Batch_ID__c, createddate, core_end_of_file__c from core_kpi_staging__c where Core_Opportunity_ID_Txt__c=:rId order by createddate desc]){
        
             // This is to find if there is dummy stage record already, to find out if any sync request already been sent
             if(stgKPI.Core_Batch_ID__c == '0'){
                dummyStagingRecord = stgKPI;
            }
            

            if(stgKPI.Core_Batch_ID__c!='0' ){

                if(stgKPI.Core_Status__c == 'Success' ){
                    if(stgKPI.Core_Batch_ID__c != lastSuccessBatch && !failedBatches.contains(stgKPI.Core_Batch_ID__c)){
                        
                        if(!failedBatches.contains(lastSuccessBatch) && lastSuccessBatch!= ''){
                            break;
                        }

                        lastSuccessBatch = stgKPI.Core_Batch_ID__c;
                        
                    }

                }else{ 
                        lastSuccessBatch = '';
                        failedBatches.add(stgKPI.Core_Batch_ID__c);
                    }
                   
                }

                
                if(mapBatchToStagingRecords.containsKey(stgKPI.Core_Batch_ID__c)){
                    mapBatchToStagingRecords.get(stgKPI.Core_Batch_ID__c).add(stgKPI);
                }else{
                    if(!mapBatchToStagingRecords.containsKey(stgKPI.Core_Batch_ID__c)){
                        mapBatchToStagingRecords.put(stgKPI.Core_Batch_ID__c,new List<core_kpi_staging__c>{stgKPI});
                    }
                }
            }


        // get the latest batch id to get the latest sync records
        Set<String> batches = mapBatchToStagingRecords.keySet();
        List<String> listBatches = new List<STring>();
        listBatches.addAll(batches);

        if(dummyStagingRecord!=null){  
            if(lastSuccessBatch!=''){
                List<core_kpi_staging__c> listSuccessStage = mapBatchToStagingRecords.get(lastSuccessBatch);
                core_kpi_staging__c lastSuccessStage = listSuccessStage[0];
                wr.lastRefreshDate = lastSuccessStage.createddate.format(dateFormat);
            }
            wr.msg = msg+System.Label.Core_KPI_Refresh_On;
        } else if(!listBatches.isEmpty()){
            List<core_kpi_staging__c> listKPIstg = mapBatchToStagingRecords.get(listBatches[0]);
            boolean success = true;
            boolean inprogress = false;

            core_kpi_staging__c successStagingRec;
            for(core_kpi_staging__c stgKPI : listKPIstg){
                successStagingRec = stgKPI;
                if(stgKPI.Core_Status__c=='Success'){
                    success = true;
                }else if (stgKPI.Core_Status__c=='New' || stgKPI.core_status__c =='Processing'){
                    inprogress = true;
                    success = false;
                    break;
                }else{
                    success = false;
                    break;
                }

            }
            if(success && !inprogress){
                wr.lastRefreshDate = successStagingRec.createddate.format(dateFormat);
            }else if(inprogress){
                // to display the last success record
                if(lastSuccessBatch!=''){
                    List<core_kpi_staging__c> listSuccessStage = mapBatchToStagingRecords.get(lastSuccessBatch);
                    core_kpi_staging__c lastSuccessStage = listSuccessStage[0];
                    wr.lastRefreshDate = lastSuccessStage.createddate.format(dateFormat);
                }

                wr.msg = msg+System.Label.Core_KPI_Refresh_On;
            }else{

                if(lastSuccessBatch!=''){
                    List<core_kpi_staging__c> listSuccessStage = mapBatchToStagingRecords.get(lastSuccessBatch);
                    core_kpi_staging__c lastSuccessStage = listSuccessStage[0];
                    wr.lastRefreshDate = lastSuccessStage.createddate.format(dateFormat);
                }

                wr.showFailed= true;
                wr.msg = msg+System.Label.Core_Is_KPI_Failed;
            }
        }
        
        
        return wr;
    }


    public static void deleteDummyRefreshRecord(List<Core_KPI_Staging__c> listKpiStagingRecs){
        // get the list of opportunity Id for KPI staging records received from AZURE
        Set<Id> oppIds = new Set<Id>();
        for(Core_KPI_Staging__c stgKpi :listKpiStagingRecs ){
            if(stgKpi.Core_Batch_ID__c!='0'){
                 oppIds.add(stgKPI.Core_Opportunity_ID_Txt__c);
            }
        }

        // if dummy staging records got inserted - Nothing to delete 
        if(oppIds.isEmpty()){
            return;
        }

        //Query the dummy staging records related to the opp KPI just received from AZURE
        List<Core_KPI_Staging__c> listDummyStgRecs = new List<Core_KPI_Staging__c>();

        for(Core_KPI_Staging__c stgKpi : [select id from Core_KPI_Staging__c where Core_Opportunity_ID_Txt__c in : oppIds and Core_Batch_ID__c = '0' ]){
            listDummyStgRecs.add(stgKpi);
        }

        if(!listDummyStgRecs.isEmpty()){
            delete listDummyStgRecs;
        }

    }

    public class wrkpi{
        @AuraEnabled
        public string msg = '';
        @AuraEnabled
        public string lastRefreshDate= null;
        @AuraEnabled
        public boolean showFailed= false;
        
        
    }
 
}