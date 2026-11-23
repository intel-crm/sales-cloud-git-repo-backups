/****************************************************************************************************
Apex Class Name : Sales_LicenseGenIntegration_Service
Version         : 1.0 
Created Date    : 11/June/2021
Function        : This class is used to receive the generated license file
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Puja Ingale                     11/June/2021               Created
*/
@RestResource(urlMapping='/license/v1/*')
global without sharing class Sales_LicenseGenIntegration_Service {
    private static final string ORIGIN = 'Sales_SFDCLicenseManagement';
    private static final string SEVERITY = 'Critical';
    private static final string PROJECT = 'PSG Sales';
    @HttpPost
    global static Sales_Response_Wrapper postLicenses(LicenseFile_Info LicenseFile_Data) {
        Sales_Response_Wrapper response = new Sales_Response_Wrapper();	
        try{       
            String incomingResponse = JSON.serialize(LicenseFile_Data);
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'','Info','BatchId:'+LicenseFile_Data.BatchId,incomingResponse, '', '', '');
            if (LicenseFile_Data.Status=='Complete' && LicenseFile_Data.Message=='Success'){
                Sales_LicenseGenIntegration_Utility.updateLicenseFileDetails(LicenseFile_Data);
                response.Status = 'Success';
                response.Comment = 'License file processed successfully';
            }
            else if(LicenseFile_Data.Status=='Complete' && LicenseFile_Data.Message=='Failure'){
                response.Status = 'Failure';
                response.Comment = LicenseFile_Data.FileString;
            }
            else{
                response.Status = 'Failure';
                response.Comment = 'Input payload is empty';
            }
        }catch(Exception e){
            Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, 'Message', SEVERITY, e.getMessage(), e.getStackTraceString(), '', '', '',e);
            response.Status = 'Failure';
            response.Comment = e.getMessage();
        }
        return response;
    }
    global class LicenseFile_Info
    { 
        global String BatchId;     
        global String Status; 
        global String Message; 
        global String FileString; 
        global String FileType;         
    }
    global class Sales_Response_Wrapper
    { 
        global String Status; 
        global String Comment;
    }
}