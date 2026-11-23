/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : Core_MDF_PFC_APIResponse
 * Author          : <YourName>
 * Created Date    : May 21, 2026
 * Last Modified By: <YourName>
 * Last Modified On: May 21, 2026
 * Description     : This class implements for the response parameters
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  May 21, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

global virtual class Core_MDF_PFC_APIResponse {
    public Boolean isSuccess;
    public ResponseStatus success;
    public ResponseStatus error;
    public Object details;
    public Integer httpStatusCode;

    global class ResponseStatus {
        public String message;
        public String code;

        public ResponseStatus(String message, String code) {
            this.message = message;
            this.code = code;
        }
    }

    public Core_MDF_PFC_APIResponse() {
    }

    public void setSuccessInfo(String message, String code) {
        this.isSuccess = true;
        this.success = new ResponseStatus(message, code);
        this.error = null;
    }

    public void setErrorInfo(String message, String code) {
        this.isSuccess = false;
        this.error = new ResponseStatus(message, code);
        this.success = null;
    }

    public String getCode() {
        if (this.isSuccess && this.success != null) {
            return this.success.code;
        }
        if (!this.isSuccess && this.error != null) {
            return this.error.code;
        }
        return null;
    }

    public String getMessage() {
        if (this.isSuccess && this.success != null) {
            return this.success.message;
        }
        if (!this.isSuccess && this.error != null) {
            return this.error.message;
        }
        return null;
    }

    public Map<String, Object> getSerializedResponse() {
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('isSuccess', this.isSuccess);

        if (this.isSuccess && this.success != null) {
            responseMap.put('success', new Map<String, Object>{
                'message' => this.success.message,
                'code' => this.success.code
            });
        } else if (!this.isSuccess && this.error != null) {
            responseMap.put('error', new Map<String, Object>{
                'message' => this.error.message,
                'code' => this.error.code
            });
        }

        responseMap.put('details', this.details);
        return responseMap;
    }
}