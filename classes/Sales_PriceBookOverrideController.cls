/*********************************************************************************************************************
Class Name    : Sales_PriceBookOverrideController
Version       : 1.0
Created Date  : April 2021  
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Puja Ingale        7-April-2021              Sales_PriceBookOverrideController
* *********************************************************************************************************************/
@isTest
public with sharing class Sales_PriceBookOverrideController {
    /*@AuraEnabled
    public static void setPricebook(Id objId, Id pId) {
        try{
            Order orderObj = [SELECT Id, Pricebook2Id  FROM Order WHERE Id=:objId];
            orderObj.Pricebook2Id=pId;
            update orderObj;
        }catch(Exception e){
            String pureErrorMsg ;          
            if(e.getMessage().contains('_EXCEPTION')){
                pureErrorMsg=e.getMessage().substringAfter('_EXCEPTION,').substringBeforeLast(': [');
                throw new AuraHandledException(pureErrorMsg);
            }
            else{
                throw new AuraHandledException(e.getMessage());
            }            
        }
    }
    
    /*
@AuraEnabled   //(cacheable=true)
public static Order onLoadDataProvider(Id objId) {
Order ord= [SELECT Id,Pricebook2Id,OrderItemCount__c,SBQQ__Quote__c FROM Order WHERE Id=:objId LIMIT 1];
return ord;
}

@AuraEnabled
public static Boolean checkActivePricebook() {
Boolean isActivePricebook=false;
for(Pricebook2 pbook : [SELECT Id, IsActive FROM Pricebook2]){
if(pbook.IsActive==true){
isActivePricebook=true;
}
else{
isActivePricebook= false;
}
}

}catch(Exception e){
String pureErrorMsg ;
if(e.getMessage().contains('_EXCEPTION')){
pureErrorMsg=e.getMessage().substringAfter('_EXCEPTION,').substringBeforeLast(': [');
throw new AuraHandledException(pureErrorMsg);
}
else{
throw new AuraHandledException(e.getMessage());
}            
}
return isActivePricebook;
}*/
    
}