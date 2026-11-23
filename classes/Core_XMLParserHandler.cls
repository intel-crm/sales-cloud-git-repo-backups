/**************************************************************************************
Apex Class Name:  Core_XMLParserHandler 
Version     : 1.0 
Created Date: 21 May 2020
Function    : Parse the raw xml response from CIM
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             05/21/2020              Original Version

*************************************************************************************/
public class Core_XMLParserHandler {
    
    public static finalWrapper parseXMLnReturn(ContentVersion conVersion, String nodeName, finalWrapper fWrp){
        Header hdr;
        Snapshot snp;
        SourceRecords srs;
        MergeBusinessOrganization mergebo;
        String xmlInput = EncodingUtil.base64Decode(EncodingUtil.base64Encode(conVersion.VersionData)).toString();
        Dom.Document myXml = new Dom.Document();
        myXml.load(xmlInput);
        
        // We'll basically be re-using the general structure of this loop throughout
        //    the parsing logic for the inner classes.
        // Check the node name, create an appropriate instance of an inner class,
        //    and then pass the responsibility to parse the current node 
        //    to that inner class.
        
        //boolean processAllLogic= true; // boolean check to know when to parse the xml. Dont Parse if the msgtype is DELETE.
        for(Dom.XmlNode node :myXml.getRootElement().getChildElements()){
            system.debug('nodename-->'+node.getName());
            if(nodeName.equalsIgnoreCase(Core_ConstantUtility.SRS) && fWrp.sourceRecordWr == null && node.getName().equalsIgnoreCase(Core_ConstantUtility.SRS)){
                srs = new SourceRecords();
                srs.process(node);
                fWrp.sourceRecordWr = srs;
                break;
            }
            if(nodeName.equalsIgnoreCase(Core_ConstantUtility.SNP) && fWrp.snpWr == null && node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP)){
                snp= new Snapshot(Core_ConstantUtility.ALL_TAG);
                snp.process(node);
                fWrp.snpWr = snp;
                break;
            }
            if(nodeName.equalsIgnoreCase(Core_ConstantUtility.HDR) && fWrp.headwr == null && node.getName().equalsIgnoreCase(Core_ConstantUtility.HDR)){
                hdr = new Header();
                hdr.process(node);
                fWrp.headwr = hdr;
                break;
            }
            if(nodeName.equalsIgnoreCase(Core_ConstantUtility.MERGEBO) && fWrp.mbWr == null && node.getName().equalsIgnoreCase(Core_ConstantUtility.MERGEBO)){
                mergebo = new MergeBusinessOrganization();
                mergebo.process(node);
                fWrp.mbWr = mergebo;
                break;
            }
        }
        
        return fWrp;
    }
    
    public static String getCIM(ContentVersion conVersion){
        String CIM = null;
        String xmlInput = EncodingUtil.base64Decode(EncodingUtil.base64Encode(conVersion.VersionData)).toString();
        system.debug('xmlInput');
        Dom.Document myXml = new Dom.Document();
        myXml.load(xmlInput);
        system.debug('myXml.getRootElement().getChildElements() '+myXml.getRootElement().getChildElements());
        for(Dom.XmlNode node :myXml.getRootElement().getChildElements()){
            if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP)){
                Snapshot snp = new Snapshot(Core_ConstantUtility.SNP_BUS_ORG);
                snp.process(node);
                CIM = snp.bo.BusinessOrganizationPartyId;
                break;
            }
        }
        return CIM;
    }
    
    //Header Tag Inner Class
    public class Header{
    
        //define the child tags of Header.
        //String MsgSource;
        public String MsgId;
        public String MsgType;
        public String EventType;
        //String MsgVersion;
        
        //constructor
        public Header(){
            MsgId = null;
            MsgType = null;
            EventType = null;
        }
        
        public void process(Dom.XmlNode inputNode){
            for(Dom.XmlNode node :inputNode.getChildElements()){
                if(node.getName().equalsIgnoreCase(Core_ConstantUtility.HDR_MSGTYPE )){
                    if(node.getText()!='' || node.getText() != null){
                        MsgType = node.getText();
                        
                    }
                }
                
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.HDR_MSGID )){
                    if(node.getText()!='' || node.getText() != null){
                        MsgId= node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.HDR_EVTTYPE )){
                    if(node.getText()!='' || node.getText() != null){
                        EventType = node.getText();
                        
                    }
                }
            }
        }
        
    } 
    
    
    //Snapshot Tag Inner Class
    public class Snapshot{
    
        private string nodeName;
        //define the child tags of Snapshot.
        public BusinessOrganization bo;
        public PhysicalAddress pa;
        public BusinessOrganizationNm bonm;
        public list<ElectronicAddress> eleAdd;
        public list<BusinessOrganizationThirdPartyWatchList> botpwlList;
        public BusinessOrganizationGoldStatusAssociation boga;
        
        //constructor
        public Snapshot(String nodeName){
            this.nodeName = nodeName;
            bo = new BusinessOrganization();
            pa = new PhysicalAddress();
            bonm = new BusinessOrganizationNm();
            eleAdd = new list<ElectronicAddress>();
            botpwlList = new list<BusinessOrganizationThirdPartyWatchList>();
            boga = new BusinessOrganizationGoldStatusAssociation();
        }
        
        public void process(Dom.XmlNode inputNode){
            for(Dom.XmlNode node :inputNode.getChildElements()){
                if((nodeName.equalsIgnoreCase(Core_ConstantUtility.SNP_BUS_ORG) || nodeName.equalsIgnoreCase(Core_ConstantUtility.ALL_TAG)) && node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_BUS_ORG )){
                    bo.process(node);
                }
                else if((nodeName.equalsIgnoreCase(Core_ConstantUtility.SNP_PHY_ADDRESS) || nodeName.equalsIgnoreCase(Core_ConstantUtility.ALL_TAG)) && node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_PHY_ADDRESS )){
                    pa.process(node);
                }
                else if((nodeName.equalsIgnoreCase(Core_ConstantUtility.SNP_BUS_ORG_NM) || nodeName.equalsIgnoreCase(Core_ConstantUtility.ALL_TAG)) && node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_BUS_ORG_NM )){
                    bonm.process(node);
                }
                else if((nodeName.equalsIgnoreCase(Core_ConstantUtility.SNP_ELEC_ADDRESS) || nodeName.equalsIgnoreCase(Core_ConstantUtility.ALL_TAG)) && node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_ELEC_ADDRESS )){
                    ElectronicAddress ea = new ElectronicAddress();
                    ea.process(node);
                    eleAdd.add(ea);
                }
                else if((nodeName.equalsIgnoreCase(Core_ConstantUtility.SNP_BUS_ORG_THIRDPARTY_WATCHLIST) || nodeName.equalsIgnoreCase(Core_ConstantUtility.ALL_TAG)) && node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_BUS_ORG_THIRDPARTY_WATCHLIST)){
                    BusinessOrganizationThirdPartyWatchList botpwl = new BusinessOrganizationThirdPartyWatchList();
                    botpwl.process(node);
                    botpwlList.add(botpwl);
                }
                else if((nodeName.equalsIgnoreCase(Core_ConstantUtility.SNP_BUS_ORG_GOLD_STATUS_ASSOC) || nodeName.equalsIgnoreCase(Core_ConstantUtility.ALL_TAG)) && node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_BUS_ORG_GOLD_STATUS_ASSOC)){
                    boga.process(node);
                }
            }
        }
        
    }  
    
    //BusinessOrganization Tag Inner Class
    public class BusinessOrganization{
        
        //define the child tags of BusinessOrganization.
        public String BusinessOrganizationPartyId;
        public String BusinessOrganizationClassificationCd;
        public String DUNSNumber;
        
        //constructor
        public BusinessOrganization(){
            BusinessOrganizationPartyId = null;
            BusinessOrganizationClassificationCd = null;
            DUNSNumber = null;
        }

        public void process(Dom.XmlNode inputNode){
            for(Dom.XmlNode node :inputNode.getChildElements()){
                if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_BUS_ORG_ID )){
                    if(node.getText()!='' || node.getText() != null){
                        BusinessOrganizationPartyId = node.getText();
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_BUS_ORG_CLASSCD )){
                    if(node.getText()!='' || node.getText() != null){
                        BusinessOrganizationClassificationCd = node.getText();
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_DUNSNUMBER )){
                    if(node.getText()!='' || node.getText() != null){
                        DUNSNumber = node.getText();
                    }
                }
            }
        }
    }
    
    
    public class BusinessOrganizationNm{
        public String GoldenNameInd;
        public String NonLatinInd;
        public String BusinessOrganizationNm;
        public String BusinessOrganizationNmTypeCd;
        
        //constructor
        public BusinessOrganizationNm(){
            GoldenNameInd = null;
            NonLatinInd = null;
            BusinessOrganizationNm = null;
            BusinessOrganizationNmTypeCd = null;
        }
        
        public void process(Dom.XmlNode inputNode){
            for(Dom.XmlNode node :inputNode.getChildElements()){
                if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_GOLDEN_NAME_IND )){
                    if(node.getText()!='' || node.getText() != null){
                        GoldenNameInd= node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_NON_LATIN_IND )){
                    if(node.getText()!='' || node.getText() != null){
                        NonLatinInd = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_BUS_ORG_NM )){
                    if(node.getText()!='' || node.getText() != null){
                        BusinessOrganizationNm = node.getText();
                        
                    }
                }
            }
        }
        
    }
    
    
    //PhysicalAddress Tag Inner Class
    public class PhysicalAddress{
        
        //define the child tags of PhysicalAddress.
        public String PhysicalStreetAddressTxt;
        public String CityNm;
        public String CountrySubdivisionCd;
        public String CountrySubdivisionNm;
        public String CountryCd;
        public String CountryNm;
        public String PostalCd;
        public String GoldenPhysicalAddressInd;
        public String NonLatinDataInd;
        //public String EffectiveStartDtm;
        //public PhysicalAddressUsageLocationAssociation phyAddressLoc;
        
        //constructor
        public PhysicalAddress(){
            PhysicalStreetAddressTxt = null;
            CityNm = null;
            CountrySubdivisionCd = null;
            CountrySubdivisionNm = null;
            CountryCd = null;
            CountryNm = null;
            PostalCd = null;
            GoldenPhysicalAddressInd = null;
            NonLatinDataInd = null;
        }
        
        public void process(Dom.XmlNode inputNode){
            for(Dom.XmlNode node :inputNode.getChildElements()){
                if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_STREET )){
                    if(node.getText()!='' || node.getText() != null){
                        PhysicalStreetAddressTxt = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_CITY )){
                    if(node.getText() != null){
                        CityNm = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_STATE_NM )){
                    if(node.getText()!='' || node.getText() != null){
                        CountrySubdivisionNm = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_STATE )){
                    if(node.getText()!='' || node.getText() != null){
                        CountrySubdivisionCd = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_COUNTRY_NM )){
                    if(node.getText()!='' || node.getText() != null){
                        CountryNm = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_COUNTRY )){
                    if(node.getText()!='' || node.getText() != null){
                        CountryCd = node.getText();
                        
                    }
                }
                
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_POSTAL )){
                    if(node.getText()!='' || node.getText() != null){
                        PostalCd = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_GOLDEN_PHY_ADR_IND )){
                    if(node.getText()!='' || node.getText() != null){
                        GoldenPhysicalAddressInd = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_NON_LATIN_DATA_IND )){
                    if(node.getText()!='' || node.getText() != null){
                        NonLatinDataInd = node.getText();
                        
                    }
                }
                
            }
        }
    }
    
    
    public class ElectronicAddress{
    
        public String ElectronicAddressTypeCd;
        public String ElectronicAddressTxt;
        
        public ElectronicAddress(){
            ElectronicAddressTypeCd = null;
            ElectronicAddressTxt = null;
        }
        
        public void process(Dom.XmlNode inputNode){
            for(Dom.XmlNode node :inputNode.getChildElements()){
                if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_ELEC_ADR_CD )){
                    if(node.getText()!='' || node.getText() != null){
                        ElectronicAddressTypeCd= node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_ELEC_ADR_TXT )){
                    if(node.getText()!='' || node.getText() != null){
                        ElectronicAddressTxt= node.getText();
                        
                    }
                }
                
            }
        }
    }
    
    public class BusinessOrganizationThirdPartyWatchList{
        
        public string WatchListTypeCd;
        public string WatchListTypeNm;
        
        public BusinessOrganizationThirdPartyWatchList(){
            WatchListTypeCd = null;
            WatchListTypeNm = null;
        }
        public void process(Dom.XmlNode inputNode){
            for(Dom.XmlNode node :inputNode.getChildElements()){
                if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_WATCHLIST_TYPE_CD)){
                    if(node.getText() != null){
                        WatchListTypeCd = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_WATCHLIST_TYPE_NAME)){
                    if( node.getText() != null){
                        WatchListTypeNm = node.getText();
                        
                    }
                }
                
            }
        }
    }
    
    
    public class MergeBusinessOrganization{
        public string SurvivorBusinessOrganizationPartyId;
        public string NonSurvivorBusinessOrganizationPartyId;
        
        public MergeBusinessOrganization(){
            SurvivorBusinessOrganizationPartyId = null;
            NonSurvivorBusinessOrganizationPartyId = null;
        }
        
        public void process(Dom.XmlNode inputNode){
            for(Dom.XmlNode node :inputNode.getChildElements()){
                if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SURVIVORID )){
                    if(node.getText()!='' || node.getText() != null){
                        SurvivorBusinessOrganizationPartyId= node.getText();
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.NONSURVIVORID)){
                    if(node.getText()!='' || node.getText() != null){
                        NonSurvivorBusinessOrganizationPartyId= node.getText();
                    }
                }
            }
        }
    }
    
    public class BusinessOrganizationGoldStatusAssociation{
        public string GoldProcessStatusApprovalStatusCd;
        
        //constructor
        public BusinessOrganizationGoldStatusAssociation(){
            GoldProcessStatusApprovalStatusCd = null;
        }
        
        public void process(Dom.XmlNode inputNode){
            for(Dom.XmlNode node :inputNode.getChildElements()){
                if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SNP_GOLDSTATUS_APPROVAL_CD)){
                    if(node.getText()!='' || node.getText() != null){
                        GoldProcessStatusApprovalStatusCd= node.getText();
                    }
                }
            }
        }
    }

    public Class SourceRecords{
    
        //define the child tags of SourceRecords.
        public List<SourceRecord> SourceRecord;
        
        
        //constructor
        public SourceRecords(){
            SourceRecord = new List<SourceRecord>();
        }

        // Having all of the child classes implement a 'process' method
        //    makes it easier to break up the parsing into small, well-defined
        //    chunks.
        // This causes our parsing to be recursive.

        public void process(Dom.XmlNode inputNode){
            
            // This loop should look familiar.
            // The logic has changed a little bit, but it is essentially the
            // same loop as we run in the outer class

            for(Dom.XmlNode node :inputNode.getChildElements()){
                if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SR)){
                    SourceRecord sr = new SourceRecord();
                    sr.process(node);

                    // Since we can run into many 'SourceRecord' nodes, we need
                    //    to add the result to a list after it has finished being parsed.
                    SourceRecord.add(sr);
                }
            }
        }
    }
    public class SourceRecord{
    
        //define the child tags of SourceRecord.
        public String SourceSystemCd;
        public SourceBusinessOrganization sbo;
        public SourceBusinessOrganizationNm sbonm;
        public SourceBusinessOrganizationEngagementGroupAssociation dedup;
        public SourceBusinessOrganizationSIC sboSIC;
        public PhysicalAddress pa;
       
        //constructor
        public SourceRecord(){
            SourceSystemCd = null;
            sbo = new SourceBusinessOrganization();
            sbonm = new SourceBusinessOrganizationNm();
            dedup = new SourceBusinessOrganizationEngagementGroupAssociation();
            pa = new PhysicalAddress();
            sboSIC = new SourceBusinessOrganizationSIC();
        }

        public void process(Dom.XmlNode inputNode){
            
            
            // More of the same general loop.
            // Dom.XmlNode.getText() is what you use to get at the value inside
            //   an XML node. It always returns a string, so you'll need to type-cast
            //   the result if you expect an Integer, Boolean, etc...
            Boolean check= false;
            Boolean checkERPM = false;
            Boolean checkSLSCLD = false;
            Boolean checkCIMHUB = false;
            
            for(Dom.XmlNode node :inputNode.getChildElements()){
                if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SR_SYSTEMCD)){
                    if( node.getText().equalsIgnoreCase(Core_ConstantUtility.SR_ERPM) || node.getText().equalsIgnoreCase(Core_ConstantUtility.SR_SLSCLD) || node.getText().equalsIgnoreCase(Core_ConstantUtility.SR_CIMHUB) || node.getText().equalsIgnoreCase(Core_ConstantUtility.SR_BVD)){
                        if(node.getText() != null ){
                            SourceSystemCd = node.getText();
                            check = true;
                        }
                    }
                } 
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SR_BUS_ORG ) && check){
                    //SourceBusinessOrganization sboObj= new SourceBusinessOrganization();
                    sbo.process(node);
                    //ERPM.add(sbo);
                    //books.add(singleBook);
                }
                
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SR_BUS_ORG_NM ) && check){
                    //SourceBusinessOrganization sboObj= new SourceBusinessOrganization();
                    sbonm.process(node);
                    //SLSCLD.add(sbo);
                    //books.add(singleBook);
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SR_PHY_ADDRESS ) && check){
                    //SourceBusinessOrganization sboObj= new SourceBusinessOrganization();
                    pa = new PhysicalAddress();
                    pa.process(node);
                    //books.add(singleBook);
                }
                //else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SR_PHY_ADDRESS ) && check){
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SR_BUS_ORG_DEDUPGRP_ASSOC) && check){
                    dedup.process(node);
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SR_BUSORG_SIC) && check){
                    sboSIC.process(node);
                }
            }
        }
    }

    public class SourceBusinessOrganization{
        
        //define the child tags of SourceBusinessOrganization.
        Public String id;
        
        //constructor
        public SourceBusinessOrganization(){
            id = null;
        }

        public void process(Dom.XmlNode inputNode){
            
            for(Dom.XmlNode node :inputNode.getChildElements()){
                if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SR_BUS_ORG_ID )){
                    if(node.getText()!='' || node.getText() != null){
                        id = node.getText();
                        
                    }
                }
            }
        }
    }
    
    public class SourceBusinessOrganizationNm{
        //define the child tags of SourceBusinessOrganizationNm.
        public String NonLatinInd;
        public String BusinessOrganizationNm;
        public String BusinessOrganizationNmTypeCd;
        
        //constructor
        public SourceBusinessOrganizationNm(){
            NonLatinInd = null;
            BusinessOrganizationNm = null;
            BusinessOrganizationNmTypeCd = null;
        }
        
        public void process(Dom.XmlNode inputNode){
            for(Dom.XmlNode node :inputNode.getChildElements()){
                if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SR_NON_LATIN_IND )){
                    if(node.getText()!='' || node.getText() != null){
                        NonLatinInd = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SR_BUS_ORG_NM_CHILD )){
                    if(node.getText()!='' || node.getText() != null){
                        BusinessOrganizationNm = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SR_BUS_ORG_NM_TYPECD )){
                    if(node.getText()!='' || node.getText() != null){
                        BusinessOrganizationNmTypeCd = node.getText();
                        
                    }
                }
            }
        }
        
    }
    
    public class SourceBusinessOrganizationEngagementGroupAssociation{
        //define the child tags of SourceBusinessOrganizationNm.
        public String EngagementDeduplicationGroupCd;
        public String ActiveInd;
        
        //constructor
        public SourceBusinessOrganizationEngagementGroupAssociation(){
            EngagementDeduplicationGroupCd = null;
            ActiveInd = null;
        }
        
        public void process(Dom.XmlNode inputNode){
            for(Dom.XmlNode node :inputNode.getChildElements()){
                if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SR_ENGAGEDEDUP_CD)){
                    if(node.getText()!='' || node.getText() != null){
                        EngagementDeduplicationGroupCd = node.getText();
                        
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SR_ACTIVE_IND)){
                    if(node.getText()!='' || node.getText() != null){
                        ActiveInd = node.getText();
                        
                    }
                }
            }
        }
    }
    public class SourceBusinessOrganizationSIC{
        public String IndustrialClassificationPriorityCd;
        public String StandardIndustrialClassificationCd;
        public String StandardIndustrialClassificationDesc;
        
        //constructor
        public SourceBusinessOrganizationSIC(){
            IndustrialClassificationPriorityCd = null;
            StandardIndustrialClassificationCd = null;
            StandardIndustrialClassificationDesc = null;
        }
        public void process(Dom.XmlNode inputNode){
            for(Dom.XmlNode node :inputNode.getChildElements()){
                if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SR_INDUSCLASSPRIORITY_CD)){
                    if(node.getText()!='' || node.getText() != null){
                        IndustrialClassificationPriorityCd = node.getText();
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SR_STDINDUSCLASSCD)){
                    if(node.getText()!='' || node.getText() != null){
                        StandardIndustrialClassificationCd = node.getText();
                    }
                }
                else if(node.getName().equalsIgnoreCase(Core_ConstantUtility.SR_STDINDUSCLASS_DESC)){
                    if(node.getText()!='' || node.getText() != null){
                        StandardIndustrialClassificationDesc = node.getText();
                    }
                }
            }
        }
    }
    
    
    public class finalWrapper{
        public SourceRecords sourceRecordWr;
        public Header headwr;
        public Snapshot snpWr;
        public MergeBusinessOrganization mbWr;
        public finalWrapper(){
            sourceRecordWr = null;
            headwr = null;
            snpWr = null;
            mbWr = null;
        }
    }
}