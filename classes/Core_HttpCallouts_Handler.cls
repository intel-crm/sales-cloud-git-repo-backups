public without sharing class Core_HttpCallouts_Handler {
    private static final String UPDATE_REASON_AGS_SYNC = 'Azure Sync'; 
    //private static final String UPDATE_REASON_AZURE_SYNC = 'Azure Sync';
    
    // Utility helpers to reduce cognitive complexity and nested IFs
    private static Boolean isInProgressOrPending(String status){
        return status == 'In Progress' || status == 'Pending';
    }
    private static Boolean isCompleteOrBlank(String status){
        return status == 'Complete' || String.isBlank(status);
    }
    private static String getEntitlementRoleTechName(Core_Contact_Entitlement__c conEntRef){
        try{
            return conEntRef.Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c;
        }catch(Exception e){
            return null;
        }
    }
    // Build the update record based on selection/status/AGS presence. Returns null if no update required.
    private static Core_Contact_Entitlement__c buildUpdateForSelectionState(Core_Contact_Entitlement__c conEntRef, Set<String> stAGSRoles){
        String roleTechName = getEntitlementRoleTechName(conEntRef);
        if(roleTechName == null) return null;
        
        Core_Contact_Entitlement__c updateConEntRef = new Core_Contact_Entitlement__c(id = conEntRef.Id);
        Boolean selected = conEntRef.Core_Selected__c;
        String status = conEntRef.Core_Status__c;
        Boolean rolePresent = stAGSRoles.contains(roleTechName);
        
        // Flatten logic using guard clauses and explicit branches
        if(selected){
            // Case: selected & In Progress/Pending & rolePresent => Complete, Successful Assignment
            if(isInProgressOrPending(status) && rolePresent){
                updateConEntRef.Core_Status__c = 'Complete';
                updateConEntRef.Core_Update_Reason__c = UPDATE_REASON_AGS_SYNC;
                updateConEntRef.Core_Status_of_Assignment_Failure__c = 'Successful Assignment';
                return updateConEntRef;
            }
            // Case: selected & Complete/Blank & role absent => deselect, Failed Assignment
            if(isCompleteOrBlank(status) && !rolePresent){
                updateConEntRef.Core_Selected__c = false;
                updateConEntRef.Core_Status__c = 'Complete';
                updateConEntRef.Core_Update_Reason__c = UPDATE_REASON_AGS_SYNC;
                updateConEntRef.Core_Status_of_Assignment_Failure__c = 'Failed Assignment';
                return updateConEntRef;
            }
            // Case: selected & In Progress/Pending & role absent => Complete + deselect + Failed Assignment
            if(isInProgressOrPending(status) && !rolePresent){
                updateConEntRef.Core_Status__c = 'Complete';
                updateConEntRef.Core_Selected__c = false;
                updateConEntRef.Core_Update_Reason__c = UPDATE_REASON_AGS_SYNC;
                updateConEntRef.Core_Status_of_Assignment_Failure__c = 'Failed Assignment';
                return updateConEntRef;
            }
        } else {
            // Not selected cases
            // Case: not selected & In Progress/Pending & role absent => Complete, Successful Removal
            if(isInProgressOrPending(status) && !rolePresent){
                updateConEntRef.Core_Status__c = 'Complete';
                updateConEntRef.Core_Update_Reason__c = UPDATE_REASON_AGS_SYNC;
                updateConEntRef.Core_Status_of_Assignment_Failure__c = 'Successful Removal';
                return updateConEntRef;
            }
            // Case: not selected & Complete/Blank & role present => select + Complete + Failed Removal
            if(isCompleteOrBlank(status) && rolePresent){
                updateConEntRef.Core_Selected__c = true;
                updateConEntRef.Core_Status__c = 'Complete';
                updateConEntRef.Core_Update_Reason__c = UPDATE_REASON_AGS_SYNC;
                updateConEntRef.Core_Status_of_Assignment_Failure__c = 'Failed Removal';
                return updateConEntRef;
            }
            // Case: not selected & In Progress/Pending & role present => Complete + select + Failed Removal
            if(isInProgressOrPending(status) && rolePresent){
                updateConEntRef.Core_Status__c = 'Complete';
                updateConEntRef.Core_Selected__c = true;
                updateConEntRef.Core_Update_Reason__c = UPDATE_REASON_AGS_SYNC;
                updateConEntRef.Core_Status_of_Assignment_Failure__c = 'Failed Removal';
                return updateConEntRef;
            }
        }
        return null;
    }
    
    // Pass in the endpoint to be used using the string url
    public static String getUpdatedAGSStatus(Contact conRef) {
        String strAzureResponse = '';
        String strResStatus = '';
        String AzureUserId = '';
        Boolean B2BContact = false;
        Map<String,id> mapAGSConEntId = new Map<String,id>();
        Map<String, Object> mapAGSRes = new Map<String, Object>();
        Map<String, Object> mapAzureRes = new Map<String, Object>();
        Set<String> stAGSRoles = new Set<String>();
        List<Core_Contact_Entitlement__c> lstToUpdate = new List<Core_Contact_Entitlement__c>();
        Set<String> stAGSRolesToGetEnt = new Set<String>();
        Map<Contact,Set<String>> mapConlstAGSRoles =  new Map<Contact,Set<String>>();
       
        List<Core_Contact_Entitlement__c> lstConEnt = new List<Core_Contact_Entitlement__c>();
        Boolean userAvailableInAzure = true;
        
        // Get the list of Entitlements assigned on the contact
        lstConEnt = [SELECT id,Core_Selected__c,Core_Status__c,Core_Entitlement_Id__c,Core_Entitlement_Id__r.Core_IsActive__c,Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c, Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_DeDup_Number__c,Core_Entitlement_Id__r.Entitlement_B2B_B2C_Indicator__c FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c = : conRef.Id AND Core_Entitlement_Id__r.Core_IsActive__c = true];
        
        // Get the user details (User Id) and list of Groups from Azure B2C using User Id
        // Part 1: Get user details from the user's email
        try{
            Http httpAzure = new Http();
            HttpRequest reqAzure = new HttpRequest();
            reqAzure.setEndpoint('callout:Azure_A_E_Get_Groups/iam/azure/v1/b2c/users(mail='+ conRef.Email + ')');  
            reqAzure.setMethod('GET');
            HttpResponse resAzure = httpAzure.send(reqAzure);
           
            strAzureResponse = resAzure.getBody();
            if(!String.isBlank(strAzureResponse) && strAzureResponse.length() != 2){ // Check if the Azure response is not Blank and its not "[]"
                list<Object> objlst = (List<Object>)JSON.deserializeUntyped(strAzureResponse);
                mapAzureRes = !objlst.isEmpty() ? (Map<String, Object>)objlst[0] : null;
                if(mapAzureRes != null){
                    AzureUserId = (String)mapAzureRes.get('id');
                  
                } 
            } else{ //If the response from Azure is Blank or its [], update the falag userAvailableInAzure to false
                userAvailableInAzure = false;
            }
            
            // Part 2: Get user group details from the User Id we got from Part 1 above and add it to the AGS roles set so that
            // further processing can take place as per the AS-IS flow.
            if(AzureUserId != ''){
                reqAzure.setEndpoint('callout:Azure_A_E_Get_Groups/iam/azure/v1/b2c/users/'+ AzureUserId + '/memberof');  
                reqAzure.setMethod('GET');
                resAzure = httpAzure.send(reqAzure);
                
                strAzureResponse = resAzure.getBody();
                if(!String.isBlank(strAzureResponse)){
                    list<Object> objlst = (List<Object>)JSON.deserializeUntyped(strAzureResponse);
                    for(object grpDet : objlst){
                        mapAGSRes = (Map<String, Object>)grpDet;
                        stAGSRoles.add((String)mapAGSRes.get('displayName')); //Add the names of the Azure groups to AS-IS flow of AGS roles
                    }
                }
            }
        } catch(Exception e){
            strResStatus = 'Received Azure Exception: ' + e.getMessage();
        }
        

        
        if(!stAGSRoles.isEmpty()){ //Process further if we have received AGS role AND/OR Azure Group response 
            for(Core_Contact_Entitlement__c conEntRef : lstConEnt){
                if(conEntRef.Core_Entitlement_Id__r.Entitlement_B2B_B2C_Indicator__c == 'B2C'){
                    Core_Contact_Entitlement__c updateConEntRef = buildUpdateForSelectionState(conEntRef, stAGSRoles);
                    if(updateConEntRef != null){
                        lstToUpdate.add(updateConEntRef);
                    }
                    //To use when inserting 'core contact entitlement' that exist in AGS and record not exist under contact
                    mapAGSConEntId.put(getEntitlementRoleTechName(conEntRef),conEntRef.id);
                    
                    // Mark B2B Indicator on Contact to TRUE if B2B Entitlements are updated to TRUE - Complete
                    if(updateConEntRef != null && updateConEntRef.Core_Status__c == 'Complete' && updateConEntRef.Core_Selected__c == true && conEntRef.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r != null && conEntRef.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_DeDup_Number__c == 'B2B'){
                        B2BContact = true;
                    }
                    // Mark B2B Indicator on Contact to TRUE if B2B Entitlements are not updated via AGS Sync, but are already TRUE - Complete
                    if(updateConEntRef == null && conEntRef.Core_Status__c == 'Complete' && conEntRef.Core_Selected__c && conEntRef.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r != null && conEntRef.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_DeDup_Number__c == 'B2B'){
                        B2BContact = true;
                    }
                }
            }
            
            for(String strRoles : stAGSRoles){
                if(!mapAGSConEntId.containsKey(strRoles)){
                    stAGSRolesToGetEnt.add(strRoles);
                }
            }
            if(stAGSRolesToGetEnt.size()>0){
                mapConlstAGSRoles.put(conRef,stAGSRolesToGetEnt);
                insertConEntByAGSRoles(mapConlstAGSRoles, UPDATE_REASON_AGS_SYNC);
            }
             
            if(lstToUpdate.size()>0){
                try{
                   
                    update lstToUpdate;
                    //strResStatus = 'Updated';
                }catch(Exception e){
                    if(String.isBlank(strResStatus)){
                        strResStatus = 'Exception while trying to update the Entitlements for AGS/Azure Sync. ' + e.getMessage();
                    }else{
                        strResStatus = strResStatus + e.getMessage();
                    }
                }
            }
        }
        
        if(B2BContact != conRef.Core_Contact_B2B_Indicator__c){
            //conRef.Core_Contact_B2B_Indicator__c = B2BContact; //Commented logic temporarily due to Production Issue of flag being turned to FALSE for valid contacts
            //update conRef; //Commented logic temporarily due to Production Issue of flag being turned to FALSE for valid contacts
        }
        
        return strResStatus;
    }
    
    public static Void insertConEntByAGSRoles(Map<Contact, Set<String>> mapConlstAGSRoles, String reason){
        Set<String> stAGSRolesToGetEnt = new Set<String>();
        Map<String,Id> mapAGSEntId = new Map<String,Id>();
        List<Core_Contact_Entitlement__c> lstToInset = new List<Core_Contact_Entitlement__c>();
        
        for(Contact conRef : mapConlstAGSRoles.keySet()){
            if(mapConlstAGSRoles.get(conRef) != null){
                for(String str : mapConlstAGSRoles.get(conRef))
                {
                    stAGSRolesToGetEnt.add(str);
                }
            }
        }
        if(stAGSRolesToGetEnt.size()>0){
            List<Core_Entitlement__c> lstEnt = [SELECT id,Core_IsActive__c,Core_AGS_Role_Id__c,Core_AGS_Role_Id__r.Core_Technical_Name__c FROM Core_Entitlement__c where Core_AGS_Role_Id__r.Core_Technical_Name__c IN : stAGSRolesToGetEnt AND Core_IsActive__c = true];
            
            for(Core_Entitlement__c entRef : lstEnt){
                mapAGSEntId.put(entRef.Core_AGS_Role_Id__r.Core_Technical_Name__c,entRef.id);
            }
            
            for(Contact conRef : mapConlstAGSRoles.keySet()){  
                for(String strRef : mapConlstAGSRoles.get(conRef)){
                    if(mapAGSEntId.get(strRef) != null){
                        Core_Contact_Entitlement__c conRefNew = new Core_Contact_Entitlement__c();
                        conRefNew.Core_Entitlement_Id__c = mapAGSEntId.get(strRef);
                        conRefNew.Core_Contact_Id__c = conRef.id;
                        conRefNew.Core_Selected__c = true;
                        conRefNew.Core_Status__c = 'Complete';
                        conRefNew.Core_Update_Reason__c = reason;
                        conRefNew.Core_Status_of_Assignment_Failure__c = 'Successful Assignment';
                        lstToInset.add(conRefNew);
                    }
                }
            }
            if(lstToInset.size()>0){
                try{
                    insert lstToInset;
                }catch(Exception e){
                    Core_Log_Entry__c excepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = 'insertConEntByAGSRoles', Core_Project__c = 'Core_HttpCallouts_Handler' , Core_Details__c = 'Getting exception while inserting contact entitlements', Core_Severity__c = 'info', Core_When__c = System.Now());     
                    insert excepLog;
             }
            }
        }
    }
}