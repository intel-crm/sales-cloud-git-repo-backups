/***************************************************************************************************
* Apex Class Name: Core_MDF_FileAuthorization
* Test Class: Core_MDF_FileAuthorization_Test
* Version     : 1.0 
* Created Date: 12th July 2023
* Function    : MDF SFT File Authorization
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Amey K     				07/12/2023              Created
****************************************************************************************************/
@RestResource(urlMapping='/mdf/sft/fileAuthorization')
global with sharing  class Core_MDF_FileAuthorization {
    //global static String test = '';
	global class AuthResp {
        public Boolean isAuthorized;
        //public string tesdesfvt;
        }
    
    
    public class Error {
        public String error;
        public String message;
        
    }
    
    @HttpGet  
    global static AuthResp CheckFileAuthorization() {
        Boolean HasAccess = false;
        AuthResp AuResp = new AuthResp();
        RestResponse resp = RestContext.response;
        RestRequest req = RestContext.request;
        
        
        
        
        //Default HTTP Response to IPaaS
        resp.addHeader('Content-Type', 'application/json');
        resp.statusCode = 200;
        Error err  = new Error();
        
        try {
            
            String AppFileId = RestContext.request.params.get('appFileId');
            
            //String userEmail = RestContext.request.params.get('userEmail');
            
            String federationId = RestContext.request.params.get('userName');
            
            String action = RestContext.request.params.get('action');
            
            if(!String.isEmpty(action) && (action == 'download' || action == 'checkContentAccess')){
                
            	if (!String.isEmpty(AppFileId) && AppFileId != 'null'){
                
                	if (!String.isEmpty(federationId)){
                    
                        // Roshan - bypass authorization for system user
                        if (federationId.toLowerCase() == 'sys_comkt_sftuser') {
                            AuResp.isAuthorized = true;
                        } else {
                            HasAccess = CheckUserRecordAccess(AppFileId,federationId,action);
                    	    AuResp.isAuthorized = HasAccess;
                        }

                        //AuResp.tesdesfvt = test;
                    	return AuResp;
                	}
            	}
            }
            //Default
            AuResp.isAuthorized = HasAccess;
            //AuResp.tesdesfvt = 'here76';
            return AuResp;
            
        } catch(Exception e) {
            resp.statusCode = 400;
            return ProcessSysExceptionObject(e);            
        }
    }
    public static AuthResp ProcessSysExceptionObject( Exception e){ 
        AuthResp AuResp = new AuthResp();
        Error err  = new Error();
        err.error = 'System Exception';
        err.message = e.getMessage();
        AuResp.isAuthorized = false;
        return AuResp;
    }
    
    public static Boolean CheckUserRecordAccess(String RecordId,String federationId,String action) {//this record id is actully the Document Id or the Claim Id -> unique id stamped on it
        Boolean HasAccess = false;
        Boolean auditDocRecAccess = false;
        List<User> usrID = new List<User>();
        Set <Id> usrIds = new Set<Id>();
        Set<Id> audDocIDs = new set<Id>();
        Set <Id> groupId = new Set<Id>();
        List<Groupmember> usersListWithGroupAccess = new List<Groupmember>();
        if( action == 'checkContentAccess')
        {
            federationId = federationId+'%';
             usrID = [Select id,FederationIdentifier, Profile.Name from user where username LIKE :federationId and IsActive = true];
        }
       else {
        if(!federationId.contains('@')){
            usrID = [Select id,FederationIdentifier, Profile.Name from user where FederationIdentifier =:federationId and IsActive = true];
        }else{
            usrID = [Select id,FederationIdentifier,Profile.Name from user where email =:federationId and IsActive = true];
        }
    }
        List<String> profilesToBeIncluded = Core_MDF_CCP_ConstantClass.SFT_Profiles.split(',');
        for(user usr:usrID){
            	usrIds.add(usr.Id);
            if(profilesToBeIncluded.contains(usr.Profile.Name)){
               auditDocRecAccess = true;
                break;
            }
        }
        if(!auditDocRecAccess){
            if(action == 'download') {
                for(Core_MDF_Audit_Document__c audDoc: [Select id,Core_MDF_Document_Id__c,Core_MDF_Claim__c,Core_MDF_Audit__c,Core_MDF_Claim_Batch_Record__c from Core_MDF_Audit_Document__c where Core_MDF_Document_Id__c =: RecordId OR ( Core_MDF_SFT_File_Download_Ind__c =true and Core_MDF_Old_Document_Id__c =: RecordId)]){
                    audDocIDs.add(audDoc.Id);
                }
                for (Core_MDF_Audit_Document__Share auditDocshare : [Select UserOrGroupId from Core_MDF_Audit_Document__Share 
                                                                     where ParentId IN: audDocIDs]){
                    groupId.add(auditDocshare.UserOrGroupId);
                }
            } else if(action == 'checkContentAccess') {
                List<PartnerFundClaimShare> pfcShareList = [select UserOrGroupId, ParentId from PartnerFundClaimshare where ParentId =: RecordId];
                for(PartnerFundClaimShare pfc: pfcShareList) {
                    groupId.add(pfc.UserOrGroupId);
                }
            } 
            if(!groupId.isEmpty()){
                usersListWithGroupAccess = [Select id,UserOrGroupId from GroupMember where GroupId in: groupId  and UserOrGroupId IN: usrIds];
            }
            if(!usersListWithGroupAccess.isEmpty()) {
                auditDocRecAccess = true;
            }
        }
        return auditDocRecAccess;
    }
}