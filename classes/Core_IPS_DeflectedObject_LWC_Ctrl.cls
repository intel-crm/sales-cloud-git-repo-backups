/****************************************************************************************************************************************
* Class Name  : Core_IPS_DeflectedObject_LWC_Ctrl 
* Version     : 1.0 
* Created Date:  10/04/2022 
* Modification Log :
* Developer: Minhaj Ameen                     Date                          Description: 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps           17/04/2022                Controller to create a deflected object and update the status of that object
when case is created.
*****************************************************************************************************************************************/

public with sharing class Core_IPS_DeflectedObject_LWC_Ctrl {
    
    @AuraEnabled(cacheable=false)
    public static String createDeflectedObject(String caseInfo, String deflectedId){
        Core_IPS_Deflected_Object__c deflectedObj = new Core_IPS_Deflected_Object__c();
        if(!String.isBlank(deflectedId)){
         deflectedObj.Id = deflectedId;
        }
        JSON2Apex caseInfoJSON = JSON2Apex.parse(caseInfo);
        String cleanedCaseInfo = '{"Subject":"'+caseInfoJSON.Subject+'","Sub_Category_Name":"'+caseInfoJSON.SubCategoryName+'","Sub_Category_ID":"'+caseInfoJSON.SubCategoryId+'","Project_Name":"'+caseInfoJSON.projectName+'","Project_ID":"'+caseInfoJSON.project+'","Product_Variant_Name":"'+caseInfoJSON.productvariantName+'","IntelProduct_Name"":"'+caseInfoJSON.ProductName+'","IntelProduct_ID":"'+caseInfoJSON.Product+'","Category_Name":"'+caseInfoJSON.CategoryName+'","Category_ID":"'+caseInfoJSON.CategoryId+'"}';
        
        if (Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Status__c.isCreateable()||Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Status__c.isupdateable())
        {
            deflectedObj.Core_IPS_Status__c='Deflected';
        }
        if (Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Contact_Id__c.isCreateable()||Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Contact_Id__c.isupdateable())
        {
            deflectedObj.Core_IPS_Contact_Id__c= caseInfoJSON.contactId;
        }
        if (Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Search_JSON__c.isCreateable()||Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Search_JSON__c.isupdateable())
        {
            deflectedObj.Core_IPS_Search_JSON__c = cleanedCaseInfo;
        }
        // Contact contactRecord;
        // if (Schema.sObjectType.Contact.isAccessible()) { //FLS Read added -Gangadhar 29/09/2023
        // 	contactRecord = [SELECT Id, Contact.Email FROM Contact WHERE Id = :caseInfoJSON.contactId];
        // }
        Contact contactRecord = new Contact(); // Exception Handling - 10-06-2026 Nuthana
        List<Contact> contactRecordList = new List<Contact>();
        if (Schema.sObjectType.Contact.isAccessible()) { 
        	contactRecordList = [SELECT Id, Contact.Email FROM Contact WHERE Id = :caseInfoJSON.contactId];
            if(contactRecordList.size()>0){ // Start If
                contactRecord=contactRecordList[0];
            } //End If
         }

        if(!String.isBlank(caseInfoJSON.Subject)){ //FLS Create/Update added -Gangadhar 29/09/2023
            if (Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Description__c.isCreateable()||
                Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Description__c.isupdateable()) {
            	deflectedObj.Core_IPS_Description__c = caseInfoJSON.Subject;
            }
            if (Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Description_on_Coveo__c.isCreateable()||
                Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Description_on_Coveo__c.isupdateable()) { //FLS Create/Update added -Gangadhar 29/09/2023
            	deflectedObj.Core_IPS_Description_on_Coveo__c = caseInfoJSON.Subject;
            }
        }
        if(contactRecord != null && !String.isBlank(contactRecord.Id)){ //FLS Create/Update added -Gangadhar 29/09/2023
            if (Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Contact_Email__c.isCreateable()||
                Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Contact_Email__c.isupdateable()) {
            	deflectedObj.Core_IPS_Contact_Email__c = contactRecord.Email;
            }
        }
        if(!String.isBlank(caseInfoJSON.Product)){ //FLS Create/Update added -Gangadhar 29/09/2023
            if (Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Product__c.isCreateable()||
                Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Product__c.isupdateable()) {
            	deflectedObj.Core_IPS_Product__c = caseInfoJSON.Product;
        	}
        }
        //upsert deflectedObj;
       List<Core_IPS_Deflected_Object__c> deflectedObjList = new List<Core_IPS_Deflected_Object__c>{ deflectedObj };
Core_IPS_QueryService.upsertRecords(deflectedObjList);
deflectedObj = deflectedObjList[0];
//return deflectedObj.Id;
 
        return deflectedObj.Id; 
    }
    
    @AuraEnabled
    public static string updateDeflectedRecord(String deflectionId, String coveoDescription){
        Core_IPS_Deflected_Object__c deflectedObj = new Core_IPS_Deflected_Object__c();
        try{
            deflectedObj.Id = deflectionId;
            if (Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Status__c.isupdateable()) { //FLS Update added -Gangadhar 29/09/2023
            		deflectedObj.Core_IPS_Status__c = 'Abandoned';
                }
            if(!String.isBlank(coveoDescription)){
                if (Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Description_on_Coveo__c.isupdateable()) { //FLS Update added -Gangadhar 29/09/2023
                	deflectedObj.Core_IPS_Description_on_Coveo__c = coveoDescription;
                }
            }
            update deflectedObj;
        } catch(Exception e){
            Core_IPS_ExceptionHandling.logEntryWithException(e, 'Core_IPS_DeflectedObject_LWC_Ctrl', 'Core_IPS_Deflected_Object__c');
            return 'false';
        }
        return deflectedObj.Id;                                                                     
    }
    
    @AuraEnabled(cacheable=false)
    public static boolean updateDeflectedObject(String deflectedId, String caseId){
        Core_IPS_Deflected_Object__c deflectedObj = new Core_IPS_Deflected_Object__c();
        deflectedObj.id = deflectedId;
        if (Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Status__c.isCreateable()||Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Status__c.isupdateable())
        {
            deflectedObj.Core_IPS_Status__c = 'Case Created';
        }
        deflectedObj.Core_IPS_Case_ID__c = caseId;
        upsert deflectedObj;
        if(deflectedObj.Core_IPS_Status__c == 'Case Created' && deflectedObj.Core_IPS_Case_ID__c != null){
            return true;
        }
        else{
            return false;
        }
    }
    
    @AuraEnabled
    public static boolean updateDeflectedInfo(String deflectedId, String caseInfo){
        Core_IPS_Deflected_Object__c deflectedObj = new Core_IPS_Deflected_Object__c();
        deflectedObj.id = deflectedId;
        JSON2Apex caseInfoJSON = JSON2Apex.parse(caseInfo);
        String cleanedCaseInfo = '{"Subject":"'+caseInfoJSON.Subject+'","Sub_Category_Name":"'+caseInfoJSON.SubCategoryName+'","Sub_Category_ID":"'+caseInfoJSON.SubCategoryId+'","Project_Name":"'+caseInfoJSON.projectName+'","Project_ID":"'+caseInfoJSON.project+'","Product_Variant_Name":"'+caseInfoJSON.productvariantName+'","IntelProduct_Name"":"'+caseInfoJSON.ProductName+'","IntelProduct_ID":"'+caseInfoJSON.Product+'","Category_Name":"'+caseInfoJSON.CategoryName+'","Category_ID":"'+caseInfoJSON.CategoryId+'"}';
        // Niyaz -- 12/06/2025 --- added as part of vulnerability fix
        if (Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Search_JSON__c.isCreateable() || Schema.sObjectType.Core_IPS_Deflected_Object__c.fields.Core_IPS_Search_JSON__c.isupdateable())
        {
            deflectedObj.Core_IPS_Search_JSON__c = cleanedCaseInfo;
        }
        
        try{
            upsert deflectedObj;  
            return true;
        }
        catch(DmlException e){
            return false;
        }
        
        
    } 
    
    public class JSON2Apex {
        
        public String project;
        public String projectName;
        public String productvariant;
        public String productvariantName;
        public String Product;
        public String ProductName;
        public String Subject;
        public String CategoryId;
        public String CategoryName;
        public String SubCategoryId;
        public String SubCategoryName;
        public String Language;
        public String NickName;
        public String testQuestion;
        public String picklistQuestion;
        public String childQuestion1;
        public String childQuestion2;
        public List<ProdEdqRecs> prodEdqRecs;
        public Boolean showProdEdqs;
        public Boolean showEdqSection;
        public String contactId;
        public String accountId; 
    }
    
    public class ProdEdqRecs {
        public Boolean hasChild;
        public String id;
        public String label;
        public String palceholderText;
        public Boolean required;
        public String type;
        public String value;
        public List<Lovs> lovs;
    }
    public class Lovs {
        public String label;
        public String value;
    }
    
    @AuraEnabled
    public static JSON2Apex parse(String json) {
        return (JSON2Apex) System.JSON.deserialize(json, JSON2Apex.class);
    }
}