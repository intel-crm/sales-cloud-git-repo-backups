global without sharing virtual class PMP_PartnerDetailsWrapper {
    
    global class Category {
         global String categoryId { get; set; } 
         global String categoryDescription { get; set; }
         global String categoryName { get; set; }
         global String categoryType { get; set; }
         global String categoryCtaLink { get; set; }
         global Integer count { get; set; }
         global List<Category> children { get; set; }
         global String parentId { get; set; }
    }
    global class CategorySearchResponse {
         global String keyword { get; set; }
         global Integer allMarketplaceCount { get; set; }
         global Integer allPartnerCount { get; set; }
         global Integer allProductCount { get; set; }
         global List<Category> partnerCategories { get; set; }
         global List<Category> productCategories { get; set; }
         global List<Filter> filters { get; set; }  //adding contextual filters with category tree
         global Map<String, List<String>> selectedFilters { get; set; } 
         global String langCode {get; set;}
         global String searchType {get; set;}
         global String category {get; set;}
         global String tagListId {get; set;}  //Current selected contextual filter's Id
    }
    global class SearchRequest {
         global String keyword { get; set; }
         global String category { get; set; }
         global Map<String, List<String>> filters {get; set;}
         global Integer page { get; set; }
         global String sortType { get; set; }
        
        // Below fields not used in the apex classes. 
         global String specialty  {get; set; }  //Added by Kartik
         global String searchType { get; set; }
         global String sortField { get; set; }
         global String sortDirection { get; set; }
         global Map<String, List<String>> selectedFilters { get; set; }   //Fields selected by the end  user in the UI
         global Integer currentPage { get; set; }
         global Integer pageSize { get; set; }
         global String langCode {get; set;}
         global String contextualCat {get; set;}
         global String tagListId {get; set;}  //Current selected contextual filter's Id
        
    }
    global class Attribute { 
         global String id { get; set; }
         global String name { get; set; }
         global List<Types> types { get; set; }
         global List<TypeGroup> typeGroupings { get; set; }
         global String textBlock { get; set; }
         global Boolean secondTierCat{get;set;}
         global Boolean isEditable {get; set;}
         global EditButton editButton {get; set;}        
         global SearchParams search {get;set;}
         global String title { get; set; }
         global List<Sections> sections { get; set; } 
         global Boolean displayInModal { get; set; } 
         global Boolean displaySectionsInModal { get; set; }
         global String modalButtonLabel { get; set; }
         global String modalTitleLabel { get; set; }
    }
    
    global class EditButton{
         global Integer currentStep {get; set;}
    }
    global class TypeGroup{
         global String name {get; set;}
         global List<Types> types { get; set; }
         global Boolean isDistributor { get; set; } 
    }
    global class Types implements Comparable{
         global String id { get; set; }
         global String parentId { get; set; }
         global String name { get; set; }
         global String englishName { get; set; }
         global String link { get; set; }
         global String ancestor { get; set; }
         global String ancestorId { get; set; } 
         global Boolean secondTierCat { get; set; }
         global String tier { get; set; } 
         global String filterId { get; set; } 
         global SearchParams searchParams { get; set; }
         global String parentName { get; set; } // Sandhya
        global Integer compareTo(Object objToCompare) {
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
    global class Product {
        
         global String type { get; set; }
         global String id { get; set; }
         global String imageUrl { get; set; }
         global String description { get; set; }
         global String title { get; set; }
         global Boolean prerelease { get; set; }
         global String prerelaseText { get; set; }
         global Boolean onlyVisibleToIntel { get; set; }
         global Partner partner { get; set; }
         global List<Attribute> attributes { get; set; }
         global Boolean featured { get; set; }
         global Boolean isContactPartnerVisible {get; set;}
         global String leadLangPreference {get; set;}
         global String autoOffId {get; set;} 
         global Boolean isGuest {get; set;}
        //2.0 Changes
         global String compareCategoryId {get;set;}
         global List<String> categories {get;set;}
         global String cardType { get; set; }
         global List<Attribute> partnerAttributes { get; set; }
         global String partnerId { get; set; }
         global String partnerName { get; set; }
         global String partnerRole { get; set; }
         global String partnerStatus { get; set; }
         global String name { get; set; }
         global String partnerByLine { get; set; }
         global String eyebrowTagline {get;set;}
         global Boolean eyebrow {get;set;}
         global String longDescription { get; set; }
         global Boolean contactPartnerVisible {get; set;}
         global CategoryLevel categoryL1 {get; set;}
         global List<CategoryLevel> categoryL2 {get; set;} //TWC1824-260 - to handle multiple L2 subcategories
         global CategoryLevel categoryL3 {get; set;}
        
    }
    global class CategoryLevel{
         global String Id { get; set; }
         global String Name { get; set; }
        
    }
    
    global class Partner {
         global String type { get; set; }
         global String id { get; set; }
         global String imageUrl { get; set; }
         global String description { get; set; }
         global String name { get; set; }
         global Boolean contactByEmail { get; set; }
         global Boolean contactByForm { get; set; }
         global List<Attribute> attributes { get; set; }
         global Boolean isContactPartnerVisible {get; set;}
         global String leadLangPreference {get; set;}
         global SearchParams search {get;set;}
         global Boolean isGuest {get; set;}
         global String autoPartnerId {get; set;}
        //Added as part 2.0 Components
         global String tierStatus { get; set; }
        //  global String specialties { get; set; }
        //  global List<Specialties> specialties { get; set; }
         global String longDescription { get; set; }
         global String partnerRole { get; set; }
         global String partnerId { get; set; }
         global String partnerName { get; set; }
         global String partnerByLine { get; set; }
         global String partnerStatus { get; set; }
         global String role { get; set; }
         global String status { get; set; }
         global List<String> partnerSpecialties { get; set; }
         global List<String> productCategories { get; set; }
        //Added as part of 2.0 changes for disti card
         global String Bizorgtype { get; set; }
         global String URL { get; set; }
         global List<Specialty> specialties { get; set; }
         global String byline { get; set; }
        //eventeyebrow
         global Boolean eyebrow {get; set;}
         global String eyebrowTagline {get; set;}
        // for contact partner visible
         global Boolean contactPartnerVisible {get; set;}
        //Added by raj for partner benefit type
         global String benefitType {get; set;}
        
    }
    
    global class Tag {
         global String label { get; set; }
         global Integer count { get; set; }
         global String value { get; set; }
         global String parent { get; set; }
         global List<Tag> children { get; set; }
         global String pimId { get; set; }
    }
    global class Filter {
         global String type { get; set; }
         global String name { get; set; } //this value will come as key in selectFilters in search/categorysearchrequest
         global String label { get; set; }
         global List<Tag> tags { get; set; }
         global Integer count { get; set; }
         global Boolean showClearLink { get; set; }
         global Boolean autoexpand { get; set; }
        
    }
    
    global class SearchResponse {
         global List<PMP_SearchPartnerController.Partner> results {get; set;} //TBD to change type to cards
         global Map<String, Integer> resultCounts {get; set;}
         global Integer resultsPerPage {get; set;}
         global Integer totalResults {get; set;}
         global Integer totalPages {get; set;}
        
        // old design
         global String keyword { get; set; }
         global String category { get; set; }
         global String searchType { get; set; }
         global String sortField { get; set; }
         global String sortDirection { get; set; }
         global Integer currentPage { get; set; }
         global Integer pageSize { get; set; }
         global Integer totalCount { get; set; }
         global Integer totalProductCount { get; set; }
         global Integer totalPartnerCount { get; set; }
         global List<Product> productResults { get; set; }
         global List<Partner> partnerResults { get; set; }
         global List<Filter> filters { get; set; }
         global List<String> suggestions { get; set; }
         global String searchHeading { get; set; }
         global String categoryDescription { get; set; }
         global String learMoreLink { get; set; } //Added by Megha as part of Specialty learnMoreLink
         global Map<String, List<String>> selectedFilters { get; set; }
    }
    global class AutoCompleteOption {
        // category, keyword, and searchType determine the search that gets sent to the server
        // when the option is selected on the front end
         global Category category { get; set; }
         global String keyword { get; set; }
         global String label { get; set; }
         global String searchType { get; set; }
         global Id recordId { get; set; }
    }
    
    global class Mobile{
         global String label { get; set; }
         global String link { get; set; }
         global String imgUrl { get; set; }
         global String page {get; set;}
         global SearchParams searchParams {get; set;}
    }
    global class FeaturedProductTab{
         global String categoryId { get; set; }
         global String label { get; set; }
         global SearchParams searchParams { get; set; }
         global List<Product> products { get; set; }
         global String ctaTitle { get; set; }
         global String eventTitle { get; set; }   //View more Event Offerings stays here.
         global Boolean featuredPdt {get; set;}
        
         global String heading {get; set;}
         global List<Product> cards {get; set;}
         global String ctaLabel {get; set;}
    }
    global class PartnerDetail{
        //Deatils from company Information Object
         global String id { get; set; } 
         global String name { get; set; }
         global String tagline {get; set;}
         global String introSection { get; set; }
         global String moreSection { get; set; }
         global Boolean showMoreSection { get; set; }//Added for US600134 by Megha
         global String partnerDescription { get;set; }
         global String partnerShortDescription { get;set; } //Added to store stripedhtml string(US954461)
         global List<Promotion> promotion { get; set; }
         global List<CategoryTab> categories { get; set; }
         global List<PartnerResource> companyResources { get; set; }
        
        
         global List<Mobile> mobileList { get; set; }
        //Used for partner card
         global Partner partnerDetails { get; set; }
        //For Edit storefront and notification
         global String currentStatus {get; set;}
         global String publishedStatus {get; set;}
         global String partnerType {get; set;}
         global Boolean isUpdateRequired {get; set;}
         global String statusUpdateDate {get; set;}
         global String initialUpdateDate {get; set;}
         global String publishedDate {get; set;} // to store published status date
        //access to edit storefront
         global Boolean isSamePartnerUser {get; set;}
         global Boolean hasAccess {get; set;}
         global Boolean isGuest {get; set;}
         global Boolean manageOfferingAccess {get; set;}
         global Boolean isIntelAdmin {get; set;}
        //Lead gen access
         global Boolean isContactPartnerVisible {get; set;}
         global Boolean hasLeadGenAccess {get; set;}
         global Boolean isLeadGenLimited {get; set;}
         global LeadGenSettings leadSettings {get; set;}
        
         global String leadLangPreference {get; set;}
         global String mdaId {get; set;}
        
        //For Benefit 
         global Boolean showCompanyResourceAndArticle {get; set;}
         global Boolean showCompanyResourceAndArticleforEnhanced {get; set;}   
        
        //Added by Subash for guided setup and a welcome note US620593
         global Boolean isMarkettingSpecialist {get; set;}
         global Boolean isPartnerAdmin {get; set;}
         global Boolean showEnhancedPopup {get; set;}
         global Boolean isOfferingEditor {get; set;}
        
        //Added by Megha as part of US619896
         global Boolean isLdrOeEmployee {get; set;}
        
        //For Event Banner at storefront page
         global Boolean isEventRelated {get; set;}
        
        //For new L3 Storefront detail page
         global String website {get; set;}
         global List<Specialties> specialties { get; set; }
         global String tierStatus { get; set; }
         global Boolean isDistributor { get; set; }
    }
    
    global class CategoryTab{
         global String label { get; set; }
         global String viewAllLabel { get; set; }
         global String viewAllLinkUrl { get; set; }
         global String iconUrl { get; set; }
         global Integer count { get; set; }
         global List<Product> entries { get; set; }
         global SearchParams searchParams { get; set; }
    }
    
    global class PartnerResource{
         global String title { get; set; }
         global String linkUrl { get; set; }
         global String type { get; set; }
         global Boolean openInNewTab { get; set; }
    }
    global class Promotion{
         global String imageUrl { get; set; }
         global String imagePosition { get; set; }
         global String title { get; set; }
         global String body { get; set; }
         global String ctaLink { get; set; }
         global String ctaLabel { get; set; }
         global SearchParams searchParams { get; set; }
         global String promotionName  { get; set; } 
         global String eventScreenReader  { get; set; } 
    }
    global class Listing {
         global String label { get; set; }
         global String imgUrl { get; set; }
         global String description { get; set; }
         global String descriptionLink { get; set; }
         global String descriptionLinkText { get; set; }
         global String descriptionLinkTarget { get; set; }
         global String page { get; set; }
         global SearchParams searchParams { get; set; } 
         global SearchType searchType { get; set; }
         global Boolean isIcon { get; set; }
        
    }
    global class SearchParams{
         global String cat { get; set; } //category
         global String PartnerProgram {get; set;}//Partner Program
         global String objectApiName {get; set;}  
         global String recordId {get; set;} 
         global String q { get; set; }   //search term
         global String page { get; set; } //current page (1,2,3)
         global String type { get; set; } //search type ('all', 'product', 'partner')
         global String dir { get; set; }  //sort direction ('asc' / 'desc')
         global String field { get; set; } //sort field
         global Map<String,List<String>> selectedFilters { get; set; } //filters
         global Boolean contextualCat {get; set;}
         global String specialty {get;set;}  //Specialty
         global String reg { get; set; } //region
        
    }
    global class SearchType{
         global String type { get; set; }
    }
    global class UserDetails {
         global String firstName { get; set; }
         global String lastName { get; set; }
         global String jobTitle { get; set; }
         global String profession { get; set; }
         global String companyName { get; set; }
         global String country { get; set; }
         global String state { get; set; }
         global String phone { get; set; }
         global String email { get; set; }   
         global Double volume {get;set;}
         global String description {get;set;}
         global Date deliveryDate {get;set;}
        
         global String offeringURL { get; set; }
         global String leadSource { get; set; }
         global String sfdcCampaignID { get; set; }
         global String leadConversionPoint { get; set; }
         global String marketingTacticID { get; set; }
         global String sourceID { get; set; }
         global String partnerProgramSegment { get; set; }
         global String sessionId {get; set;}
        
    }
    
    global class FormDataSaveRequest{
        
         global DescriptionData descriptionData {get; set;}
        
         global List<Option> regionOptions {get; set;}
        
         global List<String> regionsSelected {get; set;} //Added by Nikhil
         global List<String> applicationsSelected {get; set;}
         global List<String> industriesSelected {get; set;}
        
         global List<Resource> resources {get; set;}
         global String status {get; set;}
         global String admin {get; set;}      
         global boolean suppressEmail{get;set;}
         global PartnerWrapper partner { get; set; }
    }
    
    global class FormData{
        
         global Boolean isLocked {get; set;}
        //logo step-1
         global Boolean logoCheck {get; set;}
         global ImageWrapper logo  {get; set;}
         global String workingCopyId {get; set;}
        
        //desc and tag step-2
         global DescriptionData descriptionData {get; set;}
        
        //application, industry,region step-3
        
        
        //Added by Nikhil
         global List<Option> regionOptions {get; set;}
         global List<String> regionsSelected {get; set;}
        //resource step-4
         global ResourceData resourceData {get; set;}
        
        //POC
         global List<Option> industryOptions {get; set;}
         global List<String> industriesSelected {get; set;}
        
        //Application step-6
         global List<Option> applicationOptions {get; set;}
         global List<String> applicationsSelected {get; set;}
        
        //admin review step-7
         global Boolean isPublishedCopyDraft {get; set;}
         global String currentStatus {get; set;}
         global string submittedBy { get; set; }
         global string submittedOn { get; set; }
         global string admin { get; set; }
         global List<Options> adminList { get; set; }
         global List<Options> statusList { get; set; }
         global List<Options> partnerNames { get; set; }
         global PartnerWrapper partner { get; set; }
         global Boolean isDistributor { get; set; } //Added by Subash for US697109  
         global Map<string,PartnerWrapper> webaddwrap { get; set; } //for website and address 
        
         global Boolean isEnhanced {get;set;} // Added to check if partner has Enhanced benefit
        
    }
    
    global class Resource{
         global String title {get; set;}
         global String type {get; set;}
         global String url {get; set;}
    }
    global class ImageWrapper {
        global String id { get; set; }
        global String url { get; set; }
        global String title { get; set; }
        global Integer size { get; set; }
    }
    
    global class Logo{
         global String src { get; set; }
         global String filename { get; set; }
         global String filesize { get; set; }
    }
    
    global class DescriptionData{
         global String language {get; set;}
         global String tagline {get; set;}
         global String description {get; set;}
         global List<Options> languageOptions {get; set;}
         global Boolean languageDisabled {get; set;}
    }
    
    
    
    global class ResourceData{
         global List<Options> resourceTypes {get; set;}
         global List<Resource> resources {get; set;}
    }
    
    
    
    global class Options{
         global String label {get; set;}
         global String value {get; set;}
         global Boolean selected {get; set;}
    }
    
    global class Option{
         global String label {get; set;}
         global String value {get; set;}
         global List<Option> children {get; set;}
         global List<Option> options {get; set;}
         global Boolean isCategory {get;set;}
         global Boolean isPartnerProgram {get;set;}
         global Boolean checked {get; set;}
    }
    
    global class ArticleData{
         global String viewAllLabel { get; set; }
         global List<Article> articleList { get; set; }
    }
    global class Article{
         global String title { get; set; }
         global String link { get; set; }
         global String publishedDate { get; set; }
         global String description { get; set; }
         global String createdDate { get; set; }
         global String createdAt { get; set; }
    }
    
    
    global class LanguagePreference{
         global String label { get; set; }
         global String value { get; set; }
         global Boolean selected {get; set;}
    }
    
    global class LeadGenSettings{
         global Boolean enableLeadGeneration {get; set;}
         global Boolean limitToPartners { get; set; }
         global List<Options> languagePreference {get; set;} 
    }
    
    global class MdaInfo{
         global String mdaId {get; set;}
         global String businessSegment {get; set;}
    }
    
    //Added by Subash for US601910
    global class AutoCompleteOptionForPartnerAndOffering{
         global List<AutoCompleteOption> partnerOptions {get; set;}
         global List<AutoCompleteOption> offeringOptions {get; set;}
    }
    
    global class SeoCat{
         global String Name { get; set; }
         global String Id { get; set; }
         global Integer categoryLevel {get; set;}
         global String url {get; set;} 
         global String objectApiName {get; set;}
    }
    global class PartnerWrapper {
         global String name { get; set; }
         global String website { get; set; }
        //Added by Subash for US686667
         global String primaryStreet { get; set; }
         global String secondaryStreet { get; set; }
         global String city { get; set; }
         global String country { get; set; }
         global String state { get; set; }
         global String postalCode { get; set; }
         global String description { get; set; }
        
        //End of US686667
    }
    
    /*..Ignore the below  classes...*/
    global class TaxonomyRecord{
         global String id{ get; set; }
         global String parentId{ get; set; }
         global String label{ get; set; }
         global String englishLabel{ get; set; } // Added as part of TWC1824-3754
         global String[] children{ get; set; }
         global String description{ get; set; }
         global String svgIconUrl{ get; set; }
         global String viewAllLabel{ get; set; } 
         global String taxonomy{ get; set; } 
         global boolean featured{ get; set; } 
         global boolean prerelease{ get; set; } 
         global List<SearchResultsGrouping> searchResultsGroupings{ get; set; } 
         global Map<String, List<String>> defaultFilters{ get; set; } 
         global String learnMoreUrl {get; set;}
         global boolean showCountryWarning { get; set; }
         global boolean isIntelEmployee { get; set; }
    } 
    
    global class Taxonomy{
         global String name{ get; set; }
         global String apiName{ get; set; }
         global String label{ get; set; }
         global String englishLabel{get; set;} // Added as part of TWC1824-3754
         global String viewAllLabel{ get; set; }
         global String svgIconUrl{ get; set; }
         global List<String> topLevelIds { get; set; }  
        // global Map<Id,TaxonomyRecord> records { get; set; }    
         global Map<String,TaxonomyRecord> records { get; set; }   
         global String filterDisplayType{ get; set; } 
         global List<SearchFiltersGrouping> searchFiltersGroupings{ get; set; }
         global String description{ get; set; }
         global boolean expandByDefault{ get; set; }
        
    }
    
    
    global class RefineFilterTaxonomy {
         global String name{ get; set; }
         global String apiName{ get; set; }
         global String label{ get; set; }
         global String englishLabel{get; set;}
         global Map<String,RefineFilterTaxonomyRecord> records { get; set; } 
         global String PimId{ get; set; }
        
    }
    
    global class RefineFilterTaxonomyRecord {
         global String id{ get; set; }
         global String parentId{ get; set; }
         global String label{ get; set; }
         global String englishLabel{ get; set; }
         global String objectname {get; set; }
         global String filtertaxonomy{ get; set; }  
    }
    
    
    global class SearchFiltersGrouping{
         global String label{ get; set; }
         global String englishLabel{ get; set; } // Added as part of TWC1824-3754
         global List<String> filters{ get; set; }
    }
    
    global class SearchResultsGrouping{
         global String name{ get; set; }
         global String heading{ get; set; }
         global String subheading{ get; set; }
    }
    
    //Addes by Subash for US679015 & US679014
    global class BreadCrumb {
         global String label { get; set; }
         global String page { get; set; }
         global SearchParams searchParams {get; set;}
         global String getURL {get; set;}
        
        //2.0 Changes
         global String id { get; set; }
         global String text { get; set; } 
         global String url { get; set; }
         global Boolean cancelEvent { get; set; }
         global BreadCrumbData data { get; set; }
         global Boolean useCallback { get; set; }
         global String target { get; set; }
         global Boolean selected { get; set; } 
         global List<BreadCrumb> children { get; set; }
         global String parentId { get; set; }
    }
    
    global class BreadCrumbData {
         global String type { get; set; } 
         global BreadCrumbAttribute attributes { get; set; } 
    }
    
    global class BreadCrumbAttribute {
         global String url { get; set; }
         global String pageName { get; set; }
         global String objectApiName { get; set; }
         global String actionName { get; set; }
         global String recordId { get; set; }
    }   
    global class Specialty{
         global String title { get; set; }
         global String icon { get; set; } 
         global String sfIcon { get; set; }
         global String svgIcon {get; set;}
         global String iconImgUrl {get; set;}
    }
    
    //added for events detail page
    global class CampaignEvents {
         global String cardType { get; set; } 
         global Integer partnerTotal { get; set; } 
         global Integer productTotal { get; set; } 
         global String campaignId { get; set; } 
         global String name { get; set; } 
         global String description { get; set; } 
         global String externalUrl { get; set; } 
         global String image {get; set;}
        //added for event banner(imageAlt)
         global String imageAlt {get; set;}
         global String title { get; set; }
         global String linkLabel { get; set; }
         global String linkUrl { get; set; }
         global Boolean isInvalidEvent { get; set; }
         global List<PMP_SearchPartnerController.Partner> partnerCards { get; set; }    
         global List<PMP_SearchProductController.Product> productCards { get; set; }         
    }
    
    global class TaxonomyParams {
         global String langCode { get; set; } 
         global Boolean baseTaxonomy { get; set; } 
    }
    
    //Wrapper TO STORE OFFERING RESOURCE DETAILS
    global class OfferingResourceWrapper{
         global String id { get; set; }
         global String title { get; set; }
         global String description { get; set; }
         global String url { get; set; }
         global String resourceType { get; set; }
         global String uploadId { get; set; }
         global String fileType { get; set; }
         global String fileSize { get; set; }
         global String downloadUrl { get; set; }
         global String uploadName { get; set; }
         global String externalId { get; set; }
         global String altText { get; set; }
         global String videoThumbnail { get; set; }
         global String publishDate { get; set; }
         global String fileExt { get; set; }
         global VideoTypeWrapper videoType { get; set; }
    }
    //Wrapper TO STORE OFFERING RESOURCE DETAILS
    global class VideoTypeWrapper{
         global String accountId{ get; set; }
         global String title{ get; set; }
         global String thumbnailUrl{ get; set; }
         global String videoId{ get; set; }
         global String videoType{ get; set; }
    }   
    //Wrapper for offering additional resourcetypes picklist label and values
    global class OfferingResourceType{
         global String label { get; set; }
         global String value { get; set; }
    }
    
    //Wrapper for new L3 Storefront detail page
    global class StorefrontFeedItem{
         global List<CardData> cardData { get; set; } 
         global List<FilterStructure> filterStructure { get; set; }
         global Map<Id, FilterData> filterData { get; set; }
         global Integer totalItems { get; set; }
    }
    
    global class CardData implements Comparable{
         global String cardType { get; set; } 
         global String id { get; set; } 
         global String title { get; set; }
         global String tagline {get; set;}
         global String description { get; set; }
         global String imageUrl { get; set; }
         global String imageAlt { get; set; }
         global Boolean featured {get; set;}
         global String createdDate { get; set; }
         global String externalUrl { get; set; }
         global String statusUpdateDate{get;set;}
         global List<Categories> categories { get; set; }
        global Integer compareTo(Object objToCompare) {
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
    
    global class FilterStructure{
         global String id { get; set; } 
         global String filterName { get; set; } 
         global String label { get; set; } 
         global Set<String> children { get; set; }
         global Set<String> relatedOfferings { get; set; }
    }
    
    global class FilterData{
         global String id { get; set; } 
         global String label { get; set; }
         global Set<String> children {get; set;}
         global String parent { get; set; }
         global Integer count { get; set; }
         global Set<String> relatedOfferings { get; set; }
    }
    
    global class Specialties{
         global String name { get; set; }
         global String image { get; set; } 
    }
    
    global class Categories{
         global String separator { get; set; }
         global List<CategoryAttribute> values { get; set; } 
    }
    
    global class CategoryAttribute implements Comparable{
         global Boolean isLink { get; set; }
         global String label { get; set; }
         global String recordId { get; set; }
         global String objectPage { get; set; }
         global Integer sequenceNumber { get; set; }
        global Integer compareTo(Object objToCompare) {
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
    
    global class Sections{
         global String label { get; set; }
         global List<SectionValues> values { get; set; } 
         global String modalButtonLabel { get; set; }
         global String modalTitleLabel { get; set; }
    }
    
    global class SectionValues{
         global Boolean isLink { get; set; }
         global String label { get; set; }
         global String subsection { get; set; }
    }
	
	global class OfferingsList{
		global Id offeringId{get;set;}
		global String imageURL{get;set;}
		global String title{get;set;}
		
	}
    
    global class Error{
        global String message;
    }
    
	
}