/**************************************************************************************************************
Apex Class Name:  PRM_SearchAccounts  
Version     : 1.0 
Created Date: 28 Jan 2020
Function    : It act as wrapper class which is used in PRM_CIMAccountSearch.apxc and PRM_searchsfdcAccounts.apxc
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Prasant Sahu         02/06/2020        Initial version
***************************************************************************************************************/

global class PRM_SearchAccounts implements Comparable{
    public Id AccountId{
        get;
        private set;
    }
    
    public String accCIMId{
        get;
        private set;
    }
    
    public Account acc{
        get;
        private set;
    }
    
    public Integer searchScore{
        get;
        private set;
    }     
    
    global RelatedACMRecords relatedACM{
        get;
        set;
    }     
    
    public PRM_SearchAccounts(Id AccountId,String cimId, Account acc, Integer searchScore){
        this.AccountId = AccountId;
        this.acc = acc;
        this.searchScore = searchScore;
        this.accCIMId = cimId;
    }
    
    public Integer compareTo(Object obj) {
        PRM_SearchAccounts searchAccount = (PRM_SearchAccounts)(obj); 
        return (this.searchScore > searchAccount.searchScore ? -1 : (this.searchScore < searchAccount.searchScore ? 1 : 0));      
    }
}