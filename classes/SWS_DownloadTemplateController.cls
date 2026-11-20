/****************************************************************************************************
Apex Class Name : SWS_DownloadTemplateController
Version         : 1.0 
Created Date    : 2024-05-29
Function        : to download the template for importing credit request records.
Test Class      : SWS_DownloadTemplateControllerTest
Modifications   :
*****************************************************************************************************/
public without sharing class SWS_DownloadTemplateController {
    @AuraEnabled(cacheable=true)
    public static String downloadTemplate(){
        String fileContent;
        StaticResource template;
        template = [SELECT Id, Body, Name FROM StaticResource WHERE Name ='SWS_Cloud_Credit_Import_Template' WITH SECURITY_ENFORCED];
        fileContent = EncodingUtil.base64Encode(template.Body);           
        return fileContent;
    }
}