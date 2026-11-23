public without sharing class Pricing_BulkApprovalRejectionController {

    @AuraEnabled(cacheable=true)
    public static List<DataTableColumns> getMetadataColumns(){
        List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
        List<string> columnList = new List<string>();
        List<string> fieldAPINameList = new List<string>();
        Pricing_Dynamic_Data_Table__mdt dynamicDataTableMetadata = [SELECT Id, Label, Pricing_Field_Label__c, Pricing_Field_Value__c 
                                                                    FROM Pricing_Dynamic_Data_Table__mdt WHERE Label = 'Bulk Approve/Reject' LIMIT 1];
        if(dynamicDataTableMetadata != null) {
            if(dynamicDataTableMetadata.Pricing_Field_Label__c != null) {
                columnList = dynamicDataTableMetadata.Pricing_Field_Label__c.split(',');
            }
            if(dynamicDataTableMetadata.Pricing_Field_Value__c != null) {
                fieldAPINameList = dynamicDataTableMetadata.Pricing_Field_Value__c.split(',');
            }
            columnList.add('Change Request');
            columnList.add('Quote Line Type');
            columnList.add('Intel Response Requested By Date');
            fieldAPINameList.add('changeRequest:boolean');
            fieldAPINameList.add('quoteLineType:text');
            fieldAPINameList.add('responseRequestedDate:date-local');
            if(columnList.size() > 0) {
                for(integer i = 0; i < columnList.size(); i++) {
                    DataTableColumns datacolumn = new DataTableColumns(columnList[i].trim(), 
                                                                       fieldAPINameList[i].substringBefore(':').trim(), 
                                                                       fieldAPINameList[i].substringAfter(':').trim(), 
                                                                       'true');
                    TypeAttributes tyb =  new TypeAttributes('_blank');
                    TypeAttributes tybDate =  new TypeAttributes();
                    Label lbl = new Label(fieldAPINameList[i].substringBefore(':').trim());
                    tyb.label = lbl;
                    datacolumn.typeAttributes = fieldAPINameList[i].substringAfter(':').trim() == 'date-local' ? tybDate : tyb;
                    lstDataColumns.add(datacolumn);
                }
                system.debug('lstDataColumns: '+lstDataColumns);
                return lstDataColumns;
            }
            else {
                return null;
            } 
        } 
        else {
            return null;
        }
    }
    
    //Method to fetch all the QuoteLine records which are submitted for approval
    @AuraEnabled(cacheable=true)
    public static List<QuotelineDetails> getSubmittedRecords(){
        List<QuotelineDetails> quoteLineListWrapper = new List<QuotelineDetails>();
        List<ProcessInstanceWorkitem> processInstanceList = new List<ProcessInstanceWorkitem>();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        Set<Id> targetObjectId = new Set<Id>();

        processInstanceList = [SELECT ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ActorId  =:  UserInfo.getUserId() AND
                            ProcessInstance.TargetObject.Type = 'SBQQ__QuoteLine__c'];
        if(processInstanceList.size() > 0){
            for(ProcessInstanceWorkitem ps : processInstanceList){
                targetObjectId.add(ps.ProcessInstance.TargetObjectId);
            }
        }

        quoteLineList = [SELECT Id,SBQQ__Quote__c,SBQQ__Quote__r.Name, Pricing_Quote_Line_Number__c,Pricing_Product_Nm__r.Name,Pricing_Other_Product_Nm__c,Pricing_Status_Nm__c,
                    Pricing_OEM_Account_Nm__c,Pricing_EndCustomer_Nm__c,Pricing_UnifiedEndCustomer__c,Pricing_Region_Nm__c,Pricing_End_Customer_Country__c,Pricing_Server_Deal_Type_Nm__c,
                    Pricing_New_Change_Request_cb__c,Pricing_Program_Type_Nm__c,Pricing_Intel_Response_Requested_By_Date__c,Pricing_Last_Submitted_Date_dt__c,Pricing_Last_Submitted_By_Id__r.Name FROM SBQQ__QuoteLine__c WHERE 
                    Id IN: targetObjectId];

        for(SBQQ__QuoteLine__c qli: quoteLineList){
            QuotelineDetails qliObj = new QuotelineDetails();
                qliObj.recordId = qli.Id;
                qliObj.quoteNumber = qli.SBQQ__Quote__r.Name;
                qliObj.quoteLineNumber = qli.Pricing_Quote_Line_Number__c;
                qliObj.product = qli.Pricing_Product_Nm__r.Name;
                qliObj.writeInProduct = qli.Pricing_Other_Product_Nm__c;
                qliObj.account = qli.Pricing_OEM_Account_Nm__c;
                qliObj.endCustomer = qli.Pricing_EndCustomer_Nm__c;
                qliObj.unifiedEndCustomer = qli.Pricing_UnifiedEndCustomer__c;
                qliObj.endCustomerGeography = qli.Pricing_Region_Nm__c;
                qliObj.endCustomerCountry = qli.Pricing_End_Customer_Country__c;
                qliObj.application = qli.Pricing_Server_Deal_Type_Nm__c;
                qliObj.changeRequest = qli.Pricing_New_Change_Request_cb__c;
                qliObj.quoteLineType = qli.Pricing_Program_Type_Nm__c;
                qliObj.responseRequestedDate = qli.Pricing_Intel_Response_Requested_By_Date__c;
                //qliObj.submittedDate = qli.Pricing_Last_Submitted_Date_dt__c != null ? Date.newInstance(qli.Pricing_Last_Submitted_Date_dt__c.year(), qli.Pricing_Last_Submitted_Date_dt__c.month(), qli.Pricing_Last_Submitted_Date_dt__c.day()) : null;
                //qliObj.submittedBy = qli.Pricing_Last_Submitted_By_Id__r.Name != null ? qli.Pricing_Last_Submitted_By_Id__r.Name : '';
                qliObj.quoteNumberUrl = URL.getSalesforceBaseURL().toExternalForm()+'/'+qli.SBQQ__Quote__c;
                qliObj.quoteLineNumberUrl = URL.getSalesforceBaseURL().toExternalForm()+'/'+qli.Id;
            	quoteLineListWrapper.add(qliObj);
                }
        
        system.debug(quoteLineListWrapper.size());
        system.debug(quoteLineListWrapper);
        return quoteLineListWrapper;
    }
    
    //Method to Approve or Reject the selected records
    @AuraEnabled
    public static String processRecords(List<Id> quoteLineIds,String action){
        Set<Id> sObjectIds = new Set<Id>(quoteLineIds);
        String actionComments = '';
        String message = '';
        try{
            Pricing_Publish_Quote.setFSEActionOnQuoteLine(sObjectIds, action, actionComments, false);
            message = 'Success';
        }
        catch(Exception e){
            message = 'Error';
        }
        return message;
    }

    //Wrapper class to return Dynamic DataTable columns
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public TypeAttributes typeAttributes {get;set;}
        @AuraEnabled
        public String sortable {get;set;}
        
        public DataTableColumns(String label, String fieldName, String type, String sortable)
        {
            this.label     = label;
            this.fieldName = (fieldName == 'quoteNumber' || fieldName == 'quoteLineNumber')?fieldName+'Url':fieldName;
            this.type      = type;
            this.sortable = sortable;
        }
    }
    
    public class TypeAttributes{
        @AuraEnabled
        public Label label {get;set;}
        @AuraEnabled
        public String target {get;set;}
        @AuraEnabled
        public String day {get;set;}
        @AuraEnabled
        public String month {get;set;}
        @AuraEnabled
        public String year {get;set;}
        public TypeAttributes(String target){
            this.target = target;
        }
        public TypeAttributes(){
            this.day = 'numeric';
            this.month = 'numeric';
            this.year = 'numeric';
        }
    }
    
    public class Label{
        @AuraEnabled
        public String fieldName {get;set;}
        public Label(String fieldName){
            this.fieldName = fieldName;
        }
    }
    
    //Wrapper class to store the column values of data table
    public class QuotelineDetails{
    	@AuraEnabled public String recordId;
        @AuraEnabled public String quoteNumber;
        @AuraEnabled public String quoteLineNumber;
        @AuraEnabled public String product;
        @AuraEnabled public String writeInProduct;
        @AuraEnabled public String account;
        @AuraEnabled public String endCustomer;
        @AuraEnabled public String unifiedEndCustomer;
        @AuraEnabled public String endCustomerGeography;
        @AuraEnabled public String endCustomerCountry;
        @AuraEnabled public String application;
        @AuraEnabled public Boolean changeRequest;
        @AuraEnabled public String quoteLineType;
        @AuraEnabled public Date responseRequestedDate;
        @AuraEnabled public String quoteNumberUrl;
        @AuraEnabled public String quoteLineNumberUrl;
    }
}