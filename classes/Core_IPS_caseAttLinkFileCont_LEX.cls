/***************************************************************************************************
Apex Class Name:  Core_IPS_caseAttLinkFileCont_LEX
Version     : 1.0 
Created Date: 7 March 2022
Function    : Controller class to Link Core IPS File to Case For Internal LEX
Author      : Sai Krishna 
****************************************************************************************************/

public with sharing class Core_IPS_caseAttLinkFileCont_LEX {
    public static List<uFile> fileList = new List<uFile>();
    public static List <Core_IPS_File_Assignment__c> CoreIPSFILEAssignLst = new List<Core_IPS_File_Assignment__c>();
    public static case caseObj;
    
    @AuraEnabled(cacheable = true)
    public static List<Core_IPS_File_Upload_Master__c> getFiles(String caseId){
        fileList = new List<uFile>();
        if(case.SObjectType.getDescribe().isAccessible()){
            caseObj = [Select Id, Core_IPS_Supported_Product__c from case where id =: caseId];
        }
        if(caseObj.Core_IPS_Supported_Product__c != null && Core_IPS_File_Assignment__c.SObjectType.getDescribe().isAccessible()){
            CoreIPSFILEAssignLst = [SELECT id, Core_IPS_File_Upload_Master__c FROM Core_IPS_File_Assignment__c 
                                    WHERE Core_Supported_Product__c =: CaseObj.Core_IPS_Supported_Product__c];
        }
        else{
            
            
            return null;
        }
        Set <ID> CIPSFAID = new Set<ID>();
        if(CoreIPSFILEAssignLst != null && CoreIPSFILEAssignLst.size() > 0){
            for(Core_IPS_File_Assignment__c CIPSFA : CoreIPSFILEAssignLst){
                if(CIPSFA.Core_IPS_File_Upload_Master__c != null){
                    CIPSFAID.add(CIPSFA.Core_IPS_File_Upload_Master__c);
                }
            }
        } else {
            //No Files found to link
            
            return null;
        }
        Set <String> CoreFileGUID_Existing = new Set<String>();
        List<Core_IPS_Case_Attachments__c> ExistingCIPSCaseAttLst;
        if(Core_IPS_Case_Attachments__c.SObjectType.getDescribe().isAccessible()){
            ExistingCIPSCaseAttLst = [SELECT Core_File_GUID__c FROM Core_IPS_Case_Attachments__c WHERE Core_Case__c=:caseId];
        }
        for(Core_IPS_Case_Attachments__c CIPSFileAssignGUID : ExistingCIPSCaseAttLst){
            CoreFileGUID_Existing.add(CIPSFileAssignGUID.Core_File_GUID__c);
        }
        //Check File Upload Master for related records
        List<Core_IPS_File_Upload_Master__c> CIPSUpMasLst = new List<Core_IPS_File_Upload_Master__c>();   
        if(Core_IPS_File_Upload_Master__c.SObjectType.getDescribe().isAccessible()){
            CIPSUpMasLst = [SELECT id,Name, CreatedDate,Core_Category__c, Core_Effective_Date__c, Core_Expiration_Date__c, Core_File_Description__c, Core_File_GUID__c, Core_File_Name__c, 
                            Core_Upload_Status__c, Core_File_URL__c, Core_Last_Status_Updated_At__c, Core_Upload_UserId__c, Core_Upload_idsid__c, Core_File_Size__c, Core_FileUploadedBy__c,Core_FileUploadedBy__r.Name, 
                            Core_File_Hyperlink__c FROM Core_IPS_File_Upload_Master__c
                            WHERE id IN :CIPSFAID and Core_Upload_Status__c = 'Complete' and 
                            Core_Expiration_Date__c >: datetime.now() and 
                            Core_File_GUID__c not IN :CoreFileGUID_Existing order by lastmodifieddate];  
        }
        //Check to see if entries found   
        if(CIPSUpMasLst.size() > 0){
            
            
            for(Core_IPS_File_Upload_Master__c  f: CIPSUpMasLst) {
                String url = f.Core_File_Hyperlink__c;
                url = url.replace('<a href="', '').replace('amp;','').replace('" target="Self">Download</a>', ' ');
                
                f.Core_File_URL__c = url;
                fileList.add(new ufile(f));
            }
        }
        
        return CIPSUpMasLst;
    }
    
    @AuraEnabled
    public static void saveFile(list<Id> selectedRecordIds, String caseId){
        
        try{
            List<Core_IPS_Case_Attachments__c> selectedCaseAttachments = new  List<Core_IPS_Case_Attachments__c>();
            List<Core_IPS_File_Upload_Master__c> selectedRecords = new List<Core_IPS_File_Upload_Master__c>(); 
            Core_IPS_Case_Attachments__c tempCase = new Core_IPS_Case_Attachments__c();
            if(Core_IPS_File_Upload_Master__c.SObjectType.getDescribe().isAccessible()){
                selectedRecords = [SELECT id, Core_Category__c, Core_Effective_Date__c, Core_Expiration_Date__c, Core_File_Description__c, Core_File_GUID__c, Core_File_Name__c, 
                                   Core_Upload_Status__c, Core_File_URL__c, Core_Last_Status_Updated_At__c, Core_Upload_UserId__c, Core_Upload_idsid__c, Core_File_Size__c, Core_FileUploadedBy__c, 
                                   Core_File_Hyperlink__c FROM Core_IPS_File_Upload_Master__c WHERE Id IN : selectedRecordIds];
                
                if(caseId != null){
                    for(Core_IPS_File_Upload_Master__c f : selectedRecords){
                        tempCase = new Core_IPS_Case_Attachments__c(); 
                        //FLS Check added by- T Nishitha
                        if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_Case__c.isCreateable()) {
                            tempCase.Core_Case__c = caseId;
                        }
                        if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_IPS_File_Upload__c.isCreateable()) {
                            tempCase.Core_IPS_File_Upload__c = f.id;
                        }
                        if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_Type__c.isCreateable()) {
                            tempCase.Core_Type__c = 'Link';
                        }
                        if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_Category__c.isCreateable()) {
                            tempCase.Core_Category__c = f.Core_Category__c;
                        }
                        if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_File_Description__c.isCreateable()) {
                            tempCase.Core_File_Description__c = f.Core_File_Description__c;
                        }
                        if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_File_GUID__c.isCreateable()) {
                            tempCase.Core_File_GUID__c = f.Core_File_GUID__c;
                        }
                        if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_File_Name__c.isCreateable()) {
                            tempCase.Core_File_Name__c = f.Core_File_Name__c;
                        }
                        if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_File_URL__c.isCreateable()) {
                            tempCase.Core_File_URL__c = f.Core_File_URL__c;
                        }
                        if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_Upload_Status__c.isCreateable()) {
                            tempCase.Core_Upload_Status__c = f.Core_Upload_Status__c;
                        }
                        if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_Last_Status_Updated_At__c.isCreateable()) {
                            tempCase.Core_Last_Status_Updated_At__c = f.Core_Last_Status_Updated_At__c;
                        }
                        if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_Upload_UserId__c.isCreateable()) {
                            tempCase.Core_Upload_UserId__c = f.Core_Upload_UserId__c;
                        }
                        if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_Upload_idsid__c.isCreateable()) {
                            tempCase.Core_Upload_idsid__c = f.Core_Upload_idsid__c;
                        }
                        if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_File_Size__c.isCreateable()) {
                            tempCase.Core_File_Size__c = f.Core_File_Size__c;
                        }
                        if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_FileUploadedBy__c.isCreateable()) {
                            tempCase.Core_FileUploadedBy__c = f.Core_FileUploadedBy__c;
                        }
                        
                        /*  tempCase.Core_IPS_File_Upload__c = f.id;
tempCase.Core_Type__c = 'Link';
tempCase.Core_Category__c = f.Core_Category__c;
tempCase.Core_File_Description__c = f.Core_File_Description__c;
tempCase.Core_File_GUID__c = f.Core_File_GUID__c;
tempCase.Core_File_Name__c = f.Core_File_Name__c;
tempCase.Core_File_URL__c = f.Core_File_URL__c;
tempCase.Core_Upload_Status__c = f.Core_Upload_Status__c;
tempCase.Core_Last_Status_Updated_At__c = f.Core_Last_Status_Updated_At__c;
tempCase.Core_Upload_UserId__c = f.Core_Upload_UserId__c; 
tempCase.Core_Upload_idsid__c = f.Core_Upload_idsid__c;
tempCase.Core_File_Size__c = f.Core_File_Size__c;
tempCase.Core_FileUploadedBy__c = f.Core_FileUploadedBy__c;*/
                        selectedCaseAttachments.add(tempCase);
                    }
                }
            }
            database.insert(selectedCaseAttachments, false);        
            FileList=null; 
        }catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
        
    }
    
    public static string errorMessage(string errorCode){
        string defaultMessage ='Invalid Entry';
        if(Core_IPS_Error_Code__c.getinstance(errorCode)!=null){
            if(Core_IPS_Error_Code__c.getinstance(errorCode).Core_Error_Message__c!=null){
                defaultMessage = Core_IPS_Error_Code__c.getinstance(errorCode).Core_Error_Message__c; 
            }
        }
        return defaultMessage;
    }
    public class uFile {
        public Core_IPS_File_Upload_Master__c file {get; set;}
        public ufile(Core_IPS_File_Upload_Master__c f) 
        {
            file = f;
        }
    }
    
    @AuraEnabled
    public static String showButtons(String CaseID){
        String recordtype;
        Case c;
        if(Case.SObjectType.getDescribe().isAccessible()){
            c = [Select Id, RecordType.Name From Case Where Id =: CaseID ];
        }
        recordtype = c.RecordType.Name;
        return recordtype;
    }
    /* Start------ Tushar ---- Vanuability Changes added filter*/
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Case_Attachments__c> getattachments(String caseID, Integer limitSize, Integer offset , String fetchType ){        
        List<Core_IPS_Case_Attachments__c> cdoc = new List<Core_IPS_Case_Attachments__c>();
        List<String> allowedTiers = getVisibilityTiersForCurrentUser();
        String strqry;
        if(fetchType == 'Load Data' && offset != null)
        {
            strqry = 'SELECT Core_Case__c,Name,Core_Upload_idsid__c,Core_Case__r.Status,Core_FileUploadedBy__r.Name,Core_File_URL__c,Core_File_Hyperlink__c,CreatedDate, Core_File_Description__c, Core_File_Name__c, Core_File_Size__c, Core_Upload_Status__c,Core_IPS_Attachment_Visibility__c FROM Core_IPS_Case_Attachments__c WHERE Core_Case__c =:caseID AND Core_IPS_Attachment_Visibility__c IN :allowedTiers WITH USER_MODE ORDER BY CreatedDate DESC LIMIT :limitSize OFFSET :offset ';  
        }
        else if(fetchType == 'All Data'){
            strqry = 'SELECT Core_Case__c,Name,Core_Upload_idsid__c,Core_Case__r.Status,Core_FileUploadedBy__r.Name,Core_File_URL__c,Core_File_Hyperlink__c,CreatedDate, Core_File_Description__c, Core_File_Name__c, Core_File_Size__c, Core_Upload_Status__c,Core_IPS_Attachment_Visibility__c FROM Core_IPS_Case_Attachments__c WHERE Core_Case__c =:caseID AND Core_IPS_Attachment_Visibility__c IN :allowedTiers WITH USER_MODE ORDER BY CreatedDate DESC ';  
        }
        cdoc = Database.Query(strqry);
        for(Core_IPS_Case_Attachments__c att:cdoc ){
            if(att.Core_Upload_Status__c == 'Pending'){
                String url = att.Core_File_Hyperlink__c;
                url = url.replace('<a href="', '').replace('" target="Self">Resume</a>', ' ').replace('amp;', '');
                att.Core_File_URL__c = url;
            }
            if(att.Core_Upload_Status__c == 'Complete'){
                String url = att.Core_File_Hyperlink__c;
                url = url.replace('<a href="', '').replace('" target="Self">Download</a>', ' ').replace('amp;', '');
                att.Core_File_URL__c = url;
            }
            
        }
        return cdoc;
    }
    private static List<String> getVisibilityTiersForCurrentUser() {
        String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
        if (profileName.contains('Customer Community')) {
            return new List<String>{'Public to Customers'};
                } else if (profileName.contains('Partner-DFAE')) {
                    return new List<String>{'Public to Customers', 'Private to Partner'};
                        } else if (profileName.contains('Partner')) {
                            return new List<String>{'Public to Customers'};
                                }
        return new List<String>{'Public to Customers', 'Private to Partner', 'Private to Intel'};
            }
    /* End------ Tushar ---- Vanuability Changes added filter*/
    @AuraEnabled(cacheable=true)
    public static Case getCurrentCase(Id csId){
        case caseRecord = [SELECT Id, CaseNumber, Status, Core_Sub_Status__c, Core_Severity__c,
                           Core_Severity_Reason__c,Core_CaseType__c,Core_IPS_Legacy_IPS_ID__c,Core_IPS_Classification__c, 
                           Core_IPS_Case_Owner_Name__c,core_Account_Name__c, Core_Contact_Name__c,
                           Core_Customer_Reference_ID__c, Core_End_Customer__c, Subject,Description,Core_Issue_Description__c,
                           Core_IPS_Restricted_Secret_Content__c, Core_IPS_Knowledge_Base_Link__c,Core_IPS_Project_Case__c,
                           Core_IPS_Product_name__c,ProductId, Core_IPS_Project_Case__r.Name,Core_IPS_GEC_Flag__c,Core_Case_Issue_Sub_Category__c,
                           Core_External_Issue_Subcategory__c,Core_External_Issue_Category__c,Core_IPS_Premier_Support_Project_ID__c  FROM Case where id=:csId];
        
        if(caseRecord != null){
            return caseRecord;
        }
        return null;
    }
    
    
}