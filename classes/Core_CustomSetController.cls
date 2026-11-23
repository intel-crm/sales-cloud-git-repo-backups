/****************************************************************************************************************************************
* Class Name  : Core_CustomSetController
* Version     : 1.0 
* Created Date: 5 Oct 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         10/5/2017               Set Controller to create Premier Support Projects As IPS EXternal Customer 
*****************************************************************************************************************************************/
public class Core_CustomSetController {
    
    private  with sharing class WithSharingSetController{
        ApexPages.StandardSetController getSetCntrlr(String query) {
            System.debug(' Intializing Set controller With sharing >> Query '+query);   
            return new ApexPages.StandardSetController(Database.getQueryLocator(query));
        }
    }
    
    public String query{get; private set;}
    public String searchColumnName{get;set;}
    public String searchString{get;set;}
    public Integer pagesize {get;set;}
    public List<Integer> pagesizeList {get;set;}
    public Boolean isExisting {get;set;}
    public static final String RECORDS_LIMIT = ' Limit 10000 ';
    //public static final String ORDER_BY = 'ORDER by Name' ;
    
    public List<String> columnNames {get; private set;}
   // private String recordId {get;set;}
    //private String acctId {get;set;}
   // private String contId {get;set;}
    private Boolean isWithSharing {get;set;}
    public Boolean enableSearch {get; private set;}
    
    public Map<Id, Wrapper> selectedRecords {get;set;}
    public List<Wrapper> getAllSelectedRecords(){
        return selectedRecords.values();
    }
    //Initializing Variables
    private void init(){
        selectedRecords = new Map<Id, Wrapper>();
        this.pagesize = 10;
        this.isExisting = false;
        this.isWithSharing = false;
        this.pagesizeList = new List<Integer>{10,20,50,100};
            
            }
    //Getting the Parameters 
    public Core_CustomSetController(String qry, List<String> cols,  Boolean isWithSharing,  Boolean xsting, String columnNameToSearch){
        init();
        this.query = qry;
        this.columnNames = cols;
        this.isWithSharing = isWithSharing;
        this.isExisting = xsting;
        if(String.isNotEmpty(columnNameToSearch)){
            this.enableSearch = true;
            this.searchColumnName = columnNameToSearch;
        }
        else{
            this.enableSearch = false;
        }
    }
    //Getting Search Condition String
    public String getSearchCondition(){
        String searchCondition = '';
        if(String.isNotBlank(searchString) && String.isNotBlank(searchColumnName)){
            for(String col : searchColumnName.split(',')){
                if(searchCondition.length() > 0)
                    searchCondition = searchCondition +' OR ';
                
                searchCondition = searchCondition + col+' like \'%'+searchString+'%\'';
            }
            searchCondition = ' AND (  ' +searchCondition+' ) ';
        }
        return searchCondition;
    }
    //Set Controller
    public ApexPages.StandardSetController setCntrlr {
        get {
            if(setCntrlr == null) {
                sobjectRecords = null;
                String finalquery = query + getSearchCondition() +' ORDER by Name '+ RECORDS_LIMIT;
                if(isWithSharing == false){
                    System.debug(' Intializing Set controller With out Sharing  query'+finalquery);                
                    this.setCntrlr = new ApexPages.StandardSetController(Database.getQueryLocator(finalquery));
                }else{
                    System.debug(' Intializing Set controller With Sharing  query'+finalquery);                
                    WithSharingSetController tmp = new WithSharingSetController();
                    this.setCntrlr = tmp.getSetCntrlr(finalquery);
                }
                this.setCntrlr.setPageSize(pagesize);
            }
            return setCntrlr;
        }
        set;
    }
    //Used in Wrapper Class sobjectRecords
    public List<sObject> getRecords(){
        System.debug(' >>getRecords>> ' +setCntrlr.getRecords());
        return setCntrlr.getRecords();
    }
    //Wrapper to get Selected Records
    public List<Wrapper> getSelectedSobjectRecords(){
        return SObjectRecords;
    }
    //Wrapper for Selecting/Unselecting Records from tables.
    public List<Wrapper> sobjectRecords{
        public get{
            System.debug('\n\n\n --GET METHOD  sobjectRecords -- '+sobjectRecords);
            List<SObject> lst = setCntrlr.getRecords();
            if(sobjectRecords == null || sobjectRecords.isEmpty()){
                System.debug('Reconstructing---------'+query);
                
                sobjectRecords = new List<Wrapper>();
                for(SObject s : lst){
                    Wrapper w = new Wrapper(s);
                    sobjectRecords.add(w);
                    System.debug(' >> sobjectRecords====== '+sobjectRecords);
                    //IF -  Existing selected records section
                    //ELSE - selected Section or aviable records section
                    if(isExisting == true){
                        w.selected = isExisting;
                    }else{
                        if(selectedRecords.containsKey(s.Id)){
                            w.selected = true;
                        }else {
                            w.selected = false;
                        }
                        
                    }
                    w.isExisting = isExisting;
                }
            }
            System.debug(' >>>>> sobjectRecords====== '+sobjectRecords);
            System.debug(' >> Size of records '+setCntrlr.getResultSize()+'\n -- Returning  sobject records '+SObjectRecords);
            System.debug(' >> selectedRecords '+selectedRecords);
            return sobjectRecords;
        }public set;
    }
    
    //Wrapper used for Updating Selected Records Table
    public class Wrapper{
        public Boolean selected {get;set;}
        public sObject sobj {get;set;}
        public Boolean isExisting = false;
        public Wrapper(SObject s){
            sobj = s;
        }
        public Wrapper(sObject s, Boolean f){
            sobj = s;
            selected = f;
        }
    }    
}