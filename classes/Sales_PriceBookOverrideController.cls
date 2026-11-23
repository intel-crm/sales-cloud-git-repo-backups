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
public with sharing class Sales_PriceBookOverrideController {
    @AuraEnabled
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
}