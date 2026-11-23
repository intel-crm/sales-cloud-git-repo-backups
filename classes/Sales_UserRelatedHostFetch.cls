public without sharing class Sales_UserRelatedHostFetch {

    @AuraEnabled(cacheable=true)
    Public static List<Sales_Host__c> getHosts(){
        /*List<String> hostIds = new List<String>();
        List<Sales_Host__Share> hslist =[select id,UserOrGroupId,ParentId  from Sales_Host__Share where UserOrGroupId = :UserInfo.getUserId()];
        for(Sales_Host__Share hs : hslist){
            hostIds.add(hs.ParentId);
        }*/
        return [select Id, Name, Sales_Computer_Type__c from Sales_Host__c WITH SECURITY_ENFORCED order by createddate desc];
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SBQQ__ProductOption__c> getProductOptions(Id prodId) {
       List<SBQQ__ProductOption__c> a=[Select Id,SBQQ__Type__c, SBQQ__ConfiguredSKU__c,SBQQ__ConfiguredSKU__r.Name, SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.Name from SBQQ__ProductOption__c where SBQQ__Type__c='Related Product'and SBQQ__ConfiguredSKU__c=:prodId];
        return a;
    }
    
    @AuraEnabled()
	public static Sales_License__c createLicNew(Id productId ,List<Id> optionalProducts , Id hostId , Integer seats) {
         System.debug('In debug log ' +seats);
         List<Sales_License__c> licList=new List<Sales_License__c>();
         id userId = UserInfo.getUserId();
         id accountId;
       /*  User loginUser = [Select id,Email,FirstName, LastName, ContactId,contact.accountid from User where Id = :userId and IsActive=true];
         if(loginUser.ContactId == null){
             Map<String, User> emailUserIdMap = new Map<String, User>();
             emailUserIdMap.put(loginUser.Email, loginUser);
             loginUser.ContactId = Sales_CreateLicenseContactUser_Utility.createLicenseContactUsers(emailUserIdMap);
         }
         id primaryAdminConid=loginUser.contactid;
         accountId=[select accountid from contact where id=:primaryAdminConid].accountid;
         system.debug('userid>>>----'+primaryAdminConid+'----'+accountId);*/
         Sales_License__c lic = new Sales_License__c();
         lic.Sales_License_Web_Display_Flag__c=true;
         lic.Sales_License_Type__c='Evaluation';
       //  lic.Sales_License_Primary_Admin_Contact__c =primaryAdminConid;
		 lic.Sales_License_Start_Date_Dt__c=system.today();
		 lic.Sales_License_Status__c='Licensed';
         lic.Sales_License_Avbl_Qty_Nbr__c=0;
		// lic.Sales_License_Account__c=accountId;
         lic.Sales_License_Quantity__c = seats;
         lic.Sales_License_Product__c = productId;
         lic.Sales_License_Host_Node_Id__c=hostId;
         //lic.Sales_License_Product_Name_Txt__c = licrqst.Product_Name__c;
         //lic.Sales_License_PriAdm_Email__c = licrqst.Requester_Email__c;       
         
         //lic.PSG_Free_License_Request__c= licrqst.id;
        
         List<Core_Product_Ext_Attribute__c> tempProdExtList=new List<Core_Product_Ext_Attribute__c>();
         tempProdExtList=[select id,Core_SW_Prod_Non_Commercial_Purpose_Nm__c,Core_SW_Lic_Type_Nm__c,Core_SW_Prod_Max_Rehost_Cnt__c,Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Core_SW_Prod_Additional_Dsc__c,                                    
                         Core_Product_Id__r.id,Core_Product_Id__r.IsActive,Core_Product_Id__r.SBQQ__SubscriptionTerm__c,Core_SW_Lic_Rehostable_Ind__c,
                         Core_SW_Prod_Expiration_Duration_Nbr__c,Core_Product_Id__r.name,Core_SW_Prod_Web_Dsc__c from Core_Product_Ext_Attribute__c 
                         where Core_Product_Id__c = :productId and Core_Product_Id__r.IsActive=true AND (Core_SW_Prod_Non_Commercial_Purpose_Nm__c='Evaluation' OR Core_SW_Prod_Non_Commercial_Purpose_Nm__c='Early Access' OR Core_SW_Prod_Non_Commercial_Purpose_Nm__c='Free')];
         for(Core_Product_Ext_Attribute__c prodExt : tempProdExtList){
             //Maintainence & License Expiry Dates Logic
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
             
             //Available Rehost ,Available temporary license Logic
             if(prodExt.Core_SW_Lic_Rehostable_Ind__c){
                 lic.Sales_License_Avbl_Rehost_Nbr__c=prodExt.Core_SW_Prod_Max_Rehost_Cnt__c;
             }
             else{
                 lic.Sales_License_Avbl_Rehost_Nbr__c=0;
             }
             if(prodExt.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c){
                 system.debug('prodExtTempLicAllowed true');
                 lic.Sales_License_Available_Temp_Licenses__c=seats;
                 
             }
         }
       
		 licList.add(lic);
         System.debug('liccc ' +lic);
         insert licList;
         System.debug('License created ' + licList[0].id);
         Sales_License__c license = [select id , name from Sales_License__c where id = :licList[0].id];
         Sales_LicenseGenIntegration_Utility.returnHostIdDetail(hostId,'HostId','Event Feedback');
         System.debug('license ' +license);
         return license;
        
    }
}