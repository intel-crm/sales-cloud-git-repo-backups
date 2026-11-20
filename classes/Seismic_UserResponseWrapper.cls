/****************************************************************************************************************************************
* Class Name  : Seismic_UserResponseWrapper 
* Version     : 1.0 
* Created Date: 08/24/2022 
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            08/24/2022               		The Apex Seismic_UserResponseWrapper for Seismic API Call 
*****************************************************************************************************************************************/
public class Seismic_UserResponseWrapper {
    public Seismic_User[] entries  {get; set;}  //eyJhbGci...
    public Integer totalCount {get; set;}  //119
    public Integer offset {get; set;}  //0
    public String continuationToken {get; set;} //": "qaVbv/7rqCfwEQqnGHEXjklxzkltoh94",
    public String nextPageLink {get; set;} //": "https://api.seismic.com/integration/v2/users?limit=2000&offset=1000"
}