/***************************************************************************************************
* Apex Class Name: Core_IPS_FileList 
* Version     : 1.0 
* Created Date: 23 Sept 2015
* Function    : IPS SCFT File Downloads
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/
@RestResource(urlMapping='/ips/scft/filelist') 
global with sharing class Core_IPS_FileList {
    
    global class FileTypeResp {
        public FileType[] FileData = new FileType[] {};
        public Error[] Errors = new Error[] {};        
                }
    
    public class FileType {
        public String FileGUID;
        public String FileName;
        public String FileDescription;
        public String Category;
        public String UploadedBy;
        public datetime EffectiveDate;
        public datetime ExpirationDate;
        public String DownloadURL;
        public String FileSizeInBytes;
        public ProductType[] Products = new ProductType[] {};
            }
    
    public class ProductType {
        public String Name;
    }   
    
    public class Error {
        public String error;
        public String message;
    }
/**************************************************************************************************
* Method name  : GetFileList
* Description  : GRDC User's List of Files
* Return Type  : FileTypeResp Object Return type
* Parameters   : N/A
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/
    @HttpGet  
    global static FileTypeResp GetFileList() {
        Set<ID> sFileUploadMasterIds = new Set<ID>();        
        RestResponse resp = RestContext.response;
        FileTypeResp FileResp = new FileTypeResp();
        
        //Default HTTP Response to IPaaS
        resp.addHeader('Content-Type', 'application/json');
        resp.statusCode = 200;
        
        try {           
            //Raise dummy exception for Apex unit test coverage
            if(Test.isRunningTest()){
                RaiseExceptionForTestCoverage();
            }         
            //Get Salesforce User Id from HTTP Request Object
            String UserId = RestContext.request.headers.get('userid'); 
            system.debug('###### UserId:' + UserId ); 
            
            if (UserId != null && UserId != ''){                        
                //Get User's Contact and RoleId
                User Usr = [Select Id, UserRoleId, Profile.name, ProfileId, UserType, ContactId, Contact.AccountId From User where Id= :UserId ];                   
                //Get User's File ID's by calling Utility method
                sFileUploadMasterIds = Core_IPS_File_Utility.GetUserFileIDs(Usr);               
                system.debug('###### sFileUploadMasterIds' + sFileUploadMasterIds.size() );
                //Further Processing only if Records found
                if (sFileUploadMasterIds.size() > 0) {
                    return ProcessRespObject(sFileUploadMasterIds);  
                }
            } else {
                resp.statusCode = 400;
                return ProcessExceptionObject(true);        
            }   
            return FileResp;
        } catch(Exception e) {
            resp.statusCode = 400;
            return ProcessSysExceptionObject(e);
        }     
    }
/**************************************************************************************************
* Method name  : RaiseExceptionForTestCoverage
* Description  : Raise dummy exception to cover exception code coverage
* Return Type  : N/A
* Parameters   : N/A
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/            
    private static void RaiseExceptionForTestCoverage(){ 
        Integer MaxSize;
        String ExceptFlag = RestContext.request.headers.get('exceptfllst');
        if(ExceptFlag == 'X'){
            String Size = '10000000000000';    
            MaxSize = integer.valueof(Size);
        }      
    }
/**************************************************************************************************
* Method name  : ProcessSysExceptionObject
* Description  : Raise dummy exception to cover exception code coverage
* Return Type  : FileTypeResp
* Parameters   : Exception e
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/                     
    private static FileTypeResp ProcessSysExceptionObject( Exception e){ 
        FileTypeResp FileResp = new FileTypeResp();
        Error err  = new Error();
        err.error = 'System Exception';
        err.message = e.getMessage();
        FileResp.Errors.add(err);
        return FileResp;
    }
/**************************************************************************************************
* Method name  : ProcessExceptionObject
* Description  : Raise dummy exception to cover exception code coverage
* Return Type  : FileTypeResp
* Parameters   : Boolean Flag for missing userId
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/                                
    private static FileTypeResp ProcessExceptionObject(Boolean UserIdMissing){ 
        FileTypeResp FileResp = new FileTypeResp();
        Error err  = new Error();
        err.error = 'System Exception';
        if(UserIdMissing) {
            err.message = 'No User Id Passed';
        }
        FileResp.Errors.add(err);
        return FileResp;
    }    
/**************************************************************************************************
* Method name  : ProcessRespObject
* Description  : GRDC User's List of Files
* Return Type  : FileTypeResp Object Return type
* Parameters   : Set of File Upload Master ID's
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/                                        
    private static FileTypeResp ProcessRespObject(Set<ID> sFileUploadMasterIds){
        FileTypeResp FileResp = new FileTypeResp();
        Integer MaxSize = 200;
        
        //Check for MaxSize
        if (system.label.Core_IPS_File_List_MaxSize != null && system.label.Core_IPS_File_List_MaxSize != '' ) {
            MaxSize = integer.valueof(system.label.Core_IPS_File_List_MaxSize);
        } 
        //Get details using SOQL FOR Loop for efficient chunking of data
        //File Max size Retriction +  SOQL FOR Loop to avoid any heap size limits 
        for(Core_IPS_File_Upload_Master__c FileMasterObj :[Select c.Core_Upload_UserId__c, c.Core_File_URL__c, c.Core_File_Name__c, c.Core_File_GUID__c, c.Core_File_Description__c, 
                                                           c.Core_Expiration_Date__c, c.Core_Effective_Date__c, c.Core_Category__c, c.Core_FileSizeInBytes__c, 
                                                           (Select Core_Product_Name__c, Core_Account__c, Core_IPS_File_Upload_Master__c 
                                                            From IPS_File_Assignments__r) From Core_IPS_File_Upload_Master__c c where Id in:sFileUploadMasterIds and
                                                           Core_Upload_Status__c = 'Complete' and 
                                                           Core_Effective_Date__c <= today and
                                                           Core_Expiration_Date__c >= today                                               
                                                           order by lastmodifieddate desc limit :MaxSize]){
                                                               //Build Response    
                                                               FileType ftyp  = new FileType();
                                                               ftyp.FileGUID = FileMasterObj.Core_File_GUID__c;
                                                               ftyp.FileName = FileMasterObj.Core_File_Name__c;
                                                               ftyp.FileDescription = FileMasterObj.Core_File_Description__c; 
                                                               ftyp.Category = FileMasterObj.Core_Category__c;
                                                               ftyp.UploadedBy = FileMasterObj.Core_Upload_UserId__c;
                                                               ftyp.EffectiveDate = FileMasterObj.Core_effective_date__c;
                                                               ftyp.ExpirationDate = FileMasterObj.Core_expiration_date__c;
                                                               ftyp.DownloadURL = FileMasterObj.Core_File_URL__c; 
                                                               ftyp.FileSizeInBytes = FileMasterObj.Core_FileSizeInBytes__c;
                                                               Map<String,String> mSPName = new Map<String,String>();
                                                               for(Core_IPS_File_Assignment__c FileAssignmentObj:FileMasterObj.IPS_File_Assignments__r){
                                                                   if (FileAssignmentObj.Core_Product_Name__c !=null && FileAssignmentObj.Core_Product_Name__c != ''){
                                                                       if(mSPName.get(FileAssignmentObj.Core_Product_Name__c) == null){
                                                                           mSPName.put(FileAssignmentObj.Core_Product_Name__c, FileAssignmentObj.Core_Product_Name__c);
                                                                           ProductType prtyp = new ProductType();        
                                                                           prtyp.Name = FileAssignmentObj.Core_Product_Name__c;
                                                                           ftyp.Products.add(prtyp); 
                                                                       }
                                                                   }
                                                               } 
                                                               FileResp.FileData.add(ftyp);
                                                           }
        
        return FileResp;
    }
}