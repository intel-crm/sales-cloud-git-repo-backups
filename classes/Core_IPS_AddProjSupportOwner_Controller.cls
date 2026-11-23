/***************************************************************************************************
Class Name:  Core_IPS_AddProjSupportOwner_Controller
Class Type: Test Class 
Version     : 1.0 
Description:   This class contains unit test scenarios for Core_IPS_AddProjSupportOwner_Cont_Test class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh      		     09/07/2018              Created
* Harshavardhan chakka       12/05/2021              US1011877-DEVELOPMENT ONLY- Security Scan Fixes
****************************************************************************************************/

public with sharing class Core_IPS_AddProjSupportOwner_Controller {
    
    Public List<wrapUser> lstUser4ISO{get;set;}
    Public List<wrapUser> lstUser4PSO{get;set;}
    Public String strISOUserSearch{get;set;}
    Public String strPSOUserSearch{get;set;}
    Public String selISOId{get;set;}
    Public String selPSOId{get;set;}
    Public Boolean renderPage{get;set;}
    Public String renderMessage{get;set;}
    
    Id projectId;
    ApexPages.StandardController stdcon;
    
    public Core_IPS_AddProjSupportOwner_Controller(ApexPages.StandardController controller) {
        stdcon = controller;
        projectId = stdcon.getId();       
        init();
    }
    
    //initialize the default 
    private void init() {
        renderPage = true;
        if(String.isBlank(projectId)) {
            renderPage = false;
            renderMessage = Core_IPS_Helper_Utility.getIPSLabel('IPS_Invalid_URL');
            return;
        } 
        UserRecordAccess objUserRecAccess = [SELECT RecordId,HasEditAccess FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId=:projectId];
        if(objUserRecAccess==null || objUserRecAccess.HasEditAccess!=true) {
            renderPage = false;
            renderMessage = Core_IPS_Helper_Utility.getIPSLabel('IPS_Project_Access_Error');
            return;
        }
        searchISO();
        searchPSO();
    }
    
    //save and redirect to project
    public Pagereference SaveRedirect() {
        Core_IPS_Project__c objProj = new Core_IPS_Project__c(Id=projectId);
        Boolean isUpdate = false;
        if(String.isNotBlank(selISOId)) {
            objProj.Core_IPS_Intel_Support_Owner__c = selISOId=='none' ? null : selISOId;
            isUpdate = true;
        }
        if(String.isNotBlank(selPSOId)) {
            objProj.Core_IPS_Partner_Support_Owner__c = selPSOId=='none' ? null : selPSOId;
            isUpdate = true;
        }
        try{
            if(isUpdate)
                update objProj;
            return stdcon.cancel();
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Core_IPS_Helper_Utility.getIPSLabel('IPS_Generic_Exception_Msg')));
        }
        return null;
    }
    
    //reset the search and selected ISO
    public void ResetISOSearch() {
        selISOId = null;
        strISOUserSearch = null;
        searchISO();
    }
    
    //reset the search and selected PSO
    public void ResetPSOSearch() {
        selPSOId = null;
        strPSOUserSearch = null;
        searchPSO();
    }
    
    //perform search of ISO
    public void searchISO() {
        selISOId = null;
        lstUser4ISO = new List<wrapUser>();
        //US1011877--harsha--11/5/2021--SOQL SOSL Injection fix 
        String newISOusersearch;
        if(String.isNotBlank(strISOUserSearch))
        {
            newISOusersearch = string.escapeSingleQuotes(strISOUserSearch);
        }
        // String strQuery = 'SELECT Id,Core_IPS_User__c,Core_IPS_User__r.FirstName,Core_IPS_User__r.LastName,Core_IPS_User__r.Email FROM Core_IPS_Intel_Support_Team__c' + 
        //     ' WHERE Status__c=\'Active\' AND Core_IPS_User__r.isActive=true AND Core_IPS_Project__c=:projectId';   
        //     //US1011877--harsha--11/5/2021--SOQL SOSL Injection fix          
        // //if(String.isNotBlank(strISOUserSearch)) {
        //     if(String.isNotBlank(newISOusersearch)) {
        //     //strQuery += ' AND ( Core_IPS_User__r.FirstName LIKE \''+strISOUserSearch+'%\' OR Core_IPS_User__r.LastName LIKE \''+strISOUserSearch+'%\' OR Core_IPS_User__r.Email LIKE \''+strISOUserSearch+'%\')';
        //     strQuery += ' AND  ((Core_IPS_User__r.FirstName LIKE \''+ newISOusersearch +'%\') OR (Core_IPS_User__r.LastName LIKE \''+ newISOusersearch +'%\') OR (Core_IPS_User__r.Email LIKE  \''+ newISOusersearch +'%\'))';
        // }
        // strQuery += ' ORDER BY Core_IPS_User__r.Name';
        // SOQL Injection Fix - Start -  Shipra
        Map<String,Object> bindMap =  new Map<String, Object>{ 'projectID' => projectID, 'searchPattern' => newISOusersearch + '%' };
        String strQuery = 'SELECT Id, Core_IPS_User__c, ' +
            'Core_IPS_User__r.FirstName, ' +
            'Core_IPS_User__r.LastName, ' +
            'Core_IPS_User__r.Email ' +
            'FROM Core_IPS_Intel_Support_Team__c ' +
            'WHERE Status__c = \'Active\' ' +
            'AND Core_IPS_User__r.isActive = true ' +
            'AND Core_IPS_Project__c = :projectID ';
        if (String.isNotBlank(newISOusersearch)) {
                strQuery += ' AND ( Core_IPS_User__r.FirstName LIKE :searchPattern OR Core_IPS_User__r.LastName LIKE :searchPattern OR Core_IPS_User__r.Email LIKE :searchPattern)';
        }
        strQuery += ' ORDER BY Core_IPS_User__r.Name';  
        List<Core_IPS_Intel_Support_Team__c> supportTeamLst = Database.queryWithBinds(strQuery, bindMap, AccessLevel.USER_MODE);

        for(Core_IPS_Intel_Support_Team__c objIST : supportTeamLst) {
            System.debug('objIST =='+objIST);
           // SOQL Injection Fix - End -  Shipra
            wrapUser objWU = new wrapUser();
            objWU.userId = objIST.Core_IPS_User__c;
            objWU.firstName = objIST.Core_IPS_User__r.FirstName;
            objWU.lastName = objIST.Core_IPS_User__r.LastName;
            objWU.email = objIST.Core_IPS_User__r.Email;
            lstUser4ISO.add(objWU);
        }
        lstUser4ISO.add(emptyUser());
    }
    
    //perform search of PSO
    public void searchPSO() {
        selPSOId = null;
        lstUser4PSO = new List<wrapUser>();
         
        String DFAEPermissionSetId = System.Label.Core_IPS_Partner_DFAE_Permission_Set;
        String partnerProfileId = System.Label.Core_IPS_Partner_Profile_Id;
        //US1011877--harsha--11/5/2021--SOQL SOSL Injection fix 
        String newPSOUserSearch;
        if(String.isNotBlank(strPSOUserSearch))
        {
            newPSOUserSearch = string.escapeSingleQuotes(strPSOUserSearch);
        }
        // SOQL Injection Fix - Start -  Shipra
        Map<String,Object> bindMap =  new Map<String, Object>{ 'projectId' => projectId, 'searchPattern' => newPSOUserSearch + '%', 'DFAEPermissionSetId'=>DFAEPermissionSetId, 'PartnerProfileId'=>PartnerProfileId };

        String strQuery = 'SELECT Id,Core_User__c,Core_User__r.FirstName,Core_User__r.LastName,Core_User__r.Email FROM Core_IPS_Project_Member__c' + 
            ' WHERE Core_Status__c=\'Active\' AND Core_IPS_Contact__r.Core_IPS_Active__c=true AND Core_User__r.isActive=true AND Core_IPS_Project__c=:projectId AND Core_User__c IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =:DFAEPermissionSetId AND Assignee.ProfileId =:PartnerProfileId)';            
        //US1011877--harsha--11/5/2021--SOQL SOSL Injection fix 
        if(String.isNotBlank(newPSOUserSearch)) {
            strQuery += ' AND ( (Core_User__r.FirstName LIKE :searchPattern ) OR (Core_User__r.LastName LIKE :searchPattern) OR (Core_User__r.Email LIKE :searchPattern))';
        }
        strQuery += ' ORDER BY Core_User__r.Name';          
        List<Core_IPS_Project_Member__c> projectMemberLst = Database.queryWithBinds(strQuery, bindMap, AccessLevel.USER_MODE);
        for(Core_IPS_Project_Member__c objPM : projectMemberLst) {
            
            // SOQL Injection Fix - End -  Shipra
            wrapUser objWU = new wrapUser();
            objWU.userId = objPM.Core_User__c;
            objWU.firstName = objPM.Core_User__r.FirstName;
            objWU.lastName = objPM.Core_User__r.LastName;
            objWU.email = objPM.Core_User__r.Email;
            lstUser4PSO.add(objWU);
        }
        lstUser4PSO.add(emptyUser());
    }
    
    private wrapUser emptyUser() {
        wrapUser objWU = new wrapUser();
        objWU.userId = 'none';
        objWU.firstName = 'Blank';
        return objWU;
    }
    
    //wrapper class for User data
    public class wrapUser {
        public String userId{get;set;}
        public String firstName{get;set;}
        public String lastName{get;set;}
        public String email{get;set;}
    }

}