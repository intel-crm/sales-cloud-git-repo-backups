/****************************************************************************************************************************************
 * Class Name: Core_IPS_Copy_CategoriesEDQ_LEX
 * Test Class Name: Core_IPS_Copy_CategoriesEDQ_Test
 * Description: This class is used for Internal LEX(Support ORG) in Supported Product Detail Page(Copy Categories & EDQ's Button) 
 * Created By: Sai Krishna 
 * Created Date: 02/08/2022 
 ******************************************************************************************************************************************/

public with sharing class  Core_IPS_Copy_CategoriesEDQ_LEX {
	public static List<Core_IPS_Supported_Product__c> lstSupProd;
    
    
     /*****************************************************************************************************************************************
     * Method Name: checkUserPermission
     * Description: This method will check if the current logged in user has edit access to the particular Supported Product Record 
     * No Of Queries: 1
     * Input Values: Supported Product ID
     * Output Values: Returns the true if has access, else returns message as per criteria 
     * Created Date: 02/08/2022
     * Created By: Sai Krishna
     * Version: 1.0
     * Method Type: Custom Method
	 **************************************************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static String checkUserPermission(String recordId){
        UserRecordAccess objUserRecAccess = [SELECT RecordId,HasEditAccess FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId=:recordId];
        if(objUserRecAccess==null || objUserRecAccess.HasEditAccess!=true) {
            return 'You dont have access to Copy Environment Details !!'; 
        }
        List<Core_IPS_Supported_Product__c> splst = getSpportedProductList(recordId,0,0,'All Data');
        if(splst.isEmpty()){
            return Core_IPS_Error_Code__c.getValues('I106').Core_Error_Message__c;
        }
        return 'true';
    }
    
    
     /*****************************************************************************************************************************************
     * Method Name: getSpportedProductList
     * Description: This method will Fetch  all  Supported Products which are avilable in Supported ORG
     * No Of Queries: 2
     * Input Values: Supported Product ID, Limitsize, offset, fetchType for lazy Loading
     * Output Values: Returns the List of all Supported Products which are available on Supported ORG 
     * Created Date: 02/08/2022
     * Created By: Sai Krishna
     * Version: 1.0
     * Method Type: Custom Method
	 **************************************************************************************************************************************/

    
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Supported_Product__c> getSpportedProductList(String recordId, Integer limitsize, Integer offset, String fetchtype){
        Core_IPS_Supported_Product__c cursprec;
        if(Schema.SObjectType.Core_IPS_Supported_Product__c.isAccessible()){
            cursprec = [Select Id, name,Core_Product_Organization__c From Core_IPS_Supported_Product__c Where Id=: recordId ];
            String org = cursprec.Core_Product_Organization__c;
            String query = 'Select Id,Name,Core_Supported_Product_Name__c,Core_Flag_Status__c FROM Core_IPS_Supported_Product__c WHERE Core_Product_Organization__c=:org AND Id!=:recordId ORDER BY Core_Supported_Product_Name__c';
            if(fetchtype =='Load Data' && offset != null){
                query ='Select Id,Name,Core_Supported_Product_Name__c,Core_Flag_Status__c FROM Core_IPS_Supported_Product__c WHERE Core_Product_Organization__c=:org AND Id!=:recordId ORDER BY Core_Supported_Product_Name__c LIMIT :limitsize OFFSET :offset';
            }
            lstSupProd = DataBase.Query(query);
        }
        return lstSupProd;
    }



	
	 /*****************************************************************************************************************************************
     * Method Name: copyCaseCatSubCatEDQ
     * Description: This method will Copy all Categories,Sub Categories,EDQ's of Current Supported Product to Selected Supported Product
     * No Of Queries: 3
     * Input Values: Current Supported Product ID, Selected Supported Product ID
     * Output Values: Returns true if copy is successfull, else returns failure message
     * Created Date: 02/08/2022
     * Created By: Sai Krishna
     * Version: 1.0
     * Method Type: Custom Method
	 **************************************************************************************************************************************/

    
    @AuraEnabled
    public static String  copyCaseCatSubCatEDQ(String selsprecID, String cursprecId){
            
        
        	//Get Environment Details Operational of Current SP
            String queryEDO = 'SELECT ' + String.escapeSingleQuotes(getAllFieldStr(Core_IPS_Assigned_Environment_Variables__c.SobjectType)) +
                			  ' FROM Core_IPS_Assigned_Environment_Variables__c WHERE Core_Supported_Product__c=\''+String.escapeSingleQuotes(cursprecId)+'\' AND Core_Status__c=\'Active\' ORDER BY Name';
            
            List<Core_IPS_Assigned_Environment_Variables__c> lstEDO = Database.query(queryEDO);
            
            //Get Case Categories of Current SP 
            String queryCaseCategories = 'SELECT ' + String.escapeSingleQuotes(getAllFieldStr(Core_IPS_Product_Issue_Category__c.SobjectType)) +
                						 //',(SELECT ' + getAllFieldStr(Core_IPS_Product_Issue_Category__c.SobjectType) + ' FROM Product_Issue_Sub_Categories__r ORDER BY Name)' +
                			  			 ' FROM Core_IPS_Product_Issue_Category__c WHERE Core_Supported_Product__c=\''+String.escapeSingleQuotes(cursprecId)+'\' AND Core_Status__c=\'Active\' ORDER BY Name';
                        
            List<Core_IPS_Product_Issue_Category__c> lstCaseCat = Database.query(queryCaseCategories);
            
            //Get Case SubCategories of Current SP
            // SOQL Injection Fix - Start -  Shipra
            Map<String, Object> bindMap = new Map<String, Object>{ 'lstCaseCat' => lstCaseCat };

            String queryCaseSubCategories = 'SELECT ' + getAllFieldStr(Core_IPS_Product_Issue_Category__c.SobjectType) +
                						 ',(SELECT ' + getAllFieldStr(Core_IPS_Assigned_Environment_Variables__c.SobjectType) + ' FROM Environment_Detail_Operationals__r WHERE Core_Status__c=\'Active\' ORDER BY Name)' +
                			  			 ' FROM Core_IPS_Product_Issue_Category__c WHERE Core_Product_Issue_Category__c IN :lstCaseCat AND Core_Status__c=\'Active\' ORDER BY Name';
            
            List<Core_IPS_Product_Issue_Category__c> lstCaseSubCat = Database.queryWithBinds(queryCaseSubCategories, bindMap, AccessLevel.USER_MODE);
            // SOQL Injection Fix - End -  Shipra
            if((lstEDO==null || lstEDO.size()==0) && (lstCaseCat==null || lstCaseCat.size()==0)) {
                return 'No Environment Details and Case Categories present to Copy !!'; 
                
            }
        
            // Delete Case Categories, Sub Categories, EDQ of Selected SP      
            deleteselSPCatEDQ(selsprecID);
            
        try{
            //Clone and insert Environment Details
            List<Core_IPS_Assigned_Environment_Variables__c> lstEDO2Insert = new List<Core_IPS_Assigned_Environment_Variables__c>();
            for(Core_IPS_Assigned_Environment_Variables__c objEDO : lstEDO) {
                Core_IPS_Assigned_Environment_Variables__c newEDO = objEDO.clone(false,true);
                /* FLS Check for security vulnerability --*/
                if (Schema.sObjectType.Core_IPS_Assigned_Environment_Variables__c.fields.Core_Supported_Product__c.isCreateable()) {
                newEDO.Core_Supported_Product__c = selsprecID;
                }
                lstEDO2Insert.add(newEDO);
            }
            insert lstEDO2Insert;
            List<wrapCategories> lstWrapCategories = new List<wrapCategories>();
            List<Core_IPS_Product_Issue_Category__c> lstCaseCat2Insert = new List<Core_IPS_Product_Issue_Category__c>();
            List<Core_IPS_Product_Issue_Category__c> lstCaseSubCat2Insert = new List<Core_IPS_Product_Issue_Category__c>(); 
            List<Core_IPS_Assigned_Environment_Variables__c> lstSubCatEDO2Insert = new List<Core_IPS_Assigned_Environment_Variables__c>();
            Map<Id, List<Core_IPS_Product_Issue_Category__c>> mapCaseCat2SubCat = new Map<Id, List<Core_IPS_Product_Issue_Category__c>>();
            
            for(Core_IPS_Product_Issue_Category__c objCaseSubCat : lstCaseSubCat) {
                if(!mapCaseCat2SubCat.containsKey(objCaseSubCat.Core_Product_Issue_Category__c)) {
                    mapCaseCat2SubCat.put(objCaseSubCat.Core_Product_Issue_Category__c, new List<Core_IPS_Product_Issue_Category__c>());
                }
                mapCaseCat2SubCat.get(objCaseSubCat.Core_Product_Issue_Category__c).add(objCaseSubCat);
            }
            
            //Clone and insert Case Categories
            for(Core_IPS_Product_Issue_Category__c objCaseCat : lstCaseCat) {
                List<Core_IPS_Product_Issue_Category__c> lstSubCat;
                if(mapCaseCat2SubCat.containsKey(objCaseCat.Id)) {
                    lstSubCat = mapCaseCat2SubCat.get(objCaseCat.Id);
                }
                wrapCategories objWC = new wrapCategories(objCaseCat, lstSubCat, selsprecID);
                lstWrapCategories.add(objWC);
                lstCaseCat2Insert.add(objWC.objCaseCat);
            }
            insert lstCaseCat2Insert;
            
            //Clone and insert Case SubCategories
            for(wrapCategories objWC : lstWrapCategories) {
                for(wrapCategories objWSubCat : objWC.lstCaseSubCat) {
                    if (Schema.sObjectType.Core_IPS_Product_Issue_Category__c.fields.Core_Product_Issue_Category__c.isCreateable()) {
                    objWSubCat.objCaseCat.Core_Product_Issue_Category__c = objWC.objCaseCat.Id;
                    }
                    lstCaseSubCat2Insert.add(objWSubCat.objCaseCat);
                }
            }
            if(lstCaseSubCat2Insert.size()>0) { insert lstCaseSubCat2Insert; }
            
            for(wrapCategories objWC : lstWrapCategories) {
                for(wrapCategories objWSubCat : objWC.lstCaseSubCat) {
                    for(Core_IPS_Assigned_Environment_Variables__c objSubCatEDO : objWSubCat.lstEDO) {
                        if (Schema.sObjectType.Core_IPS_Assigned_Environment_Variables__c.fields.Core_Product_Issue_Sub_Category__c.isCreateable()) {
                        objSubCatEDO.Core_Product_Issue_Sub_Category__c = objWSubCat.objCaseCat.Id;
                        }
                        lstSubCatEDO2Insert.add(objSubCatEDO);
                    }                    
                }
            }
            if(lstSubCatEDO2Insert.size()>0) { insert lstSubCatEDO2Insert; }
            
            
            
        return 'true';
        }
        catch(Exception e){
            return e.getMessage();
        }	
    }
    
    
    
    
     /*****************************************************************************************************************************************
     * Method Name: deleteselSPCatEDQ
     * Description: This method will delete all Categories,Sub Categories,EDQ's of Selected Supported Product
     * No Of Queries: 4
     * Input Values:  Selected Supported Product ID
     * Output Values: ----
     * Created Date: 02/08/2022
     * Created By: Sai Krishna
     * Version: 1.0
     * Method Type: Custom Method
	 **************************************************************************************************************************************/

    
    public static void deleteselSPCatEDQ(String selsprecID){
        
        //Get Environment Details Operational of selected SP to Delete
            String queryEDOselsp = 'SELECT Id FROM Core_IPS_Assigned_Environment_Variables__c WHERE Core_Supported_Product__c=:selsprecID';
            
            List<Core_IPS_Assigned_Environment_Variables__c> lstEDO1 = Database.query(queryEDOselsp);
            
            //Get Case Categories & SUb Categories of selected SP to Delete
            String queryCaseCategoriesselsp = 'SELECT Id FROM Core_IPS_Product_Issue_Category__c WHERE Core_Supported_Product__c=:selsprecID';
                        
            List<Core_IPS_Product_Issue_Category__c> lstCaseCat1 = Database.query(queryCaseCategoriesselsp);
        

        if(lstEDO1!=null) {
                /* CRUD Delete Check for security vulnerability --*/
                if(Core_IPS_Assigned_Environment_Variables__c.sObjectType.getDescribe().isDeletable()) {
                delete lstEDO1;
                }
            }
            if(lstCaseCat1!=null) {
                /* CRUD Delete Check for security vulnerability --*/
                if(Core_IPS_Assigned_Environment_Variables__c.sObjectType.getDescribe().isDeletable()) {
                delete [SELECT Id FROM Core_IPS_Assigned_Environment_Variables__c WHERE Core_Product_Issue_Sub_Category__r.Core_Product_Issue_Category__c IN :lstCaseCat1];
                }
                /* CRUD Delete Check for security vulnerability --*/
                if(Core_IPS_Product_Issue_Category__c.sObjectType.getDescribe().isDeletable()) {
                    delete [SELECT Id FROM Core_IPS_Product_Issue_Category__c WHERE Core_Product_Issue_Category__c IN :lstCaseCat1];  
                }
                /*CRUD Delete Check for security vulnerability --*/
                if(Core_IPS_Product_Issue_Category__c.sObjectType.getDescribe().isDeletable()) {
                    delete lstCaseCat1;
                }
            }
        
    }
    
    
	/*****************************************************************************************************************************************
     * Method Name: getAllFieldStr
     * Description: This method will fetch all fields of given Sobject
     * No Of Queries: 0
     * Input Values:  Sobject Type
     * Output Values: returns all fields of given Sobject
     * Created Date: 02/08/2022
     * Created By: Sai Krishna
     * Version: 1.0
     * Method Type: Custom Method
	 **************************************************************************************************************************************/
    
    private static String getAllFieldStr(SObjectType sobjType) {
        Map<String, Schema.SObjectField> fieldMap = sobjType.getDescribe().fields.getMap();        
        List<String> fieldList = new List<String>();
        fieldList.addAll(fieldMap.keyset());
        String allFields = String.join(fieldList, ', ');                
		return allFields;
	}
    
    
    //Wrapper class to store Case Categories, related Subcategories and related Environment Details
    public class wrapCategories {
        public Core_IPS_Product_Issue_Category__c objCaseCat;
        public List<wrapCategories> lstCaseSubCat;
        public List<Core_IPS_Assigned_Environment_Variables__c> lstEDO;
        
        public wrapCategories(Core_IPS_Product_Issue_Category__c CaseCat, List<Core_IPS_Product_Issue_Category__c> lstSubCat, Id newSupProdId) {
            objCaseCat = CaseCat.clone(false,true);
            if (Schema.sObjectType.Core_IPS_Product_Issue_Category__c.fields.Core_Supported_Product__c.isCreateable()) {
            objCaseCat.Core_Supported_Product__c = newSupProdId;
            }
            lstCaseSubCat = new List<wrapCategories>();
            if(lstSubCat!=null && lstSubCat.size()>0) {
                for(Core_IPS_Product_Issue_Category__c objCaseSubCat : lstSubCat) {                    
                    lstCaseSubCat.add(new wrapCategories(objCaseSubCat));
                }
            }
        }
        
        public wrapCategories(Core_IPS_Product_Issue_Category__c CaseCat) {
            objCaseCat = CaseCat.clone(false,true);            
            lstEDO = new List<Core_IPS_Assigned_Environment_Variables__c>();
            if(objCaseCat.Environment_Detail_Operationals__r!=null && objCaseCat.Environment_Detail_Operationals__r.size()>0) {
                lstEDO = objCaseCat.Environment_Detail_Operationals__r.deepClone(false,true);                
            }             
        }
    }
    
}