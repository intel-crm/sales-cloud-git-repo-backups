/***************************************************************************************************
Class Name:  Core_IPS_fromJSON_Test
Class Type: Test Class 
Version     : 1.0 
Created Date: 04 Feb 2016
Function    : This class contains test coverage for Core_IPS_fromJSON Apex Class.
Description:   This class contains unit test scenarios for Core_IPS_fromJSON Apex Class
Used in     : None
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Abhishek Ekbote      04/02/2016                Created
****************************************************************************************************/ 
@isTest
public class Core_IPS_fromJSON_Test{
    static testMethod void testParse() {
        String json=        '{"query" : "??l0???6????"}';
        Core_IPS_fromJSON fromJSONobj = new Core_IPS_fromJSON();
        Core_IPS_fromJSON parsedObj = Core_IPS_fromJSON.parse(json);
        System.assert(parsedObj != null);
    }

}