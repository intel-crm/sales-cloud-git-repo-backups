/***************************************************************************************************
* Apex Class Name: Core_IPS_Copy_EDQ_Controller
* Description    : Extension class for Core_IPS_Copy_EnvironmentDetails Visualforce Page
* Function       : This class copies all the Environment Details Operational, Case Categories, Case Subcategories to select supported product
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh                    17/05/2018             Created
****************************************************************************************************/

public with sharing class Core_IPS_Copy_EDQ_Controller {
    
    Public String ErrorMessage{get;set;}
    Public List<Core_IPS_Supported_Product__c> lstSupProd{get;set;}
    Public String selectedSupProd{get;set;}
    
    Private ApexPages.StandardController stdcon;
    Private Core_IPS_Supported_Product__c objSupProd;
    
    public Core_IPS_Copy_EDQ_Controller(ApexPages.StandardController controller) {
        If(!Test.isRunningTest()) controller.addFields(new List<String> {'Core_Product_Organization__c'});
        stdcon = controller;
        objSupProd = (Core_IPS_Supported_Product__c) controller.getRecord();
        
        init();
    }
    
    public void init() {
        if(objSupProd==null || objSupProd.Id==null) { ErrorMessage = 'Invalid URL !!'; return; }
        
        UserRecordAccess objUserRecAccess = [SELECT RecordId,HasEditAccess FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId=:objSupProd.Id];
        if(objUserRecAccess==null || objUserRecAccess.HasEditAccess!=true) {
            ErrorMessage = 'You dont have access to Copy Environment Details !!'; return;
        }
        
        //Get all supported products from same support org
        lstSupProd = new List<Core_IPS_Supported_Product__c>([SELECT Id,Name,Core_Supported_Product_Name__c,Core_Flag_Status__c  
                                                              FROM Core_IPS_Supported_Product__c WHERE Core_Product_Organization__c=:objSupProd.Core_Product_Organization__c
                                                              AND Id!=:objSupProd.Id ORDER BY Core_Supported_Product_Name__c]);
    }
    
    //Copy environment details to the selected supported product. Called from Visualforce
    public Pagereference copyDetails() {
        if(String.isBlank(selectedSupProd)) {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Please select a Supported Product')); return null;
        }
        Savepoint sp = Database.setSavepoint();
        try {
            //Get Environment Details Operational
            String queryEDO = 'SELECT ' + getAllFieldStr(Core_IPS_Assigned_Environment_Variables__c.SobjectType) +
                			  ' FROM Core_IPS_Assigned_Environment_Variables__c WHERE Core_Supported_Product__c=\''+objSupProd.Id+'\' AND Core_Status__c=\'Active\' ORDER BY Name';
            
            List<Core_IPS_Assigned_Environment_Variables__c> lstEDO = Database.query(queryEDO);
            
            //Get Case Categories
            String queryCaseCategories = 'SELECT ' + getAllFieldStr(Core_IPS_Product_Issue_Category__c.SobjectType) +
                						 //',(SELECT ' + getAllFieldStr(Core_IPS_Product_Issue_Category__c.SobjectType) + ' FROM Product_Issue_Sub_Categories__r ORDER BY Name)' +
                			  			 ' FROM Core_IPS_Product_Issue_Category__c WHERE Core_Supported_Product__c=\''+objSupProd.Id+'\' AND Core_Status__c=\'Active\' ORDER BY Name';
                        
            List<Core_IPS_Product_Issue_Category__c> lstCaseCat = Database.query(queryCaseCategories);
            
            //Get Case SubCategories
            String queryCaseSubCategories = 'SELECT ' + getAllFieldStr(Core_IPS_Product_Issue_Category__c.SobjectType) +
                						 ',(SELECT ' + getAllFieldStr(Core_IPS_Assigned_Environment_Variables__c.SobjectType) + ' FROM Environment_Detail_Operationals__r WHERE Core_Status__c=\'Active\' ORDER BY Name)' +
                			  			 ' FROM Core_IPS_Product_Issue_Category__c WHERE Core_Product_Issue_Category__c IN :lstCaseCat AND Core_Status__c=\'Active\' ORDER BY Name';
            
            List<Core_IPS_Product_Issue_Category__c> lstCaseSubCat = Database.query(queryCaseSubCategories);
            
            if((lstEDO==null || lstEDO.size()==0) && (lstCaseCat==null || lstCaseCat.size()==0)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'No Environment Details and Case Categories present to Copy !!')); return null;
            }
            
            //delete existing Environment details & Case Category,Sub Category
            AdminOpertaions adminOprn = new AdminOpertaions();
            adminOprn.deleteEnvironmentDetails(new List<Core_IPS_Assigned_Environment_Variables__c>([SELECT Id FROM Core_IPS_Assigned_Environment_Variables__c WHERE Core_Supported_Product__c=:selectedSupProd]));            
            adminOprn.deleteCaseCategories(new List<Core_IPS_Product_Issue_Category__c>([SELECT Id FROM Core_IPS_Product_Issue_Category__c WHERE Core_Supported_Product__c=:selectedSupProd]));
            
            //Clone and insert Environment Details
            List<Core_IPS_Assigned_Environment_Variables__c> lstEDO2Insert = new List<Core_IPS_Assigned_Environment_Variables__c>();
            for(Core_IPS_Assigned_Environment_Variables__c objEDO : lstEDO) {
                Core_IPS_Assigned_Environment_Variables__c newEDO = objEDO.clone(false,true);
                newEDO.Core_Supported_Product__c = selectedSupProd;
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
                wrapCategories objWC = new wrapCategories(objCaseCat, lstSubCat, selectedSupProd);
                lstWrapCategories.add(objWC);
                lstCaseCat2Insert.add(objWC.objCaseCat);
            }
            insert lstCaseCat2Insert;
            
            //Clone and insert Case SubCategories
            for(wrapCategories objWC : lstWrapCategories) {
                for(wrapCategories objWSubCat : objWC.lstCaseSubCat) {
                    objWSubCat.objCaseCat.Core_Product_Issue_Category__c = objWC.objCaseCat.Id;
                    lstCaseSubCat2Insert.add(objWSubCat.objCaseCat);
                }
            }
            if(lstCaseSubCat2Insert.size()>0) { insert lstCaseSubCat2Insert; }
            
            for(wrapCategories objWC : lstWrapCategories) {
                for(wrapCategories objWSubCat : objWC.lstCaseSubCat) {
                    for(Core_IPS_Assigned_Environment_Variables__c objSubCatEDO : objWSubCat.lstEDO) {
                        objSubCatEDO.Core_Product_Issue_Sub_Category__c = objWSubCat.objCaseCat.Id;
                        lstSubCatEDO2Insert.add(objSubCatEDO);
                    }                    
                }
            }
            if(lstSubCatEDO2Insert.size()>0) { insert lstSubCatEDO2Insert; }
            
            return new Pagereference('/' + selectedSupProd);
            
        } catch(Exception ex) {
            Database.rollback(sp); ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getMessage())); system.debug(ex.getStackTraceString());            
        }
        return null;
    }
    
    public Pagereference cancel() {
        if(objSupProd==null || objSupProd.Id==null) return new Pagereference('/');
        return stdcon.view();
    }
    
    //Returns comma seperated all the fields for a passed Sobject
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
            objCaseCat.Core_Supported_Product__c = newSupProdId;
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
    
    public without sharing class AdminOpertaions {
    	public void deleteEnvironmentDetails(List<Core_IPS_Assigned_Environment_Variables__c> lstEDO) {
            if(lstEDO!=null) delete lstEDO;
        }
    
    	public void deleteCaseCategories(List<Core_IPS_Product_Issue_Category__c> lstCaseCat) {
            if(lstCaseCat!=null) {
                delete [SELECT Id FROM Core_IPS_Assigned_Environment_Variables__c WHERE Core_Product_Issue_Sub_Category__r.Core_Product_Issue_Category__c IN :lstCaseCat];
                delete [SELECT Id FROM Core_IPS_Product_Issue_Category__c WHERE Core_Product_Issue_Category__c IN :lstCaseCat];  
                delete lstCaseCat;
            }
        }
    }

}