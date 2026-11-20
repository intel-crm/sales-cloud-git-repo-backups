/**************************************************************************************
Apex Class Name:  Core_Opportunity_KPI_Handler_Test
Version     : 1.0 
Created Date: 28/5/2020
Description : Test class for the Core_Opportunity_KPI_Handler class
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket            28/5/2020                   History tracking for new Opportunity KPI Object on insert/update/delete
*************************************************************************************/
public without sharing class Core_New_KPI_History_Handler {
    private static Core_New_KPI_History_Handler instance = null;
    
    public static Core_New_KPI_History_Handler getInstance(){
        if(instance == null){
            instance = new Core_New_KPI_History_Handler();
        }
        return instance;
    }
    
    public void createKpiHistory(List<Core_Oppty_KPI_New__c> kpiList, String actionType){
        List<Core_Opp_KPI_History__c> kpiHistoryList = new List<Core_Opp_KPI_History__c>();
        Core_Opp_KPI_History__c kpiHistory;
        for(Core_Oppty_KPI_New__c oppKpi : kpiList){
            kpiHistory = new Core_Opp_KPI_History__c();
            kpiHistory.Core_Opp_KPI_Achieved_History__c = oppKpi.Core_KPI_Achieved__c;
            kpiHistory.Core_Opp_KPI_Added_Date__c = oppKpi.Core_Opp_KPI_Add_Date__c;
            kpiHistory.Core_Opp_KPI_BU_Owner__c = oppKpi.Core_KPI_BU_Owner__c;
            kpiHistory.Core_Opp_KPI_Description__c= oppKpi.Core_KPI_Description__c;
            kpiHistory.Core_Opp_KPI_Id__c = oppKpi.Id;
            //kpiHistory.Core_Opp_KPI_Last_Updated_Date_History__c= oppKpi.Core_Opp_KPI_Last_Update_Date__c;
            kpiHistory.Core_Opp_KPI_Opportunity_Volume__c= oppKpi.Core_KPI_Volume__c;
            kpiHistory.Core_Opp_KPI_Quantity__c= oppKpi.Core_KPI_Quantity__c;
            kpiHistory.Core_Opp_KPI_Total_Price__c= oppKpi.Core_KPI_Total_Price__c;
            kpiHistory.Core_Opp_KPI_Operation__c = actionType;
            if(!actionType.equalsIgnoreCase('delete')){
                kpiHistory.Core_New_Opportunity_KPI__c = oppKpi.Id;
                //kpiHistory.Core_Opp_KPI_Opportunity_KPI_Name__c = oppKpi.name;
            }
            kpiHistory.Core_Opp_KPI_Opportunity_Name__c= oppKpi.Core_KPI_Opportunity__c;
            kpiHistory.Core_Opp_KPI_Threshold_Met__c = oppKpi.Core_KPI_Threshold_Met__c;
            kpiHistory.Core_Opp_KPI_Threshold_Requirement__c= oppKpi.Core_KPI_Threshold_Met__c;
            kpiHistory.Core_Opp_KPI_Type__c = oppKpi.Core_Opp_KPI_Type__c;
            kpiHistory.Core_Opp_KPI_IsActive__c = oppKpi.Core_IsActive__c;
            kpiHistoryList.add(kpiHistory);
        }
        insert kpiHistoryList;
    }
}