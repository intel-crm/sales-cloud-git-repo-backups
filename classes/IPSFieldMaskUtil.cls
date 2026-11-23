/**
 * IPSFieldMaskUtil
 * Server-side masking utility for PII and audit fields returned to external portal users.
 * Pattern: j***@intel.com  (same approach as Core_IPS_CaseCreateLWCController.getContactRecords)
 *
 * Usage:
 *   String masked = IPSFieldMaskUtil.maskEmail(rawEmail);     // j***@intel.com
 *   String masked = IPSFieldMaskUtil.maskSfId(profileId);    // 'MASKED'
 *   Boolean ext   = IPSFieldMaskUtil.isExternalUser();
 */
public with sharing class IPSFieldMaskUtil {

    /**
     * Mask an email address: keep first char + '***' + full domain.
     * e.g. john.doe@intel.com  →  j***@intel.com
     * Returns blank as-is; null as-is.
     */
    public static String maskEmail(String email) {
        if (String.isBlank(email)) return email;
        Integer atIdx = email.indexOf('@');
        if (atIdx <= 0) return '***';
        return email.substring(0, 1) + '***' + email.substring(atIdx);
    }

    /**
     * Mask a Salesforce ID or any internal identifier.
     * Returns 'MASKED' for non-blank values; null for blank.
     */
    public static String maskSfId(String sfId) {
        System.debug('sfId ------'+sfId);
        return String.isBlank(sfId) ? sfId : 'MASKED';
    }

    /**
     * True when the running user is in an Experience Cloud network
     * (Customer Community, Community Plus, or Partner portal).
     */
    public static Boolean isExternalUser() {
        return Network.getNetworkId() != null;
    }
}