public with sharing class Product_RetrieveProdData {
    @AuraEnabled(cacheable=true)
    public static Map<String,Integer> getProdData() {       
        Map<String,Integer> finalMap = new Map<String,Integer>();         
        AggregateResult salesActiveProducts = [select count(id)cnt from Product2 where IsActive = true and Core_Product_Org__c ='sales'];
        AggregateResult ipsActiveProducts = [select count(id)cnt from Product2 where IsActive = true and Core_Product_Org__c ='ips'];
        AggregateResult[] vphProductTypes = [select Core_Product_Type_EPM_ID__c,count(id)cnt from Product2 where Core_Hierarchy_ID__c ='43' and Core_Product_Type_EPM_ID__c <> null  group by Core_Product_Type_EPM_ID__c ];
        AggregateResult[] vplchProductTypes =[select Core_Platform_EPM_ID__c,count(id)cnt from Product2 where Core_Hierarchy_ID__c ='59' and Core_Platform_EPM_ID__c <> null  group by Core_Platform_EPM_ID__c ];
        AggregateResult avlNewDesignProdCount = [select count(id)cnt from product2 where Core_Avail_for_New_Designs__c = true];
        AggregateResult IQRProdCount = [select count(id)cnt from product2 where Core_IQR_Visible__c = true];
        AggregateResult newDsgnRegProdCount = [select count(id)cnt from product2 where Core_Design_Registration_Eligible_Ind__c = true];
        AggregateResult IPSProdCount = [select count(id)cnt from product2 where Core_IPS_Visible_Flag__c = true];        
        if( salesActiveProducts != null){
            finalMap.put('Sales Active Products',(Integer)salesActiveProducts.get('cnt'));
        }
        if( ipsActiveProducts != null){
            finalMap.put('IPS Active Products',(Integer)ipsActiveProducts.get('cnt'));
        }
        if( vphProductTypes != null){
            finalMap.put('VPH Product Types',vphProductTypes.size());
        }
        if( vplchProductTypes != null){
            finalMap.put('VPLCH Product Types',vplchProductTypes.size());
        }
        if( IPSProdCount != null){
            finalMap.put('Products With IPS Visible Flag',(Integer)IPSProdCount.get('cnt'));
        }        
        if( IQRProdCount != null){
            finalMap.put('Products With IQR Visible Flag',(Integer)IQRProdCount.get('cnt'));
        }
        if( newDsgnRegProdCount != null){
            finalMap.put('Products With DDR Eligible',(Integer)newDsgnRegProdCount.get('cnt'));
        }
        if( avlNewDesignProdCount != null){
            finalMap.put('Products With Available for New Designs',(Integer)avlNewDesignProdCount.get('cnt'));
        }
         
        return finalMap;
    }
    @AuraEnabled(cacheable=true)
    public static datetime getLastRefreshDate(){
        Product2 prod = [select format(CreatedDate) from product2  order by CreatedDate desc limit 1];
        return prod.CreatedDate;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getReportId(){
        List<String> repIdList = new List<String>();        
        for(Report rep:[Select Id from Report where DeveloperName IN ('VPH_Product_Types_Report','VPLCH_Product_Types_Report')]){
            repIdList.add(rep.Id);
        }
        return repIdList;
    }
    @AuraEnabled(cacheable=true)
    public static Boolean hasPermissionSet(){
        String userId = UserInfo.getUserId();
        List<PermissionSetAssignment> psAssgnList = new List<PermissionSetAssignment>();
        Boolean flag = false;
        if(!String.isBlank(Label.Product_DashboardPermissionSets) && (Label.Product_DashboardPermissionSets == 'Empty' || Label.Product_DashboardPermissionSets == 'empty')){
            flag = true;
        }
        else if(!String.isBlank(Label.Product_DashboardPermissionSets) && !String.isBlank(userId)){
            psAssgnList = [Select Id,Assignee.name,AssigneeId from PermissionSetAssignment Where AssigneeId =:userId and PermissionSet.Name IN: Label.Product_DashboardPermissionSets.split(',')];
            if(!psAssgnList.isEmpty()){
                flag = true;
            }
        }        
        return flag;
    }
}