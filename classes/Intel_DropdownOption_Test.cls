/*************************************************************************************************************************************************************************
* Class Name  : Intel_DropdownOption_Test 
* Version     : 1.0 
* Created Date: 4/25/2019
* Modification Log : Original Version
* Description : Test class for  Intel_DropdownOption
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team											25/09/2019										Test class for 	Intel_DropdownOption		
**************************************************************************************************************************************************************************/
@isTest
public class Intel_DropdownOption_Test {
	
    static testMethod void testIntelDropdownOption(){
        
        Intel_DropdownOption dropdownOption = new Intel_DropdownOption('Test', 'testValue');
        dropdownOption.disabled = false;
        dropdownOption.required = true;
    }
}