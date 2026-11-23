public class Core_MDF_UserPermissionCheck {
    @AuraEnabled
    public static boolean getObjectAccess(string ObjectName){
        Boolean isObjectAccessible = false;
        isObjectAccessible = Schema.getGlobalDescribe().get(ObjectName).getDescribe().isAccessible();
        return isObjectAccessible;
    }
}