@isTest
public class Core_IPS_Refresh_SupProdNamecntrl_Test {  
   
   static List<User> listOfUser = new List<User> ();
   static List<Core_IPS_Supported_Product__c> testspProd = new List<Core_IPS_Supported_Product__c>();
   
   static void getRecords(){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        listOfUser = TestUtilities.getListOfUser(1);
        for(User Usr : listOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert listOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));     
    }
    
  public static testMethod void validateProdNameTest(){
        
        getRecords();
        Test.startTest();
        UserRole urole = new UserRole(Name= 'CEO'); 
        User u ;
        Id intelSupportOwner = listOfUser.get(0).id;
        System.runAs(ListOfUser[0]){                     
        insert urole; 
        System.assert(urole.Id != null, 'UserRole Record not created');

        Profile p = [select id, name from Profile where name = 'System Administrator' limit 1]; 
        u = new User(Alias = 'standt', Email='test1110099@intel.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser3445657588594534@testorg.com', userRoleId = urole.Id);
        insert u;
        System.assert(u.Id != null, 'User Record not created');
            
         }
        List<User> userList = [Select id,Name from User where id =: u.id];
        
        Core_IPS_Product_Organization__c  org = new Core_IPS_Product_Organization__c ( 
            Core_IPS_Support_Org_Name__c = 'TestName',
            Core_Organization_Description__c = 'TestDescription'        
        );
        insert org;
        System.assert(org.Id != null, 'org Record not created');

        Product2 prod2 = new Product2(
            Name = 'Haswell EP',
            Core_Sales_Visible_Flag__c = false,
            Core_IPS_Visible_Flag_External__c = true,
            Core_IPS_Visible_Flag_Internal__c = 'Yes',
            IsActive = true,
            Core_Product_Org__c = 'IPS'
        ); 
        insert prod2;
        System.assert(prod2.Id != null, 'product Record not created');

        Core_IPS_Supported_Product__c sp= new Core_IPS_Supported_Product__c(
            
            Core_Product_Organization__c = org.Id,
            Core_EOIS__c = false,
            Core_Supported_Product_Name__c = 'Haswell test 12321',
            Core_Product__c=prod2.id
        );
        insert sp;
       System.assert(sp.Id != null, 'Supported product Record not created');

      //Added by Sowmya - Start - 04/11/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        List<Asset> astlst = TestUtilities.getAssetList(1);
        astlst[0].Core_Supported_Product__c = sp.id;
        insert astlst;
       System.assert(astlst[0].Id != null, 'Asset Record not created');

		//Sowmya - End - 04/11/2024 - TWC745-6800 - Fix test coverage for all failed classes 
              
        list<Core_IPS_Supported_Product__c> splst = new list<Core_IPS_Supported_Product__c>{sp};
                  testspProd = [select id,Core_Supported_Product_Name__c,Core_Product__r.name,Core_Product__c from Core_IPS_Supported_Product__c where id =:sp.id];
         //COmmented for Classic EOL :Tejaswini         
      /*  PageReference pp= page.Core_IPS_Refresh_SupProdName;
        Test.setCurrentPage(pp);       */
        ApexPages.currentPage().getParameters().put('Id',testspProd[0].id);
        Core_IPS_Refresh_SupProdNameController testCon = new Core_IPS_Refresh_SupProdNameController();
        
        testCon.validateProdName();
        testCon.finished();
        System.assert(sp!=null);   
        Test.stopTest();
  }

}