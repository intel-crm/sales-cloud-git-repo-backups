/**************************************************************************************
Apex Class Name : PSS_NotesOnSolution
Version     : 1.0 
Created Date: 26th July, 2021
Description : to display RelatedList of Notes on Solution 
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Hanuma Pantham                  19/08/2021               Original Version
*************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
public class PSS_NotesOnSolution {
    
    // public static void getNotesOfSolution(String recordId){
    //     List<ArdiraSurvey__Survey_Result__c> surveyResult = new List<ArdiraSurvey__Survey_Result__c>();
    //     Set<Id> ContentDocumentId = new Set<Id>();
    //     List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
    //     List<ContentNote> notesList = new List<ContentNote>();
    //     if(!String.isBlank(recordId)){
    //         for(ContentDocumentLink docs : [Select Id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId =: recordId]){
    //             contentDocumentList.add(docs);
    //             ContentDocumentId.add(docs.ContentDocumentId);
    //             System.debug('doc list :'+contentDocumentList);
    //         }
    //         for(ContentNote note: [select id,Content, TextPreview, Title, FileType from ContentNote where id in : ContentDocumentId]){
    //             notesList.add(note);
    //             System.debug('NotesList :'+notesList);
    //         }
    //     }
    // }
}