/*************************************************************************************************************************************
Apex Class Name     : TestingPCCClass
Version             : 
Created Date        : May 2023
Descrpition         : Utility handler of PCC_CreateDesignRegistrationUtility_V1 class

Modification Log    :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Shraddha                May- 2023        Added a methods to fetch API values of given picklists
* Shraddha                June - 2023      Added methods to get customise error responses
************************************************************************************************************************************************/

public class TestingPCCClass {
    
    Public static Boolean PCC_checkValidPartnerFAE(String partnerFAE){
        Boolean isValidEmail = false;
        try{
            Contact con = [SELECT id, AccountId, Email FROM Contact WHERE Email =: partnerFAE limit 1];
            if(con.Id != null){
                isValidEmail = true;
            }
        }catch(exception ex){
            isValidEmail = false;
        }
        return isValidEmail;
    }
}