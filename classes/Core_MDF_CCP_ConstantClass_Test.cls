/****************************************************************************************************************************************
* Test Class Name   : Core_MDF_CCP_ConstantClass_Test
* Business Class    : Core_MDF_CCP_ConstantClass
* Description       : To cover Core_MDF_CCP_ConstantClass
* Developer         : Shiva
* Updated     		: Date			developer			description
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_CCP_ConstantClass_Test {

    	 @isTest static void testGetData(){
             Test.startTest();
        //User usr=[Select id from User where LastName = 'Test User' Limit 1];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr){
             string cnstName = 'CAMPAIGN_APPROVAL_HISTORY_JSON';
             Core_MDF_CCP_ConstantClass cnstCls = new Core_MDF_CCP_ConstantClass();
             string value = (string)cnstCls.getValue(cnstName);
             Assert.isNotNull(value);
         }
             Core_MDF_CCP_ConstantClass.getAllConstants();
             test.stopTest();
         }
    
}