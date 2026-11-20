/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateDDRProducts_V2
Version             : 
Created Date        : June 2024

Modification Log    :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Shraddha                May- 2024              Added a createDDRProductRecords method to create Design Registration Product Records through payload 
************************************************************************************************************************************************/
@RestResource(urlMapping='/v2.0/design-registration-product/*')
global with sharing class PCC_CreateDDRProducts_V2 {
    
    //create design registration product records based on payload received
    @HttpPost
    global static void createDDRProductRecords(){
        PCC_CreateDesignRegistrationUtility_V2.createDDRRecords(PCC_Constants.INSERT_DRP);
    }

    //return design registration product record based on Id
    @HttpGet
    global static void getDDRProductRecord(){
        PCC_CreateDRProductUtility_V2.getDRProductRecordDetails();
    }
    
    //return design registration product record based on Id
    @HttpPut
    global static void updateDDRProductRecord(){
        PCC_CreateDesignRegistrationUtility_V2.createDDRRecords(PCC_Constants.UPDATE_DRP);
    }
    
    @HttpDelete
    global static void deleteDRPRecords(){
        PCC_CreateDesignRegistrationUtility_V2.createDDRRecords(PCC_Constants.DELETE_DRP);     
    }

}