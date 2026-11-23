/**
 * ----------------------------------------------------------------------------------
 * Class Name      : Core_MDF_ListView_RestAPIConstants
 * Description     : Centralized constants for the generic List View (report-style)
 *                   REST API.
 * ----------------------------------------------------------------------------------
 */
public class Core_MDF_ListView_RestAPIConstants {
    // --------------------------------------------------
    // API Route Constants
    // --------------------------------------------------
    public static final String LIST_VIEW_URL_SEGMENT = '/v1.0/partnercenter/listview/';
    public static final String RESPONSE_CODE_CATEGORY = 'ListView';
    public static final String CONFIG_USER_TYPE = 'External User';
    // --------------------------------------------------
    // Request Defaults / Limits
    // --------------------------------------------------
    public static final Integer MAX_FILTERS = 10;
    public static final String DEFAULT_LOGIC = 'AND';
    public static final String DEFAULT_SORT_FIELD = 'CreatedDate';
    public static final String DEFAULT_SORT_ORDER = 'DESC';

    public static final Set<String> ALLOWED_OPERATORS = new Set<String>{
        '=', '!=', '>', '<', '>=', '<=', 'LIKE', 'IN', 'NOT IN'
    };

    // --------------------------------------------------
    // Success Messages
    // --------------------------------------------------
    public static final String MSG_LIST_RETRIEVED = 'List retrieved successfully';
    public static final String ERROR_MESSAGE_CONFIG_MISSING = 'An error occurred processing your request. Please contact support.';

    // --------------------------------------------------
    // 7010 Series API Error Codes
    // Why needed: Distinct 7010-series code range dedicated to this API.
    // --------------------------------------------------
    public static final String CODE_7010_INVALID_PAYLOAD = '7010';
    public static final String CODE_7011_INVALID_FILTER_FIELD = '7011';
    public static final String CODE_7012_INVALID_OPERATOR = '7012';
    public static final String CODE_7013_INVALID_OBJECT = '7013';
    public static final String CODE_7014_TOO_MANY_FILTERS = '7014';
    public static final String CODE_7015_INTERNAL_SERVER_ERROR = '7015';
    public static final String CODE_7016_NO_RECORDS_FOUND = '7016';
    public static final Integer HTTP_STATUS_400 = 400;
    public static final Integer HTTP_STATUS_500 = 500;
}