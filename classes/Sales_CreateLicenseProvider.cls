@isTest
public without sharing class Sales_CreateLicenseProvider {
/******************************************************
Component Name    : Sales_CreateLicenseProvider
Created Date  : Jun 2021
Function      : US981428
Modification Log :
Developer                       Date                    Description
ananga.mohan.sen@accenture.com  21/06/2021               US981428
*****************************************************/
    /*@AuraEnabled(cacheable=true)
    Public static Sales_License__c getLicense(String recordId){
        Sales_License__c lic=[Select id,Sales_License_Product__c,Sales_License_Order_Product__c,Sales_License_Type__c,Sales_Tool_License_Type__c,Sales_License_Quantity__c
                              from Sales_License__c where Id =:recordId ];
        return lic;
    }
    @AuraEnabled
    public static  Sales_License__c createLic(String json) {
        Sales_License__c licObj=new Sales_License__c();
        try{
            list<Object> parsedLicData = (list<Object>)system.JSON.deserializeUntyped(json);
            id userId = UserInfo.getUserId();
            id accountId;
            /*User loginUser = [Select id,Email,FirstName, LastName, Country, ContactId,contact.accountid from User where Id = :userId and IsActive=true];
            if(loginUser.ContactId == null){
                Map<String, User> emailUserIdMap = new Map<String, User>();
                emailUserIdMap.put(loginUser.Email, loginUser);
                loginUser.ContactId = Sales_CreateLicenseContactUser_Utility.createLicenseContactUsers(emailUserIdMap);
            }
            id primaryAdminConid=loginUser.contactid;
            accountId=[select accountid from contact where id=:primaryAdminConid].accountid;
            List<Sales_License__c> licList=new List<Sales_License__c>();
            for(Object jsonObj : parsedLicData){
                Map<String,Object> parseMap = (Map<String,Object> )jsonObj;
                Sales_License__c lic=new Sales_License__c();
                lic.Sales_License_Product__c=(id)parseMap.get('prodId');
                lic.Sales_License_Quantity__c=Integer.valueOf(parseMap.get('noSeats'));
                lic.Sales_License_Product_Name_Txt__c=(String)parseMap.get('prodName');
                String mainExpDate=String.valueOf(parseMap.get('maintenenceExp'));
                if(mainExpDate!='' && mainExpDate!=null){
                    lic.Sales_License_Maintenance_Exp_Dt__c=Date.valueOf(mainExpDate);
                }
                String licExpDate=String.valueOf(parseMap.get('licExp'));
                if(licExpDate!='' && licExpDate!=null){
                    lic.Sales_License_Expiration_Date_Dt__c=Date.valueOf(licExpDate);
                }
                lic.Sales_License_Web_Display_Flag__c=true;
                lic.Sales_License_Start_Date_Dt__c=system.today();
                if((Boolean)parseMap.get('isEmployee')){
                    lic.Sales_License_Type__c='Employee';
                    lic.Sales_License_Status__c='Unlicensed';
                    lic.Sales_License_Avbl_Rehost_Nbr__c=Integer.valueOf(parseMap.get('maxRehost'));
                }
                if(!(Boolean)parseMap.get('isEmployee')){
                    lic.Sales_License_Status__c='Unlicensed';
                    lic.Sales_License_Type__c='Evaluation';
                    lic.Opt_in_out__c=Boolean.valueOf(parseMap.get('optin'));
                    lic.Sales_License_Avbl_Rehost_Nbr__c=Integer.valueOf(parseMap.get('maxRehost'));
                }
                lic.Sales_License_Primary_Admin_Contact__c =primaryAdminConid;
                lic.Sales_License_Account__c=accountId;
                if(Boolean.valueOf(parseMap.get('prodExtTempLicAllowed'))){
                    lic.Sales_License_Available_Temp_Licenses__c=Integer.valueOf(parseMap.get('noSeats'));
                }
                lic.Sales_License_Avbl_Qty_Nbr__c=Integer.valueOf(parseMap.get('noSeats'));
                licList.add(lic);
            } 
            insert licList;
            id licid=licList[0].id;
            licObj=[select id,Sales_License_Activation_Code__c,Sales_License_Web_Display_Flag__c,Sales_License_Primary_Admin_Contact__c,
                    Sales_License_Product__c,Sales_Tool_License_Type__c,Sales_License_Product__r.Core_Prod_Tool_Type_Nm__c from Sales_License__c where id=:licid];
        }
        catch(Exception e){
        }
        return licObj;
    }
    @AuraEnabled
    public static  Boolean createOptnLic(String licId,List<Id> optProdIds) {
        List<Sales_License__c> OptnlicInsertList=new List<Sales_License__c>();
        Boolean optinalProdCreated=false;
        try{  
            Set<Id> productIdSet = new Set<Id>(optProdIds);
            Sales_License__c licObj=[select id,Sales_License_Quantity__c,Sales_License_Product_Name_Txt__c,Sales_License_Maintenance_Exp_Dt__c,
                                     Sales_License_Expiration_Date_Dt__c,Sales_License_Start_Date_Dt__c, Sales_License_Status__c,Sales_License_Primary_Admin_Contact__c,Sales_License_Account__c,Sales_License_Avbl_Qty_Nbr__c,
                                     Sales_License_Avbl_Rehost_Nbr__c,Opt_in_out__c,Sales_License_Activation_Code__c,Sales_License_SAPLine_Nbr__c from Sales_License__c where id =:licId];
            List<Product2> prodList=[select id from product2 where id IN :productIdSet];
            for(Product2 prod:prodList){
                Sales_License__c lic=new Sales_License__c();
                lic.Sales_License_Quantity__c=licObj.Sales_License_Quantity__c;
                lic.Sales_License_Product_Name_Txt__c=licObj.Sales_License_Product_Name_Txt__c;
                lic.Sales_License_Maintenance_Exp_Dt__c=licObj.Sales_License_Maintenance_Exp_Dt__c;
                lic.Sales_License_Expiration_Date_Dt__c=licObj.Sales_License_Expiration_Date_Dt__c;
                lic.Sales_License_Start_Date_Dt__c=licObj.Sales_License_Start_Date_Dt__c;
                lic.Sales_License_Status__c=licObj.Sales_License_Status__c;
                lic.Sales_License_Primary_Admin_Contact__c=licObj.Sales_License_Primary_Admin_Contact__c;
                lic.Sales_License_Account__c=licObj.Sales_License_Account__c;
                lic.Sales_License_Avbl_Qty_Nbr__c=licObj.Sales_License_Avbl_Qty_Nbr__c;
                lic.Sales_License_Avbl_Rehost_Nbr__c=licObj.Sales_License_Avbl_Rehost_Nbr__c;
                lic.Opt_in_out__c=licObj.Opt_in_out__c;
                lic.Sales_License_Web_Display_Flag__c=false;
                lic.Sales_License_Type__c='Optional';
                lic.Sales_License_Product__c=prod.id;
                lic.Sales_Parent_License__c=licId;
                lic.Sales_License_Activation_Code__c=licObj.Sales_License_Activation_Code__c;
                lic.Sales_License_SAPLine_Nbr__c= licObj.Sales_License_SAPLine_Nbr__c;
                OptnlicInsertList.add(lic);
            }
            insert OptnlicInsertList; 
        } 
        catch(Exception e){
        }
        if(!OptnlicInsertList.isEmpty()){
            optinalProdCreated=true;
        }
        return optinalProdCreated;                        
    }*/
}