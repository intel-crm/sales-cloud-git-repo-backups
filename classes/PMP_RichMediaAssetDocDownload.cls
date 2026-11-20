/*
 Author: Sai Thotakura
 Onyx Team
 Create Date: 13th-Dec-2021
 fetchFileFromExternalUrl - Downloads attachments as blob and saves it in a map corresponding to the record id
 createAttachment - uses the map above to save the blob as an attachment to the record.
 */
public with sharing class PMP_RichMediaAssetDocDownload{
    @future(callout = true)
    public static void fetchFileFromExternalUrl(String modified){

        List<PMP_Rich_Media_Asset_Stage__c> richmediaRecordslist = (List<PMP_Rich_Media_Asset_Stage__c>)JSON.deserialize(modified, List<PMP_Rich_Media_Asset_Stage__c>.class);
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        blob retFile = blob.valueOf('');
        ContentDocumentLink conDocLink = new ContentDocumentLink();
        ContentAsset casset = new ContentAsset();
        //the download url will be generated with the help of custom setting
        //String baseUrl = PMP_Utility.getValue('NetworkBuilderUrl');
        String completeUrl = richmediaRecordslist[0].PMP_Document_Download_Path_url__c;

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(completeUrl);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/pdf');
        req.setCompressed(true);
        req.setTimeout(120000);

        //Now Send HTTP Request
        if(!Test.isRunningTest()){
            try{
                HttpResponse res = h.send(req);
                retFile = res.getBodyAsBlob();
            } catch (Exception e){
                PMP_Utility.logError(e,'PMP_RichMediaAssetDocDownload_APICALLOUT');
            }
        }
        else
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/pdf');
            res.setBody('{"This is a test pdf"}');
            res.setStatusCode(200);
            retFile = res.getBodyAsBlob();
        }

        if (retFile != null && retFile.size() > 0){
            //Check if this is insert or update scenario
            if (Schema.sObjectType.ContentDocumentLink.isAccessible()){
                cdl = [SELECT ContentDocumentId, ContentDocument.CreatedDate, LinkedEntityId
                       FROM ContentDocumentLink
                       where LinkedEntityId = :richmediaRecordslist[0].Id];
            }

            if (cdl.size() > 0){
                  //Update Scenario
                ContentVersion conVer = new ContentVersion();
                if (Schema.sObjectType.ContentVersion.isAccessible()){
                conVer.ContentLocation = 'S';
                conVer.PathOnClient = 'application.pdf';
                conVer.Title = richmediaRecordslist[0].PMP_Document_Name_Nm__c;
                conVer.VersionData = retFile;
                conVer.IsAssetEnabled = true;
                conVer.IsMajorVersion = false;
                conVer.Description = richmediaRecordslist[0].PMP_Document_Id__c;
                conVer.ContentDocumentId = cdl[0].ContentDocumentId;
                }

                if (Schema.sObjectType.ContentVersion.isCreateable()){
                    insert conVer;
                }
            } else{
                  //Insert Scenario
                //create content version documents to be attached
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S';
                conVer.PathOnClient = 'application.pdf';
                conVer.Title = richmediaRecordslist[0].PMP_Document_Name_Nm__c;
                conVer.VersionData = retFile;
                conVer.IsAssetEnabled = true;
                conVer.IsMajorVersion = false;
                conVer.Description = richmediaRecordslist[0].PMP_Document_Id__c;

                if (Schema.sObjectType.ContentVersion.isCreateable()){
                    insert conVer;
                }

                //create the link between document and the asset record
                if (conVer != null){
                    // First get the Content Document Id from ContentVersion Object
                    Id conDoc = [SELECT ContentDocumentId
                                 FROM ContentVersion
                                 WHERE Id = :conVer.Id].ContentDocumentId;
                    conDocLink.LinkedEntityId = richmediaRecordslist[0].Id;
                    conDocLink.ContentDocumentId = conDoc;
                    conDocLink.shareType = 'V';
                    conDocLink.Visibility = 'AllUsers';

                    if(Schema.sObjectType.ContentAsset.isAccessible()){
                       casset = [Select Id,DeveloperName,IsVisibleByExternalUsers,Language,MasterLabel from ContentAsset Where ContentDocumentId =:conDoc ];
                    } 
                    casset.DeveloperName = 'rma'+'_'+conDoc;
                    casset.IsVisibleByExternalUsers = true;
                }

                if (Schema.sObjectType.ContentDocumentLink.isCreateable() && Schema.sObjectType.ContentDocumentLink.isUpdateable()){
                    upsert conDocLink;
                }
                
                if(Schema.sObjectType.ContentAsset.isUpdateable()){
                   update casset;
                }
            }
        } else {
            //System.debug('No Response file from the API Call');
        }
    }
}