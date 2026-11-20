/***************************************************************************************************************************
 * Apex Class Name: Level1ProductResponseWrapper
 * Author And Date: Rohit Podder, 25 MAY 2026
 * Function: Data Transfer Object for Level 1 Product API response deserialization
*****************************************************************************************************************************/
public class Level1ProductResponseWrapper {
    public Level1ProductResponseWrapper(){
        //default constructor for test coverage
    }
    public List<Category> categories;
    public Metadata metadata;
    
    public class Metadata {
        public Integer count;
        public Integer limitValue;
        public Integer offset;
    }
    
    public class Category {
        public String parentId;
        public String sourceId;
        public String Name;
    }
}