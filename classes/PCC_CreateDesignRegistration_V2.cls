/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateDesignRegistration_V2
Version             : 
Created Date        : June 2024

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Sushmita                 June- 2024      Added a createDDRRecords method to create DDR registration through payload 
* Shraddha                 June- 2024     Added a getDDRRecords method to send DDR registration deatils to external system 
***************************************************************************************************************************************/
	@RestResource(urlMapping='/v2.0/design-registration/*')
    global with sharing class PCC_CreateDesignRegistration_V2{
        
        //To create design reg record in salesforce from the received request
        @HttpPost
        global static void createDDRRecords() { 
            PCC_CreateDesignRegistrationUtility_V2.createDDRRecords(PCC_Constants.INSERT_DDR);
        }
        
        //To get design registration record details
        @HttpGet
        global static void getDDRRecords() {
            PCC_CreateDesignRegistrationUtility_V2.getDDRRecordDetails();
        }
        
        @HttpPut
        global static void updateDDRRecords() {
            PCC_CreateDesignRegistrationUtility_V2.createDDRRecords(PCC_Constants.UPDATE_DDR);
        }
        
        @HttpDelete
        global static void deleteDDRRecords(){
            PCC_CreateDesignRegistrationUtility_V2.createDDRRecords(PCC_Constants.DELETE_DDR);     
        }
        
    }