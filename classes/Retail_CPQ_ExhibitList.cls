public without sharing  class Retail_CPQ_ExhibitList {
        //added for fetching ChildIVR for each RSA in QL
    @AuraEnabled(cacheable=false)
        public static productWrapper getIVRProducts(String quoteLineId){
        System.debug('quoteLineId'+ quoteLineId);
        Set<Id> masterListProductSet = New Set<Id>();
        Set<String> pdtIdSet = New Set<String>();
        Set<Id> selectedIdSet = New Set<Id>();
        List<Product2> productList = New List <Product2>(); 
        productWrapper ow = new productWrapper();  
        List<SBQQ__QuoteLine__c> QuotelineList =[select id,Name,core_cpq_Product_Group_Name__c,SBQQ__Product__c, SBQQ__Quote__c,SBQQ__Product__r.Name from SBQQ__QuoteLine__c  WHERE Id =:quoteLineId];
       	String quoteId = QuotelineList[0].SBQQ__Quote__c;
		String productGroupName = QuotelineList[0].core_cpq_Product_Group_Name__c;
       
		
		if(!QuotelineList.isEmpty()){
			if(productGroupName != '' & productGroupName != null){
				productGroupName =  productGroupName.trim();
				for(Product2 pdtRec :[Select Id, Name, Core_Product_Org__c, Core_Product_Type__c ,Core_Processor_Number_Nm__c,Core_Product_Family__c, Core_Sales_Visible_Flag__c , Core_Hierarchy_ID__c,
					Core_Group_Code_Short_Name__c, IsActive, Core_Product_Name_EPM_ID__c,Core_Product_Series__c from Product2 
					where id IN (SELECT core_cpq_product__c from Core_CPQ_Master_Exhibit_List__c WHERE core_cpq_product_group__r.Name = :productGroupName)]){
					masterListProductSet.add(pdtRec.Id);				
				}
				for(Core_CPQ_Quote_Exhibit_List__c qxl :[select id, core_cpq_quote__c, core_cpq_product__c from Core_CPQ_Quote_Exhibit_List__c where core_cpq_quote__c =: quoteId AND core_cpq_quote_line__c =: quoteLineId]){
					pdtIdSet.add(qxl.core_cpq_product__c);
					selectedIdSet.add(qxl.core_cpq_product__c);
				}
                masterListProductSet.addAll(selectedIdSet);
                productList = [Select Id, Name, Core_Product_Org__c, Core_Product_Type__c ,Core_Processor_Number_Nm__c,Core_Product_Family__c, Core_Sales_Visible_Flag__c , Core_Hierarchy_ID__c,
								Core_Group_Code_Short_Name__c, IsActive, Core_Product_Name_EPM_ID__c,Core_Product_Series__c from Product2 where Id IN :masterListProductSet];
				
			}else{

				for(Product2 pdtRec :[Select Id, Name, Core_Product_Org__c,Core_Processor_Number_Nm__c, Core_Product_Type__c ,Core_Product_Series__c, Core_Sales_Visible_Flag__c , Core_Hierarchy_ID__c, Core_Group_Code_Short_Name__c, IsActive, Core_Product_Name_EPM_ID__c from Product2 where Core_Product_Org__c = 'Sales' and Core_Sales_Visible_Flag__c = True and Core_Hierarchy_ID__c = '43' and Core_Product_Type__c = 'Processors' and (Core_Group_Code_Short_Name__c like '%CCG%' ) and  Core_Product_Series__c =:QuotelineList[0].SBQQ__Product__r.Name]){
					//prSet.add(pdtRec.Id);
					productList.add(pdtRec);
									
				}
				for(Core_CPQ_Quote_Exhibit_List__c qxl :[select id, core_cpq_quote__c, core_cpq_product__c from Core_CPQ_Quote_Exhibit_List__c where core_cpq_quote__c =: quoteId AND core_cpq_quote_line__c =: quoteLineId]){
					//pdtIdSet.add(qxl.core_cpq_product__c);
					selectedIdSet.add(qxl.core_cpq_product__c);
				}
                System.debug('selectedIdSetPdt--->'+selectedIdSet);
				
			}
		}


		ow.selectedIdSet = selectedIdSet;
        ow.productList = productList;  
            System.debug('ow.productList--->'+ow.productList);
		System.debug('ow.selectedIdSet--->'+ow.selectedIdSet);
        return ow;
    }
    //added for saving ChildIVR for each RSA in QL
    //added to Save QuoteExhibit List in Quote
    @AuraEnabled
    public static List<Core_CPQ_Quote_Exhibit_List__c> saveChildIVRquoteExhibitList(List<Product2> ProductList,Id quoteLineId){
        System.debug('ProductList'+ ProductList);
        List<SBQQ__QuoteLine__c> QuotelineList =[select id,Name,SBQQ__Product__c, SBQQ__Quote__c,SBQQ__Product__r.Name from SBQQ__QuoteLine__c where Id =:quoteLineId];
        List<Core_CPQ_Quote_Exhibit_List__c> quoteExhibitList = new List<Core_CPQ_Quote_Exhibit_List__c>();
        String quoteId = QuotelineList[0].SBQQ__Quote__c;
        Set<Id> productIdSet = new Set<Id>();
        
        List<Core_CPQ_Quote_Exhibit_List__c> deletequoteExhibitList = New List<Core_CPQ_Quote_Exhibit_List__c>();
        List<Core_CPQ_Quote_Exhibit_List__c> exhibitList = [select id, core_cpq_quote__c,core_cpq_quote_line__c, core_cpq_product__c from Core_CPQ_Quote_Exhibit_List__c where core_cpq_quote__c =: quoteId AND core_cpq_quote_line__c =: quoteLineId];
        
        for(Core_CPQ_Quote_Exhibit_List__c qxl : exhibitList ){
            productIdSet.add(qxl.core_cpq_product__c);
            System.debug('productIdSet-------->'+productIdSet); 
        } 
        for(Product2 pdt : ProductList){
            if(productIdSet.contains(pdt.Id)){
                productIdSet.remove(pdt.Id);
                System.debug('productIdSet-------->'+productIdSet);
            }
            else{
                Core_CPQ_Quote_Exhibit_List__c quoteExRec = new Core_CPQ_Quote_Exhibit_List__c();
                quoteExRec.core_cpq_quote__c = quoteId;
				quoteExRec.core_cpq_quote_line__c = quoteLineId;
                quoteExRec.core_cpq_product__c = pdt.Id;
                quoteExhibitList.add(quoteExRec);
                System.debug('quoteExhibitList --->'+quoteExhibitList);
            }
        }
        for(Core_CPQ_Quote_Exhibit_List__c exl : exhibitlist){
            if(productIdSet.contains(exl.core_cpq_product__c)){
                deletequoteExhibitList.add(exl);
                System.debug('deletequoteExhibitList-------->'+deletequoteExhibitList);
            }
        }
        System.debug('ProductList'+ quoteExhibitList);
        if (!quoteExhibitList.isEmpty()) {
            insert quoteExhibitList;
        }
         
        if (!deletequoteExhibitList.isEmpty()) {
            Delete deletequoteExhibitList;
        }
        return quoteExhibitList;
    }
    @AuraEnabled
    public static productWrapper getAllRetailProducts(String groupId){
        //String query ='SELECT ';
        //query+=String.join(new List<String>(Product2.sObjectType.getDescribe().fields.getMap().keySet()),',');
        //query+=' FROM Product2';
        //return Database.query(query);
        Set<Id> SelectedProIdSet = new Set<Id>();
        productWrapper ow = new productWrapper();
        List<Product2> productIVRList = [Select Id, Name,Core_Processor_Number_Nm__c,Core_Product_Series__c, Core_Product_Org__c, Core_Product_Type__c , Core_Sales_Visible_Flag__c , Core_Hierarchy_ID__c, Core_Group_Code_Short_Name__c, IsActive, Core_Product_Name_EPM_ID__c from Product2 where Core_Product_Org__c = 'Sales' and Core_Sales_Visible_Flag__c = True and Core_Hierarchy_ID__c = '43' and Core_Product_Type__c = 'Processors' and (Core_Group_Code_Short_Name__c like '%CCG%') and Core_Processor_Number_Nm__c!=null  LIMIT 800  ];
        List<Core_CPQ_Master_Exhibit_List__c> masterList=[SELECT id,name,core_cpq_product__c from Core_CPQ_Master_Exhibit_List__c WHERE core_cpq_product_group__c =:groupId];
        for(Core_CPQ_Master_Exhibit_List__c masterRec:masterList){
            SelectedProIdSet.add(masterRec.core_cpq_product__c);
        }
        List<AggregateResult> productSeriesList = [Select Core_Product_Series__c, count(id) from Product2 where Core_Product_Org__c = 'Sales' and Core_Sales_Visible_Flag__c = True and Core_Hierarchy_ID__c = '43' and Core_Group_Code_Short_Name__c like '%CCG%' and Core_Product_Type__c = 'Processors' group by Core_Product_Series__c];
        Set<String> generationFilter =new Set<String>();
        for(AggregateResult agr:productSeriesList){
            String productSeries=(String)(agr.get('Core_Product_Series__c'));
            if(productSeries.containsIgnoreCase('Generation')){
                String genNo = productSeries.split(' ')[0] +' Generation';
                generationFilter.add(genNo);
            }
        }
        ow.generationFilterSet = generationFilter;
        ow.selectedIdSet = SelectedProIdSet;
        ow.productList = productIVRList;
        return ow;
	}
    @AuraEnabled
    public static List<Core_CPQ_Master_Exhibit_List__c> saveMasterExList(List<Product2> ProductList,Id productGrpId){
        System.debug('ProductList'+ ProductList);
        //List<SBQQ__QuoteLine__c> QuotelineList =[select id,Name,SBQQ__Product__c, SBQQ__Quote__c,SBQQ__Product__r.Name,P2C_Deal_Type__c from SBQQ__QuoteLine__c where P2C_Deal_Type__c ='RSA' and Id =:quoteLineId];
        List<Core_CPQ_Master_Exhibit_List__c> masterExList = new List<Core_CPQ_Master_Exhibit_List__c>();
        //String quoteId = QuotelineList[0].SBQQ__Quote__c;
        Set<Id> productIdSet = new Set<Id>();
        List<Core_CPQ_Master_Exhibit_List__c> ExList = New List<Core_CPQ_Master_Exhibit_List__c>();
        List<Core_CPQ_Master_Exhibit_List__c> deleteMasterExhibitList = New List<Core_CPQ_Master_Exhibit_List__c>();
        List<Core_CPQ_Master_Exhibit_List__c> exhibitList = [SELECT id,name,core_cpq_product__c from Core_CPQ_Master_Exhibit_List__c WHERE core_cpq_product_group__c =:productGrpId];
        
        for(Core_CPQ_Master_Exhibit_List__c qxl : exhibitList ){
            productIdSet.add(qxl.core_cpq_product__c);
            System.debug('productIdSet-------->'+productIdSet);
            
        } 
        for(Product2 pdt : ProductList){
            if(productIdSet.contains(pdt.Id)){
                productIdSet.remove(pdt.Id);
                System.debug('productIdSet-------->'+productIdSet);
            }
            
            else{
                Core_CPQ_Master_Exhibit_List__c masterExRec = new Core_CPQ_Master_Exhibit_List__c();
                masterExRec.core_cpq_product_group__c = productGrpId;
                masterExRec.core_cpq_product__c = pdt.Id;
                //masterExRec.Product_Grouping__c='aBg0q0000004GUBCA2';
                ExList.add(masterExRec);
                System.debug('QuoteExhibitList --->'+ExList);
            }
        }
        for(Core_CPQ_Master_Exhibit_List__c exl : exhibitlist){
            if(productIdSet.contains(exl.core_cpq_product__c)){
                deleteMasterExhibitList.add(exl);
                System.debug('deleteQuoteExhibitList-------->'+deleteMasterExhibitList);
            }
            
        }
        System.debug('ProductList'+ ExList);
        if (!ExList.isEmpty()) {
            
            insert ExList;
        }
         
        if (!deleteMasterExhibitList.isEmpty()) {
            
            Delete deleteMasterExhibitList;
        }
        return ExList;
    }
    public class productWrapper{  
        @AuraEnabled public List<Product2> productList {get; set;}  
        @AuraEnabled public set<Id> selectedIdSet {get; set;}  
        @AuraEnabled public set<String> generationFilterSet {get; set;}
    }  

}