/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : WordDocController
 * Author          : <YourName>
 * Created Date    : Apr 30, 2026
 * Last Modified By: <YourName>
 * Last Modified On: Apr 30, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Apr 30, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

public without sharing class WordDocController {

	public static String processHtmlImages(Id recordId) {


		Executive_Meeting_Brief__c record =  [
            
            SELECT Id, Name, Core_Executive_Meeting_Brief_Name__c,CRM_Intels_Meeting_Objectives__c,CRM_Most_Critical_Messages_to_Get_Across__c,CRM_Other_Partys_Meeting_Objectives__c,Account__c,CRM_PreparedBy__r.Name,CRM_Location__c,CRM_Location__Street__s,CRM_Location__City__s,CRM_Location__PostalCode__s,CRM_Location__StateCode__s,CRM_Location__CountryCode__s,CRM_Dress_Code__c,CRM_Scheduled_End_Time_txt__c,CRM_Scheduled_Start_Time_txt__c,
            
            Industry_Insights_Political_Climate__c,How_They_Buy_Sell__c,CRM_Investor_Scouting_Report__c,CRM_Additional_Legal_Guidance__c,CRM_Attendee_Bio_s__c,CRM_Brief_Reviewer__r.Name
            
            FROM Executive_Meeting_Brief__c
            
            WHERE Id =:recordId
            
            LIMIT 1
            
        ];
        
		String html = record.CRM_Attendee_Bio_s__c;
        // Regex to isolate individual <img> tags
        Pattern imgPattern = Pattern.compile('<img[^>]+>');
        Matcher imgMatcher = imgPattern.matcher(html);
        
        while (imgMatcher.find()) {
            String fullImgTag = imgMatcher.group();
            
            // Extract IDs and Filenames
            String refId = getTagAttribute(fullImgTag, 'refid');
            String altText = getTagAttribute(fullImgTag, 'alt');
            String originalSrc = getTagAttribute(fullImgTag, 'src');
            
            ContentVersion cv = findContentVersion(refId, altText);
            
            if (cv != null) {
                // Convert to Base64
                String base64Data = EncodingUtil.base64Encode(cv.VersionData);
                String dataUri = 'data:image/' + cv.FileType.toLowerCase() + ';base64,' + base64Data;
                
                // Swap the URL with the actual image data
                html = html.replace(originalSrc, dataUri);
            }
			system.debug('html'+html);
        }
        return html;
    }

    public static ContentVersion findContentVersion(String refId, String altText) {
        List<ContentVersion> results = new List<ContentVersion>();

        // LAYER 1: Search by the refId (treating it as a ContentDocumentId)
        if (String.isNotBlank(refId)) {
            results = [SELECT VersionData, FileType FROM ContentVersion 
                       WHERE ContentDocumentId = :refId AND IsLatest = true LIMIT 1];
        }

        // LAYER 2: Search by the refId as a ContentAsset relationship
        if (results.isEmpty() && String.isNotBlank(refId)) {
            results = [SELECT VersionData, FileType FROM ContentVersion 
                       WHERE ContentDocumentId IN (SELECT ContentDocumentId FROM ContentAsset WHERE Id = :refId) 
                       AND IsLatest = true LIMIT 1];
        }
		system.debug('results-->'+results);
        // LAYER 3: Fallback to Title Search (using the filename from the alt tag)
        if (results.isEmpty() && String.isNotBlank(altText)) {
            // Remove file extension for Title search
            String title = altText.contains('.') ? altText.substringBeforeLast('.') : altText;
            results = [SELECT VersionData, FileType FROM ContentVersion 
                       WHERE Title = :title AND IsLatest = true LIMIT 1];
        }
		system.debug('results-->'+results);
        return results.isEmpty() ? null : results[0];
    }

    public static String getTagAttribute(String tag, String attr) {
        Pattern p = Pattern.compile(attr + '="([^"]+)"');
        Matcher m = p.matcher(tag);
        return m.find() ? m.group(1) : '';
    }

}