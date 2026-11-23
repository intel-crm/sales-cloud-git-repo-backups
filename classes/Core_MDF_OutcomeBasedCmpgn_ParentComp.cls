/***************************************************************************************************** 
Class Name   :    Core_MDF_OutcomeBasedCmpgn_ParentComp
Description  :    Server-side controller of Core_MDF_OutcomeBasedCmpgn_ParentComp
Added By     :    Ramapriya - Weezer
Created Date :    12/12/2025
******************************************************************************************************/
public class Core_MDF_OutcomeBasedCmpgn_ParentComp {

    
    /**
     * Method to check if user has access to create new campaigns
     * Uses custom permission to determine access
     */
    @AuraEnabled(cacheable=true)
    public static Boolean hasNewCampaignAccess() {
        return FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Activity_Manager') || 
                FeatureManagement.checkPermission('Core_MDF_CCP_Internal_IPA_Acct_Mgr');
    }
    
    
    /**
     * Method to fetch IPA record type for PartnerFundRequest
     * This reuses the existing filtering logic from the original class
     */
    @AuraEnabled
    public static Map<String, Object> getIPARecordType() {
        try {
            Core_MDF_PFR_RecordTypeSelector.recordTypeWrapper wrapper = 
                Core_MDF_PFR_RecordTypeSelector.fetchRecordType('PartnerFundRequest');
            
            String ipaDevName = System.Label.Core_MDF_IPA_RecordType;
            
            if(wrapper != null &&
               wrapper.recordTypeDevNameAndLabelName != null && 
               wrapper.recordTypeDevNameAndId != null &&
               wrapper.recordTypeDevNameAndLabelName.containsKey(ipaDevName) && 
               wrapper.recordTypeDevNameAndId.containsKey(ipaDevName)) {
                
                Map<String, Object> result = new Map<String, Object>{
                    'recordTypeId' => wrapper.recordTypeDevNameAndId.get(ipaDevName),
                    'recordTypeName' => wrapper.recordTypeDevNameAndLabelName.get(ipaDevName),
                    'recordTypeDeveloperName' => ipaDevName
                };
                
                return result;
            } else {
                throw new AuraHandledException('IPA record type not found or not accessible to current user');
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Unable to fetch IPA record type: ' + e.getMessage());
        }
    }

    /**
     * Method to fetch IPA record type for PartnerFundRequest
     * This reuses the existing filtering logic from the original class
     */
    @AuraEnabled
    public static Map<String, Object> getClientRecordType() {
        try {
            Core_MDF_PFR_RecordTypeSelector.recordTypeWrapper wrapper = 
                Core_MDF_PFR_RecordTypeSelector.fetchRecordType('PartnerFundRequest');
            
            String ipaDevName = System.Label.Core_MDF_CCF_RecordTypeName;
            
            if(wrapper != null &&
               wrapper.recordTypeDevNameAndLabelName != null && 
               wrapper.recordTypeDevNameAndId != null &&
               wrapper.recordTypeDevNameAndLabelName.containsKey(ipaDevName) && 
               wrapper.recordTypeDevNameAndId.containsKey(ipaDevName)) {
                
                Map<String, Object> result = new Map<String, Object>{
                    'recordTypeId' => wrapper.recordTypeDevNameAndId.get(ipaDevName),
                    'recordTypeName' => wrapper.recordTypeDevNameAndLabelName.get(ipaDevName),
                    'recordTypeDeveloperName' => ipaDevName
                };
                
                return result;
            } else {
                throw new AuraHandledException('Client record type not found or not accessible to current user');
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Unable to fetch Client record type: ' + e.getMessage());
        }
    }
        /**
     * Method to fetch Datacenter record type for PartnerFundRequest
     * This reuses the existing filtering logic from the original class
     */
    @AuraEnabled
    public static Map<String, Object> getDatacenterRecordType() {
        try {
            Core_MDF_PFR_RecordTypeSelector.recordTypeWrapper wrapper = 
                Core_MDF_PFR_RecordTypeSelector.fetchRecordType('PartnerFundRequest');
            
            String ipaDevName = System.Label.Core_MDF_DCF_RecordTypeName;
            
            if(wrapper != null &&
               wrapper.recordTypeDevNameAndLabelName != null && 
               wrapper.recordTypeDevNameAndId != null &&
               wrapper.recordTypeDevNameAndLabelName.containsKey(ipaDevName) && 
               wrapper.recordTypeDevNameAndId.containsKey(ipaDevName)) {
                
                Map<String, Object> result = new Map<String, Object>{
                    'recordTypeId' => wrapper.recordTypeDevNameAndId.get(ipaDevName),
                    'recordTypeName' => wrapper.recordTypeDevNameAndLabelName.get(ipaDevName),
                    'recordTypeDeveloperName' => ipaDevName
                };
                
                return result;
            } else {
                throw new AuraHandledException('Datacenter record type not found or not accessible to current user');
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Unable to fetch Datacenter record type: ' + e.getMessage());
        }
    }

    /**
     * Method to fetch Co-Inv (Outcome-Based Activity) record type for PartnerFundRequest
     * This uses the DCF record type label as Co-Inv is managed under DCF
     */
    @AuraEnabled
    public static Map<String, Object> getCoInvRecordType() {
        try {
            Core_MDF_PFR_RecordTypeSelector.recordTypeWrapper wrapper = 
                Core_MDF_PFR_RecordTypeSelector.fetchRecordType('PartnerFundRequest');
            
            String coInvDevName = 'Core_MDF_Co_Inv';
            
            if(wrapper != null &&
               wrapper.recordTypeDevNameAndLabelName != null && 
               wrapper.recordTypeDevNameAndId != null &&
               wrapper.recordTypeDevNameAndLabelName.containsKey(coInvDevName) && 
               wrapper.recordTypeDevNameAndId.containsKey(coInvDevName)) {
                
                Map<String, Object> result = new Map<String, Object>{
                    'recordTypeId' => wrapper.recordTypeDevNameAndId.get(coInvDevName),
                    'recordTypeName' => wrapper.recordTypeDevNameAndLabelName.get(coInvDevName),
                    'recordTypeDeveloperName' => coInvDevName
                };
                
                return result;
            } else {
                throw new AuraHandledException('Co-Inv record type not found or not accessible to current user');
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Unable to fetch Co-Inv record type: ' + e.getMessage());
        }
    }

    /**
     * Returns which creation-related permissions the current user has.
     * Keys returned in the map: hasIPA (Boolean), hasCCF (Boolean), hasDCF (Boolean)
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getUserCreationPermissions() {
        Map<String, Object> result = new Map<String, Object>();
        // First check Custom Permissions (preferred). If not present, fall back to Permission Set assignment checks
        Boolean hasIPA = FeatureManagement.checkPermission('Core_MDF_CCP_External_IPA_Activity_Manager') ||
                         FeatureManagement.checkPermission('Core_MDF_CCP_Internal_IPA_Acct_Mgr');

        Boolean hasCCF = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr') ||
                         FeatureManagement.checkPermission('Core_MDF_CCP_Internal_CCF_Acct_Mgr');

        Boolean hasDCF = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_DCF_Field_Acct_Mgr') ||
                         FeatureManagement.checkPermission('Core_MDF_CCP_Internal_DCF_Acct_Mgr');

        // If custom permissions are not used in the org, also check if the user has relevant Permission Sets assigned
        try {
            if (!hasIPA) {
                List<String> ipaNames = new List<String>{'Core_MDF_CCP_External_IPA_Activity_Manager','Core_MDF_CCP_Internal_IPA_Acct_Mgr'};
                List<PermissionSet> psIPA = [SELECT Id FROM PermissionSet WHERE Name IN :ipaNames OR Label IN :ipaNames];
                if (!psIPA.isEmpty()) {
                    List<Id> psIds = new List<Id>();
                    for (PermissionSet p : psIPA) psIds.add(p.Id);
                    List<PermissionSetAssignment> psaIPA = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSetId IN :psIds LIMIT 1];
                    hasIPA = !psaIPA.isEmpty();
                }
            }

            if (!hasCCF) {
                List<String> ccfNames = new List<String>{'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr','Core_MDF_CCP_Internal_CCF_Acct_Mgr'};
                List<PermissionSet> psCCF = [SELECT Id FROM PermissionSet WHERE Name IN :ccfNames OR Label IN :ccfNames];
                if (!psCCF.isEmpty()) {
                    List<Id> psIds = new List<Id>();
                    for (PermissionSet p : psCCF) psIds.add(p.Id);
                    List<PermissionSetAssignment> psaCCF = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSetId IN :psIds LIMIT 1];
                    hasCCF = !psaCCF.isEmpty();
                }
            }

            if (!hasDCF) {
                List<String> dcfNames = new List<String>{'Core_MDF_CCP_Internal_DCF_Field_Acct_Mgr','Core_MDF_CCP_Internal_DCF_Acct_Mgr'};
                List<PermissionSet> psDCF = [SELECT Id FROM PermissionSet WHERE Name IN :dcfNames OR Label IN :dcfNames];
                if (!psDCF.isEmpty()) {
                    List<Id> psIds = new List<Id>();
                    for (PermissionSet p : psDCF) psIds.add(p.Id);
                    List<PermissionSetAssignment> psaDCF = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSetId IN :psIds LIMIT 1];
                    hasDCF = !psaDCF.isEmpty();
                }
            }
        } catch (Exception e) {
            // Query may fail in some contexts; ignore and rely on custom permission checks
            System.debug('PermissionSetAssignment fallback check failed: ' + e.getMessage());
        }

        result.put('hasIPA', hasIPA);
        result.put('hasCCF', hasCCF);
        result.put('hasDCF', hasDCF);

        return result;
    }
    

}