/*************************************************************************************************************************************
Apex Class Name     : PCC_GetDDRMasterData_V1
Version             : 
Created Date        : 1 june 2023

Modification Log    :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Shraddha                May- 2023        Added a methods to fetch API values of given picklists
************************************************************************************************************************************************/

@RestResource(urlMapping='/v1.0/design-registration/picklist/*')
global class PCC_GetDDRMasterData_V1 {
    
    //To send design reg object's picklist values to external system 
    @HttpGet
    global static void getDDRMasterData(){
        PCC_CreateDesignRegistrationUtility_V1.getDDRPicklistValues();
    }
   
}