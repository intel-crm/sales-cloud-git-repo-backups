/**
 * @description       : Controller class for Price Comparision component
 * @author            : Sandeep
 * @group             : Accenture
 * @last modified on  : 01-07-2025
 * @last modified by  : Vrushabh Uprikar
**/
public with sharing class Pricing_PriceComparisionController {
    

    /**
    * @description Method to send QuoteLineList Wrapper to LWC to display in table
    * @author Sandeep | 02-08-2023 
    * @param qliNumber 
    * @return String 
    **/
    @AuraEnabled
    public static List<QuoteLineDetails> getQuoteLineDataforComparision(String qliNumber,String searchType){
        String searchString = String.escapeSingleQuotes(qliNumber);
        searchString = searchString.trim();
        Date datetoCheck = Date.today().addDays(-Integer.valueOf(System.Label.Pricing_PriceComparision_SubmittedDate_Param));
        List<String> qliType = System.Label.Pricing_Tender_PriceComp_QuoteLineType.split(',');
        List<String> quoteLineStatusList = System.Label.Pricing_PriceComparision_Statuses.split(',');
        Boolean isFSEorSDM = Pricing_QuoteLineController.isFSEorSDM();
        String Search_Statuses = System.Label.Pricing_PriceComparision_Search_Statuses;
        if(isFSEorSDM){
            Search_Statuses = Search_Statuses.replace(System.Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview, System.Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview);
        }        
        List<SBQQ__QuoteLine__c> quoteLine = [SELECT Id,Name,Pricing_Product_Nm__c,Pricing_Product_Nm__r.Name,Pricing_Program_Type_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c FROM SBQQ__QuoteLine__c 
                                              WHERE Pricing_Quote_Program_Nm__c =: System.Label.Pricing_Tender_Quote_Program AND Pricing_Program_Type_Nm__c IN: qliType 
                                              AND (Pricing_Status_Nm__c IN: Search_Statuses.split(',')) 
                                              AND Pricing_Product_Nm__r.Name != :System.Label.Pricing_Tender_Write_In_Product 
                                              AND (Pricing_Quote_Line_Number__c =: searchString OR Id =: searchString) AND Pricing_Last_Submitted_Date_dt__c != null];
        String projectName = '';
        List<QuoteLineDetails> quoteLineDetailsList = new List<QuoteLineDetails>();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        if(quoteLine.size() > 0){
            projectName = '%'+String.join(quoteLine[0].SBQQ__Quote__r.Pricing_Project_Name_Nm__c.split(' '),'%')+'%';
            quoteLineList = searchType == 'product' ?
             [SELECT Id,Pricing_Quote_Line_Number__c,SBQQ__Quote__c,SBQQ__Quote__r.Id,SBQQ__Quote__r.Name,Pricing_OEM_Account_Nm__c,Pricing_ECAP_Price_Amt__c,Pricing_Product_Nm__c,Pricing_Product_Nm__r.Name,
                            Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Project_Nm__c,Pricing_Approved_Unit_Qty__c,Pricing_EndCustomer_Nm__c,Pricing_Last_Submitted_Date_dt__c,Pricing_Status_Nm__c, 
                            Pricing_End_Customer_Country__c,Pricing_Region_Nm__c FROM SBQQ__QuoteLine__c WHERE Pricing_Last_Submitted_Date_dt__c >=: datetoCheck AND Id !=: quoteLine[0].Id AND Pricing_Quote_Program_Nm__c =: System.Label.Pricing_Tender_Quote_Program AND 
                            Pricing_Status_Nm__c IN: quoteLineStatusList AND Pricing_Product_Nm__r.Name =: (quoteLine[0].Pricing_Product_Nm__r.Name).trim() ORDER By SBQQ__Quote__c] :
                            [SELECT Id,Pricing_Quote_Line_Number__c,SBQQ__Quote__c,SBQQ__Quote__r.Id,SBQQ__Quote__r.Name,Pricing_OEM_Account_Nm__c,Pricing_ECAP_Price_Amt__c,Pricing_Product_Nm__c,Pricing_Product_Nm__r.Name,
                            Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Project_Nm__c,Pricing_Approved_Unit_Qty__c,Pricing_EndCustomer_Nm__c,Pricing_Last_Submitted_Date_dt__c,Pricing_Status_Nm__c,
                            Pricing_End_Customer_Country__c,Pricing_Region_Nm__c FROM SBQQ__QuoteLine__c WHERE Pricing_Last_Submitted_Date_dt__c >=: datetoCheck AND Id !=: quoteLine[0].Id AND Pricing_Quote_Program_Nm__c =: System.Label.Pricing_Tender_Quote_Program AND 
                            Pricing_Status_Nm__c IN: quoteLineStatusList AND Pricing_Product_Nm__r.Name =: (quoteLine[0].Pricing_Product_Nm__r.Name).trim() and SBQQ__Quote__r.Pricing_Project_Name_Nm__c like :projectName ORDER By SBQQ__Quote__c];
            
                for(SBQQ__QuoteLine__c qli : quoteLineList){
                QuoteLineDetails quoteLineDetail = new QuoteLineDetails();
                quoteLineDetail.Id = qli.Id;
                quoteLineDetail.quoteNumber = qli.SBQQ__Quote__r.Name;
                quoteLineDetail.quoteLineNumber = qli.Pricing_Quote_Line_Number__c;
                quoteLineDetail.account = qli.Pricing_OEM_Account_Nm__c;
                quoteLineDetail.ecapPrice = qli.Pricing_ECAP_Price_Amt__c;
                quoteLineDetail.approvedQuantity = qli.Pricing_Approved_Unit_Qty__c;
                quoteLineDetail.approvedStartDate = qli.Pricing_Approved_Start_Date_Dt__c;
                quoteLineDetail.approvedEndDate = qli.Pricing_Approved_End_Date_Dt__c;
                quoteLineDetail.product = qli.Pricing_Product_Nm__r.Name;
                quoteLineDetail.endCustomer = qli.Pricing_EndCustomer_Nm__c;
                quoteLineDetail.project = qli.Pricing_Project_Nm__c;
                quoteLineDetail.endCustomerRegion = qli.Pricing_End_Customer_Country__c;
                quoteLineDetail.endCustomerGeo = qli.Pricing_Region_Nm__c;
                quoteLineDetail.quoteNumberUrl = URL.getSalesforceBaseURL().toExternalForm()+'/'+qli.SBQQ__Quote__r.Id;
                quoteLineDetail.quoteLineNumberUrl = URL.getSalesforceBaseURL().toExternalForm()+'/'+qli.Id;
                quoteLineDetailsList.add(quoteLineDetail);
            }
        }
        return quoteLineDetailsList;
    }

    /**
    * @description method to send column Headers 
    * @author Sandeep | 02-10-2023 
    * @return List<DataTableColumns> 
    **/
    @AuraEnabled
    public static List<DataTableColumns> getDataTableColumns(){
        List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
        List<string> columnList = new List<string>();
        List<string> fieldAPINameList = new List<string>();
        Pricing_Dynamic_Data_Table__mdt dynamicDataTableMetadata = [SELECT Id, Label, Pricing_Field_Label__c, Pricing_Field_Value__c 
                                                                    FROM Pricing_Dynamic_Data_Table__mdt WHERE Label = 'Price Comparision'];
        if(dynamicDataTableMetadata != null) {
            if(dynamicDataTableMetadata.Pricing_Field_Label__c != null) {
                columnList = dynamicDataTableMetadata.Pricing_Field_Label__c.split(',');
            }
            if(dynamicDataTableMetadata.Pricing_Field_Value__c != null) {
                fieldAPINameList = dynamicDataTableMetadata.Pricing_Field_Value__c.split(',');
            }
            if(columnList.size() > 0) {
                for(integer i = 0; i < columnList.size(); i++) {
                    DataTableColumns datacolumn = new DataTableColumns(columnList[i].trim(), 
                                                                       fieldAPINameList[i].substringBefore(':').trim(), 
                                                                       fieldAPINameList[i].substringAfter(':').trim(), 
                                                                       true);

                    TypeAttributes tyb;
                    if(fieldAPINameList[i].substringAfter(':').trim() == 'date-local'){
                        tyb = new TypeAttributes();
                    }
                    else{
                        tyb = new TypeAttributes('_blank');
                    }
                    Label lbl = new Label(fieldAPINameList[i].substringBefore(':').trim());
                    tyb.label = lbl;
                    datacolumn.typeAttributes = tyb;
                    CellAttributes cellAlign = new CellAttributes();
                    datacolumn.cellAttributes = cellAlign;
                    lstDataColumns.add(datacolumn);
                }
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

    @AuraEnabled
    public static String getQuoteLineNumber(String qliId){
        String qlId = String.escapeSingleQuotes(qliId);
        String quoteLineNumber;
        try {
            SBQQ__QuoteLine__c quoteline = [SELECT Pricing_Quote_Line_Number__c FROM SBQQ__QuoteLine__c WHERE Id =: qlId];
            quoteLineNumber = quoteline.Pricing_Quote_Line_Number__c;
        } catch (Exception e) {
            Pricing_Tender_Utility.logError(e);
        }
        return quoteLineNumber;
    }

    /**
    * @description Method to call Einstein Discovery model to get predicted value
    * @author Sandeep Chamate | 08-03-2023 
    * @param qliId 
    **/
    @AuraEnabled
    public static Decimal getEstimatedECAPfromDiscovery(String qliNumber){
        Decimal predictedValue;
        SBQQ__QuoteLine__c quoteline = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Pricing_Quote_Line_Number__c =: qliNumber.trim()];
        try{
            ConnectApi.SmartDataDiscoveryPredictInputRecords predictInput = new ConnectApi.SmartDataDiscoveryPredictInputRecords();
            predictInput.predictionDefinition = '1ORDf0000004CI0OAM';      
            predictInput.records = new List<Id>{quoteline.Id};
            ConnectApi.SmartDataDiscoveryPrediction response = ConnectApi.SmartDataDiscovery.predict(predictInput);
            ConnectApi.SmartDataDiscoveryPredictObject predictedResponse = (ConnectApi.SmartDataDiscoveryPredictObject) response.predictions[0];
            predictedValue = Decimal.valueOf(predictedResponse.prediction.total);
        }
        catch(Exception ex){
            Pricing_Tender_Utility.logError(ex);
        }
        return predictedValue;
    }

    //Wrapper class for Data Table columns
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
        public CellAttributes cellAttributes {get;set;}
        @AuraEnabled
        public Boolean sortable {get;set;}

        public DataTableColumns(String label, String fieldName, String type, Boolean sortable) {
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

    public class CellAttributes{
        @AuraEnabled
        public String alignment {get;set;}
        public CellAttributes(){
            this.alignment = 'left';
        }
    }

    //Wrapper class for QuoteLine details
    public class QuoteLineDetails {
        @AuraEnabled public String Id {set;get;}
        @AuraEnabled public String quoteNumber {set;get;}
        @AuraEnabled public String quoteNumberUrl {set;get;}
        @AuraEnabled public String quoteLineNumber {set;get;}
        @AuraEnabled public String quoteLineNumberUrl {set;get;}
        @AuraEnabled public String account {set;get;}
        @AuraEnabled public Decimal ecapPrice {set;get;}
        @AuraEnabled public Decimal approvedQuantity {set;get;}
        @AuraEnabled public Date approvedStartDate {set;get;}
        @AuraEnabled public Date approvedEndDate {set;get;}
        @AuraEnabled public String product {set;get;}
        @AuraEnabled public String endCustomer {set;get;}
        @AuraEnabled public String project {set;get;}
        @AuraEnabled public String endCustomerRegion {set;get;}
        @AuraEnabled public String endCustomerGeo {set;get;}
    }
}