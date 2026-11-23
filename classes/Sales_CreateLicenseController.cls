public without sharing class Sales_CreateLicenseController {
/******************************************************
Component Name    : Sales_CreateLicenseController
Created Date  : Jun 2021
Function      : US981428
Modification Log :
Developer                       Date                    Description
ananga.mohan.sen@accenture.com  21/06/2021               US981428
*****************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Sales_CreateLicenseControllerWrapper> getProductList(String licenseType) {
        List<Core_Product_Ext_Attribute__c> prodExtList=new List<Core_Product_Ext_Attribute__c>();
        List<Core_Product_Ext_Attribute__c> tempProdExtList=new List<Core_Product_Ext_Attribute__c>();
        List<Core_Product_Ext_Attribute__c> tempProdExtList1=new List<Core_Product_Ext_Attribute__c>();
        List<Core_Product_Ext_Attribute__c> tempProdExtList2=new List<Core_Product_Ext_Attribute__c>();
        Map<Id,SBQQ__ProductOption__c> optnProdMap=new Map<Id,SBQQ__ProductOption__c>();
        set<id> prodIds=new set<id>();
        //list<SBQQ__ProductOption__c> optnList=new list<SBQQ__ProductOption__c>();-- Unused Variable
        List<Sales_CreateLicenseControllerWrapper> responseProdList=new List<Sales_CreateLicenseControllerWrapper>();
        List<Sales_CreateLicenseControllerWrapper> finalProdResponseList=new List<Sales_CreateLicenseControllerWrapper>();
        if(licenseType=='Employee'){
            prodExtList=[select id,Core_SW_Prod_Additional_Dsc__c,Core_SW_Prod_Non_Commercial_Purpose_Nm__c,Core_SW_Lic_Type_Nm__c,Core_SW_Prod_Max_Rehost_Cnt__c,Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,                                    
                         Core_Product_Id__r.id,Core_Product_Id__r.IsActive,Core_Product_Id__r.SBQQ__SubscriptionTerm__c,Core_SW_Lic_Rehostable_Ind__c,
                         Core_SW_Prod_Expiration_Duration_Nbr__c,Core_Product_Id__r.name from Core_Product_Ext_Attribute__c 
                         where Core_Product_Id__r.IsActive=true and Core_SW_Prod_Non_Commercial_Purpose_Nm__c='employee' ];
        }
        else if(licenseType=='Evalution'){
            tempProdExtList=[select id,Core_SW_Prod_Non_Commercial_Purpose_Nm__c,Core_SW_Lic_Type_Nm__c,Core_SW_Prod_Max_Rehost_Cnt__c,Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Core_SW_Prod_Additional_Dsc__c,                                    
                             Core_Product_Id__r.id,Core_Product_Id__r.IsActive,Core_Product_Id__r.SBQQ__SubscriptionTerm__c,Core_SW_Lic_Rehostable_Ind__c,
                             Core_SW_Prod_Expiration_Duration_Nbr__c,Core_Product_Id__r.name,Core_SW_Prod_Web_Dsc__c from Core_Product_Ext_Attribute__c 
                             where Core_Product_Id__r.IsActive=true AND (Core_SW_Prod_Non_Commercial_Purpose_Nm__c='Evaluation' OR Core_SW_Prod_Non_Commercial_Purpose_Nm__c='Early Access' OR Core_SW_Prod_Non_Commercial_Purpose_Nm__c='Free')];
            for(Core_Product_Ext_Attribute__c prodExt:tempProdExtList){
                if(prodExt.Core_SW_Prod_Web_Dsc__c!=null && prodExt.Core_SW_Prod_Web_Dsc__c?.containsIgnoreCase('Discontinued') ){
                    tempProdExtList1.add(prodExt);
                }
                else{
                    tempProdExtList2.add(prodExt);
                }
            }
            prodExtList.addAll(tempProdExtList2);
            prodExtList.addAll(tempProdExtList1);
        }
        String regex1 ='[^0-9]';
        for(Core_Product_Ext_Attribute__c prodExt:prodExtList){
            Sales_CreateLicenseControllerWrapper wrapObj=new Sales_CreateLicenseControllerWrapper();
            wrapObj.prodExtId=prodExt.id;
            wrapObj.prodId=prodExt.Core_Product_Id__r.id;
            if(licenseType=='Evalution'){
                prodIds.add(prodExt.Core_Product_Id__r.id);
                wrapObj.optnAvailable=false;
                if(prodExt.Core_SW_Prod_Web_Dsc__c!=null){
                    List<String> words = prodExt.Core_SW_Prod_Web_Dsc__c.split('\\s+');
                    String s1=prodExt.Core_SW_Prod_Web_Dsc__c;                    
                    String s2=s1;
                    if(words.size()>1){
                        s2=words[0];
                    }
                    if((s2.replaceAll(regex1, ''))!=''){
                        wrapObj.SeqNo=  Integer.valueOf(s2.replaceAll(regex1, ''));
                    }
                    wrapObj.WebDesc=prodExt.Core_SW_Prod_Web_Dsc__c.replace(s2.replaceAll(regex1, ''),''); 
                }
                if(wrapObj.SeqNo==null){
                    wrapObj.SeqNo=99;
                }  
            }
            wrapObj.prodName=prodExt.Core_Product_Id__r.name;
            Integer maintenenceExpMonths=Integer.valueof(prodExt.Core_Product_Id__r.SBQQ__SubscriptionTerm__c);
            if(maintenenceExpMonths!=null){
                wrapObj.maintenenceExp=system.today().addMonths(maintenenceExpMonths);
            }
            else
                wrapObj.maintenenceExp=null;
            Integer licExpMonths=Integer.valueof(prodExt.Core_SW_Prod_Expiration_Duration_Nbr__c);
            if(licExpMonths!=null){
                wrapObj.licExp=system.today().addDays(licExpMonths);
            }
            else
                wrapObj.licExp=null;
            wrapObj.licType=prodExt.Core_SW_Lic_Type_Nm__c;
            if(prodExt.Core_SW_Lic_Type_Nm__c=='FIXED'){
                wrapObj.noSeats='1';
            }
            if(prodExt.Core_SW_Lic_Rehostable_Ind__c){
                wrapObj.maxRehost=prodExt.Core_SW_Prod_Max_Rehost_Cnt__c;
            }
            else{
                wrapObj.maxRehost=0;
            }
            wrapObj.prodExtTempLicAllowed=prodExt.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c;
            wrapObj.TandC=prodExt.Core_SW_Prod_Additional_Dsc__c;
            responseProdList.add(wrapObj);
            if(licenseType=='Evalution'){           
                responseProdList.sort();
            }
        }
        map<id,Sales_CreateLicenseControllerWrapper> wrapMap=new map<id,Sales_CreateLicenseControllerWrapper>();
        for(Sales_CreateLicenseControllerWrapper wrap:responseProdList){
            wrapMap.put(wrap.prodId, wrap);
            finalProdResponseList=wrapMap.values();
        }
        if(licenseType=='Evalution'){
            for(SBQQ__ProductOption__c optn:[select id,SBQQ__Type__c,SBQQ__OptionalSKU__c,SBQQ__ConfiguredSKU__c 
                                             from SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__c IN:prodIds  and SBQQ__Type__c='Related Product']){
                                                 optnProdMap.put(optn.SBQQ__ConfiguredSKU__c,optn);
                                             }
            for(Sales_CreateLicenseControllerWrapper wrap:finalProdResponseList){
                if(optnProdMap.containsKey(wrap.prodId)){
                    wrap.optnAvailable=true;
                }
            }
        }
        return finalProdResponseList;
    }
    @AuraEnabled(cacheable=true)
    public static Boolean  getFaeUser(){
        Boolean isFAEuser=false;
        List<PermissionSetAssignment> pset = [SELECT Id,Assignee.Name,PermissionSet.Name, PermissionSet.Label 
                                              FROM PermissionSetAssignment WHERE AssigneeId= : userinfo.getuserid()];
        for (PermissionSetAssignment psa: pset)
        {
            if(psa.PermissionSet.Name.equals(System.Label.Sales_Permission_SEP)){
                isFAEuser=true; 
            }
        }                                          
        return isFAEuser;    
    }
    public class  Sales_CreateLicenseControllerWrapper implements Comparable{
        @AuraEnabled
        public Id prodExtId;
        @AuraEnabled
        public Id prodId;
        @AuraEnabled
        public String prodName;
        @AuraEnabled
        public String noSeats;
        @AuraEnabled
        public Date maintenenceExp;
        @AuraEnabled
        public Date licExp;     
        @AuraEnabled
        public String licType;
        @AuraEnabled
        public Decimal maxRehost;
        @AuraEnabled
        public Boolean prodExtTempLicAllowed;
        @AuraEnabled
        Public String TandC;
        @AuraEnabled
        Public Boolean optnAvailable;
        @AuraEnabled
        Public String WebDesc;
        @AuraEnabled
        Public integer SeqNo;
        public integer compareTo(Object recordTocompare){
            return Integer.valueOf(SeqNo - ((Sales_CreateLicenseControllerWrapper)recordTocompare).SeqNo);
        }
    }
}