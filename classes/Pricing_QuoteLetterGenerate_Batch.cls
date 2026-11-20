/**
 * @description       : 
 * @author            : Vrushabh 
 * @group             : 
 * @last modified on  : 05-05-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public without sharing class Pricing_QuoteLetterGenerate_Batch extends TriggerHandler implements Database.Batchable<sObject>,Database.Stateful {
    
    /**
    * @description : Return all Quote Line with Won, Rejected and  Approved status
    * @author Vrushabh  | 12-06-2024 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Set<Id> finalQuoteIds = new Set<Id>();
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,Pricing_Quote_Program_Nm__c,Pricing_Maximum_Approved_Rejected_Date__c 
        FROM SBQQ__Quote__c WHERE Pricing_Quote_Program_Nm__c =:Label.Pricing_Tender_Quote_Program AND 
                            Pricing_Maximum_Approved_Rejected_Date__c = TODAY  AND SBQQ__Status__c !='Rejected' AND
                            Pricing_Auto_generate_Quote_Letter__c = true ]);
    }

    /**
    * @description 
    * @author Vrushabh  | 12-06-2024 
    * @param bc 
    * @param quoteLinesBatch 
    **/
    public void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> quoteBatch){
        try
        {
            List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
            List<Id> quoteIds = new List<Id> ();
            for(SBQQ__Quote__c quote : quoteBatch) {
                quoteIds.add(quote.Id);
            }
            
            Map<Id,List<SBQQ__QuoteDocument__c>> quoteIdToDocList = new Map<Id,List<SBQQ__QuoteDocument__c>>();
            for(SBQQ__QuoteDocument__c quoteDocumnetList : [SELECT Id, Name, SBQQ__Quote__c, SBQQ__Quote__r.Name, SBQQ__Version__c, CreatedDate, CreatedBy.Name 
                                        FROM SBQQ__QuoteDocument__c WHERE  SBQQ__Quote__c IN: quoteIds
                                        AND SBQQ__Quote__r.Pricing_Quote_Program_Nm__c =:Label.Pricing_Tender_Quote_Program 
                                        ORDER BY SBQQ__Version__c DESC]){
                                            if(quoteIdToDocList.containsKey(quoteDocumnetList.SBQQ__Quote__c)){
                                                quoteIdToDocList.get(quoteDocumnetList.SBQQ__Quote__c).add(quoteDocumnetList);
                                            }else{
                                                quoteIdToDocList.put(quoteDocumnetList.SBQQ__Quote__c, new List<SBQQ__QuoteDocument__c> {quoteDocumnetList});
                                            }
                                        }
            
            Set<Id> quoteIdWithQuoteDocIds = new Set<Id>();
            Set<Id> quoteIdWithDocIdsGen = new Set<Id>();
            for(SBQQ__Quote__c quote : quoteBatch){
                if(quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_Quote_Program){
                    DateTime quotelineLastApprovedDate = quote.Pricing_Maximum_Approved_Rejected_Date__c;
                    if(!quoteIdToDocList.containsKey(quote.Id)){
                        quoteIdWithQuoteDocIds.add(quote.Id);
                    }
                    else{
                        for(SBQQ__QuoteDocument__c  docs : quoteIdToDocList.get(quote.Id)){
                            DateTime docCreateDate = docs.CreatedDate;
                            //forming quote ids list where quotedocument is not created
                            if(quote.Id == docs.SBQQ__Quote__c  && docCreateDate <= quotelineLastApprovedDate){
                                quoteIdWithQuoteDocIds.add(quote.Id);
                            }
                            if(quote.Id == docs.SBQQ__Quote__c  && docCreateDate >= quotelineLastApprovedDate){
                                quoteIdWithDocIdsGen.add(quote.Id);
                            }
                        }
                    }
                }
            }

            if(quoteIdWithQuoteDocIds.size() > 0){
                quoteIdWithQuoteDocIds.removeAll(quoteIdWithDocIdsGen);
            }
            //getting all Quotelines from quoteIds.
            if(quoteIdWithQuoteDocIds.size() > 0){
                quoteLines = [SELECT Id, Pricing_Quote_Line_Number__c, Pricing_Status_Nm__c, SBQQ__Quote__r.Pricing_Maximum_Approved_Rejected_Date__c,Pricing_Product_Nm__r.Name, SBQQ__Quote__c, SBQQ__Quote__r.Name, Pricing_Last_Approved_Date_dt__c, LastModifiedDate , Pricing_Deal_RFQ_Id__c, Pricing_Quote_Program_Nm__c
                FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :quoteIdWithQuoteDocIds and ((Pricing_Deal_RFQ_Id__c != null AND Pricing_Product_Nm__r.Name =:Label.Pricing_Tender_Write_In_Product) OR (Pricing_Product_Nm__r.Name != :Label.Pricing_Tender_Write_In_Product))];
            }

            List<Id> quoteIdByStatus = new List<Id>();
            Map<Id,List<String>> quoteIdToQLStatusMap = new Map<Id,List<String>>();
            for(SBQQ__QuoteLine__c ql : quoteLines){      
                Boolean isWriteInProduct = (ql.Pricing_Product_Nm__r.Name == Label.Pricing_Tender_Write_In_Product);
                Boolean isRFQIdNull = (ql.Pricing_Deal_RFQ_Id__c == null);
                Boolean isPendingReview = ql.Pricing_Status_Nm__c == 'Pending Intel Field Review' || ql.Pricing_Status_Nm__c == 'Pending Further Intel Review';
                //if not WIN and Deal Id not null and not pending review quotelines  and if not WIN and no deal id then don't consider ql's
                if(!(isWriteInProduct && isRFQIdNull && isPendingReview)){
                    if(quoteIdToQLStatusMap.containsKey(ql.SBQQ__Quote__c)){
                        quoteIdToQLStatusMap.get(ql.SBQQ__Quote__c).add(ql.Pricing_Status_Nm__c);
                    }else{
                        quoteIdToQLStatusMap.put(ql.SBQQ__Quote__c, new List<String> {ql.Pricing_Status_Nm__c});
                    }
                }
            }

            // if not WIP or WIN with Deal id ql having PFIR or PIFR qls then removing those quotes
            for(Id quoteId : quoteIdToQLStatusMap.keyset()){
                if( !quoteIdToQLStatusMap.get(quoteId).contains('Pending Intel Field Review')
                    && !quoteIdToQLStatusMap.get(quoteId).contains('Pending Further Intel Review') 
                    && (quoteIdToQLStatusMap.get(quoteId).contains('Approved') || quoteIdToQLStatusMap.get(quoteId).contains('Won'))){
                    quoteIdByStatus.add(quoteId);
                }
            }

            //getting quote lines where quote Letter should get generate
            List<SBQQ__QuoteLine__c> eligibleQuoteLines = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c qls : quoteLines){
                if(quoteIdByStatus.contains(qls.SBQQ__Quote__c) && qls.Pricing_Status_Nm__c != 'Draft' && qls.Pricing_Status_Nm__c != 'Revised' && ((qls.Pricing_Deal_RFQ_Id__c != null && qls.Pricing_Product_Nm__r.Name == Label.Pricing_Tender_Write_In_Product) || (qls.Pricing_Product_Nm__r.Name != Label.Pricing_Tender_Write_In_Product))){
                    eligibleQuoteLines.add(qls);
                }
            }
            
            List<Id> quoteLineIdWithQuoteDoc = new List<Id>();
            for(SBQQ__QuoteLine__c ql : eligibleQuoteLines){
                if(quoteIdToDocList.containskey(ql.SBQQ__Quote__c)){
                    DateTime quotelineLastApprovedDate = ql.Pricing_Last_Approved_Date_dt__c;
                    for(SBQQ__QuoteDocument__c  docs : quoteIdToDocList.get(ql.SBQQ__Quote__c)){
                        DateTime docCreateDate = docs.CreatedDate;
                        //forming ql id list where quotedocument is created
                        if(ql.SBQQ__Quote__c == docs.SBQQ__Quote__c  && docCreateDate >= quotelineLastApprovedDate){
                            quoteLineIdWithQuoteDoc.add(ql.Id);
                        }
                    }
                }
            }
            List<Id> finalQuoteLineId = new List<Id>();
            //Excluding quoteLines where quoted document is created from eligible quote Lines.
            for(SBQQ__QuoteLine__c ql : eligibleQuoteLines){
                if(!quoteLineIdWithQuoteDoc.contains(ql.Id)){
                    finalQuoteLineId.add(ql.Id);
                    finalQuoteIds.add(ql.SBQQ__Quote__c);
                }
            }
            generateQuoteLetter(finalQuoteLineId);
        }
        catch(exception ex){
            Pricing_Tender_Utility.logError(ex);
        }
    }

    /**
    * @description create core log entry
    * @author Vrushabh  | 12-06-2024 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:bc.getJobId()];
        List<Core_Log_Entry__c> lstLogEntryRecords = createLogEntryRecords();
        List<Database.SaveResult> resultsCreateLogRecords = Database.insert(lstLogEntryRecords, false);
    }

    /**
    * @description : create core log entry record 
    * @author Vrushabh  | 12-06-2024 
    * @return List<Core_Log_Entry__c> 
    **/
    private List<Core_Log_Entry__c> createLogEntryRecords(){
        List<Core_Log_Entry__c> lstLogEntry = new List<Core_Log_Entry__c>();
        DateTime dtnow = System.now();
        decimal duration = ((dtnow.getTime())/1000) - ((System.now().getTime())/1000);        
        // Create Assign log Entry
        Core_Log_Entry__c addLogEntry = new Core_Log_Entry__c ();
        addLogEntry.Core_Origin__c = 'Generate Quote Letter batch';
        addLogEntry.Core_Project__c = 'Intel Quote Request (IQR)';
        addLogEntry.Core_Scope__c = 'IQR QuoteLetterGenerate Logic';
        addLogEntry.Core_Severity__c = 'Information';
        addLogEntry.Core_Message__c = 'Batch for IQR Quote Letter Generation for missing quote letters';
        addLogEntry.Core_When__c = System.now();
        addLogEntry.Core_Details__c = 'Duration: ' + duration+' for processing batch for following Quotes:' +finalQuoteIds;
        lstLogEntry.add(addLogEntry);        
        return(lstLogEntry);
    }

    /**
    * @description : Method for genration quote letter doc
    * @author Vrushabh  | 12-06-2024 
    * @param quoteLineList 
    **/
    public static void generateQuoteLetter(List<Id> quoteLineList){
        List<Id> runCalculateQuoteId = new List<Id>();
        Map<Id,SBQQ__QuoteLine__c> qlIdToQuoteLinesMap = new Map<Id,SBQQ__QuoteLine__c>();
        if(quoteLineList.size() > 0){
            for(SBQQ__QuoteLine__c quoteLine : [SELECT Id,SBQQ__Quote__c,Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c,Pricing_New_Change_Request_cb__c,Pricing_Save_After_Calculation_cb__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.Pricing_Auto_generate_Quote_Letter__c = TRUE AND Id IN :quoteLineList]){
                qlIdToQuoteLinesMap.put(quoteLine.Id,quoteLine);
            }
            if(qlIdToQuoteLinesMap.size() > 0){
                String quoteIdsStr = '';
                Id quoteId;
                for(Id quoteLineId : qlIdToQuoteLinesMap.keySet()){
                    if(qlIdToQuoteLinesMap.get(quoteLineId).Pricing_Save_After_Calculation_cb__c == false){
                        quoteId = qlIdToQuoteLinesMap.get(quoteLineId).SBQQ__Quote__c;
                        runCalculateQuoteId.add(quoteId);
                    }
                    else{
                        quoteIdsStr = String.isEmpty(quoteIdsStr) ? String.valueOf(qlIdToQuoteLinesMap.get(quoteLineId).SBQQ__Quote__c) : quoteIdsStr+','+String.valueOf(qlIdToQuoteLinesMap.get(quoteLineId).SBQQ__Quote__c);
                    }
                }
                if(runCalculateQuoteId.size() > 0){
                    runCalculatorService(runCalculateQuoteId);
                }
                if(!String.isEmpty(quoteIdsStr)){
                   QuoteLineBusinessLogic.publishQuoteLetter(quoteIdsStr);
                }
            }
        }
    }

    /**
    * @description : method for running calculator services    
    * @author Vrushabh  | 12-06-2024 
    * @param quoteId 
    **/
    public static void runCalculatorService(List<Id> quoteId){
        List<QuoteModel> lstQuoteModel = new List<QuoteModel>();
        Pricing_QuoteCalculator calculator = new Pricing_QuoteCalculator();
        for(SBQQ__Quote__c quote : [SELECT Id,SBQQ__LastCalculatedOn__c FROM SBQQ__Quote__c WHERE Pricing_Auto_generate_Quote_Letter__c = TRUE AND Id IN: quoteId]){
            QuoteModel quoteModel = new QuoteModel();
            quoteModel.record = quote;
            lstQuoteModel.add(quoteModel);
        }        
        if(!Test.isRunningTest()){
            calculator.calculate(lstQuoteModel, 'Pricing_CalculatorCallBack');
        }
    }
}