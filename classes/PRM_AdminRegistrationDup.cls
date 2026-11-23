public class PRM_AdminRegistrationDup {

    
    @AuraEnabled(cacheable=true)
    public static List<stateCountryInfo> fetchStateCountryValues()
    {
        Map<String,List<String>> countryStateMap = new Map<String,List<String>>();
        Map<String, Schema.SObjectField> objFieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        Schema.SObjectField  controllingField = objFieldMap.get('billingcountrycode');
        Schema.SObjectField  dependentField = objFieldMap.get('billingstatecode');
        List<String> controllingValues = new List<String>();
        List<Schema.PicklistEntry> contrEntries = new List<Schema.PicklistEntry>();
        List<Schema.PicklistEntry> depEntries =  new List<Schema.PicklistEntry>();
        Map<String,String> countryLabelValueMap = new Map<String,String>();
        
        for(Schema.PicklistEntry f :  controllingField.getDescribe().getPicklistValues()){
            String label = f.getLabel();
            contrEntries.add(f);
            countryLabelValueMap.put(label,f.getValue());
            countryStateMap.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for(Schema.PicklistEntry currDependentValue : dependentField.getDescribe().getPicklistValues()){
            depEntries.add(currDependentValue);
            String jsonString = JSON.serialize(currDependentValue);
            PickListInfo info = (PickListInfo) JSON.deserialize(jsonString, PickListInfo.class);
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            //system.debug('!!'+info.validFor);
            //system.debug('##'+EncodingUtil.base64Decode(info.validFor));
            //system.debug('@@'+hexString);
            Integer baseCount = 0;
            for(Integer curr : hexString.getChars()){
                Integer val = 0;
                if(curr >= 65){
                    val = curr - 65 + 10;
                }
                else{
                    val = curr - 48;
                }
                if((val & 8) == 8){
                    countryStateMap.get(contrEntries[baseCount + 0].getLabel()).add(currDependentValue.getLabel()+';'+currDependentValue.getValue());
                }
                if((val & 4) == 4){
                    countryStateMap.get(contrEntries[baseCount + 1].getLabel()).add(currDependentValue.getLabel()+';'+currDependentValue.getValue());                 
                }
                if((val & 2) == 2){
                    countryStateMap.get(contrEntries[baseCount + 2].getLabel()).add(currDependentValue.getLabel()+';'+currDependentValue.getValue());                 
                }
                if((val & 1) == 1){
                    countryStateMap.get(contrEntries[baseCount + 3].getLabel()).add(currDependentValue.getLabel()+';'+currDependentValue.getValue());                 
                }
                baseCount += 4;
            }         
        }
        
        List<stateCountryInfo> stateCountryInfoList = new List<stateCountryInfo>();
        for(String s : countryStateMap.keySet())
        {
            stateCountryInfo info = new stateCountryInfo();
            info.country= s+';'+countryLabelValueMap.get(s);
            info.stateList= countryStateMap.get(s);
            stateCountryInfoList.add(info);
        }
        System.debug(LoggingLevel.ERROR,' before return ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
        return stateCountryInfoList;
    }
    
    @AuraEnabled(cacheable=true)
    public static picklistValues getPicklistValues()
    {
        picklistValues pi = new picklistValues();
        pi.stateCountryInfoList =  fetchStateCountryValues();
        Map<String,String> bizOrgTypeMap= new Map<String,String>();      
        Schema.DescribeFieldResult fieldResult1 = Account.Core_Account_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple1){
            bizOrgTypeMap.put(pickListVal.getValue(),pickListVal.getLabel());
              
        }                        
        pi.bizOrgTypeMap = bizOrgTypeMap ;
/*        
Map<String,String> partnerRoleMap= new Map<String,String>();      
Schema.DescribeFieldResult fieldResult2 = Account.Core_IPA_Partner_Role__c.getDescribe();
List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
for( Schema.PicklistEntry pickListVal : ple2){
partnerRoleMap.put(pickListVal.getValue(),pickListVal.getLabel());
}
pi.partnerRoleMap = partnerRoleMap ;
        */
        //returning map of biz org type and partner role
		
        Map<String,String> roleTypeMap = new Map<String,String>();
        for(PRM_PartnerRoleTypeMappings__mdt roleTypeReq : [Select Id,PRM_Biz_Org_Type__c,PRM_Partner_Role__c,PRM_Partner_Role_Label__c
                                                            from PRM_PartnerRoleTypeMappings__mdt]){
                                                                roleTypeMap.put(roleTypeReq.PRM_Biz_Org_Type__c, roleTypeReq.PRM_Partner_Role_Label__c);
                                                            }
        pi.roleTypeMapping = roleTypeMap;
        System.debug('roleTypeMap'+pi.roleTypeMapping);
        
        Map<String,String> prefLanguageMap= new Map<String,String>();   
        String excludePrelang = System.Label.PRM_Exclude_Preferred_Languag ;
        List<String> lstName = excludePrelang.split(',');
        System.debug('rest'+lstName);
        Schema.DescribeFieldResult fieldResult3 = Contact.Core_Preferred_Language__c.getDescribe();
        List<Schema.PicklistEntry> ple3 = fieldResult3.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple3){
            
            if(!lstName.contains(pickListVal.getValue())){
            prefLanguageMap.put(pickListVal.getValue(),pickListVal.getLabel());
                }
        }     
        pi.prefLanguageMap = prefLanguageMap;
        System.debug(LoggingLevel.ERROR,' before return ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
        return pi;
    }
    
    @AuraEnabled
    public static Map<String,Contact> fetchAccountDetails(String emailId){
        
        System.debug('emailId'+emailId);
        Map<String,Contact> accConMap;
        for(Contact c : [Select Id,Account.Name,Account.BillingStreet,Account.BillingCountryCode,Account.BillingStateCode,
                         Account.BillingCity,Account.BillingPostalCode,Account.Core_Account_Type__c,Account.Core_User_Defined_Website__c,
                         toLabel(Core_IPA_PartnerRole__c) from Contact where Email =: emailId]){
                             System.debug('c'+c);
                             accConMap = new Map<String,Contact>();
                             accConMap.put(c.Id,c);
                         }
        System.debug('accConMap'+accConMap);
        return accConMap;
    }
    
    
    @AuraEnabled
    public static Map<String,String> submitAdminRequestForm(Map<String,String> registrationDetailsMap)
    {
        //system.debug('!!!-->'+PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap));
        return PRM_CreateAccountAndRelatedRecordsAdmin.createAccountAndRelatedRecordsAdmin(registrationDetailsMap);
    }
    
    public class PicklistValues{
        @AuraEnabled
        public List<stateCountryInfo> stateCountryInfoList;
        @AuraEnabled
        public Map<String,String> bizOrgTypeMap;
        @AuraEnabled
        public Map<String,String> roleTypeMapping;
        @AuraEnabled
        public Map<String,String> prefLanguageMap;
        
    }  
    
    public class StateCountryInfo{
        @AuraEnabled
        public String country;
        @AuraEnabled
        public List<String> stateList;
    }  
    
    public class PickListInfo{
        @AuraEnabled 
        public String validFor;
    }   
}