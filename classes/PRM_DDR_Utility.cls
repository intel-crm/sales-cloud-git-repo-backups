public without sharing class PRM_DDR_Utility {
    @AuraEnabled(cacheable=true)
    public static IPADDRWrapper  getProfileInfo(ID userID, String page){
        User currentUser = [Select id,name from User where id=:userID limit 1];
        IPADDRWrapper ddrWrapper = new IPADDRWrapper();
        ddrWrapper.userName = currentUser.name;
        return ddrWrapper;
    }


    class IPADDRWrapper {
        String userName;
    }
}