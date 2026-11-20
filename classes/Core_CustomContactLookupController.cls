public with sharing class Core_CustomContactLookupController {
    
    private String SOQLResultLimit = ' Limit 1000';
    
    // search results
    public List<Contact> results{get;set;} 
    
    // search keyword
    public string searchString{get;set;} 
    
    //Account Id 
    public string conAccountId;
    
    public Core_CustomContactLookupController () {
        // get the current search string
        searchString = System.currentPageReference().getParameters().get('lksrch');
        conAccountId = System.currentPageReference().getParameters().get('conaccid');
        runSearch();  
    }
    
    // performs the keyword search
    public PageReference search() {
        runSearch();
        return null;
    }
    
    // prepare the query and issue the search command
    private void runSearch() {
        // TODO prepare query string for complex serarches & prevent injections
        results = performSearch(searchString);               
    } 
    
    // run the search and return the records found. 
    private List<Contact> performSearch(string searchString) {
        //String.valueOf() method added to conAccountId for Security Scan
        string strId = String.valueOf(conAccountId);
        string escId;
        if(strId <> null){
            escId = String.escapeSingleQuotes(strId);
        }else{
            escId = null;
        }
        String soql = 'select id, name from contact where AccountId =:  escId';
        //if(searchString != '' && searchString != null )
        if(String.isNotBlank(searchString))
            soql = soql +  ' And name LIKE \'%' + String.escapeSingleQuotes(searchString)  +'%\'';
        
        soql = soql + SOQLResultLimit;
        //return database.query(soql); 
        return database.query(soql);  
    }
    
    
    // Used by the visualforce page to send the link to the right dom element
    public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }
    
    // used by the visualforce page to send the link to the right dom element for the text box
    public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }
    
}