public class Core_MDF_RecordGeoShare {
    public Id recordId;
    public string geo;
    public string subGeo;
    public string budgetType;
    public String program;
    public List<Id> groupId;
	public List<Id> groupId_RO;    
    
    public Core_MDF_RecordGeoShare(Id recordId,string geo,string subGeo, string program, string budgetType){
            this.recordId = recordId;
            this.geo = geo;
        	this.subGeo = subGeo;
            this.program = program;
        	this.budgetType = budgetType;
        } 
    public Core_MDF_RecordGeoShare(Id recordId,string geo,string subGeo, string program){
            this.recordId = recordId;
            this.geo = geo;
        	this.subGeo = subGeo;
            this.program = program;
        	this.budgetType = null;
        }
    public Core_MDF_RecordGeoShare(Id recordId,string geo, string program){
            this.recordId = recordId;
            this.geo = geo;
        	this.subGeo = null;
        	this.budgetType = null;
            this.program = program;
        } 
    public Core_MDF_RecordGeoShare(Id recordId,string program){
            this.recordId = recordId;
            this.geo = null;
        	this.subGeo = null;
        	this.budgetType = null;
            this.program = program;
        } 

}