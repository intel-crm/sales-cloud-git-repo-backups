/***************************************************************************************************** 
Class Name   :    Core_MDF_OutcomeBasedCmpgn_ParentComp
Description  :    Server-side controller of Core_MDF_OutcomeBasedCmpgn_ParentComp
Added By     :    Ramapriya - Weezer
Created Date :    12/12/2025
******************************************************************************************************/
public class Core_MDF_OutcomeBasedCmpgn_ParentComp {

    /**
     * Method to check if user has access to create new Outcome-Based Campaign
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

}