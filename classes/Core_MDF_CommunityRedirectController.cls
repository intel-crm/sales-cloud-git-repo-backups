/******************************************************************************************************
* Class Name  : Core_MDF_CommunityRedirectController 
* Version     : 1.0 
* Created Date: 7-29-2020
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Intel - SM      7/29/2020          Controller class to get User current Session Type.
Aura enabled class calling from special report redirection lightning component.
*******************************************************************************************************/
public with sharing class Core_MDF_CommunityRedirectController {
    final static String sessionTypeVal = 'SessionType';
        /****************************************************************************************************** 
    Method Name:        getCurrentSession
    @return  :          session type
    @parameters:        N/A
    Description:        This method is used to get current session type
    Added By:           Accenture - AD - 7/29/2020
    Modified By:        Date:           Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public static String getCurrentSession(){
        String sessionType = '';
        Map<String, String> sessionMap = new Map<String, String>();
        //Return true if method invoked from test class, else false
        if(!Test.isRunningTest()){
            sessionMap = Auth.SessionManagement.getCurrentSession();
        }
        //get session type       
        sessionType = sessionMap.get(sessionTypeVal);
        return sessionType;
    }
}