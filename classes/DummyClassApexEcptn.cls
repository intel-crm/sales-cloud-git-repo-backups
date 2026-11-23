public class DummyClassApexEcptn{
    //Handled Exceptions
    public static void DummyMethodApexException1(){
        String s;
        try{
            s.toLowerCase();
        }
        catch (NullPointerException e) {
            if(e.getMessage() != null){
                Core_Exceptions__c excep=new Core_Exceptions__c(); 
                excep.Core_Exception__c=e.getMessage();                
                excep.Core_Class_Name__c='DummyClassApexEcptn';
                excep.Core_Method_Name__c='DummyMethodApexException1';
                excep.Core_IPS_Object_Name__c='Account';
                excep.Core_Login_User_Id__c=userInfo.getUserId();
                //excep.Core_Record_Id__c=accountsToUpdate.Id;
                Database.insert(excep, false);
                System.debug('NullPointerException Hit'+ e.getMessage()); 
            }             
        }        
    } 
    
    //FIELD_CUSTOM_VALIDATION_EXCEPTION
    public static void DummyMethodApexException2(){
        Account acc = new Account(); 
        List<Account> listacc = new List<Account>();
        try{ 
            List<Account> accList = [Select Id,name,Core_CIM_ID__c from Account];
            For(Account acct:accList){
                if(acct.Core_CIM_ID__c != null){
                    acct.Name = 'Test Account Name test'; 
                    listacc.add(acct);
                }
            }
            update listacc;            
        }catch(Exception e){
            if(e.getMessage() != null){
                Core_Exceptions__c excep=new Core_Exceptions__c(); 
                excep.Core_Exception__c=e.getMessage();                
                excep.Core_Class_Name__c='DummyClassApexEcptn';
                excep.Core_Method_Name__c='DummyMethodApexException2';
                excep.Core_IPS_Object_Name__c='Account';
                excep.Core_Login_User_Id__c=userInfo.getUserId();
                Database.insert(excep, false);
                System.debug('Validation Rule Hit'+ e.getMessage()); 
            }             
        }     
    }
    
    //DML Exceptions
    public static void DummyMethodApexException3(){
        try {     
            Account m = new Account();
            insert m; 
        } catch(DmlException e) { 
            if(e.getMessage() != null){
                Core_Exceptions__c excep=new Core_Exceptions__c(); 
                excep.Core_Exception__c=e.getMessage();                
                excep.Core_Class_Name__c='DummyClassApexEcptn';
                excep.Core_Method_Name__c='DummyMethodApexException3';
                excep.Core_IPS_Object_Name__c='Account';
                excep.Core_Login_User_Id__c=userInfo.getUserId();
                Database.insert(excep, false);
                System.debug('DML'+ e.getMessage()); 
            }             
        }
    }
    
    //Unhandled Exceptions - ELF    
    public static void DummyMethodApexException4(){
    DummyMethodApexException45();
    }
     //Unhandled Exceptions - ELF   
    @future
    public static void DummyMethodApexException45(){  
        List<Account> accounts;
        for (Account acc : accounts){                
            List<Case> openCases = [SELECT Id, AccountId, Status FROM Case where Status ='New'];
            List<Case> workingCases = [SELECT Id, AccountId, Status FROM Case where Status ='Open'];
            for(Case cse : openCases){                    
                List<Case> openCases1 = [SELECT Id, AccountId, Status FROM Case where Status ='New'];
                List<Case> workingCases1 = [SELECT Id, AccountId, Status FROM Case where Status ='Open'];
                if (acc.Id == cse.AccountId){
                    cse.Status = 'Closed';
                } 
            }  
        }         
    }
}