/**************************************************************************************
Apex Class Name:  Core_MultiselectController_Test
Version     : 1.0 
Created Date: 03 OCT 2014
Function    : test class for Core_MultiselectController
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* kunal Mehta          10/03/2014              Original Version
*************************************************************************************/
@isTest
public class Core_MultiselectController_Test {

    /*
     * Method name  : testMultiSelectController
     * Description  : test method to cover Core_MultiselectController class
     * Return Type  : VOID
     * Parameter    : NONE
    */
    public static testMethod void testMultiSelectController() {

        Core_MultiselectController multiSelectController = new Core_MultiselectController();

        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('US', 'US'));
        options.add(new SelectOption('CANADA', 'Canada'));
        options.add(new SelectOption('UK', 'UK'));

        multiSelectController.leftOptions = options;

        multiSelectController.rightOptionsHidden = 'US&';

        System.assertEquals(multiSelectController.rightOptionsHidden, 'US&');

        List < SelectOption > optionsRight = new List < SelectOption > ();
        optionsRight.add(new SelectOption('MEXICO', 'Mexico'));
        optionsRight.add(new SelectOption('India', 'India'));
        optionsRight.add(new SelectOption('Germany', 'Germany'));

        multiSelectController.rightOptions = optionsRight;

        multiSelectController.rightOptionsHidden = 'CANADA&UK';

        multiSelectController.leftOptionsHidden = 'India&Germany';

        System.assertEquals(multiSelectController.rightOptions, new List < SelectOption > {
            new SelectOption('CANADA', 'UK')
        });

    }

}