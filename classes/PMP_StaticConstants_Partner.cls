/**************************************************************************************
Apex Class Name: PMP_StaticConstants_Partner
Version     : 1.0 
Created Date: 29 June, 2019
Description : Class to store static constants, which can be reused in other classes.
* Modification Log :
* Developer                 Date         Description
* ----------------------------------------------------------------------------
* Nikhil          29/06/2019               Original Version
*************************************************************************************/
public class PMP_StaticConstants_Partner {
    
    //use this method to get static values stored in custom settings PMP_Static_Constants__c
    public static String getValue(String name){
        if(PMP_Static_Constants__c.getValues(name) != null){
            return PMP_Static_Constants__c.getValues(name).PMP_Value__c;
        }else{
            return null;
        }  
    }
    
    public static final String categoryPimId = getValue('PMP_PIM_Category_Id');
    public static final string IMAGE= getValue('PMP_Image');
    public static final String THUMBNAIL_IMAGE = getValue('PMP_Thumbnail_Image');
    public static final String INTEL_ONLY = getValue('PMP_Intel_Only');
    
    //For PMP_SearchUtilityController 
    public static final String product = 'product';
    public static final String partner = 'partner';
    public static final String all = 'all';
    //hey
    
    public static final String TRUE_STRING = 'True';
    public static final String FALSE_STRING = 'False';
    public static final String INACTIVE = 'Inactive';
    
    //Used for Offering Translation
    public static final String OFFERING_NAME = 'PMP_Partner_Offering_Nm__c';
    public static final String OFFERING_DESCRIPTION = 'PMP_Partner_Offering_Dsc__c';
    //Added as a part of New L3 Storefront deatil page
    public static final String OFFERING_TAGLINE = 'PMP_Partner_Offering_Tag_Line_Txt__c'; 
    // Used in translation trigger class PMP_SearchCompanyTranslationAction
    public static final String Tagline = 'PMP_Account_Tag_Line__c';
    public static final String Description = 'PMP_Account_Dsc__c';
    
    public static final String Tag = 'PMP_Account_Tag_Line__c';
    
    
    // Languages supported for the MVP release
    public static final String English = 'English';
    public static final String Chinese = 'Simplified Chinese';
    public static final String Japanese = 'Japanese';
    //Language Codes
    public static final string EN_US= 'en_US';
    public static final string ZH_CN= 'zh_CN';
    public static final string ZH_HANS_CN= 'zh-Hans-CN';
    public static final string JA= 'ja';
    
    public static final String[] languagesSupported = new String[]{EN_US, ZH_CN, JA};
    public static final Map<String,String> localeMap = new Map<String,String>{EN_US => English,ZH_CN=>Chinese, ZH_HANS_CN => Chinese, JA => Japanese};
    public static final Map<String,String> languageCodeMap = new Map<String,String>{English => EN_US, Chinese => ZH_CN, Japanese => JA};        
            
    //Partner Lifecycle status //Do not replace with custom label
    public static final String Approved = 'Approved';
    public static final String Rejected = 'Rejected';
    public static final String Published = 'Published';    
    public static final String Update_Required = 'Update Required';
    public static final String Draft = 'Draft';
    public static final String Admin_Review = 'Admin Review';
    
    //Partner Translation Lifecycle
    public static final String Pending = 'Pending';
    
    //public static final String APPROVED = 'Approved';
    //public static final String UPDATE_REQUIRED = 'Update Required';
    //public static final String DRAFT = 'Draft';
    //public static final String ADMIN_REVIEW = 'Admin Review';
    
    //Added as part of US629512
    //Benefit related to the partner's account in Marketing Profile Information
    public static final String Solution_Marketplace_Basic_Access = 'Solution Marketplace Basic Access';
    public static final String Solutions_Marketplace_Basic_Profile = 'Solutions Marketplace Basic Profile';
    public static final String Solutions_Marketplace_Enhanced = 'Solutions Marketplace Enhanced';
    
    
    //sorting logic constant values
    public static final String SortFieldPartnerDescending = 'PartnerDescending';
    public static final String SortByDescending = getValue('PMP_Partner_Sort_By_Name_Desc');
    public static final String SortByAscending = getValue('PMP_Partner_Sort_By_Name_Asc');
    
    // for PMP_SearchProductController - sorting logic constants
    public static final String SortFieldProductPublishedDate = 'LatestPublishedLast';
    public static final String SortFieldProductPublishedDateFirst='LatestPublishedFirst';
    public static final String SortFieldProductAscending = 'ProductAscending';
    public static final String SortFieldProductDescending = 'ProductDescending';
    public static final String SortFieldByFeature = 'Featured';
    // public static final String SortByProductDescending = 'Name DESC NULLS LAST';
    // public static final String SortByProductAscending = 'Name ASC NULLS LAST';
    public static final String SortByProductPublishedDateFirst = 'PMP_Offering_Status_Update_Dt__c ASC NULLS LAST';
    //public static final String SortByProductPublishedDateLast ='PMP_Offering_Status_Update_Dt__c DESC NULLS LAST';
    //public static final String SortByProductPublishedDateFirst = getValue('PMP_Off_Sort_By_Pub_First');
    public static final String SortByProductPublishedDateLast = getValue('PMP_Off_Sort_By_Pub_Last');
    public static final String SortByFeature= getValue('PMP_Off_Sort_By_Featured');
    //New Sorting Constants
    public static final String SortByPartnerPublishedDateFirst = getValue('PMP_Partner_Sort_By_Pub_First');
   // public static final String SortByProductPublishedDateFirst = getValue('PMP_Product_Sort_By_Pub_First');
    public static final String SortByProdPartnerTier = getValue('PMP_Partner_Sort_By_Tier');
    public static final String SortByValue = getValue('PMP_Partner_Sort_By_Value');
    
    public static final String sortFieldTier = 'SORT_BY_TIER';
    public static final String sortFieldRecent = 'SORT_BY_MOST_RECENT';
   // public static final String sortByTierOffering = PMP_Utility.getValue('sortByTierOffering');
    //public static final String sortByMostRecentOffering = PMP_Utility.getValue('sortByMostRecentOffering');
    public static final String sortByTierPartner = 'PMP_Badge_Tier_Sequence_Nbr__c,Name';
    public static final String sortByMostRecentPartner = 'PMP_Company_Status_Update_Dt__c DESC NULLS LAST';
    
    
    //Moved static URL's to custome labels and used content asset to load image files by NIKHIL 26-Nov-2019
    public static final String staticProductUrl = getValue('PMP_Product_Card_Default_Image_URL');    
    public static final String staticPartnerUrl = getValue('PMP_Partner_Card_Default_Image_URL');
    public static final String staticStorefrontUrl = getValue('PMP_Storefront_Default_Image_URL');
    //Changes End
    
    public static final String PARTNER_ADMIN = getValue('PMP_External_Partner_Admin');    
    public static final String INTEL_ADMIN = getValue('PMP_Internal_Intel_Admin');
    public static final String guestUser = getValue('PMP_Guest_User_Name');
    public static final String MARKETING_SPECIALIST = getValue('PMP_External_Marketing_Specialist');
    public static final String OFFERING_EDITOR = getValue('PMP_External_Offering_Editor');
    public static final String LDR = getValue('PMP_External_LDR');
    public static final String EMPLOYEE = getValue('PMP_External_Employee');
    public static final String INTEL_EMPLOYEE = getValue('PMP_Internal_Intel_Read_Only');
    
    public static final String SYS_ADMIN_PROFILE = getValue('PMP_Sys_Admin_Profile');
    public static final String IT_ADMIN_PROFILE = getValue('PMP_IT_Admin_Profile');
    
    public static final String[] adminProfiles = new String[]{SYS_ADMIN_PROFILE, IT_ADMIN_PROFILE}; // Todo : changing strings into custom labels, since profile names may change with change in language 
        
    public static final String[] permissionSets = new String[]{PARTNER_ADMIN,MARKETING_SPECIALIST};   
    public static final String[] otherPartnerPSets = new String[]{MARKETING_SPECIALIST, OFFERING_EDITOR, LDR, EMPLOYEE};
    public static final String[] manageOfferingPermissionSets = new String[]{PARTNER_ADMIN,OFFERING_EDITOR};  
                    
                    
                    
    //for LeadGenForm
  	public static final String PreferredContact_CTA = 'Phone';        
    public static final String LeadSource = 'Partner Program';
    public static final String LeadConversionPoint = 'LCPxxxx';
    public static final String Marketing_Tactic_ID = 'MTIDxxxx';
    public static final String Source_ID = 'SourceIDxxxx';
    public static final String PartnerProgramSegment = 'xxxx';
    
    //PIM IDs
    public static final String PIM_CATEGORY_ID = getValue('PMP_PIM_Category_Id');
    public static final String PIM_INDUSTRY_ID = getValue('PMP_PIM_Industry_Id');
    public static final String PIM_APPLICATION_ID = getValue('PMP_PIM_Application_Id');
    public static final String REGION_PIM_ID = getValue('PMP_PIM_Region_Id');
    public static final String Geography = 'Geography';//added by krishna ch
    
    //Used in PMP_SearchFeaturedCarouselController for events tab
    public static final String EVENT_TAB_ID = 'Marketplace_Event';
    
    //Used in PMP_SearchEventDetailController for events detail page URL
    public static final String EVENT_URL = '/pmp-marketplace-event/';
    
    //Used in PMP_SearchAttributeController   
    public static final List<String> catOrder = new List<String>{PIM_CATEGORY_ID,PIM_INDUSTRY_ID,PIM_APPLICATION_ID};
        
    //Used in PMP_SearchContextualFilterController
   	public static final String CHECKBOX = getValue('PMP_Checkbox');
    public static final String LABEL = getValue('PMP_Label');
    public static final String RADIO = getValue('PMP_Radio_Button');
    public static final string[] DISPLAY_TYPES = new string[]{CHECKBOX,LABEL,RADIO};
        
    //Used in PMP_SearchEditStorefrontController
    //public static final string LOGO = System.Label.PMP_Edit_Storefront_Company_Information;
    public static final string COMPANY_DESCRIPTION = System.Label.PMP_Edit_Storefront_Company_Description;
    public static final string COMPANY_DETAILS = System.Label.PMP_Edit_Storefront_Company_Details;
    public static final string COMPANY_RESOURCES = System.Label.PMP_Edit_Storefront_Company_Resources;
    public static final string SUMMARY = System.Label.PMP_Edit_Storefront_Summary;//commented for deployment dont uncomment
    public static final string IPA_INTERNAL_ADMIN = getValue('PMP_IPA_INTERNAL_ADMIN');
    
    //Used in Attribute Controller
    public static final String SOLUTION_MARKETPLACE_HIERARCHY= getValue('PMP_SOLUTION_MARKETPLACE_HIERARCHY');
    
    //Do not translate this label
    public static final String LOEM_ODM_Partner_Program = getValue('PMP_LOEM_ODM_Partner_Program');
    
    //public static final String LOEM_ODM_Partner_Program = 'm0b0n00000001CcAAI';  //Megha to query the id from specialty metadata
    //public static final String LOEM_ODM_Partner_Program = 'ODM_LOEM';
    // Megha do not replace LOEM_ODM_Partner_Program name. Create a new static constant and query the id from specialty metadat
   //public static final PMP_Specialty__mdt specialty_Value =[Select Id from PMP_Specialty__mdt where Id='m0b0n00000001CcAAI'];
    
            /*  BNFTSMBA - Basic Access Benefit
                BFTMKTPLBC - Basic Profile Benefit
                BFTMKTPLED - Enhanced Benefit */

    //Benefit Code
    public static final String BENEFIT_ENHANCED_CODE = getValue('PMP_BENEFIT_ENHANCED_CODE');
    public static final String BENEFIT_BASIC_PROFILE = getValue('PMP_BENEFIT_BASIC_PROFILE');
    // Added as part of opid restructure - Sathish - 
    public static final String BENEFIT_BASIC_ACCESS_CODE= getValue('PMP_BENEFIT_BASIC_ACCESS_CODE');
    // Added by sathish for test - to be removed
    public static Boolean IS_AUTOMATIC_BENEFIT= false;
    //For Translation Logic
    public static final String CAT_NAME_FIELD = 'Name';
    public static final String CAT_DESC_FIELD = 'PMP_Partner_Offering_Category_Dsc__c';
    public static final String CAT_OBJ_API = 'PMP_Category__c';
    public static final String SPEC_OBJ_API = 'PMP_Specification__c';
    public static final String SPEC_NAME_FIELD = 'PMP_Specification_Name__c';
    public static final String SPECVAL_OBJ_API = 'PMP_Specification_Value__c';
    public static final String SPECVAL_NAME_FIELD = 'PMP_Specification_Value_Nm__c';
    public static final String OFF_TRANS_OBJ_API = 'PMP_Partner_Offering_Translation__c';
    public static final String OFF_CATE_FIELD ='PMP_Category_nm__c';
     public static final String OFF_SUBCATE_FIELD ='PMP_Sub_Category_nm__c';
    
    public static final String COMP_TRANS_OBJ_API = 'PMP_Company_Translation__c';
    
    //Added below boolean constant by krishna Ch as part of 101 SOQL fix
    public static Boolean isCompanyAfterUpdateTriggerActive = true;
    
    //Not used anywhere
    public static final String[] categoryPluralList = new String[]{System.label.PMP_Component_Plural, System.label.PMP_System_Plural, System.label.PMP_Service_Plural, System.label.PMP_Solution_Plural, System.label.PMP_Software_Plural}; 
    public static final String OfferingReferringURL = 'https://nppdevpmp-intelcloudcrm.cs67.force.com/imp/s/offering/offeringID/offeringName';
    public static final String SpecificLeadResource = 'Marketplace';
    public static final String LeadActionAAQ = 'Asked For Follow Up';
    public static final String LeadActionRFQ = 'Requested Quote';
    public static final Map<String,String> pimIdLabelMap = new Map<String,String>{'NPP_01_Industry'=>'Industry','NPP_01_APP'=>'Application'};
        
    //Maping for offering taxonomies
    public static final Map<String,String> taxonomyPimIdMap = new Map<String,String>{'offeringCategories' => 'NPP_01_TYPE', 'offeringIndustries' => 'NPP_01_Industry', 'offeringApplications' => 'NPP_01_APP'};
// 	public static final Map<String,String> taxonomyLabelMap = new Map<String,String>{'offeringCategories' => 'Offering Categories', 'offeringIndustries' => 'Offering Industries', 'offeringApplications' => 'Offerings by Application'};
//    public static final Map<String,String> taxonomyCtaLabelMap = new Map<String,String>{'offeringCategories' => 'View all offerings by Category', 'offeringIndustries' => 'View all offerings by Industry', 'offeringApplications' => 'View all offerings by Application'};
    // public static final Map<String,String> taxonomyLabelMapNew = new Map<String,String>{'offeringCategories' => 'Offerings by Category', 'offeringIndustries' => 'Offerings by Industry', 'offeringApplications' => 'Offering Applications'};
   	public static final Map<String,String> taxonomyLabelMapNew = new Map<String,String>{'offeringCategories' => 'OfferingCategories', 'offeringIndustries' => 'OfferingIndustries', 'offeringApplications' => 'OfferingApplications'};
   	//public static final Map<String,String> taxonomyLabelMap = new Map<String,String>{'offeringCategories' => System.Label.PMP_L0_Offerings_Category, 'offeringIndustries' => System.Label.PMP_L0_Offerings_Industry, 'offeringApplications' => System.Label.PMP_L0_Offerings_Application};
    //public static final Map<String,String> taxonomyLabelEnglishMap = new Map<String,String>{'offeringCategories' => System.Label.PMP_L0_Offerings_Category_English, 'offeringIndustries' => System.Label.PMP_L0_Offerings_Industry_English, 'offeringApplications' => System.Label.PMP_L0_Offerings_Application_English}; // Added as part of TWC1824-3754
    //public static final Map<String,String> taxonomyCtaLabelMap = new Map<String,String>{'offeringCategories' => System.Label.PMP_L0_ViewAll_Category, 'offeringIndustries' => System.Label.PMP_L0_ViewAll_Industry, 'offeringApplications' => System.Label.PMP_L0_ViewAll_Application};
    //Top level Lists for taxonomies
    
        public static final String[] offCategoryTopLevelList = new String[]{'TPS_900002', 'IPA_TYPE_Sys', 'TPS_900003', 'IPA_TYPE_Ser', 'IPA_TYPE_Sol'};
        public static final String[] industryTopLevelList = new String[]{'IPA_Ind_Finance&Insurance', 'IPA_Ind_EnergyUtil', 'IPA_Ind_HealthCare', 'IPA_Ind_Education', 'IPA_Ind_Manufacturing'};    
        public static final String[] offApplicationTopLevelList = new String[]{'IPA_APP_HighPerfComputing', 'IPA_APP_CloudComp', 'IPA_APP_ArtificalIntel', 'IPA_APP_DigSignage', 'IPA_APP_SmartCity'};
       
        public static final Map<String, String[]> taxonomyTopLevelListMap = new Map<String, String[]>{'offeringCategories' => offCategoryTopLevelList, 'offeringIndustries' => industryTopLevelList, 'offeringApplications' => offApplicationTopLevelList};    
        
            
        public static final String[] offFilterGroups = new String[]{'Technical Specifications','Business Filters'};
        public static final String[] partnerFilterGroups = new String[]{'Business Filters','Partner Information','Distributor Product'};
                
                
        //public static final Map<String, String[]> groupsByPageMap = new Map<String, String[]>{'offeringCategories' => offFilterGroups, 'offeringIndustries' => offFilterGroups, 'offeringApplications' => offFilterGroups,'partnerIndustries' => partnerFilterGroups,'partnerRole' => partnerFilterGroups,'partnerSpeciality' => partnerFilterGroups};        
		//public static final Map<String, String[]> groupsByPageMap = new Map<String, String[]>{'Offering Categories' => offFilterGroups, 'Offering Industries' => offFilterGroups, 'Offering Applications' => offFilterGroups,'Partner Industries' => partnerFilterGroups,'Partner Directory' => partnerFilterGroups,'Partner Specialties' => partnerFilterGroups};        
		 public static final Map<String, String[]> groupsByPageMap = new Map<String, String[]>{'OfferingCategories' => offFilterGroups,'OfferingSegments' =>partnerFilterGroups, 'OfferingIndustries' => offFilterGroups, 'OfferingApplications' => offFilterGroups, 'PartnerIndustries' => partnerFilterGroups,'PartnerDirectory' => partnerFilterGroups,'PartnerSpecialties' => partnerFilterGroups,'PartnerSegments' =>partnerFilterGroups};        
	    
         // static constants used in TaxonomyStore
         public static final String PIGroup = 'Partner Information';    
         public static final String[] PIGroupFilters = new String[]{'PartnerTier','IntelPartnerEvents','PartnerSpecialties','Solutions_Software_And_Services_Provider_Type'};
         public static final String DistributorProductGroup = 'Distributor Product'; 
         public static final String[] TopPartnerSegments = new String[]{'Client Computing','Data Center','Field Programmable Gate Array','Internet of Things and Embedded','Storage and Memory'};
		 //public static final String[] TopOfferingCategories = new String[]{'IPA_TYPE_Sol','IPA_TYPE_Ser','TPS_900003','IPA_TYPE_Sys','TPS_900002'};
		 //public static final String[] TopOfferingApplications = new String[]{'IPA_APP_ArtificalIntel','IPA_APP_CloudComp','IPA_APP_DigSignage','IPA_APP_HighPerfComputing','IPA_APP_SmartCity'};

        
             
        //Disti Partner
        public static final String distributor = 'Distributor';
        public static final String nandProduct = 'NAND Storage and Memory';
    	public static List<String> bizOrgTypes=new List<String> {'Intel Approved Component Supplier (IACS)','Intel Approved Device Supplier (IADS)','Intel Authorized Distributor (IAD)'};
        
         //Added by Krishna ch for : US854868 -KTBE : Changes in Biz org, Specialty story.
         public static final String serviceProviders = 'Solution, Software, and Service Providers';
         public static final String solProvider = 'Solution Provider';
         public static final String solAggregator = 'IoT Solution Aggregator';
         public static final String pagRecordTypeName = 'Core_Partner_Account_Group';
         public static Set<String> accountBizOrgTypeValues = new Set<String> {'IoT Solution Aggregator','Intel Approved Device Supplier (IADS)','Intel Approved Component Supplier (IACS)','Intel Authorized Distributor (IAD)'};

    	//for IOT used in editstorefrontcontroller
    	public static final String IOT = 'Internet of Things and Embedded';
    
    	//Member card default logo URL
    	public static final String MemberCardLogo = getValue('PMP_Member_Card_Logo');
    
    	//Event Default Logo
    	public static final String eventDefaultLogo = getValue('PMP_Event_Default_Logo');
    	
  		//for platform cache supoported languages
  		 public static final String supportedLanguagesForPlatformCache = getValue('PMP_Supported_Languages');

        //Breadcrumb	
        public static final String findAPartner = 'FIND A PARTNER';
    	
    	//Added as a part of L3 new Storefront detail Page
    	public static final String Offering = 'offering';
    	public static final String Article = 'article';
    	public static final String SOLUTION_PROVIDER = 'Solution Provider';
    	public static final String ZH_HANS_CN_NEW = 'zh_Hans_CN';
        public static final String ONBOARDING_EMAIL_SUPPRESS = 'Partner Onboarding Email is suppressed during Solutions Marketplace Basic Profile benefit assignment';
        public static final String OFFERING_CREATION_SUPPRESS = 'Offering Creation Email is suppressed during Solutions Marketplace Enhanced benefit assignment';

        //Offering Gallery Placeholder
		public static final String offeringGalleryPlaceholder1920px = getValue('PMP_Processing_Animation_1920px');
		public static final String offeringGalleryPlaceholder246px = getValue('PMP_ProcessAnimation_Thumbnail_246px');    

    
}