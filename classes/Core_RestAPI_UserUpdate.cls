/******************************************************************************************************************************************
Class Name  : Core_RestAPI_UserUpdate
Version     : 1.0
Created Date: 09 NOV 2023
Function    : Custom REST Endpoint to consume User CRUD operations done by AGS API User   

Modification Log :
* Developer                   Date [DD/MM/YYYY]             Description
* ----------------------------------------------------------------------------
* Hemant Tiwari [Team: DRACO]      09/11/2023                Original version
*****************************************************************************************************************************************/

@RestResource(urlMapping='/userapi/*')
global with sharing class Core_RestAPI_UserUpdate {
    global static boolean UnFreezeUser = false;
    
    @HttpPost
    global static String userCreate() {
        String DMLResultString = '';
        Map<String,object> userData= (Map<String,object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        User userDataNew = (User)JSON.deserialize(RestContext.request.requestBody.toString(), User.class);
        
        Database.SaveResult DMLResult = Database.insert(userDataNew, false);
        
        // Iterate through each returned result
        if (DMLResult.isSuccess()) {
            // Operation was successful, so get the details of the created user and return it in response
            DMLResultString = 'Successfully inserted User. User ID: ' + DMLResult.getId();
        }
        else {
            // Operation failed, so get all errors                
            for(Database.Error err : DMLResult.getErrors()) {
                DMLResultString = 'Following error occured at Salesforce while creating user: ' + err.getMessage();
            }
        }
        return DMLResultString;
    }
    
    @HttpPatch
    global static String userUpdate() {
        String DMLResultString = '';
        User userDataNew = (User)JSON.deserialize(RestContext.request.requestBody.toString(), User.class);
		UserLogin usrlgn = [SELECT Id, IsFrozen FROM UserLogin WHERE UserId = :userDataNew.Id LIMIT 1];
        User userDataOld = [SELECT Id, IsActive FROM User WHERE Id = :userDataNew.Id LIMIT 1];
        
        // Custom logic to check if we have specifically received IsActive field in the payload to SF. If NOT and also meets the condition below, then keep IsActive as FALSE
        if((userDataOld.IsActive == true && usrlgn.IsFrozen == true) && (userDataNew.IsActive == null || userDataNew.IsActive == false)){
            userDataNew.IsActive = false;
        }
        
        Database.SaveResult DMLResult = Database.update(userDataNew, false);
        
        // Iterate through each returned result
        if (DMLResult.isSuccess()) {
            // Operation was successful, so get the details of the created user and return it in response
            DMLResultString = 'Successfully updated User with ID: ' + DMLResult.getId() + '. The user was with IsActive ' + userDataOld.IsActive + ' and IsFrozen ' + usrlgn.IsFrozen;
        }
        else {
            // Operation failed, so get all errors                
            for(Database.Error err : DMLResult.getErrors()) {
                DMLResultString = 'Following error occured at Salesforce while Updating user: ' + err.getMessage() + '. The user was with IsActive ' + userDataNew.IsActive + ' and IsFrozen ' + usrlgn.IsFrozen;
            }
        }
        return DMLResultString;
    }
}