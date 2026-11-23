/****************************************************************************************************************************************
* Class Name  : Seismic_CustomPropertyItem 
* Version     : 1.0 
* Created Date: 12/15/2022
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            12/15/2022               		The Apex Seismic_CustomPropertyItem for Seismic API Call 
*****************************************************************************************************************************************/
public class Seismic_CustomPropertyItem_NOT_INUSE {
    public String kind {get; set;} //CustomProperty
    public String name {get; set;} //"_Do Not Use",
    public String propertyType {get; set;} //": single-select/ "string"
    public String order {get; set;} //": 0
    public String propertyHint {get; set;} //": null
    public Seismic_DOV[] domainOfValues  {get; set;}  //"domainOfValues": [{"id": "801556db-1c19-5fc2-d967-1f7d0e563866", "value": "Audience"}]
    
    public Seismic_CustomPropertySettings settings  {get; set;}
    //public Seismic_CustomPropertyScopes scopes  {get; set;}
    public Seismic_CustomPropertyTeamSites teamSites  {get; set;}
    
    public String lastUpdateUserId {get; set;}
    public String lastUpdateDateTime {get; set;}
    public String tenantId {get; set;}
    public String id {get; set;}
    public String etag {get; set;}
    public String timestamp {get; set;}
        
}