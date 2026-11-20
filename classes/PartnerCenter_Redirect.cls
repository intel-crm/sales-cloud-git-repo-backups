//This class is used to get the User current Session Type value.
public with sharing class PartnerCenter_Redirect {
    final static String sessionTypeStringVal = 'SessionType';
	
    //getting the User current session type value
    @AuraEnabled
    public static String getCurrentSession(){
        String sesionTypeVal = '';
        Map<String, String> seesionMap = new Map<String, String>();
        if(!Test.isRunningTest()){
            seesionMap = Auth.SessionManagement.getCurrentSession();
        }        
        sesionTypeVal = seesionMap.get(sessionTypeStringVal);
        return sesionTypeVal; 
    }
}