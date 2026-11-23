/*********************************************************************************************************************
Class Name    : Sales_License_Group_configTriggger_Test
Version       : 1.0
Created Date  : May 2021  
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Mohammad Dilshad           31-May-2021              Test class for Sales_License_Group_configTrigggerUtil
* ******************************************************************************************************************/
@isTest
public class Sales_License_Group_configTriggger_Test {
    
    /*@isTest static void testupdateLicenseParameter(){
     
        Sales_License_Generator__c salesLicenseGenerator = new Sales_License_Generator__c();
        salesLicenseGenerator.Name='Gen';
        salesLicenseGenerator.Sales_License_Feature_Lyn_Syntx_txt__c='-p';
        salesLicenseGenerator.Sales_License_Generator_txt__c='test';
        insert salesLicenseGenerator;
        
        Sales_License_Generator__c salesLicenseGenerator1 = new Sales_License_Generator__c();
        salesLicenseGenerator1.Name='Gen1';
        salesLicenseGenerator1.Sales_License_Feature_Lyn_Syntx_txt__c='-t';
        salesLicenseGenerator1.Sales_License_Generator_txt__c='test1';
        insert salesLicenseGenerator1;
        
        Sales_License_Group__c licGroup= new Sales_License_Group__c();
        licGroup.Name = 'Partner1';
        licGroup.Sales_License_Generator__c=salesLicenseGenerator.id;
        licGroup.Sales_License_Parameter_txt__c='test1';
        licGroup.Sales_License_Description_dsc__c='test1';
        insert licGroup;
        
        Sales_License_Group__c licGroup1= new Sales_License_Group__c();
        licGroup1.Name = 'Partner2';
        licGroup1.Sales_License_Generator__c=salesLicenseGenerator.id;
        licGroup1.Sales_License_Parameter_txt__c='test3';
        licGroup1.Sales_License_Description_dsc__c='test3';
        insert licGroup1;
        
        list<Sales_License_Generator_Switch__c> salesLicenseSwitchList = new list<Sales_License_Generator_Switch__c>();
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
        
        salesLicenseSwitchList.add(salesLicenseSwitch);
        salesLicenseSwitchList.add(salesLicenseSwitch1); 
        salesLicenseSwitchList.add(salesLicenseSwitch2);  
        insert salesLicenseSwitchList; 
        
        list<Sales_License_Group_Switch_config__c> salesLicenseGroupConfigList = new list<Sales_License_Group_Switch_config__c>();
        Sales_License_Group_Switch_config__c salesLicenseGroupSwitchConfig = new Sales_License_Group_Switch_config__c();
        salesLicenseGroupSwitchConfig.Name='test group';
        salesLicenseGroupSwitchConfig.Sales_License_Group__c=licGroup.id;
        salesLicenseGroupSwitchConfig.Sales_License_Generator_Switch__c=salesLicenseSwitch.id;
        
        Sales_License_Group_Switch_config__c salesLicenseGroupSwitchConfig1 = new Sales_License_Group_Switch_config__c();
        salesLicenseGroupSwitchConfig1.Name='test group 1';
        salesLicenseGroupSwitchConfig1.Sales_License_Group__c=licGroup.id;
        salesLicenseGroupSwitchConfig1.Sales_License_Generator_Switch__c=salesLicenseSwitch1.id;
        
        Sales_License_Group_Switch_config__c salesLicenseGroupSwitchConfig2 = new Sales_License_Group_Switch_config__c();
        salesLicenseGroupSwitchConfig2.Name='test group 2';
        salesLicenseGroupSwitchConfig2.Sales_License_Group__c=licGroup.id;
        salesLicenseGroupSwitchConfig2.Sales_License_Generator_Switch__c=salesLicenseSwitch2.id;
        
        salesLicenseGroupConfigList.add(salesLicenseGroupSwitchConfig);
        salesLicenseGroupConfigList.add(salesLicenseGroupSwitchConfig1);
        salesLicenseGroupConfigList.add(salesLicenseGroupSwitchConfig2);
        insert salesLicenseGroupConfigList;
        
        Sales_License_Group_Switch_config__c configRec = [SELECT id,Name,Sales_License_Group__c FROM Sales_License_Group_Switch_config__c WHERE Name='test group 2' ];
        configRec.Name='test group 3';
        update configRec;
         try
			{
				Delete 	salesLicenseGroupConfigList;
			}
			catch(Exception ee)
			{}
   	 }*/
        
}