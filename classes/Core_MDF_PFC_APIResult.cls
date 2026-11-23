/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : Core_MDF_PFC_APIResult
 * Author          : <YourName>
 * Created Date    : May 21, 2026
 * Last Modified By: <YourName>
 * Last Modified On: May 21, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  May 21, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

global virtual class Core_MDF_PFC_APIResult {
    public Integer rowNumber { get; set; }
    public Boolean success { get; set; }
    public String code { get; set; }
    public String message { get; set; }
    public String recordId { get; set; }
     /**
     * Populated only when one or more fields contain invalid picklist values.
     * Key   = ClaimWrapper field name (e.g. 'claimCurrency')
     * Value = ordered list of active allowed values for that field
     */
    //public Map<String, List<String>> allowedPicklistValues { get; set; }
    
    public Core_MDF_PFC_APIResult() {
        this.success = false;
    }
}