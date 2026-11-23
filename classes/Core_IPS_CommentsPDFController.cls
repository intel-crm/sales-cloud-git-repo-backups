public with sharing class Core_IPS_CommentsPDFController {
      
    public Case newcase{get;set;}
     public Boolean isPDFExportActive { get; set; }

    public Boolean isExcelExportActive { get; set; }

    public Boolean isCSVExportActive { get; set; }

    public String contentType { get; set; } 

    public String renderType { get; set; }

    public List<List<Object>> lstlstObj { get; set; }
    public String filterName { get; set; }
    
    public Core_IPS_CommentsPDFController (ApexPages.StandardController controller) {
        filterName ='test';
     }   
      
       public List<Core_IPS_Case_Comments__c> getcaseComments(){
        Profile p =[select id,name from Profile where id=:userInfo.getProfileId()];
        
            
            return [select id,name,Core_IPS_Comment__c,Core_IPS_Rich_Comment__c,CreatedBy.name,CreatedBy.Profile.Name,CreatedBy.Firstname,
                    CreatedDate,Core_IPS_BgColor__c,Core_IPS_NickName__c,Core_IPS_Case_Comment_Type__c from Core_IPS_Case_Comments__c 
                    limit 5
                    ];    // limit and offset was aded by venki for pagination
                    
               
        
            
    } 
    public pageReference pdf(){
    
        return null;
    }
    
    public boolean isExport {get;set;}
    public PageReference exportToCSV() {

        try {
           // loadData(true);  // The data must be "cleaned" for CSV
        }
        catch (Exception e) {
            String consolidatedMessage = e.getTypeName() + ' on line# ' + e.getLineNumber() + ' : ' + e.getMessage();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, consolidatedMessage);
            ApexPages.addMessage(myMsg);
            return null;
        }
isExport =true;
        
        return null;
                
    }  
    


}