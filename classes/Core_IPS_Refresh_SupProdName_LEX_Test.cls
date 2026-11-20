@isTest
public class Core_IPS_Refresh_SupProdName_LEX_Test {
   
   static List<User> listOfUser = new List<User>();
   static List<Asset> assetList = new List<Asset>();
   static List<Core_IPS_Supported_Product__c> testspProd = new List<Core_IPS_Supported_Product__c>();
   
   @TestSetUp static void getRecords(){
       
        //To get Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        
          for(Profile prof : ProfileList){
              profiles.put(prof.Name, prof.Id);
          }
       
        //To Create Users
        listOfUser = TestUtilities.getListOfUser(1);
         for(User Usr : listOfUser){
             Usr.ProfileID =  profiles.get('System Administrator');
         }
        insert listOfUser;
        System.assertEquals(listOfUser.get(0).ProfileID, profiles.get('System Administrator'));     
    }
    
  @isTest public static void validateProdNameTest(){
        
        getRecords();
        Test.startTest();
        UserRole urole = new UserRole(Name = 'CEO'); 
        User userObj ;
        Id intelSupportOwner = listOfUser.get(0).Id;
        
        System.runAs(listOfUser[0]){                     
        insert urole; 
        
        Profile p = [SELECT Id, Name FROM Profile WHERE name = 'System Administrator' LIMIT 1]; 
        userObj = new User(Alias = 'standt', 
                           Email='test1110099@intel.com', 
                           EmailEncodingKey='UTF-8', 
                           LastName='Testing', 
                           LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', 
                           ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', 
                           UserName='standarduser3445657588594534@testorg.com',
                           userRoleId = urole.Id );
        insert userObj;
        }
        List<User> userList = [SELECT Id,Name FROM User WHERE Id =: userObj.Id];
        
        Core_IPS_Product_Organization__c  org = new Core_IPS_Product_Organization__c( Core_IPS_Support_Org_Name__c = 'TestName',
                                                                                      Core_Organization_Description__c = 'TestDescription'        
                                                                                     );
        insert org;
        
        Product2 prod2 = new Product2(Name = 'Haswell EP',
                                      Core_Sales_Visible_Flag__c = false,
                                      Core_IPS_Visible_Flag_External__c = true,
                                      Core_IPS_Visible_Flag_Internal__c = 'Yes',
                                      IsActive = true,
                                      Core_Product_Org__c = 'IPS'
                                     ); 
        insert prod2;
        
        Core_IPS_Supported_Product__c sp = new Core_IPS_Supported_Product__c(Core_Product_Organization__c = org.Id,
                                                                             Core_EOIS__c = false,
                                                                             Core_Supported_Product_Name__c = 'Haswell test 12321',
                                                                             Core_Product__c = prod2.Id
                                                                            );
        insert sp;
      
        Asset assetObj = new Asset (Name = 'Test Asset',
                                    Core_Supported_Product__c = sp.Id );
        insert assetObj;
          
        List<Core_IPS_Supported_Product__c> splst = new List<Core_IPS_Supported_Product__c>{sp};
        testspProd = [SELECT Id,Core_Supported_Product_Name__c,Core_Product__r.name,Core_Product__c
                           FROM Core_IPS_Supported_Product__c 
                              WHERE Id =:sp.Id];
                  
        Core_IPS_Refresh_SupProdName_LEX.validateProdName(sp.Id);
        System.assert(sp!=null);   
        Test.stopTest();
  }  
}