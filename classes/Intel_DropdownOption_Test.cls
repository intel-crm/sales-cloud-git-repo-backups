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
    
    @isTest
    static void testIsWorking() {
        Boolean result1 = Intel_Step.isWorking();
        System.assertEquals(true, result1);
    }
    @isTest
    static void testIsWorking1() {
        Boolean result = Intel_Section.isWorking();
        result = Intel_Subsection.isWorking();
        result = Intel_Dropdown.isWorking();
        result = Intel_Text.isWorking();
        result = Intel_RichText.isWorking();
        result = Intel_Checkbox.isWorking();
        result = Intel_Resources.isWorking();
        result = Intel_Radio.isWorking();
        result = Intel_DropdownOption.isWorking();
        result = Intel_Video_Uploader.isWorking();
        result = Intel_Label.isWorking();
        result = Intel_Uploader.isWorking();
        result = Intel_RadioOption.isWorking();
        result = Intel_DropdownRadioCombo.isWorking();
        result = Intel_CheckboxOption.isWorking();
        result = Intel_input.isWorking();
        result = Intel_WizardData.isWorking();
        result = Intel_FormData.isWorking();
        result = Intel_ProductWebPageDataWrapper.isWorking();
        result = Intel_TextArea.isWorking();
        result = Intel_SpecificationDataWrapper.isWorking();
        
        System.assertEquals(true, result);
    }
   
    // static testMethod void testIntelDropdownOption(){
        
    //     Intel_DropdownOption dropdownOption = new Intel_DropdownOption('Test', 'testValue');
    //     dropdownOption.disabled = false;
    //     dropdownOption.required = true;
    //     dropdownOption.businessSegments = 'Test';
    //     system.assertEquals(dropdownOption.label, 'Test');
    // }
}