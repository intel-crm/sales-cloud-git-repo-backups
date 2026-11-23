public with sharing class showMAGquestionaire {
  public String getHtmlText() {
    String query = '';
    If(Test.isRunningTest()){
        query='Select Body From Document limit 1';
    }else{
        query='Select Body From Document Where Id =\'' + String.escapeSingleQuotes(System.Label.MAG_Document_Id) +'\' limit 1';
    }
    System.debug ('HERE  is the QUERY :' + query ); 
    Document doc = Database.query(query);
    return doc.Body.toString();    
  }

public Pagereference disclaimerPage(){
//Commented becaue Removing the vf page core_ips_customer_case_creation 
// return new Pagereference('/apex/core_ips_customer_case_creation');
    return null;

}

}