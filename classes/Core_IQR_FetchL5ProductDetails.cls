public class Core_IQR_FetchL5ProductDetails implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
    public List<String> L4ProductCategoryIdList = new List<String>();
    public Map<String, String> topLevelCategories = new Map<String, String>();
    List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();    
    
    public Core_IQR_FetchL5ProductDetails(List<String> L4ProductCategoryIdList, Map<String, String> topLevelCategories){
        this.L4ProductCategoryIdList = L4ProductCategoryIdList;
        this.topLevelCategories = topLevelCategories;
    }
    
    public Iterable<String> start(Database.BatchableContext bc) {
        Iterable<String> L4ProductCategoryIdIterable = L4ProductCategoryIdList;
        return L4ProductCategoryIdIterable;
    }
    
    public void execute(Database.BatchableContext BC, List<String> L4ProductCategoryIdList){
        try{
            
            ProductL5Details productDetailsClass =  new ProductL5Details();//Wrapper Class
            Http http = new Http();
            HttpRequest requestAccessToken = new HttpRequest();
            string l1id = null;
            string l2id = null;
            string l3id = null;
            string epmid = null;
            string l4id = null;
                       
            //Get Token using Client Id and Client Secret
            requestAccessToken.setEndpoint(Core_IQR_Endpoints__c.getValues('authtokenURL').Endpoint__c);
            requestAccessToken.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            requestAccessToken.setBody(Core_IQR_Endpoints__c.getValues('authtoken').Endpoint__c);
            requestAccessToken.setMethod('POST');
            requestAccessToken.setTimeout(40000);
            HttpResponse responseAccessToken = http.send(requestAccessToken);
            if(responseAccessToken.getStatusCode() == 200) {
                HttpRequest request = new HttpRequest();
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(responseAccessToken.getBody());
                String acessToken = (String)results.get('access_token');
                
                HttpRequest requestL5 = new HttpRequest();
                HttpResponse responseL5;
                List<Object> orderingInfoList;
                //Integer execCount=0;//dead code
                
                for(String L4ProductCategoryId: L4ProductCategoryIdList){
                    //Wrapper Class
                    ProductDetails prodDetails = new ProductDetails();
                    
                    orderingInfoList = null;
                    requestL5.setEndpoint((Core_IQR_Endpoints__c.getValues('products_id').Endpoint__c)+L4ProductCategoryId+'?localeGeoId=en-US');
                    requestL5.setHeader('Authorization', 'Bearer '+acessToken);
                    requestL5.setMethod('GET');
                    requestL5.setTimeout(60000);
                    responseL5 = http.send(requestL5);
                    if(responseL5.getStatusCode() == 200) {
                        
                        Map<String, Object> L5ProductResults = (Map<String, Object>) JSON.deserializeUntyped(responseL5.getBody());
                        system.debug('L5ProductResults::'+L5ProductResults.get('id'));
                        
                        //L4ProductId and Name-start
                        prodDetails.product_l4Id = String.valueOf(L5ProductResults.get('id'));
                        prodDetails.product_l4Name = (String)L5ProductResults.get('name');
                        l4id = String.valueOf(L5ProductResults.get('id'));
                       
                        //categories-start
                        for(Object category: (List<Object>)L5ProductResults.get('categories')){
                            if(topLevelCategories.containsKey((String)category)){
                                    
                                prodDetails.hierarchy_l1Id = (String)category;
                                prodDetails.hierarchy_l1Name = topLevelCategories.get((String)category);
                                
                                l1id = (String)category;//
                            }                             
                        }                         
                        ////categories-end
                        
                        //attributes-start
                        
                        Map<String, Object> attributesMap= (Map<String, Object>)L5ProductResults.get('attributes');
                        for(String key:attributesMap.keySet()){
                            if(key =='Filter-Family'){
                                Map<String, Object> l2Details = (Map<String, Object>)attributesMap.get(key);
                                prodDetails.hierarchy_l2Id = String.valueOf(l2Details.get('rawValue'));
                                prodDetails.hierarchy_l2Name = (String)l2Details.get('value');
                                
                                l2id = String.valueOf(l2Details.get('rawValue'));//
                            }
                            else if(key =='ProductGroup'){
                                
                                Map<String, Object> l3Details = (Map<String, Object>)attributesMap.get(key);
                               
                                prodDetails.hierarchy_l3Id = String.valueOf(l3Details.get('rawValue'));
                                prodDetails.hierarchy_l3Name = (String)l3Details.get('value');
                                
                                l3id = String.valueOf(l3Details.get('rawValue'));//
                            }
                            else if(key =='CodeNameText'){
                                
                                Map<String, Object> codeNameText = (Map<String, Object>)attributesMap.get(key);
                                //system.debug('attributes::codeNameText:'+codeNameText.get('rawValue')+'=>'+codeNameText.get('value'));
                                prodDetails.attribute_codeNameText_rawValue = String.valueOf(codeNameText.get('rawValue'));
                                prodDetails.attribute_codeNameText_value = (String)codeNameText.get('value');
                            }
                            else if(key =='ProcessorNumber'){
                                
                                Map<String, Object> processorNumber = (Map<String, Object>)attributesMap.get(key);
                                prodDetails.attribute_processorNumber_value = (String)processorNumber.get('value');
                            }
                            else if(key =='DriveCapacity'){     
                                
                                Map<String, Object> driveCapacity = (Map<String, Object>)attributesMap.get(key);
                                prodDetails.attribute_driveCapacity_value = (String)driveCapacity.get('value');
                                
                            }
                        }
                        ////attributes-end
                        
                        //orderinginfo-start
                        if(((Object)L5ProductResults.get('orderingInfo'))!=null ){
                            orderingInfoList = (List<Object>)L5ProductResults.get('orderingInfo');
                        }
                        
                        if(orderingInfoList!=null){
                            for(Object orderingInfo: orderingInfoList){//Extracting OrderingInfo details
                                ProductDetails prodDetailsOrderinginfo = new ProductDetails();
                                //cloning prodDetails details
                                prodDetailsOrderinginfo.product_l4Id = prodDetails.product_l4Id;
                                prodDetailsOrderinginfo.product_l4Name = prodDetails.product_l4Name;
                                prodDetailsOrderinginfo.hierarchy_l1Id = prodDetails.hierarchy_l1Id;
                                prodDetailsOrderinginfo.hierarchy_l1Name = prodDetails.hierarchy_l1Name;
                                prodDetailsOrderinginfo.hierarchy_l2Id = prodDetails.hierarchy_l2Id;
                                prodDetailsOrderinginfo.hierarchy_l2Name = prodDetails.hierarchy_l2Name;
                                prodDetailsOrderinginfo.hierarchy_l3Id = prodDetails.hierarchy_l3Id;
                                prodDetailsOrderinginfo.hierarchy_l3Name = prodDetails.hierarchy_l3Name;
                                prodDetailsOrderinginfo.attribute_codeNameText_rawValue = prodDetails.attribute_codeNameText_rawValue;
                                prodDetailsOrderinginfo.attribute_codeNameText_value = prodDetails.attribute_codeNameText_value;
                                prodDetailsOrderinginfo.attribute_processorNumber_value = prodDetails.attribute_processorNumber_value;
                                prodDetailsOrderinginfo.attribute_driveCapacity_value = prodDetails.attribute_driveCapacity_value;
                                Map<String, Object> orderInfoAttributeMap = (Map<String, Object>)orderingInfo; 
                                List<Object> orderInfoAttributeList = (List<Object>)orderInfoAttributeMap.get('attributes');
                                prodDetailsOrderinginfo.orderinginfo_mmid = (String)orderInfoAttributeMap.get('mmId');
                                prodDetailsOrderinginfo.orderinginfo_name = (String)orderInfoAttributeMap.get('name');
                                for(Object orderInfoAttribute:orderInfoAttributeList){
                                                                           
                                    Map<String, Object> orderInfoAttributeDetailsMap = (Map<String, Object>)orderInfoAttribute;
                                    if(((String)orderInfoAttributeDetailsMap.get('uniqueKey'))=='MaterialStatusCode'){
                                        //system.debug('orderInfoAttributeDetailsMap:'+orderInfoAttributeDetailsMap.get('value')); 
                                        prodDetailsOrderinginfo.orderinginfo_materialStatusCode_value = (String)orderInfoAttributeDetailsMap.get('value');
                                    }
                                    else if(((String)orderInfoAttributeDetailsMap.get('uniqueKey'))=='Division'){
                                         String divisionValue = (String)orderInfoAttributeDetailsMap.get('value');
                                        List<String> divisionValueSplitList = divisionValue.split(' ');
                                        prodDetailsOrderinginfo.orderinginfo_division_withoutbracket = divisionValueSplitList[0].trim();
                                        prodDetailsOrderinginfo.orderinginfo_division_withbracket = ((divisionValueSplitList[1].trim()).removeStart('(')).removeEnd(')');

                                    }
                                    else if(((String)orderInfoAttributeDetailsMap.get('uniqueKey'))=='Group'){
                                         String groupValue = (String)orderInfoAttributeDetailsMap.get('value');
                                        List<String> groupValueSplitList = groupValue.split(' ');
                                        prodDetailsOrderinginfo.orderinginfo_group_withoutbracket = groupValueSplitList[0].trim();
                                        prodDetailsOrderinginfo.orderinginfo_group_withbracket = ((groupValueSplitList[1].trim()).removeStart('(')).removeEnd(')');

                                    }
                                    else if(((String)orderInfoAttributeDetailsMap.get('uniqueKey'))=='EPMID'){
                                         prodDetailsOrderinginfo.orderinginfo_empid = (String)orderInfoAttributeDetailsMap.get('value');
                                        
                                        epmid = (String)orderInfoAttributeDetailsMap.get('value');//
                                        
                                        
                                    }
                                    else if(((String)orderInfoAttributeDetailsMap.get('uniqueKey'))=='OpCode'){
                                         prodDetailsOrderinginfo.orderinginfo_opcode = (String)orderInfoAttributeDetailsMap.get('value');
                                    }
                                    else if(((String)orderInfoAttributeDetailsMap.get('uniqueKey'))=='CustomIndicator'){
                                         prodDetailsOrderinginfo.orderinginfo_customindicator = (String)orderInfoAttributeDetailsMap.get('value');
                                    }
                                    else if(((String)orderInfoAttributeDetailsMap.get('uniqueKey'))=='OrderingCode'){
                                        prodDetailsOrderinginfo.orderinginfo_orderingCode = (String)orderInfoAttributeDetailsMap.get('value');
                                        
                                    }
                                    else if(((String)orderInfoAttributeDetailsMap.get('uniqueKey'))=='FamilyName'){
                                        prodDetailsOrderinginfo.orderinginfo_familyName = (String)orderInfoAttributeDetailsMap.get('value');
                                        
                                    }else if(((String)orderInfoAttributeDetailsMap.get('uniqueKey'))=='CustomCustomerCode'){
                                        prodDetailsOrderinginfo.orderinginfo_customCustomerCode = (String)orderInfoAttributeDetailsMap.get('value');
                                        
                                    }
                                    
                                    prodDetailsOrderinginfo.epmid_l4id_l3id_l2id_l1id = epmid+';'+l4id+';'+l3id+';'+l2id+';'+l1id;
                                }
                                
                                productDetailsClass.productDetialsList.add(prodDetailsOrderinginfo);//add changes to wrapper class
                            }
                        }
                        else{//when "orderingInfo": null
                            
                            //productDetailsClass.productDetialsList.add(prodDetails);
                        }
                        //orderinginfo-end
                    }
                    //productDetailsClass.productDetialsList.add(prodDetails);//add changes to wrapper class
                }
            }
            
            
            system.debug(':L4ProductCategoryIdList'+L4ProductCategoryIdList.size());
            //insert staging table
            List<Core_IQR_Products_Staging__c> iqrProductsStagingList = new List<Core_IQR_Products_Staging__c>();
            for(ProductDetails productDetials: productDetailsClass.productDetialsList){
                Core_IQR_Products_Staging__c iqrProductsStaging = new Core_IQR_Products_Staging__c();
                iqrProductsStaging.Core_Product_Type_EPM_ID__c = productDetials.hierarchy_l1Id;
                iqrProductsStaging.Core_Product_Type__c = productDetials.hierarchy_l1Name;
                iqrProductsStaging.Core_Product_Family_EPM_ID__c = productDetials.hierarchy_l2Id;
                iqrProductsStaging.Core_Product_Family__c = productDetials.hierarchy_l2Name;
                iqrProductsStaging.Core_Product_Series_EPM_ID__c = productDetials.hierarchy_l3Id;
                iqrProductsStaging.Core_Product_Series__c = productDetials.hierarchy_l3Name;
                iqrProductsStaging.Core_Product_Group_EPM_ID__c = productDetials.product_l4Id;
                iqrProductsStaging.Core_Product_Group__c = productDetials.product_l4Name;
                iqrProductsStaging.Core_Code_Name_EPM_ID__c = productDetials.attribute_codeNameText_rawValue;
                iqrProductsStaging.Core_Code_Name__c = productDetials.attribute_codeNameText_value;
                iqrProductsStaging.Core_Processor_Number_Nm__c = productDetials.attribute_processorNumber_value;
                iqrProductsStaging.Core_Product_Status__c = productDetials.orderinginfo_materialStatusCode_value;
                iqrProductsStaging.Core_Item_Id__c = productDetials.orderinginfo_mmid;
                iqrProductsStaging.Core_Mem_Amt__c = productDetials.attribute_driveCapacity_value;
                    
                iqrProductsStaging.Core_Division_Code_Short_Name__c = productDetials.orderinginfo_division_withoutbracket;
                iqrProductsStaging.Core_Division_Code__c = productDetials.orderinginfo_division_withbracket;
                iqrProductsStaging.Core_Group_Code_Short_Name__c = productDetials.orderinginfo_group_withoutbracket;
                iqrProductsStaging.Core_Group_Code__c = productDetials.orderinginfo_group_withbracket;
                iqrProductsStaging.Core_Product_Name_EPM_ID__c = productDetials.orderinginfo_empid;
                iqrProductsStaging.Core_BU_Operation_Code__c = productDetials.orderinginfo_opcode;
                iqrProductsStaging.Core_Is_Custom_Ind__c = productDetials.orderinginfo_customindicator;
                iqrProductsStaging.Core_Forecast_Product_Name__c = productDetials.orderinginfo_orderingCode;
                iqrProductsStaging.Core_Family_Nm__c = productDetials.orderinginfo_familyName;
                iqrProductsStaging.Core_Product_Name__c = productDetials.orderinginfo_name;
                iqrProductsStaging.Core_Business_Org_Nm__c= productDetials.orderinginfo_customCustomerCode;
                iqrProductsStaging.Core_Unique_ID__c = productDetials.epmid_l4id_l3id_l2id_l1id;
                
                iqrProductsStaging.Core_IsLatest__c = True;                
                iqrProductsStaging.Core_Processing_Status__c = 'New';
                
                iqrProductsStagingList.add(iqrProductsStaging);  
            }
            
            system.debug('iqrProductsStagingList:size:'+iqrProductsStagingList.size());
            if(iqrProductsStagingList.size()>0){
                insert iqrProductsStagingList;
            }
            
        }
        catch(Exception ex){
            system.debug('ex0:'+ex.getCause());
            system.debug('ex1:'+ex.getLineNumber());
            system.debug('ex2:'+ex.getMessage());
            system.debug('ex3:'+ex.getStackTraceString());
            system.debug('ex4:'+ex.getTypeName());
            
        }
    }
    
    public void finish(Database.BatchableContext BC){
             
        Database.executeBatch(new Core_IQR_UpdateProducts());
       // Database.executeBatch(new Core_IQR_CompareRecords());
    }
    
    
    class ProductL5Details{
        public List<ProductDetails> productDetialsList = new List<ProductDetails>();
    }
    
    class ProductDetails{
        
        public String hierarchy_l1Id = null;
        public String hierarchy_l1Name = null;
        public String hierarchy_l2Id = null;
        public String hierarchy_l2Name = null;
        public String hierarchy_l3Id = null;
        public String hierarchy_l3Name = null;
        public String product_l4Id = null;
        public String product_l4Name = null;
        public String attribute_codeNameText_rawValue = null;
        public String attribute_codeNameText_value = null;
        public String attribute_processorNumber_value = null;
        public String attribute_driveCapacity_value = null;
        public String orderinginfo_materialStatusCode_value = null;
        public String orderinginfo_mmid = null;
        public String orderinginfo_division_withoutbracket = null;
        public String orderinginfo_division_withbracket = null;
        public String orderinginfo_group_withoutbracket = null;
        public String orderinginfo_group_withbracket = null;
        public String orderinginfo_empid = null;
        public String orderinginfo_opcode = null;
        public String orderinginfo_customindicator = null;
        public String epmid_l4id_l3id_l2id_l1id = null;
        public String orderinginfo_orderingCode = null;
        public String orderinginfo_familyName = null;
        public String orderinginfo_name = null;
        public String orderinginfo_customCustomerCode = null;
    }
}