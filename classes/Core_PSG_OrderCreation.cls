/*********************************************************************************************************************
Class Name    : Core_PSG_OrderCreation
Version       : 1.0
Created Date  : Jan 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Nilesh Mithapelli           11-Jan-2021             Order Creation from lightning component
* *********************************************************************************************************************/
public class Core_PSG_OrderCreation {
    
    @AuraEnabled
    public static Order createOrder(Order objacc){
        try{  
            insert objacc;
            System.debug('>>'+objacc.Id);
            return objacc;
           
        }catch(Exception e){                     
             throw new AuraHandledException(e.getMessage());
        }  
        
    }
}