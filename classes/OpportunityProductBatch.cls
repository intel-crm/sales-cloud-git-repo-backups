/********************************************************************************************************************
Apex Class Name:  OpportunityProductBatch
Version     : 1.0 
Created Date: 20 Feb 2024
Function    : Batch class to update Core_PW_Amount__c for each Opportunity if the size exceeds 200 Line items
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*Samiksha Sharma           2/20/24                Initial Creation
*********************************************************************************************************************/

public class OpportunityProductBatch implements Database.Batchable<sObject> {

    // Variable to hold the Opportunity Line Items for processing
    private List<OpportunityLineItem> oppLineItems;

    // Constructor to initialize the list of Opportunity Line Items
    public OpportunityProductBatch(List<OpportunityLineItem> oppLineItems) {
        this.oppLineItems = oppLineItems;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('#SS' + Database.Query('SELECT Id, OpportunityId, Core_Production_Win_Total_Price__c FROM OpportunityLineItem WHERE Id IN :oppLineItems'));
        return Database.getQueryLocator([SELECT Id, OpportunityId, Core_Production_Win_Total_Price__c FROM OpportunityLineItem WHERE Id IN :oppLineItems]);
       
    }

    public void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope) {
        Map<Id, Decimal> opportunityIdToTotalPWAmount = new Map<Id, Decimal>();

        // Aggregate total PW amount for each Opportunity
        for (OpportunityLineItem oli : scope) {
            if (!opportunityIdToTotalPWAmount.containsKey(oli.OpportunityId)) {
                opportunityIdToTotalPWAmount.put(oli.OpportunityId, 0);
                System.debug('#SS' +opportunityIdToTotalPWAmount);
            }
            if (oli.Core_Production_Win_Total_Price__c != null) {
                opportunityIdToTotalPWAmount.put(oli.OpportunityId, opportunityIdToTotalPWAmount.get(oli.OpportunityId) + oli.Core_Production_Win_Total_Price__c);
                System.debug('#SS' +opportunityIdToTotalPWAmount);
            }
        }

        // Update Core_PW_Amount__c for each Opportunity
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (Id oppId : opportunityIdToTotalPWAmount.keySet()) {
            opportunitiesToUpdate.add(new Opportunity(Id = oppId, Core_PW_Amount__c = opportunityIdToTotalPWAmount.get(oppId)));
        }
		System.debug('#SS' +opportunitiesToUpdate);
        update opportunitiesToUpdate;
    }

    public void finish(Database.BatchableContext BC) {
    }
}