/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_QuoteDetailsWrapperV2 
* Version     : 2.0 
* Created Date: 09 May 2022
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         09/05/2022              Wrapper Class for QuoteDetails Ver-2

Description => Wrapper Class includes all four sections details
*****************************************************************************************************************************************/
public with sharing class Pricing_RestAPI_QuoteDetailsWrapperV2 {
    
    public class QuoteDetails {
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
        public QuoteLines quoteLines {set;get;}
        public List<QuoteComments> quoteComments {set;get;}
        public String partnerName {set;get;}
        public Boolean volumeExceptionQuote {set;get;}
        public String endCustomerUrl {set;get;}
        
    }
    
    public class QuoteDetailsClient  {
        public String quoteId {set;get;}
        public String quoteName {set;get;}
        public String endCustomer {set;get;}
        public String unifiedEndCustomer {set;get;}
        public String unifiedEndCustomerId {set;get;}
        public String projectName {set;get;}
        public Date proposalDueDate {set;get;}
        public Date intelResponseRequestedDate {set;get;}
        public Date pricingStartDate {set;get;}
        public Date pricingEndDate {set;get;}
        public String intelSalesRepEmail {set;get;}
        public String intelAccountExecutiveEmail {set;get;}
        public String endCustomerCountry {set;get;}
        public String endCustomerRegion {set;get;}
        public String marketSegment {set;get;}
        public String primaryContactName {set;get;}
        public String referenceRequestID {set;get;}
        public String secondaryContact {set;get;}
        public String quoteType {set;get;}
        public String quoteStatus {set;get;}
        public String additionalQuoteLetterRecipients {set;get;}
        public QuoteLinesClient quoteLinesClient {set;get;}
        public List<QuoteComments> quoteComments {set;get;}
        public String partnerName {set;get;}
        public Boolean volumeExceptionQuote {set;get;}
        public String endCustomerUrl {set;get;}
    }
    
    public class QuoteLines {
        public List<QuoteLineCPU> DataCenterCPU {set;get;}
        public List<QuoteLineSSD> OptaneSSD {set;get;}
        public List<QuoteLinePMem> OptanePMem {set;get;}
        public List<QuoteLineEthernet> Ethernet {set;get;}
        public List<QuoteLineGPU> DataCenterGPU {set;get;}
    }
    
    public class QuoteLineCPU {
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
        public Decimal newRequestedPrice {get;set;}//
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
        public Decimal singleSystemPricePoint {get;set;}
        public Decimal customerStdUnitPrice {get;set;}
        public String quotelineprogramtype {set;get;}
        public Decimal requestedUnitPrice {get;set;}
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
        public Datetime firstSubmittedDate {get;set;}
        public Datetime approvedDate {get;set;}
        public String lastSubmittedById {get;set;}
        public String lastSubmittedByName {get;set;}
        public String additionalComments {get; set;}
        public String referenceQuoteLineNumberId {get;set;}
        public String referenceQuoteLineNumber {get;set;}
		public String sourceQuoteLineId{get;set;}
        public String rejectionReason {get;set;}
        public String createdByEmail {get;set;}
        public String lostReason {get;set;}
        public String rejectionComments {get;set;}
        public String coreCount {get;set;}
        public String consumptionPlatform {get;set;}
        public String consumptionSalesGeo {get;set;}
        public String consumptionCountry {get;set;}
        public String consumptionRegion {get;set;}
        public String consumptionSegment {get;set;}
        public Decimal payableQuantity {get;set;}
        public String tdp {get;set;}
        public List<PerformanceMetricsWrapper> performanceMetrics {set;get;}
    }
    
    public class QuoteLineSSD {
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
        public Decimal newRequestedPrice {get;set;}//      
        public Decimal approvedECAPPrice {get;set;}
        public String dealID {set;get;}
        public Decimal newQuantity {get;set;}
        public Boolean readyForReview{get;set;}
        public Date quoteLinePricingEndDate {get; set;}
        public Date quoteLinePricingStartDate {get; set;}
        public String productId {get; set;}
        public String writeInProduct {get; set;}
        public String productName {get;set;}
        public String familyName {get; set;}
        public Decimal quantity {get;set;}
        public Decimal requestedUnitPrice {get;set;}
        public Decimal requestedDiscountUnitPricePerGB {get;set;}
        public String competitorName {get; set;}
        public String competitorProduct {get; set;}
        public Decimal competitorSingleSystemPricePoint {get;set;}
        public Decimal competitorUnitPricePerGB {get;set;}
        public Decimal competitorDensity {get;set;}
        public String volumeByQuarterAndReasoning {get; set;}
        public Datetime lastSubmittedDate {get;set;}
        public Datetime firstSubmittedDate {get;set;}
        public Datetime approvedDate {get;set;}
        public String lastSubmittedById {get;set;}
        public String lastSubmittedByName {get;set;}
        public String additionalComments {get; set;}
        public String referenceQuoteLineNumberId {get;set;}
        public String referenceQuoteLineNumber {get;set;}
		public String sourceQuoteLineId{get;set;}
        public String rejectionReason {get;set;}
        public String createdByEmail {get;set;}
        public String lostReason {get;set;}
        public String rejectionComments {get;set;}
        public String consumptionPlatform {get;set;}
        public String consumptionSalesGeo {get;set;}
        public String consumptionCountry {get;set;}
        public String consumptionRegion {get;set;}
        public String consumptionSegment {get;set;}
        public Decimal payableQuantity {get;set;}
        public Decimal density {get; set;}
        public String tdp {get;set;}
    }
    
    public class QuoteLinePMem {
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
        public Decimal newRequestedPrice {get;set;}     
        public Decimal approvedECAPPrice {get;set;}
        public String dealID {set;get;}
        public Decimal newQuantity {get;set;}
        public Boolean readyForReview{get;set;}
        public Date quoteLinePricingEndDate {get; set;}
        public Date quoteLinePricingStartDate {get; set;}
        public String productId {get; set;}
        public String productName {get;set;}
        public Decimal quantity {get;set;}
        public Decimal requestedUnitPrice {get;set;}
        public String writeInProduct {set;get;}
        public String systemModel {set;get;}
        public Decimal noOfSystems {set;get;}
        public Decimal noOfUnitsPerSystem {set;get;}
        public String competitorName {get; set;}
        public Decimal competitorSingleSystemPricePoint {get;set;}
        public Decimal competitorDensity {get;set;}
        public String pairedCPU {set;get;}
        public Decimal dramDensity {set;get;}
        public Decimal noOfDRAMPerSystem {set;get;}
        public Decimal competitorQuantity {set;get;}
        public Decimal noOfCPUsPerSystem {set;get;}
        public String serverIntegration {set;get;}
        public String workload {set;get;}
        public String pocTestingResults {set;get;}
        public Datetime lastSubmittedDate {get;set;}
        public Datetime firstSubmittedDate {get;set;}
        public Datetime approvedDate {get;set;}
        public String lastSubmittedById {get;set;}
        public String lastSubmittedByName {get;set;}
        public String additionalComments {get; set;}
        public String referenceQuoteLineNumberId {get;set;}
        public String referenceQuoteLineNumber {get;set;}
		public String sourceQuoteLineId{get;set;}
        public String sourceQuoteLine{get;set;}
        public Decimal competitorNoOfSystems {set;get;}
        public Decimal competitorNoOfUnitsPerSystem {set;get;}
        public String forecastProductName {set;get;}
        public Decimal requestedDiscountUnitPricePerGB {set;get;}
        public Decimal competitorUnitPricePerGB {set;get;}
        public String rejectionReason {get;set;}
        public String createdByEmail {get;set;}
        public String lostReason {get;set;}
        public Decimal customerStdUnitPrice {get;set;}
        public String rejectionComments {get;set;}
        public String consumptionPlatform {get;set;}
        public String consumptionSalesGeo {get;set;}
        public String consumptionCountry {get;set;}
        public String consumptionRegion {get;set;}
        public String consumptionSegment {get;set;}
        public Decimal payableQuantity {get;set;}
        public Decimal density {get; set;}
        public String tdp {get;set;}
    }
    
    public class QuoteLineEthernet {
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
        public Decimal newRequestedPrice {get;set;}      
        public Decimal approvedECAPPrice {get;set;}
        public String dealID {set;get;}
        public Decimal newQuantity {get;set;}
        public Boolean readyForReview{get;set;}
        public Date quoteLinePricingEndDate {get; set;}
        public Date quoteLinePricingStartDate {get; set;}
        public String productId {get; set;}
        public String forecastProductName {set;get;}        
        public String writeInProduct {set;get;}
        public String productName {get;set;}
        public Decimal quantity {get;set;}
        public Decimal requestedUnitPrice {get;set;}
        public String competitorProduct {get; set;}
        public Decimal competitorQuantity {set;get;}
        public Decimal competitorSingleSystemPricePoint {get;set;}
        public Datetime lastSubmittedDate {get;set;}
        public Datetime firstSubmittedDate {get;set;}
        public Datetime approvedDate {get;set;}
        public String lastSubmittedById {get;set;}
        public String lastSubmittedByName {get;set;}
        public String additionalComments {get; set;}
        public String referenceQuoteLineNumberId {get;set;}
        public String referenceQuoteLineNumber {get;set;}
		public String sourceQuoteLineId{get;set;}
        public String rejectionReason {get;set;}
        public String createdByEmail {get;set;}
        public String lostReason {get;set;}
        public String rejectionComments {get;set;}
        public String consumptionPlatform {get;set;}
        public String consumptionSalesGeo {get;set;}
        public String consumptionCountry {get;set;}
        public String consumptionRegion {get;set;}
        public String consumptionSegment {get;set;}
        public Decimal payableQuantity {get;set;}
        public String tdp {get;set;}
    }
    
    public class QuoteLineGPU {
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
        public Date effectivePricingStartDate {get;set;}
        public Date billingEndDate {get;set;}
        public Date billingStartDate {get;set;}
        public String additionalTermsandConditions {get;set;}
        public Decimal newRequestedPrice {get;set;}
        public Decimal competitiveBidDiscount {get;set;}    
        public Decimal approvedECAPPrice {get;set;}
        public String dealID {set;get;}
        public Decimal newQuantity {get;set;}
        public Boolean readyForReview{get;set;}
        public Date quoteLinePricingEndDate {get; set;}
        public Date quoteLinePricingStartDate {get; set;}
        public String productId {get; set;}
        public String productName {get;set;}
        public Decimal quantity {get;set;}
        public String writeInProduct {get; set;}
        public String systemModel {get;set;}
        public Decimal noOfSystems {get;set;}
        public Decimal noOfCPUsPerSystem {get; set;}
        public Decimal singleSystemPricePoint {get;set;}
        public Decimal noOfGPUs {get;set;}
        public Decimal noOfGPUsPerSystem {get;set;}
        public String pairedCPU {get;set;}
	    public String writeInPairedCPU {get;set;}
        public Decimal customerStdUnitPrice {get;set;}
        public String quotelineprogramtype {set;get;}
        public Decimal requestedUnitPrice {get;set;}
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
        public Decimal competitorNoOfSystems {get; set;}
        public Decimal competitorNoOfGPUsPerSystem {get; set;}
        public Decimal competitorNoOfGPUs {get;set;}
        public String competitorPairedCPU {get;set;}
        public Decimal competitorQuantity {get;set;}
        public Decimal competitorSingleSystemPrice {get; set;}
        public Decimal competitorAdditionalDiscount {get;set;}
        public Decimal competitorTotalWithoutDiscount {get;set;}
        public Decimal netCompetitorBidPrice {get;set;}
        public Datetime lastSubmittedDate {get;set;}
        public Datetime firstSubmittedDate {get;set;}
        public Datetime approvedDate {get;set;}
        public String lastSubmittedById {get;set;}
        public String lastSubmittedByName {get;set;}
        public String additionalComments {get; set;}
        public String referenceQuoteLineNumberId {get;set;}
        public String referenceQuoteLineNumber {get;set;}
		public String sourceQuoteLineId{get;set;}
        public String rejectionReason {get;set;}
        public String createdByEmail {get;set;}
        public String lostReason {get;set;}
        public String rejectionComments {get;set;}
        public String consumptionPlatform {get;set;}
        public String consumptionSalesGeo {get;set;}
        public String consumptionCountry {get;set;}
        public String consumptionRegion {get;set;}
        public String consumptionSegment {get;set;}
        public Decimal payableQuantity {get;set;}
        public Decimal competitorNoOfCPUsPerSystem {get;set;}
        public String pairedCPUId {get;set;}
        public String tdp {get;set;}
    }

    public class QuoteLinesClient{
        public List<QuoteLineClient> Client {set;get;}
    }
    
    public class QuoteLineClient{
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
        public Date effectivePricingStartDate {get;set;}
        public Date billingEndDate {get;set;}
        public Date billingStartDate {get;set;}
        public String additionalTermsandConditions {get;set;}
        public Decimal newRequestedPrice {get;set;}   
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
        public Decimal singleSystemPricePoint {get;set;}
        public Decimal customerStdUnitPrice {get;set;}
        public Decimal requestedUnitPrice {get;set;}
        public String formFactor {get;set;}
        public String competitorName {get; set;}
        public String competitorSystemModel {get; set;}
        public String competitorProductId {get; set;}
        public String competitorProductName {get; set;}
        public String writeInCompetitorProduct  {get; set;}
        public String competitorProductProvider {get;set;}
        public Decimal competitorSingleSystemPricePoint {get; set;}
        public Datetime lastSubmittedDate {get;set;}
        public Datetime firstSubmittedDate {get;set;}
        public Datetime approvedDate {get;set;}
        public String lastSubmittedById {get;set;}
        public String lastSubmittedByName {get;set;}
        public String additionalComments {get; set;}
        public String referenceQuoteLineNumberId {get;set;}
        public String referenceQuoteLineNumber {get;set;}
		public String sourceQuoteLineId{get;set;}
        public String rejectionReason {get;set;}
        public String createdByEmail {get;set;}
        public String lostReason {get;set;}
        public String rejectionComments {get;set;}
        public String coreCount {get;set;}
        public String consumptionPlatform {get;set;}
        public String consumptionSalesGeo {get;set;}
        public String consumptionCountry {get;set;}
        public String consumptionRegion {get;set;}
        public String consumptionSegment {get;set;}
        public Decimal payableQuantity {get;set;}
        public String tdp {get;set;}
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