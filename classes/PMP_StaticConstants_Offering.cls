/**************************************************************************************
Apex Class Name: PMP_StaticConstants_Offering 
Version     : 1.0 
Created Date: 2nd Jan, 2019
Description : Class to store static constants  and which can be reused in otherclasses instead of hardcoding.
* Modification Log :
* Developer                 Date         Description
* ----------------------------------------------------------------------------
* Manasa          02/01/2019               Original Version
*************************************************************************************/
public class PMP_StaticConstants_Offering{

    
    public static final String garbage_Symbols='Grabage Symbols';
    public static final String garbageSymbols = 'garbageSymbols';
    public static final String options='options'; 
    public static final String companyInfo = 'companyInfo';
    public static final String Core_PMP_CreateOfferings = 'Core_PMP_CreateOfferings';
    public static final String High = 'High';
    public static final String DRAFT = 'Draft';
    public static final String URL = 'URL';
    public static final String ADMIN_REVIEW = 'Admin Review';
    public static final String Update_Required = 'Update Required';    
    //public static final String Product_Web_Page = 'Product Web Page';
    //public static final String Data_Sheet = 'Data Sheet';
    //public static final String Additional_Resources = 'Additional Resources';
    public static final String Others = 'Additional Resources';
    //public static final String Image = 'Image';
    public static final String uploadedFiles = 'uploadedFiles';
    public static final String contentVersions = 'contentVersions';
    public static final String OfferingDetail = 'OfferingDetail';
    public static final String existingURLs = 'existingURLs';
    public static final String masterCategoriesWithSelectedValues = 'masterCategoriesWithSelectedValues';
    public static final String selectedCategories = 'selectedCategories';
    public static final String selectedSpecifications = 'selectedSpecifications';
    public static final String selectedSpecificationsMap = 'selectedSpecificationsMap';
    public static final String includedIntelTechList = 'includedIntelTechList';
    public static final String partnerDetail = 'partnerDetail';
    public static final String offeringResources = 'offeringResources';
    
    public static final String English = 'English';
    public static final String Chinese = 'Simplified Chinese';
    public static final String Japanese = 'Japanese';
    
    public static final String Name = 'PMP_Partner_Offering_Nm__c';
    public static final String Tag = 'PMP_Partner_Offering_Tag_Line_Txt__c';
     public static final String Tag1 = 'PMP_Account_Tag_Line__c';
    public static final String Description = 'PMP_Partner_Offering_Dsc__c';
    public static final String Description1 = 'PMP_Account_Dsc__c';
    
    
    //Added by Shahrukh to check public content
    public static final String publicContent = 'Public Content';
    
    
    //for the class Core_PMP_CategoryController
    public static final string ROOT_NODE='Solution_Marketplace_Hierarchy';
    public static final string EN_US='en_US';
    public static final string ZH_CN='zh_CN';
    public static final string JA_JP='ja_JP';
    
    //for the class Core_PMP_SpecificationController 
    public static final string PROCESSOR='NPP_Processors';
    //Added by Deepanshu as a part of US567690
    public static final string NUC='NPP_NUC';
    public static final string CHIPSET='NPP_Chipsets';
    public static final string OS = 'NPP_OperationSystems';
    public static final string GEOREGION='NPP_GeographicCoverage'; //Added by Manasa
    public static final string INTELTECH='NPP_IntelTechnologies'; //Added by Manasa
    public static final string GRAPHICS='NPP_Graphics'; //Added by Yashasvi Aggarwal
    public static final string ENDCUSTOMERTYPE='NPP_EndCustomerType'; //Added by Manasa
    public static final string noOFProcessors='NPP_Processors_NoOfProcessors'; //Added by Manasa - US460366
    public static final string processorsSocketed='NPP_Processors_ProcessorSocketed'; //Added by Manasa - US460366
    public static final string YES='Yes'; //Added by Manasa - US460366
    
    //for the batch class Core_PMP_UpdateArchivalReminderDate
    public static final String ARCHIVED = 'Archived';
    public static final String APPROVED = 'Approved';
    public static final String comments_Archived = 'Offering will be Archived';
    public static final string Future_Publish_Template='PMP_Future_publish_Notification';
    public static final string OwnerName = '{!PMP_Offering__c.OwnerFirstName}';
    public static final string PublishOffering = 'Core_PMP_PublishOffering';
    public static final string AdminComments = '{!PMP_Offering__c.PMP_Review_Comment_Txt__c}'; 

    
    //for the class PMP_FetchOfferingFAEs
    public static final String TechnicalOwnerRole= 'Technical Owner (100%)';
    
    //for the class PMP_SendEmailAlertsToFAEs
    public static final String PMP_FAEReview = 'PMP_FAEReview';
    public static final String Pending_FAE_approval = 'Pending FAE approval';
    public static final String Intel_MP_Admin = 'Intel MP Admin'; 
    public static final String PMP_FirstReminder_FAEReview = 'PMP_FirstReminder_FAEReview';
    public static final String PMP_SecondReminder_FAEReview = 'PMP_SecondReminder_FAEReview';
    public static final String FAE_Review = 'FAE_Review';
    public static final String First_Reminder = 'First_Reminder';
    public static final String Second_Reminder = 'Second_Reminder';
    public static final String Offering_Name = '{!PMP_Offering__c.Name}';
    public static final String Offering_Admin_Name = '{!PMP_Offering__c.PMP_Intel_Admin_Nm__c}';
   
    //for the class PMP_PIMProduct
    public static final string PRODUCT_TYPE_VALUE = 'NPP Offering';
    public static final string TYPE_ID = 'NPP_01_TYPE';
    public static final string INDUSTRY_ID = 'NPP_01_Industry';
    public static final string APPLICAION_ID = 'NPP_01_APP';

    public static final string FPGA = 'NPP_FPGA';
    public static final string PRODUCT_WEB_PAGE = 'Web Page';
    public static final string DATA_SHEET = 'Data Sheet';
    public static final string PRODUCT_BRIEF = 'Product Brief';
    public static final string ADDITIONAL_RESOURCES = 'Additional Resources';
    public static final string IMAGE='Image';
    
    public static final string PRODUCT_TYPE = 'product_type';
    public static final string TITLE = 'title';
    public static final string PRODUCT_DESCRIPTION = 'product_description';
    public static final string TAGLINE ='tagline';
    public static final string VIEW_OPTION ='view_option';
    public static final string ATTRIBUTES = 'attributes';
    public static final string CATEGORY = 'category';
    
    public static final string PRODUCT_WEBPAGE_URL = 'Product_Webpage_URL';
    public static final string DATASHEET_URL = 'Datasheet_URL';
    public static final string PRODUCT_BRIEF_TITLE = 'Product_Brief_Title';
    public static final string PRODUCT_BRIEF_URL = 'Product_Brief_URL';
    public static final string ADDITIONAL_RESOURCE_TITLE  = 'Additional_Resource_Title';
    public static final string ADDITIONAL_RESOURCE_URL  = 'Additional_Resource_URL';
    public static final string SCREEN_SHOT='ScreenShot';
    public static final string INTEGER_TYPE='Integer';
    public static final string DATE_TYPE='Date';
    public static final string OFFERING_STATUS='OfferingStatus';
    public static final string COMPANY_ID='Company_Id';
    public static final string OWNER_ID='Owner_Id';
    public static final string COMPANT_NAME='Company_Name';
    public static final string OWNER_NAME='Owner_Name';
    public static final string PUBLISHED='Published';
    public static final string PUBLIC_CONTENT='Public Content';
    public static final string PUBLIC_STR='Public';
    public static final string POST='POST';
    public static final string PUT='PUT';
    public static final string OUT_OF_SYNC='Out of Sync';
    public static final string IN_SYNC='In Sync';
    public static final string PRODUCT_NO='product_no';
    public static final string SUCCESS='success';
    public static final string FAIL='fail';
    public static final string STATUS='status';
    public static final string CONTENT_TYPE='Content-Type';
    public static final string CONTENT_TYPE_JSON='application/json;charset=UTF-8';
    public static final string API_KEY='API_Key';
    public static final string FALSE_VALUE='false';   
    public static final Integer TIME_OUT=60000; 
    public static final String languages='languages';
    public static final String ITADMIN='IT Admin';
    public static final String SYSTEMADMIN='System Administrator';
    
    public static final String OfferingDetailCommunityURL = 'Offering Detail Community URL';
    public static final String MarketplacePageURL = 'Marketplace_page_url';
    public static final String THUMBNAIL_IMAGE = 'Thumbnail Image';
    
    /*Added by raj for restricted access*/
    public static final String[] adminProfiles = new String[]{'System Administrator', 'IT Admin'};
    public static final String[] manageOfferingPermissionSets = new String[]{'PMP_External_Partner_Admin','PMP_External_Offering_Editor'};
    public static final String showEditButton = 'showEditButton';
    /*----------End--------------------*/
    
    /*Added by raj for fetching Categories, Industries and Applications*/
    public static final String categoryType = 'Category';
    public static final String industry = 'Industry';
    public static final String application = 'Use Cases'; // value change from Application to Use Cases
    /*--------------------------End-----------------------*/
    
    /*Added by Sandhya for display of COmpany Resources*/
    Public static final String productCompanyResource = 'productCompanyResource';
    Public static final String articleCompanyResource = 'articleCompanyResource';
    
    /*Added by Sandhya for Guest Profile*/
     public static final String[] guestProfiles = new String[]{'Intel® Solutions Marketplace Profile'};
     
     //Breadcrumb
     public static final String findAnOffering = 'FIND AN OFFERING';
     public static final String IntelSolutionsMarketplace = 'Intel Solutions Marketplace';
    
     public static final String PDF = 'PDF';
     public static final String solutionCategory = 'Solution';
     public static final String partnerSolutionsCategory = 'Partner Solutions';

     //Added by Yashasvi Aggarwal for Video Integration
     public static final String Authorization = 'Authorization';
     public static final String Bearer = 'Bearer ';

     //Added by Pranjal for Video
     public static final String VIDEO = 'Video';
     public static final String BRIGHTCOVE = 'brightcove';

     //Added by Sandhya for BookMark Url redirection based on Status
     public static final String RETIRED = 'Retired';

     //Added by Deepanjana
     public static final String companyLink = '/s/partner-edit/,/s/offering-edit?recordId=,&Lang=en_US&action=edit,&lang=NAS&action=clone,/s/profile/,/s/solution-detail-page?recordId=,/s/offering/';
     @auraEnabled
     public static string returnCompany(){
        return companyLink;
     }
     
}