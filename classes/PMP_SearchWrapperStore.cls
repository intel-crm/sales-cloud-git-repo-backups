/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_SearchWrapperStore
* Description : Stores all the wrapper classes used throught the Marketplace.
* Version     : 1.0 
* Created Date: 07-May-2019
* Modification Log :
* Created By  : Tanzanite Team (Infosys)
********************************************************************************************************************************************************************************************************/
public with sharing virtual class PMP_SearchWrapperStore {
    
    public class BreadCrumb{
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String page { get; set; }
        @AuraEnabled public SearchParams searchParams {get; set;}
        @AuraEnabled public String getURL {get; set;}
    }
    
    public class Category {
        @AuraEnabled public String categoryId { get; set; } 
        @AuraEnabled public String categoryDescription { get; set; }
        @AuraEnabled public String categoryName { get; set; }
        @AuraEnabled public String categoryType { get; set; }
        @AuraEnabled public String categoryCtaLink { get; set; }
        @AuraEnabled public Integer count { get; set; }
        @AuraEnabled public List<Category> children { get; set; }
        @AuraEnabled public String parentId { get; set; }
    }
    public class CategorySearchResponse {
        @AuraEnabled public String keyword { get; set; }
        @AuraEnabled public Integer allMarketplaceCount { get; set; }
        @AuraEnabled public Integer allPartnerCount { get; set; }
        @AuraEnabled public Integer allProductCount { get; set; }
        @AuraEnabled public List<Category> partnerCategories { get; set; }
        @AuraEnabled public List<Category> productCategories { get; set; }
        @AuraEnabled public List<Filter> filters { get; set; }  //adding contextual filters with category tree
        @AuraEnabled public Map<String, List<String>> selectedFilters { get; set; } 
        @AuraEnabled public String langCode {get; set;}
        @AuraEnabled public String searchType {get; set;}
        @AuraEnabled public String category {get; set;}
        @AuraEnabled public String tagListId {get; set;}  //Current selected contextual filter's Id
    }
    public class SearchRequest {
        @AuraEnabled public String keyword { get; set; }
        @AuraEnabled public String category { get; set; }
        @AuraEnabled public String specialty  {get; set; }  //Added by Kartik
        @AuraEnabled public String searchType { get; set; }
        @AuraEnabled public String sortField { get; set; }
        @AuraEnabled public String sortDirection { get; set; }
        @AuraEnabled public Map<String, List<String>> selectedFilters { get; set; }   //Fields selected by the end  user in the UI
        @AuraEnabled public Integer currentPage { get; set; }
        @AuraEnabled public Integer pageSize { get; set; }
        @AuraEnabled public String langCode {get; set;}
        @AuraEnabled public String contextualCat {get; set;}
        @AuraEnabled public String tagListId {get; set;}  //Current selected contextual filter's Id
       
    }
    public class Attribute { 
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public List<Types> types { get; set; }
        @AuraEnabled public List<TypeGroup> typeGroupings { get; set; }
        @AuraEnabled public String textBlock { get; set; }
        @AuraEnabled public Boolean secondTierCat{get;set;}
        @AuraEnabled public Boolean isEditable {get; set;}
        @AuraEnabled public EditButton editButton {get; set;}        
        @AuraEnabled public SearchParams search {get;set;}
        
    }
    
    public class EditButton{
        @AuraEnabled public Integer currentStep {get; set;}
    }
    public class TypeGroup{
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public List<Types> types { get; set; }
    }
    public class Types {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String parentId { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String link { get; set; }
        @AuraEnabled public String ancestor { get; set; }
        @AuraEnabled public String ancestorId { get; set; } 
        @AuraEnabled public Boolean secondTierCat { get; set; }
        @AuraEnabled public SearchParams searchParams { get; set; }
    } 
    public class Product {
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String imageUrl { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public Boolean prerelease { get; set; }
        @AuraEnabled public String prerelaseText { get; set; }
        @AuraEnabled public Boolean onlyVisibleToIntel { get; set; }
        @AuraEnabled public Partner partner { get; set; }
        @AuraEnabled public List<Attribute> attributes { get; set; }
        @AuraEnabled public Boolean featured { get; set; }
        @AuraEnabled public Boolean isContactPartnerVisible {get; set;}
        @AuraEnabled public Boolean isGuest {get; set;}
    }
    public class Partner {
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String imageUrl { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Boolean contactByEmail { get; set; }
        @AuraEnabled public Boolean contactByForm { get; set; }
        @AuraEnabled public List<Attribute> attributes { get; set; }
        @AuraEnabled public Boolean isContactPartnerVisible {get; set;}
        @AuraEnabled public String leadLangPreference {get; set;}
        @AuraEnabled public SearchParams search {get;set;}
        @AuraEnabled public Boolean isGuest {get; set;}
        @AuraEnabled public String autoPartnerId {get; set;}
    }
    public class Tag {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public Integer count { get; set; }
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String parent { get; set; }
        @AuraEnabled public List<Tag> children { get; set; }
        @AuraEnabled public String pimId { get; set; }
    }
    public class Filter {
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String name { get; set; } //this value will come as key in selectFilters in search/categorysearchrequest
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public List<Tag> tags { get; set; }
        @AuraEnabled public Integer count { get; set; }
        @AuraEnabled public Boolean showClearLink { get; set; }
        @AuraEnabled public Boolean autoexpand { get; set; }
        
    }
    
    public class SearchResponse {
        @AuraEnabled public String keyword { get; set; }
        @AuraEnabled public String category { get; set; }
        @AuraEnabled public String searchType { get; set; }
        @AuraEnabled public String sortField { get; set; }
        @AuraEnabled public String sortDirection { get; set; }
        @AuraEnabled public Integer currentPage { get; set; }
        @AuraEnabled public Integer pageSize { get; set; }
        @AuraEnabled public Integer totalCount { get; set; }
        @AuraEnabled public Integer totalProductCount { get; set; }
        @AuraEnabled public Integer totalPartnerCount { get; set; }
        @AuraEnabled public List<Product> productResults { get; set; }
        @AuraEnabled public List<Partner> partnerResults { get; set; }
        @AuraEnabled public List<Filter> filters { get; set; }
        @AuraEnabled public List<String> suggestions { get; set; }
        @AuraEnabled public String searchHeading { get; set; }
        @AuraEnabled public String categoryDescription { get; set; }
        @AuraEnabled public String categoryCtaLink { get; set; }
        @AuraEnabled public Map<String, List<String>> selectedFilters { get; set; }
    }
    public class AutoCompleteOption {
        // category, keyword, and searchType determine the search that gets sent to the server
        // when the option is selected on the front end
        @AuraEnabled public Category category { get; set; }
        @AuraEnabled public String keyword { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String searchType { get; set; }
        @AuraEnabled public Id recordId { get; set; }
    }
    
    public class Mobile{
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String link { get; set; }
        @AuraEnabled public String imgUrl { get; set; }
        @AuraEnabled public String page {get; set;}
        @AuraEnabled public SearchParams searchParams {get; set;}
    }
    public class FeaturedProductTab{
        @AuraEnabled public String categoryId { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public SearchParams searchParams { get; set; }
        @AuraEnabled public List<Product> products { get; set; }
        @AuraEnabled public String ctaTitle { get; set; }
        @AuraEnabled public String eventTitle { get; set; }   //View more Event Offerings stays here.
        @AuraEnabled public Boolean featuredPdt {get; set;}
    }
    public class PartnerDetail{
        //Deatils from company Information Object
        @AuraEnabled public String id { get; set; } 
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String tagline {get; set;}
        @AuraEnabled public String introSection { get; set; }
        @AuraEnabled public String moreSection { get; set; }
        @AuraEnabled public Boolean showMoreSection { get; set; }//Added for US600134 by Megha
        @AuraEnabled public String partnerDescription { get;set; }
        @AuraEnabled public List<Promotion> promotion { get; set; }
        @AuraEnabled public List<CategoryTab> categories { get; set; }
        @AuraEnabled public List<PartnerResource> companyResources { get; set; }
       
        
        @AuraEnabled public List<Mobile> mobileList { get; set; }
        //Used for partner card
        @AuraEnabled public Partner partnerDetails { get; set; }
        //For Edit storefront and notification
        @AuraEnabled public String currentStatus {get; set;}
        @AuraEnabled public String publishedStatus {get; set;}
        @AuraEnabled public String partnerType {get; set;}
        @AuraEnabled public Boolean isUpdateRequired {get; set;}
        @AuraEnabled public String statusUpdateDate {get; set;}
        @AuraEnabled public String initialUpdateDate {get; set;}
        //access to edit storefront
        @AuraEnabled public Boolean isSamePartnerUser {get; set;}
        @AuraEnabled public Boolean hasAccess {get; set;}
        @AuraEnabled public Boolean isGuest {get; set;}
        @AuraEnabled public Boolean manageOfferingAccess {get; set;}
        @AuraEnabled public Boolean isIntelAdmin {get; set;}
        //Lead gen access
        @AuraEnabled public Boolean isContactPartnerVisible {get; set;}
        @AuraEnabled public Boolean hasLeadGenAccess {get; set;}
        @AuraEnabled public Boolean isLeadGenLimited {get; set;}
        @AuraEnabled public LeadGenSettings leadSettings {get; set;}
        
        @AuraEnabled public String leadLangPreference {get; set;}
        @AuraEnabled public String mdaId {get; set;}
        
        //For Benefit 
        @AuraEnabled public Boolean showCompanyResourceAndArticle {get; set;}
        @AuraEnabled public Boolean showCompanyResourceAndArticleforEnhanced {get; set;}   
        
        //Added by Subash for guided setup and a welcome note US620593
        @AuraEnabled public Boolean isMarkettingSpecialist {get; set;}
        @AuraEnabled public Boolean isPartnerAdmin {get; set;}
        @AuraEnabled public Boolean showEnhancedPopup {get; set;}
        @AuraEnabled public Boolean isOfferingEditor {get; set;}
         
        //Added by Megha as part of US619896
         @AuraEnabled public Boolean isLdrOeEmployee {get; set;}
        
        //End
        
       
    }
    
    public class CategoryTab{
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String viewAllLabel { get; set; }
        @AuraEnabled public String viewAllLinkUrl { get; set; }
        @AuraEnabled public String iconUrl { get; set; }
        @AuraEnabled public Integer count { get; set; }
        @AuraEnabled public List<Product> entries { get; set; }
        @AuraEnabled public SearchParams searchParams { get; set; }
    }
    
    public class PartnerResource{
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String linkUrl { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public Boolean openInNewTab { get; set; }
    }
    public class Promotion{
        @AuraEnabled public String imageUrl { get; set; }
        @AuraEnabled public String imagePosition { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String body { get; set; }
        @AuraEnabled public String ctaLink { get; set; }
        @AuraEnabled public String ctaLabel { get; set; }
        @AuraEnabled public SearchParams searchParams { get; set; }
    }
    public class Listing {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String imgUrl { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String descriptionLink { get; set; }
        @AuraEnabled public String descriptionLinkText { get; set; }
        @AuraEnabled public String descriptionLinkTarget { get; set; }
        @AuraEnabled public String page { get; set; }
        @AuraEnabled public SearchParams searchParams { get; set; } 
        @AuraEnabled public SearchType searchType { get; set; }
        @AuraEnabled public Boolean isIcon { get; set; }
        
    }
    public class SearchParams{
        @AuraEnabled public String cat { get; set; } //category
        @AuraEnabled public String PartnerProgram {get; set;}//Partner Program
        @AuraEnabled public String objectApiName {get; set;}  
        @AuraEnabled public String recordId {get; set;} 
        @AuraEnabled public String q { get; set; }   //search term
        @AuraEnabled public String page { get; set; } //current page (1,2,3)
        @AuraEnabled public String type { get; set; } //search type ('all', 'product', 'partner')
        @AuraEnabled public String dir { get; set; }  //sort direction ('asc' / 'desc')
        @AuraEnabled public String field { get; set; } //sort field
        @AuraEnabled public Map<String,List<String>> selectedFilters { get; set; } //filters
        @AuraEnabled public Boolean contextualCat {get; set;}
        @AuraEnabled public String specialty {get;set;}  //Specialty
        @AuraEnabled public String reg { get; set; } //region
        
    }
    public class SearchType{
        @AuraEnabled public String type { get; set; }
    }
    public class UserDetails {
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String jobTitle { get; set; }
        @AuraEnabled public String companyName { get; set; }
        @AuraEnabled public String country { get; set; }
        @AuraEnabled public String state { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public String email { get; set; }   
        @AuraEnabled public Double volume {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public Date deliveryDate {get;set;}
       
        @AuraEnabled public String offeringURL { get; set; }
        @AuraEnabled public String leadSource { get; set; }
        @AuraEnabled public String sfdcCampaignID { get; set; }
        @AuraEnabled public String leadConversionPoint { get; set; }
        @AuraEnabled public String marketingTacticID { get; set; }
        @AuraEnabled public String sourceID { get; set; }
        @AuraEnabled public String partnerProgramSegment { get; set; }
        @AuraEnabled public String sessionId {get; set;}
        
    }
    
     public class FormDataSaveRequest{
       
        @AuraEnabled public DescriptionData descriptionData {get; set;}
        
        @AuraEnabled public List<Option> regionOptions {get; set;}
         
        @AuraEnabled public List<String> regionsSelected {get; set;} //Added by Nikhil
        @AuraEnabled public List<String> applicationsSelected {get; set;}
        @AuraEnabled public List<String> industriesSelected {get; set;}
         
        @AuraEnabled public List<Resource> resources {get; set;}
        @AuraEnabled public String status {get; set;}
        @AuraEnabled public String admin {get; set;}         
    }
    
    public class FormData{
       
        @AuraEnabled public Boolean isLocked {get; set;}
        //logo step-1
        @AuraEnabled public Boolean logoCheck {get; set;}
        @AuraEnabled public ImageWrapper logo  {get; set;}
        @AuraEnabled public String workingCopyId {get; set;}
        
        //desc and tag step-2
        @AuraEnabled public DescriptionData descriptionData {get; set;}
        
        //application, industry,region step-3
        
        
        //Added by Nikhil
        @AuraEnabled public List<Option> regionOptions {get; set;}
        @AuraEnabled public List<String> regionsSelected {get; set;}
        //resource step-4
        @AuraEnabled public ResourceData resourceData {get; set;}
        
        //POC
        @AuraEnabled public List<Option> industryOptions {get; set;}
        @AuraEnabled public List<String> industriesSelected {get; set;}
        
        //Application step-6
        @AuraEnabled public List<Option> applicationOptions {get; set;}
        @AuraEnabled public List<String> applicationsSelected {get; set;}
        
        //admin review step-7
        @AuraEnabled public Boolean isPublishedCopyDraft {get; set;}
        @AuraEnabled public String currentStatus {get; set;}
        @AuraEnabled public string submittedBy { get; set; }
        @AuraEnabled public string submittedOn { get; set; }
        @AuraEnabled public string admin { get; set; }
        @AuraEnabled public List<Options> adminList { get; set; }
        @AuraEnabled public List<Options> statusList { get; set; }
    }
    
    public class Resource{
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public String type {get; set;}
        @AuraEnabled public String url {get; set;}
    }
    public class ImageWrapper {
        public String id { get; set; }
        public String url { get; set; }
        public String title { get; set; }
        public Integer size { get; set; }
    }

    public class Logo{
        @AuraEnabled public String src { get; set; }
        @AuraEnabled public String filename { get; set; }
        @AuraEnabled public String filesize { get; set; }
    }
    
    public class DescriptionData{
        @AuraEnabled public String language {get; set;}
        @AuraEnabled public String tagline {get; set;}
        @AuraEnabled public String description {get; set;}
        @AuraEnabled public List<Options> languageOptions {get; set;}
        @AuraEnabled public Boolean languageDisabled {get; set;}
    }
    
    
    
    public class ResourceData{
        @AuraEnabled public List<Options> resourceTypes {get; set;}
        @AuraEnabled public List<Resource> resources {get; set;}
    }
        
    
    
    public class Options{
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public Boolean selected {get; set;}
    }
    
    public class Option{
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public List<Option> children {get; set;}
        @AuraEnabled public List<Option> options {get; set;}
        @AuraEnabled public Boolean isCategory {get;set;}
        @AuraEnabled public Boolean isPartnerProgram {get;set;}
    }
    
    public class ArticleData{
        @AuraEnabled public String viewAllLabel { get; set; }
        @AuraEnabled public List<Article> articleList { get; set; }
    }
    public class Article{
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String link { get; set; }
        @AuraEnabled public String publishedDate { get; set; }
    }
    
    
    public class LanguagePreference{
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public Boolean selected {get; set;}
    }
    
    public class LeadGenSettings{
        @AuraEnabled public Boolean enableLeadGeneration {get; set;}
        @AuraEnabled public Boolean limitToPartners { get; set; }
        @AuraEnabled public List<Options> languagePreference {get; set;} 
    }
    
    public class MdaInfo{
        @AuraEnabled public String mdaId {get; set;}
        @AuraEnabled public String businessSegment {get; set;}
    }
    
    //Added by Subash for US601910
    public class AutoCompleteOptionForPartnerAndOffering{
        @AuraEnabled public List<AutoCompleteOption> partnerOptions {get; set;}
        @AuraEnabled public List<AutoCompleteOption> offeringOptions {get; set;}
    }
    
    public class SeoCat{
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public Integer categoryLevel {get; set;}
        @AuraEnabled public String url {get; set;} 
        @AuraEnabled public String objectApiName {get; set;}
    }
}