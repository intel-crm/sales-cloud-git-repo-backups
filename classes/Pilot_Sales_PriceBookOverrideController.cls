/*********************************************************************************************************************
Class Name    : Pilot_Sales_PriceBookOverrideController
Version       : 1.0
Created Date  : Sep 2021

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shalini Kumari 			20/9/2021               Pilot Project for testing framework.
* *********************************************************************************************************************/
public class Pilot_Sales_PriceBookOverrideController {
 @AuraEnabled
    public static void setPricebook(Id objId, Id pId) {
        try{
            //Order orderObj = [SELECT Id, Pricebook2Id  FROM Order WHERE Id=:objId];
            //correct it
            //Order orderObj = SEL_Order.newInstance().selectByOrderId(objId);
            List<Id> objIdList = new List<Id>{objId};
            Order orderObj = SEL_Order.newInstance().selectByOrderId(objIdList)[0];
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