/**
 * @description Canonical API response model for activity create/update and validation responses.
 * Handles standard PFR response fields and structured error detail parsing.
 */
global inherited sharing class Core_MDF_PFR_RestAPI_Response {
    public boolean isSuccess { get; set; }
    public String code { get; set; }
    public String message { get; set; }
    public string errorcode { get; set; }
    public long totalRecords { get; set; }
    public List<Object> successContent { get; set; }
    public List<Core_MDF_PFR_RestAPI_Response.ErrorContent> failureContent { get; set; }
    public List<Core_MDF_PFR_RestAPI_Response.FileUploadResult> fileUploadContent { get; set; }

    // Maps an error code to the friendly field name it relates to (used for structured error output).
    private static final Map<String, String> FIELD_BY_CODE = new Map<String, String>{
        '9030' => 'Activity Category',
        '9031' => 'Activity Type',
        '9032' => 'Activity Type',
        '9033' => 'Activity Category',
        '9034' => 'Activity Type',
        '9035' => 'Event Name',
        '9036' => 'Domain Type',
        '9038' => 'Event Name',
        '9039' => 'Reimbursement Rate',
        '9040' => 'Priority',
        '9041' => 'Target Audience',
        '9042' => 'Country',
        '9043' => 'Brand',
        '9044' => 'Product Type',
        '9045' => 'Industry',
        '9046' => 'Ecosystem Partner',
        '9050' => 'Member Acceptor',
        '9051' => 'Member Acceptor',
        '9052' => 'Member Acceptor',
        '9061' => 'Currency',
        '9092' => 'Event Name',
        '9093' => 'Other Event Name',
        '9094' => 'Domain Type',
        '9095' => 'Activity Sub Type',
        '9096' => 'Activity Sub Type',
        '9199' => 'StartDate'
    };

    private static final String ALLOWED_VALUES_MARKER = 'Allowed values:';
    private static final String EXPECTED_VALUE_MARKER = 'Expected value:';

    // Default constructor initializes response values
    public Core_MDF_PFR_RestAPI_Response() {
        this.isSuccess = true;
        this.successContent = new List<Object>();
        this.failureContent = new List<Core_MDF_PFR_RestAPI_Response.ErrorContent>();
    }

    /**
     * Error content wrapper for validation failures
     */
    public class ErrorContent {
        public String pfrId { get; set; }
        public String pfrName { get; set; }

        // Raw formatted error messages produced by the validation/DML pipeline.
        // Kept as List<String> for backward compatibility so every dependent class compiles
        // independently (no coordinated deployment required). Marked transient so the raw
        // "Allowed values" newline strings are not serialized; callers read "errorDetails" instead.
        public transient List<String> errors { get; set; }

        public ErrorContent() {
            this.errors = new List<String>();
        }

        // Structured representation returned to the caller: each entry exposes the error code,
        // related field and the allowed values as a real array (derived from the raw messages).
        public List<ErrorDetail> errorDetails {
            get {
                List<ErrorDetail> details = new List<ErrorDetail>();
                if (this.errors != null) {
                    for (String rawError : this.errors) {
                        if (String.isNotBlank(rawError)) {
                            details.add(Core_MDF_PFR_RestAPI_Response.toErrorDetail(rawError));
                        }
                    }
                }
                return details;
            }
            private set;
        }
    }

    /**
     * Structured representation of a single error message: the error code, the related field
     * (when known), the human-readable message, and the allowed values as a real array.
     */
    public class ErrorDetail {
        public String message { get; set; }
        public Integer httpStatusCode { get; set; }
        public String code { get; set; }
        public String field { get; set; }
        public String allowedValuesFieldName { get; set; }
        public List<Object> allowedValues { get; set; }
    }

    /**
     * Parses a formatted error string into a structured ErrorDetail. Splits off any "Allowed values"
     * numbered list into the allowedValues array and derives the field name from the error code.
     * Handles formats: "ERR-9040: message", "9040: message", "9040" (numeric code only)
     * Also handles field name marker: "###FieldName:FieldValue###ERR-9040: message"
     */
    public static ErrorDetail toErrorDetail(String rawError) {
        ErrorDetail detail = new ErrorDetail();
        if (String.isBlank(rawError)) {
            return detail;
        }
        String text = rawError.trim();
        
        // Extract allowedValuesFieldName first if embedded in message (format: "###FieldName:FieldValue###...")
        String fieldNameMarker = '###FieldName:';
        if (text.startsWith(fieldNameMarker)) {
            Integer endMarker = text.indexOf('###', fieldNameMarker.length());
            if (endMarker > 0) {
                detail.allowedValuesFieldName = text.substring(fieldNameMarker.length(), endMarker);
                text = text.substring(endMarker + 3).trim();
            }
        }
        
        String codeValue;

        if (text.startsWith('ERR-') && text.contains(':')) {
            codeValue = text.substringBefore(':').trim();
            // Drop the code prefix from the message so the code is not duplicated.
            text = text.substringAfter(':').trim();
        } else if (text.startsWith('ERR-') && text.length() > 4 && text.substring(4).trim().isNumeric()) {
            codeValue = text.trim();
            text = '';
        } else if (text.contains(':')) {
            String prefix = text.substringBefore(':').trim();
            if (prefix.isNumeric()) {
                codeValue = prefix;
                text = text.substringAfter(':').trim();
            }
        } else if (text.isNumeric()) {
            // Handle pure numeric code without prefix or colon
            codeValue = text.trim();
            text = '';
        }
        
        codeValue = normalizeErrorCode(codeValue);
        detail.code = codeValue;
        detail.field = codeValue != null ? FIELD_BY_CODE.get(codeValue) : null;

        Integer markerIndex = text.indexOf(EXPECTED_VALUE_MARKER);
        String marker = EXPECTED_VALUE_MARKER;
        Integer allowedMarkerIndex = text.indexOf(ALLOWED_VALUES_MARKER);
        if (markerIndex < 0 || (allowedMarkerIndex >= 0 && allowedMarkerIndex < markerIndex)) {
            markerIndex = allowedMarkerIndex;
            marker = ALLOWED_VALUES_MARKER;
        }
        if (markerIndex >= 0) {
            detail.message = text.substring(0, markerIndex).trim();
            String allowedPart = text.substring(markerIndex + marker.length());
            detail.allowedValues = parseNumberedList(allowedPart);
        } else {
            detail.message = text;
        }

        applyCustomSetting(detail);

        return detail;
    }

    public Map<String, Object> toErrorResponsePayload() {
        ErrorDetail detail = getPrimaryErrorDetail();
        if (detail == null || String.isBlank(detail.code)) {
            detail = toErrorDetail(String.isNotBlank(this.errorcode) ? this.errorcode : null);
        }
        if (detail == null || String.isBlank(detail.code)) {
            detail = new ErrorDetail();
            detail.code = String.isNotBlank(this.errorcode) ? this.errorcode : this.code;
            detail.message = this.message;
            detail.httpStatusCode = parseStatusCode(this.code);
        }
        return toErrorResponsePayload(detail, this.code);
    }

    public Object toErrorResponsePayloadBody() {
        List<Map<String, Object>> payloads = toErrorResponsePayloads();
        if (payloads.size() == 1) {
            return payloads[0];
        }
        return payloads;
    }

    public List<Map<String, Object>> toErrorResponsePayloads() {
        List<Map<String, Object>> payloads = new List<Map<String, Object>>();
        if (this.failureContent != null) {
            for (Core_MDF_PFR_RestAPI_Response.ErrorContent failure : this.failureContent) {
                if (failure == null || failure.errors == null) {
                    continue;
                }
                for (String rawError : failure.errors) {
                    if (String.isNotBlank(rawError)) {
                        payloads.add(toErrorResponsePayload(toErrorDetail(rawError), this.code));
                    }
                }
            }
        }
        if (payloads.isEmpty()) {
            payloads.add(toErrorResponsePayload());
        }
        return payloads;
    }

    public static Map<String, Object> toErrorResponsePayload(String rawError, String fallbackHttpStatusCode) {
        return toErrorResponsePayload(toErrorDetail(rawError), fallbackHttpStatusCode);
    }

    private Core_MDF_PFR_RestAPI_Response.ErrorDetail getPrimaryErrorDetail() {
        if (this.failureContent == null) {
            return null;
        }
        for (Core_MDF_PFR_RestAPI_Response.ErrorContent failure : this.failureContent) {
            if (failure == null || failure.errors == null) {
                continue;
            }
            for (String rawError : failure.errors) {
                if (String.isNotBlank(rawError)) {
                    return toErrorDetail(rawError);
                }
            }
        }
        return null;
    }

    private static Map<String, Object> toErrorResponsePayload(ErrorDetail detail, String fallbackHttpStatusCode) {
        Map<String, Object> payload = new Map<String, Object>();
        Integer httpStatusCode = detail != null && detail.httpStatusCode != null
            ? detail.httpStatusCode
            : parseStatusCode(fallbackHttpStatusCode);
        payload.put('code', detail != null ? detail.code : null);
        payload.put('message', detail != null ? detail.message : null);
        payload.put('httpStatusCode', httpStatusCode);
        if (detail != null && String.isNotBlank(detail.allowedValuesFieldName)) {
            payload.put('allowedValuesFieldName', detail.allowedValuesFieldName);
        }
        if (detail != null && detail.allowedValues != null) {
            payload.put('allowedValues', detail.allowedValues);
        }
        return payload;
    }

    private static Integer parseStatusCode(String statusCode) {
        return String.isNotBlank(statusCode) && statusCode.isNumeric() ? Integer.valueOf(statusCode) : null;
    }

    private static String normalizeErrorCode(String codeValue) {
        if (String.isBlank(codeValue)) {
            return codeValue;
        }
        String normalized = codeValue.trim();
        if (normalized.toUpperCase().startsWith('ERR-') && normalized.length() > 4) {
            return normalized.substring(4).trim();
        }
        return normalized;
    }

    private static void applyCustomSetting(ErrorDetail detail) {
        if (detail == null || String.isBlank(detail.code)) {
            return;
        }
        String originalCode = detail.code;
        Core_MDF_PFR_RestAPI_Utility.ResponseCodeSetting setting =
            Core_MDF_PFR_RestAPI_Utility.getResponseCodeSetting(detail.code, null, detail.field);
        if (!isMatchingSetting(setting, originalCode)) {
            setting = Core_MDF_PFR_RestAPI_Utility.getResponseCodeSetting(detail.code, null, null);
        }
        if (!isMatchingSetting(setting, originalCode)) {
            return;
        }
        if (String.isNotBlank(setting.code)) {
            detail.code = setting.code;
        }
        if (String.isNotBlank(setting.context)) {
            detail.field = setting.context;
        }
        if (String.isNotBlank(setting.httpStatusCode) && setting.httpStatusCode.isNumeric()) {
            detail.httpStatusCode = Integer.valueOf(setting.httpStatusCode);
        }
        if (String.isBlank(detail.message) && String.isNotBlank(setting.message)) {
            detail.message = setting.message;
        }
    }

    private static Boolean isMatchingSetting(Core_MDF_PFR_RestAPI_Utility.ResponseCodeSetting setting, String expectedCode) {
        return setting != null && (String.isBlank(setting.code) || setting.code == expectedCode);
    }

    /**
     * Converts a numbered, newline-separated list ("1. A\n2. B") back into a clean list of values.
     * Returns null when there are no values so the array is omitted from the response.
     */
    private static List<Object> parseNumberedList(String numberedList) {
        List<Object> values = new List<Object>();
        if (String.isNotBlank(numberedList)) {
            for (String line : numberedList.split('\n')) {
                String value = line.replaceFirst('^\\s*[0-9]+\\.\\s*', '').trim();
                if (String.isNotBlank(value)) {
                    values.add(parseAllowedValue(value));
                }
            }
        }
        return values.isEmpty() ? null : values;
    }

    private static Object parseAllowedValue(String value) {
        if (String.isBlank(value)) {
            return value;
        }
        String trimmedValue = value.trim();
        if (trimmedValue.startsWith('{') && trimmedValue.endsWith('}')) {
            try {
                return JSON.deserializeUntyped(trimmedValue);
            } catch (Exception e) {
                return value;
            }
        }
        return value;
    }

    /**
     * Result of an inline file upload during activity creation.
     */
    public class FileUploadResult {
        public String fileName;
        public String status;

        public FileUploadResult(String fileName, String status) {
            this.fileName = fileName;
            this.status = status;
        }
    }
    
}