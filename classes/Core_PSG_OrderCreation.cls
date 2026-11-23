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
    private static Integer cnt=0; 
    @AuraEnabled
    public static Order createOrder(Order objacc){
      //  Integer cnt =0;
        try{
            System.debug('before insert of order');
            insert objacc;
            Integer val = cnt++;
            System.debug('count'+cnt++);
            System.debug('>>'+objacc.Id);
            return objacc;
           
        }catch(Exception e){                     
             throw new AuraHandledException(e.getMessage());
        }  
        
    }
}