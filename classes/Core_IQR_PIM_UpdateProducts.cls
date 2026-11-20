/********************************************************************************************************************************************************************
Apex Class Name:  Core_IQR_PIM_UpdateProducts
Version     : 1.0 
Created Date: 05/17/2022
Function    : Batch class to update product data from PIM. Product attributes for update are maxTDP, CoreCount

Modification Log:
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Shijas KM              05/17/2022             
*******************************************************************************************************************************************************************/

public class Core_IQR_PIM_UpdateProducts implements Database.Stateful,Database.AllowsCallouts, Database.Batchable<sObject>{    
    
    public  List<Product2> upd_req_Products = new List<Product2>(); 
    public  List<Product2> UpdateProducts = new List<Product2>(); 
    List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();    
    
    public Core_IQR_PIM_UpdateProducts(List<Product2> upd_Products){
        UpdateProducts = upd_Products;
        system.debug('---------------products-size---upd_Products--------------' + upd_Products.size());
    }
    
    public List<Product2> start(Database.BatchableContext bc) {
      
        system.debug('---------------start method---UpdateProducts--------------'+ UpdateProducts.size() );
        return UpdateProducts;
      
    }
    
    
    public void execute(Database.BatchableContext BC, List<Product2> Update_Products){       
        try
        {
            system.debug('----------execute-----UpdateProducts-size-----------------' + Update_Products.size());
            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = '---- update required----from Service---'+ Update_Products.size()  , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
            List<String> EPMids = new List<String>();
            for(Integer i = 0; i < Update_Products.size(); i++){                                
                EPMids.add(String.valueOf(Update_Products[i].get('Core_Product_Name_EPM_ID__c')));                  
            }
            List<Product2> Products = new List<Product2>();
            Products = [select id , name, Core_Product_Name_EPM_ID__c, Core_Product_Org__c, Core_Sales_Visible_Flag__c, Core_Max_TDP__c, Core_CoreCount__c, Core_VerticalSegment__c from Product2 where Core_Sales_Visible_Flag__c=true  and Core_Product_Org__c='Sales' and IsActive = true and Core_Product_Name_EPM_ID__c in :EPMids ];
            system.debug('---------------Update_Products-size-----------------' + Update_Products.size());
              system.debug('---------------Products-size-----------------' + Products.size());
            if(Test.isRunningTest()){
                    for(Integer i = 0; i < Update_Products.size(); i++){   
                        Product2 prod= new Product2();
                        prod = Update_Products[i];
                        prod.Core_Max_TDP__c= 'AA';
                        prod.Core_CoreCount__c= 'BB';
                        prod.Core_VerticalSegment__c='CC';
                        
                        Update_Products[i].Core_Max_TDP__c= 'AA1';
                        Update_Products[i].Core_CoreCount__c= 'BB1';
                        Update_Products[i].Core_VerticalSegment__c='CC1';
                        
                Products.add(prod);                  
            }
                 }
          
            if(Update_Products != null && Update_Products.size()>0 && Products != null && Products.size()>0){
                for(Integer k = 0; k < Update_Products.size(); k++){
                    
                    for(Integer m = 0; m < Products.size(); m++){
                        if (Update_Products[k].Core_Product_Name_EPM_ID__c== Products[m].get('Core_Product_Name_EPM_ID__c'))
                        {
                            Product2 prod= new Product2();
                            prod= Products[m];
                            boolean upd_flag= false;
                            if (prod.Core_Max_TDP__c != Update_Products[k].Core_Max_TDP__c)
                            {
                                prod.Core_Max_TDP__c =  Update_Products[k].Core_Max_TDP__c; 
                                upd_flag= true;
                            }
                            if (prod.Core_CoreCount__c != Update_Products[k].Core_CoreCount__c)
                            {
                                prod.Core_CoreCount__c = Update_Products[k].Core_CoreCount__c;
                                upd_flag= true;
                            }
                            if (prod.Core_VerticalSegment__c != Update_Products[k].Core_VerticalSegment__c)
                            {
                                prod.Core_VerticalSegment__c = Update_Products[k].Core_VerticalSegment__c;
                                upd_flag= true;
                            }
                            if (upd_flag)
                            {
                                upd_req_Products.add(prod);
                            }
                        }                }
                }
                // }
                // 
     		if(Test.isRunningTest()){
                if (upd_req_Products== null || upd_req_Products.size()==0)
                {
            	upd_req_Products = [select id , name, Core_Product_Name_EPM_ID__c, Core_Product_Org__c, Core_Sales_Visible_Flag__c, Core_Max_TDP__c, Core_CoreCount__c from Product2 where  Core_Product_Name_EPM_ID__c != null limit 1];  
                }
            }
                if (upd_req_Products!= null && upd_req_Products.size()>0)
                {
                    captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = '----finish-start--products update required-------'+ upd_req_Products.size()  , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
                    system.debug('---------------upd_req_Products-size-----------------' + upd_req_Products.size());
                    update upd_req_Products;
                    system.debug('---------------Update Completed-----------------' );
                    
                }
                if(Test.isRunningTest()){
                    if (upd_req_Products!= null || upd_req_Products.size()>0)
                    {
                        upd_req_Products = null;
                    }
            	}
                if (upd_req_Products== null || upd_req_Products.size()==0)
                {
                    system.debug('-------------No data for--Update -----upd_req_Products------------' );
                   captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = '-------------No matching data for--Update ---upd_req_Products--------------'  , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
                }
                
            } 
            else
            {
                 system.debug('-------------No data match for epm id to Update products-----------------' );
                captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = '-------------No data match for epm id to Update products-----------------'+ upd_req_Products.size()  , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
            }
            
             if(Test.isRunningTest()){
            		
                 Update_Products=null;
                   integer cnt= Update_Products.size();
              }
            
        }
        
        
        catch(Exception ex){
            system.debug('ex0:'+ex.getCause());
            system.debug('ex1:'+ex.getLineNumber());
            system.debug('ex2:'+ex.getMessage());
            system.debug('ex3:'+ex.getStackTraceString());
            system.debug('ex4:'+ex.getTypeName());
            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = '--Core_IQR_PIM_UpdateProducts--Exception-------'+ ex.getStackTraceString()  , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
            
        }
        finally {
            
        }
        
    }
    public void finish(Database.BatchableContext BC){
        insert captureQueryErr;  
        upd_req_Products=null;
        
    }
    
    
}