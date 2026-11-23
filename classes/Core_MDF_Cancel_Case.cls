public with sharing class Core_MDF_Cancel_Case {

    @AuraEnabled
    public static Boolean getCancelCaseAccess() {
        system.debug('access called');
        Boolean hasAccess = false;
        try {
            hasAccess = FeatureManagement.checkPermission(Core_MDF_CCP_ConstantClass.CCRM_CUSTOM_PS);
            return hasAccess;
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            return null;
        }
    }
}