/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_KPIFullLoadHandler
Version     : 1.0 
Created Date: 25 JAN 2021
Function    : Utility methods to handle Full Load
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             01/25/2021              Original Version

*****************************************************************************************************************************************************************************************************/

public without sharing class Core_KPIFullLoadHandler {
    
    /*
    * Method name  : handleFullLoad
    * Description  : 
    * Return Type  : VOID
    * Parameter    : List<Core_KPI_Staging__c> newList,boolean KPIFullLoadCheck
    */
    //public static void handleFullLoad(List<Core_KPI_Staging__c> newList,boolean KPIFullLoadCheck) {
    public static void handleFullLoad(List<Core_KPI_Staging__c> newList,Set<String> batchIDs, boolean KPIFullLoadCheck) {
        KPIFullLoadCheck =false;
        
        try{
            List<Core_KPI_Staging__c> KsList = [select id,Core_Batch_ID__c,Core_Batch_Time__c,Core_Begin_Of_File__c,Core_End_Of_File__c,
                                                Core_KPI_Achieved__c,core_opp_kpi_add_date__c,Core_KPI_Record_ID__c,core_kpi_threshold_req__c,
                                                Core_KPI_Total_Price__c,Core_KPI_Name__c,Core_KPI_Quantity__c,Core_KPI_Type__c,
                                                Core_Opportunity_ID_Txt__c,Core_Is_Delete__c,Core_Retry_Counter__c ,Core_Opportunity_Product_Txt__c, Core_TIER__c, core_opp_kpi_product__c,Core_Refresh_Type__c,Core_Status__c,Core_Threshold_Met__c
                                                from Core_KPI_Staging__c where
                                                Core_Batch_ID__c IN: batchIDs and Core_Refresh_Type__c ='Full'
                                                and id in: newList];
    
            if(KsList.size()>0){
                /*List<Core_KPI_FullRefresh_Check__c> FrList = new List<Core_KPI_FullRefresh_Check__c>();
                for(Core_KPI_FullRefresh_Check__c fr: [SELECT id, Name FROM Core_KPI_FullRefresh_Check__c]){
                    fr.IsFullRefresh__c = true;
                    FrList.add(fr);
                }
                update FrList;*/
                List<Database.Batchable<SObject>> batchJobs = new List<Database.Batchable<SObject>>();
                for(String batchID :batchIDs){
                    batchJobs.add(new Core_Batch_OpportunityKPIDelete(batchID));
                    //database.executeBatch(new Core_Batch_OpportunityKPIDelete(batchID),integer.valueof(system.label.Core_Batch_Full_Inactive_BatchSize));
                }
                for(Database.Batchable<SObject> batchJob : batchJobs){
                database.executeBatch(batchJob,integer.valueof(system.label.Core_Batch_Full_Inactive_BatchSize));
                }
            }
        }
        catch(exception e){
            PMP_Utility.logError(e,'Core_KPIFullLoadHandler.handleFullLoad');
        }
    }
}