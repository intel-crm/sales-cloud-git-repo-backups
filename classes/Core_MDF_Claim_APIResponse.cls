/**
 * ----------------------------------------------------------------------------------
 * Class Name      : Core_MDF_Claim_APIResponse
 * Description     : Standardized claim API response wrapper. Details accepts Object
 *                   to support flexible payloads.
 * ----------------------------------------------------------------------------------
 */

global class Core_MDF_Claim_APIResponse {
    public Boolean isSuccess;
    public ResponseStatus success;
    public ResponseStatus error;
    public Object details;

    global class ResponseStatus {
        public String message;
        public String code;

        public ResponseStatus(String message, String code) {
            this.message = message;
            this.code = code;
        }
    }

    /**
     * Initialize response with default values.
     */
    public Core_MDF_Claim_APIResponse() {
    }

    /**
     * Set success status block.
     */
    public void setSuccessInfo(String message, String code) {
        this.isSuccess = true;
        this.success = new ResponseStatus(message, code);
        this.error = null;
    }

    /**
     * Set error status block.
     */
    public void setErrorInfo(String message, String code) {
        this.isSuccess = false;
        this.error = new ResponseStatus(message, code);
        this.success = null;
    }

    /**
     * Get serializable response map with only non-null status block.
     */
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