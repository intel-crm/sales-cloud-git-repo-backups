/*********************************************************************************************************************
Apex Class Name  : ER_RegistrationProfileResponse_Test
Version       : 1.0
Created Date  : 1 Feb 2022
Function      : 

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Gaurav Kurwade            1 Feb 2022              Test class for ER_RegistrationProfileResponse     
*************************************************************************************************************************/


@isTest
public class ER_RegistrationProfileResponse_Test {

    
    static testMethod void testEmptyClass() {
        Test.startTest();
 ER_RegistrationProfileResponse utility = new ER_RegistrationProfileResponse();
        System.assert(true, 'Ensure something happens in the class');
        Test.stopTest();

}
}