@isTest
public class Retail_CPQ_TestDataSetup {
     private static Id getSObjectRecordTypeId(String objectAPIName,String recordTypeName){
        Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = new Map<String,Schema.RecordTypeInfo>();
        sObject obj;
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectAPIName);
        
        if(objType != null){
            obj = objType.newsObject();  
            Schema.DescribeSObjectResult sObjDesc = obj.getSObjectType().getDescribe(); 
            
            if(sObjDesc != null){  
                recordTypeInfoMap = sObjDesc.getRecordTypeInfosByDeveloperName();  
            }
            
            if(recordTypeInfoMap.containsKey(recordTypeName)){
                return recordTypeInfoMap.get(recordTypeName).getRecordTypeId();
            }else{
                return null;
            }
        }        
        return null;
    }
    
   public static Account createAccount(){
        Account acc = new Account(); 
        acc.RecordTypeId = getSObjectRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);
        acc.Name='Test Account Parent'+Integer.valueOf(Math.random()*1000);
        acc.Core_Account_Type__c='Retailer';
        acc.Industry='Education';
        acc.Core_Sub_Industry__c='Student';
        acc.BillingCity='Swans Island City ';
        acc.BillingState = 'ME';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = '1234 Victoria Court ABCHE';
        acc.BillingPostalCode = '04685';
        acc.Core_Sub_Geo__c='NAR';
        acc.Core_Geo__c = 'APJ';
        return acc;
        
    }
    
    public static Core_MDF_Bank__c createBankRecord(){
        Core_MDF_Bank__c bank = new Core_MDF_Bank__c();
        bank.Name = 'Test bank';
        bank.Core_MDF_Bank_Alias_Name__c = 'Test';
        bank.Core_MDF_Supplier_Name__c = 'test8% VAT';
        bank.Core_MDF_Supplier_Number__c = '1234567891';
        bank.Core_MDF_Effective_Date__c = System.today();
        bank.Core_MDF_Bank_Account_Number__c = '7575' ;
        bank.Core_MDF_Intel_Company_Code__c =  '150';
        bank.Core_MDF_Payment_Method_Code__c = 'C';
        bank.Core_MDF_Bank_Beneficiary_Name__c = 'test8% VAT';
        bank.Core_MDF_Program__c = 'Core_MDF_Retail_Marketing_Funds';
        bank.Core_MDF_Tax_codes_cd__c = 'V3';
        return bank ;
    }
    
public static SBQQ__Quote__c createQuoteRecord(){
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
       quote.RecordTypeId=getSObjectRecordTypeId('SBQQ__Quote__c', Label.Retail_CPQ_Quote_New_RecordType);//Retail_CPQ_Quote_New_RecordType
        quote.core_cpq_Status__c = 'In-Progress';
        quote.core_cpq_name_nm__c='Test quote';
        quote.SBQQ__StartDate__c=date.today();
        quote.SBQQ__EndDate__c=date.today()+365;
        return quote;
    } 
    
public static List<Product2> createRSAproducts()
    {
        List<Product2> productlist = new List<Product2>();
        
        Integer numOfProducts;
        for(numOfProducts=0;numOfProducts<5;numOfProducts++){
            productlist.add(new Product2(Name = 'Test Product' + numOfProducts,IsActive = true,Core_OPN__c = '1SG00'+ numOfProducts,Core_Sales_Visible_Flag__c = true,Core_Product_Org__c = 'Sales',Core_Group_Code_Short_Name__c = 'CCG',Core_Product_Type__c='Processors',Core_Processor_Number_Nm__c='Z250'+numOfProducts,Core_Product_Family__c='Intel Test Processor Series '+numOfProducts,Core_Hierarchy_ID__c='43',Core_Product_Series__c='Intel Celeron Processors J456')); 
        }
        return productlist;
    }
    public static List<Core_CPQ_Product_Group__c> createProductGrouping(Integer numOfProducts){
        List<Core_CPQ_Product_Group__c> productGroupingList=new List<Core_CPQ_Product_Group__c>();
        for(Integer i=0;i<numOfProducts;i++){
            productGroupingList.add(new Core_CPQ_Product_Group__c(Name='Custom Test Product'+numOfProducts));
        }
        return productGroupingList;
    }
  
    

 public static SBQQ__QuoteLine__c createQuoteLineRSA(){
        
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quantity__c=30;
      
        return ql;
    }    
    
public static SBQQ__DiscountTier__c creatediscounttier(){
SBQQ__DiscountTier__c dt1 = new SBQQ__DiscountTier__c();
                    dt1.Name='Tier1';
                    dt1.SBQQ__LowerBound__c=1;
                    dt1.SBQQ__UpperBound__c=11;
                    //dt1.SBQQ__Schedule__c=ds.Id;
                    dt1.SBQQ__Number__c =1;

return dt1;

}


public static SBQQ__DiscountSchedule__c creatediscountschedule(){
SBQQ__DiscountSchedule__c ds = new SBQQ__DiscountSchedule__c();
               
                ds.SBQQ__UsePriceForAmount__c=true;
                ds.SBQQ__PriceScale__c=2;
                ds.SBQQ__Type__c='Slab';
                ds.SBQQ__OverrideBehavior__c='All';
                ds.SBQQ__DiscountUnit__c='Price';
				return ds;
                
	}
    
    

}