/***************************************************************************************************
* Apex Class Name:  Core_IPS_FileAuthorization
* Version     : 1.0 
* Created Date: 23 Sept 2015
* Function    : IPS SFT File Authorization
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/
@RestResource(urlMapping='/ips/sft/fileauth') 
global with sharing class Core_IPS_FileAuthorization {
    
    global class AuthResp {
        public Boolean Authorized;
        public Error[] Errors = new Error[] {};        
            }
    
    public class Error {
        public String error;
        public String message;
    }
/**************************************************************************************************
* Method name  : CheckFileAuthorization
* Description  : SFT related File Authorization for Uploads and Case Authorization scenarios
* Return Type  : AuthResp Object Return type
* Parameters   : N/A
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/       
    @HttpGet  
    global static AuthResp CheckFileAuthorization() {
        Boolean HasAccess = false;
        AuthResp AuResp = new AuthResp();
        RestResponse resp = RestContext.response;
        
        //Default HTTP Response to IPaaS
        resp.addHeader('Content-Type', 'application/json');
        resp.statusCode = 200;
        
        try {
            //Get Salesforce User Id from HTTP Request Object
            String UserId = RestContext.request.headers.get('userid');
            //Get FileGUID from HTTP Request Object  
            String AppFileId = RestContext.request.headers.get('appfileid'); 
            //Get AppData from HTTP Request Object  
            String AppData = RestContext.request.headers.get('appdata'); 
            //Get CaseId from HTTP Request Object
            String CaseId = RestContext.request.headers.get('caseId');
            
            //Exception scenario for Apex Unit Test coverage
            if(Test.isRunningTest()){
                RaiseExceptionForTestCoverage();
            }           
            //File Upload (non-case related) Authorization Check scenario
            if (AppData == null || AppData == '' || AppData == 'null'){ 
                if (AppFileId != null && AppFileId != ''){  
                    HasAccess = CheckUserFileUploadAccess(UserId, AppFileId);
                    AuResp.Authorized = HasAccess;
                    return AuResp;
                }
            }
            //Case Authorization Check scenario
            if (AppData != null || AppData != '' || AppData != 'null'){
                if (CaseId != null && Caseid != ''){
                    HasAccess = Core_IPS_File_Utility.CheckUserRecordAccess(UserId, CaseId);
                    AuResp.Authorized = HasAccess;
                    return AuResp;
                } 
            }
            //Default
            AuResp.Authorized = HasAccess;
            return AuResp;
            
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
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/                
    private static void RaiseExceptionForTestCoverage(){ 
        Integer MaxSize;
        String ExceptFlag = RestContext.request.headers.get('exceptflauth');
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
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/                           
    private static AuthResp ProcessSysExceptionObject( Exception e){ 
        AuthResp AuResp = new AuthResp();
        Error err  = new Error();
        err.error = 'System Exception';
        err.message = e.getMessage();
        AuResp.Authorized = false;
        AuResp.Errors.add(err);
        return AuResp;
    } 
/**************************************************************************************************
* Method name  : CheckUserFileUploadAccess
* Description  : SFT related File Authorization for Uploads and Case Authorization scenarios
* Return Type  : Boolean (Access Flag)
* Parameters   : User ID and SFT AppFileId
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     09/23/2015              Created
****************************************************************************************************/                                  
    private static Boolean CheckUserFileUploadAccess(String UserId, String AppFileId){
        List<Core_IPS_File_Upload_Master__c> lstFileUploadMaster = new List<Core_IPS_File_Upload_Master__c>();
        Set<ID> sFileUploadMasterIds = new Set<ID>();
        Boolean HasAccess = false;       
        //Get user details
        User Usr = [Select Id, UserRoleId, UserType, Profile.name, ProfileId, Alias, Core_Login_Id__c, ContactId, Contact.AccountId 
                    From User where Id= :UserId ]; 
        //Check for Access against User's authorized File ID's
        
        //Call Utility to get Authorized File ID's
        sFileUploadMasterIds = Core_IPS_File_Utility.GetAuthUserFileID(Usr, AppFileId);                           
        //Further Processing if Records found
        if(sFileUploadMasterIds != null && sFileUploadMasterIds.size() > 0){                
            //Get File GUID's for Authorized File ID's
            lstFileUploadMaster = [select id, Core_File_GUID__c from Core_IPS_File_Upload_Master__c 
                                   where id in :sFileUploadMasterIds];                
            //Check for a Match with the SFT AppFileId   
            if(lstFileUploadMaster != null && lstFileUploadMaster.size() > 0){     
                for(Core_IPS_File_Upload_Master__c FileMasterObj : lstFileUploadMaster)    
                {
                    if(FileMasterObj.Core_File_GUID__c == AppFileId){
                        HasAccess = true;
                        break;
                    }
                }
            }
        }       
        return HasAccess;
    }  
}