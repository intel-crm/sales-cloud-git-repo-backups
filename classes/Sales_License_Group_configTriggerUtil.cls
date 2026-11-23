/***************************************************************************
Class Name    : Sales_License_Group_configTriggerUtil
Version       : 1.0
Created Date  : May 2021
Function      : update license parameter field with switches for the sales license group switch configuration
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Mohammad Dilshad           31-May-2021              Sales License Group Config Switch Trigger Handler Util
* *********************************************************************************************************************/
public without sharing class Sales_License_Group_configTriggerUtil {
    public static void updateLicenseParameter(List<Sales_License_Group_Switch_config__c> groupSwitchConfigList){
        set<id> licGroupIdSet = new set<id>();
        map<id,String> licGroupLicParamMap = new map<id,String>();
        string licenseParamtervalue ;
        list<Sales_License_Group__c> toUpdateSalesLicenseGroup = new list<Sales_License_Group__c>();
        if(groupSwitchConfigList.size()>0){
            for(Sales_License_Group_Switch_config__c salesLicenseGroupConfig :groupSwitchConfigList){
                licGroupIdSet.add(salesLicenseGroupConfig.Sales_License_Group__c);
            }
            for(Sales_License_Group_Switch_config__c salesLicenseGroupConfigRec :[SELECT id,Sales_License_Generator_Switch__c,Sales_License_Value_txt__c,Sales_License_Generator_Switch__r.Sales_License_Switch_txt__c,Sales_License_Group__c,Sales_License_Sequence_nbr__c FROM Sales_License_Group_Switch_config__c WHERE Sales_License_Group__c IN:licGroupIdSet Order By Sales_License_Sequence_nbr__c]){
                if(licGroupLicParamMap.containsKey(salesLicenseGroupConfigRec.Sales_License_Group__c) && salesLicenseGroupConfigRec.Sales_License_Generator_Switch__r.Sales_License_Switch_txt__c != null){
                    licenseParamtervalue = licGroupLicParamMap.get(salesLicenseGroupConfigRec.Sales_License_Group__c);                     
                    licenseParamtervalue = licenseParamtervalue + ' ' + salesLicenseGroupConfigRec.Sales_License_Generator_Switch__r.Sales_License_Switch_txt__c;
                    if(salesLicenseGroupConfigRec.Sales_License_Value_txt__c != null)
                        licenseParamtervalue = licenseParamtervalue + ' ' + salesLicenseGroupConfigRec.Sales_License_Value_txt__c;
                    licGroupLicParamMap.put(salesLicenseGroupConfigRec.Sales_License_Group__c, licenseParamtervalue);
                }else if(salesLicenseGroupConfigRec.Sales_License_Generator_Switch__r.Sales_License_Switch_txt__c != null){
                    licenseParamtervalue=salesLicenseGroupConfigRec.Sales_License_Generator_Switch__r.Sales_License_Switch_txt__c;    
                    if(salesLicenseGroupConfigRec.Sales_License_Value_txt__c != null)
                        licenseParamtervalue = licenseParamtervalue + ' ' + salesLicenseGroupConfigRec.Sales_License_Value_txt__c;
                    licGroupLicParamMap.put(salesLicenseGroupConfigRec.Sales_License_Group__c, licenseParamtervalue);
                }                
            }
            for(Id groupId: licGroupLicParamMap.keyset()){
                Sales_License_Group__c licGroup = new Sales_License_Group__c();
                licGroup.id = groupId;
                licGroup.Sales_License_Parameter_txt__c = licGroupLicParamMap.get(groupId);
                toUpdateSalesLicenseGroup.add(licGroup);
            }
            update toUpdateSalesLicenseGroup;
        }
    }
    public static void checkForDuplicateLicGroupSwitchConfig(List<Sales_License_Group_Switch_config__c> newLicGroupSwitchConfigList){
        if(newLicGroupSwitchConfigList != null && !newLicGroupSwitchConfigList.isEmpty()){
            Set<Id> groupIDs = new Set<Id>();
            Map<String, Sales_License_Group_Switch_config__c> groupSwitchConfigMap = new Map<String, Sales_License_Group_Switch_config__c>();
            for(Sales_License_Group_Switch_config__c config: newLicGroupSwitchConfigList){
                groupIDs.add(config.Sales_License_Group__c);                
                groupSwitchConfigMap.put(String.valueOf(config.Sales_License_Group__c)+String.valueOf(config.Sales_License_Generator_Switch__c), config);
            }
            for(Sales_License_Group_Switch_config__c existingConfig: [Select Id,Sales_License_Group__c,Sales_License_Generator_Switch__c from Sales_License_Group_Switch_config__c where Sales_License_Group__c IN: groupIDs]){
                if(groupSwitchConfigMap.containsKey(String.valueOf(existingConfig.Sales_License_Group__c) + String.valueOf(existingConfig.Sales_License_Generator_Switch__c))){
                    groupSwitchConfigMap.get(String.valueOf(existingConfig.Sales_License_Group__c) + String.valueOf(existingConfig.Sales_License_Generator_Switch__c)).addError('This Switch is already associated with the License Group.');    
                }    
            }
        }    
    }
}