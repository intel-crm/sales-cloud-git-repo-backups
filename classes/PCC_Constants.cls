/*********************************************************************************************************************
Apex Class Name  : PCC_Constants
Version       : 1.0
Created Date  : May 2023
Function      : Utility class to store common keywords related to PCC

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Sushmita                  22/05/2023               Utility class to store common keywords related to PCC

*********************************************************************************************************************/
public class PCC_Constants {
   // public enum allowedFieldsPostDRP {quantity,targetResalePrice,comments,partnerTrackingNumber,mmId,recordId,oldMMId,orderingCd,externalId,designRegId }
    //public enum allowedFieldsPutDRP {quantity, targetResalePrice, comments, partnerTrackingNumber, mmId, recordId, oldMMId, orderingCd, designRegId}
    public static final String CALLOUT_TYPE_OUTBOUND = 'Outbound';
    public static final String CALLOUT_TYPE_INBOUND = 'Inbound';
    public static final String MODULE_DDR_REGISTRATION = 'DDR Registration';
    public static final String SYSTEM_NAME_AGS = 'AGS';
    public static final String SYSTEM_NAME_M2M = 'M2M';
    public static final String SYSTEM_NAME_Collinsion = 'Collinsion';
    public static Map<String, String> drProductApiToLabelMap = new Map<String, String>{'Core_Design_Registration_Id__c'=> 'designRegistration',
        'Core_Product_Id__c' => 'productId',
        'Core_Full_Year_Qty__c' => 'quantity',
        'Core_External_Id__c' => 'externalId',
        'Core_Design_Product_Status_Nm__c'=> 'status',
        'Core_Retired_As_Of_Dt__c'=>'retiredAsOf',
        'Core_Design_Registration_Id__c'=> 'designRegistration',
        'Core_Product_Group_Nm__c' => 'productGroup',
        'Core_Military_Aerospace_Gvrnmt_Use_Ind__c' => 'militaryAerospaceGvrnmtUseInd',
        'Core_Vertical_Market_Nm__c' => 'verticalMarket',
        'Core_Product_Segment_Nm__c'=> 'productSegment',
        'Core_Product_Application_Nm__c'=>'productApplication',
        'PCC_Design_Type__c' => 'designType',
        'PCC_ODM_Board_partner__c' => 'odmBoardPartner',
        'Core_Partner_FAE_Nm__c' => 'partnerFAE',
        'Core_End_Customer_Nm__c' => 'endCustomerName',
        'Core_End_Customer_Street_Addr_Line1_Txt__c' => 'endCustomerAddress1',
        'Core_End_Customer_Postal_Cd__c' => 'endCustomerPostalCode',
        'Core_End_Customer_Country_Nm__c' => 'endCustomerCountry',
        'Core_Intel_Platform_Nm__c' => 'intelPlatform',
        'Core_Opportunity_Volume_Cnt__c' => 'opportunityVolume',
        'Core_Opportunity_Decision_Dt__c' => 'designDecisionDate',
        'Core_First_Customer_Ship_Dt__c' => 'firstCustomerShipDate',
        'Core_Production_End_Dt__c' => 'productionEndDate',
        'Core_Design_Registration_Dsc__c' => 'description',
        'Core_End_Customer_Street_Addr_Line2_Txt__c' => 'endCustomerAddress2',
        'Core_End_Customer_City_Nm__c' => 'endCustomerCity',
        'Core_End_Customer_Country_Subdivision_Nm__c' => 'endCustomerState',
        'Core_End_Customer_Postal_Cd__c' => 'endCustomerZipCode',
        'Core_End_Customer_Contact_Title_Txt__c' => 'endCustomerContactTitle',
        'Core_End_Customer_Contact_Nm__c' => 'endCustomerContactName',
        'Core_End_Customer_Contact_Email_Txt__c' => 'endCustomerContactEmail',
        'Core_End_Customer_Contact_Phone_Txt__c' => 'endCustomerContactPhone',
        'Core_Manufacturing_Region_Cd__c' => 'manufacturingRegion',
        'Core_Design_Registration_Nm__c' => 'designRegistrationName',
        'DDR_Partner_FAE_Email__c' => 'partnerFAEEmail',
        'MMID_or_Ordering_code__c' => 'mmId/oldMMId/orderingCd'
        }; 
            public static Map<String, String> drProductApiToLabelMapV2 = new Map<String, String>{'Core_Design_Registration_Id__c'=> 'designRegistration',
        'Core_Product_Id__c' => 'productId',
        'Core_Full_Year_Qty__c' => 'quantity',
        'Core_External_Id__c' => 'externalId',
        'Core_Design_Product_Status_Nm__c'=> 'status',
        'Core_Retired_As_Of_Dt__c'=>'retiredAsOf',
        'Core_Design_Registration_Id__c'=> 'designRegistration',
        'Core_Product_Group_Nm__c' => 'productGroup',
        'Core_Military_Aerospace_Gvrnmt_Use_Ind__c' => 'militaryAerospaceGvrnmtUseInd',
        'Core_Vertical_Market_Nm__c' => 'verticalMarket',
        'Core_Product_Segment_Nm__c'=> 'productSegment',
        'Core_Product_Application_Nm__c'=>'productApplication',
        'PCC_Design_Type__c' => 'designType',
        'PCC_ODM_Board_partner__c' => 'odmBoardPartner',
        'Core_Partner_FAE_Nm__c' => 'partnerFAE',
        'Core_End_Customer_Nm__c' => 'endCustomerName',
        'Core_End_Customer_Street_Addr_Line1_Txt__c' => 'endCustomerAddress1',
        'Core_End_Customer_Postal_Cd__c' => 'endCustomerPostalCode',
        'PCC_End_Customer_Country__c' => 'endCustomerCountry',
        'Core_Intel_Platform_Nm__c' => 'intelPlatform',
        'Core_Opportunity_Volume_Cnt__c' => 'opportunityVolume',
        'Core_Opportunity_Decision_Dt__c' => 'designDecisionDate',
        'Core_First_Customer_Ship_Dt__c' => 'firstCustomerShipDate',
        'Core_Production_End_Dt__c' => 'productionEndDate',
        'Core_Design_Registration_Dsc__c' => 'description',
        'Core_End_Customer_Street_Addr_Line2_Txt__c' => 'endCustomerAddress2',
        'Core_End_Customer_City_Nm__c' => 'endCustomerCity',
        'Core_End_Customer_Country_Subdivision_Nm__c' => 'endCustomerState',
        'Core_End_Customer_Postal_Cd__c' => 'endCustomerZipCode',
        'Core_End_Customer_Contact_Title_Txt__c' => 'endCustomerContactTitle',
        'Core_End_Customer_Contact_Nm__c' => 'endCustomerContactName',
        'Core_End_Customer_Contact_Email_Txt__c' => 'endCustomerContactEmail',
        'Core_End_Customer_Contact_Phone_Txt__c' => 'endCustomerContactPhone',
        'Core_Manufacturing_Region_Cd__c' => 'manufacturingRegion',
        'Core_Design_Registration_Nm__c' => 'designRegistrationName',
        'DDR_Partner_FAE_Email__c' => 'partnerFAEEmail',
        'MMID_or_Ordering_code__c' => 'mmId/oldMMId/orderingCd'
        }; 
          public static Set<String> allowedFieldsPostDR = new Set<String>{
        'productGroup',
        'militaryAerospaceGvrnmtUseInd',
        'verticalMarket',
        'productSegment',
        'designType',
        'odmBoardPartner',
        'productApplication',
        'partnerFAE',
        'endCustomerName',
        'endCustomerAddress1',
        'endCustomerPostalCode',
        'endCustomerCountry',
        'intelPlatform',
        'opportunityVolume',
        'designDecisionDate',
        'firstCustomerShipDate',
        'productionEndDate',
        'description',
        'endCustomerAddress2',
        'endCustomerCity',
        'endCustomerState',
        'endCustomerZipCode',
        'endCustomerContactTitle',
        'endCustomerContactName',
        'endCustomerContactEmail',
        'endCustomerContactPhone',
        'manufacturingRegion',
        'designRegistrationName',
        'partnerFAEEmail',
            'externalId',
            'partnerFSR','endCustomerUrl'
    };
        public static Set<String> allowedFieldsPutDR = new Set<String>{
        'productGroup',
        'militaryAerospaceGvrnmtUseInd',
        'verticalMarket',
        'productSegment',
        'productApplication',
        'designType',
        'odmBoardPartner',
        'partnerFAE',
        'endCustomerName',
        'endCustomerAddress1',
        'endCustomerPostalCode',
        'endCustomerCountry',
        'intelPlatform',
        'opportunityVolume',
        'designDecisionDate',
        'firstCustomerShipDate',
        'productionEndDate',
        'description',
        'endCustomerAddress2',
        'endCustomerCity',
        'endCustomerState',
        'endCustomerZipCode',
        'endCustomerContactTitle',
        'endCustomerContactName',
        'endCustomerContactEmail',
        'endCustomerContactPhone',
        'manufacturingRegion',
        'designRegistrationName',
        'partnerFAEEmail',
            'partnerFSR','recordId','endCustomerUrl','status'
    };
        public static Set<String> allowedFieldsPutDRP = new Set<String>{
            'quantity',
    'targetResalePrice',
    'comments',
    'partnerTrackingNumber',
    'mmId',
    'recordId','oldMMId','orderingCd','designRegId'
        };
           
    public static Set<String> allowedFieldsPostDRP = new Set<String>{'quantity',
    'targetResalePrice',
    'comments',
    'partnerTrackingNumber',
    'mmId','oldMMId','orderingCd','externalId','designRegId'};
            public static Set<String> allowedFieldsDeleteAPI = new Set<String>{'recordId'};

     public static final String INSERT_DDR = 'Insert Design Registration';
     public static final String UPDATE_DDR = 'Update Design Registration';
     public static final String INSERT_DRP = 'Insert Design Registration Product';
     public static final String UPDATE_DRP = 'Update Design Registration Product';
     public static final String DELETE_DDR = 'Delete Design Registration';
     public static final String DELETE_DRP = 'Delete Design Registration Product';
     public static final String DESIGN_REG = 'Design Registration';
     public static final String DESIGN_REG_PROD = 'Design Registration Product';
    public static final String INSERT_ACTION = 'Insert';
    public static final String UPDATE_ACTION = 'Update';
     public static final String RESTRICTED_PICKLIST = 'INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST';
    public static final String FIELD_FILTER_VALIDATION = 'FIELD_FILTER_VALIDATION_EXCEPTION';
    public static final String REQUIRED_FIELD_MISSING = 'REQUIRED_FIELD_MISSING';
    public static final String FIELD_INTEGRITY_EXCEPTION = 'FIELD_INTEGRITY_EXCEPTION';
    public static final String MALFORMED_ID = 'MALFORMED_ID';
    public static final String INVALID_ID_FIELD = 'INVALID_ID_FIELD';
    public static final String STRING_TOO_LONG = 'STRING_TOO_LONG';
    public static final String INVALID_CROSS_REFERENCE_KEY = 'INVALID_CROSS_REFERENCE_KEY';
    public static final String DUPLICATE_VALUE = 'DUPLICATE_VALUE';

	 public static final String static_DDR_MD_Label = 'PicklistValues';
     public static final Integer MAX_CHARACTER_TO_STORE = 131070;
     public static final String NO_FILE_UPLOADED ='No file(s) has been uploaded. Please upload the required supported documents';
     public static final String INVALID_TYPE = 'Invalid File Type';
     public static final String SIZE_EXCEEDS = 'File Size exceeds permissible limit';
     public static final String FILE_ERRORS= 'File Errors';
     public static final String FILE_ERROR= 'File Error';
     public static final String DEALPROD_RECORD_ERRORS= 'Please add at least one Intel Product as part of this Deal Registration';
     public static final String DEAL_MAX_LENGTH='Max Length character limit exceeded for';
     public static final String DEAL_PRICING_START_DATE_VALIDATION='Please provide a date greater than current Date.';
     public static final String DEAL_PRICING_END_DATE_VALIDATION='Pricing Start Date shouldn’t be greater than Pricing End Date.';
     public static final String DEAL_PRICING_END_DATE_FUTURE_VALIDATION='Please provide a date greater than current Date.';
     public static final String DEAL_DESCRIPTION_VALIDATION='Your entry is too short! Minimum 10 characters required.';
     public static final String DEAL_END_CUST_USE_VALIDATION='Your entry is too short! Minimum 10 characters required.';
     public static final String DEAL_COMPETITION_ASSUMPTIONS_VALIDATION='Your entry is too short! Minimum 10 characters required.';
     public static final String DEAL_INTEL_RESPONSE_VALIDATION='Intel Response Requested By Date cannot be later than Proposal Due Date.';
     public static final String DEAL_INTEL_RESPONSE_SLA_VALIDATION='The Intel Response Requested By Date has already passed. Please enter a Intel Response Requested By Date more than one day in the future.';
     public static final String DEAL_PROPOSAL_DUE_DATE_VALIDATION='Please provide a date greater than current Date.';
     public static final String DEAL_SUBMITTED_STATUS='Submitted';
     public static final String DEAL_REG_PRODUCT='Deal Registration Product';
     public static final String DEAL_PROPOSAL_DATE='Proposal Due Date';
     public static final String DEAL_PRICING_START_DATE='Pricing Start Date';
     public static final String DEAL_PRICING_END_DATE='Pricing End Date';
     public static final String DEAL_DESCRIPTION='Deal Description';
     public static final String DEAL_END_CUST_USE='End Customer Use';
     public static final String DEAL_DECISIONDATE='Decision Date';
     public static final String DEAL_COMPETITION_ASSUMPTIONS='Competition Assumptions';
     public static final String DEAL_PRICINGSD_OPPTYDECISIONDATE='Pricing start date should be after opportunity decision Date.';
     public static final String DEAL_OPPTYDECISIONDATE_PASTDATE='Decision Date should not be less than 7 days from the Deal Reg submission Date.';
     public static final String DEAL_PROPOSALDUEDATE_OPPTYDD='Proposal due date should be before Opportunity Decision Date.';
     public static final String LOG_ENTRY_MSG     = 'Deal Registration submission has encountered an error. Please contact Support.';
     public static final String DEAL_CUSTERR= 'Deal Reg Owner alone can submit this Deal Registration';
     public static final String DRP_ADDITION_ERROR_MSG = 'Deal Reg Products cannot be added/modified at this stage';
     public static final String DRP_NON_FIN_ERROR_MSG ='Deal Registration has products that are not eligible for Financial Incentives (FI).Kindly review the product(s) in ';
     public static final String SUCCESS_STATUS = 'Success';
     public static final String FAILED_STATUS = 'Failed';
     public static final String RC_INVDATE_BLANK = 'Blank Invoice Date ';
     public static final String RC_INVDATE_INVALID ='Invalid Invoice Date ';
     public static final String RC_Qty_BLANK = 'Blank Claim Quantity ';
     public static final String RC_Qty_INVALID ='Invalid Claim Quantity ';
     public static final String RC_LINE_SEPERATOR ='\n';
     public static final String RC_Quote_BLANK = 'Quote cannot be blank ';
     public static final String RC_QLN_BLANK = 'Blank Quote Line # ';
     public static final String RC_QIN_BLANK = 'Blank Invoice # ';
     public static final String RC_OEM_BLANK = 'Blank OEM Name ';
     public static final String RC_OEM_INVALID = 'Invalid OEM Name ';
     public static final String RC_COUNTRY_BLANK = 'Blank Consumption Countries ';
     public static final String RC_QLN_INVALID = 'Invalid Quote Line ';
     public static final String RC_Prod_BLANK = 'Blank Product Name ';
     public static final String RC_Prod_INVALID = 'Invalid Product Name ';
     public static final String RC_SUBMITTED = 'Submitted';
     public static final String RC_CLAIM_SUBMITTED = 'Claim Submitted';
     public static final String RC_RECTYPE = 'PCC_Rebate_Claim';
     public static final String RC_LIRECTYPE = 'Rebate_Claim_Line_Item';
     public static final String RC_FieldSetName='PCC_RebateClaimFields';
     public static final String RC_ObjectName='PCC_Rebate_Claim_Stage__c';
     public static final String RC_OPPTY_INVALID = 'Invalid QL/Opportunity Status ';
     public static final String RC_CLAIMQTY_INVALID = 'Claim Quantity exceeds Claimable Quantity ';
     public static final String RC_TECHERROR = 'Technical Error - Please contact Support ';
     public static final String RC_OPPTYCOVERAGE = 'Partner-Led Opportunity';
     public static final String RC_COVERAGETYPE = 'Deal Registration';
     public static final String RC_QLSTATUS = 'Won';
     public static final String RC_OPPTYSTAGE = 'Design Win';
     public static final String RC_OPPTYSTATUS = 'Approved';
     public static final String RC_CLAIMDATE_INVALID = 'Claim Submission Timeline lapsed';
     public static final String DEAL_REGISTRATIONTYPE = 'Design Registration';

    }