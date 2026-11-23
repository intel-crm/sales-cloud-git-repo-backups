/***************************************************************************************************** 
Class Name :	Core_MDF_checkSObjectCRUDPermission
Description:    Server side controller for Core_MDF_PFR_Community_New/Edit button
				component which checks whether user have object access or not
Added By   :    Accenture - SS 
Modified By:                      Date:09/04/2018                     Changes:None  
******************************************************************************************************/
public with sharing class Core_MDF_checkSObjectCRUDPermission {
    
/***************************************************************************************************** 
Method Name :	checkSObjectCreatePermission
Added By   :    Accenture - SS
Modified By:                      Date:09/04/2018                     Changes:None  
******************************************************************************************************/
    @AuraEnabled
    public static Boolean checkSObjectCreatePermission(String objectName){
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(objectName);

		Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Boolean checkCreate = r.createable;
       	return checkCreate;
    }
    
/***************************************************************************************************** 
Method Name :	checkSObjectEditPermission
Added By   :    Accenture - SS
Modified By:                      Date:09/04/2018                     Changes:None  
******************************************************************************************************/
    @AuraEnabled
    public static Boolean checkSObjectEditPermission(String objectName){
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(objectName);

		Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Boolean checkEdit = r.updateable;
       	return checkEdit;  
    }
    
/***************************************************************************************************** 
Method Name :	checkSObjectDeletePermission
Added By   :    Accenture - KK
Modified By:                      Date:08/08/2019                     Changes:None  
******************************************************************************************************/
    @AuraEnabled
    public static Boolean checkSObjectDeletePermission(String objectName){
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(objectName);

		Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Boolean checkDelete = r.deletable;
       	return checkDelete;  
    }
    
}