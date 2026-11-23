/*********************************************************************************************************************
Apex Class Name  : PCC_Constants
Version       : 1.0
Created Date  : May 2023
Function      : Utility class to store common keywords related to PCC

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Sushmita                  22/05/2023               Utility class to store common keywords related to PCC

*********************************************************************************************************************/
public class PCC_Constants {
    public static final String CALLOUT_TYPE_OUTBOUND = 'Outbound';
    public static final String CALLOUT_TYPE_INBOUND = 'Inbound';
    public static final String MODULE_DDR_REGISTRATION = 'DDR Registration';
    public static final String SYSTEM_NAME_AGS = 'AGS';
    public static final String SYSTEM_NAME_M2M = 'M2M';
    public static final String SYSTEM_NAME_Collinsion = 'Collinsion';
    public static Map<String, String> drProductApiToLabelMap = new Map<String, String>{'Core_Design_Registration_Id__c'=> 'designRegistration',
        'Core_Product_Id__c' => 'productId',
        'Core_Full_Year_Qty__c' => 'quantity',
        'Core_External_Id__c' => 'externalId',
        'Core_Design_Product_Status_Nm__c'=> 'status',
        'Core_Retired_As_Of_Dt__c'=>'retiredAsOf',
        'Core_Design_Registration_Id__c'=> 'designRegistration',
        'Core_Product_Group_Nm__c' => 'productGroup',
        'Core_Military_Aerospace_Gvrnmt_Use_Ind__c' => 'militaryAerospaceGvrnmtUseInd',
        'Core_Vertical_Market_Nm__c' => 'verticalMarket',
        'Core_Product_Segment_Nm__c'=> 'productSegment',
        'Core_Product_Application_Nm__c'=>'productApplication',
        'Core_Partner_FAE_Nm__c' => 'partnerFAE',
        'Core_End_Customer_Nm__c' => 'endCustomerName',
        'Core_End_Customer_Street_Addr_Line1_Txt__c' => 'endCustomerAddress1',
        'Core_End_Customer_Postal_Cd__c' => 'endCustomerPostalCode',
        'Core_End_Customer_Country_Nm__c' => 'endCustomerCountry',
        'Core_Intel_Platform_Nm__c' => 'intelPlatform',
        'Core_Opportunity_Volume_Cnt__c' => 'opportunityVolume',
        'Core_Opportunity_Decision_Dt__c' => 'designDecisionDate',
        'Core_First_Customer_Ship_Dt__c' => 'firstCustomerShipDate',
        'Core_Production_End_Dt__c' => 'productionEndDate',
        'Core_Design_Registration_Dsc__c' => 'description',
        'Core_End_Customer_Street_Addr_Line2_Txt__c' => 'endCustomerAddress2',
        'Core_End_Customer_City_Nm__c' => 'endCustomerCity',
        'Core_End_Customer_Country_Subdivision_Nm__c' => 'endCustomerState',
        'Core_End_Customer_Postal_Cd__c' => 'endCustomerZipCode',
        'Core_End_Customer_Contact_Title_Txt__c' => 'endCustomerContactTitle',
        'Core_End_Customer_Contact_Nm__c' => 'endCustomerContactName',
        'Core_End_Customer_Contact_Email_Txt__c' => 'endCustomerContactEmail',
        'Core_End_Customer_Contact_Phone_Txt__c' => 'endCustomerContactPhone',
        'Core_Manufacturing_Region_Cd__c' => 'manufacturingRegion',
        'Core_Design_Registration_Nm__c' => 'designRegistrationName'
        }; 
        public static Map<String, String> drProductLabelToApiMap = new Map<String, String>{'designRegistration'=> 'Core_Design_Registration_Id__c',
        'productId'=>'Core_Product_Id__c',
        'quantity' => 'Core_Full_Year_Qty__c',
        'externalId' => 'Core_External_Id__c',
        'status' => 'Core_Design_Product_Status_Nm__c',
        'retiredAsOf' => 'Core_Retired_As_Of_Dt__c',
        'designRegistration' => 'Core_Design_Registration_Id__c',
        'productGroup' => 'Core_Product_Group_Nm__c',
        'militaryAerospaceGvrnmtUseInd' => 'Core_Military_Aerospace_Gvrnmt_Use_Ind__c',
        'verticalMarket' => 'Core_Vertical_Market_Nm__c',
        'productSegment' => 'Core_Product_Segment_Nm__c',
        'productApplication' => 'Core_Product_Application_Nm__c',
        'partnerFAE' => 'Core_Partner_FAE_Nm__c',
        'endCustomerName' => 'Core_End_Customer_Nm__c',
        'endCustomerAddress1' => 'Core_End_Customer_Street_Addr_Line1_Txt__c',
        'endCustomerPostalCode' => 'Core_End_Customer_Postal_Cd__c',
        'endCustomerCountry' => 'Core_End_Customer_Country_Nm__c',
        'intelPlatform' => 'Core_Intel_Platform_Nm__c',
        'opportunityVolume' => 'Core_Opportunity_Volume_Cnt__c',
        'designDecisionDate' => 'Core_Opportunity_Decision_Dt__c',
        'firstCustomerShipDate' => 'Core_First_Customer_Ship_Dt__c',
        'description' => 'Core_Design_Registration_Dsc__c',
        'endCustomerAddress2' => 'Core_End_Customer_Street_Addr_Line2_Txt__c',
        'endCustomerCity' => 'Core_End_Customer_City_Nm__c',
        'endCustomerState' => 'Core_End_Customer_Country_Subdivision_Nm__c',
        'endCustomerZipCode' => 'Core_End_Customer_Postal_Cd__c',
        'endCustomerContactTitle' => 'Core_End_Customer_Contact_Title_Txt__c',
        'endCustomerContactName' => 'Core_End_Customer_Contact_Nm__c',
        'endCustomerContactEmail' => 'Core_End_Customer_Contact_Email_Txt__c',
        'endCustomerContactPhone' => 'Core_End_Customer_Contact_Phone_Txt__c',
        'manufacturingRegion' => 'Core_Manufacturing_Region_Cd__c',
        'designRegistrationName' => 'Core_Design_Registration_Nm__c',
        'partnerFAEEmail' => 'DDR_Partner_FAE_Email__c'   
        }; 
 }