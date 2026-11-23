public class Core_MDF_FeatureFlag {
    
    Public Static Set<string> customPermissionNames = customPermissionNames.isEmpty() ? getCustomPermissionNames() : new Set<string>();
    Public static Map<String,Core_MDF_Feature_Flag__c> features = features.isEmpty() ? getFeatureFlags() : new Map<String,Core_MDF_Feature_Flag__c>();
    Public static List<string> fieldToValidate = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_FeatureFlag_Fields').split(',');
    Public static Map<String,SObjectField> objectFieldMap = objectFieldMap.isEmpty() ? getObjFieldType() : new Map<String,SObjectField>();
    Public static List<User> loggedInUserInfo = loggedInUserInfo.isEmpty() ? getUserDetails() : new List<User>();
    
    public static FeatureEvaluationResult evaluate(String featureName) {
        system.debug('customPermissionNames-->'+customPermissionNames);
        FeatureEvaluationResult result;
        
        if(customPermissionNames.contains(featureName)){
            result = checkCustomPermission(featureName);
        }
        else{
            result = checkFeature(featureName);
        }
        
        return result;
    }
    
    public static FeatureEvaluationResult checkCustomPermission(string featureName){
        return FeatureManagement.checkPermission(featureName) ? new FeatureEvaluationResult(true, featureName) : 
        new FeatureEvaluationResult(false, featureName);
    }
    
    public static FeatureEvaluationResult checkFeature(string featureName){
        Boolean result = true;
        string EFFECTIVE_DATE = 'Core_MDF_Effective_Date__c';
        string INEFFECTIVE_DATE = 'Core_MDF_Ineffective_Date__c';
        string REQUIRED_PERMISSION = 'Core_MDF_Required_Permission__c';
        string USER_GEO = 'Core_MDF_User_Geo__c';
        string USER_TYPE = 'Core_MDF_User_Type__c';
        
        if(features.containsKey(featureName) && features.get(featureName).Core_MDF_Active__c){
            Core_MDF_Feature_Flag__c featureFlag = features.get(featureName);
            
            for(string field : fieldToValidate){
                if(featureFlag.get(field) != NULL){
                    
                    string fieldType = string.valueOf(objectFieldMap.get(field).getDescribe().getType());
                    string fieldValue = string.ValueOf(featureFlag.get(field));
                    
                    switch on fieldType {
                        when 'DATE' {
                            if(fieldValue != NULL){
                                if((field == EFFECTIVE_DATE && system.today() <= date.ValueOf(fieldValue)) || 
                                   (field == INEFFECTIVE_DATE && system.today() > date.ValueOf(fieldValue))){
                                       result = false;
                                   }  
                            }
                            
                        }
                        when 'STRING' {	
                            if(string.isNotBlank(fieldValue)){
                                if(field == REQUIRED_PERMISSION && !FeatureManagement.checkPermission(fieldValue)){
                                    result = false;
                                }else if(field == USER_GEO && !loggedInUserInfo.isEmpty() && loggedInUserInfo[0].Core_User_Geo__c != fieldValue){
                                    result = false;
                                }else if(field == USER_TYPE && !loggedInUserInfo.isEmpty() && !fieldValue.contains(loggedInUserInfo[0].UserType)){
                                    result = false;
                                }
                            }
                        }
                    }
                }
                
            }            
        }else{
            result = false;
        }
        return new FeatureEvaluationResult(result, featureName);
    }
    
    public static Set<String> getCustomPermissionNames(){
        Set<String> customPermissionNames = new Set<String>();
        for(CustomPermission perm : [SELECT Id, DeveloperName FROM CustomPermission]){
            customPermissionNames.add(perm.DeveloperName);
        }
        return customPermissionNames;
    }
    
    public static Map<String,Core_MDF_Feature_Flag__c> getFeatureFlags(){
        return Core_MDF_Feature_Flag__c.getAll();
    }
    
    public static List<User> getUserDetails(){
        return [SELECT Id, Core_User_Geo__c, UserType FROM User WHERE Id =: UserInfo.getUserId()];
    }
    
    public static Map<String,SObjectField> getObjFieldType(){
        Schema.SObjectType sObjType = ((SObject)(Type.forName('Schema.Core_MDF_Feature_Flag__c').newInstance())).getSObjectType();
        DescribeSObjectResult sObjResult = sObjType.getDescribe();
        return sObjResult.fields.getMap();
    }
    
    public class FeatureEvaluationResult{
        private Boolean result;
        private String featureName;
        
        public Boolean isEnabled(){
            return result;
        }
        
        public String getFeatureName(){
            return featureName;
        }
        
        public FeatureEvaluationResult(Boolean result, String featureName){
            this.result = result;
            this.featureName = featureName;
        }
    }
    
}