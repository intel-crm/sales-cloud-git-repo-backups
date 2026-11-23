/******************************************************
     Component Name    : Sales_FreeLicenseProvider 
     Created Date  : Aug 2023
     Function      : US-0037522 - Created as part of SSLC enhancements for Free/Eval Licenses
     Modification Log :
     Developer                       Date                    Description
     Ayan Chatterjee                23/08/2023               US-0037522
     *****************************************************/
public without sharing class Sales_FreeLicenseProvider {
    @AuraEnabled(cacheable=true)
    Public static List<Sales_Host__c> getHosts(String licenseType){
        List<String> hostIds = new List<String>();
        List<Sales_Host__Share> hslist =[select id,UserOrGroupId,ParentId  from Sales_Host__Share where UserOrGroupId = :UserInfo.getUserId()];
        for(Sales_Host__Share hs : hslist){
            hostIds.add(hs.ParentId);
        }
        if(licenseType == 'FIXED'){
            return [select Id, Name, Sales_Computer_Type__c,Sales_Computer_Name_Txt__c from Sales_Host__c where id in :hostIds and Sales_License_Type__c = 'FIXED' and Sales_isActiveHost__c=true WITH SECURITY_ENFORCED order by createddate desc];
        }
        else if(licenseType == 'FLOAT'){
            return [select Id, Name, Sales_Computer_Type__c,Sales_Computer_Name_Txt__c from Sales_Host__c where id in :hostIds and Sales_License_Type__c = 'FLOAT' and Sales_isActiveHost__c=true WITH SECURITY_ENFORCED order by createddate desc];
        }
        else{
            return [select Id, Name, Sales_Computer_Type__c,Sales_Computer_Name_Txt__c from Sales_Host__c where id in :hostIds and Sales_isActiveHost__c=true WITH SECURITY_ENFORCED order by createddate desc];
        }
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getProductOptions(Id prodId) {
        List<SBQQ__ProductOption__c> productOptions = [SELECT Id, SBQQ__Type__c, SBQQ__ConfiguredSKU__c, SBQQ__ConfiguredSKU__r.Name, SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__c, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Name, SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Web_Dsc__c FROM SBQQ__ProductOption__c WHERE SBQQ__Type__c='Related Product' AND SBQQ__ConfiguredSKU__c=:prodId AND SBQQ__OptionalSKU__r.Name != null AND SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__c != NULL];
        List<Sales_ProductOptionWrapper> wrapList=new List<Sales_ProductOptionWrapper>();
        List<String> pids = new List<String>();
        //List<Id> oids = new List<Id>();--Unsed Variable
        String regex1 ='[^0-9]';
        for (SBQQ__ProductOption__c c : productOptions) {
            Sales_ProductOptionWrapper wrap=new Sales_ProductOptionWrapper();
            if(c.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Web_Dsc__c!=null){
                List<String> words = c.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Web_Dsc__c.split('\\s+');
                String s1=c.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Web_Dsc__c;
                    String s2;
                    if(words.size()>1){
                        s2=s1.substring(0, s1.indexOf(' '));
                    }else{
                        s2=s1;
            }
                    if((s2.replaceAll(regex1, ''))!=''){
                        wrap.SeqNo=  Integer.valueOf(s2.replaceAll(regex1, ''));
                    }
                    if( wrap.SeqNo==null){
                        if(s2=='Discontinued'){
                            wrap.SeqNo=99999;
                        }
                        else{
                            wrap.SeqNo=9999;
                        }
                    }
                    wrap.WebDesc=c.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Web_Dsc__c.replaceFirst(s2.replaceAll(regex1, ''),'')+'%'+c.Id; 
            }else{
                wrap.WebDesc='%'+c.Id;
                wrap.SeqNo=9999;
            } 
            wrapList.add(wrap);
        }        
        wrapList.sort();
        for(Sales_ProductOptionWrapper wrap:wrapList){
            pids.add(wrap.WebDesc);
        }
        Map<String,List<String>> mapValues = new Map<String,List<String>>();
        mapValues.put('productOptions',pids);
        return mapValues;
    }
    public class  Sales_ProductOptionWrapper implements Comparable{
        Public String WebDesc;
        Public integer SeqNo;
        public integer compareTo(Object recordTocompare){
			return Integer.valueOf(SeqNo - ((Sales_ProductOptionWrapper)recordTocompare).SeqNo);
		}        
    }
    @AuraEnabled()
	public static Sales_License__c createLicNew(Id productId ,String[] productOption , Id hostId , Integer seats) {
         List<Sales_License__c> licList=new List<Sales_License__c>();
         id userId = UserInfo.getUserId();
         id accountId;
         User loginUser = [Select id,Email,FirstName, LastName,Country, ContactId,contact.accountid from User where Id = :userId and IsActive=true];
         if(loginUser.ContactId == null){
             Map<String, User> emailUserIdMap = new Map<String, User>();
             emailUserIdMap.put(loginUser.Email, loginUser);
             loginUser.ContactId = Sales_CreateLicenseContactUser_Utility.createLicenseContactUsers(emailUserIdMap);
         }
         id primaryAdminConid=loginUser.contactid;
         accountId=[select accountid from contact where id=:primaryAdminConid].accountid;
         Sales_License__c lic = new Sales_License__c();
         lic.Sales_License_Web_Display_Flag__c=true;
         lic.Sales_License_Type__c='Evaluation';
         lic.Sales_License_Primary_Admin_Contact__c =primaryAdminConid;
		 lic.Sales_License_Start_Date_Dt__c=system.today();
		 lic.Sales_License_Status__c='Licensed';
         lic.Sales_License_Avbl_Qty_Nbr__c=0;
		 lic.Sales_License_Account__c=accountId;
         lic.Sales_License_Quantity__c = seats;
         lic.Sales_License_Product__c = productId;
         lic.Sales_License_Host_Node_Id__c=hostId;
         List<Core_Product_Ext_Attribute__c> tempProdExtList=new List<Core_Product_Ext_Attribute__c>();
         tempProdExtList=[select id,Core_SW_Prod_Non_Commercial_Purpose_Nm__c,Core_SW_Lic_Type_Nm__c,Core_SW_Prod_Max_Rehost_Cnt__c,Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Core_SW_Prod_Additional_Dsc__c,                                    
                         Core_Product_Id__r.id,Core_Product_Id__r.IsActive,Core_Product_Id__r.SBQQ__SubscriptionTerm__c,Core_SW_Lic_Rehostable_Ind__c,
                         Core_SW_Prod_Expiration_Duration_Nbr__c,Core_Product_Id__r.name,Core_SW_Prod_Web_Dsc__c from Core_Product_Ext_Attribute__c 
                         where Core_Product_Id__c = :productId and Core_Product_Id__r.IsActive=true AND (Core_SW_Prod_Non_Commercial_Purpose_Nm__c='Evaluation' OR Core_SW_Prod_Non_Commercial_Purpose_Nm__c='Early Access' OR Core_SW_Prod_Non_Commercial_Purpose_Nm__c='Free')];
         for(Core_Product_Ext_Attribute__c prodExt : tempProdExtList){
             Integer maintenenceExpMonths=Integer.valueof(prodExt.Core_Product_Id__r.SBQQ__SubscriptionTerm__c);
             if(maintenenceExpMonths!=null){
                 lic.Sales_License_Maintenance_Exp_Dt__c=system.today().addMonths(maintenenceExpMonths);
             }
             else
                 lic.Sales_License_Maintenance_Exp_Dt__c=null;
             Integer licExpMonths=Integer.valueof(prodExt.Core_SW_Prod_Expiration_Duration_Nbr__c);
             if(licExpMonths!=null){
                  lic.Sales_License_Expiration_Date_Dt__c=system.today().addDays(licExpMonths);
             }
             else
                  lic.Sales_License_Expiration_Date_Dt__c=null;
             if(prodExt.Core_SW_Lic_Rehostable_Ind__c){
                 lic.Sales_License_Avbl_Rehost_Nbr__c=prodExt.Core_SW_Prod_Max_Rehost_Cnt__c;
             }
             else{
                 lic.Sales_License_Avbl_Rehost_Nbr__c=0;
             }
             if(prodExt.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c){
                 lic.Sales_License_Available_Temp_Licenses__c=seats;
             }
         }
		 licList.add(lic);
         insert licList;
         List<Id> optionalProductSku = new List<Id>();
         for(SBQQ__ProductOption__c op : [select id, SBQQ__OptionalSKU__c from SBQQ__ProductOption__c where id in :productOption]){
            optionalProductSku.add(op.SBQQ__OptionalSKU__c);
         }
         if(optionalProductSku.size()>0){
            Boolean isOptionalProdCreated = createOptnLic(licList[0].id,optionalProductSku);
         }
         Sales_License__c license = [select id , name from Sales_License__c where id = :licList[0].id];
         Sales_LicenseGenIntegration_Utility.returnHostIdDetail(hostId,'HostId','Event Feedback');
         return license;
    }
    @AuraEnabled()
    public static  Boolean createOptnLic(String licId,List<Id> productOption) {
        List<Sales_License__c> OptnlicInsertList=new List<Sales_License__c>();
        Boolean optinalProdCreated=false;
        try{  
            Set<Id> productIdSet = new Set<Id>(productOption);
            Sales_License__c licObj=[select id,Sales_License_Quantity__c,Sales_License_Product_Name_Txt__c,Sales_License_Maintenance_Exp_Dt__c,
                                     Sales_License_Expiration_Date_Dt__c,Sales_License_Start_Date_Dt__c, Sales_License_Status__c,Sales_License_Primary_Admin_Contact__c,Sales_License_Account__c,Sales_License_Avbl_Qty_Nbr__c,
                                     Sales_License_Avbl_Rehost_Nbr__c,Opt_in_out__c,Sales_License_Activation_Code__c,Sales_License_SAPLine_Nbr__c from Sales_License__c where id =:licId];
            List<Product2> prodList=[select id from product2 where id in :productOption];
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
    }
}