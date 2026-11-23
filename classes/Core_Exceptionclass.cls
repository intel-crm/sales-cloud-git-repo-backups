public without sharing class Core_Exceptionclass
{
   public string InsertException(string  Record_Id,string ClassName,string objectName,string Msg,string MethodName,exception ex)
   {
       try
       {
       Core_Exceptions__c Exce =  new Core_Exceptions__c();
       Exce.Core_Class_Name__c = ClassName;
       //Exce.Core_Exception__c = string.valueOf(ex.Message());
       Exce.Core_Login_User_Id__c = userInfo.getUserId();
       Exce.Core_Method_Name__c = MethodName;
       Exce.Core_Record_Id__c = Record_Id;
       Exce.Core_Exception__c = Json.serialize(ex);
       insert Exce;
       return Exce.Id;
       }
       catch(exception ex1)
       {
         
       }
       
       
       
       return '';
   }
   public string InsertException(string  Record_Id,string ClassName,string objectName,string Msg,string MethodName,String ex)
   {
       try
       {
       Core_Exceptions__c Exce =  new Core_Exceptions__c();
       Exce.Core_Class_Name__c = ClassName;
       //Exce.Core_Exception__c = string.valueOf(ex.Message());
       Exce.Core_Login_User_Id__c = userInfo.getUserId();
       Exce.Core_Method_Name__c = MethodName;
       Exce.Core_Record_Id__c = Record_Id;
       Exce.Core_Exception__c = ex;
       insert Exce;
       return Exce.Id;
       }
       catch(exception ex1)
       {
         
       }
       
       
       
       return '';
   }
}