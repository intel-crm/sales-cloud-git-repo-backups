public with sharing class Core_MDF_CCP_MultiLookup {
    public Core_MDF_CCP_MultiLookup() {

    }

    @AuraEnabled( cacheable=true )  
    public static list<Core_MDF_CCP_Maintenance_Screen__mdt> fetchSampleRecs() {
        List<Core_MDF_CCP_Maintenance_Screen__mdt> resultData = new List<Core_MDF_CCP_Maintenance_Screen__mdt>();
        for(Core_MDF_CCP_Maintenance_Screen__mdt obj: [ SELECT Id, Core_MDF_Object_Label__c,Core_MDF_Object_API_Name__c,Core_MDF_Field_Label__c,	Core_MDF_Field_API_Name__c,Core_MDF_Object_Record_Name__c,Core_MDF_Column_Fields__c,Core_MDF_Fields_Editable__c,ShareObject__c FROM Core_MDF_CCP_Maintenance_Screen__mdt where Core_MDF_IsActive__c = true order by Core_MDF_Object_Label__c])
        {
           resultData.add(obj);
        }
        return resultData;
    }


      @AuraEnabled(cacheable=true)
    public static List<SObJectResult> getResult(String ObjectName,String filterCondition) {
        List<SObJectResult> sObjectResultList1 = new List<SObJectResult>();
        String replacedQuery = '';
        Core_MDF_CCP_Maintenance_Screen__mdt[] accts =[SELECT Core_MDF_Object_Record_Name__c FROM Core_MDF_CCP_Maintenance_Screen__mdt WHERE Core_MDF_Object_API_Name__c LIKE :ObjectName and Core_MDF_IsActive__c = true];
            String query = 'Select Id,';
           if(filterCondition!=null)
               
               {   
                   query = query+accts[0].Core_MDF_Object_Record_Name__c +' FROM '+String.escapeSingleQuotes(ObjectName)+' WHERE '+String.escapeSingleQuotes(filterCondition);
                   replacedQuery = query.replaceAll('\\\\', '');
               }
                 String fieldvalue='';
                for(sObject so : Database.Query(replacedQuery)) 
                {    fieldvalue = (String)so.get(accts[0].Core_MDF_Object_Record_Name__c);
                     sObjectResultList1.add(new SObjectResult(fieldvalue, so.Id));
                }
                return sObjectResultList1;
    }
    
    
    
 
    public class SObjectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;


public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
        public SObJectResult() {

        }
    }

}