/****************************************************************************************************************************************
* Class Name  : Seismic_DOVsResponseWrapper 
* Version     : 1.0 
* Created Date: 12/15/2022
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            12/15/2022               		The Apex Seismic_DOVsResponseWrapper for Seismic API Call 
*****************************************************************************************************************************************/
public class Seismic_DOVsResponseWrapper {
    public String id {get; set;} //": "526306a2-a841-3097-34f5-a36b104c9770",
    public String name {get; set;} //": "Audience L0",
    public String type {get; set;} //": "string"
    public Boolean hasDomainOfValues {get; set;} //true
    public Seismic_DOV[] domainOfValues  {get; set;}  //"domainOfValues": [{"id": "801556db-1c19-5fc2-d967-1f7d0e563866", "value": "Audience"}]
    //public String teamsites {get; set;} //": "string"
}