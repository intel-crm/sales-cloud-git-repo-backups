/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_CaseCommentV1_Handler 
* Version     : 1.0 
* Created Date: 12/12/2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps      12/12/2017                 Handler class to process request and response for the Case Comments
*****************************************************************************************************************************************/
public with sharing class Core_RestAPI_CaseCommentV1_Handler{  
    
    private String ERROR_CODE_500 = '500';
    private String SUCCESS_CODE_200 = '200';
    private String MALFORMED_INPUT_9011 = '9011';
    private static final String ORDER_BY_CREATED_DATE_DESC = 'Order by CreatedDate DESC';
    private DateTime entryTime = null;
    private String apiName; 
    private String condition{get;set;}
    public Core_RestAPI_Response response = new Core_RestAPI_Response();
    public static final String caseNumberCondition = Core_RestAPI_Util.getConditionWithURIParam('Core_IPS_Case__r.CaseNumber',3);
    private static final String CASE_NUMBER =  Core_RestAPI_Util.getInputFromURIParam(3);
    private String CaseCommentV1_URI ='/v1.0/cases/*/comments';
    private String INVALID_URI_404= '404';
    
    private static Map<String, String> mUserProfieName = new Map<String, String>();
   
    
    private Static final String GET_CASE_COMMENTS_SOQL =  'SELECT Core_IPS_Comment__c, Core_IPS_Comment_Author_Type__c,CreatedBy_Name__c,'+
        'Core_IPS_NickName__c, CreatedDate, CreatedBy.Email,CreatedBy.Contact.Email,CreatedBy.Account.Name, Core_IPS_Case__r.CaseNumber,'+ 
        'CreatedBy.UserRole.Name,CreatedBy.Profile.Name,CreatedBy_FirstName__c, Name FROM Core_IPS_Case_Comments__c'+
        ' WHERE '+ caseNumberCondition + ' AND Core_IPS_Case_Comment_Type__c= \'' + 'Public to Customers' +'\' AND Core_IPS_Case__r.Core_IPS_Customer_Visible__c = true '+ 
        ORDER_BY_CREATED_DATE_DESC +' LIMIT '+ LABEL.Core_RestAPI_CaseCommentV1_Record_Limits;
    
    public Core_RestAPI_CaseCommentV1_Handler(DateTime currTime, String APIname){
        this.entryTime = currTime;
        this.apiName = APIname;
        this.condition = '';
        response.successContent = new List<CaseCommentWrapper>();
        mUserProfieName.put('IPS Agent', 'Intel Technical Specialist');
        mUserProfieName.put('IPS Agent Enhanced', 'Intel Technical Specialist');
        mUserProfieName.put('IPS Support Org Admin', 'Intel Technical Specialist');
        mUserProfieName.put('Sales Rep-BB-Dual IPS','Intel Technical Specialist');
        mUserProfieName.put('Sales Rep-BB', 'Intel Sales Representative');
        mUserProfieName.put('Sales Ops','Intel Sales Representative');
        
    }
    
    
    public Core_RestAPI_Response getCaseComments(){ 
        try{ 
            //Validations if need to be handled in util class       
            boolean isRequestValid = doValidations(); 
            
            //Process the api request 
            if(isRequestValid == true){ 
                processRequest(); 
            }    
            
        }catch(Exception e){ 
            Core_RestAPI_Util.processException( e, ERROR_CODE_500, response, apiName, entryTime); 
        }finally{ 
            if(String.isBlank(response.code)) 
                response.code = SUCCESS_CODE_200; 
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response); 
        } 
        return response;
    }
    
    //Validate the data , Incase of error set the error code to 
    @testVisible private Boolean doValidations(){
        Boolean isRequestValid = true;
        if(!CASE_NUMBER.isNumeric() || CASE_NUMBER.length() != 8){
            Core_RestAPI_Util.processException(null ,MALFORMED_INPUT_9011, response, apiName, entryTime); 
            isRequestValid = false;
        }else if(Core_RestAPI_Util.isRequestURIValid(CaseCommentV1_URI) == false){
            Core_RestAPI_Util.processException(null , INVALID_URI_404, response, apiName, entryTime);   
            isRequestValid = false;
        } 
        return isRequestValid;
    }
    
    //Execute the SOQL and populate the result to wrapper list objects 
    public void processRequest(){
        CaseCommentInnerClass commentsObj = new CaseCommentInnerClass();
        response.successContent =  commentsObj.getCaseComments();
        //CaseCommentInnerClass objCommentInner = new CaseCommentInnerClass(this);
        //objCommentInner.processRequestInnerMethod();
    }
    
    public without sharing class CaseCommentInnerClass {
        
        //Core_RestAPI_CaseCommentV1_Handler caseCommentOuter;
        
        //public CaseCommentInnerClass (Core_RestAPI_CaseCommentV1_Handler caseCommentOuter) {
        //    this.caseCommentOuter = caseCommentOuter;
        //}
        private List<CaseCommentWrapper> wrprList = new List<CaseCommentWrapper>();
        public  List<CaseCommentWrapper> getCaseComments() {
            
            
            List<Core_IPS_Case_Comments__c > lstCaseComment = Database.query(GET_CASE_COMMENTS_SOQL);
            if(!lstCaseComment.isEmpty()){
                Map<String,List<Core_IPS_Case_Comments__c>> mIdCreatedBy = new Map<String,List<Core_IPS_Case_Comments__c>>();
                for(Core_IPS_Case_Comments__c  objCaseComment : lstCaseComment){
                    mIdCreatedBy.put(objCaseComment.Id,new List<Core_IPS_Case_Comments__c>{objCaseComment});
                }   
                for(String str : mIdCreatedBy.KeySet()){
                    List<Core_IPS_Case_Comments__c> lstCreatedByComment = mIdCreatedBy.get(str);
                    CaseCommentWrapper objCsCommtWrap = new CaseCommentWrapper ();
                    objCsCommtWrap.comment = lstCreatedByComment[0].Core_IPS_Comment__c;
                    objCsCommtWrap.caseCommentId = lstCreatedByComment[0].Name; 
                    objCsCommtWrap.caseNumber = lstCreatedByComment[0].Core_IPS_Case__r.CaseNumber;
                    CreatedByWrapper lstCreatedByWrapper= new CreatedByWrapper();
                    
                    for(Core_IPS_Case_Comments__c objCaseComment : lstCreatedByComment){
                        CreatedByWrapper objCreatedBy = new CreatedByWrapper();
                        if(objCaseComment.Core_IPS_Comment_Author_Type__c== 'Customer' || objCaseComment.Core_IPS_Comment_Author_Type__c== 'Partner'){
                            objCreatedBy.createdByName = objCaseComment.CreatedBy_Name__c;
                            objCreatedBy.createdDate = objCaseComment.CreatedDate;
                            objCreatedBy.createdByEmail = objCaseComment.CreatedBy.Contact.Email;
                            objCreatedBy.createdByRole = 'Customer';
                            objCreatedBy.accountName = objCaseComment.CreatedBy.Account.Name;
                        }else{
                            objCreatedBy.createdByName = objCaseComment.CreatedBy_FirstName__c;
                            objCreatedBy.createdDate = objCaseComment.CreatedDate;
                            if(objCaseComment.Core_IPS_Comment_Author_Type__c== 'Agent'){
                                objCreatedBy.createdByRole = 'Intel Technical Specialist';
                            }else{
                                objCreatedBy.createdByRole = Core_RestAPI_CaseCommentV1_Handler.mUserProfieName.get(objCaseComment.CreatedBy.Profile.Name);
                            }    
                        }
                        lstCreatedByWrapper= objCreatedBy;
                    }
                    objCsCommtWrap.createdBy = lstCreatedByWrapper;
                    wrprList.add(objCsCommtWrap);
                    //caseCommentOuter.response.successContent.add(objCsCommtWrap);
                }
            } 
            return wrprList;
        }
    }   
    
    
    //IMPORTANT : Wrapper class must implement the interface Core_RestAPI_SuccessContent
    // Wrapper to display the Case's Comments which are 'Public to Customers' only 
    public class CaseCommentWrapper implements Core_RestAPI_SuccessContent{
        public String comment{get;set;}
        public String caseCommentId{get;set;}
        public String caseNumber{get;set;}
        public createdByWrapper createdBy{get;set;}
        
    }
    
    //Separate wrapper for displayng Created By in one place
    public class CreatedByWrapper{
        
        public String createdByName{set;get;}
        public String createdByRole{get;set;}
        public String createdByEmail{get;set;}
        public DateTime createdDate{get;set;}
        public String accountName{get;set;}
    }
}