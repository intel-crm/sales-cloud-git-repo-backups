/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_Exception 
* Version     : 1.0 
* Created Date: 4 Jan 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         1/04/2017               Custom Exception class for all the Rest API's 
*****************************************************************************************************************************************/
global class Core_RestAPI_Exception extends Exception {
    //Defaults error messags are set in code, set the custom message explicity when needed.
    public String errorCode = 'NOT_FOUND';
    public String message = 'Could not find a match for URL';
}