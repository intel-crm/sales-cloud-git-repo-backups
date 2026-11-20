/********************************************************************************************************************************************************************
Apex Class Name:  Core_IQR_PIM_IntelProductData
Version     : 1.0 
Created Date: 05/17/2022
Function    : Batch class to update product data from PIM. Product attributes for update are maxTDP, CoreCount

Modification Log:
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Shijas KM              05/17/2022       

*******************************************************************************************************************************************************************/
global class Core_IQR_PIM_IntelProductData implements Database.Batchable<String>,Database.AllowsCallouts, Database.Stateful, Schedulable {
    
    List<Product2> upd_req_Products = new List<Product2>(); 
    List<Product2> upd_Products = new List<Product2>(); 
    List<Map<String, Object>> data = new List<Map<String, Object>>();
    Integer numOfRemainingInteration = 0;
    List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
    String str_response= '';
    String acessToken =''; 
    boolean customAPILoadFlag  = false; 
    datetime customAPILoaddate = null;
    
    
    global Iterable<String> start(Database.BatchableContext bc) { 
        List<String> loopList = new List<String>(); 
        for(Integer i = 1; i <= 110; i++){
                loopList.add(String.valueOf(i));
            }         
    
            customAPILoadFlag = Core_IQR_Endpoints__c.getValues('Product_PIM_Integration_IQR').IQR_PIM_Custom_DataLoad__c;
        
            if (customAPILoadFlag)
            {
                customAPILoaddate = Core_IQR_Endpoints__c.getValues('Product_PIM_Integration_IQR').IQR_PIM_Custom_DataLoad_Date__c;
            }
       
            system.debug(customAPILoadFlag);
            system.debug(customAPILoaddate);
            
            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = '------Core_IQR_PIM_IntelProductData-----start-method--------'  , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
               if(Test.isRunningTest()){ 
                   loopList = new List<String>();
                    for(Integer i = 1; i <= 1; i++){
                        loopList.add(String.valueOf(i));             
                    }             
                    customAPILoadFlag =true;
                    customAPILoaddate =System.today()-2;   
                }
        
        Iterable<String> loops  = loopList;
        return loops;
    }
    global void execute(Database.BatchableContext bc, List<String> scope){
        
        Http http = new Http();
        HttpRequest requestAccessToken = new HttpRequest();
        HttpRequest request = new HttpRequest();
        Map<String, Object>  ProductResults = new Map<String, Object>();
        Map<String, Object> metadata = new Map<String, Object>();
        Integer scope_loop=0;
        HttpResponse response =new HttpResponse();
        for(String scope_item : scope){ 
            scope_loop = Integer.valueOf(scope_item);
            system.debug('--------scope_item------' + scope_item);
            
            try{
                DateTime todaysDate = System.today()-1;           
                
                String todaysDateStr='';
                if (customAPILoadFlag)
                {
                    todaysDateStr = customAPILoaddate.format('yyyy-MM-dd');
                    todaysDateStr =todaysDateStr + 'T00:00:00Z';
                }
                else
                {
                    todaysDateStr = todaysDate.format('yyyy-MM-dd');
                    todaysDateStr =todaysDateStr + 'T00:00:00Z';
                }
                
                
                System.debug(todaysDateStr);
                
                
                
                captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = '----execute---method----STARTED----DateTime for API---> ' + todaysDateStr , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
                Decimal count =0;
                
                system.debug('---------------PIM products update MaxTDP and CoreCount started------------------');
                if (scope_loop==1 )
                {
                    
                    
                    //system.debug('---------------products without MaxTDP and CoreCount------------------' + upd_Products.size());
                    //Get Token using Client Id and Client Secret
                    requestAccessToken.setEndpoint(Core_IQR_Endpoints__c.getValues('authtokenURL').Endpoint__c);
                    requestAccessToken.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    requestAccessToken.setBody(Core_IQR_Endpoints__c.getValues('authtoken').Endpoint__c);
                    requestAccessToken.setMethod('POST');
                    requestAccessToken.setTimeout(40000);            
                    HttpResponse responseAccessToken = http.send(requestAccessToken);
                    if(responseAccessToken.getStatusCode() == 200) { 
                        system.debug('---------------responseAccessToken.getStatusCode() == 200------------------' );
                        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(responseAccessToken.getBody());
                        acessToken = (String)results.get('access_token');            
                        //Get products and its MaxTDP and CoreCount            
                        request.setEndpoint((Core_IQR_Endpoints__c.getValues('Product_PIM_Integration_IQR').Endpoint__c)+'&offset=1&filters=updatedDateTime gt "' + todaysDateStr +'"');              
                        request.setHeader('Authorization', 'Bearer '+acessToken);
                        request.setMethod('GET');
                        request.setTimeout(60000);            
                        response = http.send(request);			
                        system.debug('---------------1st loop starts------------------' );
                        if(response.getStatusCode() == 200) {
                            system.debug('---------------1st loop starts---response 200---------------' );
                            str_response= response.getBody();
                            str_response= str_response.replace( '-', '' );
                            str_response= str_response.replace( '—', '' );
                            ProductResults = (Map<String, Object>) JSON.deserializeUntyped(str_response);
                            metadata = (Map<String, Object>)ProductResults.get('_metadata');
                            
                            count = (Integer)metadata.get('count');
                            if (count>0)
                            {
                                Decimal block = count/50; 
								numOfRemainingInteration = (Integer)block.round(System.RoundingMode.UP);
                            }                           
                          
                            system.debug('---------------numOfRemainingInteration------------------' + String.valueOf(numOfRemainingInteration));
                            system.debug('---------------count------------------' + String.valueOf(count));
                            system.debug('---------------ProductResults------------------' + ProductResults.size());
                            system.debug('---------------metadata------------------' + metadata.size());
                            
                            // data = new List<Map<String, Object>>();
                            for (Object instance : (List<Object>)ProductResults.get('products')){
                                data.add((Map<String, Object>)instance);   
                            } 
                        }			
                        response =new HttpResponse();
                        system.debug('---------------loop 1 data count ------------------' + data.size());   
                        for(Integer i = 0; i < data.size(); i++){
                            
                            string EPMid = String.valueOf(data[i].get('id'));
                            
                            Map<String, Object> attr = (Map<String, Object>)data[i].get('attributes');
                            Map<String, Object> maxTDP = (Map<String, Object>)attr.get('MaxTDP');
                            Map<String, Object> coreCount = (Map<String, Object>)attr.get('CoreCount');                   		
                            Map<String, Object> FilterVerticalSegment = (Map<String, Object>)attr.get('MarketSegment');
                            if(data[i].get('id')!=null ){   
                                Product2 prod= new Product2();
                                prod.Core_Product_Name_EPM_ID__c= String.valueOf(data[i].get('id'));
                                if (maxTDP!=null )
                                {
                                    prod.Core_Max_TDP__c = String.valueOf(maxTDP.get('value')); 
                                    
                                }
                                if (coreCount!=null )
                                {
                                    prod.Core_CoreCount__c = String.valueOf(coreCount.get('value'));
                                    
                                }
                                
                                if (FilterVerticalSegment!=null )
                                {
                                    prod.Core_VerticalSegment__c = String.valueOf(FilterVerticalSegment.get('value'));
                                    
                                }
                                upd_Products.add(prod);
                            }
                        }
                        
                        system.debug('--------loop 1-------products--count ----------------' + upd_Products.size());
                        captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = '---------------products------------------' + data.size() , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
                        //List<Map<String, Object>> data1 = new List<Map<String, Object>>();
                        // update upd_req_Products;
                        captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = '---Loop 1--products-update---count----' + upd_req_Products.size() , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
                        
                        system.debug('----------products updating on this batch for MaxTDP and CoreCount-----------' + upd_req_Products.size());
                        ProductResults= null;
                        metadata= null;
                    } 
                    else
                    {
                        captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = '------------------1st loop response error---------------------'  , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
                        system.debug('---------------1st loop response error------------------' );
                    }
                    
                   
                    system.debug('---------------1st loop ends------------------' );
                }
                 if(Test.isRunningTest()){ 
                     scope_loop=2;
                 }
                 system.debug('---------------numOfRemainingInteration-----------------' + numOfRemainingInteration);
                 system.debug('---------------scope_loop-----------------' + scope_loop);
                if (scope_loop>1 && scope_loop <= numOfRemainingInteration)
                {
                    
                    system.debug('---------------2nd for loop----start-------------scope_loop-' + scope_loop);
                    
                    
                    request.setEndpoint((Core_IQR_Endpoints__c.getValues('Product_PIM_Integration_IQR').Endpoint__c)+'&offset='+scope_loop + '&filters=updatedDateTime gt "' + todaysDateStr +'"');  
                    //  request.setEndpoint((Core_IQR_Endpoints__c.getValues('Product_PIM_Integration_IQR').Endpoint__c)+'&offset='+scope_loop);
                    request.setHeader('Authorization', 'Bearer '+acessToken);
                    request.setMethod('GET');
                    request.setTimeout(60000);  
                    HttpResponse  responsedata =new HttpResponse();
                    responsedata = new Http().send(request);              
                    if(responsedata.getStatusCode() == 200) {
                        
                        str_response= '';
                        str_response= responsedata.getBody();
                        str_response= str_response.replace( '-', '' );
                        str_response= str_response.replace( '—', '' );      
                        data = new List<Map<String, Object>>();
                        Map<String, Object> ProductResultsData = (Map<String, Object>) JSON.deserializeUntyped(str_response);
                        
                        //data = new List<Map<String, Object>>();
                        for (Object instance : (List<Object>)ProductResultsdata.get('products')){
                            data.add((Map<String, Object>)instance);
                        }  
                        str_response= '';
                        responsedata =new HttpResponse();
                        ProductResultsData= new Map<String, Object>();
                        system.debug('---------------products-size-----------------' + data.size());
                        captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c =  '---------------products-size-----------------' + data.size() , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
                        
                    }
                    else
                    {
                        captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = '------------------2nd loop response error---------------------'  , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
                        system.debug('---------------2nd loop response error------------------' );
                    }
                    
                    for(Integer i = 0; i < data.size(); i++){
                        
                        string EPMid = String.valueOf(data[i].get('id'));
                        
                        Map<String, Object> attr = (Map<String, Object>)data[i].get('attributes');
                        Map<String, Object> maxTDP = (Map<String, Object>)attr.get('MaxTDP');
                        Map<String, Object> coreCount = (Map<String, Object>)attr.get('CoreCount');
                        Map<String, Object> FilterVerticalSegment = (Map<String, Object>)attr.get('MarketSegment');
                        if(data[i].get('id')!=null ){   
                            Product2 prod= new Product2();
                            prod.Core_Product_Name_EPM_ID__c= String.valueOf(data[i].get('id'));
                            if (maxTDP!=null )
                            {
                                prod.Core_Max_TDP__c = String.valueOf(maxTDP.get('value')); 
                                
                            }
                            if (coreCount!=null )
                            {
                                prod.Core_CoreCount__c = String.valueOf(coreCount.get('value'));
                                
                            }
                            if (FilterVerticalSegment!=null )
                            {
                                prod.Core_VerticalSegment__c = String.valueOf(FilterVerticalSegment.get('value'));
                                
                            }
                            upd_Products.add(prod);
                        }
                    }  
                    
                    //}
                    
                    captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c =  '----upd_Products---size-------' + upd_Products.size() , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
                    system.debug('---------------2nd for loop----ends--------------');
                    
                 
                    str_response= '';
                }
            }
            
            catch(Exception ex){
                system.debug('-------------Exception----');
                system.debug('ex0:'+ex.getCause());
                system.debug('ex1:'+ex.getLineNumber());
                system.debug('ex2:'+ex.getMessage());
                system.debug('ex3:'+ex.getStackTraceString());
                system.debug('ex4:'+ex.getTypeName());
                captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Exception     '+ ex.getMessage() + ex.getStackTraceString() , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
            }
            finally {
                
            }
        }	
    }
    global void finish(Database.BatchableContext BC){
        try{
          
                if (upd_Products!=null && upd_Products.size()>0 )
                {
                    captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = '----data available to process Core_IQR_PIM_UpdateProducts-------' + upd_Products.size() , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
                    system.debug('---------------products passed to Core_IQR_PIM_UpdateProducts class------size-----------------' + upd_Products.size()); 
                    Database.executeBatch(new Core_IQR_PIM_UpdateProducts(upd_Products),10);
                }
                else
                {
                    system.debug('--------------no data available to process Core_IQR_PIM_UpdateProducts-----------' ); 
                    captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = '----no data available to process Core_IQR_PIM_UpdateProducts-------'  , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
                }
                        
        }catch(Exception e){
            system.debug('---------------ex-----------' + e.getMessage()); 
            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Exception    '+ e.getMessage() + e.getStackTraceString() , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
        }
        finally {
            insert captureQueryErr;         
        }
    }
  
    global void execute(SchedulableContext sc) {
        try
        {
            Id jobId=Database.executeBatch(new Core_IQR_PIM_IntelProductData());
            
        }
        catch(Exception e){
            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Exception    '+ e.getMessage() + e.getStackTraceString() , Core_Message__c = 'PIM products update MaxTDP and CoreCount ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_PIM_IntelProductData', Core_When__c = System.now()));
        }
        finally {
            
        }
    }
    
  
}