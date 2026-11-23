public with sharing class  Sales_UpdateHostDetailsOnLicense {
 @AuraEnabled(cacheable=true)
        public static List<Sales_Host__c> getHost(String hostName){
            List<Sales_Host__c> hostList =new List<Sales_Host__c>();
            if(String.isNotEmpty(hostName)){
            string searchText = '%'+hostName+'%';
                hostList=[select id,Name from Sales_Host__c where Sales_License_Type__c!='FIXED'and (Name like :searchText or id =:searchText)];
            }
             return hostList;
            
        }
    @AuraEnabled(cacheable=true)
    public static List<Sales_License__c> getRecords(Id hostId){
        List<Sales_License__c> licenseListToReturn =new List<Sales_License__c>();
        if(hostId!=null){
        licenseListToReturn=[select Id,name,Sales_License_Host_Node_Txt__c,Sales_License_Host_Node_Id__c,Sales_License_Host_Node_Id__r.name,Sales_License_Type__c from Sales_License__c where Sales_License_Host_Node_Id__c=:hostId and Sales_Tool_License_Type__c!='FIXED'];
            
            }
        else{
                    licenseListToReturn=[select Id,name,Sales_License_Host_Node_Txt__c,Sales_License_Host_Node_Id__c,Sales_License_Host_Node_Id__r.name from Sales_License__c where Sales_License_Host_Node_Txt__c=null and Sales_License_Status__c='Unassigned'and Sales_Tool_License_Type__c!='FIXED'];

        }
        return licenseListToReturn;
        
    }
     @AuraEnabled
    public static  List<listWrapper> updateRecords(String oldHost,String newHost,String licenseSelected){
          List<String> selectedLicense=new List<String>();
        boolean Success=false;
        List<Sales_License__c> licenseListToUpdate=new List<Sales_License__c>();
        
         List<listWrapper> tempWrapperList = new List<listWrapper>();
        selectedLicense=licenseSelected.split(',');
         if(selectedLicense.size()>0){
             for(Sales_License__c licenseList:[select id,name,Sales_License_Host_Node_Id__c,Sales_Tool_License_Type__c from Sales_License__c where name in :selectedLicense]){
                 if(Sales_LicenseRecordPageComponentsUtility.LicenseTypeCheck(newHost,licenseList.id)==true){
            
                      String returnMsg=Sales_LicenseRecordPageComponentsUtility.hostReassignment(newHost,licenseList.id);
                     if(returnMsg!=(System.label.Sales_SuccessHostReassignment)){
                       tempWrapperList.add(new listWrapper(licenseList.name,returnMsg));
                     }     
                 }
                 else{
                    String errmsg='For License Tool Type as FIXED, you can select Host with FIXED License Type / For License Tool Type as FLOAT or N-A, you can select Host with FLOAT License Type & For License Tool Type as NEUTRAL, you can select Host with FIXED/FLOAT License Type.';
                     tempWrapperList.add(new listWrapper(licenseList.name,errmsg));
                 }
                 
                 
             }
             Database.SaveResult[] saveResultList = Database.update(licenseListToUpdate, false);
             for(Integer i=0;i<saveResultList.size();i++){
                if (!saveResultList.get(i).isSuccess()){ // DML operation failed
                    Database.Error error = saveResultList.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    system.debug('failedDML>>'+failedDML); 
                    String licName=licenseListToUpdate.get(i).name; 
                    tempWrapperList.add(new listWrapper(licName,failedDML));
                }
            }
         }
        return tempWrapperList;
    }
     public without sharing class listWrapper{
        @AuraEnabled public String lname;
        @AuraEnabled public String errmsg;
        public listWrapper(String lname,String errmsg){
            this.lname = lname;
            this.errmsg = errmsg;
        }
    }
}