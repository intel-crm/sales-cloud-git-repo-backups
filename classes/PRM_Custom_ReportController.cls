public class PRM_Custom_ReportController {
public list <account> acc {get;set;} 
public string searchstring {get;set;}
public boolean sendmail{get;set;}  
public string selectedCountry1{get;set;} 
public PRM_Custom_ReportController ( ) { 
sendmail=true;
} 
public void search(){ 
searchstring ='test';
string searchquery='select name,id from account where name like \'%'+searchstring+'%\' Limit 20'; 
acc= Database.query(searchquery);
sendmail=false; 
} 
public void clear(){ 
acc.clear(); 
} 
}