@IsTest
public without sharing class BLD_QuoteLines extends ObjectBuilderBase {
    private static final String DEF_QUOTELINE_STATUS = 'Draft';
    
    public BLD_QuoteLines() {
        this(getNewUnitOfWork());
    }
    
    public BLD_QuoteLines(fflib_SObjectUnitOfWork workUnit) {
        super(SBQQ__QuoteLine__c.SObjectType, workUnit);
    }
    
    private BLD_QuoteLines(SBQQ__QuoteLine__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }
    
    protected override void setDefaultData() {
        setField(SBQQ__QuoteLine__c.Pricing_Status_Nm__c, DEF_QUOTELINE_STATUS);
    }
    
    public BLD_QuoteLines quote(Id quoteId) {
        return(BLD_QuoteLines) setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, quoteId);
    }
    
    public BLD_QuoteLines otherProduct(Id otherProductId) {
        return(BLD_QuoteLines) setField(SBQQ__QuoteLine__c.Pricing_Other_Product_Nm__c, otherProductId);
    }
    
    public BLD_QuoteLines pricingQuoteLineNumber(String pricingQuoteLineNumber) {
        return(BLD_QuoteLines) setField(SBQQ__QuoteLine__c.Pricing_Quote_Line_Number__c, pricingQuoteLineNumber);
    }
    
    public BLD_QuoteLines quotelineStatus(String quotelineStatus) {
        return(BLD_QuoteLines) setField(SBQQ__QuoteLine__c.Pricing_Status_Nm__c, quotelineStatus);
    }
    
    public BLD_QuoteLines pricingIntegrationStatus(String pricingIntegrationStatus) {
        return(BLD_QuoteLines) setField(SBQQ__QuoteLine__c.Pricing_Integration_Status_Nm__c, pricingIntegrationStatus);
    }
    
    public BLD_QuoteLines pricingErrorMessage(String pricingErrorMessage) {
        return(BLD_QuoteLines) setField(SBQQ__QuoteLine__c.Pricing_Error_Messages__c, pricingErrorMessage);
    }
    
    public BLD_QuoteLines pricingSalesRep(Id pricingSalesRep) {
        return(BLD_QuoteLines) setField(SBQQ__QuoteLine__c.Pricing_Sales_Rep__c, pricingSalesRep);
    }
    
    public BLD_QuoteLines createdById(Id createdById) {
        return(BLD_QuoteLines) setField(SBQQ__QuoteLine__c.CreatedById, createdById);
    }   
    
    public BLD_QuoteLines pricingPrimaryContact(Id pricingPrimaryContact) {
        return(BLD_QuoteLines) setField(SBQQ__QuoteLine__c.Pricing_Primary_Contact_Nm__c, pricingPrimaryContact);
    }
    
    public BLD_QuoteLines pricingChangeRequest(Boolean pricingChangeRequest) {
        return(BLD_QuoteLines) setField(SBQQ__QuoteLine__c.Pricing_Change_Request_cb__c, pricingChangeRequest);
    }
    
    public BLD_QuoteLines pricingDealStatus(String pricingDealStatus) {
        return(BLD_QuoteLines) setField(SBQQ__QuoteLine__c.Pricing_Deal_RFQ_Status_Nm__c, pricingDealStatus);
    }
    
    public BLD_QuoteLines pricingDealId(String pricingDealId) {
        return(BLD_QuoteLines) setField(SBQQ__QuoteLine__c.Pricing_Deal_RFQ_Id__c, pricingDealId);
    }
    
    public BLD_QuoteLines pricingApprovedEndDate(Date pricingApprovedEndDate) {
        return(BLD_QuoteLines) setField(SBQQ__QuoteLine__c.Pricing_Approved_End_Date_Dt__c, pricingApprovedEndDate);
    }
}