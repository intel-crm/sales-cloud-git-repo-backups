global class PIMProduct_Model {
	public class TXT {
		public String label {get;set;} 
		public String value {get;set;} 
		public Boolean rawValue {get;set;} 
		public String toolTip {get;set;} 
		}
	
	public class EM64 {
		public String label {get;set;} 
		public String value {get;set;} 
		public Boolean rawValue {get;set;} 
		public String toolTip {get;set;} 
		public String disclaimer {get;set;} 
		
	}
    
    public class Cache {
		public String label {get;set;} 
		public String value {get;set;} 
		public Boolean rawValue {get;set;} 
		public String toolTip {get;set;} 
		public String disclaimer {get;set;} 

		
	}
	
	public class SortOrder {
		public String label {get;set;} 
		public String value {get;set;} 
		public Integer rawValue {get;set;} 

		
	}
	
	public class Links {
		public String self {get;set;} 

		
	}
	
	public class ARKPageURL {
		public String label {get;set;} 
		public String value {get;set;} 
		public String rawValue {get;set;} 

		
	}
	
	public class TCase {
		public String label {get;set;} 
		public String value {get;set;} 
		public String rawValue {get;set;} 
		public String toolTip {get;set;} 

		
	}
	
	public class Ark_Page_refresh {
		public String label {get;set;} 
		public String value {get;set;} 
		public Double rawValue {get;set;} 

		
	}
	
	
	public class MaxTDP {
		public String label {get;set;} 
		public String value {get;set;} 
		public Integer rawValue {get;set;} 
		public String toolTip {get;set;} 
		public String disclaimer {get;set;} 

		}
		
		public class Attributes {
		public TXT TXT {get;set;} 
		public TXT VTD {get;set;} 
		public TXT VTX {get;set;} 
		public EM64 EM64 {get;set;} 
		public Cache Cache {get;set;} 
		public TCase TCase {get;set;} 
		public Cache MaxMem {get;set;} 
		public MaxTDP MaxTDP {get;set;} 
		public EM64 AESTech {get;set;} 
		public TXT Embedded {get;set;} 
		public Cache CoreCount {get;set;} 
		public TXT ECCMemory {get;set;} 
		public SortOrder SortOrder {get;set;} 
		public ARKPageURL ARKPageURL {get;set;} 
		public MaxTDP BornOnDate {get;set;} 
		public Cache ClockSpeed {get;set;} 
		public MaxTDP TBTVersion {get;set;} 
		public ARKPageURL UPEPageURL {get;set;} 
		public Cache Lithography {get;set;} 
		public TCase MemoryTypes {get;set;} 
		public ARKPageURL PackageSize {get;set;} 
		public Cache ThreadCount {get;set;} 
		public SortOrder CodeNameText {get;set;} 
		public ARKPageURL DatasheetUrl {get;set;} 
		public SortOrder ProductGroup {get;set;} 
		public Cache ClockSpeedMax {get;set;} 
		public ARKPageURL FilterFamily {get;set;} 
		public ARKPageURL MarketSegment {get;set;} 
		public TXT ExecuteDisable {get;set;} 
		public EM64 HyperThreading {get;set;} 
		public SortOrder StatusCodeText {get;set;} 
		public TXT VProTechnology {get;set;} 
		public ARKPageURL FilterCodeName {get;set;} 
		public MaxTDP ProcessorNumber {get;set;} 
		public ARKPageURL ProductBriefUrl {get;set;} 
		public ARKPageURL ScalableSockets {get;set;} 
		public Ark_Page_refresh Ark_Page_refresh {get;set;} 
		public TCase SocketsSupported {get;set;} 
		public Ark_Page_refresh Sort_Change_Date {get;set;} 
		public ARKPageURL AdditionalInfoUrl {get;set;} 
		public SortOrder MemoryMaxSpeedMhz {get;set;} 
		public Cache NumMemoryChannels {get;set;} 
		public TXT ExtendedPageTables {get;set;} 
		public ARKPageURL FilterLithography {get;set;} 
		public Cache NumPCIExpressPorts {get;set;} 
		public Cache PCIExpressRevision {get;set;} 
		public TXT RetailSkuAvailable {get;set;} 
		public TCase OptaneMemorySupport {get;set;} 
		public TXT SpeedstepTechnology {get;set;} 
		public ARKPageURL FilterUseConditions {get;set;} 
		public ARKPageURL FilterVProtechnology {get;set;} 
		public TXT SpeedShiftTechVersion {get;set;} 
		public TCase CertifiedUseConditions {get;set;} 
		public ARKPageURL FilterIntelTechnology {get;set;} 
		public ARKPageURL FilterVerticalSegment {get;set;} 
		public ARKPageURL FilterSocketsSupported {get;set;} 
		public ARKPageURL TechnologyIndicatorList {get;set;} 
		public ARKPageURL FilterProcessorGraphics {get;set;} 
		public TCase InstructionSetExtensions {get;set;} 
		public TXT RunSureTechnologyVersion {get;set;} 
		public EM64 TurboBoostMaxTechVersion {get;set;} 
		public Cache UltraPathInterconnectLinks {get;set;} 
		public Cache AVX512FusedMultiplyAddUnits {get;set;} 
		public TXT VolumeManagementDeviceVersion {get;set;} 
		public ARKPageURL FilterInstructionSetExtensions {get;set;} 
		public ARKPageURL PublicOrderingandComplianceFlag {get;set;} 
		public TXT ModeBasedExecutionControlVersion {get;set;} 
		public TXT TransactionalSynchronizationExtensionVersion {get;set;} 
		}
	
 global class  PIMProduct {
	public String id {get;set;} 
	public String name {get;set;} 
	public String rawName {get;set;} 
	public String localizedName {get;set;} 
	public String description {get;set;} 
	public String thumbnail {get;set;} 
	public String manufacturer {get;set;} 
	public String onMarketDateTime {get;set;} 
	public Object skus {get;set;} 
	public List<String> categories {get;set;} 
	public String createdDateTime {get;set;} 
	public String updatedDateTime {get;set;} 
	public Integer marketingProductType {get;set;} 
	public Attributes attributes {get;set;} 
	public Links x_links {get;set;} 


}
	
	}