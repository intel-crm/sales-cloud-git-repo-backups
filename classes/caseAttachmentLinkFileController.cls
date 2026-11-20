public with sharing class caseAttachmentLinkFileController {
    public static List<uFile> fileList = new List<uFile>();
    public static List <Core_IPS_File_Assignment__c> coreIPSFILEAssignLst = new List<Core_IPS_File_Assignment__c>();
    public static case caseObj;
    
    @AuraEnabled(cacheable = true)
    public static List<Core_IPS_File_Upload_Master__c> getFiles(String caseId){
        fileList = new List<uFile>();
        //FLS Check Added - Madhuri
        if(case.SObjectType.getDescribe().isAccessible()){
            caseObj = [Select Id, Core_IPS_Supported_Product__c from case where id =: caseId];
        }
		/*Start -- Tushar -- 16/06/2026 --- CRUD Added as part of vulnerability fix. */
        Schema.DescribeFieldResult fieldDescribe = 
            Case.Core_IPS_Supported_Product__c.getDescribe();
        if (!fieldDescribe.isAccessible()) {
            return null;
        }
        /*End -- Tushar -- 16/06/2026 --- added as part of vulnerability fix. */
        if(caseObj.Core_IPS_Supported_Product__c != null){
            //FLS Check Added - Madhuri
            if(Core_IPS_File_Assignment__c.SObjectType.getDescribe().isAccessible()){
                coreIPSFILEAssignLst = [SELECT id, Core_IPS_File_Upload_Master__c FROM Core_IPS_File_Assignment__c 
                                        WHERE Core_Supported_Product__c =: CaseObj.Core_IPS_Supported_Product__c];
            }
        }
        else {           
            return null;
        }
        Set <ID> cIPSFAID = new Set<ID>();
        if(coreIPSFILEAssignLst != null && coreIPSFILEAssignLst.size() > 0){
            for(Core_IPS_File_Assignment__c cIPSFA : coreIPSFILEAssignLst){
                if(cIPSFA.Core_IPS_File_Upload_Master__c != null){
                    cIPSFAID.add(cIPSFA.Core_IPS_File_Upload_Master__c);
                }
            }
        } else {
            //No Files found to link
            return null;
        }
        Set <String> coreFileGUID_Existing = new Set<String>();
        List<Core_IPS_Case_Attachments__c> existingCIPSCaseAttLst;
        //FLS Check Added - Madhuri
        if(Core_IPS_Case_Attachments__c.SObjectType.getDescribe().isAccessible()){
            existingCIPSCaseAttLst = [SELECT Core_File_GUID__c FROM Core_IPS_Case_Attachments__c WHERE Core_Case__c=:caseId];
        }
        
        for(Core_IPS_Case_Attachments__c cIPSFileAssignGUID : existingCIPSCaseAttLst){
            coreFileGUID_Existing.add(cIPSFileAssignGUID.Core_File_GUID__c);
        }
        //Check File Upload Master for related records
        List<Core_IPS_File_Upload_Master__c> CIPSUpMasLst = new List<Core_IPS_File_Upload_Master__c>(); 
        /* 11/07/2022 - Suresh - security vulnerability --*/
        if(Core_IPS_File_Upload_Master__c.SObjectType.getDescribe().isAccessible()){
            CIPSUpMasLst = [SELECT id,Name, CreatedDate,Core_Category__c, Core_Effective_Date__c, Core_Expiration_Date__c, Core_File_Description__c, Core_File_GUID__c, Core_File_Name__c, 
                            Core_Upload_Status__c, Core_File_URL__c, Core_Last_Status_Updated_At__c, Core_Upload_UserId__c, Core_Upload_idsid__c, Core_File_Size__c, Core_FileUploadedBy__c,Core_FileUploadedBy__r.Name, 
                            Core_File_Hyperlink__c FROM Core_IPS_File_Upload_Master__c
                            WHERE id IN :cIPSFAID and Core_Upload_Status__c = 'Complete' and 
                            Core_Expiration_Date__c >: datetime.now() and 
                            Core_File_GUID__c not IN :CoreFileGUID_Existing order by lastmodifieddate]; 
        }
        //Check to see if entries found   
        if(CIPSUpMasLst.size() > 0){
            // Catch Exception if the upload master is empty                 
            for(Core_IPS_File_Upload_Master__c  f: CIPSUpMasLst) {
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
            //FLS Check Added - Madhuri
            if(Core_IPS_File_Upload_Master__c.SObjectType.getDescribe().isAccessible()){
                selectedRecords = [SELECT id, Core_Category__c, Core_Effective_Date__c, Core_Expiration_Date__c, Core_File_Description__c, Core_File_GUID__c, Core_File_Name__c, 
                                   Core_Upload_Status__c, Core_File_URL__c, Core_Last_Status_Updated_At__c, Core_Upload_UserId__c, Core_Upload_idsid__c, Core_File_Size__c, Core_FileUploadedBy__c, 
                                   Core_File_Hyperlink__c FROM Core_IPS_File_Upload_Master__c WHERE Id IN : selectedRecordIds];
                
            }
            if(caseId != null){
                for(Core_IPS_File_Upload_Master__c f : selectedRecords){
                    
                    tempCase = new Core_IPS_Case_Attachments__c(); 
                    //FLS fix applied by T Nishitha on 17-10-2022
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
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_File_Description__c.isCreateable())  {
                        tempCase.Core_File_Description__c = f.Core_File_Description__c;
                    }
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_File_GUID__c.isCreateable()) {
                        tempCase.Core_File_GUID__c = f.Core_File_GUID__c;
                    }
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_File_Name__c.isCreateable()){
                        tempCase.Core_File_Name__c = f.Core_File_Name__c;
                    }
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_File_URL__c.isCreateable()) {
                        tempCase.Core_File_URL__c = f.Core_File_URL__c;
                    }
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_Upload_Status__c.isCreateable()){
                        tempCase.Core_Upload_Status__c = f.Core_Upload_Status__c;
                    }
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_Last_Status_Updated_At__c.isCreateable()) {
                        tempCase.Core_Last_Status_Updated_At__c = f.Core_Last_Status_Updated_At__c;
                    }
                    tempCase.Core_Upload_UserId__c = f.Core_Upload_UserId__c;
                    tempCase.Core_Upload_idsid__c = f.Core_Upload_idsid__c;
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_File_Size__c.isCreateable()) {
                        tempCase.Core_File_Size__c = f.Core_File_Size__c;
                    }
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_FileUploadedBy__c.isCreateable()) {
                        tempCase.Core_FileUploadedBy__c = f.Core_FileUploadedBy__c;
                    }
                    selectedCaseAttachments.add(tempCase);
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
    
    @AuraEnabled(cacheable=true)
    public static String showButtons(String CaseID){
        String recordtype;
        Case c = [Select Id, RecordType.Name From Case Where Id =: CaseID ];
        recordtype = c.RecordType.Name;
        return recordtype;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Case_Attachments__c> getattachments(String caseID, Integer limitSize, Integer offset , String fetchType ){        
        List<Core_IPS_Case_Attachments__c> cdoc = new List<Core_IPS_Case_Attachments__c>();
        String strqry;
        if(fetchType == 'Load Data' && offset != null)
        {
            strqry = 'SELECT Core_Case__c,Name,Core_Upload_idsid__c,Core_Case__r.Status,Core_FileUploadedBy__r.Name,Core_File_URL__c,Core_File_Hyperlink__c,CreatedDate, Core_File_Description__c, Core_File_Name__c, Core_File_Size__c, Core_Upload_Status__c,Core_IPS_Attachment_Visibility__c FROM Core_IPS_Case_Attachments__c where Core_Case__c =:caseID ORDER BY CreatedDate DESC   LIMIT :limitSize OFFSET: offset ';  
        }
        else if(fetchType == 'All Data'){
            strqry = 'SELECT Core_Case__c,Name,Core_Upload_idsid__c,Core_Case__r.Status,Core_FileUploadedBy__r.Name,Core_File_URL__c,Core_File_Hyperlink__c,CreatedDate, Core_File_Description__c, Core_File_Name__c, Core_File_Size__c, Core_Upload_Status__c,Core_IPS_Attachment_Visibility__c FROM Core_IPS_Case_Attachments__c where Core_Case__c =:caseID ORDER BY CreatedDate DESC ';  
        }        
        cdoc = Database.Query(strqry);
        for(Core_IPS_Case_Attachments__c att:cdoc ){
            if(att.Core_Upload_Status__c == 'Pending'){
                String url = att.Core_File_Hyperlink__c;
                
                url = url.replace('<a href="', '').replace('" target="_blank">Resume</a>', ' ').replace('amp;', '');
                
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
    
}