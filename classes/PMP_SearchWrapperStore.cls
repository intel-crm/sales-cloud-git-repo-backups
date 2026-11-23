/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_SearchWrapperStore
* Description : Stores all the wrapper classes used throught the Marketplace.
* Version     : 1.0 
* Created Date: 07-May-2019
* Modification Log :
* Created By  : Tanzanite Team (Infosys)
********************************************************************************************************************************************************************************************************/
public with sharing virtual class PMP_SearchWrapperStore {
   
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
        
    public class OffSpecWrapper{
        @AuraEnabled public String localSpecName{get; set;}
        @AuraEnabled public String localSpecValueName{get; set;}
        @AuraEnabled public String specificationId{get; set;}
        @AuraEnabled public String ancestorId{get; set;}
    }

    public class OffCatWrapper implements Comparable{
       public String localName{get; set;}
       public String ancestorId{get; set;}
       public Integer compareTo(Object ObjToCompare) 
        {
            return localName.CompareTo(((OffCatWrapper)ObjToCompare).localName);
        }
    }

    public class media{
        @AuraEnabled
        public string accountId{get;set;}
        @AuraEnabled
        public string videoId{get;set;}
        @AuraEnabled
        public string title{get;set;}
        @AuraEnabled 
        public string videoType{get;set;}
        @AuraEnabled 
        public string thumbnailUrl{get;set;}
        @AuraEnabled
        public string imageUrl{get;set;}
        @AuraEnabled
        public string videoThumbnailUrl{get;set;}
        @AuraEnabled
        public string description{get;set;}
        @AuraEnabled
        public string altText{get;set;}
        @AuraEnabled
        public string placeholder1920px{get;set;}
        @AuraEnabled
        public string placeholder246px{get;set;}
    }

    public class contentAssetWrapper{
        @AuraEnabled
        public string type{get;set;}
        @AuraEnabled 
        public string thumbnailUrl{get;set;}
        @AuraEnabled
        public string imageUrl{get;set;}
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
        @AuraEnabled public Map<String, List<String>> filters {get; set;}
        @AuraEnabled public Integer page { get; set; }
        @AuraEnabled public String sortType { get; set; }
        
        // Below fields not used in the apex classes. 
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
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public List<Sections> sections { get; set; } 
        @AuraEnabled public Boolean displayInModal { get; set; } 
        @AuraEnabled public Boolean displaySectionsInModal { get; set; }
        @AuraEnabled public String modalButtonLabel { get; set; }
        @AuraEnabled public String modalTitleLabel { get; set; }
    }
    
    public class EditButton{
        @AuraEnabled public Integer currentStep {get; set;}
    }
    public class TypeGroup{
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public List<Types> types { get; set; }
        @AuraEnabled public Boolean isDistributor { get; set; } 
    }
    public class Types implements Comparable{
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String parentId { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String englishName { get; set; }
        @AuraEnabled public String link { get; set; }
        @AuraEnabled public String ancestor { get; set; }
        @AuraEnabled public String ancestorId { get; set; } 
        @AuraEnabled public Boolean secondTierCat { get; set; }
        @AuraEnabled public String tier { get; set; } 
        @AuraEnabled public String filterId { get; set; } 
        @AuraEnabled public SearchParams searchParams { get; set; }
        @AuraEnabled public String parentName { get; set; } // Sandhya
        public Integer compareTo(Object objToCompare) {
            Types typesData = (Types)objToCompare;
            if (englishName == typesData.englishName){
                return 0;
            }
            else if (englishName < typesData.englishName){
                return -1;
            }
            else{
                return 1;
            }
        }
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
        @AuraEnabled public String leadLangPreference {get; set;}
        @AuraEnabled public String autoOffId {get; set;} 
        @AuraEnabled public Boolean isGuest {get; set;}
        //2.0 Changes
        @AuraEnabled public String compareCategoryId {get;set;}
        @AuraEnabled public List<String> categories {get;set;}
        @AuraEnabled public String cardType { get; set; }
        @AuraEnabled public List<Attribute> partnerAttributes { get; set; }
        @AuraEnabled public String partnerId { get; set; }
        @AuraEnabled public String partnerName { get; set; }
        @AuraEnabled public String partnerRole { get; set; }
        @AuraEnabled public String partnerStatus { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String partnerByLine { get; set; }
        @AuraEnabled public String eyebrowTagline {get;set;}
        @AuraEnabled public Boolean eyebrow {get;set;}
        @AuraEnabled public String longDescription { get; set; }
        @AuraEnabled public Boolean contactPartnerVisible {get; set;}
        @AuraEnabled public CategoryLevel categoryL1 {get; set;}
        @AuraEnabled public List<CategoryLevel> categoryL2 {get; set;} //TWC1824-260 - to handle multiple L2 subcategories
        @AuraEnabled public CategoryLevel categoryL3 {get; set;}

    }
    public class CategoryLevel{
                @AuraEnabled public String Id { get; set; }
                @AuraEnabled public String Name { get; set; }

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
        //Added as part 2.0 Components
        @AuraEnabled public String tierStatus { get; set; }
       // @AuraEnabled public String specialties { get; set; }
       // @AuraEnabled public List<Specialties> specialties { get; set; }
        @AuraEnabled public String longDescription { get; set; }
        @AuraEnabled public String partnerRole { get; set; }
        @AuraEnabled public String partnerId { get; set; }
        @AuraEnabled public String partnerName { get; set; }
        @AuraEnabled public String partnerByLine { get; set; }
        @AuraEnabled public String partnerStatus { get; set; }
        @AuraEnabled public String role { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public List<String> partnerSpecialties { get; set; }
        @AuraEnabled public List<String> productCategories { get; set; }
        //Added as part of 2.0 changes for disti card
        @AuraEnabled public String Bizorgtype { get; set; }
        @AuraEnabled public String URL { get; set; }
        @AuraEnabled public List<Specialty> specialties { get; set; }
        @AuraEnabled public String byline { get; set; }
         //eventeyebrow
        @AuraEnabled public Boolean eyebrow {get; set;}
        @AuraEnabled public String eyebrowTagline {get; set;}
        // for contact partner visible
        @AuraEnabled public Boolean contactPartnerVisible {get; set;}
        //Added by raj for partner benefit type
        @AuraEnabled public String benefitType {get; set;}
        
       
            
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
        @AuraEnabled public List<PMP_SearchPartnerController.Partner> results {get; set;} //TBD to change type to cards
        @AuraEnabled public Map<String, Integer> resultCounts {get; set;}
        @AuraEnabled public Integer resultsPerPage {get; set;}
        @AuraEnabled public Integer totalResults {get; set;}
        @AuraEnabled public Integer totalPages {get; set;}
        
        // old design
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
        @AuraEnabled public String learMoreLink { get; set; } //Added by Megha as part of Specialty learnMoreLink
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
        
        @AuraEnabled public String heading {get; set;}
        @AuraEnabled public List<Product> cards {get; set;}
        @AuraEnabled public String ctaLabel {get; set;}
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
        @AuraEnabled public String partnerShortDescription { get;set; } //Added to store stripedhtml string(US954461)
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
        @AuraEnabled public String publishedDate {get; set;} // to store published status date
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
        
       //For Event Banner at storefront page
        @AuraEnabled public Boolean isEventRelated {get; set;}
        
        //For new L3 Storefront detail page
        @AuraEnabled public String website {get; set;}
        @AuraEnabled public List<Specialties> specialties { get; set; }
        @AuraEnabled public String tierStatus { get; set; }
        @AuraEnabled public Boolean isDistributor { get; set; }
        //For adding banner to storefront if its AI generated
         @AuraEnabled public Boolean scrapingValue {get; set;}
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
        @AuraEnabled public String promotionName  { get; set; } 
        @AuraEnabled public String eventScreenReader  { get; set; } 
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
         @AuraEnabled public String profession { get; set; }
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
        @AuraEnabled public boolean suppressEmail{get;set;}
        @AuraEnabled public PartnerWrapper partner { get; set; }
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
        @AuraEnabled public List<Options> partnerNames { get; set; }
        @AuraEnabled public PartnerWrapper partner { get; set; }
        @AuraEnabled public Boolean isDistributor { get; set; } //Added by Subash for US697109  
        @AuraEnabled public Map<string,PartnerWrapper> webaddwrap { get; set; } //for website and address 

        @AuraEnabled public Boolean isEnhanced {get;set;} // Added to check if partner has Enhanced benefit
       
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
        @AuraEnabled public Boolean checked {get; set;}
    }
    
    public class ArticleData{
        @AuraEnabled public String viewAllLabel { get; set; }
        @AuraEnabled public List<Article> articleList { get; set; }
    }
    public class Article{
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String link { get; set; }
        @AuraEnabled public String publishedDate { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String createdDate { get; set; }
        @AuraEnabled public String createdAt { get; set; }
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
        //@AuraEnabled public List<AutoCompleteOption> offeringOptions {get; set;}
    }
    
    public class SeoCat{
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public Integer categoryLevel {get; set;}
        @AuraEnabled public String url {get; set;} 
        @AuraEnabled public String objectApiName {get; set;}
    }
    public class PartnerWrapper {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String website { get; set; }
        //Added by Subash for US686667
        @AuraEnabled public String primaryStreet { get; set; }
        @AuraEnabled public String secondaryStreet { get; set; }
        @AuraEnabled public String city { get; set; }
        @AuraEnabled public String country { get; set; }
        @AuraEnabled public String state { get; set; }
        @AuraEnabled public String postalCode { get; set; }
        @AuraEnabled public String description { get; set; }

        //End of US686667
    }
    
 /*..Ignore the below  classes...*/
    public class TaxonomyRecord{
        @AuraEnabled public String id{ get; set; }
        @AuraEnabled public String parentId{ get; set; }
        @AuraEnabled public String label{ get; set; }
        @AuraEnabled public String englishLabel{ get; set; } // Added as part of TWC1824-3754
        @AuraEnabled public String[] children{ get; set; }
        @AuraEnabled public String description{ get; set; }
        @AuraEnabled public String svgIconUrl{ get; set; }
        @AuraEnabled public String viewAllLabel{ get; set; } 
        @AuraEnabled public String taxonomy{ get; set; } 
        @AuraEnabled public boolean featured{ get; set; } 
        @AuraEnabled public boolean prerelease{ get; set; } 
        @AuraEnabled public List<SearchResultsGrouping> searchResultsGroupings{ get; set; } 
        @AuraEnabled public Map<String, List<String>> defaultFilters{ get; set; } 
        @AuraEnabled public String learnMoreUrl {get; set;}
        @AuraEnabled public boolean showCountryWarning { get; set; }
        @AuraEnabled public boolean isIntelEmployee { get; set; }
    } 
    
    public class Taxonomy{
        @AuraEnabled public String name{ get; set; }
        @AuraEnabled public String apiName{ get; set; }
        @AuraEnabled public String label{ get; set; }
        @AuraEnabled public String englishLabel{get; set;} // Added as part of TWC1824-3754
        @AuraEnabled public String viewAllLabel{ get; set; }
        @AuraEnabled public String svgIconUrl{ get; set; }
        @AuraEnabled public List<String> topLevelIds { get; set; }  
        //@AuraEnabled public Map<Id,TaxonomyRecord> records { get; set; }    
        @AuraEnabled public Map<String,TaxonomyRecord> records { get; set; }   
        @AuraEnabled public String filterDisplayType{ get; set; } 
        @AuraEnabled public List<SearchFiltersGrouping> searchFiltersGroupings{ get; set; }
        @AuraEnabled public String description{ get; set; }
        @AuraEnabled public boolean expandByDefault{ get; set; }

    }

    
    public class RefineFilterTaxonomy {
        @AuraEnabled public String name{ get; set; }
        @AuraEnabled public String apiName{ get; set; }
        @AuraEnabled public String label{ get; set; }
        @AuraEnabled public String englishLabel{get; set;}
        @AuraEnabled public Map<String,RefineFilterTaxonomyRecord> records { get; set; } 
        @AuraEnabled public String PimId{ get; set; }

    }
	
	    public class RefineFilterTaxonomyRecord {
        @AuraEnabled public String id{ get; set; }
        @AuraEnabled public String parentId{ get; set; }
        @AuraEnabled public String label{ get; set; }
        @AuraEnabled public String englishLabel{ get; set; }
        @AuraEnabled public String objectname {get; set; }
        @AuraEnabled public String filtertaxonomy{ get; set; }  
    }


    public class SearchFiltersGrouping{
        @AuraEnabled public String label{ get; set; }
        @AuraEnabled public String englishLabel{ get; set; } // Added as part of TWC1824-3754
        @AuraEnabled public List<String> filters{ get; set; }
    }
    
    public class SearchResultsGrouping{
        @AuraEnabled public String name{ get; set; }
        @AuraEnabled public String heading{ get; set; }
        @AuraEnabled public String subheading{ get; set; }
    }
    
    //Addes by Subash for US679015 & US679014
    public class BreadCrumb {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String page { get; set; }
        @AuraEnabled public SearchParams searchParams {get; set;}
        @AuraEnabled public String getURL {get; set;}
        
        //2.0 Changes
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String text { get; set; } 
        @AuraEnabled public String url { get; set; }
        @AuraEnabled public Boolean cancelEvent { get; set; }
        @AuraEnabled public BreadCrumbData data { get; set; }
        @AuraEnabled public Boolean useCallback { get; set; }
        @AuraEnabled public String target { get; set; }
        @AuraEnabled public Boolean selected { get; set; } 
        @AuraEnabled public List<BreadCrumb> children { get; set; }
        @AuraEnabled public String parentId { get; set; }
    }
    
    public class BreadCrumbData {
        @AuraEnabled public String type { get; set; } 
        @AuraEnabled public BreadCrumbAttribute attributes { get; set; } 
    }
    
    public class BreadCrumbAttribute {
        @AuraEnabled public String url { get; set; }
        @AuraEnabled public String pageName { get; set; }
        @AuraEnabled public String objectApiName { get; set; }
        @AuraEnabled public String actionName { get; set; }
        @AuraEnabled public String recordId { get; set; }
    }   
    public class Specialty{
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String icon { get; set; } 
        @AuraEnabled public String sfIcon { get; set; }
        @AuraEnabled public String svgIcon {get; set;}
        @AuraEnabled public String iconImgUrl {get; set;}
    }
    
    //added for events detail page
    public class CampaignEvents {
        @AuraEnabled public String cardType { get; set; } 
        @AuraEnabled public Integer partnerTotal { get; set; } 
        @AuraEnabled public Integer productTotal { get; set; } 
        @AuraEnabled public String campaignId { get; set; } 
        @AuraEnabled public String name { get; set; } 
        @AuraEnabled public String description { get; set; } 
        @AuraEnabled public String externalUrl { get; set; } 
        @AuraEnabled public String image {get; set;}
        //added for event banner(imageAlt)
        @AuraEnabled public String imageAlt {get; set;}
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String linkLabel { get; set; }
        @AuraEnabled public String linkUrl { get; set; }
        @AuraEnabled public Boolean isInvalidEvent { get; set; }
        @AuraEnabled public List<PMP_SearchPartnerController.Partner> partnerCards { get; set; }    
       // @AuraEnabled public List<PMP_SearchProductController.Product> productCards { get; set; }         
    }
    
    public class TaxonomyParams {
        @AuraEnabled public String langCode { get; set; } 
        @AuraEnabled public Boolean baseTaxonomy { get; set; } 
    }
    
     //Wrapper TO STORE OFFERING RESOURCE DETAILS
    /* public class OfferingResourceWrapper{
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String url { get; set; }
        @AuraEnabled public String resourceType { get; set; }
        @AuraEnabled public String uploadId { get; set; }
        @AuraEnabled public String fileType { get; set; }
        @AuraEnabled public String fileSize { get; set; }
        @AuraEnabled public String downloadUrl { get; set; }
        @AuraEnabled public String uploadName { get; set; }
        @AuraEnabled public String externalId { get; set; }
        @AuraEnabled public String altText { get; set; }
        @AuraEnabled public String videoThumbnail { get; set; }
        @AuraEnabled public String publishDate { get; set; }
        @AuraEnabled public String fileExt { get; set; }
	    @AuraEnabled public VideoTypeWrapper videoType { get; set; }
    }
    //Wrapper TO STORE OFFERING RESOURCE DETAILS
    public class VideoTypeWrapper{
        @AuraEnabled public String accountId{ get; set; }
        @AuraEnabled public String title{ get; set; }
        @AuraEnabled public String thumbnailUrl{ get; set; }
        @AuraEnabled public String videoId{ get; set; }
        @AuraEnabled public String videoType{ get; set; }
    }   
    //Wrapper for offering additional resourcetypes picklist label and values
    public class OfferingResourceType{
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
    }*/
    
    //Wrapper for new L3 Storefront detail page
    public class StorefrontFeedItem{
        @AuraEnabled public List<CardData> cardData { get; set; } 
        @AuraEnabled public List<FilterStructure> filterStructure { get; set; }
        @AuraEnabled public Map<Id, FilterData> filterData { get; set; }
        @AuraEnabled public Integer totalItems { get; set; }
    }
    
    public class CardData implements Comparable{
        @AuraEnabled public String cardType { get; set; } 
        @AuraEnabled public String id { get; set; } 
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String tagline {get; set;}
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String imageUrl { get; set; }
        @AuraEnabled public String imageAlt { get; set; }
        @AuraEnabled public Boolean featured {get; set;}
        @AuraEnabled public String createdDate { get; set; }
        @AuraEnabled public String externalUrl { get; set; }
        @AuraEnabled public String statusUpdateDate{get;set;}
        @AuraEnabled public List<Categories> categories { get; set; }
        public Integer compareTo(Object objToCompare) {
            CardData cardData = (CardData)objToCompare;
            if (statusUpdateDate == cardData.statusUpdateDate){
                return 0;
            }
            else if (statusUpdateDate < cardData.statusUpdateDate){
                return 1;
            }
            else{
                return -1;
            }
        }
    }
    
    public class FilterStructure{
        @AuraEnabled public String id { get; set; } 
        @AuraEnabled public String filterName { get; set; } 
        @AuraEnabled public String label { get; set; } 
        @AuraEnabled public Set<String> children { get; set; }
        @AuraEnabled public Set<String> relatedOfferings { get; set; }
    }
    
    public class FilterData{
        @AuraEnabled public String id { get; set; } 
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public Set<String> children {get; set;}
        @AuraEnabled public String parent { get; set; }
        @AuraEnabled public Integer count { get; set; }
        @AuraEnabled public Set<String> relatedOfferings { get; set; }
    }
    
    public class Specialties{
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String image { get; set; } 
    }
    
    public class Categories{
        @AuraEnabled public String separator { get; set; }
        @AuraEnabled public List<CategoryAttribute> values { get; set; } 
    }

    public class CategoryAttribute implements Comparable{
        @AuraEnabled public Boolean isLink { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String recordId { get; set; }
        @AuraEnabled public String objectPage { get; set; }
        @AuraEnabled public Integer sequenceNumber { get; set; }
        public Integer compareTo(Object objToCompare) {
            CategoryAttribute catSeq = (CategoryAttribute)objToCompare;
            if (sequenceNumber == catSeq.sequenceNumber){
                return 0;
            }
            else if (sequenceNumber < catSeq.sequenceNumber){
                return -1;
            }
            else{
                return 1;
            }
        }
    }
    
    public class Sections{
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public List<SectionValues> values { get; set; } 
        @AuraEnabled public String modalButtonLabel { get; set; }
        @AuraEnabled public String modalTitleLabel { get; set; }
    }

    public class SectionValues{
        @AuraEnabled public Boolean isLink { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String subsection { get; set; }
    }    
}