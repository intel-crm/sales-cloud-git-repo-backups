/****************************************************************************************************************************************
* Class Name  : Core_AccountPlanFiles 
* Version     : 1.0 
* Created Date: 12-06-2023
* Modification Log :
* Developer                     Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Hira (Accenture - Unicorn)    12-06-2023         Handler Class for Account Plan content files
*****************************************************************************************************************************************/
public class Core_AccountPlanFiles {
    /*
* Method name  : AccountPlanContentDocumentLink
* Description  : Updates the Count of Files on Account Plan on Insertion or Removal of files
* Return Type  : VOID
* Parameter    : List<ContentDocumentLink>,List<ContentDocumentLink>,Boolean
*/
    public static void AccountPlanContentDocumentLink(List<ContentDocumentLink> newCDLList,List<ContentDocumentLink> oldCDLList,Boolean isInsert){
        Set<Id> accountPlanIds = new Set<Id>();
        Set<Id> contentDocIds=new Set<Id>();
        List<Account_Plan__c> accplanListToUpdate=new List<Account_Plan__c>();
        List<ContentDocumentLink> contentLinks= new List<ContentDocumentLink>();
        
        Map<Id,List<ContentDocumentLink>> accountPlanMap=new Map<Id,List<ContentDocumentLink>>();
        
        //checking insert or delete operation
        if(isInsert){
            for(ContentDocumentLink link : newCDLList){
                if(link.LinkedEntityId.getSobjectType() ==Account_Plan__c.sObjectType){
                    accountPlanIds.add(link.LinkedEntityId);
                }
            }
        }else{
            for(ContentDocumentLink link : oldCDLList){
                //checking Account Plan sobject and getting triggered Account Plan Ids
                if(link.LinkedEntityId.getSobjectType() ==Account_Plan__c.sObjectType){
                    accountPlanIds.add(link.LinkedEntityId);
                }
            }     
        }
        
        for(Id accplanId:accountPlanIds){
            //getting all the files on Account Plan which are not Notes or Quip Template
            contentLinks =[Select ContentDocumentId from ContentDocumentLink where LinkedEntityId=:accplanId AND ContentDocument.FileType NOT IN ('SNOTE','QUIPTEMPLATE')];
            
            //counting and updating the number of files on Account Plan
            Account_Plan__c ap=new Account_Plan__c();
            ap.Id=accplanId;
            ap.Number_of_Attachments__c=contentLinks.size();
            accplanListToUpdate.add(ap);
        }
        if(!accplanListToUpdate.isEmpty()){
            update accplanListToUpdate;
        }
    }
    
    /*
* Method name  : AccountPlanContentDocument
* Description  : Updates the Count of Files on Account Plan on Deletion of Files
* Return Type  : VOID
* Parameter    : List<ContentDocumentLink>
*/
    public static void AccountPlanContentDocument(List<ContentDocument> ContentFiles){    
        List<ContentDocumentLink> contentdocumentlinks=new List<ContentDocumentLink>();
        
        for(ContentDocument cd : ContentFiles){
            contentdocumentlinks = [select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where ContentDocumentId =: cd.id ALL ROWS];
            AccountPlanContentDocumentLink(null,contentdocumentlinks,false);
        }
    }
}