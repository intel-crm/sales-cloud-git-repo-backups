/***************************************************************************************************
Class Name  :  Core_AAQC_LookupController
Class Type  : LookUp Class 
Version     : 1.0 
Description :   Used in case edit page to get the user lookup results.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Nikhil Godhani              27/11/2018              Created
****************************************************************************************************/ 
public with sharing class Core_AAQC_LookupController 
{
    public String searchString {get; set;}                                          // varaible to hold the data which is written in input field  
    public string paramName {get;set;}                                              // varaible to hold data which passed thorugh URL
    public String seatchPhase;                                                      // varaible which can use in dynamic soql query with Like Oprator
    public String queryString;                                                      // variable for dynamic query 
    public transient List<user> lstUser;                                             // variable for user list which is result of dynamic SOQL
    public transient List<user> lstOfProfileUsesr{get; set;}                        // variable to hold username and profile Name
    public transient List<user> lstOfMngerAndUser{get;set;}                         // variable to hold user name and corresponing manager name
    public string adminProfileName;                                                 // variable to hold admin profile Name
    Public string LoggedInUserProfileName;
    Public string LoggedInUserId;

    public Core_AAQC_LookupController(){
        lstUser = new List<user>();
        paramName = ApexPages.currentPage().getParameters().get('queryParam');
    }   
    
    /*  Method Name : pageLoad()
    *   Input Parameters: None
    *   Output Parameters: None  
    *   Author : Nikhil Godhani
    *   Date Created : 13-11-18
    *   Description : This method will set URL passed parameters to controller's varaible    */
    
    public void pageLoad(){
        if(paramName!=null && paramName!=''){
            searchString = paramName;
            getRecords();
            
        }
    }
    
    /*  Method Name : getRecords()
    *   Input Parameters: None
    *   Output Parameters: None  
    *   Author : Nikhil Godhani
    *   Date Created : 13-11-18
    *   Description : This method will return the user list which is searched by lookup filter and Contains Admin Profile
    */
    
    public PageReference getRecords(){
        lstOfProfileUsesr = new List<user>();
        lstOfMngerAndUser = new List<user>();
        LoggedInUserId = UserInfo.getUserId();
        adminProfileName = Label.Core_AAQC_Inquiries_Admin_Profile;
        system.debug('=adminProfileName=='+adminProfileName);
        
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        
        if(PROFILE != null && PROFILE.size()>0){
            LoggedInUserProfileName = PROFILE[0].Name;
        }
        
        system.debug('searchString'+searchString);
        system.debug('LoggedInUserProfileName'+LoggedInUserProfileName+'adminProfileName'+adminProfileName);
        
        if(searchString != '' && searchString.trim().length()>1 ){
            
            seatchPhase ='\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\'';
            
            //created Dynamic query string
            queryString = 'SELECT id,Name,Manager.Id,Manager.Name,Profile.Name FROM user where name like' + seatchPhase;
            
            lstUser = Database.query(queryString);
            
            system.debug('lstUser'+lstUser);
            
            if(lstUser.size() > 0){
                    
                    if(adminProfileName.Contains(LoggedInUserProfileName)){
                            system.debug('not inside of statement');
                            system.debug('inside loggedin user if');
                            
                            for(user userObj : lstUser){
                                system.debug('==='+userObj.Profile.Name);
                                if(userObj.Profile.Name != null && System.Label.Core_AAQC_OBO_Allow_Profile.Contains(userObj.Profile.Name)){
                                    system.debug('inside profile if');
                                    lstOfProfileUsesr.add(userObj);
                                }
                            }
                            system.debug('lstOfProfileUsesr'+lstOfProfileUsesr);
                            
                            /*
                            As per last discussion with Anil now they don't require manager Functionality
                            if(lstOfProfileUsesr!= null && lstOfProfileUsesr.size() == 0){
                                if(LoggedInUserId != null && lstUser != null){
                                    for(User userobj : lstUser){
                                        if(userobj.ManagerId != null && userobj.ManagerId == LoggedInUserId){
                                            lstOfMngerAndUser.add(userobj);
                                        }
                                    }   
                                }
                            system.debug('lstOfMngerAndUser'+lstOfMngerAndUser);
                            }*/
                            
                            if(lstOfProfileUsesr!= null && lstOfProfileUsesr.size() == 0 
                                            /*&& lstOfMngerAndUser != null && lstOfMngerAndUser.size() == 0*/){
                                apexPages.addmessage(new apexpages.message(apexpages.severity.ERROR, LABEL.Core_AAQC_No_Records_Found_Error));
                                return null;
                            }
                    }
                    else{
                        apexPages.addmessage(new apexpages.message(apexpages.severity.ERROR, LABEL.Core_AAQC_No_Records_Found_Error));
                        return null;
                    }
                    
                  /*  
                    As per last discussion with Anil now they don't require manager Functionality
                    else{
                            system.debug('inside manager profile else ');
                            if(LoggedInUserId != null && lstUser != null){
                                for(User userobj : lstUser){
                                    if(userobj.ManagerId != null && userobj.ManagerId == LoggedInUserId){
                                        lstOfMngerAndUser.add(userobj);
                                    }
                                }   
                            }
                            system.debug('lstOfMngerAndUser'+lstOfMngerAndUser);
                            
                            if(lstOfMngerAndUser != null && lstOfMngerAndUser.size() == 0){
                                apexPages.addmessage(new apexpages.message(apexpages.severity.ERROR, LABEL.Core_AAQC_No_Records_Found_Error));
                                return null;
                            }
                    }*/
            }
            else{
                apexPages.addmessage(new apexpages.message(apexpages.severity.ERROR, LABEL.Core_AAQC_No_Records_Found_Error));
                return null;
            }
        }
        else if(searchString== '' || searchString.trim().length() <= 1 ){
            
            apexPages.addmessage(new apexpages.message(apexpages.severity.WARNING,LABEL.Core_AAQC_Enter_Two_Character_Error));
            return null;
        }
        else{
            apexPages.addmessage(new apexpages.message(apexpages.severity.WARNING, LABEL.Core_AAQC_Some_Error_Occurred));
            return null;
        }
        return null;
    }
}