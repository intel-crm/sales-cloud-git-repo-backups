/**************************************************************************************
Apex Class Name : PSS_FileMigrationFromIOTGBatch
Version     : 1.0 
Created Date: 2nd July 2021
Description : Batch class to migrate files from IOTG to Marketplace and attach it to Records in MarketPlace
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* ONYX Team                 02/07/2021               Original Version
*************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest 
global class PSS_FileMigrationFromIOTGBatch {}/*implements Database.Batchable<sObject>,Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // added dummy syntax to override error
       return null;
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        // added dummy syntax to override error
    }

    global void finish(Database.BatchableContext bc) {
        // added dummy syntax to override error
    }
}*/
/*
    global List<ArdiraSurvey__Survey_Result__c> solutionSuccessList = new List<ArdiraSurvey__Survey_Result__c>();
    global List<ArdiraSurvey__Survey_Result__c> solutionFailureList = new List<ArdiraSurvey__Survey_Result__c>();
    global List<ContentDocumentLink> cdLinkSuccessList = new List<ContentDocumentLink>();
    global List<ContentDocumentLink> cdLinkFailureList = new List<ContentDocumentLink>();
    //Start Method
	global Database.QueryLocator start(Database.BatchableContext context) 
    {

        String sSourceSystem = 'IOTG';

        // Fetch all Partner Solution Records created from IOTG Source System 
        String queryPartnerSolutions = 'SELECT Id, PSS_Source_System__c, PSS_External_Id__c,PSS_File_Migration_Flag__c from ArdiraSurvey__Survey_Result__c WHERE PSS_File_Migration_Flag__c = false AND PSS_Source_System__c = \''+sSourceSystem+'\'';
        return Database.getQueryLocator(queryPartnerSolutions);

    }

    //Execute - Method
    global void execute(Database.BatchableContext context,List<ArdiraSurvey__Survey_Result__c> solutionList)
    {

        //Process Each Solution Record and attach its ContentDocuments to the QuestionResult Record Level
        try {

            List<String> sContentDocIds = new List<String>();
            Map<String,List<String>> sQuesLogicalIdToDocIdListMap = new Map<String,List<String>>();
            Map<String,List<String>> sQuestionResultIdToDocIdListMap = new Map<String,List<String>>();
            Set<String> sQuestionLogicalIdSet = new Set<String>();
            List<ContentDocumentLink> sContentDocLinksInsertList = new List<ContentDocumentLink>(); // List for INSERT DML Operation
            String solutionId = solutionList[0].Id; // Batch will be executed with Batch Size of 1

            // Fetch ContentDocumentIds linked to the Solution record
            for(ContentDocumentLink cdLink : [SELECT Id,ContentDocumentId,LinkedEntityId 
                                              FROM ContentDocumentLink 
                                              WHERE LinkedEntityId =: solutionId])
            {
                sContentDocIds.add(cdLink.ContentDocumentId);
            }

            // Fetch ContentVersionIds of Latest Version related to ContentDocumentIds and build sQuesLogicalIdToDocIdListMap Map
            if(sContentDocIds.size() > 0)
            {
                for(ContentVersion cdVersion : [SELECT Id,ContentDocumentId,Description
                                                FROM ContentVersion
                                                WHERE IsLatest = true AND ContentDocumentId IN: sContentDocIds])
                {
                    // Append ContentDocumentId to ContentDocList against the Question Logical Id in Map
                    List<String> sDocList = new List<String>();

                    // Build Map only if the ContentVersion Description contains the Question Logical Id
                    if(!String.isEmpty(cdVersion.Description))
                    {
                        if(sQuesLogicalIdToDocIdListMap.containsKey(cdVersion.Description))
                        {
                            sDocList = sQuesLogicalIdToDocIdListMap.get(cdVersion.Description);
                            sDocList.add(cdVersion.ContentDocumentId);
                            sQuesLogicalIdToDocIdListMap.put(cdVersion.Description , sDocList);
                        }
                        else // Build Map between QuestionLogicalId to List<ContentDocument> Ids that needs to be attached
                        {
                            sDocList.add(cdVersion.ContentDocumentId);
                            sQuesLogicalIdToDocIdListMap.put(cdVersion.Description , sDocList);
                        }
                    }

                } // FOR END

            } // IF END

            // Build a sQuestionResultIdToDocIdListMap Map of QuestionResultId to List<ContentDocument> Ids for further processing
            if(!sQuesLogicalIdToDocIdListMap.isEmpty() && sQuesLogicalIdToDocIdListMap.keySet().size() > 0)
            {
                sQuestionLogicalIdSet = sQuesLogicalIdToDocIdListMap.keySet();

                // Fetch and Loop Question Result records to build sQuestionResultIdToDocIdListMap Map
                for(ArdiraSurvey__Question_Result__c sQuesResult : [SELECT Id,ArdiraSurvey__Question__r.ArdiraSurvey__Logical_Id__c
                                                                    FROM ArdiraSurvey__Question_Result__c
                                                                    WHERE ArdiraSurvey__Survey_Result__r.Id =: solutionId
                                                                    AND ArdiraSurvey__Question__r.ArdiraSurvey__Logical_Id__c IN: sQuestionLogicalIdSet])
                {

                    String sQuestionLogicalId = sQuesResult.ArdiraSurvey__Question__r.ArdiraSurvey__Logical_Id__c;
                    List<String> sContentDocList = new List<String>();
                    if(sQuesLogicalIdToDocIdListMap.containsKey(sQuestionLogicalId))
                    {
                        sContentDocList = sQuesLogicalIdToDocIdListMap.get(sQuestionLogicalId);
                        sQuestionResultIdToDocIdListMap.put(sQuesResult.Id, sContentDocList);
                    }
                }

            }


            // Build a List of ContentDocumentLinks to be inserted in order to attach the ContentDocuments to QuestionResult record

            if(!sQuestionResultIdToDocIdListMap.isEmpty() && sQuestionResultIdToDocIdListMap.keySet().size() > 0)
            {

                for (String sQuestionResultId : sQuestionResultIdToDocIdListMap.keySet())
                {
                    List<String> sDocIdList = new List<String>();
                    sDocIdList = sQuestionResultIdToDocIdListMap.get(sQuestionResultId);

                    // Iterate each DocId in the sDocIdList and create ContentDocumentLink record
                    for (String sDocId : sDocIdList)
                    {
                        ContentDocumentLink sContentDocLink = new ContentDocumentLink();
                        sContentDocLink.LinkedEntityId = sQuestionResultId;
                        sContentDocLink.ContentDocumentId = sDocId;
                        sContentDocLink.ShareType = 'I';
                        sContentDocLink.Visibility = 'AllUsers'; 

                        sContentDocLinksInsertList.add(sContentDocLink); // Append List for INSERT DML Operation
                        
                    } // FOR LOOP DOCUMENT LIST END
                    
                }// FOR LOOP MAP END

            }

            // Insert sContentDocLinksInsertList to attach ContentDocuments to QuestionResult record
            try 
            {
                if(sContentDocLinksInsertList.size() > 0)
                {
                    insert sContentDocLinksInsertList;

                    // Appending the List<ContentDocumentLink> to the cdLinkSuccessList if INSERT DML didn't got Exception
                    cdLinkSuccessList.addAll(sContentDocLinksInsertList);
                }
                
            } 
            catch (Exception e) 
            {
                // Append List<ContentDocumentLink> to the cdLinkFailureList if the INSERT DML is not successfull
                cdLinkFailureList.addAll(sContentDocLinksInsertList);
                throw e; // Throw Exception to make the code flow to outer Catch Block and to append solutionFailureList                
            }



            // Append List of Solutions that has been successfully processed
            solutionSuccessList.addAll(solutionList);
            
        }
        catch (Exception Ex)
        {
            // Append List of Solutions that has been failed during Batch Processing Execute Method
            solutionFailureList.addAll(solutionList);            
            
        }

    }

    // Finish Method
    global void finish(Database.BatchableContext context)
    {  
        List<ArdiraSurvey__Survey_Result__c> solutionsToUpdate = new List<ArdiraSurvey__Survey_Result__c>();
        String solutionSuccessFileRow = '';
        String solutionSuccessCSVFile = 'Id\n';
        String solutionFailureFileRow = '';
        String solutionFailureCSVFile = 'Id\n';
        String cdLinkSuccessFileRow = '';
        String cdLinkSuccessCSVFile = 'Id,LinkedEntityId,ContentDocumentId,ShareType,Visibility\n';
        String cdLinkFailureFileRow = '';
        String cdLinkFailureCSVFile = 'LinkedEntityId,ContentDocumentId,ShareType,Visibility\n';

        for(ArdiraSurvey__Survey_Result__c solution : solutionSuccessList)
        {
            //ArdiraSurvey__Survey_Result__c updatedSolution = new ArdiraSurvey__Survey_Result__c();
            //updatedSolution.Id = solution.Id;
            solution.PSS_File_Migration_Flag__c = true; // Set this Flag to true so that Batch won't pick this record again
            solutionsToUpdate.add(solution); // Append Updated Solution to the solutionsToUpdate List
        }

        // Perform UPDATE DML Operation with the solutionsToUpdate List to update the PSS_File_Migration_Flag__c field as true
        Database.update(solutionsToUpdate, false); 

        // Prepare solutionSuccessList CSV Attachment for Email
        if(solutionSuccessList.size() > 0)
        {            
            for(ArdiraSurvey__Survey_Result__c solutionSuccess : solutionSuccessList)
            {
                solutionSuccessFileRow = '';
                solutionSuccessFileRow = solutionSuccess.Id;
                // CSV File value for solutionSuccessList
                solutionSuccessCSVFile = solutionSuccessCSVFile + solutionSuccessFileRow + '\n';
            }
        }

        // Prepare solutionFailureList CSV Attachment for Email
        if(solutionFailureList.size() > 0)
        {            
            for(ArdiraSurvey__Survey_Result__c solutionFailure : solutionFailureList)
            {
                solutionFailureFileRow = '';
                solutionFailureFileRow = solutionFailure.Id;
                // CSV File value for solutionFailureList
                solutionFailureCSVFile = solutionFailureCSVFile + solutionFailureFileRow + '\n';
            }
        }

        // Prepare cdLinkSuccessList CSV Attachment for Email
        if(cdLinkSuccessList.size() > 0)
        {
            for(ContentDocumentLink cdLinkSuccess : cdLinkSuccessList)
            {
                cdLinkSuccessFileRow = '';
                cdLinkSuccessFileRow = cdLinkSuccess.Id;
                cdLinkSuccessFileRow = cdLinkSuccessFileRow +','+ cdLinkSuccess.LinkedEntityId;
                cdLinkSuccessFileRow = cdLinkSuccessFileRow +','+ cdLinkSuccess.ContentDocumentId;
                cdLinkSuccessFileRow = cdLinkSuccessFileRow +','+ cdLinkSuccess.ShareType;
                cdLinkSuccessFileRow = cdLinkSuccessFileRow +','+ cdLinkSuccess.Visibility;

                cdLinkSuccessCSVFile = cdLinkSuccessCSVFile + cdLinkSuccessFileRow + '\n';

            }

        }

        // Prepare cdLinkFailureList CSV Attachment for Email
        if(cdLinkFailureList.size() > 0)
        {
            for(ContentDocumentLink cdLinkFailure : cdLinkFailureList)
            {
                cdLinkFailureFileRow = '';
                cdLinkFailureFileRow = cdLinkFailure.LinkedEntityId;
                cdLinkFailureFileRow = cdLinkFailureFileRow +','+ cdLinkFailure.ContentDocumentId;
                cdLinkFailureFileRow = cdLinkFailureFileRow +','+ cdLinkFailure.ShareType;
                cdLinkFailureFileRow = cdLinkFailureFileRow +','+ cdLinkFailure.Visibility;

                cdLinkFailureCSVFile = cdLinkFailureCSVFile + cdLinkFailureFileRow + '\n';

            }

        }

        // Prepare CSV Attachments for Email
        Messaging.EmailFileAttachment solutionSuccessCSVFileAttachment = new Messaging.EmailFileAttachment();
        Blob csvBlob1 = blob.valueOf(solutionSuccessCSVFile);
        solutionSuccessCSVFileAttachment.setFileName('solutionSuccessCSVFile.csv');
        solutionSuccessCSVFileAttachment.setBody(csvBlob1);

        Messaging.EmailFileAttachment solutionFailureCSVFileAttachment = new Messaging.EmailFileAttachment();
        Blob csvBlob2 = blob.valueOf(solutionFailureCSVFile);
        solutionFailureCSVFileAttachment.setFileName('solutionFailureCSVFile.csv');
        solutionFailureCSVFileAttachment.setBody(csvBlob2);

        Messaging.EmailFileAttachment cdLinkSuccessCSVFileAttachment = new Messaging.EmailFileAttachment();
        Blob csvBlob3 = blob.valueOf(cdLinkSuccessCSVFile);
        cdLinkSuccessCSVFileAttachment.setFileName('cdLinkSuccessCSVFile.csv');
        cdLinkSuccessCSVFileAttachment.setBody(csvBlob3);

        Messaging.EmailFileAttachment cdLinkFailureCSVFileAttachment = new Messaging.EmailFileAttachment();
        Blob csvBlob4 = blob.valueOf(cdLinkFailureCSVFile);
        cdLinkFailureCSVFileAttachment.setFileName('cdLinkFailureCSVFile.csv');
        cdLinkFailureCSVFileAttachment.setBody(csvBlob4);

        // Send Email regarding the Batch Execution Status
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{solutionSuccessCSVFileAttachment,solutionFailureCSVFileAttachment,cdLinkSuccessCSVFileAttachment,cdLinkFailureCSVFileAttachment});
        message.toAddresses = new String[] { 'laxmanax.lenka@intel.com','sivashankaranx.ezhilarasan@intel.com','siva.shakthi.velx.eswaran@intel.com','apoorva1x.pathak@intel.com','hariprakashx.narasanna@intel.com','veerax.bhadra.hanuma.pantham@intel.com' };
        message.subject = 'Batch Script MP Execution Status: Attaching files to Question Result Records for Migration';
        String emailBodyMessage = 'solutionSuccessList : ' + solutionSuccessList.size() + '\n solutionFailureList : ' + solutionFailureList.size() + '\n';
        emailBodyMessage = emailBodyMessage + 'cdLinkSuccessList : ' + cdLinkSuccessList.size() + '\n cdLinkFailureList : ' + cdLinkFailureList.size();
        message.plainTextBody = 'Batch Script MP Execution Status : \n \n'+ emailBodyMessage;

        //SEND EMAIL TO RECIPIENTS
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);


    }
}
*/