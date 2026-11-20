public class Core_MDF_BudgetTransferWrapper {
    public Id fromAccount;
    public Id toAccount;
    public Id budgetId;
    public Decimal transferAmount;
    public string transferType;
    public Id pfrId;
    public Boolean reverseTransfer;
    
    
    public Core_MDF_BudgetTransferWrapper(Id fromAccount,Id toAccount,Id budgetId, Decimal transferAmount, string transferType){
            this.fromAccount = fromAccount;
            this.toAccount = toAccount;
            this.budgetId = budgetId;
            this.transferAmount = transferAmount;
        	this.transferType = transferType;
        } 
    public Core_MDF_BudgetTransferWrapper(Id fromAccount,Id toAccount,Id budgetId, Decimal transferAmount, string transferType , Id pfrId, Boolean reverseTransfer){
            this.fromAccount = fromAccount;
            this.toAccount = toAccount;
            this.budgetId = budgetId;
            this.transferAmount = transferAmount;
        	this.transferType = transferType;
            this.pfrId = pfrId;
        	this.reverseTransfer = reverseTransfer;
        } 

}