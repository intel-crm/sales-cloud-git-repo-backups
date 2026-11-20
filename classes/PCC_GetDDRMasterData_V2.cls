/*************************************************************************************************************************************
Apex Class Name     : PCC_GetDDRMasterData_V2
Version             : 
Created Date        : June 2024

Modification Log    :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Shraddha                June- 2024        Added a methods to fetch API values of given picklists
************************************************************************************************************************************************/

@RestResource(urlMapping='/v2.0/design-registration/picklist/*')
global class PCC_GetDDRMasterData_V2 {
    
    //To send design reg object's picklist values to external system 
    @HttpGet
    global static void getDDRMasterData(){
        PCC_CreateDesignRegistrationUtility_V2.getDDRPicklistValues();
    }
   
}