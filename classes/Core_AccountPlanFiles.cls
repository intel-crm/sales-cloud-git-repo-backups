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
        List<Account_Plan__c> accplanListToUpdate=new List<Account_Plan__c>();
        List<ContentDocumentLink> contentLinks= new List<ContentDocumentLink>();
        Map<Id,List<ContentDocumentLink>> mapAcctPlanContentDocumentLinks = new Map<Id,List<ContentDocumentLink>>();
        
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
        if (!accountPlanIds.isEmpty()) {
            //getting all the files on Account Plan which are not Notes or Quip Template
            List<ContentDocumentLink> listContentDocumentLinks = [Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN: accountPlanIds AND ContentDocument.FileType NOT IN ('SNOTE','QUIPTEMPLATE')];
            for (ContentDocumentLink cdl : listContentDocumentLinks) {
                if (mapAcctPlanContentDocumentLinks.containsKey(cdl.LinkedEntityId)) {
                    mapAcctPlanContentDocumentLinks.get(cdl.LinkedEntityId).add(cdl);
                }else {
                    mapAcctPlanContentDocumentLinks.put(cdl.LinkedEntityId, new List<ContentDocumentLink>{cdl});
                }
            }
            
            for(Id accplanId:accountPlanIds){
                //contentLinks =[Select ContentDocumentId from ContentDocumentLink where LinkedEntityId=:accplanId AND ContentDocument.FileType NOT IN ('SNOTE','QUIPTEMPLATE')];
                //counting and updating the number of files on Account Plan
                Account_Plan__c ap=new Account_Plan__c();
                ap.Id=accplanId;
                ap.Number_of_Attachments__c= !mapAcctPlanContentDocumentLinks.isEmpty() && mapAcctPlanContentDocumentLinks.containsKey(accplanId) ? mapAcctPlanContentDocumentLinks.get(accplanId).size() : 0; //contentLinks.size();
                accplanListToUpdate.add(ap);
            }
            
            if(!accplanListToUpdate.isEmpty()){
                update accplanListToUpdate;
            }
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
        Set<Id> setContentDocumentId = new Set<Id>();
        for(ContentDocument cd : ContentFiles){
            setContentDocumentId.add(cd.Id);
        }
        
        if(!setContentDocumentId.isEmpty()) {
            AccountPlanContentDocumentLink(Null, [select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where ContentDocumentId In: setContentDocumentId ALL ROWS], false);
        }
	        
        /*for(ContentDocument cd : ContentFiles){
            contentdocumentlinks = [select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where ContentDocumentId =: cd.id ALL ROWS];
            AccountPlanContentDocumentLink(null,contentdocumentlinks,false);
        }*/
    }
}