/****************************************************************************************************************************************
* Class Name  : Core_MDF_CCP_UtilityClass_Test
* Version     : 1.0 
* Created Date: 9-07-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sushma Hamom        9/7/2018                    Created to test CCP Utility class for DataBase Update and processing teh results
*                                                 Log Enrty creation
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_CCP_UtilityClass_Test {
     @isTest static void test(){     


            List<Account> acctList = new List<Account>();
            
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1.Core_Account_Type__c = 'Reseller';
            //acc1.Core_Sales_Groups__c = 'Automotive Sales Group';
            acc1.Industry = 'Food & Beverage';
            Database.insert(acc1);
            system.assert(acc1.id!=Null);
            
            acc1.Core_Sales_Groups__c = 'Automotive Sales Group Testjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjhhhhhhhhhhhhhhhhhhhhhhhhhhhhooooooooooooooobbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
            acctList.add(acc1);
            Account acc2 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 2', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc2.Core_Account_Type__c = 'Reseller';
            //acc2.Core_Sales_Groups__c = 'Automotive Sales Group';
            acc2.Industry = 'Food & Beverage'; 
            Database.insert(acc2);
            acctList.add(acc2);
            String errortext = 'Test';
            Core_MDF_CCP_UtilityClass.updateListAndLogErrors(acctList,errortext);
            Core_MDF_CCP_UtilityClass.logErrorinLogObject(errortext, 'Test');
         	system.assert(acc2.id!=Null);
            
         	String s ;
            try {
			s = s.toLowerCase();
            }
            Catch(Exception e){
            Core_MDF_CCP_UtilityClass.getErrorDetails(e);
            Core_MDF_CCP_UtilityClass.logError(e);                
            }
         	

      }
}