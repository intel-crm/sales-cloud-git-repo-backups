public class Core_MDF_RecordPGMShareWrapper {
    public Id recordId;
    public string geo;
    public string subGeo;
    public string budgetType;
    public String program; 
    public Id ultAccountId;
    public String accessLevel;
    
    public Core_MDF_RecordPGMShareWrapper(Id recordId,string geo,string subGeo,string program,string budgetType,Id ultAccountId){
            this.recordId = recordId;
            this.geo = geo;
        	this.subGeo = subGeo;
        	this.program = program;
            this.budgetType = budgetType;
            this.ultAccountId = ultAccountId;
    }
    
    public Core_MDF_RecordPGMShareWrapper(Id recordId,string geo,string subGeo,string program,Id ultAccountId){
        this.recordId = recordId;
        this.geo = geo;
        this.subGeo = subGeo;
        this.program = program;
        this.budgetType = null;
        this.ultAccountId = ultAccountId;
    }
    public Core_MDF_RecordPGMShareWrapper(Id recordId,string geo,string subGeo,string program,string budgetType,Id ultAccountId, String accessLevel){
            this.recordId = recordId;
            this.geo = geo;
        	this.subGeo = subGeo;
        	this.program = program;
            this.budgetType = budgetType;
            this.ultAccountId = ultAccountId;
            this.accessLevel = accessLevel;
    }
   
}