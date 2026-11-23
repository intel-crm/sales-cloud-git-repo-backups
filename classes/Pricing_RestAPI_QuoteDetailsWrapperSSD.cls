/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_QuoteDetailsWrapperSSD 
* Version     : 1.0 
* Created Date: 04 January 2022
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         04/01/2022              Wrapper Class for QuoteDetails for SSD product

Description => Wrapper Class includes all four sections details
*****************************************************************************************************************************************/
public without sharing class Pricing_RestAPI_QuoteDetailsWrapperSSD {
    
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
        public Date effectivePricingStartDate {get;set;}//
        public Date billingEndDate {get;set;}//
        public Date billingStartDate {get;set;}//
        public String additionalTermsandConditions {get;set;}//
        public Decimal newRequestedDiscountUnitPrice {get;set;}//      
        public Decimal approvedECAPPrice {get;set;}
        public String dealID {set;get;}
        public Decimal newQuantity {get;set;}
        public Boolean readyForReview{get;set;}
        public Date quoteLinePricingEndDate {get; set;}
        public Date quoteLinePricingStartDate {get; set;}
        public String productId {get; set;}
        public String familyName {get; set;}
        public String productName {get;set;}
        public Decimal quantity {get;set;}
        public Decimal requestedDiscountUnitPrice {get;set;}
        public Decimal requestedDiscountUnitPricePerGB {get;set;}
        public String competitorName {get; set;}
        public String competitorProduct {get; set;}
        public Decimal competitorUnitPrice {get;set;}
        public Decimal competitorUnitPricePerGB {get;set;}
        public Decimal competitorDensity {get;set;}
        public String volumeByQuarterAndReasoning {get; set;}
        public Datetime lastSubmittedDate {get;set;}
        public Datetime approvedDate {get;set;}
        public String lastSubmittedById {get;set;}
        public String lastSubmittedByName {get;set;}
        public String additionalComments {get; set;}
        public String referenceQuoteLineNumberId {get;set;}
        public String referenceQuoteLineNumber {get;set;}
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
        public Date effectivePricingStartDate {get;set;}//
        public Date billingEndDate {get;set;}//
        public Date billingStartDate {get;set;}//
        public String additionalTermsandConditions {get;set;}//
        public Decimal newRequestedDiscountUnitPrice {get;set;}//      
        public Decimal approvedECAPPrice {get;set;}
        public String dealID {set;get;}
        public Decimal newQuantity {get;set;}
        public Boolean readyForReview{get;set;}
        public Date quoteLinePricingEndDate {get; set;}
        public Date quoteLinePricingStartDate {get; set;}
        public String productId {get; set;}
        public String productName {get;set;}
        public String familyName {get; set;}
        public Decimal quantity {get;set;}
        public Decimal requestedDiscountUnitPrice {get;set;}
        public Decimal requestedDiscountUnitPricePerGB {get;set;}
        public String competitorName {get; set;}
        public String competitorProduct {get; set;}
        public Decimal competitorUnitPrice {get;set;}
        public Decimal competitorUnitPricePerGB {get;set;}
        public Decimal competitorDensity {get;set;}
        public String volumeByQuarterAndReasoning {get; set;}
        public Datetime lastSubmittedDate {get;set;}
        public Datetime approvedDate {get;set;}
        public String lastSubmittedById {get;set;}
        public String lastSubmittedByName {get;set;}
        public String additionalComments {get; set;}
        public String referenceQuoteLineNumberId {get;set;}
        public String referenceQuoteLineNumber {get;set;}
    }
    
    public class QuoteComments{
        public String question {get;set;}
        public String answer {get;set;}
        public String quoteCommentReferenceId {get;set;}
    }   
}