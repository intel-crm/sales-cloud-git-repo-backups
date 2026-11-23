public class PRM_ProfileResponse_Utility {

    public static String profRespSwitch=System.label.PRM_IPARefresh;
    public static final String POINTS_NOT_ELIGIBLE = 'Points Not Eligible';
    public static final String POINTS_OPT_IN = 'Points Opt-in';
    public static final String IPA_REG_SRC = 'IPA_Registration_Source';
    
        public static Map<String, String> getProfResFieldNames() {
            Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.PRM_IPAMembership_Attributes__c.fields.getMap();
            Map<String, String> fieldLabelsMap = new Map<String, String>();
            for (String fieldName : fieldsMap.keySet()) {
                String fieldLabel = fieldsMap.get(fieldName).getDescribe().getLabel();
                fieldLabelsMap.put(fieldName, fieldLabel); 
            }
            system.debug('-----'+fieldLabelsMap);
            return fieldLabelsMap;
        }

        public static Map<Id, List<String>> getUpdatedPRFields(List<PRM_IPAMembership_Attributes__c> newList,Map<id, PRM_IPAMembership_Attributes__c> oldMap) {
           Map<Id, List<String>> OPIDPRMap = new Map<Id, List<String>>(); 
           
            List<String> fieldNames = new List<String>{'PRM_ODM_whiteboxPointEarning_excl_Ind__c',
            'PRM_Point_Status__c',
            'PRM_Points_Not_Eligible__c',
            'PRM_Points_Opt_in_Date__c'
            };     
            // add all fields above    
            for (PRM_IPAMembership_Attributes__c newPR : newList) {         
                List<String> updatedPRList = new List<String>();       
                PRM_IPAMembership_Attributes__c oldPR= oldMap.get(newPR.PRM_Account_Id__c);         
               
                // Iterate over the field names and compare values dynamically         
                for (String fieldName : fieldNames) {             
                    // Retrieve field values dynamically using get() method
                    //oldPR.PRM_Account_Id__c = newPR.PRM_Account_Id__c;
                    Object newValue = newPR.get(fieldName);             
                    Object oldValue = oldPR.get(fieldName);             
                    // Compare field values             
                    if (newValue != null && !newValue.equals(oldValue)) {                 
                        System.debug(fieldName + ' has changed from ' + oldValue + ' to ' + newValue);
                        updatedPRList.add(fieldName);
                        system.debug('updatedPRList---'+updatedPRList);             
                    }         
                } 
                if(!updatedPRList.isEmpty()){
                    OPIDPRMap.put(newPR.PRM_Account_Id__c, updatedPRList);
                }    
            } 
            return OPIDPRMap;
        }

        public static List<PRM_IPAMembership_Attributes__c> fetchIPAMemberAttributes() {
    return [
        Select 
            Id,
            Name, 
            PRM_Account_Id__c, 
            PRM_Branded_Point_earning_excl_Ind__c, 
            PRM_Branded_Point_earning_excl_Dt__c,
            PRM_Component_Point_earning_excl_Ind__c, 
            PRM_Component_Point_earning_excl_Dt__c,
            PRM_ODM_whiteboxPointEarning_excl_Ind__c,
            PRM_ODM_whiteboxPointEarning_excl_Dt__c,
            PRM_Point_Status_Txt__c,
            PRM_Point_Status_Dt__c,
            PRM_Point_Status_Reason_Txt__c,
            PRM_Points_Not_Eligible_Ind__c,
            PRM_Points_Not_Eligible_Dt__c,
            PRM_Points_Opt_in_Ind__c,
            PRM_Points_Opt_in_Dt__c,
            PRM_Registration_Source_Txt__c
        from PRM_IPAMembership_Attributes__c
    ];
}

public static Set<String> getOptInRoles() {
    return new Set<String>{
        System.Label.PRM_Service_Provider,
        System.Label.PRM_OEM,
        System.Label.PRM_Independent_Software_Vendor,
        System.Label.PRM_Solution_Integrator
    };
}


public static Set<String> getNotEligibleRoles() {
    return new Set<String>{
        System.Label.PRM_Distributor_Partner_Role,
        System.Label.PRM_FPGA_Designer_Partner_role,
        System.Label.PRM_Guest_Partner_Role
    };
}

    public static Boolean checkExistingPartnerRoles(List<String> partnerRoleList, String roleIndicatorStr) {//change to metadata
    Boolean isRoleExist = false;
    Set<String> notEligibleSetRoles= new Set<String>{
            System.Label.PRM_Distributor_Partner_Role,
            System.Label.PRM_FPGA_Designer_Partner_role,
            System.Label.PRM_Guest_Partner_Role
        };
            
        Set<String> optInRoles= new Set<String>{
        System.Label.PRM_Service_Provider,
        System.Label.PRM_OEM,
        System.Label.PRM_Independent_Software_Vendor,
        System.Label.PRM_Solution_Integrator
    };    
        if(roleIndicatorStr=='Not Eligible Role'){
            for(String str : partnerRoleList){
                if(notEligibleSetRoles.contains(str)){
                    isRoleExist=true;
                    break;
                }  
            }    
        }else if(roleIndicatorStr=='Opt In Role'){
            for(String str : partnerRoleList){
                if(optInRoles.contains(str)){
                    isRoleExist=true;
                    break;
                }   
            }
        }
    return isRoleExist;
}

public static Map<String, Object> getProfResponsemdt(){

    Map<String, Object> qstnPRMap = new Map<String, Object>();

    for(Map<String, Object> obj : new Core_CustomMetadataObjectController('PRM_IPAMembership_Mapping__mdt').getAll().values()){
        System.debug('obj in mdt----'+obj);
        String key = (String)obj.get('Question_Code__c') + '|' + (String)obj.get('Answer_Code__c');
        qstnPRMap.put(key, obj);
        System.debug('qstnPRMap----'+qstnPRMap);
    }
    //System.debug('qstnAnsCode--'+qstnPRMap);
    return qstnPRMap; 
}
        

}