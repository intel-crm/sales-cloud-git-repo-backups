public with sharing class PMP_FetchAssetContent {
    public static List<ContentAsset> getContentAsset(Set<id> imageIds){
        
        List<ContentAsset> ca = new List<ContentAsset>();
            ca = [ Select ContentDocumentId,DeveloperName from ContentAsset where  ContentDocumentId IN :imageIds ];
        return ca;
    }

    public static List<ContentAsset> getContentAsset(List<id> imageIds){
        
        List<ContentAsset> ca = new List<ContentAsset>();
            ca = [ Select ContentDocumentId,DeveloperName from ContentAsset where  ContentDocumentId IN :imageIds ];
        return ca;
    }



    public static List<ContentAsset> getContentAsset(String imageIds){
        
        List<ContentAsset> ca = new List<ContentAsset>();
            ca = [ Select ContentDocumentId,DeveloperName from ContentAsset where  ContentDocumentId  =:imageIds ];
        return ca;
    }
}