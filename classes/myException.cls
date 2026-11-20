public class myException extends Exception {
    boolean escape ;
    String errMsg ; 
   public myException (String errMsg, boolean escape){
        this.errMsg = errMsg;
        this.escape = escape;
    }
    
    public void addError(String errMsg, boolean escape){
        
    }
    
}