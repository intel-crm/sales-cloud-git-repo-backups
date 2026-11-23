/**************************************************************************************
Apex Class Name:  Core_XMLSAPAccountParserHandler 
Version     : 1.0 
Created Date: 25 March 2021
Function    : Parse the raw xml response from SAP
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kavyashree HR            03/25/2021              Original Version

*************************************************************************************/
public class Core_XMLSAPAccountParserHandler {    
    public static List<Account> listAccnt ;
    public static RecordType recType;
    public static List<Core_Account_SoldTo_ShipTo_Rel__c> listAccSoldToShipTo;
    public static String soldToAccId;
    public static Boolean IsSoldTo = False;
    public static List<Account> parseXMLnReturn(ContentVersion conVersion){
         finalWrapper fwrp = new finalWrapper();
         SalesforceCustomer sfCust;
         //String xmltest = '<?xml version="1.0" encoding="UTF-8"?><RandomTag><SiebelMessage><ListOfPsgSfdcAccountInterface><SfdcAccountInterfaceBc><Name>AADL - ASIA PD</Name><SFDC_ID>0012D00000Ok5bw</SFDC_ID><CIM_ID>13909741</CIM_ID><ExportComplianceBlock>false</ExportComplianceBlock><AccountTier>PSG-Tier 4</AccountTier><PartnerProgram>PSG Demand Creation - Distribution</PartnerProgram><MilitaryAerospaceGovernmentIndicator>false</MilitaryAerospaceGovernmentIndicator><ListOfCutAddressEaiAltera><CutAddressEaiAltera><BillingCity>Kwai Chung</BillingCity><BillingCountryCode>HKG</BillingCountryCode><BillingPostalCode>99999</BillingPostalCode><BillingStateCode></BillingStateCode><BillingStreet>20/f Tower 2 Evergain Plaza 88 8 Container Port Rd</BillingStreet></CutAddressEaiAltera></ListOfCutAddressEaiAltera></SfdcAccountInterfaceBc></ListOfPsgSfdcAccountInterface></SiebelMessage></RandomTag>';
         String xmlInput = EncodingUtil.base64Decode(EncodingUtil.base64Encode(conVersion.VersionData)).toString();
         //String xmlInput = EncodingUtil.base64Decode(EncodingUtil.base64Encode(xmltest)).toString();
         Dom.Document myXml = new Dom.Document();
         myXml.load(xmlInput);


         for(Dom.XmlNode node :myXml.getRootElement().getChildElements()){
             System.debug('Node* '+node);
             if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.SIEMSG)){
                 System.debug('#G:Node');
                System.debug('node.gettname* '+node.getName());
                sfCust = new SalesforceCustomer();
                sfCust.process(node);
                fwrp.salesforCust = sfCust;
            }        
         }
         System.debug('final Wrap '+fwrp);
        return listAccnt;
     }
     
     public class ListOfAccountEaiAltera{    
        //private string nodeName;
        //define the child tags of ListOfPsgSfdcAccountInterface.
        public List<AccountEaiAltera> listSfdcAccInt;
        
        //constructor
        public ListOfAccountEaiAltera(){
            listSfdcAccInt = new List<AccountEaiAltera>();
        }
        
        public void process(Dom.XmlNode inputNode){
        listAccnt = new List<Account>();        
        recType = [SELECT Id, DeveloperName FROM Recordtype WHERE DeveloperName = 'Core_Direct_Account'];
            for(Dom.XmlNode node :inputNode.getChildElements()){
                System.debug('ListPSG Node* '+node.getName());
                if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.ACCEAI)){
                    AccountEaiAltera accEaiAltera = new AccountEaiAltera();
                    accEaiAltera.process(node);
                    Account acc = new Account();
                    acc.ParentId = accEaiAltera.TrainStationId;
                    acc.Name = accEaiAltera.Name;
                    acc.Core_Direct_Account_Id__c = accEaiAltera.SAPAccountNumber;
                    acc.Core_Direct_Incoterm_Dsc__c = accEaiAltera.FreightTerms;
                    acc.Core_CIM_ID__c = accEaiAltera.Type;
                    acc.Core_Direct_Payment_Term_Nm__c = accEaiAltera.X_ALT_PAYTERMS;
                    acc.Core_Direct_Account_Type_Nm__c = accEaiAltera.X_ALT_SAP_ACCT_TYPE;
                    acc.Core_Direct_Shipping_Condition_Nm__c = accEaiAltera.ShippingCondition;
                    acc.BillingStreet = accEaiAltera.StreetAddress+' '+accEaiAltera.StreetAddress2;
                    acc.BillingCity = accEaiAltera.City;
                    acc.BillingState = accEaiAltera.Province;
                    acc.BillingStateCode = accEaiAltera.State;
                    acc.BillingCountry = accEaiAltera.Country;
                    acc.BillingPostalCode = accEaiAltera.PostalCode;
                    acc.Core_Geo__c = accEaiAltera.RegionCode;
                    acc.Core_Direct_Sales_Organization_Nm__c = accEaiAltera.SalesOrganization;
                    acc.Core_Direct_Distributor_Channel_Nm__c = accEaiAltera.DistyChannel;
                    acc.Core_Direct_Ship_To_End_Customer_Id__c = accEaiAltera.ShipToEndCustomer;
                    //acc.RecordtypeId = '0122D000001MhgLQAS';
                    acc.RecordtypeId = recType.Id;
                    acc.Core_Is_Pricing_Parent_ChkBox__c = Boolean.valueOf(accEaiAltera.IsPricingParent);
                    acc.Core_Direct_Account_Active_Ind__c = True;
                    listAccnt.add(acc);                    
                    System.debug('ListPSG sfdcAcc* '+acc.RecordtypeId);                    
                }
            }
            insert listAccnt;
            if(listAccnt[0].Core_Direct_Account_Type_Nm__c == 'Sold To'){
                soldToAccId = listAccnt[0].Id;   
                IsSoldTo = True;        
            }
         }
     }
     
     public class AccountEaiAltera{
         public String TrainStationId;
         public String Name;
         public String SAPAccountNumber;
         public String FreightTerms;
         public String Type;
         public String X_ALT_PAYTERMS;
         public String X_ALT_SAP_ACCT_TYPE;
         public String ShippingCondition;
         public String StreetAddress;
         public String StreetAddress2;
         public String City;
         public String Province;
         public String State;
         public String Country;
         public String PostalCode;
         public String RegionCode;
         public String SalesOrganization;
         public String DistyChannel;
         public String ShipToEndCustomer;
         public String IndustryCode1;
         public String IsPricingParent;
         public Shipto_Partners shipToPart;
         
         public AccountEaiAltera(){
            TrainStationId = null;
            Name = null;
            SAPAccountNumber = null;
            FreightTerms = null;
            Type = null;
            X_ALT_PAYTERMS = null;
            X_ALT_SAP_ACCT_TYPE = null;
            ShippingCondition = null;
            StreetAddress = null;
            StreetAddress2 = null;
            City = null;
            Province = null;
            State = null;
            Country = null;
            PostalCode = null;
            RegionCode = null;
            SalesOrganization = null;
            DistyChannel = null;
            ShipToEndCustomer = null;
            IndustryCode1 = null;
            IsPricingParent = null;
            shipToPart = new Shipto_Partners();
        }
        
        
        public void process(Dom.XmlNode inputNode){
            listAccSoldToShipTo = new List<Core_Account_SoldTo_ShipTo_Rel__c>();    
            for(Dom.XmlNode node :inputNode.getChildElements()){
                System.debug('ListCut * '+node);
                if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.TRAINSTATION)){
                    if(node.getText()!='' || node.getText() != null){
                        TrainStationId= node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.NAM)){
                    if(node.getText()!='' || node.getText() != null){
                        Name = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.SAPACCNUM)){
                    if(node.getText()!='' || node.getText() != null){
                        SAPAccountNumber = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.FREIGT)){
                    if(node.getText()!='' || node.getText() != null){
                        FreightTerms = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.TYPE)){
                    if(node.getText()!='' || node.getText() != null){
                        Type = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.XALTPAYTERM)){
                    if(node.getText()!='' || node.getText() != null){
                        X_ALT_PAYTERMS = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.XALTSAPACCTYPE)){
                    if(node.getText()!='' || node.getText() != null){
                        X_ALT_SAP_ACCT_TYPE = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.SHIPPINGCOND)){
                    if(node.getText()!='' || node.getText() != null){
                        ShippingCondition = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.STREETADD)){
                    if(node.getText()!='' || node.getText() != null){
                        StreetAddress = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.STREETADD2)){
                    if(node.getText()!='' || node.getText() != null){
                        StreetAddress2 = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.CITY)){
                    if(node.getText()!='' || node.getText() != null){
                        City = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.PROVIN)){
                    if(node.getText()!='' || node.getText() != null){
                        Province = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.STATE)){
                    if(node.getText()!='' || node.getText() != null){
                        State = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.COUNTRY)){
                    if(node.getText()!='' || node.getText() != null){
                        Country = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.POSTCODE)){
                    if(node.getText()!='' || node.getText() != null){
                        PostalCode = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.REGIONCODE)){
                    if(node.getText()!='' || node.getText() != null){
                        RegionCode = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.SALESORG)){
                    if(node.getText()!='' || node.getText() != null){
                        SalesOrganization = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.DISTYCHA)){
                    if(node.getText()!='' || node.getText() != null){
                        DistyChannel = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.SHIPTOENDCUST)){
                    if(node.getText()!='' || node.getText() != null){
                        ShipToEndCustomer = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.ISPRICINGPAR)){
                    if(node.getText()!='' || node.getText() != null){
                        IsPricingParent = node.getText();
                        
                    }
                } 
                
               else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.SHIPTOEXSTATIONID)){
                   // if(node.getText()!='' || node.getText() != null){
                   //     shipToPart.process(node);                       
                   // }
                   if(IsSoldTo = True){
                       Shipto_Partners shipToPartner = new Shipto_Partners();
                       shipToPartner.process(node);
                       Core_Account_SoldTo_ShipTo_Rel__c accSoldToShipTo = new Core_Account_SoldTo_ShipTo_Rel__c();
                       accSoldToShipTo.Core_Ship_To_Account__c = shipToPartner.ShiptoExpressStationID;
                       accSoldToShipTo.Core_Sold_To_Account__c = soldToAccId;
                   }
                }                
                
            }
        }
     
     }
     
     
     public class Shipto_Partners{    
        public String Shipto;
        public String ShiptoExpressStationID;
        
        //constructor
        public Shipto_Partners(){
            Shipto = null;
            ShiptoExpressStationID = null;
        }
        
        public void process(Dom.XmlNode inputNode){
            //listAccSoldToShipTo = new List<Core_Account_SoldTo_ShipTo_Rel__c>();
            for(Dom.XmlNode node :inputNode.getChildElements()){
                System.debug('ListCut * '+node);
                if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.SHIPTO)){
                    if(node.getText()!='' || node.getText() != null){
                        Shipto= node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.SHIPTOEXSTATIONID)){
                    if(node.getText()!='' || node.getText() != null){
                        ShiptoExpressStationID = node.getText();
                     }
                }
            }
        }
     
     }
     
     
     public class SalesforceCustomer{
    
        //define the child tags of Siebel Message.
        public ListOfAccountEaiAltera lstAccEai;
        
        
        //constructor
        public SalesforceCustomer(){
           lstAccEai = new ListOfAccountEaiAltera();
            
        }
        
        public void process(Dom.XmlNode inputNode){
            for(Dom.XmlNode node :inputNode.getChildElements()){
                if(node.getName().equalsIgnoreCase(Core_SAPConstantUtility.LSTACC )){
                    if(node.getText()!='' || node.getText() != null){
                        lstAccEai.process(node);                       
                    }
                }                                
            }
        }        
    } 
     
     public class finalWrapper{
        public SalesforceCustomer salesforCust;
        public finalWrapper(){
            salesforCust = null;        
        }
    }
}