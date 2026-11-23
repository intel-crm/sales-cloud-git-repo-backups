public with sharing class Utilities_Portal_LEX {

    public static String getAllFieldsAccessible(Set<String> exclude, sObject obj) {
        Schema.sObjectType objType = obj.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult objDesc = objType.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> fmap = objDesc.fields.getMap(); //get a map of fields for the passed sobject

        String fieldList = '';
        for (String apiName : fmap.keySet()) {
            Schema.SObjectField field = fmap.get(apiName);
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            if (fieldResult.isAccessible() && fieldResult.isUpdateable()) {
                if (exclude == null || !exclude.contains(apiName)) {
                    fieldList += apiName + ', ';
                }
            }
        }

        fieldList = fieldList.removeEnd(', ');
        System.debug('case retrieved fields: ' + fieldList);
        return fieldList;
    }
    public static List<Product2> getProducts(String selectedProductId){
        Boolean blnShowVariant = false;
        if(selectedProductId!=null && selectedProductId!=''){
            //Query on Asset
            List<Asset> assetList = database.Query('select id, Name,Core_Product_Organization__c,core_supported_product__c,core_supported_product__r.Core_IPS_Is_Show_Variant__c,Core_IPS_Project__c,Core_Product_EPM_ID__c from asset where id=:selectedProductId'); 
            System.debug('List of asset records====='+assetList);
            if(!assetList.isEmpty() && assetList.size()>0){
                if(assetList[0].core_supported_product__r.Core_IPS_Is_Show_Variant__c== true){
                    //Query on FlatProductHierarchy
                    String strQuery = 'select id,Core_EPM_Hierarchy_Name__c, Core_L1_EPM_ID__c,Core_L1_EPM_Name__c,Core_L2_EPM_ID__c,Core_L2_EPM_Name__c,Core_Unique_ID__c from Core_Flat_Product_Hierarchy__c where Core_Unique_ID__c like \'%;'+assetList[0].Core_Product_EPM_ID__c+';%\'' +'OR Core_Unique_ID__c like'+ '\'%;'+assetList[0].Core_Product_EPM_ID__c+'\'';
                    //String strQuery = 'select id,Core_EPM_Hierarchy_Name__c, Core_L1_EPM_ID__c,Core_L1_EPM_Name__c,Core_L2_EPM_ID__c,Core_L2_EPM_Name__c,Core_Unique_ID__c from Core_Flat_Product_Hierarchy__c where Core_Unique_ID__c like \'%;'+assetList[0].Core_Product_EPM_ID__c+';%\'';
                    List<Core_Flat_Product_Hierarchy__c > flatIdsList = database.Query(strQuery);
                    set<String> ids=new set<String>();
                    System.debug('FLATProd Data'+ flatIdsList);
                    if(!flatIdsList.isEmpty() && flatIdsList.size()>0){
                        for(Core_Flat_Product_Hierarchy__c fph :flatIdsList){
                            String data=fph.Core_Unique_ID__c;
                            List<String> recorddata=data.split(';');
                            for(integer i=0;i<recorddata.size();i++){
                                System.debug(' This belongs to this org-->'+(assetList[0].Core_Product_Organization__c));
                                if(recorddata[i]==assetList[0].Core_Product_EPM_ID__c){
                                    //added by ranjini for PSG
                                    if(System.label.Core_IPS_MAG_Support_Org.Contains((assetList[0].Core_Product_Organization__c+'').substring(0,15))){
                                        System.debug(' Entering loop PSG-->'+(assetList[0].Core_Product_Organization__c));
                                        if(i>0 && i==1){
                                            ids.add(recorddata.get(i-1));
                                        }else if(i>0 && i==2){
                                            ids.add(recorddata.get(i-2));
                                        }else if(i>0 && i==3){
                                            ids.add(recorddata.get(i-1));
                                        }
                                        //changes ends
                                    }else{
                                        if(i>0){
                                            ids.add(recorddata.get(i-1));
                                        }
                                    }
                                }
                            } 
                        }
                    }
                    ids.remove(assetList[0].Core_Product_EPM_ID__c);
                    List<Product2> Productlist = new List<Product2>();
                    String strIPS = 'IPS';
                    
                    //Query on Product for showing the product variant names based on EPM ID 
                    if(ids!=null && ids.size()>0){
                        Productlist = database.Query('select id, Name FROM Product2 where Core_Product_Org__c = :strIPS  and Core_Product_Name_EPM_ID__c IN  :ids order by Name');     
                        System.debug(' Productlist-->'+Productlist);
                    }
                    list<Product2> variants = new list<Product2>();
                    for(Product2 prod:Productlist)
                    {
                        variants.add(prod);
                    }
                        if(variants.size()>1){
                            blnShowVariant = true;
                        }
                        System.debug(' variants-->'+variants);
                        
                        return variants;
                }
            }
        }
        return null;
    }
    public static List<Core_IPS_Product_Issue_Category__c> getSubCategories(String issueCategoryId){
        if(issueCategoryId!=null && issueCategoryid!=''){
            return [SELECT id,name,core_issue_category_Name__c,Core_Issue_Sub_Category_Name__r.Name,Core_Issue_Category_Name__r.Name FROM Core_IPS_Product_Issue_Category__c WHERE Core_Product_Issue_Category__c =:issuecategoryId and core_status__c!='Inactive' ];
        }
        return null;
    }
    public static List<Core_IPS_Product_Issue_Category__c> getsubCategory_Options(String categorySelected){
        list<Core_IPS_Product_Issue_Category__c> categoryList = new list<Core_IPS_Product_Issue_Category__c>();
        if(categorySelected!=null && categorySelected!=''){
            for(Core_IPS_Product_Issue_Category__c a:Core_IPS_CaseUtility.getSubCategories(categorySelected)){
                if(a.Core_Issue_Sub_Category_Name__c!=null){
                    categoryList.add(a);
                }
            }
        }
        return categoryList;
    }
    
    
    @AuraEnabled
    public static string saveCaseComment(string caseId, String visibility, string comment){
      /*  Core_IPS_CaseCmt_LWC caseCmtObj = new Core_IPS_CaseCmt_LWC();
        
        Case currentcase = [select id,subject,Core_IPS_Comment__c,RecordType.Name,AccountId,Core_Sub_Status__c,status,CreatedBy.Email,contactid,Core_IPS_Date_Time_Close_Pending__c from Case where id =:caseId ];
        
        return caseCmtObj.saveComments(currentcase, visibility, comment);
      */
        return null;
    }
    
}