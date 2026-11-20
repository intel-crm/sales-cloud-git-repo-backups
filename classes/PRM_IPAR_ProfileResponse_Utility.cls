public class PRM_IPAR_ProfileResponse_Utility {

    //public static boolean profRespSwitch = boolean.valueOf(label.PRM_IPARefresh);
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
            return fieldLabelsMap;
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
        String key = (String)obj.get('Question_Code__c') + '|' + (String)obj.get('Answer_Code__c');
        qstnPRMap.put(key, obj);
        
    }
    return qstnPRMap; 
}
        

}