/*
* Class Name : PCC_FlowApexActionCntroller
* Description : This is the controller class for Create_opportunity_and_related_Records flow
* Developer : DINESH
* Version  : 1.0
* Created Date : 12/6/2024
**/
public with sharing class PCC_FlowApexActionCntroller {

    @InvocableMethod(label='Process Deal Lines' description='Process DR Lines and Create Opportunity Line items' category='Other')
    public static List<ActionOutput> processDealLines(List<Core_Design_Registration__c> dealRecord){
        // Validate input
        Opportunity opportunity = new Opportunity();
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        List<Core_Design_Registration_Product__c> drpLines = new List<Core_Design_Registration_Product__c>();
        boolean isPDIEligible = false;
        try{

        if (dealRecord == null || dealRecord.isEmpty()) {
            return new List<ActionOutput>{generateErrorOutput('dealRecord is empty or null')};
        }

        // Retrieve the opportunity related to the deal record
        opportunity = retrieveOpportunity(dealRecord[0].Id);
        if (opportunity == null) {
            return new List<ActionOutput>{generateErrorOutput('No opportunity found for the given deal record')};
        }

        // Retrieve the products associated with the deal record
        drpLines = retrieveProducts(dealRecord[0].Id);
        // Check if any product is eligible for PDI
        isPDIEligible = checkProductEligibility(drpLines);

        // Collect product IDs
        Set<Id> productIds = new Set<Id>();
        for (Core_Design_Registration_Product__c product : drpLines) {
            productIds.add(product.Core_Product_Id__c);
        }

        // Get Pricebook Entries for the products
        Map<Id, PricebookEntry> productToPriceBook = getPricebookEntries(productIds);
        if (!productToPriceBook.keySet().containsAll(productIds)) {
            return new List<ActionOutput>{generateErrorOutput('Invalid products selected!')};
        }

        // Create Opportunity Line Items
        oliList = createOpportunityLineItems(drpLines, opportunity.Id, productToPriceBook);
        // Process Opportunity Line Items and update DRP records
        String errorMessage = processOLIandUpdateDRP(oliList, drpLines);

        // Generate the output for the flow
        return new List<ActionOutput>{generateActionOutput(opportunity.Id, drpLines, oliList, isPDIEligible, !String.isBlank(errorMessage), errorMessage)};
        }catch(Exception ex){
            return new List<ActionOutput>{generateActionOutput(opportunity.Id, drpLines, oliList, isPDIEligible, !String.isBlank(ex.getMessage()), ex.getMessage())};
        }
    }

    // Retrieves the opportunity related to the given deal record ID
    private static Opportunity retrieveOpportunity(Id dealRecordId) {
        List<Opportunity> opportunityList = [SELECT Id, Pricebook2.Name FROM Opportunity WHERE Core_Design_Registration_Id__c = :dealRecordId ORDER BY CreatedDate DESC LIMIT 1];
        return opportunityList.isEmpty() ? null : opportunityList[0];
    }

    // Retrieves the products associated with the given deal record ID
    private static List<Core_Design_Registration_Product__c> retrieveProducts(Id dealRecordId) {
        return [SELECT Id, Core_Design_Registration_Id__c, PCC_Programs_Eligible__c, Core_Product_Id__c, Core_Design_Registration_Id__r.Core_Opportunity_Id__c, Core_Full_Year_Qty__c, Core_Target_Resale_Amt__c FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c = :dealRecordId and Core_Design_Product_Status_Nm__c='Approved' and Core_Active_Status__c=true];
    }

    // Checks if any product in the list is eligible for PDI
    private static boolean checkProductEligibility(List<Core_Design_Registration_Product__c> drpLines) {
        for (Core_Design_Registration_Product__c product : drpLines) {
            if (String.isNotBlank(product.PCC_Programs_Eligible__c) && product.PCC_Programs_Eligible__c.contains('PDI')) {
                return true;
            }
        }
        return false;
    }

    // Retrieves active Pricebook Entries for the given product IDs from the 'Partner Price Book'
    public static Map<Id, PricebookEntry> getPricebookEntries(Set<Id> productIds) {
        List<PricebookEntry> priceBookEntryRecords = [SELECT Id, Name, Product2Id, Product2.Name FROM PricebookEntry WHERE Pricebook2.Name = 'Partner Price Book' AND IsActive = true AND Product2Id IN :productIds];
        Map<Id, PricebookEntry> productToPriceBook = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : priceBookEntryRecords) {
            productToPriceBook.put(pbe.Product2Id, pbe);
        }
        return productToPriceBook;
    }

    // Creates Opportunity Line Items from the given DRP lines and price book entries
    public static List<OpportunityLineItem> createOpportunityLineItems(List<Core_Design_Registration_Product__c> drpLines, Id opportunityId, Map<Id, PricebookEntry> productToPriceBook) {
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        for (Core_Design_Registration_Product__c product : drpLines) {
            if (productToPriceBook.containsKey(product.Core_Product_Id__c)) {
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = opportunityId;
                oli.Core_Design_Registration_Product_Id__c = product.Id;
                oli.UnitPrice = product.Core_Target_Resale_Amt__c;
                oli.Quantity = product.Core_Full_Year_Qty__c;
                // oli.TotalPrice = oli.UnitPrice * oli.Quantity;
                oli.Product2Id = product.Core_Product_Id__c;
                oli.Failed_DDR_RecordID__c = product.Core_Design_Registration_Id__c;
                oli.PricebookEntryId = productToPriceBook.get(product.Core_Product_Id__c).Id;
                oliList.add(oli);
            }
        }
        return oliList;
    }

    // Processes Opportunity Line Items and updates the associated DRP records
    public static String processOLIandUpdateDRP(List<OpportunityLineItem> oliList, List<Core_Design_Registration_Product__c> drpList) {
        String errorMessage = '';

        // Get locked record type ID
        String recordTypeId = Schema.SobjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Locked').getRecordTypeId();

        // Insert Opportunity Line Items and collect errors if any
        Database.SaveResult[] oliResultList = Database.insert(oliList, true);
        Integer counter = 0;
        List<Core_Design_Registration_Product__c> updateDrpList = new List<Core_Design_Registration_Product__c>();

        for (Database.SaveResult sr : oliResultList) {
            if (sr.isSuccess()) {
                Core_Design_Registration_Product__c drprec = new Core_Design_Registration_Product__c();
                drprec.Id = oliList[counter].Core_Design_Registration_Product_Id__c;
                drprec.Core_Opportunity_Product_Id__c = sr.getId();
                drprec.Core_Locked_Ind__c = true;
                drprec.RecordTypeId = recordTypeId;
                updateDrpList.add(drprec);
                
            } else {
                for (Database.Error error : sr.getErrors()) {
                    errorMessage += 'Exception occurred while creating Opportunity Line Items: Fields: ' + error.getFields() + ' Message: ' + error.getMessage() + '\n';
                }
            }
            counter++;
        }

        // If no errors occurred during OLI insertion, update DRP records
        if (String.isBlank(errorMessage)) {
            Database.SaveResult[] drpResList = Database.update(updateDrpList, true);
            for (Database.SaveResult sr : drpResList) {
                if (!sr.isSuccess()) {
                    for (Database.Error error : sr.getErrors()) {
                        errorMessage += 'Exception occurred while updating DR Line Items: Fields: ' + error.getFields() + ' Message: ' + error.getMessage() + '\n';
                    }
                }
            }
        }
        return errorMessage;
    }

    // Generates an ActionOutput object with the provided details
    private static ActionOutput generateActionOutput(Id opportunityId, List<Core_Design_Registration_Product__c> drpList, List<OpportunityLineItem> oliList, boolean isPDIEligible, boolean errorOccurred, String errorMessage) {
        ActionOutput ao = new ActionOutput();
        ao.Opportunity = opportunityId;
        ao.drpList = drpList;
        ao.oliInsertedList = oliList;
        ao.isPDIEligibleProduct = isPDIEligible;
        ao.errorOccured = errorOccurred;
        ao.error = errorMessage;
        return ao;
    }

    // Generates an ActionOutput object to indicate an error
    private static ActionOutput generateErrorOutput(String errorMessage) {
        ActionOutput ao = new ActionOutput();
        ao.errorOccured = true;
        ao.error = errorMessage;
        return ao;
    }

    // Inner class to hold the output data for the invocable method
    public class ActionOutput {
        @InvocableVariable public Id Opportunity;
        @InvocableVariable public List<Core_Design_Registration_Product__c> drpList = new List<Core_Design_Registration_Product__c>();
        @InvocableVariable public List<OpportunityLineItem> oliInsertedList = new List<OpportunityLineItem>();
        @InvocableVariable public boolean isPDIEligibleProduct;
        @InvocableVariable public boolean errorOccured;
        @InvocableVariable public String error;
    }
}