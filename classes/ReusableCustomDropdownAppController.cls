public with sharing class ReusableCustomDropdownAppController {
    
    @AuraEnabled
    public static List<Map<String, String>> getSObjectSelectList() {
        List<Map<String, String>> SobjectList = new List<Map<String, String>>();

            for(Account sobjName : [Select Id, Name, Core_MDF_Channel_Program__c From Account where Core_MDF_CoMarketing_Ultimate_Account__c = '001g0000024cgUuAAI'
                              And Core_MDF_Channel_Program__c = '0Pkg00000008OTTCA2' And Core_MDF_Active_Ind__c = TRUE ORDER BY Name ASC]) {
                Map<String, String> sObjMap = new Map<String, String>();
                                  
                /*//Exclude all the unwanted Sobjects e.g. CustomSettings, History, Share, Feed, ApexClass, Pages etc..
                if(!objType.getDescribe().isCustomSetting() && !sobjName.endsWithIgnoreCase('__c') && objType.getDescribe().getRecordTypeInfos().size() > 0 && objType.getDescribe().isCreateable() &&
                    !sobjName.containsIgnoreCase('history') && !sobjName.containsIgnoreCase('tag') && !sobjName.containsIgnoreCase('share') && !sobjName.containsIgnoreCase('feed')) {
                    sObjMap.put('label', objLabel);  
                    sObjMap.put('value', sobjName);   
                    sortSObjectList.add(new sortingWrapper(sObjMap));
                }
                else if(!objType.getDescribe().isCustomSetting() && sobjName.endsWithIgnoreCase('__c')) {
                    sObjMap.put('label', objLabel);
                    sObjMap.put('value', sobjName);
                    sortSObjectList.add(new sortingWrapper(sObjMap));
                }*/
               if(SobjectList != NULL && sobjName.Id != NULL && sobjName.Name != NULL && SobjectList.size()>0){
                    sObjMap.put('label', String.valueOf(sobjName.Name));
                    sObjMap.put('value', String.valueOf(sobjName.Id));
                    SobjectList.add(sObjMap);
                }
                else{
                    sObjMap.put('label', 'choose one...');
                    sObjMap.put('value', 'choose one...');
                    SobjectList.add(sObjMap);
                }
            }
        System.debug('@@@Label-> '+SobjectList[0]);
        return SobjectList;
    }
}