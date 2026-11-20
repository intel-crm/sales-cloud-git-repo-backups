public with sharing  class core_IPS_caseCreate_LEX {
    @AuraEnabled(cacheable = true)
    public static List<Product2> getProductVariants(String prodId) {
        String productId;
        if(prodId != null){
            productId = prodId;
        } else {
            productId = '';
        }
        
        List<Asset> assetList = new List<Asset>();
        List<Core_Flat_Product_Hierarchy__c> prodHierarchyList = new List<Core_Flat_Product_Hierarchy__c>();
        Set<String> ids = new Set<String>();
        List<Product2> productList = new List<Product2>();
        try{
            if(prodId != null || prodId != ''){
                List<sObject> listprod = new List<sObject>();
                assetList = Database.Query('select id, Name,Core_Product_Organization__c,core_supported_product__c,core_supported_product__r.Core_IPS_Is_Show_Variant__c,Core_IPS_Project__c,Core_Product_EPM_ID__c from asset where id=:productId');
                if(!assetList.isEmpty() || assetList.size() > 0){
                    if(assetList[0].core_supported_product__r.Core_IPS_Is_Show_Variant__c== true){
                        if(Core_Flat_Product_Hierarchy__c.SObjectType.getDescribe().isAccessible()){
                            // Venrublity Fix - Refering query to service class
                            // prodHierarchyList = [select id,Core_EPM_Hierarchy_Name__c, Core_L1_EPM_ID__c,Core_L1_EPM_Name__c,Core_L2_EPM_ID__c,Core_L2_EPM_Name__c,Core_Unique_ID__c from Core_Flat_Product_Hierarchy__c where Core_Unique_ID__c LIKE: '%'+assetList[0].Core_Product_EPM_ID__c+'%'];
                            prodHierarchyList = (List<Core_Flat_Product_Hierarchy__c>) Core_IPS_QueryService.queryRecords(
                                'select id,Core_EPM_Hierarchy_Name__c, Core_L1_EPM_ID__c,Core_L1_EPM_Name__c,Core_L2_EPM_ID__c,Core_L2_EPM_Name__c,Core_Unique_ID__c from Core_Flat_Product_Hierarchy__c where Core_Unique_ID__c LIKE :epmPattern',
                                new Map<String, Object>{ 'epmPattern' => '%' + assetList[0].Core_Product_EPM_ID__c + '%' }
                            );
                        }
                        
                        if(!prodHierarchyList.isEmpty() && prodHierarchyList.size()>0){
                            List<String> recorddata = new List<String>();
                            for(Core_Flat_Product_Hierarchy__c fph :prodHierarchyList){
                                String data=fph.Core_Unique_ID__c;
                                recorddata=data.split(';');
                            }
                            for(integer i=0;i<recorddata.size();i++){
                                if(recorddata[i]==assetList[0].Core_Product_EPM_ID__c){
                                    if(System.label.Core_IPS_MAG_Support_Org.Contains((assetList[0].Core_Product_Organization__c+'').substring(0,15))){
                                        if(i>0 && i==1){
                                            ids.add(recorddata.get(i-1));
                                        }else if(i>0 && i==2){
                                            ids.add(recorddata.get(i-2));
                                        }else if(i>0 && i==3){
                                            ids.add(recorddata.get(i-1));
                                        }
                                    } else {
                                        if(i>0){
                                            ids.add(recorddata.get(i-1));
                                        }
                                    }
                                }
                            }
                        }
                        
                        ids.remove(assetList[0].Core_Product_EPM_ID__c);
                        String strIPS = 'IPS';
                        if(ids!=null && ids.size()>0){
                            // Venrublity Fix - Refering query to service class
                            productList = [SELECT Id, Name FROM Product2 WHERE Core_Product_Org__c = :strIPS  and Core_Product_Name_EPM_ID__c IN  :ids order by Name];
                        }
                    }
                }
            }
        } catch(Exception e){
        }
        if(!productlist.isEmpty()){
            return productlist;
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Core_IPS_Product_Issue_Category__c> getCaseCategories(String prodId) {
        
        List<Core_IPS_Product_Issue_Category__c> categoryOptions = new List<Core_IPS_Product_Issue_Category__c>();
        String productId;
        if(prodId != null){
            productId = prodId.substring(1, prodId.length()-1); 
        } else {
            productId ='';
        }
        
        try{
            if(productId != null && productId != ''){
                categoryOptions = Core_IPS_CaseUtility.getCategories(prodId);
                
            }
        } catch(Exception e) {
        }
        if(!categoryOptions.isEmpty() || categoryOptions.size() > 0) {
            return categoryOptions;
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Core_IPS_Product_Issue_Category__c> getCaseSubCategories(String categoryId){
        List<Core_IPS_Product_Issue_Category__c> subCategories = new List<Core_IPS_Product_Issue_Category__c>();
        try{
            if(categoryId != null && categoryId != ''){
                subCategories = Core_IPS_CaseUtility.getSubCategories(categoryId);
                
            }
        } catch(Exception e) {
        }
        if(!subCategories.isEmpty() || subCategories.size() > 0) {
            return subCategories;
        }
        return null;
    }
    
    @AuraEnabled
    public static void GetEdqMethod(String supportedProdId) {
        String tempVar = supportedProdId;
        Map<Id,List<Core_IPS_Answer__c>> newMapStr = new Map<Id,List<Core_IPS_Answer__c>>();
        Map<String,Map<Core_IPS_Question__c,List<Core_IPS_Answer__c>>> newMapList = new Map<String,Map<Core_IPS_Question__c,List<Core_IPS_Answer__c>>>();
        List<String> envIds = new List<String>();
        List<Core_IPS_Assigned_Environment_Variables__c> envVarList = new List<Core_IPS_Assigned_Environment_Variables__c>();
        if(Core_IPS_Assigned_Environment_Variables__c.SObjectType.getDescribe().isAccessible()){
            // Venrublity Fix - Refering query to service class
            envVarList = [select id, name, Core_IPS_Question__c from Core_IPS_Assigned_Environment_Variables__c where Core_Supported_Product__c =:tempVar];
        }
        for(Core_IPS_Assigned_Environment_Variables__c env :envVarList) {
            envIds.add(env.Core_IPS_Question__c);
        }
        
        List<Core_IPS_Question__c> queList = new List<Core_IPS_Question__c>();
        List<String> queIds = new List<String>();
        if(Core_IPS_Question__c.SObjectType.getDescribe().isAccessible()){
            // Venrublity Fix - Refering query to service class
            queList = [select id, Core_IPS_Question__c, Core_IPS_Datatype__c from Core_IPS_Question__c where id IN: envIds];
        }
        List<Core_IPS_Answer__c> ansList = new List<Core_IPS_Answer__c>();
        for(Core_IPS_Question__c que : queList) {
            queIds.add(que.Id);
            newMapStr.put(que.Id,new List<Core_IPS_Answer__c>());
        }
        if(Core_IPS_Answer__c.SObjectType.getDescribe().isAccessible()){
            // Venrublity Fix - Refering query to service class
            ansList= [select id, name, Core_IPS_Answer__c, Core_IPS_Question__c from Core_IPS_Answer__c where Core_IPS_Question__c IN: queIds];
        }
        for(Core_IPS_Answer__c lstItem : ansList) {
            if(newMapStr.containsKey(lstItem.Core_IPS_Question__c)) {
                newMapStr.get(lstItem.Core_IPS_Question__c).add(lstItem);
            }
        }
        
    }
    public static List<Core_IPS_Assigned_Environment_Variables__c> envDeOpList;
    @AuraEnabled
    public static void getEDQ(String supportedId){
        String tempVar = supportedId;
        
        Map<Id,Map<Core_IPS_Question__c,List<Core_IPS_Answer__c>>> newMapStr = new Map<Id,Map<Core_IPS_Question__c,List<Core_IPS_Answer__c>>>();
        List<String> queIds = new List<String>();
        List<String> ansIds = new List<String>();
        Map<String,Core_IPS_Question__c> queMap = new Map<String,Core_IPS_Question__c>();
        List<Core_IPS_Question__c> queList = new List<Core_IPS_Question__c>();
        List<Core_IPS_Answer__c> ansList = new List<Core_IPS_Answer__c>();
        if(Core_IPS_Assigned_Environment_Variables__c.SObjectType.getDescribe().isAccessible()){
            // Venrublity Fix - Refering query to service class
            envDeOpList = [select id, name, Core_IPS_Question__c from Core_IPS_Assigned_Environment_Variables__c where Core_Supported_Product__c =:tempVar];
        }
        for(Core_IPS_Assigned_Environment_Variables__c env : envDeOpList) {
            queIds.add(env.Id);
        }
        if(Core_IPS_Question__c.SObjectType.getDescribe().isAccessible()){
            queList = [select id, Core_IPS_Question__c, Core_IPS_Datatype__c from Core_IPS_Question__c where id IN: queIds];
        }
        for(Core_IPS_Question__c queItem : queList) {
            queMap.put(queItem.Id, queItem);
            newMapStr.put(queItem.Id, new Map<Core_IPS_Question__c,List<Core_IPS_Answer__c>>());
            ansIds.add(queItem.Id);
        }
        if(Core_IPS_Answer__c.SObjectType.getDescribe().isAccessible()){
            // Venrublity Fix - Refering query to service class
            ansList = [select id, name, Core_IPS_Answer__c, Core_IPS_Question__c from Core_IPS_Answer__c where Core_IPS_Question__c IN: ansIds];
        }
        for(Core_IPS_Answer__c lstItem : ansList) {
            if(newMapStr.containsKey(lstItem.Core_IPS_Question__c)) {
                if(newMapStr.get(lstItem.Core_IPS_Question__c) == null) {
                    newMapStr.get(lstItem.Core_IPS_Question__c).put(queMap.get(lstItem.Core_IPS_Question__c),new List<Core_IPS_Answer__c>{lstItem});   
                } else {
                    
                }
            }
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<contact> getContactDetails()
    {
        List<contact>  userContact = new List<contact>();       
        // Venrublity Fix - Refering query to service class
        List<user> usrRecord = [SELECT Id, ContactId FROM User where id =:UserInfo.getUserId() limit 1 ];
        if(usrRecord.size()>0){
            if (Schema.sObjectType.Contact.isAccessible()) {
                // Venrublity Fix - Refering query to service class
                // userContact = [SELECT Id,Name,AccountId,Account.Name,Core_Country_Region__c,Core_IPS_Embargoed_State__c From Contact where id =:usrRecord[0].ContactId limit 1 ]; 
                userContact = (List<Contact>) Core_IPS_QueryService.queryRecords(
                    'SELECT Id,Name,AccountId,Account.Name,Core_Country_Region__c,Core_IPS_Embargoed_State__c From Contact where id = :contactId limit 1',
                    new Map<String, Object>{ 'contactId' => usrRecord[0].ContactId }
                );
            }
        }
        return userContact;  
    }
    @AuraEnabled(cacheable=true)
    public static String getSupportedProd(String assetID){
        String supportPrdID = '';
        try{
            Asset aset=new Asset();
            if (Schema.sObjectType.Asset.isAccessible()) {
                // Venrublity Fix - Refering query to service class
                List<Asset> asetList = [SELECT ID, Core_Supported_Product__c FROM Asset WHERE ID = :assetID];
                if (!asetList.isEmpty()) {
                    aset = asetList[0];
                }
            }
            if(aset.Core_Supported_Product__c != null || aset.Core_Supported_Product__c != ''){
                supportPrdID = aset.Core_Supported_Product__c;
            }
        }catch(Exception e){
        }
        return supportPrdID;
    }
    
}