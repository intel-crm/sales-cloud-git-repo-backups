@isTest
public class Core_RestAPI_OpportunityDtlsWrapper_Test {
    static testmethod void testOpportunityDetails(){
        Core_RestAPI_OpportunityDetailsWrapper.OpportunityDetails opp = new Core_RestAPI_OpportunityDetailsWrapper.OpportunityDetails();
        opp.accountName = null;
        opp.opportunityName = null;
        opp.opportunityId = null;
        opp.opportunityRegion = null;
        //opp.designRegisrationName = null;
        //opp.designRegisrationId = null;
        opp.stage = null;       
        opp.decisionDate = null;
        opp.probability = null;
        //opp.endCustomerCountry = null;
        opp.opportunityType = null;
        opp.productSegment = null;
        opp.productApplication = null;
        opp.verticalMarket = null;
        opp.amount = null;
        opp.technicalOwner = null;
        opp.opportunityOwner = null;
        opp.competitiveArchitecture = null;
        opp.statusUpdate = null;        
        opp.architectureConversion = null;
        opp.LossCancelRegion = null;
        opp.LossCancelDetails = null;
        opp.description = null;
        //opp.quantityCount = null;
        //opp.IntelPlatform = null;        
        opp.volume = null;
        opp.firstCustomerShipDate = null;
        opp.productionEndDate = null;
        opp.manufacturingRegion = null;
        opp.areIntelItemsUsedForMINDS = null;
        opp.complianceComments = null;
        opp.complianceStatus = null;
        opp.complianceSubStatus = null;
        opp.createdDate = null;
        opp.lastModifiedDate = null;
        opp.createdBy = null;
        opp.lastModifiedBy = null;

        Core_RestAPI_OpportunityDetailsWrapper.OpportunityProducts oppProd = new Core_RestAPI_OpportunityDetailsWrapper.OpportunityProducts();
        oppProd.opportunityProductId = null;
        oppProd.product = null;
        oppProd.status = null;
        oppProd.quantity = null;
        oppProd.competitor  = null;
        oppProd.competitorProduct  = null;
        oppProd.salesPrice  = null;
        oppProd.lossCancelRegion  = null;
        oppProd.createdDate = null;
        oppProd.lastModifiedDate = null;
        oppProd.createdBy = null;
        oppProd.lastModifiedBy = null;
    }
}