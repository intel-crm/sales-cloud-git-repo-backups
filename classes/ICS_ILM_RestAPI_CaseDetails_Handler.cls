public with sharing class ICS_ILM_RestAPI_CaseDetails_Handler {  // Niyaz -- 12/06/2025 --- added as part of vulnerability fix, changed to with sharing
    private final static String ERROR_CODE_500 = '500';
    private final static String SUCCESS_CODE_200 = '200';
    private static DateTime entryTime = System.now();
    private static String apiName; 
    private static Integer Offset =0;
    private static Integer Number_Of_Pages;
    private static Integer Current_page = 0;
    private static String  condition = '';
    private static final String ORDER_BY =' Order by CaseNumber DESC ';
    public static Core_RestAPI_Response_withCount response = new Core_RestAPI_Response_withCount();
    public static casewrapper csewrap = new casewrapper();
    private static String jsonData = '';
    public static string getCases(){
           RestRequest request = RestContext.request;
           //List<case> CaseList = new List<Case>();
           Integer PageNumber = Integer.valueOf(request.params.get('pagenumber'));
           Integer limitSize = Integer.valueOf(request.params.get('limit'));
           String productId = request.params.get('EpmId');
           String accountId = request.params.get('CIMId');
           String contactId = request.params.get('contactId');
           String contactEmail = request.params.get('contactEmail');
           String contactName = request.params.get('contactName');
           String productName = request.params.get('productName');
           String accountName = request.params.get('accountName');
           String CaseNo = request.requestURI.substring(request.requestURI.lastIndexof('/')+1);
           //condition = ' AND Core_IPSPortal_Check__c = true ';
        if(String.isNotBlank(productId)){
            condition = condition + ' Account.Core_CIM_ID__c =: '+string.escapeSingleQuotes(productId)+' AND';
        }
        if(String.isNotBlank(accountId)){
            condition = condition + ' Account.Core_CIM_ID__c = '+string.escapeSingleQuotes(accountId)+' AND';
        }
        if(String.isNotBlank(contactEmail)){
            condition = condition + ' Contact.email LIKE \'%'+string.escapeSingleQuotes(contactEmail)+'%\'';
        }
        if(String.isNotBlank(contactName)){
            condition = condition + ' AND Contact.Name LIKE \'%'+string.escapeSingleQuotes(contactName)+'%\'';
        }
        if(String.isNotBlank(productName)){
            condition = condition + ' Core_IPS_Product__c LIKE \'%'+String.escapeSingleQuotes(productName)+'%\'';
        }
        if(String.isNotBlank(accountName)){
            condition = condition + ' Account.Name = '+string.escapeSingleQuotes(accountName);
        }
        string condition1 = condition + ORDER_BY;
        system.debug('Condition'+condition);
        if(limitSize!=NULL){
            condition = condition1 + ' LIMIT '+''+string.escapeSingleQuotes(string.valueof(limitSize));
        }
         condition = condition + ' OFFSET '+''+offset;
        system.debug('Condition2'+condition);
        string tempQery = 'SELECT id,CaseNumber, Status,Core_Sub_Status__c, Core_Severity__c, Core_IPS_Project_Case__r.Name, Core_IPS_Product__c, '+
                      'Subject, Contact.Name, Contact.Account.Name, CreatedDate,Core_Customer_Reference_ID__c, ClosedDate, LastModifiedDate, Core_Issue_Description__c,CreatedBy.Core_Login_Id__c, '+ 
                      'Core_IPS_Project_Case__r.Core_IPS_Project_ID__c, Core_IPS_Product_name__c '+
                      'FROM case WHERE ';
        String GET_CASES_SOQL = tempQery;
        string TempQery_with_condition = tempQery + condition1;
        
        
        system.debug('Query'+GET_CASES_SOQL);
         List<Case> cList = new List<Case>();
        List<Case> cList1 = new List<Case>();
        Try{
            cList1 = Database.Query(TempQery_with_condition);
            
            system.debug('Case List'+cList1);
            if(cList1.size()>0){
                /*if(Math.Mod(cList1.size(),limitSize)==0){
                    Number_Of_Pages = cList1.size()/limitSize;
                }else{
                    Number_Of_Pages = cList1.size()/limitSize+1;
                }
                system.debug('Number_Of_Pages'+Number_Of_Pages);*/
            
            JSONGenerator jsonGen = JSON.createGenerator(true);
            
            jsonGen.writeStartObject();
            jsonGen.writeFieldName('SystemDetails');
            jsonGen.writeStartObject();
            jsonGen.writeStringField('source','IPS');
            jsonGen.writeStringField('target','ILM');
            jsonGen.writeStringField('message_type','Comment');
            jsonGen.writeEndObject();
           
            jsonGen.writeFieldName('FilterCriteria');
            jsonGen.writeStartObject();
            jsonGen.writeStringField('ContactId','0033F00000b4Oqk');
            jsonGen.writeEndObject();
            jsonGen.writeFieldName('CommentInfo');
            jsonGen.writeStartArray();
            for(case c : cList1){
                jsonGen.writeStartObject();
                jsonGen.writeStringField('CaseNumber',c.CaseNumber);
                jsonGen.writeStringField('AccountName',c.Contact.Account.Name);
                jsonGen.writeStringField('Contactname',c.Contact.Name);
                jsonGen.writeStringField('ID',c.Id);
                jsonGen.writeStringField('Severity',c.Core_Severity__c);
                jsonGen.writeStringField('Status',c.Status);
                jsonGen.writeStringField('Case sub Status',c.Core_Sub_Status__c);
                //jsonGen.writeStringField('Project Name',c.Core_IPS_Project_Case__r.Name);
                jsonGen.writeStringField('Prodcut Name',c.Core_IPS_Product__c);
                jsonGen.writeStringField('Sub Status',c.Subject);
                //jsonGen.writeStringField('Customer referenceId',c.Core_Customer_Reference_ID__c);
                jsonGen.writeStringField('Case Description',c.Core_Issue_Description__c);
                jsonGen.writeStringField('Product Name',c.Core_IPS_Product_name__c);
                //jsonGen.writeStringField('Created by',c.CreatedBy.Core_Login_Id__c);
                
                jsonGen.writeEndObject();
            }
            jsonGen.writeEndArray();
            jsonGen.writeEndObject();
            jsonData = jsonGen.getAsString();
        System.debug('Json Data - ' +jsonData);
        }
      
            /*for(Case c : Database.Query(GET_CASES_SOQL))
            { 
                integer i =0;
                if(i<=Number_Of_Pages && offset<=cList.size()){
                    CaseWrapper cw = new CaseWrapper();
                    cw.caseNumber = c.CaseNumber;
                    cw.status = c.Status;
                    cw.subStatus = c.Core_Sub_Status__c;
                    cw.severity = c.Core_Severity__c;
                    cw.ipsProjectName = c.Core_IPS_Project_Case__r.Name;
                    cw.intelProductName = c.Core_IPS_Product__c;
                    cw.subject = c.Subject;
                    cw.contactName = c.Contact.Name;
                    cw.accountName = c.Contact.Account.Name;
                    cw.dateTimeOpened = c.CreatedDate;
                    cw.lastModifiedDateTime = c.LastModifiedDate;
                    cw.dateTimeClosed = c.ClosedDate;
                    cw.customerReferenceId= c.Core_Customer_Reference_ID__c;
                    cw.caseLink=Label.Core_RestAPI_Attachment_Link+c.id;
                 // response.successContent.add(cw);
                  i++;
                }
            }
               system.debug('Current_page'+Current_page);
               system.debug('PageNumber'+PageNumber);
            if(PageNumber>Current_page && Current_page<=Number_Of_Pages){
                Current_page = pagenumber;
                //offset+=limitSize;
                offset=pagenumber;
                system.debug('offset'+offset);
                cList= Database.query(GET_CASES_SOQL);
                system.debug('GET_CASES_SOQL1'+GET_CASES_SOQL);
            }else if(PageNumber<=Current_page && Current_page<=Number_Of_Pages){
                Current_page = pagenumber;
                offset-=limitSize;
                cList= Database.query(GET_CASES_SOQL);
                system.debug('GET_CASES_SOQL2'+GET_CASES_SOQL);
            }*/
            
         }catch(Exception e){
              Core_RestAPI_Util.processException(e, ERROR_CODE_500, response, apiName, entryTime);
              response.successContent = null;
             system.debug('excepetion'+e.getMessage());
        }finally{
                if(String.isBlank(response.code)){
                response.code = SUCCESS_CODE_200;
            }
                
            Core_RestAPI_LoggingUtil.logTransaction(entryTime, response);
        }        
        system.debug('Case List'+cList);
          return jsonData; 
    }
    public class Core_RestAPI_Response_withCount extends Core_RestAPI_Response{
        Integer openCases {get;set;}
        Integer newCases {get;set;}
        //public List<case> caseList{get;set;}
    }
    public class CaseWrapper implements Core_RestAPI_SuccessContent{
        public String caseNumber {get;set;}
        public String status {get;set;}
        public String subStatus {get;set;}
        public String severity {get;set;}
        public String ipsProjectName {get;set;}
        public String intelProductName {get;set;}
        public String subject {get;set;}//Encrypted field
        public String contactName {get;set;}
        public String  accountName {get;set;}
        public String customerReferenceId {get;set;}
        public DateTime dateTimeOpened {get;set;}
        public DateTime lastModifiedDateTime {get;set;}
        public DateTime dateTimeClosed {get;set;}
        public String caseLink{get;set;}
    }
}