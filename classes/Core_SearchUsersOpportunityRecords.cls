/*********************************************************************************************************************************************************************************
Apex Class Name:  Core_SearchUsersOpportunityRecords
Version     : 1.0 
Created Date: 10 OCT 2014
Function    : Apex Class for Core_GlobalOpportunitySearch Page. 
              To return records for which user is having access
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Harshith M L             10/10/2014              Original Version
* Kunal Mehta              10/10/2014              Original Version
* Harshith M L             02/17/2015              Added extra parameter for doQuery method opportunity ids set used in query( Line No 23 - 26 )
* Brian Matthews           03/09/2015              Clone Cleanup
**********************************************************************************************************************************************************************************/

Public with sharing class Core_SearchUsersOpportunityRecords
{
    /*
    * Method name  : doQuery
    * Description  : Method to fetch records for which user is having access 
    * Return Type  : List<Opportunity>
    * Parameter    : None
    */
    public Static List<Opportunity> doQuery(string query,SET<ID> setOpportunityIds)
    { 
        //String.escapeSingleQuotes added for security scan.
        //return database.Query(query  + ' Where Id in :setOpportunityIds ORDER BY ID');
        return database.Query(String.escapeSingleQuotes(query  + ' Where Id in :setOpportunityIds ORDER BY ID'));
    }
}