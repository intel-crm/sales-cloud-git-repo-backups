public class MaintenanceScreen{
    
    @AuraEnabled( cacheable=true )  
    public static list<Core_MDF_CCP_Maintenance_Screen__mdt> fetchSampleRecs() {
        List<Core_MDF_CCP_Maintenance_Screen__mdt> resultData = new List<Core_MDF_CCP_Maintenance_Screen__mdt>();
        for(Core_MDF_CCP_Maintenance_Screen__mdt obj: [ SELECT Id, Core_MDF_Object_Label__c,Core_MDF_Object_API_Name__c,Core_MDF_Field_Label__c,	Core_MDF_Field_API_Name__c,Core_MDF_Object_Record_Name__c,Core_MDF_Column_Fields__c,Core_MDF_Fields_Editable__c,ShareObject__c FROM Core_MDF_CCP_Maintenance_Screen__mdt])
        {
           resultData.add(obj);
        }
        return resultData;
    }

    @AuraEnabled
    public static  Map<String, List<shareResult>> fetchSampleRecs1(String ObjectName, List<String> selectedRecId) {
    String queryObject = 'Select Id, ';
    queryObject =queryObject +' AccessLevel, RowCause,ParentId,UserOrGroupId,UserOrGroup.name FROM '+ ObjectName  ;
    List<sObject> resultData = new List<sObject>();
    Map<String, List<shareResult>> pfrShareMap = new Map<String, List<shareResult>>();
    for(String act :selectedRecId )
    {  
        List<shareResult> shareRecord = new List<shareResult>();
        for(sObject pfr : Database.Query(queryObject+' WHERE ParentId =\'' +  act + '\'') )
        {
           System.debug('pfr '+pfr);
           shareResult sr = new shareResult();
           sr.AccessLevel = (String)pfr.get('AccessLevel');
           sr.ParentId =  (Id)pfr.get('ParentId');
           sr.RowCause = (String)pfr.get('RowCause');
           sr.UserOrGroupId = (String)pfr.get('UserOrGroupId'); 
           PartnerFundRequestShare userRecord = (PartnerFundRequestShare)pfr; 
           String userName =userRecord.UserOrGroup.name;
           System.debug('userName'+userName);
           sr.UserOrGroupName = userName;
           shareRecord.add(sr);
           System.debug('shareRecord '+shareRecord);
        }
        pfrShareMap.put(act,shareRecord);
        System.debug('pfrShareMap '+pfrShareMap);
    }
    return pfrShareMap;
}
public class shareResult {
    @AuraEnabled
    public String AccessLevel;
    @AuraEnabled
    public Id ParentId;
    @AuraEnabled
    public String RowCause;
    @AuraEnabled
    public String UserOrGroupId;
    @AuraEnabled
    public String UserOrGroupName;
    @AuraEnabled
    public sObject userData;
    @AuraEnabled
    public sObject UserOrGroup;
    @AuraEnabled
    public String name;
    
}
}