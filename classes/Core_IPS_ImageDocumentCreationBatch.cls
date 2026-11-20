/**
 * @description       : 
 * @author            : Prem Ranjan
 * @group             : 
 * @last modified on  : 09-02-2020
 * @last modified by  : Prem Ranjan
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   09-02-2020   Prem Ranjan   Initial Version
**/
public without sharing class Core_IPS_ImageDocumentCreationBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
     
    public final String Query;
    public Core_IPS_ImageDocumentCreationBatch(String queryString){
        Query=queryString;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        List<Document> documentList = new List<Document>();
        if(scope!=null && scope.size()>0 && scope[0].Id.getSobjectTYpe()==Case.SobjectType){
            documentList = getBase64CSURLImgConvert(scope);
        }
        if(scope!=null && scope.size()>0 && scope[0].Id.getSobjectTYpe()==Core_IPS_Case_Comments__c.SobjectType){
            documentList = getBase64CSCURLImgConvert(scope);
        }	
        
        if(documentList.size()>0){
            database.insert(documentList, false);
        }
    }
    
    public void finish(Database.BatchableContext bc){
    }
    public static List<Document> getBase64CSURLImgConvert(List<Case> queriedcaseList){
        
        String richTextAreaString=null;
        List<Document> docList= new List<Document>();
        
        for(Case caseObj: queriedcaseList){
            richTextAreaString = caseObj.Core_Issue_Description__c;
            if(String.isNotBlank(richTextAreaString)){
                docList.addAll(getBase64URLDocument(caseObj.Id,caseObj.casenumber,richTextAreaString));
            }
        }
        return docList;
    }
    public static List<Document> getBase64CSCURLImgConvert(List<Core_IPS_Case_Comments__c> queriedcaseList){
        //SELECT Id, Name, Core_IPS_Rich_Comment__c FROM Core_IPS_Case_Comments__c
        String richTextAreaString=null;
        List<Document> docList= new List<Document>();
        
        for(Core_IPS_Case_Comments__c caseCommObj: queriedcaseList){
            richTextAreaString = caseCommObj.Core_IPS_Rich_Comment__c;
            if(String.isNotBlank(richTextAreaString)){
               docList.addAll(getBase64URLDocument(caseCommObj.Id,caseCommObj.Name,richTextAreaString));
            }
           
        }
        return docList;
    }
    public static List<Document> getBase64URLDocument(String recordId, String recordName, String richTextAreaString ){
        List<Document> docList= new List<Document>();
        List<String> allimgString = richTextAreaString.split('<img ');
        For(String str: allimgString ){
            String s2 = str.substringBetween('src="','"');
            If(!String.IsBlank(s2) && s2.startsWith('http') && !s2.endsWithIgnoreCase('.jpg') ){
                String s3=s2.replaceAll('amp;','');
                try{
                    PageReference pageRef = new PageReference(s3);
                    String strFolderId = Label.Core_IPS_MaxLinear_FolderId;
                    Document doc = new Document();
                    doc.Type = 'jpg';
                    doc.Name = recordId+'_'+recordName+'_RichTextId_'+s3.right(15);
                    doc.Description =s2;
                    doc.FolderId = strFolderId;
                    if(Test.isRunningTest()){
                        doc.Body = blob.valueOf('Unit.Test');
                    }else{
                        doc.Body = pageRef.getContent();
                    }
                    docList.add(doc);
                }catch(Exception e){}
            }
        }
        return docList;
    }
    public static void deleteMaxlinearDocument(){
        List<Document> documentList= [select Id, FolderId, Name from document where id=:Label.Core_IPS_MaxLinear_FolderId];
        Delete documentList;
         if(!Test.isRunningTest()){
             Database.emptyRecycleBin(documentList);
         }
    }
}