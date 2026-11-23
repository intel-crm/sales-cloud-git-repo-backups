/*********************************************************************************************************************
Class Name    : Pilot_Sales_QuoteUtility
Version       : 1.0
Created Date  : Sep 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shalini Kumari            30/09/2021              Pilot Project for testing framework.
* ************************************************************************************************************************************************/
public  without sharing class Pilot_Sales_QuoteUtility {
 //Counter to avoid recalling future method.
    public static Integer counter ;
    
    /***********************************************************************
    Name: Mitesh Dedhia
    Date: June 2021
    Parameters: List<SBQQ__Quote__c>
    High Level Description: US1034569 - Common method
    ************************************************************************/
    public static void afterUpdateQuoteOperation(List<SBQQ__Quote__c> quoteList){
        
        Set<Id> quoteIds = new Set<Id>();
        Id contractId;
        Id originalQuoteId;
        
        Set<Id> deleteOppQuoteIds = new Set<Id>();
       
        if(counter == null || counter == 0){
            counter=0;
            
            //Iterate over Amended Quote List and get it Id and Master Contract
            for(SBQQ__Quote__c amendedquoteRecord: quoteList){
                if(amendedquoteRecord.SBQQ__Type__c == 'Amendment' &&
                    amendedquoteRecord.SBQQ__Opportunity2__c == null &&
                    amendedquoteRecord.Pricing_Quote_Program_Nm__c == 'PSG'){
            
                    quoteIds.add(amendedquoteRecord.id);
                
                    if(amendedquoteRecord.SBQQ__MasterContract__c != null){
                        contractId = amendedquoteRecord.SBQQ__MasterContract__c;
                    }
                }
            }
           
            //Required if Contract is Amended for first time then need to fetch only Original Quote
            //for(SBQQ__Quote__c originalQuote : [Select id,SBQQ__MasterContract__r.SBQQ__Quote__c 
            //                                    FROM SBQQ__Quote__c 
            //                                    WHERE Id IN :  quoteIds 
            //                                    LIMIT 1] ){
            for(SBQQ__Quote__c originalQuote : [Select id,SBQQ__MasterContract__r.SBQQ__Quote__c 
                                                FROM SBQQ__Quote__c 
                                                WHERE Id IN :  quoteIds 
                                                LIMIT 1] ){                                       
                originalQuoteId = originalQuote.SBQQ__MasterContract__r.SBQQ__Quote__c;
                
            }
        }
            
        if(quoteIds != null && contractId != null){
            updatePreviousAmendedAndOriginalQuotes(quoteIds,contractId,originalQuoteId); 
        }
        
        if(quoteIds != null){
            deleteAmendedOpportunity(quoteIds);
        }
    }
    /* public static void updateQuoteforRenewalAment(List<SBQQ__Quote__c> quoteList){
        For(SBQQ__Quote__c quoteRecord:[Select Id, SBQQ__MasterContract__r.SBQQ__Quote__r.SBQQ__Distributor__c ,
                                        core_cpq_original_quote__r.core_cpq_business_unit_nm__c,SBQQ__Distributor__c,
                                        SBQQ__MasterContract__r.SBQQ__Quote__r.core_cpq_business_unit_nm__c ,
                                        core_cpq_distributor_disty_view_nm__c,core_cpq_business_unit_nm__c,
                                        Sales_Renewed_from_Contract_Id__r.SBQQ__Quote__r.core_cpq_business_unit_nm__c,
                                        Sales_Renewed_from_Contract_Id__r.SBQQ__Quote__r.SBQQ__Distributor__c
                                        FROM SBQQ__Quote__c where id IN: quoteList and (SBQQ__Type__c ='Renewal' OR SBQQ__Type__c ='Amendment')]){
                                            if(quoteRecord.SBQQ__Type__c =='Renewal'){
                                                quoteRecord.SBQQ__Distributor__c=quoteRecord.Sales_Renewed_from_Contract_Id__r.SBQQ__Quote__r.SBQQ__Distributor__c;
                                                quoteRecord.core_cpq_business_unit_nm__c =quoteRecord.Sales_Renewed_from_Contract_Id__r.SBQQ__Quote__r.core_cpq_business_unit_nm__c;
                                            }
                                            if(quoteRecord.SBQQ__Type__c =='Amendment'){
                                                quoteRecord.SBQQ__Distributor__c=quoteRecord.SBQQ__MasterContract__r.SBQQ__Quote__r.SBQQ__Distributor__c ;
                                                quoteRecord.core_cpq_business_unit_nm__c = quoteRecord.SBQQ__MasterContract__r.SBQQ__Quote__r.core_cpq_business_unit_nm__c;
                                            }
                                        }
    }
    */
    /***********************************************************************************
    Name: Mitesh Dedhia
    Date: June 2021
    Parameters: Set<Id>,Id,Id
    High Level Description: US1034569 - Inactivate Original and Previous Amended Quotes
    ***********************************************************************************/
    public static void updatePreviousAmendedAndOriginalQuotes(Set<Id> quoteIdSet,Id contractId,Id originalQuoteId){
        
        Set<Id> quoteIdsforInactive = new Set<Id>();
        List<SBQQ__Quote__c> updatequoteList = new List<SBQQ__Quote__c>();
        System.debug('quoteIdsforInactive>>>>'+quoteIdsforInactive);
        //for(SBQQ__Quote__c quoteRecord : [Select                
        //                    id,core_cpq_active_cb__c,Name,SBQQ__MasterContract__c,
        //                    SBQQ__MasterContract__r.SBQQ__Quote__c 
        //                    FROM SBQQ__Quote__c 
        //                    WHERE SBQQ__MasterContract__c =: contractId 
        //                    AND Id NOT IN : quoteIdSet]){
         for(SBQQ__Quote__c quoteRecord : [Select                
                            id,core_cpq_active_cb__c,Name,SBQQ__MasterContract__c,
                            SBQQ__MasterContract__r.SBQQ__Quote__c 
                            FROM SBQQ__Quote__c 
                            WHERE SBQQ__MasterContract__c =: contractId 
                            AND Id NOT IN : quoteIdSet]){
                	quoteIdsforInactive.add(quoteRecord.id);
                if(quoteRecord.SBQQ__MasterContract__r.SBQQ__Quote__c!= null){
                    quoteIdsforInactive.add(quoteRecord.SBQQ__MasterContract__r.SBQQ__Quote__c);
                }
            }
        //quoteIdsforInactive == null &&
        if( quoteIdsforInactive.isEmpty() && originalQuoteId != null){
            quoteIdsforInactive.add(originalQuoteId);
        }
        
        if(quoteIdsforInactive != null){
            for(Id id : quoteIdsforInactive){
                SBQQ__Quote__c quoteRecord = new SBQQ__Quote__c();
                quoteRecord.id = Id;
                quoteRecord.core_cpq_active_cb__c = false;
                updatequoteList.add(quoteRecord);
            }
        }
        counter++;
        
        if(updatequoteList!=null){
            update updatequoteList;
        }
    }
    
    /***********************************************************************
    Name: Mitesh Dedhia
    Date: June 2021
    Parameters: Set<Id>
    High Level Description: US1034569 - Delete Amended Opportunity 
    ************************************************************************/
    @future
    public static void deleteAmendedOpportunity(Set<Id> quoteIdSet){
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        //for(SBQQ__Quote__c amendedquoteRecord: [Select id,SBQQ__MasterContract__c,
        //                                        SBQQ__MasterContract__r.Sales_Amendment_Opportunity_Id__c
        //                                        FROM SBQQ__Quote__c 
        //                                        WHERE id IN : quoteIdSet 
        //                                        AND SBQQ__MasterContract__c != null
        //                                        AND SBQQ__MasterContract__r.Sales_Amendment_Opportunity_Id__c != null]){
                                                    
         for(SBQQ__Quote__c amendedquoteRecord: [Select id,SBQQ__MasterContract__c,
                                                SBQQ__MasterContract__r.Sales_Amendment_Opportunity_Id__c
                                                FROM SBQQ__Quote__c 
                                                WHERE id IN : quoteIdSet 
                                                AND SBQQ__MasterContract__c != null
                                                AND SBQQ__MasterContract__r.Sales_Amendment_Opportunity_Id__c != null]){
                                                    
                                                    if(amendedquoteRecord.SBQQ__MasterContract__r.Sales_Amendment_Opportunity_Id__c!=null){
                                                        Opportunity oppRecord = new Opportunity();
                                                        oppRecord.id = amendedquoteRecord.SBQQ__MasterContract__r.Sales_Amendment_Opportunity_Id__c;
                                                        opportunityList.add(oppRecord);
                                                    }                                          
                                                }
        //counter++;
        if(opportunityList != null){
            delete opportunityList;
        }
    }
}