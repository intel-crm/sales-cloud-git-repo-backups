global class Product3_Core_IQR_IntelProductData implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
    public List<String> L4ProductCategoryIdListGlobal = new List<String>();
    public Map<String, String> topLevelCategories = new Map<String, String>();
    List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
    global Iterable<String> start(Database.BatchableContext bc) {
       List<String> emptyList = new List<String>();
       emptyList.add('void');
       Iterable<String> nullIterable  = emptyList;
        return nullIterable;
    }
    global void execute(Database.BatchableContext BC, List<String> scope){
        try{
        Http http = new Http();
        HttpRequest requestAccessToken = new HttpRequest();
        List<String> L4ProductCategoryIdList = new List<String>();
        //Get Token using Client Id and Client Secret
        requestAccessToken.setEndpoint(Product3_Endpoints__c.getValues('authtokenURL').Endpoint__c);
        requestAccessToken.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        requestAccessToken.setBody(Product3_Endpoints__c.getValues('authtoken').Endpoint__c);
        requestAccessToken.setMethod('POST');
        requestAccessToken.setTimeout(40000);
        HttpResponse responseAccessToken = http.send(requestAccessToken); 
        if(responseAccessToken.getStatusCode() == 200) {
            HttpRequest request = new HttpRequest();
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(responseAccessToken.getBody());
            String acessToken = (String)results.get('access_token');
            //Get Top Level category Ids for Processors, Ethernet Products, Memory and Storage 
            //request.setEndpoint('https://apis-sandbox.intel.com/pim/v1/services/categories?localeGeoId=en-US&limit=1000&fields=id,parentId,rawName');
            request.setEndpoint(Product3_Endpoints__c.getValues('hierarchies').Endpoint__c);
            //system.debug('endpoints:gg:1:'+Product3_Endpoints__c.getValues('hierarchies').Endpoint__c);
            request.setHeader('Authorization', 'Bearer '+acessToken);
            request.setMethod('GET');
            request.setTimeout(60000);
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200) {
                Map<String, Object> topLevelResults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> categories = (List<Object>)topLevelResults.get('categories');
                for(Object category: categories){
                    Map<String, Object> root = (Map<String, Object>)category;
                    if((String)root.get('parentId')=='root'&& ((String)root.get('rawName') == 'Chipsets'))
                      {
                          topLevelCategories.put((String)root.get('id'), (String)root.get('name'));
                    }
                }
                 List<String> tempKeys = new List<String>();
                for(String key: topLevelCategories.keySet()){
                    tempKeys.add(key);
                }
                String categoryId = String.join(tempKeys,',');
                system.debug('categoryId:'+categoryId);
                if(topLevelCategories!=null){
                        HttpRequest requestL4 = new HttpRequest();
                        //Get 1st 1K records with offset=1
                    	requestL4.setEndpoint((Product3_Endpoints__c.getValues('products').Endpoint__c)+'&categoryId='+categoryId+'&offset=1');
                    	requestL4.setHeader('Authorization', 'Bearer '+acessToken);
                        requestL4.setMethod('GET');
                        requestL4.setTimeout(60000);
                        HttpResponse responseL4 = http.send(requestL4);
                        if(responseL4.getStatusCode() == 200) {
                            Map<String, Object> L4ProductResults = (Map<String, Object>) JSON.deserializeUntyped(responseL4.getBody());
                            Map<String, Object> metadata = (Map<String, Object>)L4ProductResults.get('_metadata');
                            Integer count = (Integer)metadata.get('count');
                            Integer numOfRemainingInteration = count/1000;
                            List<Object> L4Products = (List<Object>)L4ProductResults.get('products');
                            for(Object L4Product: L4Products){
                                Map<String, Object> l4ProductDetails = (Map<String, Object>)L4Product;
                                L4ProductCategoryIdList.add((String)l4ProductDetails.get('id'));                                
                            } 
                            //Get remaining records with 1K per iteration
                            for(Integer i=2; i<2+numOfRemainingInteration; i++){
                                requestL4.setEndpoint((Product3_Endpoints__c.getValues('products').Endpoint__c)+'&categoryId='+categoryId+'&offset='+i);
                                system.debug('endpoints:g::'+(Product3_Endpoints__c.getValues('products').Endpoint__c)+'&categoryId='+categoryId+'&offset='+i);
                                responseL4 = http.send(requestL4);
                                if(responseL4.getStatusCode() == 200) {
                                    L4ProductResults = (Map<String, Object>) JSON.deserializeUntyped(responseL4.getBody());
                                    L4Products = (List<Object>)L4ProductResults.get('products');
                                    for(Object L4Product: L4Products){
                                        Map<String, Object> l4ProductDetails = (Map<String, Object>)L4Product;
                                        L4ProductCategoryIdList.add((String)l4ProductDetails.get('id'));                                
                                    }
                                }
                            }
                            system.debug('L4ProductCategoryIdListSize:'+L4ProductCategoryIdList.size()); 
                        }
                }
            }else{
                system.debug('responseError:'+response.getBody());
            }
        }       
        else{
            system.debug('responseAccessTokenError:'+responseAccessToken.getBody());
            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Authentication Issue', Core_Message__c = 'IQR_Product Get L1 to L4 authentication Issue', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='CoreIQRIntelProductData', Core_When__c = System.now()));
        }     
        L4ProductCategoryIdListGlobal = L4ProductCategoryIdList;
       //L4ProductCategoryIdListGlobal.addAll(L4ProductCategoryIdList);
    }catch(Exception ex){
             system.debug('ex0:'+ex.getCause());
             system.debug('ex1:'+ex.getLineNumber());
             system.debug('ex2:'+ex.getMessage());
             system.debug('ex3:'+ex.getStackTraceString());
             system.debug('ex4:'+ex.getTypeName());
         }
    }
    global void finish(Database.BatchableContext BC){
        List<String> asdad= new List<String>();
        asdad.add('120487');
       
        if(Test.isRunningTest()){
            List<String> testIdList = new List<String>();
            testIdList.add('120487');
            testIdList.add('125900');
            //Database.executeBatch(new Product3_Core_IQR_FetchL5ProductDetails(testIdList, topLevelCategories), 90);
        }
        else{
            try{
                //Database.executeBatch(new Product3_Core_IQR_FetchL5ProductDetails(L4ProductCategoryIdListGlobal, topLevelCategories), 90);
            }catch(Exception e){
               captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Batch execution Issue', Core_Message__c = 'IQR_Product Get L1 to L4 Issue', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Product3_Core_IQR_IntelProductData', Core_When__c = System.now()));
            }
        }
        //pass topLevelCategories as reference
        }
}