global class AccountWrapper implements Comparable {

    public Account Acc;
    
    // Constructor
    public AccountWrapper(Account Ac) {
        Acc = Ac;
    }
    
    // Compare opportunities based on the Account CreatedDate.
    global Integer compareTo(Object compareTo) {
        // Cast argument to AccountWrapper
        AccountWrapper compareToAcc = (AccountWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (Acc.CreatedDate > compareToAcc.Acc.CreatedDate) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (Acc.CreatedDate < compareToAcc.Acc.CreatedDate) {
            // Set return value to a negative value.
            returnValue = -1;
        } else if ((Acc.CreatedDate == null) && (compareToAcc.Acc.CreatedDate != null)){
            // nulls-first implementation
            returnValue = -1;
        } else if ((Acc.CreatedDate != null) && (compareToAcc.Acc.CreatedDate == null)){
            // nulls-first implementation
            returnValue = 1;
        }        
        return returnValue;       
    }
}