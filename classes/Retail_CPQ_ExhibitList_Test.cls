@isTest
public class Retail_CPQ_ExhibitList_Test {
	@testSetup
    public static void setUpData(){
        SBQQ.TriggerControl.disable();       
        List<Product2> productList =Retail_CPQ_TestDataSetup.createRSAproducts();
        productList[0].Core_Product_Series__c='10th Generation';
        insert productList;
                 
        List<SBQQ__Quote__c> quoteList = New List <SBQQ__Quote__c>();
        Account acc = Retail_CPQ_TestDataSetup.createAccount();
        acc.Core_MDF_CoMarketingActive__c = true;
        insert acc;
        SBQQ__Quote__c q = Retail_CPQ_TestDataSetup.createQuoteRecord();
        
        q.core_cpq_Account__c = acc.id;
        // Test.startTest();
        q.RecordTypeId =  PSG_Utility.getRecordTypeId('SBQQ__Quote__c', label.Retail_CPQ_Quote_Save_RecordType);
        insert q;
        SBQQ__QuoteLine__c ql = Retail_CPQ_TestDataSetup.createQuoteLineRSA();
        ql.RecordTypeId =  PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'Retail_Quote_Line_Base_RSA');
        ql.SBQQ__Product__c=productList[0].Id;
        ql.SBQQ__Quote__c=q.Id;
       
        insert ql;
        List<Core_CPQ_Product_Group__c> productGroupingList= Retail_CPQ_TestDataSetup.createProductGrouping(1);
        insert productGroupingList;
        List<Core_CPQ_Master_Exhibit_List__c> masterExList = new List<Core_CPQ_Master_Exhibit_List__c>();
        List<Core_CPQ_Quote_Exhibit_List__c> quoteExList = new List<Core_CPQ_Quote_Exhibit_List__c>();
        for(Integer i=0;i<productList.size()-2;i++){
            Core_CPQ_Master_Exhibit_List__c obj =new Core_CPQ_Master_Exhibit_List__c();
            obj.core_cpq_product__c=productList[i].Id;
            obj.core_cpq_product_group__c=productGroupingList[0].id;
            masterExList.add(obj);
        }
        
        insert masterExList;
        //creating quote exhibit List 
        for(Integer i=0;i<productList.size()-2;i++){
            Core_CPQ_Quote_Exhibit_List__c obj =new Core_CPQ_Quote_Exhibit_List__c();
            obj.core_cpq_product__c=productList[i].Id;
            obj.core_cpq_quote__c=q.id;
            obj.core_cpq_quote_line__c=ql.id;
             
            quoteExList.add(obj);
        }
        insert quoteExList;
   }
    @isTest
    public static void testFunctionality(){
        List<Product2> productList=[SELECT id,name from Product2 LIMIT 5];
        List<Core_CPQ_Product_Group__c> productGroupingList=[Select id,name from Core_CPQ_Product_Group__c ];
        List<SBQQ__QuoteLine__c> lstquoteLineList=[Select Id from SBQQ__QuoteLine__c];
        test.startTest();
        Retail_CPQ_ExhibitList.getAllRetailProducts(productGroupingList[0].id);
        Retail_CPQ_ExhibitList.saveMasterExList(productList,productGroupingList[0].id);
        Retail_CPQ_ExhibitList.getIVRProducts(lstquoteLineList[0].Id);
        Retail_CPQ_ExhibitList.saveChildIVRquoteExhibitList(productList,lstquoteLineList[0].Id);

        test.stopTest();
    }
}