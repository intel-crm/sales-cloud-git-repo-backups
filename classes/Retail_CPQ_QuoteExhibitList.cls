public class Retail_CPQ_QuoteExhibitList {
    //used to fectchRecordTypes in NewQuoteLineButton Component
    public static Map<Id, String> recordtypemap;
    @AuraEnabled        
    public static Map<Id, String> fetchRecordTypeValues(String objectName){

        List<Schema.RecordTypeInfo> recordtypes = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfos();    

        recordtypemap = new Map<Id, String>();

        for(RecordTypeInfo rt : recordtypes){

            if(rt.getName() != 'Master' && rt.getName().trim() != '')
                if((rt.getName()).contains('Retail')){
                    recordtypemap.put(rt.getRecordTypeId(), rt.getName());
                }
        }        

        return recordtypemap;
    }
    

    
        /*@AuraEnabled(cacheable=true)
    public static productWrapper getProducts(String quoteId){  
        System.debug('quoteId'+ quoteId);
        Set<String> prSet = New Set<String>();
        List<SBQQ__QuoteLine__c> QuotelineList =[select id,Name,SBQQ__Product__r.Name, SBQQ__Product__r.Core_Product_Series__c, SBQQ__Product__r.Core_Processor_Number_Nm__c,P2C_Deal_Type__c from SBQQ__QuoteLine__c where P2C_Deal_Type__c ='RSA' and SBQQ__Quote__c =:quoteId];
        for(SBQQ__QuoteLine__c ql :QuotelineList ){
          prSet.add(ql.SBQQ__Product__r.Name) ;
        }
        System.debug('QuotelineList'+QuotelineList);
        productWrapper ow = new productWrapper();  
        ow.productList = [Select Id, Name,P2C_Deal_Type__c, Core_Product_Org__c, Core_Product_Type__c ,Core_Processor_Number_Nm__c,Core_Product_Family__c, Core_Sales_Visible_Flag__c , Core_Hierarchy_ID__c, Core_Group_Code_Short_Name__c, IsActive, Core_Product_Name_EPM_ID__c,Core_Product_Series__c from Product2 where Core_Product_Series__c IN: prSet AND P2C_Deal_Type__c = 'IVR'];    
       // ow.productList = [Select Id, Name,P2C_Deal_Type__c, Core_Product_Org__c, Core_Product_Type__c ,Core_Processor_Number_Nm__c,Core_Product_Family__c, Core_Sales_Visible_Flag__c , Core_Hierarchy_ID__c, Core_Group_Code_Short_Name__c, IsActive, Core_Product_Name_EPM_ID__c from Product2 where Core_Product_Org__c = 'Sales'and P2C_Deal_Type__c = 'IVR' and Core_Sales_Visible_Flag__c = True and (Core_Group_Code_Short_Name__c like '%CCG%' ) and IsActive = true LIMIT 50];  
        List<Quote_Exhibit_List__c> exhibitList = [select id, Quote__c, Product__c from Quote_Exhibit_List__c where Quote__c =: quoteId];
        Set<Id> selectedOppIdSet = new Set<Id>();  
        for(Quote_Exhibit_List__c qxl : exhibitList ){
            selectedOppIdSet.add(qxl.Product__c);
        }
        //selectedOppIdSet.add(ow.productList[0].Id);    
        //selectedOppIdSet.add(ow.productList[1].Id);   
        System.debug('selectedOppIdSet90'+ selectedOppIdSet); 
        ow.selectedIdSet = selectedOppIdSet;  
        return ow;  
    }*/
    
    public class productWrapper{  
        @AuraEnabled public List<Product2> productList {get; set;}  
        @AuraEnabled public set<Id> selectedIdSet {get; set;}  
    }

}