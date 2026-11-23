public class Core_MDF_RecordGeoShare {
    public Id recordId;
    public string geo;
    public string subGeo;
    public String program;
    public string groupId;
    
    
    public Core_MDF_RecordGeoShare(Id recordId,string geo,string subGeo, string program){
            this.recordId = recordId;
            this.geo = geo;
        	this.subGeo = subGeo;
            this.program = program;
        } 
    public Core_MDF_RecordGeoShare(Id recordId,string geo, string program){
            this.recordId = recordId;
            this.geo = geo;
        	this.subGeo = null;
            this.program = program;
        } 

}