/****************************************************************************************************
Apex Class Name : PSG_ManagePricebookController
Version         : 1.0 
Created Date    : 26/02/2021
Function        : Controller class for psg_ManagePriceBooks LWC component.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijay                    26/02/2021                Created
*****************************************************************************************************/
public with sharing class PSG_ManagePricebookController {
    
    /*********************************************************************************************************************
    *Method Name : updatePricebookEntries
    *Created Date: 26/02/2021
    *Author: Vijay
    *Description : To update all the price book entries
    **************************************************************************************************************************/
    @AuraEnabled
    public static string updatePricebookentries(list<pricebookEntriesWrapper> pbeWrapperforUpdate) {
        try {
            list<pricebookentry> pbeforUpdate = new list<pricebookentry>();
            Map<string,pricebookEntry> priceBookEntryIdToPbeMap = new Map<string,pricebookEntry>();
            for(pricebookEntriesWrapper pbeWrap :pbeWrapperforUpdate){
                pricebookEntry pbeObj = new pricebookEntry();
                pbeObj.Id = pbeWrap.Id;
                if(pbeWrap.unitPrice != null){ 
                    pbeObj.unitPrice = pbeWrap.unitPrice;
                }
                if(pbeWrap.distyCost != null)    
                    pbeObj.price_disty_cost__c = pbeWrap.distyCost;
                
                if(pbeWrap.speed != null)    
                    pbeObj.core_cpq_speed_nbr__c =pbeWrap.speed;
                
                if(pbeWrap.multipleQty != null)    
                    pbeObj.core_cpq_multiple_order_quantity__c =pbeWrap.multipleQty;
                
                if(pbeWrap.minimumQty !=null)    
                    pbeObj.core_cpq_minimum_order_qty__c = pbeWrap.minimumQty;
                
                
                pbeforUpdate.add(pbeObj);
                priceBookEntryIdToPbeMap.put(pbeObj.Id,pbeObj);
            }
            update pbeforUpdate;
            List<core_cpq_list_price__c> lpforUpdate = new List<core_cpq_list_price__c>();
            for(core_cpq_list_price__c listPriceUpdate : [Select Id, core_cpq_minimum_order_qty__c,core_cpq_multiple_order_quantity__c,Pricebookentry__c from core_cpq_list_price__c WHERE Pricebookentry__c IN: priceBookEntryIdToPbeMap.KeySet()]){
                if(priceBookEntryIdToPbeMap.get(listPriceUpdate.Pricebookentry__c).core_cpq_minimum_order_qty__c != null)
                    listPriceUpdate.core_cpq_minimum_order_qty__c = priceBookEntryIdToPbeMap.get(listPriceUpdate.Pricebookentry__c).core_cpq_minimum_order_qty__c;
                if(priceBookEntryIdToPbeMap.get(listPriceUpdate.Pricebookentry__c).core_cpq_multiple_order_quantity__c != null)
                    listPriceUpdate.core_cpq_multiple_order_quantity__c = priceBookEntryIdToPbeMap.get(listPriceUpdate.Pricebookentry__c).core_cpq_multiple_order_quantity__c;
                if(priceBookEntryIdToPbeMap.get(listPriceUpdate.Pricebookentry__c).price_disty_cost__c != null)
                    listPriceUpdate.price_disty_cost_amt__c = priceBookEntryIdToPbeMap.get(listPriceUpdate.Pricebookentry__c).price_disty_cost__c;
                if(priceBookEntryIdToPbeMap.get(listPriceUpdate.Pricebookentry__c).core_cpq_minimum_order_qty__c != null || priceBookEntryIdToPbeMap.get(listPriceUpdate.Pricebookentry__c).core_cpq_multiple_order_quantity__c != null || priceBookEntryIdToPbeMap.get(listPriceUpdate.Pricebookentry__c).price_disty_cost__c != null)
                    lpforUpdate.add(listPriceUpdate);
            }
            update lpforUpdate;
            return 'Success: updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }
    
    /*********************************************************************************************************************
    *Method Name : updateListPrices
    *Created Date: 26/02/2021
    *Author: Vijay
    *Description : To update all the list price
    **************************************************************************************************************************/
    @AuraEnabled
    public static string updateListPrices(list<listPriceWrapper> lpWrapperforUpdate) {
        try {
            list<core_cpq_list_price__c> lpforUpdate = new list<core_cpq_list_price__c>();
            for(listPriceWrapper lpWrap :lpWrapperforUpdate){
                core_cpq_list_price__c lbObj = new core_cpq_list_price__c();
                lbObj.Id = lpWrap.Id;
                if(lpWrap.unitPrice != null)    
                    lbObj.core_cpq_list_price_amt__c = lpWrap.unitPrice;
                
                if(lpWrap.lbound != null)    
                    lbObj.core_cpq_lowerbound_qty__c = lpWrap.lbound;
                
                if(lpWrap.Ubound != null)    
                    lbObj.core_cpq_upperbound_qty__c =lpWrap.Ubound;
                
                lpforUpdate.add(lbObj);
            }
            update lpforUpdate;
            return 'Success: updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }
    
    /*********************************************************************************************************************
    *Method Name : getPricebookEntries
    *Created Date: 26/02/2021
    *Author: Vijay
    *Description : Prepares PriceBookEntry Wrapper for PriceBookEntry records and returns the wrapper list.
    **************************************************************************************************************************/
    @AuraEnabled(Cacheable = true)
    Public static List<pricebookEntriesWrapper> getPricebookEntries(string strPriceBookId,string strProductName){
        List<pricebookEntriesWrapper> pbeList = new List<pricebookEntriesWrapper>();
        if(string.isNotEmpty(strProductName)){
            string strProdName = '%' + strProductName + '%';
            for(PricebookEntry pbe : [SELECT Id,isActive,PriceBook2Id,Product2.core_opn__c,Product2.isActive,Name,
                                      Product2.Name,UnitPrice, price_disty_cost__c,core_cpq_minimum_order_qty__c,
                                      core_cpq_multiple_order_quantity__c,core_cpq_speed_nbr__c,Product2Id , core_cpq_opn_txt__c
                                      FROM PricebookEntry WHERE isActive = true and Pricebook2Id =:strPriceBookId and 
                                      (product2.Name Like: strProdName or product2.core_opn__c Like : strProdName) and 
                                      Product2.core_opn__c != null ORDER BY Name ASC limit :1000]){
                if(pbe.product2.core_opn__c != null){
                    pricebookEntriesWrapper pbeWrap = new pricebookEntriesWrapper();
                    pbeWrap.product = pbe.product2.core_opn__c;
                    pbeWrap.opn = pbe.Product2.core_opn__c;
                    pbeWrap.prodName = pbe.Product2.Name;
                    pbeWrap.prodUrl='/'+pbe.Product2Id;
                    pbeWrap.prodActive = pbe.Product2.isActive;
                    pbeWrap.unitPrice = pbe.UnitPrice;
                    pbeWrap.isActive = pbe.isActive;
                    pbeWrap.distyCost = pbe.price_disty_cost__c;
                    pbeWrap.speed = pbe.core_cpq_speed_nbr__c;
                    pbeWrap.multipleQty = pbe.core_cpq_multiple_order_quantity__c;
                    pbeWrap.minimumQty = pbe.core_cpq_minimum_order_qty__c;
                    pbeWrap.Id = pbe.Id;                          
                    pbeList.add(pbeWrap);
                }
                
            }
            return pbeList;
        }else{
            if(string.isNotEmpty(strPriceBookId)){
                for(PricebookEntry pbe : [SELECT Id,isActive,PriceBook2Id,Product2.core_opn__c,Product2.isActive,Name,Product2.Name,UnitPrice, price_disty_cost__c,
                                          core_cpq_minimum_order_qty__c,core_cpq_multiple_order_quantity__c,core_cpq_speed_nbr__c,Product2Id , core_cpq_opn_txt__c 
                                          FROM PricebookEntry WHERE isActive = true and Pricebook2Id =:strPriceBookId and Product2.core_opn__c != null 
                                          ORDER BY Product2.core_opn__c ASC LIMIT 15]){
                    if(pbe.product2.core_opn__c != null){
                        pricebookEntriesWrapper pbeWrap = new pricebookEntriesWrapper();
                        pbeWrap.product = pbe.product2.core_opn__c;
                        pbeWrap.opn = pbe.Product2.core_opn__c;
                        pbeWrap.prodName = pbe.Product2.Name;
                        pbeWrap.prodUrl='/'+pbe.Product2Id;
                        pbeWrap.prodActive = pbe.Product2.isActive;
                        pbeWrap.unitPrice = pbe.UnitPrice;
                        pbeWrap.isActive = pbe.isActive;
                        pbeWrap.distyCost = pbe.price_disty_cost__c;
                        pbeWrap.speed = pbe.core_cpq_speed_nbr__c;
                        pbeWrap.multipleQty = pbe.core_cpq_multiple_order_quantity__c;
                        pbeWrap.minimumQty = pbe.core_cpq_minimum_order_qty__c;
                        pbeWrap.Id = pbe.Id;                          
                        pbeList.add(pbeWrap);
                    }
                    
                }
            }
            return pbeList;
        }
    }
    
    /*********************************************************************************************************************
    *Method Name : getListPrice
    *Created Date: 26/02/2021
    *Author: Vijay
    *Description : Prepares wrapper for core_cpq_list_price__c records and returns the wrapper list.
    **************************************************************************************************************************/
    @AuraEnabled(Cacheable = true)
    Public static List<listPriceWrapper> getListPrice(string strPriceBookId,string strProductName,string strPriceBookEntryId){
        List<listPriceWrapper> lpList = new List<listPriceWrapper>();
        
        if(String.isNotEmpty(strPriceBookEntryId)){
            //String strProdName = '%' + strProductName + '%';
            for(core_cpq_list_price__c lp : [SELECT Id,core_cpq_lowerbound_qty__c,core_cpq_list_price_amt__c,core_cpq_product_opn_txt__c,core_cpq_product_name__c,
                                             core_cpq_upperbound_qty__c,Pricebookentry__c	FROM core_cpq_list_price__c WHERE Pricebookentry__c =: strPriceBookEntryId 
                                             ORDER BY core_cpq_lowerbound_qty__c, core_cpq_upperbound_qty__c limit 2000]){
                listPriceWrapper lpWrap = new listPriceWrapper();
                lpWrap.opn = lp.core_cpq_product_opn_txt__c;
                lpWrap.priceBookEntry = lp.Pricebookentry__c;
                lpWrap.lbound = lp.core_cpq_lowerbound_qty__c;
                lpWrap.Ubound =lp.core_cpq_upperbound_qty__c;
                lpWrap.unitPrice =lp.core_cpq_list_price_amt__c;
                lpWrap.range = lp.core_cpq_lowerbound_qty__c + ' - ' + lp.core_cpq_upperbound_qty__c ;
                if(lp.core_cpq_upperbound_qty__c == null){
                    lpWrap.range = '> ' +lp.core_cpq_lowerbound_qty__c; 
                }
                lpWrap.Id  =  lp.Id;
                lpList.add(lpWrap);
            }
        }
        return lpList;
    }
    
    /*********************************************************************************************************************
    *Method Name : getPriceList
    *Created Date: 26/02/2021
    *Author: Vijay
    *Description : Returns all the PSG pricebooks.
    **************************************************************************************************************************/
    @AuraEnabled(Cacheable = true)
    public static list<pricebook2> getPriceList(){
        try {
            return  [SELECT Name FROM Pricebook2 WHERE core_cpq_program__c = 'PSG'];            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    /**************************************WRAPPER CLASSES***************************************************************/
    public class pricebookEntriesWrapper{
        @AuraEnabled public Boolean isActive{get;set;}
        @AuraEnabled public string opn{get;set;}
        @AuraEnabled public string prodName{get;set;}
        @AuraEnabled public string prodUrl{get;set;}
        @AuraEnabled public Boolean prodActive{get;set;}
        @AuraEnabled public Decimal distyCost{get;set;}
        @AuraEnabled public Decimal unitPrice{get;set;}
        @AuraEnabled public Decimal speed{get;set;}
        @AuraEnabled public Decimal multipleQty{get;set;}
        @AuraEnabled public Decimal minimumQty{get;set;}
        @AuraEnabled public String product{get;set;}
        @AuraEnabled public ID Id{get;set;}
    }
    
    public class listPriceWrapper{
        @AuraEnabled public string opn{get;set;}
        @AuraEnabled public String priceBookEntry{get;set;}
        @AuraEnabled public Decimal lbound{get;set;}
        @AuraEnabled public Decimal Ubound{get;set;}
        @AuraEnabled public Decimal unitPrice{get;set;}
        @AuraEnabled public string range{get;set;}
        @AuraEnabled public ID Id{get;set;}
    }
    
}