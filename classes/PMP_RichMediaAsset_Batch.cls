/*
Author: Sai Thotakura
Onyx Team
Created Date: 13th-Dec-2021
Purpose: 
start: Batch job to fetch all rich media asset stage records where retrieved is false
execute: download files and save as attachments
finish: send email upon finish
*/
public without sharing class PMP_RichMediaAsset_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        query='SELECT Id, Name, PMP_Document_Download_Path_url__c, PMP_Updated_On_Dt__c, PMP_Added_On_Dt__c, PMP_Document_Path_Txt__c, PMP_Document_Name_Nm__c, PMP_Document_Description_Dsc__c, PMP_Partner_Name_Nm__c, PMP_Partner_MPID__c, PMP_Partner_ID__c, PMP_Document_Id__c, PMP_Document_Type_Txt__c, PMP_Is_Retrieved_Ind__c FROM PMP_Rich_Media_Asset_Stage__c Where '+ System.label.PMP_RichMediaAssetStage_BatchQuery;
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<PMP_Rich_Media_Asset_Stage__c> scope) {
        //Download the Documents and attach them to the Rich Media Asset Stage records.
        //Maximum scope can only be 10, since maximum cumulative timeout for callouts by a single Apex transaction is 120 seconds.
        //'A single Apex transaction can make a maximum of 10 callouts to an HTTP request or an API call.'
        Map<Id,String> docIdtoDownloadUrlMap = new Map<Id,String>();
        for (PMP_Rich_Media_Asset_Stage__c s : scope) {
			//Populate the Map and List
			if(s.PMP_Document_Download_Path_url__c!=null) {	
				docIdtoDownloadUrlMap.put(s.Id, s.PMP_Document_Download_Path_url__c);	
			}  
        }
		//calling the download utility class to download all the documents
		Map<Id,blob> documentsMap = PMP_RichMediaAssetDocDownload.fetchFileFromExternalUrl(docIdtoDownloadUrlMap);
		
		if(DocumentsMap!=null) {
			PMP_RichMediaAssetDocDownload.createAttachment(documentsMap);
		}
            
    }    
    public void finish(Database.BatchableContext bc) {
		//can be used to send an email after completion of job
       System.debug('The job is now finished');
    }    
}