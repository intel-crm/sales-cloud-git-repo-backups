@istest
public class Core_IPS_EoisErrorController_test
{
    static List<User> ListOfUser = new List<User> ();
    static User CommunityUser;
static void getRecords (){
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> strProf = new List<String>();
        strProf.add('System Administrator');
        strProf.add('Sales Rep-BB');
        List<Profile> ProfileList = [select id, name from Profile where name IN : strProf];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(2);
        ListOfUser.get(0).ProfileID =  profiles.get('System Administrator');
        ListOfUser.get(1).ProfileID =  profiles.get('Sales Rep-BB');
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        ListOfUser.get(0).UserRoleID =  role.Id;
        insert ListOfUser;
        System.assertEquals(ListOfUser.get(0).profileid, profiles.get('System Administrator'));
        System.assertEquals(ListOfUser.get(1).profileid, profiles.get('Sales Rep-BB'));
        
        system.runAs(ListOfUser[0])
        {
         CommunityUser = TestUtilities.getCustomerUser('IPS External Customer');
         
         List<Core_IPS_Error_Code__c> LstErrorCode  = TestUtilities.getListOfIpsErrorCodes();
         insert LstErrorCode;
         }
         
    }
    static testMethod void EoisErrorController_testMethod1() 
    {
       Test.startTest();
       getrecords();
      system.runAs(CommunityUser)
      {
        PageReference ErrorPage = Page.Core_IPS_EoisError;
        Test.setCurrentPage(ErrorPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('ErrCode','G101');
        ApexPages.currentPage().getParameters().put('retURL','sunil');
        
        Core_IPS_EoisErrorController EoisError =  new Core_IPS_EoisErrorController();
        EoisError.PageInit();
        EoisError.GoBack();
       }
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        Test.stopTest();
    }
    
    static testMethod void EoisErrorController_testMethod2() 
    {
      Test.startTest();
        
       getrecords();
      system.runAs(CommunityUser)
      {
        PageReference ErrorPage = Page.Core_IPS_EoisError;
        Test.setCurrentPage(ErrorPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('ErrCode','G101');
        
        
        Core_IPS_EoisErrorController EoisError =  new Core_IPS_EoisErrorController();
        EoisError.PageInit();
        EoisError.GoBack();
       }
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
        
        Test.stopTest();
    }
    
    static testMethod void EoisErrorController_testMethod3() 
    {
       Test.startTest();
       
       getrecords();
      system.runAs(ListOfUser[0])
      {
        PageReference ErrorPage = Page.Core_IPS_EoisError;
        Test.setCurrentPage(ErrorPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('ErrCode','G101');
        ApexPages.currentPage().getParameters().put('retURL','sunil');
        
        Core_IPS_EoisErrorController EoisError =  new Core_IPS_EoisErrorController();
        EoisError.PageInit();
        EoisError.GoBack();
       }
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
       Test.stopTest(); 
    }

static testMethod void EoisErrorController_testMethod4() 
    {
      Test.startTest();
        
       getrecords();
      system.runAs(ListOfUser[0])
      {
        PageReference ErrorPage = Page.Core_IPS_EoisError;
        Test.setCurrentPage(ErrorPage);
        // Assigning parameters in the URL
        ApexPages.currentPage().getParameters().put('ErrCode','G101');
        
        
        Core_IPS_EoisErrorController EoisError =  new Core_IPS_EoisErrorController();
        EoisError.PageInit();
        EoisError.GoBack();
       }
        //ApexPages.currentPage().getParameters().put('rType','012210000004IHR');
       Test.stopTest(); 
    }

}