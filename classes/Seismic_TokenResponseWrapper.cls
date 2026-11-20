/****************************************************************************************************************************************
* Class Name  : Seismic_TokenResponseWrapper 
* Version     : 1.0 
* Created Date: 08/24/2022 
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            08/24/2022               		The Apex TokenResponseWrapper for Seismic API Call 
*****************************************************************************************************************************************/

public class Seismic_TokenResponseWrapper {
    public String access_token {get; set;}  //eyJhbGci...
    public String expires_in {get; set;}  //21600
    public String token_type {get; set;}  //Bearer
    public String scope {get; set;}  //seismic.user.manage
}