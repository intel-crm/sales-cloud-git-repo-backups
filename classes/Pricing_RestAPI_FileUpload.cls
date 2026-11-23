/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_FileUpload 
* Version     : 2.0 
* Created Date: 26 APR 2023
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         04/26/2022              Rest API to upload file to quotes

Sample API call:- /services/apexrest/v2.0/quoterequest/uploadFile
The above call Uploads File to Notes And Attachment Section on Quote Record Page
*****************************************************************************************************************************************/

@RestResource(urlMapping='/*/quoterequest/uploadfile')
global without sharing class Pricing_RestAPI_FileUpload {
    public static Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Pricing_RestAPI_FileUpload.class.getName();
    
    @HttpPost
    global static Pricing_RestAPI_Response doPost() {
        RestRequest req = RestContext.request;
        processRequest(req.requestBody.toString());
        return response;
    }
    
    /**
* @description method to process the request and upload document creating chatter post
* @author Subhanku | 05-02-2023 
* @param String reqBody 
**/
    public static void processRequest(String reqBody){ 
        try {
            Id networkId = [SELECT id from Network where Name = 'Tenders' limit 1].Id;// getting community id
            UploadFile uploadFile = (UploadFile) JSON.deserialize(reqBody, UploadFile.class);
            Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg quoteErrors = new Pricing_RestAPI_QuotesUtilityV2.QuoteErrorMsg();
            Pricing_RestAPI_QuotesUtilityV2 quoteUtility = new Pricing_RestAPI_QuotesUtilityV2();
            if(quoteUtility.validateFileUploadDetails(uploadFile,quoteErrors)){//validation json inputs
                ContentVersion doc = new ContentVersion();
                try{
                    //inserting file into content version by decoding base64 string sent in payload
                    doc.PathOnClient = uploadFile.fileName;
                    doc.Title = uploadFile.fileName;
                    doc.VersionData = EncodingUtil.base64Decode(uploadFile.file);
                    doc.NetworkId  = networkId;
                    Insert doc;
                }catch(Exception e){
                    if(e.getMessage().contains('Maximum size of request reached')){
                        Pricing_RestAPI_QuotesUtilityV2.addValidationError(quoteErrors.quoteErrors, 'file', Pricing_RestAPI_ResponseCodes.VALID_ERROR_CODE_1019, new Map<String,String>{'{{dataMaxLimit}}'=> '2GB'});
                        Pricing_RestAPI_QuotesUtilityV2.isValid=false;
                    }
                    Pricing_RestAPI_Util.quoteErrMsgsV2 = quoteErrors;
                    Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                }
                
                
                Id documentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:doc.Id].ContentDocumentId;//getting the id of document inserted
                
                //attaching the document to quote
                ContentDocumentLink docLink = new ContentDocumentLink();
                docLink.ContentDocumentId = documentId;
                docLink.LinkedEntityId = uploadFile.quoteId;
                Insert docLink;
                
                // creating a chatter post for the quote
                FeedItem post = new FeedItem();
                post.Body = String.isBlank(uploadFile.comment) ? Label.Pricing_UploadFile_DefaultComment.replace('<datetime>', string.valueof(ENTRY_TIME)) : uploadFile.comment;
                post.ParentId = uploadFile.quoteId;
                insert post;
                
                //attaching the document to the chatter post
                FeedAttachment postAttachment = new FeedAttachment();
                postAttachment.FeedEntityId = post.id;
                postAttachment.Type = 'Content';
                postAttachment.RecordId = doc.id;
                insert postAttachment;
                
                //sending the success response
                String res = 'File Uploaded successfully for Quote: '+ uploadFile.quoteId;
                response.totalRecords = 1;
                response.successContent = new List<UploadFileDetails>();
                response.successContent.add(new UploadFileDetails(res));
            }
            else {
                Pricing_RestAPI_Util.quoteErrMsgsV2 = quoteErrors;
                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }
        }catch(Exception exp){
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);            
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }
            user currentUser = [Select Id, ContactId,AccountId from User where Id = :UserInfo.getUserId()];
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response, currentUser);            
        }        
    }    
    //wrapper class for request json 
    public class UploadFile{
        public String quoteId {set;get;}
        public String file {set;get;}
        public String fileName {set;get;}
        public String comment {set;get;}
    }
    //wrapper class for success json
    public class UploadFileDetails implements Pricing_RestAPI_SuccessContent {
        String quote {set;get;}
        public UploadFileDetails(String msg){
            quote = msg;
        }
    }
}