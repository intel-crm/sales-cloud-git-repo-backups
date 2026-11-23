public class Core_KPIFull_InsertProcess implements Queueable {
    
	private List<Core_KPI_Staging__c> newRec;
    
    public Core_KPIFull_InsertProcess(List<Core_KPI_Staging__c> recordstoInsert) {
        newRec = recordstoInsert;
    }
    
    public void execute(QueueableContext queCont) {
        List<Core_Oppty_KPI_New__c> oppKPIList = new List<Core_Oppty_KPI_New__c>();
        system.debug('newrec-'+newRec.size());
        try{
        for(Core_KPI_Staging__c ks: newRec){
            if(ks.Core_Begin_Of_File__c || ks.Core_End_Of_File__c){
                continue;
            }
            else{
            Core_Oppty_KPI_New__c oppKPIObj = new Core_Oppty_KPI_New__c();
            
            oppKPIObj.Core_KPI_Achieved__c = ks.Core_KPI_Achieved__c;
            oppKPIObj.Core_KPI_Opportunity__c = ks.Core_Opportunity_ID__c;
            oppKPIObj.Core_KPI_Record_Id__c = ks.Core_KPI_Record_ID__c;
            oppKPIObj.Core_KPI_Threshold_Met__c = ks.Core_Threshold_Met__c;
            oppKPIObj.Core_KPI_Threshold_Req__c = ks.core_kpi_threshold_req__c;
            oppKPIObj.Core_Opp_KPI_Add_Date__c = ks.core_opp_kpi_add_date__c;
            oppKPIObj.Core_Opp_KPI_Type__c = ks.Core_KPI_Type__c;
            oppKPIObj.Core_Opportunity_Product_Id__c = ks.core_opp_kpi_product__c;
            oppKPIObj.Core_Opp_KPI_Product__c = ks.core_opp_kpi_product__c;
            
            oppKPIList.add(oppKPIObj);        
            }
        }
        integer count = 0;
        Database.SaveResult[] srr = database.insert(oppKPIList,false);
        for (Database.SaveResult sr : srr) {
            if (sr.isSuccess()) {
                count++;
            }
            else if (!sr.isSuccess()){
            // DML operation failed
            
            }
        }
        Core_KPI_Staging__c ksStatus = [select id,Core_Status__c from Core_KPI_Staging__c where Core_Batch_ID__c =: newRec[0].Core_Batch_ID__c and Core_End_Of_File__c = true];
        if(newRec.size() == count){
        	ksStatus.Core_Status__c = 'Success';
        }
        else{
            ksStatus.Core_Status__c = 'Failure';
        }
        update ksStatus;
        //insert oppKPIList;
        }
        catch(exception e){
            
        }
    }
}