/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateDesignRegistration_V1
Version             : 
Created Date        : May 2023

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Sushmita                 May- 2023      Added a createDDRRecords method to create DDR registration through payload 
* Shraddha                 June- 2023     Added a getDDRRecords method to send DDR registration deatils to external system 
***************************************************************************************************************************************/

@RestResource(urlMapping='/v1.0/design-registration/*')
global class PCC_CreateDesignRegistration_V1{
    
    //To create design reg record in salesforce from the received request
    @HttpPost
    global static void createDDRRecords() { 
        PCC_CreateDesignRegistrationUtility_V1.createDDRRecords('Insert Design Registration');
    }
    
    //To get design registration record details
    @HttpGet
    global static void getDDRRecords() {
        PCC_CreateDesignRegistrationUtility_V1.getDDRRecordDetails();
    }
    
    @HttpPut
    global static void updateDDRRecords() {
        PCC_CreateDesignRegistrationUtility_V1.createDDRRecords('Update Design Registration');
    }
    
}