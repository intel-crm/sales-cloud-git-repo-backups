/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_OpportunityDetailsWrapper 
* Version     : 1.0 
* Created Date: 05 Aug 2023
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Biswa			         05/08/2023             Wrapper Class for OpportunityDetails

Description => Wrapper Class includes all sections details
*****************************************************************************************************************************************/
public with sharing class Core_RestAPI_OpportunityDetailsWrapper {
	public class OpportunityDetails  {
        public String accountName {set;get;}
        public String opportunityName {set;get;}
        public String opportunityId {set;get;}
        public String opportunityRegion {set;get;}
        public String designRegistrationName {set;get;}
        public String designRegistrationId {set;get;}
        public String stage {set;get;}       
        public Date decisionDate {set;get;}
        public Decimal probability {set;get;}
        //public String endCustomerCountry {set;get;}
        public String opportunityType {set;get;}
        public String productSegment {set;get;}
        public String productApplication {set;get;}
        public String verticalMarket {set;get;}
        public Decimal amount {set;get;}
        public String technicalOwner {set;get;}
        public String opportunityOwner {set;get;}
        public String competitiveArchitecture {set;get;}
        public String statusUpdate {set;get;}        
        public Boolean architectureConversion {set;get;}
        public String LossCancelRegion {set;get;}
        public String LossCancelDetails {set;get;}
        public String description {set;get;}
        //public String quantityCount {set;get;}
        //public String IntelPlatform {set;get;}        
        public Decimal volume {set;get;}
        public Date firstCustomerShipDate {set;get;}
        public Date productionEndDate {set;get;}
        public String manufacturingRegion {set;get;}
        public String areIntelItemsUsedForMINDS {set;get;}
        public String complianceComments {set;get;}
        //public String MINDSQuestionnaire {set;get;}
        public String complianceStatus {set;get;}
        public String complianceSubStatus {set;get;}
        public DateTime createdDate {set;get;}
        public DateTime lastModifiedDate {set;get;}
        public String createdBy {set;get;}
        public String lastModifiedBy {set;get;}
        public List<OpportunityProducts> opportunityProducts {set;get;}
    }
    
    public class OpportunityProducts {
        public String opportunityProductId {get; set;}
        public String designRegistrationProductId {get; set;}
        public String product {get; set;}
        public String status {get; set;}
        public Decimal quantity {set;get;}
        public String competitor {get;set;}
        public String competitorProduct {get;set;}
        public Decimal salesPrice {get;set;}
        public Decimal totalPrice {get;set;}
        public String lossCancelRegion {get;set;}
        //public String lossCancelDetails {get;set;}
        public DateTime createdDate {set;get;}
        public DateTime lastModifiedDate {set;get;}
        public String createdBy {set;get;}
        public String lastModifiedBy {set;get;}
    }
}