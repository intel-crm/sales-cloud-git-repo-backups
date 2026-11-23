//Class created to store constants
public class Core_MDF_CCP_ConstantClass {
    //CASE STATUS
    public static final String CASE_OPEN_STATUS = 'Under Review';
    public static final String CASE_OPEN = 'Open';
    public static final String CASE_OPEN_RECORDTYPE_NAME = 'Core_MDF_Audit';
    //PFR RECORD TYPE
    public static final String PFR_CCF_RECORDTYPE = 'Core_MDF_Client_CoMarketing_Fund';
    public static final String PFR_DCF_RECORDTYPE = 'Core_MDF_Data_Center_CoMarketing_Fund';
    public static final String PFR_CMDF_RECORDTYPE = 'Core_MDF_Channel_MDF';
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
    // PFR PROGRAM
    public static final String PFR_CHANNEL_MDF_PROGRAM = 'Channel MDF';
    public static final String PFR_IPA_PROGRAM = 'Intel Partner Alliance';
    public static final String PFR_RMF_PROGRAM = 'Retail Marketing Funds';
    public static final String PFR_EEF_PROGRAM = 'Ecosystem Extension Fund';

    //PFR ACTIVITY CATEGORY
    public static final String PFR_EVENT_CATEGORY = 'Event';
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
    public static final String PFR_MANUAL_MISSED_APPROVAL = 'Manual - Missed Approval';
    public static final String PFR_RevisionRequired = 'Revision Required';
    //ESCALATION
    public static final String ESC_APPROVED_STATUS = 'Approved';
    public static final String LATECLAIM_TYPE = 'Late Claim';
    public static final String ESC_EXPIRED_STATUS = 'Expired';
    public static final String ESC_CANCELLED_EXPIRED_STATUS = 'Cancelled;Expired';
    //CLAIM
    public static final String TYPE_CLAIM = 'Claim';
    //Activity Type Event
    public static final string EVENT_ACTIVITY_TYPE = 'Other (Event),Third Party Event';
    
     //Internal CSC user PS
    public static final string INTERNAL_CSC_PS = 'Core_MDF_Internal_CSC_User';
    
    //CAMPAIGN
    public static final String COMPLETED_APPROVAL_LEVEL = 'L1 Approval';
    public static final Integer INCREMENT_STEP_COUNTER = 0;

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

    //EXCEPTION STATUS
    public static final String EXCEPTION_PENDING_REVIEW = 'Pending Review';

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
    
    //PROGRAMS
    public static final String CCF_PROGRAM = 'Client Co-Marketing Fund';
    public static final String DCF_PROGRAM = 'Data Center Co-Marketing Fund';
    public static final String CMDF_PROGRAM = 'Channel MDF';
    public static final String IPA_PROGRAM = 'Intel Partner Alliance';
    public static final String SPCF_PROGRAM = 'Service Provider Co-Marketing Fund Boost';
    public static final String RMF_PROGRAM = 'Retail Marketing Funds';
    public static final String EEF_PROGRAM = 'Ecosystem Extension Fund';

    //Account PartnerType
    public static final String ACTIVATING_PARTNER = 'Activating Partner';
    public static final String PRIMARY_PARTNER = 'Primary Partner';
    //LOCALE
    public static final String CCP_SUPPORTED_LOCALE = 'zh_CN,zh_TW,fr,de,it,ja,ko,ru,es_MX,es,pt_BR,en_US';
	 
    public static final String IPA_PROP_EMAIL_TEMPLATE = 'Core_MDF_NotifyProposalApprovers' ;
    public string CAMPAIGN_APPROVAL_HISTORY_JSON ='[ {"record":[{"step_Name": "Price Reviewer","comments_masked": "true","comments_desc":"Please contact your Account Manager for details"}],"ps_name":"Core_MDF_CCP_External_IPA_Proposal_Manager"}]';
    public string PFR_IPA_ACCBASED_EXT_APPROVAL_HISTORY_JSON = '[{"record":[{"step_Name": "Price Reviewer","comments_masked": "true","comments_desc":"Please contact your Account Manager for details"}],"ps_name":"Core_MDF_CCP_External_IPA_Activity_Manager"}]';
    
    //IPA Multiselect Picklists - CampFieldAPIName vs ActivityFieldAPIName
    public static final string  CAMPAIGN_FIELD_AND_ACTIVITY_FIELD_APINAMES = '{"Core_MDF_Audience__c": "Core_MDF_TargetAudience_nm__c","Core_MDF_Market__c": "Core_MDF_Country_nm__c","Core_MDF_IPA_Priority_nm__c": "Core_MDF_Priority_nm__c","Core_MDF_Industry_Nm__c": "Core_MDF_Industry_Multi_nm__c","Core_MDF_Initiative_nm__c": "Core_MDF_Initiative_nm__c","Core_MDF_Focus_Area_nm__c": "Core_MDF_Focus_Area_nm__c","Core_MDF_Brand__c": "Core_MDF_Brand_nm__c","Core_MDF_Product_Type__c": "Core_MDF_ProductType__c","Core_MDF_Ecosystem_Partner_Nm__c": "Core_MDF_EcosystemPartner_nm__c","Core_MDF_Opal_Budget_Type_Txt__c":"Core_MDF_Budget_Type_nm__c"}';
    
  //  public static final string EXCEPTION_REVIEWER_PROGRAM_MAPPING = '{"Core_MDF_Intel_Partner_Alliance": "Core_MDF_Internal_IPA_Exception_Reviewer","Core_MDF_Client_CoMarketing_Fund": "Core_MDF_CCP_Internal_CCF_Exception_Reviewer","Core_MDF_Data_Center_CoMarketing_Fund": "Core_MDF_CCP_Internal_DCF_Exception_Reviewer","Core_MDF_Service_Provider_CoMarketing_Fund": "Core_MDF_CCP_Internal_SPCF_Exception_Reviewer","Core_MDF_Client_CoMarketing_Fund_Boost": "Core_MDF_CCP_Internal_CCF_Boost_Exception_Reviewer","Core_MDF_Retail_Marketing_Funds": "Core_MDF_CCP_Internal_RMF_Exception_Reviewer"}';
    public static final string CCP_CAMPAIGN_FIELD_AND_ACTIVITY_FIELD_APINAMES = '{"Core_MDF_Audience__c": "Core_MDF_TargetAudience__c","Core_MDF_Market__c": "Core_MDF_Country_nm__c", "Core_MDF_Product_Type__c": "Core_MDF_ProductType__c", "Core_MDF_Brand__c": "Core_MDF_Brand_nm__c","Core_MDF_Activity_Category_Type__c": "Core_MDF_Activity_Types__c", "Core_MDF_Priority__c": "Core_MDF_Priorities__c", "Core_MDF_Priority_2_nm__c": "Core_MDF_Priorities__c", "Core_MDF_Priority_3_nm__c": "Core_MDF_Priorities__c","Core_MDF_Opal_Budget_Type_Txt__c":"Core_MDF_Budget_Type_nm__c","Core_MDF_Industry_Nm__c": "Core_MDF_Industry_Multi_nm__c"}';
    
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
    public static final List<String> CAMPAIGN_STATUSES_TO_QUERY_CLAIMS = new List<String>{'In Progress','Cancelled'};

    //PFR valid active statuses
    public static final List<String> VALID_PFR_STATUSES = new List<String>{'Draft', 'Revision Required', 'Pending Review', 'Pending Approval', 'Planned', 'In-Progress', 'Proposal Accepted'};

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
      Public static List<String> Intel_Owner_Based_Notification_Prog =  new List<string>{'Client Co-Marketing Fund','Data Center Co-Marketing Fund'};
       Public static List<string> IUPGM_Based_Notification_Prog = new List<string>{'Retail Marketing Funds','Intel Partner Alliance'};
       Public static final String AUDIT_CLOSED = 'Audit Closed';
        Public static final String REVIEW_COMPLETED = 'Review Completed';
        Public static final String PAID_CLAIMS = 'Paid';
        
    public static final String httpAuthorization = 'Authorization';
    //CCF/DCF External Recovery Admin Permission Sets
    public static final String ccfRecoveryAdmEntitlement = 'CCF RECOVERY ADMINISTRATOR';
    public static final String dcfRecoveryAdmEntitlement = 'DCF RECOVERY ADMINISTRATOR';
    public static final List<String> ccf_dcf_ProgramName = new List<String>{'Client CoMarketing Fund','Data Center CoMarketing Fund'};

    //EFT Character Limit
    public static final Integer EFT_Char_Limit = 1001;
     
    //Feedback LoginHistory Status
    public static final String FEEDBACK_SUCCESS_STATUS = 'Success';
     
    @AuraEnabled
    public final String PFR_IPA_LOV_Fields = 'Core_MDF_TargetAudience_nm__c,Core_MDF_ProductType__c,Core_MDF_Brand_nm__c,Core_MDF_Initiative_nm__c,Core_MDF_Industry_Multi_nm__c,Core_MDF_EcosystemPartner_nm__c,Core_MDF_Priority_nm__c,Core_MDF_Activity_Types__c,Core_MDF_Activity_SubType_nm__c,Core_MDF_Event_Name_nm__c';

    @AuraEnabled
    public final String PFR_IPA_ACT_CAT_TYPE_FIELDS = 'Core_MDF_Activity_Types__c,Core_MDF_Activity_SubType_nm__c,Core_MDF_Event_Name_nm__c'; 
    
    //User Type
     public static final String Ext_UserType = 'PowerPartner';
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
    public final String campaignIPAMultiSelectFieldsOnUI = 'Core_MDF_Audience__c,Core_MDF_Technology__c,Core_MDF_Brand__c,Core_MDF_Product_Type__c,Core_MDF_IPA_Priority_nm__c,Core_MDF_Industry_Nm__c,Core_MDF_Ecosystem_Partner_Nm__c,Core_MDF_Initiative_nm__c,Core_MDF_Use_Case_Nm__c,Core_MDF_Focus_Area_nm__c';

    @AuraEnabled
    public final String campaignRMFMultiSelectFieldsOnUI = 'Core_MDF_Audience__c,Core_MDF_Brand__c,Core_MDF_Technology__c,Core_MDF_Product_Type__c,Core_MDF_Initiative_nm__c';

    @AuraEnabled
    public final String campaignCCFAndDCFMultiSelectFieldsOnUI = 'Core_MDF_Audience__c,Core_MDF_Brand__c,Core_MDF_Technology__c,Core_MDF_Industry_Nm__c,Core_MDF_Product_Type__c,Core_MDF_Activity_Category_Type__c,Core_MDF_Opal_Budget_Type_Txt__c';

    @AuraEnabled
    public final String campaignEEFMultiSelectFieldsOnUI = 'Core_MDF_Audience__c,Core_MDF_Brand__c,Core_MDF_Industry_Nm__c,Core_MDF_Product_Type__c,Core_MDF_Activity_Category_Type__c,Core_MDF_Opal_Budget_Type_Txt__c';
    
    @AuraEnabled(cacheable=true)
    public static Core_MDF_CCP_ConstantClass getAllConstants() {
        return new Core_MDF_CCP_ConstantClass();
    }
    //IUPGM Configuration
    Public Static string CORE_MDF_USER_ROLE_WITH_READ_WRITE_ACCESS = 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr;Core_MDF_CCP_Internal_DCF_Field_Acct_Mgr;Core_MDF_CCP_Internal_CCF_Acct_Mgr;Core_MDF_CCP_Internal_SPCF_Acct_Mgr;Core_MDF_CCP_Internal_CCFB_Account_Manager;Core_MDF_CCP_Internal_IPA_Budget_Loader;' +
                                                                     'Core_MDF_CCP_Internal_Retail_Account_Manager;Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver;Core_MDF_CCP_Internal_RMF_Activity_Reviewer;Core_MDF_CCP_Internal_RMF_Activity_Approver;Core_MDF_CCP_Internal_IPA_Acct_Mgr;Core_MDF_CCP_Internal_DCF_Acct_Mgr;'+
                                                                     'Core_MDF_CCP_Internal_IPA_Program_Adm;Core_MDF_CCP_Int_IPA_ProposalL1_Approver_Manager;Core_MDF_CCP_Int_IPA_ProposalL1_Approver;Core_MDF_CCP_Internal_IPA_Budget_Approver;Core_MDF_CCP_Internal_IPA_Budget_Manager;' +
                                                                     'Core_MDF_CCP_Internal_DCF_MDF_Payment_Admin;Core_MDF_CCP_Internal_Price_Reviewer;Core_MDF_Internal_Escalation_Reviewer_L1;Core_MDF_Internal_Escalation_Reviewer_L2;Core_MDF_Internal_EEF_Escalation_Reviewer;Core_MDF_Internal_EEF_Exception_Reviewer;' +
                                                                     'Core_MDF_CCP_Internal_CCF_MDF_Payment_Admin;Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver;Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver;Core_MDF_CCP_Internal_IPA_Finance_Usr;Core_MDF_Internal_IPA_Exception_Reviewer;Core_MDF_Internal_EEF_Program_Adm;' + 
                                                                     'Core_MDF_Internal_EEF_Budget_Approver;Core_MDF_Internal_EEF_Budget_Loader;Core_MDF_Internal_EEF_Budget_Manager;Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr;Core_MDF_Internal_EEF_Activating_Partner_Acct_Mgr;Core_MDF_Internal_EEF_Activity_L2_Approver;Core_MDF_Internal_EEF_Activity_POR_Approver;' +
                                                                     'Core_MDF_CCP_CSP_MDM;Core_MDF_CCP_ISV_MDM;Core_MDF_CCP_Internal_Activity_L2_Approver;Core_MDF_CCP_Internal_Activity_POR_Approver';
    Public Static string CORE_MDF_SINGLEACC_SPECIFICBT_ROLES = 'Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver;Core_MDF_CCP_Internal_DCF_Field_Acct_Mgr;Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver;Core_MDF_Internal_Escalation_Reviewer_L1;Core_MDF_Internal_Escalation_Reviewer_L2;' +
        														'Core_MDF_CCP_Internal_DCF_Acct_Mgr;Core_MDF_CCP_Internal_MDF_Budget_Manager;Core_MDF_CCP_Internal_Retail_Account_Manager;Core_MDF_CCP_Internal_SPCF_Acct_Mgr;Core_MDF_CCP_Int_IPA_ProposalL1_Approver;Core_MDF_Internal_EEF_Program_Adm;'+
                                                                'Core_MDF_CCP_RMF_PRC_Claim_Operations;Core_MDF_CCP_Internal_Level_1_Manager;Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader;Core_MDF_CCP_Int_Read_Only;Core_MDF_CCP_Internal_IPA_Budget_Manager;Core_MDF_CCP_Internal_IPA_Acct_Mgr;' +
                                                                'Core_MDF_CCP_Internal_CCF_MDF_Budget_Approver;Core_MDF_CCP_Internal_DCF_MDF_Budget_Approver;Core_MDF_CCP_Internal_DCF_MDF_Budget_Loader;Core_MDF_CCP_Internal_CCF_MDF_Payment_Admin;Core_MDF_Internal_EEF_Activity_POR_Approver;' +
        														'Core_MDF_CCP_Internal_CCFB_Account_Manager;Core_MDF_CCP_Internal_IPA_Budget_Loader;Core_MDF_CCP_Internal_IPA_Budget_Approver;Core_MDF_CCP_Internal_IPA_Program_Adm;Core_MDF_Internal_IPA_Exception_Reviewer;Core_MDF_Internal_EEF_Exception_Reviewer;' +
                                                                'Core_MDF_Internal_EEF_Budget_Loader;Core_MDF_Internal_EEF_Budget_Approver;Core_MDF_Internal_EEF_Budget_Manager;Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr;Core_MDF_Internal_EEF_Activating_Partner_Acct_Mgr;Core_MDF_Internal_EEF_Activity_L2_Approver';
   
   
    Public Static string EGF_BUDGETTYPE_ROLES = 'Core_MDF_Internal_EEF_Budget_Loader;Core_MDF_Internal_EEF_Budget_Approver;Core_MDF_Internal_EEF_Budget_Manager;Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr;' +
                                                'Core_MDF_Internal_EEF_Activating_Partner_Acct_Mgr;Core_MDF_CCP_Int_Read_Only;Core_MDF_Internal_EEF_Activity_L2_Approver;' +
                                                'Core_MDF_Internal_EEF_Activity_POR_Approver;Core_MDF_Internal_EEF_Program_Adm;Core_MDF_Internal_EEF_Exception_Reviewer';

   Public Static string EEF_ACTIVATING_PRIMARY_PARTNER_ROLES = 'Core_MDF_Internal_EEF_Activating_Partner_Acct_Mgr;Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr;Core_MDF_Internal_EEF_Budget_Manager;Core_MDF_Internal_EEF_Budget_Loader;Core_MDF_Internal_EEF_Budget_Approver';
   
   Public static Map<String, string> IUPGM_EGF_ROLE_PARTNER_TYPE_MAP = new Map<String, string>{'Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr' => 'Primary Partner',
                                                                                           'Core_MDF_Internal_EEF_Activating_Partner_Acct_Mgr' => 'Activating Partner',
                                                                                           'Core_MDF_Internal_EEF_Budget_Manager' => 'Activating Partner',
                                                                                           'Core_MDF_Internal_EEF_Budget_Loader' => 'Primary Partner',
                                                                                           'Core_MDF_Internal_EEF_Budget_Approver' => 'Primary Partner'};    
    
    Public static string NO_ACCESS_ERROR_MSG = 'You are not authorized to create the record for the selected Account';

    Public static string EEF_ACCOUNT_VALIDATION_ELIGIBLE_BUDGETTYPE = 'Cloud';

    Public static string INTEL_ACCOUNT = 'Intel Account';
    Public static string CO_MARKETING_ACCOUNT = 'CoMarketing';
    
    //Claim notification templates
    public static final String ClaimScore_Notification = 'Core_MDF_ClaimScore_Notification';
    public static final String PIC_Completed_Notification = 'Core_MDF_PIC_Completed_Notification';
    public static final String Paid_Claims_Notification = 'Core_MDF_Paid_Claims_Notification';
}