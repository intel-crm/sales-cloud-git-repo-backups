public with sharing class ImageController{

    public ImageController(ApexPages.StandardSetController controller) {
        fetchingImageUrl();
    }

 public String imageURL{get;set;}
   
  public void fetchingImageUrl()
  {
    imageURL='/servlet/servlet.FileDownload?file=';
    List< document > documentList=[select name from document where name='Maintenance.png'];
    system.debug('documentList==>'+documentList);
   
    if(documentList.size()>0)
    {
      imageURL=imageURL+documentList[0].id;
      system.debug('imageURL====>'+imageURL);
    }
  }
}