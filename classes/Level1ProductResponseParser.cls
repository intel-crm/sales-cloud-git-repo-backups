/***************************************************************************************************************************
 * Apex Class Name: Level1ProductResponseParser
 * Author And Date: Rohit Podder, 25 MAY 2026
 * Function: Parses HTTP responses from PIM API into Level1ProductResponseWrapper
 *          (Single Responsibility: Only handles JSON parsing and category filtering)
 ****************************************************************************************************************************/
public class Level1ProductResponseParser {
    
    public Level1ProductResponseWrapper parse(HttpResponse response) {
        String modifiedJson = response.getBody()
            .replace('"_metadata":', '"metadata":')
            .replace('"limit":', '"limitValue":');
        System.debug((Level1ProductResponseWrapper) JSON.deserialize(modifiedJson, Level1ProductResponseWrapper.class));
        return (Level1ProductResponseWrapper) JSON.deserialize(modifiedJson, Level1ProductResponseWrapper.class);
    }
    
    public Map<String, String> extractRootCategories(Level1ProductResponseWrapper wrapper) {
        Map<String, String> rootCategories = new Map<String, String>();
        if (wrapper != null && wrapper.categories != null) {
            for (Level1ProductResponseWrapper.Category c : wrapper.categories) {
                if (c.parentId == 'root' && c.Name != Null && (String)c.sourceId != Null) {
                    rootCategories.put(c.Name, (String) c.sourceId);
                }
            }
        }
        return rootCategories;
    }
}