/*********************************************************************************************************************
Class Name    : Sales_License_GenTriggerUtil_Test
Version       : 1.0
Created Date  : May 2021  
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Mohammad Dilshad           17-May-2021              Test class for Sales_License_GenTriggerUtil_Test
* ******************************************************************************************************************/
@isTest
public class Sales_License_GenTriggerUtil_Test {
 
   
     /*@isTest static void testblockLicenseGeneratorDeletion(){
        
        list<Sales_License_Generator__c> saleslicenseGenList = new list<Sales_License_Generator__c>();
        Sales_License_Generator__c salesLicenseGenerator = new Sales_License_Generator__c();
        salesLicenseGenerator.Name='Gen';
        salesLicenseGenerator.Sales_License_Feature_Lyn_Syntx_txt__c='-p';
        salesLicenseGenerator.Sales_License_Generator_txt__c='test';
  
        Sales_License_Generator__c salesLicenseGenerator1 = new Sales_License_Generator__c();
        salesLicenseGenerator1.Name='Gen1';
        salesLicenseGenerator1.Sales_License_Feature_Lyn_Syntx_txt__c='-t';
        salesLicenseGenerator1.Sales_License_Generator_txt__c='test1'; 
        saleslicenseGenList.add(salesLicenseGenerator);
        saleslicenseGenList.add(salesLicenseGenerator1); 
        insert saleslicenseGenList;
         
        
        Sales_License_Group__c licGroup= new Sales_License_Group__c();
        licGroup.Name = 'Partner1';
        licGroup.Sales_License_Generator__c=salesLicenseGenerator.id;
        licGroup.Sales_License_Parameter_txt__c='test1';
        licGroup.Sales_License_Description_dsc__c='test1';
        insert licGroup;
         
         
         try
			{
				Delete 	saleslicenseGenList;
			}
			catch(Exception ee)
			{}
        
        Test.startTest();
        Sales_License_GenTriggerUtil.blockLicenseGeneratorDeletion(saleslicenseGenList) ; 
        Test.stopTest();
        system.assert(saleslicenseGenList.size()>0);
        
    }*/
        
    
}