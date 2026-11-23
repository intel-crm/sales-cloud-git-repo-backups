/*********************************************************************************************************************
Apex Class Name  : Core_IntegrationMessageJSONParsing
Author And Date  : Rohit Podder, 04 JUNE 2026
Function         : This class is for parsing the JSON payload coming from Integration Inbound Message
*********************************************************************************************************************/
public class Core_IntegrationMessageJSONParsing {
    public Person person;
    
    public class Person {
        public PersonInformation person_information;
        public PersonAccounts person_accounts;
        public PersonElectronicAddresses person_electronic_addresses;
        public PersonEngagement person_engagements;
        public PersonAttribute person_attributes;
        public PersonPhysicalAddress person_physical_addresses;
        public PersonSubscription person_subscription;
        public String inact_indicator;
        public String is_delete_indicator;
        public String change_agt_id;
        public String publish_timestamp;
    }
    
    public class PersonAccounts{
        public List<PersonAccount> person_account;
    }
    
    public class PersonAccount{
        public String account_number;
        public String account_name;
        public map<String,String> cim_id;
        public String inact_indicator;
        public map<String,String> engg_dedup_grp_cd;
        public String salescloud_id;
        public List<PersonAccountRelation> person_account_relation;
        
    }
    
    public class PersonAccountRelation{
        public String relation_code;
        public String relation_name;
        public String inact_indicator;
        public String engagement_code;
    }
    public class PersonInformation {
        public String person_id;
        public Enterprise enterprise_id;
        public IdentityStatus identity_status;
        public ExternalLoginId external_login_id;
        public PersonIdentityDeleted person_is_identity_deleted;
        public PersonDeleteStatusReason person_delete_status_reason;
        public PersonTitle person_title;
        public PersonGivenName person_given_name;
        public PersonFamilyName person_family_name;
        public String language_code;
        public OccupationTitleCode occupation_title_code;
        public String primary_email_address;
        public String externaluserstate;
        public String externaluserstatechangedatetime;
    }
    
    public class PersonElectronicAddresses{
        public List<PersonElectronicAddress> person_electronic_address;
    }
    
    public class PersonElectronicAddress{
        public String electronic_addr_type_code;
        public String electronic_address;
        public String isnull_indicator;
    }
    
    public class PersonEngagement{
        public List<Engagement> engagement;
    }
    
    public class Engagement{
    	public String engg_code;
        public String engg_name;
        public String engg_status_code;
        public String effective_tier_code;
        public Map<String,String> effective_end_dtm;
    }
    
    public class PersonAttribute{
        public Attribute attribute;
    }
    
    public class Attribute{
        public Map<String,String> profession_code;
    }
    
    public class PersonPhysicalAddress{
        public List<PhysicalAddress> physical_address;
    }
    
    public class PhysicalAddress{
        public String address_usg_type_code;
        public String isnull_indicator;
        public Map<String,String> address_line1_text;
        public Map<String,String> address_line2_text;
        public Map<String,String> address_line3_text;
        public Map<String,String> address_line4_text;
        public Map<String,String> city_name;
        public Map<String,String> state_code;
        public Map<String,String> postal_code;
        public String iso_country_code; 
    }
    
    public class PersonSubscription{
        public List<Subscription> subscription;
    }
    
    public class Subscription{
        public String subscription_code;
        public String subscription_statuscode;
        public String engg_code;
    }
    
    
    public class Enterprise{
        public string text;
    }
    
    public class IdentityStatus{
        public string text;
    }
    
    public class ExternalLoginId{
        public string text;
    }
    
    public class PersonIdentityDeleted{
        public string text;
    }
    
    public class PersonDeleteStatusReason{
        public string text;
    }
    
    public class PersonTitle{
        public string text;
    }
    
    public class PersonGivenName{
        public string text;
    }
    
    public class PersonFamilyName{
        public string text;
    }
    
    public class OccupationTitleCode{
        public string text;
    }
    
    // Utility method to deserialize JSON
    public static Core_IntegrationMessageJSONParsing parseJSON(String jsonString) {
        return (Core_IntegrationMessageJSONParsing) JSON.deserialize(jsonString, Core_IntegrationMessageJSONParsing.class);
    }
    
    public static Core_IntegrationUtility.ERPM_Person mapJSON(){
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'personJsonHardcoded' LIMIT 1];
        String jsonString = sr.Body.toString();//.replace('"person-id":','"person_id":').replace('"person-information":', '"person_information":');
        Core_IntegrationMessageJSONParsing parsedJSON = parseJSON(jsonString);
        //System.debug(parsedJSON.person.person_accounts);
        
        if(parsedJSON.Person != Null ){
            Core_IntegrationUtility.ERPM_Person p = new Core_IntegrationUtility.ERPM_Person();
            p.inactIndicator = parsedJSON.Person.inact_indicator;
            p.isDeleteIndicator = parsedJSON.Person.is_delete_indicator;
            p.changeAgentId = parsedJSON.Person.change_agt_id;
            p.publishTimestamp = parsedJSON.Person.publish_timestamp != ''? Core_IntegrationUtility.convertERPMDatetimeStringToDatetime(parsedJSON.Person.publish_timestamp) : Null;
            p.erpmPersonId     = parsedJSON.Person.person_information.person_id;
            p.enterpriseId     = parsedJSON.Person.person_information.enterprise_id.text;
            p.identityStatus   = parsedJSON.Person.person_information.identity_status.text;
            p.isIdentityDeleted = parsedJSON.Person.person_information.person_is_identity_deleted?.text;
            p.deleteStatusReason = parsedJSON.Person.person_information.person_delete_status_reason?.text;
            p.loginId          = parsedJSON.Person.person_information.external_login_id.text;
            p.title            = parsedJSON.Person.person_information.person_title.text;
            p.firstName        = parsedJSON.Person.person_information.person_given_name.text;
            p.lastName         = parsedJSON.Person.person_information.person_family_name.text;
            p.erpmLanguageCode = parsedJSON.Person.person_information.language_code;
            p.jobFunctionCode  = parsedJSON.Person.person_information.occupation_title_code.text;
            p.externalUserState = parsedJSON.Person.person_information.externaluserstate;
            p.externalStateChange = parsedJSON.Person.person_information.externaluserstatechangedatetime;
            p.email = parsedJSON.Person.person_information.primary_email_address.toLowerCase();
            
            //person account details section
            if(!parsedJSON.Person.person_accounts.person_account.isEmpty()) {
                for (PersonAccount pacc : parsedJSON.Person.person_accounts.person_account) {
                    p.personAccounts.add(parsePersonAccounts(pacc));
                }
            }
            
            //person electronic address details section
            if(!parsedJSON.Person.person_electronic_addresses.person_electronic_address.IsEmpty()){
                for (PersonElectronicAddress pea : parsedJSON.Person.person_electronic_addresses.person_electronic_address) {
                    if(pea.isnull_indicator != 'Y'){
                        if (pea.electronic_addr_type_code == 'FAX'){
                            p.fax = pea.electronic_address;
                        }else if (pea.electronic_addr_type_code == 'PHONE'){
                            p.phone = pea.electronic_address;
                        }else if (pea.electronic_addr_type_code == 'MOB'){
                            p.mobilePhone = pea.electronic_address;
                        }
                    }
                }
            }
            
            //person engagemtn details section
            if(!parsedJSON.Person.person_engagements.engagement.isEmpty()) {
                for (Engagement e : parsedJSON.Person.person_engagements.engagement) {
                    p.personEngagements.add(parsePersonEngagement(e));
                }
            }  
            
            //person attribute details section
            p.Profession.Professioncode = parsedJSON.Person.person_attributes.attribute?.profession_code?.get('text');
            
            //person physical address details section
            for (PhysicalAddress pa : parsedJSON.Person.person_physical_addresses.physical_address) {
                if (pa.address_usg_type_code == 'MAIL' && pa.isnull_indicator != 'Y') {
                    p.mailingStreet1 = pa.address_line1_text?.get('text');
                    p.mailingStreet2 = pa.address_line2_text?.get('text');
                    p.mailingStreet3 = pa.address_line3_text?.get('text');
                    p.mailingStreet4 = pa.address_line4_text?.get('text');
                    p.mailingCity = pa.city_name.get('text');
                    p.mailingState = pa.state_code.get('text');
                    p.mailingCountry = pa.iso_country_code;
                    p.mailingPostalCode = pa.postal_code.get('text');
                    break;
                }
            }
            
            //person subscrition details section
            if (!parsedJSON.Person.person_subscription.subscription.isEmpty()) {
                for(Subscription sc : parsedJSON.Person.person_subscription.subscription) {
                    p.eRPM_Subscriptions.add(parsePersonSubscription(sc));
                }
            }
            return p;
        }
        return Null;  
    }
    
    public static Core_IntegrationUtility.ERPM_Person_Account parsePersonAccounts(PersonAccount pacc){
        Core_IntegrationUtility.ERPM_Person_Account pa;
        if(pacc.inact_indicator == 'N'){
            pa = new Core_IntegrationUtility.ERPM_Person_Account();
            pa.erpmAccountNumber = pacc.account_number;
            pa.cimId = pacc.cim_id.get('text');
            pa.acctSalesCloudID =pacc.salescloud_id;
            pa.accountName = pacc.account_name;
            pa.erpmDedupGroupCode = pacc.engg_dedup_grp_cd.get('text');
            if(pacc.person_account_relation != Null) {
                for(PersonAccountRelation par : pacc.person_account_relation) {
                    Core_IntegrationUtility.ERPM_Person_Account_Relation relation = new Core_IntegrationUtility.ERPM_Person_Account_Relation();
                    relation.engagementCode = par.engagement_code;
                    relation.relationCode = par.relation_code;
                    relation.relationName = par.relation_name;
                    relation.inactiveIndicator = par.inact_indicator =='N' ? false : true;
                    pa.personAccountRelations.add(relation);
                }
            }
        }
        return pa;
    }
    
     public static Core_IntegrationUtility.ERPM_Engagement parsePersonEngagement(Engagement e) {

        Core_IntegrationUtility.ERPM_Engagement pe = new Core_IntegrationUtility.ERPM_Engagement();

        pe.engagementCode = e.engg_code;
        pe.engagementName = e.engg_name;
        pe.engagementStatusCode = e.engg_status_code;
        pe.effectiveTierCode = e.effective_tier_code;
        pe.effEndEngagmentDate = e.effective_end_dtm.get('isnull_indicator');
        return pe;
    }
    
    public static Core_IntegrationUtility.eRPM_Subscription parsePersonSubscription(Subscription sc) {
        Core_IntegrationUtility.eRPM_Subscription subscription = new Core_IntegrationUtility.eRPM_Subscription();
        subscription.eRPM_EngagementCode = sc.engg_code;      
        subscription.eRPM_SubscriptionCode = sc.subscription_code;                       
        subscription.eRPM_SubscriptionStatusCode = sc.subscription_statuscode == 'USER-SUB' ?'Active' : 'Inactive';
        return subscription;
    }
}