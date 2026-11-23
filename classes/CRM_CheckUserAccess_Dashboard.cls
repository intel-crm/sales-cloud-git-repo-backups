public without sharing class CRM_CheckUserAccess_Dashboard {
    public class CustomException extends Exception{}
    @future(callout=true)
    public static void updateRunningUser(List<String> dashboardNameList, Id newRunningUserId) {
        For(String dashboardName : dashboardNameList){
            CRM_MetadataService.MetadataPort service = createService();
            user userId = [SELECT Username FROM user WHERE Id =: newRunningUserId];
            try {
                CRM_MetadataService.Dashboard dashboardMetadata = (CRM_MetadataService.Dashboard)service.readMetadata('Dashboard', new List<String>{dashboardName}).getRecords()[0];
                /*if (dashboardMetadata == null) {
                          Throw new CustomException('Dashboard not found: ' + dashboardName);
                      }*/
                dashboardMetadata.runningUser = userId.Username;//newRunningUserId;
                CRM_MetadataService.SaveResult result = service.updateMetadata(new List<CRM_MetadataService.Metadata>{dashboardMetadata})[0];
                if (result.success) {
                    System.debug('Dashboard running user updated successfully.');
                } else {
                    System.debug('Failed to update dashboard: ' + result.errors[0].message);
                }
            } catch (Exception e) {
                System.debug('Error: ' + e.getMessage());
            }
        }
    }

    private static CRM_MetadataService.MetadataPort createService() {
        CRM_MetadataService.MetadataPort service = new CRM_MetadataService.MetadataPort();
        service.SessionHeader = new CRM_MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
}