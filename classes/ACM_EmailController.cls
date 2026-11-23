public class ACM_EmailController {
    
    public List<NDAAccountWrapper> wrapperList { get; set; }
    
	public ACM_EmailController(List<NDAAccountWrapper> lst)
    {
        System.debug('ACM_EmailController lst'+lst);
        this.wrapperList = lst;
    }
    
    public ACM_EmailController(){}
    
    
    public class NDAAccountWrapper {
    public List<String> ndaList { get; set; }  // Store NDA information
    public String accountId { get; set; }  // Store Account ID

    // Constructor
    public NDAAccountWrapper(List<String> ndaList, String accountId) {
        this.ndaList = ndaList;
        this.accountId = accountId;
    }
	}

}