/*********************************************************************************************************************
Class Name    : Sales_License_Gen_SwitchTriggerUtil_Test
Version       : 1.0
Created Date  : May 2021  
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Mohammad Dilshad           17-May-2021              Test class for Sales_License_Gen_SwitchTriggerutil
* ******************************************************************************************************************/
@isTest
public class Sales_License_Gen_SwitchTriggerutil_Test {
    /******************************
* Developer Name : Mohammad Dilshad
* Test method: testblockLicenseSwitchDeletion - Test method for Apex Class -> Sales_License_Gen_SwitchTriggerutil
* Modification Log :
* 1. Shivam Vishwakarma (26.7.21)- Updated Test Code to Cover Handler Class as well.
* ****************************/     
    @isTest static void testblockLicenseSwitchDeletion(){
        String errMsg='';
        Sales_License_Generator__c salesLicenseGenerator = new Sales_License_Generator__c();
        salesLicenseGenerator.Name='Gen';
        salesLicenseGenerator.Sales_License_Feature_Lyn_Syntx_txt__c='-p';
        salesLicenseGenerator.Sales_License_Generator_txt__c='test';        
        Sales_License_Generator__c salesLicenseGenerator1 = new Sales_License_Generator__c();
        salesLicenseGenerator1.Name='Gen1';
        salesLicenseGenerator1.Sales_License_Feature_Lyn_Syntx_txt__c='-t';
        salesLicenseGenerator1.Sales_License_Generator_txt__c='test1';       
        insert new List<Sales_License_Generator__c>{salesLicenseGenerator,salesLicenseGenerator1};
        Sales_License_Group__c licGroup= new Sales_License_Group__c();
        licGroup.Name = 'Partner1';
        licGroup.Sales_License_Generator__c=salesLicenseGenerator.id;
        licGroup.Sales_License_Parameter_txt__c='test1';
        licGroup.Sales_License_Description_dsc__c='test1';
        insert licGroup;
        Sales_License_Generator_Switch__c salesLicenseSwitch = new Sales_License_Generator_Switch__c();
        salesLicenseSwitch.Name='genlic';
        salesLicenseSwitch.Sales_License_Switch_txt__c='-r';
        salesLicenseSwitch.Sales_License_Description_dsc__c='switch test';
        salesLicenseSwitch.Sales_License_Generator__c=salesLicenseGenerator.id;
        Sales_License_Generator_Switch__c salesLicenseSwitch1 = new Sales_License_Generator_Switch__c();        
        salesLicenseSwitch1.Name='genlic1';
        salesLicenseSwitch1.Sales_License_Switch_txt__c='-p';
        salesLicenseSwitch1.Sales_License_Description_dsc__c='switch test1';
        salesLicenseSwitch1.Sales_License_Generator__c=salesLicenseGenerator.id; 
        Sales_License_Generator_Switch__c salesLicenseSwitch2 = new Sales_License_Generator_Switch__c();
        salesLicenseSwitch2.Name='genlic2';
        salesLicenseSwitch2.Sales_License_Switch_txt__c='-c';
        salesLicenseSwitch2.Sales_License_Description_dsc__c='switch test2';
        salesLicenseSwitch2.Sales_License_Generator__c=salesLicenseGenerator1.id; 
        insert new List<Sales_License_Generator_Switch__c>{salesLicenseSwitch,salesLicenseSwitch1,salesLicenseSwitch2};
        Sales_License_Group_Switch_config__c configSW = new Sales_License_Group_Switch_config__c();
        configSW.Name = 'TryConfig';
        configSW.Sales_License_Generator_Switch__c = salesLicenseSwitch.Id;
        configSW.Sales_License_Group__c = licGroup.Id;
        configSW.Sales_License_Value_txt__c = '=UHD';
        insert configSW;
        Test.startTest();
        try{
            delete salesLicenseSwitch;
        }catch(Exception e){
            errMsg = e.getMessage();
        }        
        Test.stopTest(); 
        System.assert(errMsg.contains('You cannot Delete this Switch as it is associated to License group') , errMsg );
    }
}