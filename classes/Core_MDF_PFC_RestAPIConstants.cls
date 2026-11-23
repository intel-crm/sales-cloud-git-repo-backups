/**
 * Central constants for Partner Fund Claims REST API.
 */
public with sharing class Core_MDF_PFC_RestAPIConstants {
    public static final String RESPONSE_CODE_CATEGORY_CLAIM = 'Claim';

    // HTTP-style response status codes used in API payload
    public static final String STATUS_200_SUCCESS = '200';
    public static final String STATUS_207_PARTIAL_SUCCESS = '207';

    // Request-processing limits
    public static final Integer MAX_CLAIMS_PER_REQUEST = 50;

    // Supported claim type values
    public static final String CLAIM_TYPE_PARAM = 'claimType';
    public static final String CLAIM_TYPE_NORMAL = 'normal';
    public static final String CLAIM_TYPE_LATE = 'lateclaim';

    // Error code catalog (8000 series): request and payload validation
    public static final String CODE_8001_REQUEST_BODY_REQUIRED = '8001';
    public static final String CODE_8002_INVALID_PAYLOAD_STRUCTURE = '8002';
    public static final String CODE_8003_CLAIM_TITLE_REQUIRED = '8003';
    public static final String CODE_8004_ACTIVITY_NUMBER_REQUIRED = '8004';
    public static final String CODE_8005_CLAIM_SUBMITTER_REQUIRED = '8005';
    public static final String CODE_8006_INVALID_CLAIM_DATES = '8006';

    // Error code catalog (8000 series): field value and business validation
    public static final String CODE_8009_CLAIM_CURRENCY_REQUIRED = '8009';
    public static final String CODE_8012_INVALID_TOTAL_AMOUNT_LOCAL = '8012';
    public static final String CODE_8013_INVALID_COSTS_NOT_REIMBURSABLE = '8013';
    public static final String CODE_8015_CLAIM_COUNTRY_REQUIRED = '8015';
    public static final String CODE_8017_BUSINESS_VALIDATION_FAILED = '8017';
    public static final String CODE_8026_LATECLAIM_ESCALATION_REQUIRED = '8026';
    public static final String CODE_8019_COUNTRY_NOT_IN_ACTIVITY = '8019';
    public static final String CODE_8022_PROOF_OF_COST_NUMBER_REQUIRED = '8022';
    public static final String CODE_8023_INVALID_PROOF_OF_COST_DATE = '8023';
    public static final String CODE_8024_INVALID_ESCALATION_ID = '8024';
    public static final String CODE_8027_PROCESSING_PREFERENCE_REQUIRED = '8027';
    public static final String CODE_8040_ESCALATION_ID_REQUIRED = '8040';
    public static final String CODE_8029_TAXES_LOCAL_REQUIRED = '8029';
    public static final String CODE_8030_INVALID_CLAIM_SUBMITTER_ID = '8030';
    public static final String CODE_8031_MAX_CLAIMS_EXCEEDED = '8031';
    public static final String CODE_8032_NO_ACTIVITY_FOUND = '8032';
    public static final String CODE_8034_INVALID_FILE_NAME = '8034';
    public static final String CODE_8035_INVALID_BASE64_FILE_CONTENT = '8035';
    public static final String CODE_8036_DOCUMENT_TYPE_REQUIRED = '8036';
    public static final String CODE_8038_INVALID_BANK_SUPPLIER_NUMBER = '8038';
    public static final String CODE_8039_INVALID_CLAIM_TYPE = '8039';
    public static final String CODE_8043_DOCUMENTS_REQUIRED = '8043';

    // Error code catalog (8000 series): runtime failures
    public static final String CODE_8018_INTERNAL_SERVER_ERROR = '8018';
    public static final String CODE_8021_APPLICATION_ERROR = '8021';

    // Request/response envelope keys
    public static final String KEY_MESSAGE = 'message';
    public static final String KEY_RESULTS = 'results';

    // Common literals
    public static final String EMPTY_STRING = '';
    public static final String CONTENT_TYPE_HEADER = 'Content-Type';
    public static final String CONTENT_TYPE_JSON = 'application/json';
    public static final String DELIMITER_PIPE = ' | ';
    public static final String DELIMITER_SEMICOLON = ';';
    public static final String DELIMITER_SEMICOLON_SPACE = '; ';

    // Validation and processing messages
    public static final String MSG_INVALID_PICKLIST_VALUE_PREFIX = 'Invalid value \'';
    public static final String MSG_INVALID_PICKLIST_VALUE_MIDDLE = '\' for ';
    public static final String MSG_VALIDATED = 'Validated';
    public static final String MSG_VALIDATION_FAILED_PREFIX = 'Validation failed for ';
    public static final String MSG_VALIDATION_FAILED_SUFFIX = ' row(s).';
    public static final String MSG_ROW_PREFIX = 'Row ';
    public static final String MSG_ROW_SEPARATOR = ': ';
    public static final String MSG_CREATED = 'Created';
    public static final String MSG_ALL_CLAIMS_PROCESSED_SUCCESS = 'All claims processed successfully';

    // Audit document defaults — mirrors Core_MDF_PFC_Create Aura component auditDocumentFieldPopulation
    public static final String DEFAULT_DOCUMENT_TYPE = 'Proof of Cost;Proof of Execution;Proof of Attribution';
    public static final String DEFAULT_APP_DOCUMENT_TYPES = 'Proof of Cost;Proof of Execution;Proof of Attribution';

    // UI-aligned server/date validation messages
    public static final String MSG_APPLICATION_ERROR = Label.Core_MDF_ApplicationErrorMessage;
    public static final String MSG_START_DATE_FUTURE_VALIDATION = Label.Core_MDF_StartDateFutureValidation;
    public static final String MSG_END_DATE_FUTURE_VALIDATION = Label.Core_MDF_EndDateFutureValidation;
    public static final String MSG_START_DATE_VALIDATION = Label.Core_MDF_StartDateValidation;
    public static final String MSG_END_DATE_VALIDATION = Label.Core_MDF_EndDateValidation;
    public static final String MSG_START_DATE_END_DATE_VALIDATION = Label.Core_MDF_StartDate_EndDate_Validation;
    public static final String MSG_END_DATE_START_DATE_VALIDATION = Label.Core_MDF_EndDate_StartDate_Validation;
    public static final String FIELD_CUSTOM_VALIDATION_EXCEPTION = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';

    // Claim payload field names that carry logic beyond the configured required/format rules.
    // Every other field is driven entirely by Core_MDF_Custom_Layout_Configurations__c.
    public static final String FIELD_ACTIVITY_NUMBER = 'activityNumber';
    public static final String FIELD_CLAIM_TYPE = 'claimType';
    public static final String FIELD_CLAIM_SUBMITTER = 'claimSubmitter';
    public static final String FIELD_CLAIM_START_DATE = 'claimStartDate';
    public static final String FIELD_CLAIM_END_DATE = 'claimEndDate';
    public static final String FIELD_BANK_SUPPLIER_NUMBER = 'bankSupplierNumber';
    public static final String FIELD_ESCALATION_ID = 'escalationId';
    public static final String FIELD_CLAIM_COUNTRY = 'claimCountry';
    public static final String FIELD_DOCUMENTS = 'documents';

}