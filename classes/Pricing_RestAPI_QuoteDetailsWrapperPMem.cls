/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_QuoteDetailsWrapperPMem 
* Version     : 1.0 
* Created Date: 04 March 2022
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         03/04/2022              Wrapper Class for QuoteDetails for PMem product

Description => Wrapper Class for PMem Quote Types that includes Quotes, Quote Lines and Quote Comments section details
*****************************************************************************************************************************************/
public class Pricing_RestAPI_QuoteDetailsWrapperPMem {
    public class QuoteDetails  {
        public String quoteId {set;get;}
        public String quoteName {set;get;}
        public String endCustomer {set;get;}
        public String unifiedEndCustomer {set;get;}
        public String unifiedEndCustomerId {set;get;}
        public String projectName {set;get;}
        public String application {set;get;}
        public Date proposalDueDate {set;get;}
        public Date intelResponseRequestedDate {set;get;}
        public Date pricingStartDate {set;get;}
        public Date pricingEndDate {set;get;}
        public String intelSalesRepEmail {set;get;}
        public String intelAccountExecutiveEmail {set;get;}
        public String endCustomerCountry {set;get;}
        public String endCustomerRegion {set;get;}
        public String primaryContactName {set;get;}
        public String referenceRequestID {set;get;}
        public String secondaryContact {set;get;}
        public String quoteType {set;get;}
        public String quoteStatus {set;get;}
        public String additionalQuoteLetterRecipients {set;get;}
        public List<QuoteLineItems> quoteLineItems {set;get;}
        public List<QuoteComments> quoteComments {set;get;}
    }
    
    public class QuoteLineItems {
        public String quoteLineId {get; set;}
        public String quoteLineNumber {get; set;}
        public String quoteLineStatus {set;get;}
        public Boolean changeRequest {get;set;}
        public Date approvedPricingStartDate {get;set;}
        public Date approvedPricingEndDate {get;set;}
        public Decimal approvedQuantity {get;set;}
        public Date effectivePricingStartDate {get;set;}
        public Date billingEndDate {get;set;}
        public Date billingStartDate {get;set;}
        public String additionalTermsandConditions {get;set;}
        public Decimal newRequestedDiscountUnitPrice {get;set;}     
        public Decimal approvedECAPPrice {get;set;}
        public String dealID {set;get;}
        public Decimal newQuantity {get;set;}
        public Boolean readyForReview{get;set;}
        public Date quoteLinePricingEndDate {get; set;}
        public String productId {get; set;}
        public String productName {get;set;}
        public Decimal quantity {get;set;}
        public Decimal requestedDiscountUnitPrice {get;set;}
        public String writeInProduct {set;get;}
        public String systemModel {set;get;}
        public Decimal noOfSystems {set;get;}
        public Decimal noOfUnitsPerSystem {set;get;}
        public String competitorName {get; set;}
        //public String competitorProduct {get; set;}
        public Decimal competitorUnitPrice {get;set;}
        public Decimal competitorDensity {get;set;}
        //public String volumeByQuarterAndReasoning {get; set;}
        public String pairedCPU {set;get;}
        public Decimal dramDensity {set;get;}
        public Decimal noOfDRAMPerSystem {set;get;}
        public Decimal competitorQuantity {set;get;}
        public Decimal cpuQuantityPerSystem {set;get;}
        public String serverIntegration {set;get;}
        public String workload {set;get;}
        public String pocTestingResults {set;get;}
        public Datetime lastSubmittedDate {get;set;}
        public Datetime approvedDate {get;set;}
        public String lastSubmittedById {get;set;}
        public String lastSubmittedByName {get;set;}
        public String additionalComments {get; set;}
        public String referenceQuoteLineNumberId {get;set;}
        public String referenceQuoteLineNumber {get;set;}
        public Decimal competitorNoOfSystems {set;get;}
        public Decimal competitorNoOfCPUsPerSystem {set;get;}
        public String forecastProductName {set;get;}
        public Decimal requestedDiscountUnitPricePerGB {set;get;}
        public Decimal competitorUnitPricePerGB {set;get;}
    }
    
    public class QuoteLineDetails {
        public String quoteId {get; set;}
        public String quoteLineType {get; set;}
        public String quote {get; set;}
        public String quoteLineId {get; set;}
        public String quoteLineNumber {get; set;}
        public String quoteLineStatus {set;get;}
        public Boolean changeRequest {get;set;}
        public Date approvedPricingStartDate {get;set;}
        public Date approvedPricingEndDate {get;set;}
        public Decimal approvedQuantity {get;set;}
        public Date effectivePricingStartDate {get;set;}
        public Date billingEndDate {get;set;}
        public Date billingStartDate {get;set;}
        public String additionalTermsandConditions {get;set;}
        public Decimal newRequestedDiscountUnitPrice {get;set;}     
        public Decimal approvedECAPPrice {get;set;}
        public String dealID {set;get;}
        public Decimal newQuantity {get;set;}
        public Boolean readyForReview{get;set;}
        public Date quoteLinePricingEndDate {get; set;}
        public String productId {get; set;}
        public String productName {get;set;}
        public Decimal quantity {get;set;}
        public Decimal requestedDiscountUnitPrice {get;set;}
        public String writeInProduct {set;get;}
        public String systemModel {set;get;}
        public Decimal noOfSystems {set;get;}
        public Decimal noOfUnitsPerSystem {set;get;}
        public String competitorName {get; set;}
        //public String competitorProduct {get; set;}
        public Decimal competitorUnitPrice {get;set;}
        public Decimal competitorDensity {get;set;}
        //public String volumeByQuarterAndReasoning {get; set;}
        public String pairedCPU {set;get;}
        public Decimal dramDensity {set;get;}
        public Decimal noOfDRAMPerSystem {set;get;}
        public Decimal competitorQuantity {set;get;}
        public Decimal cpuQuantityPerSystem {set;get;}
        public String serverIntegration {set;get;}
        public String workload {set;get;}
        public String pocTestingResults {set;get;}
        public Datetime lastSubmittedDate {get;set;}
        public Datetime approvedDate {get;set;}
        public String lastSubmittedById {get;set;}
        public String lastSubmittedByName {get;set;}
        public String additionalComments {get; set;}
        public String referenceQuoteLineNumberId {get;set;}
        public String referenceQuoteLineNumber {get;set;}
        public Decimal competitorNoOfSystems {set;get;}
        public Decimal competitorNoOfCPUsPerSystem {set;get;}
        public String forecastProductName {set;get;}
        public Decimal requestedDiscountUnitPricePerGB {set;get;}
        public Decimal competitorUnitPricePerGB {set;get;}
    }
    
    public class QuoteComments{
        public String question {get;set;}
        public String answer {get;set;}
        public String quoteCommentReferenceId {get;set;}
    }   
}