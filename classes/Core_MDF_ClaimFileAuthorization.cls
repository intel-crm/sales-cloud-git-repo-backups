@RestResource(urlMapping='/mdf/sft/ClaimFileAuthorization')
global with sharing class Core_MDF_ClaimFileAuthorization {
	global class AuthResp {
        public Boolean Authorized;
        public Error[] Errors = new Error[] {};        
            }
    
    public class Error {
        public String error;
        public String message;
    }
    
    @HttpGet  
    global static AuthResp CheckClaimFileAuthorization() {
        Boolean HasAccess = false;
        AuthResp AuResp = new AuthResp();
        RestResponse resp = RestContext.response;
        
        //Default HTTP Response to IPaaS
        resp.addHeader('Content-Type', 'application/json');
        resp.statusCode = 200;
        
        try {
            //Get Salesforce User Id from HTTP Request Object
            String UserId = RestContext.request.headers.get('userid');
            system.debug('###### UserId:' + UserId );
            //Get FileGUID from HTTP Request Object  
            String AppFileId = RestContext.request.headers.get('appfileid'); 
            system.debug('###### AppFileId:' + AppFileId );
            //Get AppData from HTTP Request Object  
            String AppData = RestContext.request.headers.get('appdata'); 
            system.debug('###### AppData:' + AppData );
            //Get ClaimId from HTTP Request Object
            String ClaimId = RestContext.request.headers.get('claimId');
            system.debug('###### ClaimId:' + ClaimId );
            String userEmail = RestContext.request.headers.get('userEmail');
                    
            //Claim Authorization Check scenario
            if (AppData != null || AppData != '' || AppData != 'null'){
                system.debug('###### Claim Authorization Start: AppData is NOT NULL');
                if (ClaimId != null && ClaimId != ''){
                    system.debug('###### Claim Authorization for Claim Id:' + ClaimId );
                    HasAccess = CheckUserRecordAccess(userEmail, ClaimId);
                    AuResp.Authorized = HasAccess;
                    system.debug('###### User:' + UserId + ' '  + HasAccess);                    
                    return AuResp;
                } 
            }
            //Default
            AuResp.Authorized = HasAccess;
            return AuResp;
            
        } catch(Exception e) {
            resp.statusCode = 400;
            return ProcessSysExceptionObject(e);            
        }
    }
    private static AuthResp ProcessSysExceptionObject( Exception e){ 
        AuthResp AuResp = new AuthResp();
        Error err  = new Error();
        err.error = 'System Exception';
        err.message = e.getMessage();
        AuResp.Authorized = false;
        AuResp.Errors.add(err);
        return AuResp;
    }
    
    public static Boolean CheckUserRecordAccess( String userEmail, Id RecordId){
        Boolean HasAccess = false;
        List<User> usrID = [Select id from user where email =:userEmail and IsActive = true limit 1];//need to show this line to leads
        List<UserRecordAccess> lstUserRecordAccess = [Select u.RecordId, u.HasReadAccess From UserRecordAccess u
                                                      where UserId =:usrID and RecordId =:RecordId limit 1];
        if(lstUserRecordAccess != null && lstUserRecordAccess.size() > 0){
            for (UserRecordAccess UserRecordAccessObj : lstUserRecordAccess){
                HasAccess = UserRecordAccessObj.HasReadAccess;    
            }     
        }
        return HasAccess;
    }
    
    
    
    
    /*
      private static Boolean CheckUserFileUploadAccess(String UserId, String AppFileId){
        Boolean HasAccess = false; 
        //ApFileId is nothing but guID
        User Usr = [Select Id, UserRoleId, UserType, Profile.name, ProfileId, Alias, Core_Login_Id__c, ContactId, Contact.AccountId 
                    From User where Id= :UserId ];
        List<String> rolesList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Finance_Roles');
        //List to store assigned permission sets
        List<String> assignedPS = new List<String>();
        for(PermissionSetAssignment psa : [SELECT Id,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId=:Usr.id and PermissionSet.Name IN: rolesList]){
                assignedPS.add(psa.PermissionSet.Name);
            }
        //with the userid and guID combination on claim we'll fetch attachment ids (if we are as well creating new object similar to the IPS)
        //then we'll query on that attachemnt object with filter as record present in the id's we got from above. - now we have attachment ids
        //now then queried object's guID == AppFileId then allow access
        //-------------------
        //from request we'll get unique id which will be on claim as well
        //we'll query the claim based on that unique id
        //we'll check user access on that claim rec and if read access found we'll return hasAccess = true;
        return HasAccess;
    }
     */
}