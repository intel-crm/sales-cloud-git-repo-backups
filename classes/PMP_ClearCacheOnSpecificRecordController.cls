public class PMP_ClearCacheOnSpecificRecordController {   
    @AuraEnabled
    public static Boolean removeRecordCache(String recordId, String objectName){  
        String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');
        String langKeys=PMP_StaticConstants_Partner.supportedLanguagesForPlatformCache;
        Map<String,String> langMap= new Map<string,string>();
        for(String languageCode : langKeys.split('\\;')){
            langMap.put(languageCode,languageCode.replace('_', '').replace('-', ''));
        }
        for(string str : langMap.keySet()){
            if(langMap.containsKey(str)){
               String cachekey = objectName+recordId+langMap.get(str); 
                if(cachekey != null){
                    Cache.Org.remove(partitionInput+'.'+cachekey);
                 } 
               }            
        }                     
	    return true;
	}
}