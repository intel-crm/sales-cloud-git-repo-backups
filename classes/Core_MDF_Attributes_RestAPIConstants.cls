public class Core_MDF_Attributes_RestAPIConstants {
    // --------------------------------------------------
    // HTTP Status Codes
    // --------------------------------------------------
    public static final Integer HTTP_200 = 200;
    public static final Integer HTTP_400 = 400;
    public static final Integer HTTP_404 = 404;
    public static final Integer HTTP_500 = 500;
    // --------------------------------------------------
    // API Response Codes
    // --------------------------------------------------
    public static final String CODE_200 = '200';
    public static final String CODE_1000_PROGRAM_NAME_REQUIRED = '1000';
    public static final String CODE_1001_INVALID_PROGRAM_NAME = '1001';
    public static final String CODE_1002_NO_PICKLIST_VALUES_FOUND = '1002';
    public static final String CODE_1003_INVALID_PARAMETER_KEY = '1003';
    public static final String CODE_1004_APPLICATION_ERROR = '1004';
    public static final String CODE_1005_INVALID_FIELDDISPLAY_VALUE = '1005';
    public static final String CODE_1006_INVALID_CONTROLLING_VALUE = '1006';
    public static final String CODE_1007_INVALID_FIELD = '1007';
   
    private static final Map<String, Integer> HTTP_STATUS_BY_API_CODE = new Map<String, Integer>{
        CODE_200 => HTTP_200,
        CODE_1000_PROGRAM_NAME_REQUIRED => HTTP_400,
        CODE_1001_INVALID_PROGRAM_NAME => HTTP_400,
        CODE_1002_NO_PICKLIST_VALUES_FOUND => HTTP_404,
        CODE_1003_INVALID_PARAMETER_KEY => HTTP_400,
        CODE_1004_APPLICATION_ERROR => HTTP_500,
        CODE_1005_INVALID_FIELDDISPLAY_VALUE => HTTP_400,
        CODE_1006_INVALID_CONTROLLING_VALUE => HTTP_400,
        CODE_1007_INVALID_FIELD => HTTP_400
    };

    public static Integer getHttpStatusByApiCode(String apiCode) {
        return HTTP_STATUS_BY_API_CODE.containsKey(apiCode) ? HTTP_STATUS_BY_API_CODE.get(apiCode) : HTTP_500;
    }	
}