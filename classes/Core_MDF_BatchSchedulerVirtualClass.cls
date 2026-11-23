public virtual class Core_MDF_BatchSchedulerVirtualClass {
    public string jsonString = '';
    public Core_MDF_BatchSchedulerVirtualClass(){
        
    }
    public Core_MDF_BatchSchedulerVirtualClass(String jsonString){
        this.jsonString = jsonString;
    }
    public string getJsonString(){
        return jsonString;
    }
    public virtual object generateInstance(String jsonString){
       	return null;
    }
}