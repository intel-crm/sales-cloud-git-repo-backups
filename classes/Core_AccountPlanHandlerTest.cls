@isTest
public class Core_AccountPlanHandlerTest {
    
    @isTest
    static void testAccountPlanShareToBuExecutives(){
        //Creating accounts
        Id newAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acctInTrty = new Account(Name = 'TestAccountterritory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA', Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                       BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert acctInTrty;
        }
        
        
        Account acctNotInTrty = new Account(Name = 'TestAccountterritory2', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                       BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA', Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                       BillingPostalCode = '12345', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI());
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert acctNotInTrty;
        }
        
        //Creating Account Plan records
        Account_Plan__c accountPlanToShare = new Account_Plan__c(Plan_Name__c = 'Test Account Plan',Account__c = acctInTrty.Id);
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert accountPlanToShare;
        }
        
        
        Account_Plan__c accountPlanNotToShare = new Account_Plan__c(Plan_Name__c = 'Test Account Plan not shared',Account__c = acctNotInTrty.Id);
       System.runAs(Core_Test_Utility.systemAdminUser){  
            insert accountPlanNotToShare;
        }
        
        List<Account_Plan__c> accountPlanList = new List<Account_Plan__c>();
        accountPlanList.add(accountPlanToShare);
        accountPlanList.add(accountPlanNotToShare);
        
        //Creating Public Group
        Group buExePG = [select id from group where DeveloperName ='AGS_BU_Executive_Users_Group'];
        
        
        
        /*Creating Territory 
        Territory2Model activeTerrModel = [Select id from Territory2Model where State = 'Active' ];
        Id terrTypeId = [Select Id from Territory2Type limit 1][0].Id;
        
        Territory2 trty = new Territory2(Name='Test Territory 1 in TestMethod', DeveloperName='Test_Territory_1', Territory2ModelId=activeTerrModel.Id,
        Territory2TypeId=terrTypeId);
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert trty;
        }*/
        Territory2 trty = [select id from Territory2 where DeveloperName = 'SMG_WW_Read'] ;
        
        ObjectTerritory2Association acctTerr = new ObjectTerritory2Association(ObjectId = acctInTrty.Id,Territory2Id = trty.Id,AssociationCause='Territory2Manual');
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert acctTerr;
        }
        
        Account_Plan__Share apShare = new Account_Plan__Share(ParentId = accountPlanNotToShare.id,UserOrGroupId=buExePG.id,AccessLevel='Read');
        System.runAs(Core_Test_Utility.systemAdminUser){  
            insert apShare;
        }

        Test.startTest();
        Core_AccountPlanHandler.accountPlanShareToBuExecutives(accountPlanList);
        Test.stopTest();
        
        List<Account_Plan__Share> finalApShare = [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM Account_Plan__Share WHERE ParentId =:accountPlanToShare.id];
        System.assertEquals(true,finalApShare.size()>0,'Account Plan Share records are created');
        
    }

}