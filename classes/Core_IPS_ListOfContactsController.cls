/***************************************************************************************************
Version     : 1.0 
Created Date: 17 AUG 2020
Description: THis controller is responsible for Displaying all contacts on Partner Portal of the respective Account.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
Created for US682835 - A Contact on the Partner portal needs to have a means to see all other IPS Active Contacts on their same Account.
****************************************************************************************************/ 
public class Core_IPS_ListOfContactsController {
    public static list<Contact> con{set;get;}
    public integer counter{get;set;}{counter=0;} //keeps track of the offset 
    public integer totalSize{get;set;} //used to show user the total size of the list
    public Core_IPS_ListOfContactsController() {
        totalSize=[select count() FROM Contact WHERE ( AccountID In (SELECT AccountID FROM User WHERE id=:userinfo.getuserid()) and (Core_IPS_Active__c=true)) ];
    } 
    public void showAllContacts()
    {   
        con=[SELECT Id,Name,FirstName,LastName,Email,Account.Name FROM Contact WHERE ( AccountID In (SELECT AccountID FROM User WHERE id=:userinfo.getuserid()) and (Core_IPS_Active__c=true)) ORDER BY Name limit :numberLimit offset :counter];
    }
    //Number of records to be displayed per page Starts
    List<String> contactPages;
    public list<selectOption> records{get;set;}{
        contactPages = String.valueOf(System.label.Core_IPS_CaseComment_Pages).split(';');
        records=new List<selectOption>();
        for(Integer i=0;i<contactPages.size();i++){
            records.add(new selectoption(contactPages[i],contactPages[i]));                    
        } 
    }
    public integer numberLimit{get;set;}{
        if(contactPages.size()>0){
            numberLimit=Integer.valueOf(contactPages[0]);
        }else {
            numberLimit=0;
        }
    }
    // //Number of records to be displayed per page Ends
    public Boolean getDisablePrevious() { 
        //this will disable the previous and beginning buttons
        if (counter>0){ return true; }
        else{ return false;}
    }
    public Boolean getDisableNext() { //this will disable the next and end buttons
        if ((counter + numberLimit) < totalSize){ return true; }
        else{ return false;} 
    }
    public Integer getTotalSize() {
        return totalSize;
    }
    public Integer getPageNumber() {
        return counter/numberLimit + 1;
    }
    
    public Integer getTotalPages() {
        if (math.mod(totalSize, numberLimit) > 0) {
            return totalSize/numberLimit + 1;
        }else {
            return (totalSize/numberLimit);
        }       
    }
    
    public void next(){  
        Counter += numberLimit;
        showAllContacts();
    }
    
    public void previous(){
        counter -= numberLimit;
        showAllContacts();
    }
    
    public void showRecords() {  
        counter=0;
        showAllContacts();
    }
    
}