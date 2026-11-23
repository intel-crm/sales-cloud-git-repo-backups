/*********************************************************************************************************************
Class Name    : Sales_SapIntegrationRetryBatch
Version       : 1.0
Created Date  : Feb 2021
Function      : This is batch class on order will pick all the records whoose status is resubmission in progress and schedule by Sales_SapIntegrationUtility.
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           19-Feb-2021              US862553: Implementation of US870456 : Retry mechanism for failed Orders from SFDC to SAP via new Integration
* *********************************************************************************************************************/
global with sharing class Sales_SapIntegrationRetryBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{
    private static final string ORIGIN = 'Sales_SapIntegrationUtility';
    private static final String SALES_STATUS_RESUBMISSION = 'SAP Resubmission In Progress';
    private static final String RETRY_MASTER_COUNT = 'Resubmit_to_SAP_Count';
    global set<id> allOrderIds=new set<id>();
    public Database.QueryLocator start(Database.BatchableContext context) {
        Integer retryCountForSubmitToSap = Sales_SapIntegrationUtility.getRetryMasterData(RETRY_MASTER_COUNT);
        return Database.getQueryLocator([
            SELECT Id,Sales_Retry_Count__c,Sales_status__c
            FROM Order
            WHERE Sales_Retry_Count__c<=:retryCountForSubmitToSap
            And Sales_status__c=:SALES_STATUS_RESUBMISSION
        ]);
    }
    public void execute(Database.BatchableContext context, List<Order> orders) {
        List<String> orderIdList = new List<String>();
        for(Order order:orders){
            allOrderIds.add(order.Id);
            orderIdList.add(order.Id);
        }
        Sales_SapIntegrationUtility.updateSapOrderStatus(orderIdList);
    }
    public void finish(Database.BatchableContext param1) {
        List<Order> orderUpdateList = new List<Order>();
        Integer masterRetryCount = Sales_SapIntegrationUtility.getRetryMasterData(RETRY_MASTER_COUNT);
        for(Order order:[Select Id,Sales_Retry_Count__c,Sales_status__c from Order where Id IN:allOrderIds]){
            if(order.Sales_status__c==SALES_STATUS_RESUBMISSION && order.Sales_Retry_Count__c<masterRetryCount){
                order.Sales_Retry_Count__c = order.Sales_Retry_Count__c+1;
                orderUpdateList.add(order);
            }
        }
        if(orderUpdateList.size()>0){
            List<Database.SaveResult> saveResultList = Database.update(orderUpdateList,false);
            Sales_CreateLogRecords.createLogRecords(saveResultList,orderUpdateList,ORIGIN);
        }
    }
}