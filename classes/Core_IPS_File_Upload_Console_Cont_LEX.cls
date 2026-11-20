/***************************************************************************************************
Apex Class Name:  Core_IPS_File_Upload_Console_Cont_LEX
Version     : 1.0 
Created Date: 11 April 2022
Function    : Controller class for Assigning SP & Account to File Assignmnet object (Used for Files uploaded from IPS File Upload Console)
Author      : Sai Krishna  
****************************************************************************************************/

public with sharing class Core_IPS_File_Upload_Console_Cont_LEX {
    
    
    
    public static List<String> sprodIds = new List<String>();
	
    @AuraEnabled(cacheable = true)
    public static String getFileUploadConsoleUrl(){
        String Url = System.Label.Core_IPS_File_SCFT_URL+'&console=true';
        return Url;
    }
    
    @AuraEnabled(cacheable = true)
    public static String checkStatus(String fileuploadId){
        Core_IPS_File_Upload_Master__c fup;
        if(Core_IPS_File_Upload_Master__c.SObjectType.getDescribe().isAccessible()){
        fup = [Select Id, Name, Core_Expiration_Date__c,Core_Upload_Status__c From Core_IPS_File_Upload_Master__c Where Id =: fileuploadId  ];
        }
            //Integer curdt = System.now().format();
        if(fup.Core_Expiration_Date__c < System.now()){
            return 'dateexpired';
        }
        else if(fup.Core_Upload_Status__c != 'Complete'){
            return 'statusIncomplete';
        }
        return 'true';
    }
    @AuraEnabled
    public static List<Core_IPS_File_Upload_Master__C> getUploadedFiles(){
        List<Core_IPS_File_Upload_Master__C> filesList = new List<Core_IPS_File_Upload_Master__C>();
        String userName = getCurrentLoggedinUserName();
        if(Core_IPS_File_Upload_Master__C.SObjectType.getDescribe().isQueryable()){
             filesList = [Select Id, Name, CreatedDate,Core_Upload_Status__c, Core_File_Description__c,Core_File_Name__c ,Core_File_Size__c ,Core_File_URL__c,Core_File_Hyperlink__c, Core_FileUploadedBy__c,Core_FileUploadedBy__r.Name From Core_IPS_File_Upload_Master__C Where  Core_FileUploadedBy__r.Name =: userName  ORDER BY CreatedDate DESC ];
        }
        
        if(filesList.size() > 0){
            for(Core_IPS_File_Upload_Master__C fls : filesList){
                if(fls.Core_Upload_Status__c == 'Complete'){
                    String url = fls.Core_File_Hyperlink__c;
                	url = url.replace('<a href="', '').replace('" target="Self">Download</a>', ' ').replace('amp;','');
                	fls.Core_File_URL__c = url;
                }
                else{
                    String url = fls.Core_File_Hyperlink__c;
                	url = url.replace('<a href="', '').replace('" target="Self">Resume</a>', ' ').replace('amp;','');
                	fls.Core_File_URL__c = url;
                }
            	
        	}
        }
        return filesList;
    }
    @AuraEnabled 
    public static String getCurrentLoggedinUserName(){
        User us = [Select Id, Name From User Where Id =:UserInfo.getUserId() ];
        return us.Name;
    }
    
    
    @AuraEnabled
    public static String saveRecords(List<Core_IPS_File_Assignment__c> prodIds, String upldId){
         List<Core_IPS_File_Assignment__c> existingRecords = new  List<Core_IPS_File_Assignment__c>();
        if(Core_IPS_File_Assignment__c.SobjectType.getDescribe().isQueryable()){
            existingRecords = [Select Id, Core_Account__c, Core_Supported_Product__c,Core_IPS_File_Upload_Master__c from Core_IPS_File_Assignment__c where Core_IPS_File_Upload_Master__c =: upldId ];
        }
         
        for(Integer i =0;i<existingRecords.size();i++){
            if( existingRecords[i].Core_Account__c != null){
                sprodIds.add(existingRecords[i].Core_Supported_Product__c +' '+ existingRecords[i].Core_Account__c);  
            }
            else{
                sprodIds.add(existingRecords[i].Core_Supported_Product__c +' '+ 'null');  
            }    
        }
        List<Core_IPS_File_Assignment__c> iPDFAssLst = new List<Core_IPS_File_Assignment__c>();
        if(prodIds.size()>0){
            for(Integer i=0; i < prodIds.size(); i++){
                if(sprodIds.contains(prodIds[i].Core_Supported_Product__c +' '+prodIds[i].Core_Account__c )){
                    Integer rowno = i+1;
                    return 'Row No '+rowno+' Already associated to File';
                }
            }for(Integer i=0; i < prodIds.size(); i++){
                    Core_IPS_File_Assignment__c fps = new Core_IPS_File_Assignment__c();
                    if(prodIds[i].Core_Account__c != null){
                        fps.Core_Account__c = prodIds[i].Core_Account__c;
                    }
                    if (Schema.sObjectType.Core_IPS_File_Assignment__c.fields.Core_IPS_File_Upload_Master__c.isCreateable()) { // Fls Create fix applied - Gangadhar - 07/09/2022
            			fps.Core_IPS_File_Upload_Master__c = upldId;
                    }
            		fps.Core_Supported_Product__c = prodIds[i].Core_Supported_Product__c;
            		iPDFAssLst.add(fps);
                
        	}
            try{
                insert iPDFAssLst;
            }
            catch(Exception ex){
                throw new AuraHandledException(ex.getMessage());
            }
        	
        }
         return 'true';
    }
    // Method to fetch lookup search result   
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {    
        List < sObject > returnList = new List < sObject > ();
        string sQuery;
        string sWildCardText = '%' + searchKey + '%';
        String sObjApiName = String.escapeSingleQuotes(sObjectApiName);
        if(sObjApiName == 'Core_IPS_Supported_Product__c'){
            sQuery = 'Select Id,Name,Core_Supported_Product_Name__c From ' + sObjApiName + ' Where Name Like : sWildCardText LIMIT 5';
        }
        else{
            sQuery = 'Select Id,Name From ' + sObjApiName + ' Where Name Like : sWildCardText LIMIT 5';
        }
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
        string sRecId = recordId;    
        String sObjApiName = String.escapeSingleQuotes(sObjectApiName);
        string sQuery = 'Select Id,Name From ' + sObjApiName + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
}