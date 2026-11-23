/****************************************************************************************************************************************
* Class Name  : Core_MDF_DeleteFeedsAndFiles_Batch 
* Version     : 1.0 
* Created Date: 04-29-2020
* Modification Log :
* Developer                          Date                     Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Bikram Bebarta         04/29/2020               Created Core_MDF_DeleteFeedsAndFiles_Batch for deleting feeds and files
*****************************************************************************************************************************************/
public without sharing class Core_MDF_DeleteFeedsAndFiles_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public string objectName;
    public string errorMessage = '';
    public string successMessage = '';
    //public set<string> recordIds;
    public Organization currOrg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization limit 1];

    public Core_MDF_DeleteFeedsAndFiles_Batch(String objName){
        objectName= objName;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        string strQuery = 'SELECT id FROM '+objectName+ ' limit 5';
        //strQuery += ' WHERE id IN :recordIds ';
        //strQuery += ' WHERE id = \'001g000002IVQik\' ';
        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
        set<string> recordIdSet = new set<string>();
        if(currorg.issandbox){
            for(sobject s : scope){
                recordIdSet.add(s.id);
            }
            system.debug('recordIdSet---   '+recordIdSet);
            if(recordIdSet != null && !recordIdSet.isEmpty()){
                deleteFeedsAndFiles(recordIdSet);
            }
        }
    }
    
    public void deleteFeedsAndFiles(set<string> recordIdSet){
        list<Database.DeleteResult> deleteResultList = new list<Database.DeleteResult>();
        // Delete Files
        list<ContentDocumentLink> cdLinkList = [select Id, ContentDocumentid, LinkedEntityId 
                                                from ContentDocumentLink 
                                                where LinkedEntityId IN :recordIdSet];
        system.debug('cdLinkList---   '+cdLinkList);
        if(cdLinkList != null && !cdLinkList.isEmpty()){
            set<string> contentDocumentIdSet = new set<string>();
            for(ContentDocumentLink cdl : cdLinkList){
                contentDocumentIdSet.add(cdl.ContentDocumentid);
            }
            if(!contentDocumentIdSet.isEmpty()){
                list<ContentDocument> contentDocumentList = [select Id from ContentDocument where id IN :contentDocumentIdSet];
                system.debug('contentDocumentList---   '+contentDocumentList);
                if(contentDocumentList != null && !contentDocumentList.isEmpty()){
                    Database.DeleteResult[] drList_contentDoc = Database.delete(contentDocumentList, false);
                    if(drList_contentDoc != null && !drList_contentDoc.isEmpty()){
                        deleteResultList.addAll(drList_contentDoc);
                    }
                }
            }
        }
        
        // Delete Feeds
        list<FeedItem> feedItemList = [SELECT Body,Id FROM FeedItem WHERE ParentId IN :recordIdSet];
        system.debug('feedItemList---   '+feedItemList);
        if(feedItemList != null && !feedItemList.isEmpty()){
            Database.DeleteResult[] drList_feedItem = Database.delete(feedItemList, false);
            if(drList_feedItem != null && !drList_feedItem.isEmpty()){
                deleteResultList.addAll(drList_feedItem);
            }
        }
        
        // Delete claim/case review docs        
        if(objectName == 'PartnerFundClaim'){
            list<Core_MDF_Audit_Document__c> auditDocumentList =  [select Id from Core_MDF_Audit_Document__c where Core_MDF_Claim__c IN :recordIdSet];    
            system.debug('auditDocumentList---   '+auditDocumentList);
            if(auditDocumentList != null && !auditDocumentList.isEmpty()){
                Database.DeleteResult[] drList_claimAuditDocument = Database.delete(auditDocumentList, false);
                if(drList_claimAuditDocument != null && !drList_claimAuditDocument.isEmpty()){
                    deleteResultList.addAll(drList_claimAuditDocument);
                }
            }
        }
        if(objectName == 'Case'){
            list<Core_MDF_Audit_Document__c> auditDocumentList =  [select Id from Core_MDF_Audit_Document__c where Core_MDF_Audit__c IN :recordIdSet];    
            system.debug('auditDocumentList---   '+auditDocumentList);
            if(auditDocumentList != null && !auditDocumentList.isEmpty()){
                Database.DeleteResult[] drList_caseAuditDocument = Database.delete(auditDocumentList, false);
                if(drList_caseAuditDocument != null && !drList_caseAuditDocument.isEmpty()){
                    deleteResultList.addAll(drList_caseAuditDocument);
                }
            }
        }
        if(deleteResultList != null && !deleteResultList.isEmpty()){
            for(Database.DeleteResult dr : deleteResultList){
                if(!dr.isSuccess()){
                  //  system.debug('Successfully deleted record - ' + dr.getId());
                    
                    //successMessage +='<tr><td>'+dr.getId()+'</td>';
                    //successMessage += '<td>'+dr.isSuccess()+'</td>';
                    //successMessage += '</tr>';
                //}else{
                    errorMessage +='<tr><td>'+dr.getId()+'</td>';
                    for(Database.Error err : dr.getErrors()){
                        system.debug('Error--  '+err.getStatusCode() + ' -- ' + err.getMessage()+ ' -- ' + err.getFields());
                        errorMessage += '<td>'+err.getMessage()+'</td>';
                    }
                    errorMessage += '</tr>';
                }
            }
        }
    }

    public void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email 
                          FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        string[] toAddresses = new string[] {userinfo.getUserEmail()};
        mail.setToAddresses(toAddresses);
        mail.setSubject(currOrg.InstanceName + ' P2P Refresh Batch Delete Files, Feeds and Review Documents: ' + a.Status);
        //string messageObjName = '<div>Success:</div><br/>';
        //string messageBody = '<style>table, th, td {border: 1px solid black;border-collapse: collapse;}';
        string messageBody = 'Successfully deleted all the documents and feeds.';

        /*string successMsgTableBody = '';
        successMsgTableBody += '<table style="width:50%"><tr><th>Record Id</th><th>Success</th></tr>';
        successMsgTableBody += successMessage;
        successMsgTableBody += '</table>';*/
        
        string errorMsgTableBody = '';
        errorMsgTableBody += '<table style="width:50%"><tr><th>Record Id</th><th>Error</th></tr>';
        errorMsgTableBody += errorMessage;
        errorMsgTableBody += '</table>';
        
        string finalMsgBody = '';
        if(string.isNotBlank(messageBody) || string.isNotBlank(errorMessage)){
            finalMsgBody += messageBody;
        }
        /*if(string.isNotBlank(successMessage)){
            string tableHeader = '<div>Success:</div><br/>';
            finalMsgBody += tableHeader + successMsgTableBody;
        }*/
        if(string.isNotBlank(errorMessage)){
            string tableHeader = '<div>Errors:</div><br/>';
            finalMsgBody += errorMsgTableBody;
        }
 
        mail.setHtmlBody(finalMsgBody);
        
        list<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        system.debug('email results------  '+results);
    }
}