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
        System.debug('req'+req);
        
        
        
        //Default HTTP Response to IPaaS
        resp.addHeader('Content-Type', 'application/json');
        resp.statusCode = 200;
        Error err  = new Error();
        
        try {
            System.debug('req1'+RestContext.request.params);
            String AppFileId = RestContext.request.params.get('appFileId');
            
            //String userEmail = RestContext.request.params.get('userEmail');
            
            String federationId = RestContext.request.params.get('userName');
			
            
            String action = RestContext.request.params.get('action');
            String appData = RestContext.request.params.get('appData');//contains record Id in this format -> caseId-500di00000Xmmx2AAB
            //ATHR - Deeply Nested if 16209 - TK
            if(String.isEmpty(action) || !(action == 'download')) {
                AuResp.isAuthorized = HasAccess;
                return AuResp;
            }
            
            
            if (!String.isEmpty(AppFileId) && AppFileId != 'null' && !String.isEmpty(federationId)){
                // Roshan - bypass authorization for system user
                if (federationId.toLowerCase() == 'sys_comkt_sftuser') {
                    AuResp.isAuthorized = true;
                } else {
                    HasAccess = CheckUserRecordAccess(AppFileId,federationId,appData);
                    AuResp.isAuthorized = HasAccess;
                }
                
                return AuResp;
            }
            //Default
            AuResp.isAuthorized = HasAccess;
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
    
    public static Boolean CheckUserRecordAccess(String appFileId,String federationId,String appData) {//this record id is actully the Document Id or the Claim Id -> unique id stamped on it
        Boolean HasAccess = false;
        Boolean auditDocRecAccess = false;
        List<User> usrID = new List<User>();
        Set <Id> usrIds = new Set<Id>();
        Set<Id> audDocIDs = new set<Id>();
        Set <Id> groupId = new Set<Id>();
        List<Groupmember> usersListWithGroupAccess = new List<Groupmember>();
        Boolean isCdbSftUser = false;
       
        if(federationId.startsWith('AMR') && federationId.toLowerCase().contains('sys_comkt_cdb_sft') && !String.isEmpty(appData)) {//CDB-SFT Changes
            isCdbSftUser = true;
            usrID = [Select id,FederationIdentifier, Profile.Name from user where username LIKE '%cdb-integration-user%' and IsActive = true];
        }
        else if(!federationId.contains('@')){
            usrID = [Select id,FederationIdentifier, Profile.Name from user where FederationIdentifier =:federationId and IsActive = true];
        }else{
            usrID = [Select id,FederationIdentifier,Profile.Name from user where email =:federationId and IsActive = true];
        }
        
        System.debug('User list:'+usrID);
        List<String> profilesToBeIncluded = Core_MDF_CCP_ConstantClass.SFT_Profiles.split(',');
        for(user usr:usrID){
            usrIds.add(usr.Id);
            if(profilesToBeIncluded.contains(usr.Profile.Name)){
                auditDocRecAccess = true;
                break;
            }
        }
       
        if(!auditDocRecAccess){
            if(isCdbSftUser && appData.startsWith('claimId')) {//CDB-SFT Changes
                //PFC Share
                String recordId = appData.right(18);
                List<PartnerFundClaimShare> pfcShareList = [select UserOrGroupId from PartnerFundClaimshare where ParentId =: recordId]; //HP:ATHR Fix
                for(PartnerFundClaimShare pfc: pfcShareList) {
                    groupId.add(pfc.UserOrGroupId);
                } 
                
            } else if(isCdbSftUser && appData.startsWith('caseId')) {//CDB-SFT Changes
                //Case Share
                String recordId = appData.right(18);
                List<CaseShare> caseShareList = [select UserOrGroupId  from CaseShare where CaseId =: recordId ];//HP:ATHR Fix
                for(CaseShare cs: caseShareList) {
                    groupId.add(cs.UserOrGroupId);
                }
            }
            else {//SFT Changes - Audit Document Share
                for(Core_MDF_Audit_Document__c audDoc: [Select id from Core_MDF_Audit_Document__c where Core_MDF_Document_Id__c =: appFileId OR ( Core_MDF_SFT_File_Download_Ind__c =true and Core_MDF_Old_Document_Id__c =: appFileId)]){ //HP:ATHR Fix
                    audDocIDs.add(audDoc.Id);
                }
                for (Core_MDF_Audit_Document__Share auditDocshare : [Select UserOrGroupId from Core_MDF_Audit_Document__Share where ParentId IN: audDocIDs]){
                    groupId.add(auditDocshare.UserOrGroupId);
                }
            }
            
          
            if(!groupId.isEmpty()){
                usersListWithGroupAccess = [Select id from GroupMember where GroupId in: groupId  and UserOrGroupId IN: usrIds]; //HP:ATHR Fix
            }
            if(!usersListWithGroupAccess.isEmpty()) {
                auditDocRecAccess = true;
            }
        }
        return auditDocRecAccess;
    }
}