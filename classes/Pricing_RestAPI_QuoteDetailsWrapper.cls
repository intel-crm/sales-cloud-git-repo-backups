/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_QuoteDetailsWrapper 
* Version     : 1.0 
* Created Date: 18 November 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         18/11/2020              Wrapper Class for QuoteDetails

Description => Wrapper Class includes all four sections details
*****************************************************************************************************************************************/
public with sharing class Pricing_RestAPI_QuoteDetailsWrapper {
    
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
        public Decimal competitiveBidDiscount {get;set;}//       
        public Decimal approvedECAPPrice {get;set;}
        public String dealID {set;get;}
        public Decimal newQuantity {get;set;}
        public Boolean readyForReview{get;set;}
        public Date quoteLinePricingEndDate {get; set;}
        public Date quoteLinePricingStartDate {get; set;}
        public String productId {get; set;}
        public String productName {get;set;}
        public String processorNumber{get;set;}
        public Decimal quantity {get;set;}
        public String writeInProduct {get; set;}
        public String systemModel {get;set;}
        public Decimal noOfSystems {get;set;}
        public Decimal noOfCPUsPerSystem {get; set;}
        public Decimal singleSystemPrice {get;set;}
        public Decimal customerStdUnitPrice {get;set;}
        public Decimal requestedDiscountUnitPrice {get;set;}
        public Decimal totalBidWithoutDiscount {get;set;}
        public Decimal additionalDiscount {get;set;}
        public Decimal netIntelBidPrice {get;set;}
        public Decimal intelDiscount {get;set;}
        public Decimal customerDiscount {get;set;}
        public Decimal totalIntelDiscount {get;set;}
        public Decimal intelBidDiscount {get;set;}
        public String competitorName {get; set;}
        public String competitorSystemModel {get; set;}
        public String competitorProductId {get; set;}
        public String competitorProductName {get; set;}
        public String writeInCompetitorProduct  {get; set;}
        public String competitorProductProvider {get;set;}
        public Decimal competitorNoOfSystems {get; set;}
        public Decimal competitorNoOfCPUsPerSystem {get; set;}
        public Decimal competitorQuantity {get;set;}
        public Decimal competitorSingleSystemPrice {get; set;}
        public Decimal competitorAdditionalDiscount {get;set;}
        public Decimal competitorTotalWithoutDiscount {get;set;}
        public Decimal netCompetitorBidPrice {get;set;}
        public Datetime lastSubmittedDate {get;set;}
        public Datetime approvedDate {get;set;}
        public String lastSubmittedById {get;set;}
        public String lastSubmittedByName {get;set;}
        public String additionalComments {get; set;}
        public String referenceQuoteLineNumberId {get;set;}
        public String referenceQuoteLineNumber {get;set;}
        public List<PerformanceMetricsWrapper> performanceMetrics {set;get;}
    }
    
    public class QuoteLineDetails {
        public String quoteLineType {get; set;}
        public String quoteId {get; set;}
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
        public Decimal competitiveBidDiscount {get;set;}//       
        public Decimal approvedECAPPrice {get;set;}
        public String dealID {set;get;}
        public Decimal newQuantity {get;set;}
        public Boolean readyForReview{get;set;}
        public Date quoteLinePricingEndDate {get; set;}
        public Date quoteLinePricingStartDate {get; set;}
        public String productId {get; set;}
        public String productName {get;set;}
        public String processorNumber{get;set;}
        public Decimal quantity {get;set;}
        public String writeInProduct {get; set;}
        public String systemModel {get;set;}
        public Decimal noOfSystems {get;set;}
        public Decimal noOfCPUsPerSystem {get; set;}
        public Decimal singleSystemPrice {get;set;}
        public Decimal customerStdUnitPrice {get;set;}
        public Decimal requestedDiscountUnitPrice {get;set;}
        public Decimal totalBidWithoutDiscount {get;set;}
        public Decimal additionalDiscount {get;set;}
        public Decimal netIntelBidPrice {get;set;}
        public Decimal intelDiscount {get;set;}
        public Decimal customerDiscount {get;set;}
        public Decimal totalIntelDiscount {get;set;}
        public Decimal intelBidDiscount {get;set;}
        public String competitorName {get; set;}
        public String competitorSystemModel {get; set;}
        public String competitorProductId {get; set;}
        public String competitorProductName {get; set;}
        public String writeInCompetitorProduct  {get; set;}
        public String competitorProductProvider {get;set;}
        public Decimal competitorNoOfSystems {get; set;}
        public Decimal competitorNoOfCPUsPerSystem {get; set;}
        public Decimal competitorQuantity {get;set;}
        public Decimal competitorSingleSystemPrice {get; set;}
        public Decimal competitorAdditionalDiscount {get;set;}
        public Decimal competitorTotalWithoutDiscount {get;set;}
        public Decimal netCompetitorBidPrice {get;set;}
        public Datetime lastSubmittedDate {get;set;}
        public Datetime approvedDate {get;set;}
        public String lastSubmittedById {get;set;}
        public String lastSubmittedByName {get;set;}
        public String additionalComments {get; set;}
        public String referenceQuoteLineNumberId {get;set;}
        public String referenceQuoteLineNumber {get;set;}
        public List<PerformanceMetricsWrapper> performanceMetrics {set;get;}
    }
    
    public class PerformanceMetricsWrapper{
        public String performanceMetricsId {get; set;}
        public String performanceMetricsUsed {get; set;}
        public Decimal intelScore {get; set;}
        public Decimal compScore {get; set;}
        public Decimal weighting {get; set;}
        public String otherText {get; set;}  
    }
    
    public class PerformanceMetricsDetailWrapper{
        public String performanceMetricsId {get; set;}
        public String performanceMetricsUsed {get; set;}
        public Decimal intelScore {get; set;}
        public Decimal compScore {get; set;}
        public Decimal weighting {get; set;}
        public String quotelineId {get;set;}
        public String quotelineNumber {get;set;}
        public String otherText {get; set;}  
    }
    
    public class QuoteComments{
        public String question {get;set;}
        public String answer {get;set;}
        public String quoteCommentReferenceId {get;set;}
    }
    
    public class QuoteCommentsWithId{
        public String quoteCommentReferenceId {get;set;}
        public String commentId {get;set;}
        public String question {get;set;}
        public String answer {get;set;}
    }
    
    public class QuoteCommentsWithQuoteId{
        public String quoteId {get;set;}
        public String quoteNumber {get;set;}
        public String quoteCommentReferenceId {get;set;}
        public String commentId {get;set;}
        public String question {get;set;}
        public String answer {get;set;}
    }
    
    public class CommentDetails implements Pricing_RestAPI_SuccessContent {
     	public String quoteCommentReferenceId {set;get;}
        public String question {set;get;}
        public CommentDetails(String recId, String ques){
            quoteCommentReferenceId = recId;
            question = ques;
        }
    }
    
}