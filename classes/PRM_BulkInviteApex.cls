public with sharing class PRM_BulkInviteApex {
    public static boolean isLoading=false;
   public static String sanitizedSearchKey = String.escapeSingleQuotes(UserInfo.getUserId());
    public static User user = [select Id, username,Core_IPA_One_Partner_Id__c,Core_IPS_AccountId__c,Email from User where Id = :sanitizedSearchKey];//where Id =: currentUserId  
   
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPicklistValues() {
        List<Schema.PicklistEntry> entries = Account.BillingCountryCode.getDescribe().getPicklistValues();
        List<Map<String, String>> values = new List<Map<String, String>>();
        for (Schema.PicklistEntry entry : entries) {
            Map<String, String> valueMap = new Map<String, String>();
            valueMap.put('label', entry.getLabel());
            valueMap.put('value', entry.getValue());
            values.add(valueMap);
        }
        return values;
    }
    @AuraEnabled (cacheable=true)
    public static string getAccounId() {
     
      //  User user = [select Id, username,Core_IPA_One_Partner_Id__c,Core_IPS_AccountId__c,Email from User where Id = :sanitizedSearchKey];//where Id =: currentUserId  
        // List<User> userList=new List<User>();
        // userList.add(user);
        string accountId;
        if(user.Core_IPS_AccountId__c !=null){
                accountId=string.valueOf(user.Core_IPS_AccountId__c);
            }        
        
        return accountId;
    }

    @AuraEnabled 
    public static list<string> createBulkRecords(string accId,string rowData) {
    string result;
    List<bulkDataWrapper> ObjList = new List<bulkDataWrapper>();
    if(string.isNotBlank(rowData)){
        ObjList =(List<bulkDataWrapper>)System.JSON.deserialize(rowData,   List<bulkDataWrapper>.class);
        system.debug('ObjList-->'+ObjList);
    }
       
        list<PRM_Bulk_Data_Upload__c> bulkListToInsert=new list<PRM_Bulk_Data_Upload__c>();
       map<string,string> mapOfEmailToResult=new map<string,string>();
        for(bulkDataWrapper row:ObjList){
            PRM_Bulk_Data_Upload__c bulkNew=new PRM_Bulk_Data_Upload__c();
            bulkNew.PRM_AccountId__c=accId;
            bulkNew.PRM_First_Name__c=row.firstname;
            bulkNew.PRM_Last_Name__c=row.lastname;
            bulkNew.PRM_ContactEmail__c=row.ContactEmail.toLowercase();
            bulkNew.PRM_Mailing_Country__c=row.ContactCountry;
            bulkListToInsert.add(bulkNew);
        }
        list<string> resulLitst=new list<string>();
        string result1;
        map<string,list<string>> mapResult=new  map<string,list<string>> ();
       if(!bulkListToInsert.isempty()){

        list<Database.saveResult> saveLogBulkLst =  Database.insert(bulkListToInsert,false); 
       
        integer count=0;
       
        for (Database.SaveResult sr : saveLogBulkLst) {
           
            
            if (sr.isSuccess()) {
                result='Records inserted successfully';
                resulLitst.add(result);
               
            }
            else{
                result='Records not inserted, please contact support team';
                resulLitst.add(result);
            }
            count++;
           
            system.debug('sr-->'+sr);
           
       }
       
        system.debug('resulLitst-->'+resulLitst);
    }
   return resulLitst;
}
    public class bulkDataWrapper{
        @AuraEnabled
        public string ContactEmail{get;set;}
        @AuraEnabled
        public string firstname{get;set;}
        @AuraEnabled
        public string lastname{get;set;}
        @AuraEnabled
        public string ContactCountry{get;set;}
    }

   
    @AuraEnabled 
    public static string getstatus() {
        string userEmail=string.valueOf(user.email);
        list<string> statusList=new list<string>();
        string stautsBulk;
        integer countSuccess=0,countFail=0;
        datetime dtTime= Datetime.now().addMinutes(Integer.valueOf(system.label.PRM_getstatus_Time));// -8
        list<PRM_Bulk_Data_Upload__c>  bulkUploadList= [select id,PRM_Status__c,CreatedDate, PRM_ContactEmail__c,CreatedById, CreatedBy.Email,PRM_First_Name__c, PRM_Last_Name__c,PRM_Mailing_Country__c
        from PRM_Bulk_Data_Upload__c where (PRM_Status__c=:system.label.PRM_AsyncStatus or PRM_Status__c=:system.label.PRM_FailedLabel or  PRM_Status__c=:system.label.PRM_Status_New or PRM_Status__c=:system.label.PRM_Discarded) and CreatedDate >=:dtTime and  CreatedBy.Email=:userEmail];
        system.debug('bulkUploadList-->'+bulkUploadList);
        for(PRM_Bulk_Data_Upload__c b:bulkUploadList){
                if(b.PRM_Status__c==system.label.PRM_AsyncStatus){ countSuccess=countSuccess+1;
        }else if(b.PRM_Status__c==system.label.PRM_FailedLabel){ countFail=countFail+1;
        }else if(b.PRM_Status__c==system.label.PRM_Discarded){ countFail=countFail+1;
        }else if(b.PRM_Status__c==system.label.PRM_Status_New){ countFail=0; countSuccess=0;
        }

        }
        if((countSuccess>0 && countFail>0) 
        || (countSuccess==0 && countFail>0)){ isLoading=false; stautsBulk='Failed';
        }else if(countSuccess>0 && countFail==0){ isLoading=true; stautsBulk='Success';
        }
        else{
            isLoading=false;
            stautsBulk='Wait';
        }
        system.debug('stautsBulk--->'+stautsBulk);
       
        return stautsBulk;
    }

    @AuraEnabled
    public static string getUploadStatusInWaiting(){
        string userEmail=string.valueOf(user.email);
        string waitStatus; 
        datetime dtTime= Datetime.now().addMinutes(integer.valueof(system.label.PRM_getWaitingstatus_Time)); //-3
        try {
            list<PRM_Bulk_Data_Upload__c>  bulkUploadStatusCheckList= [select id,PRM_Status__c,CreatedDate, PRM_ContactEmail__c,CreatedById, CreatedBy.Email,PRM_First_Name__c, PRM_Last_Name__c,PRM_Mailing_Country__c
            from PRM_Bulk_Data_Upload__c where PRM_Status__c=:system.label.PRM_Status_New and  CreatedBy.Email=:userEmail and CreatedDate >=:dtTime];
            if(!bulkUploadStatusCheckList.isempty()){
                waitStatus='Wait';
            }else{
                //waitStatus='Processed';
                waitStatus= getstatus();
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return waitStatus;
    }
@AuraEnabled
public static string retryStatusOver(){
   // system.debug('retrycount-->'+retrycount);
    string userEmail=string.valueOf(user.email);
    datetime dtTime= Datetime.now().addMinutes(Integer.valueOf(system.label.PRM_getretryOver_Time)); //-10
    list<PRM_Bulk_Data_Upload__c> bulkUpdateLst=new list<PRM_Bulk_Data_Upload__c>();
    try {
    //    if(retrycount==true){
            List<AsyncApexJob> apexJobsList =   [select id, Status, ApexClass.name, CreatedBy.name from AsyncApexJob 
            where CreatedBy.email=:userEmail and CreatedDate>=:dtTime and ApexClass.name='PRM_BulkDataUpload_Batch' and Status IN ('Holding', 'Preparing', 'Processing', 'Queued')];

            if(!apexJobsList.isEmpty()){            
                for(AsyncApexJob asyncj:apexJobsList ){
                    System.abortJob(asyncj.id);
                }
               
            }
            
            string bulkRecStringFail,bulkRecStringForExcelFail='',statuss;
            list<PRM_Bulk_Data_Upload__c>  bulkUploadStatusCheckList= [select id,PRM_Status__c,CreatedDate, PRM_ContactEmail__c,CreatedById, CreatedBy.Email,PRM_First_Name__c, PRM_Last_Name__c,PRM_Mailing_Country__c
            from PRM_Bulk_Data_Upload__c where PRM_Status__c='New' and  CreatedBy.Email=:userEmail and CreatedDate >=:dtTime];
          
                if(!bulkUploadStatusCheckList.isempty()){
                    for(PRM_Bulk_Data_Upload__c bulkUpdate:bulkUploadStatusCheckList){
                        bulkUpdate.PRM_Status__c='Discarded'; statuss='records not processed. Please try again';
                        bulkRecStringFail=bulkUpdate.PRM_ContactEmail__c+','+bulkUpdate.PRM_Last_Name__c+','+bulkUpdate.PRM_First_Name__c+','+bulkUpdate.PRM_Mailing_Country__c+','+statuss+'\n';
                        bulkRecStringForExcelFail = bulkRecStringForExcelFail +bulkRecStringFail; bulkUpdateLst.add(bulkUpdate);
                    }
                }
                if(string.isNotBlank(bulkRecStringForExcelFail)){
                    System.debug('bulkRecStringForExcelFail-->'+bulkRecStringForExcelFail);
                    PRM_SendEmailToUsers.sendData('PRM_Bulk_Invite_template','',bulkRecStringForExcelFail,System.Label.PRM_Failure_Email_Bulk,system.label.PRM_Bulk_Email_Subject);
                }
                    
     //   }
        if(!bulkUpdateLst.isempty()){
            update bulkUpdateLst;
        }
        return system.label.PRM_Discarded;
    }
    catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}
   
    
}