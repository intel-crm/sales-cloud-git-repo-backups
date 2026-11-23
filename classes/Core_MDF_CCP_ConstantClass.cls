//Class created to store constants
public class Core_MDF_CCP_ConstantClass {
    //CASE STATUS
    public static final String CASE_OPEN_STATUS = 'Under Review'; 
    public static final String CASE_OPEN = 'Open';
    public static final String CASE_OPEN_RECORDTYPE_NAME = 'Core_MDF_Audit';
    //PFR RECORD TYPE
    public static final String PFR_CCF_RECORDTYPE = 'Core_MDF_Client_CoMarketing_Fund';
    public static final String PFR_DCF_RECORDTYPE = 'Core_MDF_Data_Center_CoMarketing_Fund';
   // public static final String PFR_CMDF_RECORDTYPE = 'Core_MDF_Channel_MDF';
    public static final String PFR_IPA_RECORDTYPE = 'Core_MDF_Intel_Partner_Alliance';
    public static final String PFR_SPCMP_RECORDTYPE = 'Core_MDF_Service_Provider_CoMarketing_Fund';
    public static final String PFR_CCFB_RECORDTYPE = 'Core_MDF_Client_CoMarketing_Fund_Boost';
    public static final String PFR_RMF_RECORDTYPE = 'Core_MDF_Retail_Marketing_Funds';
    public static final String PFR_EEF_RECORDTYPE = 'Core_MDF_Ecosystem_Extension_Fund';
    //PFR BUDGET TYPE
    public static final String OEM_CMP_BUDGET_TYPE = 'OEM CMP';
    public static final String SPCMP_BUDGET_TYPE = 'Service Provider CMP';
    public static final String MDF_BUDGET_TYPE = 'MDF';
    public static final String MDFPLUS_BUDGET_TYPE = 'MDF+';
    public static final String CCF_Legacy_BUDGET_TYPE = 'CCF 1.0';
    public static final String DCF_Legacy_BUDGET_TYPE = 'DCF 1.0';
    public static final String BCA_MDF_BUDGET_TYPE = 'Business Client Acceleration - MDF';
    public static final String CS_MDF_BUDGET_TYPE ='Client Specialties MDF';
    public static final String PR_MDF_BUDGET_TYPE = 'Proposal I MDF';
    public static final String EEF_BUDGET_TYPE = 'Cloud';
    
    //PFR APPROVAL STAGE
    public static final String PFR_L1_APPROVAL = 'L1 Approval';
    public static final String PFR_L2_APPROVAL = 'L2 Approval';
    public static final String PFR_FIRST_LEVEL_MGR = 'First Level Manager';
    public static final String PFR_SECOND_LEVEL_MGR = 'Second Level Manager';
  public static final String PFR_PRICE_REVIEWER = 'Price Reviewer';    
    public static final String PFR_CUSTOMER_ACCEPTANCE = 'Customer Acceptance';
    //public static final String PFR_L2_REGIONAL_SALES = 'L2 Regional Sales';
    //public static final String PFR_L2_REGIONAL_MARKETING = 'L2 Regional Marketing';
    //PFR STATUS
    public static final String PFR_PENDING_REVIEW_STATUS = 'Pending Review';
    public static final String PFR_CLOSED_STATUS = 'Closed';
    public static final String PFR_CANCELLED_STATUS = 'Cancelled';
    public static final String PFR_REJECTED_STATUS = 'Rejected';
    public static final String PFR_APPROVED_STATUS = 'Approved';
  public static final String PFR_RR_STATUS = 'Revision Required';
    public static final String PFR_PLANNED_STATUS = 'Planned';   
    public static final String PFR_PENDING_APPROVAL_STATUS = 'Pending Approval';
    public static final String PFR_PENDING_STATUS = 'Pending';
    public static final String PFR_IN_PROGRESS_PENDING_REVIEW_STATUS = 'In-Progress Pending Review';
    public static final String PFR_IN_PROGRESS_PENDING_APPROVAL_STATUS = 'In-Progress Pending Approval';
    public static final String PFR_IN_PROGRESS_REVISION_REQUIRED_STATUS = 'In-Progress Revision Required';
    public static final String PFR_IN_PROGRESS_STATUS = 'In-Progress';
    
    // PFR PROGRAM
    //public static final String PFR_CHANNEL_MDF_PROGRAM = 'Channel MDF';
    public static final String PFR_IPA_PROGRAM = 'Intel Partner Alliance';
    public static final String PFR_RMF_PROGRAM = 'Retail Marketing Funds';
    public static final String PFR_EEF_PROGRAM = 'Ecosystem Extension Fund';
    //PFR ACTIVITY CATEGORY
    public static final String PFR_EVENT_CATEGORY = 'Event';
    public static final String PFR_EVENT_2025_CATEGORY = 'Event 2025';
    public static final String PFR_PRINT_MEDIA_CATEGORY = 'Print Media';
    public static final String PFR_JOINT_EVENT_CATEGORY = 'Joint Event';
    public static final String PFR_THIRD_PARTY_CATEGORY = 'Third Party Event';
    //PFR SUB GEO
    public static final String PFR_LAR_SUBGEO = 'LAR';
    public static final String PFR_NAR_SUBGEO = 'NAR';
    //PFR BUDGET CURRENCY
    public static final String PFR_CURRENCY_USD = 'USD';
    //PFR REGION
    public static final String PFR_REGION_EMEA = 'EMEA';
    //PFR APPROVER SOURCE
    public static final String PFR_APP_SOURCE_IUPGM = 'IUPGM';
    //RULE ENGINE 
    public static final String RULE_ENGINE_FRONT_END_REVIEW = 'Front End Review';
    public static final String RULE_ENGINE_NO_ACTION = 'No Action';
    public static final String RULE_ENGINE_APPROVAL_CRITERIA = 'Approval Criteria';
    public static final String RULE_ENGINE_OBJECT_FIELD = 'Object Field';
    //FIELD LIMIT
    public static final Integer LONG_TEXT_AREA_LIMIT = 32768;
    public static final Integer COMMENT_FIELD_LIMIT = 131072;
    //PFR ACTIVITY CLOSURE TYPE
    public static final String PFR_AUTO = 'Auto';
    public static final String PFR_AUTO_MISSED_APPROVAL = 'Auto - Missed Approval';
    public static final String PFR_AUTO_MISSED_IN_PROGRESS_APPROVAL = 'Auto - Missed In-Progress Approval';
    public static final String PFR_MANUAL_MISSED_APPROVAL = 'Manual - Missed Approval';
    public static final String PFR_RevisionRequired = 'Revision Required';
    public static final String PFR_Manual_Close = 'Manual';
    //ESCALATION
    public static final String ESC_APPROVED_STATUS = 'Approved';
    public static final String LATECLAIM_TYPE = 'Late Claim';
    public static final String ESC_EXPIRED_STATUS = 'Expired';
    public static final String ESC_CANCELLED_EXPIRED_STATUS = 'Cancelled;Expired';
    public static final String ESC_PENDING_REVIEW_STATUS = 'Pending Review';
    //CLAIM
    public static final String TYPE_CLAIM = 'Claim';
    public static final String PENDING_ACCOUNT_MANAGER_CLARIFICATION = 'Pending Account Manager Clarification';  //Roshan
    public static final String PENDING_CLARIFICATION = 'Pending Clarification'; 
    public static final String BULK_CLAIM_TEMPLATE = 'Bulk Claim Template';
    //To Throw mandatory error if Event Name is Blank for below mentioned Activity Types
    public static final string EVENT_ACTIVITY_TYPE = 'Other (Event),Third Party Event,Joint Event';
    
     //Internal CSC user PS
    public static final string INTERNAL_CSC_PS = 'Core_MDF_Internal_CSC_User';
    
    //Auto Transfer Type
    public static final string AUTO_ACTIVITY_TRANSFER_TYPE = 'Auto-Activity';

    
    //CAMPAIGN
    public static final String COMPLETED_APPROVAL_LEVEL = 'L1 Approval';
    public static final Integer INCREMENT_STEP_COUNTER = 0;
    public static final String CAMPAIGN_ALL_REGION = 'APJ;ASMO;EMEA;PRC;INDIA';
    public static final String CO_ENGINEERING_DEFAULT_ACT_CAT_TYPE = 'Innovation ->Engineering';
    public static final String CAMPAIGN_ATF_DATE = 'ATF Date';

    //Object Name - Opportunity
    public static final String OPPORTUNITY_OBJECT_NAME = 'Opportunity';

    //CAMPAIGN STATUS
    public static final String CAMPAIGN_PENDING_REVIEW = 'Pending Review';
    public static final String CAMPAIGN_PLANNED = 'Planned';
    public static final String CAMPAIGN_IN_PROGRESS = 'In Progress';
    public static final String CAMPAIGN_COMPLETED = 'Completed';
    public static final String CAMPAIGN_REVISION_REQUIRED = 'Revision Required';
    public static final String CAMPAIGN_CANCELLED = 'Cancelled';
    public static final String CAMPAIGN_PENDING_APPROVAL = 'Pending Approval';
    public static final String CAMPAIGN_PROPOSAL_ACCEPTED = 'Proposal Accepted';
    public static final String CAMPAIGN_DECLINED = 'Declined';
    public static final String CAMPAIGN_ACCEPTED = 'Campaign Accepted';  // Roshan - CoGTM Intermediate status

    //EXCEPTION STATUS
    public static final String EXCEPTION_PENDING_REVIEW = 'Pending Review';
    public static final String PFR_EEF_APINAME = 'Core_MDF_Ecosystem_Extension_Fund';

    //Budget STATUS
    public static final String Budget_PENDING_REVIEW = 'Pending Review';
    
    //Account Record Type
    public static final String ACCOUNT_RECORD_TYPE = 'Core_MDF_Co_Marketing';


    
     // APPROVAL STAGE
    public static final String L1_APPROVAL = 'L1 Approval';
    public static final String L2_APPROVAL = 'L2 Approval';
    public static final String FIRST_LEVEL_MGR = 'First Level Manager';
    public static final String SECOND_LEVEL_MGR = 'Second Level Manager';
  public static final String PRICE_REVIEWER = 'Price Reviewer';    
    public static final String CUSTOMER_ACCEPTANCE = 'Customer Acceptance';
    public static final String L2_REGIONAL_SALES = 'L2 Regional Sales';
    public static final String L2_REGIONAL_MARKETING = 'L2 Regional Marketing';
    public static final String PROGRAM_OFFICE_REVIEWER = 'Program Office Reviewer';
    public static final String GEO_LEAD = 'Geo Lead Approval';
    public static final String L1_APPROVAL_ACTIVATING_PARTNER = 'L1 Approval (Activating Partner)'; 
    public static final String L1_APPROVAL_PRIMARY_PARTNER = 'L1 Approval (Primary Partner)'; 
    public static final String L2_PRIMARY_APPROVAL = 'L2 Primary Approval';
    public static final String CUSTOMER_ACCEPTANCE_PRIMARY_PARTNER = 'Customer Acceptance (Primary Partner)';
    public static final String CUSTOMER_ACCEPTANCE_ACTIVATING_PARTNER = 'Customer Acceptance (Activating Partner)';
    public static final String PFR_EEF_ACTIVATINGPARTNER = 'ActivatingPartner';
    public static final String PFR_EEF_PRIMARYPARTNER = 'PrimaryPartner';
    public static final String LEGAL_REVIEWER = 'Legal Reviewer';  //Roshan - Co-GTM campaign setup 
    public static final String BUSINESS_APPROVER = 'Business Approver'; 
    public static final String Technical_Approver = 'Technical Approver'; //Roshan Co-GTM Claim
    public static final String Account_Manager = 'Account Manager'; //Swati IPA Claim
    //ROLE
     public static final String CCF_PRICE_REVIEWER = 'Core_MDF_CCP_Internal_Price_Reviewer';    
     public static final String L2_Iupgm_Role ='Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver';
     public static final String CCF_Internal_Acct_Mgr = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';    
     public static final String DCF_Internal_Acct_Mgr ='Core_MDF_CCP_Internal_DCF_Acct_Mgr';
     //Campaign Record Type
    @AuraEnabled
    public final String CMP_CCF_RECORDTYPE = 'Core_MDF_Client_CoMarketing_Fund';
    @AuraEnabled
    public final String CMP_DCF_RECORDTYPE = 'Core_MDF_Data_Center_CoMarketing_Fund';
    public static final String CMP_IPA_RECORDTYPE = 'Core_MDF_Intel_Partner_Alliance';
    public static final String CMP_SPCMP_RECORDTYPE = 'Core_MDF_Service_Provider_CoMarketing_Fund';
    public static final String CMP_CCFB_RECORDTYPE = 'Core_MDF_Client_CoMarketing_Fund_Boost';
    public static final String CMP_RMF_RECORDTYPE = 'Core_MDF_Retail_Marketing_Funds';
    public static final String CMP_EEF_RECORDTYPE = 'Core_MDF_Ecosystem_Extension_Fund';
    public static final String CMP_CO_GTM_RECORDTYPE = 'Core_MDF_Co_GTM';
    
    //PROGRAMS Names not API names
    public static final String CCF_PROGRAM = 'Client';
    public static final String DCF_PROGRAM = 'Datacenter';
    public static final String CCF_TECHNICAL_PROGRAM_NAME = 'Client CoMarketing Fund';
    public static final String DCF_TECHNICAL_PROGRAM_NAME = 'Data Center CoMarketing Fund';
   // public static final String CMDF_PROGRAM = 'Channel MDF';
    public static final String IPA_PROGRAM = 'Intel Partner Alliance';
    public static final String SPCF_PROGRAM = 'Service Provider Co-Marketing Fund';
    public static final String CCFB_PROGRAM = 'Client Co-Marketing Fund Boost';
    public static final String RMF_PROGRAM = 'Retail Marketing Funds';
    public static final String EEF_PROGRAM = 'Ecosystem Extension Fund';
    public static final String Co_GTM_PROGRAM = 'Co-GTM';
    public static final String Co_GTM_TECHNICAL_PROGRAM = 'CoGTM';
    public static final String CCFB_TECHNICAL_PROGRAM_NAME = 'Client CoMarketing Fund Boost';
    public static final String SPCF_TECHNICAL_PROGRAM_NAME = 'Service Provider CoMarketing Fund';
    
    public static final List<String> validOutcomeMetricProgramName = new List<String>{'Client CoMarketing Fund','Data Center CoMarketing Fund','Intel Partner Alliance','Retail Marketing Funds'};

    
    public static final Set<string> MDF_BUDGETTYPES= new Set<string>{'MDF','MDF+'};
    
    //CampActPartners default rr%
    public static final String ActPartner_RR_Pct = '100%';

    //Campaign Budgets default RR% for CCF/DCF
    @AuraEnabled
    public final String defaultRR_Pct = '50%';
    
    //Roshan - added for IPA OutcomeBased claims
    public static final String CLAIM_APPROVAL_MAPPING = 'Core_MDF_Claim_Approval_Role_Mappings';

    //Account PartnerType
    public static final String ACTIVATING_PARTNER = 'Activating Partner';
    public static final String PRIMARY_PARTNER = 'Primary Partner';
    public static final List<String> ELIGIBLE_PFRSTATUS_FOR_REVERSAL = new list<String>{'Planned','Pending Review'};


    //Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr PS 
    public static final String EEF_Primary_Partner_Account_Manager= 'Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr';
    //LOCALE
    public static final String CCP_SUPPORTED_LOCALE = 'zh_CN,zh_TW,fr,de,it,ja,ko,ru,es_MX,es,pt_BR,en_US';
   
    public static final String IPA_PROP_EMAIL_TEMPLATE = 'Core_MDF_NotifyProposalApprovers' ;

    //Roshan - modified for hiding comments for external user for CoGTM
    //public string CAMPAIGN_APPROVAL_HISTORY_JSON ='[ {"record":[{"step_Name": "Price Reviewer","comments_masked": "true","comments_desc":"Please contact your Account Manager for details"}],"ps_name":"Core_MDF_CCP_External_IPA_Proposal_Manager"}]';
    public string CAMPAIGN_APPROVAL_HISTORY_JSON = '[{"record": [{"step_Name": "Price Reviewer","comments_masked": "true","comments_desc": "Please contact your Account Manager for details"}],"ps_name": "ALLUSERS"}, {"record": [{"step_Name": "Legal Reviewer","comments_masked": "true","comments_desc": "Please contact your Account Manager for details"}],"ps_name": "ALLUSERS"},{"record": [{"step_Name": "Business Approver","comments_masked": "true","comments_desc": "Please contact your Account Manager for details"}],"ps_name": "ALLUSERS"}]';
    public string PFR_IPA_ACCBASED_EXT_APPROVAL_HISTORY_JSON = '[{"record":[{"step_Name": "Price Reviewer","comments_masked": "true","comments_desc":"Please contact your Account Manager for details"}],"ps_name":"Core_MDF_CCP_External_IPA_Activity_Manager"}]';
    
    //IPA Multiselect Picklists - CampFieldAPIName vs ActivityFieldAPIName
    public static final string  CAMPAIGN_FIELD_AND_ACTIVITY_FIELD_APINAMES = '{"Core_MDF_Audience__c": "Core_MDF_TargetAudience_nm__c","Core_MDF_Market__c": "Core_MDF_Country_nm__c","Core_MDF_IPA_Priority_nm__c": "Core_MDF_Priority_nm__c","Core_MDF_Industry_Nm__c": "Core_MDF_Industry_Multi_nm__c","Core_MDF_Initiative_nm__c": "Core_MDF_Initiative_nm__c","Core_MDF_Focus_Area_nm__c": "Core_MDF_Focus_Area_nm__c","Core_MDF_Brand__c": "Core_MDF_Brand_nm__c","Core_MDF_Product_Type__c": "Core_MDF_ProductType__c","Core_MDF_Ecosystem_Partner_Nm__c": "Core_MDF_EcosystemPartner_nm__c","Core_MDF_Opal_Budget_Type_Txt__c":"Core_MDF_Budget_Type_nm__c"}';
    
  //  public static final string EXCEPTION_REVIEWER_PROGRAM_MAPPING = '{"Core_MDF_Intel_Partner_Alliance": "Core_MDF_Internal_IPA_Exception_Reviewer","Core_MDF_Client_CoMarketing_Fund": "Core_MDF_CCP_Internal_CCF_Exception_Reviewer","Core_MDF_Data_Center_CoMarketing_Fund": "Core_MDF_CCP_Internal_DCF_Exception_Reviewer","Core_MDF_Service_Provider_CoMarketing_Fund": "Core_MDF_CCP_Internal_SPCF_Exception_Reviewer","Core_MDF_Client_CoMarketing_Fund_Boost": "Core_MDF_CCP_Internal_CCF_Boost_Exception_Reviewer","Core_MDF_Retail_Marketing_Funds": "Core_MDF_CCP_Internal_RMF_Exception_Reviewer"}';
    public static final string CCP_CAMPAIGN_FIELD_AND_ACTIVITY_FIELD_APINAMES = '{"Core_MDF_Audience__c": "Core_MDF_TargetAudience__c","Core_MDF_Market__c": "Core_MDF_Country_nm__c", "Core_MDF_Product_Type__c": "Core_MDF_ProductType__c", "Core_MDF_Brand__c": "Core_MDF_Brand_nm__c","Core_MDF_Activity_Category_Type__c": "Core_MDF_Activity_Types__c", "Core_MDF_Priority__c": "Core_MDF_Priorities__c", "Core_MDF_Priority_2_nm__c": "Core_MDF_Priorities__c", "Core_MDF_Priority_3_nm__c": "Core_MDF_Priorities__c","Core_MDF_Opal_Budget_Type_Txt__c":"Core_MDF_Budget_Type_nm__c","Core_MDF_Budget_Type_txt__c":"Core_MDF_Budget_Type_nm__c","Core_MDF_Industry_Nm__c": "Core_MDF_Industry_Multi_nm__c"}';

    public static final string GTM_CAMPAIGN_FIELD_AND_ACTIVITY_FIELD_APINAMES = '{"Core_MDF_Audience__c": "Core_MDF_TargetAudience__c","Core_MDF_Market__c": "Core_MDF_Country_nm__c", "Core_MDF_Product_Type__c": "Core_MDF_ProductType__c", "Core_MDF_Brand__c": "Core_MDF_Brand_nm__c","Core_MDF_Activity_Category_Type__c": "Core_MDF_Activity_Types__c", "Core_MDF_Priority__c": "Core_MDF_Priorities__c", "Core_MDF_Priority_2_nm__c": "Core_MDF_Priorities__c", "Core_MDF_Priority_3_nm__c": "Core_MDF_Priorities__c","Core_MDF_Opal_Budget_Type_Txt__c":"Core_MDF_Budget_Type_nm__c","Core_MDF_Budget_Type_txt__c":"Core_MDF_Budget_Type_nm__c","Core_MDF_Industry_Nm__c": "Core_MDF_Industry_Multi_nm__c"}';

    
    //IPA Activity Status Declined - Will be reverted later
    public static final String ACTIVITY_STATUS_DECLINED = 'Declined';
    
    //EmailLog Contsants Success and Failure
    public static final String strSuccess = 'Success';
    public static final String strFailed = 'Failed';

    //Recovery Notification Batch actions
    public static final String SEND_EMAIL = 'SendEmail';
    public static final String SCHEDULE_RECOVERY_NOTIFICATION = 'ScheduleRecoveryNotification';
    //SFT Profiles
    public static String SFT_Profiles  = 'IT Admin, System Administrator';


    //Bank LE Code
    public static String Bank_LE420 = '420';
    public static String Bank_LE650 = '650';
    
    
     //Programs for which claim recovery needs to be done based on node accounts
     public static final Set<string> Programs_For_Node_Account = new Set<string>{'Retail Marketing Funds','Intel Partner Alliance'};

    //Campaign fields to be emptied on clone
    public static final List<String> CAMPAIGN_EXCLUDED_FIELDS = new List<String>{'Core_MDF_Proposal_Score_nbr__c','Core_MDF_Comments_Internal_Only__c','Core_MDF_Comments__c','Core_MDF_Priority_Percentage__c','Core_MDF_Priority_Percentage_2__c','Core_MDF_Priority_Percentage_3__c'};

    //Campaign status to be queried on claim
    public static final List<String> CAMPAIGN_STATUSES_TO_QUERY_CLAIMS = new List<String>{'In Progress','Cancelled', 'Revision Required'};

    //PFR valid active statuses
    public static final List<String> VALID_PFR_STATUSES = new List<String>{'Draft', 'Revision Required', 'Pending Review', 'Pending Approval', 'Planned', 'In-Progress', 'Proposal Accepted', 'In-Progress Revision Required','In-Progress Pending Approval', 'In-Progress Pending Review'};

    public static final List<String> defaultFieldsToMask = new List<String>{'Owner'};

     //Values to pass for Recovery Batch Scheduler
     public static string jobFrequency = 'Once';
     public static string priority = 'High';
     public static string programTxt = 'CCP';
     public static string recoveryBatch = 'Core_MDF_Recovery_Batch';

    //Record Type Id and Name
    public static Id coMarketing_RecordType_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Core_MDF_Co_Marketing_Record_Type_Name).getRecordTypeId();
    public static Id master_RecordType_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    
     Public static Map<String, string> stageToClassificationMap = new Map<String, string>{'L2 Regional Sales' => 'Sales', 'L2 Regional Marketing' => 'Marketing'};    
    Public static List<String> L2_APPROVAL_STAGES = new List<String>{'L2 Regional Marketing','L2 Regional Sales'};   

    Public static Set<String> ipaReminderEmailTemplates = new Set<String>{'Core_MDF_IPA_ReminderNotification','Core_MDF_IPA_ReminderNotification_Ext'}; 
     public static final String ipaClaimSubmitterPS ='Core_MDF_CCP_External_IPA_Claim_Submitter';
     public static final String allAccountYes ='Yes';
         
     public static final String EXTERNAL_CLAIM_SUBMITTER ='Core_MDF_CCP_External_Claim_Submitter';
     
      public static final String CANCELLED_STATUS ='Cancelled';
      Public static List<String> Intel_Owner_Based_Notification_Prog =  new List<string>{'Client','Datacenter'};
       Public static List<string> IUPGM_Based_Notification_Prog = new List<string>{'Retail Marketing Funds','Intel Partner Alliance'};
       Public static final String AUDIT_CLOSED = 'Audit Closed';
        Public static final String REVIEW_COMPLETED = 'Review Completed';
        Public static final String PAID_CLAIMS = 'Paid';
        
    public static final String httpAuthorization = 'Authorization';
   
    public static final List<String> allAccessGroupSupportedPrograms = new List<String>{'Client CoMarketing Fund','Data Center CoMarketing Fund','Ecosystem Extension Fund'};

    //EFT Character Limit
    public static final Integer EFT_Char_Limit = 1001;
     
    //Pic Question Respones Set
    public static Set<String> picQuestionResponses = new Set<String>{'No','true'};
     
    //Feedback LoginHistory Status
    public static final String FEEDBACK_SUCCESS_STATUS = 'Success';
     
    @AuraEnabled
    public final String PFR_IPA_LOV_Fields = 'Core_MDF_Focus_Area_nm__c,Core_MDF_TargetAudience_nm__c,Core_MDF_ProductType__c,Core_MDF_Brand_nm__c,Core_MDF_Initiative_nm__c,Core_MDF_Industry_Multi_nm__c,Core_MDF_EcosystemPartner_nm__c,Core_MDF_Priority_nm__c,Core_MDF_ActivityCategory__c,Core_MDF_Activity_Types__c,Core_MDF_Activity_SubType_nm__c,Core_MDF_Event_Name_nm__c,Core_MDF_Country_nm__c';//Core_MDF_Focus_Area_nm__c

    @AuraEnabled
    public final String PFR_IPA_ACT_CAT_TYPE_FIELDS = 'Core_MDF_Activity_Types__c,Core_MDF_Activity_SubType_nm__c,Core_MDF_Event_Name_nm__c'; 
    
    //User Type
     public static final String Ext_UserType = 'PowerPartner';
     public static final String Std_UserType = 'Standard';
    public Object getValue(String variableName) {
        String jsonString = toJSON();
        Map<String, Object> untyped_instance;
        untyped_instance = 
            (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        return untyped_instance.get(variableName);
    }
    
    public string toJSON() {
        return JSON.serialize(this);
    }

    @AuraEnabled
    public final String SPENDING_TARGETS_LINE_ITEMS_HEADER = 'Spending Targets Line Items';

    @AuraEnabled
    public final String PRIORITY_WEIGHTAGE_RANGE_ERROR = 'Priority Weightage should be within 0% - 100%';

    @AuraEnabled
    public final String PRIORITY_WEIGHTAGE_BLANK_ERROR = 'Priority Weightage field cannot be blank';

    @AuraEnabled
    public final String AMOUNT_NEGATIVE_ERROR = 'Amount should be greater or equal to 0';

    @AuraEnabled
    public final String REGION_VALIDATION_ERROR = 'Access Denied: You must have an Account Manager role for the selected country to proceed.';

    @AuraEnabled
    public final String MULTI_COUNTRY_VALIDATION_ERROR = 'Invalid Country Selection. The combination of the selected countries is not permitted.';

    @AuraEnabled
    public final String COUNTRY_NAME_BLANK_ERROR = 'Country field cannot be blank';

    @AuraEnabled
    public final String CAMPAIGN_NAME_BLANK_ERROR = 'Campaign Name field cannot be blank';



    @AuraEnabled
    public final String campaignIPAMultiSelectFieldsOnUI = 'Core_MDF_Audience__c,Core_MDF_Technology__c,Core_MDF_Brand__c,Core_MDF_Product_Type__c,Core_MDF_IPA_Priority_nm__c,Core_MDF_Industry_Nm__c,Core_MDF_Ecosystem_Partner_Nm__c,Core_MDF_Initiative_nm__c,Core_MDF_Use_Case_Nm__c,Core_MDF_Focus_Area_nm__c';

    @AuraEnabled
    public final String campaignRMFMultiSelectFieldsOnUI = 'Core_MDF_Audience__c,Core_MDF_Brand__c,Core_MDF_Technology__c,Core_MDF_Product_Type__c,Core_MDF_Initiative_nm__c';

    @AuraEnabled
    public final String campaignCCFAndDCFMultiSelectFieldsOnUI = 'Core_MDF_Audience__c,Core_MDF_Brand__c,Core_MDF_Technology__c,Core_MDF_Industry_Nm__c,Core_MDF_Product_Type__c,Core_MDF_Activity_Category_Type__c,Core_MDF_Opal_Budget_Type_Txt__c';

    @AuraEnabled
    public final String campaignEEFMultiSelectFieldsOnUI = 'Core_MDF_Audience__c,Core_MDF_Brand__c,Core_MDF_Industry_Nm__c,Core_MDF_Product_Type__c,Core_MDF_Activity_Category_Type__c,Core_MDF_Opal_Budget_Type_Txt__c';
    
    @AuraEnabled
    public final String campaignGTMMultiSelectFieldsOnUI = 'Core_MDF_Audience__c,Core_MDF_Brand__c,Core_MDF_Industry_Nm__c,Core_MDF_Product_Type__c,Core_MDF_Activity_Category_Type__c,Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Market_Segment_nm__c,Core_MDF_Design_Features_nm__c';

    @AuraEnabled(cacheable=true)
    public static Core_MDF_CCP_ConstantClass getAllConstants() {
        return new Core_MDF_CCP_ConstantClass();
    }
    //IUPGM Configuration
    Public Static string CORE_MDF_USER_ROLE_WITH_READ_WRITE_ACCESS = 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr;Core_MDF_CCP_Internal_DCF_Field_Acct_Mgr;Core_MDF_CCP_Internal_CCF_Acct_Mgr;Core_MDF_CCP_Internal_SPCF_Acct_Mgr;Core_MDF_CCP_Internal_CCFB_Account_Manager;Core_MDF_CCP_Internal_IPA_Budget_Loader;' +
                                                                     'Core_MDF_CCP_Internal_Retail_Account_Manager;Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver;Core_MDF_CCP_Internal_RMF_Activity_Reviewer;Core_MDF_CCP_Internal_RMF_Activity_Approver;Core_MDF_CCP_Internal_IPA_Acct_Mgr;Core_MDF_CCP_Internal_DCF_Acct_Mgr;'+
                                                                     'Core_MDF_CCP_Internal_IPA_Program_Adm;Core_MDF_CCP_Internal_Regional_Admin;Core_MDF_CCP_Int_IPA_ProposalL1_Approver_Manager;Core_MDF_CCP_Int_IPA_ProposalL1_Approver;Core_MDF_CCP_Internal_IPA_Budget_Approver;Core_MDF_CCP_Internal_IPA_Budget_Manager;' +
                                                                     'Core_MDF_CCP_Internal_DCF_MDF_Payment_Admin;Core_MDF_CCP_Internal_Price_Reviewer;Core_MDF_Internal_Escalation_Reviewer_L1;Core_MDF_Internal_Escalation_Reviewer_L2;Core_MDF_Internal_EEF_Escalation_Reviewer;Core_MDF_Internal_EEF_Exception_Reviewer;' +
                                                                     'Core_MDF_CCP_Internal_CCF_MDF_Payment_Admin;Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver;Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver;Core_MDF_CCP_Internal_IPA_Finance_Usr;Core_MDF_Internal_IPA_Exception_Reviewer;Core_MDF_Internal_EEF_Program_Adm;' + 
                                                                     'Core_MDF_Internal_EEF_Budget_Approver;Core_MDF_Internal_EEF_Budget_Loader;Core_MDF_Internal_EEF_Budget_Manager;Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr;Core_MDF_Internal_EEF_Activating_Partner_Acct_Mgr;Core_MDF_Internal_EEF_Activity_L2_Approver;Core_MDF_Internal_EEF_Activity_POR_Approver;' +
                                                                     'Core_MDF_CCP_CSP_MDM;Core_MDF_CCP_ISV_MDM;Core_MDF_CCP_Internal_Activity_L2_Approver;Core_MDF_CCP_Internal_Activity_POR_Approver;Core_MDF_CCP_Internal_Co_GTM_Budget_Loader;Core_MDF_CCP_Internal_Co_GTM_Budget_Approver;Core_MDF_CCP_Internal_Co_GTM_Budget_Manager;' +
                           'Core_MDF_CCP_Internal_Co_GTM_Program_Adm;Core_MDF_CCP_Internal_Co_GTM_Account_Manager;Core_MDF_CCP_Internal_Co_GTM_POR_Approver;Core_MDF_CCP_Internal_Co_GTM_L2_Approver;Core_MDF_Internal_Co_GTM_Exception_Reviewer;Core_MDF_CCP_Internal_Co_GTM_Legal_Reviewer;Core_MDF_Internal_Co_GTM_Escalation_Reviewer;Core_MDF_CCP_Internal_Co_GTM_Business_Approver;Core_MDF_CCP_Internal_Report_Viewer';
    
    Public Static string CORE_MDF_SINGLEACC_SPECIFICBT_ROLES = 'Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver;Core_MDF_CCP_Internal_DCF_Field_Acct_Mgr;Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver;Core_MDF_Internal_Escalation_Reviewer_L1;Core_MDF_Internal_Escalation_Reviewer_L2;' +
                                    'Core_MDF_CCP_Internal_DCF_Acct_Mgr;Core_MDF_CCP_Internal_MDF_Budget_Manager;Core_MDF_CCP_Internal_Retail_Account_Manager;Core_MDF_CCP_Internal_SPCF_Acct_Mgr;Core_MDF_CCP_Int_IPA_ProposalL1_Approver;Core_MDF_Internal_EEF_Program_Adm;'+
                                                                'Core_MDF_CCP_RMF_PRC_Claim_Operations;Core_MDF_CCP_Internal_Level_1_Manager;Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader;Core_MDF_CCP_Int_Read_Only;Core_MDF_CCP_Internal_IPA_Budget_Manager;Core_MDF_CCP_Internal_IPA_Acct_Mgr;' +
                                                                'Core_MDF_CCP_Internal_CCF_MDF_Budget_Approver;Core_MDF_CCP_Internal_DCF_MDF_Budget_Approver;Core_MDF_CCP_Internal_DCF_MDF_Budget_Loader;Core_MDF_CCP_Internal_CCF_MDF_Payment_Admin;Core_MDF_Internal_EEF_Activity_POR_Approver;' +
                                    'Core_MDF_CCP_Internal_CCFB_Account_Manager;Core_MDF_CCP_Internal_IPA_Budget_Loader;Core_MDF_CCP_Internal_IPA_Budget_Approver;Core_MDF_CCP_Internal_IPA_Program_Adm;Core_MDF_Internal_IPA_Exception_Reviewer;Core_MDF_Internal_EEF_Exception_Reviewer;' +
                                                                'Core_MDF_Internal_EEF_Budget_Loader;Core_MDF_Internal_EEF_Budget_Approver;Core_MDF_Internal_EEF_Budget_Manager;Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr;Core_MDF_Internal_EEF_Activating_Partner_Acct_Mgr;Core_MDF_Internal_EEF_Activity_L2_Approver;'+
                                    'Core_MDF_CCP_Internal_Co_GTM_Budget_Loader;Core_MDF_CCP_Internal_Co_GTM_Budget_Approver;Core_MDF_CCP_Internal_Co_GTM_Budget_Manager;Core_MDF_CCP_Internal_Co_GTM_Account_Manager;Core_MDF_CCP_Internal_Co_GTM_L2_Approver;Core_MDF_Internal_Co_GTM_Exception_Reviewer;Core_MDF_CCP_Internal_Co_GTM_Legal_Reviewer;Core_MDF_CCP_Internal_Report_Viewer';
   
   Public Static string Core_MDF_AllAcc_WithoutBTAccess_Roles = 'Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver;Core_MDF_CCP_Internal_RMF_Activity_Approver;Core_MDF_CCP_Internal_RMF_Activity_Reviewer;Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver;Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver;'+
                                     'Core_MDF_CCP_Internal_CCF_MDF_Payment_Admin;Core_MDF_CCP_Internal_DCF_MDF_Payment_Admin;Core_MDF_CCP_Internal_Price_Reviewer;Core_MDF_CCP_Int_Read_Only;Core_MDF_CCP_Internal_IPA_Finance_Usr;Core_MDF_CCP_Internal_IPA_Budget_Loader;'+
                                     'Core_MDF_CCP_Int_IPA_ProposalL1_Approver;Core_MDF_CCP_Internal_IPA_Program_Adm;Core_MDF_CCP_Internal_Regional_Admin;Core_MDF_CCP_Internal_IPA_Budget_Approver;Core_MDF_CCP_Internal_IPA_Budget_Manager;Core_MDF_CCP_Internal_IPA_Acct_Mgr;Core_MDF_Internal_IPA_Exception_Reviewer;'+
                                     'Core_MDF_Internal_Escalation_Reviewer_L1;Core_MDF_Internal_Escalation_Reviewer_L2;Core_MDF_Internal_EEF_Budget_Loader;Core_MDF_Internal_EEF_Budget_Approver;Core_MDF_Internal_EEF_Activity_L2_Approver;'+
                                     'Core_MDF_Internal_EEF_Activity_POR_Approver;Core_MDF_Internal_EEF_Program_Adm;Core_MDF_Internal_EEF_Escalation_Reviewer;Core_MDF_Internal_EEF_Exception_Reviewer;Core_MDF_CCP_Internal_Co_GTM_Budget_Loader;Core_MDF_CCP_Internal_Co_GTM_Budget_Approver;'+
                                     'Core_MDF_CCP_Internal_Co_GTM_L2_Approver;Core_MDF_CCP_Internal_Co_GTM_POR_Approver;Core_MDF_CCP_Internal_Co_GTM_Program_Adm;Core_MDF_Internal_Co_GTM_Escalation_Reviewer;Core_MDF_Internal_Co_GTM_Exception_Reviewer;Core_MDF_CCP_Internal_Co_GTM_Legal_Reviewer;Core_MDF_CCP_Internal_Co_GTM_Business_Approver;Core_MDF_CCP_Internal_Co_GTM_Technical_Approver;Core_MDF_CCP_Internal_Report_Viewer';
    
   Public Static string Core_MDF_AllAcc_SpecificBT_Roles = 'Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver;Core_MDF_CCP_Internal_IPA_Program_Adm;Core_MDF_CCP_Int_IPA_ProposalL1_Approver;Core_MDF_CCP_Int_IPA_ProposalL1_Approver_Manager;Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver;'+
                                    'Core_MDF_CCP_Internal_CCF_MDF_Payment_Admin;Core_MDF_CCP_Internal_DCF_MDF_Payment_Admin;Core_MDF_CCP_Internal_Price_Reviewer;Core_MDF_CCP_Internal_IPA_Budget_Loader;'+
                                    'Core_MDF_CCP_Internal_IPA_Budget_Approver;Core_MDF_CCP_Int_Read_Only;Core_MDF_CCP_Internal_IPA_Budget_Manager;Core_MDF_CCP_Internal_IPA_Acct_Mgr;Core_MDF_Internal_Escalation_Reviewer_L1;Core_MDF_Internal_Escalation_Reviewer_L2;'+
                                    'Core_MDF_Internal_EEF_Budget_Loader;Core_MDF_Internal_EEF_Budget_Approver;Core_MDF_Internal_EEF_Activity_L2_Approver;Core_MDF_Internal_EEF_Activity_POR_Approver;Core_MDF_Internal_EEF_Program_Adm;'+
                                    'Core_MDF_Internal_EEF_Escalation_Reviewer;Core_MDF_Internal_EEF_Exception_Reviewer;Core_MDF_CCP_Internal_Co_GTM_Budget_Loader;Core_MDF_CCP_Internal_Co_GTM_Budget_Approver;Core_MDF_CCP_Internal_Co_GTM_L2_Approver;Core_MDF_CCP_Internal_Co_GTM_POR_Approver;'+
                                    'Core_MDF_CCP_Internal_Co_GTM_Program_Adm;Core_MDF_Internal_Co_GTM_Escalation_Reviewer;Core_MDF_Internal_Co_GTM_Exception_Reviewer;Core_MDF_CCP_Internal_Co_GTM_Legal_Reviewer;Core_MDF_CCP_Internal_Co_GTM_Budget_Manager;Core_MDF_CCP_Internal_Co_GTM_Business_Approver;Core_MDF_CCP_Internal_Co_GTM_Technical_Approver;Core_MDF_CCP_Internal_Report_Viewer';
   
    Public Static string EGF_BUDGETTYPE_ROLES = 'Core_MDF_Internal_EEF_Budget_Loader;Core_MDF_Internal_EEF_Budget_Approver;Core_MDF_Internal_EEF_Budget_Manager;Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr;' +
                                                'Core_MDF_Internal_EEF_Activating_Partner_Acct_Mgr;Core_MDF_CCP_Int_Read_Only;Core_MDF_Internal_EEF_Activity_L2_Approver;' +
                                                'Core_MDF_Internal_EEF_Activity_POR_Approver;Core_MDF_Internal_EEF_Program_Adm;Core_MDF_Internal_EEF_Exception_Reviewer;Core_MDF_CCP_Internal_Report_Viewer';

   public static string Co_GTM_BUDGETTYPE_ROLES = 'Core_MDF_CCP_Internal_Co_GTM_Budget_Loader;Core_MDF_CCP_Internal_Co_GTM_Budget_Approver;Core_MDF_CCP_Internal_Co_GTM_Budget_Manager;Core_MDF_CCP_Internal_Co_GTM_Account_Manager;Core_MDF_CCP_Int_Read_Only;'+
                               'Core_MDF_CCP_Internal_Co_GTM_L2_Approver;Core_MDF_CCP_Internal_Co_GTM_POR_Approver;Core_MDF_CCP_Internal_Co_GTM_Program_Adm;Core_MDF_Internal_Co_GTM_Exception_Reviewer;Core_MDF_CCP_Internal_Co_GTM_Legal_Reviewer;Core_MDF_CCP_Internal_Report_Viewer';

   Public Static string EEF_ACTIVATING_PRIMARY_PARTNER_ROLES = 'Core_MDF_Internal_EEF_Activating_Partner_Acct_Mgr;Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr;Core_MDF_Internal_EEF_Budget_Manager;Core_MDF_Internal_EEF_Budget_Loader;Core_MDF_Internal_EEF_Budget_Approver';
   
   Public static Map<String, string> IUPGM_EGF_ROLE_PARTNER_TYPE_MAP = new Map<String, string>{'Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr' => 'Primary Partner',
                                                                                           'Core_MDF_Internal_EEF_Activating_Partner_Acct_Mgr' => 'Activating Partner',
                                                                                           'Core_MDF_Internal_EEF_Budget_Manager' => 'Activating Partner',
                                                                                           'Core_MDF_Internal_EEF_Budget_Loader' => 'Primary Partner',
                                                                                           'Core_MDF_Internal_EEF_Budget_Approver' => 'Primary Partner'};    
    
    Public static string NO_ACCESS_ERROR_MSG = 'You are not authorized to create the record for the selected Account';

    //Escalation
    Public static string ESC_AMT_INCREASE_CLAIM = 'Escalation Amount cannot exceed the Claimed Amount';
    Public static string ESC_AMT_DECREASE_CLAIM = 'Escalation Amount cannot be less than the claim amount';

    Public static string EEF_ACCOUNT_VALIDATION_ELIGIBLE_BUDGETTYPE = 'Cloud';

    Public static string INTEL_ACCOUNT = 'Intel Account';
    Public static string CO_MARKETING_ACCOUNT = 'CoMarketing';
    
    //Claim notification templates
    public static final String ClaimScore_Notification = 'Core_MDF_ClaimScore_Notification';
    public static final String PIC_Completed_Notification = 'Core_MDF_PIC_Completed_Notification';
    public static final String Paid_Claims_Notification = 'Core_MDF_Paid_Claims_Notification';
    
    //Campaign purpose notification templates
    
    public static final String Campaign_Purpose_Notification = 'Core_MDF_Reminder_Result_Quantity'; // Added by RS
    public static final String Outcome_Claim_Rejection_Notification = 'Core_MDF_Outcome_Claim_Rejection'; // Akash
    //PGM Access Type
    public static final String INTERNAL = 'INTERNAL';
    public static final String EXTERNAL = 'EXTERNAL';
    public static final String INTERNAL_EXTERNAL = 'INTERNAL;EXTERNAL';
    //Max email chunck size
    public static Integer maxEmailChunckLimit = 150;
    //Recovery Admin Permission Sets
    Public static List<String> recoveryAdmPSList =  new List<string>{'Core_MDF_CCP_CCF_External_Recovery_Administrator','Core_MDF_CCP_DCF_External_Recovery_Administrator','Core_MDF_CCP_IPA_External_Recovery_Administrator','Core_MDF_CCP_RMF_External_Recovery_Administrator'};

    //IUPGM - Validation Message 
    public static final string ALL_ACCOUNT_VALIDATION_ERROR_MESSAGE = 'This role is already configured. Please inactivate or update the existing role to continue.';
    
    //validateUserRegion - TrgtSettingLineItemIUPGMValidation Message
    public static final string TRGT_SETTNG_LINE_ITEM_REGION_VALIDATION_ERROR_MESSAGE = 'Access Denied: You must have an Account Manager role for the selected country to proceed.';

    //validateCountrySelection - TrgtSettingLineItemMultiCountryValidation Message
    public static final string TRGT_SETTNG_LINE_ITEM_MULTI_COUNTRY_VALIDATION_ERROR_MESSAGE = 'Invalid Country Selection. The combination of the selected countries is not permitted.';
    
    //validateUserRegion - Target Setting Line Item REGION
    public static final String Trgt_Setting_Line_Item_All_Other_EMEA = 'All Other EMEA';
    public static final String Trgt_Setting_Line_Item_All_Other_ASMO = 'All Other ASMO';
    public static final String Trgt_Setting_Line_Item_All_Other_APJ = 'All Other APJ';
    public static final String EMEA_Region = 'EMEA';
    public static final String ASMO_Region = 'ASMO';
    public static final String APJ_Region = 'APJ';

    public static final String SA_SUBREGION = 'SA';
    
    //Country :INDIA 
    public static final String INDIA_Country = 'INDIA';

    //Map to hold exclude account metadata and program
    public static Map<String,String> Program_ExcludeAccountMdtMap = new Map<String,String>{
        'Client CoMarketing Fund' => 'Core_MDF_CCF_Exclude_Accounts',
        'Data Center CoMarketing Fund' => 'Core_MDF_DCF_Exclude_Accounts',
        'Intel Partner Alliance' => 'Core_MDF_IPA_Exclude_Accounts',
        'Retail Marketing Funds' => 'Core_MDF_RMF_Exclude_Accounts',
        'Client CoMarketing Fund Boost' => 'Core_MDF_CCFB_Exclude_Accounts',
        'Service Provider CoMarketing Fund' => 'Core_MDF_SPCF_Exclude_Accounts'
    };
    //Target Setting Line Item Validation Message for Duplicate records.
    public static final string TRGT_SETTNG_LINE_ITEM_DUPLICATE_RECORD_ERROR_MESSAGE = 'This is a Duplicate Record';
    
    //Core_MDF_Approval_Object_List__mdt converted to list of api names of the object.
    public static final List<String> OBJECT_API_NAME_LIST = new List<String>{'Campaign','Contact','PartnerMarketingBudget','Account','PartnerFundAllocation','PartnerFundClaim','PartnerFundRequest'};

    //Salesforce Standard error Formats
    public static final String FIELD_CUSTOM_VALIDATION_EXCEPTION = 'FIELD_CUSTOM_VALIDATION_EXCEPTION,';
    public static final String STRING_LENGTH_EXCEEDS_MAXIMUM = 'String length exceeds maximum:';

    //Account Based and Proposal based ind
    public static final String Account_based_Indicator = 'Account Based';
    public static final String Proposal_based_Indicator = 'Proposal Based';

    //Custom Permission For EEF Primary Account Manager
    public static final String PRIMARY_PARTNER_CUSTOM_PERMISSION = 'Core_MDF_CCP_Internal_EEF_Primary_Account_Manager';
    
    //POP Translation Category Value
    public static final String POP_TRANSLATION = 'POP Translation';
    
    //BU Split Category Value
    public static final String BU_SPLIT = 'BU Splits';
    
    //OPAL Category Value
    public static final String OPAL_CATEGORY = 'OPAL Category';

    //Attributes Map category value
    public static final String ATTRIBUTES_MAP_CATEGORY = 'Attributes Map';

    //Approval Request Metadata Category Value
    public static final String APPROVAL_REQUEST_OBJECT_CATEGORY = 'Internal Approval Request Tab';
    
    //Product Type Category Split Metadata value
    public static final String PRODUCT_CAT_TYPE_SPLIT = 'Product Category Type Split';

    public static List<String>  NRE_ALLOWED_STATUSES_TO_CREATE_ACTIVITY = new List<String>{'Draft', 'Revision Required', 'Planned', 'In Progress'};

    //Added for RMF India geo change- WW24'2025 (referred in AccountOnboardingHelper class)
    public static final String INDIA_REGION = 'INDIA';
    
    //To restrict claim creation on these activity statuses
    public static List<String> NRE_RESTRICTED_PFR_STATUSES_TO_CREATE_CLAIM = new List<String>{'In-Progress Pending Review', 'In-Progress Pending Approval', 'In-Progress Revision Required'};

    //CampaignCreatePage
    public static List<String> FIELDS_TO_PROCESS = new List<String>{ 'StartDate__c','EndDate__c','Name__c','Description__c'};
        
    // Addes by Rishabh::--
    public static final String IPA_BUDGET_TYPE = 'Account Plan';
  public static final String IPA_PROPOSAL_MDF_BUDGET_TYPE = 'Proposal II MDF'; 
    public static final String CO_GTM_BUDGET_TYPE = 'Co-Engineering'; 
    public static final String GEO_WW = 'WW';
    Public static List<String>  ALL_REGION = new List<String>{'APJ', 'ASMO', 'EMEA', 'INDIA', 'PRC'};
    Public static List<String>  ALL_REGION_FOR_RMF = new List<String>{'APJ', 'ASMO', 'EMEA', 'INDIA', 'PRC'};
    Public static List<String>  Budget_Type_For_IPA_EEF_COGTM = new List<String>{'Account Plan', 'Cloud', 'Co-Engineering'};
    Public static List<String> Prog_For_CCF_DCF_EEF_COGTM_FOR_IUPGM =  new List<string>{'Client','Datacenter','Ecosystem Extension Fund','CoGTM'};
    //Public static Map<String, string> stageToClassificationMap_PFR = new Map<String, string>{'L2 Sales' => 'Sales', 'L2 Marketing' => 'Marketing'};
    Public static List<String>  FIRST_SECOND_LEVEL_MGR = new List<String>{'First Level Manager', 'Second Level Manager'};
    Public static List<String>  APPROVAL_STAGE_FOR_EXTERNAL_USER = new List<String>{'Customer Acceptance', 'Customer Acceptance (Primary Partner)','Customer Acceptance (Activating Partner)'};
        
}