/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateDDRProducts_V1
Version             : 
Created Date        : June 2023

Modification Log    :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Shraddha                May- 2023              Added a createDDRProductRecords method to create Design Registration Product Records through payload 
************************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/design-registration-product/*')
global class PCC_CreateDDRProducts_V1 {
    
    //create design registration product records based on payload received
    @HttpPost
    global static void createDDRProductRecords(){
        PCC_CreateDesignRegistrationUtility_V1.createDDRRecords('Design Registration Product');
    }

    //return design registration product record based on Id
    @HttpGet
    global static void getDDRProductRecord(){
        PCC_CreateDRProductUtility_V1.getDRProductRecordDetails();
    }

}