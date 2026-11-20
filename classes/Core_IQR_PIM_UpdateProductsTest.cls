@isTest
public class Core_IQR_PIM_UpdateProductsTest {  

@testSetup static void setup(){

		Product2 product2Obj = new Product2 (
			Core_Product_Name_EPM_ID__c = 'test value', 
			Core_Product_Org__c ='Sales', 
			Core_Sales_Visible_Flag__c = TRUE, 
			Core_Max_TDP__c = 'test value', 
			Core_CoreCount__c = 'test value', 
			Name = 'test value'
		);
		insert product2Obj;
    
    
       Product2 p3 = new Product2();
        p3.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
        p3.Core_Product_Org__c = 'Sales';
        p3.Core_Unique_ID__c='1239292929;122573;122570;86065;35125';
        p3.Core_Product_Name_EPM_ID__c='1239292929';
        p3.isActive=True;
        p3.Core_Hierarchy_Name__c ='Valid Product Hierarchy';
        p3.Core_Hierarchy_ID__c = '43';
        insert p3;
		 
	}

	@isTest static void testMethod1() {
         Test.startTest(); 
         List<Product2> upd_req_Products = new List<Product2>();
		 Database.executeBatch(new Core_IQR_PIM_UpdateProducts(upd_req_Products),1);
         Test.stopTest(); 
	}

	@isTest static void testMethod2() {
		// code_block	
	}    


    @isTest static void Core_IQR_PIM_UpdateProductsTest() {
        Test.startTest(); 
        List<Product2> upd_req_Products = new List<Product2>();
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>(); 
        
        upd_req_Products = [select id , name, Core_Product_Name_EPM_ID__c, Core_Product_Org__c, Core_Sales_Visible_Flag__c, Core_Max_TDP__c, Core_CoreCount__c from Product2 where Core_Sales_Visible_Flag__c=true  and Core_Product_Org__c='Sales' and IsActive = true limit 10 ];
        system.debug('qqqq' + upd_req_Products.size());    
        Database.executeBatch(new Core_IQR_PIM_UpdateProducts(upd_req_Products),1);
         Test.stopTest(); 
        
    }
    
    public static List<Product2> DataSetUp(){
        Product2 p = new Product2();
        p.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)';
        p.Core_Product_Org__c = 'Sales';
        p.Core_Unique_ID__c='120458;122573;122570;86065;35125';
        p.Core_Product_Name_EPM_ID__c='120458';
        p.isActive=True;
        insert p;
        
        Product2 p1 = new Product2();
        p1.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
        p1.Core_Product_Org__c = 'IPS';
        p1.Core_Unique_ID__c='123808;122573;122570;86065;35125';
        p1.Core_Product_Name_EPM_ID__c='123808';
        p1.isActive=True;
        insert p1;
        
        Product2 p2 = new Product2();
        p2.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
        p2.Core_Product_Org__c = 'Sales';
        p2.Core_Unique_ID__c='1239292929;122573;122570;86065;35125';
        p2.Core_Product_Name_EPM_ID__c='1239292929';
        p2.isActive=True;
        insert p2;
        
        Product2 p3 = new Product2();
        p3.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
        p3.Core_Product_Org__c = 'Sales';
        p3.Core_Unique_ID__c='1239292929;122573;122570;86065;35125';
        p3.Core_Product_Name_EPM_ID__c='1239292929';
        p3.isActive=True;
        p3.Core_Hierarchy_Name__c ='Valid Product Hierarchy';
        p3.Core_Hierarchy_ID__c = '43';
        insert p3;
        List<Product2> Products = new List<Product2>();
        
        Products.add(p);
        Products.add(p1);
        Products.add(p2);
        Products.add(p3);
        insert Products;
        
        
        
        return   Products;      
    }
     

}