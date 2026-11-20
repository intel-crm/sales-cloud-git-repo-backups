public without Sharing class Core_MDF_Generic_Class_Record_Tracking {
    public static void insertingTrackRecord(String recordId,String objectName,String scope){
        
          Core_MDF_Record_Tracking__c recTracking = new Core_MDF_Record_Tracking__c();
            recTracking.Core_MDF_Object_Name_nm__c = objectName;
            recTracking.Core_MDF_Scope_nm__c =scope ;
            recTracking.Core_MDF_Target_Record_Id__c = recordId;
        
        Database.Insert(recTracking);
    }
}