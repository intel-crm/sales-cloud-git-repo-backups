////Public class ER_SearchAccounts ---Previously class was Publc, for IPA changes made it Global date:06/10/21

global class ER_SearchAccounts implements Comparable{
    public Id AccountId{        get;        private set;    }
    
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
    

    public ER_SearchAccounts(Id AccountId,String cimId, Account acc, Integer searchScore){
        this.AccountId = AccountId;
        this.acc = acc;
        this.searchScore = searchScore;
        this.accCIMId = cimId;
    }
    
	public Integer compareTo(Object obj) {
    ER_SearchAccounts searchAccount = (ER_SearchAccounts)(obj); 
    return (this.searchScore > searchAccount.searchScore ? -1 : (this.searchScore < searchAccount.searchScore ? 1 : 0));
    }
}