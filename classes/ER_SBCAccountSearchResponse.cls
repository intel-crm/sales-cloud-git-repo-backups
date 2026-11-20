/*********************************************************************************************************************
Modification Log : 
* Developer                 		Date                    Description
* ----------------------------------------------------------------------------------------------
*Harshitha/Manjunatha(Quest)       25/06/2021               Response Format for handling the CIM Results returned
*********************************************************************************************************************/


global class ER_SBCAccountSearchResponse {
    public String AccountName;
    public Address AccountAddress;
    public String AccountID;
    public String CimID;
    public ER_SBCAccountSearchResponse(String accName, Address add, String sfdId, String cimIds){
        AccountName = accName;
        AccountAddress = add;
        AccountID = sfdId;
        CimID = cimIds;
    }	
}