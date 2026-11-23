public class Pricing_RestAPI_QuoteQLIDetailsWrapper {
    public class QuoteWrapperDetails {
        public QuoteRecordDetails quoteDetails {set; get;}
        public String quoteId {set;get;}
    }
    public class QuoteRecordDetails {
        public String referenceRequestID {set;get;}
        public String projectName {set;get;}
        public String pricingStartDate {set;get;}
        public String pricingEndDate {set;get;}
        public String intelSalesRepEmail {set;get;}
        public String intelAccountExecutiveEmail {set;get;}
        public String industryTechnicalSpecialistEmail {set;get;}
        public String primaryContactEmail {set; get;}
        public String endCustomerCountry {set;get;}
        public String endCustomer {set;get;}
        public String unifiedEndCustomerId {set;get;}
        public String proposalDueDate {set;get;}
        public String intelResponseRequestedDate {set;get;}
        public String application {set;get;}
        public String secondaryContact {set;get;}
        public String additionalQuoteLetterRecipients {set;get;}
        public List<QuoteLineRecordDetails> quoteLines {set;get;}
        public List<Pricing_RestAPI_QuotesUtilityV2.QuoteComment> quoteComments {set;get;}
    }
    
    public class QuoteLineWrapperDetails {
        public String quoteId {set;get;}
        public List<QuoteLineRecordDetails> quoteLines {set;get;}
    }
    public class QuoteLineRecordDetails {
        public String productId {set;get;}
        public String quoteLinePricingEndDate {set;get;}
        public String quoteLinePricingStartDate {set;get;}
        public String quotelineReferenceID {set;get;}
        public String writeInProduct {set;get;}
        public String systemModel {set;get;}
        public Decimal noOfSystems {set;get;}
        public Decimal noOfCPUsPerSystem {set;get;}
        public Decimal singleSystemPrice {set;get;}
        public Decimal customerStdUnitPrice {set;get;}
        public Decimal requestedDiscountUnitPrice {set;get;}
        public Decimal additionalDiscount {set;get;}
        public String competitorName {set;get;}
        public String competitorSystemModel {set;get;}
        public String competitorProductId {set;get;}
        public String competitorWriteInProduct {set;get;}
        public Decimal competitorNoOfSystems {set;get;}
        public Decimal competitorNoOfCPUsPerSystem {set;get;}
        public Decimal competitorSingleSystemPrice {set;get;}
        public Decimal competitorAdditionalDiscount {set;get;}
        public String additionalComment {set;get;}
        public List<Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics> performanceMetrics {set;get;}
        public String unifiedEndCustomer {set;get;}
        
        //won/lost wrapper
        public String quotelineId {set;get;}
        public String status {set;get;}
        public String wonLostComments {set;get;}
        public String lostReason {set;get;}
        
        //change request wrapper
        public Decimal newRequestedDiscountUnitPrice {set;get;}
        public Decimal newRequestedPrice {set;get;}
        public Decimal newQuantity {set;get;}
    }

    public class PerformanceMetricsWrapperDetails {
        public String quoteLineId {set;get;}
        public List<Pricing_RestAPI_QuotesUtilityV2.PerformanceMetrics> performanceMetrics {set;get;}
    }
    
    public class QuoteCommentWrapperDetails {
        public String quoteId {set;get;}
        public List<Pricing_RestAPI_QuotesUtilityV2.QuoteComment> quoteComments {set;get;}
    }

}