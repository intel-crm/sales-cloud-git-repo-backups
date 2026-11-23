/*********************************************************************************************************************
Class Name    : Sales_ValidateProduct
Version       : 1.0
Created Date  : June 2022
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma            29-June-2022         TWC3144-418 - SPIKE | Orders | Alternate/Duplicate Product identify during Contract Renewal  
* *********************************************************************************************************************/
public without sharing class Sales_ValidateProduct {
    public static final string ORIGIN = 'Sales_ValidateProduct';
    public static final string CRITICALSEVERITY = 'Critical';
    public static final string INFOSEVERITY = 'Info';
    public static final string SUCCESSSEVERITY = 'Operation Completed Successfully!';
    public static final string FAILSEVERITY = 'Operation Failed!';
    public static final string PROJECT = 'PSG Sales';
    private static final string CONTRACT_PROGRAM = 'PSG';
    private static final string IN_PROGRESS = 'InProgress';
    private static final string QUEUED  ='Queued';
    private static final string INPROGRESS ='In Progress';
    public Boolean status=true; 
    @AuraEnabled
    public static string checkProductInactive(String recordId,boolean childCheck){
        Set<Id> inactiveProdConIds=new Set<Id>();
        Set<Id> inactiveProdIds = new Set<Id>();
        String record=RecordId+'::RenewContract';
        string returnMsg='';
        for(SBQQ__RecordJob__c recordjob : [select id,SBQQ__RecordId__c,  SBQQ__JobDetails__c, SBQQ__JobStatus__c from SBQQ__RecordJob__c where SBQQ__RecordId__c = : record order by LastModifiedDate desc limit 1]){
            if(recordjob!=null && (recordjob.SBQQ__JobStatus__c==QUEUED || recordjob.SBQQ__JobStatus__c==INPROGRESS)){
                returnMsg=System.label.Sales_RenwalInProgressErrMsg;
                return returnMsg;
            }
        }
        if(childCheck==true){
            try{
                contract con=new contract(id=recordId);
                con.SBQQ__RenewalQuoted__c=false;
                update con;
            }
            catch(Exception e){
            }
        }
        List<contract> conList=new List<contract>();
        list<SBQQ__Subscription__c> sublist= new list<SBQQ__Subscription__c>();
        String str='';
        for(SBQQ__Subscription__c subs : [Select id ,Name,SBQQ__Contract__c,SBQQ__Contract__r.StartDate,SBQQ__Contract__r.SBQQ__RenewalQuoted__c,SBQQ__Contract__r.EndDate,SBQQ__SubscriptionStartDate__c,SBQQ__SubscriptionEndDate__c,SBQQ__Product__c,SBQQ__Product__r.Name,SBQQ__Product__r.Core_OPN__c,SBQQ__Product__r.IsActive,SBQQ__Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,SBQQ__Quantity__c,SBQQ__BundledQuantity__c,SBQQ__RenewalQuantity__c,SBQQ__RequiredByProduct__c,SBQQ__RequiredById__c,SBQQ__DynamicOptionId__c,SBQQ__TerminatedDate__c from SBQQ__Subscription__c where SBQQ__Contract__c=:recordId ]){
            if(subs.SBQQ__Product__r.IsActive == true && (subs.SBQQ__TerminatedDate__c==null)){
                subs.Sales_Renewal_Status__c=System.label.Sales_renewalStatusOpn1;
                sublist.add(subs);                
            }
            if(subs.SBQQ__TerminatedDate__c!=null){
                subs.Sales_Renewal_Status__c=System.label.Sales_renewalStatusOpn5;
                sublist.add(subs);
            }
            if(subs.SBQQ__Contract__r.SBQQ__RenewalQuoted__c==true){
                returnMsg='failure';
            }
            else if(subs.SBQQ__Product__r.IsActive == false){
                inactiveProdIds.add(subs.SBQQ__Product__c);
                inactiveProdConIds.add(subs.SBQQ__Contract__c);
            }
        }
        try{
            if(sublist.size()>0){
                update sublist;
            }
        }
        catch (Exception e){
            Core_Log_Entry.logEntryWithDetails(Sales_ValidateProduct.ORIGIN, Sales_ValidateProduct.PROJECT,'',Sales_ValidateProduct.INFOSEVERITY,'','Error occurred while updating renewal comments on :Subscription : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', '', '');   
        }
        if(inactiveProdIds.size()>0){
            returnMsg=Sales_ValidateProduct.updateProductDetails_LicenseSubscription(inactiveProdIds,inactiveProdConIds,null);
            if(returnMsg=='' || returnMsg==null){
                contract con=new contract(id=recordId);
                con.SBQQ__RenewalQuoted__c=true;
                update con;
                returnMsg='success';
            }
        }
        else{
            if(returnMsg==null || returnMsg==''){
                contract con=new contract(id=recordId);
                con.SBQQ__RenewalQuoted__c=true;
                update con;
                returnMsg='success';
            }
        }
        return returnMsg;
    }
    public static String updateProductDetails_LicenseSubscription(Set<Id> productSet,Set<Id> conIds,Map<Id,Contract> conMap){
        set<Id> productId= new Set<Id>();
        Set<String> prodOpn= new Set<String>();
        //Map<String,Product2> newProdMap = new Map<String,Product2>();--Unused
        Map<String,Product2> OpnMap = new Map<String,Product2>();
        Map<Id,Id> duplicateAndNewProdMap = new Map<Id,Id>();
        Map<String,Id> duplicateAndNewOpnMap = new Map<String,Id>();
        map<ID,string> errormap = new map<ID,string>();
        String Str ='';
        boolean inactiveProductFound=false;
        boolean duplicateProducFound=false;
        boolean errormsg=false;
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        List<Product2> proList=new List<Product2>();
        for(Product2 InactiveprodList:[Select  id,Name,IsActive,Core_OPN__c,Core_Item_Id__c,Core_Product_Org__c,Core_Item_Orderable_Ind__c, Core_Item_Quotable_Ind__c, Core_Product_Ext_Attribute_Id__c, Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c, Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c from Product2 where id in:productSet]){
            productId.add(InactiveprodList.id);
            prodOpn.add(InactiveprodList.Core_OPN__c);
            OpnMap.put(InactiveprodList.Core_OPN__c,InactiveprodList);
        }
        proList=[Select id,Name,IsActive,Core_OPN__c,Core_Item_Id__c,Core_Product_Type_Nm__c,Core_Sales_Visible_Flag__c,Core_Product_Org__c,Core_Item_Orderable_Ind__c, Core_Item_Quotable_Ind__c, Core_Product_Ext_Attribute_Id__c, Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c, Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c from Product2 where Core_OPN__c IN:prodOpn and Id Not IN:productId and  IsActive=true and
                 Core_Product_Org__c='Sales'order by CreatedDate desc];
        if(proList.size()>0){
            for(Product2 prod :proList){
                if(prod.Core_OPN__c==OpnMap.get(prod.Core_OPN__c).Core_OPN__c && !duplicateAndNewOpnMap.containsKey(prod.Core_OPN__c)){
                    duplicateAndNewOpnMap.put(OpnMap.get(prod.Core_OPN__c).id,prod.id);
                    if((prod.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == OpnMap.get(prod.Core_OPN__c).Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c) && ( prod.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c== OpnMap.get(prod.Core_OPN__c).Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c
                                                                                                                                                                                        && prod.Core_Product_Org__c=='Sales' && prod.Core_Sales_Visible_Flag__c==true &&  prod.Core_Product_Type_Nm__c=='Tool' && prod.Core_Item_Orderable_Ind__c==true && prod.Core_Item_Quotable_Ind__c==true )){
                                                                                                                                                                                            duplicateAndNewProdMap.put(OpnMap.get(prod.Core_OPN__c).id,prod.id);
                                                                                                                                                                                        }
                }
            }
        }
        if(productId.size()!=duplicateAndNewOpnMap.size()){
            for(SBQQ__Subscription__c sub: [Select id,Name,SBQQ__Product__c,Sales_Renewal_Status__c,SBQQ__Product__r.Core_OPN__c,SBQQ__Contract__c,SBQQ__Product__r.Name,SBQQ__Contract__r.Sales_Program__c,SBQQ__Product__r.IsActive,SBQQ__DynamicOptionId__c from SBQQ__Subscription__c where SBQQ__Product__c IN:productId and SBQQ__Product__c Not IN:duplicateAndNewOpnMap.keySet() and SBQQ__Product__r.IsActive=false and SBQQ__Contract__c In:conIds and SBQQ__Contract__r.Sales_Program__c =:CONTRACT_PROGRAM and (SBQQ__TerminatedDate__c>TODAY or SBQQ__TerminatedDate__c=null)  limit 10000 FOR UPDATE]){
                errormsg=true;
                inactiveProductFound=true;  
                sub.Sales_Renewal_Status__c=System.label.Sales_renewalStatusOpn2;
                subList.add(sub);
            }
        }
        if(duplicateAndNewOpnMap.size()!=duplicateAndNewProdMap.size()){
            List<SBQQ__Subscription__c> subListForOpn = [Select id,Name,SBQQ__Product__c,Sales_Renewal_Status__c,SBQQ__Product__r.Core_OPN__c,SBQQ__Contract__c,SBQQ__Product__r.Name,SBQQ__Contract__r.Sales_Program__c,SBQQ__Product__r.IsActive,SBQQ__DynamicOptionId__c from SBQQ__Subscription__c where SBQQ__Product__c IN:duplicateAndNewOpnMap.keySet() and SBQQ__Product__c Not IN:duplicateAndNewProdMap.keySet() and SBQQ__Product__r.IsActive=false and SBQQ__Contract__c In:conIds and SBQQ__Contract__r.Sales_Program__c =:CONTRACT_PROGRAM and (SBQQ__TerminatedDate__c>TODAY or SBQQ__TerminatedDate__c=null)  limit 10000 FOR UPDATE];
            if(subListForOpn.size()>0){
                errormsg=true;
                for(SBQQ__Subscription__c subs : subListForOpn){
                    duplicateProducFound=true;
                    subs.Sales_Renewal_Status__c=System.label.Sales_renewalStatusOpn3;
                    subList.add(subs);
                }
            }
        }
        if( inactiveProductFound==true && duplicateProducFound==true){
            str+=System.label.Sales_ProductInactiveMsg+'\n';
            str+= System.label.Sales_DuplicateProductFoundMsg;
        }
        else
        {
            if(inactiveProductFound==true){
                str=System.label.Sales_ProductInactiveMsg+' '+System.label.Sales_DuplicateProductFoundMsg;
            }
            else if(duplicateProducFound==true){
                str=System.label.Sales_ProductInactiveMsg+' '+System.label.Sales_DuplicateProductFoundMsg;
            }
        }
        if(duplicateAndNewProdMap.size()>0){
            List<SBQQ__Subscription__c> subListToUpdate = [Select id,Name,SBQQ__Product__c,Sales_Renewal_Status__c,SBQQ__Product__r.Core_OPN__c,SBQQ__Contract__c,SBQQ__Contract__r.Sales_Program__c,SBQQ__Product__r.IsActive,SBQQ__DynamicOptionId__c from SBQQ__Subscription__c where SBQQ__Product__c IN:duplicateAndNewProdMap.keySet() and SBQQ__Product__r.IsActive=false and SBQQ__Contract__c In:conIds and SBQQ__Contract__r.Sales_Program__c =:CONTRACT_PROGRAM and (SBQQ__TerminatedDate__c>TODAY or SBQQ__TerminatedDate__c=null) limit 10000 FOR UPDATE];
            if(subListToUpdate.size()>0){
                for(SBQQ__Subscription__c subs : subListToUpdate){
                    subs.Sales_Renewal_Status__c = System.label.Sales_renewalStatusOpn4;
                    subList.add(subs);
                }
            }
            if(errormsg==false){
                System.enqueueJob(new updateProductDetailsOnLicenseSubscription(productId,conIds,duplicateAndNewProdMap));
            }
        }   
        try{
            if(subList.size()>0){
                update subList;
            }
        }
        catch (Exception e){
            Core_Log_Entry.logEntryWithDetails(Sales_ValidateProduct.ORIGIN, Sales_ValidateProduct.PROJECT,'',Sales_ValidateProduct.INFOSEVERITY,'','Error occurred while updating renewal status on :Subscription : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', '', '');    
        }
        return str;
    }
    public without sharing class updateProductDetailsOnLicenseSubscription implements System.Queueable{
        private set<Id> productId;
        private set<Id> conIds;
        private Map<Id,Id> duplicateAndNewProdMap ;
        public updateProductDetailsOnLicenseSubscription(set<Id> productId,set<Id> conIds,Map<Id,Id> duplicateAndNewProdMap){
            this.productId=productId;
            this.conIds=conIds;
            this.duplicateAndNewProdMap = duplicateAndNewProdMap;
        }
        public void execute(System.QueueableContext ctx){
            Sales_UpdateContactDetails.BypassTriggerForContactUpdate=true;
            Boolean successLicense=true; 
            Boolean successSubscription=true;
            List<String> dynamicOptionProd = new List<String>();
            List<Sales_License__c> licenseListUpdate = new List<Sales_License__c>();
            List<Sales_License__c> licenseList = [Select id,Name, Sales_License_Product__c,Sales_License_Product__r.IsActive,Sales_License_Product__r.Core_OPN__c,Sales_License_Contract__c from Sales_License__c  where Sales_License_Product__c IN:duplicateAndNewProdMap.keySet() and Sales_License_Contract__c IN:conIds and Sales_License_Product__r.IsActive=false limit 10000 FOR UPDATE] ;
            if(licenseList.size()>0){
                try{
                    for(Sales_License__c lic : licenseList){
                        if(lic.Sales_License_Product__c!=duplicateAndNewProdMap.get(lic.Sales_License_Product__c)){
                            lic.Sales_License_Product__c = duplicateAndNewProdMap.get(lic.Sales_License_Product__c);
                        }
                        licenseListUpdate.add(lic);
                    }
                    if(licenseListUpdate.size()>0){
                        update licenseListUpdate;
                    }
                    System.enqueueJob(new updateProductDetailsOnLicenseSubscription(productId,conIds,duplicateAndNewProdMap));
                }
                catch (Exception e){
                    Core_Log_Entry.logEntryWithDetails(Sales_UpdateProductDetails.ORIGIN, Sales_UpdateProductDetails.PROJECT,'',Sales_UpdateProductDetails.INFOSEVERITY,'','Error occurred while initializing the updation of product Details on :license  : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', '', '');   
                    successLicense=false;
                }
            }
            else{
                List<SBQQ__Subscription__c> subListUpdate= new List<SBQQ__Subscription__c>();
                List<SBQQ__Subscription__c> subList = [Select id,Name,SBQQ__Product__c,Sales_Renewal_Status__c,SBQQ__Product__r.Core_OPN__c,SBQQ__Contract__c,SBQQ__Contract__r.Sales_Program__c,SBQQ__Product__r.IsActive,SBQQ__DynamicOptionId__c from SBQQ__Subscription__c where SBQQ__Product__c IN:duplicateAndNewProdMap.keySet() and SBQQ__Product__r.IsActive=false and SBQQ__Contract__c In:conIds and SBQQ__Contract__r.Sales_Program__c =:CONTRACT_PROGRAM and (SBQQ__TerminatedDate__c>TODAY or SBQQ__TerminatedDate__c=null) limit 10000 FOR UPDATE];
                if(subList.size()>0){
                    try{
                        for(SBQQ__Subscription__c subs : subList){
                            subs.Sales_Renewal_Status__c = System.label.Sales_renewalStatusOpn1;
                            if(subs.SBQQ__Product__c!=duplicateAndNewProdMap.get(subs.SBQQ__Product__c)){
                                subs.SBQQ__Product__c = duplicateAndNewProdMap.get(subs.SBQQ__Product__c);
                            }
                            if(subs.SBQQ__DynamicOptionId__c!=null){
                                dynamicOptionProd = subs.SBQQ__DynamicOptionId__c.split(':');
                                subs.SBQQ__DynamicOptionId__c = dynamicOptionProd[0]+':'+duplicateAndNewProdMap.get(subs.SBQQ__Product__c);
                            }
                            subListUpdate.add(subs);
                            dynamicOptionProd.clear();
                        }
                        if(subListUpdate.size()>0){
                            update subListUpdate;
                        }
                        System.enqueueJob(new updateProductDetailsOnLicenseSubscription(productId,conIds,duplicateAndNewProdMap));
                    }
                    catch (Exception e){
                        Core_Log_Entry.logEntryWithDetails(Sales_ValidateProduct.ORIGIN, Sales_ValidateProduct.PROJECT,'',Sales_ValidateProduct.INFOSEVERITY,'','Error occurred while initializing the updation of product Details on :Subscription : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', '', '');   
                        successSubscription=false;
                    }
                }
            }  
            if(successLicense==true){  
                Core_Log_Entry.logEntryWithDetails(Sales_ValidateProduct.ORIGIN, Sales_ValidateProduct.PROJECT,'',Sales_ValidateProduct.INFOSEVERITY,'','Successfully Updated Product Details on License','','', '');    
            }
            if(successSubscription==true){     
                Core_Log_Entry.logEntryWithDetails(Sales_ValidateProduct.ORIGIN, Sales_ValidateProduct.PROJECT,'',Sales_ValidateProduct.INFOSEVERITY,'','Successfully Updated Product Details on Subscription','','', '');   
            }
        }    
    }
    @AuraEnabled
    public static Boolean validateAccount(String contId) {
        Contract contractRecord=[select Id,Account.Core_Deactivated__c from Contract where Id=:contId limit 1];
        if(contractRecord.Account.Core_Deactivated__c==true) {
            return true;
        }
        else {
            return false;
        } 
    }
}