@isTest
private class Core_IPS_CommEmailOptController_Test{
    public static User SystUserRunAs; 
    
    public static void getRecords(){
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
        List<User> userList = new List<user>();
        UserRole role = new UserRole();
        role.name='CEO';
        insert role;
        userList = TestUtilities.getListOfUser(1);
        userList[0].profileId=prof.id;
        userList[0].userRoleId = role.id;
        //userList[0].userroleid=role.id;
        insert userlist;
        SystUserRunAs = new User();
        SystUserRunAs = userList[0];
    }
    public static testmethod void EmailOptOut_test(){
        User u;
        getRecords();
        Core_IPS_CommEmailOptController controller;
        System.runAs(systUserRunAs){
        u=TestUtilities.getCustomerUser('IPS External Customer');
        Contact cont = [select id, Core_IPS_Email_Opt_Out__c from Contact where id=:u.contactid];
        cont.Core_IPS_Email_Opt_Out__c=true;
        update cont;
        }
        System.runAs(u){
            PageReference pageRef = Page.Core_IPS_EmailOpt;
            Test.setCurrentPage(pageRef);
            controller = new Core_IPS_CommEmailOptController();
            List<String> choices = new List<String>();
            choices.add('OptOut');
            controller.SelectedChoice= new List<String>();
            controller.SelectedChoice=choices;
        }
        System.runAs(systUserRunAs){
            controller.SubmitChoice();
        }
    }
    
    public static testmethod void EmailOptIn_test(){
        User u;
        getRecords();
        Core_IPS_CommEmailOptController controller;
        System.runAs(systUserRunAs){
        u=TestUtilities.getCustomerUser('IPS External Customer');
        Contact cont = [select id, Core_IPS_Email_Opt_Out__c,Core_MINDS__c,Core_Country_Region__c from Contact where id=:u.contactid];//Added fields US254983
        cont.Core_IPS_Email_Opt_Out__c=false;
        cont.Core_Country_Region__c='India';
           
        
        update cont;
        
        }
        System.runAs(u){
            PageReference pageRef = Page.Core_IPS_EmailOpt;
            Test.setCurrentPage(pageRef);
            controller = new Core_IPS_CommEmailOptController();
            List<String> choices = new List<String>();
            choices.add('OptIn');
            controller.SelectedChoice= new List<String>();
            controller.SelectedChoice=choices;
            controller.getCountries();//Added fields US254983
            controller.cancel();
            controller.Checkbox=True;
           
        }
        System.runAs(systUserRunAs){
            controller.SubmitChoice();
        }
    }
}