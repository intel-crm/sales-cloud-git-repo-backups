/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Batch_Upd_Acct_GlobalMNCODM_Test 
Version     : 1.0 
Created Date: 3/22/16
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Shailaja Gandam            3/22/16               Initial Version
*****************************************************************************************************************************************************************************************************/
@isTest
public class Core_Batch_Upd_Acct_GlobalMNCODM_Test 
{
    static testMethod void testAcctGlobalMNCODM()
    {
           
        List<Territory2> lstTerritory2 = new List<Territory2>();
      
        //create territorymodel 
       Territory2Model tModel = new Territory2Model();
          tModel.name = 'SGtest1';
                tModel.developername = 'SGtest1';
                insert tModel;
        //create territory with gloabl mcn/odm flag = true
        Id tNamedType = [Select id from territory2type where MasterLabel = 'Named / Strategic Accounts'].Id;
       
        territory2 t2 = new territory2();
         t2.name = 'SGtest1';
         t2.developername = 'SGtest1';
         t2.Territory2ModelId = tModel.Id;
         t2.territory2typeId = tNamedType;
         t2.Core_Global_MNC_ODM__c = true;
         lstTerritory2.add(t2);    
         insert lstTerritory2; 
       
      
   System.runAs(Core_Test_Utility.systemAdminUser) {
     	list<Account> acclist = new list<Account>();
           
               // Create a new account  
                Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
                Account acct = new Account(Name = 'SG_3/28 test Account1 territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                           BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                           BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
                acclist.add(acct); 
      			Account acct1 = new Account(Name = 'SG_3/28 test Account2 territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                           BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                           BillingPostalCode = '12345', Core_CIM_ID__c = '8675309', Core_Global_MNC_ODM_Account__c = 'Gloabl Dell');
        		acclist.add(acct1);                       		
                insert acclist;
         
         
         list<ObjectTerritory2Association> objectassocitelist = new list<ObjectTerritory2Association>();
         
         ObjectTerritory2Association oTerri2 = new ObjectTerritory2Association();
         
         oTerri2.ObjectId = acclist[0].Id;
         oterri2.territory2Id = lstTerritory2[0].Id;
         oterri2.AssociationCause  = 'Territory2Manual';
         objectassocitelist.add(oTerri2);

         insert objectassocitelist;
      			 
        test.startTest();
        database.executebatch(new Core_Batch_Upd_Acct_GlobalMNCODM());
        test.stopTest();
   }
    }
}