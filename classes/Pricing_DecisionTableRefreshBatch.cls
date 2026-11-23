/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-07-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_DecisionTableRefreshBatch  implements Database.Batchable<sObject>{

    public Database.querylocator start(Database.BatchableContext bc){

        return Database.getQueryLocator([SELECT Id, Name,Pricing_Quote_Type__c, Pricing_End_Date__c, Pricing_Region_Nm__c, Pricing_Form_Factor__c, Pricing_Server_Deal_Type_Nm__c FROM Pricing_Approval_Price_Rules__c]);

    }
    public void execute(Database.BatchableContext bc, List<sObject> scope){

        try {
                Flow.Interview decisionTableFlow = Flow.Interview.createInterview('Pricing_Decision_Table_Refresh_Flow_From_Batch',new Map<String, Object>());
                decisionTableFlow.start();
            } catch (Exception e) {
                Pricing_Tender_Utility.logError(e);
            }
    }
    public void finish(Database.BatchableContext bc){

    }
}