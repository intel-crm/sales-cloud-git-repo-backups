/*********************************************************************************************************************
* Apex Class Name  : Core_IntegrationMessageJSONWrapper
* Author And Date  : Rohit Podder, 10 AUG 2026
* Function         : Wrapper class for parsing JSON payload of Integration Inbound Message
*********************************************************************************************************************/
public with sharing class Core_IntegrationMessageJSONWrapper {
    public Core_IntegrationMessageJSONWrapper(){
        //default constructor for test coverage
    }
    public UserProfile userProfile;
    public String publishTimeStamp;
    public String changeAgent;
    public String isDeleteIndicator;
    public class UserProfile{
        public List<Map<String,String>> personBasicProfile;
        public List<Map<String,String>> electronicAddresses;
        public List<Map<String,String>> subscriptions;
        public List<Map<String,String>> physicalAddresses;
        public List<Map<String,String>> professions;
        public List<Map<String,String>> engagements;
        
    }
}