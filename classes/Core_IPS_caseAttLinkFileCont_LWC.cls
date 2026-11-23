/***************************************************************************************************
Apex Class Name:  Core_IPS_caseAttLinkFileCont_LWC
Version     : 1.0 
Created Date: 7 March 2022
Function    : Controller class to Link Core IPS File to Case For LWC Portal
Author      : Sai Krishna  
****************************************************************************************************/
public with sharing class Core_IPS_caseAttLinkFileCont_LWC {
    public static List<uFile> fileList = new List<uFile>();
    public static List <Core_IPS_File_Assignment__c> CoreIPSFILEAssignLst = new List<Core_IPS_File_Assignment__c>();
    public static case caseObj;
    public static List<Core_IPS_Case_Attachments__c> ExistingCIPSCaseAttLst ;
    
    @AuraEnabled(cacheable = true)
    public static List<Core_IPS_File_Upload_Master__c> getFiles(String caseId){
        List<Core_IPS_File_Upload_Master__c> CIPSUpMasLst = new List<Core_IPS_File_Upload_Master__c>();   
        /// Mohan code fix for null getting in caseId Line no 18 - 76
        if(caseId != '' && caseId != null){          
            fileList = new List<uFile>();
            if (Schema.sObjectType.case.fields.Core_IPS_Supported_Product__c.isAccessible()) {
                // Hassan Khan creating a "List<Case> caseList" to fix (List has no rows for assignment to Sobject) Exception Handling issue.
                String strCaseQry = 'SELECT Id, Core_IPS_Supported_Product__c FROM case WHERE id =:caseId';
                List<Case> caseList = (List<Case>) Core_IPS_QueryService.queryRecords(
                    strCaseQry,
                    new Map<String, Object>{ 'caseId' => caseId }
                );
                if(!caseList.isEmpty()){
                    caseObj = caseList[0];
                }
            }
            if(caseObj!= null && caseObj.Core_IPS_Supported_Product__c != null){ // TWC745-9175 - Exceptional Handling - Phani Added Null check
                if (Schema.sObjectType.Core_IPS_File_Assignment__c.isAccessible()) {
                    // Venrublity Fix - Refering query to service class
                    String strFileAssignQry = 'SELECT id, Core_IPS_File_Upload_Master__c FROM Core_IPS_File_Assignment__c WHERE Core_Supported_Product__c =:supportedProductId';
                    CoreIPSFILEAssignLst = (List<Core_IPS_File_Assignment__c>) Core_IPS_QueryService.queryRecords(
                        strFileAssignQry,
                        new Map<String, Object>{ 'supportedProductId' => caseObj.Core_IPS_Supported_Product__c }
                    );
                }
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
                return null;
            }
            Set <String> CoreFileGUID_Existing = new Set<String>();
            if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_File_GUID__c.isAccessible()) {
                // Venrublity Fix - Refering query to service class
                String strExistingAttQry = 'SELECT Core_File_GUID__c FROM Core_IPS_Case_Attachments__c WHERE Core_Case__c=:caseId';
                ExistingCIPSCaseAttLst = (List<Core_IPS_Case_Attachments__c>) Core_IPS_QueryService.queryRecords(
                    strExistingAttQry,
                    new Map<String, Object>{ 'caseId' => caseId }
                );
            }
            for(Core_IPS_Case_Attachments__c CIPSFileAssignGUID : ExistingCIPSCaseAttLst){
                CoreFileGUID_Existing.add(CIPSFileAssignGUID.Core_File_GUID__c);
            }
            //Check File Upload Master for related records
            //FLS Read permission added --Suresh ---23/11/2022
            String strUpMasQry = 'SELECT id,Name, CreatedDate,Core_Category__c, Core_Effective_Date__c, Core_Expiration_Date__c, Core_File_Description__c, Core_File_GUID__c, Core_File_Name__c, ' +
                'Core_Upload_Status__c, Core_File_URL__c, Core_Last_Status_Updated_At__c, Core_Upload_UserId__c, Core_Upload_idsid__c, Core_File_Size__c, Core_FileUploadedBy__c,Core_FileUploadedBy__r.Name, ' +
                'Core_File_Hyperlink__c FROM Core_IPS_File_Upload_Master__c ' +
                'WHERE id IN :CIPSFAID and Core_Upload_Status__c = \'Complete\' and ' +
                'Core_Expiration_Date__c >:currentDateTime and ' +
                'Core_File_GUID__c not IN :CoreFileGUID_Existing order by lastmodifieddate';
            CIPSUpMasLst = (List<Core_IPS_File_Upload_Master__c>) Core_IPS_QueryService.queryRecords(
                strUpMasQry,
                new Map<String, Object>{
                    'CIPSFAID' => CIPSFAID,
                    'currentDateTime' => datetime.now(),
                    'CoreFileGUID_Existing' => CoreFileGUID_Existing
                }
            );
            //}
            //Check to see if entries found   
            if(CIPSUpMasLst.size() > 0){
                for(Core_IPS_File_Upload_Master__c  f: CIPSUpMasLst) {
                    String url = f.Core_File_Hyperlink__c;
                    url = url.replace('<a href="', '').replace('amp;','').replace('" target="Self">Download</a>', ' ');
                    f.Core_File_URL__c = url;
                    fileList.add(new ufile(f));
                }
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
            if (Schema.sObjectType.Core_IPS_File_Upload_Master__c.isAccessible()) {
                // Venrublity Fix - Refering query to service class
                String strSelRecQry = 'SELECT id, Core_Category__c, Core_Effective_Date__c, Core_Expiration_Date__c, Core_File_Description__c, Core_File_GUID__c, Core_File_Name__c, ' +
                    'Core_Upload_Status__c, Core_File_URL__c, Core_Last_Status_Updated_At__c, Core_Upload_UserId__c, Core_Upload_idsid__c, Core_File_Size__c, Core_FileUploadedBy__c, ' +
                    'Core_File_Hyperlink__c FROM Core_IPS_File_Upload_Master__c WHERE Id IN :selectedRecordIds';
                selectedRecords = (List<Core_IPS_File_Upload_Master__c>) Core_IPS_QueryService.queryRecords(
                    strSelRecQry,
                    new Map<String, Object>{ 'selectedRecordIds' => selectedRecordIds }
                );
            }
            if(caseId != null){
                for(Core_IPS_File_Upload_Master__c f : selectedRecords){
                    tempCase = new Core_IPS_Case_Attachments__c();               
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_Case__c.isCreateable())
                    {
                        tempCase.Core_Case__c = caseId;
                    }
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_IPS_File_Upload__c.isCreateable()){ 
                        tempCase.Core_IPS_File_Upload__c = f.id;
                    }
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_Type__c.isCreateable()){ 
                        tempCase.Core_Type__c = 'Link';
                    }
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_Category__c.isCreateable()){   
                        tempCase.Core_Category__c = f.Core_Category__c;
                    }     
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_File_Description__c.isCreateable()){     
                        tempCase.Core_File_Description__c = f.Core_File_Description__c;
                    }
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_File_GUID__c.isCreateable()){ 
                        tempCase.Core_File_GUID__c = f.Core_File_GUID__c;
                    }
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_File_Name__c.isCreateable()) 
                    {
                        tempCase.Core_File_Name__c = f.Core_File_Name__c;
                    }
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_File_URL__c.isCreateable()) 
                    {
                        tempCase.Core_File_URL__c = f.Core_File_URL__c;
                    }
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_Upload_Status__c.isCreateable()) 
                    {
                        tempCase.Core_Upload_Status__c = f.Core_Upload_Status__c;
                    } 
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_Last_Status_Updated_At__c.isCreateable()) 
                    {
                        tempCase.Core_Last_Status_Updated_At__c = f.Core_Last_Status_Updated_At__c;
                    } 
                    tempCase.Core_Upload_UserId__c = f.Core_Upload_UserId__c; 
                    tempCase.Core_Upload_idsid__c = f.Core_Upload_idsid__c;
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_File_Size__c.isCreateable()) 
                    {
                        tempCase.Core_File_Size__c = f.Core_File_Size__c;
                    }
                    if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_FileUploadedBy__c.isCreateable()) 
                    {
                        tempCase.Core_FileUploadedBy__c = f.Core_FileUploadedBy__c;
                    }
                    selectedCaseAttachments.add(tempCase);
                }
            }
            // Venrublity Fix - Refering DML to service class
            // database.insert(selectedCaseAttachments, false);
            Core_IPS_QueryService.insertRecords(selectedCaseAttachments);
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
    
}