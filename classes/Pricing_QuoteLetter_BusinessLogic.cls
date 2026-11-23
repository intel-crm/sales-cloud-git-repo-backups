/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 12-24-2024
* @last modified by  : Vrushabh 
**/
public without sharing class Pricing_QuoteLetter_BusinessLogic {
    public static Map<Id,Account> accountIdtoRecordMap = new Map<Id, Account>();
    
    public static void generateQuoteLetters(List<Pricing_Quote_Letter_Event__e> events){
        Set<Id> accountIdSet = new Set<Id>(); 
        Set<String> quoteIds = new Set<String>();
        for(Pricing_Quote_Letter_Event__e evt : events){
            if(!String.isEmpty(evt.Pricing_QuoteIds_Txt__c) && evt.Pricing_Action_Nm__c==Label.Pricing_Generate_QuoteLetter_Action){
                quoteIds.addAll(evt.Pricing_QuoteIds_Txt__c.split(','));
            }
        }
        Set<String> fiQuotes = new Set<String>();
        Set<String> tenderQuotes = new Set<String>();
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Pricing_Program_Type_Nm__c FROM SBQQ__Quote__c WHERE Id IN: quoteIds];
        for(SBQQ__Quote__c quote : quoteList){
            if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote){
                fiQuotes.add(quote.Id);
            }else{
                tenderQuotes.add(quote.Id);
            }
        }
        if(quoteIds.size() > 0 ){
            Set<String> statuses = new Set<String>{'Draft','Lost','Revised','Rejected'};
            Set<Id> quoteIdsForQuoteLetter = new Set<Id>();
            Map<Id,List<SBQQ__QuoteLine__c>> quoteIdQLIsMap = new Map<Id,List<SBQQ__QuoteLine__c>>();
            
            if(fiQuotes.size() > 0){
                generateQuoteLetterForFI(fiQuotes, statuses, quoteIdsForQuoteLetter, quoteIdQLIsMap);
            }

            if(tenderQuotes.size() > 0){            
                for(SBQQ__QuoteLine__c quoteLine : [SELECT id,SBQQ__Quote__c,Name,Pricing_Ready_for_QuoteLetter_cb__c,Pricing_Status_Nm__c,SBQQ__Quote__r.SBQQ__Account__c FROM SBQQ__QuoteLine__c 
                                                    WHERE Pricing_Status_Nm__c NOT IN :statuses AND (Pricing_Deal_RFQ_Id__c != null
                                                    OR SBQQ__ProductName__c !=: Label.Pricing_Tender_Write_In_Product)
                                                    AND SBQQ__Quote__c IN :tenderQuotes]){
                    accountIdSet.add(quoteLine.SBQQ__Quote__r.SBQQ__Account__c);
                    if(quoteIdQLIsMap.containsKey(quoteLine.SBQQ__Quote__c)){
                        quoteIdQLIsMap.get(quoteLine.SBQQ__Quote__c).add(quoteLine);
                    }else{
                        quoteIdQLIsMap.put(quoteLine.SBQQ__Quote__c, new List<SBQQ__QuoteLIne__c>{quoteLine});
                    }
                }
                if(quoteIdQLIsMap.size() > 0){
                    for(Id quoteId : quoteIdQLIsMap.keySet()){
                        boolean hasPendingQLIs = false;
                        for(SBQQ__QuoteLine__c qli : quoteIdQLIsMap.get(quoteId) ){
                            if(!qli.Pricing_Ready_for_QuoteLetter_cb__c){
                                hasPendingQLIs = true;
                            }
                        }
                        if(!hasPendingQLIs){
                            quoteIdsForQuoteLetter.add(quoteId);
                        }
                    }

                    if(!accountIdSet.isEmpty()){
                        getAccountIdToRecordMap(accountIdSet);
                    }

                    if(quoteIdsForQuoteLetter.size() > 0){
                        //List<SBQQ__QuoteTemplate__c> quoteTemplates = [SELECT id FROM SBQQ__QuoteTemplate__c WHERE Name=:Label.Pricing_IQR_Quote_Template LIMIT 1];
                        Map<id,SBQQ__Quote__c> quotesMap = new Map<Id,SBQQ__Quote__c>([SELECT Id,Name,Pricing_End_Customer_Name__c,Pricing_Project_Name_Nm__c,Pricing_Account_Name__c,Pricing_Program_Type_Nm__c,SBQQ__Account__c,Pricing_Account_Simplified_Name__c,Pricing_End_Customer_Account__r.Name FROM SBQQ__Quote__c WHERE Id IN :quoteIdsForQuoteLetter ]);
                        if(quotesMap.size() > 0){
                            QuoteBusinessLogic.accountNamePopulate(quotesMap,accountIdtoRecordMap,true);
                            generateLetters(quotesMap);
                        }
                    }
                }
            }
        }
    }
    
    @testVisible
    private static void generateQuoteLetterForFI(Set<String> quoteIds, Set<String> statuses, Set<Id> quoteIdsForQuoteLetter, Map<Id,List<SBQQ__QuoteLine__c>> quoteIdQLIsMap){
        for(SBQQ__QuoteLine__c quoteLine : [SELECT id,SBQQ__Quote__c,Name,Pricing_Quote_Line_Number__c,Pricing_Ready_for_QuoteLetter_cb__c,Pricing_Status_Nm__c,SBQQ__Quote__r.SBQQ__Account__c FROM SBQQ__QuoteLine__c 
                                            WHERE Pricing_Status_Nm__c NOT IN :statuses AND SBQQ__Quote__c IN :quoteIds]){
                                                if(quoteIdQLIsMap.containsKey(quoteLine.SBQQ__Quote__c)){
                                                    quoteIdQLIsMap.get(quoteLine.SBQQ__Quote__c).add(quoteLine);
                                                }else{
                                                    quoteIdQLIsMap.put(quoteLine.SBQQ__Quote__c, new List<SBQQ__QuoteLIne__c>{quoteLine});
                                                }
                                            }
        if(quoteIdQLIsMap.size() > 0){
            for(Id quoteId : quoteIdQLIsMap.keySet()){
                boolean hasPendingQLIs = false;
                for(SBQQ__QuoteLine__c qli : quoteIdQLIsMap.get(quoteId) ){
                    if(!qli.Pricing_Ready_for_QuoteLetter_cb__c){
                        hasPendingQLIs = true;
                    }
                }
                if(!hasPendingQLIs){
                    quoteIdsForQuoteLetter.add(quoteId);
                }
            }
            if(quoteIdsForQuoteLetter.size() > 0){
                Map<id,SBQQ__Quote__c> quotesMap = new Map<Id,SBQQ__Quote__c>([SELECT id,Name,Pricing_End_Customer_Account__r.Name,Pricing_End_Customer_Name__c,Pricing_Project_Name_Nm__c,Pricing_Account_Name__c,Pricing_Program_Type_Nm__c,SBQQ__Account__c,Pricing_Account_Simplified_Name__c FROM SBQQ__Quote__c WHERE Id IN :quoteIdsForQuoteLetter]);
                if(quotesMap.size() > 0){
                    generateLetters(quotesMap);
                }
            }
        }
    }
    
    private static void generateLetters(Map<id,SBQQ__Quote__c> quotesMap){
        //To add version number for Quote Letter.
        Map<id,Decimal> quoteIdToVerisonMap = new Map<id,Decimal>();
        for(SBQQ__QuoteDocument__c doc:[select id,SBQQ__Quote__r.name,SBQQ__Quote__c,SBQQ__Version__c from SBQQ__QuoteDocument__c where SBQQ__Quote__c IN: quotesMap.keySet() order by CreatedDate desc]){
            if(quoteIdToVerisonMap.containsKey(doc.SBQQ__Quote__c) ){
                if(doc.SBQQ__Version__c > quoteIdToVerisonMap.get(doc.SBQQ__Quote__c)){   
                    quoteIdToVerisonMap.put(doc.SBQQ__Quote__c,doc.SBQQ__Version__c);
                }
            }
            else{   
                quoteIdToVerisonMap.put(doc.SBQQ__Quote__c,doc.SBQQ__Version__c);
            }
        }
        for(String quoteId : quotesMap.keySet()){
            QuoteProposalModel model = new QuoteProposalModel();
            String endCustomer = (quotesMap.get(quoteId).Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote)?quotesMap.get(quoteId).Pricing_End_Customer_Account__r.Name:quotesMap.get(quoteId).Pricing_End_Customer_Name__c;
            model.quoteId = quoteId;             
            SBQQ__Quote__c quote = quotesMap.get(quoteId); 
            model.templateId = quotesMap.get(quoteId).Pricing_Program_Type_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote?Label.Pricing_FI_QuoteLetterEmailNotificationTemplate:Label.Pricing_Quote_Template;
            String name = quote.Name+'-'+endCustomer+'-'+quote.Pricing_Project_Name_Nm__c+'-'+quote.Pricing_Account_Simplified_Name__c;
            //name length should not be greater than 77 characters as the limit is 80 characters for the field.
            name = (quoteIdToVerisonMap.get(quoteId) == null || quoteIdToVerisonMap.get(quoteId) < 9) ? name.left(77) : name.left(76);
            name +='-v'+(quoteIdToVerisonMap.get(quoteId)!=null ? (quoteIdToVerisonMap.get(quoteId) +1):1);
            model.name = name;
            if(!test.isRunningTest()){
                String jobId = saveQuoteDocument(model);
            }            
        }
    }
    
    public static String saveQuoteDocument(QuoteProposalModel context) {
        return SBQQ.ServiceRouter.save('SBQQ.QuoteDocumentAPI.Save', JSON.serialize(context));
    } 
    
    public static void getAccountIdToRecordMap(Set<Id> accountIdSet){
        for(Account acc:[SELECT Id, Name, Core_Customer_Aggregation_Type__c, Core_Unified_Intermediate_Customer_Name__c,Core_Unified_Global_Customer_Name__c,Core_Unified_Intermdt_Customer_2_Name__c 
                         FROM Account WHERE id IN:accountIdSet]){
                             accountIdtoRecordMap.put(acc.Id, acc);
                         }
    }
}