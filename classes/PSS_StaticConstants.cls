/**************************************************************************************
Apex Class Name: PSS_StaticConstants 
Version     : 1.0 
Created Date: 15th Feb, 2021
Description : Class to store static constants  and which can be reused in otherclasses instead of hardcoding.
* Modification Log :
* Developer                 Date         Description
* ----------------------------------------------------------------------------
* Shahrukh Riyan          15/02/2021    Original Version
*************************************************************************************/

public without sharing class PSS_StaticConstants{   
    public static final String COMPLETED='Completed';
    public static final String ADMIN_REVIEW='Admin Review';
    public static final String IN_PROGRESS='In Progress';
    public static final String SOLUTION_APPROVED_STATUS = 'Approved';
    public static final String SOLUTION_REJECTED_STATUS = 'Rejected';
    public static final String SOLUTION_CANCELLED_STATUS = 'Cancelled';
    public static final String SOLUTION_ONHOLD_STATUS = 'On Hold';
    public static final String SOLUTION_UPDATE_REQUIRED_STATUS = 'Update Required';
    public static final String REVIEW_SCHEDULED = 'Review Scheduled';
    public static final String RETIRED='Retired';
    public static final String SOLUTION_WORKFLOW_REJECT_STATUS = 'Reject';
    public static final String SOLUTIONS_MARKETPLACE_ENHANCED='Solutions Marketplace Enhanced';
    public static final String SOLUTIONS_CONVERSION_RESOURCEOBJECT_NAME = 'Partner Offering Resource';
    public static final String SURVEY_QUESTION_DISPLAY_ORDER = '001';
    public static final String SURVEY_QUESTION_RADIO_DISPLAY = 'Vertical Radio';
    public static final String SURVEY_SECTION_SHORT_TITLE = 'WLC';
    public static final String SURVEY_QUESTION_THANKS_TYPE = 'Text-Thanks';
    public static final String SOLUTION_CONVERTED_STATUS = 'Converted to MP Offerings';
    public static final String DRAFT = 'Draft';
    public static final String SELECT_BENEFITS = 'Select Benefits';
    public static final String LOG_MESSAGE_SEPERATOR = ' -- ';
    public static final String PERMISSION_FOR_Employee='PMP_External_Employee';
    public static final String PUBLIC_GROUP_FOR_GETMADMIN='PSS_All_Intel_Admin_Users';
    public static final String DATA_COLLECTION = 'Data Collection';
    public static final String REVIEW = 'Review';
    public static Boolean opIDTriggerLogicStop = True;
    public static Boolean intelProductsTriggerLogicStop = True;
    public static Boolean questionResultTriggerFlag = True;
    public static final List<String> PARTNER_LISTVIEW = new List<String> {'All','Admin_Review_Queue'};
    //public static final List<String> PARTNER_OFFERING_LISTVIEW = new List<String> {'All_Offerings','Retired_Offerings'};//IPA 2.0 OFFERING EOL
    //public static final List<String> ADMIN_REVIEW_LISTVIEW_OFFERING = new List<String> {'Admin_Review_Queue','All_Offerings','Retired_Offerings'};//IPA 2.0 OFFERING EOL
    public static final List<String> ADMIN_REVIEW_LISTVIEW = new List<String> {'All_Custom','Admin_Review_DCG','Admin_Review_IOTG','Admin_Review_Partner_Solutions','All_DCG','All_IOTG','All_Partner_Solutions'};
    public static final String ALL_LISTVIEW = 'All_Custom';
    
    
    public static final String SOLUTION_DETAIL_FILE_URL = '/sfc/servlet.shepherd/version/download/';
    public static final String SOLUTION_DETAIL_FILE_EXTENSION='?asPdf=false&operationContent=CHATTER';
    public static final String PARTNER_PROFILE='Partner';
    public static final String PARTNER_ACCOUNT_GROUP ='Partner Account Group';
    public static final String INTEL_ACCOUNT ='Intel Account';
    public static final String INTEL_ACCOUNT_DEVELOPERNAME = 'Mastered_Account';
    public static final String PAG_ACCOUNT_DEVELOPERNAME = 'Core_Partner_Account_Group';
    public static final String IOTG_INTELPRODUCT= 'IOTG_IntelProduct';
    public static final String IOTG_PROJECTED_QUANTITY = 'IOTG_ProjectedQuantity';
    public static final String DCG_PAST_REVENUE = 'DCG-PastRevenue';
    public static final List<String> INTEL_PRODUCT_UNIQUE_KEYS = New List<String>{'IOTG_IntelProduct','IOTG_ProjectedQuantity'}; 
    public static final String MRS = 'MRS';
    public static final String MRS_RRK = 'MRS,RRK';
    public static final String RRK = 'RRK';
    public static final String PARTNER_SOLUTION = 'Partner Solution';
    public static final String INTEL_SELECT = 'Intel Select';
    public static final String INTEL_SCALE = 'Intel Scale';
    public static final String INTEL_DATA_CENTER = 'Intel Data Center-Centric Solutions';
    public static final String NO_CATEGORY = 'No Category';
    public static final String DCG_INTELPRODUCT = 'DCG_IntelProduct';
    public static final String IOTG_GEO_COUNTRIES = 'IOTG_Geo_Countries';
    public static final String IOTG_Geographies_Available = 'IOTG_Geographies_Available';
    public static final String IOTG_Geographies_deployed = 'IOTG_Geographies_deployed';
    public static final String DCG_PASTREVENUE = 'DCG-PastRevenue';
    public static final String DCG_REVENUEPROJECTION = 'dcg-revenue-projection';
    public static final String DCG_STRATEGICQUE = 'DCG_StrategicQue';
    public static final String IOTG_VIRTUAL_LAYER = 'IOTG_Virtual_Layer';
    public static final String WORKLOAD_CONSOLIDATION = 'Workload Consolidation';
    public static final String IOTG_HIDDEN_CATEGORY_SCORING_NEW = 'IOTG_Hidden_Category_Scoring1';
    public static final List<String> PRODUCT_UNIQUE_KEYS = New List<String>{'IOTG_IntelProduct','IOTG_ProjectedQuantity','IOTG_Geographies_Available','DCG_IntelProduct','IOTG_Geo_Countries',
                                                           'DCG-PastRevenue','dcg-revenue-projection','DCG_StrategicQue','IOTG_Virtual_Layer','IOTG_Geographies_deployed'};
    public static final Map<String,String> EMAIL_TEMPLATES = new Map<String,String>{'PSS_Solution_Shared' => 'PSS_ContactAdded_Solution', 'PSS_Solution_Unshared' => 'PSS_ContactRemoved_Solution'};
    public static final String TCS = 'TCS';
    public static final String QUIT = 'Quit';
    public static final String NEXT = 'Next';
    //public static final String Offering_Web_Page='Offering Web page';//IPA 2.0 OFFERING EOL
    public static final Set<String> MRSAndRRK= new Set<String> {'MRS','RRK'};
    public static final String ENTITLEMENT_PA = 'Partner Admin';
    public static final String ENTITLEMENT_PAD = 'Partner Admin Delegate';
    public static final String ENTITLEMENT_OE = 'Offering Editor';
    public static final String ENTITLEMENT_STATUS_PENDING = 'Pending';
    public static final String ENTITLEMENT_STATUS_COMPLETE = 'Complete';
    public PSS_StaticConstants(){}
}