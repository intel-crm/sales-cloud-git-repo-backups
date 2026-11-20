/****************************************************************************************************************************
Apex Class Name     : PRM_OPIDErrorWrapper 
Version             : 1.0
Created Date        : Dec 2018
Function            : Wrapper class to hold error related updates

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Prasant Sahu      26-Jun-2020                   Wrapper class to hold error related updates
****************************************************************************************************************************/
public class PRM_OPIDErrorWrapper {
    
    public Map<String,String> pagAccountMapError = new Map<String,String>();
    public Map<String,String> asaMapError = new Map<String,String>();
    public Map<String,String> acmMapError = new Map<String,String>();
    public Map<String,String> cagMapError = new Map<String,String>();    
    public Map<String,String> aiaMapError = new Map<String,String>(); //NJ AIA   
 	/*public Map<String,String> abaMapError = new Map<String,String>(); */
    
    public void putPAGError(Map<String,String> pagAccountMapError){
        this.pagAccountMapError.putAll(pagAccountMapError);
    }
    
    public Map<String,String> getPAGError(){
        return this.pagAccountMapError;
    }
    
    public void putASAError(Map<String,String> asaError){
        this.asaMapError.putAll(asaError);
    }
    
    public Map<String,String> getASAError(){
        return this.asaMapError;
    }
    
    public void putACMError(Map<String,String> acmError){
        this.acmMapError.putAll(acmError);
    }
    
    public Map<String,String> getACMError(){
        return this.acmMapError;
    }
    
    public void putCAGError(Map<String,String> cagError){
        this.cagMapError.putAll(cagError);
    }
    
    public Map<String,String> getCAGError(){
        return this.cagMapError;
    }

    // AIA Start
    public void putAIAError(Map<String,String> aiaError){
        this.aiaMapError.putAll(aiaError);
    }
    
    public Map<String,String> getAIAError(){
        return this.aiaMapError;
    }
    // AIA end

 /*	public void putABAError(Map<String,String> ABAError){
        this.abaMapError.putAll(ABAError);
    }
    
    public Map<String,String> getABAError(){
        return this.abaMapError;
    } */
    
}