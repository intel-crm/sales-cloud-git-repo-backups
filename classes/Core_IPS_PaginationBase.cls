public virtual class Core_IPS_PaginationBase {
           
    Public Core_IPS_PaginationBase() {
        pageSize = 10;
        pageNo = 1;
    }    
    
    /****************** Pagination Variables ****************/
    
    Public List<SelectOption> lstColumn{get;set;}
    Public List<Object> recordList;        
    Public List<Object> lstRecord{
        get{
            if(recordList!=null) {              
                List<Object> newList = new List<Object>();
                for(Integer i=skipFirst; i < (skipFirst+currentPageSize); i++) {                    
                    newList.add(recordList[i]);                    
                }
                return newList;
            }
            return recordList;
        }
        set{
            recordList = value;
        }
    }
        
    Public Integer sortColNo{get;set;}
    Public String sortColName{get;set;}
    Public Boolean sortAsc{get{
        if(sortAsc==null){ sortAsc = false; }
        return sortAsc;
    }set;}
    Public Integer pageSize{get;set;}
    Public Integer pageNo{get;private set;}    
    
    public Integer totalSize {
        get {
            Integer totSize = 0;
            if(recordList!=null){ totSize = recordList.size(); }
            //if(recordSList!=null){ totSize = recordSList.size(); }
            return totSize;
        }
    }
    
    public Integer totalPage {
        get {
            Integer totPage = 0;
            if(totalSize>0) {
                if(Math.mod(totalSize,pageSize)==0) {
                    totPage = totalSize/pageSize;
                }
                else {
                     totPage = (totalSize/pageSize) + 1;
                }
            }
            return totPage;
        }
    }
    
    Public Integer skipFirst{
        get {            
            return ((pageNo - 1) * pageSize);
        }
    }
    
    Public Integer currentPageSize {
        get {
            if(pageNo<totalPage) { return pageSize; }
            else { return totalSize-skipFirst; }
        }
    }
    
    Public Boolean hasNext {
        get{
            return pageNo<totalPage;
        }
    }
    
    Public Boolean hasPrevious {
        get{
            return pageNo>1;
        }
    }
    
    
    /****************** Pagination Methods ****************/
    
    public void nextPage() {
        pageNo++;
        if(pageNo>totalPage) {
            pageNo = totalPage;
        }
    }
    
    public void previousPage() {
        pageNo--;
        if(pageNo<1) {
            pageNo = 1;
        }
    }
    
    public void firstPage() {
        pageNo = 1;
    }
    
    public void lastPage() {
        pageNo = totalPage;
    }
    
    public void pageChanged() {
        if(pageNo>totalPage)
            lastPage();
    }
    /*
    public void doSortByColNo() {
        if(recordList!=null) {
            if(lstColumn!=null && sortColNo!=null) {
				wrapRecord.SortByCol = lstColumn.get(sortColNo).getValue();
                //sortAsc = !sortAsc;
                wrapRecord.sortDesc = !sortAsc;
                recordList.sort();
                firstPage();
            }
        }
    }
    
    public void doSortByColName() {
        if(recordList!=null && String.isNotBlank(sortColName)) {
            wrapRecord.SortByCol = sortColName;
            //sortAsc = !sortAsc;
            wrapRecord.sortDesc = !sortAsc;            
            recordList.sort();
            firstPage();
        }
    }
	*/
}