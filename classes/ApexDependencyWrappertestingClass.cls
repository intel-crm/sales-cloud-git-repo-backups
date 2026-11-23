public class ApexDependencyWrappertestingClass {
    public List<DependencyRecords> records {get; set;}
    public class DependencyRecords{
        //class being referred to
        public String RefMetadataComponentName {get; set;}
        //class relying on the above
        public String MetadataComponentName {get; set;}
    }
}