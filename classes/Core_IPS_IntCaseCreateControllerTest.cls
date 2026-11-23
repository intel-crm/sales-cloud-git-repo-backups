@isTest(seeAllData=false)
private class Core_IPS_IntCaseCreateControllerTest {
    /*@isTest
private static void readFieldSetTest() {
Core_IPS_InternalCaseCreateController.readFieldSet('AssetFieldSet', 'asset');
}*/
    
    
    /*
    @isTest
    private static void getProjectListTest() {
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        insert ListOfAccounts;
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
        }
        insert ListOfContacts;
        Core_IPS_InternalCaseCreateController.getProjectList(ListOfContacts[0].Id);
    }*/
    
    @isTest
    private static void displayProductVariant() {
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        List<User> ListOfUser = TestUtilities.getListOfUser(1);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
            
        }
        insert ListOfUser;
        System.assert(ListOfUser[0].Id != null, 'Record not created');
        
        System.runAs(ListOfUser.get(0)){
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        insert ListOfAccounts;
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        
        // Create Contact
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
        }
        insert ListOfContacts;
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        
        Core_IPS_InternalCaseCreateController.getProjectList(ListOfContacts[0].Id);
        Core_IPS_InternalCaseCreateController.getProjectList('9087467387353');
       
        //Added by Sowmya - Start - 08/11/2024 - TWC745-7027 - Fix test coverage for all failed classes 
        List<Core_IPS_project__c> ListofProjects = TestUtilities.getListOfIpsProjects(1);
        insert ListofProjects;
        System.assert(ListofProjects[0].Id != null, 'Record not created');
        
        for(Core_IPS_project__c pro : ListofProjects){
              pro.core_status__c = 'Active';
         }
        update ListofProjects;
        
        Product2 prod = new Product2();
        prod.Core_Product_Name_EPM_ID__c='75025';
        prod.IsActive = true;
        prod.Core_Code_Name_EPM_ID__c ='75025';
        prod.Core_Sales_Visible_Flag__c = false;
        prod.IsActive = true;
        prod.Core_Product_Status__c= 'Active';
        prod.Core_IPS_Visible_Flag_External__c = true;
        prod.Core_IPS_Visible_Flag_Internal__c = 'Yes';
        prod.Core_Product_Org__c = 'IPS';
        prod.Core_Hierarchy_ID__c = '43';
        prod.Name = 'test';
        insert prod;
        System.assert(prod.Id != null, 'Record not created');
        
        Core_IPS_Product_Organization__c prodOrg = TestUtilities.getSupportOrg();
        insert prodOrg;
        System.assert(prodOrg.Id != null, 'Record not created');
        

        Core_IPS_Supported_Product__c SupportedProduct = new Core_IPS_Supported_Product__c();
        SupportedProduct.Core_Flag_Status__c = 'Auto Approve';
        SupportedProduct.Core_Product_EPM_ID__c = '75025';
        SupportedProduct.Core_IPS_Is_Show_Variant__c = true;
        SupportedProduct.Core_Product__c = prod.Id;
        SupportedProduct.Core_Product_Organization__c = prodOrg.Id;
        insert SupportedProduct;
        System.assert(SupportedProduct.Id != null, 'Record not created');
        
       //Sowmya - End - 08/11/2024 - TWC745-7027 - Fix test coverage for all failed classes 
        
        // Create Asset
        list<Asset> AssetList = TestUtilities.getAssetList(1);
        for(Asset Asst : AssetList){
            Asst.accountId = ListOfAccounts.get(0).Id;
            Asst.Contactid = ListOfContacts.get(0).id;
            //Added by Sowmya - Start - 08/11/2024 - TWC745-7027 - Fix test coverage for all failed classes 
        	Asst.Core_Supported_Product__c = SupportedProduct.Id;
            //Sowmya - End - 08/11/2024 - TWC745-7027 - Fix test coverage for all failed classes 
        
        }
        insert AssetList;
        System.assert(AssetList[0].Id != null, 'Record not created');
        
            Core_IPS_InternalCaseCreateController.displayProductVariant(AssetList[0].Id);
             //Added by Sowmya - Start - 08/11/2024 - TWC745-7027 - Fix test coverage for all failed classes 
        	// Core_IPS_InternalCaseCreateController.displayProductVariantNAC(AssetList[0].Id);
            Core_IPS_InternalCaseCreateController.displayProductVariantNAC(SupportedProduct.Id);
            //Sowmya - End - 08/11/2024 - TWC745-7027 - Fix test coverage for all failed classes 
        }
    }
   //Added by Sowmya - Start - 08/11/2024 - TWC745-7027 - Fix test coverage for all failed classes 
    @isTest
    private static void displayProductVariantFAEUser() {
       
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('IPS External Customer');
        List<Profile> profileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : profileList){
            profiles.put(prf.name, prf.id);
        }
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
      
        // Create Users
        List<User> ListOfUser = TestUtilities.getListOfUser(2);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        insert ListOfUser[0];
        System.assert(ListOfUser[0].Id != null, 'Record not created');
        
        System.runAs(ListOfUser.get(0)){
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        insert ListOfAccounts;
        System.assert(ListOfAccounts[0].Id != null, 'Record not created');
        
        // Create Contact
        for(Contact ContactRec : ListOfContacts){
            ContactRec.Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId();
            ContactRec.Accountid = ListOfAccounts.get(0).Id;
        }
        insert ListOfContacts;
        System.assert(ListOfContacts[0].Id != null, 'Record not created');
        
         
            List<Core_IPS_project__c> ListofProjects = TestUtilities.getListOfIpsProjects(1);
            insert ListofProjects;
            System.assert(ListofProjects[0].Id != null, 'Record not created');
        
            for(Core_IPS_project__c pro : ListofProjects){
                pro.core_status__c = 'Active';
            }
            update ListofProjects;
             
            ListOfUser[1].ProfileID =  profiles.get('IPS External Customer');
       		ListOfUser[1].contactId =  ListOfContacts[0].Id;
       		Insert ListOfUser[1];
            System.assert(ListOfUser[1].Id != null, 'Record not created');
        
         }  
         System.runAs(ListOfUser.get(1)){

          Core_IPS_InternalCaseCreateController.getProjectList(ListOfContacts[0].Id);
         }
    }
  //Sowmya - End - 08/11/2024 - TWC745-7027 - Fix test coverage for all failed classes 
        
}