public class Core_MDF_RecordGeoShare {
    public Id recordId;
    public string geo;
    public string subGeo;
    public string budgetType;
    public String program;
    public List<Id> groupId;
	public List<Id> groupId_RO;  
    public Id accountId;  
    public Id programId;
    public String accessLevelForEditGrps ;
    
        public Core_MDF_RecordGeoShare(Id recordId,string geo,string subGeo, string program, string budgetType){
            this.recordId = recordId;
            this.geo = geo;
        	this.subGeo = subGeo;
            this.program = program;
        	this.budgetType = budgetType;
        } 
        public Core_MDF_RecordGeoShare(Id recordId,string geo,string subGeo, string program, string budgetType,String accessLevelForEditGrps){
            this.recordId = recordId;
            this.geo = geo;
        	this.subGeo = subGeo;
            this.program = program;
        	this.budgetType = budgetType;
            this.accessLevelForEditGrps = accessLevelForEditGrps;
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
   public Core_MDF_RecordGeoShare(Id recordId,string geo,string subGeo, string budgetType, Id accountId, String program){
            this.recordId = recordId;
            this.geo = geo;
        	this.subGeo = subGeo;
        	this.budgetType = budgetType;
            this.program = program;
            this.accountId = accountId;
    } 
    public Core_MDF_RecordGeoShare(Id recordId,string geo,string subGeo, Id accountId, String program){
        this.recordId = recordId;
        this.geo = geo;
        this.subGeo = subGeo;
        this.budgetType = null;
        this.program = program;
        this.accountId = accountId;
 }  
   
}