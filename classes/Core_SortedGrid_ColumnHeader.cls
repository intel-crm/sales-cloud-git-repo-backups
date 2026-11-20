public class Core_SortedGrid_ColumnHeader {
 
    public final static String ASCENDING_TEXT = 'ASC';    
    public final static String ASCENDING_ICON = '▼';    

    public final static String DESCENDING_TEXT = 'DESC';    
    public final static String DESCENDING_ICON = '▲';    

    public final static String NULLS_FIRST_TEXT = 'NULLS FIRST';
    public final static String NULLS_LAST_TEXT  = 'NULLS LAST';
 
    // The constructor initializes sortDir & sortExp  
    private String sortDir;
    private String sortExp;
    private String sortNull;

    public Core_SortedGrid_ColumnHeader(String defaultField)
    {    
        sortExpression = defaultField;        
    }
    
    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == ASCENDING_TEXT) ? DESCENDING_TEXT : ASCENDING_TEXT;
            else
                sortDirection = ASCENDING_TEXT;
                
            sortExp = value;
        }
    }


    public String sortDirection
    {
        get 
        {
            //if not column is selected 
            if (sortExpression == null || sortExpression == '')
                sortDir = ASCENDING_TEXT;

            return sortDir;
        }
        set 
        {  
            sortDir = value;
            if (sortDir == ASCENDING_TEXT)
                sortNull = NULLS_FIRST_TEXT;
            else
                sortNull = NULLS_LAST_TEXT;                        
        }  
    }  
  

    public String sortNullFirstLast 
    {
        get
        {
            if (sortNull == null || sortNull == '')
                sortNull = NULLS_FIRST_TEXT; 
            
            return sortNull;
        }
    }

  
    public String sortIndicator
    {
        get 
        {
            if (sortDirection == ASCENDING_TEXT)
                return ASCENDING_ICON;
            else    
                return DESCENDING_ICON;        
        }       
    }  
}