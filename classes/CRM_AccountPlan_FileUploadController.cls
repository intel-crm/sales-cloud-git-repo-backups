/**
* @File Name : CRM_AccountPlan_FileUploadController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : May 14, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 14, 2025 |   | Initial Version
**/

public class CRM_AccountPlan_FileUploadController {
	@AuraEnabled
    public static String saveScreenshot(String base64Data, String fileName) {
        String cleanData = base64Data.replaceFirst('^data:image/[^;]+;base64,', '');

        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = fileName + '.png';
        cv.VersionData = EncodingUtil.base64Decode(cleanData);
        insert cv;

        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        return cv.ContentDocumentId;
    }
}