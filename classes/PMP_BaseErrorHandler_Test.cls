@isTest
public class PMP_BaseErrorHandler_Test {

    static testMethod void formatException(){        
        String sClass='';
        String sSeverity='';
            
        try{
         Account acct = new Account();
            insert acct;
        }
        catch(Exception e){
            PMP_BaseErrorHandler.formatException(sClass, sSeverity, e);    
        }        
    }

}